-- This is for debug Option Platoon-Names

OLDFactoryBuilderManager = FactoryBuilderManager
FactoryBuilderManager = Class(OLDFactoryBuilderManager) {

    AssignBuildOrder = function(self,factory,bType)
        if factory.Dead then
            return
        end
        local builder = self:GetHighestBuilder(bType,{factory})
        if builder then
            local personality = self.Brain:GetPersonality()
            local template = self:GetFactoryTemplate(builder:GetPlatoonTemplate(), factory)
            -- rename factory to actual build-platoon name
            if self.Brain[ScenarioInfo.Options.AIPLatoonNameDebug] then
                factory:SetCustomName(builder.BuilderName)
            end
            -- LOG('*AI DEBUG: ARMY ', repr(self.Brain:GetArmyIndex()),': Factory Builder Manager Building - ',repr(builder.BuilderName))
            if not template then
                LOG('*AI DEBUG: ARMY ', repr(self.Brain:GetArmyIndex()),': Factory Builder Manager template is nil- ',repr(builder.BuilderName))
            end
            if not factory then
                LOG('*AI DEBUG: ARMY ', repr(self.Brain:GetArmyIndex()),': Factory Builder Manager factory is nil- ',repr(builder.BuilderName))
            end
            self.Brain:BuildPlatoon(template, {factory}, 1)
        else
            -- No builder found setup way to check again
            self:ForkThread(self.DelayBuildOrder, factory, bType, 2)
        end
    end,
}


