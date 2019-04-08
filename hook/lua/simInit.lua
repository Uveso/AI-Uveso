WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] * Uveso-AI: offset simInit.lua' )

-- hooks for map validation on game start and debugstuff for pathfinding and base ranger.
local CREATEAIMARKERS = true
local MaxPassableElevation = 62
local CREATEDMARKERS = {}
local MarkerCountX = 30
local MarkerCountY = 30

--local DebugMarker = 'Marker0-9' -- TKP Lakes
--local DebugMarker = 'Marker1-0' -- Twin Rivers
local DebugMarker = 'Marker00-00'
local DebugValidMarkerPosition = false

local OldSetupSessionFunction = SetupSession
function SetupSession()
    OldSetupSessionFunction()
    ValidateMapAndMarkers()
end

local OldBeginSessionFunction = BeginSession
function BeginSession()
    OldBeginSessionFunction()
    if ScenarioInfo.Options.AIPathingDebug ~= 'off' then
        LOG('ForkThread(GraphRender)')
        ForkThread(GraphRender)
    end
    if CREATEAIMARKERS then
        LOG('ForkThread(RenderMarkerCreator)')
        ForkThread(RenderMarkerCreator)
    end
    if CREATEAIMARKERS then
        LOG('ForkThread(CreateAIMarkers)')
        ForkThread(CreateAIMarkers)
    end
end

local OldOnCreateArmyBrainFunction = OnCreateArmyBrain
function OnCreateArmyBrain(index, brain, name, nickname)
    OldOnCreateArmyBrainFunction(index, brain, name, nickname)
    -- check if we have an Ai brain that is not a civilian army
    if brain.BrainType == 'AI' and nickname ~= 'civilian' then
        -- check if we need to set a new unitcap for the AI. (0 = we are using the player unit cap)
        if tonumber(ScenarioInfo.Options.AIUnitCap) > 0 then
            LOG('* Uveso-AI: OnCreateArmyBrain: Setting AI unit cap to '..ScenarioInfo.Options.AIUnitCap..' ('..nickname..')')
            SetArmyUnitCap(index,tonumber(ScenarioInfo.Options.AIUnitCap))
        end
    end
end

local KnownMarkerTypes = {
    ['Air Path Node']=true,
    ['Amphibious Path Node']=true,
    ['Blank Marker']=true,
    ['Camera Info']=true,
    ['Combat Zone']=true,
    ['Defensive Point']=true,
    ['Effect']=true,
    ['Expansion Area']=true,
    ['Hydrocarbon']=true,
    ['Island']=true,
    ['Land Path Node']=true,
    ['Large Expansion Area']=true,
    ['Mass']=true,
    ['Naval Area']=true,
    ['Naval Defensive Point']=true,
    ['Naval Exclude']=true,
    ['Naval Link']=true,
    ['Naval Rally Point']=true,
    ['Protected Experimental Construction']=true,
    ['Rally Point']=true,
    ['Transport Marker']=true,
    ['Water Path Node']=true,
    ['Weather Definition']=true,
    ['Weather Generator']=true,
 }
local BaseLocations = {
    ['Blank Marker']         = { ['priority'] = 4 },
    ['Naval Area']           = { ['priority'] = 3 },
    ['Large Expansion Area'] = { ['priority'] = 2 },
    ['Expansion Area']       = { ['priority'] = 1 },
}
local Offsets = {
    ['DefaultLand']       = { [1] =  0.0, [2] =  0.0, [3] =  0.0, ['color'] = 'ffF4A460', },
    ['DefaultWater']      = { [1] = -0.5, [2] =  0.0, [3] = -0.5, ['color'] = 'ff000080', },
    ['DefaultAmphibious'] = { [1] = -1.0, [2] =  0.0, [3] = -1.0, ['color'] = 'ff00BFFF', },
    ['DefaultAir']        = { [1] = -1.5, [2] =  0.0, [3] = -1.5, ['color'] = 'ffEFEFFF', },
}

local MarkerDefaults = {
    ['Land Path Node']          = { ['graph'] ='DefaultLand',       ['color'] = 'ff808080', },
    ['Water Path Node']         = { ['graph'] ='DefaultWater',      ['color'] = 'ff0000ff', },
    ['Amphibious Path Node']    = { ['graph'] ='DefaultAmphibious', ['color'] = 'ff404060', },
    ['Air Path Node']           = { ['graph'] ='DefaultAir',        ['color'] = 'ffffffff', },
}
local colors = {
    ['counter'] = 0,
    ['countermax'] = 0,
    ['lastcolorindex'] = 1,
    [1] = 'ff000000',
    [2] = 'ff202000',
    [3] = 'ff404000',
    [4] = 'ff606000',
    [5] = 'ff808000',
    [6] = 'ffA0A000',
    [7] = 'ffC0C000',
    [8] = 'ffE0E000',

    [9] = 'ffFFFF00',
    [10] = 'ffFFFF00',
    [11] = 'ffFFFF00',

    [12] = 'ffE0E000',
    [13] = 'ffC0C000',
    [14] = 'ffA0A000',
    [15] = 'ff808000',
    [16] = 'ff606000',
    [17] = 'ff404000',
    [18] = 'ff202000',
    [19] = 'ff000000',
}
function ValidateMapAndMarkers()
    -- Check norushradius
    if ScenarioInfo.norushradius and ScenarioInfo.norushradius > 0 then
        if ScenarioInfo.norushradius < 10 then
            WARN('* Uveso-AI: ValidateMapAndMarkers: norushradius is too smal ('..ScenarioInfo.norushradius..')! Set radius to minimum (15).')
            ScenarioInfo.norushradius = 15
        else
            LOG('* Uveso-AI: ValidateMapAndMarkers: norushradius is OK. ('..ScenarioInfo.norushradius..')')
        end
    else
        WARN('* Uveso-AI: ValidateMapAndMarkers: norushradius is missing! Set radius to default (20).')
        ScenarioInfo.norushradius = 20
    end

    -- Check map markers
    local TEMP = {}
    local UNKNOWNMARKER
    local dist
    for k, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
        -- Check if the marker is known. If not, send a debug message
        if not KnownMarkerTypes[v.type] then
            if not UNKNOWNMARKER[v.type] then
                LOG('* Uveso-AI: ValidateMapAndMarkers: Unknown MarkerType: [\''..v.type..'\']=true,')
                UNKNOWNMARKER[v.type] = true
            end
        end
        -- Check Mass Marker
        if v.type == 'Mass' then
            if v.position[1] <= 8 or v.position[1] >= ScenarioInfo.size[1] - 8 or v.position[3] <= 8 or v.position[3] >= ScenarioInfo.size[2] - 8 then
                WARN('* Uveso-AI: ValidateMapAndMarkers: MarkerType: [\''..v.type..'\'] is too close to map border. IndexName = ['..k..']. (Mass marker deleted!!!)')
                Scenario.MasterChain._MASTERCHAIN_.Markers[k] = nil
            end
        end
        -- Check Waypoint Marker
        if MarkerDefaults[v.type] then
            if v.adjacentTo then
                local adjancents = STR_GetTokens(v.adjacentTo or '', ' ')
                if adjancents[0] then
                    for i, node in adjancents do
                        --local otherMarker = Scenario.MasterChain._MASTERCHAIN_.Markers[node]
                        if not Scenario.MasterChain._MASTERCHAIN_.Markers[node] then
                            WARN('* Uveso-AI: ValidateMapAndMarkers: adjacentTo is wrong in marker ['..k..'] - MarkerType: [\''..v.type..'\']. - Adjacent marker ['..node..'] is missing.')
                        end
                    end
                else
                    --WARN('* Uveso-AI: ValidateMapAndMarkers: adjacentTo is empty in marker ['..k..'] - MarkerType: [\''..v.type..'\']. - Pathmarker must have an adjacent marker for pathing.')
                end
            else
                --WARN('* Uveso-AI: ValidateMapAndMarkers: adjacentTo is missing in marker ['..k..'] - MarkerType: [\''..v.type..'\']. - Pathmarker must have an adjacent marker for pathing.')
            end
            -- Checking marker type/graph 
            if MarkerDefaults[v.type]['graph'] ~= v.graph then
                WARN('* Uveso-AI: ValidateMapAndMarkers: graph missmatch in marker ['..k..'] - MarkerType: [\''..v.type..'\']. - marker.type is ('..repr(v.graph)..'), but should be ('..MarkerDefaults[v.type]['graph']..').')
                -- save the correct graph type 
                v.graph = MarkerDefaults[v.type]['graph']
            end
            -- Checking colors (for debug)
            if MarkerDefaults[v.type]['color'] ~= v.color then
                -- we actual don't print a debugmessage here. This message is for debuging a debug function :)
                --LOG('* Uveso-AI: ValidateMapAndMarkers: color missmatch in marker ['..k..'] - MarkerType: [\''..v.type..'\']. marker.color is ('..repr(v.color)..'), but should be ('..MarkerDefaults[v.type]['color']..').')
                v.color = MarkerDefaults[v.type]['color']
            end
        -- Check BaseLocations distances to other locations
        elseif BaseLocations[v.type] then
            for k2, v2 in Scenario.MasterChain._MASTERCHAIN_.Markers do
                if BaseLocations[v2.type] and v ~= v2 then
                    local dist = VDist2( v.position[1], v.position[3], v2.position[1], v2.position[3] )
                    -- Are we checking a Start location, and another marker is nearer then 80 units ?
                    if v.type == 'Blank Marker' and v2.type ~= 'Blank Marker' and dist < 80 then
                        LOG('* Uveso-AI: ValidateMapAndMarkers: Marker [\''..k2..'\'] is to close to Start Location [\''..k..'\']. Distance= '..math.floor(dist)..' (under 80).')
                        --Scenario.MasterChain._MASTERCHAIN_.Markers[k2] = nil
                    -- Check if we have other locations that have a low distance (under 60)
                    elseif v.type ~= 'Blank Marker' and v2.type ~= 'Blank Marker' and dist < 60 then
                        -- Check priority from small locations up to main base.
                        if BaseLocations[v.type].priority >= BaseLocations[v2.type].priority then
                            LOG('* Uveso-AI: ValidateMapAndMarkers: Marker [\''..k2..'\'] is to close to Marker [\''..k..'\']. Distance= '..math.floor(dist)..' (under 60).')
                            -- Not used at the moment, but we can delete the location with the lower priority here.
                            -- This is used for debuging the locationmanager, so we can be sure that locations are not overlapping.
                            --Scenario.MasterChain._MASTERCHAIN_.Markers[k2] = nil
                        end
                    end
                end
            end
        end
    end
