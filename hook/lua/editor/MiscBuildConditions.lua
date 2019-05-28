
local BASEPOSTITIONS = {}

--            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
function BuildOnlyOnLocation(aiBrain, LocationType, AllowedLocationType)
    --LOG('* BuildOnlyOnLocation: we are on location '..LocationType..', Allowed locations are: '..AllowedLocationType..'')
    if string.find(LocationType, AllowedLocationType) then
        return true
    end
    return false
end

--            { UCBC, 'BuildNotOnLocation', { 'LocationType', 'MAIN' } },
function BuildNotOnLocation(aiBrain, LocationType, ForbiddenLocationType, DEBUG)
    if string.find(LocationType, ForbiddenLocationType) then
        if DEBUG then
            LOG('* BuildOnlyOnLocation: we are on location '..LocationType..', forbidden locations are: '..ForbiddenLocationType..'. return false (don\'t build it)')
        end
        return false
    end
    if DEBUG then
        LOG('* BuildOnlyOnLocation: we are on location '..LocationType..', forbidden locations are: '..ForbiddenLocationType..'. return true (OK, build it)')
    end
    return true
end

--Highest:0.00048828125 - Average:0.00048828125 - Actual:0.00048828125
--{ UCBC, 'CanBuildCategory', { categories.RADAR * categories.TECH1 } },
local FactionIndexToCategory = {[1] = categories.UEF, [2] = categories.AEON, [3] = categories.CYBRAN, [4] = categories.SERAPHIM, [5] = categories.NOMADS }
function CanBuildCategory(aiBrain,category)
    local FactionCat = FactionIndexToCategory[aiBrain:GetFactionIndex()] or categories.ALLUNITS
    local numBuildableUnits = table.getn(EntityCategoryGetUnitList(category * FactionCat)) or -1
    --LOG('* CanBuildCategory: FactionIndex: ('..repr(aiBrain:GetFactionIndex())..') numBuildableUnits:'..numBuildableUnits..' - '..repr( EntityCategoryGetUnitList(category * FactionCat) ))
    return numBuildableUnits > 0
end

-- Uveso AI. Function to see if we are on a water map and/or can't send Land units to the enemy
local CanPathToEnemy = {}
function CanPathToCurrentEnemy(aiBrain, bool)
    local AIAttackUtils = import('/lua/AI/aiattackutilities.lua')
    local startX, startZ = aiBrain:GetArmyStartPos()
    local enemyX, enemyZ
    if aiBrain:GetCurrentEnemy() then
        enemyX, enemyZ = aiBrain:GetCurrentEnemy():GetArmyStartPos()
        -- if we don't have an enemy position then we can't search for a path. Return until we have an enemy position
        if not enemyX then
            return false
        end
    else
        -- if we don't have a current enemy then return false
        return false
    end

    -- Get the armyindex from the enemy
    local EnemyIndex = ArmyBrains[aiBrain:GetCurrentEnemy():GetArmyIndex()].Nickname
    local OwnIndex = ArmyBrains[aiBrain:GetArmyIndex()].Nickname

    -- create a table for the enemy index in case it's nil
    CanPathToEnemy[OwnIndex] = CanPathToEnemy[OwnIndex] or {} 
    -- Check if we have already done a path search to the current enemy
    if CanPathToEnemy[OwnIndex][EnemyIndex] == 'LAND' then
        return true == bool
    elseif CanPathToEnemy[OwnIndex][EnemyIndex] == 'WATER' then
        return false == bool
    end

    -- path wit AI markers from our base to the enemy base
    local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Land', {startX,0,startZ}, {enemyX,0,enemyZ}, 1000)
    -- if we have a path generated with AI path markers then....
    if path then
        LOG('* AI-Uveso: CanPathToCurrentEnemy: Land path to the enemy found! LAND map! - '..OwnIndex..' vs '..EnemyIndex..'')
        CanPathToEnemy[OwnIndex][EnemyIndex] = 'LAND'
    -- if we not have a path
    else
        -- "NoPath" means we have AI markers but can't find a path to the enemy - There is no path!
        if reason == 'NoPath' then
            LOG('* AI-Uveso: CanPathToCurrentEnemy: No land path to the enemy found! WATER map! - '..OwnIndex..' vs '..EnemyIndex..'')
            CanPathToEnemy[OwnIndex][EnemyIndex] = 'WATER'
        -- "NoGraph" means we have no AI markers and cant graph to the enemy. We can't search for a path - No markers
        elseif reason == 'NoGraph' then
            LOG('* AI-Uveso: CanPathToCurrentEnemy: No AI markers found! Using land/water ratio instead')
            -- Check if we have less then 50% water on the map
            if aiBrain:GetMapWaterRatio() < 0.50 then
                --lets asume we can move on land to the enemy
                LOG(string.format('* AI-Uveso: CanPathToCurrentEnemy: Water on map: %0.2f%%. Assuming LAND map! - '..OwnIndex..' vs '..EnemyIndex..'',aiBrain:GetMapWaterRatio()*100 ))
                CanPathToEnemy[OwnIndex][EnemyIndex] = 'LAND'
            else
                -- we have more then 50% water on this map. Ity maybe a water map..
                LOG(string.format('* AI-Uveso: CanPathToCurrentEnemy: Water on map: %0.2f%%. Assuming WATER map! - '..OwnIndex..' vs '..EnemyIndex..'',aiBrain:GetMapWaterRatio()*100 ))
                CanPathToEnemy[OwnIndex][EnemyIndex] = 'WATER'
            end
        end
    end
    if CanPathToEnemy[OwnIndex][EnemyIndex] == 'LAND' then
        return true == bool
    elseif CanPathToEnemy[OwnIndex][EnemyIndex] == 'WATER' then
        return false == bool
    end
    CanPathToEnemy[OwnIndex][EnemyIndex] = 'WATER'
    return false == bool
