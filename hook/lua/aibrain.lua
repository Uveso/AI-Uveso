
UvesoAIBrainClass = AIBrain
AIBrain = Class(UvesoAIBrainClass) {

    -- For AI Patch V8 add BaseType for function GetManagerCount
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

    -- For AI Patch V8. patch for faster location search, needs AddBuilderManagers
    GetManagerCount = function(self, type)
        local count = 0
        for k, v in self.BuilderManagers do
            if not v.BaseType then
                continue
            end
            if type then
                if type == 'Start Location' and v.BaseType ~= 'MAIN' and v.BaseType ~= 'Blank Marker' then
                    continue
                elseif type == 'Naval Area' and v.BaseType ~= 'Naval Area' then
                    continue
                elseif type == 'Expansion Area' and v.BaseType ~= 'Expansion Area' and v.BaseType ~= 'Large Expansion Area' then
                    continue
                end
            end

            if v.EngineerManager:GetNumCategoryUnits('Engineers', categories.ALLUNITS) <= 0 and v.FactoryManager:GetNumCategoryFactories(categories.ALLUNITS) <= 0 then
                continue
            end

            count = count + 1
        end
        return count
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
