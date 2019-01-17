-- For AI Patch. Exclude masspoints near the map boder
OLDAIGetSortedMassLocations = AIGetSortedMassLocations
function AIGetSortedMassLocations(aiBrain, maxNum, tMin, tMax, tRings, tType, position)
    local markerList = AIGetMarkerLocations(aiBrain, 'Mass')
    local newList = {}
    for _, v in markerList do
        -- check distance to map border. (game engine can't build mass closer then 8 mapunits to the map border.) 
        if v.Position[1] <= 8 or v.Position[1] >= ScenarioInfo.size[1] - 8 or v.Position[3] <= 8 or v.Position[3] >= ScenarioInfo.size[2] - 8 then
            -- mass marker is too close to border, skip it.
            continue
        end
        if aiBrain:CanBuildStructureAt('ueb1103', v.Position) then
            table.insert(newList, v)
        end
    end
    return AISortMarkersFromLastPos(aiBrain, newList, maxNum, tMin, tMax, tRings, tType, position)
end

-- For AI Patch. reclaim before building mexes etc
OLDEngineerTryReclaimCaptureArea = EngineerTryReclaimCaptureArea
function EngineerTryReclaimCaptureArea(aiBrain, eng, pos)
    if not pos then
        return false
    end
    local Reclaiming = false
    -- Check if enemy units are at location
    local checkUnits = aiBrain:GetUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) - categories.AIR, pos, 10, 'Enemy')
    -- reclaim units near our building place.
    if checkUnits and table.getn(checkUnits) > 0 then
        for num, unit in checkUnits do
            if unit.Dead or unit:BeenDestroyed() then
                continue
            end
            if not IsEnemy( aiBrain:GetArmyIndex(), unit:GetAIBrain():GetArmyIndex() ) then
                continue
            end
            if unit:IsCapturable() then 
                -- if we can capture the unit/building then do so
                IssueCapture({eng}, unit)
            else
                -- if we can't capture then reclaim
                IssueReclaim({eng}, unit)
            end
        end
        Reclaiming = true
    end
    -- reclaim rocks etc or we can't build mexes or hydros
    local Reclaimables = GetReclaimablesInRect(Rect(pos[1], pos[3], pos[1], pos[3]))
    if Reclaimables and table.getn( Reclaimables ) > 0 then
        for k,v in Reclaimables do
            if v.MaxMassReclaim and v.MaxMassReclaim > 0 or v.MaxEnergyReclaim and v.MaxEnergyReclaim > 0 then
                IssueReclaim({eng}, v)
            end
        end
    end
    return Reclaiming
end

-- Helper function for targeting
function ValidateLayer(UnitPos,MovementLayer)
    if MovementLayer == 'Air' then
        return true
    end
    local TerrainHeight = GetTerrainHeight( UnitPos[1], UnitPos[3] ) -- terran high
    local SurfaceHeight = GetSurfaceHeight( UnitPos[1], UnitPos[3] ) -- water high
    -- Terrain > Surface = Target is on land
    if TerrainHeight >= SurfaceHeight and ( MovementLayer == 'Land' or MovementLayer == 'Amphibious' ) then
        --LOG('AttackLayer '..MovementLayer..' - TerrainHeight > SurfaceHeight. = Target is on land ')
        return true
    end
    -- Terrain > Surface = Target is underwater
    if TerrainHeight < SurfaceHeight and ( MovementLayer == 'Water' or MovementLayer == 'Amphibious' ) then
        --LOG('AttackLayer '..MovementLayer..' - TerrainHeight < SurfaceHeight. = Target is on water ')
        return true
    end

    return false
end