end

function GraphRender()
    -- wait 10 seconds at gamestart before we start debuging
    WaitTicks(100)
    while true do
        -- draw all paths with location radius and AI Pathfinding
        if ScenarioInfo.Options.AIPathingDebug == 'all' or ScenarioInfo.Options.AIPathingDebug == 'path' then
            -- display first all land nodes (true will let them blink)
            if GetGameTimeSeconds() < 15 then
                DrawPathGraph('DefaultLand', false)
                DrawPathGraph('DefaultAmphibious', false)
                DrawPathGraph('DefaultWater', false)
                --DrawPathGraph('DefaultAir', false)
            elseif GetGameTimeSeconds() < 20 then
                --DrawPathGraph('DefaultAmphibious', false)
                --DrawPathGraph('DefaultWater', false)
                --DrawPathGraph('DefaultAir', false)
                DrawPathGraph('DefaultLand', true)
            -- display amphibious nodes
            elseif GetGameTimeSeconds() < 25 then
                --DrawPathGraph('DefaultLand', false)
                --DrawPathGraph('DefaultWater', false)
                --DrawPathGraph('DefaultAir', false)
                DrawPathGraph('DefaultAmphibious', true)
            -- water nodes
            elseif GetGameTimeSeconds() < 30 then
                --DrawPathGraph('DefaultLand', false)
                --DrawPathGraph('DefaultAmphibious', false)
                --DrawPathGraph('DefaultAir', false)
                DrawPathGraph('DefaultWater', true)
            -- air nodes
            elseif GetGameTimeSeconds() < 35 then
                --DrawPathGraph('DefaultLand', false)
                --DrawPathGraph('DefaultAmphibious', false)
                --DrawPathGraph('DefaultWater', false)
                DrawPathGraph('DefaultAir', true)
            elseif GetGameTimeSeconds() < 40 then
                DrawPathGraph('DefaultLand', false)
                DrawPathGraph('DefaultAmphibious', false)
                DrawPathGraph('DefaultWater', false)
                --DrawPathGraph('DefaultAir', false)
            end
            -- Draw the radius of each base(manager)
            if ScenarioInfo.Options.AIPathingDebug == 'all' then
                DrawBaseRanger()
            end
            DrawAIPatchCache()
        -- Display land path permanent
        elseif ScenarioInfo.Options.AIPathingDebug == 'land' then
            DrawPathGraph('DefaultLand', false)
            DrawAIPatchCache('DefaultLand')
        -- Display water path permanent
        elseif ScenarioInfo.Options.AIPathingDebug == 'water' then
            DrawPathGraph('DefaultWater', false)
            DrawAIPatchCache('DefaultWater')
        -- Display amph path permanent
        elseif ScenarioInfo.Options.AIPathingDebug == 'amph' then
            DrawPathGraph('DefaultAmphibious', false)
            DrawAIPatchCache('DefaultAmphibious')
        -- Display air path permanent
        elseif ScenarioInfo.Options.AIPathingDebug == 'air' then
            DrawPathGraph('DefaultAir', false)
            DrawAIPatchCache('DefaultAir')
        end
        WaitTicks(2)
    end
end

function DrawBaseRanger()
    -- get the range of combat zones
    local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua').GetDangerZoneRadii()
    -- Render the radius of any base and expansion location
    if Scenario.MasterChain._MASTERCHAIN_.BaseRanger then
        for Index, ArmyRanger in Scenario.MasterChain._MASTERCHAIN_.BaseRanger do
            for nodename, markerInfo in ArmyRanger do
                if nodename == 'MAIN' then
                    DrawCircle(markerInfo.Pos, BasePanicZone, 'ffFF0000')
                    DrawCircle(markerInfo.Pos, BaseMilitaryZone, 'ffFF0000')
                end
                -- Draw the inner circle black
                DrawCircle(markerInfo.Pos, markerInfo.Rad-0.5, 'ff000000')
                -- Draw the main circle white
                DrawCircle(markerInfo.Pos, markerInfo.Rad, 'ffFFE0E0')
            end
        end
    end
end

