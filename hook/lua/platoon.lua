
local UUtils = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua')

oldPlatoon = Platoon
Platoon = Class(oldPlatoon) {

    -- For AI Patch V2. Unpause engineers and set AssistPlatoon to nil
    PlatoonDisband = function(self)
        local aiBrain = self:GetBrain()
        -- Only use this with AI-Uveso
        if not aiBrain.Uveso then
            return oldPlatoon.PlatoonDisband(self)
        end
        if self.BuilderHandle then
            self.BuilderHandle:RemoveHandle(self)
        end
        for k,v in self:GetPlatoonUnits() do
            v.PlatoonHandle = nil
            v.AssistPlatoon = nil
            if v:IsPaused() then
                v:SetPaused( false )
            end
            if not v.Dead and v.BuilderManagerData then
                if self.CreationTime == GetGameTimeSeconds() and v.BuilderManagerData.EngineerManager then
                    if self.BuilderName then
                        --LOG('*AI DEBUG: ERROR - Platoon disbanded same tick as created - ' .. self.BuilderName .. ' - Army: ' .. aiBrain:GetArmyIndex() .. ' - Location: ' .. v.BuilderManagerData.LocationType)
                        v.BuilderManagerData.EngineerManager:AssignTimeout(v, self.BuilderName)
                    else
                        --LOG('*AI DEBUG: ERROR - Platoon disbanded same tick as created - Army: ' .. aiBrain:GetArmyIndex() .. ' - Location: ' .. v.BuilderManagerData.LocationType)
                    end
                    v.BuilderManagerData.EngineerManager:DelayAssign(v)
                elseif v.BuilderManagerData.EngineerManager then
                    v.BuilderManagerData.EngineerManager:TaskFinished(v)
                end
            end
            if not v.Dead then
                IssueStop({v})
                IssueClearCommands({v})
            end
        end
        aiBrain:DisbandPlatoon(self)
    end,

    -- For AI Patch V2. Small optimization from "if eng:IsIdleState() then break end"
    RepairAI = function(self)
        local aiBrain = self:GetBrain()
        -- Only use this with AI-Uveso
        if not aiBrain.Uveso then
            return oldPlatoon.RepairAI(self)
        end
        if not self.PlatoonData or not self.PlatoonData.LocationType then
            self:PlatoonDisband()
        end
        local eng = self:GetPlatoonUnits()[1]
        local engineerManager = aiBrain.BuilderManagers[self.PlatoonData.LocationType].EngineerManager
        local Structures = AIUtils.GetOwnUnitsAroundPoint(aiBrain, categories.STRUCTURE - (categories.TECH1 - categories.FACTORY), engineerManager:GetLocationCoords(), engineerManager:GetLocationRadius())
        for k,v in Structures do
            -- prevent repairing a unit while reclaim is in progress (see ReclaimStructuresAI)
            if not v.Dead and not v.ReclaimInProgress and v:GetHealthPercent() < .8 then
                self:Stop()
                IssueRepair(self:GetPlatoonUnits(), v)
                break
            end
        end
        local count = 0
        repeat
            WaitSeconds(2)
            if not aiBrain:PlatoonExists(self) then
                return
            end
            count = count + 1
            if eng:IsIdleState() then break end
        until count >= 30
        self:PlatoonDisband()
    end,

    -- For AI Patch V2. We need a better error message if we can't upgrade a building.
    UnitUpgradeAI = function(self)
        local aiBrain = self:GetBrain()
        -- Only use this with AI-Uveso
        if not aiBrain.Uveso then
            return oldPlatoon.UnitUpgradeAI(self)
        end
        local platoonUnits = self:GetPlatoonUnits()
        local factionIndex = aiBrain:GetFactionIndex()
        local FactionToIndex  = { UEF = 1, AEON = 2, CYBRAN = 3, SERAPHIM = 4, NOMADS = 5}
        local UnitBeingUpgradeFactionIndex = nil
        local upgradeIssued = false
        self:Stop()
        for k, v in platoonUnits do
            local upgradeID
            -- Get the factionindex from the unit to get the right update (in case we have captured this unit from another faction)
            UnitBeingUpgradeFactionIndex = FactionToIndex[v.factionCategory] or factionIndex
            if EntityCategoryContains(categories.MOBILE, v) then
                upgradeID = aiBrain:FindUpgradeBP(v:GetUnitId(), UnitUpgradeTemplates[UnitBeingUpgradeFactionIndex])
                -- if we can't find a UnitUpgradeTemplate for this unit, warn the programmer
                if not upgradeID then
                    -- Output: WARNING: [platoon.lua, line:xxx] *UnitUpgradeAI ERROR: Can\'t find UnitUpgradeTemplate for mobile unit: ABC1234
                    WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] *UnitUpgradeAI ERROR: Can\'t find UnitUpgradeTemplate for mobile unit: ' .. repr(v:GetUnitId()) )
                end
            else
                upgradeID = aiBrain:FindUpgradeBP(v:GetUnitId(), StructureUpgradeTemplates[UnitBeingUpgradeFactionIndex])
                -- if we can't find a StructureUpgradeTemplate for this unit, warn the programmer
                if not upgradeID then
                    -- Output: WARNING: [platoon.lua, line:xxx] *UnitUpgradeAI ERROR: Can\'t find StructureUpgradeTemplate for structure: ABC1234
                    WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] *UnitUpgradeAI ERROR: Can\'t find StructureUpgradeTemplate for structure: ' .. repr(v:GetUnitId()) .. '  factionIndex: ' .. repr(factionIndex) )
                end
            end
            if upgradeID and EntityCategoryContains(categories.STRUCTURE, v) and not v:CanBuild(upgradeID) then
                -- in case the unit can't upgrade with StructureUpgradeTemplate, warn the programmer
                -- Output: WARNING: [platoon.lua, line:xxx] *UnitUpgradeAI ERROR: Can\'t find StructureUpgradeTemplate for structure unit: ABC1234
                WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] *UnitUpgradeAI ERROR: Can\'t find StructureUpgradeTemplate for structure unit ' .. repr(v:GetUnitId()) )
                continue
            end
            if upgradeID then
                upgradeIssued = true
                IssueUpgrade({v}, upgradeID)
            end
        end
        if not upgradeIssued then
            self:PlatoonDisband()
            return
        end
        local upgrading = true
        while aiBrain:PlatoonExists(self) and upgrading do
            WaitSeconds(3)
            upgrading = false
            for k, v in platoonUnits do
                if v and not v.Dead then
                    upgrading = true
                end
            end
        end
        if not aiBrain:PlatoonExists(self) then
            return
        end
        WaitTicks(1)
        self:PlatoonDisband()
    end,

    -- For AI Patch V2. Bugfix GetGuards count
    EconAssistBody = function(self)
        local aiBrain = self:GetBrain()
        -- Only use this with AI-Uveso
        if not aiBrain.Uveso then
            return oldPlatoon.EconAssistBody(self)
        end
        local eng = self:GetPlatoonUnits()[1]
        if not eng then
            self:PlatoonDisband()
            return
        end

        --DUNCAN - added
        if eng:IsUnitState('Building') or eng:IsUnitState('Upgrading') or  eng:IsUnitState("Enhancing") then
           self:PlatoonDisband()
           return
        end

        local assistData = self.PlatoonData.Assist
        local assistee = false

        local assistRange = assistData.AssistRange or 80
        local platoonPos = self:GetPlatoonPosition()

        eng.AssistPlatoon = self

        if not assistData.AssistLocation or not assistData.AssisteeType then
            WARN('*AI WARNING: Disbanding Assist platoon that does not have either AssistLocation or AssisteeType')
            if not assistData.AssistLocation then
                WARN('*AI WARNING: Builder '..repr(self.BuilderName)..' is missing AssistLocation')
            end
            if not assistData.AssisteeType then
                WARN('*AI WARNING: Builder '..repr(self.BuilderName)..' is missing AssisteeType')
            end
            self:PlatoonDisband()
            return
        end

        local beingBuilt = assistData.BeingBuiltCategories or { 'ALLUNITS' }

        local assisteeCat = assistData.AssisteeCategory or categories.ALLUNITS
        if type(assisteeCat) == 'string' then
            assisteeCat = ParseEntityCategory(assisteeCat)
        end

        -- loop through different categories we are looking for
        for _,catString in beingBuilt do
            -- Track all valid units in the assist list so we can load balance for factories

            local category = ParseEntityCategory(catString)

            local assistList = AIUtils.GetAssistees(aiBrain, assistData.AssistLocation, assistData.AssisteeType, category, assisteeCat)

            if table.getn(assistList) > 0 then
                -- only have one unit in the list; assist it
                if table.getn(assistList) == 1 then
                    assistee = assistList[1]
                    break
                else
                    -- Find the unit with the least number of assisters; assist it
                    local lowNum = false
                    local lowUnit = false

                    for k,v in assistList do
                        --DUNCAN - check unit is inside assist range
                        local unitPos = v:GetPosition()
                        if not lowNum or (table.getn(v:GetGuards()) < lowNum
                        and VDist2(platoonPos[1], platoonPos[3], unitPos[1], unitPos[3]) < assistRange) then
                            lowNum = table.getn(v:GetGuards())
                            lowUnit = v
                        end
                    end
                    assistee = lowUnit
                    break
                end
            end
        end
        -- assist unit
        if assistee  then
            self:Stop()
            eng.AssistSet = true
            IssueGuard({eng}, assistee)
        else
            -- stop the platoon from endless assisting
            self:Stop()
            self:PlatoonDisband()
        end
    end,



    -- Uveso AI permanent hook for eco management while assisting
    ManagerEngineerAssistAI = function(self)
        local aiBrain = self:GetBrain()
        -- Only use this with AI-Uveso
        if not aiBrain.Uveso then
            return oldPlatoon.ManagerEngineerAssistAI(self)
        end
        local eng = self:GetPlatoonUnits()[1]
        self:EconAssistBody()
        -- do we assist until the building is finished ?
        if self.PlatoonData.Assist.AssistUntilFinished then
            -- loop as long as we are not dead and not idle
            while eng and not eng.Dead and aiBrain:PlatoonExists(self) and not eng:IsIdleState() do
                -- Only assist if we have more then 75% mass and more then 95% energy storage
                if aiBrain:GetEconomyStoredRatio('MASS') < 0.50 or aiBrain:GetEconomyStoredRatio('ENERGY') < 0.90 then
                    -- if we have a negative trend, stop the unit from assisting
                    if aiBrain:GetEconomyTrend('MASS') < 0.00 or aiBrain:GetEconomyTrend('ENERGY') < 0.00 then
                        self:Stop()
                        self:PlatoonDisband()
                        return
                    -- if we have positive trend, pause the unit.
                    elseif aiBrain:GetEconomyStoredRatio('MASS') > 0.75 or aiBrain:GetEconomyStoredRatio('ENERGY') > 0.99 then
                        if not eng:IsPaused() then
                            -- .. pause it.
                            eng:SetPaused( true )
                        end
                    end
                else
                    -- We have good eco, check if the engineer is paused
                    if eng:IsPaused() then
                        -- resume assisting
                        eng:SetPaused( false )
                    end
                end
                -- wait 1.5 seconds until we loop again
                WaitTicks(15)
            end
        else
            WaitSeconds(self.PlatoonData.Assist.Time or 60)
        end
        if not aiBrain:PlatoonExists(self) then
            return
        end
        -- stop the platoon from endless assisting
        self:Stop()
        self:PlatoonDisband()
    end,