-- Target function
function AIFindNearestCategoryTargetInRange(aiBrain, platoon, squad, position, maxRange, PrioritizedTargetList, TargetSearchCategory, enemyBrain)
    if not maxRange then
        --LOG('* Uveso-AI: AIFindNearestCategoryTargetInRange: function called with empty "maxRange"' )
        return false, false, false, 'NoRange'
    end
    if not TargetSearchCategory then
        --LOG('* Uveso-AI: AIFindNearestCategoryTargetInRange: function called with empty "TargetSearchCategory"' )
        return false, false, false, 'NoCat'
    end
    if not position then
        --LOG('* Uveso-AI: AIFindNearestCategoryTargetInRange: function called with empty "position"' )
        return false, false, false, 'NoPos'
    end
    if not platoon then
        LOG('* Uveso-AI: AIFindNearestCategoryTargetInRange: function called with no "platoon"' )
        return false, false, false, 'NoPos'
    end
    local AttackEnemyStrength = platoon.PlatoonData.AttackEnemyStrength or 300
    local platoonUnits = platoon:GetPlatoonUnits()
    local PlatoonStrength = table.getn(platoonUnits)

    if type(TargetSearchCategory) == 'string' then
        TargetSearchCategory = ParseEntityCategory(TargetSearchCategory)
    end
    local enemyIndex = false
    if enemyBrain then
        enemyIndex = enemyBrain:GetArmyIndex()
    end

    local RangeList = { [1] = maxRange }
    if maxRange > 512 then
        RangeList = {
            [1] = 30,
            [1] = 64,
            [2] = 128,
            [2] = 192,
            [3] = 256,
            [3] = 384,
            [4] = 512,
            [5] = maxRange,
        }
    elseif maxRange > 256 then
        RangeList = {
            [1] = 30,
            [1] = 64,
            [2] = 128,
            [2] = 192,
            [3] = 256,
            [4] = maxRange,
        }
    elseif maxRange > 64 then
        RangeList = {
            [1] = 30,
            [2] = maxRange,
        }
    end
    local path = false
    local reason = false
    local UnitWithPath = false
    local UnitNoPath = false
    local count = 0
    local TargetsInRange, EnemyStrength, TargetPosition, category, distance, targetRange, success, bestGoalPos, canAttack
    for _, range in RangeList do
        TargetsInRange = aiBrain:GetUnitsAroundPoint(TargetSearchCategory, position, range, 'Enemy')
        --DrawCircle(position, range, '0000FF')
        for _, v in PrioritizedTargetList do
            category = v
            if type(category) == 'string' then
                category = ParseEntityCategory(category)
            end
            distance = maxRange
            --LOG('* AIFindNearestCategoryTargetInRange: numTargets '..table.getn(TargetsInRange)..'  ')
            for num, Target in TargetsInRange do
                if Target.Dead or Target:BeenDestroyed() then
                    continue
                end
                TargetPosition = Target:GetPosition()
                EnemyStrength = 0
                -- check if the target is on the same layer then the attacker
                if not ValidateLayer(TargetPosition, platoon.MovementLayer) then continue end
                -- check if we have a special player index as enemy
                if enemyBrain and enemyIndex and enemyBrain ~= enemyIndex then continue end
                -- check if the Target is still alive, matches our target priority and can be attacked from our platoon
                canAttack = platoon:CanAttackTarget(squad, Target) or false
                --LOG('* AIFindNearestCategoryTargetInRange: canAttack '..repr(canAttack))
                if not Target.Dead and EntityCategoryContains(category, Target) and canAttack then
                    -- yes... we need to check if we got friendly units with GetUnitsAroundPoint(_, _, _, 'Enemy')
                    if Target:BeenDestroyed() then
                        WARN('* AIFindNearestCategoryTargetInRange: Unit destroyed but not .Dead !?!')
                        continue
                    end
                    if Target.ReclaimInProgress then
                        --WARN('* AIFindNearestCategoryTargetInRange: ReclaimInProgress !!! Ignoring the target.')
                        continue
                    end
                    if Target.CaptureInProgress then
                        --WARN('* AIFindNearestCategoryTargetInRange: CaptureInProgress !!! Ignoring the target.')
                        continue
                    end
                    if not IsEnemy( aiBrain:GetArmyIndex(), Target:GetAIBrain():GetArmyIndex() ) then continue end
                    targetRange = VDist2(position[1],position[3],TargetPosition[1],TargetPosition[3])
                    --LOG('* AIFindNearestCategoryTargetInRange: targetRange '..repr(targetRange))
                    if targetRange < distance then
                        if not aiBrain:PlatoonExists(platoon) then
                            return false, false, false, 'NoPlatoonExists'
                        end
                        if platoon.MovementLayer == 'Land' then
                            EnemyStrength = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE + categories.GROUNDATTACK) , TargetPosition, 40, 'Enemy' )
                        elseif platoon.MovementLayer == 'Air' then
                            EnemyStrength = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * categories.ANTIAIR , TargetPosition, 50, 'Enemy' )
                        elseif platoon.MovementLayer == 'Water' then
                            EnemyStrength = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE + categories.GROUNDATTACK + categories.ANTINAVY) , TargetPosition, 40, 'Enemy' )
                        elseif platoon.MovementLayer == 'Amphibious' then
                            EnemyStrength = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE + categories.GROUNDATTACK + categories.ANTINAVY) , TargetPosition, 40, 'Enemy' )
                        end
                        --LOG('PlatoonStrength / 100 * AttackEnemyStrength <= '..(PlatoonStrength / 100 * AttackEnemyStrength)..' || EnemyStrength = '..EnemyStrength)
                        -- Only attack if we have a chance to win
                        if PlatoonStrength / 100 * AttackEnemyStrength < EnemyStrength then continue end
                        --WaitTicks(1)
                        --LOG('* AIFindNearestCategoryTargetInRange: PlatoonGenerateSafePathTo ')
                        path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, platoon.MovementLayer, position, TargetPosition, platoon.PlatoonData.NodeWeight or 10 )
                        -- Check if we found a path with markers
                        if path then
                            UnitWithPath = Target
                            distance = targetRange
                            --LOG('* AIFindNearestCategoryTargetInRange: Possible target with path. distance '..distance..'  ')
                        -- We don't find a path with markers
                        else
                            -- NoPath happens if we have markers, but can't find a way to the destination. (We need transport)
                            if reason == 'NoPath' then
                                UnitNoPath = Target
                                distance = targetRange
                                --LOG('* AIFindNearestCategoryTargetInRange: Possible target no path. distance '..distance..'  ')
                            -- NoGraph means we have no Map markers. Lets try to path with c-engine command CanPathTo()
                            elseif reason == 'NoGraph' then
                                --WaitTicks(1)
                                local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(platoon, TargetPosition)
                                -- check if we found a path with c-engine command.
                                if success then
                                    UnitWithPath = Target
                                    distance = targetRange
                                    --LOG('* AIFindNearestCategoryTargetInRange: Possible target with CanPathTo(). distance '..distance..'  ')
                                    -- break out of the loop, so we don't use CanPathTo too often.
                                    break
                                -- There is no path to the target.
                                else
                                    UnitNoPath = Target
                                    distance = targetRange
                                    --LOG('* AIFindNearestCategoryTargetInRange: Possible target failed CanPathTo(). distance '..distance..'  ')
                                end
                            end
                        end
                    end
                end
                count = count + 1
                if count > 300 then
                    WaitTicks(1)
                    count = 0
                end
            end
            if UnitWithPath then
                return UnitWithPath, UnitNoPath, path, reason
            end
        end
    end
    if UnitNoPath then
        return UnitWithPath, UnitNoPath, path, reason
    end
    return false, false, false, 'NoUnitFound'
