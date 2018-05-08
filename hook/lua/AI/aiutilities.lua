-- hook until AI patch
OLDAIGetMarkerLocationsEx = AIGetMarkerLocationsEx
function AIGetMarkerLocationsEx(aiBrain, markerType)
    local markerList = {}
    local markers = ScenarioUtils.GetMarkers()
    if markers then
        markerList = GenerateMarkerList(markerList,markers,markerType)
        LOG('AIGetMarkerLocationsEx '..table.getn(markerList)..' markers for '..markerType)
        -- If we have no Amphibious Path Nodes, generate them from Land and Water Nodes
        if markerType == 'Amphibious Path Node' and table.getn(markerList) <= 0 then
            markerList = GenerateAmphibiousMarkerList(markerList,markers,'Land Path Node')
            markerList = GenerateAmphibiousMarkerList(markerList,markers,'Water Path Node')
            LOG('AIGetMarkerLocationsEx '..table.getn(markerList)..' markers for '..markerType..' (generated from Land/Water markers).')
            -- Inject the new amphibious marker to the MasterChain
            for k, v in markerList do
                if v.type == 'Amphibious Path Node' then
                    Scenario.MasterChain._MASTERCHAIN_.Markers[v.name] = v
                end
            end
        end
    end
    -- Make a list of all the markers in the scenario that are of the markerType
    return markerList
end

function GenerateMarkerList(markerList,markers,markerType)
    for k, v in markers do
        if v.type == markerType then
            -- copy the marker to a local variable. We don't want to change values inside the original markers array
            local marker = table.copy(v)
            marker.name = k
            -- insert the (default)graph if missing.
            if not marker.graph then
                marker.graph = 'Default'..markerType
            end
            table.insert(markerList, marker)
        end
    end
    return markerList
end

function GenerateAmphibiousMarkerList(markerList,markers,markerType)
    for k, v in markers do
        local marker = table.copy(v)
        if marker.type == markerType then
            -- transform adjacentTo to Amphibious marker names
            local adjacentTo = ''
            for i, node in STR_GetTokens(marker.adjacentTo, ' ') do
                if adjacentTo == '' then
                    adjacentTo = 'Amph'..node
                else
                    adjacentTo = adjacentTo..' '..'Amph'..node
                end
            end
            marker.adjacentTo = adjacentTo
            -- Add 'Amph' to marker name
            marker.name = 'Amph'..k
            marker.graph = 'DefaultAmphibious'
            marker.type = 'Amphibious Path Node'
            marker.color = 'ff00FFFF'
            table.insert(markerList, marker)
        end
    end
    return markerList
end

-- hook until AI patch
OLDAIFindBrainTargetInRange = AIFindBrainTargetInRange
function AIFindBrainTargetInRange(aiBrain, platoon, squad, maxRange, atkPri, enemyBrain)
    -- Only use this with AI-Uveso
    if not aiBrain.Uveso then
        return OLDAIFindBrainTargetInRange(aiBrain, platoon, squad, maxRange, atkPri, enemyBrain)
    end
    local position = platoon:GetPlatoonPosition()
    if not aiBrain or not position or not maxRange or not platoon or not enemyBrain then
        return false
    end

    local enemyIndex = enemyBrain:GetArmyIndex()
    local targetUnits = aiBrain:GetUnitsAroundPoint(categories.ALLUNITS, position, maxRange, 'Enemy')
    for _, v in atkPri do
        local category = v
        if type(category) == 'string' then
            category = ParseEntityCategory(category)
        end
        local retUnit = false
        local distance = false
        for num, unit in targetUnits do
            if not unit.Dead and EntityCategoryContains(category, unit) and unit:GetAIBrain():GetArmyIndex() == enemyIndex and platoon:CanAttackTarget(squad, unit) then
                local unitPos = unit:GetPosition()
                if not retUnit or Utils.XZDistanceTwoVectors(position, unitPos) < distance then
                    retUnit = unit
                    distance = Utils.XZDistanceTwoVectors(position, unitPos)
                end
            end
        end
        if retUnit then
            return retUnit
        end
    end

    return false
