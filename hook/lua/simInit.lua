local UvesoOffsetSimInitLUA = debug.getinfo(1).currentline - 1
WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..UvesoOffsetSimInitLUA..'] * AI-Uveso: offset simInit.lua')
--457

local AIAttackUtils = import('/lua/ai/aiattackutilities.lua')
local TimeConvert = import('/lua/AI/sorianutilities.lua').TimeConvert

-- This function can be called from all SIM state lua files
function DebugArray(Table)
    for Index, Array in Table do
        if type(Array) == 'thread' or type(Array) == 'userdata' then
            LOG('Index['..Index..'] is type('..type(Array)..'). I won\'t print that!')
        elseif type(Array) == 'table' then
            LOG('Index['..Index..'] is type('..type(Array)..'). I won\'t print that!')
        else
            LOG('Index['..Index..'] is type('..type(Array)..'). "', repr(Array),'".')
        end
    end
end

function AILog(data, bool, offset)
    if bool == false then return end
    -- visual indicator for offset line numbers - 1234 = normal line number, ^1234 linenumber with offset
    if not offset then offset = 0 end
    if offset > 0 then off = "^" else off = "" end
    -- print to the debuglog filename and linenumber from this log call
    local text = tostring( TimeConvert(GetGameTimeSeconds()).." ["..string.gsub(debug.getinfo(2).source, ".*\\(.*.lua)", "%1")..":"..off..(debug.getinfo(2).currentline - offset).."] " )
    -- check datatype and print the data to the logfile
    if type(data) == "boolean" then
        _ALERT(text..tostring(data))
    elseif type(data) == "number" then
        _ALERT(text..tostring(data))
    elseif type(data) == "string" then
        _ALERT(text..data)
    elseif type(data) == "function" then
        _ALERT(text.."arg is type("..type(data).."): ["..tostring(data).."]")
    elseif type(data) == "table" then
        _ALERT(text.."printing root of table:")
        _ALERT(text.."{")
        for index, array in pairs(data) do
            if type(array) == "boolean" then
                _ALERT(text.."    Index["..tostring(index).."] is type("..type(array).."): ["..tostring(array).."]")
            elseif type(array) == "number" then
                _ALERT(text.."    Index["..tostring(index).."] is type("..type(array).."): ["..tostring(array).."]")
            elseif type(array) == "string" then
                _ALERT(text.."    Index["..tostring(index).."] is type("..type(array).."): ["..array.."]")
            elseif type(array) == "table" then
                _ALERT(text.."    Index["..tostring(index).."] is type("..type(array)..") with #"..(table.getn(array)).." indexes. I won\'t print that!")
            elseif type(array) == "function" then
                _ALERT(text.."    Index["..tostring(index).."] is type("..type(array).."): ["..tostring(array).."]")
            else
                _ALERT(text.."    * AILog: Unknow data type: ("..type(array).."). I won\'t print that!")
            end
        end
        _ALERT(text.."}")
    else
        _ALERT(text.."* AILog: Unknow data type: ("..type(data).."). I won\'t print that!")
    end
end

function AIDebug(data, bool, offset)
    if bool == false then return end
    -- visual indicator for offset line numbers - 1234 = normal line number, ^1234 linenumber with offset
    if not offset then offset = 0 end
    if offset > 0 then off = "^" else off = "" end
    -- print to the debuglog filename and linenumber from this log call
    SPEW(tostring( TimeConvert(GetGameTimeSeconds()).." ["..string.gsub(debug.getinfo(2).source, ".*\\(.*.lua)", "%1")..":"..off..(debug.getinfo(2).currentline - offset).."] " )..data)
end

function AIWarn(data, bool, offset)
    if bool == false then return end
    -- visual indicator for offset line numbers - 1234 = normal line number, ^1234 linenumber with offset
    if not offset then offset = 0 end
    if offset > 0 then off = "^" else off = "" end
    -- print to the debuglog filename and linenumber from this log call
    WARN(tostring( TimeConvert(GetGameTimeSeconds()).." ["..string.gsub(debug.getinfo(2).source, ".*\\(.*.lua)", "%1")..":"..off..(debug.getinfo(2).currentline - offset).."] " )..data)
end

-- hooks for map validation on game start and debugstuff for pathfinding and base ranger.
local MaxSlope = 0.36 -- 36
local MaxAngle = 0.161 -- 18
local CREATEDMARKERS = {}
local MarkerCountX = 32
local MarkerCountY = 32
local ScanResolution = 0.4
local FootprintSize = 0.20

--local DebugMarker = 'Marker1-10' -- TKP Lakes
--local DebugMarker = 'Marker1-0' -- Twin Rivers
--local DebugMarker = 'Marker14-2' -- pass survival aix v8
--local DebugMarker = 'Marker19-1' -- Open Palms
local DebugMarker = false

local DebugValidMarkerPosition = false
local TraceEast = false
local TraceSouth = false
local TraceSouthEast = false
local TraceSouthWest = false

local OldBeginSessionUveso = BeginSession
function BeginSession()
    OldBeginSessionUveso()
    ValidateModFilesUveso()
    if ScenarioInfo.Options.AIPathingDebug ~= 'off' then
        ForkThread(GraphRenderThread)
    end
    -- show the marker grid and expansions
    ForkThread(RenderMarkerCreatorThread)
    -- Debug ACUChampion platoon function
--    ForkThread(DrawACUChampion)
    -- Debug HeatMap
--    ForkThread(DrawHeatMap)
    -- In case we are debugging with linedraw and waits we need to fork this function
    if DebugValidMarkerPosition then
        AILog('* AI-Uveso: Debug: ForkThread(CreateAIMarkers) DEEPTRACE', true, UvesoOffsetSimInitLUA)
        ForkThread(CreateAIMarkers)
    -- Fist calculate markers, then continue with the game start sequence.
    else
        AILog('* AI-Uveso: Function CreateAIMarkers() started!', true, UvesoOffsetSimInitLUA)
        local START = GetSystemTimeSecondsOnlyForProfileUse()
        CreateAIMarkers()
        local END = GetSystemTimeSecondsOnlyForProfileUse()
        AILog(string.format('* AI-Uveso: Function CreateAIMarkers() finished, runtime: %.2f seconds.', END - START  ), true, UvesoOffsetSimInitLUA)
    end
    CreateMassCount()
    ValidateMapAndMarkers()
end

local OldOnCreateArmyBrainUveso = OnCreateArmyBrain
function OnCreateArmyBrain(index, brain, name, nickname)
    OldOnCreateArmyBrainUveso(index, brain, name, nickname)
    -- check if we have an Ai brain that is not a civilian army
    if brain.BrainType == 'AI' and nickname ~= 'civilian' then
        -- check if we need to set a new unitcap for the AI. (0 = we are using the player unit cap)
        if tonumber(ScenarioInfo.Options.AIUnitCap) > 0 then
            AILog('* AI-Uveso: Function OnCreateArmyBrain(): Setting AI unit cap to '..ScenarioInfo.Options.AIUnitCap..' ('..nickname..')', true, UvesoOffsetSimInitLUA)
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
    ['DefaultLand']       = { [1] =  0.0, [2] =  0.0, [3] =  0.0, ['color'] = 'fff4a460', },
    ['DefaultWater']      = { [1] = -0.5, [2] =  0.0, [3] = -0.5, ['color'] = 'ff27408b', },
    ['DefaultAmphibious'] = { [1] = -1.0, [2] =  0.0, [3] = -1.0, ['color'] = 'ff1e90ff', },
    ['DefaultAir']        = { [1] = -1.5, [2] =  0.0, [3] = -1.5, ['color'] = 'ffffffff', },
}

