-- This hook is for debug Option Platoon-Names. Hook for all AI's
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
            if self.Brain[ScenarioInfo.Options.AIPLatoonNameDebug] or ScenarioInfo.Options.AIPLatoonNameDebug == 'all' then
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

    DelayBuildOrder = function(self,factory,bType,time)
        factory.LastActive = GetGameTimeSeconds()
        local guards = factory:GetGuards()
        for k,v in guards do
            if not v.Dead and v.AssistPlatoon then
                if self.Brain:PlatoonExists(v.AssistPlatoon) then
                    v.AssistPlatoon:ForkThread(v.AssistPlatoon.EconAssistBody)
                else
                    v.AssistPlatoon = nil
                end
            end
        end
        if factory.DelayThread then
            return
        end
        factory.DelayThread = true
        WaitSeconds(time)
        factory.DelayThread = false
        self:AssignBuildOrder(factory,bType)
    end,

    RallyPointMonitor = function(self)
        -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return OLDFactoryBuilderManager.RallyPointMonitor(self)
        end
        -- End the ForkThread RallyPointMonitor
        --LOG('*UVESO Ending forked thread RallyPointMonitor')
    end,

    SetRallyPoint = function(self, factory)
        -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return OLDFactoryBuilderManager.SetRallyPoint(self, factory)
        end
        -- don't set any rally point, we use units on the fly.
        return true
    end,

}
