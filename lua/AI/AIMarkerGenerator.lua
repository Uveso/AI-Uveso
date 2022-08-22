local PathMap = {}

function BuildTerrainPathMap()
    -- disabled for release.
    if 1 == 1 then
        return
    end
    
    local playableArea = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetPlayableArea()
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
    ForkThread(PathableTerrainRenderThread)
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

function PathableTerrainRenderThread()
    local playableArea = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetPlayableArea()
    while true do
        coroutine.yield(2)
        for x = playableArea[1], playableArea[3], 1 do
            for z = playableArea[2], playableArea[4], 1 do
                if PathMap[x][z].blocked then
                    if PathMap[x][z].layer == "Land" then
                        DrawCircle({x + 0.50, GetTerrainHeight(x, z) , z + 0.50}, 0.5, 'ffFF9440')
                    elseif PathMap[x][z].layer == "Hover" then
                        DrawCircle({x + 0.50, GetTerrainHeight(x, z) , z + 0.50}, 0.5, 'ffFF90ff')
                    elseif PathMap[x][z].layer == "Amphibious" then
                        DrawCircle({x + 0.50, GetTerrainHeight(x, z) , z + 0.50}, 0.5, 'ffFf80ef')
                    elseif PathMap[x][z].layer == "Naval" then
                        DrawCircle({x + 0.50, GetTerrainHeight(x, z) , z + 0.50}, 0.5, 'ffFF408b')
                    end
                else
                    if PathMap[x][z].layer == "Land" then
                        --DrawCircle({x + 0.50, GetTerrainHeight(x, z) , z + 0.50}, 0.5, 'fff4a460')
                    elseif PathMap[x][z].layer == "Hover" then
                        --DrawCircle({x + 0.50, GetTerrainHeight(x, z) , z + 0.50}, 0.5, 'ff1e90ff')
                    elseif PathMap[x][z].layer == "Amphibious" then
                        --DrawCircle({x + 0.50, GetTerrainHeight(x, z) , z + 0.50}, 0.5, 'ff0e80ef')
                    elseif PathMap[x][z].layer == "Naval" then
                        --DrawCircle({x + 0.50, GetTerrainHeight(x, z) , z + 0.50}, 0.5, 'ff27408b')
                    end
                end
            end
        end
    end
end