local MarkerDefaults = {
    ['Land Path Node']          = { ['graph'] ='DefaultLand',       ['color'] = 'fff4a460', ['area'] = 'LandArea', },
    ['Water Path Node']         = { ['graph'] ='DefaultWater',      ['color'] = 'ff27408b', ['area'] = 'WaterArea', },
    ['Amphibious Path Node']    = { ['graph'] ='DefaultAmphibious', ['color'] = 'ff1e90ff', ['area'] = 'AmphibiousArea', },
    ['Air Path Node']           = { ['graph'] ='DefaultAir',        ['color'] = 'ffffffff', ['area'] = 'AirArea', },
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
            AIWarn('* AI-Uveso: ValidateMapAndMarkers: norushradius is too smal ('..ScenarioInfo.norushradius..')! Set radius to minimum (15).')
            ScenarioInfo.norushradius = 15
        else
            AILog('* AI-Uveso: ValidateMapAndMarkers: norushradius is OK. ('..ScenarioInfo.norushradius..')', true, UvesoOffsetSimInitLUA)
        end
    else
        AIWarn('* AI-Uveso: ValidateMapAndMarkers: norushradius is missing! Set radius to default (20).', true, UvesoOffsetSimInitLUA)
        ScenarioInfo.norushradius = 20
    end

    -- Check map markers
    local TEMP = {}
    local UNKNOWNMARKER = {}
    local dist
    local adjancents
    for k, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
        -- Check if the marker is known. If not, send a debug message
        if not KnownMarkerTypes[v.type] then
            if not UNKNOWNMARKER[v.type] then
                AILog('* AI-Uveso: ValidateMapAndMarkers: Unknown MarkerType: [\''..v.type..'\']=true,', true, UvesoOffsetSimInitLUA)
                UNKNOWNMARKER[v.type] = true
            end
        end
        -- Check Index Name
        if v.type == 'Naval Area' then
            if string.find(k, 'NavalArea') then
                AIWarn('* AI-Uveso: ValidateMapAndMarkers: MarkerType: [\''..v.type..'\'] Has wrong Index Name ['..k..']. (Should be [Naval Area xx] )')
            elseif not string.find(k, 'Naval Area') then
                AIWarn('* AI-Uveso: ValidateMapAndMarkers: MarkerType: [\''..v.type..'\'] Has wrong Index Name ['..k..']. (Should be [Naval Area xx] )')
            end
        end
        if v.type == 'Expansion Area' then
            if string.find(k, 'ExpansionArea') then
                AIWarn('* AI-Uveso: ValidateMapAndMarkers: MarkerType: [\''..v.type..'\'] Has wrong Index Name ['..k..']. (Should be [Expansion Area xx] )')
            elseif not string.find(k, 'Expansion Area') then
                AIWarn('* AI-Uveso: ValidateMapAndMarkers: MarkerType: [\''..v.type..'\'] Has wrong Index Name ['..k..']. (Should be [Expansion Area xx] )')
            end
        end
        if v.type == 'Large Expansion' then
            if string.find(k, 'LargeExpansion') then
                AIWarn('* AI-Uveso: ValidateMapAndMarkers: MarkerType: [\''..v.type..'\'] Has wrong Index Name ['..k..']. (Should be [Large Expansion xx] )')
            elseif not string.find(k, 'Large Expansion') then
                AIWarn('* AI-Uveso: ValidateMapAndMarkers: MarkerType: [\''..v.type..'\'] Has wrong Index Name ['..k..']. (Should be [Large Expansion xx] )')
            end
        end
        --'ARMY_'

        -- Check Mass Marker
        if v.type == 'Mass' then
            if v.position[1] <= 8 or v.position[1] >= ScenarioInfo.size[1] - 8 or v.position[3] <= 8 or v.position[3] >= ScenarioInfo.size[2] - 8 then
                AIWarn('* AI-Uveso: ValidateMapAndMarkers: MarkerType: [\''..v.type..'\'] is too close to map border. IndexName = ['..k..']. (Mass marker deleted!!!)')
                Scenario.MasterChain._MASTERCHAIN_.Markers[k] = nil
            end
        end
        -- Check Waypoint Marker
        if MarkerDefaults[v.type] then
            if v.adjacentTo then
                adjancents = STR_GetTokens(v.adjacentTo or '', ' ')
                if adjancents[0] then
                    for i, node in adjancents do
                        --local otherMarker = Scenario.MasterChain._MASTERCHAIN_.Markers[node]
                        if not Scenario.MasterChain._MASTERCHAIN_.Markers[node] then
                            AIWarn('* AI-Uveso: ValidateMapAndMarkers: adjacentTo is wrong in marker ['..k..'] - MarkerType: [\''..v.type..'\']. - Adjacent marker ['..node..'] is missing.')
                        end
                    end
                else
                    AIWarn('* AI-Uveso: ValidateMapAndMarkers: adjacentTo is empty in marker ['..k..'] - MarkerType: [\''..v.type..'\']. - Pathmarker must have an adjacent marker for pathing.')
                end
            else
                AIWarn('* AI-Uveso: ValidateMapAndMarkers: adjacentTo is missing in marker ['..k..'] - MarkerType: [\''..v.type..'\']. - Pathmarker must have an adjacent marker for pathing.')
            end
            -- Checking marker type/graph
--            if MarkerDefaults[v.type]['graph'] ~= v.graph then
--                AIWarn('* AI-Uveso: ValidateMapAndMarkers: graph missmatch in marker ['..k..'] - MarkerType: [\''..v.type..'\']. - marker.type is ('..repr(v.graph)..'), but should be ('..MarkerDefaults[v.type]['graph']..').')
                -- save the correct graph type
--                v.graph = MarkerDefaults[v.type]['graph']
--            end
            -- Checking colors (for debug)
            if MarkerDefaults[v.type]['color'] ~= v.color then
                -- we actual don't print a debugmessage here. This message is for debuging a debug function :)
                --AILog('* AI-Uveso: ValidateMapAndMarkers: color missmatch in marker ['..k..'] - MarkerType: [\''..v.type..'\']. marker.color is ('..repr(v.color)..'), but should be ('..MarkerDefaults[v.type]['color']..').')
                v.color = MarkerDefaults[v.type]['color']
            end
        -- Check BaseLocations distances to other locations
        elseif BaseLocations[v.type] then
            for k2, v2 in Scenario.MasterChain._MASTERCHAIN_.Markers do
                if BaseLocations[v2.type] and v ~= v2 then
                    dist = VDist2( v.position[1], v.position[3], v2.position[1], v2.position[3] )
                    -- Are we checking a Start location, and another marker is nearer then 80 units ?
                    if v.type == 'Blank Marker' and v2.type ~= 'Blank Marker' and dist < 80 then
                        AILog('* AI-Uveso: ValidateMapAndMarkers: Marker [\''..k2..'\'] is to close to Start Location [\''..k..'\']. Distance= '..math.floor(dist)..' (under 80).', true, UvesoOffsetSimInitLUA)
                        --Scenario.MasterChain._MASTERCHAIN_.Markers[k2] = nil
                    -- Check if we have other locations that have a low distance (under 60)
                    elseif v.type ~= 'Blank Marker' and v2.type ~= 'Blank Marker' and dist < 60 then
                        -- Check priority from small locations up to main base.
                        if BaseLocations[v.type].priority >= BaseLocations[v2.type].priority then
                            AILog('* AI-Uveso: ValidateMapAndMarkers: Marker [\''..k2..'\'] is to close to Marker [\''..k..'\']. Distance= '..math.floor(dist)..' (under 60).', true, UvesoOffsetSimInitLUA)
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

function GraphRenderThread()
    -- wait 10 seconds at gamestart before we start debuging
    coroutine.yield(100)
    AIDebug('* AI-Uveso: Function GraphRenderThread() started.', true, UvesoOffsetSimInitLUA)
    while true do
        --AILog('* AI-Uveso: Function GraphRenderThread() beat.')
        -- draw all paths with location radius and AI Pathfinding
        if ScenarioInfo.Options.AIPathingDebug == 'pathlocation'
        or ScenarioInfo.Options.AIPathingDebug == 'path'
        or ScenarioInfo.Options.AIPathingDebug == 'paththreats'
        or ScenarioInfo.Options.AIPathingDebug == 'imapthreats'
        then
            -- display first all land nodes (true will let them blink)
            if GetGameTimeSeconds() < 15 then
                DrawPathGraph('DefaultLand', false)
                DrawPathGraph('DefaultAmphibious', false)
                DrawPathGraph('DefaultWater', false)
            elseif GetGameTimeSeconds() < 20 then
                DrawPathGraph('DefaultLand', true)
            -- display amphibious nodes
            elseif GetGameTimeSeconds() < 25 then
                DrawPathGraph('DefaultAmphibious', true)
            -- water nodes
            elseif GetGameTimeSeconds() < 30 then
                DrawPathGraph('DefaultWater', true)
            -- air nodes
            elseif GetGameTimeSeconds() < 35 then
                DrawPathGraph('DefaultAir', true)
            elseif GetGameTimeSeconds() < 40 then
                DrawPathGraph('DefaultLand', false)
                DrawPathGraph('DefaultAmphibious', false)
                DrawPathGraph('DefaultWater', false)
            end
            -- Draw the radius of each base(manager)
            if ScenarioInfo.Options.AIPathingDebug == 'pathlocation' then
                DrawBaseRanger()
            -- Draw the IMAP threat
            elseif ScenarioInfo.Options.AIPathingDebug == 'imapthreats' then
                DrawIMAPThreats()
            end
            DrawAIPathCache()
        -- Display land path permanent
        elseif ScenarioInfo.Options.AIPathingDebug == 'land' then
            DrawPathGraph('DefaultLand', false)
            DrawAIPathCache('DefaultLand')
        -- Display water path permanent
        elseif ScenarioInfo.Options.AIPathingDebug == 'water' then
            DrawPathGraph('DefaultWater', false)
            DrawAIPathCache('DefaultWater')
        -- Display amph path permanent
        elseif ScenarioInfo.Options.AIPathingDebug == 'amph' then
            DrawPathGraph('DefaultAmphibious', false)
            DrawAIPathCache('DefaultAmphibious')
        -- Display air path permanent
        elseif ScenarioInfo.Options.AIPathingDebug == 'air' then
            DrawPathGraph('DefaultAir', false)
            DrawAIPathCache('DefaultAir')
        end
        coroutine.yield(2)
    end
end

function DrawACUChampion()
    local FocussedArmy
    while true do
        FocussedArmy = GetFocusArmy()
        for ArmyIndex, aiBrain in ArmyBrains do
            -- if CHAMPIONDEBUG = false then stop the Thread here
            if aiBrain.ACUChampion.RemoveDebugDrawThread then
                return
            end
            if FocussedArmy == -1 then
                continue
            end
            -- only draw the ACU data from the focussed army
            if FocussedArmy ~= ArmyIndex then
                continue
            end
            -- Don't draw debug lines for dead AIs
            if aiBrain.Result == "defeat" then
                continue
            end
            -- Draw a circle for CDRposition
            if aiBrain.ACUChampion.CDRposition then
                DrawCircle(aiBrain.ACUChampion.CDRposition[1], aiBrain.ACUChampion.CDRposition[2], 'c00000FF')
            end
            -- Draw a line for MainBaseTarget with path
            if aiBrain.ACUChampion.MainBaseTargetWithPathPos then
                DrawLinePop(aiBrain.ACUChampion.MainBaseTargetWithPathPos[1], aiBrain.ACUChampion.MainBaseTargetWithPathPos[2], 'ffB0FFB0')
            end
            -- Draw a line for closest MainBaseTarget, ignoring path
            if aiBrain.ACUChampion.MainBaseTargetCloseRangePos then
                DrawLinePop(aiBrain.ACUChampion.MainBaseTargetCloseRangePos[1], aiBrain.ACUChampion.MainBaseTargetCloseRangePos[2], 'ffFFFF00')
            end
            -- Draw a line for closest ACU MainBaseTarget, ignoring path
            if aiBrain.ACUChampion.MainBaseTargetACUCloseRangePos then
                DrawLinePop(aiBrain.ACUChampion.MainBaseTargetACUCloseRangePos[1], aiBrain.ACUChampion.MainBaseTargetACUCloseRangePos[2], 'ffFF2020')
            end

            -- Draw a line for Overcharge target
            if aiBrain.ACUChampion.OverchargeTargetPos then
                DrawLinePop(aiBrain.ACUChampion.OverchargeTargetPos[1], aiBrain.ACUChampion.OverchargeTargetPos[2], 'ffFF2020')
            end
            -- Draw a line for Focused Target
            if aiBrain.ACUChampion.FocusTargetPos then
                DrawLinePop(aiBrain.ACUChampion.FocusTargetPos[1], aiBrain.ACUChampion.FocusTargetPos[2], 'ffFFFFE0')
            end

            -- Draw a line for enemy tml
            if aiBrain.ACUChampion.EnemyTMLPos then
                DrawLinePop(aiBrain.ACUChampion.EnemyTMLPos[1], aiBrain.ACUChampion.EnemyTMLPos[2], 'ff404040')
            end

            -- Draw a line for enemy experimental
            if aiBrain.ACUChampion.EnemyExperimentalPos then
                DrawLinePop(aiBrain.ACUChampion.EnemyExperimentalPos[1], aiBrain.ACUChampion.EnemyExperimentalPos[2], 'ffFF4040')
                DrawCircle(aiBrain.ACUChampion.EnemyExperimentalPos[1], aiBrain.ACUChampion.EnemyExperimentalWepRange, 'ffFF4040')
            end

            -- Draw a line for movement
            if aiBrain.ACUChampion.moveto then
                DrawLinePop(aiBrain.ACUChampion.moveto[1], aiBrain.ACUChampion.moveto[2], 'ff0000FF')
            end

            -- Draw a circle for free areas
            if aiBrain.ACUChampion.AreaTable then
                for index, pos in aiBrain.ACUChampion.AreaTable do
                --AILog('index='..index..' - pos='..repr(pos)..'')
                    DrawCircle({pos[1], pos[2], pos[3]}, 25, 'c0000000')
                    DrawCircle({pos[1], pos[2], pos[3]}, math.min( 26, pos[4] ) , 'ffFF6060')
                end
            end

            -- Draw lines for assisties
            if aiBrain.ACUChampion.Assistees[1] then
                for index, pos in aiBrain.ACUChampion.Assistees do
                    DrawLine(pos[1], pos[2], 'ff30D030')
                end
            end
        end
        coroutine.yield(2)
    end
end

function DrawBaseRanger()
    -- get the range of combat zones
    local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetDangerZoneRadii()
    local FocussedArmy = GetFocusArmy()
    -- Render the radius of any base and expansion location
    if Scenario.MasterChain._MASTERCHAIN_.BaseRanger then
        for Index, ArmyRanger in Scenario.MasterChain._MASTERCHAIN_.BaseRanger do
            if FocussedArmy ~= Index then
                continue
            end
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
            --AILog('lastcolorindex:'..colors['lastcolorindex']..' - table.getn(colors)'..table.getn(colors))
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
    local MarkerPosition = {0,0,0}
    local Marker2Position = {0,0,0}
    -- Render the connection between the path nodes for the specific graph
    local otherMarker
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
                    otherMarker = Scenario.MasterChain._MASTERCHAIN_.Markers[node]
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
    for nodename, markerInfo in Scenario.MasterChain._MASTERCHAIN_.Markers or {} do
        if markerInfo['type'] == 'Blank Marker' then
            DrawCircle(markerInfo['position'], 8, 'ffFF0000' )
            DrawCircle(markerInfo['position'], 7.5, 'ff000000' )
            DrawCircle(markerInfo['position'], 9, 'ffF4A460' )
        end
        if markerInfo['type'] == 'Expansion Area' then
            DrawCircle(markerInfo['position'], 5, 'ffFF0000' )
            DrawCircle(markerInfo['position'], 4.5, 'ff808080' )
            DrawCircle(markerInfo['position'], 6, 'ffF4A460' )
        end
        if markerInfo['type'] == 'Large Expansion Area' then
            DrawCircle(markerInfo['position'], 10, 'ffFF0000' )
            DrawCircle(markerInfo['position'], 9.5, 'ffFFFFFF' )
            DrawCircle(markerInfo['position'], 11, 'ffF4A460' )
        end
        if markerInfo['type'] == 'Naval Area' then
            DrawCircle(markerInfo['position'], 8, 'ffFF0000' )
            DrawCircle(markerInfo['position'], 7.5, 'ff808080' )
            DrawCircle(markerInfo['position'], 9, 'ffF0F0FF' )
        end
    end
end

local threatScale = {Land=1, Amphibious=1, Water=1, Air=1}
local highestThreat = {Land=1, Amphibious=1, Water=1, Air=1}

function DrawIMAPThreats()
    local MCountX = 48
    local MCountY = 48
    local PosX
    local PosY
    local enemyThreat
    local FocussedArmy = GetFocusArmy()
    local DistanceBetweenMarkers
    for ArmyIndex, aiBrain in ArmyBrains do
        -- only draw the pathcache from the focussed army
        if FocussedArmy ~= ArmyIndex then
            continue
        end
        DistanceBetweenMarkers = ScenarioInfo.size[1] / ( MCountX )
        highestThreat = {Land=1, Amphibious=1, Water=1, Air=1}
        for Y = 0, MCountY - 1 do
            for X = 0, MCountX - 1 do
                PosX = X * DistanceBetweenMarkers + DistanceBetweenMarkers / 2
                PosY = Y * DistanceBetweenMarkers + DistanceBetweenMarkers / 2
                PosZ = GetTerrainHeight( PosX, PosY )
                -- -------------------------------------------------------------------------------- --
                enemyThreat = aiBrain:GetThreatAtPosition({PosX, PosZ, PosY}, 0, true, 'Overall')
                if highestThreat["Land"] < enemyThreat then
                    highestThreat["Land"] = enemyThreat
                end
                DrawCircle({PosX, PosZ, PosY}, (enemyThreat * threatScale["Land"]) + 0.1, 'fff4a460' )
                -- -------------------------------------------------------------------------------- --
                enemyThreat = aiBrain:GetThreatAtPosition({PosX+0.5, PosZ, PosY}, 0, true, 'AntiAir')
                if highestThreat["Air"] < enemyThreat then
                    highestThreat["Air"] = enemyThreat
                end
                DrawCircle({PosX, PosZ, PosY}, (enemyThreat * threatScale["Air"]) + 0.1, 'ffffffff' )
                -- -------------------------------------------------------------------------------- --
                enemyThreat = aiBrain:GetThreatAtPosition({PosX, PosZ, PosY+0.5}, 0, true, 'AntiSurface')
                enemyThreat = enemyThreat + aiBrain:GetThreatAtPosition({PosX, PosZ, PosY}, 0, true, 'AntiSurface')
                if highestThreat["Amphibious"] < enemyThreat then
                    highestThreat["Amphibious"] = enemyThreat
                end
                DrawCircle({PosX, PosZ, PosY}, (enemyThreat * threatScale["Amphibious"]) + 0.1, 'ff27408b' )
                -- -------------------------------------------------------------------------------- --
            end
        end
        -- max radius for a circle is DistanceBetweenMarkers / 2
        threatScale["Land"] = DistanceBetweenMarkers / 2 / highestThreat["Land"]
        threatScale["Air"] = DistanceBetweenMarkers / 2 / highestThreat["Air"]
        threatScale["Amphibious"] = DistanceBetweenMarkers / 2 / highestThreat["Amphibious"]
    end
end

function DrawAIPathCache(DrawOnly)
    -- loop over all players in the game
    local FocussedArmy = GetFocusArmy()
    local LineCountOffset
    local LastNode

    for ArmyIndex, aiBrain in ArmyBrains do
        -- only draw the pathcache from the focussed army
        if FocussedArmy ~= ArmyIndex then
            continue
        end
        -- is the player an AI-Uveso ?
        if aiBrain.PathCache then
            -- Loop over all paths that starts from "StartNode"
            for StartNode, EndNodeCache in aiBrain.PathCache do
                LineCountOffset = 0
                -- Loop over all paths starting from StartNode and ending in EndNode
                for EndNode, Path in EndNodeCache do
                    -- Loop over all threatWeighted paths
                    for threatWeight, PathNodes in Path do
                        -- Display only valid paths
                        if PathNodes.path ~= 'bad' then
                            LastNode = false
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


function RenderMarkerCreatorThread()
    AIDebug('* AI-Uveso: Function RenderMarkerCreatorThread() started.', true, UvesoOffsetSimInitLUA)
    local MarkerPosition = {}
    local Marker2Position = {}
    local adjancents
    local otherMarker
    while GetGameTimeSeconds() < 5 do
        coroutine.yield(10)
    end
    while true do
        if GetGameTimeSeconds() > 8 then
            --AILog('* AI-Uveso: Function RenderMarkerCreatorThread() beat.')
            for nodename, markerInfo in CREATEDMARKERS or {} do
                MarkerPosition[1] = markerInfo.position[1]
                MarkerPosition[2] = markerInfo.position[2]
                MarkerPosition[3] = markerInfo.position[3]
                -- Draw the marker path node
                DrawCircle(MarkerPosition, 4, Offsets[markerInfo.graph]['color'] or 'ff000000' )
                -- Draw the connecting lines to its adjacent nodes
                if markerInfo.adjacentTo then
                    adjancents = STR_GetTokens(markerInfo.adjacentTo or '', ' ')
                    if adjancents[0] then
                        for i, node in adjancents do
                            otherMarker = CREATEDMARKERS[node]
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
        end
        for nodename, markerInfo in Scenario.MasterChain._MASTERCHAIN_.Markers or {} do
            if markerInfo['type'] == 'Blank Marker' then
                DrawCircle(markerInfo['position'], 8, 'ffFF0000' )
                DrawCircle(markerInfo['position'], 7.5, 'ff000000' )
                DrawCircle(markerInfo['position'], 9, 'ffF4A460' )
            end
            if markerInfo['type'] == 'Expansion Area' then
                DrawCircle(markerInfo['position'], 5, 'ffFF0000' )
                DrawCircle(markerInfo['position'], 4.5, 'ff808080' )
                DrawCircle(markerInfo['position'], 6, 'ffF4A460' )
            end
            if markerInfo['type'] == 'Large Expansion Area' then
                DrawCircle(markerInfo['position'], 10, 'ffFF0000' )
                DrawCircle(markerInfo['position'], 9.5, 'ffFFFFFF' )
                DrawCircle(markerInfo['position'], 11, 'ffF4A460' )
            end
            if markerInfo['type'] == 'Naval Area' then
                DrawCircle(markerInfo['position'], 8, 'ffFF0000' )
                DrawCircle(markerInfo['position'], 7.5, 'ff808080' )
                DrawCircle(markerInfo['position'], 9, 'ffF0F0FF' )
            end
        end

        coroutine.yield(2)
        -- only display all markers at the start of the game
        if GetGameTimeSeconds() > 10 and not DebugValidMarkerPosition then
            return
        end
    end
end

function CreateAIMarkers()
    if ScenarioInfo.Options.AIMapMarker == 'off' then
        AILog('* AI-Uveso: Running without markers, deleting map marker.', true, UvesoOffsetSimInitLUA)
        CREATEDMARKERS = {}
        CopyMarkerToMASTERCHAIN('Land')
        CopyMarkerToMASTERCHAIN('Water')
        CopyMarkerToMASTERCHAIN('Amphibious')
        CopyMarkerToMASTERCHAIN('Air')
        return
    elseif ScenarioInfo.Options.AIMapMarker == 'map' then
        AILog('* AI-Uveso: Using the original marker from the map.', true, UvesoOffsetSimInitLUA)
        -- Build Graphs like LAND1 LAND2 WATER1 WATER2
        BuildGraphAreas()
        return
    elseif ScenarioInfo.DoNotAllowMarkerGenerator == true then
        AIWarn('* AI-Uveso: Map does not allow automated marker creation, using the original marker from the map.')
        -- Build Graphs like LAND1 LAND2 WATER1 WATER2
        BuildGraphAreas()
        return
    elseif ScenarioInfo.Options.AIMapMarker == 'miss' then
        local count = 0
        for k, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
            if MarkerDefaults[v.type] then
                count = count + 1
            end
        end
        if count > 1 then
            AILog('* AI-Uveso: No autogenerating. Map has '..count..' marker.', true, UvesoOffsetSimInitLUA)
            return
        else
            AILog('* AI-Uveso: Map has no markers; Generating marker, please wait...', true, UvesoOffsetSimInitLUA)
        end
    elseif ScenarioInfo.Options.AIMapMarker == 'all' then
        AILog('* AI-Uveso: Generating marker, please wait...', true, UvesoOffsetSimInitLUA)
    end
    -- Map size like 20x10 and 10x20
    if ScenarioInfo.size[1] > ScenarioInfo.size[2] then
        MarkerCountY = MarkerCountY / 2
    elseif ScenarioInfo.size[1] < ScenarioInfo.size[2] then
        MarkerCountX = MarkerCountX / 2
    end
    -- Playable area
    local playablearea
    if  ScenarioInfo.MapData.PlayableRect then
        playablearea = ScenarioInfo.MapData.PlayableRect
    else
        playablearea = {0, 0, ScenarioInfo.size[1], ScenarioInfo.size[2]}
    end
    --AILog('* AI-Uveso: playable area coordinates are ' .. repr(playablearea))
    -- Create Air Marker
    CREATEDMARKERS = {}
    local DistanceBetweenMarkers = ScenarioInfo.size[1] / ( MarkerCountX/2 )
    local PosX
    local PosY
    for Y = 0, MarkerCountY/2 - 1 do
        for X = 0, MarkerCountX/2 - 1 do
            PosX = X * DistanceBetweenMarkers + DistanceBetweenMarkers / 2
            PosY = Y * DistanceBetweenMarkers + DistanceBetweenMarkers / 2
                CREATEDMARKERS['Marker'..X..'-'..Y] = {
                    ['position'] = VECTOR3( PosX, GetSurfaceHeight(PosX,PosY), PosY ),
                    ['graph'] = 'DefaultAir',
                }
            if PosX < playablearea[1] or PosX > playablearea[3] or PosY < playablearea[2] or PosY > playablearea[4] then
                CREATEDMARKERS['Marker'..X..'-'..Y].graph = 'Blocked'
            end
        end
    end
    -- connect air markers
    for Y = 0, MarkerCountY/2 - 1 do
        for X = 0, MarkerCountX/2 - 1 do
            if not DebugValidMarkerPosition then
                ConnectMarker(X,Y)
            end
        end
    end
    -- Copy Markers to the Scenario.MasterChain._MASTERCHAIN
    CopyMarkerToMASTERCHAIN('Air')

    -- create Land/Water/Amphibious marker grid
    CREATEDMARKERS = {}
    DistanceBetweenMarkers = ScenarioInfo.size[1] / ( MarkerCountX )
    for Y = 0, MarkerCountY - 1 do
        for X = 0, MarkerCountX - 1 do
            PosX = X * DistanceBetweenMarkers + DistanceBetweenMarkers / 2
            PosY = Y * DistanceBetweenMarkers + DistanceBetweenMarkers / 2
                CREATEDMARKERS['Marker'..X..'-'..Y] = {
                    ['position'] = VECTOR3( PosX, GetSurfaceHeight(PosX,PosY), PosY ),
                }
        end
    end
    -- define marker as land, amp, water
    local ReturnGraph
    local MarkerIndex
    local MarkerPosition
    for Y = 0, MarkerCountY - 1 do
        for X = 0, MarkerCountX - 1 do
            MarkerIndex = 'Marker'..X..'-'..Y
            MarkerPosition = CREATEDMARKERS[MarkerIndex].position
            if MarkerPosition[1] > playablearea[1] and MarkerPosition[1] < playablearea[3] and MarkerPosition[3] > playablearea[2] and MarkerPosition[3] < playablearea[4] then
                ReturnGraph = CheckValidMarkerPosition(MarkerIndex)
            else
                ReturnGraph = 'Blocked'
            end
--            if DebugMarker == MarkerIndex then
--                ReturnGraph = 'DefaultAir'
--            end
            --AILog('Marker '..'Marker '..X..'-'..Y..' TerrainType = '..ReturnGraph)
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

    --create naval Areas
    CreateNavalExpansions()
    --create land expansions
    CreateLandExpansions()

    CleanMarkersInMASTERCHAIN('Land')
    CleanMarkersInMASTERCHAIN('Water')
    CleanMarkersInMASTERCHAIN('Amphibious')


    if ScenarioInfo.Options.AIMapMarker == 'print' then
        AILog('map: Printing markers to game.log', true, UvesoOffsetSimInitLUA)
        PrintMASTERCHAIN()
    end

    -- Build Graphs like LAND1 LAND2 WATER1 WATER2
    BuildGraphAreas()
end

function CleanMarkersInMASTERCHAIN(layer)
    local adjancents
    local adjancentsD
    local NewadjacentTo
    for Y = 0, MarkerCountY - 1 do
        for X = 0, MarkerCountX - 1 do
            if Scenario.MasterChain._MASTERCHAIN_.Markers[layer..X..'-'..Y] then
                --AILog('Cleaning marker '..layer..X..'-'..Y)
                -- check if we have 8 adjacentTo. If yes, delete this Marker
                adjancents = STR_GetTokens(Scenario.MasterChain._MASTERCHAIN_.Markers[layer..X..'-'..Y].adjacentTo or '', ' ')
                -- disabled for chp2001, it's also not really needed.
                -- if adjancents[7] then -- pruning markers with 8 adjancents
                if adjancents[8] then
                    AILog('markers has 8 adjacentTo: '..Scenario.MasterChain._MASTERCHAIN_.Markers[layer..X..'-'..Y].adjacentTo, true, UvesoOffsetSimInitLUA)
                    Scenario.MasterChain._MASTERCHAIN_.Markers[layer..X..'-'..Y] = nil
                    -- delete adjacentTo from near markers
                    for YD = -1, 1 do
                        for XD = -1, 1 do
                            --AILog('XD '..XD..' - YD '..YD..'')
                            if Scenario.MasterChain._MASTERCHAIN_.Markers[layer..(X+XD)..'-'..(Y+YD)] then
                                adjancentsD = STR_GetTokens(Scenario.MasterChain._MASTERCHAIN_.Markers[layer..(X+XD)..'-'..(Y+YD)].adjacentTo or '', ' ')
                                NewadjacentTo = nil
                                for i, node in adjancentsD do
                                    if node ~= layer..X..'-'..Y then
                                        --AILog('adding node '..node..' this is never'..layer..X..'-'..Y)
                                        if not NewadjacentTo then
                                            NewadjacentTo = node
                                        else
                                            NewadjacentTo = NewadjacentTo..' '..node
                                        end
                                    end
                                end
                                --AILog('Set new adjacent to marker : '..layer..(X+XD)..'-'..(Y+YD) )
                                Scenario.MasterChain._MASTERCHAIN_.Markers[layer..(X+XD)..'-'..(Y+YD)].adjacentTo = NewadjacentTo
                                --AILog('validate: '..repr(Scenario.MasterChain._MASTERCHAIN_.Markers[layer..(X+XD)..'-'..(Y+YD)].adjacentTo))
                            end
                        end
                    end
                elseif Scenario.MasterChain._MASTERCHAIN_.Markers[layer..X..'-'..Y].adjacentTo then
                    adjancents = STR_GetTokens(Scenario.MasterChain._MASTERCHAIN_.Markers[layer..X..'-'..Y].adjacentTo or '', ' ')
                    if not adjancents[0] then
                        --AILog('* AI-Uveso: adjacentTo table is empty, deleting node '..X..' '..Y..'')
                        Scenario.MasterChain._MASTERCHAIN_.Markers[layer..X..'-'..Y] = nil
                        CREATEDMARKERS['Marker'..X..'-'..Y] = nil
                    end
                else
                    --AILog('* AI-Uveso: no adjacentTo table found, deleting node '..X..' '..Y..'')
                    Scenario.MasterChain._MASTERCHAIN_.Markers[layer..X..'-'..Y] = nil
                    CREATEDMARKERS['Marker'..X..'-'..Y] = nil
                end
            end
        end
    end
end

function CopyMarkerToMASTERCHAIN(layer)
    --AILog('Delete original marker from MASTERCHAIN for Layer: '..layer)
    -- Deleting all previous markers from MASTERCHAIN
    for nodename, markerInfo in Scenario.MasterChain._MASTERCHAIN_.Markers or {} do
        if markerInfo['graph'] == 'Default'..layer then
            Scenario.MasterChain._MASTERCHAIN_.Markers[nodename] = nil
            --AILog('Removed from Masterchain: '..nodename)
        elseif markerInfo['type'] == layer..' Path Node' then
            Scenario.MasterChain._MASTERCHAIN_.Markers[nodename] = nil
            --AILog('Removed from Masterchain: '..nodename)
        end
    end
    -- Copy marker
    --AILog('Copy new marker to MASTERCHAIN for Layer: '..layer)
    local NewNodeName
    local NewadjacentTo
    local adjancents
    for nodename, markerInfo in CREATEDMARKERS do
        -- check if we have the right layer
        if markerInfo['graph'] == 'Default'..layer or layer == 'Amphibious' then
            NewNodeName = string.gsub(nodename, 'Marker', layer)
            Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName] = table.copy(markerInfo)
            -- Validate adjacentTo
            NewadjacentTo = nil
            adjancents = STR_GetTokens(Scenario.MasterChain._MASTERCHAIN_.Markers[NewNodeName].adjacentTo or '', ' ')
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
    local math = math
    local GetSurfaceHeight = GetSurfaceHeight
    local MarkerLayer = 'DefaultLand'
    if GetTerrainHeight(CREATEDMARKERS[MarkerIndex].position[1], CREATEDMARKERS[MarkerIndex].position[3]) < GetSurfaceHeight(CREATEDMARKERS[MarkerIndex].position[1], CREATEDMARKERS[MarkerIndex].position[3]) then
        MarkerLayer = 'DefaultWater'
    end
    local High, UHigh, DHigh, LHigh, RHigh = 0,0,0,0,0
    local LUHigh, RUHigh, LDHigh, RDHigh = 0,0,0,0
    local FAILLINE = 0
    local FAILSUMM = 0
    local MaxFails = 8 * 1/ScanResolution
    local MarkerPos = CREATEDMARKERS[MarkerIndex].position
    local Block, THigh
