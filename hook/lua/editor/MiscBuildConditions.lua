local UvesoOffsetMiscBuildConditionsLUA = debug.getinfo(1).currentline - 1
SPEW('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..UvesoOffsetMiscBuildConditionsLUA..'] * AI-Uveso: offset MiscBuildConditions.lua')
--504

-- Uveso AI. Function to see if we are on a water map and/or can't send Land units to the enemy
local CanPathToEnemy = {}
local debugoutput = false
--- Determines whether there is a valid path to the current enemy based on the type of path required (land or water).
-- @param aiBrain The brain of the AI army.
-- @param bool Boolean value indicating desired outcome:
--             true if we expect a land path to be available, false if we want a return indicating lack of path.
-- @param LocationType A string indicating the location type being checked.
-- @return Boolean value based on whether a path exists as desired.
function CanPathToCurrentEnemy(aiBrain, bool, LocationType)
    -- Get the current enemy of the AI brain
    local CurrentEnemy = aiBrain:GetCurrentEnemy()
    -- If there is no current enemy (too early in the game or only allies), return based on input `bool`
    if not CurrentEnemy then
        return bool
    end
    -- Get the nickname of the enemy and the AI brain
    local EnemyIndex = ArmyBrains[CurrentEnemy:GetArmyIndex()].Nickname
    local Nickname = ArmyBrains[aiBrain:GetArmyIndex()].Nickname
    -- Initialize path cache table for the current AI if it does not exist
    CanPathToEnemy[Nickname] = CanPathToEnemy[Nickname] or {}
    CanPathToEnemy[Nickname][LocationType] = CanPathToEnemy[Nickname][LocationType] or {}
    -- Check if there is already a cached path result for this enemy and location type
    if CanPathToEnemy[Nickname][LocationType][EnemyIndex] == 'LAND' then
        return bool
    elseif CanPathToEnemy[Nickname][LocationType][EnemyIndex] == 'WATER' then
        return not bool
    end
    -- Import AI attack utilities for pathfinding
    local AIAttackUtils = import('/lua/AI/aiattackutilities.lua')
    -- Get the starting position of the AI army
    local startX, startZ = aiBrain:GetArmyStartPos()
    -- Get the starting position of the enemy
    local enemyX, enemyZ = CurrentEnemy:GetArmyStartPos()
    -- If the enemy position is not available, return as no path found
    if not enemyX then
        return not bool
    end
    -- Attempt to generate a safe path from the AI base to the enemy base using AI path markers
    local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Land', {startX, 0, startZ}, {enemyX, 0, enemyZ}, 1000)
    -- If a path was found, cache the result and return true if a path was desired (`bool` is true)
    if path then
        AILog('* AI-Uveso: CanPathToCurrentEnemy: Land path from '..LocationType..' to the enemy found! LAND map! - '..Nickname..' vs '..EnemyIndex, true, UvesoOffsetMiscBuildConditionsLUA)
        CanPathToEnemy[Nickname][LocationType][EnemyIndex] = 'LAND'
        return bool
    else
        -- If no path was found, handle based on the reason
        if reason == 'NoPath' then
            -- No path available even though markers exist - cache and return based on input `bool`
            AILog('* AI-Uveso: CanPathToCurrentEnemy: No land path from '..LocationType..' to the enemy found! WATER map! - '..Nickname..' vs '..EnemyIndex, true, UvesoOffsetMiscBuildConditionsLUA)
            CanPathToEnemy[Nickname][LocationType][EnemyIndex] = 'WATER'
            return not bool
        elseif reason == 'NoGraph' then
            -- No graph/markers available - use map water ratio as a heuristic
            AILog('* AI-Uveso: CanPathToCurrentEnemy: No AI markers found! Using land/water ratio instead', true, UvesoOffsetMiscBuildConditionsLUA)
            -- Check if the map is predominantly land or water
            if aiBrain:GetMapWaterRatio() < 0.50 then
                -- Assume a land map if less than 50% water
                AILog(string.format('* AI-Uveso: CanPathToCurrentEnemy: Water on map: %0.2f%%. Assuming LAND map! - '..Nickname..' vs '..EnemyIndex, aiBrain:GetMapWaterRatio()*100), true, UvesoOffsetMiscBuildConditionsLUA)
                CanPathToEnemy[Nickname][LocationType][EnemyIndex] = 'LAND'
                return bool
            else
                -- Assume a water map if more than 50% water
                AILog(string.format('* AI-Uveso: CanPathToCurrentEnemy: Water on map: %0.2f%%. Assuming WATER map! - '..Nickname..' vs '..EnemyIndex, aiBrain:GetMapWaterRatio()*100), true, UvesoOffsetMiscBuildConditionsLUA)
                CanPathToEnemy[Nickname][LocationType][EnemyIndex] = 'WATER'
                return not bool
            end
        end
    end
    -- Default return if none of the above conditions are met
    return not bool
end


function IsBrainPersonality(aiBrain, neededPersonality, bool)
    local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
    if personality == neededPersonality and bool then
        --AILog('personality = '..personality..' = true', true, UvesoOffsetMiscBuildConditionsLUA)
        return true
    elseif personality ~= neededPersonality and not bool then
        --AILog('personality not '..neededPersonality..' = true', true, UvesoOffsetMiscBuildConditionsLUA)
        return true
    end
    return false
end

--            { MIBC, 'HasParagon', {} },
function HasParagon(aiBrain)
    if aiBrain.PriorityManager.HasParagon then
        return true
    end
    return false
end

--            { MIBC, 'HasNotParagon', {} },
function HasNotParagon(aiBrain)
    if not aiBrain.PriorityManager.HasParagon then
        return true
    end
    return false
end

--            { MIBC, 'IsNavalExpansionsAllowed', {} },
function IsNavalExpansionsAllowed(aiBrain)
    local ratio = aiBrain:GetMapWaterRatio()
    -- check if we have less than 20% water on the map
    if ratio < 0.2 then
        --AILog('* IsNavalExpansionsAllowed: GetMapWaterRatio: '..(ratio*100)..'% - return false', true, UvesoOffsetMiscBuildConditionsLUA)
        return false
    end
    local allowed = tonumber(ScenarioInfo.Options.NavalExpansionsAllowed) or 0
    local exist = aiBrain:GetManagerCount('Naval Area')
    -- check if we have already build the allowed amount of naval expansions
    if exist >= allowed then
        --AILog('* IsNavalExpansionsAllowed: GetManagerCount: ('..exist..'/'..allowed..') - return false', true, UvesoOffsetMiscBuildConditionsLUA)
        return false
    end
    --AILog('* IsNavalExpansionsAllowed: GetManagerCount: ('..exist..'/'..allowed..') GetMapWaterRatio: '..(ratio*100)..'% - return true', true, UvesoOffsetMiscBuildConditionsLUA)
    return true
end

--            { MIBC, 'ItsTimeForGameender', {} },
function ItsTimeForGameender(aiBrain)
    local TimeForEnder = tonumber(ScenarioInfo.Options.AIGameenderStart) or 25
    if TimeForEnder * 60 < GetGameTimeSeconds() then
        --AILog('* ItsTimeForGameender: TimeForEnder: '..(TimeForEnder*60)..' < '..GetGameTimeSeconds()..' TRUE', true, UvesoOffsetMiscBuildConditionsLUA)
        return true
    end
    --AILog('* ItsTimeForGameender: TimeForEnder: '..(TimeForEnder*60)..' < '..GetGameTimeSeconds()..' FALSE', true, UvesoOffsetMiscBuildConditionsLUA)
    return false
end