function DrawPathGraph(DrawOnly,Blink)
    local color
    if Blink then
        colors['counter'] = colors['counter'] + 1
        if colors['counter'] > colors['countermax'] then
            colors['counter'] = 0
            --LOG('lastcolorindex:'..colors['lastcolorindex']..' - table.getn(colors)'..table.getn(colors))
            if colors['lastcolorindex'] >= (table.getn(colors)) then
                colors['lastcolorindex'] = 1
            else
                colors['lastcolorindex'] = colors['lastcolorindex'] + 1
            end
        end
        color = colors[colors['lastcolorindex']]
    else
        color = Offsets[DrawOnly]['color']
    end
    local AIAttackUtils = import('/lua/ai/aiattackutilities.lua')
    local MarkerPosition = {0,0,0}
    local Marker2Position = {0,0,0}
    -- Render the connection between the path nodes for the specific graph
    for Layer, LayerMarkers in AIAttackUtils.GetPathGraphs() do
        for graph, GraphMarkers in LayerMarkers do
            for nodename, markerInfo in GraphMarkers do
                if DrawOnly and DrawOnly ~= markerInfo.graphName then
                    continue
                end
                MarkerPosition[1] = markerInfo.position[1] + (Offsets[markerInfo.graphName][1])
                MarkerPosition[2] = markerInfo.position[2] + (Offsets[markerInfo.graphName][2])
                MarkerPosition[3] = markerInfo.position[3] + (Offsets[markerInfo.graphName][3])
                -- Draw the marker path node
                DrawCircle(MarkerPosition, 5, Offsets[markerInfo.graphName]['color'] or colors[colors['lastcolorindex']] )
                -- Draw the connecting lines to its adjacent nodes
                for i, node in markerInfo.adjacent do
                    local otherMarker = Scenario.MasterChain._MASTERCHAIN_.Markers[node]
                    if otherMarker then
                        Marker2Position[1] = otherMarker.position[1] + Offsets[otherMarker.graph][1]
                        Marker2Position[2] = otherMarker.position[2] + Offsets[otherMarker.graph][2]
                        Marker2Position[3] = otherMarker.position[3] + Offsets[otherMarker.graph][3]
                        --DrawLinePop(MarkerPosition, Marker2Position, GraphOffsets[otherMarker.graph]['color'])
                        DrawLinePop(MarkerPosition, Marker2Position, color )
                    end
                end
            end
        end
    end
end

function DrawAIPatchCache(DrawOnly)
    -- loop over all players in the game
    for ArmyIndex, aiBrain in ArmyBrains do
        -- is the player an AI-Uveso ?
        if aiBrain.Uveso and aiBrain.PathCache then
            local LineCountOffset = 0
            local Pos1 = {}
            local Pos2 = {}
            -- Loop over all paths that starts from "StartNode"
            for StartNode, EndNodeCache in aiBrain.PathCache do
                LineCountOffset = 0
                -- Loop over all paths starting from StartNode and ending in EndNode
                for EndNode, Path in EndNodeCache do
                    -- Loop over all threatWeighted paths
                    for threatWeight, PathNodes in Path do
                        -- Display only valid paths
                        if PathNodes.path ~= 'bad' then
                            local LastNode = false
                            if not PathNodes.path.path then
                                continue
                            end
                            -- loop over all path waypoints and draw lines.
                            for NodeIndex, PathNode in PathNodes.path.path do
                                -- continue if we don't want to draw this graph node
                                if DrawOnly and DrawOnly ~= PathNode.graphName then
                                    continue
                                end
                                if LastNode then
                                    -- If we draw a horizontal line, then draw the next line "under" the last line
                                    if math.abs(LastNode.position[1] - PathNode.position[1]) > math.abs(LastNode.position[3] - PathNode.position[3]) then
                                        DirectionOffsetX = 0
                                        DirectionOffsetY = 0.2
                                    -- else we are drawing vertical, then draw the next line "Right" near the last line
                                    else
                                        DirectionOffsetX = 0.2
                                        DirectionOffsetY = 0
                                    end
                                    DrawLinePop({LastNode.position[1] + LineCountOffset + DirectionOffsetX,     LastNode.position[2], LastNode.position[3] + LineCountOffset + DirectionOffsetY},     {PathNode.position[1] + LineCountOffset + DirectionOffsetX,     PathNode.position[2],PathNode.position[3] + LineCountOffset + DirectionOffsetY},     'ff000000' )                   

                                    DrawLinePop({LastNode.position[1] + LineCountOffset,                        LastNode.position[2], LastNode.position[3] + LineCountOffset},                        {PathNode.position[1] + LineCountOffset,                        PathNode.position[2],PathNode.position[3] + LineCountOffset},                        Offsets[PathNode.graphName]['color'] )                   
                                    DrawLinePop({LastNode.position[1] + LineCountOffset + DirectionOffsetX * 2, LastNode.position[2], LastNode.position[3] + LineCountOffset + DirectionOffsetY * 2}, {PathNode.position[1] + LineCountOffset + DirectionOffsetX * 2, PathNode.position[2],PathNode.position[3] + LineCountOffset + DirectionOffsetY * 2}, Offsets[PathNode.graphName]['color'] )                             

                                end
                                LastNode = PathNode
                            end
                            LineCountOffset = LineCountOffset + 0.3
                        end
                    end
                end
            end
        end
    end
end


function RenderMarkerCreator()
    local MarkerPosition = {}
    local Marker2Position = {}
    WaitTicks(10)
    while true do
        for nodename, markerInfo in CREATEDMARKERS or {} do
            MarkerPosition[1] = markerInfo.position[1]
            MarkerPosition[2] = markerInfo.position[2]
            MarkerPosition[3] = markerInfo.position[3]
            -- Draw the marker path node
            DrawCircle(MarkerPosition, 4, Offsets[markerInfo.graph]['color'] or 'ff000000' )
            -- Draw the connecting lines to its adjacent nodes
            if markerInfo.adjacentTo then
                local adjancents = STR_GetTokens(markerInfo.adjacentTo or '', ' ')
                if adjancents[0] then
                    for i, node in adjancents do
                        local otherMarker = CREATEDMARKERS[node]
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
                                continue
                            end
                            Marker2Position[1] = otherMarker.position[1]
                            Marker2Position[2] = otherMarker.position[2]
                            Marker2Position[3] = otherMarker.position[3]
                            DrawLinePop(MarkerPosition, Marker2Position, Color )
                        end
                    end
                end
            end
        end
        WaitTicks(2)
        if GetGameTimeSeconds() > 5 then
            return
        end
    end
end

function CreateAIMarkers()
    if ScenarioInfo.Options.AIMapMarker == 'map' then
        LOG('* Uveso-AI: Using the original marker from the map')
        return
    elseif ScenarioInfo.Options.AIMapMarker == 'off' then
        LOG('* Uveso-AI: No markers, deleting original marker...')
        CREATEDMARKERS = {}
        CopyMarkerToMASTERCHAIN('Land')
        CopyMarkerToMASTERCHAIN('Water')
        CopyMarkerToMASTERCHAIN('Amphibious')
        CopyMarkerToMASTERCHAIN('Air')
        return
    elseif ScenarioInfo.Options.AIMapMarker == 'miss' then
        local count = 0
        for k, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
            if MarkerDefaults[v.type] then
                count = count + 1
            end
        end
        if count > 1 then
            LOG('* Uveso-AI: Map has '..count..' markers, no autogenerating.')
            return
        else
            LOG('* Uveso-AI: Map has no markers; autogenerating!')
        end
    elseif ScenarioInfo.Options.AIMapMarker == 'all' then
        LOG('* Uveso-AI: Generating markers always')
    end
    -- Create Air Marker
    CREATEDMARKERS = {}
    local DistanceBetweenMarkers = ScenarioInfo.size[1] / ( MarkerCountX/2 )
    for Y = 0, MarkerCountY/2 - 1 do
        for X = 0, MarkerCountX/2 - 1 do
            local PosX = X * DistanceBetweenMarkers + DistanceBetweenMarkers / 2
            local PosY = Y * DistanceBetweenMarkers + DistanceBetweenMarkers / 2
            CREATEDMARKERS['Marker'..X..'-'..Y] = {
                ['position'] = VECTOR3( PosX, GetSurfaceHeight(PosX,PosY), PosY ),
                ['graph'] = 'DefaultAir',
            }
        end
    end
    -- connect air markers
    for Y = 0, MarkerCountY/2 - 1 do
        for X = 0, MarkerCountX/2 - 1 do
            ConnectMarker(X,Y)
        end
    end
    -- Copy Markers to the Scenario.MasterChain._MASTERCHAIN
    CopyMarkerToMASTERCHAIN('Air')

    -- create Land/Water/Amphibious marker grid
    CREATEDMARKERS = {}
    local DistanceBetweenMarkers = ScenarioInfo.size[1] / ( MarkerCountX )
    for Y = 0, MarkerCountY - 1 do
        for X = 0, MarkerCountX - 1 do
            local PosX = X * DistanceBetweenMarkers + DistanceBetweenMarkers / 2
            local PosY = Y * DistanceBetweenMarkers + DistanceBetweenMarkers / 2
            CREATEDMARKERS['Marker'..X..'-'..Y] = {
                ['position'] = VECTOR3( PosX, GetSurfaceHeight(PosX,PosY), PosY ),
            }
        end
    end
    -- define marker as land, amp, water
    for Y = 0, MarkerCountY - 1 do
        for X = 0, MarkerCountX - 1 do
            local MarkerIndex = 'Marker'..X..'-'..Y
            local MarkerPosition = CREATEDMARKERS[MarkerIndex].position
            local ReturnGraph = CheckValidMarkerPosition(MarkerIndex)
            if DebugMarker == MarkerIndex then
                ReturnGraph = 'DefaultAir'
            end
            --LOG('Marker '..'Marker '..X..'-'..Y..' TerrainType = '..ReturnGraph)
            CREATEDMARKERS[MarkerIndex].graph = ReturnGraph
        end
    end
    -- connect markers
    for Y = 0, MarkerCountY - 1 do
        for X = 0, MarkerCountX - 1 do
            ConnectMarker(X,Y)
        end
    end
    -- optimize
    
    -- Copy Markers to the Scenario.MasterChain._MASTERCHAIN
    CopyMarkerToMASTERCHAIN('Land')
    CopyMarkerToMASTERCHAIN('Water')
    CopyMarkerToMASTERCHAIN('Amphibious')

    CleanMarkersInMASTERCHAIN('Land')
    CleanMarkersInMASTERCHAIN('Water')
    CleanMarkersInMASTERCHAIN('Amphibious')

    if ScenarioInfo.Options.AIMapMarker == 'print' then
        LOG('map: Printing markers to game.log')
        PrintMASTERCHAIN()
    end

