-- hook for additional build conditions used from AIBuilders

local MAPBASEPOSTITIONS = {}
local mapSizeX, mapSizeZ = GetMapSize()

--{ UCBC, 'CanBuildCategory', { categories.RADAR * categories.TECH1 } },
local FactionIndexToCategory = {[1] = categories.UEF, [2] = categories.AEON, [3] = categories.CYBRAN, [4] = categories.SERAPHIM, [5] = categories.NOMADS, [6] = categories.ARM, [7] = categories.CORE }
function CanBuildCategory(aiBrain,category)
    -- convert text categories like 'MOBILE AIR' to 'categories.MOBILE * categories.AIR'
    local FactionCat = FactionIndexToCategory[aiBrain:GetFactionIndex()] or categories.ALLUNITS
    local numBuildableUnits = table.getn(EntityCategoryGetUnitList(category * FactionCat)) or -1
    --LOG('* CanBuildCategory: FactionIndex: ('..repr(aiBrain:GetFactionIndex())..') numBuildableUnits:'..numBuildableUnits..' - '..repr( EntityCategoryGetUnitList(category * FactionCat) ))
    return numBuildableUnits > 0
end

--            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.RADAR * categories.TECH1 }},
function HaveUnitsInCategoryBeingUpgrade(aiBrain, numunits, category, compareType)
    -- get all units matching 'category'
    local unitsBuilding = aiBrain:GetListOfUnits(category, false)
    local numBuilding = 0
    -- own armyIndex
    local armyIndex = aiBrain:GetArmyIndex()
    -- loop over all units and search for upgrading units
    for unitNum, unit in unitsBuilding do
        if not unit.Dead and not unit:BeenDestroyed() and unit:IsUnitState('Upgrading') and unit:GetAIBrain():GetArmyIndex() == armyIndex then
            numBuilding = numBuilding + 1
        end
    end
    --LOG(aiBrain:GetArmyIndex()..' HaveUnitsInCategoryBeingUpgrade ( '..numBuilding..' '..compareType..' '..numunits..' ) --  return '..repr(CompareBody(numBuilding, numunits, compareType))..' ')
    return CompareBody(numBuilding, numunits, compareType)
end
function HaveLessThanUnitsInCategoryBeingUpgrade(aiBrain, numunits, category)
    return HaveUnitsInCategoryBeingUpgrade(aiBrain, numunits, category, '<')
end
function HaveGreaterThanUnitsInCategoryBeingUpgrade(aiBrain, numunits, category)
    return HaveUnitsInCategoryBeingUpgrade(aiBrain, numunits, category, '>')
end

-- function GreaterThanGameTime(aiBrain, num) is multiplying the time by 0.5, if we have an cheat AI. But i need the real time here.
--            { UCBC, 'GreaterThanGameTimeSeconds', { 180 } },
function GreaterThanGameTimeSeconds(aiBrain, num)
    if num < GetGameTimeSeconds() then
        return true
    end
    return false
end
--            { UCBC, 'LessThanGameTimeSeconds', { 180 } },
function LessThanGameTimeSeconds(aiBrain, num)
    if num > GetGameTimeSeconds() then
        return true
    end
    return false
end

