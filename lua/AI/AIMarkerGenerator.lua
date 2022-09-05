
local WantedGridSize = 16
local playableArea
local PlayableMapSizeX
local PlayableMapSizeZ
local MarkerGridCountX
local MarkerGridCountZ
local MarkerGridSizeX
local MarkerGridSizeZ
local MarkerGrid = {}
local PathMap = {}

function InitMarkerGenerator()
    playableArea = import("/mods/AI-Uveso/lua/AI/AITargetManager.lua").GetPlayableArea()
    PlayableMapSizeX = playableArea[3] - playableArea[1]
    PlayableMapSizeZ = playableArea[4] - playableArea[2]
    MarkerGridCountX = math.floor(PlayableMapSizeX / WantedGridSize)
    MarkerGridCountZ = math.floor(PlayableMapSizeZ / WantedGridSize)
    MarkerGridSizeX = PlayableMapSizeX / MarkerGridCountX
    MarkerGridSizeZ = PlayableMapSizeZ / MarkerGridCountZ
end

function SetWantedGridSize(size)
    AIDebug("* AI-Uveso: Function SetWantedGridSize() Grid size for AI marker set to: "..size, true)
    WantedGridSize = size
    InitMarkerGenerator()
    return
end

function MarkerGridCountXZ()
    return MarkerGridCountX, MarkerGridCountZ
end

function BuildTerrainPathMap()
    AIDebug("* AI-Uveso: Function BuildTerrainPathMap() started.", true)
    -- disabled for release.
    if 1 == 2 then
        return
    end
    
    local waterDepth
    for x = playableArea[1], playableArea[3] do
        PathMap[x] = {}
        for z = playableArea[2], playableArea[4] do
            PathMap[x][z] = {}
            -- check for water depth. -21 would be 21 beyond the water surface
            waterDepth = GetTerrainHeight(x, z) - GetSurfaceHeight(x, z)
            -- make sure waterdeep is not over 0 (Land)
            waterDepth = math.min(waterDepth, 0)
            -- set the layer depending on the water depth
            if waterDepth >= 0 then
                -- 0 is land / hover / amphibious (not naval)
                PathMap[x][z].layer = "Land"
            elseif waterDepth >= -1.8 then
                -- -1.8 to 0 is hover / amphibious (not land or naval)
                PathMap[x][z].layer = "Hover"
            elseif waterDepth >= -24.9 then
                -- -24.9 to -1.8 is hover / amphibious / naval (not land)
                PathMap[x][z].layer = "Amphibious"
            else
                -- -25 to xx is hover / naval (not amphibious / land)
                PathMap[x][z].layer = "Naval"
            end
            if waterDepth <= -25.0 then
                -- block pathing for seabed deeper than 25
                PathMap[x][z].blocked = true
            else
                -- check for pathing. (check also water for seabed pathing)
                PathMap[x][z].blocked = not IsPathable(x,z)
            end
        end
    end
    -- debug draw
    --ForkThread(PathableTerrainRenderThread)
end

function IsPathable(x,z)
    if not GetTerrainType(x,z).Blocking then
        local U, D, L, R, LU, RU, LD, RD
        U = GetTerrainHeight(x + 0.50, z + 0.01 )
        D = GetTerrainHeight(x + 0.50, z + 0.99)
        L = GetTerrainHeight(x + 0.01, z + 0.50)
        R = GetTerrainHeight(x + 0.99, z + 0.50)
        LU = GetTerrainHeight(x + 0.20, z + 0.20)
        RU = GetTerrainHeight(x + 0.80, z + 0.20)
        LD = GetTerrainHeight(x + 0.20, z + 0.80)
        RD = GetTerrainHeight(x + 0.80, z + 0.80)
        return math.max(math.abs(U-D), math.abs(L-R), math.abs(LU-RD), math.abs(LD-RU)) < 0.72
    end
    return false
end

local Offsets = {
    ['Default']    = { [1] =  0.0, [2] =  0.0, [3] =  0.0, ['color'] = 'ff000000', ['colorBlocked'] = 'ffFF0000' },
    ['Land']       = { [1] =  0.0, [2] =  0.0, [3] =  0.0, ['color'] = 'fff4a460', ['colorBlocked'] = 'ffFFa460' },
    ['Naval']      = { [1] = -0.5, [2] =  0.0, [3] = -0.5, ['color'] = 'ff27408b', ['colorBlocked'] = 'ffFF408b' },
    ['Hover']      = { [1] =  0.5, [2] =  0.0, [3] =  0.5, ['color'] = 'ff1e90ff', ['colorBlocked'] = 'ffFF90ff' },
    ['Amphibious'] = { [1] = -1.0, [2] =  0.0, [3] = -1.0, ['color'] = 'ff0e80Ef', ['colorBlocked'] = 'ffFF80Ef' },
    ['Air']        = { [1] = -1.5, [2] =  0.0, [3] = -1.5, ['color'] = 'ffffffff', ['colorBlocked'] = 'ffff0000' },
}