end

function CleanMarkersInMASTERCHAIN(layer)
    for Y = 0, MarkerCountY - 1 do
        for X = 0, MarkerCountX - 1 do
            if Scenario.MasterChain._MASTERCHAIN_.Markers[layer..X..'-'..Y] then
                --LOG('Cleaning marker '..layer..X..'-'..Y)
                -- check if we have 8 adjacentTo. If yes, delete this Marker
                local adjancents = STR_GetTokens(Scenario.MasterChain._MASTERCHAIN_.Markers[layer..X..'-'..Y].adjacentTo or '', ' ')
                if adjancents[7] then
                    --LOG('markers has 8 adjacentTo: '..Scenario.MasterChain._MASTERCHAIN_.Markers[layer..X..'-'..Y].adjacentTo)
                    Scenario.MasterChain._MASTERCHAIN_.Markers[layer..X..'-'..Y] = nil
                    -- delete adjacentTo from near markers
                    for YD = -1, 1 do
                        for XD = -1, 1 do
                            --LOG('XD '..XD..' - YD '..YD..'')
                            if Scenario.MasterChain._MASTERCHAIN_.Markers[layer..(X+XD)..'-'..(Y+YD)] then
                                local adjancentsD = STR_GetTokens(Scenario.MasterChain._MASTERCHAIN_.Markers[layer..(X+XD)..'-'..(Y+YD)].adjacentTo or '', ' ')
                                local NewadjacentTo = nil
                                for i, node in adjancentsD do
                                    if node ~= layer..X..'-'..Y then
                                        --LOG('adding node '..node..' this is never'..layer..X..'-'..Y)
                                        if not NewadjacentTo then
                                            NewadjacentTo = node
                                        else
                                            NewadjacentTo = NewadjacentTo..' '..node
                                        end
                                    end
                                end
                                -- We deleted this marker, so we scan't set it
                                --LOG('Set new adjacent to marker : '..layer..(X+XD)..'-'..(Y+YD) )
                                Scenario.MasterChain._MASTERCHAIN_.Markers[layer..(X+XD)..'-'..(Y+YD)].adjacentTo = NewadjacentTo
                                --LOG('validate: '..repr(Scenario.MasterChain._MASTERCHAIN_.Markers[layer..(X+XD)..'-'..(Y+YD)].adjacentTo))
                            end
                        end
                    end
                end
            end
        end
    end
end

function CopyMarkerToMASTERCHAIN(layer)
    --LOG('Delete original marker from MASTERCHAIN for Layer: '..layer)
    -- Deleting all previous markers from MASTERCHAIN
    for nodename, markerInfo in Scenario.MasterChain._MASTERCHAIN_.Markers or {} do
        if markerInfo['graph'] == 'Default'..layer then
            Scenario.MasterChain._MASTERCHAIN_.Markers[nodename] = nil
            --LOG('Removed from Masterchain: '..nodename)
        end
    end
    -- Copy marker
    --LOG('Copy new marker to MASTERCHAIN for Layer: '..layer)
    for nodename, markerInfo in CREATEDMARKERS do
        -- check if we have the right layer
        if markerInfo['graph'] == 'Default'..layer or layer == 'Amphibious' then
            local NewNodeName = string.gsub(nodename, 'Marker', layer)
            Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName] = table.copy(markerInfo)
            -- Validate adjacentTo
            local NewadjacentTo = nil
            local adjancents = STR_GetTokens(Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].adjacentTo or '', ' ')
            if adjancents[0] then
                for i, node in adjancents do
                    -- Does the node on this layer exist ? 
                    if CREATEDMARKERS[node] and (CREATEDMARKERS[node]['graph'] == 'Default'..layer or layer == 'Amphibious') then
                        if not NewadjacentTo then
                            NewadjacentTo = string.gsub(node, 'Marker', layer)
                        else
                            NewadjacentTo = NewadjacentTo..' '..string.gsub(node, 'Marker', layer)
                        end
                    end
                end
            end
            -- copy the new adjancents to the masterchain marker
            if NewadjacentTo then
                Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].adjacentTo = NewadjacentTo
            else
                Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].adjacentTo = ''
            end
            -- add data for a real marker
            Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].color = MarkerDefaults[layer.." Path Node"]['color']
            Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].hint = true
            Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].orientation = { 0, 0, 0 }
            Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].prop = "/env/common/props/markers/M_Path_prop.bp"
            Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].type = layer.." Path Node"
            Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].graph = 'Default'..layer
        end
    end

end

