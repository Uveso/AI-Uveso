
OldAIBrainClass = AIBrain
AIBrain = Class(OldAIBrainClass) {

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