end

function HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation(aiBrain, locationType, numReq, category, constructionCat)
    local cat = category
    if type(category) == 'string' then
        cat = ParseEntityCategory(category)
    end
    local consCat = constructionCat
    if consCat and type(consCat) == 'string' then
        consCat = ParseEntityCategory(constructionCat)
    end
    local numUnits
    if consCat then
        numUnits = table.getn( GetUnitsBeingBuiltLocation(aiBrain, locationType, cat, cat + categories.ENGINEER * categories.MOBILE + consCat) or {} )
    else
        numUnits = table.getn( GetUnitsBeingBuiltLocation(aiBrain,locationType, cat, cat + categories.ENGINEER * categories.MOBILE ) or {} )
    end
    if numUnits > numReq then
        return true
    end
    return false
end

function GetUnitsBeingBuiltLocation(aiBrain, locationType, buildingCategory, builderCategory)
    local LocationPosition, Radius
    if aiBrain.BuilderManagers[locationType] then
        LocationPosition = aiBrain.BuilderManagers[locationType].FactoryManager:GetLocationCoords()
        Radius = aiBrain.BuilderManagers[locationType].FactoryManager:GetLocationRadius()
    elseif aiBrain:PBMHasPlatoonList() then
        for k,v in aiBrain.PBM.Locations do
            if v.LocationType == locationType then
                LocationPosition = v.Location
                Radius = v.Radius
                break
            end
        end
    end
    if not LocationPosition then
        return false
    end
    local filterUnits = GetOwnUnitsAroundLocation(aiBrain, builderCategory, LocationPosition, Radius)
    local retUnits = {}
    for k,v in filterUnits do
        -- Only assist if allowed
        if v.DesiresAssist == false then
            continue
        end
        -- Engineer doesn't want any more assistance
        if v.NumAssistees and table.getn(v:GetGuards()) >= v.NumAssistees then
            continue
        end
        -- skip the unit, if it's not building or upgrading.
        if not v:IsUnitState('Building') and not v:IsUnitState('Upgrading') then
            continue
        end
        local beingBuiltUnit = v.UnitBeingBuilt
        if not beingBuiltUnit or not EntityCategoryContains(buildingCategory, beingBuiltUnit) then
            continue
        end
        table.insert(retUnits, v)
    end
    return retUnits
