
-- Hook for own engineer pathing
OLDEngineerMoveWithSafePath = EngineerMoveWithSafePath
function EngineerMoveWithSafePath(aiBrain, unit, destination)
    -- Only use this with AI-Uveso
    if not aiBrain.Uveso then
        return OLDEngineerMoveWithSafePath(aiBrain, unit, destination)
    end
    if not destination then
        return false
    end
    local pos = unit:GetPosition()
    local result, bestPos = unit:CanPathTo(destination)
    local bUsedTransports = false
    -- Increase check to 300 for transports
    if not result or VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 300 * 300
    and unit.PlatoonHandle and not EntityCategoryContains(categories.COMMAND, unit) then
        -- If we can't path to our destination, we need, rather than want, transports
        local needTransports = not result
        if VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 300 * 300 then
            needTransports = true
        end

        -- Skip the last move... we want to return and do a build
        bUsedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, unit.PlatoonHandle, destination, needTransports, true, false)

        if bUsedTransports then
            return true
        elseif VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 512 * 512 then
            -- If over 512 and no transports dont try and walk!
            return false
        end
    end

    -- If we're here, we haven't used transports and we can path to the destination
    if result then
        local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Amphibious', pos, destination)
        if path then
            local pathSize = table.getn(path)
            -- Move to way points (but not to destination... leave that for the final command)
            for widx, waypointPath in path do
                if pathSize ~= widx then
                    IssueMove({unit}, waypointPath)
                end
            end
        end
        -- If there wasn't a *safe* path (but dest was pathable), then the last move would have been to go there directly
        -- so don't bother... the build/capture/reclaim command will take care of that after we return
        return true
    -- if we are here, then we don't have a valid Path from the c-engine. maybe we find an alternative destination.
    elseif aiBrain.Uveso then
        --LOG('* EngineerMoveWithSafePath: Fist unit:CanPathTo('..repr(destination)..') = '..repr(result)..' - bestPos'..repr(bestPos))
        local DistEngDestination = VDist2(pos[1], pos[3], destination[1], destination[3])
        local DistDestinationBestPosition = VDist2(bestPos[1], bestPos[3], destination[1], destination[3])
        --LOG('* EngineerMoveWithSafePath: DistEngDestination '..DistEngDestination..' - DistDestinationBestPosition '..DistDestinationBestPosition..'')
        -- Are we near our destination ?
        if DistEngDestination < 30 then
            --LOG('* EngineerMoveWithSafePath: near destination! DistEngDestination '..DistEngDestination..' - Moving directly.')
            IssueMove({unit}, destination)
            return true
        end
        -- Do we have a alternative destination that is near the original destination ?
        if DistDestinationBestPosition < 15 then
            --LOG('* EngineerMoveWithSafePath: alternative destination! DistDestinationBestPosition '..DistDestinationBestPosition..' - Moving directly.')
            path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Amphibious', pos, bestPos)
            if path then
                for widx, waypointPath in path do
                    IssueMove({unit}, waypointPath)
                end
                return true
            end
        end
        --WaitTicks(3)
        -- Search again for a redundant path with slight different destination.
        destination[1] = destination[1] + 5
        destination[3] = destination[3] + 5
        result, bestPos = unit:CanPathTo(destination)
        --LOG('* EngineerMoveWithSafePath: redundant unit:CanPathTo('..repr(destination)..') = '..repr(result)..' - bestPos'..repr(bestPos))
        if result then
            path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Amphibious', pos, destination)
            if path then
                local pathSize = table.getn(path)
                -- Move to way points (but not to destination... leave that for the final command)
                for widx, waypointPath in path do
                    if pathSize ~= widx then
                        IssueMove({unit}, destination)
                    end
                end
                return true
            else
                --LOG('* EngineerMoveWithSafePath: redundant no Path!.')
            end
        else
            DistDestinationBestPosition = VDist2(bestPos[1], bestPos[3], destination[1], destination[3])
            if DistDestinationBestPosition < 15 then
                --LOG('* EngineerMoveWithSafePath: redundant destination! DistDestinationBestPosition '..DistDestinationBestPosition..' - Moving directly.')
                IssueMove({unit}, bestPos)
                return true
            else
                --LOG('* EngineerMoveWithSafePath: No way to the Destination.')
            end
        end
    end
    return false
