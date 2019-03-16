
local OldUnitClass = Unit
Unit = Class(OldUnitClass) {

    -- prevent capturing
    OnStopBeingCaptured = function(self, captor)
        OldUnitClass.OnStopBeingCaptured(self, captor)
        local aiBrain = self:GetAIBrain()
        if aiBrain.Uveso then
            self:Kill()
        end
    end,

}
