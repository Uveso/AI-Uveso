local UvesoOffsetSimInitLUA = debug.getinfo(1).currentline - 1
SPEW('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..UvesoOffsetSimInitLUA..'] * AI-Uveso: offset simInit.lua')
--556

local FormatGameTimeSeconds = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua').FormatGameTimeSeconds

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

-- This function can be called from all SIM state lua files
function AILog(data, bool, offset)
    if bool == false then return end
    -- visual indicator for offset line numbers - 1234 = normal line number, ^1234 linenumber with offset
    if not offset then offset = 0 end
    if offset > 0 then off = "^" else off = "" end
    -- print to the debuglog filename and linenumber from this log call
    local text = FormatGameTimeSeconds(GetGameTimeSeconds()).." ["..string.gsub(debug.getinfo(2).source, ".*\\(.*.lua)", "%1")..":"..off..(debug.getinfo(2).currentline - offset).."] "
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

-- This function can be called from all SIM state lua files
function AIDebug(data, bool, offset)
    if bool == false then return end
    -- visual indicator for offset line numbers - 1234 = normal line number, ^1234 linenumber with offset
    if not offset then offset = 0 end
    if offset > 0 then off = "^" else off = "" end
    -- print to the debuglog filename and linenumber from this log call
    SPEW( FormatGameTimeSeconds(GetGameTimeSeconds()).." ["..string.gsub(debug.getinfo(2).source, ".*\\(.*.lua)", "%1")..":"..off..(debug.getinfo(2).currentline - offset).."] "..data)
end

-- This function can be called from all SIM state lua files
function AIWarn(data, bool, offset)
    if bool == false then return end
    -- visual indicator for offset line numbers - 1234 = normal line number, ^1234 linenumber with offset
    if not offset then offset = 0 end
    if offset > 0 then off = "^" else off = "" end
    -- print to the debuglog filename and linenumber from this log call
    WARN( FormatGameTimeSeconds(GetGameTimeSeconds()).." ["..string.gsub(debug.getinfo(2).source, ".*\\(.*.lua)", "%1")..":"..off..(debug.getinfo(2).currentline - offset).."] "..data)
end

-- hooks for map validation on game start and debugstuff for pathfinding and base ranger.
local CREATEDMARKERS = {}

local OldBeginSessionUveso = BeginSession
function BeginSession()
    OldBeginSessionUveso()

    ValidateModFilesUveso()
    -- init data for target manager
    local WantedGridCellSize = math.floor( math.max( ScenarioInfo.size[1], ScenarioInfo.size[2] ) / 36)
    import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').InitAITargetManagerData(WantedGridCellSize)

    if ScenarioInfo.Options.AIPathingDebug ~= 'off' then
        -- import functions for marker generator
        local AIMarkerGenerator = import('/mods/AI-Uveso/lua/AI/AIMarkerGenerator.lua')
        -- draw the marker graphs
        ForkThread(AIMarkerGenerator.GraphRenderThread)
    end

    -- Fist calculate markers, then continue with the game start sequence.
    AILog('* AI-Uveso: Function CreateAIMarkers() started!', true, UvesoOffsetSimInitLUA)
    CreateAIMarkers()

    ValidateMapAndMarkers()

    -- Debug ACUChampion platoon function
--    ForkThread(DrawACUChampion)
    -- Debug HeatMap
--    ForkThread(DrawHeatMap)
    -- Debug Units
--    ForkThread(UnitDebugThread)
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
    ['Hover Path Node']=true,
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

local MarkerDefaults = {
    ['Land Path Node']          = { ['graph'] ='DefaultLand',       ['color'] = 'fff4a460', ['area'] = 'LandArea', },
    ['Water Path Node']         = { ['graph'] ='DefaultWater',      ['color'] = 'ff27408b', ['area'] = 'WaterArea', },
    ['Amphibious Path Node']    = { ['graph'] ='DefaultAmphibious', ['color'] = 'ff1e90ff', ['area'] = 'AmphibiousArea', },
    ['Hover Path Node']         = { ['graph'] ='DefaultHover',      ['color'] = 'ff2760ab', ['area'] = 'HoverArea', },
    ['Air Path Node']           = { ['graph'] ='DefaultAir',        ['color'] = 'ffffffff', ['area'] = 'AirArea', },
}

