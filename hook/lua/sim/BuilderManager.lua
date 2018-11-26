-- AI DEBUG Platoon builder names. (prints to the game.log)
local AntiSpamList = {}
local AntiSpamCounter = 0
local LastBuilder = ''
local DEBUGBUILDER = {}

-- Hook for debugging
OLDBuilderManager = BuilderManager
BuilderManager = Class(OLDBuilderManager) {

    GetHighestBuilder = function(self,bType,factory)
        if not self.BuilderData[bType] then
            error('*BUILDERMANAGER ERROR: Invalid builder type - ' .. bType)
        end
        if not self.Brain.BuilderManagers[self.LocationType] then
            return false
        end
        self.NumGet = self.NumGet + 1
        local found = false
        local possibleBuilders = {}
        -- Print the whole builder table into the game.log. 
        if self.Brain[ScenarioInfo.Options.AIBuilderNameDebug] then
            if not DEBUGBUILDER[ScenarioInfo.Options.AIBuilderNameDebug] then
                DEBUGBUILDER[ScenarioInfo.Options.AIBuilderNameDebug] = true
                for k,v in self.BuilderData[bType].Builders do
                    LOG('* AI ('..ScenarioInfo.Options.AIBuilderNameDebug..') DEBUG: Builder ['..bType..']: Priority = '..v.Priority..' - possibleBuilders = '..repr(v.BuilderName))
                end
            end
        end
        for k,v in self.BuilderData[bType].Builders do
            if v.Priority >= 1 and self:BuilderParamCheck(v,factory) and (not found or v.Priority == found) and v:GetBuilderStatus() then
                if not self:IsPlattonBuildDelayed(v.DelayEqualBuildPlattons) then
                    found = v.Priority
                    table.insert(possibleBuilders, k)
                    --LOG('* AI DEBUG: GetHighestBuilder(): Priority = '..found..' - possibleBuilders = '..repr(v.BuilderName))
                end
            elseif found and v.Priority < found then
                break
            end
        end
        if found and found > 0 then
            local whichBuilder = Random(1,table.getn(possibleBuilders))
            -- DEBUG SPAM - Start
            -- If we have a builder that is repeating (Happens when buildconditions are true, but the builder can't find anything to build/assist or a build location)
            local BuilderName = self.BuilderData[bType].Builders[ possibleBuilders[whichBuilder] ].BuilderName
            if BuilderName ~= LastBuilder then
                LastBuilder = BuilderName
                AntiSpamCounter = 0
            elseif not AntiSpamList[BuilderName] then
                AntiSpamCounter = AntiSpamCounter + 1
                if AntiSpamCounter > 20 then
                    -- Warn the programmer that something is going wrong.
                    WARN('* AI DEBUG: GetHighestBuilder(): PlatoonBuilder is spaming. Maybe wrong Buildconditions for Builder = '..self.BuilderData[bType].Builders[ possibleBuilders[whichBuilder] ].BuilderName..' ?!?')
                    AntiSpamCounter = 0
                    AntiSpamList[BuilderName] = true
                end                
            end
            -- DEBUG SPAM - End
            if self.Brain[ScenarioInfo.Options.AIBuilderNameDebug] or ScenarioInfo.Options.AIBuilderNameDebug == 'all' then
                -- building Mass percent bar
                local percent = self.Brain:GetEconomyStoredRatio('MASS')
                local massBar = ''
                local count = 1
                for i = count, percent*20 do
                    massBar = massBar..'#'
                    count = count + 1
                end
                for i = count, 20 do
                    massBar = massBar..'~'
                end
                -- building Mass percent bar
                local percent = self.Brain:GetEconomyStoredRatio('ENERGY')
                local energyBar = ''
                local count = 1
                for i = count, percent*20 do
                    energyBar = energyBar..'#'
                    count = count + 1
                end
                for i = count, 20 do
                    energyBar = energyBar..'~'
                end
                -- format priority numbers
                local PrioText = ''
                local Priolen = string.len(found)
                if 6 > Priolen then
                    PrioText = string.rep('  ', 6 - Priolen) .. found
                end
                LOG(' M: ['..massBar..']  E: ['..energyBar..']  -  BuilderPriority = '..PrioText..' - SelectedBuilder = '..self.BuilderData[bType].Builders[ possibleBuilders[whichBuilder] ].BuilderName)
            end
            return self.BuilderData[bType].Builders[ possibleBuilders[whichBuilder] ]
        end
        return false
    end,

}