end

-- Helper function for targeting
function ValidateLayer(UnitPos,MovementLayer)
    if MovementLayer == 'Air' then
        return true
    end
    local height = GetTerrainHeight( UnitPos[1], UnitPos[3] ) -- terran high
    local surfHeight = GetSurfaceHeight( UnitPos[1], UnitPos[3] ) -- water high
    if height >= surfHeight and ( MovementLayer == 'Land' or MovementLayer == 'Amphibious' ) then
        return true
    end
    if height < surfHeight  and ( MovementLayer == 'Water' or MovementLayer == 'Amphibious' ) then
        return true
    end
--    LOG('MovementLayer '..MovementLayer..' - height '..height..' - surfHeight '..surfHeight)
    return false
end

-- target function
function AIFindNearestCategoryTargetInRange(aiBrain, platoon, squad, position, maxRange, PrioritizedTargetList, TargetSearchCategory, enemyBrain)
    if not maxRange then
        LOG('* AIFindNearestCategoryTargetInRange: function called with empty "maxRange"')
        return false, false, false, 'NoRange'
    end
    if not TargetSearchCategory then
        LOG('* AIFindNearestCategoryTargetInRange: function called with empty "TargetSearchCategory"')
        return false, false, false, 'NoCat'
    end
    if not position then
        LOG('* AIFindNearestCategoryTargetInRange: function called with empty "position"')
        return false, false, false, 'NoPos'
    end
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
            [2] = 100,
            [3] = 256,
            [4] = 512,
            [5] = maxRange,
        }
    elseif maxRange > 256 then
        RangeList = {
            [1] = 30,
            [2] = 100,
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
    for _, range in RangeList do
        TargetsInBaseRange = aiBrain:GetUnitsAroundPoint(TargetSearchCategory, position, range, 'Enemy')
        --DrawCircle(position, range, '0000FF')
        for _, v in PrioritizedTargetList do
            local category = v
            if type(category) == 'string' then
                category = ParseEntityCategory(category)
            end
            local distance = maxRange
            --LOG('* AIFindNearestCategoryTargetInRange: numTargets '..table.getn(TargetsInBaseRange)..'  ')
            for num, Target in TargetsInBaseRange do
                local TargetPosition = Target:GetPosition()
                -- check if the target is on the same layer then the attacker
                if not ValidateLayer(TargetPosition,platoon.MovementLayer) then continue end
                -- check if we have a special player index as enemy
                if enemyBrain and enemyIndex and enemyBrain ~= enemyIndex then continue end
                -- check if the Target is still alive, matches our target priority and can be attacked from our platoon
                if not Target.Dead and EntityCategoryContains(category, Target) and platoon:CanAttackTarget(squad, Target) then


                    --local GroundDefenseUnitsAtTargetPos = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.DIRECTFIRE) , TargetPosition, 60, 'Enemy' )
                    --local AntiAirUnitsAtTargetPos = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * categories.ANTIAIR , LastTargetPos, 60, 'Enemy' )


                    local targetRange = Utils.XZDistanceTwoVectors(position, TargetPosition)
                    if targetRange < distance then
                        path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, platoon.MovementLayer, platoon:GetPlatoonPosition(), TargetPosition, platoon.PlatoonData.NodeWeight or 10 )
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
            end
            if UnitWithPath then
                return UnitWithPath, UnitNoPath, path, reason
            end
        end
    end
    return UnitWithPath, UnitNoPath, path, reason
end

