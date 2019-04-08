-- This hook is for debug Option Platoon-Names. Hook for all AI's
OldFactoryBuilderManagerClass = FactoryBuilderManager
FactoryBuilderManager = Class(OldFactoryBuilderManagerClass) {

    -- For AI Patch V4. 
    GetFactoryTemplate = function(self, templateName, factory)
        local templateData = PlatoonTemplates[templateName]
        if not templateData then
            SPEW('*AI WARNING: No templateData found for template '..templateName..'. ')
            return false
        end
        if not templateData.FactionSquads then
            SPEW('*AI ERROR: PlatoonTemplate named: ' .. templateName .. ' does not have a FactionSquads')
            return false
        end
        local template = {
            templateData.Name,
            '',
        }

        local faction = self:GetFactoryFaction(factory)
        local customData = self.Brain.CustomUnits[templateName]
        if faction and templateData.FactionSquads[faction] then
            for k,v in templateData.FactionSquads[faction] do
                if customData and customData[faction] then
                    -- LOG('*AI DEBUG: Replacement unit found!')
                    local replacement = self:GetCustomReplacement(v, templateName, faction)
                    if replacement then
                        table.insert(template, replacement)
                    else
                        table.insert(template, v)
                    end
                else
                    table.insert(template, v)
                end
            end
        elseif faction and customData and customData[faction] then
            --LOG('*AI DEBUG: New unit found for '..templateName..'!')
            local Squad = nil
            if templateData.FactionSquads then
                -- get the first squad from the template
                for k,v in templateData.FactionSquads do
                    -- use this squad as base template for the replacement
                    Squad = table.copy(v[1])
                    -- flag this template as dummy
                    Squad[1] = "NoOriginalUnit"
                    break
                end
            end
            -- if we don't have a template use a dummy.
            if not Squad then
                -- this will only happen if we have a empty template. Warn the programmer!
                SPEW('*AI WARNING: No faction squad found for '..templateName..'. using Dummy! '..repr(templateData.FactionSquads) )
                Squad = { "NoOriginalUnit", 1, 1, "attack", "none" }
            end
            local replacement = self:GetCustomReplacement(Squad, templateName, faction)
            if replacement then
                table.insert(template, replacement)
            end
        end
        return template
    end,

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
            -- LOG('*AI DEBUG: ARMY ', repr(self.Brain:GetArmyIndex()),': Factory Builder Manager Building - ',repr(builder.BuilderName))
            if not template then
                SPEW('*AI DEBUG: ARMY ', repr(self.Brain:GetArmyIndex()),': Factory Builder Manager template is nil- ',repr(builder.BuilderName))
            end
            if not factory then
                SPEW('*AI DEBUG: ARMY ', repr(self.Brain:GetArmyIndex()),': Factory Builder Manager factory is nil- ',repr(builder.BuilderName))
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

    -- Hook for adding factory.LastActive to restart factories.
    DelayBuildOrder = function(self,factory,bType,time)
        factory.LastActive = GetGameTimeSeconds()
        OldFactoryBuilderManagerClass.DelayBuildOrder(self,factory,bType,time)
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