--            { UCBC, 'HaveUnitRatioVersusCap', { 0.024, '<=', categories.STRUCTURE * categories.FACTORY * categories.LAND } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
function HaveUnitRatioVersusCap(aiBrain, ratio, compareType, categoryOwn)
    local numOwnUnits = aiBrain:GetCurrentUnits(categoryOwn)
    local cap = GetArmyUnitCap(aiBrain:GetArmyIndex())
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {World} ( '..numOwnUnits..' '..compareType..' '..cap..' ) -- ['..ratio..'] -- '..repr(DEBUG)..' :: '..(numOwnUnits / cap)..' '..compareType..' '..cap..' return '..repr(CompareBody(numOwnUnits / cap, ratio, compareType)))
    return CompareBody(numOwnUnits / cap, ratio, compareType)
end

--             { UCBC, 'HaveUnitRatioUveso', { 0.75, 'MASSEXTRACTION TECH1', '<=','MASSEXTRACTION TECH2',true } },
function HaveUnitRatioUveso(aiBrain, ratio, categoryOne, compareType, categoryTwo)
    local numOne = aiBrain:GetCurrentUnits(categoryOne)
    local numTwo = aiBrain:GetCurrentUnits(categoryTwo)
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {World} ( '..numOne..' '..compareType..' '..numTwo..' ) -- ['..ratio..'] -- '..categoryOne..' '..compareType..' '..categoryTwo..' ('..(numOne / numTwo)..' '..compareType..' '..ratio..' ?) return '..repr(CompareBody(numOne / numTwo, ratio, compareType)))
    return CompareBody(numOne / numTwo, ratio, compareType)
end

function HaveUnitRatioVersusEnemy(aiBrain, ratio, categoryOwn, compareType, categoryEnemy)
    if ScenarioInfo.Options.OmniCheat == "off" and aiBrain:GetCurrentUnits(categories.STRUCTURE * categories.OMNI) == 0 then
        return true
    end
    local numOwnUnits = aiBrain:GetCurrentUnits(categoryOwn)
    local numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(categoryEnemy, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ , 'Enemy')
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {World} ( '..numOwnUnits..' '..compareType..' '..numEnemyUnits..' ) -- ['..ratio..'] -- return '..repr(CompareBody(numOwnUnits / numEnemyUnits, ratio, compareType)))
    return CompareBody(numOwnUnits / numEnemyUnits, ratio, compareType)
end

function HaveUnitRatioAtLocation(aiBrain, locType, ratio, categoryNeed, compareType, categoryHave)
    local AIName = ArmyBrains[aiBrain:GetArmyIndex()].Nickname
    local baseposition, radius
    if MAPBASEPOSTITIONS[AIName][locType] then
        baseposition = MAPBASEPOSTITIONS[AIName][locType].Pos
        radius = MAPBASEPOSTITIONS[AIName][locType].Rad
    elseif aiBrain.BuilderManagers[locType] then
        baseposition = aiBrain.BuilderManagers[locType].FactoryManager.Location
        radius = aiBrain.BuilderManagers[locType].FactoryManager:GetLocationRadius()
        MAPBASEPOSTITIONS[AIName] = MAPBASEPOSTITIONS[AIName] or {} 
        MAPBASEPOSTITIONS[AIName][locType] = {Pos=baseposition, Rad=radius}
    elseif aiBrain:PBMHasPlatoonList() then
        for k,v in aiBrain.PBM.Locations do
            if v.LocationType == locType then
                baseposition = v.Location
                radius = v.Radius
                MAPBASEPOSTITIONS[AIName] = MAPBASEPOSTITIONS[AIName] or {} 
                MAPBASEPOSTITIONS[AIName][locType] = {baseposition, radius}
                break
            end
        end
    end
    if not baseposition then
        return false
    end
    local numNeedUnits = aiBrain:GetNumUnitsAroundPoint(categoryNeed, baseposition, radius , 'Ally')
    local numHaveUnits = aiBrain:GetNumUnitsAroundPoint(categoryHave, baseposition, radius , 'Ally')
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {'..locType..'} ( '..numNeedUnits..' '..compareType..' '..numHaveUnits..' ) -- ['..ratio..'] -- '..categoryNeed..' '..compareType..' '..categoryHave..' return '..repr(CompareBody(numNeedUnits / numHaveUnits, ratio, compareType)))
    return CompareBody(numNeedUnits / numHaveUnits, ratio, compareType)
end

-- 0.8 = 4:5
--{ UCBC, 'HaveUnitRatioAtLocationRadiusVersusEnemy', { 1.50, 'LocationType', 90, 'STRUCTURE DEFENSE ANTIMISSILE TECH3', '<','SILO NUKE TECH3' } },
function HaveUnitRatioAtLocationRadiusVersusEnemy(aiBrain, ratio, locType, radius, categoryOwn, compareType, categoryEnemy)
    local AIName = ArmyBrains[aiBrain:GetArmyIndex()].Nickname
    local baseposition, radius
    if MAPBASEPOSTITIONS[AIName][locType] then
        baseposition = MAPBASEPOSTITIONS[AIName][locType].Pos
        radius = MAPBASEPOSTITIONS[AIName][locType].Rad
    elseif aiBrain.BuilderManagers[locType] then
        baseposition = aiBrain.BuilderManagers[locType].FactoryManager.Location
        radius = aiBrain.BuilderManagers[locType].FactoryManager:GetLocationRadius()
        MAPBASEPOSTITIONS[AIName] = MAPBASEPOSTITIONS[AIName] or {} 
        MAPBASEPOSTITIONS[AIName][locType] = {Pos=baseposition, Rad=radius}
    elseif aiBrain:PBMHasPlatoonList() then
        for k,v in aiBrain.PBM.Locations do
            if v.LocationType == locType then
                baseposition = v.Location
                radius = v.Radius
                MAPBASEPOSTITIONS[AIName] = MAPBASEPOSTITIONS[AIName] or {} 
                MAPBASEPOSTITIONS[AIName][locType] = {baseposition, radius}
                break
            end
        end
    end
    if not baseposition then
        return false
    end
    local numNeedUnits = aiBrain:GetNumUnitsAroundPoint(categoryOwn, baseposition, radius , 'Ally')
    local numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(categoryEnemy, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ , 'Enemy')
    return CompareBody(numNeedUnits / numEnemyUnits, ratio, compareType)
end

--            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MASSEXTRACTION} },
function HavePoolUnitInArmy(aiBrain, unitCount, unitCategory, compareType)
    local poolPlatoon = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
    local numUnits = poolPlatoon:GetNumCategoryUnits(unitCategory)
    --LOG('* HavePoolUnitInArmy: numUnits= '..numUnits) 
    return CompareBody(numUnits, unitCount, compareType)
