
-- ToDo: Targeting Take the weapon range in to account and remove the spreaded threat

local TARGETDEBUG = false
local HEATMAPDEBUG = false
local SCOUTDEBUG = false

local WantedGridCellSize = 14
local HeatMap = {}
local TempMap = {}
local playableArea
local PlayableMapSizeX
local PlayableMapSizeZ
local HeatMapGridCountX
local HeatMapGridCountZ
local HeatMapGridSizeX
local HeatMapGridSizeZ

function InitAITargetManagerData(GridCellSize)
    WantedGridCellSize = GridCellSize
    playableArea = GetPlayableArea()
    PlayableMapSizeX = playableArea[3] - playableArea[1]
    PlayableMapSizeZ = playableArea[4] - playableArea[2]
    HeatMapGridCountX = math.floor(PlayableMapSizeX / WantedGridCellSize)
    HeatMapGridCountZ = math.floor(PlayableMapSizeZ / WantedGridCellSize)
    HeatMapGridSizeX = PlayableMapSizeX / HeatMapGridCountX
    HeatMapGridSizeZ = PlayableMapSizeZ / HeatMapGridCountZ
end

function AITargetManagerThread(aiBrain, armyIndex)
    AILog("* AI-Uveso: AITargetManagerThread(): [A:"..armyIndex.."]", TARGETDEBUG)
    -- setup the HeatMap table, every AI has it's own table
    HeatMap[armyIndex] = CreateHeatMap(GetOwnBasePosition(aiBrain))
    ArmyBrains[armyIndex].targets = {}
    ArmyBrains[armyIndex].highestEnemyThreat = {}
    ArmyBrains[armyIndex].highestEnemyEcoValue = {}
    if SCOUTDEBUG then
        aiBrain:ForkThread(DrawScoutMap)
    end

    aiBrain:ForkThread(ArmyScouting, armyIndex)

    local loop = 0 
    while true do
        while not aiBrain:IsOpponentAIRunning() do
            coroutine.yield(10)
        end
        loop = loop + 1
        AILog("* AI-Uveso: AITargetManagerThread(): [A:"..armyIndex.."] Loop ["..loop.."]", TARGETDEBUG)

        CalculateThreat(armyIndex)

        SetTargets(armyIndex, GetOwnBasePosition(aiBrain))
        -- wait for the next loop
        coroutine.yield(10)
    end

end

function CreateHeatMap(basePosition)
    local map = {}
    local gridCenterPos
    for x = 0, HeatMapGridCountX - 1 do
        map[x] = {}
        for z = 0, HeatMapGridCountZ - 1 do
            map[x][z] = {}
            map[x][z].numEnemyCommander = 0
            map[x][z].numEnemyUnits = 0
            map[x][z].numEnemyEngineers = 0
            map[x][z].numEnemyFactories = 0
            map[x][z].highestEnemyEcoValue = {}
            map[x][z].highestEnemyEcoValue["Mass"] = 0
            map[x][z].highestEnemyEcoValue["Energy"] = 0
            map[x][z].highestEnemyEcoValue["All"] = 0
            map[x][z].threat = {}
            map[x][z].threat["Land"] = 0
            map[x][z].threat["Air"] = 0
            map[x][z].threat["Water"] = 0
            map[x][z].threat["Amphibious"] = 0
            map[x][z].threat["Hover"] = 0
            map[x][z].threatRing = {}
            map[x][z].threatRing["Land"] = 0
            map[x][z].threatRing["Air"] = 0
            map[x][z].threatRing["Water"] = 0
            map[x][z].threatRing["Amphibious"] = 0
            map[x][z].threatRing["Hover"] = 0
            map[x][z].lastScouted = -60
            -- ony calculate when base location is present (first time)
            if basePosition then
                gridCenterPos = GetHeatMapGridPositionFromIndex(x, z)
                map[x][z].distantToOwnBase = VDist2(basePosition[1], basePosition[3], gridCenterPos[1], gridCenterPos[3])
            end
        end
    end
    return map
end

function GetHeatMapForArmy(armyIndex)
    return HeatMap[armyIndex]
end

function GetHeatMapGridSizeXZ()
    return HeatMapGridSizeX, HeatMapGridSizeZ
end

function GetPlayableMapSizeXZ()
    return PlayableMapSizeX, PlayableMapSizeZ
end

function HeatMapGridCountXZ()
    return HeatMapGridCountX, HeatMapGridCountZ
end

function GetPlayableArea()
    if ScenarioInfo.MapData.PlayableRect then
        return ScenarioInfo.MapData.PlayableRect
    end
    return {0, 0, ScenarioInfo.size[1], ScenarioInfo.size[2]}
end

function GetHeatMapGridIndexFromPosition(Position)
    if not Position.x or not Position.z then
        AILog("- Warning: * Fn GetHeatMapGridIndexFromPosition(): Position.x or Position.z not present!!!.")
        local FuncData = debug.getinfo(2)
        if FuncData.name and FuncData.name ~= "" then
            AILog("- Warning: * Fn GetHeatMapGridIndexFromPosition(): Called from function: \""..FuncData.name.."\" in "..string.gsub(FuncData.short_src, "in file: ", "").." line "..FuncData.currentline..'')
        else
            AILog('- Warning: * Fn GetHeatMapGridIndexFromPosition(): Called from '..FuncData.source..' - line: '..FuncData.currentline.. '')
        end
    end
    local x = math.floor( (Position.x - playableArea[1]) / HeatMapGridSizeX ) 
    local z = math.floor( (Position.z - playableArea[2]) / HeatMapGridSizeZ )
    -- Make sure that x and z are inside the playable area
    x = math.max( 0, x )
    x = math.min( HeatMapGridCountX - 1, x )
    z = math.max( 0, z )
    z = math.min( HeatMapGridCountZ - 1, z )
    return x, z
end

function GetHeatMapGridPositionFromIndex(x, z)
    --AILog("GetHeatMapGridPositionFromIndex index x "..x.." - z "..z.."")
    local posX = x * HeatMapGridSizeX + HeatMapGridSizeX / 2 + playableArea[1]
    local posZ = z * HeatMapGridSizeZ + HeatMapGridSizeZ / 2 + playableArea[2]
    local posY = 0
    --AILog("GetHeatMapGridPositionFromIndex MapPos"..posX.." "..posZ.."")
    return {posX, posY, posZ}
end

function GetThreatFromHeatMapPosition(armyIndex, position, layer)
    local x, z = GetHeatMapGridIndexFromPosition(position)
    return HeatMap[armyIndex][x][z].threatRing[layer] or 0
end

function GetThreatFromHeatMapGrid(armyIndex, gridPos, layer)
    if not gridPos[1] then
        AILog("GetThreatFromHeatMapGrid gridPos[1] = NIL!")
    end
    if not gridPos[2] then
        AILog("GetThreatFromHeatMapGrid gridPos[2] = NIL!")
    end
    return HeatMap[armyIndex][gridPos[1]][gridPos[2]].threatRing[layer] or 0
end