end

function AIFindNearestCategoryTargetInRangeCDR(aiBrain, position, maxRange, PrioritizedTargetList, TargetSearchCategory, enemyBrain)
    if type(TargetSearchCategory) == 'string' then
        TargetSearchCategory = ParseEntityCategory(TargetSearchCategory)
    end
    local enemyIndex = false
    if enemyBrain then
        enemyIndex = enemyBrain:GetArmyIndex()
    end
    local RangeList = {
        [1] = 30,
        [1] = 64,
        [2] = 128,
        [4] = maxRange,
    }
    local TargetUnit = false
    local basePostition = aiBrain.BuilderManagers['MAIN'].Position
    local TargetsInRange, EnemyStrength, TargetPosition, category, distance, targetRange, baseTargetRange, canAttack
    for _, range in RangeList do
        TargetsInRange = aiBrain:GetUnitsAroundPoint(TargetSearchCategory, position, range, 'Enemy')
        --DrawCircle(position, range, '0000FF')
        for _, v in PrioritizedTargetList do
            category = v
            if type(category) == 'string' then
                category = ParseEntityCategory(category)
            end
            distance = maxRange
            --LOG('* AIFindNearestCategoryTargetInRange: numTargets '..table.getn(TargetsInRange)..'  ')
            for num, Target in TargetsInRange do
                if Target.Dead or Target:BeenDestroyed() then
                    continue
                end
                TargetPosition = Target:GetPosition()
                EnemyStrength = 0
                -- check if the target is on the same layer then the attacker
                -- check if we have a special player index as enemy
                if enemyBrain and enemyIndex and enemyBrain ~= enemyIndex then continue end
                -- check if the Target is still alive, matches our target priority and can be attacked from our platoon
                if not Target.Dead and EntityCategoryContains(category, Target) then
                    -- yes... we need to check if we got friendly units with GetUnitsAroundPoint(_, _, _, 'Enemy')
                    if Target.ReclaimInProgress then
                        --WARN('* AIFindNearestCategoryTargetInRange: ReclaimInProgress !!! Ignoring the target.')
                        continue
                    end
                    if Target.CaptureInProgress then
                        --WARN('* AIFindNearestCategoryTargetInRange: CaptureInProgress !!! Ignoring the target.')
                        continue
                    end
                    if Target.ReclaimInProgress then
                        --WARN('* AIFindNearestCategoryTargetInRange: ReclaimInProgress !!! Ignoring the target.')
                        continue
                    end
                    if not IsEnemy( aiBrain:GetArmyIndex(), Target:GetAIBrain():GetArmyIndex() ) then continue end
                    targetRange = VDist2(position[1],position[3],TargetPosition[1],TargetPosition[3])
                    baseTargetRange = VDist2(basePostition[1],basePostition[3],TargetPosition[1],TargetPosition[3])
                    -- check if the target is in range of the ACU and in range of the base
                    if targetRange < distance and baseTargetRange < maxRange then
                        TargetUnit = Target
                        distance = targetRange
                    end
                end
            end
            if TargetUnit then
                return TargetUnit
            end
           WaitTicks(10)
        end
        WaitTicks(1)
    end
    return TargetUnit
