
local UvesoUnit = Unit
Unit = Class(UvesoUnit) {

    -- Hook For AI-Uveso. prevent capturing
    OnStopBeingCaptured = function(self, captor)
        UvesoUnit.OnStopBeingCaptured(self, captor)
        local aiBrain = self:GetAIBrain()
        if aiBrain.Uveso then
            self:Kill()
        end
    end,

}