end

-- Hook only for Uveso AI
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

function AIFindNearestCategoryTargetInRange(aiBrain, platoon, squad, position, maxRange, PrioritizedTargetList, TargetSearchCategory, enemyBrain)
    local TargetSearchCategory = TargetSearchCategory
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

    for _, range in RangeList do
        TargetsInBaseRange = aiBrain:GetUnitsAroundPoint(TargetSearchCategory, position, range, 'Enemy')
        --DrawCircle(position, range, '0000FF')
        for _, v in PrioritizedTargetList do
            local category = v
            if type(category) == 'string' then
                category = ParseEntityCategory(category)
            end
            local retUnit = false
            local distance = maxRange
            local path, reason
            --LOG('* AIFindNearestCategoryTargetInRange: numTargets '..table.getn(TargetsInBaseRange)..'  ')
            for num, unit in TargetsInBaseRange do
                if not ValidateLayer(unit:GetPosition(),platoon.MovementLayer) then continue end
                if enemyBrain and enemyIndex and enemyBrain ~= enemyIndex then continue end
                if not unit.Dead and EntityCategoryContains(category, unit) and platoon:CanAttackTarget(squad, unit) then
                    local targetRange = Utils.XZDistanceTwoVectors(position, unit:GetPosition())
                    if targetRange < distance then
                        path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, platoon.MovementLayer, platoon:GetPlatoonPosition(), unit:GetPosition(), platoon.PlatoonData.NodeWeight or 10 )
                        if path or reason == 'NoGraph' then
                            retUnit = unit
                            distance = targetRange
                            --LOG('* AIFindNearestNavalCategoryTargetInRange: Possible target. distance '..distance..'  ')
                        else
                            --LOG('* AIFindNearestNavalCategoryTargetInRange: no path to target reason '..reason..'  ')
                            if reason != 'NoPath' then
                                LOG('* AIFindNearestNavalCategoryTargetInRange: Bad Target. reason '..reason..'  ')
                            end
                        end
                    end
                end
            end
            if retUnit then
                return retUnit, path, reason
            end
        end
    end
    return false
end

function AIFindNearestNavalCategoryTargetInRange(aiBrain, platoon, squad, position, maxRange, PrioritizedTargetList, TargetSearchCategory, enemyBrain)
    local TargetSearchCategory = TargetSearchCategory
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

    for _, range in RangeList do
        TargetsInBaseRange = aiBrain:GetUnitsAroundPoint(TargetSearchCategory, position, range, 'Enemy')
        --DrawCircle(position, range, '0000FF')
        for _, v in PrioritizedTargetList do
            local category = v
            if type(category) == 'string' then
                category = ParseEntityCategory(category)
            end
            local retUnit = false
            local distance = maxRange
            local path, reason
            --LOG('* AIFindNearestNavalCategoryTargetInRange: numTargets '..table.getn(TargetsInBaseRange)..'  ')
            for num, unit in TargetsInBaseRange do
                if not ValidateLayer(unit:GetPosition(),platoon.MovementLayer) then continue end
                if enemyBrain and enemyIndex and enemyBrain ~= enemyIndex then continue end
                if not unit.Dead and EntityCategoryContains(category, unit) and platoon:CanAttackTarget(squad, unit) then
                    local targetRange = Utils.XZDistanceTwoVectors(position, unit:GetPosition())
                    if targetRange < distance then
                        path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, platoon.MovementLayer, platoon:GetPlatoonPosition(), unit:GetPosition(), platoon.PlatoonData.NodeWeight or 10 )
                        if path or reason == 'NoGraph' then
                            retUnit = unit
                            distance = targetRange
                            --LOG('* AIFindNearestNavalCategoryTargetInRange: Possible target. distance '..distance..'  ')
                        else
                            if reason != 'NoPath' then
                                --LOG('* AIFindNearestNavalCategoryTargetInRange: Bad Target. reason '..reason..'  ')
                            end
                        end
                    end
                end
            end
            if retUnit then
                return retUnit, path, reason
            end
        end
    end
    return false
end