function UnitDebugThread()
    local waterDepth
    local x, y, z
    local FocussedArmy = GetFocusArmy()
    while true do
        coroutine.yield(10)
        if GetFocusArmy() > 0 then
            -- using this in multiplayer can cause desyncs!!!
            aiBrain = ArmyBrains[GetFocusArmy()]
            ArmyUnits = aiBrain:GetListOfUnits(categories.MOBILE, false, false) -- also gets unbuilded units (planed to build)
            for _, unit in ArmyUnits do
                if unit.Dead then
                    continue
                end
                x, y, z = unit:GetPositionXYZ()
                waterDepth = GetTerrainHeight(x, z) - GetSurfaceHeight(x, z)
                unit:SetCustomName('waterDepth: '..waterDepth)
            end
        end
    end
end

function ValidateMapAndMarkers()
    -- Check norushradius
    if ScenarioInfo.norushradius and ScenarioInfo.norushradius > 0 then
        if ScenarioInfo.norushradius < 10 then
            AIWarn('* AI-Uveso: ValidateMapAndMarkers: norushradius is too smal ('..ScenarioInfo.norushradius..')! Set radius to minimum (15).', true, UvesoOffsetSimInitLUA)
            ScenarioInfo.norushradius = 15
        else
            AILog('* AI-Uveso: ValidateMapAndMarkers: norushradius is OK. ('..ScenarioInfo.norushradius..')', true, UvesoOffsetSimInitLUA)
        end
    else
        AIWarn('* AI-Uveso: ValidateMapAndMarkers: norushradius is missing! Set radius to default (20).', true, UvesoOffsetSimInitLUA)
        ScenarioInfo.norushradius = 20
    end

    -- Check map markers
    local playableArea = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetPlayableArea()
    local TEMP = {}
    local UNKNOWNMARKER = {}
    local dist
    local adjancents
    for k, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
        -- Check if the marker is known. If not, send a debug message
        if not KnownMarkerTypes[v.type] then
            if not UNKNOWNMARKER[v.type] then
                AIWarn('* AI-Uveso: ValidateMapAndMarkers: Unknown MarkerType: [\''..v.type..'\']=true,', true, UvesoOffsetSimInitLUA)
                UNKNOWNMARKER[v.type] = true
            end
        end
        -- Check Index Name
        if v.type == 'Naval Area' then
            if string.find(k, 'NavalArea') then
                AIWarn('* AI-Uveso: ValidateMapAndMarkers: MarkerType: [\''..v.type..'\'] Has wrong Index Name ['..k..']. (Should be [Naval Area xx] )', true, UvesoOffsetSimInitLUA)
            elseif not string.find(k, 'Naval Area') then
                AIWarn('* AI-Uveso: ValidateMapAndMarkers: MarkerType: [\''..v.type..'\'] Has wrong Index Name ['..k..']. (Should be [Naval Area xx] )', true, UvesoOffsetSimInitLUA)
            end
        end
        if v.type == 'Expansion Area' then
            if string.find(k, 'ExpansionArea') then
                AIWarn('* AI-Uveso: ValidateMapAndMarkers: MarkerType: [\''..v.type..'\'] Has wrong Index Name ['..k..']. (Should be [Expansion Area xx] )', true, UvesoOffsetSimInitLUA)
            elseif not string.find(k, 'Expansion Area') then
                AIWarn('* AI-Uveso: ValidateMapAndMarkers: MarkerType: [\''..v.type..'\'] Has wrong Index Name ['..k..']. (Should be [Expansion Area xx] )', true, UvesoOffsetSimInitLUA)
            end
        end
        if v.type == 'Large Expansion' then
            if string.find(k, 'LargeExpansion') then
                AIWarn('* AI-Uveso: ValidateMapAndMarkers: MarkerType: [\''..v.type..'\'] Has wrong Index Name ['..k..']. (Should be [Large Expansion xx] )', true, UvesoOffsetSimInitLUA)
            elseif not string.find(k, 'Large Expansion') then
                AIWarn('* AI-Uveso: ValidateMapAndMarkers: MarkerType: [\''..v.type..'\'] Has wrong Index Name ['..k..']. (Should be [Large Expansion xx] )', true, UvesoOffsetSimInitLUA)
            end
        end
        --'ARMY_'

        -- Check Mass Marker
        if v.type == 'Mass' then
            if v.position[1] <= playableArea[1] + 8 or v.position[1] >= playableArea[3] - 8 or v.position[3] <= playableArea[2] + 8 or v.position[3] >= playableArea[4] - 8 then
                AIWarn('* AI-Uveso: ValidateMapAndMarkers: MarkerType: [\''..v.type..'\'] is too close to map border. IndexName = ['..k..']. (Mass marker deleted!!!)', true, UvesoOffsetSimInitLUA)
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
                            AIWarn('* AI-Uveso: ValidateMapAndMarkers: adjacentTo is wrong in marker ['..k..'] - MarkerType: [\''..v.type..'\']. - Adjacent marker ['..node..'] is missing.', true, UvesoOffsetSimInitLUA)
                        end
                    end
                end
            end
        -- Check BaseLocations distances to other locations
        elseif BaseLocations[v.type] then
            for k2, v2 in Scenario.MasterChain._MASTERCHAIN_.Markers do
                if BaseLocations[v2.type] and v ~= v2 then
                    dist = VDist2( v.position[1], v.position[3], v2.position[1], v2.position[3] )
                    -- Are we checking a Start location, and another marker is nearer then 80 units ?
                    if v.type == 'Blank Marker' and v2.type ~= 'Blank Marker' and dist < 80 then
                        AIDebug('* AI-Uveso: ValidateMapAndMarkers: Marker [\''..k2..'\'] is to close to Start Location [\''..k..'\']. Distance= '..math.floor(dist)..' (under 80).', true, UvesoOffsetSimInitLUA)
                        --Scenario.MasterChain._MASTERCHAIN_.Markers[k2] = nil
                    -- Check if we have other locations that have a low distance (under 60)
                    elseif v.type ~= 'Blank Marker' and v2.type ~= 'Blank Marker' and dist < 60 then
                        -- Check priority from small locations up to main base.
                        if BaseLocations[v.type].priority >= BaseLocations[v2.type].priority then
                            AIDebug('* AI-Uveso: ValidateMapAndMarkers: Marker [\''..k2..'\'] is to close to Marker [\''..k..'\']. Distance= '..math.floor(dist)..' (under 60).', true, UvesoOffsetSimInitLUA)
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
            if aiBrain.Status == "Defeat" then
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

