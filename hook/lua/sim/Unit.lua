
local oldUnit = Unit
Unit = Class(oldUnit) {

    -- prevent capturing
    OnStopBeingCaptured = function(self, captor)
        oldUnit.OnStopBeingCaptured(self, captor)
        local aiBrain = self:GetAIBrain()
        if aiBrain.Uveso then
            self:Kill()
        end
    end,

}