function CalculateThreat(armyIndex)
    local x, z
    -- make a copy of the heatmap so we don't have an empty table for other functions while building a new table
    local HMAP = CreateHeatMap()
    -- check units on the map
    local EnemyUnits = ArmyBrains[armyIndex]:GetUnitsAroundPoint(categories.ALLUNITS, Vector(PlayableMapSizeX/2,0,PlayableMapSizeZ/2), PlayableMapSizeX+PlayableMapSizeZ , 'Enemy')
    local loopCount = 0
    local unitCat
    for _, unit in pairs(EnemyUnits) do
        if not unit.Dead and IsEnemy( armyIndex, unit.Army ) and unit:GetFractionComplete() >= 1 then

            x, z = GetHeatMapGridIndexFromPosition(unit:GetPosition())
            unitCat = unit.Blueprint.CategoriesHash
            -- enemy COMMANDER
            if unitCat.MOBILE and unitCat.COMMAND then
                HMAP[x][z].numEnemyCommander = HMAP[x][z].numEnemyCommander + 1
            -- enemy engineers
            elseif unitCat.MOBILE and unitCat.ENGINEER and not unitCat.COMMAND then
                HMAP[x][z].numEnemyEngineers = HMAP[x][z].numEnemyEngineers + 1
            -- enemy mobile units except engineers
            elseif unitCat.MOBILE and not unitCat.ENGINEER then
                HMAP[x][z].numEnemyUnits = HMAP[x][z].numEnemyUnits + 1
            -- enemy factories
            elseif unitCat.STRUCTURE and unitCat.FACTORY then
                HMAP[x][z].numEnemyFactories = HMAP[x][z].numEnemyFactories + 1
            end
            -- enemy strength
                -- TECH 1 unit =  1 threat
                -- TECH 2 unit =  3 threat
                -- TECH 3 unit = 13 threat
                -- TECH 4 unit = 80 threat
                -- Commander   = 20 threat
            if unitCat.ANTIAIR then
                -- air threat
                if unitCat.TECH1 then
                    HMAP[x][z].threat["Air"] = HMAP[x][z].threat["Air"] + 1
                elseif unitCat.TECH2 then
                    HMAP[x][z].threat["Air"] = HMAP[x][z].threat["Air"] + 3
                elseif unitCat.TECH3 then
                    HMAP[x][z].threat["Air"] = HMAP[x][z].threat["Air"] + 13
                elseif unitCat.EXPERIMENTAL then
                    HMAP[x][z].threat["Air"] = HMAP[x][z].threat["Air"] + 80
                else
                    AIWarn('* CalculateThreat: cant identify unit TECH for Strength '..repr(unit.UnitId))
                end
            end

            if unitCat.ANTINAVY then
                -- water threat
                if unitCat.TECH1 then
                    HMAP[x][z].threat["Water"] = HMAP[x][z].threat["Water"] + 1
                    HMAP[x][z].threat["Amphibious"] = HMAP[x][z].threat["Amphibious"] + 1
                    HMAP[x][z].threat["Hover"] = HMAP[x][z].threat["Hover"] + 1
                elseif unitCat.TECH2 then
                    HMAP[x][z].threat["Water"] = HMAP[x][z].threat["Water"] + 3
                    HMAP[x][z].threat["Amphibious"] = HMAP[x][z].threat["Amphibious"] + 3
                    HMAP[x][z].threat["Hover"] = HMAP[x][z].threat["Hover"] + 3
                elseif unitCat.TECH3 then
                    HMAP[x][z].threat["Water"] = HMAP[x][z].threat["Water"] + 13
                    HMAP[x][z].threat["Amphibious"] = HMAP[x][z].threat["Amphibious"] + 13
                    HMAP[x][z].threat["Hover"] = HMAP[x][z].threat["Hover"] + 13
                elseif unitCat.EXPERIMENTAL then
                    HMAP[x][z].threat["Water"] = HMAP[x][z].threat["Water"] + 80
                    HMAP[x][z].threat["Amphibious"] = HMAP[x][z].threat["Amphibious"] + 80
                    HMAP[x][z].threat["Hover"] = HMAP[x][z].threat["Hover"] + 80
                else
                    AIWarn('* CalculateThreat: cant identify unit TECH for Strength '..repr(unit.UnitId))
                end
            end

            if (unitCat.DIRECTFIRE or unitCat.INDIRECTFIRE) then
                -- land threat
                if unitCat.TECH1 then
                    HMAP[x][z].threat["Land"] = HMAP[x][z].threat["Land"] + 1
                    HMAP[x][z].threat["Amphibious"] = HMAP[x][z].threat["Amphibious"] + 1
                    HMAP[x][z].threat["Hover"] = HMAP[x][z].threat["Hover"] + 1
                elseif unitCat.TECH2 then
                    HMAP[x][z].threat["Land"] = HMAP[x][z].threat["Land"] + 3
                    HMAP[x][z].threat["Amphibious"] = HMAP[x][z].threat["Amphibious"] + 3
                    HMAP[x][z].threat["Hover"] = HMAP[x][z].threat["Hover"] + 3
                elseif unitCat.TECH3 then
                    HMAP[x][z].threat["Land"] = HMAP[x][z].threat["Land"] + 13
                    HMAP[x][z].threat["Amphibious"] = HMAP[x][z].threat["Amphibious"] + 13
                    HMAP[x][z].threat["Hover"] = HMAP[x][z].threat["Hover"] + 13
                elseif unitCat.EXPERIMENTAL then
                    HMAP[x][z].threat["Land"] = HMAP[x][z].threat["Land"] + 80
                    HMAP[x][z].threat["Amphibious"] = HMAP[x][z].threat["Amphibious"] + 80
                    HMAP[x][z].threat["Hover"] = HMAP[x][z].threat["Hover"] + 80
                elseif unitCat.COMMAND then
                    HMAP[x][z].threat["Land"] = HMAP[x][z].threat["Land"] + 20
                    HMAP[x][z].threat["Amphibious"] = HMAP[x][z].threat["Amphibious"] + 20
                    HMAP[x][z].threat["Hover"] = HMAP[x][z].threat["Hover"] + 20
                else
                    AIWarn('* CalculateThreat: cant identify unit TECH for Strength '..repr(unit.UnitId))
                end
            end
            -- calculate the mass/energy cost of the enemies army
            if unitCat.COMMAND then
                -- special case for FAF commander. Eco is artificial high because of scoreboard
                HMAP[x][z].highestEnemyEcoValue["Mass"] = HMAP[x][z].highestEnemyEcoValue["Mass"] + 28000
                HMAP[x][z].highestEnemyEcoValue["Energy"] = HMAP[x][z].highestEnemyEcoValue["Energy"] + 350000
                HMAP[x][z].highestEnemyEcoValue["All"] = 28000 + 350000 / 10
            elseif not unitCat.SATELLITE and not unitCat.INSIGNIFICANTUNIT then
                HMAP[x][z].highestEnemyEcoValue["Mass"] = HMAP[x][z].highestEnemyEcoValue["Mass"] + unit.Blueprint.Economy.BuildCostMass
                HMAP[x][z].highestEnemyEcoValue["Energy"] = HMAP[x][z].highestEnemyEcoValue["Energy"] + unit.Blueprint.Economy.BuildCostEnergy
                HMAP[x][z].highestEnemyEcoValue["All"] = HMAP[x][z].highestEnemyEcoValue["Mass"] + HMAP[x][z].highestEnemyEcoValue["Energy"] / 10
            end
            
        end
        loopCount = loopCount + 1
        if loopCount > 300 then -- 300
            --AIWarn('* CalculateThreat: loopCount: '..loopCount..'  ')
            coroutine.yield(1)
            loopCount = 0
        end
    end

    coroutine.yield(1)

    -- Loop over the heatmap grid and spread the threat over adjacent squares
    for indexX, xTables in pairs(HMAP) do
        for indexZ, yData in pairs(xTables) do
            -- search for surrounding fields
            for x = -1, 1 do
                for z = -1, 1 do
                    if x == 0 and z == 0 then
                        -- add normal threat for the field itself
                        HMAP[indexX][indexZ].threatRing["Land"] = HMAP[indexX][indexZ].threatRing["Land"] + ( HMAP[indexX + x][indexZ + z].threat["Land"] )
                        HMAP[indexX][indexZ].threatRing["Air"] = HMAP[indexX][indexZ].threatRing["Air"] + ( HMAP[indexX + x][indexZ + z].threat["Air"] )
                        HMAP[indexX][indexZ].threatRing["Water"] = HMAP[indexX][indexZ].threatRing["Water"] + ( HMAP[indexX + x][indexZ + z].threat["Water"] )
                        HMAP[indexX][indexZ].threatRing["Amphibious"] = HMAP[indexX][indexZ].threatRing["Amphibious"] + ( HMAP[indexX + x][indexZ + z].threat["Amphibious"] )
                        HMAP[indexX][indexZ].threatRing["Hover"] = HMAP[indexX][indexZ].threatRing["Hover"] + ( HMAP[indexX + x][indexZ + z].threat["Hover"] )
                    else
                        -- add half threat for surrounding fields
                        if HMAP[indexX + x] and HMAP[indexX + x][indexZ + z] then
                            HMAP[indexX][indexZ].threatRing["Land"] = HMAP[indexX][indexZ].threatRing["Land"] + ( HMAP[indexX + x][indexZ + z].threat["Land"] ) / 2
                            HMAP[indexX][indexZ].threatRing["Air"] = HMAP[indexX][indexZ].threatRing["Air"] + ( HMAP[indexX + x][indexZ + z].threat["Air"] ) / 2
                            HMAP[indexX][indexZ].threatRing["Water"] = HMAP[indexX][indexZ].threatRing["Water"] + ( HMAP[indexX + x][indexZ + z].threat["Water"] ) / 2
                            HMAP[indexX][indexZ].threatRing["Amphibious"] = HMAP[indexX][indexZ].threatRing["Amphibious"] + ( HMAP[indexX + x][indexZ + z].threat["Amphibious"] ) / 2
                            HMAP[indexX][indexZ].threatRing["Hover"] = HMAP[indexX][indexZ].threatRing["Hover"] + ( HMAP[indexX + x][indexZ + z].threat["Hover"] ) / 2
                        end
                    end
                end
            end
        end
    end

    coroutine.yield(1)

    -- copy the updated table to the main HeatMap
    for indexX, xTables in pairs(HMAP) do
        for indexZ, zData in pairs(xTables) do
            HeatMap[armyIndex][indexX][indexZ].numEnemyCommander = zData.numEnemyCommander
            HeatMap[armyIndex][indexX][indexZ].numEnemyUnits = zData.numEnemyUnits
            HeatMap[armyIndex][indexX][indexZ].numEnemyEngineers = zData.numEnemyEngineers
            HeatMap[armyIndex][indexX][indexZ].numEnemyFactories = zData.numEnemyFactories
            HeatMap[armyIndex][indexX][indexZ].highestEnemyEcoValue["Mass"] = zData.highestEnemyEcoValue["Mass"]
            HeatMap[armyIndex][indexX][indexZ].highestEnemyEcoValue["Energy"] = zData.highestEnemyEcoValue["Energy"]
            HeatMap[armyIndex][indexX][indexZ].highestEnemyEcoValue["All"] = zData.highestEnemyEcoValue["All"]
            HeatMap[armyIndex][indexX][indexZ].threatRing["Land"] = zData.threatRing["Land"]
            HeatMap[armyIndex][indexX][indexZ].threatRing["Air"] = zData.threatRing["Air"]
            HeatMap[armyIndex][indexX][indexZ].threatRing["Water"] = zData.threatRing["Water"]
            HeatMap[armyIndex][indexX][indexZ].threatRing["Amphibious"] = zData.threatRing["Amphibious"]
            HeatMap[armyIndex][indexX][indexZ].threatRing["Hover"] = zData.threatRing["Hover"]
            -- copy the mapdata to the ghost map in case the square is scouted lately
            if HeatMap[armyIndex][indexX][indexZ].scouted then
                HeatMap[armyIndex][indexX][indexZ].highestEnemyEcoValue["Ghost"] = HMAP[indexX][indexZ].highestEnemyEcoValue["All"]
                HeatMap[armyIndex][indexX][indexZ].scouted = false
            end
        end
    end
