
function ExtractorPause(self, aiBrain, MassExtractorUnitList, ratio, techLevel)
    local UpgradingBuilding = nil
    local UpgradingBuildingNum = 0
    local PausedUpgradingBuilding = nil
    local PausedUpgradingBuildingNum = 0
    local DisabledBuilding = nil
    local DisabledBuildingNum = 0
    local IdleBuilding = nil
    local IdleBuildingNum = 0
    -- loop over all MASSEXTRACTION buildings 
    for unitNum, unit in MassExtractorUnitList do
        if unit
            and not unit:BeenDestroyed()
            and not unit.Dead
            and EntityCategoryContains(ParseEntityCategory(techLevel), unit)
            and not unit:GetFractionComplete() < 1
        then
            -- Is the building upgrading ?
            if unit:IsUnitState('Upgrading') then
                -- If is paused
                if unit:IsPaused() then
                    if not PausedUpgradingBuilding then
                        PausedUpgradingBuilding = unit
                    end
                    PausedUpgradingBuildingNum = PausedUpgradingBuildingNum + 1
                -- The unit is upgrading but not paused
                else
                    if not UpgradingBuilding then
                         UpgradingBuilding = unit
                    end
                    UpgradingBuildingNum = UpgradingBuildingNum + 1
                end
            -- check if we have stopped the production
            elseif unit:GetScriptBit('RULEUTC_ProductionToggle') then
                if not DisabledBuilding then
                    DisabledBuilding = unit
                end
                DisabledBuildingNum = DisabledBuildingNum + 1
            -- we have left buildings that are not disabled, and not upgrading. Mabe they are paused ?
            else
                if not unit:IsPaused() then
                    if not IdleBuilding then
                        IdleBuilding = unit
                    end
                else
                    unit:SetPaused( false )
                end
               IdleBuildingNum = IdleBuildingNum + 1
            end
        end
    end
    --LOG('* ExtractorPause: Idle= '..UpgradingBuildingNum..'   Upgrading= '..UpgradingBuildingNum..'   Paused= '..PausedUpgradingBuildingNum..'   Disabled= '..DisabledBuildingNum..'   techLevel= '..techLevel)
    --Check for energy stall
    if (aiBrain:GetEconomyStoredRatio('ENERGY') < 0.10 and aiBrain:GetEconomyTrend('ENERGY') < 0) or (aiBrain:GetEconomyStoredRatio('MASS') > aiBrain:GetEconomyStoredRatio('ENERGY')) then
        -- All buildings that are doing nothing
        if IdleBuilding then
            IdleBuilding:SetScriptBit('RULEUTC_ProductionToggle', true)
            return true
        -- Have we a building that is actual upgrading
        elseif UpgradingBuilding then
            -- Its upgrading, now check fist if we only have 1 building that is upgrading
            if UpgradingBuildingNum <= 1 and table.getn(MassExtractorUnitList) >= 6 then
            else
                -- we don't have the eco to upgrade the extractor. Pause it!
                UpgradingBuilding:SetPaused( true )
                return true
            end
        end
    -- Do we produce more mass then we need ? Disable some for more energy    
    else
        if DisabledBuilding then
            DisabledBuilding:SetScriptBit('RULEUTC_ProductionToggle', false)
            return true
        end
    end
    -- Check for positive Mass/Upgrade ratio
    local MassRatioCheckPositive = GlobalMassUpgradeCostVsGlobalMassIncomeRatio( self, aiBrain, ratio, techLevel, '<' )
    -- Did we found a paused unit ?
    if PausedUpgradingBuilding then
        if MassRatioCheckPositive then
            -- We have good Mass ratio. We can unpause an extractor
            PausedUpgradingBuilding:SetPaused( false )
            -- return false. Re don't want to create a platoon that is building a new extractor. 
            return true
        elseif not MassRatioCheckPositive and UpgradingBuildingNum < 1 and table.getn(MassExtractorUnitList) >= 6 then
            PausedUpgradingBuilding:SetPaused( false )
            return true
        end
    end
    -- Check for negative Mass/Upgrade ratio
    local MassRatioCheckNegative = GlobalMassUpgradeCostVsGlobalMassIncomeRatio( self, aiBrain, ratio, techLevel, '>=')
    --LOG('* ExtractorPause 2 MassRatioCheckNegative >: '..repr(MassRatioCheckNegative)..' - IF this is true , we have bad eco and we should pause.')
    if UpgradingBuilding then
        if MassRatioCheckNegative then
            if UpgradingBuildingNum <= 1 and table.getn(MassExtractorUnitList) >= 6 then
                return false
            else
                -- we don't have the eco to upgrade the extractor. Pause it!
                UpgradingBuilding:SetPaused( true )
                return true
            end
        end
    end
    --LOG('* ExtractorPause 3 MassRatioCheckNegative >: '..repr(MassRatioCheckNegative)..' - IF This is true , we have very bad eco and we should cancel if possible.')
    if MassRatioCheckNegative and PausedUpgradingBuilding then
        local econ = {}
        econ.MassTrend = aiBrain:GetEconomyTrend('MASS')
        econ.MassStorage = aiBrain:GetEconomyStored('MASS')
        if econ.MassTrend <= 0 and econ.MassStorage <= 0  then
            IssueClearCommands({PausedUpgradingBuilding})
            PausedUpgradingBuilding:SetPaused( false )
            return true
        end
    end
    return false