function PathableTerrainRenderThread()
    while true do
        coroutine.yield(2)
        for x = playableArea[1], playableArea[3], 1 do
            for z = playableArea[2], playableArea[4], 1 do
                if PathMap[x][z].blocked then
                    if PathMap[x][z].layer == "Land" then
                        DrawCircle({x + 0.50, GetTerrainHeight(x, z) , z + 0.50}, 0.5, Offsets[PathMap[x][z].layer].colorBlocked )
                    elseif PathMap[x][z].layer == "Hover" then
                        DrawCircle({x + 0.50, GetTerrainHeight(x, z) , z + 0.50}, 0.5, Offsets[PathMap[x][z].layer].colorBlocked )
                    elseif PathMap[x][z].layer == "Amphibious" then
                        DrawCircle({x + 0.50, GetTerrainHeight(x, z) , z + 0.50}, 0.5, Offsets[PathMap[x][z].layer].colorBlocked )
                    elseif PathMap[x][z].layer == "Naval" then
                        DrawCircle({x + 0.50, GetTerrainHeight(x, z) , z + 0.50}, 0.5, Offsets[PathMap[x][z].layer].colorBlocked )
                    end
                else
                    if PathMap[x][z].layer == "Land" then
                        --DrawCircle({x + 0.50, GetTerrainHeight(x, z) , z + 0.50}, 0.5, Offsets[PathMap[x][z].layer].color )
                    elseif PathMap[x][z].layer == "Hover" then
                        --DrawCircle({x + 0.50, GetTerrainHeight(x, z) , z + 0.50}, 0.5, Offsets[PathMap[x][z].layer].color )
                    elseif PathMap[x][z].layer == "Amphibious" then
                        --DrawCircle({x + 0.50, GetTerrainHeight(x, z) , z + 0.50}, 0.5, Offsets[PathMap[x][z].layer].color )
                    elseif PathMap[x][z].layer == "Naval" then
                        --DrawCircle({x + 0.50, GetTerrainHeight(x, z) , z + 0.50}, 0.5, Offsets[PathMap[x][z].layer].color )
                    end
                end
            end
        end
    end
end

function MarkerRenderThread()
    AIDebug("* AI-Uveso: Function MarkerRenderThread() started.", true)
    local MarkerPosition = {}
    local Marker2Position = {}
    local adjancents
    local otherMarker
    while GetGameTimeSeconds() < 5 do
        coroutine.yield(10)
    end
    while true do
        for x, MarkerGridYrow in MarkerGrid or {} do
            for y, markerInfo in MarkerGridYrow or {} do
                -- Draw the marker path node
                DrawCircle(markerInfo.position, 2.5, Offsets[markerInfo.graph]['color'] or 'ff000000' )
                -- Draw the connecting lines to its adjacent nodes
                for i, node in markerInfo.adjacentTo or {} do
                    otherMarker = MarkerGrid[node[1]][node[2]]
                    if otherMarker then
                        if markerInfo.graph == 'DefaultLand' and otherMarker.graph == 'DefaultLand' then
                            Color = Offsets['DefaultLand']['color']
                        elseif markerInfo.graph == 'DefaultWater' and otherMarker.graph == 'DefaultWater' then
                            Color = Offsets['DefaultWater']['color']
                        elseif markerInfo.graph == 'DefaultAmphibious' or otherMarker.graph == 'DefaultAmphibious' then
                            Color = Offsets['DefaultAmphibious']['color']
                        elseif markerInfo.graph == 'DefaultLand' and otherMarker.graph == 'DefaultWater' then
                            Color = Offsets['DefaultAmphibious']['color']
                        elseif markerInfo.graph == 'DefaultWater' and otherMarker.graph == 'DefaultLand' then
                            Color = Offsets['DefaultAmphibious']['color']
                        else
                            Color = 'ff000000'
                        end
                        
                        DrawLinePop({markerInfo.position[1], markerInfo.position[2]+0.1, markerInfo.position[3]}, {otherMarker.position[1], otherMarker.position[2]+0.1, otherMarker.position[3]}, Color )
                    end
                end
            end
        end
        coroutine.yield(2)
    end
end

