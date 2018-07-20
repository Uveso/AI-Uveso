
--hook to inject own pathfinding function
OLDPlatoonGenerateSafePathTo = PlatoonGenerateSafePathTo
function PlatoonGenerateSafePathTo(aiBrain, platoonLayer, startPos, endPos, optThreatWeight, optMaxMarkerDist, testPathDist)
    -- Only use this with AI-Uveso
    if not aiBrain.Uveso then
        return OLDPlatoonGenerateSafePathTo(aiBrain, platoonLayer, startPos, endPos, optThreatWeight, optMaxMarkerDist, testPathDist)
    end
    if not GetPathGraphs()[platoonLayer] then
        --LOG('*AI DEBUG: PlatoonGenerateSafePathTo(): No graph for layer ('..platoonLayer..') found.')
        return false, 'NoGraph'
    end
    optMaxMarkerDist = optMaxMarkerDist or 250
    optThreatWeight = optThreatWeight or 1
    local finalPath = {}

    --If we are within 100 units of the destination, don't bother pathing. (Sorian and Duncan AI)
    if (aiBrain.Sorian or aiBrain.Duncan) and (VDist2(startPos[1], startPos[3], endPos[1], endPos[3]) <= 100
    or (testPathDist and VDist2Sq(startPos[1], startPos[3], endPos[1], endPos[3]) <= testPathDist)) then
        table.insert(finalPath, endPos)
        return finalPath, 'PathOK'
    end

    --Get the closest path node at the platoon's position
    local startNode
    if (aiBrain.Sorian or aiBrain.Duncan) then
        startNode = GetClosestPathNodeInRadiusByLayerSorian(startPos, endPos, optMaxMarkerDist, platoonLayer)
    else
        startNode = GetClosestPathNodeInRadiusByLayer(startPos, optMaxMarkerDist, platoonLayer)
    end
    if not startNode then return false, 'NoStartNode' end

    --Get the matching path node at the destiantion
    local endNode
    if (aiBrain.Sorian or aiBrain.Duncan) then
    	endNode = GetClosestPathNodeInRadiusByLayerSorian(endPos, endPos, optMaxMarkerDist, platoonLayer)
    else
        endNode = GetClosestPathNodeInRadiusByGraph(endPos, optMaxMarkerDist, startNode.graphName)
    end
    if not endNode then return false, 'NoEndNode' end

    --Generate the safest path between the start and destination
    local path
    if aiBrain.Sorian or aiBrain.Duncan then
        -- Sorian and Duncans AI are using a strong modified pathfinding with path shortcuts, range checks and path caching for better performance.
        path = GeneratePathSorian(aiBrain, startNode, endNode, ThreatTable[platoonLayer], optThreatWeight, endPos, startPos)
    elseif aiBrain.Uveso then
        -- Uveso AI is using a optimized version of the original GeneratePath function with extended path caching.
        path = GeneratePathUveso(aiBrain, startNode, endNode, ThreatTable[platoonLayer], optThreatWeight, endPos, startPos)
    else
        -- The original AI is using the vanilla version of GeneratePath. No cache, ugly (AStarLoopBody) code, but reacts faster on new situations.
        path = GeneratePath(aiBrain, startNode, endNode, ThreatTable[platoonLayer], optThreatWeight, endPos, startPos)
    end
    if not path then return false, 'NoPath' end

    -- Insert the path nodes (minus the start node and end nodes, which are close enough to our start and destination) into our command queue.
    if aiBrain.Uveso then
        local NodeCount = table.getn(path.path)
        -- delete the first and last node only if they are very near (under 30 map units) to the start or end destination.
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
    else
        for i,node in path.path do
            if i > 1 and i < table.getn(path.path) then
                table.insert(finalPath, node.position)
            end
        end
    end

    -- return the path
    return finalPath, 'PathOK'
end