end

local DEBUGLASTPRINTED = 0
function SetTargets(armyIndex, basePosition)
    -- ****************************************************************
    -- search for the highest enemy unit count inside the HeatMap grid
    -- ****************************************************************
    local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = GetDangerZoneRadii()
    local HighestEnemyThreat = {}

    -- ******************
    -- Make threat tables
    -- ******************
    ArmyBrains[armyIndex].highestEnemyThreat["Land"] = BuildThreatTable(armyIndex, "Land") or {}
    ArmyBrains[armyIndex].highestEnemyThreat["Air"] = BuildThreatTable(armyIndex, "Air") or {}
    ArmyBrains[armyIndex].highestEnemyThreat["Water"] = BuildThreatTable(armyIndex, "Water") or {}
    ArmyBrains[armyIndex].highestEnemyThreat["Amphibious"] = BuildThreatTable(armyIndex, "Amphibious") or {}
    ArmyBrains[armyIndex].highestEnemyThreat["Hover"] = BuildThreatTable(armyIndex, "Hover") or {}

    coroutine.yield(1)

    -- ***************************
    -- Make economic target tables
    -- ***************************
    ArmyBrains[armyIndex].highestEnemyEcoValue["Mass"] = BuildEcoValueTable(armyIndex, "Mass") or {}
    ArmyBrains[armyIndex].highestEnemyEcoValue["Energy"] = BuildEcoValueTable(armyIndex, "Energy") or {}
    ArmyBrains[armyIndex].highestEnemyEcoValue["All"] = BuildEcoValueTable(armyIndex, "All") or {}

    -- ***************************
    -- Make ghost target tables (targets that might be under fog of war)
    -- ***************************
    ArmyBrains[armyIndex].highestEnemyEcoValue["Ghost"] = BuildEcoValueTable(armyIndex, "Ghost") or {}

    coroutine.yield(1)

    -- ************************************************************
    -- Make a list of enemy buildings and defenses.
    -- ************************************************************
    local EnemyUnits = ArmyBrains[armyIndex]:GetUnitsAroundPoint(categories.ALLUNITS, Vector(PlayableMapSizeX/2,0,PlayableMapSizeZ/2), PlayableMapSizeX+PlayableMapSizeZ , 'Enemy')
    local loopCount = 0
    local unitCat, unitPosition
    local enemyDefense = { smd = {}, shieldExperimental = {}, shield = {} }
    local enemyTargets = { experimentalMilitaryZone = {}, commander = {}, engineer = {}, experimental = {}, satellite = {}, artillery = {}, nuke = {}, factory = {} }
    local enemyEco = { mass = {}, energy = {}, expgen = {} }
    local distToBase
    for _, unit in EnemyUnits do
        if not unit.Dead and IsEnemy( armyIndex, unit.Army ) and unit:GetFractionComplete() >= 0.7 then
            unitCat = unit.Blueprint.CategoriesHash
            unit.techCategory = unit.Blueprint.TechCategory
            unitPosition = unit:GetPosition()
            distToBase = VDist2(basePosition[1], basePosition[3], unitPosition[1], unitPosition[3])
            -- commander
            if unitCat.COMMAND then
                table.insert(enemyTargets.commander,{ name = "commander", priority = 100, pos = unitPosition, distToBase = distToBase, categories = categories.COMMAND } )
            -- shields experimantal
            elseif unitCat.STRUCTURE and unitCat.SHIELD and unitCat.EXPERIMENTAL then
                if not unit.shieldSize then
                    unit.shieldSize = unit.MyShield.Size or unit.Blueprint.Defense.Shield.ShieldSize
                    unit.nukeProtectRadius = unit.shieldSize / 2
                end
                table.insert(enemyDefense.shieldExperimental,{ name = "shieldExperimental", priority = 95, pos = unitPosition, distToBase = distToBase, shieldRadius = unit.shieldSize/2, nukeProtectRadius = unit.nukeProtectRadius, categories = categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL } )
            -- shields
            elseif unitCat.STRUCTURE and unitCat.SHIELD and not unitCat.EXPERIMENTAL then
                if not unit.shieldSize then
                    unit.shieldSize = unit.MyShield.Size or unit.Blueprint.Defense.Shield.ShieldSize
                end
                table.insert(enemyDefense.shield,{ name = "shield", priority = 90, pos = unitPosition, distToBase = distToBase, shieldRadius = unit.shieldSize/2, categories = categories.STRUCTURE * categories.SHIELD - categories.EXPERIMENTAL } )
            -- experimental resource generator
            elseif unitCat.STRUCTURE and unitCat.ECONOMIC and unitCat.ENERGYPRODUCTION and unitCat.MASSPRODUCTION and unitCat.EXPERIMENTAL then
                table.insert(enemyEco.expgen,{ name = "expgen", priority = 85, pos = unitPosition, distToBase = distToBase, categories = categories.STRUCTURE * categories.ECONOMIC * categories.ENERGYPRODUCTION * categories.MASSPRODUCTION * categories.EXPERIMENTAL } )
            -- artillery
            elseif unitCat.STRUCTURE and unitCat.ARTILLERY and (unitCat.TECH3 or unitCat.EXPERIMENTAL) then
                table.insert(enemyTargets.artillery,{ name = "artillery", priority = 80, pos = unitPosition, distToBase = distToBase, categories = categories.STRUCTURE * categories.ARTILLERY * (categories.TECH3 + categories.EXPERIMENTAL) } )
            -- satellite station
            elseif unitCat.STRUCTURE and unitCat.ORBITALSYSTEM then
                table.insert(enemyTargets.satellite,{ name = "satellite", priority = 80, pos = unitPosition, distToBase = distToBase, categories = categories.STRUCTURE * categories.ORBITALSYSTEM } )
            -- strategic missile defense
            elseif unitCat.STRUCTURE and unitCat.DEFENSE and unitCat.ANTIMISSILE and (unitCat.TECH3 or unitCat.EXPERIMENTAL) then
                if not unit.nukeProtectRadius then
                    unit.nukeProtectRadius = unit.Blueprint.Weapon[1].MaxRadius
                end
                table.insert(enemyDefense.smd,{ name = "smd", priority = 70, pos = unitPosition, distToBase = distToBase, nukeProtectRadius = unit.nukeProtectRadius, categories = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * ( categories.TECH3 + categories.EXPERIMENTAL ) } )
            -- nukes
            elseif unitCat.STRUCTURE and unitCat.NUKE then
                table.insert(enemyTargets.nuke,{ name = "nuke", priority = 60, pos = unitPosition, distToBase = distToBase, categories = categories.STRUCTURE * categories.NUKE } )
            -- experimentals
            elseif unitCat.MOBILE and unitCat.EXPERIMENTAL and not unitCat.AIR and not unitCat.INSIGNIFICANTUNIT then
                if distToBase < BaseMilitaryZone then
                    -- mobile experimantals in BaseMilitaryZone
                    table.insert(enemyTargets.experimentalMilitaryZone,{ name = "experimentalMilitaryZone", priority = 200, pos = unitPosition, distToBase = distToBase, categories = categories.MOBILE * categories.EXPERIMENTAL - categories.AIR } )
                else
                    -- mobile experimantals in EnemyZone
                    table.insert(enemyTargets.experimental,{ name = "experimental", priority = 50, pos = unitPosition, distToBase = distToBase, categories = categories.MOBILE * categories.EXPERIMENTAL - categories.AIR } )
                end
            -- engineer
            elseif unitCat.MOBILE and unitCat.ENGINEER and not unitCat.COMMAND and not unitCat.STATIONASSISTPOD then
                table.insert(enemyTargets.engineer,{ name = "engineer", priority = 40, pos = unitPosition, distToBase = distToBase, techCategory = unit.techCategory, categories = categories.MOBILE * categories.ENGINEER - categories.COMMAND - categories.STATIONASSISTPOD  } )
            -- extractors
            elseif unitCat.STRUCTURE and unitCat.MASSEXTRACTION then
                table.insert(enemyEco.mass,{ name = "mass", priority = 40, pos = unitPosition, distToBase = distToBase, techCategory = unit.techCategory, categories = categories.STRUCTURE * categories.MASSEXTRACTION } )
            -- energy
            elseif unitCat.STRUCTURE and unitCat.ENERGYPRODUCTION then
                table.insert(enemyEco.energy,{ name = "energy", priority = 40, pos = unitPosition, distToBase = distToBase, techCategory = unit.techCategory, categories = categories.STRUCTURE * categories.ENERGYPRODUCTION } )
            -- factories
            elseif unitCat.STRUCTURE and unitCat.FACTORY then
                table.insert(enemyTargets.factory,{ name = "factory", priority = 30, pos = unitPosition, distToBase = distToBase, techCategory = unit.techCategory, categories = categories.STRUCTURE * categories.FACTORY } )
            end
        end
        loopCount = loopCount + 1
        if loopCount > 500 then -- 500
            --AIWarn('* SetTargets: loopCount: '..loopCount..'  ')
            coroutine.yield(1)
            loopCount = 0
        end
    end

    coroutine.yield(1)

    -- *****************************
    -- search for a satellite target
    -- *****************************
    -- build list with all targets we want to attack
    local weaponTargets = {}
    weaponTargets = tableMerge(weaponTargets,enemyTargets.experimentalMilitaryZone)
    weaponTargets = tableMerge(weaponTargets,enemyDefense.shieldExperimental)
    weaponTargets = tableMerge(weaponTargets,enemyDefense.shield)
    weaponTargets = tableMerge(weaponTargets,enemyEco.expgen)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.artillery)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.satellite)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.experimental)
    weaponTargets = tableMerge(weaponTargets,enemyDefense.smd)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.nuke)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.commander)
    weaponTargets = tableMerge(weaponTargets,enemyEco.mass)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.engineer)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.factory)
    weaponTargets = tableMerge(weaponTargets,enemyEco.energy)
    -- check first if the targets are protected by a shield
    weaponTargets = checkIsShielded( weaponTargets, tableMerge( enemyDefense.shield, enemyDefense.shieldExperimental ) )
    -- check if the target is under water, satellites can't fire at it
    weaponTargets = checkIsUnderWater(weaponTargets)
    -- sort table first by priority, then shield count, then by range to base
    weaponTargets = SortTableForSatellite(weaponTargets)
    -- store the list into the brain
    ArmyBrains[armyIndex].targets.satelliteTargets = weaponTargets
    
    coroutine.yield(1)

    -- *****************************
    -- search for a artillery target
    -- *****************************
    -- build list with all targets we want to attack
    weaponTargets = {}
    weaponTargets = tableMerge(weaponTargets,GetTargetsFromEcoTable(armyIndex, ArmyBrains[armyIndex].highestEnemyEcoValue["All"]))
    weaponTargets = tableMerge(weaponTargets,enemyTargets.experimentalMilitaryZone)
    weaponTargets = tableMerge(weaponTargets,enemyDefense.shieldExperimental)
    weaponTargets = tableMerge(weaponTargets,enemyDefense.shield)
    weaponTargets = tableMerge(weaponTargets,enemyEco.expgen)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.artillery)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.satellite)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.experimental)
    weaponTargets = tableMerge(weaponTargets,enemyDefense.smd)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.nuke)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.commander)
    weaponTargets = tableMerge(weaponTargets,enemyEco.mass)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.engineer)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.factory)
    weaponTargets = tableMerge(weaponTargets,enemyEco.energy)
    -- check first if the targets are protected by a shield
    weaponTargets = checkIsShielded( weaponTargets, tableMerge( enemyDefense.shield, enemyDefense.shieldExperimental ) )
    -- check if the target is under water, artilleries can't fire at it
    weaponTargets = checkIsUnderWater(weaponTargets)
    -- sort table first by priority, then shield count, then by range to base
    weaponTargets = SortTableForArtillery(weaponTargets)
    -- store the list into the brain
    ArmyBrains[armyIndex].targets.artilleryTargets = weaponTargets

    coroutine.yield(1)

    -- *****************************
    -- search for a nuke target
    -- *****************************
    -- build list with all targets we want to attack
    weaponTargets = {}
    weaponTargets = tableMerge(weaponTargets,GetTargetsFromEcoTable(armyIndex, ArmyBrains[armyIndex].highestEnemyEcoValue["All"]))
    weaponTargets = tableMerge(weaponTargets,enemyTargets.experimentalMilitaryZone)
    weaponTargets = tableMerge(weaponTargets,enemyDefense.shieldExperimental)
    weaponTargets = tableMerge(weaponTargets,enemyEco.expgen)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.artillery)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.satellite)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.experimental)
    weaponTargets = tableMerge(weaponTargets,enemyDefense.smd)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.nuke)
    weaponTargets = tableMerge(weaponTargets,enemyTargets.commander)
    -- check first if the targets are protected by a shield
    weaponTargets = checkIsSMDProtected( weaponTargets, tableMerge( enemyDefense.smd, enemyDefense.shieldExperimental ) )
    -- sort table first by priority, then shield count, then by range to base
    weaponTargets = SortTableForNuke(weaponTargets)
    -- store the list into the brain
    ArmyBrains[armyIndex].targets.nukeTargets = weaponTargets

    coroutine.yield(1)

