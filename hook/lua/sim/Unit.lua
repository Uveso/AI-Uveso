
local TheOldUnit = Unit
Unit = Class(TheOldUnit) {

    -- prevent capturing
    OnStopBeingCaptured = function(self, captor)
        TheOldUnit.OnStopBeingCaptured(self, captor)
        local aiBrain = self:GetAIBrain()
        if aiBrain.Uveso then
            self:Kill()
        end
    end,

}
