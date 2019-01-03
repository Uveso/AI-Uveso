
TheOldAIBrain = AIBrain
AIBrain = Class(TheOldAIBrain) {

    BaseMonitorThread = function(self)
       -- Only use this with AI-Uveso
        if not self.Uveso then
            return TheOldAIBrain.BaseMonitorThread(self)
        end
        WaitTicks(10)
        -- We are leaving this forked thread here because we don't need it.
    end,

    ParseIntelThread = function(self)
        -- Only use this with AI-Uveso
        if not self.Uveso then
            return TheOldAIBrain.ParseIntelThread(self)
        end
        WaitTicks(10)
        -- We are leaving this forked thread here because we don't need it.
    end,

    EconomyMonitor = function(self)
        -- Only use this with AI-Uveso
        if not self.Uveso then
            return TheOldAIBrain.EconomyMonitor(self)
        end
        WaitTicks(10)
        -- We are leaving this forked thread here because we don't need it.
    end,

}