-- UVESO's Stuff: ------------------------------------------------------------------------------------

    InterceptorAIUveso = function(self)
        AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        local aiBrain = self:GetBrain()
        -- Search all platoon units and activate Stealth and Cloak (mostly Modded units)
        local platoonUnits = self:GetPlatoonUnits()
        if platoonUnits and table.getn(platoonUnits) > 0 then
            for k, v in platoonUnits do
                if not v.Dead then
                    if v:TestToggleCaps('RULEUTC_StealthToggle') then
                        --LOG('* InterceptorAIUveso: Switching RULEUTC_StealthToggle')
                        v:SetScriptBit('RULEUTC_StealthToggle', false)
                    end
                    if v:TestToggleCaps('RULEUTC_CloakToggle') then
                        --LOG('* InterceptorAIUveso: Switching RULEUTC_CloakToggle')
                        v:SetScriptBit('RULEUTC_CloakToggle', false)
                    end
                end
            end
        end
        --LOG('* InterceptorAIUveso: self.PlatoonData.SearchRadius: '..maxRadius)
        local PrioritizedTargetList = {}
        if self.PlatoonData.PrioritizedCategories then
            --LOG('* InterceptorAIUveso: self.PlatoonData.PrioritizedCategories!!!!!!!!!!!!!')
            for k,v in self.PlatoonData.PrioritizedCategories do
                --LOG('* InterceptorAIUveso: PrioritizedCategories '..v)
                table.insert(PrioritizedTargetList, ParseEntityCategory(v))
            end
        end
        self:SetPrioritizedTargetList('Attack', PrioritizedTargetList)
        local target
        local bAggroMove = self.PlatoonData.AggressiveMove or false
        local path
        local reason
        local DistanceToTarget = 0
        local maxRadius = self.PlatoonData.SearchRadius or 100
        local PlatoonPos = self:GetPlatoonPosition()
        local lastPlatoonPos = table.copy(PlatoonPos)
        local LastPositionCheck = GetGameTimeSeconds()
        local LastTargetPos = PlatoonPos
        local basePosition
        if self.MovementLayer == 'Water' then
            -- we could search for the nearest naval base here, but buildposition is almost at the same location
            basePosition = PlatoonPos
        else
            -- land and air units are assigned to mainbase
            basePosition = aiBrain.BuilderManagers['MAIN'].Position
        end
        local GetTargetsFromBase = self.PlatoonData.GetTargetsFromBase or true
        local GetTargetsFrom = basePosition
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        local LastTargetCheck
        while aiBrain:PlatoonExists(self) do
            if self:IsOpponentAIRunning() then
                PlatoonPos = self:GetPlatoonPosition()
                if not GetTargetsFromBase then
                    GetTargetsFrom = PlatoonPos
                end
                -- only get a new target and make a move command if the target is dead
                if not target or target.Dead then
                    UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRange(aiBrain, self, 'Attack', GetTargetsFrom, maxRadius, PrioritizedTargetList, TargetSearchCategory, false )
                    --LOG('* InterceptorAIUveso: Targetting... recived retUnit, path, reason '..repr(reason)..'  ')
                    if UnitWithPath then
                        self:Stop()
                        target = UnitWithPath
                        --LOG('* InterceptorAIUveso: UnitWithPath.')
                        if self.PlatoonData.IgnorePathing then
                            --LOG('* InterceptorAIUveso: AttackTarget.')
                            self:Stop()
                            self:AttackTarget(UnitWithPath)
                        elseif path then
                            --LOG('* InterceptorAIUveso: MovePath.')
                            self:MovePath(aiBrain, path, bAggroMove, UnitWithPath)
                        -- if we dont have a path, but UnitWithPath is true, then we have no map markers but PathCanTo() found a direct path
                        else
                            --LOG('* InterceptorAIUveso: MoveDirect.')
                            self:MoveDirect(aiBrain, bAggroMove, UnitWithPath)
                        end
                        -- We moved to the target, attack it now if its still exists
                        if aiBrain:PlatoonExists(self) and UnitWithPath and not UnitWithPath.Dead then
                            self:AttackTarget(UnitWithPath)
                        end
                    elseif UnitNoPath then
                        self:Stop()
                        target = UnitNoPath
                        --LOG('* InterceptorAIUveso: MoveWithTransport() DistanceToTarget:'..DistanceToTarget)
                        if self.MovementLayer == 'Air' then
                            self:Stop()
                            self:AttackTarget(target)
                        else
                            self:Stop()
                            self:SimpleReturnToBase(basePosition)
                        end
                    else
                        -- we have no target return to main base
                        --LOG('* InterceptorAIUveso: ForceReturnToNearestBaseAIUveso() (no target)')
                        self:Stop()
                        self:SimpleReturnToBase(basePosition)
                    end
                else
                    DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0)
                    --LOG('* InterceptorAIUveso: Target Valid. range to target:'..DistanceToTarget)
                    self:AttackTarget(target)
                end
            end
            --LOG('* InterceptorAIUveso: WaitSeconds(3)')
            WaitSeconds(3)
        end
    end,

    AttackPrioritizedLandTargetsAIUveso = function(self)
        AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        -- Search all platoon units and activate Stealth and Cloak (mostly Modded units)
        local platoonUnits = self:GetPlatoonUnits()
        local ExperimentalInPlatoon = false
        if platoonUnits and table.getn(platoonUnits) > 0 then
            for k, v in platoonUnits do
                if not v.Dead then
                    if v:TestToggleCaps('RULEUTC_StealthToggle') then
                        --LOG('* AttackPrioritizedLandTargetsAIUveso: Switching RULEUTC_StealthToggle')
                        v:SetScriptBit('RULEUTC_StealthToggle', false)
                    end
                    if v:TestToggleCaps('RULEUTC_CloakToggle') then
                        --LOG('* AttackPrioritizedLandTargetsAIUveso: Switching RULEUTC_CloakToggle')
                        v:SetScriptBit('RULEUTC_CloakToggle', false)
                    end
                end
                if EntityCategoryContains(categories.EXPERIMENTAL, v) then
                    ExperimentalInPlatoon = true
                end
            end
        end
        local PrioritizedTargetList = {}
        if self.PlatoonData.PrioritizedCategories then
            --LOG('* AttackPrioritizedLandTargetsAIUveso: self.PlatoonData.PrioritizedCategories!!!!!!!!!!!!!')
            for k,v in self.PlatoonData.PrioritizedCategories do
                --LOG('* AttackPrioritizedLandTargetsAIUveso: PrioritizedCategories '..v)
                table.insert(PrioritizedTargetList, ParseEntityCategory(v))
            end
        end
        -- Set the target list to all platoon units
        self:SetPrioritizedTargetList('Attack', PrioritizedTargetList)
        local aiBrain = self:GetBrain()
        local target
        local bAggroMove = self.PlatoonData.AggressiveMove or false
        local WantsTransport = self.PlatoonData.RequireTransport
        local maxRadius = self.PlatoonData.SearchRadius or 250
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        local PlatoonPos = self:GetPlatoonPosition()
        local lastPlatoonPos = table.copy(PlatoonPos)
        local LastPositionCheck = GetGameTimeSeconds()
        local LastTargetPos = PlatoonPos
        local DistanceToTarget = 0
        local basePosition = aiBrain.BuilderManagers['MAIN'].Position
        while aiBrain:PlatoonExists(self) do
            if self:IsOpponentAIRunning() then
                PlatoonPos = self:GetPlatoonPosition()
                -- only get a new target and make a move command if the target is dead or after 10 seconds
                if not target or target.Dead then
                    UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRange(aiBrain, self, 'Attack', PlatoonPos, maxRadius, PrioritizedTargetList, TargetSearchCategory, false )
                    --LOG('* AttackPrioritizedLandTargetsAIUveso: Targetting... recived retUnit, path, reason '..repr(reason)..'  ')
                    if UnitWithPath then
                        self:Stop()
                        target = UnitWithPath
                        --LOG('* AttackPrioritizedLandTargetsAIUveso: UnitWithPath.')
                        LastTargetPos = table.copy(target:GetPosition())
                        DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0)
                        if DistanceToTarget > 30 then
                            --LOG('* AttackPrioritizedLandTargetsAIUveso: AttackTarget! DistanceToTarget:'..DistanceToTarget)
                            -- if we have a path then use the waypoints
                            if self.PlatoonData.IgnorePathing then
                                --LOG('* InterceptorAIUveso: AttackTarget.')
                                self:Stop()
                                self:AttackTarget(UnitWithPath)
                            elseif path then
                                --LOG('* AttackPrioritizedLandTargetsAIUveso: MovePath.')
                                self:MovePath(aiBrain, path, bAggroMove, target)
                            -- if we dont have a path, but UnitWithPath is true, then we have no map markers but PathCanTo() found a direct path
                            else
                                --LOG('* AttackPrioritizedLandTargetsAIUveso: MoveDirect.')
                                self:MoveDirect(aiBrain, bAggroMove, target)
                            end
                            -- We moved to the target, attack it now if its still exists
                            if aiBrain:PlatoonExists(self) and UnitWithPath and not UnitWithPath.Dead then
                                self:Stop()
                                self:AttackTarget(UnitWithPath)
                            end
                        end
                    elseif UnitNoPath then
                        self:Stop()
                        target = UnitNoPath
                        --LOG('* AttackPrioritizedLandTargetsAIUveso: MoveWithTransport() DistanceToTarget:'..DistanceToTarget)
                        self:MoveWithTransport(aiBrain, bAggroMove, target, basePosition, ExperimentalInPlatoon)
                        -- We moved to the target, attack it now if its still exists
                        if aiBrain:PlatoonExists(self) and UnitNoPath and not UnitNoPath.Dead then
                            self:AttackTarget(UnitNoPath)
                        end
                    else
                        -- we have no target return to main base
                        --LOG('* AttackPrioritizedLandTargetsAIUveso: ForceReturnToNearestBaseAIUveso() (no target)')
                        self:Stop()
                        self:ForceReturnToNearestBaseAIUveso()
                    end
                else
                    DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0)
                    --LOG('* AttackPrioritizedLandTargetsAIUveso: Target Valid. range to target:'..DistanceToTarget)
                    if aiBrain:PlatoonExists(self) and target and not target.Dead then
                        self:AttackTarget(target)
                    end
                end
            end
            WaitSeconds(3)
        end
    end,

    MoveWithTransport = function(self, aiBrain, bAggroMove, target, basePosition, ExperimentalInPlatoon)
        local TargetPosition = table.copy(target:GetPosition())
        --LOG('* MoveWithTransport: CanPathTo() failed for '..repr(TargetPosition)..' forcing SendPlatoonWithTransportsNoCheck.')
        if not ExperimentalInPlatoon and aiBrain:PlatoonExists(self) then
            usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, TargetPosition, true, false)
        end
        if not usedTransports then
            --LOG('* MoveWithTransport: SendPlatoonWithTransportsNoCheck failed.')
            local PlatoonPos = self:GetPlatoonPosition() or TargetPosition
            local DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, TargetPosition[1] or 0, TargetPosition[3] or 0)
            local DistanceToBase = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
            if DistanceToBase < DistanceToTarget or DistanceToTarget > 50 then
                --LOG('* MoveWithTransport: base is nearer then distance to target or distance to target over 50. Return To base')
                self:SimpleReturnToBase(basePosition)
            else
                --LOG('* MoveWithTransport: Direct move to Target')
                if bAggroMove then
                    self:AggressiveMoveToLocation(TargetPosition)
                else
                    self:MoveToLocation(TargetPosition, false)
                end
            end
        else
            --LOG('* MoveWithTransport: We got a transport!!')
        end
    end,

    MoveDirect = function(self, aiBrain, bAggroMove, target)
        local TargetPosition = table.copy(target:GetPosition())
        local PlatoonPosition
        local Lastdist
        local dist
        local Stuck = 0
        if bAggroMove then
            self:AggressiveMoveToLocation(TargetPosition)
        else
            self:MoveToLocation(TargetPosition, false)
        end
        while aiBrain:PlatoonExists(self) do
            PlatoonPosition = self:GetPlatoonPosition() or TargetPosition
            dist = VDist2( TargetPosition[1], TargetPosition[3], PlatoonPosition[1], PlatoonPosition[3] )
            --LOG('* MoveDirect: dist to next Waypoint: '..dist)
            if dist < 20 then
                return
            end
            -- Do we move ?
            if Lastdist ~= dist then
                Stuck = 0
                Lastdist = dist
            -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
            else
                Stuck = Stuck + 1
                if Stuck > 20 then
                    --LOG('* MoveDirect: Stucked while moving to target. Stuck='..Stuck)
                    self:Stop()
                    return
                end
            end
            -- If we lose our target, stop moving to it.
            if not target or target.Dead then
                --LOG('* MoveDirect: Lost target while moving to target. ')
                return
            end
            WaitTicks(10)
        end
    end,

    MovePath = function(self, aiBrain, path, bAggroMove, target)
        for i=1, table.getn(path) do
            local PlatoonPosition
            local Lastdist
            local dist
            local Stuck = 0
            --LOG('* MovePath: moving to destination. i: '..i..' coords '..repr(path[i]))
            if bAggroMove then
                self:AggressiveMoveToLocation(path[i])
            else
                self:MoveToLocation(path[i], false)
            end
            while aiBrain:PlatoonExists(self) do
                PlatoonPosition = self:GetPlatoonPosition() or path[i]
                dist = VDist2( path[i][1], path[i][3], PlatoonPosition[1], PlatoonPosition[3] )
                --LOG('* MovePath: dist to next Waypoint: '..dist)
                -- are we closer then 20 units from the next marker ? Then break and move to the next marker
                if dist < 20 then
                    -- If we don't stop the movement here, then we have heavy traffic on this Map marker with blocking units
                    self:Stop()
                    break
                end
                -- Do we move ?
                if Lastdist ~= dist then
                    Stuck = 0
                    Lastdist = dist
                -- No, we are not moving, wait 20 ticks then break and use the next weaypoint
                else
                    Stuck = Stuck + 1
                    if Stuck > 20 then
                        --LOG('* MovePath: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                        self:Stop()
                        break -- break the while aiBrain:PlatoonExists(self) do loop and move to the next waypoint
                    end
                end
                -- If we lose our target, stop moving to it.
                if not target or target.Dead then
                    --LOG('* MovePath: Lost target while moving to Waypoint. '..repr(path[i]))
                    return
                end
                WaitTicks(10)
            end
        end
    end,

    AttackPrioritizedSeaTargetsAIUveso = function(self)
        local unit = AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon (Water or Amphibious)
        -- Search all platoon units and activate Stealth and Cloak (mostly Modded units)
        local platoonUnits = self:GetPlatoonUnits()
        if platoonUnits and table.getn(platoonUnits) > 0 then
            for k, v in platoonUnits do
                if not v.Dead then
                    if v:TestToggleCaps('RULEUTC_StealthToggle') then
                        --LOG('* AttackPrioritizedSeaTargetsAIUveso: Switching RULEUTC_StealthToggle')
                        v:SetScriptBit('RULEUTC_StealthToggle', false)
                    end
                    if v:TestToggleCaps('RULEUTC_CloakToggle') then
                        --LOG('* AttackPrioritizedSeaTargetsAIUveso: Switching RULEUTC_CloakToggle')
                        v:SetScriptBit('RULEUTC_CloakToggle', false)
                    end
                end
            end
        end
        local PrioritizedTargetList = {}
        if self.PlatoonData.PrioritizedCategories then
            --LOG('* AttackPrioritizedSeaTargetsAIUveso: self.PlatoonData.PrioritizedCategories!!!!!!!!!!!!!')
            for k,v in self.PlatoonData.PrioritizedCategories do
                --LOG('* AttackPrioritizedSeaTargetsAIUveso: PrioritizedCategories '..v)
                table.insert(PrioritizedTargetList, ParseEntityCategory(v))
            end
        end
        -- Set the target list to all platoon units
        self:SetPrioritizedTargetList('Attack', PrioritizedTargetList)
        local aiBrain = self:GetBrain()
        local target
        local bAggroMove = self.PlatoonData.AggressiveMove or false
        local maxRadius = self.PlatoonData.SearchRadius or 250
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        local PlatoonPos = self:GetPlatoonPosition()
        local lastPlatoonPos = table.copy(PlatoonPos)
        local LastTargetPos = PlatoonPos
        local LastPositionCheck = GetGameTimeSeconds()
        local DistanceToTarget = 0
        local DistanceToBase = 0
        local basePosition = PlatoonPos   -- Platoons will be created near a base, so we can return to this position if we don't have targets.
        while aiBrain:PlatoonExists(self) do
            if self:IsOpponentAIRunning() then
                PlatoonPos = self:GetPlatoonPosition()
                -- only get a new target and make a move command if the target is dead or after 10 seconds
                if not target or target.Dead then
                    --LOG('* AttackPrioritizedSeaTargetsAIUveso: Targetting...')
                    target, AltTarget, path, reason = AIUtils.AIFindNearestCategoryTargetInRange(aiBrain, self, 'Attack', PlatoonPos, maxRadius, PrioritizedTargetList, TargetSearchCategory, false )
                    if target then
                        --LOG('* AttackPrioritizedSeaTargetsAIUveso: Target!.')
                        LastTargetPos = table.copy(target:GetPosition())
                        DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0)
                        if target then
                            --LOG('* AttackPrioritizedSeaTargetsAIUveso: MoveToLocation! AggressiveMove=false.')
                            local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer or 'Water' , self:GetPlatoonPosition(), LastTargetPos, 1000, 512)
                            -- clear commands, so we don't get stuck if we have an unreachable destination
                            IssueClearCommands(self:GetPlatoonUnits())
                            if self.PlatoonData.IgnorePathing then
                                --LOG('* InterceptorAIUveso: AttackTarget.')
                                self:Stop()
                                self:AttackTarget(target)
                            elseif path then
                                if table.getn(path) > 1 then
                                    --LOG('* AttackPrioritizedSeaTargetsAIUveso: table.getn(path): '..table.getn(path))
                                end
                                --LOG('* AttackPrioritizedSeaTargetsAIUveso: moving to destination by path.')
                                for i=1, table.getn(path) do
                                    --LOG('* AttackPrioritizedSeaTargetsAIUveso: moving to destination. i: '..i..' coords '..repr(path[i]))
                                    if bAggroMove then
                                        self:AggressiveMoveToLocation(path[i])
                                    else
                                        self:MoveToLocation(path[i], false)
                                    end
                                    --LOG('* AttackPrioritizedSeaTargetsAIUveso: moving to Waypoint')
                                    local PlatoonPosition
                                    local Lastdist
                                    local dist
                                    local Stuck = 0
                                    while aiBrain:PlatoonExists(self) do
                                        PlatoonPosition = self:GetPlatoonPosition()
                                        dist = VDist2( path[i][1], path[i][3], PlatoonPosition[1], PlatoonPosition[3] )
                                        -- are we closer then 15 units from the next marker ? Then break and move to the next marker
                                        if dist < 20 then
                                            -- If we don't stop the movement here, then we have heavy traffic on this Map marker with blocking units
                                            self:Stop()
                                            break
                                        end
                                        -- Do we move ?
                                        if Lastdist ~= dist then
                                            Stuck = 0
                                            Lastdist = dist
                                        -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
                                        else
                                            Stuck = Stuck + 1
                                            if Stuck > 15 then
                                                --LOG('* AttackPrioritizedSeaTargetsAIUveso: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                                                self:Stop()
                                                self:ForceReturnToNavalBaseAIUveso(aiBrain, basePosition)
                                            end
                                        end
                                        -- If we lose our target, stop moving to it.
                                        if not target then
                                            --LOG('* AttackPrioritizedSeaTargetsAIUveso: Lost target while moving to Waypoint. '..repr(path[i]))
                                            self:Stop()
                                            break
                                        end
                                        WaitTicks(10)
                                    end
                                end
                            else
                                --LOG('* AttackPrioritizedSeaTargetsAIUveso: we have no Graph to reach the destination. Checking CanPathTo()')
                                if reason == 'NoGraph' then
                                    local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(self, LastTargetPos)
                                    if success then
                                        --LOG('* AttackPrioritizedSeaTargetsAIUveso: found a way with CanPathTo(). moving to destination')
                                        if bAggroMove then
                                            self:AggressiveMoveToLocation(LastTargetPos)
                                        else
                                            self:MoveToLocation(LastTargetPos, false)
                                        end
                                    else
                                        --LOG('* AttackPrioritizedSeaTargetsAIUveso: CanPathTo() failed for '..repr(LastTargetPos)..'.')
                                    end
                                end
                            end
                        end
                    else
                        -- we have no target return to main base
                        --LOG('* AttackPrioritizedSeaTargetsAIUveso: Return to MainBase (no target)')
                        self:ForceReturnToNavalBaseAIUveso(aiBrain, basePosition)
                    end
                else
                    LastTargetPos = table.copy(target:GetPosition())
                    DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0)
                    -- if we have moved to our destination and the target is not close, take a new target
                    if DistanceToTarget >=30 then
                        target = nil
                    end
                    --LOG('* AttackPrioritizedSeaTargetsAIUveso: Target Valid. range to target:'..DistanceToTarget..' - '.. LastPositionCheck - GetGameTimeSeconds() +10 )
                    if LastPositionCheck + 30 < GetGameTimeSeconds() then
                        if PlatoonPos[1] == lastPlatoonPos[1] and PlatoonPos[3] == lastPlatoonPos[3] then
                            --LOG('* AttackPrioritizedLandTargetsAIUveso: We are stucked! Range to target:'..DistanceToTarget..' - time: '.. LastPositionCheck + 30 - GetGameTimeSeconds() )
                            self:ForceReturnToNearestBaseAIUveso()
                        else
                            --LOG('* AttackPrioritizedLandTargetsAIUveso: We are Ok, move on!')
                            target = nil
                        end
                        lastPlatoonPos = table.copy(PlatoonPos)
                        LastPositionCheck = GetGameTimeSeconds()
                    end
                end
            end
            --LOG('* AttackPrioritizedSeaTargetsAIUveso: WaitSeconds(3)')
            WaitSeconds(3)
        end
    end,

    MoveToLocationInclTransport = function(self, target, TargetPosition, bAggroMove, WantsTransport, basePosition, ExperimentalInPlatoon)
        if not TargetPosition then
            TargetPosition = table.copy(target:GetPosition())
        end
        local aiBrain = self:GetBrain()
        -- this will be true if we got our units transported to the destination
        local usedTransports = false
        local TransportNotNeeded, bestGoalPos
        -- check, if we can reach the destination without a transport
        local unit = AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer or 'Land' , self:GetPlatoonPosition(), TargetPosition, 1000, 512)
        if not aiBrain:PlatoonExists(self) then
            return
        end
        -- use a transporter if we don't have a path, or if we want a transport
        if not ExperimentalInPlatoon and ((not path and reason ~= 'NoGraph') or WantsTransport)  then
            --LOG('* MoveToLocationInclTransport: SendPlatoonWithTransportsNoCheck')
            usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, TargetPosition, true, false)
        end
        -- if we don't got a transport, try to reach the destination by path or directly
        if not usedTransports then
            -- clear commands, so we don't get stuck if we have an unreachable destination
            IssueClearCommands(self:GetPlatoonUnits())
            if path then
                --LOG('* MoveToLocationInclTransport: No transport used, and we dont need it.')
                if table.getn(path) > 1 then
                    --LOG('* MoveToLocationInclTransport: table.getn(path): '..table.getn(path))
                end
                for i=1, table.getn(path) do
                    --LOG('* MoveToLocationInclTransport: moving to destination. i: '..i..' coords '..repr(path[i]))
                    if bAggroMove then
                        self:AggressiveMoveToLocation(path[i])
                    else
                        self:MoveToLocation(path[i], false)
                    end
                    local PlatoonPosition
                    local Lastdist
                    local dist
                    local Stuck = 0
                    while aiBrain:PlatoonExists(self) do
                        PlatoonPosition = self:GetPlatoonPosition() or {0,0,0}
                        dist = VDist2( path[i][1], path[i][3], PlatoonPosition[1], PlatoonPosition[3] )
                        --LOG('* MoveToLocationInclTransport: dist to next Waypoint: '..dist)
                        -- are we closer then 20 units from the next marker ? Then break and move to the next marker
                        if dist < 20 then
                            -- If we don't stop the movement here, then we have heavy traffic on this Map marker with blocking units
                            self:Stop()
                            break
                        end
                        -- Do we move ?
                        if Lastdist ~= dist then
                            Stuck = 0
                            Lastdist = dist
                        -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
                        else
                            Stuck = Stuck + 1
                            if Stuck > 20 then
                                --LOG('* MoveToLocationInclTransport: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                                self:Stop()
                                break -- break the while aiBrain:PlatoonExists(self) do loop and move to the next waypoint
                            end
                        end
                        -- If we lose our target, stop moving to it.
                        if not target then
                            --LOG('* MoveToLocationInclTransport: Lost target while moving to Waypoint. '..repr(path[i]))
                            self:Stop()
                            return
                        end
                        WaitTicks(10)
                    end
                end
            else
                --LOG('* MoveToLocationInclTransport: No transport used, and we have no Graph to reach the destination. Checking CanPathTo()')
                if reason == 'NoGraph' then
                    local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(self, TargetPosition)
                    if success then
                        --LOG('* MoveToLocationInclTransport: No transport used, found a way with CanPathTo(). moving to destination')
                        if bAggroMove then
                            self:AggressiveMoveToLocation(bestGoalPos)
                        else
                            self:MoveToLocation(bestGoalPos, false)
                        end
                        local PlatoonPosition
                        local Lastdist
                        local dist
                        local Stuck = 0
                        while aiBrain:PlatoonExists(self) do
                            PlatoonPosition = self:GetPlatoonPosition() or {0,0,0}
                            dist = VDist2( bestGoalPos[1], bestGoalPos[3], PlatoonPosition[1], PlatoonPosition[3] )
                            if dist < 20 then
                                break
                            end
                            -- Do we move ?
                            if Lastdist ~= dist then
                                Stuck = 0
                                Lastdist = dist
                            -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
                            else
                                Stuck = Stuck + 1
                                if Stuck > 20 then
                                    --LOG('* MoveToLocationInclTransport: Stucked while moving to target. Stuck='..Stuck)
                                    self:Stop()
                                    break -- break the while aiBrain:PlatoonExists(self) do loop and move to the next waypoint
                                end
                            end
                            -- If we lose our target, stop moving to it.
                            if not target then
                                --LOG('* MoveToLocationInclTransport: Lost target while moving to target. ')
                                self:Stop()
                                return
                            end
                            WaitTicks(10)
                        end
                    else
                        --LOG('* MoveToLocationInclTransport: CanPathTo() failed for '..repr(TargetPosition)..' forcing SendPlatoonWithTransportsNoCheck.')
                        if not ExperimentalInPlatoon then
                            usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, TargetPosition, true, false)
                        end
                        if not usedTransports then
                            --LOG('* MoveToLocationInclTransport: CanPathTo() and SendPlatoonWithTransportsNoCheck failed. SimpleReturnToBase!')
                            local PlatoonPos = self:GetPlatoonPosition()
                            local DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, TargetPosition[1] or 0, TargetPosition[3] or 0)
                            local DistanceToBase = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
                            if DistanceToBase < DistanceToTarget and DistanceToTarget > 50 then
                                --LOG('* MoveToLocationInclTransport: base is nearer then distance to target and distance to target over 50. Return To base')
                                self:SimpleReturnToBase(basePosition)
                            else
                                --LOG('* MoveToLocationInclTransport: Direct move to Target')
                                if bAggroMove then
                                    self:AggressiveMoveToLocation(TargetPosition)
                                else
                                    self:MoveToLocation(TargetPosition, false)
                                end
                            end
                        else
                            --LOG('* MoveToLocationInclTransport: CanPathTo() failed BUT we got an transport!!')
                        end

                    end
                else
                    --LOG('* MoveToLocationInclTransport: We have no path but there is a Graph with markers. So why we don\'t get a path ??? (Island or threat too high?) - reason: '..repr(reason))
                end
            end
        else
            --LOG('* MoveToLocationInclTransport: TRANSPORTED.')
        end
    end,

    TransferAIUveso = function(self)
        local aiBrain = self:GetBrain()
        if not aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType] then
            --LOG('* TransferAIUveso: Location ('..self.PlatoonData.MoveToLocationType..') has no BuilderManager!')
            self:PlatoonDisband()
        end
        local eng = self:GetPlatoonUnits()[1]
        if eng and not eng.Dead and eng.BuilderManagerData.EngineerManager then
            --LOG('* TransferAIUveso: '..repr(self.BuilderName))
            eng.BuilderManagerData.EngineerManager:RemoveUnit(eng)
            --LOG('* TransferAIUveso: AddUnit units to - BuilderManagers: '..self.PlatoonData.MoveToLocationType..' - ' .. aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType].EngineerManager:GetNumCategoryUnits('Engineers', categories.ALLUNITS) )
            aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType].EngineerManager:AddUnit(eng, true)
            -- Move the unit to the desired base after transfering BuilderManagers to the new LocationType
            local basePosition = aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType].Position
            --LOG('* TransferAIUveso: Moving transfer-units to - ' .. self.PlatoonData.MoveToLocationType)
            self:SimpleReturnToBase(basePosition)
        end
        if aiBrain:PlatoonExists(self) then
            self:PlatoonDisband()
        end
    end,

    ReclaimAIUveso = function(self)
        local aiBrain = self:GetBrain()
        local platoonUnits = self:GetPlatoonUnits()
        local eng
        for k, v in platoonUnits do
            if not v.Dead and EntityCategoryContains(categories.MOBILE * categories.ENGINEER, v) then
                eng = v
                break
            end
        end
        UUtils.ReclaimAIThread(self,eng,aiBrain)
        self:PlatoonDisband()
    end,

    PlatoonMerger = function(self)
        --LOG('* PlatoonMerger: called from Builder: '..(self.BuilderName or 'Unknown'))
        local aiBrain = self:GetBrain()
        local PlatoonPlan = self.PlatoonData.AIPlan
        --LOG('* PlatoonMerger: AIPlan: '..(PlatoonPlan or 'Unknown'))
        if not PlatoonPlan then
            return
        end
        -- Get all units from the platoon
        local platoonUnits = self:GetPlatoonUnits()
        -- check if we have already a Platoon for MassExtractor Upgrades
        local AlreadyMergedPlatoon
        PlatoonList = aiBrain:GetPlatoonsList()
        for _,Platoon in PlatoonList do
            if Platoon:GetPlan() == PlatoonPlan then
                --LOG('* PlatoonMerger: Found Platton with plan '..PlatoonPlan)
                AlreadyMergedPlatoon = Platoon
                break
            end
            --LOG('* PlatoonMerger: Found '..repr(Platoon:GetPlan()))
        end
        -- If we dont have already a platton for upgrades, create one.
        if not AlreadyMergedPlatoon then
            AlreadyMergedPlatoon = aiBrain:MakePlatoon( PlatoonPlan..'Platoon', PlatoonPlan )
            AlreadyMergedPlatoon.PlanName = PlatoonPlan
            AlreadyMergedPlatoon.BuilderName = PlatoonPlan..'Platoon'
            AlreadyMergedPlatoon:UniquelyNamePlatoon(PlatoonPlan)
        end
        -- Add our unit(s) to the upgrade platoon
        aiBrain:AssignUnitsToPlatoon( AlreadyMergedPlatoon, platoonUnits, 'support', 'none' )
        -- Disband this platoon, it's no longer needed.
        self:PlatoonDisbandNoAssign()
    end,

    ExtractorUpgradeAI = function(self)
        --LOG('+++ ExtractorUpgradeAI: START')
        local aiBrain = self:GetBrain()
        while aiBrain:PlatoonExists(self) do
            local ratio = 0.3
            if aiBrain:GetEconomyOverTime().MassIncome > 200 then
                --LOG('Mass over 200. Eco running with 30%')
                ratio = 0.3
            elseif GetGameTimeSeconds() > 1800 then -- 30 * 60
                ratio = 0.30
            elseif GetGameTimeSeconds() > 1200 then -- 20 * 60
                ratio = 0.40
            elseif GetGameTimeSeconds() > 900 then -- 15 * 60
                ratio = 0.40
            elseif GetGameTimeSeconds() > 600 then -- 10 * 60
                ratio = 0.40
            elseif GetGameTimeSeconds() > 360 then -- 6 * 60
                ratio = 0.40
            elseif GetGameTimeSeconds() <= 360 then -- 6 * 60 run the first 6 minutes with 30% Eco and 70% Army
                ratio = 0.30
            end
            local platoonUnits = self:GetPlatoonUnits()
            local MassExtractorUnitList = aiBrain:GetListOfUnits(categories.MASSEXTRACTION * (categories.TECH1 + categories.TECH2 + categories.TECH3), false, false)
            -- Check if we can pause/unpause TECH3 Extractors (for more energy)
            if not UUtils.ExtractorPause( self, aiBrain, MassExtractorUnitList, ratio, 'TECH3') then
                -- Check if we can pause/unpause TECH2 Extractors
                if not UUtils.ExtractorPause( self, aiBrain, MassExtractorUnitList, ratio, 'TECH2') then
                    -- Check if we can pause/unpause TECH1 Extractors
                    if not UUtils.ExtractorPause( self, aiBrain, MassExtractorUnitList, ratio, 'TECH1') then
                        -- We have nothing to pause or unpause, lets upgrade more extractors
                        -- if we have 10% TECH1 extractors left (and 90% TECH2), then upgrade TECH2 to TECH3
                        if UUtils.HaveUnitRatio( aiBrain, 0.90, categories.MASSEXTRACTION * categories.TECH1, '<=', categories.MASSEXTRACTION * categories.TECH2 ) then
                            -- Try to upgrade a TECH2 extractor.
                            if not UUtils.UnitUpgrade(self, aiBrain, MassExtractorUnitList, ratio, 'TECH2', UnitUpgradeTemplates, StructureUpgradeTemplates) then
                                -- We can't upgrade a TECH2 extractor. Try to upgrade from TECH1 to TECH2
                                UUtils.UnitUpgrade(self, aiBrain, MassExtractorUnitList, ratio, 'TECH1', UnitUpgradeTemplates, StructureUpgradeTemplates)
                            end
                        else
                            -- We have less than 90% TECH2 extractors compared to TECH1. Upgrade more TECH1
                            UUtils.UnitUpgrade(self, aiBrain, MassExtractorUnitList, ratio, 'TECH1', UnitUpgradeTemplates, StructureUpgradeTemplates)
                        end
                    end
                end
            end
            -- Check the Eco every x Ticks
            WaitTicks(5)
            -- find dead units inside the platoon and disband if we find one
            for k,v in self:GetPlatoonUnits() do
                if not v or v.Dead or v:BeenDestroyed() then
                    -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                    --LOG('+++ ExtractorUpgradeAI: Found Dead unit, self:PlatoonDisbandNoAssign()')
                    self:PlatoonDisbandNoAssign()
                    return
                end
            end
        end
        -- No return here. We will never reach this position. After disbanding this platoon, the forked 'ExtractorUpgradeAI' thread will be terminated from outside.
    end,

    SimpleReturnToBase = function(self, basePosition)
        local aiBrain = self:GetBrain()
        local PlatoonPosition
        local Lastdist
        local dist
        local Stuck = 0
        self:Stop()
        self:MoveToLocation(basePosition, false)
        while aiBrain:PlatoonExists(self) do
            PlatoonPosition = self:GetPlatoonPosition()
            if not PlatoonPosition then
                --LOG('* SimpleReturnToBase: no Platoon Position')
                break
            end
            dist = VDist2( basePosition[1], basePosition[3], PlatoonPosition[1], PlatoonPosition[3] )
            if dist < 20 then
                break
            end
            -- Do we move ?
            if Lastdist ~= dist then
                Stuck = 0
                Lastdist = dist
            -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
            else
                Stuck = Stuck + 1
                if Stuck > 20 then
                    self:Stop()
                    break
                end
            end
            WaitTicks(10)
        end
        self:PlatoonDisband()
    end,

    ForceReturnToNearestBaseAIUveso = function(self)
        local platPos = self:GetPlatoonPosition() or false
        if not platPos then
            return
        end
        local aiBrain = self:GetBrain()
        local nearestbase = false
        for k,v in aiBrain.BuilderManagers do
            -- check if we can move to this base
            if not AIUtils.ValidateLayer(v.FactoryManager.Location,self.MovementLayer) then
                --LOG('ForceReturnToNearestBaseAIUveso Can\'t return to This base. Wrong movementlayer: '..repr(v.FactoryManager.LocationType))
                continue
            end
            local dist = VDist2( platPos[1], platPos[3], v.FactoryManager.Location[1], v.FactoryManager.Location[3] )
            if not nearestbase or nearestbase.dist > dist then
                nearestbase = {}
                nearestbase.Pos = v.FactoryManager.Location
                nearestbase.dist = dist
            end
        end
        if not nearestbase then
            return
        end
        self:Stop()
        self:MoveToLocationInclTransport(true, nearestbase.Pos, false, false, nearestbase.Pos, false)
        -- Disband the platoon so the locationmanager can assign a new task to the units.
        WaitTicks(30)
        self:PlatoonDisband()
        return
    end,

    ForceReturnToNavalBaseAIUveso = function(self, aiBrain, basePosition)
        local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer or 'Water' , self:GetPlatoonPosition(), basePosition, 1000, 512)
        -- clear commands, so we don't get stuck if we have an unreachable destination
        IssueClearCommands(self:GetPlatoonUnits())
        if path then
            if table.getn(path) > 1 then
                --LOG('* ForceReturnToNavalBaseAIUveso: table.getn(path): '..table.getn(path))
            end
            --LOG('* ForceReturnToNavalBaseAIUveso: moving to destination by path.')
            for i=1, table.getn(path) do
                --LOG('* ForceReturnToNavalBaseAIUveso: moving to destination. i: '..i..' coords '..repr(path[i]))
                self:MoveToLocation(path[i], false)
                --LOG('* ForceReturnToNavalBaseAIUveso: moving to Waypoint')
                local PlatoonPosition
                local Lastdist
                local dist
                local Stuck = 0
                while aiBrain:PlatoonExists(self) do
                    PlatoonPosition = self:GetPlatoonPosition()
                    dist = VDist2( path[i][1], path[i][3], PlatoonPosition[1], PlatoonPosition[3] )
                    -- are we closer then 15 units from the next marker ? Then break and move to the next marker
                    if dist < 20 then
                        -- If we don't stop the movement here, then we have heavy traffic on this Map marker with blocking units
                        self:Stop()
                        break
                    end
                    -- Do we move ?
                    if Lastdist ~= dist then
                        Stuck = 0
                        Lastdist = dist
                    -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
                    else
                        Stuck = Stuck + 1
                        if Stuck > 15 then
                            --LOG('* ForceReturnToNavalBaseAIUveso: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                            self:Stop()
                            break
                        end
                    end
                    WaitTicks(10)
                end
            end
        else
            --LOG('* ForceReturnToNavalBaseAIUveso: we have no Graph to reach the destination. Checking CanPathTo()')
            if reason == 'NoGraph' then
                local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(self, basePosition)
                if success then
                    --LOG('* ForceReturnToNavalBaseAIUveso: found a way with CanPathTo(). moving to destination')
                    self:MoveToLocation(basePosition, false)
                else
                    --LOG('* ForceReturnToNavalBaseAIUveso: CanPathTo() failed for '..repr(basePosition)..'.')
                end
            end
        end
        local oldDist = 100000
        local platPos = self:GetPlatoonPosition() or basePosition
        while aiBrain:PlatoonExists(self) do
            --LOG('* ForceReturnToNavalBaseAIUveso: Waiting for moving to base')
            platPos = self:GetPlatoonPosition() or basePosition
            dist = VDist2(platPos[1], platPos[3], basePosition[1], basePosition[3])
            if dist < 30 then
                --LOG('* ForceReturnToNavalBaseAIUveso: We are home! disband!')
                -- Wait some second, so all platoon units have time to reach the base.
                WaitSeconds(5)
                self:Stop()
                break
            end
            -- if we haven't moved in 5 seconds... leave the loop
            if oldDist - dist < 0 then
                break
            end
            oldDist = dist
            WaitSeconds(5)
        end
        -- Disband the platoon so the locationmanager can assign a new task to the units.
        WaitTicks(30)
        self:PlatoonDisband()
    end,

    NukePlatoonAI = function(self)
        --LOG('* NukePlatoonAI: Started')
        local aiBrain = self:GetBrain()
        local mapSizeX, mapSizeZ = GetMapSize()
        local platoonUnits
        local MissileCount = 0
        local LauncherReady = 0
        local EnemyTargetPositions = {}
        local EnemyAntiMissile = {}
        local ECOLoopCounter = 0
        while aiBrain:PlatoonExists(self) do
            ---------------------------------------------------------------------------------------------------
            -- Count Launchers, set them to automode, count stored missiles
            ---------------------------------------------------------------------------------------------------
            MissileCount = 0
            LauncherReady = 0

            platoonUnits = self:GetPlatoonUnits()
            for _, Launcher in platoonUnits do
                if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                    -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                    self:PlatoonDisband()
                    return
                end
                local NukeSiloAmmoCount = Launcher:GetNukeSiloAmmoCount() or 0
                -- Set the Laucher to automatically building missiles
                Launcher:SetAutoMode(true)
                if NukeSiloAmmoCount > 0 then
                    -- count nuke launchers that are able to shoot a missile
                    LauncherReady = LauncherReady + 1
                    -- count nuke missiles
                    MissileCount = MissileCount + NukeSiloAmmoCount
                end
            end
            ---------------------------------------------------------------------------------------------------
            -- check if the enemy has more then 2 Anti Missiles, if yes, stop building nukes. It's to much ECO
            ---------------------------------------------------------------------------------------------------
            EnemyAntiMissile = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * ((categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3) + (categories.SHIELD * categories.EXPERIMENTAL)), Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
            if ( table.getn(EnemyAntiMissile) > 2 and not aiBrain.HasParagon ) or aiBrain:GetEconomyStoredRatio('ENERGY') < 0.90 or aiBrain:GetEconomyStoredRatio('MASS') < 0.90 then
                -- We don't want to attack. Save the eco and disable launchers.
                --LOG('* NukePlatoonAI: Too much Antimissiles or low mass/energy, deactivating all nuke launchers')
                for k,Launcher in platoonUnits do
                    if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                        -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                        self:PlatoonDisband()
                        return
                    end
                    -- Check if the launcher is active
                    if not Launcher:IsPaused() then
                        -- yes, its active. Disable it.
                        Launcher:SetPaused( true )
                        -- now break, we only want do disable one launcher per loop
                        break
                    end
                end
            else
                -- Enemy has less then 3 Anti Missiles. And we have good eco. Activate nukes!
                --LOG('* NukePlatoonAI: Activating all nuke launchers')
                for k,Launcher in platoonUnits do
                    if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                        -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                        self:PlatoonDisband()
                        return
                    end
                    -- Check if the launcher is deactivated
                    if Launcher:IsPaused() then
                        -- yes, it's off. Turn it on.
                        Launcher:SetPaused( false )
                        break
                    end
                end

            end
            -- At this point we have only checked the eco for our launchers. Only check targetting and missile launching every 5th loop
            ECOLoopCounter = ECOLoopCounter + 1
            if ECOLoopCounter < 5 then
                WaitTicks(10)
                -- start the "while aiBrain:PlatoonExists(self) do" loop from the beginning
                continue
            end
            ECOLoopCounter = 0
            ---------------------------------------------------------------------------------------------------
            -- Launch nukes if possible. First check for unprotected targets
            ---------------------------------------------------------------------------------------------------
            --LOG('* NukePlatoonAI: MissileCount '..MissileCount..' Unprotected!')
            if MissileCount > 0 then
                local EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE - categories.MASSEXTRACTION - categories.TECH1 - categories.TECH2 , Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                EnemyTargetPositions = {}
                ---------------------------------------------------------------------------------------------------
                -- first try to target all targets that are not protected from enemy anti missile
                ---------------------------------------------------------------------------------------------------
                --LOG('* NukePlatoonAI: (Unprotected) EnemyUnits '..table.getn(EnemyUnits))
                for _, EnemyTarget in EnemyUnits do
                    -- get position of the possible next target
                    local EnemyTargetPos = EnemyTarget:GetPosition() or {0,0,0}
                    local ToClose = false
                    -- loop over all already attacked targets
                    for _, ETargetPosition in EnemyTargetPositions do
                        -- Check if the target is closeer then 40 to an already attacked target
                        if VDist2(EnemyTargetPos[1],EnemyTargetPos[3],ETargetPosition[1],ETargetPosition[3]) < 40 then
                            ToClose = true
                            break -- break out of the EnemyTargetPositions loop
                        end
                    end
                    if ToClose then
                        continue -- Skip this enemytarget and check the next
                    end
                    -- loop over all Enemy anti nuke launchers.
                    for _, AntiMissile in EnemyAntiMissile do
                        -- if the launcher is still in build, don't count it.
                        if AntiMissile:GetFractionComplete() < 1 then
                            continue
                        end
                        -- get the location of AntiMissile
                        local AntiMissilePos = AntiMissile:GetPosition() or {0,0,0}
                        -- Check if our target is inside range of an antimissile
                        if VDist2(EnemyTargetPos[1],EnemyTargetPos[3],AntiMissilePos[1],AntiMissilePos[3]) < 90 then
                            --LOG('* NukePlatoonAI: (Unprotected) Target in range of Nuke Anti Missile. Skiped')
                            ToClose = true
                            break -- break out of the EnemyTargetPositions loop
                        end
                    end
                    if ToClose then
                        continue -- Skip this enemytarget and check the next
                    end
                    table.insert(EnemyTargetPositions, EnemyTargetPos)
                end
                ---------------------------------------------------------------------------------------------------
                -- Now, if we have targets, shot at it
                ---------------------------------------------------------------------------------------------------
                --LOG('* NukePlatoonAI: (Unprotected) table.getn(EnemyTargetPositions) '..table.getn(EnemyTargetPositions))
                if table.getn(EnemyTargetPositions) > 0 then
                    NukeBussy = { ['n'] = 0}
                    while table.getn(EnemyTargetPositions) > 0 do
                        --LOG('* NukePlatoonAI: (Unprotected) table.getn(EnemyTargetPositions) '..table.getn(EnemyTargetPositions))
                        -- get a target and remove it from the target list
                        local ActualTargetPos = table.remove(EnemyTargetPositions)
                        -- loop over all nuke launcher
                        for _, Launcher in platoonUnits do
                            if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                                -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                                self:PlatoonDisband()
                                return
                            end
                            -- check if the launcher has already launched a nuke
                            if NukeBussy[Launcher] then
                                --LOG('* NukePlatoonAI: (Unprotected) NukeBussy. Skiped')
                                -- The luancher is bussy with launching missiles. Skip it.
                                continue
                            end
                            -- check if we have at least 1 missile
                            if Launcher:GetNukeSiloAmmoCount() <= 0 then
                                --LOG('* NukePlatoonAI: (Unprotected) GetNukeSiloAmmoCount() <= 0. Skiped')
                                -- we don't have a missile, skip this launcher
                                NukeBussy[Launcher] = true
                                NukeBussy.n = NukeBussy.n + 1
                                continue
                            end
                            -- check if the target is closer then 20000
                            LauncherPos = Launcher:GetPosition() or {0,0,0}
                            if VDist2(LauncherPos[1],LauncherPos[3],ActualTargetPos[1],ActualTargetPos[3]) > 20000 then
                                --LOG('* NukePlatoonAI: (Unprotected) Target out of range. Skiped')
                                -- Target is out of range, skip this launcher
                                continue
                            end
                            -- Attack the target
                            --LOG('* NukePlatoonAI: (Unprotected) Attacking Enemy Position!')
                            IssueNuke({Launcher}, ActualTargetPos)
                            NukeBussy[Launcher] = true
                            NukeBussy.n = NukeBussy.n + 1
                            LauncherReady = LauncherReady - 1
                            MissileCount = MissileCount - 1
                            break -- stop seraching for available launchers and check the next target
                        end
                        if table.getn(NukeBussy) >= table.getn(platoonUnits) then
                            --LOG('* NukePlatoonAI: (Unprotected) All Launchers are bussy! Break!')
                            break  -- stop seraching for targets, we don't hava a launcher ready.
                        end
                        WaitTicks(40)-- wait 4 seconds between each Missile shoot
                    end
                    WaitTicks(450)-- wait 45 seconds for the missile flight, then get new targets
                end
                ---------------------------------------------------------------------------------------------------
                -- Try to overwhelm anti nuke if we have more then 10 launchers and 22 missiles ready
                ---------------------------------------------------------------------------------------------------
                --LOG('* NukePlatoonAI: MissileCountB '..MissileCount..' Overwhelm!')
                if MissileCount > table.getn(EnemyAntiMissile) * 8 and 1 == 2 then
                    --LOG('* NukePlatoonAI: (Overwhelm) MissileCount ('..MissileCount..') > EnemyAntiMissile )'..table.getn(EnemyAntiMissile)..')')
                    local AntiMissileRanger = {}
                    ---------------------------------------------------------------------------------------------------
                    -- get a list with all antinukes and distance to each other
                    ---------------------------------------------------------------------------------------------------
                    for MissileIndex, AntiMissileSTART in EnemyAntiMissile do
                        AntiMissileRanger[MissileIndex] = 0
                        -- get the location of AntiMissile
                        local AntiMissilePosSTART = AntiMissileSTART:GetPosition() or {0,0,0}
                        for _, AntiMissileEND in EnemyAntiMissile do
                            local AntiMissilePosEND = AntiMissileSTART:GetPosition() or {0,0,0}
                            local dist = VDist2(AntiMissilePosSTART[1],AntiMissilePosSTART[3],AntiMissilePosEND[1],AntiMissilePosEND[3])
                            AntiMissileRanger[MissileIndex] = AntiMissileRanger[MissileIndex] + dist
                        end
                    end
                    ---------------------------------------------------------------------------------------------------
                    -- find the least protected anti missile
                    ---------------------------------------------------------------------------------------------------
                    local HighestDistance = 0
                    local HighIndex = false
                    for MissileIndex, MissileRange in AntiMissileRanger do
                        if MissileRange > HighestDistance then
                            HighestDistance = MissileRange
                            HighIndex = MissileIndex
                        end
                    end
                    local EnemyTarget
                    local TargetPosition = false
                    if HighIndex and EnemyAntiMissile[HighIndex] and not EnemyAntiMissile[HighIndex].Dead then
                        --LOG('* NukePlatoonAI: (Overwhelm) Antimissile with highest dinstance to other antimisiiles has HighIndex= '..HighIndex)
                        -- kill the launcher will all missiles we have
                        EnemyTarget = EnemyAntiMissile[HighIndex]
                        TargetPosition = EnemyTarget:GetPosition() or false
                    elseif EnemyAntiMissile[1] and not EnemyAntiMissile[1].Dead then
                        --LOG('* NukePlatoonAI: (Overwhelm) Targetting Antimissile[1]')
                        EnemyTarget = EnemyAntiMissile[1]
                        TargetPosition = EnemyTarget:GetPosition() or false
                    end
                    WaitTicks(1)
                    ---------------------------------------------------------------------------------------------------
                    -- Fire as long as the target exists
                    ---------------------------------------------------------------------------------------------------
                    --LOG('* NukePlatoonAI: while EnemyTarget do ')
                    while EnemyTarget and not EnemyTarget.Dead do
                        --LOG('* NukePlatoonAI: (Overwhelm) Loop!')
                        local missile = false
                        for Index, Launcher in platoonUnits do
                            if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                                -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                                self:PlatoonDisband()
                                return
                            end
                            --LOG('* NukePlatoonAI: (Overwhelm) Fireing Nuke: '..repr(Index))
                            if Launcher:GetNukeSiloAmmoCount() > 0 then
                                if Launcher:GetNukeSiloAmmoCount() > 1 then
                                    missile = true
                                end
                                IssueNuke({Launcher}, TargetPosition)
                                LauncherReady = LauncherReady - 1
                                MissileCount = MissileCount - 1
                            end
                            if not EnemyTarget or EnemyTarget.Dead then
                                --LOG('* NukePlatoonAI: (Overwhelm) Target is dead. break fire loop')
                                break -- break the "for Index, Launcher in platoonUnits do" loop
                            end
                        end
                        if not missile then
                            --LOG('* NukePlatoonAI: (Overwhelm) Nukes are empty')
                            break -- break the "while EnemyTarget do" loop
                        end
                        WaitTicks(450)
                    end
                end
                --LOG('* NukePlatoonAI: MissileCountC '..MissileCount..' Jericho!')
                ---------------------------------------------------------------------------------------------------
                -- If we have more then 8 missiles per enemy antimissile, then Fire at all
                ---------------------------------------------------------------------------------------------------
                if LauncherReady > table.getn(platoonUnits)-3 or LauncherReady > 30 then
                    EnemyTargetPositions = {}
                    --LOG('* NukePlatoonAI: (Jericho) LauncherReady ('..LauncherReady..') > platoonUnits-3 )'..table.getn(platoonUnits)..')')
                    for _, EnemyTarget in EnemyUnits do
                        -- get position of the possible next target
                        local EnemyTargetPos = EnemyTarget:GetPosition() or {0,0,0}
                        local ToClose = false
                        -- loop over all already attacked targets
                        for _, ETargetPosition in EnemyTargetPositions do
                            -- Check if the target is closeer then 40 to an already attacked target
                            if VDist2(EnemyTargetPos[1],EnemyTargetPos[3],ETargetPosition[1],ETargetPosition[3]) < 40 then
                                ToClose = true
                                break -- break out of the EnemyTargetPositions loop
                            end
                        end
                        if ToClose then
                            continue -- Skip this enemytarget and check the next
                        end
                        table.insert(EnemyTargetPositions, EnemyTargetPos)
                    end

                end
                ---------------------------------------------------------------------------------------------------
                -- Now, if we have targets, shot at it
                ---------------------------------------------------------------------------------------------------
                NukeBussy = { ['n'] = 0}
                while table.getn(EnemyTargetPositions) > 0 do
                    --LOG('* NukePlatoonAI: (Jericho) table.getn(EnemyTargetPositions) '..table.getn(EnemyTargetPositions))
                    -- get a target and remove it from the target list
                    local ActualTargetPos = table.remove(EnemyTargetPositions)
                    -- loop over all nuke launcher
                    for _, Launcher in platoonUnits do
                        if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                            -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                            self:PlatoonDisband()
                            return
                        end
                        -- check if the launcher has already launched a nuke
                        if NukeBussy[Launcher] then
                            --LOG('* NukePlatoonAI: (Jericho) NukeBussy. Skiped')
                            -- The luancher is bussy with launching missiles. Skip it.
                            continue
                        end
                        -- check if we have at least 1 missile
                        if Launcher:GetNukeSiloAmmoCount() <= 0 then
                            --LOG('* NukePlatoonAI: (Jericho) GetNukeSiloAmmoCount() <= 0. Skiped')
                            -- we don't have a missile, skip this launcher
                            NukeBussy[Launcher] = true
                            NukeBussy.n = NukeBussy.n + 1
                            continue
                        end
                        -- check if the target is closer then 20000
                        LauncherPos = Launcher:GetPosition() or {0,0,0}
                        if VDist2(LauncherPos[1],LauncherPos[3],ActualTargetPos[1],ActualTargetPos[3]) > 20000 then
                            --LOG('* NukePlatoonAI: (Jericho) Target out of range. Skiped')
                            -- Target is out of range, skip this launcher
                            continue
                        end
                        -- Attack the target
                        --LOG('* NukePlatoonAI: (Jericho) Attacking Enemy Position!')
                        IssueNuke({Launcher}, ActualTargetPos)
                        NukeBussy[Launcher] = true
                        NukeBussy.n = NukeBussy.n + 1
                        LauncherReady = LauncherReady - 1
                        MissileCount = MissileCount - 1
                        break -- stop seraching for available launchers and check the next target
                    end
                    if table.getn(NukeBussy) >= table.getn(platoonUnits) then
                        --LOG('* NukePlatoonAI: (Jericho) All Launchers are bussy! Break!')
                        break  -- stop seraching for targets, we don't hava a launcher ready.
                    end
                    WaitTicks(1)
                end
                --LOG('* NukePlatoonAI: MissileCountD '..MissileCount..' Launcher Full!')
                ---------------------------------------------------------------------------------------------------
                -- Well, if we are here then we don't have any primary targets. Enemy is almost dead, finish him!
                ---------------------------------------------------------------------------------------------------
                EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                -- if we don't have any enemy structures, then attack mobile units.
                if not EnemyUnits then
                    EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.MOBILE , Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                end
                if MissileCount > 1 and table.getn(EnemyUnits) > 0 then
                    --LOG('* NukePlatoonAI: (Launcher Full) MissileCount ('..MissileCount..') > EnemyUnits ('..table.getn(EnemyUnits)..')')
                    EnemyTargetPositions = {}
                    ---------------------------------------------------------------------------------------------------
                    -- get enemy target positions
                    ---------------------------------------------------------------------------------------------------
                    for _, EnemyTarget in EnemyUnits do
                        -- get position of the possible next target
                        local EnemyTargetPos = EnemyTarget:GetPosition() or {0,0,0}
                        local ToClose = false
                        -- loop over all already attacked targets
                        for _, ETargetPosition in EnemyTargetPositions do
                            -- Check if the target is closeer then 40 to an already attacked target
                            if VDist2(EnemyTargetPos[1],EnemyTargetPos[3],ETargetPosition[1],ETargetPosition[3]) < 40 then
                                ToClose = true
                                break -- break out of the EnemyTargetPositions loop
                            end
                        end
                        if ToClose then
                            continue -- Skip this enemytarget and check the next
                        end
                        table.insert(EnemyTargetPositions, EnemyTargetPos)
                    end
                end
                --LOG('* NukePlatoonAI: (Launcher Full) MissileCount ('..MissileCount..') > EnemyTargetPositions )'..table.getn(EnemyTargetPositions)..')')
                ---------------------------------------------------------------------------------------------------
                -- Now, if we have targets, shot at it
                ---------------------------------------------------------------------------------------------------
                NukeBussy = { ['n'] = 0}
                while table.getn(EnemyTargetPositions) > 0 do
                    --LOG('* NukePlatoonAI: (Launcher Full) table.getn(EnemyTargetPositions) '..table.getn(EnemyTargetPositions))
                    -- get a target and remove it from the target list
                    local ActualTargetPos = table.remove(EnemyTargetPositions)
                    -- loop over all nuke launcher
                    for _, Launcher in platoonUnits do
                        if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                            -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                            self:PlatoonDisband()
                            return
                        end
                        -- check if the launcher has already launched a nuke
                        if NukeBussy[Launcher] then
                            --LOG('* NukePlatoonAI: (Launcher Full) NukeBussy. Skiped')
                            -- The luancher is bussy with launching missiles. Skip it.
                            continue
                        end
                        -- check if we have at least 1 missile
                        if Launcher:GetNukeSiloAmmoCount() < 5 then
                            --LOG('* NukePlatoonAI: (Launcher Full) GetNukeSiloAmmoCount() '..Launcher:GetNukeSiloAmmoCount()..'< 5. Skiped')
                            NukeBussy[Launcher] = true
                            NukeBussy.n = NukeBussy.n + 1
                            continue
                        end
                        -- check if the target is closer then 20000
                        LauncherPos = Launcher:GetPosition() or {0,0,0}
                        if VDist2(LauncherPos[1],LauncherPos[3],ActualTargetPos[1],ActualTargetPos[3]) > 20000 then
                            --LOG('* NukePlatoonAI: (Launcher Full) Target out of range. Skiped')
                            -- Target is out of range, skip this launcher
                            continue
                        end
                        -- Attack the target
                        --LOG('* NukePlatoonAI: (Launcher Full) Attacking Enemy Position!')
                        IssueNuke({Launcher}, ActualTargetPos)
                        NukeBussy[Launcher] = true
                        NukeBussy.n = NukeBussy.n + 1
                        LauncherReady = LauncherReady - 1
                        MissileCount = MissileCount - 1
                        break -- stop seraching for available launchers and check the next target
                    end
                    --LOG('* NukePlatoonAI: (Launcher Full) table.getn(NukeBussy) '..table.getn(NukeBussy)..' >= table.getn(platoonUnits) '..table.getn(platoonUnits))
                    if table.getn(NukeBussy) >= table.getn(platoonUnits) then
                        --LOG('* NukePlatoonAI: (Launcher Full) All Launchers are bussy! Break!')
                        break  -- stop seraching for targets, we don't hava a launcher ready.
                    end
                end
                WaitTicks(45)
            end
            -- find dead units inside the platoon and disband if we find one
            for k,Launcher in platoonUnits do
                if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                    -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                    self:PlatoonDisband()
                    --LOG('* NukePlatoonAI: PlatoonDisband')
                    return
                end
            end
            WaitTicks(3)
        end
    end,

    AntiNukePlatoonAI = function(self)
        local aiBrain = self:GetBrain()
        while aiBrain:PlatoonExists(self) do
            --LOG('* AntiNukePlatoonAI: PlatoonExists')
            local platoonUnits = self:GetPlatoonUnits()
            for _, unit in platoonUnits do
                unit:SetAutoMode(true)
            end
            WaitSeconds(10)
            -- find dead units inside the platoon and disband if we find one
            for k,unit in platoonUnits do
                if not unit or unit.Dead or unit:BeenDestroyed() then
                    -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                    self:PlatoonDisband()
                    --LOG('* AntiNukePlatoonAI: PlatoonDisband')
                    return
                end
            end
        end
    end,

}
