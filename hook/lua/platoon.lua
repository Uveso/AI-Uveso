
local UUtils = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua')

oldPlatoon = Platoon
Platoon = Class(oldPlatoon) {

    -- overwriting original function until AIpatch is released
    LandScoutingAI = function(self)
        local aiBrain = self:GetBrain()
        -- Only use this with AI-Uveso
        if not aiBrain.Uveso then
            return oldPlatoon.LandScoutingAI(self)
        end
        AIAttackUtils.GetMostRestrictiveLayer(self)

        local scout = self:GetPlatoonUnits()[1]

        -- Build always BuildScoutLocations. We need this also for the Cheating AI's with Omniview.
        aiBrain:BuildScoutLocations()
        --If we have cloaking (are cybran), then turn on our cloaking
        --DUNCAN - Fixed to use same bits
        if scout:TestToggleCaps('RULEUTC_CloakToggle') then
            scout:SetScriptBit('RULEUTC_CloakToggle', false)
        end

        while not scout.Dead do
            --Head towards the the area that has not had a scout sent to it in a while
            local targetData = false

            --For every scouts we send to all opponents, send one to scout a low pri area.
            if aiBrain.IntelData.HiPriScouts < aiBrain.NumOpponents and table.getn(aiBrain.InterestList.HighPriority) > 0 then
                targetData = aiBrain.InterestList.HighPriority[1]
                aiBrain.IntelData.HiPriScouts = aiBrain.IntelData.HiPriScouts + 1
                targetData.LastScouted = GetGameTimeSeconds()

                aiBrain:SortScoutingAreas(aiBrain.InterestList.HighPriority)

            elseif table.getn(aiBrain.InterestList.LowPriority) > 0 then
                targetData = aiBrain.InterestList.LowPriority[1]
                aiBrain.IntelData.HiPriScouts = 0
                targetData.LastScouted = GetGameTimeSeconds()

                aiBrain:SortScoutingAreas(aiBrain.InterestList.LowPriority)
            else
                --Reset number of scoutings and start over
                aiBrain.IntelData.HiPriScouts = 0
            end

            --Is there someplace we should scout?
            if targetData then
                --Can we get there safely?
                local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer, scout:GetPosition(), targetData.Position, 400) --DUNCAN - Increase threatwieght from 100

                IssueClearCommands(self)

                if path then
                    local pathLength = table.getn(path)
                    for i=1, pathLength-1 do
                        self:MoveToLocation(path[i], false)
                    end
                end

                self:MoveToLocation(targetData.Position, false)

                --Scout until we reach our destination
                while not scout.Dead and not scout:IsIdleState() do
                    WaitSeconds(2.5)
                end
            end

            WaitSeconds(1)
        end
    end,

    -- overwriting original function until AIpatch is released
    AirScoutingAI = function(self)
        local aiBrain = self:GetBrain()
        -- Only use this with AI-Uveso
        if not aiBrain.Uveso then
            return oldPlatoon.AirScoutingAI(self)
        end
        local scout = self:GetPlatoonUnits()[1]
        if not scout then
            return
        end

        -- Build always BuildScoutLocations. We need this also for the Cheating AI's with Omniview.
        aiBrain:BuildScoutLocations()

        --If we have Stealth (are cybran), then turn on our Stealth
        if scout:TestToggleCaps('RULEUTC_CloakToggle') then
            scout:EnableUnitIntel('Toggle', 'Cloak')
        end

        while not scout.Dead do
            local targetArea = false
            local highPri = false

            local mustScoutArea, mustScoutIndex = aiBrain:GetUntaggedMustScoutArea()
            local unknownThreats = aiBrain:GetThreatsAroundPosition(scout:GetPosition(), 16, true, 'Unknown')

            --1) If we have any "must scout" (manually added) locations that have not been scouted yet, then scout them
            if mustScoutArea then
                mustScoutArea.TaggedBy = scout
                targetArea = mustScoutArea.Position

            --2) Scout "unknown threat" areas with a threat higher than 25
            elseif table.getn(unknownThreats) > 0 and unknownThreats[1][3] > 25 then
                aiBrain:AddScoutArea({unknownThreats[1][1], 0, unknownThreats[1][2]})

            --3) Scout high priority locations
            elseif aiBrain.IntelData.AirHiPriScouts < aiBrain.NumOpponents and aiBrain.IntelData.AirLowPriScouts < 1
            and table.getn(aiBrain.InterestList.HighPriority) > 0 then
                aiBrain.IntelData.AirHiPriScouts = aiBrain.IntelData.AirHiPriScouts + 1

                highPri = true

                targetData = aiBrain.InterestList.HighPriority[1]
                targetData.LastScouted = GetGameTimeSeconds()
                targetArea = targetData.Position

                aiBrain:SortScoutingAreas(aiBrain.InterestList.HighPriority)

            --4) Every time we scout NumOpponents number of high priority locations, scout a low priority location
            elseif aiBrain.IntelData.AirLowPriScouts < 1 and table.getn(aiBrain.InterestList.LowPriority) > 0 then
                aiBrain.IntelData.AirHiPriScouts = 0
                aiBrain.IntelData.AirLowPriScouts = aiBrain.IntelData.AirLowPriScouts + 1

                targetData = aiBrain.InterestList.LowPriority[1]
                targetData.LastScouted = GetGameTimeSeconds()
                targetArea = targetData.Position

                aiBrain:SortScoutingAreas(aiBrain.InterestList.LowPriority)
            else
                --Reset number of scoutings and start over
                aiBrain.IntelData.AirLowPriScouts = 0
                aiBrain.IntelData.AirHiPriScouts = 0
            end

            --Air scout do scoutings.
            if targetArea then
                self:Stop()

                local vec = self:DoAirScoutVecs(scout, targetArea)

                while not scout.Dead and not scout:IsIdleState() do

                    --If we're close enough...
                    if VDist2Sq(vec[1], vec[3], scout:GetPosition()[1], scout:GetPosition()[3]) < 15625 then
                        if mustScoutArea then
                            --Untag and remove
                            for idx,loc in aiBrain.InterestList.MustScout do
                                if loc == mustScoutArea then
                                   table.remove(aiBrain.InterestList.MustScout, idx)
                                   break
                                end
                            end
                        end
                        --Break within 125 ogrids of destination so we don't decelerate trying to stop on the waypoint.
                        break
                    end

                    if VDist3(scout:GetPosition(), targetArea) < 25 then
                        break
                    end

                    WaitSeconds(5)
                end
            else
                WaitSeconds(1)
            end
            WaitTicks(1)
        end
    end,

    -- overwriting original function until AIpatch is released
    ManagerEngineerFindUnfinished = function(self)
        local aiBrain = self:GetBrain()
        local beingBuilt = false
        self:EconUnfinishedBody()
        WaitSeconds(20)
        local eng = self:GetPlatoonUnits()[1]
        if eng.UnitBeingBuilt then
            beingBuilt = eng.UnitBeingBuilt
        end
        if beingBuilt then
            while not beingBuilt:BeenDestroyed() and beingBuilt:GetFractionComplete() < 1 do
                WaitSeconds(5)
            end
        end
        if not aiBrain:PlatoonExists(self) then
            return
        end
        -- stop the platoon from endless assisting
        self:Stop()
        self:PlatoonDisband()
    end,

    -- overwriting original function until AIpatch is released
    EconUnfinishedBody = function(self)
        local eng = self:GetPlatoonUnits()[1]
        if not eng then
            self:PlatoonDisband()
            return
        end
        local aiBrain = self:GetBrain()
        local assistData = self.PlatoonData.Assist
        local assistee = false

        --eng.AssistPlatoon = self

        if not assistData.AssistLocation then
            WARN('*AI WARNING: Disbanding EconUnfinishedBody platoon that does not have either AssistLocation')
            self:PlatoonDisband()
        end

        local beingBuilt = assistData.BeingBuiltCategories or { 'ALLUNITS' }

        -- loop through different categories we are looking for
        for _,catString in beingBuilt do
            -- Track all valid units in the assist list so we can load balance for factories

            local category = ParseEntityCategory(catString)

            local assistList = SUtils.FindUnfinishedUnits(aiBrain, assistData.AssistLocation, category)

            if assistList then
                assistee = assistList
                break
            end
        end
        -- assist unit
        if assistee then
            self:Stop()
            eng.AssistSet = true
            IssueGuard({eng}, assistee)
        else
            -- stop the platoon from endless assisting
            self:Stop()
            self:PlatoonDisband()
        end
    end,

    -- overwriting original function until AIpatch is released
    ManagerEngineerAssistAI = function(self)
        local aiBrain = self:GetBrain()
        self:EconAssistBody()
        WaitSeconds(self.PlatoonData.AssistData.Time or 60)
        if not aiBrain:PlatoonExists(self) then
            return
        end
        self.AssistPlatoon = nil
        -- stop the platoon from endless assisting
        self:Stop()
        self:PlatoonDisband()
    end,

    -- overwriting original function until AIpatch is released
    EconAssistBody = function(self)
        local eng = self:GetPlatoonUnits()[1]
        if not eng then
            self:PlatoonDisband()
            return
        end

        --DUNCAN - added
        if eng:IsUnitState('Building') or eng:IsUnitState('Upgrading') or  eng:IsUnitState("Enhancing") then
           return
        end

        local aiBrain = self:GetBrain()
        local assistData = self.PlatoonData.Assist
        local assistee = false

        local assistRange = assistData.AssistRange or 80
        local platoonPos = self:GetPlatoonPosition()

        eng.AssistPlatoon = self

        if not assistData.AssistLocation or not assistData.AssisteeType then
            WARN('*AI WARNING: Disbanding Assist platoon that does not have either AssistLocation or AssisteeType')
            self:PlatoonDisband()
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
                            lowNum = v:GetGuards()
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
            self.AssistPlatoon = nil
            -- stop the platoon from endless assisting
            self:Stop()
            self:PlatoonDisband()
        end
    end,

    -- overwriting original function until AIpatch is released
    AssistBody = function(self)
        local platoonUnits = self:GetPlatoonUnits()
        local eng = platoonUnits[1]
        eng.AssistPlatoon = self
        local aiBrain = self:GetBrain()
        local assistData = self.PlatoonData.Assist
        local platoonPos = self:GetPlatoonPosition()
        local assistee = false
        local assistingBool = false
        WaitTicks(5)
        if not aiBrain:PlatoonExists(self) then
            return
        end
        if not eng.Dead then
            local guardedUnit = eng:GetGuardedUnit()
            if guardedUnit and not guardedUnit.Dead then
                if eng.AssistSet and assistData.PermanentAssist then
                    return
                end
                eng.AssistSet = false
                if guardedUnit:IsUnitState('Building') or guardedUnit:IsUnitState('Upgrading') then
                    return
                end
            end
        end
        self:Stop()
        if assistData then
            local assistRange = assistData.AssistRange or 80
            -- Check for units being built
            if assistData.BeingBuiltCategories then
                local unitsBuilding = aiBrain:GetListOfUnits(categories.CONSTRUCTION, false)
                for catNum, buildeeCat in assistData.BeingBuiltCategories do
                    local buildCat = ParseEntityCategory(buildeeCat)
                    for unitNum, unit in unitsBuilding do
                        if not unit.Dead and (unit:IsUnitState('Building') or unit:IsUnitState('Upgrading')) then
                            local buildingUnit = unit.UnitBeingBuilt
                            if buildingUnit and not buildingUnit.Dead and EntityCategoryContains(buildCat, buildingUnit) then
                                local unitPos = unit:GetPosition()
                                if unitPos and platoonPos and VDist2(platoonPos[1], platoonPos[3], unitPos[1], unitPos[3]) < assistRange then
                                    assistee = unit
                                    break
                                end
                            end
                        end
                    end
                    if assistee then
                        break
                    end
                end
            end
            -- Check for builders
            if not assistee and assistData.BuilderCategories then
                for catNum, buildCat in assistData.BuilderCategories do
                    local unitsBuilding = aiBrain:GetListOfUnits(ParseEntityCategory(buildCat), false)
                    for unitNum, unit in unitsBuilding do
                        if not unit.Dead and unit:IsUnitState('Building') then
                            local unitPos = unit:GetPosition()
                            if unitPos and platoonPos and VDist2(platoonPos[1], platoonPos[3], unitPos[1], unitPos[3]) < assistRange then
                                assistee = unit
                                break
                            end
                        end
                    end
                end
            end
            -- If the unit to be assisted is a factory, assist whatever it is assisting or is assisting it
            -- Makes sure all factories have someone helping out to load balance better
            if assistee and not assistee.Dead and EntityCategoryContains(categories.FACTORY, assistee) then
                local guardee = assistee:GetGuardedUnit()
                if guardee and not guardee.Dead and EntityCategoryContains(categories.FACTORY, guardee) then
                    local factories = AIUtils.AIReturnAssistingFactories(guardee)
                    table.insert(factories, assistee)
                    AIUtils.AIEngineersAssistFactories(aiBrain, platoonUnits, factories)
                    assistingBool = true
                elseif table.getn(assistee:GetGuards()) > 0 then
                    local factories = AIUtils.AIReturnAssistingFactories(assistee)
                    table.insert(factories, assistee)
                    AIUtils.AIEngineersAssistFactories(aiBrain, platoonUnits, factories)
                    assistingBool = true
                end
            end
        end
        if assistee and not assistee.Dead then
            if not assistingBool then
                eng.AssistSet = true
                IssueGuard(platoonUnits, assistee)
            end
        elseif not assistee then
            if eng.BuilderManagerData then
                local emLoc = eng.BuilderManagerData.EngineerManager:GetLocationCoords()
                local dist = assistData.AssistRange or 80
                if VDist3(eng:GetPosition(), emLoc) > dist then
                    self:MoveToLocation(emLoc, false)
                    WaitSeconds(9)
                end
            end
            WaitSeconds(1)
            self.AssistPlatoon = nil
            -- stop the platoon from endless assisting
            self:Stop()
            self:PlatoonDisband()
        end
    end,

    -- overwriting original function until AIpatch is released
    EngineerAssistAI = function(self)
        self:ForkThread(self.AssistBody)
        local aiBrain = self:GetBrain()
        WaitSeconds(self.PlatoonData.AssistData.Time or 60)
        if not aiBrain:PlatoonExists(self) then
            return
        end
        self.AssistPlatoon = nil
        -- stop the platoon from endless assisting
        self:Stop()
        WaitTicks(1)
        self:PlatoonDisband()
    end,

    -- overwriting original function until AIpatch is released
    ReclaimStructuresAI = function(self)
        local aiBrain = self:GetBrain()
        -- Only use this with AI-Uveso
        if not aiBrain.Uveso then
            return oldPlatoon.ReclaimStructuresAI(self)
        end
        self:Stop()
        local data = self.PlatoonData
        local radius = aiBrain:PBMGetLocationRadius(data.Location)
        local categories = data.Reclaim
        local counter = 0
        while aiBrain:PlatoonExists(self) do
            local unitPos = self:GetPlatoonPosition()
            local reclaimunit = false
            local distance = false
            for num,cat in categories do
                local reclaimcat = ParseEntityCategory(cat)
                local reclaimables = aiBrain:GetListOfUnits(reclaimcat, false)
                for k,v in reclaimables do
                    if not v.Dead and (not reclaimunit or VDist3(unitPos, v:GetPosition()) < distance) and unitPos then
                        reclaimunit = v
                        distance = VDist3(unitPos, v:GetPosition())
                    end
                end
                if reclaimunit then break end
            end
            if reclaimunit and not reclaimunit.Dead then
                counter = 0
                IssueReclaim(self:GetPlatoonUnits(), reclaimunit)
                -- Set ReclaimInProgress to prevent repairing (see RepairAI)
                reclaimunit.ReclaimInProgress = true
                local allIdle
                repeat
                    WaitSeconds(2)
                    if not aiBrain:PlatoonExists(self) then
                        return
                    end
                    allIdle = true
                    for k,v in self:GetPlatoonUnits() do
                        if not v.Dead and not v:IsIdleState() then
                            allIdle = false
                            break
                        end
                    end
                until allIdle
            elseif not reclaimunit or counter >= 5 then
                self:PlatoonDisband()
            else
                counter = counter + 1
                WaitSeconds(5)
            end
        end
    end,

    -- overwriting original function until AIpatch is released
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
        --LOG('*AI DEBUG: Engineer Repairing')
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
            allIdle = true
            if not eng:IsIdleState() then allIdle = false end
        until allIdle or count >= 30
        -- stop repairing