function CreateAIMarkers()
    if ScenarioInfo.DoNotAllowMarkerGenerator == true then
        AIWarn('* AI-Uveso: Map does not allow automated marker creation, using the original marker from the map.', true, UvesoOffsetSimInitLUA)
        -- Build Graphs like LAND1 LAND2 WATER1 WATER2
        BuildGraphAreasWithFAFMarker()
        return
-- disabled option for marker generator
--[[
    elseif ScenarioInfo.Options.AIMapMarker == 'off' then
        AILog('* AI-Uveso: Running without markers, deleting map marker.', true, UvesoOffsetSimInitLUA)
        CREATEDMARKERS = {}
        CopyCREATEDMARKERStoMASTERCHAIN('Land')
        CopyCREATEDMARKERStoMASTERCHAIN('Water')
        CopyCREATEDMARKERStoMASTERCHAIN('Amphibious')
        CopyCREATEDMARKERStoMASTERCHAIN('Air')
        return
    elseif ScenarioInfo.Options.AIMapMarker == 'map' then
        AILog('* AI-Uveso: Using the original marker from the map.', true, UvesoOffsetSimInitLUA)
        -- Build Graphs like LAND1 LAND2 WATER1 WATER2
        BuildGraphAreasWithFAFMarker()
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
--]]
    end

    AILog('* AI-Uveso: Generating marker, please wait...', true, UvesoOffsetSimInitLUA)

