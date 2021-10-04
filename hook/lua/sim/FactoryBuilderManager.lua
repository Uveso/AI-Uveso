-- This hook is for debug Option Platoon-Names. Hook for all AI's
OldFactoryBuilderManagerClass = FactoryBuilderManager
FactoryBuilderManager = Class(OldFactoryBuilderManagerClass) {

    -- Hook for Builder names
    AssignBuildOrder = function(self,factory,bType)
        if factory.Dead then
            return
        end
        local builder = self:GetHighestBuilder(bType,{factory})
        if builder then
            local template = self:GetFactoryTemplate(builder:GetPlatoonTemplate(), factory)
            -- rename factory to actual build-platoon name
            if self.Brain[ScenarioInfo.Options.AIPLatoonNameDebug] or ScenarioInfo.Options.AIPLatoonNameDebug == 'all' then
                factory:SetCustomName(builder.BuilderName)
            end
            if not template then
                SPEW('*AI DEBUG: ARMY '..repr(self.Brain:GetArmyIndex())..': Factory Builder Manager template is nil- '..repr(builder.BuilderName))
            end
            if not factory then
                SPEW('*AI DEBUG: ARMY '..repr(self.Brain:GetArmyIndex())..': Factory Builder Manager factory is nil- '..repr(builder.BuilderName))
            end
            --LOG('*AI DEBUG: ARMY '..repr(self.Brain:GetArmyIndex())..': Factory Builder Manager Building - '..repr(builder.BuilderName)..' - '..repr(template))
            self.Brain:BuildPlatoon(template, {factory}, 1)
        else
            -- rename factory
            if self.Brain[ScenarioInfo.Options.AIPLatoonNameDebug] or ScenarioInfo.Options.AIPLatoonNameDebug == 'all' then
                if factory:IsUnitState('Upgrading') and factory.PlatoonHandle.BuilderName then
                    factory:SetCustomName(factory.PlatoonHandle.BuilderName)
                else
                    factory:SetCustomName('')
                end
            end
            -- No builder found setup way to check again
            self:ForkThread(self.DelayBuildOrder, factory, bType, 2)
        end
    end,

    RallyPointMonitor = function(self)
        -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return OldFactoryBuilderManagerClass.RallyPointMonitor(self)
        end
        -- Exit the ForkThread RallyPointMonitor
    end,

    SetRallyPoint = function(self, factory)
        -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return OldFactoryBuilderManagerClass.SetRallyPoint(self, factory)
        end
        -- don't set any rally point, we use units on the fly.
        return true
    end,

}