function CheckValidMarkerPosition(MarkerIndex)
    local MarkerLayer = 'DefaultLand'
    if GetTerrainHeight(CREATEDMARKERS[MarkerIndex].position[1], CREATEDMARKERS[MarkerIndex].position[3]) < GetSurfaceHeight(CREATEDMARKERS[MarkerIndex].position[1], CREATEDMARKERS[MarkerIndex].position[3]) then
        MarkerLayer = 'DefaultWater'
    end
    local NewLine
    local LastSHigh
    local LastTHigh
    local SHigh
    local THigh
    local Elevation
    local FAIL = 0
    local MaxFails = 5
    local MarkerPos = CREATEDMARKERS[MarkerIndex].position
    local ASCIIGFX = ''
    ------------------
    -- Check X Axis --
    ------------------
    FAIL = 0
    for Y = -4, 4, 0.5 do
        NewLine = true
        ASCIIGFX = ''
        for X = -4, 4, 0.5 do
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                DrawLine( {MarkerPos[1] -4, MarkerPos[2], MarkerPos[3] + Y}, {MarkerPos[1] + X, MarkerPos[2], MarkerPos[3] + Y}, 'ffFFE0E0' )
                WaitTicks(1)
            end
            if NewLine then
                NewLine = false
                LastSHigh = GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
                LastTHigh = GetTerrainHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
            end
            -- Elevation between checkpoints
            SHigh = GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
            THigh = GetTerrainHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
            Elevation = math.abs(math.floor(LastSHigh*100 - SHigh*100))
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                if Elevation ~= 0 then
                    --LOG('*CheckValidMarkerPosition MaxPassableElevation : '..Elevation )
                end
            end
            if Elevation > MaxPassableElevation then
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                    --WARN('*CheckValidMarkerPosition MaxPassableElevation Blocked!!! '..Elevation )
                end
                FAIL = FAIL + 1
                ASCIIGFX = ASCIIGFX..'----'
                break
            else
                ASCIIGFX = ASCIIGFX..'....'
            end
            -- check Land / Water passage
            if MarkerLayer ~= 'DefaultAmphibious' then
                if THigh < SHigh then
                    if MarkerLayer ~= 'DefaultWater' then
                        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                            WARN('*CheckValidMarkerPosition Land / Water passage!!!')
                        end
                        MarkerLayer = 'DefaultAmphibious'
                    end
                else
                    if MarkerLayer == 'DefaultWater' then
                        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                            WARN('*CheckValidMarkerPosition Land / Water passage!!!')
                        end
                        MarkerLayer = 'DefaultAmphibious'
                    end
                end
            end
            LastSHigh = SHigh
            LastTHigh = THigh
        end
        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
            LOG(ASCIIGFX)
        end
    end
    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
        WARN('*CheckValidMarkerPosition X Axis ('..FAIL..') Fails')
    end
    if FAIL >= MaxFails then
        return 'Blocked'
    end
    ------------------
    -- Check Y Axis --
    ------------------
    FAIL = 0
    for X = -4, 4, 0.5 do
        NewLine = true
        ASCIIGFX = ''
        for Y = -4, 4, 0.5 do
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                DrawLine( {MarkerPos[1] + X , MarkerPos[2], MarkerPos[3] -4}, {MarkerPos[1] + X, MarkerPos[2], MarkerPos[3] + Y}, 'ffFFE0E0' )
                WaitTicks(1)
            end
            if NewLine then
                NewLine = false
                LastSHigh = GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
                LastTHigh = GetTerrainHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
            end
            -- Elevation between checkpoints
            SHigh = GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
            THigh = GetTerrainHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
            Elevation = math.abs(math.floor(LastSHigh*100 - SHigh*100))
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                if Elevation ~= 0 then
                    --LOG('*CheckValidMarkerPosition MaxPassableElevation : '..Elevation )
                end
            end
            if Elevation > MaxPassableElevation then
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                    --WARN('*CheckValidMarkerPosition MaxPassableElevation Blocked!!! '..Elevation )
                end
                FAIL = FAIL + 1
                ASCIIGFX = ASCIIGFX..'----'
                break
            else
                ASCIIGFX = ASCIIGFX..'....'
            end
            -- check Land / Water passage
            if MarkerLayer ~= 'DefaultAmphibious' then
                if THigh < SHigh then
                    if MarkerLayer ~= 'DefaultWater' then
                        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                            WARN('*CheckValidMarkerPosition Land / Water passage!!!')
                        end
                        MarkerLayer = 'DefaultAmphibious'
                    end
                else
                    if MarkerLayer == 'DefaultWater' then
                        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                            WARN('*CheckValidMarkerPosition Land / Water passage!!!')
                        end
                        MarkerLayer = 'DefaultAmphibious'
                    end
                end
            end
            LastSHigh = SHigh
            LastTHigh = THigh
        end
        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
            LOG(ASCIIGFX)
        end
    end
    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
        WARN('*CheckValidMarkerPosition Y Axis ('..FAIL..') Fails')
    end
    if FAIL >= MaxFails then
        return 'Blocked'
    end
    return MarkerLayer
end

