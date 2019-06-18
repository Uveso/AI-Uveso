
OldAIBrainClass = AIBrain
AIBrain = Class(OldAIBrainClass) {

    -- For AI Patch V5 (patched). patch for missing StrategyManager
    OnDefeat = function(self)
        self:SetResult("defeat")

        -- For Sorian AI
        if self.BrainType == 'AI' then
            SUtils.AISendChat('enemies', ArmyBrains[self:GetArmyIndex()].Nickname, 'ilost')
        end

        SetArmyOutOfGame(self:GetArmyIndex())

        import('/lua/SimUtils.lua').UpdateUnitCap(self:GetArmyIndex())
        import('/lua/SimPing.lua').OnArmyDefeat(self:GetArmyIndex())

        local function KillArmy()
            local shareOption = ScenarioInfo.Options.Share

            local function KillWalls()
                -- Kill all walls while the ACU is blowing up
                local tokill = self:GetListOfUnits(categories.WALL, false)
                if tokill and table.getn(tokill) > 0 then
                    for index, unit in tokill do
                        unit:Kill()
                    end
                end
            end

            if shareOption == 'ShareUntilDeath' then
                ForkThread(KillWalls)
            end

            WaitSeconds(10) -- Wait for commander explosion, then transfer units.
            local selfIndex = self:GetArmyIndex()
            local shareOption = ScenarioInfo.Options.Share
            local victoryOption = ScenarioInfo.Options.Victory
            local BrainCategories = {Enemies = {}, Civilians = {}, Allies = {}}

            -- Used to have units which were transferred to allies noted permanently as belonging to the new player
            local function TransferOwnershipOfBorrowedUnits(brains)
                for index, brain in brains do
                    local units = brain:GetListOfUnits(categories.ALLUNITS, false)
                    if units and table.getn(units) > 0 then
                        for _, unit in units do
                            if unit.oldowner == selfIndex then
                                unit.oldowner = nil
                            end
                        end
                    end
                end
            end

            -- Used to remove unique platoon handles from Sorian AI units
            local function RemovePlatoonHandleFromUnit(units)
                if not self.Sorian then return end

                for _, unit in units do
                    if not unit.Dead then
                        if unit.PlatoonHandle and self:PlatoonExists(unit.PlatoonHandle) then
                            unit.PlatoonHandle:Stop()
                            unit.PlatoonHandle:PlatoonDisbandNoAssign()
                        end
                        IssueStop({unit})
                        IssueClearCommands({unit})
                    end
                end
            end

            -- Transfer our units to other brains. Wait in between stops transfer of the same units to multiple armies.
            local function TransferUnitsToBrain(brains)
                if table.getn(brains) > 0 then
                    if shareOption == 'FullShare' then 
                        local indexes = {}
                        for _, brain in brains do 
                            table.insert(indexes, brain.index)
                        end 
                        local units = self:GetListOfUnits(categories.ALLUNITS - categories.WALL - categories.COMMAND, false)
                        TransferUnfinishedUnitsAfterDeath(units, indexes)
                    end
                    
                    for k, brain in brains do
                        local units = self:GetListOfUnits(categories.ALLUNITS - categories.WALL - categories.COMMAND, false)
                        if units and table.getn(units) > 0 then

                            RemovePlatoonHandleFromUnit(units)

                            TransferUnitsOwnership(units, brain.index)
                            WaitSeconds(1)
                        end
                    end
                end
            end

            -- Sort the destiniation armies by score
            local function TransferUnitsToHighestBrain(brains)
                if table.getn(brains) > 0 then
                    table.sort(brains, function(a, b) return a.score > b.score end)
                    TransferUnitsToBrain(brains)
                end
            end

            -- Transfer units to the player who killed me
            local function TransferUnitsToKiller()
                local KillerIndex = 0
                local units = self:GetListOfUnits(categories.ALLUNITS - categories.WALL - categories.COMMAND, false)
                if units and table.getn(units) > 0 then

                    RemovePlatoonHandleFromUnit(units)

                    if victoryOption == 'demoralization' then
                        KillerIndex = ArmyBrains[selfIndex].CommanderKilledBy or selfIndex
                        TransferUnitsOwnership(units, KillerIndex)
                    else
                        KillerIndex = ArmyBrains[selfIndex].LastUnitKilledBy or selfIndex
                        TransferUnitsOwnership(units, KillerIndex)
                    end
                end
                WaitSeconds(1)
            end

            -- Return units transferred during the game to me
            local function ReturnBorrowedUnits()
                local units = self:GetListOfUnits(categories.ALLUNITS - categories.WALL, false)

                RemovePlatoonHandleFromUnit(units)

                local borrowed = {}
                for index, unit in units do
                    local oldowner = unit.oldowner
                    if oldowner and oldowner ~= self:GetArmyIndex() and not GetArmyBrain(oldowner):IsDefeated() then
                        if not borrowed[oldowner] then
                            borrowed[oldowner] = {}
                        end
                        table.insert(borrowed[oldowner], unit)
                    end
                end

                for owner, units in borrowed do
                    TransferUnitsOwnership(units, owner)
                end

                WaitSeconds(1)
            end

            -- Return units I gave away to my control. Mainly needed to stop EcoManager mods bypassing all this stuff with auto-give
            local function GetBackUnits(brains)
                local given = {}
                for index, brain in brains do
                    local units = brain:GetListOfUnits(categories.ALLUNITS - categories.WALL, false)
                    if units and table.getn(units) > 0 then
                        for _, unit in units do
                            if unit.oldowner == selfIndex then -- The unit was built by me
                                table.insert(given, unit)
                                unit.oldowner = nil
                            end
                        end
                    end
                end

                TransferUnitsOwnership(given, selfIndex)
            end

            -- Sort brains out into mutually exclusive categories
            for index, brain in ArmyBrains do
                brain.index = index
                brain.score = CalculateBrainScore(brain)

                if not brain:IsDefeated() and selfIndex ~= index then
                    if ArmyIsCivilian(index) then
                        table.insert(BrainCategories.Civilians, brain)
                    elseif IsEnemy(selfIndex, brain:GetArmyIndex()) then
                        table.insert(BrainCategories.Enemies, brain)
                    else
                        table.insert(BrainCategories.Allies, brain)
                    end
                end
            end

            local KillSharedUnits = import('/lua/SimUtils.lua').KillSharedUnits

            -- This part determines the share condition
            if shareOption == 'ShareUntilDeath' then
                KillSharedUnits(self:GetArmyIndex()) -- Kill things I gave away
                ReturnBorrowedUnits() -- Give back things I was given by others
            elseif shareOption == 'FullShare' then
                TransferUnitsToHighestBrain(BrainCategories.Allies) -- Transfer things to allies, highest score first
                TransferOwnershipOfBorrowedUnits(BrainCategories.Allies) -- Give stuff away permanently
            else
                GetBackUnits(BrainCategories.Allies) -- Get back units I gave away
                if shareOption == 'CivilianDeserter' then
                    TransferUnitsToBrain(BrainCategories.Civilians)
                elseif shareOption == 'TransferToKiller' then
                    TransferUnitsToKiller()
                elseif shareOption == 'Defectors' then
                    TransferUnitsToHighestBrain(BrainCategories.Enemies)
                else -- Something went wrong in settings. Act like share until death to avoid abuse
                    WARN('Invalid share condition was used for this game. Defaulting to killing all units')
                    KillSharedUnits(self:GetArmyIndex()) -- Kill things I gave away
                    ReturnBorrowedUnits() -- Give back things I was given by other
                end
            end

            -- Kill all units left over
            local tokill = self:GetListOfUnits(categories.ALLUNITS - categories.WALL, false)
            if tokill and table.getn(tokill) > 0 then
                for index, unit in tokill do
                    unit:Kill()
                end
            end
        end

        ForkThread(KillArmy)

        if self.BuilderManagers then
            self.ConditionsMonitor:Destroy()
            for k, v in self.BuilderManagers do
                v.EngineerManager:SetEnabled(false)
                v.EngineerManager:Destroy()
                v.FactoryManager:SetEnabled(false)
                v.FactoryManager:Destroy()
                v.PlatoonFormManager:SetEnabled(false)
                v.PlatoonFormManager:Destroy()
                if v.StrategyManager then
                    v.StrategyManager:SetEnabled(false)
                    v.StrategyManager:Destroy()
                end
                self.BuilderManagers[k] = nil
            end
        end
        
        -- delete the pathcache
        self.PathCache = nil

        if self.Trash then
            self.Trash:Destroy()
        end
    end,

    -- For AI Patch V5 (patched). patch for missing StrategyManager
    DeadBaseMonitor = function(self)
        while true do
            WaitSeconds(5)
            local needSort = false
            for k, v in self.BuilderManagers do
                if k ~= 'MAIN' and v.EngineerManager:GetNumCategoryUnits('Engineers', categories.ALLUNITS) <= 0 and v.FactoryManager:GetNumCategoryFactories(categories.ALLUNITS) <= 0 then
                    v.EngineerManager:SetEnabled(false)
                    v.EngineerManager:Destroy()
                    v.FactoryManager:SetEnabled(false)
                    v.FactoryManager:Destroy()
                    v.PlatoonFormManager:SetEnabled(false)
                    v.PlatoonFormManager:Destroy()
                    if v.StrategyManager then
                        v.StrategyManager:SetEnabled(false)
                        v.StrategyManager:Destroy()
                    end
                    self.BuilderManagers[k] = nil
                    self.NumBases = self.NumBases - 1
                    needSort = true
                end
            end
            if needSort then
                self.BuilderManagers = self:RebuildTable(self.BuilderManagers)
            end
        end
    end,

    -- AI-Uveso. Removing the StrategyManager
    AddBuilderManagers = function(self, position, radius, baseName, useCenter)
       -- Only use this with AI-Uveso
        if not self.Uveso then
            return OldAIBrainClass.AddBuilderManagers(self, position, radius, baseName, useCenter)
        end
        self.BuilderManagers[baseName] = {
            FactoryManager = FactoryManager.CreateFactoryBuilderManager(self, baseName, position, radius, useCenter),
            PlatoonFormManager = PlatoonFormManager.CreatePlatoonFormManager(self, baseName, position, radius, useCenter),
            EngineerManager = EngineerManager.CreateEngineerManager(self, baseName, position, radius),
            -- Only Sorian is using the StrategyManager
            --StrategyManager = StratManager.CreateStrategyManager(self, baseName, position, radius),

            -- Table to track consumption
            MassConsumption = {
                Resources = {Units = {}, Drain = 0, },
                Units = {Units = {}, Drain = 0, },
                Defenses = {Units = {}, Drain = 0, },
                Upgrades = {Units = {}, Drain = 0, },
                Engineers = {Units = {}, Drain = 0, },
                TotalDrain = 0,
            },
            BuilderHandles = {},
            Position = position,
        }
        self.NumBases = self.NumBases + 1
    end,

    BaseMonitorThread = function(self)
       -- Only use this with AI-Uveso
        if not self.Uveso then
            return OldAIBrainClass.BaseMonitorThread(self)
        end
        WaitTicks(10)
        -- We are leaving this forked thread here because we don't need it.
        KillThread(CurrentThread())
    end,

    EconomyMonitor = function(self)
        -- Only use this with AI-Uveso
        if not self.Uveso then
            return OldAIBrainClass.EconomyMonitor(self)
        end
        WaitTicks(10)
        -- We are leaving this forked thread here because we don't need it.
        KillThread(self.EconomyMonitorThread)
        self.EconomyMonitorThread = nil
    end,

   ExpansionHelpThread = function(self)
       -- Only use this with AI-Uveso
        if not self.Uveso then
            return OldAIBrainClass.ExpansionHelpThread(self)
        end
        WaitTicks(10)
        -- We are leaving this forked thread here because we don't need it.
        KillThread(CurrentThread())
    end,

    InitializeEconomyState = function(self)
        -- Only use this with AI-Uveso
        if not self.Uveso then
            return OldAIBrainClass.InitializeEconomyState(self)
        end
    end,

    OnIntelChange = function(self, blip, reconType, val)
        -- Only use this with AI-Uveso
        if not self.Uveso then
            return OldAIBrainClass.OnIntelChange(self, blip, reconType, val)
        end
    end,

    SetupAttackVectorsThread = function(self)
       -- Only use this with AI-Uveso
        if not self.Uveso then
            return OldAIBrainClass.SetupAttackVectorsThread(self)
        end
        WaitTicks(10)
        -- We are leaving this forked thread here because we don't need it.
        KillThread(CurrentThread())
    end,

    ParseIntelThread = function(self)
       -- Only use this with AI-Uveso
        if not self.Uveso then
            return OldAIBrainClass.ParseIntelThread(self)
        end
        WaitTicks(10)
        -- We are leaving this forked thread here because we don't need it.
        KillThread(CurrentThread())
    end,

}