--[[
    -- only print for focussed army
    FocussedArmy = GetFocusArmy()
    if FocussedArmy ~= armyIndex then return end

    if DEBUGLASTPRINTED + 30 < GetGameTimeSeconds() then
        DEBUGLASTPRINTED = GetGameTimeSeconds()
        AILog("**********************************************************************************")
        for _, array in ArmyBrains[armyIndex].targets.satelliteTargets do
            AILog("satellite targets: priority: "..array.priority.." - protectedByShield:"..array.protectedByShield.." - shieldRadius: "..repr(array.shieldRadius or 0).." - techCategory: "..repr(array.techCategory or 0).." - distToBase: "..math.floor(array.distToBase).." - name: "..array.name.."" )
        end
        for _, array in ArmyBrains[armyIndex].targets.artilleryTargets do
            AILog("artillery targets: priority: "..array.priority.." - protectedByShield:"..array.protectedByShield.." - shieldRadius: "..repr(array.shieldRadius or 0).." - distToBase: "..math.floor(array.distToBase).." - name: "..array.name.."" )
        end
        for _, array in ArmyBrains[armyIndex].targets.nukeTargets do
            AILog("nuke targets: priority: "..array.priority.." - protectedBySMD:"..array.protectedBySMD.." - shieldRadius: "..repr(array.shieldRadius or 0).." - name: "..array.name.."" )
        end
        AILog("----------------------------------------------------------------------------------")
    end
--]]