function CreateMarkerGrid(pathCheck)
    AIDebug("* AI-Uveso: Function CreateMarkerGrid() started.", true)
    local posX
    local posZ
    MarkerGrid = {}
    for x = 0, MarkerGridCountX - 1 do
        MarkerGrid[x] = {}
        for z = 0, MarkerGridCountZ - 1 do
            if pathCheck then
                posX, posZ = getFreeMarkerPosition(x, z)
            else
                posX = x * MarkerGridSizeX + MarkerGridSizeX / 2 + playableArea[1]
                posZ = z * MarkerGridSizeZ + MarkerGridSizeZ / 2 + playableArea[2]
            end
            if posX and posZ then
                MarkerGrid[x][z] =
                    {
                        ['position'] = VECTOR3( posX, GetSurfaceHeight(posX,posZ), posZ ),
                        ['graph'] = 'Default',
                    }
            end
        end
    end
    return
end

function ConnectMarkerWithoutPathing()
    for x = 0, MarkerGridCountX - 1 do
        for z = 0, MarkerGridCountZ - 1 do
            MarkerGrid[x][z].adjacentTo = {}
            -- connecting marker x,z with adjacents
            --AIDebug("* AI-Uveso: Function ConnectMarkerWithoutPathing() connecting marker ("..x..", "..z..") with adjacents.", true)
            for xA = -1, 1, 1 do
                if  x + xA >= 0 and x + xA <= MarkerGridCountX - 1 then
                    for zA = -1, 1, 1 do
                        if z + zA >= 0 and z + zA <= MarkerGridCountZ - 1 then
                            -- don't connect to self
                            if x ~= x + xA or z ~= z + zA then
                                --AIDebug("* AI-Uveso: Function ConnectMarkerWithoutPathing() adjacent index ok: ["..x + xA.."]["..z + zA.."].", true)
                                table.insert(MarkerGrid[x][z].adjacentTo,{x + xA,z + zA})
                            end
                        end
                    end
                end
            end
        end
    end
end

function GetMarkerTable()
    return MarkerGrid
end

function ConnectMarkerWithPathing()
    for x = 0, MarkerGridCountX - 1 do
        for z = 0, MarkerGridCountZ - 1 do
            if MarkerGrid[x][z] then
                MarkerGrid[x][z].adjacentTo = {}
                -- connecting marker x,z with adjacents
                --AIDebug("* AI-Uveso: Function ConnectMarkerWithoutPathing() connecting marker ("..x..", "..z..") with adjacents.", true)
-- this is to draw the pathing on a specific marker
--if x == 12 and z == 10 then
--while true do
--coroutine.yield(2)
                for xA = -1, 1, 1 do
                    if  x + xA >= 0 and x + xA <= MarkerGridCountX - 1 then
                        for zA = -1, 1, 1 do
                            if z + zA >= 0 and z + zA <= MarkerGridCountZ - 1 then
                                -- don't connect to self
                                if x ~= x + xA or z ~= z + zA then
                                    if MarkerGrid[x + xA][z + zA] then
                                        --AIDebug("* AI-Uveso: Function ConnectMarkerWithoutPathing() adjacent index ok: ["..x + xA.."]["..z + zA.."].", true)
                                        if CanMoveBetweenPosition(x, z, x + xA, z + zA) then
                                            table.insert(MarkerGrid[x][z].adjacentTo,{x + xA,z + zA})
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
--end
--end
        end
    end
end