end

-- UnitUpgradeAIUveso is upgrading the nearest building to our own main base instead of a random building.
function UnitUpgrade(self, aiBrain, MassExtractorUnitList, ratio, techLevel, UnitUpgradeTemplates, StructureUpgradeTemplates)
    -- Do we have the eco to upgrade ?
    local MassRatioCheckPositive = GlobalMassUpgradeCostVsGlobalMassIncomeRatio(self, aiBrain, ratio, techLevel, '<' )
    local aiBrain = self:GetBrain()
    -- search for the neares building to the base for upgrade.
    local BasePosition = aiBrain.BuilderManagers['MAIN'].Position
    local factionIndex = aiBrain:GetFactionIndex()
    local UpgradingBuilding = 0
    local DistanceToBase = nil
    local LowestDistanceToBase = nil
    local upgradeID = nil
    local upgradeBuilding = nil
    local UnitPos = nil
    local FactionToIndex  = { UEF = 1, AEON = 2, CYBRAN = 3, SERAPHIM = 4, NOMADS = 5}
    local UnitBeingUpgradeFactionIndex = nil
    for k, v in MassExtractorUnitList do
        local TempID
        -- Check if we don't want to upgrade this unit
        if not v
            or v:BeenDestroyed()
            or v.Dead
            or v:IsPaused()
            or not EntityCategoryContains(ParseEntityCategory(techLevel), v)
            or v:GetFractionComplete() < 1
        then
            -- Skip this loop and continue with the next array
            continue
        end
        if v:IsUnitState('Upgrading') then
            UpgradingBuilding = UpgradingBuilding + 1
            -- Skip this loop and continue with the next array
            continue
        end
        -- Check for the nearest distance from mainbase
        UnitPos = v:GetPosition()
        DistanceToBase= VDist2(BasePosition[1] or 0, BasePosition[3] or 0, UnitPos[1] or 0, UnitPos[3] or 0)
        if not LowestDistanceToBase or DistanceToBase < LowestDistanceToBase then
            -- Get the factionindex from the unit to get the right update (in case we have captured this unit from another faction)
            UnitBeingUpgradeFactionIndex = FactionToIndex[v.factionCategory] or factionIndex
            -- see if we can find a upgrade
            if EntityCategoryContains(categories.MOBILE, v) then
                TempID = aiBrain:FindUpgradeBP(v:GetUnitId(), UnitUpgradeTemplates[UnitBeingUpgradeFactionIndex])
                if not TempID then
                    WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] *UnitUpgradeAI ERROR: Can\'t find UnitUpgradeTemplate for mobile unit: ' .. repr(v:GetUnitId()) )
                end
            else
                TempID = aiBrain:FindUpgradeBP(v:GetUnitId(), StructureUpgradeTemplates[UnitBeingUpgradeFactionIndex])
                if not TempID then
                    WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] *UnitUpgradeAI ERROR: Can\'t find StructureUpgradeTemplate for structure: ' .. repr(v:GetUnitId()) )
                end
            end 
            -- Check if we can build the upgrade
            if TempID and EntityCategoryContains(categories.STRUCTURE, v) and not v:CanBuild(TempID) then
                WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] *UnitUpgradeAI ERROR: Can\'t upgrade structure with StructureUpgradeTemplate: ' .. repr(v:GetUnitId()) )
            elseif TempID then
                upgradeID = TempID
                upgradeBuilding = v
                LowestDistanceToBase = DistanceToBase
            end
        end
    end
    -- If we have not the Eco then return false. Exept we have none extractor upgrading
    if not MassRatioCheckPositive then
        -- if we have at least 1 extractor upgrading or less then 4 extractors, then return false
        if UpgradingBuilding > 0 or table.getn(MassExtractorUnitList) < 6 then
            return false
        end
        -- Even if we don't have the Eco for it; If we have more then 4 Extractors, then upgrade at least one of them.
    end
    -- Have we found a unit that can upgrade ?
    if upgradeID and upgradeBuilding then
        --LOG('* UnitUpgradeAIUveso: Upgrading Building in DistanceToBase '..(LowestDistanceToBase or 'Unknown ???')..' '..techLevel..' - UnitId '..upgradeBuilding:GetUnitId()..' - upgradeID '..upgradeID..'')
        IssueUpgrade({upgradeBuilding}, upgradeID)
        WaitTicks(1)
        return true
    end
    return false
