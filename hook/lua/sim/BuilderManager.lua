local DebugNames = false -- Display next building Platoonn inside LOG
-- AI DEBUG
local AntiSpamList = {}
local AntiSpamCounter = 0
local LastBuilder = ''

-- Hook for debugging
OLDBuilderManager = BuilderManager
BuilderManager = Class(OLDBuilderManager) {

    GetHighestBuilder = function(self,bType,factory)
        -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return OLDBuilderManager.GetHighestBuilder(self,bType,factory)
        end
        if not self.BuilderData[bType] then
            error('*BUILDERMANAGER ERROR: Invalid builder type - ' .. bType)
        end
        if not self.Brain.BuilderManagers[self.LocationType] then
            return false
        end
        self.NumGet = self.NumGet + 1
        local found = false
        local possibleBuilders = {}
        for k,v in self.BuilderData[bType].Builders do
            if v:GetPriority() >= 1 and self:BuilderParamCheck(v,factory) and (not found or v:GetPriority() == found) and v:GetBuilderStatus() then
                if not self:IsPlattonBuildDelayed(v.DelayEqualBuildPlattons) then
                    found = v:GetPriority()
                    table.insert(possibleBuilders, k)
                    if DebugNames then
                        --LOG('* AI DEBUG: GetHighestBuilder: Priority = '..found..' - possibleBuilders = '..repr(v.BuilderName))
                    end
                end
            elseif found and v:GetPriority() < found then
                break
            end
        end
        if found and found > 0 then
            local whichBuilder = Random(1,table.getn(possibleBuilders))
            -- DEBUG - Start
            -- If we have a builder that is repeating (Happens when buildconditions are true, but the builder can't find anything to build/assist nor a build location)
            local BuilderName = self.BuilderData[bType].Builders[ possibleBuilders[whichBuilder] ].BuilderName
            if BuilderName ~= LastBuilder then
                LastBuilder = BuilderName
                AntiSpamCounter = 0
            elseif not AntiSpamList[BuilderName] then
                AntiSpamCounter = AntiSpamCounter + 1
                if AntiSpamCounter > 10 then
                    -- Warn the programmer that something is going wrong.
                    WARN('* AI DEBUG: GetHighestBuilder: Builder is spaming. Maybe wrong Buildconditions for Builder = '..self.BuilderData[bType].Builders[ possibleBuilders[whichBuilder] ].BuilderName..' ???')
                    AntiSpamCounter = 0
                    AntiSpamList[BuilderName] = true
                end                
            end
            -- DEBUG - End
            if DebugNames then
                local percent = self.Brain:GetEconomyStoredRatio('MASS')
                local percentbar = ''
                local count = 1
                for i = count, percent*20 do
                    percentbar = percentbar..'#'
                    count = count + 1
                end
                for i = count, 20 do
                    percentbar = percentbar..'~'
                end
--                if not string.find(self.BuilderData[bType].Builders[ possibleBuilders[whichBuilder] ].BuilderName,'U1 ') then
                LOG('* GetHighestBuilder: Mass:['..percentbar..'] Priority = '..found..' - SelectedBuilder = '..self.BuilderData[bType].Builders[ possibleBuilders[whichBuilder] ].BuilderName)
--                end
            end
            return self.BuilderData[bType].Builders[ possibleBuilders[whichBuilder] ]
        end
        return false
    end,

}