end
function HaveLessThanArmyPoolWithCategory(aiBrain, unitCount, unitCategory)
    return HavePoolUnitInArmy(aiBrain, unitCount, unitCategory, '<')
end
function HaveGreaterThanArmyPoolWithCategory(aiBrain, unitCount, unitCategory)
    return HavePoolUnitInArmy(aiBrain, unitCount, unitCategory, '>')
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

function HaveEnemyUnitAtLocation(aiBrain, radius, locationType, unitCount, categoryEnemy, compareType)
    if not aiBrain.BuilderManagers[locationType] then
        WARN('*AI WARNING: HaveEnemyUnitAtLocation - Invalid location - ' .. locationType)
        return false
    elseif not aiBrain.BuilderManagers[locationType].Position then
        WARN('*AI WARNING: HaveEnemyUnitAtLocation - Invalid position - ' .. locationType)
        return false
    end
    local numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(categoryEnemy, aiBrain.BuilderManagers[locationType].Position, radius , 'Enemy')
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {World} radius:['..radius..'] '..repr(DEBUG)..' ['..numEnemyUnits..'] '..compareType..' ['..unitCount..'] return '..repr(CompareBody(numEnemyUnits, unitCount, compareType)))
    return CompareBody(numEnemyUnits, unitCount, compareType)
end
--            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.LAND }}, -- radius, LocationType, unitCount, categoryEnemy
function EnemyUnitsGreaterAtLocationRadius(aiBrain, radius, locationType, unitCount, categoryEnemy)
    return HaveEnemyUnitAtLocation(aiBrain, radius, locationType, unitCount, categoryEnemy, '>')
end
--            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND }}, -- radius, LocationType, unitCount, categoryEnemy
function EnemyUnitsLessAtLocationRadius(aiBrain, radius, locationType, unitCount, categoryEnemy)
    return HaveEnemyUnitAtLocation(aiBrain, radius, locationType, unitCount, categoryEnemy, '<')
end