function ConnectMarker(X,Y)
    local MarkerIndex = 'Marker'..X..'-'..Y
    -- First check a path to East Marker
    local MaxFails = 8
    local SHigh
    local LastSHigh
    local NewLine
    local MarkerPos = CREATEDMARKERS[MarkerIndex].position
    local ASCIIGFX = ''
    -----------------------------------------
    -- Search for a connection to E (East) --
    -----------------------------------------
    FAIL = 0
    local LastElevation
    local EastMarkerIndex = 'Marker'..(X+1)..'-'..Y
    for Y = -3, 3, 0.5 do
        NewLine = true
        ASCIIGFX = ''
        if not CREATEDMARKERS[EastMarkerIndex] then continue end
        for X = MarkerPos[1], CREATEDMARKERS[EastMarkerIndex].position[1], 0.5 do
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                DrawLine( {MarkerPos[1], MarkerPos[2], MarkerPos[3] + Y}, { X, MarkerPos[2], MarkerPos[3] + Y}, 'ffFFE0E0' )
                WaitTicks(1)
            end
            if NewLine then
                NewLine = false
                LastSHigh = GetSurfaceHeight( X, MarkerPos[3] + Y )
                LastElevation = false
            end
            -- Elevation between checkpoints
            local Block = false
            SHigh = GetSurfaceHeight( X, MarkerPos[3] + Y )
            Elevation = math.abs(math.floor(LastSHigh*100 - SHigh*100))
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                if Elevation ~= 0 then
                    --LOG('*ConnectMarker MaxPassableElevation : '..Elevation )
                end
            end
            if Elevation > MaxPassableElevation then
                if DebugMarker == MarkerIndex then
                    --WARN('*ConnectMarker MaxPassableElevation Blocked!!! '..Elevation )
                end
                Block = true
            end
            -- Up
            SHigh = GetSurfaceHeight( X - 0.5, MarkerPos[3] + Y - 1)
            Elevation = math.abs(math.floor(LastSHigh*100 - SHigh*100))
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                if Elevation ~= 0 then
                    --LOG('*ConnectMarker MaxPassableElevation U : '..Elevation )
                end
            end
            if Elevation > MaxPassableElevation then
                if DebugMarker == MarkerIndex then
                    --WARN('*ConnectMarker MaxPassableElevation U Blocked!!! '..Elevation )
                end
                Block = true
            end
            -- Down
            SHigh = GetSurfaceHeight( X - 0.5, MarkerPos[3] + Y + 1)
            Elevation = math.abs(math.floor(LastSHigh*100 - SHigh*100))
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                if Elevation ~= 0 then
                    --LOG('*ConnectMarker MaxPassableElevation D : '..Elevation )
                end
            end
            if Elevation > MaxPassableElevation then
                if DebugMarker == MarkerIndex then
                    --WARN('*ConnectMarker MaxPassableElevation D Blocked!!! '..Elevation )
                end
                Block = true
            end


            if Block == true then
                if DebugMarker == MarkerIndex then
                    --WARN('*ConnectMarker MaxPassableElevation Blocked!!! '..Elevation )
                end
                FAIL = FAIL + 1
                ASCIIGFX = ASCIIGFX..'----'
                break
            else
                ASCIIGFX = ASCIIGFX..'....'
            end
            LastSHigh = SHigh
        end
        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
            LOG(ASCIIGFX)
        end
    end
    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
        WARN('*CheckValidMarkerPosition East ('..FAIL..') Fails')
    end
    -- Check if we have failed to find pathable Terrain
    if FAIL < MaxFails or CREATEDMARKERS[MarkerIndex]['graph'] == 'DefaultAir' then
        -- Add the EastMarker to our current Marker as adjacency
        if CREATEDMARKERS[EastMarkerIndex] then
            if not CREATEDMARKERS[MarkerIndex].adjacentTo then
                CREATEDMARKERS[MarkerIndex].adjacentTo = EastMarkerIndex
            else
                CREATEDMARKERS[MarkerIndex].adjacentTo = CREATEDMARKERS[MarkerIndex].adjacentTo..' '..EastMarkerIndex
            end
        end
        -- And add the current marker also to the EastMarker as adjacency
        if CREATEDMARKERS[EastMarkerIndex] then
            if not CREATEDMARKERS[EastMarkerIndex].adjacentTo then
                CREATEDMARKERS[EastMarkerIndex].adjacentTo = MarkerIndex
            else
                CREATEDMARKERS[EastMarkerIndex].adjacentTo = CREATEDMARKERS[EastMarkerIndex].adjacentTo..' '..MarkerIndex
            end
        end
        if DebugMarker == MarkerIndex then
            LOG('*ConnectMarker Terrain Free -> Connecting ('..MarkerIndex..') with ('..EastMarkerIndex..')')
        end
    else
        if DebugMarker == MarkerIndex then
            WARN('*ConnectMarker Terrain Blocked. Cant connect ('..MarkerIndex..') with ('..EastMarkerIndex..')')
        end
    end

    ------------------------------------------
    -- Search for a connection to S (South) --
    ------------------------------------------
    FAIL = 0
    local SouthMarkerIndex = 'Marker'..X..'-'..(Y+1)
    for X = -3, 3, 0.5 do
        NewLine = true
        ASCIIGFX = ''
        MaxElevation = 0
        if not CREATEDMARKERS[SouthMarkerIndex] then continue end
        for Y = MarkerPos[3], CREATEDMARKERS[SouthMarkerIndex].position[3], 0.5 do
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                DrawLine( {MarkerPos[1] + X, MarkerPos[2], MarkerPos[3]}, { MarkerPos[1] + X, MarkerPos[2], Y}, 'ffFFE0E0' )
                WaitTicks(1)
            end
            if NewLine then
                NewLine = false
                LastSHigh = GetSurfaceHeight( MarkerPos[1] + X, Y )
            end
            -- Elevation between checkpoints
            local Block = false
            SHigh = GetSurfaceHeight( MarkerPos[1] + X, Y )
            Elevation = math.abs(math.floor(LastSHigh*100 - SHigh*100))
            if Elevation > MaxElevation then
                MaxElevation = Elevation
            end
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                if Elevation ~= 0 then
                    --LOG('*ConnectMarker MaxPassableElevation : '..Elevation )
                end
            end
            if Elevation > MaxPassableElevation then
                if DebugMarker == MarkerIndex then
                    --WARN('*ConnectMarker MaxPassableElevation Blocked!!! '..Elevation )
                end
                Block = true
            end
            -- left
            SHigh = GetSurfaceHeight( MarkerPos[1] + X -1 , Y -0.5 )
            Elevation = math.abs(math.floor(LastSHigh*100 - SHigh*100))
            if Elevation > MaxElevation then
                MaxElevation = Elevation
            end
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                if Elevation ~= 0 then
                    --LOG('*ConnectMarker MaxPassableElevation L : '..Elevation )
                end
            end
            if Elevation > MaxPassableElevation then
                if DebugMarker == MarkerIndex then
                    --WARN('*ConnectMarker MaxPassableElevation L Blocked!!! '..Elevation )
                end
                Block = true
            end
            -- right
            SHigh = GetSurfaceHeight( MarkerPos[1] + X +1, Y -0.5)
            Elevation = math.abs(math.floor(LastSHigh*100 - SHigh*100))
            if Elevation > MaxElevation then
                MaxElevation = Elevation
            end
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                if Elevation ~= 0 then
                    --LOG('*ConnectMarker MaxPassableElevation R : '..Elevation )
                end
            end
            if Elevation > MaxPassableElevation then
                if DebugMarker == MarkerIndex then
                    --WARN('*ConnectMarker MaxPassableElevation R Blocked!!! '..Elevation )
                end
                Block = true
            end


            if Block == true then
                if DebugMarker == MarkerIndex then
                    --WARN('*ConnectMarker MaxPassableElevation Blocked!!! '..Elevation )
                end
                FAIL = FAIL + 1
                ASCIIGFX = ASCIIGFX..'----'
                break
            else
                ASCIIGFX = ASCIIGFX..'....'
            end
            LastSHigh = SHigh
        end
        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
            LOG(ASCIIGFX)
        end
    end
    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
        WARN('*CheckValidMarkerPosition South ('..FAIL..') Fails - Max Elevation= '..MaxElevation)
    end
    -- Check if we have failed to find pathable Terrain
    if FAIL < MaxFails or CREATEDMARKERS[MarkerIndex]['graph'] == 'DefaultAir' then
        -- Add the SouthMarker to our current Marker as adjacency
        if CREATEDMARKERS[SouthMarkerIndex] then
            if not CREATEDMARKERS[MarkerIndex].adjacentTo then
                CREATEDMARKERS[MarkerIndex].adjacentTo = SouthMarkerIndex
            else
                CREATEDMARKERS[MarkerIndex].adjacentTo = CREATEDMARKERS[MarkerIndex].adjacentTo..' '..SouthMarkerIndex
            end
        end
        -- And add the current marker also to the SouthMarker as adjacency
        if CREATEDMARKERS[SouthMarkerIndex] then
            if not CREATEDMARKERS[SouthMarkerIndex].adjacentTo then
                CREATEDMARKERS[SouthMarkerIndex].adjacentTo = MarkerIndex
            else
                CREATEDMARKERS[SouthMarkerIndex].adjacentTo = CREATEDMARKERS[SouthMarkerIndex].adjacentTo..' '..MarkerIndex
            end
        end
        if DebugMarker == MarkerIndex then
            LOG('*ConnectMarker Terrain Free -> Connecting ('..MarkerIndex..') with ('..SouthMarkerIndex..')')
        end
    else
        if DebugMarker == MarkerIndex then
            WARN('*ConnectMarker Terrain Blocked. Cant connect ('..MarkerIndex..') with ('..SouthMarkerIndex..')')
        end
    end

    ------------------------------------------------
    -- Search for a connection to SE (South-East) --
    ------------------------------------------------
    FAIL = 0
    local SouthEastMarkerIndex = 'Marker'..(X+1)..'-'..(Y+1)
    if CREATEDMARKERS[SouthEastMarkerIndex] then
        for X = -3, 3, 0.5 do
            NewLine = true
            ASCIIGFX = ''
            for XY = 0, CREATEDMARKERS[SouthEastMarkerIndex].position[3] - MarkerPos[3] , 0.5 do
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                    DrawLine( {MarkerPos[1] + X, MarkerPos[2], MarkerPos[3] - X}, { MarkerPos[1] + X+XY, MarkerPos[2], MarkerPos[3] + XY - X}, 'ffFFE0E0' )
                    WaitTicks(1)
                end
                if NewLine then
                    NewLine = false
                    LastSHigh = GetSurfaceHeight( MarkerPos[1] + X+XY, MarkerPos[3] + XY -X )
                end
                -- Elevation between checkpoints
                local Block = false
                SHigh = GetSurfaceHeight( MarkerPos[1] + X+XY, MarkerPos[3] + XY -X )
                Elevation = math.abs(math.floor(LastSHigh*100 - SHigh*100))
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                    if Elevation ~= 0 then
                        --LOG('*ConnectMarker MaxPassableElevation : '..Elevation )
                    end
                end
                if Elevation > MaxPassableElevation then
                    if DebugMarker == MarkerIndex then
                        --WARN('*ConnectMarker MaxPassableElevation Blocked!!! '..Elevation )
                    end
                    Block = true
                end
                -- Up
                SHigh = GetSurfaceHeight( MarkerPos[1] + X+XY, MarkerPos[3] + XY -X -1)
                Elevation = math.abs(math.floor(LastSHigh*100 - SHigh*100))
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                    if Elevation ~= 0 then
                        --LOG('*ConnectMarker MaxPassableElevation U : '..Elevation )
                    end
                end
                if Elevation > MaxPassableElevation then
                    if DebugMarker == MarkerIndex then
                        --WARN('*ConnectMarker MaxPassableElevation U Blocked!!! '..Elevation )
                    end
                    Block = true
                end
                -- left
                SHigh = GetSurfaceHeight( MarkerPos[1] + X+XY-1, MarkerPos[3] + XY -X )
                Elevation = math.abs(math.floor(LastSHigh*100 - SHigh*100))
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                    if Elevation ~= 0 then
                        --LOG('*ConnectMarker MaxPassableElevation D : '..Elevation )
                    end 
                end 
                if Elevation > MaxPassableElevation then
                    if DebugMarker == MarkerIndex then
                        --WARN('*ConnectMarker MaxPassableElevation D Blocked!!! '..Elevation )
                    end
                    Block = true
                end


                if Block == true then
                    if DebugMarker == MarkerIndex then
                        --WARN('*ConnectMarker MaxPassableElevation Blocked!!! '..Elevation )
                    end
                    FAIL = FAIL + 1
                    ASCIIGFX = ASCIIGFX..'----'
                    break
                else
                    ASCIIGFX = ASCIIGFX..'....'
                end
                LastSHigh = SHigh
            end
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                LOG(ASCIIGFX)
            end
        end
    end
    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
        WARN('*CheckValidMarkerPosition South-East ('..FAIL..') Fails')
    end
    -- Check if we have failed to find pathable Terrain
    if FAIL < MaxFails or CREATEDMARKERS[MarkerIndex]['graph'] == 'DefaultAir' then
        -- Add the SouthEastMarker to our current Marker as adjacency
        if CREATEDMARKERS[SouthEastMarkerIndex] then
            if not CREATEDMARKERS[MarkerIndex].adjacentTo then
                CREATEDMARKERS[MarkerIndex].adjacentTo = SouthEastMarkerIndex
            else
                CREATEDMARKERS[MarkerIndex].adjacentTo = CREATEDMARKERS[MarkerIndex].adjacentTo..' '..SouthEastMarkerIndex
            end
        end
        -- And add the current marker also to the SouthEastMarker as adjacency
        if CREATEDMARKERS[SouthEastMarkerIndex] then
            if not CREATEDMARKERS[SouthEastMarkerIndex].adjacentTo then
                CREATEDMARKERS[SouthEastMarkerIndex].adjacentTo = MarkerIndex
            else
                CREATEDMARKERS[SouthEastMarkerIndex].adjacentTo = CREATEDMARKERS[SouthEastMarkerIndex].adjacentTo..' '..MarkerIndex
            end
        end
        if DebugMarker == MarkerIndex then
            LOG('*ConnectMarker Terrain Free -> Connecting ('..MarkerIndex..') with ('..SouthEastMarkerIndex..')')
        end
    else
        if DebugMarker == MarkerIndex then
            WARN('*ConnectMarker Terrain Blocked. Cant connect ('..MarkerIndex..') with ('..SouthEastMarkerIndex..')')
        end
    end
    ------------------------------------------------
    -- Search for a connection to SW (South-West) --
    ------------------------------------------------
    FAIL = 0
    local SouthWestMarkerIndex = 'Marker'..(X-1)..'-'..(Y+1)
    if CREATEDMARKERS[SouthWestMarkerIndex] then
        for X = -3, 3, 0.5 do
            NewLine = true
            ASCIIGFX = ''
            for XY = 0, CREATEDMARKERS[SouthWestMarkerIndex].position[3] - MarkerPos[3] , 0.5 do
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                    DrawLine( {MarkerPos[1] + X, MarkerPos[2], MarkerPos[3] + X}, { MarkerPos[1] + X-XY, MarkerPos[2], MarkerPos[3] + XY + X}, 'ffFFE0E0' )
                    WaitTicks(1)
                end
                if NewLine then
                    NewLine = false
                    LastSHigh = GetSurfaceHeight( MarkerPos[1] + X-XY, MarkerPos[3] + XY + X )
                end
                -- Elevation between checkpoints
                local Block = false
                SHigh = GetSurfaceHeight( MarkerPos[1] + X-XY, MarkerPos[3] + XY + X )
                Elevation = math.abs(math.floor(LastSHigh*100 - SHigh*100))
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                    if Elevation ~= 0 then
                        --LOG('*ConnectMarker MaxPassableElevation : '..Elevation )
                    end
                end
                if Elevation > MaxPassableElevation then
                    if DebugMarker == MarkerIndex then
                        --WARN('*ConnectMarker MaxPassableElevation Blocked!!! '..Elevation )
                    end
                    Block = true
                end
                -- right
                SHigh = GetSurfaceHeight( MarkerPos[1] + X-XY +1, MarkerPos[3] + XY + X )
                Elevation = math.abs(math.floor(LastSHigh*100 - SHigh*100))
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                    if Elevation ~= 0 then
                        --LOG('*ConnectMarker MaxPassableElevation U : '..Elevation )
                    end
                end
                if Elevation > MaxPassableElevation then
                    if DebugMarker == MarkerIndex then
                        --WARN('*ConnectMarker MaxPassableElevation U Blocked!!! '..Elevation )
                    end
                    Block = true
                end
                -- up
                SHigh = GetSurfaceHeight( MarkerPos[1] + X-XY, MarkerPos[3] + XY + X -1)
                Elevation = math.abs(math.floor(LastSHigh*100 - SHigh*100))
                if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                    if Elevation ~= 0 then
                        --LOG('*ConnectMarker MaxPassableElevation U : '..Elevation )
                    end 
                end 
                if Elevation > MaxPassableElevation then
                    if DebugMarker == MarkerIndex then
                        --WARN('*ConnectMarker MaxPassableElevation U Blocked!!! '..Elevation )
                    end
                    Block = true
                end


                if Block == true then
                    if DebugMarker == MarkerIndex then
                        --WARN('*ConnectMarker MaxPassableElevation Blocked!!! '..Elevation )
                    end
                    FAIL = FAIL + 1
                    ASCIIGFX = ASCIIGFX..'----'
                    break
                else
                    ASCIIGFX = ASCIIGFX..'....'
                end
                LastSHigh = SHigh
            end
            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
                LOG(ASCIIGFX)
            end
        end
    end
    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
        WARN('*CheckValidMarkerPosition South-West ('..FAIL..') Fails')
    end
    -- Check if we have failed to find pathable Terrain
    if FAIL < MaxFails or CREATEDMARKERS[MarkerIndex]['graph'] == 'DefaultAir' then
        -- Add the SouthWestMarker to our current Marker as adjacency
        if CREATEDMARKERS[SouthWestMarkerIndex] then
            if not CREATEDMARKERS[MarkerIndex].adjacentTo then
                CREATEDMARKERS[MarkerIndex].adjacentTo = SouthWestMarkerIndex
            else
                CREATEDMARKERS[MarkerIndex].adjacentTo = CREATEDMARKERS[MarkerIndex].adjacentTo..' '..SouthWestMarkerIndex
            end
        end
        -- And add the current marker also to the SouthWestMarker as adjacency
        if CREATEDMARKERS[SouthWestMarkerIndex] then
            if not CREATEDMARKERS[SouthWestMarkerIndex].adjacentTo then
                CREATEDMARKERS[SouthWestMarkerIndex].adjacentTo = MarkerIndex
            else
                CREATEDMARKERS[SouthWestMarkerIndex].adjacentTo = CREATEDMARKERS[SouthWestMarkerIndex].adjacentTo..' '..MarkerIndex
            end
        end
        if DebugMarker == MarkerIndex then
            LOG('*ConnectMarker Terrain Free -> Connecting ('..MarkerIndex..') with ('..SouthWestMarkerIndex..')')
        end
    else
        if DebugMarker == MarkerIndex then
            WARN('*ConnectMarker Terrain Blocked. Cant connect ('..MarkerIndex..') with ('..SouthWestMarkerIndex..')')
        end
    end

    return
