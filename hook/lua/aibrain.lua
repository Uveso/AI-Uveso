
OldAIBrainClass = AIBrain
AIBrain = Class(OldAIBrainClass) {

    BaseMonitorThread = function(self)
       -- Only use this with AI-Uveso
        if not self.Uveso then
            return OldAIBrainClass.BaseMonitorThread(self)
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

   SetupAttackVectorsThread = function(self)
       -- Only use this with AI-Uveso
        if not self.Uveso then
            return OldAIBrainClass.SetupAttackVectorsThread(self)
        end
        WaitTicks(10)
        -- We are leaving this forked thread here because we don't need it.
        KillThread(CurrentThread())
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