end

function GetOwnBasePosition(aiBrain)
    return aiBrain.BuilderManagers['MAIN'].Position
end

function checkIsShielded(enemyTargets, enemyShields)
    for _, target in enemyTargets do
        target.protectedByShield = 0
        for _, shield in enemyShields do
            --DrawCircle( { shield.pos[1], shield.pos[2], shield.pos[3] }, shield.shieldRadius , '8000FFFF' )
            if VDist2(target.pos[1], target.pos[3], shield.pos[1], shield.pos[3]) < shield.shieldRadius then
                --DrawCircle( { target.pos[1], target.pos[2], target.pos[3] }, 2 , '80FF0000' )
                target.protectedByShield = target.protectedByShield + 1
            end
        end
    end
    return enemyTargets
end

function checkIsSMDProtected(enemyTargets, enemySMDs)
    for _, target in enemyTargets do
        target.protectedBySMD = 0
        for _, SMDs in enemySMDs do
            --DrawCircle( { SMDs.pos[1], SMDs.pos[2], SMDs.pos[3] }, SMDs.nukeProtectRadius , '8000FFFF' )
            if VDist2(target.pos[1], target.pos[3], SMDs.pos[1], SMDs.pos[3]) < SMDs.nukeProtectRadius then
                --DrawCircle( { target.pos[1], target.pos[2], target.pos[3] }, 2 , '80FF0000' )
                target.protectedBySMD = target.protectedBySMD + 1
            end
        end
    end
    return enemyTargets
end

function checkIsUnderWater(enemyTargets)
    for _, target in enemyTargets do
        if GetTerrainHeight(target.pos[1], target.pos[3]) >= GetSurfaceHeight(target.pos[1], target.pos[3]) then
            --land
        else
            --water
            target.underWater = true
        end
    end
    return enemyTargets
end

function tableMerge(t1, t2)
    for k,v in t2 do
        table.insert(t1, v)
    end
    return t1
end

function BuildThreatTable(armyIndex, layer)
    -- make a list with threat from layer
    local threatTable = {}
    local highestThreatMinimum
    -- search for the highest value to make a minimum from where we consider threat
    for indexX, xTables in pairs(HeatMap[armyIndex]) do
        for indexZ, zData in pairs(xTables) do
            if not highestThreatMinimum or highestThreatMinimum < zData.threatRing[layer] then
                highestThreatMinimum = zData.threatRing[layer]
            end
        end
    end
    highestThreatMinimum = highestThreatMinimum / 10
    -- make table with threat spots
    for indexX, xTables in pairs(HeatMap[armyIndex]) do
        for indexZ, zData in pairs(xTables) do
            if zData.threatRing[layer] > highestThreatMinimum then
                table.insert(threatTable,{ threat = zData.threatRing[layer], gridPos = {indexX, indexZ} })
            end
        end
    end
    table.sort(threatTable, function(a, b) return a.threat > b.threat end)
    -- remove all threats that are to close to each other
    if threatTable[1] then
        local spacedThreatTable = {}
        local tooClose
        table.insert(spacedThreatTable,{ threat = threatTable[1].threat, gridPos = threatTable[1].gridPos })
        for _, threat in pairs(threatTable) do
            tooClose = false
            for _, spacedThreat in pairs(spacedThreatTable) do
                -- closer than 4 grids ?
                if math.abs( threat.gridPos[1] - spacedThreat.gridPos[1] ) + math.abs( threat.gridPos[2] - spacedThreat.gridPos[2] ) <= 4 then
                    tooClose = true
                    break
                end
            end
            if not tooClose then
                table.insert(spacedThreatTable,{ threat = threat.threat, gridPos = threat.gridPos })
            end
        end
        return spacedThreatTable
    end
    return threatTable
end

