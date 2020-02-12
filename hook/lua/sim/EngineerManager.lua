-- Don't disable units on low energy/mass for AI-Uveso

TheOldEngineerManager = EngineerManager
EngineerManager = Class(TheOldEngineerManager) {

-- For AI Patch V8 self:ForkEngineerTask(unit)
    AddUnit = function(self, unit, dontAssign)
        for k,v in self.ConsumptionUnits do
            if EntityCategoryContains(v.Category, unit) then
                table.insert(v.Units, { Unit = unit, Status = true })
                table.insert(v.UnitsList, unit)
                v.Count = v.Count + 1

                if not unit.BuilderManagerData then
                    unit.BuilderManagerData = {}
                end
                unit.BuilderManagerData.EngineerManager = self
                unit.BuilderManagerData.LocationType = self.LocationType

                if not unit.BuilderManagerData.CallbacksSetup then
                    unit.BuilderManagerData.CallbacksSetup = true
                    -- Callbacks here
                    local deathFunction = function(unit)
                        unit.BuilderManagerData.EngineerManager:RemoveUnit(unit)
                    end

                    import('/lua/scenariotriggers.lua').CreateUnitDestroyedTrigger(deathFunction, unit)

                    local newlyCapturedFunction = function(unit, captor)
                        local aiBrain = captor:GetAIBrain()
                        --LOG('*AI DEBUG: ENGINEER: I was Captured by '..aiBrain.Nickname..'!')
                        if aiBrain.BuilderManagers then
                            local engManager = aiBrain.BuilderManagers[captor.BuilderManagerData.LocationType].EngineerManager
                            if engManager then
                                engManager:AddUnit(unit)
                            end
                        end
                    end

                    import('/lua/scenariotriggers.lua').CreateUnitCapturedTrigger(nil, newlyCapturedFunction, unit)

                    if EntityCategoryContains(categories.ENGINEER, unit) then
                        local unitConstructionFinished = function(unit, finishedUnit)
                                                    -- Call function on builder manager; let it handle the finish of work
                                                    local aiBrain = unit:GetAIBrain()
                                                    local engManager = aiBrain.BuilderManagers[unit.BuilderManagerData.LocationType].EngineerManager
                                                    if engManager then
                                                        engManager:UnitConstructionFinished(unit, finishedUnit)
                                                    end
                        end
                        import('/lua/ScenarioTriggers.lua').CreateUnitBuiltTrigger(unitConstructionFinished, unit, categories.ALLUNITS)

                        local unitConstructionStarted = function(unit, unitBeingBuilt)
                                                    local aiBrain = unit:GetAIBrain()
                                                    local engManager = aiBrain.BuilderManagers[unit.BuilderManagerData.LocationType].EngineerManager
                                                    if engManager then
                                                        engManager:UnitConstructionStarted(unit, unitBeingBuilt)
                                                    end
                        end
                        import('/lua/ScenarioTriggers.lua').CreateStartBuildTrigger(unitConstructionStarted, unit, categories.ALLUNITS)
                    end
                end

                if not dontAssign then
                    self:ForkEngineerTask(unit)
                end

                return
            end
        end
    end,
-- For AI Patch V8 self:ForkEngineerTask(unit)
    TaskFinished = function(self, unit)
        --LOG('+ TaskFinished')
        if VDist3(self.Location, unit:GetPosition()) > self.Radius and not EntityCategoryContains(categories.COMMAND, unit) then
            self:ReassignUnit(unit)
        else
            self:ForkEngineerTask(unit)
        end
    end,
-- For AI Patch V8 KillThread
    ForkEngineerTask = function(manager, unit)
        --LOG('+ ForkEngineerTask')
        if unit.ForkedEngineerTask then
            KillThread(unit.ForkedEngineerTask)
            unit.ForkedEngineerTask = unit:ForkThread(manager.Wait, manager, 3)
        else
            unit.ForkedEngineerTask = unit:ForkThread(manager.Wait, manager, 20)
        end
    end,
-- For AI Patch V8 KillThread
    DelayAssign = function(manager, unit, delaytime)
        --LOG('+ DelayAssign')
        if unit.ForkedEngineerTask then
            KillThread(unit.ForkedEngineerTask)
        end
        unit.ForkedEngineerTask = unit:ForkThread(manager.Wait, manager, delaytime or 10)
    end,
-- For AI Patch V8 manager:AssignEngineerTask(unit)
    Wait = function(unit, manager, ticks)
        --LOG('+ Wait')
        coroutine.yield(ticks)
        if not unit.Dead then
            manager:AssignEngineerTask(unit)
        end
    end,
-- For AI Patch V8 self:ForkEngineerTask(unit)
    AssignEngineerTask = function(self, unit)
        --LOG('+ AssignEngineerTask')
        if unit.UnitBeingAssist or unit.UnitBeingBuilt then
            self:DelayAssign(unit, 50)
            return
        end

        unit.DesiresAssist = false
        unit.NumAssistees = nil
        unit.MinNumAssistees = nil

        if self.AssigningTask then
            self:DelayAssign(unit, 50)
            return
        else
            self.AssigningTask = true
        end

        local builder = self:GetHighestBuilder('Any', {unit})
        if builder then
            -- Fork off the platoon here
            local template = self:GetEngineerPlatoonTemplate(builder:GetPlatoonTemplate())
            local hndl = self.Brain:MakePlatoon(template[1], template[2])
            self.Brain:AssignUnitsToPlatoon(hndl, {unit}, 'support', 'none')
            unit.PlatoonHandle = hndl

            --if EntityCategoryContains(categories.COMMAND, unit) then
            --    LOG('*AI DEBUG: ARMY '..self.Brain.Nickname..': Engineer Manager Forming - '..builder.BuilderName..' - Priority: '..builder:GetPriority())
            --end

            --LOG('*AI DEBUG: ARMY ', repr(self.Brain:GetArmyIndex()),': Engineer Manager Forming - ',repr(builder.BuilderName),' - Priority: ', builder:GetPriority())
            hndl.PlanName = template[2]

            --If we have specific AI, fork that AI thread
            if builder:GetPlatoonAIFunction() then
                hndl:StopAI()
                local aiFunc = builder:GetPlatoonAIFunction()
                hndl:ForkAIThread(import(aiFunc[1])[aiFunc[2]])
            end
            if builder:GetPlatoonAIPlan() then
                hndl.PlanName = builder:GetPlatoonAIPlan()
                hndl:SetAIPlan(hndl.PlanName)
            end

            --If we have additional threads to fork on the platoon, do that as well.
            if builder:GetPlatoonAddPlans() then
                for papk, papv in builder:GetPlatoonAddPlans() do
                    hndl:ForkThread(hndl[papv])
                end
            end

            if builder:GetPlatoonAddFunctions() then
                for pafk, pafv in builder:GetPlatoonAddFunctions() do
                    hndl:ForkThread(import(pafv[1])[pafv[2]])
                end
            end

            if builder:GetPlatoonAddBehaviors() then
                for pafk, pafv in builder:GetPlatoonAddBehaviors() do
                    hndl:ForkThread(import('/lua/ai/AIBehaviors.lua')[pafv])
                end
            end

            hndl.Priority = builder:GetPriority()
            hndl.BuilderName = builder:GetBuilderName()

            hndl:SetPlatoonData(builder:GetBuilderData(self.LocationType))

            if hndl.PlatoonData.DesiresAssist then
                unit.DesiresAssist = hndl.PlatoonData.DesiresAssist
            else
                unit.DesiresAssist = true
            end

            if hndl.PlatoonData.NumAssistees then
                unit.NumAssistees = hndl.PlatoonData.NumAssistees
            end

            if hndl.PlatoonData.MinNumAssistees then
                unit.MinNumAssistees = hndl.PlatoonData.MinNumAssistees
            end

            builder:StoreHandle(hndl)
            self.AssigningTask = false
            return
        end
        self.AssigningTask = false
        self:DelayAssign(unit, 50)
    end,

    -- Hook For AI-Uveso. Don't need this, we have our own ecomanagement
    LowMass = function(self)
        -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return TheOldEngineerManager.LowMass(self)
        end
    end,

    -- Hook For AI-Uveso. Don't need this, we have our own ecomanagement
    LowEnergy = function(self)
        -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return TheOldEngineerManager.LowEnergy(self)
        end
    end,

}