end

-- Helperfunction fro ExtractorUpgradeAI. 
function GlobalMassUpgradeCostVsGlobalMassIncomeRatio(self, aiBrain, ratio, techLevel, compareType)
    local GlobalUpgradeCost = 0
    -- get all units matching 'category'
    local unitsBuilding = aiBrain:GetListOfUnits(categories.MASSEXTRACTION * (categories.TECH1 + categories.TECH2), true)
    local numBuilding = 0
    -- if we compare for more buildings, add the cost for a building.
    if compareType == '<' or compareType == '<=' then
        numBuilding = 1
        if techLevel == 'TECH1' then
            GlobalUpgradeCost = 10
            MassIncomeLost = 2
        else
            GlobalUpgradeCost = 26
            MassIncomeLost = 6
        end
    end
    local SingleUpgradeCost
    -- own armyIndex
    local armyIndex = aiBrain:GetArmyIndex()
    -- loop over all units and search for upgrading units
    for unitNum, unit in unitsBuilding do
        if unit
            and not unit:BeenDestroyed()
            and not unit.Dead
            and not unit:IsPaused()
            and not unit:GetFractionComplete() < 1
            and unit:IsUnitState('Upgrading')
            and unit:GetAIBrain():GetArmyIndex() == armyIndex
        then
            numBuilding = numBuilding + 1
            -- look for every building, category can hold different categories / techlevels for multiple building search
            local UpgraderBlueprint = unit:GetBlueprint()
            local BeingUpgradeEconomy = __blueprints[UpgraderBlueprint.General.UpgradesTo].Economy
            SingleUpgradeCost = (UpgraderBlueprint.Economy.BuildRate / BeingUpgradeEconomy.BuildTime) * BeingUpgradeEconomy.BuildCostMass
            GlobalUpgradeCost = GlobalUpgradeCost + SingleUpgradeCost
        end
    end
    local MassIncome = ( aiBrain:GetEconomyOverTime().MassIncome * 10 ) - MassIncomeLost
    -- If we have under 10 Massincome return always false
    if MassIncome < 10 and ( compareType == '<' or compareType == '<=' ) then
        return false
    end
    return CompareBody(GlobalUpgradeCost / MassIncome, ratio, compareType)
end

function HaveUnitRatio(aiBrain, ratio, categoryOne, compareType, categoryTwo)
    local numOne = aiBrain:GetCurrentUnits(categoryOne)
    local numTwo = aiBrain:GetCurrentUnits(categoryTwo)
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {World} ( '..numOne..' '..compareType..' '..numTwo..' ) -- ['..ratio..'] -- return '..repr(CompareBody(numOne / numTwo, ratio, compareType)))
    return CompareBody(numOne / numTwo, ratio, compareType)
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

