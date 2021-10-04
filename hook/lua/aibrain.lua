
UvesoAIBrainClass = AIBrain
AIBrain = Class(UvesoAIBrainClass) {

    -- Hook AI-Uveso. Removing the StrategyManager
    AddBuilderManagers = function(self, position, radius, baseName, useCenter)
       -- Only use this with AI-Uveso
        if not self.Uveso then
            return UvesoAIBrainClass.AddBuilderManagers(self, position, radius, baseName, useCenter)
        end
        self.BuilderManagers[baseName] = {
            FactoryManager = FactoryManager.CreateFactoryBuilderManager(self, baseName, position, radius, useCenter),
            PlatoonFormManager = PlatoonFormManager.CreatePlatoonFormManager(self, baseName, position, radius, useCenter),
            EngineerManager = EngineerManager.CreateEngineerManager(self, baseName, position, radius),
            -- Only Sorian is using the StrategyManager
            --StrategyManager = StratManager.CreateStrategyManager(self, baseName, position, radius),

            -- Table to track consumption
            -- can be removed after game patch is released
            -- https://github.com/FAForever/fa/pull/3281
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
            BaseType = Scenario.MasterChain._MASTERCHAIN_.Markers[baseName].type or 'MAIN',
        }
        self.NumBases = self.NumBases + 1
    end,

    -- For AI Patch V9. remove AI tables and functions on defeat; destroying first Buildmanager then condition manager
    OnDefeat = function(self)
        self:SetResult("defeat")

        SetArmyOutOfGame(self:GetArmyIndex())

        import('/lua/SimUtils.lua').UpdateUnitCap(self:GetArmyIndex())
        import('/lua/SimPing.lua').OnArmyDefeat(self:GetArmyIndex())

        local function KillArmy()
            local shareOption = ScenarioInfo.Options.Share

            if shareOption == 'ShareUntilDeath' then
                -- Kill all walls while the ACU is blowing up
                local tokill = self:GetListOfUnits(categories.WALL, false)
                if tokill and table.getn(tokill) > 0 then
                    for index, unit in tokill do
                        unit:Kill()
                    end
                end
            end

            WaitSeconds(10) -- Wait for commander explosion, then transfer units.
            local selfIndex = self:GetArmyIndex()
            local shareOption = ScenarioInfo.Options.Share
            local victoryOption = ScenarioInfo.Options.Victory
            local BrainCategories = {Enemies = {}, Civilians = {}, Allies = {}}

            -- AI Start

            if self.BrainType == 'AI' then
                -- print AI "ilost" text to chat
                SUtils.AISendChat('enemies', ArmyBrains[self:GetArmyIndex()].Nickname, 'ilost')
                -- Stop the AI from executing AI plans
                self.RepeatExecution = false
                -- remove PlatoonHandle from all AI units before we kill / transfer the army
                local units = self:GetListOfUnits(categories.ALLUNITS - categories.WALL, false)
                if units and table.getn(units) > 0 then
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
                coroutine.yield(3)
                -- removing AI BrainConditionMonitorThread
                if self.ConditionsMonitor.ConditionMonitor then
                    KillThread(self.ConditionsMonitor.ConditionMonitor)
                end
                coroutine.yield(3)
                -- stop AI BuilderManagers
                if self.BuilderManagers then
                    for k, v in self.BuilderManagers do
                        v.EngineerManager:SetEnabled(false)
                        v.FactoryManager:SetEnabled(false)
                        v.PlatoonFormManager:SetEnabled(false)
                        if v.StrategyManager then
                            v.StrategyManager:SetEnabled(false)
                        end
                    end
                end
                -- remove ArmyStatsTrigger
                self:RemoveArmyStatsTrigger('Economy_Ratio_Mass', 'EconLowMassStore')
                self:RemoveArmyStatsTrigger('Economy_Ratio_Energy', 'EconLowEnergyStore')
            end

            -- AI End

            -- Used to have units which were transferred to allies noted permanently as belonging to the new player
            local function TransferOwnershipOfBorrowedUnits(brains)
                for index, brain in brains do
                    local units = brain:GetListOfUnits(categories.ALLUNITS, false)
                    if units and not table.empty(units) then
                        for _, unit in units do
                            if unit.oldowner == selfIndex then
                                unit.oldowner = nil
                            end
                        end
                    end
                end
            end

            -- Transfer our units to other brains. Wait in between stops transfer of the same units to multiple armies.
            local function TransferUnitsToBrain(brains)
                if not table.empty(brains) then
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
                        if units and not table.empty(units) then
                            TransferUnitsOwnership(units, brain.index)
                            WaitSeconds(1)
                        end
                    end
                end
            end

            -- Sort the destiniation armies by score
            local function TransferUnitsToHighestBrain(brains)
                if not table.empty(brains) then
                    table.sort(brains, function(a, b) return a.score > b.score end)
                    TransferUnitsToBrain(brains)
                end
            end

            -- Transfer units to the player who killed me
            local function TransferUnitsToKiller()
                local KillerIndex = 0
                local units = self:GetListOfUnits(categories.ALLUNITS - categories.WALL - categories.COMMAND, false)
                if units and not table.empty(units) then
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
                    if units and not table.empty(units) then
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
            if tokill and not table.empty(tokill) then
                for index, unit in tokill do
                    unit:Kill()
                end
            end

            -- AI Start

            if self.BrainType == 'AI' then
                coroutine.yield(3)
                -- removing AI BuilderManagers
                if self.BuilderManagers then
                    for k, v in self.BuilderManagers do
                        v.EngineerManager:Destroy()
                        v.FactoryManager:Destroy()
                        v.PlatoonFormManager:Destroy()
                        if v.StrategyManager then
                            v.StrategyManager:Destroy()
                        end
                        self.BuilderManagers[k].EngineerManager = nil
                        self.BuilderManagers[k].FactoryManager = nil
                        self.BuilderManagers[k].PlatoonFormManager = nil
                        self.BuilderManagers[k].BaseSettings = nil
                        self.BuilderManagers[k].BuilderHandles = nil
                    end
                end
                coroutine.yield(3)
                -- removing AI BrainConditionsMonitor
                if self.ConditionsMonitor then
                    self.ConditionsMonitor:Destroy()
                end
                -- delete the AI pathcache
                self.PathCache = {}
                -- remove EconState tabes
                self.EconMassStorageState = {}
                self.EconEnergyStorageState = {}
                self.EconStorageTrigs = {}
                -- remove remaining tables
                self.BuilderManagers = {}
                self.CurrentPlan = {}
                self.PlatoonNameCounter = {}
                self.BaseTemplates = {}
                self.IntelData = {}
                self.UnitBuiltTriggerList = {}
                self.FactoryAssistList = {}
                self.DelayEqualBuildPlattons = {}
                self.AIPlansList = {}
                self.IntelTriggerList = {}
                self.VeterancyTriggerList = {}
                self.PingCallbackList = {}
                self.UnitBuiltTriggerList = {}
                self.VOTable = {}
            end

            -- AI End

            if self.Trash then
                self.Trash:Destroy()
            end
        end

        -- the whole KillThread is forked here, so we can continue the game while removing/transfering the dead army
        ForkThread(KillArmy)

    end,

    -- Hook AI-Uveso, set self.Uveso = true
    OnCreateAI = function(self, planName)
        UvesoAIBrainClass.OnCreateAI(self, planName)
        local per = ScenarioInfo.ArmySetup[self.Name].AIPersonality
        if string.find(per, 'uveso') then
            LOG('* AI-Uveso: OnCreateAI() found AI-Uveso  Name: ('..self.Name..') - personality: ('..per..') ')
            self.Uveso = true
        end
    end,

    BaseMonitorThread = function(self)
       -- Only use this with AI-Uveso
        if not self.Uveso then
            return UvesoAIBrainClass.BaseMonitorThread(self)
        end
        coroutine.yield(10)
        -- We are leaving this forked thread here because we don't need it.
        KillThread(CurrentThread())
    end,

    EconomyMonitor = function(self)
        -- Only use this with AI-Uveso
        if not self.Uveso then
            return UvesoAIBrainClass.EconomyMonitor(self)
        end
        coroutine.yield(10)
        -- We are leaving this forked thread here because we don't need it.
        KillThread(self.EconomyMonitorThread)
        self.EconomyMonitorThread = nil
    end,

   ExpansionHelpThread = function(self)
       -- Only use this with AI-Uveso
        if not self.Uveso then
            return UvesoAIBrainClass.ExpansionHelpThread(self)
        end
        coroutine.yield(10)
        -- We are leaving this forked thread here because we don't need it.
        KillThread(CurrentThread())
    end,

    InitializeEconomyState = function(self)
        -- Only use this with AI-Uveso
        if not self.Uveso then
            return UvesoAIBrainClass.InitializeEconomyState(self)
        end
    end,

    OnIntelChange = function(self, blip, reconType, val)
        -- Only use this with AI-Uveso
        if not self.Uveso then
            return UvesoAIBrainClass.OnIntelChange(self, blip, reconType, val)
        end
    end,

    SetupAttackVectorsThread = function(self)
       -- Only use this with AI-Uveso
        if not self.Uveso then
            return UvesoAIBrainClass.SetupAttackVectorsThread(self)
        end
        coroutine.yield(10)
        -- We are leaving this forked thread here because we don't need it.
        KillThread(CurrentThread())
    end,

    ParseIntelThread = function(self)
       -- Only use this with AI-Uveso
        if not self.Uveso then
            return UvesoAIBrainClass.ParseIntelThread(self)
        end
        coroutine.yield(10)
        -- We are leaving this forked thread here because we don't need it.
        KillThread(CurrentThread())
    end,

}
