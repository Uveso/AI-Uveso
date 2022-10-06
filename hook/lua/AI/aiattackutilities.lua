local UvesoOffsetaiattackutilitiesLUA = debug.getinfo(1).currentline - 1
SPEW('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..UvesoOffsetaiattackutilitiesLUA..'] * AI-Uveso: offset aiattackutilities.lua' )
--2360


-- hook for new hover movement layer
UvesoGetThreatOfUnitsFunction = GetThreatOfUnits
function GetThreatOfUnits(platoon)
    -- Only use this with AI-Uveso
    if not platoon:GetBrain().Uveso then
        return UvesoGetThreatOfUnitsFunction(platoon)
    end
    local totalThreat = 0
    local bpThreat = 0

    --get the layer this platoon acts on for attack weight calculation
    GetMostRestrictiveLayer(platoon)

    local units = platoon:GetPlatoonUnits()
    for _,u in units do
        if not u.Dead then
            if platoon.MovementLayer == 'Land' then
                bpThreat = u:GetBlueprint().Defense.SurfaceThreatLevel
            elseif platoon.MovementLayer == 'Water' then
                bpThreat = u:GetBlueprint().Defense.SurfaceThreatLevel
            elseif platoon.MovementLayer == 'Amphibious' or platoon.MovementLayer == 'Hover' then
                bpThreat = u:GetBlueprint().Defense.SurfaceThreatLevel
            elseif platoon.MovementLayer == 'Air' then
                bpThreat = u:GetBlueprint().Defense.SurfaceThreatLevel
                if u:GetBlueprint().Defense.AirThreatLevel then
                    bpThreat = bpThreat + u:GetBlueprint().Defense.AirThreatLevel
                end
            end
        end
        totalThreat = totalThreat + bpThreat
    end

    return totalThreat
end
-- hook for new hover movement layer
UvesoGetMostRestrictiveLayerFunction = GetMostRestrictiveLayer
function GetMostRestrictiveLayer(platoon)
    -- Only use this with AI-Uveso
    if not platoon:GetBrain().Uveso then
        return UvesoGetMostRestrictiveLayerFunction(platoon)
    end
    -- in case the platoon is already destroyed return false.
    if not platoon then
        return false
    end
    local unit = false
    local layer = false
    for k,v in platoon:GetPlatoonUnits() do
        if not v.Dead then
            local mType = v:GetBlueprint().Physics.MotionType
            -- only set air if no other layer is set
            if mType == 'RULEUMT_Air' and not layer then
                layer = 'Air' -- air can move on all layers
                unit = v
            -- set layer to land will stop the search
            elseif (mType == 'RULEUMT_Biped' or mType == 'RULEUMT_Land') then
                layer = 'Land'
                unit = v
                break
            -- set layer to water will stop the search
            elseif (mType == 'RULEUMT_Water' or mType == 'RULEUMT_SurfacingSub') then
                layer = 'Water'
                unit = v
                break
            -- only set to hover layer if we don't have already set amphibious layer
            elseif (mType == 'RULEUMT_AmphibiousFloating' or mType == 'RULEUMT_Hover') and layer ~= 'Amphibious' then
                layer = 'Hover' -- hover can use amphibious and land layer too
                unit = v
            elseif mType == 'RULEUMT_Amphibious' then
                layer = 'Amphibious' -- amphibious can use land layer too
                unit = v
            end

        end
    end
    platoon.MovementLayer = layer or 'Air'
    return unit