-- 10x10 Map
--runtime: 50.04 seconds. first run
--runtime: 29.36 seconds. code shortcut when a free place was found on the grid center position
--runtime: 22.26 seconds. after using 3 check lines instead of 5 for pathing check between markers
--runtime: 22.20 seconds. early return when a free place was found on the grid center position
--runtime: 19.79 seconds. after removing debug stuff
--runtime: 17.59 seconds. after making variables local
--runtime: 14.09 seconds. after making commands local
--runtime:  2.90 seconds. after optimizing cell search for marker placement

    local START = GetSystemTimeSecondsOnlyForProfileUse()
    -- for FAF we want the same grid count (36)+1 on every map size, so we adjust the grid cell size here
    local WantedGridCellSize = math.floor( math.max( ScenarioInfo.size[1], ScenarioInfo.size[2] ) / 36)
    AILog("* AI-Uveso: Generating marker with grid cell size of ("..WantedGridCellSize..")", true, UvesoOffsetSimInitLUA)
   
    -- import functions for marker generator
    local AIMarkerGenerator = import("/mods/AI-Uveso/lua/AI/AIMarkerGenerator.lua")
    -- init Generator variables
    AIMarkerGenerator.SetWantedGridCellSize(WantedGridCellSize)
    local markerTable, NavalMarkerPositions, LandMarkerPositions
    -- build a table with dirty / unpathable terrain
    AIMarkerGenerator.BuildTerrainPathMap()
    -- debug; draw dirty/unpathable areas
    --ForkThread(AIMarkerGenerator.PathableTerrainRenderThread)
    AIDebug(string.format("* AI-Uveso: Function CreateAIMarkers(): building TerrainPathMap finished, runtime: %.2f seconds.", GetSystemTimeSecondsOnlyForProfileUse() - START  ), true, UvesoOffsetSimInitLUA)

    -- build marker grid for air
    AIMarkerGenerator.CreateMarkerGrid("Air")
    -- build connections for air
    AIMarkerGenerator.ConnectMarkerWithPathing("Air")
    --ForkThread(AIMarkerGenerator.ConnectMarkerWithPathing, 'Air')
    -- build Graph for related areas
    AIMarkerGenerator.BuildGraphAreas("Air")
    -- get marker for air
    markerTable = AIMarkerGenerator.GetMarkerTable("Air")
    -- convert markers and copy to MASTERCHAIN
    ConvertMarkerTableToFAF(markerTable, "Air")

    -- build marker grid for land
    local STARTSUB = GetSystemTimeSecondsOnlyForProfileUse()
    AIMarkerGenerator.CreateMarkerGrid("Land")
    AIDebug(string.format('* AI-Uveso: Function CreateAIMarkers(): CreateMarkerGrid (Land) finished, runtime: %.2f seconds.', GetSystemTimeSecondsOnlyForProfileUse() - STARTSUB  ), true, UvesoOffsetSimInitLUA)
    -- build connections for land
    local STARTSUB = GetSystemTimeSecondsOnlyForProfileUse()
    AIMarkerGenerator.ConnectMarkerWithPathing("Land")
    --ForkThread(AIMarkerGenerator.ConnectMarkerWithPathing, 'Land')
    AIDebug(string.format('* AI-Uveso: Function CreateAIMarkers(): ConnectMarkerWithPathing (Land) finished, runtime: %.2f seconds.', GetSystemTimeSecondsOnlyForProfileUse() - STARTSUB  ), true, UvesoOffsetSimInitLUA)
    -- build Graph for related areas
    local STARTSUB = GetSystemTimeSecondsOnlyForProfileUse()
    AIMarkerGenerator.BuildGraphAreas("Land")
    AIDebug(string.format('* AI-Uveso: Function CreateAIMarkers(): BuildGraphAreas (Land) finished, runtime: %.2f seconds.', GetSystemTimeSecondsOnlyForProfileUse() - STARTSUB  ), true, UvesoOffsetSimInitLUA)
    -- get marker for land
    markerTable = AIMarkerGenerator.GetMarkerTable("Land")
    -- convert markers and copy to MASTERCHAIN
    ConvertMarkerTableToFAF(markerTable, "Land")

    -- build marker grid for water
    AIMarkerGenerator.CreateMarkerGrid("Water")
    -- build connections for water
    AIMarkerGenerator.ConnectMarkerWithPathing("Water")
    --ForkThread(AIMarkerGenerator.ConnectMarkerWithPathing, 'Water')
    -- build Graph for related areas
    AIMarkerGenerator.BuildGraphAreas("Water")
    -- get marker for water
    markerTable = AIMarkerGenerator.GetMarkerTable("Water")
    -- convert markers and copy to MASTERCHAIN
    ConvertMarkerTableToFAF(markerTable, "Water")

    -- build marker grid for amphibious
    AIMarkerGenerator.CreateMarkerGrid("Amphibious")
    -- build connections for amphibious
    AIMarkerGenerator.ConnectMarkerWithPathing("Amphibious")
    --ForkThread(AIMarkerGenerator.ConnectMarkerWithPathing, 'Amphibious')
    -- build Graph for related areas
    AIMarkerGenerator.BuildGraphAreas("Amphibious")
    -- get marker for amphibious
    markerTable = AIMarkerGenerator.GetMarkerTable("Amphibious")
    -- convert markers and copy to MASTERCHAIN
    ConvertMarkerTableToFAF(markerTable, "Amphibious")

    -- build marker grid for hover
    AIMarkerGenerator.CreateMarkerGrid("Hover")
    -- build connections for hover
    AIMarkerGenerator.ConnectMarkerWithPathing("Hover")
    --ForkThread(AIMarkerGenerator.ConnectMarkerWithPathing, 'Hover')
    -- build Graph for related areas
    AIMarkerGenerator.BuildGraphAreas("Hover")
    -- get marker for hover
    markerTable = AIMarkerGenerator.GetMarkerTable("Hover")
    -- convert markers and copy to MASTERCHAIN
    ConvertMarkerTableToFAF(markerTable, "Hover")
    
    --create naval Areas
    NavalMarkerPositions = AIMarkerGenerator.CreateNavalExpansions()
    ConvertNavalExpansionsToFAF(NavalMarkerPositions)

    --create land expansions
    LandMarkerPositions = AIMarkerGenerator.CreateLandExpansions()
    ConvertLandExpansionsToFAF(LandMarkerPositions)

    -- clear the PathMap[]
    AIMarkerGenerator.ClearMemoryMarkerGenerator()

    AILog(string.format("* AI-Uveso: Function CreateAIMarkers(): Marker generator finished, runtime: %.2f seconds.", GetSystemTimeSecondsOnlyForProfileUse() - START  ), true, UvesoOffsetSimInitLUA)

