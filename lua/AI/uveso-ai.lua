
local UvesoAIBrainClass = import("/lua/aibrains/base-ai.lua").AIBrain

AIBrain = Class(UvesoAIBrainClass) {

     -- Hook AI-Uveso, set self.Uveso = true
     OnCreateAI = function(self, planName)
         UvesoAIBrainClass.OnCreateAI(self, planName)
         local per = ScenarioInfo.ArmySetup[self.Name].AIPersonality
         if string.find(per, 'uveso') then
             AILog('* AI-Uveso: OnCreateAI() found AI-Uveso  Name: ('..self.Name..') - personality: ('..per..') ')
             self.Uveso = true
         end
     end,

     BaseMonitorThread = function(self)
         coroutine.yield(10)
         -- We are leaving this forked thread here because we don't need it.
         KillThread(CurrentThread())
     end,

     CanPathToCurrentEnemy = function(self)
         coroutine.yield(10)
         -- We are leaving this forked thread here because we don't need it.
         KillThread(CurrentThread())
     end,

     EconomyMonitor = function(self)
         coroutine.yield(10)
         -- We are leaving this forked thread here because we don't need it.
         KillThread(self.EconomyMonitorThread)
         self.EconomyMonitorThread = nil
     end,

}