end
function GetOwnUnitsAroundLocation(aiBrain, category, LocationPosition, radius)
    local units = aiBrain:GetUnitsAroundPoint(category, LocationPosition, radius, 'Ally')
    local index = aiBrain:GetArmyIndex()
    local retUnits = {}
    for _, v in units do
        if not v.Dead and v:GetAIBrain():GetArmyIndex() == index then
            table.insert(retUnits, v)
        end
    end
    return retUnits
end

--            { UCBC, 'UnitsLessAtEnemy', { 1 , 'MOBILE EXPERIMENTAL' } },
--            { UCBC, 'UnitsGreaterAtEnemy', { 1 , 'MOBILE EXPERIMENTAL' } },
function GetEnemyUnits(aiBrain, unitCount, categoryEnemy, compareType, DEBUG)
    local testCatEnemy = categoryEnemy
    if type(testCatEnemy) == 'string' then
        testCatEnemy = ParseEntityCategory(testCatEnemy)
    end
    local mapSizeX, mapSizeZ = GetMapSize()
    local numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(testCatEnemy, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ , 'Enemy')
    if DEBUG then
        LOG(aiBrain:GetArmyIndex()..' CompareBody {World} '..categoryEnemy..' ['..numEnemyUnits..'] '..compareType..' ['..unitCount..'] return '..repr(CompareBody(numEnemyUnits, unitCount, compareType)))
    end
    return CompareBody(numEnemyUnits, unitCount, compareType)
end
function UnitsLessAtEnemy(aiBrain, unitCount, categoryEnemy, DEBUG)
    return GetEnemyUnits(aiBrain, unitCount, categoryEnemy, '<', DEBUG)
end
function UnitsGreaterAtEnemy(aiBrain, unitCount, categoryEnemy, DEBUG)
    return GetEnemyUnits(aiBrain, unitCount, categoryEnemy, '>', DEBUG)
end

--             { UCBC, 'HaveUnitRatio', { 0.75, 'MASSEXTRACTION TECH1', '<=','MASSEXTRACTION TECH2',true } },
function HaveUnitRatioLOW(aiBrain, ratio, categoryOne, compareType, categoryTwo)
    local numOne = aiBrain:GetCurrentUnits(categoryOne)
    local numTwo = aiBrain:GetCurrentUnits(categoryTwo)
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {World} ( '..numOne..' '..compareType..' '..numTwo..' ) -- ['..ratio..'] -- '..categoryOne..' '..compareType..' '..categoryTwo..' ('..(numOne / numTwo)..' '..compareType..' '..ratio..' ?) return '..repr(CompareBody(numOne / numTwo, ratio, compareType)))
    return CompareBody(numOne / numTwo, ratio, compareType)
end