function CanMoveBetweenPosition(x, z, xA, zA)
    --AIWarn("* AI-Uveso: Function CanMoveBetweenPosition() from grid ["..x.."]["..z.."] to adjacent ["..xA.."]["..zA.."].", true)
    local pos = MarkerGrid[x][z].position
    local posA = MarkerGrid[xA][zA].position

    --AIWarn("* AI-Uveso: Function CanMoveBetweenPosition() from pos1("..pos[1]..", "..pos[3]..") to posA("..posA[1]..", "..posA[3]..").", true)
    local distance = VDist2(pos[1], pos[3], posA[1], posA[3])
    local steps = math.floor(distance)
    local xstep = (posA[1] - pos[1]) / steps
    local ystep = (posA[3] - pos[3]) / steps


    -- orientation offsets
    local alpha = math.atan2(pos[3] - posA[3] ,pos[1] - posA[1]) * ( 180 / math.pi )
    --AIWarn("alpha "..alpha)
    --   45  90  135
    --    0  ##  180
    --  -45 -90 -135 
    if math.abs(alpha) <= 22.5 or math.abs(alpha) >= 157.5 then
        --AIWarn("- L R")
        xH = 0
        zH = 1
        -- L R
    elseif math.abs(alpha) >= 67.5 and math.abs(alpha) <= 112.5 then
        --AIWarn("| U D")
        xH = 1
        zH = 0
        -- U D
    elseif alpha >= 22.5 and alpha <= 67.5 or alpha <= -112.5 and alpha >= -157.5 then
        --AIWarn("\\ LU RD")
        xH = -0.8
        zH = 0.8
        -- LU RD
    else
        --AIWarn("/ LD RU")
        xH = -0.8
        zH = -0.8
        -- LD RU
    end

    for o = -3, 3, 1.5 do
        local blocked = 0
        for i = 0, steps do
            if blocked > 0 or PathMap[math.floor(o*xH + pos[1] + (xstep * i))][math.floor(o*zH + pos[3] + (ystep * i))].blocked then
                --AIWarn("blocked", true)
                --DrawLine( {pos[1] + o*xH, pos[2] + 0.1, pos[3] + o*zH}, { math.floor(o*xH + pos[1] + (xstep * i)), pos[2] + 0.1, math.floor(o*zH + pos[3] + (ystep * i))}, 'ffFF0000' )
                blocked = blocked + 1
            else
                --DrawLine( {pos[1] + o*xH, pos[2] + 0.1, pos[3] + o*zH}, { math.floor(o*xH + pos[1] + (xstep * i)), pos[2] + 0.1, math.floor(o*zH + pos[3] + (ystep * i))}, 'ff0000FF' )
                --AIWarn("free", true)
            end
        end
        if blocked <= 3  then
            --AIWarn(" "..math.floor(o*xH).." "..math.floor(o*zH).." PATH FOUND")
            return true
        end
        --AIWarn(" "..math.floor(o*xH).." "..math.floor(o*zH).." BLOCKED")
    end
    return false
end

function getFreeMarkerPosition(x, z)
    local debugPrint = false
--    if (x == 5 or x == 5) and (z == 5 or z == 6) then
--        debugPrint = true
--    end
    local zcStart = math.floor(z * MarkerGridSizeZ + playableArea[2])
    local zcEnd = math.floor(z * MarkerGridSizeZ + MarkerGridSizeZ + playableArea[2])
    local xcStart =  math.floor(x * MarkerGridSizeX + playableArea[1])
    local xcEnd = math.floor(x * MarkerGridSizeX + MarkerGridSizeX + playableArea[1])
    -- first check if we have a water or land grid
    local landCount, waterCount = 0, 0
    for zc = zcStart, zcEnd do
        for xc = xcStart, xcEnd do
            if PathMap[xc][zc].layer == "Land" then
                landCount = landCount + 1
            else
                waterCount = waterCount + 1
            end
        end
    end
    AIWarn("landCount: "..landCount.." - waterCount: "..waterCount.." ", debugPrint)
    landRatio = 100 / (landCount + waterCount) * landCount
    AIWarn("landRatio: "..landRatio.." ", debugPrint)
    
    
    local area = 0
    local blocked, AreaNeedReplace
    for zc = zcStart, zcEnd do
AIWarn("* AI-Uveso:  "..zc.."#####################################################", debugPrint)
        if not blocked then
            blocked = true
            area = area + 1
        end
        for xc = xcStart, xcEnd do
            if PathMap[xc][zc].blocked or (landRatio > -1 and PathMap[xc][zc].layer ~= "Land") then
                PathMap[xc][zc].graphArea = 0
                if not blocked then
                    blocked = true
                    area = area + 1
                end
AIWarn("* AI-Uveso:  "..zc.." "..xc.." "..area.." blocked", debugPrint)
            else
                if zc - 1 >= zcStart and PathMap[xc][zc-1].graphArea and PathMap[xc][zc-1].graphArea > 0 then
AIWarn("* AI-Uveso:  "..zc.." "..xc.." "..area.." UP", debugPrint)
                    if xc - 1 >= xcStart and PathMap[xc-1][zc].graphArea and PathMap[xc-1][zc].graphArea > 0 then
                        AreaNeedReplace = PathMap[xc][zc-1].graphArea
                        PathMap[xc][zc].graphArea = PathMap[xc-1][zc].graphArea
                    else
                        PathMap[xc][zc].graphArea = PathMap[xc][zc-1].graphArea
                        AreaNeedReplace = area
                    end
AIWarn("* AI-Uveso:  "..zc.." "..xc.." "..area.." change "..AreaNeedReplace.." to "..PathMap[xc][zc].graphArea, debugPrint)


                    for zm = zcStart, zcEnd do
                        for xm = xcStart, xcEnd do
                            if PathMap[xm][zm].graphArea == AreaNeedReplace then
                                PathMap[xm][zm].graphArea = PathMap[xc][zc].graphArea
                            end
                        end
                    end
                elseif xc - 1 >= xcStart and PathMap[xc-1][zc].graphArea and PathMap[xc-1][zc].graphArea > 0 then