function BuildEcoValueTable(armyIndex, ecoType)
    -- make a list with eco
    local ecoValueTable = {}
    local highestEcoMinimum
    -- search for the highest value to make a minimum from where we consider eco value
    for indexX, xTables in pairs(HeatMap[armyIndex]) do
        for indexZ, zData in pairs(xTables) do
            if not highestEcoMinimum or highestEcoMinimum < zData.highestEnemyEcoValue[ecoType] then
                highestEcoMinimum = zData.highestEnemyEcoValue[ecoType]
            end
        end
    end
    if not highestEcoMinimum then 
        return ecoValueTable
    end
    -- don't waste arty/nuke on low eco targets
    highestEcoMinimum = highestEcoMinimum / 2.5 -- 40%
    -- make table with eco spots
    for indexX, xTables in pairs(HeatMap[armyIndex]) do
        for indexZ, zData in pairs(xTables) do
            if zData.highestEnemyEcoValue[ecoType] > highestEcoMinimum then
                table.insert(ecoValueTable,{ ecoValue = zData.highestEnemyEcoValue[ecoType], gridPos = {indexX, indexZ}, distToBase = zData.distToBase })
            end
        end
    end
    -- sort first by value, so we get the center of the highest value
    table.sort(ecoValueTable, function(a, b) return a.ecoValue > b.ecoValue end)
    -- remove all targets that are to close to each other
    if ecoValueTable[1] then
        local spacedThreatTable = {}
        local tooClose
        table.insert(spacedThreatTable,{ ecoValue = ecoValueTable[1].ecoValue, gridPos = ecoValueTable[1].gridPos, distToBase = ecoValueTable[1].distToBase })
        for _, ecoValue in pairs(ecoValueTable) do
            tooClose = false
            for _, spacedThreat in pairs(spacedThreatTable) do
                -- closer than 4 grids ?
                if math.abs( ecoValue.gridPos[1] - spacedThreat.gridPos[1] ) + math.abs( ecoValue.gridPos[2] - spacedThreat.gridPos[2] ) <= 4 then
                    tooClose = true
                    break
                end
            end
            if not tooClose then
                table.insert(spacedThreatTable,{ ecoValue = ecoValue.ecoValue, gridPos = ecoValue.gridPos, distToBase = ecoValue.distToBase })
            end
        end
        return spacedThreatTable
    end
    -- sort second by distance to base, to attack the closer/easier target first
    table.sort(ecoValueTable, function(a, b) return a.distToBase > b.distToBase end)
    return ecoValueTable
end

function SortTableForSatellite(satelliteTargets)
    table.sort(satelliteTargets, function(a, b)
        -- sort in case we have unprotected targets. Unprotected first
        if a.protectedByShield == 0 or b.protectedByShield == 0 then
            if a.protectedByShield ~= b.protectedByShield then
                return a.protectedByShield < b.protectedByShield
            elseif a.priority ~= b.priority then
                return a.priority > b.priority
            elseif a.techCategory ~= b.techCategory then
                return a.techCategory > b.techCategory
            elseif a.shieldRadius ~= b.shieldRadius then
                return a.shieldRadius > b.shieldRadius
            else
                return a.distToBase < b.distToBase
            end
        else
            -- sort if we have protected targets. bigger shieldradius first
            -- bigger shields mostly cover smaller ones, so we need to kill the bigger ones first
            if a.shieldRadius ~= b.shieldRadius then
                return a.shieldRadius > b.shieldRadius
            elseif a.protectedByShield ~= b.protectedByShield then
                return a.protectedByShield < b.protectedByShield
            elseif a.priority ~= b.priority then
                return a.priority > b.priority
            elseif a.techCategory ~= b.techCategory then
                return a.techCategory > b.techCategory
            else
                return a.distToBase < b.distToBase
            end
        end
    end)
    return satelliteTargets
end

function SortTableForArtillery(artilleryTargets)
    table.sort(artilleryTargets, function(a, b)
        -- sort in case we have unprotected targets. Unprotected first
        if a.protectedByShield == 0 or b.protectedByShield == 0 then
            if a.protectedByShield ~= b.protectedByShield then
                return a.protectedByShield < b.protectedByShield
            elseif a.priority ~= b.priority then
                return a.priority > b.priority
            else
                return a.distToBase < b.distToBase
            end
        else
            -- sort if we have protected targets. bigger shieldradius first
            -- bigger shields mostly cover smaller ones, so we need to kill the bigger ones first
            if a.shieldRadius ~= b.shieldRadius then
                return a.shieldRadius > b.shieldRadius
            elseif a.protectedByShield ~= b.protectedByShield then
                return a.protectedByShield < b.protectedByShield
            elseif a.priority ~= b.priority then
                return a.priority > b.priority
            else
                return a.distToBase < b.distToBase
            end
        end
    end)
    return artilleryTargets
end

function SortTableForNuke(nukeTargets)
    table.sort(nukeTargets, function(a, b)
        -- sort in case we have unprotected targets. Unprotected first
        if a.protectedBySMD == 0 or b.protectedBySMD == 0 then
            if a.protectedBySMD ~= b.protectedBySMD then
                return a.protectedBySMD < b.protectedBySMD
            elseif a.priority ~= b.priority then
                return a.priority > b.priority
            elseif a.techCategory ~= b.techCategory then
                return a.techCategory > b.techCategory
            else
                return a.distToBase < b.distToBase
            end
        else
            -- sort if we have protected targets. bigger shieldradius first
            -- bigger shields mostly cover smaller ones, so we need to kill the bigger ones first
            if a.protectedBySMD ~= b.protectedBySMD then
                return a.protectedBySMD < b.protectedBySMD
            elseif a.shieldRadius ~= b.shieldRadius then
                return a.shieldRadius > b.shieldRadius
            elseif a.priority ~= b.priority then
                return a.priority > b.priority
            elseif a.techCategory ~= b.techCategory then
                return a.techCategory > b.techCategory
            else
                return a.distToBase < b.distToBase
            end
        end
    end)
    return nukeTargets
end

function GetDangerZoneRadii(bool)
    if not playableArea then
        playableArea = {0, 0, ScenarioInfo.size[1], ScenarioInfo.size[2]}
    end
    -- Military zone is the half the map size (10x10map) or maximal 250.
    local BaseMilitaryZone = math.max( playableArea[3], playableArea[4] ) / 2
    BaseMilitaryZone = math.min( 250, BaseMilitaryZone )
    -- Panic Zone is half the BaseMilitaryZone. That's 1/4 of a 10x10 map
    local BasePanicZone = BaseMilitaryZone / 2
    -- Make sure the Panic Zone is not smaller than 60 or greater than 120
    BasePanicZone = math.max( 60, BasePanicZone )
    BasePanicZone = math.min( 120, BasePanicZone )
    -- The rest of the map is enemy zone
    local BaseEnemyZone = math.sqrt( playableArea[3] * playableArea[3] + playableArea[4] * playableArea[4] )
    -- "bool" is only true if called from "AIBuilders/Mobile Land.lua", so we only print this once.
    if bool then
        AILog('* AI-Uveso: playableArea= ('..playableArea[1]..', '..playableArea[2]..' - '..playableArea[3]..', '..playableArea[4]..')' )
        AILog('* AI-Uveso: BasePanicZone= '..math.floor( BasePanicZone * 0.01953125 ) ..' Km - ('..math.floor( BasePanicZone )..' units)' )
        AILog('* AI-Uveso: BaseMilitaryZone= '..math.floor( BaseMilitaryZone * 0.01953125 )..' Km - ('..math.floor( BaseMilitaryZone )..' units)' )
        AILog('* AI-Uveso: BaseEnemyZone= '..math.floor( BaseEnemyZone * 0.01953125 )..' Km - ('..math.floor( BaseEnemyZone )..' units)' )
    end
    return BasePanicZone, BaseMilitaryZone, BaseEnemyZone
end

function GetTargetsFromEcoTable(armyIndex, ecoTable)
    local returnTable = {}
    local highestEco
    for _, data in pairs(ecoTable) do
        if not highestEco or highestEco < data.ecoValue then
            highestEco = data.ecoValue
        end
    end
    if highestEco then
        for _, data in pairs(ecoTable) do
            table.insert(returnTable,{ name = "EcoValue", priority = math.floor(100 / highestEco * data.ecoValue), pos = GetHeatMapGridPositionFromIndex(data.gridPos[1], data.gridPos[2] ), distToBase = HeatMap[armyIndex][data.gridPos[1]][data.gridPos[2]].distantToOwnBase, categories = categories.ALLUNITS } )
        end
    end
    return returnTable
end

function DrawScoutMap()
    while GetGameTimeSeconds() < 1 do
        coroutine.yield(10)
    end
    local playableArea = GetPlayableArea()
    local px, py, pz = 0,0,0
    local ScoutScale = 1
    local Scouthighest = 1
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
            for x = 0, HeatMapGridCountX - 1 do
                for z = 0, HeatMapGridCountZ - 1 do
                    gridCenterPos = GetHeatMapGridPositionFromIndex(x, z)
                    px = gridCenterPos[1]
                    pz = gridCenterPos[3]