end
-- destructive hook for new hover movement layer
function GetPathGraphs()
    if ScenarioInfo.PathGraphs then
        return ScenarioInfo.PathGraphs
    else
        ScenarioInfo.PathGraphs = {}
    end

    local markerGroups = {
        Land = AIUtils.AIGetMarkerLocationsEx(nil, 'Land Path Node') or {},
        Water = AIUtils.AIGetMarkerLocationsEx(nil, 'Water Path Node') or {},
        Air = AIUtils.AIGetMarkerLocationsEx(nil, 'Air Path Node') or {},
        Amphibious = AIUtils.AIGetMarkerLocationsEx(nil, 'Amphibious Path Node') or {},
        Hover = AIUtils.AIGetMarkerLocationsEx(nil, 'Hover Path Node') or {},
    }

    for gk, markerGroup in markerGroups do
        for mk, marker in markerGroup do
            --Create stuff if it doesn't exist
            ScenarioInfo.PathGraphs[gk] = ScenarioInfo.PathGraphs[gk] or {}
            ScenarioInfo.PathGraphs[gk][marker.graph] = ScenarioInfo.PathGraphs[gk][marker.graph] or {}
            --Add the marker to the graph.
            ScenarioInfo.PathGraphs[gk][marker.graph][marker.name] = {name = marker.name, layer = gk, graphName = marker.graph, position = marker.position, adjacent = STR_GetTokens(marker.adjacentTo, ' '), impassability = marker.impassability or 0, color = marker.color}
        end
    end

    return ScenarioInfo.PathGraphs or {}
end



--AI-Uveso hook to inject own pathfinding function
UvesoPlatoonGenerateSafePathToFunction = PlatoonGenerateSafePathTo
function PlatoonGenerateSafePathTo(aiBrain, platoonLayer, startPos, endPos, optThreatWeight, optMaxMarkerDist, testPathDist)
    -- Only use this with AI-Uveso
    if not aiBrain.Uveso then
        return UvesoPlatoonGenerateSafePathToFunction(aiBrain, platoonLayer, startPos, endPos, optThreatWeight, optMaxMarkerDist, testPathDist)
    end
    if not GetPathGraphs()[platoonLayer] then
        return false, 'NoGraph'
    end

    --Get the closest path node at the platoon's position
    optMaxMarkerDist = optMaxMarkerDist or 250
    optThreatWeight = optThreatWeight or 1
    local startNode
    startNode = GetClosestPathNodeInRadiusByLayer(startPos, optMaxMarkerDist, platoonLayer)
    if not startNode then return false, 'NoStartNode' end

    --Get the matching path node at the destiantion
    local endNode = GetClosestPathNodeInRadiusByGraph(endPos, optMaxMarkerDist, startNode.graphName)
    if not endNode then return false, 'NoEndNode' end

    --Generate the safest path between the start and destination
    local path = GeneratePathUveso(aiBrain, startNode, endNode, ThreatTable[platoonLayer], optThreatWeight, endPos, startPos)
    if not path then return false, 'NoPath' end

    -- Insert the path nodes (minus the start node and end nodes, which are close enough to our start and destination) into our command queue.
    -- delete the first and last node only if they are very near (under 30 map units) to the start or end destination.
    local finalPath = {}
    local NodeCount = table.getn(path.path)
    for i,node in path.path do
        -- IF this is the first AND not the only waypoint AND its nearer 30 THEN continue and don't add it to the finalpath
        if i == 1 and NodeCount > 1 and VDist2(startPos[1], startPos[3], node.position[1], node.position[3]) < 30 then  
            continue
        end
        -- IF this is the last AND not the only waypoint AND its nearer 20 THEN continue and don't add it to the finalpath
        if i == NodeCount and NodeCount > 1 and VDist2(endPos[1], endPos[3], node.position[1], node.position[3]) < 20 then  
            continue
        end
        table.insert(finalPath, node.position)
    end
    -- in case we have a path with only 2 waypoints and skipped both:
    if not finalPath[1] then
        table.insert(finalPath, table.copy(endPos))
    end
    -- return the path
    return finalPath, 'PathOK'
end