AIWarn("* AI-Uveso:  "..zc.." "..xc.." "..area.." LEFT", debugPrint)
                    PathMap[xc][zc].graphArea = PathMap[xc-1][zc].graphArea
                else
                    if blocked then
                        blocked = false
                    else
                        area = area + 1
                    end
                    PathMap[xc][zc].graphArea = area
AIWarn("* AI-Uveso:  "..zc.." "..xc.." "..area.." NEW", debugPrint)
                end
            end
        end
    end

    -- count graph fileds to find the biggest graph area inside the grid
    local text
    local count = {}
    local countMax, countMaxGraph = 0, nil
    for zc = zcStart, zcEnd do
        text = ""
        for xc = xcStart, xcEnd do
            if PathMap[xc][zc].graphArea ~= 0 then
                if count[PathMap[xc][zc].graphArea] then
                    count[PathMap[xc][zc].graphArea] = count[PathMap[xc][zc].graphArea] + 1
                else
                    count[PathMap[xc][zc].graphArea] = 1
                end
                if count[PathMap[xc][zc].graphArea] > countMax then
                    countMax = count[PathMap[xc][zc].graphArea]
                    countMaxGraph = PathMap[xc][zc].graphArea
                end
            end
            text = text.." "..PathMap[xc][zc].graphArea or "x"
        end
        AIWarn(text, debugPrint)
    end
    -- if we don't have at least 1 graph, then return false
    if not countMaxGraph then
        return false, false
    end

    AIWarn("Grid Areas: "..repr(count), debugPrint)
    AIWarn("Biggest area ID: "..countMaxGraph.." with "..countMax.." positions", debugPrint)

    AIWarn("Search grid "..xcStart.." "..xcEnd.." "..zcStart.." "..zcEnd.." ", debugPrint)

    -- search for all possible free places inside the grid
    local markerSize = 5
    local blockedTolerance = 2
    local blocked
    local possiblePositions = {}
    for zc = zcStart - 3, zcEnd - markerSize + 3 do
        for xc = xcStart - 3, xcEnd - markerSize + 3 do
            blocked = 0
            for zm = zc, zc + markerSize - 1 do
                text = ""
                for xm = xc, xc + markerSize - 1 do
                    if PathMap[xm][zm].graphArea ~= countMaxGraph then
                        blocked = blocked + 1
                    end
                    if not PathMap[xm][zm].graphArea then
                        text = text.."x"
                    else
                    text = text..PathMap[xm][zm].graphArea
                    end
                end
            end
            -- is the square a valid place ?
            if blocked <= blockedTolerance then
--AIWarn("place valid; "..(xc + markerSize / 2).." "..(zc + markerSize / 2).." ", debugPrint)
                table.insert(possiblePositions, {math.floor(xc + markerSize / 2), math.floor (zc + markerSize / 2) })
            end
        end
    end
    if not possiblePositions[1] then
        return false, false
    end
 
    -- search for the center position of MaxGraph
    local centerX, centerZ, centerCount = 0, 0, 0
    for zc = zcStart, zcEnd do
        for xc = xcStart, xcEnd do
            if PathMap[xc][zc].graphArea == countMaxGraph then
                centerX = centerX + xc
                centerZ = centerZ + zc
                centerCount = centerCount + 1
            end
        end
    end
    centerX = math.floor(centerX / centerCount)
    centerZ = math.floor(centerZ / centerCount)


    AIWarn(centerX, debugPrint)
    AIWarn(centerZ, debugPrint)

    -- now search for the closest free place to the center position
    local dist, closestDist, closestPos
    for index, freePostions in possiblePositions do
        dist = math.abs(freePostions[1] - centerX) + math.abs(freePostions[2] - centerZ)
--AIWarn("dist "..dist, debugPrint)
        if not closestDist or closestDist > dist then
--AIWarn("found closest free place! ", debugPrint)
            closestDist = dist
            closestPos = freePostions
        end
    end
    AIWarn("Closest free place: "..repr(closestPos), debugPrint)
    if closestPos then
        return closestPos[1], closestPos[2]
    end
    

    -- return the center position of the grid
--    x = math.floor(x * MarkerGridSizeX + MarkerGridSizeX / 2 + playableArea[1])
--    z = math.floor(z * MarkerGridSizeZ + MarkerGridSizeZ / 2 + playableArea[2])
    x = false
    z = false
    return x, z
 
end