--            { UCBC, 'UnitsLessAtEnemy', { 1 , 'MOBILE EXPERIMENTAL' } },
--            { UCBC, 'UnitsGreaterAtEnemy', { 1 , 'MOBILE EXPERIMENTAL' } },
function GetEnemyUnits(aiBrain, unitCount, categoryEnemy, compareType)
    local numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(categoryEnemy, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ , 'Enemy')
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {World} '..categoryEnemy..' ['..numEnemyUnits..'] '..compareType..' ['..unitCount..'] return '..repr(CompareBody(numEnemyUnits, unitCount, compareType)))
    return CompareBody(numEnemyUnits, unitCount, compareType)
end
function UnitsLessAtEnemy(aiBrain, unitCount, categoryEnemy)
    return GetEnemyUnits(aiBrain, unitCount, categoryEnemy, '<')
end
function UnitsGreaterAtEnemy(aiBrain, unitCount, categoryEnemy)
    return GetEnemyUnits(aiBrain, unitCount, categoryEnemy, '>')
end

--            { UCBC, 'EngineerManagerUnitsAtLocation', { 'MAIN', '<=', 100,  'ENGINEER TECH3' } },
function EngineerManagerUnitsAtLocation(aiBrain, LocationType, compareType, numUnits, category)
    local numEngineers = aiBrain.BuilderManagers[LocationType].EngineerManager:GetNumCategoryUnits('Engineers', category)
    --LOG('* EngineerManagerUnitsAtLocation: '..LocationType..' ( engineers: '..numEngineers..' '..compareType..' '..numUnits..' ) -- '..category..' return '..repr(CompareBody( numEngineers, numUnits, compareType )) )
    return CompareBody( numEngineers, numUnits, compareType )
end

--            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
function BuildOnlyOnLocation(aiBrain, LocationType, AllowedLocationType)
    --LOG('* BuildOnlyOnLocation: we are on location '..LocationType..', Allowed locations are: '..AllowedLocationType..'')
    if string.find(LocationType, AllowedLocationType) then
        return true
    end
    return false
end
--            { UCBC, 'BuildNotOnLocation', { 'LocationType', 'MAIN' } },
function BuildNotOnLocation(aiBrain, LocationType, ForbiddenLocationType)
    if string.find(LocationType, ForbiddenLocationType) then
        --LOG('* BuildOnlyOnLocation: we are on location '..LocationType..', forbidden locations are: '..ForbiddenLocationType..'. return false (don\'t build it)')
        return false
    end
    --LOG('* BuildOnlyOnLocation: we are on location '..LocationType..', forbidden locations are: '..ForbiddenLocationType..'. return true (OK, build it)')
    return true
end

function HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation(aiBrain, locationType, numReq, category, constructionCat)
    local numUnits
    if constructionCat then
        numUnits = table.getn( GetUnitsBeingBuiltLocation(aiBrain, locationType, category, category + (categories.ENGINEER * categories.MOBILE - categories.STATIONASSISTPOD) + constructionCat) or {} )
    else
        numUnits = table.getn( GetUnitsBeingBuiltLocation(aiBrain,locationType, category, category + (categories.ENGINEER * categories.MOBILE - categories.STATIONASSISTPOD) ) or {} )
    end
    if numUnits > numReq then
        return true
    end
    return false
end

function GetUnitsBeingBuiltLocation(aiBrain, locType, buildingCategory, builderCategory)
    local AIName = ArmyBrains[aiBrain:GetArmyIndex()].Nickname
    local baseposition, radius
    if MAPBASEPOSTITIONS[AIName][locType] then
        baseposition = MAPBASEPOSTITIONS[AIName][locType].Pos
        radius = MAPBASEPOSTITIONS[AIName][locType].Rad
    elseif aiBrain.BuilderManagers[locType] then
        baseposition = aiBrain.BuilderManagers[locType].FactoryManager.Location
        radius = aiBrain.BuilderManagers[locType].FactoryManager:GetLocationRadius()
        MAPBASEPOSTITIONS[AIName] = MAPBASEPOSTITIONS[AIName] or {} 
        MAPBASEPOSTITIONS[AIName][locType] = {Pos=baseposition, Rad=radius}
    elseif aiBrain:PBMHasPlatoonList() then
        for k,v in aiBrain.PBM.Locations do
            if v.LocationType == locType then
                baseposition = v.Location
                radius = v.Radius
                MAPBASEPOSTITIONS[AIName] = MAPBASEPOSTITIONS[AIName] or {} 
                MAPBASEPOSTITIONS[AIName][locType] = {baseposition, radius}
                break
            end
        end
    end
    if not baseposition then
        return false
    end
    local filterUnits = GetOwnUnitsAroundLocation(aiBrain, builderCategory, baseposition, radius)
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