--Highest:0.0009765625 - Average:0.0009765625 - Actual:0.0009765625
--{ UCBC, 'HaveUnitRatioAtLocationRadiusVersusEnemy', { 1.50, 'LocationType', 90, 'STRUCTURE DEFENSE ANTIMISSILE TECH3', '<','SILO NUKE TECH3' } },
function HaveUnitRatioAtLocationRadiusVersusEnemy(aiBrain, ratio, locType, radius, categoryOwn, compareType, categoryEnemy)
    local AIName = ArmyBrains[aiBrain:GetArmyIndex()].Nickname
    local AIName = ArmyBrains[aiBrain:GetArmyIndex()].Nickname
    local baseposition, radius
    if BASEPOSTITIONS[AIName][locType] then
        baseposition = BASEPOSTITIONS[AIName][locType].Pos
        radius = BASEPOSTITIONS[AIName][locType].Rad
    elseif aiBrain.BuilderManagers[locType] then
        baseposition = aiBrain.BuilderManagers[locType].FactoryManager:GetLocationCoords()
        radius = aiBrain.BuilderManagers[locType].FactoryManager:GetLocationRadius()
        BASEPOSTITIONS[AIName] = BASEPOSTITIONS[AIName] or {} 
        BASEPOSTITIONS[AIName][locType] = {Pos=baseposition, Rad=radius}
    elseif aiBrain:PBMHasPlatoonList() then
        for k,v in aiBrain.PBM.Locations do
            if v.LocationType == locType then
                baseposition = v.Location
                radius = v.Radius
                BASEPOSTITIONS[AIName] = BASEPOSTITIONS[AIName] or {} 
                BASEPOSTITIONS[AIName][locType] = {baseposition, radius}
                break
            end
        end
    end
    if not baseposition then
        return false
    end
    local numNeedUnits = aiBrain:GetNumUnitsAroundPoint(categoryOwn, baseposition, radius , 'Ally')
    local numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(categoryEnemy, Vector(ScenarioInfo.size[1]/2,0,ScenarioInfo.size[2]/2), ScenarioInfo.size[1]+ScenarioInfo.size[2] , 'Enemy')
    return CompareBody(numNeedUnits / numEnemyUnits, ratio, compareType)
end

--            { UCBC, 'HaveUnitRatioVersusCap', { 0.024, '<=', categories.STRUCTURE * categories.FACTORY * categories.LAND } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
function HaveUnitRatioVersusCap(aiBrain, ratio, compareType, categoryOwn)
    local numOwnUnits = aiBrain:GetCurrentUnits(categoryOwn)
    local cap = GetArmyUnitCap(aiBrain:GetArmyIndex())
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {World} ( '..numOwnUnits..' '..compareType..' '..cap..' ) -- ['..ratio..'] -- '..repr(DEBUG)..' :: '..(numOwnUnits / cap)..' '..compareType..' '..cap..' return '..repr(CompareBody(numOwnUnits / cap, ratio, compareType)))
    return CompareBody(numOwnUnits / cap, ratio, compareType)
end

--            { UCBC, 'HaveUnitRatioVersusEnemy', { 2, categories.STRUCTURE * categories.NUKE, '<=', categories.STRUCTURE * categories.ANTIMISSILE } },
function HaveUnitRatioVersusEnemy(aiBrain, ratio, categoryOwn, compareType, categoryEnemy)
    local numOwnUnits = aiBrain:GetCurrentUnits(categoryOwn)
    local numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(categoryEnemy, Vector(ScenarioInfo.size[1]/2,0,ScenarioInfo.size[2]/2), ScenarioInfo.size[1]+ScenarioInfo.size[2] , 'Enemy')
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {World} ( '..numOwnUnits..' '..compareType..' '..numEnemyUnits..' ) -- ['..ratio..'] -- return '..repr(CompareBody(numOwnUnits / numEnemyUnits, ratio, compareType)))
    return CompareBody(numOwnUnits / numEnemyUnits, ratio, compareType)
end

function HaveEnemyUnitAtLocation(aiBrain, radius, locType, unitCount, categoryEnemy, compareType, DEBUG)
    local AIName = ArmyBrains[aiBrain:GetArmyIndex()].Nickname
    local baseposition, radius
    if BASEPOSTITIONS[AIName][locType] then
        baseposition = BASEPOSTITIONS[AIName][locType].Pos
        radius = BASEPOSTITIONS[AIName][locType].Rad
    elseif aiBrain.BuilderManagers[locType] then
        baseposition = aiBrain.BuilderManagers[locType].FactoryManager:GetLocationCoords()
        radius = aiBrain.BuilderManagers[locType].FactoryManager:GetLocationRadius()
        BASEPOSTITIONS[AIName] = BASEPOSTITIONS[AIName] or {} 
        BASEPOSTITIONS[AIName][locType] = {Pos=baseposition, Rad=radius}
    elseif aiBrain:PBMHasPlatoonList() then
        for k,v in aiBrain.PBM.Locations do
            if v.LocationType == locType then
                baseposition = v.Location
                radius = v.Radius
                BASEPOSTITIONS[AIName] = BASEPOSTITIONS[AIName] or {} 
                BASEPOSTITIONS[AIName][locType] = {baseposition, radius}
                break
            end
        end
    end
    if not baseposition then
        return false
    end
    local numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(categoryEnemy, baseposition, radius , 'Enemy')
--    if DEBUG then
--        LOG('Command units in base range('..radius..') count:('..numEnemyUnits..')')
--    end
    return CompareBody(numEnemyUnits, unitCount, compareType)
end
--            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.LAND }}, -- radius, LocationType, unitCount, categoryEnemy
function EnemyUnitsGreaterAtLocationRadius(aiBrain, radius, locationType, unitCount, categoryEnemy, DEBUG)
    return HaveEnemyUnitAtLocation(aiBrain, radius, locationType, unitCount, categoryEnemy, '>', DEBUG)