-- disabled option for marker generator
--[[
    if ScenarioInfo.Options.AIMapMarker == 'print' then
        AILog('map: Printing markers to game.log', true, UvesoOffsetSimInitLUA)
        PrintMASTERCHAIN()
    end
--]]
end

function ConvertMarkerTableToFAF(markerTable, layer)
    CREATEDMARKERS = {}
    -- MarkerGridCountXZ - calculation based on AIMarkerGenerator.SetWantedGridCellSize(x)
    local MarkerGridCountX, MarkerGridCountZ = import('/mods/AI-Uveso/lua/AI/AIMarkerGenerator.lua').MarkerGridCountXZ()
    for x = 0, MarkerGridCountX - 1 do
        for z = 0, MarkerGridCountZ - 1 do
            if markerTable[x][z] then
                CREATEDMARKERS['Marker'..x..'-'..z] = {
                    ['position'] = markerTable[x][z].position,
                    ['graph'] = 'Default'..layer,
                    ['GraphArea'] = markerTable[x][z].GraphArea,
                    ['impassability'] = markerTable[x][z].impassability,
                    ['gridPos'] = {x, z}
                }
                -- copy adjacent
                if markerTable[x][z].adjacentTo[1] then
                    for _, adjacent in markerTable[x][z].adjacentTo do
                        if not CREATEDMARKERS['Marker'..x..'-'..z].adjacentTo then
                            CREATEDMARKERS['Marker'..x..'-'..z].adjacentTo = 'Marker'..adjacent[1]..'-'..adjacent[2]
                        else
                            CREATEDMARKERS['Marker'..x..'-'..z].adjacentTo = CREATEDMARKERS['Marker'..x..'-'..z].adjacentTo..' '..'Marker'..adjacent[1]..'-'..adjacent[2]
                        end
                    end
                end
            end
        end
    end
    CopyCREATEDMARKERStoMASTERCHAIN(layer)
end

function CopyCREATEDMARKERStoMASTERCHAIN(layer)
    --AILog('Delete original marker from MASTERCHAIN for Layer: '..layer)
    -- Deleting all previous markers from MASTERCHAIN
    for nodename, markerInfo in Scenario.MasterChain._MASTERCHAIN_.Markers or {} do
        if markerInfo['graph'] == 'Default'..layer then
            Scenario.MasterChain._MASTERCHAIN_.Markers[nodename] = nil
            --AILog('* CopyCREATEDMARKERStoMASTERCHAIN(): Removed from Masterchain: '..nodename)
        elseif markerInfo['type'] == layer..' Path Node' then
            Scenario.MasterChain._MASTERCHAIN_.Markers[nodename] = nil
            --AILog('* CopyCREATEDMARKERStoMASTERCHAIN(): Removed from Masterchain: '..nodename)
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
            --AILog('* CopyCREATEDMARKERStoMASTERCHAIN(): prozessing marker: '..nodename)
            NewNodeName = string.gsub(nodename, 'Marker', layer)
            --AILog('* CopyCREATEDMARKERStoMASTERCHAIN(): NewNodeName: '..NewNodeName)
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

function BuildGraphAreasWithFAFMarker()
    local GraphIndex = {
        ['Land Path Node'] = 0,
        ['Water Path Node'] = 0,
        ['Amphibious Path Node'] = 0,
        ['Hover Path Node'] = 0,
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
            Scenario.MasterChain._MASTERCHAIN_.Markers[k].GraphArea = MarkerDefaults[v.type].area..'_'..v.GraphArea
        end
    end
--[[
    -- Validate (only for debug printing)
    local GraphCountIndex = {
        ['Land Path Node'] = {},
        ['Water Path Node'] = {},
        ['Amphibious Path Node'] = {},
        ['Hover Path Node'] = {},
        ['Air Path Node'] = {},
    }
    for k, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
        if v.GraphArea then
            GraphCountIndex[v.type][v.GraphArea] = GraphCountIndex[v.type][v.GraphArea] or 1
            GraphCountIndex[v.type][v.GraphArea] = GraphCountIndex[v.type][v.GraphArea] + 1
        end
    end
    AIDebug('* AI-Uveso: BuildGraphAreas_Old(): '..repr(GraphCountIndex), true, UvesoOffsetSimInitLUA)
--]]
end

function ConvertNavalExpansionsToFAF(NavalMarkerPositions)
   -- Deleting all NavalExpansions markers from MASTERCHAIN
    for nodename, markerInfo in Scenario.MasterChain._MASTERCHAIN_.Markers or {} do
        if markerInfo['type'] == 'Naval Area' then
            Scenario.MasterChain._MASTERCHAIN_.Markers[nodename] = nil
        end
    end
    -- creating real naval Marker
    for index, NAVALpostition in NavalMarkerPositions do
        -- add data for a real marker
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index] = {}
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].color = MarkerDefaults["Water Path Node"]['color']
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].hint = true
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].orientation = { 0, 0, 0 }
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].prop = "/env/common/props/markers/M_Expansion_prop.bp"
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].type = "Naval Area"
        Scenario.MasterChain._MASTERCHAIN_.Markers['Naval Area '..index].position = {NAVALpostition.x, GetTerrainHeight(NAVALpostition.x, NAVALpostition.z), NAVALpostition.z}
    end