end

function AIFindNearestCategoryTeleportLocation(aiBrain, position, maxRange, PrioritizedTargetList, TargetSearchCategory, enemyBrain)
    if type(TargetSearchCategory) == 'string' then
        TargetSearchCategory = ParseEntityCategory(TargetSearchCategory)
    end
    local enemyIndex = false
    if enemyBrain then
        enemyIndex = enemyBrain:GetArmyIndex()
    end
    local TargetUnit = false
    local TargetsInRange, TargetPosition, category, distance, targetRange, AntiteleportUnits

    TargetsInRange = aiBrain:GetUnitsAroundPoint(TargetSearchCategory, position, maxRange, 'Enemy')
    --LOG('* AIFindNearestCategoryTeleportLocation: numTargets '..table.getn(TargetsInRange)..'  ')
    --DrawCircle(position, range, '0000FF')
    for _, v in PrioritizedTargetList do
        category = v
        if type(category) == 'string' then
            category = ParseEntityCategory(category)
        end
        distance = maxRange
        for num, Target in TargetsInRange do
            if Target.Dead or Target:BeenDestroyed() then
                continue
            end
            TargetPosition = Target:GetPosition()
            -- check if the target is on the same layer then the attacker
            -- check if we have a special player index as enemy
            if enemyBrain and enemyIndex and enemyBrain ~= enemyIndex then continue end
            -- check if the Target is still alive, matches our target priority and can be attacked from our platoon
            if not Target.Dead and EntityCategoryContains(category, Target) then
                -- yes... we need to check if we got friendly units with GetUnitsAroundPoint(_, _, _, 'Enemy')
                if not IsEnemy( aiBrain:GetArmyIndex(), Target:GetAIBrain():GetArmyIndex() ) then continue end
                targetRange = VDist2(position[1],position[3],TargetPosition[1],TargetPosition[3])
                -- check if the target is in range of the ACU and in range of the base
                if targetRange < distance then
                    -- Check if the target is protected by antiteleporter
                    if categories.ANTITELEPORT then 
                        AntiteleportUnits = aiBrain:GetUnitsAroundPoint(categories.ANTITELEPORT, TargetPosition, 60, 'Enemy')
                        --LOG('* AIFindNearestCategoryTeleportLocation: numAntiteleportUnits '..table.getn(AntiteleportUnits)..'  ')
                        local scrambled = false
                        for i, unit in AntiteleportUnits do
                            -- If it's an ally, then we skip.
                            if not IsEnemy( aiBrain:GetArmyIndex(), unit:GetAIBrain():GetArmyIndex() ) then continue end
                            local NoTeleDistance = unit:GetBlueprint().Defense.NoTeleDistance
                            if NoTeleDistance then
                                local AntiTeleportTowerPosition = unit:GetPosition()
                                local dist = VDist2(TargetPosition[1], TargetPosition[3], AntiTeleportTowerPosition[1], AntiTeleportTowerPosition[3])
                                if dist and NoTeleDistance >= dist then
                                    --LOG('* AIFindNearestCategoryTeleportLocation: Teleport Destination Scrambled 1 '..repr(TargetPosition)..' - '..repr(AntiTeleportTowerPosition))
                                    scrambled = true
                                    break
                                end
                            end
                        end
                        if scrambled then
                            continue
                        end
                    end
                    --LOG('* AIFindNearestCategoryTeleportLocation: Found a target that is not Teleport Scrambled')
                    TargetUnit = Target
                    distance = targetRange
                end
            end
        end
        if TargetUnit then
            return TargetUnit
        end
       WaitTicks(10)
    end
    return TargetUnit
end