--        IssueClearCommands(self:GetPlatoonUnits())
--        self:Stop()
        self:MoveToLocation(self:GetPlatoonPosition(), false)
        WaitSeconds(2)
        self:PlatoonDisband()
    end,

    -- overwriting original function until AIpatch is released
    ReclaimAI = function(self)
        local brain = self:GetBrain()
        -- Only use this with AI-Uveso
        if not brain.Uveso then
            return oldPlatoon.ReclaimAI(self)
        end
        self:Stop()
        local locationType = self.PlatoonData.LocationType
        local createTick = GetGameTick()
        local oldClosest
        local units = self:GetPlatoonUnits()
        local eng = units[1]
        if not eng then
            self:PlatoonDisband()
            return
        end

        eng.BadReclaimables = eng.BadReclaimables or {}

        while brain:PlatoonExists(self) do
            local ents = AIUtils.AIGetReclaimablesAroundLocation(brain, locationType) or {}
            local pos = self:GetPlatoonPosition()

            if not ents[1] or not pos then
                WaitTicks(1)
                self:PlatoonDisband()
                return
            end

            local reclaim = {}
            local needEnergy = brain:GetEconomyStoredRatio('ENERGY') < 0.5

            for k,v in ents do
                if not IsProp(v) or eng.BadReclaimables[v] then continue end
                if not needEnergy or v.MaxEnergyReclaim then
                    local rpos = v:GetCachePosition()
                    table.insert(reclaim, {entity=v, pos=rpos, distance=VDist2(pos[1], pos[3], rpos[1], rpos[3])})
                end
            end

            IssueClearCommands(units)
            table.sort(reclaim, function(a, b) return a.distance < b.distance end)

            local recPos = nil
            local closest = {}
            for i, r in reclaim do
                -- This is slowing down the whole sim when engineers start's reclaiming, and every engi is pathing with CanPathTo (r.pos)
                -- even if the engineer will run into walls, it is only reclaimig and don't justifies the huge CPU cost. (Simspeed droping from +9 to +3 !!!!)
                -- eng.BadReclaimables[r.entity] = r.distance > 10 and not eng:CanPathTo (r.pos)
                eng.BadReclaimables[r.entity] = r.distance > 20
                if not eng.BadReclaimables[r.entity] then
                    IssueReclaim(units, r.entity)
                    if i > 10 then break end
                end
            end

            local reclaiming = not eng:IsIdleState()
            local max_time = self.PlatoonData.ReclaimTime

            while reclaiming do
                WaitSeconds(5)

                if eng:IsIdleState() or (max_time and (GetGameTick() - createTick)*10 > max_time) then
                    reclaiming = false
                end
            end

            local basePosition = brain.BuilderManagers[locationType].Position
            local location = AIUtils.RandomLocation(basePosition[1],basePosition[3])
            self:MoveToLocation(location, false)
            WaitSeconds(10)
            self:PlatoonDisband()
        end
    end,

    -- overwriting original function until AIpatch is released
    EngineerBuildAI = function(self)
        local aiBrain = self:GetBrain()
        -- Only use this with AI-Uveso
        if not aiBrain.Uveso then
            return oldPlatoon.EngineerBuildAI(self)
        end
        --DUNCAN - removed
        --self:Stop()

        local platoonUnits = self:GetPlatoonUnits()
        local armyIndex = aiBrain:GetArmyIndex()
        local x,z = aiBrain:GetArmyStartPos()
        local cons = self.PlatoonData.Construction
        local buildingTmpl, buildingTmplFile, baseTmpl, baseTmplFile

        local factionIndex = cons.FactionIndex or self:GetFactionIndex()

        buildingTmplFile = import(cons.BuildingTemplateFile or '/lua/BuildingTemplates.lua')
        baseTmplFile = import(cons.BaseTemplateFile or '/lua/BaseTemplates.lua')
        buildingTmpl = buildingTmplFile[(cons.BuildingTemplate or 'BuildingTemplates')][factionIndex]
        baseTmpl = baseTmplFile[(cons.BaseTemplate or 'BaseTemplates')][factionIndex]

        -- Old version of delaying the build of an experimental.
        -- This was implemended but a depricated function from sorian AI. 
        -- makes the same as the new DelayEqualBuildPlattons. Can be deleted if all platoons are rewritten to DelayEqualBuildPlattons
        -- (This is also the wrong place to do it. Should be called from Buildermanager BEFORE the builder is selected)
        if cons.T4 then
            if not aiBrain.T4Building then
                --LOG('EngineerBuildAI'..repr(cons))
                aiBrain.T4Building = true
                ForkThread(SUtils.T4Timeout, aiBrain)
                --LOG('Building T4 uinit, delaytime started')
            else
                --LOG('BLOCK building T4 unit; aiBrain.T4Building = TRUE')
                WaitTicks(1)
                self:PlatoonDisband()
                return
            end
        end

        local eng
        for k, v in platoonUnits do
            if not v.Dead and EntityCategoryContains(categories.ENGINEER, v) then --DUNCAN - was construction
                if not eng then
                    eng = v
                else
                    IssueClearCommands({v})
                    IssueGuard({v}, eng)
                end
            end
        end

        if not eng or eng.Dead then
            WaitTicks(1)
            self:PlatoonDisband()
            return
        end

        --DUNCAN - added
        if eng:IsUnitState('Building') or eng:IsUnitState('Upgrading') or  eng:IsUnitState("Enhancing") then
           return
        end

        --LOG('*AI DEBUG: EngineerBuild AI ' .. eng.Sync.id)

        if self.PlatoonData.NeedGuard then
            eng.NeedGuard = true
        end

        -------- CHOOSE APPROPRIATE BUILD FUNCTION AND SETUP BUILD VARIABLES --------
        local reference = false
        local refName = false
        local buildFunction
        local closeToBuilder
        local relative
        local baseTmplList = {}

        -- if we have nothing to build, disband!
        if not cons.BuildStructures then
            WaitTicks(1)
            self:PlatoonDisband()
            return
        end
        if cons.NearUnitCategory then
            self:SetPrioritizedTargetList('support', {ParseEntityCategory(cons.NearUnitCategory)})
            local unitNearBy = self:FindPrioritizedUnit('support', 'Ally', false, self:GetPlatoonPosition(), cons.NearUnitRadius or 50)
            --LOG("ENGINEER BUILD: " .. cons.BuildStructures[1] .." attempt near: ", cons.NearUnitCategory)
            if unitNearBy then
                reference = table.copy(unitNearBy:GetPosition())
                -- get commander home position
                --LOG("ENGINEER BUILD: " .. cons.BuildStructures[1] .." Near unit: ", cons.NearUnitCategory)
                if cons.NearUnitCategory == 'COMMAND' and unitNearBy.CDRHome then
                    reference = unitNearBy.CDRHome
                end
            else
                reference = table.copy(eng:GetPosition())
            end
            relative = false
            buildFunction = AIBuildStructures.AIExecuteBuildStructure
            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))
        elseif cons.Wall then
            local pos = aiBrain:PBMGetLocationCoords(cons.LocationType) or cons.Position or self:GetPlatoonPosition()
            local radius = cons.LocationRadius or aiBrain:PBMGetLocationRadius(cons.LocationType) or 100
            relative = false
            reference = AIUtils.GetLocationNeedingWalls(aiBrain, 200, 4, 'STRUCTURE - WALLS', cons.ThreatMin, cons.ThreatMax, cons.ThreatRings)
            table.insert(baseTmplList, 'Blank')
            buildFunction = AIBuildStructures.WallBuilder
        elseif cons.NearBasePatrolPoints then
            relative = false
            reference = AIUtils.GetBasePatrolPoints(aiBrain, cons.Location or 'MAIN', cons.Radius or 100)
            baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]
            for k,v in reference do
                table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, v))
            end
            -- Must use BuildBaseOrdered to start at the marker; otherwise it builds closest to the eng
            buildFunction = AIBuildStructures.AIBuildBaseTemplateOrdered
        elseif cons.FireBase and cons.FireBaseRange then
            --DUNCAN - pulled out and uses alt finder
            reference, refName = AIUtils.AIFindFirebaseLocation(aiBrain, cons.LocationType, cons.FireBaseRange, cons.NearMarkerType,
                                                cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType,
                                                cons.MarkerUnitCount, cons.MarkerUnitCategory, cons.MarkerRadius)
            if not reference or not refName then
                self:PlatoonDisband()
            end

        elseif cons.NearMarkerType and cons.ExpansionBase then
            local pos = aiBrain:PBMGetLocationCoords(cons.LocationType) or cons.Position or self:GetPlatoonPosition()
            local radius = cons.LocationRadius or aiBrain:PBMGetLocationRadius(cons.LocationType) or 100

            if cons.NearMarkerType == 'Expansion Area' then
                reference, refName = AIUtils.AIFindExpansionAreaNeedsEngineer(aiBrain, cons.LocationType,
                        (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                -- didn't find a location to build at
                if not reference or not refName then
                    self:PlatoonDisband()
                end
            elseif cons.NearMarkerType == 'Naval Area' then
                reference, refName = AIUtils.AIFindNavalAreaNeedsEngineer(aiBrain, cons.LocationType,
                        (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                -- didn't find a location to build at
                if not reference or not refName then
                    self:PlatoonDisband()
                end
            else
                --DUNCAN - use my alternative expansion finder on large maps below a certain time
                local mapSizeX, mapSizeZ = GetMapSize()
                if GetGameTimeSeconds() <= 780 and mapSizeX > 512 and mapSizeZ > 512 then
                    reference, refName = AIUtils.AIFindFurthestStartLocationNeedsEngineer(aiBrain, cons.LocationType,
                        (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                    if not reference or not refName then
                        reference, refName = AIUtils.AIFindStartLocationNeedsEngineer(aiBrain, cons.LocationType,
                            (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                    end
                else
                    reference, refName = AIUtils.AIFindStartLocationNeedsEngineer(aiBrain, cons.LocationType,
                        (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                end
                -- didn't find a location to build at
                if not reference or not refName then
                    self:PlatoonDisband()
                end
            end

            -- If moving far from base, tell the assisting platoons to not go with
            if cons.FireBase or cons.ExpansionBase then
                local guards = eng:GetGuards()
                for k,v in guards do
                    if not v.Dead and v.PlatoonHandle then
                        v.PlatoonHandle:PlatoonDisband()
                    end
                end
            end

            if not cons.BaseTemplate and (cons.NearMarkerType == 'Naval Area' or cons.NearMarkerType == 'Defensive Point' or cons.NearMarkerType == 'Expansion Area') then
                baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]
            end
            if cons.ExpansionBase and refName then
                AIBuildStructures.AINewExpansionBase(aiBrain, refName, reference, eng, cons)
            end
            relative = false
            if reference and aiBrain:GetThreatAtPosition(reference , 1, true, 'AntiSurface') > 0 then
                --aiBrain:ExpansionHelp(eng, reference)
            end
            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))
            -- Must use BuildBaseOrdered to start at the marker; otherwise it builds closest to the eng
            --buildFunction = AIBuildStructures.AIBuildBaseTemplateOrdered
            buildFunction = AIBuildStructures.AIBuildBaseTemplate
        elseif cons.NearMarkerType and cons.NearMarkerType == 'Defensive Point' then
            baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]

            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIFindDefensivePointNeedsStructure(aiBrain, cons.LocationType, (cons.LocationRadius or 100),
                            cons.MarkerUnitCategory, cons.MarkerRadius, cons.MarkerUnitCount, (cons.ThreatMin or 0), (cons.ThreatMax or 1),
                            (cons.ThreatRings or 1), (cons.ThreatType or 'AntiSurface'))

            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))

            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        elseif cons.NearMarkerType and cons.NearMarkerType == 'Naval Defensive Point' then
            baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]

            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIFindNavalDefensivePointNeedsStructure(aiBrain, cons.LocationType, (cons.LocationRadius or 100),
                            cons.MarkerUnitCategory, cons.MarkerRadius, cons.MarkerUnitCount, (cons.ThreatMin or 0), (cons.ThreatMax or 1),
                            (cons.ThreatRings or 1), (cons.ThreatType or 'AntiSurface'))

            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))

            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        elseif cons.NearMarkerType and (cons.NearMarkerType == 'Rally Point' or cons.NearMarkerType == 'Protected Experimental Construction') then
            --DUNCAN - add so experimentals build on maps with no markers.
            if not cons.ThreatMin or not cons.ThreatMax or not cons.ThreatRings then
                cons.ThreatMin = -1000000
                cons.ThreatMax = 1000000
                cons.ThreatRings = 0
            end
            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIGetClosestThreatMarkerLoc(aiBrain, cons.NearMarkerType, pos[1], pos[3],
                                                            cons.ThreatMin, cons.ThreatMax, cons.ThreatRings)
            if not reference then
                reference = pos
            end
            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))
            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        elseif cons.NearMarkerType then
            --WARN('*Data weird for builder named - ' .. self.BuilderName)
            if not cons.ThreatMin or not cons.ThreatMax or not cons.ThreatRings then
                cons.ThreatMin = -1000000
                cons.ThreatMax = 1000000
                cons.ThreatRings = 0
            end
            if not cons.BaseTemplate and (cons.NearMarkerType == 'Defensive Point' or cons.NearMarkerType == 'Expansion Area') then
                baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]
            end
            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIGetClosestThreatMarkerLoc(aiBrain, cons.NearMarkerType, pos[1], pos[3],
                                                            cons.ThreatMin, cons.ThreatMax, cons.ThreatRings)
            if cons.ExpansionBase and refName then
                AIBuildStructures.AINewExpansionBase(aiBrain, refName, reference, (cons.ExpansionRadius or 100), cons.ExpansionTypes, nil, cons)
            end
            if reference and aiBrain:GetThreatAtPosition(reference, 1, true) > 0 then
                --aiBrain:ExpansionHelp(eng, reference)
            end
            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))
            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        elseif cons.AvoidCategory then
            relative = false
            local pos = aiBrain.BuilderManagers[eng.BuilderManagerData.LocationType].EngineerManager:GetLocationCoords()
            local cat = cons.AdjacencyCategory
            -- convert text categories like 'MOBILE AIR' to 'categories.MOBILE * categories.AIR'
            if type(cat) == 'string' then
                cat = ParseEntityCategory(cat)
            end
            local avoidCat = cons.AvoidCategory
            -- convert text categories like 'MOBILE AIR' to 'categories.MOBILE * categories.AIR'
            if type(avoidCat) == 'string' then
                avoidCat = ParseEntityCategory(avoidCat)
            end
            local radius = (cons.AdjacencyDistance or 50)
            if not pos or not pos then
                WaitTicks(1)
                self:PlatoonDisband()
                return
            end
            reference  = AIUtils.FindUnclutteredArea(aiBrain, cat, pos, radius, cons.maxUnits, cons.maxRadius, avoidCat)
            buildFunction = AIBuildStructures.AIBuildAdjacency
            table.insert(baseTmplList, baseTmpl)
        elseif cons.AdjacencyCategory then
            relative = false
            local pos = aiBrain.BuilderManagers[eng.BuilderManagerData.LocationType].EngineerManager:GetLocationCoords()
            local cat = cons.AdjacencyCategory
            -- convert text categories like 'MOBILE AIR' to 'categories.MOBILE * categories.AIR'
            if type(cat) == 'string' then
                cat = ParseEntityCategory(cat)
            end
            local radius = (cons.AdjacencyDistance or 50)
            local radius = (cons.AdjacencyDistance or 50)
            if not pos or not pos then
                WaitTicks(1)
                self:PlatoonDisband()
                return
            end
            reference  = AIUtils.GetOwnUnitsAroundPoint(aiBrain, cat, pos, radius, cons.ThreatMin,
                                                        cons.ThreatMax, cons.ThreatRings)
            buildFunction = AIBuildStructures.AIBuildAdjacency
            table.insert(baseTmplList, baseTmpl)
        else
            table.insert(baseTmplList, baseTmpl)
            relative = true
            reference = true
            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        end
        if cons.BuildClose then
            closeToBuilder = eng
        end
        if cons.BuildStructures[1] == 'T1Resource' or cons.BuildStructures[1] == 'T2Resource' or cons.BuildStructures[1] == 'T3Resource' then
            relative = true
            closeToBuilder = eng
            local guards = eng:GetGuards()
            for k,v in guards do
                if not v.Dead and v.PlatoonHandle and aiBrain:PlatoonExists(v.PlatoonHandle) then
                    v.PlatoonHandle:PlatoonDisband()
                end
            end
        end

        --LOG("*AI DEBUG: Setting up Callbacks for " .. eng.Sync.id)
        self.SetupEngineerCallbacks(eng)

        -------- BUILD BUILDINGS HERE --------
        for baseNum, baseListData in baseTmplList do
            for k, v in cons.BuildStructures do
                if aiBrain:PlatoonExists(self) then
                    if not eng.Dead then
                  local faction = SUtils.GetEngineerFaction(eng)
                  if aiBrain.CustomUnits[v] and aiBrain.CustomUnits[v][faction] then
                     local replacement = SUtils.GetTemplateReplacement(aiBrain, v, faction)
                     if replacement then
                        buildFunction(aiBrain, eng, v, closeToBuilder, relative, replacement, baseListData, reference, cons.NearMarkerType)
                     else
                        buildFunction(aiBrain, eng, v, closeToBuilder, relative, buildingTmpl, baseListData, reference, cons.NearMarkerType)
                     end
                  else
                     buildFunction(aiBrain, eng, v, closeToBuilder, relative, buildingTmpl, baseListData, reference, cons.NearMarkerType)
                  end
                    else
                        if aiBrain:PlatoonExists(self) then
                            WaitTicks(1)
                            self:PlatoonDisband()
                            return
                        end
                    end
                end
            end
        end

        -- wait in case we're still on a base
        if not eng.Dead then
            local count = 0
            while eng:IsUnitState('Attached') and count < 2 do
                WaitSeconds(6)
                count = count + 1
            end
        end

        if not eng:IsUnitState('Building') then
            return self.ProcessBuildCommand(eng, false)
        end
    end,

    -- overwriting original function until AIpatch is released
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
                -- Output: WARNING: [platoon.lua, line:xxx] *UnitUpgradeAI ERROR: Can\'t find StructureUpgradeTemplate for mobile unit: ABC1234
                WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] *UnitUpgradeAI ERROR: Can\'t upgrade structure with StructureUpgradeTemplate: ' .. repr(v:GetUnitId()) )
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
        local IgnoreAntiAir = self.PlatoonData.IgnoreAntiAir
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
                    --LOG('* AttackPrioritizedLandTargetsAIUveso: Targetting... recived retUnit, path, reason '..repr(reason)..'  ')
                    if UnitWithPath then
                        self:Stop()
                        target = UnitWithPath
                        --LOG('* AttackPrioritizedLandTargetsAIUveso: UnitWithPath.')
                        self:AttackTarget(target)
                    elseif UnitNoPath then
                        self:Stop()
                        target = UnitNoPath
                        --LOG('* AttackPrioritizedLandTargetsAIUveso: MoveWithTransport() DistanceToTarget:'..DistanceToTarget)
                        if self.MovementLayer == 'Air' then
                            self:Stop()
                            self:AttackTarget(target)
                        else
                            self:Stop()
                            self:SimpleReturnToBase(basePosition)
                        end
                    else
                        -- we have no target return to main base
                        --LOG('* AttackPrioritizedLandTargetsAIUveso: ForceReturnToNearestBaseAIUveso() (no target)')
                        self:Stop()
                        self:SimpleReturnToBase(basePosition)
                    end
                else
                    DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0)
                    --LOG('* AttackPrioritizedLandTargetsAIUveso: Target Valid. range to target:'..DistanceToTarget)
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
        local IgnoreGroundDefense = self.PlatoonData.IgnoreGroundDefense
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
                            if path then
                                --LOG('* AttackPrioritizedLandTargetsAIUveso: MovePath.')
                                self:MovePath(aiBrain, path, bAggroMove, target)
                            -- if we dont have a path, but UnitWithPath is true, then we have no map markers but PathCanTo() found a direct path
                            else
                                --LOG('* AttackPrioritizedLandTargetsAIUveso: MoveDirect.')
                                self:MoveDirect(aiBrain, bAggroMove, target)
                            end
                            -- We moved to the target, attack it now if its still exists
                            if target and not target.Dead then
                                self:AttackTarget(target)
                            end
                        end
                    elseif UnitNoPath then
                        self:Stop()
                        target = UnitNoPath
                        --LOG('* AttackPrioritizedLandTargetsAIUveso: MoveWithTransport() DistanceToTarget:'..DistanceToTarget)
                        self:MoveWithTransport(aiBrain, bAggroMove, target, basePosition, ExperimentalInPlatoon)
                        -- We moved to the target, attack it now if its still exists
                        if target and not target.Dead then
                            self:AttackTarget(target)
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
                    self:AttackTarget(target)
                end
            end
            WaitSeconds(3)
        end
    end,

    MoveWithTransport = function(self, aiBrain, bAggroMove, target, basePosition, ExperimentalInPlatoon)
        local TargetPosition = table.copy(target:GetPosition())
        LOG('* MoveWithTransport: CanPathTo() failed for '..repr(TargetPosition)..' forcing SendPlatoonWithTransportsNoCheck.')
        if not ExperimentalInPlatoon and aiBrain:PlatoonExists(self) then
            usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, TargetPosition, true, false)
        end
        if not usedTransports then
            LOG('* MoveWithTransport: SendPlatoonWithTransportsNoCheck failed.')
            local PlatoonPos = self:GetPlatoonPosition() or TargetPosition
            local DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, TargetPosition[1] or 0, TargetPosition[3] or 0)
            local DistanceToBase = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
            if DistanceToBase < DistanceToTarget or DistanceToTarget > 50 then
                LOG('* MoveWithTransport: base is nearer then distance to target or distance to target over 50. Return To base')
                self:SimpleReturnToBase(basePosition)
            else
                LOG('* MoveWithTransport: Direct move to Target')
                if bAggroMove then
                    self:AggressiveMoveToLocation(TargetPosition)
                else
                    self:MoveToLocation(TargetPosition, false)
                end
            end
        else
            LOG('* MoveWithTransport: We got a transport!!')
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
                    LOG('* MoveDirect: Stucked while moving to target. Stuck='..Stuck)
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
        local IgnoreGroundDefense = self.PlatoonData.IgnoreGroundDefense
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
                            if path then
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
                                                LOG('* AttackPrioritizedSeaTargetsAIUveso: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                                                self:Stop()
                                                self:ForceReturnToNavalBaseAIUveso(aiBrain, basePosition)
                                            end
                                        end
                                        -- If we lose our target, stop moving to it.
                                        if not target then
                                            LOG('* AttackPrioritizedSeaTargetsAIUveso: Lost target while moving to Waypoint. '..repr(path[i]))
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
            if aiBrain:GetEconomyOverTime().MassIncome > 1000 then
                --LOG('Mass over 1000. Eco running with 30%')
                ratio = 0.3
            elseif GetGameTimeSeconds() > 1800 then -- 30 * 60 
                ratio = 0.40
            elseif GetGameTimeSeconds() > 1200 then -- 20 * 60
                ratio = 0.60
            elseif GetGameTimeSeconds() > 900 then -- 15 * 60
                ratio = 0.50
            elseif GetGameTimeSeconds() > 600 then -- 10 * 60
                ratio = 0.40
            elseif GetGameTimeSeconds() > 360 then -- 6 * 60
                ratio = 0.30
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
                LOG('* SimpleReturnToBase: no Platoon Position')
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
        LOG('* NukePlatoonAI: Started')
        local aiBrain = self:GetBrain()
        local platoonUnits
        local mapSizeX, mapSizeZ = GetMapSize()
        while aiBrain:PlatoonExists(self) do
            ---------------------------------------------------------------------------------------------------
            -- Count Launchers, set them to automode, count stored missiles
            ---------------------------------------------------------------------------------------------------
            local MissileCount = 0
            local LauncherReady = 0
            local EnemyTargetPositions = {}
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
            WaitTicks(1)
            ---------------------------------------------------------------------------------------------------
            -- check if the enemy has more then 2 Anti Missiles, and if we have the eco to build nukes
            ---------------------------------------------------------------------------------------------------
            local EnemyAntiMissile = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * (categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3) + (categories.SHIELD * categories.EXPERIMENTAL), Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
            if (table.getn(EnemyAntiMissile) > 2 or aiBrain:GetEconomyStoredRatio('ENERGY') < 0.5 or aiBrain:GetEconomyStoredRatio('MASS') < 0.5) and not aiBrain.HasParagon then
                -- We don't want to attack. Save the eco and disable launchers.
                --LOG('* NukePlatoonAI: Too much Antimissiles or low mass/energy, deactivating all nuke launchers')
                for k,Launcher in platoonUnits do
                    -- Check if the launcher is active
                    if not Launcher:IsPaused() then
                        -- yes, its active. Disable it.
                        Launcher:SetPaused( true )
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
            WaitTicks(1)
            ---------------------------------------------------------------------------------------------------
            -- Launch nukes if possible
            ---------------------------------------------------------------------------------------------------
            LOG('* NukePlatoonAI: MissileCount '..MissileCount..' Unprotected!')
            if MissileCount > 0 then
                local EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * categories.EXPERIMENTAL + categories.STRUCTURE * categories.TECH3 - categories.MASSEXTRACTION , Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                ---------------------------------------------------------------------------------------------------
                -- first try to target all targets that are not protected from enemy anti missile
                ---------------------------------------------------------------------------------------------------
                LOG('* NukePlatoonAI: EnemyTarget in EnemyUnits ')
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
                            --LOG('* NukePlatoonAI: Target in range of Nuke Anti Missile. Skiped')
                            ToClose = true
                            break -- break out of the EnemyTargetPositions loop
                        end
                    end
                    if ToClose then
                        continue -- Skip this enemytarget and check the next
                    end
                    table.insert(EnemyTargetPositions, EnemyTargetPos)
                end
                WaitTicks(1)
                ---------------------------------------------------------------------------------------------------
                -- Now, if we have targets, shot at it
                ---------------------------------------------------------------------------------------------------
                LOG('* NukePlatoonAI: table.getn(EnemyTargetPositions) '..table.getn(EnemyTargetPositions))
                if table.getn(EnemyTargetPositions) > 0 then
                    NukeBussy = {}
                    while table.getn(EnemyTargetPositions) > 0 do
                        LOG('* NukePlatoonAI: table.getn(EnemyTargetPositions) '..table.getn(EnemyTargetPositions))
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
                                LOG('* NukePlatoonAI: NukeBussy. Skiped')
                                -- The luancher is bussy with launching missiles. Skip it.
                                continue
                            end
                            -- check if we have at least 1 missile
                            if Launcher:GetNukeSiloAmmoCount() <= 0 then
                                LOG('* NukePlatoonAI: GetNukeSiloAmmoCount() <= 0. Skiped')
                                -- we don't have a missile, skip this launcher
                                continue
                            end
                            -- check if the target is closer then 20000
                            LauncherPos = Launcher:GetPosition() or {0,0,0}
                            if VDist2(LauncherPos[1],LauncherPos[3],ActualTargetPos[1],ActualTargetPos[3]) > 20000 then
                                LOG('* NukePlatoonAI: Target out of range. Skiped')
                                -- Target is out of range, skip this launcher
                                continue
                            end
                            -- Attack the target
                            LOG('* NukePlatoonAI: Attacking Enemy Position!')
                            IssueNuke({Launcher}, ActualTargetPos)
                            NukeBussy[Launcher] = true
                            LauncherReady = LauncherReady - 1
                            MissileCount = MissileCount - 1
                            break -- stop seraching for available launchers and check the next target
                        end
                        if table.getn(NukeBussy) >= table.getn(platoonUnits) then
                            LOG('* NukePlatoonAI: All Launchers are bussy! Break!')
                            break  -- stop seraching for targets, we don't hava a launcher ready.
                        end
                        WaitTicks(40)
                    end
                    WaitTicks(450)
                end
                WaitTicks(1)
                ---------------------------------------------------------------------------------------------------
                -- Try to overwhelm anti nuke if we have more then 10 launchers and 22 missiles ready
                ---------------------------------------------------------------------------------------------------
                LOG('* NukePlatoonAI: MissileCountB '..MissileCount..' Overwhelm!')
                if MissileCount > 22 and table.getn(platoonUnits) > 10 then
                    LOG('* NukePlatoonAI: Overwhelm: MissileCount > 15 ('..MissileCount..')')
                    local AntiMissileRanger = {}
                    ---------------------------------------------------------------------------------------------------
                    -- get a list with all antinukes and distance ti each other
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
                        --LOG('* NukePlatoonAI: Overwhelm: Antimissile with highest dinstance to other antimisiiles has HighIndex= '..HighIndex)
                        -- kill the launcher will all missiles we have
                        EnemyTarget = EnemyAntiMissile[HighIndex]
                        TargetPosition = EnemyTarget:GetPosition() or false
                    elseif EnemyAntiMissile[1] and not EnemyAntiMissile[1].Dead then
                        --LOG('* NukePlatoonAI: Overwhelm: Targetting Antimissile[1]')
                        EnemyTarget = EnemyAntiMissile[1]
                        TargetPosition = EnemyTarget:GetPosition() or false
                    end
                    WaitTicks(1)
                    ---------------------------------------------------------------------------------------------------
                    -- Fire as long as the target is exists
                    ---------------------------------------------------------------------------------------------------
                    LOG('* NukePlatoonAI: while EnemyTarget do ')
                    while EnemyTarget and not EnemyTarget.Dead do
                        LOG('* NukePlatoonAI: Overwhelm Loop!')
                        local missile = false
                        for Index, Launcher in platoonUnits do
                            if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                                -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                                self:PlatoonDisband()
                                return
                            end
                            --LOG('* NukePlatoonAI: Overwhelm: Fireing Nuke: '..repr(Index))
                            if Launcher:GetNukeSiloAmmoCount() > 0 then
                                if Launcher:GetNukeSiloAmmoCount() > 1 then
                                    missile = true
                                end
                                IssueNuke({Launcher}, TargetPosition)
                                LauncherReady = LauncherReady - 1
                                MissileCount = MissileCount - 1
                            end
                            if not EnemyTarget or EnemyTarget.Dead then
                                LOG('* NukePlatoonAI: Overwhelm: Target is dead. break fire loop')
                                break -- break the "for Index, Launcher in platoonUnits do" loop
                            end
                        end
                        if not missile then
                            LOG('* NukePlatoonAI: Overwhelm: Nukes are empty')
                            break -- break the "while EnemyTarget do" loop
                        end
                        WaitTicks(40)
                    end
                end
                WaitTicks(1)
                LOG('* NukePlatoonAI: MissileCountC '..MissileCount..' Jericho!')
                ---------------------------------------------------------------------------------------------------
                -- If we have more then 8 missiles per enemy antimissile, then Fire at all
                ---------------------------------------------------------------------------------------------------
                if MissileCount > table.getn(EnemyAntiMissile) * 8 then
                    ---------------------------------------------------------------------------------------------------
                    -- first try to target all targets that are not protected from enemy anti missile
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
                                --LOG('* NukePlatoonAI: Target in range of Nuke Anti Missile. Skiped')
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
                WaitTicks(1)
                ---------------------------------------------------------------------------------------------------
                -- Now, if we have targets, shot at it
                ---------------------------------------------------------------------------------------------------
                NukeBussy = {}
                while table.getn(EnemyTargetPositions) > 0 do
                    LOG('* NukePlatoonAI: table.getn(EnemyTargetPositions) '..table.getn(EnemyTargetPositions))
                    -- get a target and remove it from the target list
                    local ActualTargetPos = table.remove(EnemyTargetPositions)
                    -- loop over all nuke launcher
                    for _, Launcher in platoonUnits do
                        -- check if the launcher has already launched a nuke
                        if NukeBussy[Launcher] then
                            LOG('* NukePlatoonAI: NukeBussy. Skiped')
                            -- The luancher is bussy with launching missiles. Skip it.
                            continue
                        end
                        -- check if we have at least 1 missile
                        if Launcher:GetNukeSiloAmmoCount() <= 0 then
                            LOG('* NukePlatoonAI: GetNukeSiloAmmoCount() <= 0. Skiped')
                            -- we don't have a missile, skip this launcher
                            continue
                        end
                        -- check if the target is closer then 20000
                        LauncherPos = Launcher:GetPosition() or {0,0,0}
                        if VDist2(LauncherPos[1],LauncherPos[3],ActualTargetPos[1],ActualTargetPos[3]) > 20000 then
                            LOG('* NukePlatoonAI: Target out of range. Skiped')
                            -- Target is out of range, skip this launcher
                            continue
                        end
                        -- Attack the target
                        LOG('* NukePlatoonAI: Attacking Enemy Position!')
                        IssueNuke({Launcher}, ActualTargetPos)
                        NukeBussy[Launcher] = true
                        LauncherReady = LauncherReady - 1
                        MissileCount = MissileCount - 1
                        break -- stop seraching for available launchers and check the next target
                    end
                    if table.getn(NukeBussy) >= table.getn(platoonUnits) then
                        LOG('* NukePlatoonAI: All Launchers are bussy! Break!')
                        break  -- stop seraching for targets, we don't hava a launcher ready.
                    end
                    WaitTicks(1)
                end
                LOG('* NukePlatoonAI: MissileCountD '..MissileCount..' Finish him!')
                ---------------------------------------------------------------------------------------------------
                -- Well, if we are here then we don't have any primary targets. Enemy is almost dead, finish him!
                ---------------------------------------------------------------------------------------------------
                EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE + categories.MOBILE , Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                if MissileCount > 1 and table.getn(EnemyUnits) > 0 then
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
                WaitTicks(1)
                ---------------------------------------------------------------------------------------------------
                -- Now, if we have targets, shot at it
                ---------------------------------------------------------------------------------------------------
                NukeBussy = {}
                while table.getn(EnemyTargetPositions) > 0 do
                    LOG('* NukePlatoonAI: table.getn(EnemyTargetPositions) '..table.getn(EnemyTargetPositions))
                    -- get a target and remove it from the target list
                    local ActualTargetPos = table.remove(EnemyTargetPositions)
                    -- loop over all nuke launcher
                    for _, Launcher in platoonUnits do
                        -- check if the launcher has already launched a nuke
                        if NukeBussy[Launcher] then
                            LOG('* NukePlatoonAI: NukeBussy. Skiped')
                            -- The luancher is bussy with launching missiles. Skip it.
                            continue
                        end
                        -- check if we have at least 1 missile
                        if Launcher:GetNukeSiloAmmoCount() <= 0 then
                            LOG('* NukePlatoonAI: GetNukeSiloAmmoCount() <= 0. Skiped')
                            -- we don't have a missile, skip this launcher
                            continue
                        end
                        -- check if the target is closer then 20000
                        LauncherPos = Launcher:GetPosition() or {0,0,0}
                        if VDist2(LauncherPos[1],LauncherPos[3],ActualTargetPos[1],ActualTargetPos[3]) > 20000 then
                            LOG('* NukePlatoonAI: Target out of range. Skiped')
                            -- Target is out of range, skip this launcher
                            continue
                        end
                        -- Attack the target
                        LOG('* NukePlatoonAI: Attacking Enemy Position!')
                        IssueNuke({Launcher}, ActualTargetPos)
                        NukeBussy[Launcher] = true
                        LauncherReady = LauncherReady - 1
                        MissileCount = MissileCount - 1
                        break -- stop seraching for available launchers and check the next target
                    end
                    if table.getn(NukeBussy) >= table.getn(platoonUnits) then
                        LOG('* NukePlatoonAI: All Launchers are bussy! Break!')
                        break  -- stop seraching for targets, we don't hava a launcher ready.
                    end
                    WaitTicks(1)
                end

            end
            -- Stop all nukes and check if they are still alive
            IssueClearCommands(platoonUnits)
            WaitTicks(1)
            -- find dead units inside the platoon and disband if we find one
            for k,Launcher in platoonUnits do
                if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                    -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                    self:PlatoonDisband()
                    --LOG('* NukePlatoonAI: PlatoonDisband')
                    return
                end
            end
            WaitTicks(50)
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
