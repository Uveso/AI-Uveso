
-- AI DEBUG Platoon builder names. (prints to the game.log)
local AntiSpamList = {}
local AntiSpamCounter = 0
local LastBuilder = ''
local DEBUGBUILDER = {}

-- Hook for debugging
TheOldBuilderManager = BuilderManager
BuilderManager = Class(TheOldBuilderManager) {

    -- Hook for all AI debug
    GetHighestBuilder = function(self, bType, params)
        local builderData = self.BuilderData[bType]
        local returnBuilder
        if not builderData then
            error('*BUILDERMANAGER ERROR: Invalid builder type - ' .. bType)
        end
        -- Print the whole builder table into the game.log. 
        if self.Brain[ScenarioInfo.Options.AIBuilderNameDebug] then
            if not DEBUGBUILDER[ScenarioInfo.Options.AIBuilderNameDebug] then
                DEBUGBUILDER[ScenarioInfo.Options.AIBuilderNameDebug] = true
                for k,v in builderData.Builders do
                    AILog('* '..ScenarioInfo.Options.AIBuilderNameDebug..'-AI: Builder ['..bType..']: Priority = '..v.Priority..' - possibleBuilders = '..repr(v.BuilderName))
                end
            end
        end
        -- Print end
        local candidates = BuilderCache
        local candidateNext = 1
        local candidatePriority = -1

        -- list of builders that is sorted on priority
        local builders = builderData.Builders
        for k in builders do
            local builder = builders[k] --[ [@as Builder] ]

            -- builders with no priority are ignored
            local priority = builder.Priority
            if priority >= 1 then
                -- break when we have found a builder and the next builder has a lower priority
                if priority < candidatePriority then
                    break
                end

                -- check if we're intentionally delaying this builder
                if not self:IsPlattonBuildDelayed(builder.DelayEqualBuildPlattons) then
                    -- check builder conditions
                    if self:BuilderParamCheck(builder, params) then
                        -- check task conditions
                        if builder:GetBuilderStatus() then
                            candidates[candidateNext] = builder
                            candidateNext = candidateNext + 1
                            candidatePriority = priority
                        end
                    end
                end
            end
        end

        -- only one candidate
        if candidateNext == 2 then
            returnBuilder = candidates[1]

        -- multiple candidates, choose one at random
        elseif candidateNext > 2 then
            returnBuilder = candidates[Random(1, candidateNext - 1)]
        end
        
        if returnBuilder then
            -- Print actual builder
            -- DEBUG SPAM - Start
            -- If we have a builder that is repeating (Happens when buildconditions are true, but the builder can't find anything to build/assist or a build location)
            local BuilderName = returnBuilder.BuilderName
            if BuilderName ~= LastBuilder then
                LastBuilder = BuilderName
                AntiSpamCounter = 0
            elseif not AntiSpamList[BuilderName] then
                AntiSpamCounter = AntiSpamCounter + 1
                if AntiSpamCounter > 20 then
                    -- Warn the programmer that something is going wrong.
                    AIWarn('* AI DEBUG: GetHighestBuilder(): PlatoonBuilder is spaming. Maybe wrong Buildconditions for Builder = '..returnBuilder.BuilderName..' ?!?')
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
                local Priolen = string.len(candidatePriority)
                if 6 > Priolen then
                    PrioText = string.rep('  ', 6 - Priolen) .. candidatePriority
                end
                AILog(' M: ['..massBar..']  E: ['..energyBar..']  -  BuilderPriority = '..PrioText..' - SelectedBuilder = '..returnBuilder.BuilderName)
            end
            -- Print end
            return returnBuilder
        end
    end,

}