end

function ConvertLandExpansionsToFAF(LandMarkerPositions)
    -- deleting all (Large-) Expansion markers from MASTERCHAIN
    for nodename, markerInfo in Scenario.MasterChain._MASTERCHAIN_.Markers or {} do
        if markerInfo['type'] == 'Expansion Area' or markerInfo['type'] == 'Large Expansion Area' then
            Scenario.MasterChain._MASTERCHAIN_.Markers[nodename] = nil
        end
    end
    -- creating real expasnion Marker
    for index, Expansion in LandMarkerPositions do
        -- large expansions should have more than 3 mexes
        if Expansion.MexInRange > 3 then
            -- add data for a large expansion
            Scenario.MasterChain._MASTERCHAIN_.Markers['Large Expansion Area '..index] = {}
            Scenario.MasterChain._MASTERCHAIN_.Markers['Large Expansion Area '..index].color = MarkerDefaults["Land Path Node"]['color']
            Scenario.MasterChain._MASTERCHAIN_.Markers['Large Expansion Area '..index].hint = true
            Scenario.MasterChain._MASTERCHAIN_.Markers['Large Expansion Area '..index].orientation = { 0, 0, 0 }
            Scenario.MasterChain._MASTERCHAIN_.Markers['Large Expansion Area '..index].prop = "/env/common/props/markers/M_Expansion_prop.bp"
            Scenario.MasterChain._MASTERCHAIN_.Markers['Large Expansion Area '..index].type = "Large Expansion Area"
            Scenario.MasterChain._MASTERCHAIN_.Markers['Large Expansion Area '..index].position = {Expansion.x, GetTerrainHeight(Expansion.x, Expansion.z), Expansion.z}
        -- normal expansions should have 2-3 mexes
        elseif Expansion.MexInRange > 1 then
            -- add data for a normal expansion
            Scenario.MasterChain._MASTERCHAIN_.Markers['Expansion Area '..index] = {}
            Scenario.MasterChain._MASTERCHAIN_.Markers['Expansion Area '..index].color = MarkerDefaults["Land Path Node"]['color']
            Scenario.MasterChain._MASTERCHAIN_.Markers['Expansion Area '..index].hint = true
            Scenario.MasterChain._MASTERCHAIN_.Markers['Expansion Area '..index].orientation = { 0, 0, 0 }
            Scenario.MasterChain._MASTERCHAIN_.Markers['Expansion Area '..index].prop = "/env/common/props/markers/M_Expansion_prop.bp"
            Scenario.MasterChain._MASTERCHAIN_.Markers['Expansion Area '..index].type = "Expansion Area"
            Scenario.MasterChain._MASTERCHAIN_.Markers['Expansion Area '..index].position = {Expansion.x, GetTerrainHeight(Expansion.x, Expansion.z), Expansion.z}
        end
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
                AIWarn('Missing value in marker '..k..' -> '..repr(v), true, UvesoOffsetSimInitLUA)
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

