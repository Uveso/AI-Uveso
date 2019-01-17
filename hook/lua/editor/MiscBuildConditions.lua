
-- For AI Patch V3. Fix for 5 factions
function FactionIndex(aiBrain, ...)
    local FactionIndex = aiBrain:GetFactionIndex()
    for index, faction in arg do
        if index == 'n' then continue end
        if faction == FactionIndex then
            return true
        end
    end
    return false
end

-- Uveso AI. Function to see if we are on a water map and/or can't send Land units to the enemy
local CanPathToEnemy = {}
function CanPathToCurrentEnemy(aiBrain, bool)
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

    -- Get the armyindex from the enemy
    local EnemyIndex = ArmyBrains[aiBrain:GetCurrentEnemy():GetArmyIndex()].Nickname
    local OwnIndex = ArmyBrains[aiBrain:GetArmyIndex()].Nickname

    -- create a table for the enemy index in case it's nil
    CanPathToEnemy[OwnIndex] = CanPathToEnemy[OwnIndex] or {} 
    -- Check if we have already done a path search to the current enemy
    if CanPathToEnemy[OwnIndex][EnemyIndex] == 'LAND' then
        return true == bool
    elseif CanPathToEnemy[OwnIndex][EnemyIndex] == 'WATER' then
        return false == bool
    end

    -- path wit AI markers from our base to the enemy base
    local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Land', {startX,0,startZ}, {enemyX,0,enemyZ}, 1000)
    -- if we have a path generated with AI path markers then....
    if path then
        LOG('* Uveso-AI: CanPathToCurrentEnemy: Land path to the enemy found! LAND map! - '..OwnIndex..' vs '..EnemyIndex..'')
        CanPathToEnemy[OwnIndex][EnemyIndex] = 'LAND'
    -- if we not have a path
    else
        -- "NoPath" means we have AI markers but can't find a path to the enemy - There is no path!
        if reason == 'NoPath' then
            LOG('* Uveso-AI: CanPathToCurrentEnemy: No land path to the enemy found! WATER map! - '..OwnIndex..' vs '..EnemyIndex..'')
            CanPathToEnemy[OwnIndex][EnemyIndex] = 'WATER'
        -- "NoGraph" means we have no AI markers and cant graph to the enemy. We can't search for a path - No markers
        elseif reason == 'NoGraph' then
            LOG('* Uveso-AI: CanPathToCurrentEnemy: No AI markers found! Using land/water ratio instead')
            -- Check if we have less then 50% water on the map
            if aiBrain:GetMapWaterRatio() < 0.50 then
                --lets asume we can move on land to the enemy
                LOG(string.format('* Uveso-AI: CanPathToCurrentEnemy: Water on map: %0.2f%%. Assuming LAND map! - '..OwnIndex..' vs '..EnemyIndex..'',aiBrain:GetMapWaterRatio()*100 ))
                CanPathToEnemy[OwnIndex][EnemyIndex] = 'LAND'
            else
                -- we have more then 50% water on this map. Ity maybe a water map..
                LOG(string.format('* Uveso-AI: CanPathToCurrentEnemy: Water on map: %0.2f%%. Assuming WATER map! - '..OwnIndex..' vs '..EnemyIndex..'',aiBrain:GetMapWaterRatio()*100 ))
                CanPathToEnemy[OwnIndex][EnemyIndex] = 'WATER'
            end
        end
    end
    if CanPathToEnemy[OwnIndex][EnemyIndex] == 'LAND' then
        return true == bool
    elseif CanPathToEnemy[OwnIndex][EnemyIndex] == 'WATER' then
        return false == bool
    end
    CanPathToEnemy[OwnIndex][EnemyIndex] = 'WATER'
    return false == bool
end
