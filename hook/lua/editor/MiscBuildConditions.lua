local UvesoOffsetMiscBuildConditionsLUA = debug.getinfo(1).currentline - 1
SPEW('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..UvesoOffsetMiscBuildConditionsLUA..'] * AI-Uveso: offset MiscBuildConditions.lua')
--504

-- Uveso AI. Function to see if we are on a water map and/or can't send Land units to the enemy
local CanPathToEnemy = {}
local debugoutput = false
function CanPathToCurrentEnemy(aiBrain, bool, LocationType)
    -- Get the armyindex from the enemy
    local CurrentEnemy = aiBrain:GetCurrentEnemy()
    -- in case we started to erly and we have no enemy yet, or we started a game with only Allies
    if not CurrentEnemy then
        return true == bool
    end
    local EnemyIndex = ArmyBrains[aiBrain:GetCurrentEnemy():GetArmyIndex()].Nickname
    local Nickname = ArmyBrains[aiBrain:GetArmyIndex()].Nickname

    -- create a table for the enemy index in case it's nil
    CanPathToEnemy[Nickname] = CanPathToEnemy[Nickname] or {} 
    CanPathToEnemy[Nickname][LocationType] = CanPathToEnemy[Nickname][LocationType] or {} 
    -- Check if we have already done a path search to the current enemy
    if CanPathToEnemy[Nickname][LocationType][EnemyIndex] == 'LAND' then
        return true == bool
    elseif CanPathToEnemy[Nickname][LocationType][EnemyIndex] == 'WATER' then
        return false == bool
    end

    -- We have no cached path. Searching now for a path.
    local AIAttackUtils = import('/lua/AI/aiattackutilities.lua')
    local startX, startZ = aiBrain:GetArmyStartPos()
    local enemyX, enemyZ
    if aiBrain:GetCurrentEnemy() then
        enemyX, enemyZ = aiBrain:GetCurrentEnemy():GetArmyStartPos()
        -- if we don't have an enemy position then we can't search for a path. Return until we have an enemy position
        if not enemyX then
            return false
        end
    else
        -- if we don't have a current enemy then return false
        return false
    end

    -- path wit AI markers from our base to the enemy base
    local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Land', {startX,0,startZ}, {enemyX,0,enemyZ}, 1000)
    -- if we have a path generated with AI path markers then....
    if path then
        AILog('* AI-Uveso: CanPathToCurrentEnemy: Land path from '..LocationType..' to the enemy found! LAND map! - '..Nickname..' vs '..EnemyIndex..'', true, UvesoOffsetMiscBuildConditionsLUA)
        CanPathToEnemy[Nickname][LocationType][EnemyIndex] = 'LAND'
        return true == bool
    -- if we not have a path
    else
        -- "NoPath" means we have AI markers but can't find a path to the enemy - There is no path!
        if reason == 'NoPath' then
            AILog('* AI-Uveso: CanPathToCurrentEnemy: No land path from '..LocationType..' to the enemy found! WATER map! - '..Nickname..' vs '..EnemyIndex..'', true, UvesoOffsetMiscBuildConditionsLUA)
            CanPathToEnemy[Nickname][LocationType][EnemyIndex] = 'WATER'
            return false == bool
        -- "NoGraph" means we have no AI markers and cant graph to the enemy. We can't search for a path - No markers
        elseif reason == 'NoGraph' then
            AILog('* AI-Uveso: CanPathToCurrentEnemy: No AI markers found! Using land/water ratio instead', true, UvesoOffsetMiscBuildConditionsLUA)
            -- Check if we have less then 50% water on the map
            if aiBrain:GetMapWaterRatio() < 0.50 then
                --lets asume we can move on land to the enemy
                AILog(string.format('* AI-Uveso: CanPathToCurrentEnemy: Water on map: %0.2f%%. Assuming LAND map! - '..Nickname..' vs '..EnemyIndex..'',aiBrain:GetMapWaterRatio()*100 ), true, UvesoOffsetMiscBuildConditionsLUA)
                CanPathToEnemy[Nickname][LocationType][EnemyIndex] = 'LAND'
                return true == bool
            else
                -- we have more then 50% water on this map. Ity maybe a water map..
                AILog(string.format('* AI-Uveso: CanPathToCurrentEnemy: Water on map: %0.2f%%. Assuming WATER map! - '..Nickname..' vs '..EnemyIndex..'',aiBrain:GetMapWaterRatio()*100 ), true, UvesoOffsetMiscBuildConditionsLUA)
                CanPathToEnemy[Nickname][LocationType][EnemyIndex] = 'WATER'
                return false == bool
            end
        end
    end
    return false
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