-- WARNING THIS FUNCTION CAUSED CRASH AT 002cbc63. ONLY LEFT FOR DEBUGGING
-- Hook for AI-Uveso engineer pathing
--OLDEngineerMoveWithSafePath = EngineerMoveWithSafePath
--function XXXXXXEngineerMoveWithSafePathXXXXX(aiBrain, unit, destination)
--    -- Only use this with AI-Uveso
--    if not aiBrain.Uveso then
--        return OLDEngineerMoveWithSafePath(aiBrain, unit, destination)
--    end
--    if not destination then
--        return false
--    end
--    local pos = unit:GetPosition()
--    local result, bestPos = unit:CanPathTo(destination)
--    local bUsedTransports = false
--    -- Increase check to 300 for transports
--    if not result or VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 300 * 300
--    and unit.PlatoonHandle and not EntityCategoryContains(categories.COMMAND, unit) then
--        -- If we can't path to our destination, we need, rather than want, transports
--        local needTransports = not result
--        if VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 300 * 300 then
--            needTransports = true
--        end
--        -- Skip the last move... we want to return and do a build
--        bUsedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, unit.PlatoonHandle, destination, needTransports, true, false)
--        if bUsedTransports then
--            return true
--        elseif VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 512 * 512 then
--            -- If over 512 and no transports dont try and walk!
--            return false
--        end
--    end
--    -- If we're here, we haven't used transports and we can path to the destination
--    if result then
--        local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Amphibious', pos, destination)
--        if path then
--            local pathSize = table.getn(path)
--            -- Move to way points (but not to destination... leave that for the final command)
--            for widx, waypointPath in path do
--                if pathSize ~= widx then
--                    IssueMove({unit}, waypointPath)
--                end
--            end
--        end
--        -- If there wasn't a *safe* path (but dest was pathable), then the last move would have been to go there directly
--        -- so don't bother... the build/capture/reclaim command will take care of that after we return
--        return true
--    -- if we are here, then we don't have a valid Path from the c-engine. maybe we find an alternative destination.
--    elseif aiBrain.Uveso then
--        --LOG('* EngineerMoveWithSafePath: Fist unit:CanPathTo('..repr(destination)..') = '..repr(result)..' - bestPos'..repr(bestPos))
--        local DistEngDestination = VDist2(pos[1], pos[3], destination[1], destination[3])
--        local DistDestinationBestPosition = VDist2(bestPos[1], bestPos[3], destination[1], destination[3])
--        -- Are we near our destination ?
--        if DistEngDestination < 30 then
--            --LOG('* EngineerMoveWithSafePath: near destination! DistEngDestination '..DistEngDestination..' - Moving directly.')
--            IssueMove({unit}, destination)
--            return true
--        end
--        -- Do we have a alternative destination that is near the original destination ?
--        if DistDestinationBestPosition < 15 then
--            --LOG('* EngineerMoveWithSafePath: alternative destination! DistDestinationBestPosition '..DistDestinationBestPosition..' - Moving Waypoints.')
--            path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Amphibious', pos, bestPos)
--            if path then
--                for widx, waypointPath in path do
--                    IssueMove({unit}, waypointPath)
--                end
--                return true
--            end
--        end
--        --WaitTicks(3)
--        -- Search again for a redundant path with slight different destination.
--        destination[1] = destination[1] + 5
--        destination[3] = destination[3] + 5
--        result, bestPos = unit:CanPathTo(destination)
--        --LOG('* EngineerMoveWithSafePath: redundant unit:CanPathTo('..repr(destination)..') = '..repr(result)..' - bestPos'..repr(bestPos))        if result then
--            path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Amphibious', pos, destination)
--            if path then
--                local pathSize = table.getn(path)
--                -- Move to way points (but not to destination... leave that for the final command)
--                for widx, waypointPath in path do
--                    if pathSize ~= widx then
--                        IssueMove({unit}, destination)
--                    end
--                end
--                return true
--            else
--                --LOG('* EngineerMoveWithSafePath: redundant no Path!.')
--            end
--        else
--            DistDestinationBestPosition = VDist2(bestPos[1], bestPos[3], destination[1], destination[3])
--            if DistDestinationBestPosition < 15 then
--                --LOG('* EngineerMoveWithSafePath: redundant destination! DistDestinationBestPosition '..DistDestinationBestPosition..' - Moving directly.')
--                IssueMove({unit}, bestPos)
--                return true
--            else
--                --LOG('* EngineerMoveWithSafePath: No way to the Destination.')
--            end
--        end
--    end
--    return false
--end
