local DebugNames = true

OLDFactoryBuilderManager = FactoryBuilderManager
FactoryBuilderManager = Class(OLDFactoryBuilderManager) {

    AssignBuildOrder = function(self,factory,bType)
        -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return OLDFactoryBuilderManager.AssignBuildOrder(self,factory,bType)
        end
        -- Find a builder the factory can build
        if factory.Dead then
            return
        end
        local builder = self:GetHighestBuilder(bType,{factory})
        if builder then
            local personality = self.Brain:GetPersonality()
            local template = self:GetFactoryTemplate(builder:GetPlatoonTemplate(), factory)
            -- LOG('*AI DEBUG: ARMY ', repr(self.Brain:GetArmyIndex()),': Factory Builder Manager Building - ',repr(builder.BuilderName))
            if DebugNames then
                factory:SetCustomName(builder.BuilderName)
            end
            self.Brain:BuildPlatoon(template, {factory}, 1)
        else
            -- No builder found setup way to check again
            self:ForkThread(self.DelayBuildOrder, factory, bType, 2)
        end
    end,
}