--                    if py > GetTerrainHeight( px, pz ) then
                        py = GetTerrainHeight( px, pz )
--                    end
                    -- draw heatmap box
                    DrawLine({px-HeatMapGridSizeX/2, py, pz-HeatMapGridSizeZ/2}, {px+HeatMapGridSizeX/2, py, pz-HeatMapGridSizeZ/2}, 'ff707070') -- U
--                    DrawLine({px-HeatMapGridSizeX/2, py, pz+HeatMapGridSizeZ/2}, {px+HeatMapGridSizeX/2, py, pz+HeatMapGridSizeZ/2}, 'ff707070') -- D
                    DrawLine({px-HeatMapGridSizeX/2, py, pz-HeatMapGridSizeZ/2}, {px-HeatMapGridSizeX/2, py, pz+HeatMapGridSizeZ/2}, 'ff707070') -- L
--                    DrawLine({px+HeatMapGridSizeX/2, py, pz-HeatMapGridSizeZ/2}, {px+HeatMapGridSizeX/2, py, pz+HeatMapGridSizeZ/2}, 'ff707070') -- R

                    -- draw scouted areas
                    pr["Land"] = (GetGameTimeSeconds() - heatMap[x][z].lastScouted)  * ScoutScale
                    DrawCircle( { px, py, pz }, pr["Land"] , '80f4a460' )
                    -- get the highest value to scale all circles
                    if (GetGameTimeSeconds() - heatMap[x][z].lastScouted) > Scouthighest then
                        Scouthighest = (GetGameTimeSeconds() - heatMap[x][z].lastScouted)
                    end
                end
            end
            ScoutScale = (math.min( HeatMapGridSizeX, HeatMapGridSizeZ ) - 1) / 2 / Scouthighest
            Scouthighest = 1
        end -- if FocussedArmy > 0 then
    end
end

function GetScoutTable(armyIndex)
    local AIMarkerGenerator = import('/mods/AI-Uveso/lua/AI/AIMarkerGenerator.lua')
    local highPrioList = {}
    local lowPrioList = {}
    local lastScouted, scoutedBy
    local ScoutTimeOut = 60
    -- build highPrioList with start positions and expansions.
    for i, startPosition in pairs(AIMarkerGenerator.GetStartPositions()) do
        lastScouted, scoutedBy = GetLastScouted(armyIndex, startPosition)
        if not scoutedBy and (not lastScouted or GetGameTimeSeconds() - lastScouted > ScoutTimeOut) then
            table.insert(highPrioList, {x = startPosition.x, z = startPosition.z, id = "Start Position", lastScouted = lastScouted} )
        end
    end
    for i, expansionPosition in pairs(AIMarkerGenerator.GetLandExpansions()) do
        lastScouted, scoutedBy = GetLastScouted(armyIndex, expansionPosition)
        if not scoutedBy and (not lastScouted or GetGameTimeSeconds() - lastScouted > ScoutTimeOut) then
            if expansionPosition.MexInRange > 3 then
                table.insert(highPrioList, {x = expansionPosition.x, z = expansionPosition.z, id = "Large Expansion Area", lastScouted = lastScouted} )
            else
                table.insert(highPrioList, {x = expansionPosition.x, z = expansionPosition.z, id = "Small Expansion Area", lastScouted = lastScouted} )
            end
        end
    end
    for i, expansionPosition in pairs(AIMarkerGenerator.GetNavalExpansions()) do
        lastScouted, scoutedBy = GetLastScouted(armyIndex, expansionPosition)
        if not scoutedBy and (not lastScouted or GetGameTimeSeconds() - lastScouted > ScoutTimeOut) then
            table.insert(highPrioList, {x = expansionPosition.x, z = expansionPosition.z, id = "Naval Expansion Area", lastScouted = lastScouted} )
        end
    end
    table.sort(highPrioList, function(a, b) return a.lastScouted < b.lastScouted end)
    -- build lowPrioList with normal grid position
    for indexX, xTables in pairs(HeatMap[armyIndex]) do
        for indexZ, zData in pairs(xTables) do
            blocked = false
            -- check if we have already a scout target in this area
            for x = indexX - 5, indexX + 5 do
                for z = indexZ - 5, indexZ + 5 do
                    if HeatMap[armyIndex][x] and HeatMap[armyIndex][x][z] then
                        if HeatMap[armyIndex][x][z].scoutedBy then
--                            if HeatMap[armyIndex][x][z].lastScouted > 0 and GetGameTimeSeconds() - HeatMap[armyIndex][x][z].lastScouted < 180 then
                                blocked = true
--                            end
                        end
                    end
                end
            end
            gridCenterPos = GetHeatMapGridPositionFromIndex(indexX, indexZ)
            lastScouted, scoutedBy = GetLastScouted(armyIndex, {x = gridCenterPos[1], y = gridCenterPos[2], z = gridCenterPos[3]})
            if not scoutedBy and (not lastScouted or GetGameTimeSeconds() - lastScouted > 30) then
                -- check if the scout location is close to an already saved position
                for i, location in pairs(lowPrioList) do
                    if VDist2( location.x, location.z, gridCenterPos[1], gridCenterPos[3]) < 40 then
                        blocked = true
                        break
                    end
                end
                -- check if the scout location is to close to an highPrio location
                for i, location in pairs(highPrioList) do
                    if VDist2( location.x, location.z, gridCenterPos[1], gridCenterPos[3]) < 40 then
                        blocked = true
                        break
                    end
                end
                if not blocked then
                    table.insert(lowPrioList, {x = gridCenterPos[1], z = gridCenterPos[3], id = "Normal Area", lastScouted = lastScouted} )
                end
            end
        end
    end
    table.sort(lowPrioList, function(a, b) return a.lastScouted < b.lastScouted end)

    return highPrioList, lowPrioList
end

function GetLastScouted(armyIndex, position)
    local gridX, gridZ = GetHeatMapGridIndexFromPosition(position)
    return HeatMap[armyIndex][gridX][gridZ].lastScouted, HeatMap[armyIndex][gridX][gridZ].scoutedBy
end

function GetUnScoutedNearby(armyIndex, position, scoutRadius)
    scoutRadius = scoutRadius + 2
    local closestAreaDistance = scoutRadius
    local gridX, gridZ = GetHeatMapGridIndexFromPosition(position)
    local offsetX = math.floor((scoutRadius / HeatMapGridSizeX) + 0.5) - 1
    local offsetZ = math.floor((scoutRadius / HeatMapGridSizeZ) + 0.5) - 1
    local scoutingTarget, scoutDestination, gridCenterPos
    offsetX = math.max(offsetX, 0)
    offsetZ = math.max(offsetZ, 0)
    --AILog('* Fn: GetUnScoutedNearby(): HeatMapGridSizeX['..HeatMapGridSizeX..'] scoutRadius['..scoutRadius..']', true)
    --AILog('* Fn: GetUnScoutedNearby(): offsetX['..offsetX..'] offsetZ['..offsetZ..']', true)
    for x = gridX - offsetX, gridX + offsetX do
        for z = gridZ - offsetZ, gridZ + offsetZ do
            if HeatMap[armyIndex][x] and HeatMap[armyIndex][x][z] then
                gridCenterPos = GetHeatMapGridPositionFromIndex(x, z)
                scoutDestination = {x = gridCenterPos[1], y = GetTerrainHeight(gridCenterPos[1], gridCenterPos[3]), z = gridCenterPos[3]}
                if GetLastScoutBy(armyIndex, scoutDestination) then
                    return false
                end
                local dist = VDist2(position.x, position.z, gridCenterPos[1], gridCenterPos[3])
                if dist < closestAreaDistance and GetGameTimeSeconds() - HeatMap[armyIndex][x][z].lastScouted > 15 then
                    --AILog('* Fn: GetUnScoutedNearby(): Grid['..x..']['..z..'] closestAreaDistance='..closestAreaDistance..' TRUE', true)
                    scoutingTarget = {x = gridCenterPos[1], y = 0, z = gridCenterPos[3]}
                    closestAreaDistance = dist
                else
                    --AILog('* Fn: GetUnScoutedNearby(): Grid['..x..']['..z..'] closestAreaDistance='..closestAreaDistance..' FALSE', true)
                end
            end
        end
    end
    --AILog('* Fn: GetUnScoutedNearby(): scoutingTarget='..repr(scoutingTarget)..' FALSE', true)
    return scoutingTarget