function DrawHeatMap()
    while GetGameTimeSeconds() < 1 do
        coroutine.yield(10)
    end
    local GetHeatMapGridPositionFromIndex = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetHeatMapGridPositionFromIndex
    local HeatMapGridSizeX, HeatMapGridSizeZ = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetHeatMapGridSizeXZ()
    local mapXGridCount, mapZGridCount = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').HeatMapGridCountXZ()
    local playableArea = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetPlayableArea()
    local px, py, pz = 0,1000,0
    local threatScale = { Land = 1, Air = 1, Water = 1, Amphibious = 1, ecoValue = 1, Ghost = 1}
    local highestThreat = { Land = 1, Air = 1, Water = 1, Amphibious = 1, ecoValue = 1, Ghost = 1}
    local FocussedArmy
    local heatMap
    local enemyMainForce
    local basePosition
    local pr = {}
    while true do
        coroutine.yield(2)
        FocussedArmy = GetFocusArmy()
        if FocussedArmy > 0 then
            heatMap = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetHeatMapForArmy(FocussedArmy)
            basePosition = ArmyBrains[FocussedArmy].BuilderManagers['MAIN'].Position
            if not heatMap or not basePosition then 
                continue 
            end
            -- draw debug
            for x = 0, mapXGridCount - 1 do
                for z = 0, mapZGridCount - 1 do
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
                    if ArmyBrains[FocussedArmy].highestEnemyThreat["Land"] then
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
                                -- draw a line to base
                                DrawLine(basePosition, {px, py, pz}, 'fff4a460') -- M
                            end
                        end
                    end
