
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

    -- debug, Pring the unit name in case bp.BuildCostEnergy or bp.BuildTime is nil
    CreateEnhancementEffects = function(self, enhancement)
        local bp = self:GetBlueprint().Enhancements[enhancement]
        local effects = TrashBag()
        if not bp.BuildCostEnergy then
            WARN('Unit ['..self.UnitId..'] has no BuildCostEnergy in enhancement ['..enhancement..'] - '..repr( self:GetBlueprint().General.UnitName or "Unknown name" )..' - '..repr( LOC(self:GetBlueprint().Description or "Unknown description" ))..' ')
        end
        if not bp.BuildTime then
            WARN('Unit ['..self.UnitId..'] has no BuildTime in enhancement ['..enhancement..'] - '..repr( self:GetBlueprint().General.UnitName or "Unknown name" )..' - '..repr( LOC(self:GetBlueprint().Description or "Unknown description" ))..' ')
        end
        local scale = math.min(4, math.max(1, (bp.BuildCostEnergy / bp.BuildTime or 1) / 50))

        if bp.UpgradeEffectBones then
            for _, v in bp.UpgradeEffectBones do
                if self:IsValidBone(v) then
                    EffectUtilities.CreateEnhancementEffectAtBone(self, v, self.UpgradeEffectsBag)
                end
            end
        end

        if bp.UpgradeUnitAmbientBones then
            for _, v in bp.UpgradeUnitAmbientBones do
                if self:IsValidBone(v) then
                    EffectUtilities.CreateEnhancementUnitAmbient(self, v, self.UpgradeEffectsBag)
                end
            end
        end

        for _, e in effects do
            e:ScaleEmitter(scale)
            self.UpgradeEffectsBag:Add(e)
        end
    end,

}
