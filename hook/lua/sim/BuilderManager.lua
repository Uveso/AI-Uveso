local DebugNames = true -- Display next building Platoonn inside LOG
-- AI DEBUG
local AntiSpamList = {}
local AntiSpamCounter = 0
local LastBuilder = ''

OLDBuilderManager = BuilderManager
BuilderManager = Class(OLDBuilderManager) {

    AddInstancedBuilder = function(self,newBuilder, builderType)
        -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return OLDBuilderManager.AddInstancedBuilder(self,newBuilder, builderType)
        end
        builderType = builderType or newBuilder:GetBuilderType()
        if not builderType then
            -- Warn the programmer that something is wrong. We can continue, hopefully the builder is not too important for the AI ;)
            -- But god for testing, and the case that a mod has bad builders.
            -- Output: WARNING: [buildermanager.lua, line:xxx] *BUILDERMANAGER ERROR: No BuilderData for builder: T3 Air Scout
            WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] *BUILDERMANAGER ERROR: Invalid builder type: ' .. repr(builderType) .. ' - in builder: ' .. newBuilder.BuilderName)
            return
        end
        if newBuilder then
            if not self.BuilderData[builderType] then
                -- Warn the programmer that something is wrong here. Same here, we can continue.
                -- Output: WARNING: [buildermanager.lua, line:xxx] *BUILDERMANAGER ERROR: No BuilderData for builder: T3 Air Scout
                WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] *BUILDERMANAGER ERROR: No BuilderData for builder: ' .. newBuilder.BuilderName)
                return
            end
            table.insert(self.BuilderData[builderType].Builders, newBuilder)
            self.BuilderData[builderType].NeedSort = true
            self.BuilderList = true
        end
        self.NumBuilders = self.NumBuilders + 1
        if newBuilder.InstantCheck then
            self:ManagerLoopBody(newBuilder)
        end
    end,

    IsPlattonBuildDelayed = function(self, DelayEqualBuildPlattons)
        if DelayEqualBuildPlattons then
            local CheckDelayTime = GetGameTimeSeconds()
            local PlatoonName = DelayEqualBuildPlattons[1]
            if not self.Brain.DelayEqualBuildPlattons[PlatoonName] or self.Brain.DelayEqualBuildPlattons[PlatoonName] < CheckDelayTime then
                --LOG('Setting '..DelayEqualBuildPlattons[2]..' sec. delaytime for builder ['..PlatoonName..']')
                self.Brain.DelayEqualBuildPlattons[PlatoonName] = CheckDelayTime + DelayEqualBuildPlattons[2]
                return false
            else
                --LOG('Builder ['..PlatoonName..'] still delayed for '..(CheckDelayTime - self.Brain.DelayEqualBuildPlattons[PlatoonName])..' seconds.')
                return true
            end
        end
    end,

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
                if AntiSpamCounter > 6 then
                    -- Warn the programmer that something is going wrong.
                    WARN('* AI DEBUG: GetHighestBuilder: Builder is spaming. Maybe wrong Buildconditions for Builder = '..repr(self.BuilderData[bType].Builders[ possibleBuilders[whichBuilder] ].BuilderName)..' ???')
                    AntiSpamCounter = 0
                    AntiSpamList[BuilderName] = true
                end                
            end
            -- DEBUG - End
            if DebugNames then
                local percent = self.Brain:GetEconomyStoredRatio('MASS')
                local percentbar = ''
                for i = 1, percent*20 do
                    percentbar = percentbar..'#'
                end
                for i = percent*20, 20 do
                    percentbar = percentbar..'~'
                end
                
                LOG('* GetHighestBuilder: Mass:['..percentbar..'] Priority = '..found..' - SelectedBuilder = '..repr(self.BuilderData[bType].Builders[ possibleBuilders[whichBuilder] ].BuilderName))
            end
            return self.BuilderData[bType].Builders[ possibleBuilders[whichBuilder] ]
        end
        return false
    end,

}