--[[
                    -- ****
                    -- AIR
                    -- ****
                    -- draw threatRings
                    pr["Air"] = heatMap[x][z].threatRing["Air"] * threatScale["Air"]
                    DrawCircle( { px, py, pz }, pr["Air"] , '80B0B0FF' )
                    -- get the highest value to scale all circles
                    if heatMap[x][z].threatRing["Air"] > highestThreat["Air"] then
                        highestThreat["Air"] = heatMap[x][z].threatRing["Air"]
                    end
                    -- draw box with highest threats
                    for _, threats in pairs(ArmyBrains[FocussedArmy].highestEnemyThreat["Air"]) do
                        if threats.gridPos[1] == x and threats.gridPos[2] == z then
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, 'ffB0B0FF') -- U
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'ffB0B0FF') -- D
                            DrawLine({ 2 + px-HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, { 2 + px-HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'ffB0B0FF') -- L
                            DrawLine({-2 + px+HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, 'ffB0B0FF') -- R
                            -- draw a line to base
                            DrawLine(basePosition, {px, py, pz}, 'ffB0B0FF') -- M
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
                    if ArmyBrains[FocussedArmy].highestEnemyEcoValue["All"] then
                        pr["ecoValue"] = heatMap[x][z].highestEnemyEcoValue["All"] * threatScale["ecoValue"]
                        DrawCircle( { px, py, pz }, pr["ecoValue"] , '80A0A0A0' )
                        -- get the highest value to scale all circles
                        if heatMap[x][z].highestEnemyEcoValue["All"] > highestThreat["ecoValue"] then
                            highestThreat["ecoValue"] = heatMap[x][z].highestEnemyEcoValue["All"]
                        end
                        -- draw box with highest ecoValue
                        for _, ecoValue in pairs(ArmyBrains[FocussedArmy].highestEnemyEcoValue["All"]) do
                            if ecoValue.gridPos[1] == x and ecoValue.gridPos[2] == z then
                                DrawLine({ 2 + px-HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, '80A0A0A0') -- U
                                DrawLine({ 2 + px-HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, '80A0A0A0') -- D
                                DrawLine({ 2 + px-HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, { 2 + px-HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, '80A0A0A0') -- L
                                DrawLine({-2 + px+HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, '80A0A0A0') -- R
                                -- draw a line to base
                                DrawLine(basePosition, {px, py, pz}, '80A0A0A0') -- M
                            end
                        end
                    end

                    -- ****
                    -- ECO
                    -- ****
                    -- draw Ghost
                    if heatMap[x][z].highestEnemyEcoValue["Ghost"] then
                        pr["Ghost"] = heatMap[x][z].highestEnemyEcoValue["Ghost"] * threatScale["ecoValue"]
                        DrawCircle( { px, py, pz }, pr["Ghost"] , '807070FF' )
                        -- get the highest value to scale all circles
                        if heatMap[x][z].highestEnemyEcoValue["Ghost"] > highestThreat["Ghost"] then
                            highestThreat["Ghost"] = heatMap[x][z].highestEnemyEcoValue["Ghost"]
                        end
                        -- draw box with highest Ghost
                        for _, Ghost in pairs(ArmyBrains[FocussedArmy].highestEnemyEcoValue["Ghost"]) do
                            if Ghost.gridPos[1] == x and Ghost.gridPos[2] == z then
                                DrawLine({ 2 + px-HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, '807070FF') -- U
                                DrawLine({ 2 + px-HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, '807070FF') -- D
                                DrawLine({ 2 + px-HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, { 2 + px-HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, '807070FF') -- L
                                DrawLine({-2 + px+HeatMapGridSizeX/2, py,  2 + pz-HeatMapGridSizeZ/2}, {-2 + px+HeatMapGridSizeX/2, py, -2 + pz+HeatMapGridSizeZ/2}, '807070FF') -- R
                                -- draw a line to base
                                DrawLine(basePosition, {px, py, pz}, '807070FF') -- M
                            end
                        end
                    end

                end
            end
            threatScale["Land"] = (math.min( HeatMapGridSizeX, HeatMapGridSizeZ ) - 1) / 2 / highestThreat["Land"]
            threatScale["Air"] = (math.min( HeatMapGridSizeX, HeatMapGridSizeZ ) - 1) / 2 / highestThreat["Air"]
            threatScale["Water"] = (math.min( HeatMapGridSizeX, HeatMapGridSizeZ ) - 1) / 2 / highestThreat["Water"]
            threatScale["Amphibious"] = (math.min( HeatMapGridSizeX, HeatMapGridSizeZ ) - 1) / 2 / highestThreat["Amphibious"]
            threatScale["ecoValue"] = (math.min( HeatMapGridSizeX, HeatMapGridSizeZ ) - 1) / 2 / highestThreat["ecoValue"]
            threatScale["Ghost"] = (math.min( HeatMapGridSizeX, HeatMapGridSizeZ ) - 1) / 2 / highestThreat["Ghost"]
            highestThreat["Land"] = 0
            highestThreat["Air"] = 0
            highestThreat["Water"] = 0
            highestThreat["Amphibious"] = 0
            highestThreat["ecoValue"] = 0
            highestThreat["Ghost"] = 0
        end -- if FocussedArmy > 0 then
    end
end

function ValidateModFilesUveso()
    local ModName = 'AI-Uveso'
    local ModDirectory = 'AI-Uveso'
    local Files = 87
    local Bytes = 2049076
    local modlocation = ""
    for i, mod in __active_mods do
        if mod.name == ModName then
            AILog('* '..ModName..': Mod "'..ModName..'" version ('..mod.version..') is active.', true, UvesoOffsetSimInitLUA)
            modlocation = mod.location
        end
    end
    AILog('* '..ModName..': Running from: '..debug.getinfo(1).source..'.', true, UvesoOffsetSimInitLUA)
    AILog('* '..ModName..': Checking directory "/mods/'..ModDirectory..'"...', true, UvesoOffsetSimInitLUA)
    local FilesInFolder = DiskFindFiles('/mods/', '*.*')
    local modfoundcount = 0
    local modfilepath = ""
    for _, FilepathAndName in FilesInFolder do
        -- FilepathAndName = /mods/ai-uveso/mod_info.lua
        if string.find(FilepathAndName, 'mod_info.lua') then
            if string.gsub(FilepathAndName, ".*/(.*)/.*", "%1") == string.lower(ModDirectory) then
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
        AILog('* '..ModName..': Check OK. Found '..modfoundcount..' "'..ModDirectory..'" directory.', true, UvesoOffsetSimInitLUA)
    else
        AILog('* '..ModName..': Check FAILED! Found '..modfoundcount..' "'..ModDirectory..'" directories.', true, UvesoOffsetSimInitLUA)
    end
    AILog('* '..ModName..': Checking files and filesize for "'..ModName..'"...', true, UvesoOffsetSimInitLUA)
    local FilesInFolder = DiskFindFiles('/mods/'..ModDirectory..'/', '*.*')
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
        AILog('* '..ModName..': Check FAILED! Directory: "'..ModDirectory..'" - Missing '..(Files - filecount)..' files! ('..filecount..'/'..Files..')', true, UvesoOffsetSimInitLUA)
        FAIL = true
    elseif filecount > Files then
        AILog('* '..ModName..': Check FAILED! Directory: "'..ModDirectory..'" - Found '..(filecount - Files)..' odd files! ('..filecount..'/'..Files..')', true, UvesoOffsetSimInitLUA)
        FAIL = true
    end
    if bytecount < Bytes then
        AILog('* '..ModName..': Check FAILED! Directory: "'..ModDirectory..'" - Missing '..(Bytes - bytecount)..' bytes! ('..bytecount..'/'..Bytes..')', true, UvesoOffsetSimInitLUA)
        FAIL = true
    elseif bytecount > Bytes then
        AILog('* '..ModName..': Check FAILED! Directory: "'..ModDirectory..'" - Found '..(bytecount - Bytes)..' odd bytes! ('..bytecount..'/'..Bytes..')', true, UvesoOffsetSimInitLUA)
        FAIL = true
    end
    if not FAIL then
        AILog('* '..ModName..': Check OK! files: '..filecount..', bytecount: '..bytecount..'.', true, UvesoOffsetSimInitLUA)
    end
end