end


-- OFFSET 418

--['LandPN310'] = {
--    ['color'] = STRING( 'ff00ff00' ),
--    ['hint'] = BOOLEAN( true ),
--    ['graph'] = STRING( 'DefaultLand' ),
--    ['adjacentTo'] = STRING( 'LandPN99 LandPN279 LandPN63 LandPN176 LandPN83' ),
--    ['type'] = STRING( 'Land Path Node' ),
--    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
--    ['orientation'] = VECTOR3( 0, 0, 0 ),
--    ['position'] = VECTOR3( 382.5, 68.45339, 276.5 ),
--},
--    ['Land Path Node']          = { ['graph'] ='DefaultLand',       ['color'] = 'ff808080', },
--    ['Water Path Node']         = { ['graph'] ='DefaultWater',      ['color'] = 'ff0000ff', },
--    ['Amphibious Path Node']    = { ['graph'] ='DefaultAmphibious', ['color'] = 'ff404060', },
--    ['Air Path Node']           = { ['graph'] ='DefaultAir',        ['color'] = 'ffffffff', },

function PrintMASTERCHAIN()
    --LOG(repr(Scenario.MasterChain._MASTERCHAIN_.Markers))
    LOG('******************************************** START ***************************************************')
    LOG('************************ Copy the MASTERCHAIN table to your map_save.lua file ************************')
    LOG('* Please Copy&Paste the markers from the game.log file from HDD not from the [F9] debug log window!! *')
    LOG('******************************************************************************************************')
    LOG('  MasterChain = {')
    LOG('    [\'_MASTERCHAIN_\'] = {')
    LOG('      Markers = {')
        for k, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
            local count = 0
            LOG('        [\''..k..'\'] = {')
            if v.type then
                LOG('          [\'type\'] = STRING( \''..v.type..'\' ),')
                count = count + 1
            end
            if v.position then
                LOG('          [\'position\'] = VECTOR3( '..v.position[1]..', '..v.position[2]..', '..v.position[3]..' ),')
                count = count + 1
            end
            if v.orientation then
                LOG('          [\'orientation\'] = VECTOR3( '..v.orientation[1]..', '..v.orientation[2]..', '..v.orientation[3]..' ),')
                count = count + 1
            end
            if v.size then
                LOG('          [\'size\'] = FLOAT( '..v.size..' ),')
                count = count + 1
            end
            if v.resource then
                LOG('          [\'resource\'] = BOOLEAN( '..tostring(v.resource)..' ),')
                count = count + 1
            end
            if v.hint then
                LOG('          [\'hint\'] = BOOLEAN( '..tostring(v.hint)..' ),')
                count = count + 1
            end
            if v.graph then
                LOG('          [\'graph\'] = STRING( \''..v.graph..'\' ),')
                count = count + 1
            end
            if v.adjacentTo then
                LOG('          [\'adjacentTo\'] = STRING( \''..v.adjacentTo..'\' ),')
                count = count + 1
            end
            if v.amount then
                LOG('          [\'amount\'] = FLOAT( '..v.amount..' ),')
                count = count + 1
            end
            if v.color then
                LOG('          [\'color\'] = STRING( \''..v.color..'\' ),')
                count = count + 1
            end
            if v.editorIcon then
                LOG('          [\'editorIcon\'] = STRING( \''..v.editorIcon..'\' ),')
                count = count + 1
            end
            if v.prop then
                LOG('          [\'prop\'] = STRING( \''..v.prop..'\' ),')
                count = count + 1
            end
            -- camera
            if v.zoom then
                LOG('          [\'zoom\'] = FLOAT( '..v.zoom..' ),')
                count = count + 1
            end
            if v.canSetCamera then
                LOG('          [\'canSetCamera\'] = BOOLEAN( '..tostring(v.canSetCamera)..' ),')
                count = count + 1
            end
            if v.canSyncCamera then
                LOG('          [\'canSyncCamera\'] = BOOLEAN( '..tostring(v.canSyncCamera)..' ),')
                count = count + 1
            end
            -- Weather
            if v.MapStyle then
                LOG('          [\'MapStyle\'] = STRING( \''..v.MapStyle..'\' ),')
                count = count + 1
            end
            if v.WeatherType01 then
                LOG('          [\'WeatherType01\'] = STRING( \''..v.WeatherType01..'\' ),')
                count = count + 1
            end
            if v.WeatherType01Chance then
                LOG('          [\'WeatherType01Chance\'] = FLOAT( '..v.WeatherType01Chance..' ),')
                count = count + 1
            end
            if v.WeatherType02 then
                LOG('          [\'WeatherType02\'] = STRING( \''..v.WeatherType02..'\' ),')
                count = count + 1
            end
            if v.WeatherType02Chance then
                LOG('          [\'WeatherType02Chance\'] = FLOAT( '..v.WeatherType02Chance..' ),')
                count = count + 1
            end
            if v.WeatherType03 then
                LOG('          [\'WeatherType03\'] = STRING( \''..v.WeatherType03..'\' ),')
                count = count + 1
            end
            if v.WeatherType03Chance then
                LOG('          [\'WeatherType03Chance\'] = FLOAT( '..v.WeatherType03Chance..' ),')
                count = count + 1
            end
            if v.WeatherType04 then
                LOG('          [\'WeatherType04\'] = STRING( \''..v.WeatherType04..'\' ),')
                count = count + 1
            end
            if v.WeatherType04Chance then
                LOG('          [\'WeatherType04Chance\'] = FLOAT( '..v.WeatherType04Chance..' ),')
                count = count + 1
            end
            if v.WeatherDriftDirection then
                LOG('          [\'WeatherDriftDirection\'] = VECTOR3( '..v.WeatherDriftDirection[1]..', '..v.WeatherDriftDirection[2]..', '..v.WeatherDriftDirection[3]..' ),')
                count = count + 1
            end
            -- cloud
            if v.ForceType then
                LOG('          [\'ForceType\'] = STRING( \''..v.ForceType..'\' ),')
                count = count + 1
            end
            if v.cloudHeight then
                LOG('          [\'cloudHeight\'] = FLOAT( '..v.cloudHeight..' ),')
                count = count + 1
            end
            if v.cloudEmitterScale then
                LOG('          [\'cloudEmitterScale\'] = FLOAT( '..v.cloudEmitterScale..' ),')
                count = count + 1
            end
            if v.cloudEmitterScaleRange then
                LOG('          [\'cloudEmitterScaleRange\'] = FLOAT( '..v.cloudEmitterScaleRange..' ),')
                count = count + 1
            end
            if v.cloudCountRange then
                LOG('          [\'cloudCountRange\'] = FLOAT( '..v.cloudCountRange..' ),')
                count = count + 1
            end
            if v.cloudSpread then
                LOG('          [\'cloudSpread\'] = FLOAT( '..v.cloudSpread..' ),')
                count = count + 1
            end
            if v.cloudHeightRange then
                LOG('          [\'cloudHeightRange\'] = FLOAT( '..v.cloudHeightRange..' ),')
                count = count + 1
            end
            if v.spawnChance then
                LOG('          [\'spawnChance\'] = FLOAT( '..v.spawnChance..' ),')
                count = count + 1
            end
            if v.cloudCount then
                LOG('          [\'cloudCount\'] = FLOAT( '..v.cloudCount..' ),')
                count = count + 1
            end
            -- Effect
            if v.EffectTemplate then
                LOG('          [\'EffectTemplate\'] = STRING( \''..v.EffectTemplate..'\' ),')
                count = count + 1
            end
            if v.offset then
                LOG('          [\'offset\'] = VECTOR3( '..v.offset[1]..', '..v.offset[2]..', '..v.offset[3]..' ),')
                count = count + 1
            end
            if v.scale then
                LOG('          [\'scale\'] = FLOAT( '..v.scale..' ),')
                count = count + 1
            end

            LOG('        },')
            -- Validate 
            local ArrayCount = 0
            for _, _ in v do
                ArrayCount = ArrayCount + 1
            end
            if count ~= ArrayCount then
                WARN('Missing value in marker '..k..' -> '..repr(v)) 
            end
        end
    LOG('      },')
    LOG('    },')
    LOG('  },')
    LOG('******************************************************************************************************')
    LOG('************************ Copy the MASTERCHAIN table to your map_save.lua file ************************')
    LOG('* Please Copy&Paste the markers from the game.log file from HDD not from the [F9] debug log window!! *')
    LOG('********************************************* END ****************************************************')

end