end
--            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND }}, -- radius, LocationType, unitCount, categoryEnemy
function EnemyUnitsLessAtLocationRadius(aiBrain, radius, locationType, unitCount, categoryEnemy, DEBUG)
    return HaveEnemyUnitAtLocation(aiBrain, radius, locationType, unitCount, categoryEnemy, '<', DEBUG)
end

function IsBrainPersonality(aiBrain, neededPersonality, bool)
    local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
    if personality == neededPersonality and bool then
        --LOG('personality = '..personality..' = true')
        return true
    elseif personality ~= neededPersonality and not bool then
        --LOG('personality not '..neededPersonality..' = true')
        return true
    end
    return false
end

--            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.STRUCTURE * categories.FACTORY * categories.NAVAL }}, -- radius, LocationType, categoryUnits
function NavalBaseWithLeastUnits(aiBrain, radius, locationType, unitCategory)
    local navalMarkers = AIUtils.AIGetMarkerLocations(aiBrain, 'Naval Area')
    local lowloc
    local lownum
    for baseLocation, managers in aiBrain.BuilderManagers do
        for index, marker in navalMarkers do
            if marker.Name == baseLocation then
                local pos = aiBrain.BuilderManagers[baseLocation].EngineerManager.Location
                local numUnits = aiBrain:GetNumUnitsAroundPoint(unitCategory, pos, radius , 'Ally')
                local numFactory = aiBrain:GetNumUnitsAroundPoint(categories.STRUCTURE * categories.FACTORY * categories.NAVAL, pos, radius , 'Ally')
                if numFactory < 1 then continue end
                if not lownum or lownum > numUnits then
                    lowloc = baseLocation
                    lownum = numUnits
                end
            end
        end
    end
    --LOG('Checking location: '..repr(locationType)..' - Location with lowest units: '..repr(lowloc))
    return locationType == lowloc
end

function ReclaimableMassInArea(aiBrain, locType)
    local ents = AIUtils.AIGetReclaimablesAroundLocation(aiBrain, locType)
    if ents and table.getn(ents) > 0 then
        for _, p in ents do
            if p.MaxMassReclaim and p.MaxMassReclaim > 1 then
                return true
            end
        end
    end
    return false
end

function ReclaimableEnergyInArea(aiBrain, locType)
    local ents = AIUtils.AIGetReclaimablesAroundLocation(aiBrain, locType)
    if ents and table.getn(ents) > 0 then
        for _, p in ents do
            if p.MaxEnergyReclaim and p.MaxEnergyReclaim > 1 then
                return true
            end
        end
    end
    return false
end

function CompareBody(numOne, numTwo, compareType)
    if compareType == '>' then
        if numOne > numTwo then
            return true
        end
    elseif compareType == '<' then
        if numOne < numTwo then
            return true
        end
    elseif compareType == '>=' then
        if numOne >= numTwo then
            return true
        end
    elseif compareType == '<=' then
        if numOne <= numTwo then
            return true
        end
    else
       error('*AI ERROR: Invalid compare type: ' .. compareType)
       return false
    end
    return false
end