--    local ASCIIGFX = ''
    ------------------
    -- Check X Axis --
    ------------------
    FAILSUMM = 0
    for Y = -4, 4, ScanResolution do
--        ASCIIGFX = ''
        FAILLINE = 0
        for X = -4, 4, ScanResolution do
--            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--                --DrawLine( {MarkerPos[1] -4, MarkerPos[2], MarkerPos[3] + Y}, {MarkerPos[1] + X, MarkerPos[2], MarkerPos[3] + Y}, 'ffFFE0E0' )
--                --coroutine.yield(1)
--            end
            Block = false
                -- Check a square with FootprintSize if it has less then MaxSlope and MaxAngle
            High = GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
            UHigh = High - GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y-FootprintSize )
            DHigh = High - GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y+FootprintSize )
            LHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize, MarkerPos[3] + Y )
            RHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize, MarkerPos[3] + Y )
            LUHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize*0.8, MarkerPos[3] + Y-FootprintSize*0.8 )
            RUHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize*0.8, MarkerPos[3] + Y-FootprintSize*0.8 )
            LDHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize*0.8, MarkerPos[3] + Y+FootprintSize*0.8 )
            RDHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize*0.8, MarkerPos[3] + Y+FootprintSize*0.8 )
--            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--              AILog('*ConnectMarker slope  : '..string.format("slope:  %.3f  %.3f  %.3f  %.3f   angle:  %.3f  %.3f  %.3f  %.3f ... %.3f  %.3f  %.3f  %.3f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh), math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
--            end
            if math.abs(UHigh + DHigh) > MaxSlope or math.abs(LHigh + RHigh) > MaxSlope or math.abs(LUHigh + RDHigh) > MaxSlope or math.abs(RUHigh + LDHigh) > MaxSlope then
--                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthWest then
--                    AIWarn('*ConnectMarker slope  : '..string.format("%.2f %.2f %.2f %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh) ) )
--                end
                Block = true
            end
            if math.abs(UHigh) > MaxAngle or math.abs(DHigh) > MaxAngle or math.abs(LHigh) > MaxAngle or math.abs(RHigh) > MaxAngle or math.abs(LUHigh) > MaxAngle or math.abs(RUHigh) > MaxAngle or math.abs(LDHigh) > MaxAngle or math.abs(RDHigh) > MaxAngle then
--                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthWest then
--                    AIWarn('*ConnectMarker angle  : '..string.format("%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f", math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
--                end
                Block = true
            end
            if Block == true then
                FAILLINE = FAILLINE + 1
--                ASCIIGFX = ASCIIGFX..'----'
--            else
--                ASCIIGFX = ASCIIGFX..'....'
            end
            -- check Land / Water passage
            THigh = GetTerrainHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
            if MarkerLayer ~= 'DefaultAmphibious' then
                if THigh < High then
                    if MarkerLayer ~= 'DefaultWater' then
--                        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--                            AIWarn('*CheckValidMarkerPosition Land / Water passage!!!')
--                        end
                        MarkerLayer = 'DefaultAmphibious'
                    end
                else
                    if MarkerLayer == 'DefaultWater' then
--                        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--                            AIWarn('*CheckValidMarkerPosition Land / Water passage!!!')
--                        end
                        MarkerLayer = 'DefaultAmphibious'
                    end
                end
            end
        end
--        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--            AILog(ASCIIGFX)
--        end
        if FAILLINE >= MaxFails then
--            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--                AIWarn('*CheckValidMarkerPosition X Axis ('..FAILLINE..'/'..MaxFails..') LINE Failed')
--            end
            return 'Blocked'
        end
        if FAILLINE > 0 then
            FAILSUMM = FAILSUMM + 1
        end
--        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--            AILog('*CheckValidMarkerPosition X Axis FAILLINE ('..FAILLINE..'/'..MaxFails..')')
--        end
    end
    if FAILSUMM >= MaxFails then
--        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--            AIWarn('*CheckValidMarkerPosition X Axis FAILSUMM ('..FAILSUMM..'/'..MaxFails..') SUMM Failed')
--        end
        return 'Blocked'
    end
--    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--        AILog('*CheckValidMarkerPosition X Axis FAILSUMM ('..FAILSUMM..'/'..MaxFails..')')
--    end
    ------------------
    -- Check Y Axis --
    ------------------
    FAILSUMM = 0
    for X = -4, 4, ScanResolution do
        FAILLINE = 0
--        ASCIIGFX = ''
        for Y = -4, 4, ScanResolution do
--            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--                --DrawLine( {MarkerPos[1] + X , MarkerPos[2], MarkerPos[3] -4}, {MarkerPos[1] + X, MarkerPos[2], MarkerPos[3] + Y}, 'ffFFE0E0' )
--                --coroutine.yield(1)
--            end
            Block = false
                -- Check a square with FootprintSize if it has less then MaxSlope and MaxAngle
            High = GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
            UHigh = High - GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y-FootprintSize )
            DHigh = High - GetSurfaceHeight( MarkerPos[1] + X, MarkerPos[3] + Y+FootprintSize )
            LHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize, MarkerPos[3] + Y )
            RHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize, MarkerPos[3] + Y )
            LUHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize*0.8, MarkerPos[3] + Y-FootprintSize*0.8 )
            RUHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize*0.8, MarkerPos[3] + Y-FootprintSize*0.8 )
            LDHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize*0.8, MarkerPos[3] + Y+FootprintSize*0.8 )
            RDHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize*0.8, MarkerPos[3] + Y+FootprintSize*0.8 )
