-- Don't disable units on low energy/mass for AI-Uveso

TheOldEngineerManager = EngineerManager
EngineerManager = Class(TheOldEngineerManager) {

    LowMass = function(self)
        -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return TheOldEngineerManager.LowMass(self)
        end
    end,

    LowEnergy = function(self)
        -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return TheOldEngineerManager.LowEnergy(self)
        end
    end,

    -- For AI Patch V4. (patched)
    AssignEngineerTask = function(self, unit)
        unit.LastActive = GetGameTimeSeconds()
        if unit.UnitBeingAssist or unit.UnitBeingBuilt then
            self:DelayAssign(self, unit)
            return
        end

        unit.DesiresAssist = false
        unit.NumAssistees = nil
        unit.MinNumAssistees = nil

        if self.AssigningTask then
            self:DelayAssign(self, unit)
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
        self:ForkThread(self.EngineerWaiting, unit)
    end,
}