function EngineerGenerateSafePathTo(aiBrain, platoonLayer, startPos, endPos, optThreatWeight, optMaxMarkerDist)
    if not GetPathGraphs()[platoonLayer] then
        return false, 'NoGraph'
    end

    --Get the closest path node at the platoon's position
    optMaxMarkerDist = optMaxMarkerDist or 250
    optThreatWeight = optThreatWeight or 1
    local startNode
    startNode = GetClosestPathNodeInRadiusByLayer(startPos, optMaxMarkerDist, platoonLayer)
    if not startNode then return false, 'NoStartNode' end

    --Get the matching path node at the destiantion
    local endNode = GetClosestPathNodeInRadiusByGraph(endPos, optMaxMarkerDist, startNode.graphName)
    if not endNode then return false, 'NoEndNode' end

    --Generate the safest path between the start and destination
    local path = GeneratePathUveso(aiBrain, startNode, endNode, ThreatTable[platoonLayer], optThreatWeight, endPos, startPos)
    if not path then return false, 'NoPath' end

    -- Insert the path nodes (minus the start node and end nodes, which are close enough to our start and destination) into our command queue.
    -- delete the first and last node only if they are very near (under 30 map units) to the start or end destination.
    local finalPath = {}
    local NodeCount = table.getn(path.path)
    for i,node in path.path do
        -- IF this is the first AND not the only waypoint AND its nearer 30 THEN continue and don't add it to the finalpath
        if i == 1 and NodeCount > 1 and VDist2(startPos[1], startPos[3], node.position[1], node.position[3]) < 30 then  
            continue
        end
        -- IF this is the last AND not the only waypoint AND its nearer 20 THEN continue and don't add it to the finalpath
        if i == NodeCount and NodeCount > 1 and VDist2(endPos[1], endPos[3], node.position[1], node.position[3]) < 20 then  
            continue
        end
        table.insert(finalPath, node.position)
    end

    -- return the path
    return finalPath, 'PathOK'
end