end
function SetLastScoutedSquared(armyIndex, position, scoutRadius)
    local gridX, gridZ = GetHeatMapGridIndexFromPosition(position)
    local offsetX = math.floor((scoutRadius / HeatMapGridSizeX) + 0.5) - 1
    local offsetZ = math.floor((scoutRadius / HeatMapGridSizeZ) + 0.5) - 1
    offsetX = math.max(offsetX, 0)
    offsetZ = math.max(offsetZ, 0)
    --AIWarn('* AI-Uveso: SetLastScoutedSquared(): HeatMapGridSizeX['..HeatMapGridSizeX..'] scoutRadius['..scoutRadius..']', true)
    --AIWarn('* AI-Uveso: SetLastScoutedSquared(): offsetX['..offsetX..'] offsetZ['..offsetZ..']', true)
    for x = gridX - offsetX, gridX + offsetX do
        for z = gridZ - offsetZ, gridZ + offsetZ do
            if HeatMap[armyIndex][x][z] then
                --AIWarn('* AI-Uveso: SetLastScoutedSquared(): Grid['..x..']['..z..']', true)
                HeatMap[armyIndex][x][z].lastScouted = GetGameTimeSeconds()
                HeatMap[armyIndex][x][z].scoutedBy = false
                HeatMap[armyIndex][x][z].scouted = true
            end
        end
    end
end

function SetLastScoutedDistance(armyIndex, position, scoutRadius)
    local gridX, gridZ = GetHeatMapGridIndexFromPosition(position)
    local offsetX = math.floor((scoutRadius / HeatMapGridSizeX) + 0.5) - 1
    local offsetZ = math.floor((scoutRadius / HeatMapGridSizeZ) + 0.5) - 1
    offsetX = math.max(offsetX, 0)
    offsetZ = math.max(offsetZ, 0)
    --AIWarn('* AI-Uveso: SetLastScoutedDistance(): HeatMapGridSizeX['..HeatMapGridSizeX..'] scoutRadius['..scoutRadius..']', true)
    --AIWarn('* AI-Uveso: SetLastScoutedDistance(): gridX['..gridX..'] gridZ['..gridZ..']', true)
    --AIWarn('* AI-Uveso: SetLastScoutedDistance(): offsetX['..offsetX..'] offsetZ['..offsetZ..']', true)
    for x = gridX - offsetX, gridX + offsetX do
        for z = gridZ - offsetZ, gridZ + offsetZ do
            --AIWarn('* AI-Uveso: SetLastScoutedDistance(): checking grid HeatMap['..armyIndex..']['..x..']['..z..']', true)
            if HeatMap[armyIndex][x][z] then
                local gridCenterPos = GetHeatMapGridPositionFromIndex(x, z)
                --AIWarn('* AI-Uveso: SetLastScoutedDistance(): gridCenterPos ('..repr(gridCenterPos)..')', true)
                local dist = VDist2(position.x, position.z, gridCenterPos[1], gridCenterPos[3])
                --AIWarn('* AI-Uveso: SetLastScoutedDistance(): dist ('..dist..') - scoutRadius('..scoutRadius..')', true)
                if dist < scoutRadius then
                    --AIWarn('* AI-Uveso: SetLastScoutedDistance(): Grid['..x..']['..z..'] scoutRadius='..scoutRadius..' - dist='..dist..' TRUE', true)
                    HeatMap[armyIndex][x][z].lastScouted = GetGameTimeSeconds()
                    HeatMap[armyIndex][x][z].scoutedBy = false
                    HeatMap[armyIndex][x][z].scouted = true
                else
                    --AIWarn('* AI-Uveso: SetLastScoutedDistance(): Grid['..x..']['..z..'] scoutRadius='..scoutRadius..' - dist='..dist..' FALSE', true)
                end
            end
        end
    end
end

function SetWillBeScoutedFrom(armyIndex, position, EntityId)
    --AIWarn('* AI-Uveso: SetWillBeScoutedFrom(): position '..repr(position), true)
    local gridX, gridZ = GetHeatMapGridIndexFromPosition(position)
    --AIWarn('* AI-Uveso: SetWillBeScoutedFrom(): Grid['..gridX..']['..gridZ..'] will be scouted from '..repr(EntityId), true)
    HeatMap[armyIndex][gridX][gridZ].scoutedBy = EntityId
    HeatMap[armyIndex][gridX][gridZ].lastScoutOrder = GetGameTimeSeconds()
end

function GetLastScoutOrder(armyIndex, position)
    local gridX, gridZ = GetHeatMapGridIndexFromPosition(position)
    return HeatMap[armyIndex][gridX][gridZ].lastScoutOrder
end

function GetLastScoutBy(armyIndex, position)
    local gridX, gridZ = GetHeatMapGridIndexFromPosition(position)
    return HeatMap[armyIndex][gridX][gridZ].scoutedBy
end

function ArmyScouting(aiBrain, armyIndex)
    local armyUnits, position, gridX, gridZ, loopCount, visionRadius, maxVisionRadius, radarRadius, scoutRadius
    while true do
        coroutine.yield(10)
        armyUnits = aiBrain:GetListOfUnits((categories.MOBILE + categories.STRUCTURE) - categories.SCOUT, false, false)
        loopCount = 0
        for _, unit in armyUnits do
            if not unit.Dead then
                position = unit:GetPosition()
                gridX, gridZ = GetHeatMapGridIndexFromPosition(position)
                visionRadius = unit.Blueprint.Intel.VisionRadius or 1
                radarRadius = unit.Blueprint.Intel.RadarRadius or 1
                maxVisionRadius = unit.Blueprint.Intel.MaxVisionRadius or 1
                scoutRadius = math.max(visionRadius, radarRadius, maxVisionRadius)
                --AILog("Unit["..unit.UnitId.."] ("..unit.Blueprint.Description..") "..repr(unit.Blueprint.CategoriesHash))
                --AILog("Unit["..unit.UnitId.."] ("..unit.Blueprint.Description..") "..repr(unit.Blueprint.Intel))
                --does the unit need energy to generate intel?
                energyOK = false
                if unit.Blueprint.Economy.MaintenanceConsumptionPerSecondEnergy > 0 then
                    --do we have energy to work?
                    if unit:GetResourceConsumed() == 1 then
                        energyOK = true
                    end
                else
                    energyOK = true
                end
                --in case we have energy or the unit does not need energy, update the scout area
                if energyOK and scoutRadius >= 15 then
                    --AILog("* AI-Uveso: ArmyScouting(): energyOK:"..repr(energyOK).." scoutRadius:"..scoutRadius.." Position:"..position.x..", "..position.z)
                    SetLastScoutedDistance(armyIndex, position, scoutRadius)
                end
            end
            loopCount = loopCount + 1
            if loopCount > 50 then -- 50
                --AIWarn('* ArmyScouting: loopCount: '..loopCount..'  ')
                coroutine.yield(1)
                loopCount = 0
            end
        end
    end
end