function GetOwnUnitsAroundLocation(aiBrain, category, location, radius)
    local units = aiBrain:GetUnitsAroundPoint(category, location, radius, 'Ally')
    local index = aiBrain:GetArmyIndex()
    local retUnits = {}
    for _, v in units do
        if not v.Dead and v:GetAIBrain():GetArmyIndex() == index then
            table.insert(retUnits, v)
        end
    end
    return retUnits
end

function HaveLessThanIdleEngineers(aiBrain, count, tech)
    local ENGINEER = aiBrain:GetListOfUnits(categories.ENGINEER - categories.STATIONASSISTPOD, true, false)
    local engineers = {}
    engineers[5] = EntityCategoryFilterDown(categories.SUBCOMMANDER, ENGINEER)
    engineers[4] = EntityCategoryFilterDown(categories.TECH3 - categories.SUBCOMMANDER, ENGINEER)
    engineers[3] = EntityCategoryFilterDown(categories.FIELDENGINEER, ENGINEER)
    engineers[2] = EntityCategoryFilterDown(categories.TECH2 - categories.FIELDENGINEER, ENGINEER)
    engineers[1] = EntityCategoryFilterDown(categories.TECH1 - categories.COMMAND, ENGINEER)
    local c = 0
    for _, v in engineers[tech] do
        if v:IsIdleState() then
            c=c+1
        end
    end
    --LOG('tech '..tech..' - Eng='..table.getn(engineers[tech])..' - idle='..c..' == '..repr(c < count))
    return c < count
end

--            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.STRUCTURE * categories.FACTORY * categories.NAVAL }}, -- radius, LocationType, categoryUnits
function NavalBaseWithLeastUnits(aiBrain, radius, locationType, unitCategory)
    local startmarker = AIUtils.AIGetMarkerLocations(aiBrain, 'Start Location')
    local navalmarker = AIUtils.AIGetMarkerLocations(aiBrain, 'Naval Area')
    local marker = table.merged( navalmarker , startmarker )
    local lowloc
    local lownum
    local baseManagerName
    for baseLocation, managers in aiBrain.BuilderManagers do
        for index, marker in marker do
            if marker.Name == 'ARMY_'..aiBrain:GetArmyIndex() then
                baseManagerName = 'MAIN'
            else
                baseManagerName = marker.Name
            end
            --LOG('Checking location Manger '..baseManagerName)
            if baseManagerName == baseLocation then
                local pos = aiBrain.BuilderManagers[baseLocation].FactoryManager.Location
                --LOG('Found location Manger '..baseManagerName..' - '..repr(pos))
                --search for idle factories
                local numFactory = 0
                local Factories = GetOwnUnitsAroundLocation(aiBrain, categories.STRUCTURE * categories.FACTORY * categories.NAVAL, pos, radius)
                for _, Factory in Factories do
                    if not Factory.Dead then
                        if Factory:IsIdleState() then
                            numFactory = numFactory + 1
                            -- we found a factory that can potentially build units on this location
                            break
                        end
                    end
                end
                --LOG('numFactory: '..numFactory)
                if numFactory < 1 then continue end
                local numUnits = aiBrain:GetNumUnitsAroundPoint(unitCategory, pos, radius , 'Ally')
                --LOG('numUnits: '..numUnits)
                if not lownum or lownum > numUnits then
                    lowloc = baseLocation
                    lownum = numUnits
                end
            end
        end
    end
    --LOG('Checking location: '..repr(locationType)..' - Location with lowest units: '..repr(lowloc)..' - AI:'..ArmyBrains[aiBrain:GetArmyIndex()].Nickname)
    return locationType == lowloc
end