-- new function for pathing
function GeneratePathUveso(aiBrain, startNode, endNode, threatType, threatWeight, endPos, startPos)
    threatWeight = threatWeight or 1
    -- Check if we have this path already cached.
    if aiBrain.PathCache[startNode.name][endNode.name][threatWeight].path then
        -- Path is not older then 30 seconds. Is it a bad path? (the path is too dangerous)
        if aiBrain.PathCache[startNode.name][endNode.name][threatWeight].path == 'bad' then
            -- We can't move this way at the moment. Too dangerous.
            return false
        else
            -- The cached path is newer then 30 seconds and not bad. Sounds good :) use it.
            return aiBrain.PathCache[startNode.name][endNode.name][threatWeight].path
        end
    end
    -- loop over all path's and remove any path from the cache table that is older then 30 seconds
    if aiBrain.PathCache then
        local GameTime = GetGameTimeSeconds()
        -- loop over all cached paths
        for StartNodeName, CachedPaths in aiBrain.PathCache do
            -- loop over all paths starting from StartNode
            for EndNodeName, ThreatWeightedPaths in CachedPaths do
                -- loop over every path from StartNode to EndNode stored by ThreatWeight
                for ThreatWeight, PathNodes in ThreatWeightedPaths do
                    -- check if the path is older then 30 seconds.
                    if GameTime - 30 > PathNodes.settime then
                        --AILog('* AI-Uveso: GeneratePathUveso() Found old path: storetime: '..PathNodes.settime..' store+60sec: '..(PathNodes.settime + 30)..' actual time: '..GameTime..' timediff= '..(PathNodes.settime + 30 - GameTime) )
                        -- delete the old path from the cache.
                        aiBrain.PathCache[StartNodeName][EndNodeName][ThreatWeight] = nil
                    end
                end
            end
        end
    end
    -- We don't have a path that is newer then 30 seconds. Let's generate a new one.
    --Create path cache table. Paths are stored in this table and saved for 30 seconds, so
    --any other platoons needing to travel the same route can get the path without any extra work.
    aiBrain.PathCache = aiBrain.PathCache or {}
    aiBrain.PathCache[startNode.name] = aiBrain.PathCache[startNode.name] or {}
    aiBrain.PathCache[startNode.name][endNode.name] = aiBrain.PathCache[startNode.name][endNode.name] or {}
    aiBrain.PathCache[startNode.name][endNode.name][threatWeight] = {}
    local fork = {}
    -- Is the Start and End node the same OR is the distance to the first node longer then to the destination ?
    if startNode.name == endNode.name
    or VDist2(startPos[1], startPos[3], startNode.position[1], startNode.position[3]) > VDist2(startPos[1], startPos[3], endPos[1], endPos[3])
    or VDist2(startPos[1], startPos[3], endPos[1], endPos[3]) < 50 then
        -- store as path only our current destination.
        fork.path = { { position = endPos } }
        aiBrain.PathCache[startNode.name][endNode.name][threatWeight] = { settime = GetGameTimeSeconds(), path = fork }
        -- return the destination position as path
        return fork
    end
    -- Set up local variables for our path search
    local AlreadyChecked = {}
    local curPath = {}
    local lastNode = {}
    local newNode = {}
    local dist = 0
    local threat = 0
    local lowestpathkey = 1
    local lowestcost
    local tableindex = 0
    local armyIndex = aiBrain:GetArmyIndex()
    -- Get all the waypoints that are from the same movementlayer than the start point.
    local graph = GetPathGraphs()[startNode.layer][startNode.graphName]
    -- For the beginning we store the startNode here as first path node.
    local queue = {
        {
        cost = 0,
        path = {startNode},
        }
    }
    local table = table
    local unpack = unpack
    local GetThreatFromHeatMap = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetThreatFromHeatMap
    -- Now loop over all path's that are stored in queue. If we start, only the startNode is inside the queue
    -- (We are using here the "A*(Star) search algorithm". An extension of "Edsger Dijkstra's" pathfinding algorithm used by "Shakey the Robot" in 1959)
    while aiBrain.Status ~= "Defeat" do
        -- remove the table (shortest path) from the queue table and store the removed table in curPath
        -- (We remove the path from the queue here because if we don't find a adjacent marker and we
        --  have not reached the destination, then we no longer need this path. It's a dead end.)
        curPath = table.remove(queue,lowestpathkey)
        if not curPath then break end
        -- get the last node from the path, so we can check adjacent waypoints
        lastNode = curPath.path[table.getn(curPath.path)]
        -- Have we already checked this node for adjacenties ? then continue to the next node.
        if not AlreadyChecked[lastNode] then
            -- Check every node (marker) inside lastNode.adjacent
            for i, adjacentNode in lastNode.adjacent do
                -- get the node data from the graph table
                newNode = graph[adjacentNode]
                -- check, if we have found a node.
                if newNode then
                    -- copy the path from the startNode to the lastNode inside fork,
                    -- so we can add a new marker at the end and make a new path with it
                    fork = {
                        cost = curPath.cost,            -- cost from the startNode to the lastNode
                        path = {unpack(curPath.path)},  -- copy full path from starnode to the lastNode
                    }
                    -- get distance from new node to destination node
                    dist = VDist2(newNode.position[1], newNode.position[3], endNode.position[1], endNode.position[3])
                    -- get threat from current node to adjacent node
                    threat = GetThreatFromHeatMap(armyIndex, newNode.position, startNode.layer)
                    -- add as cost for the path the distance and threat to the overall cost from the whole path
                    --fork.cost = fork.cost + dist + (threat * 1) * threatWeight
                    fork.cost = fork.cost + dist + (newNode.impassability or 0) * 30 + (threat * 1) * threatWeight
                    -- add the newNode at the end of the path
                    table.insert(fork.path, newNode)
                    -- check if we have reached our destination
                    if newNode.name == endNode.name then
                        -- store the path inside the path cache
                        aiBrain.PathCache[startNode.name][endNode.name][threatWeight] = { settime = GetGameTimeSeconds(), path = fork }
                        -- return the path
                        return fork
                    end
                    -- add the path to the queue, so we can check the adjacent nodes on the last added newNode
                    table.insert(queue,fork)
                end
            end
            -- Mark this node as checked
            AlreadyChecked[lastNode] = true
        end
        -- Search for the shortest / safest path and store the table key in lowestpathkey
        lowestcost = 100000000
        lowestpathkey = 1
        tableindex = 1
        while queue[tableindex].cost do
            if lowestcost > queue[tableindex].cost then
                lowestcost = queue[tableindex].cost
                lowestpathkey = tableindex
            end
            tableindex = tableindex + 1
        end
    end
    -- At this point we have not found any path to the destination.
    -- The path is to dangerous at the moment (or there is no path at all). We will check this again in 30 seconds.
    aiBrain.PathCache[startNode.name][endNode.name][threatWeight] = { settime = GetGameTimeSeconds(), path = 'bad' }
    return false
end

-- moved to AIMarkerGenerator.lua
--[[
function CanGraphAreaTo(startPos, destPos, layer)
    if layer == 'Air' then
        return true
    end
    local graphTable = GetPathGraphs()[layer]
    --AILog('* AI-Uveso: CanGraphAreaTo: graphTable['..layer..']')
    --AILog('* AI-Uveso: CanGraphAreaTo: startPos = '..repr(startPos))
    --AILog('* AI-Uveso: CanGraphAreaTo: destPos = '..repr(destPos))
    local startNode, endNode, distS, distE
    local bestDistS, bestDistE = 1000000, 1000000 -- will only find markers that are closer than 1000 map units
    if graphTable then
        for mn, markerInfo in graphTable['Default'..layer] do
            distS = VDist2Sq(startPos[1], startPos[3], markerInfo.position[1], markerInfo.position[3])
            distE = VDist2Sq(destPos[1], destPos[3], markerInfo.position[1], markerInfo.position[3])
            if distS < bestDistS then
                --DrawLinePop(startPos, markerInfo.position, 'ffFF0000')
                --AILog('* AI-Uveso: CanGraphAreaTo: distS('..math.sqrt(distS)..')')
                --AILog('* AI-Uveso: CanGraphAreaTo: markerInfo.name('..markerInfo.name..')')
                bestDistS = distS
                startNode = markerInfo.name
            end
            if distE < bestDistE then
                --DrawLinePop(destPos, markerInfo.position, 'ff0000FF')
                --AILog('* AI-Uveso: CanGraphAreaTo: distE('..math.sqrt(distE)..')')
                --AILog('* AI-Uveso: CanGraphAreaTo: markerInfo.name('..markerInfo.name..')')
                bestDistE = distE
                endNode = markerInfo.name
            end
        end
    end
    --AILog('* AI-Uveso: CanGraphAreaTo: startNode: '..repr(startNode)..' - endNode: '..repr(endNode)..'')
    --AILog('* AI-Uveso: CanGraphAreaTo: Start Area: '..repr(Scenario.MasterChain._MASTERCHAIN_.Markers[startNode].GraphArea)..' - End Area: '..repr(Scenario.MasterChain._MASTERCHAIN_.Markers[endNode].GraphArea)..'')
    if startNode and endNode and Scenario.MasterChain._MASTERCHAIN_.Markers[startNode].GraphArea == Scenario.MasterChain._MASTERCHAIN_.Markers[endNode].GraphArea then
        --AILog('* AI-Uveso: CanGraphAreaTo: startNode: '..repr(startNode)..' - endNode: '..repr(endNode)..' TRUE')
        return true
    end
    --AIWarn('* AI-Uveso: CanGraphAreaTo: startNode: '..repr(startNode)..' - endNode: '..repr(endNode)..' FALSE')
    return false
end
--]]

----For time debug GeneratePathUveso()
--local TimeHIGHEST
--local TimeSUM = 0
--local TimeCOUNT = 0
--local TimeAVERAGE
--local LastCheck = 0
--function GeneratePathUveso(aiBrain, startNode, endNode, threatType, threatWeight, endPos, startPos)
--    local START = GetSystemTimeSecondsOnlyForProfileUse()
--    local PATHs = GeneratePathUvesoXXX(aiBrain, startNode, endNode, threatType, threatWeight, endPos, startPos)
--    local END = GetSystemTimeSecondsOnlyForProfileUse()
--    local DIV = END - START
--    if DIV > 0.001 then
--        if LastCheck + 60 < GetSystemTimeSecondsOnlyForProfileUse() then
--            LastCheck = GetSystemTimeSecondsOnlyForProfileUse()
--            TimeAVERAGE = nil
--        end
--        if not TimeHIGHEST or DIV > TimeHIGHEST then
--            TimeHIGHEST = DIV
--            TimeAVERAGE = nil
--        end
--        TimeSUM = TimeSUM + (DIV)
--        TimeCOUNT = TimeCOUNT + 1
--        if not TimeAVERAGE or TimeAVERAGE < TimeSUM/TimeCOUNT then
--            TimeAVERAGE = TimeSUM/TimeCOUNT
--            AILog('- Pathing Highest:'..(TimeHIGHEST)..' - Pathing Average:'..(TimeSUM/TimeCOUNT)..' - Pathing Actual:'..(DIV))
--        end
--    end
--    return PATHs
--end