-- new function for pathing
function GeneratePathUveso(aiBrain, startNode, endNode, threatType, threatWeight, endPos, startPos)
    threatWeight = threatWeight or 1
    -- Check first if this path is bad at all. (no connection to the destination)
    if aiBrain.PathCache[startNode.name][endNode.name][1].path and aiBrain.PathCache[startNode.name][endNode.name][1].path == 'bad' then
        -- We can't move this way with any threatWeight.
        return false
    -- Check if we have this path already cached.
    elseif aiBrain.PathCache[startNode.name][endNode.name][threatWeight].path then
        -- OK, we have a path stored. Is the path still valid ? (not older then 1 minute?)
        if aiBrain.PathCache[startNode.name][endNode.name][threatWeight].settime + 60 > GetGameTimeSeconds() then
            -- Path is not older then 1 minute. Is it a bad path? (the path is too dangerous)
            if aiBrain.PathCache[startNode.name][endNode.name][threatWeight].path == 'bad' then
                -- We can't move this way at the moment. Too dangerous.
                return false
            else
                -- The cached path is newer then 1 minute and not bad. Sounds good :) use it.
                return aiBrain.PathCache[startNode.name][endNode.name][threatWeight].path
            end
        end
    end
    -- Queue will be sorted such that best path is at the end.
    -- For the beginning we store the startNode here as first path node.
    local queue = {
        {
        cost = 0,
        path = {startNode},
        threat = 0
        }
    }
    -- loop over all path's and remove any path from the cache table that is older then 60 seconds
    if aiBrain.PathCache then
        local GameTime = GetGameTimeSeconds()
        -- loop over all cached paths
        for StartNodeName, CachedPaths in aiBrain.PathCache do
            -- loop over all paths starting from StartNode
            for EndNodeName, ThreatWeightedPaths in CachedPaths do
                -- loop over every path from StartNode to EndNode stored by ThreatWeight
                for ThreatWeight, PathNodes in ThreatWeightedPaths do
                    -- check if the path is older then 1 minute.
                    if GameTime > PathNodes.settime + 60 then
                        --LOG('* AIDEBUG: GeneratePathUveso() Found old path: storetime: '..PathNodes.settime..' store+60sec: '..(PathNodes.settime + 60)..' actual time: '..GameTime..' timediff= '..(PathNodes.settime + 60 - GameTime) )
                        -- delete the old path from the cache.
                        aiBrain.PathCache[StartNodeName][EndNodeName][ThreatWeight] = nil
                    end
                end
            end
        end
    end
    -- We don't have a path that is newer then 1 minute. Let's generate a new one.
    -- First get all the waypoints that are from the same movementlayer then the start point.
    local graph = GetPathGraphs()[startNode.layer][startNode.graphName]
    --Create path cache table. Paths are stored in this table and saved for 1 minute, so
    --any other platoons needing to travel the same route can get the path without any extra work.
    aiBrain.PathCache = aiBrain.PathCache or {}
    aiBrain.PathCache[startNode.name] = aiBrain.PathCache[startNode.name] or {}
    aiBrain.PathCache[startNode.name][endNode.name] = aiBrain.PathCache[startNode.name][endNode.name] or {}
    aiBrain.PathCache[startNode.name][endNode.name][threatWeight] = {}
    -- Is the Start and End node the same OR is the distance to the first node longer then to the destination ?
    if startNode.name == endNode.name
    or VDist2(startPos[1], startPos[3], startNode.position[1], startNode.position[3]) > VDist2(startPos[1], startPos[3], endPos[1], endPos[3])
    or VDist2(startPos[1], startPos[3], endPos[1], endPos[3]) < 50 then
        -- remove the last table (path) from the queue table and store the removed table in queue
        queue = table.remove(queue)
        -- store as path our current destination. We will move the rest of the way with build or attack command
        queue.path = { { position = startPos } }
        aiBrain.PathCache[startNode.name][endNode.name][threatWeight] = { settime = GetGameTimeSeconds(), path = queue }
        -- return the destination position as path
        return queue
    end
    -- Set up local variables for our path search
    local AlreadyChecked = {}
    local curPath = {}
    local lastNode = {}
    local newNode = {}
    local fork = {}
    local dist = 0
    local threat = 0
    local MaxMapTravel = VDist2(0,0,ScenarioInfo.size[1],ScenarioInfo.size[2]) -- The distance between 2 waypoints can't be greater then the map diagonal
    -- Now loop over all path's that are stored in queue. If we start, only the startNode is inside the queue
    -- (We are using here the "A*(Star) search algorithm". An extension of Edsger Dijkstra's pathfinding algorithm used by "Shakey the Robot" in 1959)
    while table.getn(queue) > 0 do
        -- remove the last table (path) from the queue table and store the removed table in curPath
        -- (We remove the path from the queue here because if we don't find a adjacent marker and we
        --  have not reached the destination, then we no longer need this path. It's a dead end.)
        curPath = table.remove(queue)
        -- get the last node from the path, so we can check adjacent waypoints
        lastNode = curPath.path[table.getn(curPath.path)]
        -- Is the last node identical to our destination? Then use the path.
        if lastNode == endNode then
            -- store the path inside the path cache
            aiBrain.PathCache[startNode.name][endNode.name][threatWeight] = { settime = GetGameTimeSeconds(), path = curPath }
            -- return the path
            return curPath
        -- Have we already checked this node for adjacenties ? then continue to the next node.
        elseif AlreadyChecked[lastNode] then
            continue
        end
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
                    path = {unpack(curPath.path)},  -- full path from starnode to the lastNode
                    threat = curPath.threat         -- threat from the startNode to the lastNode
                }
                -- get distance from new node to destination node
                dist = VDist2(newNode.position[1], newNode.position[3], endNode.position[1], endNode.position[3])
                -- this brings the dist value from 0 to 100% of the maximum length with can travel on a map
                dist = 100 / MaxMapTravel * dist
                -- get threat from current node to adjacent node
                threat = aiBrain:GetThreatBetweenPositions(newNode.position, lastNode.position, nil, threatType)
                -- add as cost for the path the distance and threat to the overall cost from the whole path
                fork.cost = fork.cost + dist + threat*threatWeight
                -- add the thread from the last node to this adjacent node to the overall cost from the whole path
                fork.threat = fork.threat + threat
                -- add the newNode at the end of the path
                table.insert(fork.path, newNode)
                -- add the path to the queue, so we can check the adjacent nodes on the last added newNode
                table.insert(queue,fork)
             else
                SPEW('* AI DEBUG: GeneratePathUveso: No node found for adjacentNode ('..repr(adjacentNode)..') from node [ '..lastNode.name..' ]')
             end
        end
        -- Mark this node as checked
        AlreadyChecked[lastNode] = true
        -- Sort queue by cost (distance and threat). The path with the shortest way to the destination (less cost) will be at the end
        table.sort(queue, function(a,b) return a.cost > b.cost end)
    end
    -- At this point we have not found any path to the destination.
    if threatWeight == 1 then
        -- If the threatWeight is 1, then we will never have a good path if we path again. Store it forever. (technically 24 hours)
        aiBrain.PathCache[startNode.name][endNode.name][threatWeight] = { settime = 60*60*24, path = 'bad' }
    else
        -- The path is to dangerous at the moment (or there is no path at all). We will check this again in 1 minute.
        aiBrain.PathCache[startNode.name][endNode.name][threatWeight] = { settime = GetGameTimeSeconds(), path = 'bad' }
    end
    return false
end