--            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.NAVAL }}, -- LocationType, categoryUnits
function CanPathNavalBaseToNavalTargets(aiBrain, locationType, unitCategory)
    local AIAttackUtils = import('/lua/AI/aiattackutilities.lua')
    baseposition = aiBrain.BuilderManagers[locationType].FactoryManager.Location
    local Factories = aiBrain.BuilderManagers[locationType].FactoryManager:GetFactories(categories.NAVAL)
    if Factories[1] then
        baseposition = Factories[1]:GetPosition()
    end
    --LOG('Searching water path from base ['..locationType..'] position '..repr(baseposition))
    local EnemyNavalUnits = aiBrain:GetUnitsAroundPoint(unitCategory, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
    local path, reason
    for _, EnemyUnit in EnemyNavalUnits do
        if not EnemyUnit.Dead then
            --LOG('checking enemy factories '..repr(EnemyUnit:GetPosition()))
            path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Water', baseposition, EnemyUnit:GetPosition(), 1)
            --LOG('reason'..repr(reason))
            if path then
                --LOG('Found a water path from base ['..locationType..'] to enemy position '..repr(EnemyUnit:GetPosition()))
                return true
            end
        end
    end
    --LOG('Found no path to any target from naval base ['..locationType..']')
    return false
end

--            { UCBC, 'UnfinishedUnitsAtLocation', { 'LocationType' }},
function UnfinishedUnitsAtLocation(aiBrain, locationType)
    local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
    if not engineerManager then
        --WARN('*AI WARNING: UnfinishedUnitsAtLocation: Invalid location - ' .. locationType)
        return false
    end
    local unfinishedUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE + categories.EXPERIMENTAL, engineerManager.Location, engineerManager.Radius, 'Ally')
    for num, unit in unfinishedUnits do
        local FractionComplete = unit:GetFractionComplete()
        if FractionComplete < 1 and table.getn(unit:GetGuards()) < 1 then
            return true
        end
    end
    return false
end

--            { UCBC, 'UnitsLessInPlatoon', {} },
function UnitsLessInPlatoon(aiBrain,PlatoonPlan, num, cat)
    local SearchCat = cat or categories.ALLUNITS
    local PlatoonList = aiBrain:GetPlatoonsList()
    local NumPlatoonUnits = 0
    local PlatoonFound
    for Li,Platoon in PlatoonList do
        --LOG('* UnitsLessInPlatoon: Found Platoon: '..repr(Platoon:GetPlan()))
        if Platoon:GetPlan() == PlatoonPlan then
            PlatoonFound = true
            for Ui,Unit in Platoon:GetPlatoonUnits() or {} do
                if EntityCategoryContains(cat, Unit) then
                    NumPlatoonUnits = NumPlatoonUnits + 1
                end
            end
            break
        end
    end
    if not PlatoonFound then
        --LOG('* UnitsLessInPlatoon: Platoon ('..PlatoonPlan..') not found.')
        -- in case the platoon is not formed yet, just return false.
        -- so the platoonformer does not try to add the unit to an non existing platoon
        return false
    end
    if NumPlatoonUnits < num then
        --LOG('* UnitsLessInPlatoon: TRUE Units in platoon ('..PlatoonPlan..'): '..NumPlatoonUnits..'/'..num)
        return true
    end
    --LOG('* UnitsLessInPlatoon: FALSE Units in platoon('..PlatoonPlan..'): '..NumPlatoonUnits..'/'..num)
    return false
end

function CDRHealthLessThan(aiBrain, health)
    local cdr = aiBrain:GetListOfUnits(categories.COMMAND, false)[1]
    if cdr.Dead or not cdr.BeenDestroyed or cdr:BeenDestroyed() then
        return false
    end
    local armorPercent = 100 / cdr:GetMaxHealth() * cdr:GetHealth()
    local shieldPercent = armorPercent
    if cdr.MyShield then
        shieldPercent = 100 / cdr.MyShield:GetMaxHealth() * cdr.MyShield:GetHealth()
    end
    return math.floor(( armorPercent + shieldPercent ) / 2) < health
end
