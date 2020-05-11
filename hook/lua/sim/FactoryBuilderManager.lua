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

    BuilderParamCheck = function(self,builder,params)
        -- Only use this with AI-Uveso
        if 1 == 1 or not self.Brain.Uveso then
            return OldFactoryBuilderManagerClass.BuilderParamCheck(self,builder,params)
        end
        local template = self:GetFactoryTemplate(builder:GetPlatoonTemplate(), params[1])
        if not template then
            WARN('*Factory Builder Error: Could not find template named: ' .. builder:GetPlatoonTemplate())
            return false
        end
        if not template[3][1] then
            --WARN('*Factory Builder Error: no FactionSquad for Template ' .. repr(template))
            return false
        end
        local FactoryLevel = params[1].techCategory
        local TemplateLevel = __blueprints[template[3][1]].TechCategory
        if FactoryLevel == TemplateLevel then
            --LOG('Factory Tech Level: ['..FactoryLevel..'] - Template Tech Level: ['..TemplateLevel..'] -  Factory is equal to Template Level, we want to continue!')
        elseif FactoryLevel > TemplateLevel then
            --LOG('Factory Tech Level: ['..FactoryLevel..'] - Template Tech Level: ['..TemplateLevel..'] -  Factory is higher than Template Level, stop building low tech crap!')
            local EngineerFound
            -- search categories for ENGINEER
            for _, cat in __blueprints[template[3][1]].Categories do
                -- continue withthe next categorie if its not ENGINEER
                if cat ~= 'ENGINEER' and cat ~= 'SCOUT' then continue end
                -- found ENGINEER category
                --WARN('found categorie engineer')
                EngineerFound = true
                break
            end
            -- template islower than factory level and its not an engineer, then return false
            if not EngineerFound then
--                return false
            end
        elseif FactoryLevel < TemplateLevel then
            --LOG('Factory Tech Level: ['..FactoryLevel..'] - Template Tech Level: ['..TemplateLevel..'] -  Factory is lower than Template Level, we can\'t built that!')
            return false
        else
            --LOG('Factory Tech Level: ['..FactoryLevel..'] - Template Tech Level: ['..TemplateLevel..'] -  if you can read this then we have messed it up :D')
        end

        -- This faction doesn't have unit of this type
        if table.getn(template) == 2 then
            return false
        end

        -- This function takes a table of factories to determine if it can build
        return self.Brain:CanBuildPlatoon(template, params)

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
