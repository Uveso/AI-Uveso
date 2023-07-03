-- AI DEBUG Platoon builder names. (prints to the game.log)
local AntiSpamList = {}
local AntiSpamCounter = 0
local LastBuilder = ''
local DEBUGBUILDER = {}

-- Hook for debugging
TheOldBuilderManager = BuilderManager
BuilderManager = Class(TheOldBuilderManager) {

    -- Hook for Uveso AI debug
    GetHighestBuilder = function(self, bType, params)
        local builderData = self.BuilderData[bType]
        if not builderData then
            error('*BUILDERMANAGER ERROR: Invalid builder type - ' .. bType)
        end

        local candidates = BuilderCache
        local candidateNext = 1
        local candidatePriority = -1

        -- list of builders that is sorted on priority
        local builders = builderData.Builders
        for k in builders do
            local builder = builders[k] --[[@as Builder]]

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
            PrintHighestBuilder(candidates[1])
            return candidates[1]
        -- multiple candidates, choose one at random
        elseif candidateNext > 2 then
            local candidate = candidates[Random(1, candidateNext - 1)]
            PrintHighestBuilder(candidate)
            return candidate
        end
    end,

    PrintHighestBuilder = function(candidate)
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
            AILog(' M: ['..massBar..']  E: ['..energyBar..']  -  BuilderPriority = '..PrioText..' - SelectedBuilder = '..candidate.BuilderName)
        end
    end,

}