--            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--              AILog('*ConnectMarker slope  : '..string.format("slope:  %.3f  %.3f  %.3f  %.3f   angle:  %.3f  %.3f  %.3f  %.3f ... %.3f  %.3f  %.3f  %.3f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh), math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
--            end
            if math.abs(UHigh + DHigh) > MaxSlope or math.abs(LHigh + RHigh) > MaxSlope or math.abs(LUHigh + RDHigh) > MaxSlope or math.abs(RUHigh + LDHigh) > MaxSlope then
--                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthWest then
--                    AIWarn('*ConnectMarker slope  : '..string.format("%.2f %.2f %.2f %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh) ) )
--                end
                Block = true
            end
            if math.abs(UHigh) > MaxAngle or math.abs(DHigh) > MaxAngle or math.abs(LHigh) > MaxAngle or math.abs(RHigh) > MaxAngle or math.abs(LUHigh) > MaxAngle or math.abs(RUHigh) > MaxAngle or math.abs(LDHigh) > MaxAngle or math.abs(RDHigh) > MaxAngle then
--                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthWest then
--                    AIWarn('*ConnectMarker angle  : '..string.format("%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f", math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
--                end
                Block = true
            end
            if Block == true then
                FAILLINE = FAILLINE + 1
--                ASCIIGFX = ASCIIGFX..'----'
--            else
--                ASCIIGFX = ASCIIGFX..'....'
            end
            -- check Land / Water passage
            THigh = GetTerrainHeight( MarkerPos[1] + X, MarkerPos[3] + Y )
            if MarkerLayer ~= 'DefaultAmphibious' then
                if THigh < High then
                    if MarkerLayer ~= 'DefaultWater' then
--                        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--                            AIWarn('*CheckValidMarkerPosition Land / Water passage!!!')
--                        end
                        MarkerLayer = 'DefaultAmphibious'
                    end
                else
                    if MarkerLayer == 'DefaultWater' then
--                        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--                            AIWarn('*CheckValidMarkerPosition Land / Water passage!!!')
--                        end
                        MarkerLayer = 'DefaultAmphibious'
                    end
                end
            end
        end
--        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--            AILog(ASCIIGFX)
--        end
        if FAILLINE >= MaxFails then
--            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--                AIWarn('*CheckValidMarkerPosition Y Axis ('..FAILLINE..'/'..MaxFails..') LINE Failed')
--            end
            return 'Blocked'
        end
        if FAILLINE > 0 then
            FAILSUMM = FAILSUMM + 1
        end
--        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--            AILog('*CheckValidMarkerPosition Y Axis FAILLINE ('..FAILLINE..'/'..MaxFails..')')
--        end
    end
    if FAILSUMM >= MaxFails then
--        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--            AIWarn('*CheckValidMarkerPosition Y Axis FAILSUMM ('..FAILSUMM..'/'..MaxFails..') SUMM Failed')
--        end
        return 'Blocked'
    end
--    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--        AILog('*CheckValidMarkerPosition Y Axis FAILSUMM ('..FAILSUMM..'/'..MaxFails..')')
--    end
    return MarkerLayer
end

function ConnectMarker(X,Y)
    local math = math
    local GetSurfaceHeight = GetSurfaceHeight
    local MarkerIndex = 'Marker'..X..'-'..Y
    -- Check if this marker is valid
    if not CREATEDMARKERS[MarkerIndex] or CREATEDMARKERS[MarkerIndex].graph == 'Blocked' then
        return
    end
    -- First check a path to East Marker
    local MaxFails = 9
    local High, UHigh, DHigh, LHigh, RHigh = 0,0,0,0,0
    local LUHigh, RUHigh, LDHigh, RDHigh = 0,0,0,0
    local LUHigh, RUHigh, LDHigh, RDHigh = 0,0,0,0
    local MarkerPos = CREATEDMARKERS[MarkerIndex].position
    local Block
--    local ASCIIGFX = ''
    -----------------------------------------
    -- Search for a connection to E (East) --
    -----------------------------------------
    FAIL = 0
    local EastMarkerIndex = 'Marker'..(X+1)..'-'..Y
    if CREATEDMARKERS[EastMarkerIndex] and CREATEDMARKERS[EastMarkerIndex].graph ~= 'Blocked' then
        for Y = -3, 3, ScanResolution do
--            ASCIIGFX = ''
            for X = MarkerPos[1], CREATEDMARKERS[EastMarkerIndex].position[1], ScanResolution do
--                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceEast then
--                    DrawLine( {MarkerPos[1], MarkerPos[2], MarkerPos[3] + Y}, { X, MarkerPos[2], MarkerPos[3] + Y}, 'ffFFE0E0' )
--                    coroutine.yield(1)
--                end
                Block = false
                -- Check a square with FootprintSize if it has less then MaxSlope/MaxAngle ((circle 16:20  1:20*16 = 0.8))
                High = GetSurfaceHeight( X, MarkerPos[3] + Y )
                UHigh = High - GetSurfaceHeight( X, MarkerPos[3] + Y-FootprintSize )
                DHigh = High - GetSurfaceHeight( X, MarkerPos[3] + Y+FootprintSize )
                LHigh = High - GetSurfaceHeight( X-FootprintSize, MarkerPos[3] + Y )
                RHigh = High - GetSurfaceHeight( X+FootprintSize, MarkerPos[3] + Y )
                LUHigh = High - GetSurfaceHeight( X-FootprintSize*0.8, MarkerPos[3] + Y-FootprintSize*0.8 )
                RUHigh = High - GetSurfaceHeight( X+FootprintSize*0.8, MarkerPos[3] + Y-FootprintSize*0.8 )
                LDHigh = High - GetSurfaceHeight( X-FootprintSize*0.8, MarkerPos[3] + Y+FootprintSize*0.8 )
                RDHigh = High - GetSurfaceHeight( X+FootprintSize*0.8, MarkerPos[3] + Y+FootprintSize*0.8 )

-- TypeCode 9 an 230 is blocking terrain type (Did not find a map that is using it)
--if GetTerrainType(X,  MarkerPos[3] + Y).Blocking then
--    AIWarn('############ Blocking ############')
--end

--                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceEast then
--                    AILog('*ConnectMarker slope  : '..string.format("slope:  %.3f  %.3f  %.3f  %.3f   angle:  %.3f  %.3f  %.3f  %.3f ... %.3f  %.3f  %.3f  %.3f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh), math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
--                end
                if math.abs(UHigh + DHigh) > MaxSlope or math.abs(LHigh + RHigh) > MaxSlope or math.abs(LUHigh + RDHigh) > MaxSlope or math.abs(RUHigh + LDHigh) > MaxSlope then
--                    if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouth then
--                        AIWarn('*ConnectMarker slope  : '..string.format("%.2f %.2f %.2f %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh) ) )
--                    end
                    Block = true
                end
                if math.abs(UHigh) > MaxAngle or math.abs(DHigh) > MaxAngle or math.abs(LHigh) > MaxAngle or math.abs(RHigh) > MaxAngle or math.abs(LUHigh) > MaxAngle or math.abs(RUHigh) > MaxAngle or math.abs(LDHigh) > MaxAngle or math.abs(RDHigh) > MaxAngle then
--                    if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouth then
--                        AIWarn('*ConnectMarker angle  : '..string.format("%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f", math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
--                    end
                    Block = true
                end
                if Block == true then
                    FAIL = FAIL + 1
--                    ASCIIGFX = ASCIIGFX..'----'
                    break
--                else
--                    ASCIIGFX = ASCIIGFX..'....'
                end
            end
--            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--                AILog(ASCIIGFX)
--            end
        end
    else
        FAIL = MaxFails
    end
--    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--        AIWarn('*CheckValidMarkerPosition East ('..FAIL..') Fails')
--    end
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
--        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--            AILog('*ConnectMarker Terrain Free -> Connecting ('..MarkerIndex..') with ('..EastMarkerIndex..')')
--        end
    else
--        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--            AIWarn('*ConnectMarker Terrain Blocked. Cant connect ('..MarkerIndex..') with ('..EastMarkerIndex..')')
--        end
    end
    ------------------------------------------
    -- Search for a connection to S (South) --
    ------------------------------------------
    FAIL = 0
    local SouthMarkerIndex = 'Marker'..X..'-'..(Y+1)
    if CREATEDMARKERS[SouthMarkerIndex] and CREATEDMARKERS[SouthMarkerIndex].graph ~= 'Blocked' then
        for X = -3, 3, ScanResolution do
--            ASCIIGFX = ''
            for Y = MarkerPos[3], CREATEDMARKERS[SouthMarkerIndex].position[3], ScanResolution do
--                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouth then
--                    DrawLine( {MarkerPos[1] + X, MarkerPos[2], MarkerPos[3]}, { MarkerPos[1] + X, MarkerPos[2], Y}, 'ffFFE0E0' )
--                    coroutine.yield(1)
--                end
                Block = false
                -- Check a square with FootprintSize if it has less then MaxSlope/MaxAngle ((circle 16:20  1:20*16 = 0.8))
                High = GetSurfaceHeight( MarkerPos[1] + X, Y )
                UHigh = High - GetSurfaceHeight( MarkerPos[1] + X, Y-FootprintSize )
                DHigh = High - GetSurfaceHeight( MarkerPos[1] + X, Y+FootprintSize )
                LHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize, Y )
                RHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize, Y )
                LUHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize*0.6, Y-FootprintSize*0.6 )
                RUHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize*0.6, Y-FootprintSize*0.6 )
                LDHigh = High - GetSurfaceHeight( MarkerPos[1] + X-FootprintSize*0.6, Y+FootprintSize*0.6 )
                RDHigh = High - GetSurfaceHeight( MarkerPos[1] + X+FootprintSize*0.6, Y+FootprintSize*0.6 )
--                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouth then
--                    AILog('*ConnectMarker slope  : '..string.format("slope:  %.3f  %.3f  %.3f  %.3f   angle:  %.3f  %.3f  %.3f  %.3f ... %.3f  %.3f  %.3f  %.3f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh), math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
--                end
                if math.abs(UHigh + DHigh) > MaxSlope or math.abs(LHigh + RHigh) > MaxSlope or math.abs(LUHigh + RDHigh) > MaxSlope or math.abs(RUHigh + LDHigh) > MaxSlope then
--                    if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouth then
--                        AIWarn('*ConnectMarker slope  : '..string.format("%.2f %.2f %.2f %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh) ) )
--                    end
                    Block = true
                end
                
                if math.abs(UHigh) > MaxAngle or math.abs(DHigh) > MaxAngle or math.abs(LHigh) > MaxAngle or math.abs(RHigh) > MaxAngle or math.abs(LUHigh) > MaxAngle or math.abs(RUHigh) > MaxAngle or math.abs(LDHigh) > MaxAngle or math.abs(RDHigh) > MaxAngle then
--                    if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouth then
--                        AIWarn('*ConnectMarker angle  : '..string.format("%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f", math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
--                    end
                    Block = true
                end
                if Block == true then
                    FAIL = FAIL + 1
--                    ASCIIGFX = ASCIIGFX..'----'
                    break
--                else
--                    ASCIIGFX = ASCIIGFX..'....'
                end
            end
--            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--                AILog(ASCIIGFX)
--            end
        end
    else
        FAIL = MaxFails
    end
--    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--        AIWarn('*ConnectMarker South ('..FAIL..') Fails. - MaxSlope:'..maxS..' - MaxAngle:'..maxA)
--    end
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
--        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--            AILog('*ConnectMarker Terrain Free -> Connecting ('..MarkerIndex..') with ('..SouthMarkerIndex..')')
--        end
    else
--        if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--            AIWarn('*ConnectMarker Terrain Blocked. Cant connect ('..MarkerIndex..') with ('..SouthMarkerIndex..')')
--        end
    end

    ------------------------------------------------
    -- Search for a connection to SE (South-East) --
    ------------------------------------------------
    FAIL = 0
    local SouthEastMarkerIndex = 'Marker'..(X+1)..'-'..(Y+1)
    if CREATEDMARKERS[SouthEastMarkerIndex] and CREATEDMARKERS[SouthEastMarkerIndex].graph ~= 'Blocked' then
        for X = -3, 3, ScanResolution do
--            ASCIIGFX = ''
            for XY = 0, CREATEDMARKERS[SouthEastMarkerIndex].position[3] - MarkerPos[3] , ScanResolution do
--                if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--                    DrawLine( {MarkerPos[1] + X, MarkerPos[2], MarkerPos[3] - X}, { MarkerPos[1] + X+XY, MarkerPos[2], MarkerPos[3] + XY - X}, 'ffFFE0E0' )
--                    coroutine.yield(1)
--                end
                Block = false
                -- Check a square with FootprintSize if it has less then MaxSlope and MaxAngle
                High = GetSurfaceHeight( MarkerPos[1] + X+XY, MarkerPos[3] + XY-X )
                UHigh = High - GetSurfaceHeight( MarkerPos[1] + X+XY, MarkerPos[3] + XY-X-FootprintSize )
                DHigh = High - GetSurfaceHeight( MarkerPos[1] + X+XY, MarkerPos[3] + XY-X+FootprintSize )
                LHigh = High - GetSurfaceHeight( MarkerPos[1] + X+XY-FootprintSize, MarkerPos[3] + XY-X )
                RHigh = High - GetSurfaceHeight( MarkerPos[1] + X+XY+FootprintSize, MarkerPos[3] + XY-X )
                LUHigh = High - GetSurfaceHeight( MarkerPos[1] + X+XY-FootprintSize*0.8, MarkerPos[3] + XY-X-FootprintSize*0.8 )
                RUHigh = High - GetSurfaceHeight( MarkerPos[1] + X+XY+FootprintSize*0.8, MarkerPos[3] + XY-X-FootprintSize*0.8 )
                LDHigh = High - GetSurfaceHeight( MarkerPos[1] + X+XY-FootprintSize*0.8, MarkerPos[3] + XY-X+FootprintSize*0.8 )
                RDHigh = High - GetSurfaceHeight( MarkerPos[1] + X+XY+FootprintSize*0.8, MarkerPos[3] + XY-X+FootprintSize*0.8 )
--                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthEast then
--                    AILog('*ConnectMarker slope  : '..string.format("slope:  %.3f  %.3f  %.3f  %.3f   angle:  %.3f  %.3f  %.3f  %.3f ... %.3f  %.3f  %.3f  %.3f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh), math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
--                end
                if math.abs(UHigh + DHigh) > MaxSlope or math.abs(LHigh + RHigh) > MaxSlope or math.abs(LUHigh + RDHigh) > MaxSlope or math.abs(RUHigh + LDHigh) > MaxSlope then
--                    if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthEast then
--                       AIWarn('*ConnectMarker slope  : '..string.format("%.2f %.2f %.2f %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh) ) )
--                    end
                    Block = true
                end
                if math.abs(UHigh) > MaxAngle or math.abs(DHigh) > MaxAngle or math.abs(LHigh) > MaxAngle or math.abs(RHigh) > MaxAngle or math.abs(LUHigh) > MaxAngle or math.abs(RUHigh) > MaxAngle or math.abs(LDHigh) > MaxAngle or math.abs(RDHigh) > MaxAngle then
--                    if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthEast then
--                        AIWarn('*ConnectMarker angle  : '..string.format("%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f", math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
--                    end
                    Block = true
                end
                if Block == true then
                    FAIL = FAIL + 1
--                    ASCIIGFX = ASCIIGFX..'----'
                    break
--                else
--                    ASCIIGFX = ASCIIGFX..'....'
                end
            end
--            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--                AILog(ASCIIGFX)
--            end
        end
    else
        FAIL = MaxFails
    end
--    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--       AIWarn('*CheckValidMarkerPosition South-East ('..FAIL..') Fails')
--    end
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
--        if DebugMarker == MarkerIndex then
--            AILog('*ConnectMarker Terrain Free -> Connecting ('..MarkerIndex..') with ('..SouthEastMarkerIndex..')')
--        end
    else
--        if DebugMarker == MarkerIndex then
--            AIWarn('*ConnectMarker Terrain Blocked. Cant connect ('..MarkerIndex..') with ('..SouthEastMarkerIndex..')')
--        end
    end
    ------------------------------------------------
    -- Search for a connection to SW (South-West) --
    ------------------------------------------------
    FAIL = 0
    local SouthWestMarkerIndex = 'Marker'..(X-1)..'-'..(Y+1)
    if CREATEDMARKERS[SouthWestMarkerIndex] and CREATEDMARKERS[SouthWestMarkerIndex].graph ~= 'Blocked' then
        for X = -3, 3, ScanResolution do
--            ASCIIGFX = ''
            for XY = 0, CREATEDMARKERS[SouthWestMarkerIndex].position[3] - MarkerPos[3] , ScanResolution do
--                if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--                    DrawLine( {MarkerPos[1] + X, MarkerPos[2], MarkerPos[3] + X}, { MarkerPos[1] + X-XY, MarkerPos[2], MarkerPos[3] + XY + X}, 'ffFFE0E0' )
--                    coroutine.yield(1)
--                end
                Block = false
                -- Check a square with FootprintSize if it has less then MaxSlope and MaxAngle
                High = GetSurfaceHeight( MarkerPos[1] + X-XY, MarkerPos[3] + XY+X )
                UHigh = High - GetSurfaceHeight( MarkerPos[1] + X-XY, MarkerPos[3] + XY+X-FootprintSize )
                DHigh = High - GetSurfaceHeight( MarkerPos[1] + X-XY, MarkerPos[3] + XY+X+FootprintSize )
                LHigh = High - GetSurfaceHeight( MarkerPos[1] + X-XY-FootprintSize, MarkerPos[3] + XY+X )
                RHigh = High - GetSurfaceHeight( MarkerPos[1] + X-XY+FootprintSize, MarkerPos[3] + XY+X )
                LUHigh = High - GetSurfaceHeight( MarkerPos[1] + X-XY-FootprintSize*0.8, MarkerPos[3] + XY+X-FootprintSize*0.8 )
                RUHigh = High - GetSurfaceHeight( MarkerPos[1] + X-XY+FootprintSize*0.8, MarkerPos[3] + XY+X-FootprintSize*0.8 )
                LDHigh = High - GetSurfaceHeight( MarkerPos[1] + X-XY-FootprintSize*0.8, MarkerPos[3] + XY+X+FootprintSize*0.8 )
                RDHigh = High - GetSurfaceHeight( MarkerPos[1] + X-XY+FootprintSize*0.8, MarkerPos[3] + XY+X+FootprintSize*0.8 )
--                if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthWest then
--                    AILog('*ConnectMarker slope  : '..string.format("slope:  %.3f  %.3f  %.3f  %.3f   angle:  %.3f  %.3f  %.3f  %.3f ... %.3f  %.3f  %.3f  %.3f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh), math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
--                end
                if math.abs(UHigh + DHigh) > MaxSlope or math.abs(LHigh + RHigh) > MaxSlope or math.abs(LUHigh + RDHigh) > MaxSlope or math.abs(RUHigh + LDHigh) > MaxSlope then
--                    if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthWest then
--                        AIWarn('*ConnectMarker slope  : '..string.format("%.2f %.2f %.2f %.2f", math.abs(UHigh - DHigh), math.abs(LHigh - RHigh), math.abs(LUHigh - RDHigh), math.abs(RUHigh - LDHigh) ) )
--                    end
                    Block = true
                end
                if math.abs(UHigh) > MaxAngle or math.abs(DHigh) > MaxAngle or math.abs(LHigh) > MaxAngle or math.abs(RHigh) > MaxAngle or math.abs(LUHigh) > MaxAngle or math.abs(RUHigh) > MaxAngle or math.abs(LDHigh) > MaxAngle or math.abs(RDHigh) > MaxAngle then
--                    if DebugMarker == MarkerIndex and DebugValidMarkerPosition and TraceSouthWest then
--                        AIWarn('*ConnectMarker angle  : '..string.format("%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f", math.abs(UHigh), math.abs(DHigh), math.abs(LHigh), math.abs(RHigh), math.abs(LUHigh), math.abs(RUHigh), math.abs(LDHigh), math.abs(RDHigh) ) )
--                    end
                    Block = true
                end
                if Block == true then
                    FAIL = FAIL + 1
--                    ASCIIGFX = ASCIIGFX..'----'
                    break
--                else
--                    ASCIIGFX = ASCIIGFX..'....'
                end
            end
--            if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--                AILog(ASCIIGFX)
--            end
        end
    else
        FAIL = MaxFails
    end
--    if DebugMarker == MarkerIndex and DebugValidMarkerPosition then
--        AIWarn('*CheckValidMarkerPosition South-West ('..FAIL..') Fails')
--    end
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
--        if DebugMarker == MarkerIndex then
--            AILog('*ConnectMarker Terrain Free -> Connecting ('..MarkerIndex..') with ('..SouthWestMarkerIndex..')')
--        end
    else
--        if DebugMarker == MarkerIndex then
--            AIWarn('*ConnectMarker Terrain Blocked. Cant connect ('..MarkerIndex..') with ('..SouthWestMarkerIndex..')')
--        end
    end

    return
end

function CreateNavalExpansions()
    local StartMarker = {}
    local NavalMarker = {}
    local Blocked
    local markerInfo
    -- Deleting all NavalExpansions markers from MASTERCHAIN
    for nodename, markerInfo in Scenario.MasterChain._MASTERCHAIN_.Markers or {} do
        if markerInfo['type'] == 'Naval Area' then
            Scenario.MasterChain._MASTERCHAIN_.Markers[nodename] = nil
        end
    end
    local adjancents
    local dist
    -- Search for naval areas
    for Y = 0, MarkerCountY - 1 do
        for X = 0, MarkerCountX - 1 do
            markerInfo = Scenario.MasterChain._MASTERCHAIN_.Markers['Water'..X..'-'..Y]
            if not markerInfo then
                continue
            end
            Blocked = false
            -- check if we are in the middle of water nodes 3x3 grid
            for YW = -1, 1 do
                for XW = -1, 1 do
                    if not Scenario.MasterChain._MASTERCHAIN_.Markers['Water'..X+XW..'-'..Y+YW] then
                        Blocked = true
                        break
                    end
                end
            end
            if Blocked then
                continue
            end
            Blocked = true
            -- check if we are sourrounded with land nodes (transition water/land) 5x5 grid
            for YD = -2, 2 do
                for XD = -2, 2 do
                    if (YD == -2 or YD == 2) or (XD == -2 or XD == 2) then
                        if Scenario.MasterChain._MASTERCHAIN_.Markers['Land'..(X+XD)..'-'..(Y+YD)] then
                            -- check if we have an amphibious way from his land node to water
                            adjancents = STR_GetTokens(Scenario.MasterChain._MASTERCHAIN_.Markers['Amphibious'..(X+XD)..'-'..(Y+YD)].adjacentTo or '', ' ')
                            if adjancents[0] then
                                for i, node in adjancents do
                                    -- checking node, if it has a conection to our naval marker
                                    for YA = -1, 1 do
                                        for XA = -1, 1 do
                                            if node == 'Amphibious'..(X+XA)..'-'..(Y+YA) then
                                                Blocked = false
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if Blocked then
                continue
            end
            -- check if we have a naval marker close to this area
            for index, NAVALpostition in NavalMarker do
                dist = VDist2( markerInfo['position'][1], markerInfo['position'][3], NAVALpostition[1], NAVALpostition[3])
                -- is this marker farther away than 60
                if dist < 60 then
                    Blocked = true
                    break
                end
            end
            if not Blocked then
                table.insert(NavalMarker, markerInfo['position'])
            end
        end
    end

    -- creating real naval Marker
    for index, NAVALpostition in NavalMarker do
        -- add data for a real marker
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index] = {}
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].color = MarkerDefaults["Water Path Node"]['color']
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].hint = true
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].orientation = { 0, 0, 0 }
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].prop = "/env/common/props/markers/M_Expansion_prop.bp"
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].type = "Naval Area"
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].position = NAVALpostition
    end
end

function CreateLandExpansions()
    local MassMarker = {}
    local MexInMarkerRange = {}
    local StartPosition = {}
    local NewExpansion = {}
    local AlreadyUsed = {}
    -- get player start positions
    for nodename, markerInfo in Scenario.MasterChain._MASTERCHAIN_.Markers or {} do
        if markerInfo['type'] == 'Blank Marker' then
            table.insert(StartPosition, {Position = markerInfo.position} )
        end
    end
    -- deleting all (Large-) Expansion markers from MASTERCHAIN
    for nodename, markerInfo in Scenario.MasterChain._MASTERCHAIN_.Markers or {} do
        if markerInfo['type'] == 'Expansion Area' or markerInfo['type'] == 'Large Expansion Area' then
            Scenario.MasterChain._MASTERCHAIN_.Markers[nodename] = nil
        end
    end
    -- get all mass spots
    for _, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
        if v.type == 'Mass' then
            if v.position[1] <= 8 or v.position[1] >= ScenarioInfo.size[1] - 8 or v.position[3] <= 8 or v.position[3] >= ScenarioInfo.size[2] - 8 then
                -- mass marker is too close to border, skip it.
                continue
            end
            table.insert(MassMarker, {Position = v.position})
        end
    end
    -- search for areas with mex in range
    local MarkerPosition
    for Y = 0, MarkerCountY - 1 do
        for X = 0, MarkerCountX - 1 do
            if Scenario.MasterChain._MASTERCHAIN_.Markers['Land'..X..'-'..Y] then
                MarkerPosition = Scenario.MasterChain._MASTERCHAIN_.Markers['Land'..X..'-'..Y].position
                -- check how many masspoints are located near the marker
                for k, v in MassMarker do
                    if VDist2(MarkerPosition[1], MarkerPosition[3], v.Position[1], v.Position[3]) > 30 then
                        continue
                    end
                    MexInMarkerRange['Land'..X..'-'..Y] = MexInMarkerRange['Land'..X..'-'..Y] or {}
                    table.insert(MexInMarkerRange['Land'..X..'-'..Y], {Position = v.Position} )
                    -- insert mexcount into table
                    MexInMarkerRange['Land'..X..'-'..Y].mexcount = table.getn(MexInMarkerRange['Land'..X..'-'..Y])
                end

            end
        end
    end
    -- build IndexTable with number as index
    local IndexTable = {}
    local count = 0
    for _, array in MexInMarkerRange do
        if array.mexcount > 1 then
            IndexTable[count+1] = array
            count = count +1
        end
    end
    -- bubblesort IndexTable
    local Sorting
    repeat
        Sorting = false
        count = count - 1
        for i = 1, count do
            if IndexTable[i].mexcount < IndexTable[i + 1].mexcount then
                IndexTable[i], IndexTable[i + 1] = IndexTable[i + 1], IndexTable[i]
                Sorting = true
            end
        end
    until Sorting == false
    -- remove mexes that are already assigned to another expansion
    for k, v in IndexTable do
        if type(v) == 'table' then
            for k2, v2 in v do
                if type(v2) == 'table' then
                    if not AlreadyUsed[v2.Position] then
                        AlreadyUsed[v2.Position] = true
                        continue
                    end
                    -- delete this marker, its already part of another expansion
                    v[k2] = nil
                    v.mexcount = v.mexcount - 1
                    -- if we have only 1 mex left, then this is no longer a possible expansion
                    if v.mexcount < 2 then
                        IndexTable[k] = nil
                    end
                end
            end
        end
    end
    -- Search for the center location of all mexes inside an expansion
    for k, v in IndexTable do
        local posCount = 0
        local x = 0
        local y = 0
        if type(v) == 'table' then
            for k2, v2 in v do
                if type(v2) == 'table' then
                    posCount = posCount + 1
                    x = x + v[k2].Position[1]
                    y = y + v[k2].Position[3]
                end
            end
            IndexTable[k].x = x / posCount
            IndexTable[k].y = y / posCount
        end
    end
    -- search for possible expansion areas
    for k, v in IndexTable do
        local MexInRange = v.mexcount
        local UseThisMarker = true
        -- Search if we are near a start position
        for ks, vs in StartPosition do
            if VDist2(v.x, v.y, vs.Position[1], vs.Position[3]) < 60 then
                -- we are to close to a start position, don't use it as expansion
                UseThisMarker = false
            end
        end
        -- check if we are to close to an expansion
        for ks, vn in NewExpansion do
            if VDist2(v.x, v.y, vn.x, vn.y) < 50 then
                -- we are to close to another expansion, don't use it
                UseThisMarker = false
            end
        end
        -- save the expansion position
        if UseThisMarker then
            table.insert(NewExpansion, {x = v.x, y = v.y, MexInRange = v.mexcount} )
        end
    end
    -- creating real expasnion Marker
    for index, Expansion in NewExpansion do
        -- large expansions should have more than 3 mexes
        if Expansion.MexInRange > 3 then
            -- add data for a large expansion
            Scenario.MasterChain._MASTERCHAIN_.Markers['Large Expansion Area '..index] = {}
            Scenario.MasterChain._MASTERCHAIN_.Markers['Large Expansion Area '..index].color = MarkerDefaults["Land Path Node"]['color']
            Scenario.MasterChain._MASTERCHAIN_.Markers['Large Expansion Area '..index].hint = true
            Scenario.MasterChain._MASTERCHAIN_.Markers['Large Expansion Area '..index].orientation = { 0, 0, 0 }
            Scenario.MasterChain._MASTERCHAIN_.Markers['Large Expansion Area '..index].prop = "/env/common/props/markers/M_Expansion_prop.bp"
            Scenario.MasterChain._MASTERCHAIN_.Markers['Large Expansion Area '..index].type = "Large Expansion Area"
            Scenario.MasterChain._MASTERCHAIN_.Markers['Large Expansion Area '..index].position = {Expansion.x, GetTerrainHeight(Expansion.x, Expansion.y), Expansion.y}
        -- normal expansions should have 2-3 mexes
        elseif Expansion.MexInRange > 1 then
            -- add data for a normal expansion
            Scenario.MasterChain._MASTERCHAIN_.Markers['Expansion Area '..index] = {}
            Scenario.MasterChain._MASTERCHAIN_.Markers['Expansion Area '..index].color = MarkerDefaults["Land Path Node"]['color']
            Scenario.MasterChain._MASTERCHAIN_.Markers['Expansion Area '..index].hint = true
            Scenario.MasterChain._MASTERCHAIN_.Markers['Expansion Area '..index].orientation = { 0, 0, 0 }
            Scenario.MasterChain._MASTERCHAIN_.Markers['Expansion Area '..index].prop = "/env/common/props/markers/M_Expansion_prop.bp"
            Scenario.MasterChain._MASTERCHAIN_.Markers['Expansion Area '..index].type = "Expansion Area"
            Scenario.MasterChain._MASTERCHAIN_.Markers['Expansion Area '..index].position = {Expansion.x, GetTerrainHeight(Expansion.x, Expansion.y), Expansion.y}
        end
    end
end

function CreateMassCount()
    local Expansions = {}
    local MassMarker = {}
    -- get player start positions
    for nodename, markerInfo in Scenario.MasterChain._MASTERCHAIN_.Markers or {} do
        if markerInfo['type'] == 'Blank Marker' or markerInfo['type'] == 'Expansion Area' or markerInfo['type'] == 'Large Expansion Area' then
            table.insert(Expansions, {Name = nodename , Position = markerInfo.position} )
        end
    end
    -- get all mass spots
    for _, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
        if v.type == 'Mass' then
            if v.position[1] <= 8 or v.position[1] >= ScenarioInfo.size[1] - 8 or v.position[3] <= 8 or v.position[3] >= ScenarioInfo.size[2] - 8 then
                -- mass marker is too close to border, skip it.
                continue
            end
            table.insert(MassMarker, {Position = v.position})
        end
    end
    -- search for areas with mex in range
    for k, v in Expansions do
        -- check how many masspoints are located near the marker
        local masscount = 0
        for k2, v2 in MassMarker do
            if VDist2(v.Position[1], v.Position[3], v2.Position[1], v2.Position[3]) > 30 then
                continue
            end
            masscount = masscount + 1
        end        
        -- insert mexcount into marker
        Scenario.MasterChain._MASTERCHAIN_.Markers[v.Name].MassSpotsInRange = masscount
        AIDebug('* AI-Uveso: CreateMassCount: Node: '..v.Name..' - MassSpotsInRange: '..Scenario.MasterChain._MASTERCHAIN_.Markers[v.Name].MassSpotsInRange, true, UvesoOffsetSimInitLUA)
    end
end

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
                AIWarn('Missing value in marker '..k..' -> '..repr(v))
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

function BuildGraphAreas()
    local GraphIndex = {
        ['Land Path Node'] = 0,
        ['Water Path Node'] = 0,
        ['Amphibious Path Node'] = 0,
        ['Air Path Node'] = 0,
    }
    local old
    local adjancents
    for k, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
        -- only check waypoint markers
        if MarkerDefaults[v.type] then
            -- Do we have already an Index number for this Graph area ?
            if not v.GraphArea then
                GraphIndex[v.type] = GraphIndex[v.type] + 1
                Scenario.MasterChain._MASTERCHAIN_.Markers[k].GraphArea = GraphIndex[v.type]
                --AILog('*BuildGraphAreas: Marker '..k..' has no Graph index, set it to '..GraphArea[v.type])
            end
            -- check adjancents
            if v.adjacentTo then
                adjancents = STR_GetTokens(v.adjacentTo or '', ' ')
                if adjancents[0] then
                    for i, node in adjancents do
                        -- check if the new node has not a GraphIndex 
                        if not Scenario.MasterChain._MASTERCHAIN_.Markers[node].GraphArea then
                            --AILog('*BuildGraphAreas: adjacentTo '..node..' has no Graph index, set it to '..Scenario.MasterChain._MASTERCHAIN_.Markers[k].GraphArea)
                            Scenario.MasterChain._MASTERCHAIN_.Markers[node].GraphArea = Scenario.MasterChain._MASTERCHAIN_.Markers[k].GraphArea
                        -- the node has already a graph index. Overwrite all nodes connected to this node with the new index
                        elseif Scenario.MasterChain._MASTERCHAIN_.Markers[node].GraphArea ~= Scenario.MasterChain._MASTERCHAIN_.Markers[k].GraphArea then
                            -- save the old index here, we will overwrite Markers[node].GraphArea
                            old = Scenario.MasterChain._MASTERCHAIN_.Markers[node].GraphArea
                            --AILog('*BuildGraphAreas: adjacentTo '..node..' has Graph index '..old..' overwriting it with '..Scenario.MasterChain._MASTERCHAIN_.Markers[k].GraphArea)
                            for k2, v2 in Scenario.MasterChain._MASTERCHAIN_.Markers do
                                -- Has the adjacent the same type than the marker
                                if v.type == v2.type then
                                    -- has this node the same index then our main marker ?
                                    if Scenario.MasterChain._MASTERCHAIN_.Markers[k2].GraphArea == old then
                                        --AILog('*BuildGraphAreas: adjacentTo '..k2..' has Graph index '..old..' overwriting it with '..Scenario.MasterChain._MASTERCHAIN_.Markers[k].GraphArea)
                                        Scenario.MasterChain._MASTERCHAIN_.Markers[k2].GraphArea = Scenario.MasterChain._MASTERCHAIN_.Markers[k].GraphArea
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- make propper Area names and IDs
    for k, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
        if v.GraphArea then
            -- We can't just copy it into .graph without breaking stuff, so we use .GraphArea instead
--            Scenario.MasterChain._MASTERCHAIN_.Markers[k].graph = MarkerDefaults[v.type].area..'_'..v.GraphArea
            Scenario.MasterChain._MASTERCHAIN_.Markers[k].GraphArea = MarkerDefaults[v.type].area..'_'..v.GraphArea
        end
    end

    -- Validate (only for debug printing)
    local GraphCountIndex = {
        ['Land Path Node'] = {},
        ['Water Path Node'] = {},
        ['Amphibious Path Node'] = {},
        ['Air Path Node'] = {},
    }
    for k, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
        if v.GraphArea then
            GraphCountIndex[v.type][v.GraphArea] = GraphCountIndex[v.type][v.GraphArea] or 1
            GraphCountIndex[v.type][v.GraphArea] = GraphCountIndex[v.type][v.GraphArea] + 1
        end
    end
    AIDebug('* AI-Uveso: BuildGraphAreas(): '..repr(GraphCountIndex), true, UvesoOffsetSimInitLUA)
end

function DrawHeatMap()
    coroutine.yield(10)
    local GetHeatMapGridPositionFromIndex = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetHeatMapGridPositionFromIndex
    local HeatMapGridSizeX, HeatMapGridSizeZ = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetHeatMapGridSizeXZ()
    local PlayableMapSizeX, PlayableMapSizeZ = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetPlayableMapSizeXZ()
    local mapXGridCount = math.floor( PlayableMapSizeX / HeatMapGridSizeX )
    local mapYGridCount = math.floor( PlayableMapSizeZ / HeatMapGridSizeZ )
    local playableArea = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetPlayableArea()
    local OffsetX = playableArea[1]
    local OffsetZ = playableArea[2]
    local px, py, pz = 0,1000,0
    local threatScale = { Land = 1, Air = 1, Water = 1, Amphibious = 1, ecoValue = 1}
    local highestThreat = { Land = 1, Air = 1, Water = 1, Amphibious = 1, Mass = 1}
    local FocussedArmy
    local heatMap
    local enemyMainForce
    local pr = {}
    while true do
        coroutine.yield(2)
        FocussedArmy = GetFocusArmy()
        if FocussedArmy > 0 then
            heatMap = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetHeatMapForArmy(FocussedArmy)
            if not heatMap then 
                continue 
            end


            -- draw debug
            for x = 0, mapXGridCount - 1 do
                for z = 0, mapYGridCount - 1 do
                    GridCenterPos = GetHeatMapGridPositionFromIndex(x, z)
                    px = GridCenterPos[1]
                    pz = GridCenterPos[3]
--                    if py > GetTerrainHeight( px, pz ) then
                        py = GetTerrainHeight( px, pz )
--                    end
                    -- draw heatmap box
                    DrawLine({px-HeatMapGridSizeX/2, py, pz-HeatMapGridSizeZ/2}, {px+HeatMapGridSizeX/2, py, pz-HeatMapGridSizeZ/2}, 'ff707070') -- U
--                    DrawLine({px-HeatMapGridSizeX/2, py, pz+HeatMapGridSizeZ/2}, {px+HeatMapGridSizeX/2, py, pz+HeatMapGridSizeZ/2}, 'ff707070') -- D
                    DrawLine({px-HeatMapGridSizeX/2, py, pz-HeatMapGridSizeZ/2}, {px-HeatMapGridSizeX/2, py, pz+HeatMapGridSizeZ/2}, 'ff707070') -- L
--                    DrawLine({px+HeatMapGridSizeX/2, py, pz-HeatMapGridSizeZ/2}, {px+HeatMapGridSizeX/2, py, pz+HeatMapGridSizeZ/2}, 'ff707070') -- R


                    -- ****
                    -- LAND
                    -- ****
                    -- draw threatRings
                    pr["Land"] = heatMap[x][z].threatRing["Land"] * threatScale["Land"]
                    DrawCircle( { px, py, pz }, pr["Land"] , '80f4a460' )
                    -- get the highest value to scale all circles
                    if heatMap[x][z].threatRing["Land"] > highestThreat["Land"] then
                        highestThreat["Land"] = heatMap[x][z].threatRing["Land"]
                    end
                    -- draw box with highest threats
                    for _, threats in pairs(ArmyBrains[FocussedArmy].highestEnemyThreat["Land"]) do
                        if threats.gridPos[1] == x and threats.gridPos[2] == z then
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, 'fff4a460') -- U
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'fff4a460') -- D
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, { 2 + px-HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'fff4a460') -- L
                            DrawLine({-2 + px+HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'fff4a460') -- R
                        end
                    end
--[[
                    -- ****
                    -- AIR
                    -- ****
                    -- draw threatRings
                    pr["Air"] = heatMap[x][z].threatRing["Air"] * threatScale["Air"]
                    DrawCircle( { px, py, pz }, pr["Air"] , '80FFFFFF' )
                    -- get the highest value to scale all circles
                    if heatMap[x][z].threatRing["Air"] > highestThreat["Air"] then
                        highestThreat["Air"] = heatMap[x][z].threatRing["Air"]
                    end
                    -- draw box with highest threats
                    for _, threats in pairs(ArmyBrains[FocussedArmy].highestEnemyThreat["Air"]) do
                        if threats.gridPos[1] == x and threats.gridPos[2] == z then
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, 'ffFFFFFF') -- U
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'ffFFFFFF') -- D
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, { 2 + px-HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'ffFFFFFF') -- L
                            DrawLine({-2 + px+HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'ffFFFFFF') -- R
                        end
                    end
                    -- ****
                    -- WATER
                    -- ****
                    -- draw threatRings
                    pr["Water"] = heatMap[x][z].threatRing["Water"] * threatScale["Water"]
                    DrawCircle( { px, py, pz }, pr["Water"] , '8027408b' )
                    -- get the highest value to scale all circles
                    if heatMap[x][z].threatRing["Water"] > highestThreat["Water"] then
                        highestThreat["Water"] = heatMap[x][z].threatRing["Water"]
                    end
                    -- draw box with highest threats
                    for _, threats in pairs(ArmyBrains[FocussedArmy].highestEnemyThreat["Water"]) do
                        if threats.gridPos[1] == x and threats.gridPos[2] == z then
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, 'ff27408b') -- U
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'ff27408b') -- D
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, { 2 + px-HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'ff27408b') -- L
                            DrawLine({-2 + px+HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'ff27408b') -- R
                        end
                    end
                    -- ****
                    -- AMPHIBIOUS
                    -- ****
                    -- draw threatRings
                    pr["Amphibious"] = heatMap[x][z].threatRing["Amphibious"] * threatScale["Amphibious"]
                    DrawCircle( { px, py, pz }, pr["Amphibious"] , '801e90ff' )
                    -- get the highest value to scale all circles
                    if heatMap[x][z].threatRing["Amphibious"] > highestThreat["Amphibious"] then
                        highestThreat["Amphibious"] = heatMap[x][z].threatRing["Amphibious"]
                    end
                    -- draw box with highest threats
                    for _, threats in pairs(ArmyBrains[FocussedArmy].highestEnemyThreat["Amphibious"]) do
                        if threats.gridPos[1] == x and threats.gridPos[2] == z then
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, 'ff1e90ff') -- U
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'ff1e90ff') -- D
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, { 2 + px-HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'ff1e90ff') -- L
                            DrawLine({-2 + px+HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'ff1e90ff') -- R
                        end
                    end
--]]

                    -- ****
                    -- ECO
                    -- ****
                    -- draw ecoValue
                    pr["ecoValue"] = heatMap[x][z].highestEnemyEcoValue["All"] * threatScale["ecoValue"]
                    DrawCircle( { px, py, pz }, pr["ecoValue"] , '80FFFFFF' )
                    -- get the highest value to scale all circles
                    if heatMap[x][z].highestEnemyEcoValue["All"] > highestThreat["ecoValue"] then
                        highestThreat["ecoValue"] = heatMap[x][z].highestEnemyEcoValue["All"]
                    end
                    -- draw box with highest ecoValue
                    for _, ecoValue in pairs(ArmyBrains[FocussedArmy].highestEnemyEcoValue["All"]) do
                        if ecoValue.gridPos[1] == x and ecoValue.gridPos[2] == z then
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, 'ffFFFFFF') -- U
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'ffFFFFFF') -- D
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, { 2 + px-HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'ffFFFFFF') -- L
                            DrawLine({-2 + px+HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'ffFFFFFF') -- R
                        end
                    end

                end
            end
            threatScale["Land"] = (math.min( HeatMapGridSizeX, HeatMapGridSizeZ ) - 1) / 2 / highestThreat["Land"]
            threatScale["Air"] = (math.min( HeatMapGridSizeX, HeatMapGridSizeZ ) - 1) / 2 / highestThreat["Air"]
            threatScale["Water"] = (math.min( HeatMapGridSizeX, HeatMapGridSizeZ ) - 1) / 2 / highestThreat["Water"]
            threatScale["Amphibious"] = (math.min( HeatMapGridSizeX, HeatMapGridSizeZ ) - 1) / 2 / highestThreat["Amphibious"]
            threatScale["ecoValue"] = (math.min( HeatMapGridSizeX, HeatMapGridSizeZ ) - 1) / 2 / highestThreat["ecoValue"]
            highestThreat["Land"] = 0
            highestThreat["Air"] = 0
            highestThreat["Water"] = 0
            highestThreat["Amphibious"] = 0
            highestThreat["ecoValue"] = 0
        end -- if FocussedArmy > 0 then
    end
end

function ValidateModFilesUveso()
    local ModName = 'AI-Uveso'
    local Files = 87
    local Bytes = 2032736
    local modlocation = ""
    for i, mod in __active_mods do
        if mod.name == ModName then
            AILog('* '..ModName..': Mod "'..ModName..'" version ('..mod.version..') is active.', true, UvesoOffsetSimInitLUA)
            modlocation = mod.location
        end
    end
    AILog('* '..ModName..': Running from: '..debug.getinfo(1).source..'.', true, UvesoOffsetSimInitLUA)
    AILog('* '..ModName..': Checking directory /mods/ for "'..ModName..'"...', true, UvesoOffsetSimInitLUA)
    local FilesInFolder = DiskFindFiles('/mods/', '*.*')
    local modfoundcount = 0
    local modfilepath = ""
    for _, FilepathAndName in FilesInFolder do
        -- FilepathAndName = /mods/ai-uveso/mod_info.lua
        if string.find(FilepathAndName, 'mod_info.lua') then
            if string.gsub(FilepathAndName, ".*/(.*)/.*", "%1") == string.lower(ModName) then
                modfilepath = string.gsub(FilepathAndName, "(.*/.*)/.*", "%1")
                modfoundcount = modfoundcount + 1
                if modlocation == modfilepath then
                    AILog('* '..ModName..': Found mod in correct directory: '..FilepathAndName..'.', true, UvesoOffsetSimInitLUA)
                else
                    AILog('* '..ModName..': Found mod in wrong directory: '..FilepathAndName..'.', true, UvesoOffsetSimInitLUA)
                end
            end
        end
    end
    if modfoundcount == 1 then
        AILog('* '..ModName..': Check OK. Found '..modfoundcount..' "'..ModName..'" directory.', true, UvesoOffsetSimInitLUA)
    else
        AILog('* '..ModName..': Check FAILED! Found '..modfoundcount..' "'..ModName..'" directories.', true, UvesoOffsetSimInitLUA)
    end
    AILog('* '..ModName..': Checking files and filesize for "'..ModName..'"...', true, UvesoOffsetSimInitLUA)
    local FilesInFolder = DiskFindFiles('/mods/'..ModName..'/', '*.*')
    local filecount = 0
    local bytecount = 0
    local fileinfo
    for _, FilepathAndName in FilesInFolder do
        if not string.find(FilepathAndName, '.git') then
            filecount = filecount + 1
            fileinfo = DiskGetFileInfo(FilepathAndName)
            bytecount = bytecount + fileinfo.SizeBytes
        end
    end
    local FAIL = false
    if filecount < Files then
        AILog('* '..ModName..': Check FAILED! Directory: "'..ModName..'" - Missing '..(Files - filecount)..' files! ('..filecount..'/'..Files..')', true, UvesoOffsetSimInitLUA)
        FAIL = true
    elseif filecount > Files then
        AILog('* '..ModName..': Check FAILED! Directory: "'..ModName..'" - Found '..(filecount - Files)..' odd files! ('..filecount..'/'..Files..')', true, UvesoOffsetSimInitLUA)
        FAIL = true
    end
    if bytecount < Bytes then
        AILog('* '..ModName..': Check FAILED! Directory: "'..ModName..'" - Missing '..(Bytes - bytecount)..' bytes! ('..bytecount..'/'..Bytes..')', true, UvesoOffsetSimInitLUA)
        FAIL = true
    elseif bytecount > Bytes then
        AILog('* '..ModName..': Check FAILED! Directory: "'..ModName..'" - Found '..(bytecount - Bytes)..' odd bytes! ('..bytecount..'/'..Bytes..')', true, UvesoOffsetSimInitLUA)
        FAIL = true
    end
    if not FAIL then
        AILog('* '..ModName..': Check OK! files: '..filecount..', bytecount: '..bytecount..'.', true, UvesoOffsetSimInitLUA)
    end
end
