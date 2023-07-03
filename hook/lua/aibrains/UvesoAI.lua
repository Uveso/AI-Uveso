
local DefaultBrain = import("/lua/aibrain.lua").AIBrain
UvesoAIBrain = Class(DefaultBrain) {

    -- Hook AI-Uveso, set self.Uveso = true
    OnCreateAI = function(self, planName)
        DefaultBrain.OnCreateAI(self, planName)
        local per = ScenarioInfo.ArmySetup[self.Name].AIPersonality
        AILog('*! AI-Uveso: OnCreateAI() found AI-Uveso  Name: ('..self.Name..') - personality: ('..per..') ')
        self.Uveso = true
    end,

}