local PropBlacklist = {}
function ReclaimAIThread(platoon,self,aiBrain)
    local scanrange = 25
    local scanKM = 0
    local MAPx, MAPy = GetMapSize()
    local basePosition = aiBrain.BuilderManagers['MAIN'].Position
    local MassStorageRatio
    local EnergyStorageRatio
    local SelfPos
    while aiBrain:PlatoonExists(platoon) and self and not self.Dead do
        SelfPos = self:GetPosition()
        MassStorageRatio = aiBrain:GetEconomyStoredRatio('MASS')
        EnergyStorageRatio = aiBrain:GetEconomyStoredRatio('ENERGY')
        if (MassStorageRatio < 0.8 or EnergyStorageRatio < 0.1) then
            --LOG('Searching for reclaimables')
            local x1 = SelfPos[1]-scanrange
            local y1 = SelfPos[3]-scanrange
            local x2 = SelfPos[1]+scanrange
            local y2 = SelfPos[3]+scanrange
            if x1 < 6 then x1 = 6 end
            if y1 < 6 then y1 = 6 end
            if x2 > MAPx-6 then x2 = MAPx-6 end
            if y2 > MAPy-6 then y2 = MAPy-6 end
            --LOG('GetReclaimablesInRect from x1='..math.floor(x1)..' - x2='..math.floor(x2)..' - y1='..math.floor(y1)..' - y2='..math.floor(y2)..' - scanrange='..scanrange..'')
            local props = GetReclaimablesInRect(Rect(x1, y1, x2, y2))
            local NearestWreckDist = -1
            local NearestWreckPos = {}
            local WreckDist = 0
            local WrackCount = 0
            if props and table.getn( props ) > 0 then
                for _, p in props do
                    local WreckPos = p.CachePosition
                    -- Start Blacklisted Props
                    local blacklisted = false
                    for _, BlackPos in PropBlacklist do
                        if WreckPos[1] == BlackPos[1] and WreckPos[3] == BlackPos[3] then
                            blacklisted = true
                            break
                        end
                    end
                    if blacklisted then continue end
                    -- End Blacklisted Props
                    local BPID = p.AssociatedBP or "unknown"
                    if BPID ~= "unknown" then
                        if BPID == 'ueb5101' or BPID == 'uab5101' or BPID == 'urb5101' or BPID == 'xsb5101' then
                            continue
                        end
                    end
                    if (MassStorageRatio < EnergyStorageRatio and p.MaxMassReclaim and p.MaxMassReclaim > 1) or (MassStorageRatio > EnergyStorageRatio and p.MaxEnergyReclaim and p.MaxEnergyReclaim > 1) then
                        if WreckPos[1] >= x1-5 and WreckPos[1] <= x2+5 and WreckPos[3] >= y1-5 and WreckPos[3] <= y2+5 then
                            WreckDist = VDist2(SelfPos[1], SelfPos[3], WreckPos[1], WreckPos[3])
                            WrackCount = WrackCount + 1
                            if WreckDist < NearestWreckDist or NearestWreckDist == -1 then
                                NearestWreckDist = WreckDist
                                NearestWreckPos = WreckPos
                                --LOG('Found Wreckage no.('..WrackCount..') from '..BPID..'. - Distance:'..WreckDist..' - NearestWreckDist:'..NearestWreckDist..'')
                            end
                            if NearestWreckDist < 20 then
                                --LOG('Found Wreckage nearer then 20. break!')
                                break
                            end
                        else
                            --LOG('Found Wreckage outside searchradius - x:'..WreckPos[1]..' Y:'..WreckPos[3]..'')
                        end
                    end
                end
            end
            if self.Dead then 
                return
            end
            if NearestWreckDist == -1 then
                scanrange = math.floor(scanrange + 100)
                if scanrange > 512 then -- 5 Km
                    IssueClearCommands({self})
                    scanrange = 25
                    local HomeDist = VDist2(SelfPos[1], SelfPos[3], basePosition[1], basePosition[3])
                    if HomeDist > 50 then
                        --LOG('noop returning home')
                        StartMoveDestination(self, {basePosition[1], basePosition[2], basePosition[3]})
                    end
                    PropBlacklist = {}
                end
                --LOG('No Wreckage, expanding scanrange:'..scanrange..'.')
            elseif math.floor(NearestWreckDist) < scanrange then
                scanrange = math.floor(NearestWreckDist)
                if scanrange < 25 then
                    scanrange = 25
                end
                --LOG('Adapting scanrange to nearest Object:'..scanrange..'.')
            end
            scanKM = math.floor(10000/512*NearestWreckDist)
            if NearestWreckDist > 20 and not self.Dead then
                --LOG('NearestWreck is > 20 away Distance:'..NearestWreckDist..'. Moving to Wreckage!')
                if NearestWreckPos[1] < 0+21 then
                    NearestWreckPos[1] = 21
                end
                if NearestWreckPos[1] > MAPx-21 then
                    NearestWreckPos[1] = MAPx-21
                end
                if NearestWreckPos[3] < 0+21 then
                    NearestWreckPos[3] = 21
                end
                if NearestWreckPos[3] > MAPy-21 then
                    NearestWreckPos[3] = MAPy-21
                end
                 if self.lastXtarget == NearestWreckPos[1] and self.lastYtarget == NearestWreckPos[3] then
                    self.blocked = self.blocked + 1
                    if self.blocked > 10 then
                        self.blocked = 0
                        table.insert (PropBlacklist, NearestWreckPos)
                    end
                else
                    self.blocked = 0
                    self.lastXtarget = NearestWreckPos[1]
                    self.lastYtarget = NearestWreckPos[3]
                    StartMoveDestination(self, NearestWreckPos)
                end
            end 
            WaitTicks(10)
            if not self.Dead and self:IsUnitState("Moving") then
                --LOG('Moving to Wreckage.')
                while self and not self.Dead and self:IsUnitState("Moving") do
                    WaitTicks(10)
                end
                scanrange = 25
            end
            IssueClearCommands({self})
            IssuePatrol({self}, self:GetPosition())
            IssuePatrol({self}, self:GetPosition())
        else
            --LOG('No reclaim, moving home')
            local HomeDist = VDist2(SelfPos[1], SelfPos[3], basePosition[1], basePosition[3])
            if HomeDist > 36 then
                --LOG('full, moving home')
                StartMoveDestination(self, {basePosition[1], basePosition[2], basePosition[3]})
                WaitTicks(10)
                if not self.Dead and self:IsUnitState("Moving") then
                    while self and not self.Dead and self:IsUnitState("Moving") and (MassStorageRatio == 1 or EnergyStorageRatio == 1) and HomeDist > 30 do
                        MassStorageRatio = aiBrain:GetEconomyStoredRatio('MASS')
                        EnergyStorageRatio = aiBrain:GetEconomyStoredRatio('ENERGY')
                        HomeDist = VDist2(SelfPos[1], SelfPos[3], basePosition[1], basePosition[3])
                        WaitTicks(30)
                    end
                    IssueClearCommands({self})
                    scanrange = 25
                end
            else
                return
            end
        end
        WaitTicks(10)
    end
end

function StartMoveDestination(self,destination)
    local NowPosition = self:GetPosition()
    local x, z, y = unpack(self:GetPosition())
    local count = 0
    IssueClearCommands({self})
    while x == NowPosition[1] and y == NowPosition[3] and count < 20 do
        count = count + 1
        IssueClearCommands({self})
        IssueMove( {self}, destination )
        WaitTicks(10)
    end
end

function DebugArray(Table)
    for Index, Array in Table do
        if type(Array) == 'thread' or type(Array) == 'userdata' then
            LOG('Index['..Index..'] is type('..type(Array)..'). I won\'t print that!')
        elseif type(Array) == 'table' then
            LOG('Index['..Index..'] is type('..type(Array)..'). I won\'t print that!')
            LOG(repr(Array))
        else
            LOG('Index['..Index..'] is type('..type(Array)..'). "', repr(Array),'".')
        end
    end
end
