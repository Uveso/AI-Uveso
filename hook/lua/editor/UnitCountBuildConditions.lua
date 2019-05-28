local TimeHIGHEST
local TimeSUM = 0
local TimeCOUNT = 0
local TimeAVERAGE
local LastCheck = 0



-- hook for additional build conditions used from AIBuilders

local BASEPOSTITIONS = {}

--{ UCBC, 'ReturnTrue', {} },
function ReturnTrue(aiBrain)
    LOG('** true')
    return true
end

--{ UCBC, 'ReturnFalse', {} },
function ReturnFalse(aiBrain)
    LOG('** false')
    return false
end

--Highest:0.00027490234 - Average:0.000078228577971 - Actual:0.00010888671
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
    return CompareBody(numBuilding, numunits, compareType)
end
function HaveLessThanUnitsInCategoryBeingUpgrade(aiBrain, numunits, category, DEBUG)
    return HaveUnitsInCategoryBeingUpgrade(aiBrain, numunits, category, '<')
end
function HaveGreaterThanUnitsInCategoryBeingUpgrade(aiBrain, numunits, category, DEBUG)
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

--            { UCBC, 'LessThanMassTrend', { 50.0 } },
function LessThanMassTrend(aiBrain, mTrend)
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if econ.MassTrend < mTrend then
        return true
    else
        return false
    end
end

--            { UCBC, 'LessThanEnergyTrend', { 50.0 } },
function LessThanEnergyTrend(aiBrain, eTrend)
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if econ.EnergyTrend < eTrend then
        return true
    else
        return false
    end
end

--            { UCBC, 'EnergyToMassRatioIncome', { 10.0, '>=',true } },  -- True if we have 10 times more Energy then Mass income ( 100 >= 10 = true )
function EnergyToMassRatioIncome(aiBrain, ratio, compareType, DEBUG)
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if DEBUG then
        LOG(aiBrain:GetArmyIndex()..' CompareBody {World} ( E:'..(econ.EnergyIncome*10)..' '..compareType..' M:'..(econ.MassIncome*10)..' ) -- R['..ratio..'] -- return '..repr(CompareBody(econ.EnergyIncome / econ.MassIncome, ratio, compareType)))
    end
    return CompareBody(econ.EnergyIncome / econ.MassIncome, ratio, compareType)
end

--Highest:0.0009765625 - Average:0.0009765625 - Actual:0.0009765625
function HaveUnitRatioAtLocation(aiBrain, locType, ratio, categoryNeed, compareType, categoryHave)
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
    local numNeedUnits = aiBrain:GetNumUnitsAroundPoint(categoryNeed, baseposition, radius , 'Ally')
    local numHaveUnits = aiBrain:GetNumUnitsAroundPoint(categoryHave, baseposition, radius , 'Ally')
    return CompareBody(numNeedUnits / numHaveUnits, ratio, compareType)
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

--            { UCBC, 'EngineerManagerUnitsAtLocation', { 'MAIN', '<=', 100,  'ENGINEER TECH3' } },
function EngineerManagerUnitsAtLocation(aiBrain, LocationType, compareType, numUnits, category, DEBUG)
    local testCat = category
    if type(testCat) == 'string' then
        testCat = ParseEntityCategory(testCat)
    end
    local numEngineers = aiBrain.BuilderManagers[LocationType].EngineerManager:GetNumCategoryUnits('Engineers', testCat)
    if DEBUG then
        LOG('* EngineerManagerUnitsAtLocation: '..LocationType..' ( engineers: '..numEngineers..' '..compareType..' '..numUnits..' ) -- '..category..' return '..repr(CompareBody( numEngineers, numUnits, compareType )) )
    end
    return CompareBody( numEngineers, numUnits, compareType )
end

function HaveLessThanIdleEngineers(aiBrain, count, tech)
    local ENGINEER = aiBrain:GetListOfUnits(categories.ENGINEER, true, false)
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

--            { UCBC, 'HasParagon', {} },
function HasParagon(aiBrain)
    if aiBrain.HasParagon then
        return true
    end
    return false
end

--            { UCBC, 'HasNotParagon', {} },
function HasNotParagon(aiBrain)
    if not aiBrain.HasParagon then
        return true
    end
    return false
end

--                { SBC, 'CanBuildOnHydroLessThanDistance', { 'LocationType', 1000, -1000, 100, 1, 'AntiSurface', 1 }},
function CanBuildOnHydroLessThanDistance(aiBrain, locationType, distance, threatMin, threatMax, threatRings, threatType, maxNum)
    local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
    if not engineerManager then
        WARN('*AI WARNING: Invalid location - ' .. locationType)
        return false
    end
    local position = engineerManager:GetLocationCoords()

    local markerTable = AIUtils.AIGetSortedHydroLocations(aiBrain, maxNum, threatMin, threatMax, threatRings, threatType, position)
    if markerTable[1] and VDist3(markerTable[1], position) < distance then
        return true
    end
    return false
end

--            { UCBC, 'UnfinishedUnitsAtLocation', { 'LocationType' }},
function UnfinishedUnitsAtLocation(aiBrain, locationType)
    local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
    if not engineerManager then
        return false
    end
    local unfinishedUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE + categories.EXPERIMENTAL, engineerManager:GetLocationCoords(), engineerManager.Radius, 'Ally')
    for num, unit in unfinishedUnits do
        local FractionComplete = unit:GetFractionComplete()
        if FractionComplete < 1 and table.getn(unit:GetGuards()) < 1 then
            return true
        end
    end
    return false
end

--            { UCBC, 'UnitsLessInPlatoon', {} },
function UnitsLessInPlatoon(aiBrain,PlatoonPlan, num)
    local PlatoonList = aiBrain:GetPlatoonsList()
    local NumPlatoonUnits = 0
    for _,Platoon in PlatoonList do
        if Platoon:GetPlan() == PlatoonPlan then
            NumPlatoonUnits = table.getn(Platoon:GetPlatoonUnits() or 0)
            break
        end
        --LOG('* PlatoonMerger: Found '..repr(Platoon:GetPlan()))
    end
    if NumPlatoonUnits < num then
        --LOG('* UnitsLessInPlatoon: TRUE Units in platoon ('..PlatoonPlan..'): '..NumPlatoonUnits..'/'..num)
        return true
    end
    --LOG('* UnitsLessInPlatoon: FALSE Units in platoon('..PlatoonPlan..'): '..NumPlatoonUnits..'/'..num)
    return false
end

-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
-- In progess, next project, not working...
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

local timedilatation = false
function IsGameSimSpeedLow(aiBrain)
    local SystemTime = GetSystemTimeSecondsOnlyForProfileUse()
    local GameTime = GetGameTimeSeconds()
    if not timedilatation then
        timedilatation = GetSystemTimeSecondsOnlyForProfileUse() - GetGameTimeSeconds()
    end
        
    LOG('** SystemTime'..SystemTime)
    LOG('** timedilatation'..timedilatation)
    LOG('** SystemTimedilatation'..(GetSystemTimeSecondsOnlyForProfileUse()-timedilatation))
    LOG('** GameTime'..GameTime)
    
    
    LOG('** true')
    return true
end
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
-- In progess, next project, not working...
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
