
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
        local DistanceToTarget = 0
        local IgnoreAntiAir = self.PlatoonData.IgnoreAntiAir
        local maxRadius = self.PlatoonData.SearchRadius or 100
        local PlatoonPos = self:GetPlatoonPosition()
        local LastTargetPos = PlatoonPos
        local basePosition
        if self.MovementLayer == 'Water' then
            -- we could search for the nearest naval base here, but buildposition is almost at the same location
            basePosition = PlatoonPos
        else
            -- land and air units are assigned to mainbase
            basePosition = aiBrain.BuilderManagers['MAIN'].Position
        end
        local GetTargetsFromBase = self.PlatoonData.SearchRadius or true
        local GetTargetsFrom = basePosition
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        while aiBrain:PlatoonExists(self) do
            if self:IsOpponentAIRunning() then
                PlatoonPos = self:GetPlatoonPosition()
                if not GetTargetsFromBase then
                    GetTargetsFrom = PlatoonPos
                end
                if target and not target.Dead then
                    DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0)
                end
                -- only get a new target and make a move command if the target is dead or after 2 seconds
                if DistanceToTarget < 20 or not target or target.Dead or LastTargetCheck + 1 < GetGameTimeSeconds() then
                    --LOG('* InterceptorAIUveso: Targetting...')
                    target = AIUtils.AIFindNearestCategoryTargetInRange(aiBrain, self, 'Attack', GetTargetsFrom, maxRadius, PrioritizedTargetList, TargetSearchCategory, aiBrain:GetCurrentEnemy() )
                    if not target or target.Dead then
                        --LOG('* InterceptorAIUveso: No target found for focussed enemy. Searching for other enemies...')
                        target = AIUtils.AIFindNearestCategoryTargetInRange(aiBrain, self, 'Attack', GetTargetsFrom, maxRadius, PrioritizedTargetList, TargetSearchCategory, false )
                    end
                    if target then
                        --LOG('* InterceptorAIUveso: Target!.')
                        LastTargetCheck = GetGameTimeSeconds()
                        LastTargetPos = table.copy(target:GetPosition())
                        DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0)
                        local AntiAirUnitsAtTargetPos = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * categories.ANTIAIR , LastTargetPos, 60, 'Enemy' )
                        --LOG("* InterceptorAIUveso: AntiAirUnitsAtTargetPos: " .. AntiAirUnitsAtTargetPos)

                        if IgnoreAntiAir and AntiAirUnitsAtTargetPos > IgnoreAntiAir then
                            --LOG('* InterceptorAIUveso: Return to MainBase (AntiAirUnitsAtTargetPos = '..AntiAirUnitsAtTargetPos..' )')
                            self:Stop()
                            self:SimpleReturnToMainBase(basePosition)
                        elseif not self.PlatoonData.UseMoveOrder then
                            --LOG('* InterceptorAIUveso: AttackTarget! UseMoveOrder=false.')
                            self:Stop()
                            --self:MoveToLocation(LastTargetPos, false)
                            self:AttackTarget(target)
                        else
                            --LOG('* InterceptorAIUveso: MoveToLocation! UseMoveOrder=true.')
                            self:Stop()
                            self:MoveToLocation(LastTargetPos, false)
                        end
                    else
                        -- we have no target return to main base
                        --LOG('* InterceptorAIUveso: Return to MainBase (no target)')
                        self:Stop()
                        self:SimpleReturnToMainBase(basePosition)
                    end
                else
                    --LOG('* InterceptorAIUveso: Target Valid. range to target:'..DistanceToTarget..' - '.. LastTargetCheck - GetGameTimeSeconds() +10 )
                    if LastTargetCheck + 15 < GetGameTimeSeconds() then
                        --LOG('* InterceptorAIUveso: We are stucked! Return to MainBase.')
                        self:Stop()
                        self:SimpleReturnToMainBase(basePosition)
                    end
                end
            end
            --LOG('* InterceptorAIUveso: WaitSeconds(3)')
            WaitSeconds(1)
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
        local LastTargetCheck = GetGameTimeSeconds()
        local DistanceToTarget = 0
        local basePosition = aiBrain.BuilderManagers['MAIN'].Position
        local IgnoreGroundDefense = self.PlatoonData.IgnoreGroundDefense
        while aiBrain:PlatoonExists(self) do
            if self:IsOpponentAIRunning() then
                PlatoonPos = self:GetPlatoonPosition()
                if target and not target.Dead then
                    DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0)
                end
                -- only get a new target and make a move command if the target is dead or after 10 seconds
                if DistanceToTarget < 10 or not target or target.Dead then
                    --LOG('* AttackPrioritizedLandTargetsAIUveso: Targetting...')
                    target = AIUtils.AIFindNearestCategoryTargetInRange(aiBrain, self, 'Attack', PlatoonPos, maxRadius, PrioritizedTargetList, TargetSearchCategory, false )
                    if not target or target.Dead then
                        --LOG('* AttackPrioritizedLandTargetsAIUveso: No target found for focussed enemy. Searching for other enemies...')
                        target = self:FindClosestUnit('Attack', 'Enemy', true, categories.LAND - categories.WALL)
                    end
                    if target then
                        --LOG('* AttackPrioritizedLandTargetsAIUveso: Target!.')
                        LastTargetCheck = GetGameTimeSeconds()
                        LastTargetPos = table.copy(target:GetPosition())
                        DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0)
                        local GroundDefenseUnitsAtTargetPos = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.DIRECTFIRE) , LastTargetPos, 60, 'Enemy' )
                        --LOG("* AttackPrioritizedLandTargetsAIUveso: GroundDefenseUnitsAtTargetPos: " .. GroundDefenseUnitsAtTargetPos)
                        if DistanceToTarget < 50 then
                            --LOG('* AttackPrioritizedLandTargetsAIUveso: AttackTarget! DistanceToTarget:'..DistanceToTarget)
                            self:AttackTarget(target)
                        elseif IgnoreGroundDefense and GroundDefenseUnitsAtTargetPos > IgnoreGroundDefense then
                            --LOG('* AttackPrioritizedLandTargetsAIUveso: SimpleReturnToMainBase() (GroundDefenseUnitsAtTargetPos = '..GroundDefenseUnitsAtTargetPos..' )')
                            self:SimpleReturnToMainBase(basePosition)
                        else
                            --LOG('* AttackPrioritizedLandTargetsAIUveso: MoveToLocationInclTransport() AggressiveMove='..repr(bAggroMove)..'. DistanceToTarget:'..DistanceToTarget)
                            self:MoveToLocationInclTransport(target, false, bAggroMove, WantsTransport, basePosition, ExperimentalInPlatoon)
                        end
                    else
                        -- we have no target return to main base
                        --LOG('* AttackPrioritizedLandTargetsAIUveso: ForceReturnToNearestBaseAIUveso() (no target)')
                        self:ForceReturnToNearestBaseAIUveso()
                    end
                else
                    --LOG('* AttackPrioritizedLandTargetsAIUveso: Target Valid. range to target:'..DistanceToTarget..' - '.. LastPositionCheck + 30 - GetGameTimeSeconds() )
                    if LastPositionCheck + 30 < GetGameTimeSeconds() then
                        if PlatoonPos[1] == lastPlatoonPos[1] and PlatoonPos[3] == lastPlatoonPos[3] then
                            --LOG('* AttackPrioritizedLandTargetsAIUveso: We are stucked! Return to MainBase.')
                            self:ForceReturnToNearestBaseAIUveso()
                        else
                            --LOG('* AttackPrioritizedLandTargetsAIUveso: We are Ok, move on!')
                        end
                        lastPlatoonPos = table.copy(PlatoonPos)
                        LastPositionCheck = GetGameTimeSeconds()
                    end
                end
            end
            --LOG('* AttackPrioritizedLandTargetsAIUveso: WaitSeconds(3)')
            WaitSeconds(3)
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
        local LastTargetPos = PlatoonPos
        local DistanceToTarget = 0
        local DistanceToBase = 0
        local basePosition = PlatoonPos   -- Platoons will be created near a base, so we can return to this position if we don't have targets.
        local IgnoreGroundDefense = self.PlatoonData.IgnoreGroundDefense
        while aiBrain:PlatoonExists(self) do
            if self:IsOpponentAIRunning() then
                PlatoonPos = self:GetPlatoonPosition()
                if target and not target.Dead then
                    DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0)
                end
                -- only get a new target and make a move command if the target is dead or after 10 seconds
                if DistanceToTarget < 10 or not target or target.Dead or LastTargetCheck + 3 < GetGameTimeSeconds() then
                    --LOG('* AttackPrioritizedSeaTargetsAIUveso: Targetting...')
                    target = AIUtils.AIFindNearestNavalCategoryTargetInRange(aiBrain, self, 'Attack', PlatoonPos, maxRadius, PrioritizedTargetList, TargetSearchCategory, false )
                    if target then
                        --LOG('* AttackPrioritizedSeaTargetsAIUveso: Target!.')
                        LastTargetCheck = GetGameTimeSeconds()
                        LastTargetPos = table.copy(target:GetPosition())
                        DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0)
                        local GroundDefenseUnitsAtTargetPos = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.DIRECTFIRE) , LastTargetPos, 60, 'Enemy' )
                        --LOG("* AttackPrioritizedSeaTargetsAIUveso: GroundDefenseUnitsAtTargetPos: " .. GroundDefenseUnitsAtTargetPos)

                        if IgnoreGroundDefense and GroundDefenseUnitsAtTargetPos > IgnoreGroundDefense then
                            --LOG('* AttackPrioritizedSeaTargetsAIUveso: Return to MainBase (GroundDefenseUnitsAtTargetPos = '..GroundDefenseUnitsAtTargetPos..' )')
                            self:SimpleReturnToMainBase(basePosition)
                        else
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
                                        if dist < 25 then
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
                                                break
                                            end
                                        end
                                        -- If we lose our target, stop moving to it.
                                        if not target then
                                            LOG('* AttackPrioritizedSeaTargetsAIUveso: Lost target while moving to Waypoint. '..repr(path[i]))
                                            self:Stop()
                                            return
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
                        DistanceToBase = VDist2(PlatoonPos[1], PlatoonPos[3], basePosition[1], basePosition[3])
                        if DistanceToBase > 30 then
                            self:ForceReturnToNavalBaseAIUveso(aiBrain, basePosition)
                        end
                    end
                else
                    --LOG('* AttackPrioritizedSeaTargetsAIUveso: Target Valid. range to target:'..DistanceToTarget..' - '.. LastTargetCheck - GetGameTimeSeconds() +10 )
                    if LastTargetCheck + 15 < GetGameTimeSeconds() then
                        --LOG('* AttackPrioritizedSeaTargetsAIUveso: We are stucked! Return to MainBase.')
                        DistanceToBase = VDist2(PlatoonPos[1], PlatoonPos[3], basePosition[1], basePosition[3])
                        if DistanceToBase > 30 then
                            self:ForceReturnToNavalBaseAIUveso(aiBrain, basePosition)
                        end
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
        --LOG('* MoveToLocationInclTransport: PlatoonGenerateSafePathTo: '..repr(reason))
        if not aiBrain:PlatoonExists(self) then
            --LOG('* MoveToLocationInclTransport: Unit died on his way to the destination.')
            return
        end
        if path then
            --LOG('* MoveToLocationInclTransport: Land Path found. no transport needed.')
        else
            --LOG('* MoveToLocationInclTransport: No Path found. Transport needed!!')
        end
        -- use a transporter if we don't have a path, or if we want a transport
        if not ExperimentalInPlatoon and ((not path and reason ~= 'NoGraph') or WantsTransport)  then
            LOG('* MoveToLocationInclTransport: SendPlatoonWithTransportsNoCheck')
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
                --LOG('* MoveToLocationInclTransport: moving to destination by path.')
                for i=1, table.getn(path) do
                    --LOG('* MoveToLocationInclTransport: moving to destination. i: '..i..' coords '..repr(path[i]))
                    if bAggroMove then
                        self:AggressiveMoveToLocation(path[i])
                    else
                        self:MoveToLocation(path[i], false)
                    end
                    --LOG('* MoveToLocationInclTransport: moving to Waypoint')
                    local PlatoonPosition
                    local Lastdist
                    local dist
                    local Stuck = 0
                    while aiBrain:PlatoonExists(self) do
                        PlatoonPosition = self:GetPlatoonPosition() or {0,0,0}
                        dist = VDist2( path[i][1], path[i][3], PlatoonPosition[1], PlatoonPosition[3] )
                        -- are we closer then 15 units from the next marker ? Then break and move to the next marker
                        if dist < 25 then
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
                                break
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
                            self:AggressiveMoveToLocation(TargetPosition)
                        else
                            self:MoveToLocation(TargetPosition, false)
                        end
                    else
                        --LOG('* MoveToLocationInclTransport: CanPathTo() failed for '..repr(TargetPosition)..' forcing SendPlatoonWithTransportsNoCheck.')
                        if not ExperimentalInPlatoon then
                            usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, TargetPosition, true, false)
                        end
                        if not usedTransports then
                            --LOG('* MoveToLocationInclTransport: CanPathTo() and SendPlatoonWithTransportsNoCheck failed. SimpleReturnToMainBase!')
                            local PlatoonPos = self:GetPlatoonPosition()
                            local DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, TargetPosition[1] or 0, TargetPosition[3] or 0)
                            local DistanceToBase = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
                            if DistanceToBase < DistanceToTarget and DistanceToTarget > 50 then
                                --LOG('* MoveToLocationInclTransport: base is nearer then distance to target and distance to target over 50. Return To base')
                                self:SimpleReturnToMainBase(basePosition)
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
                    LOG('* MoveToLocationInclTransport: We have no path but reason is not "NoGraph". So why we dont get a path ??? reason: '..repr(reason))
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
            LOG('* TransferAIUveso: '..repr(self.BuilderName))
            eng.BuilderManagerData.EngineerManager:RemoveUnit(eng)
            --LOG('* TransferAIUveso: AddUnit units to - BuilderManagers: '..self.PlatoonData.MoveToLocationType..' - ' .. aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType].EngineerManager:GetNumCategoryUnits('Engineers', categories.ALLUNITS) )
            aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType].EngineerManager:AddUnit(eng, true)
            -- Move the unit to the desired base after transfering BuilderManagers to the new LocationType
            local basePosition = aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType].Position
            --LOG('* TransferAIUveso: Moving transfer-units to - ' .. self.PlatoonData.MoveToLocationType)
            self:ForceReturnToNearestBaseAIUveso()
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
        UUtils.ReclaimAIThread(eng,aiBrain)
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
            elseif GetGameTimeSeconds() > 20 * 60 then
                ratio = 0.6
            elseif GetGameTimeSeconds() > 15 * 60 then
                ratio = 0.5
            elseif GetGameTimeSeconds() > 10 * 60 then
                ratio = 0.4
            elseif GetGameTimeSeconds() > 6 * 60 then -- run the first 6 minutes with 30% Eco and 70% Army
                ratio = 0.3
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
    
    SimpleReturnToMainBase = function(self, basePosition)
        local aiBrain = self:GetBrain()
        --local basePosition = aiBrain.BuilderManagers['MAIN'].Position
        local PlatoonPos = self:GetPlatoonPosition()
        if VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0) > 40 then
            self:MoveToLocation(basePosition, false)
        end
        self:PlatoonDisbandNoAssign()
    end,

    ForceReturnToNearestBaseAIUveso = function(self)
        local platPos = self:GetPlatoonPosition() or false
        if not platPos then
            return
        end

        local aiBrain = self:GetBrain()
        local nearestbase = false
        for k,v in aiBrain.BuilderManagers do
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
                    if dist < 25 then
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
                local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(self, LastTargetPos)
                if success then
                    --LOG('* ForceReturnToNavalBaseAIUveso: found a way with CanPathTo(). moving to destination')
                    self:MoveToLocation(LastTargetPos, false)
                else
                    --LOG('* ForceReturnToNavalBaseAIUveso: CanPathTo() failed for '..repr(LastTargetPos)..'.')
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
                self:PlatoonDisband()
                break
            end
            -- if we haven't moved in 5 seconds... leave the loop
            if oldDist - dist < 0 then
                break
            end
            oldDist = dist
            WaitSeconds(5)
        end
    end,


    NukePlatoonAI = function(self)
        local aiBrain = self:GetBrain()
        local mapSizeX, mapSizeZ = GetMapSize()
        local platoonUnits = {}
        local PlatoonUnitCount = 0
        local AlphaStrike = false
        local NukeReady = 0
        local NukeBussy = {}
        local NearTarget = 0
        local Protected = 0
        local EnemyUnits = {}
        local EnemyAntiMissile = {}
        local NukeTarget = {}
        local LauncherPos = {}
        local TargetsInNukeRange = {}
        local AttackedEnemyPositions = {}
        local NukeSiloAmmoCount = 0
        local MissileCount = 0
        while aiBrain:PlatoonExists(self) do
            --LOG('* NukePlatoonAI: while PlatoonExists')
            platoonUnits = self:GetPlatoonUnits()
            PlatoonUnitCount = table.getn(platoonUnits) or 0
            -- If we launch a nuke with all nukelaunchers then we have an AlphaStrike
            AlphaStrike = true
            NukeReady = 0
            MissileCount = 0
            for _, Launcher in platoonUnits do
                -- Set the unit to automode
                Launcher:SetAutoMode(true)
                -- check if we have a nuke silo without a loaded nuke
                --LOG('* NukePlatoonAI: Checking launcher for loaded nukes')
                NukeSiloAmmoCount = Launcher:GetNukeSiloAmmoCount() or 0
                MissileCount = MissileCount + NukeSiloAmmoCount
                if NukeSiloAmmoCount <= 0 then
                    --LOG('* NukePlatoonAI: No nuke found!')
                    -- bad, at least one launcher has no nuke, so we can't do an AlphaStrike
                    AlphaStrike = false
                end
                -- check if we have a launcher wit a nuke
                if NukeSiloAmmoCount >= 1 then
                    NukeReady = NukeReady + 1
                end
            end
            if AlphaStrike then
                LOG('* NukePlatoonAI: AlphaStrike')
            end
            AttackedEnemyPositions = {}
            -- We have a nuke in every Nuke Launcher. AlphaStrike!
            EnemyAntiMissile = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
            if NukeReady and AlphaStrike then
                -- Get all enemy units on MAP
                EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * categories.EXPERIMENTAL + categories.STRUCTURE * categories.TECH3 - categories.MASSEXTRACTION , Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                NearTarget = 0
                Protected = 0
                -- Check 
                for _, EnemyTarget in EnemyUnits do
                    -- get position of the possible next target
                    local EnemyTargetPos = EnemyTarget:GetPosition() or {0,0,0}
                    --LOG('* NukePlatoonAI: EnemyTargetPos '..repr(EnemyTargetPos))
                    local ToClose = false
                    -- loop over all already attacked targets
                    for _, AttackedPosition in AttackedEnemyPositions do
                        --LOG('* NukePlatoonAI: check AttackedPosition '..repr(AttackedPosition))
                        -- Check if the target is closeer then 40 to an already attacked target
                        if VDist2(EnemyTargetPos[1],EnemyTargetPos[3],AttackedPosition[1],AttackedPosition[3]) < 40 then
                            --LOG('* NukePlatoonAI: Target to close to other target. Skiped')
                            ToClose = true
                            NearTarget = NearTarget + 1
                            break -- break out of the AttackedEnemyPositions loop
                        end
                    end
                    if ToClose then
                        continue -- Skip this enemytarget and check the next
                    end
                    -- loop over all Enemy anti nuke launchers.
                    for _, AntiMissile in EnemyAntiMissile do
                        -- get the location of AntiMissile
                        local AntiMissilePos = AntiMissile:GetPosition() or {0,0,0}
                        -- Check if our target is inside range of an antimissile
                        if VDist2(EnemyTargetPos[1],EnemyTargetPos[3],AntiMissilePos[1],AntiMissilePos[3]) < 90 then
                            --LOG('* NukePlatoonAI: Target in range of Nuke Anti Missile. Skiped')
                            ToClose = true
                            Protected = Protected + 1
                            break -- break out of the AttackedEnemyPositions loop
                        end
                    end
                    if ToClose then
                        continue -- Skip this enemytarget and check the next
                    end
                    table.insert(AttackedEnemyPositions, EnemyTargetPos)
                end
                -- loop over target table as long as we have targets
                NukeBussy = {}
                while table.getn(AttackedEnemyPositions) > 0 do
                    LOG('* NukePlatoonAI: table.getn(AttackedEnemyPositions) '..table.getn(AttackedEnemyPositions))
                    -- get a target and remove it from the target list
                    local ActualTargetPos = table.remove(AttackedEnemyPositions)
                    --LOG('* NukePlatoonAI: ActualTargetPos '..repr(ActualTargetPos))
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
                            --LOG('* NukePlatoonAI: GetNukeSiloAmmoCount() <= 0. Skiped')
                            -- we don't have a missile, skip this launcher
                            continue
                        end
                        -- check if the target is closer then 20000
                        LauncherPos = Launcher:GetPosition() or {0,0,0}
                        if VDist2(LauncherPos[1],LauncherPos[3],ActualTargetPos[1],ActualTargetPos[3]) > 20000 then
                            --LOG('* NukePlatoonAI: Target out of range. Skiped')
                            -- Target is out of range, skip this launcher
                            continue
                        end
                        -- Attack the target
                        --LOG('* NukePlatoonAI: AATTAAACCCKKK!!!!')
                        IssueNuke({Launcher}, ActualTargetPos)
                        NukeBussy[Launcher] = true
                        NukeReady = NukeReady - 1
                        break -- stop seraching for available launchers and check the next target
                    end
                    if table.getn(NukeBussy) >= PlatoonUnitCount then
                        LOG('* NukePlatoonAI: All Launchers are bussy! Break!')
                        break  -- stop seraching for targets, we don't hava a launcher ready.
                    end
                    WaitTicks(10)
                end
            end
            local count = 'PlatoonUnitCount: '..PlatoonUnitCount
            local bussy = 'NukeBussy: '..PlatoonUnitCount - NukeReady
            local ready = 'NukeReady: '..NukeReady
            local missiles = 'Missiles: '..MissileCount
            local enemy = table.getn(EnemyUnits) or 0
            local target= 'EnemyCount: '..enemy..' - NearTarget: '..NearTarget..' - Protected: '..Protected
            local all   = 'TargetCount: '..(enemy - NearTarget - Protected)
            --LOG(count..' - '..bussy..' - '..ready..' - '..target..' - '..all )
            local AntiMissileRanger = {}
            --LOG('* NukePlatoonAI: MissileCount > table.getn(EnemyAntiMissile) * 8 ('..MissileCount..'>'..(table.getn(EnemyAntiMissile) * 8)..')')
            if MissileCount > table.getn(EnemyAntiMissile) * 8 then
                -- search for the less protected anti missile
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
                -- get the Index for the least protected Antimisile
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
                    LOG('* NukePlatoonAI: Antimissile with highest dinstance to other antimisiiles has HighIndex= '..HighIndex)
                    -- kill the launcher will all missiles we have
                    EnemyTarget = EnemyAntiMissile[HighIndex]
                    TargetPosition = EnemyTarget:GetPosition() or false
                elseif EnemyAntiMissile[1] and not EnemyAntiMissile[1].Dead then
                    LOG('* NukePlatoonAI: Targetting Antimissile[1]')
                    EnemyTarget = EnemyAntiMissile[1]
                    TargetPosition = EnemyTarget:GetPosition() or false
                else
                    LOG('* NukePlatoonAI: No Antimissile found. Waiting for Alpha Strike')
--                    EnemyTarget = import('/lua/ai/aibehaviors.lua').GetHighestThreatClusterLocation(aiBrain, platoonUnits[1])
                end
                -- wait until the target is dead or all launchers empty
                while TargetPosition do
                    --LOG('* NukePlatoonAI: Armageddon Loop!')
                    local missile = false
                    for Index, Launcher in platoonUnits do
                        --LOG('* NukePlatoonAI: Armageddon Fireing Nuke: '..repr(Index))
                        if Launcher:GetNukeSiloAmmoCount() > 0 then
                            if Launcher:GetNukeSiloAmmoCount() > 1 then
                                missile = true
                            end
                            IssueNuke({Launcher}, TargetPosition)
                            WaitTicks(30)
                        end
                    end
                    --LOG('* NukePlatoonAI: Armageddon Loop! Nukes Fired')
                    if not missile then
                        LOG('* NukePlatoonAI: Armageddon - Nukes are empty')
                        break -- break the "while true do" loop
                    end
                    if not EnemyTarget or EnemyTarget.Dead then
                        LOG('* NukePlatoonAI: Armageddon - Target is dead')
                        break -- break the "while true do" loop
                    end
                    --LOG('* NukePlatoonAI: Armageddon Loop! Waiting 3 sec')
                    WaitTicks(30)
                end
            end
            WaitTicks(100)
            -- The launcher will fire after "IssueNuke({Launcher}, EnemyTarget)" until he is empty.
            -- But we only want a single launch, so we stop all launchers here.
            IssueClearCommands(platoonUnits)
            -- find dead units inside the platoon and disband if we find one
            for k,Launcher in platoonUnits do
                if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                    -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                    self:PlatoonDisbandNoAssign()
                    LOG('* NukePlatoonAI: PlatoonDisbandNoAssign')
                    return
                end
            end
        end
    end,

    AntiNukePlatoonAI = function(self)
        local aiBrain = self:GetBrain()
        while aiBrain:PlatoonExists(self) do
            LOG('* AntiNukePlatoonAI: PlatoonExists')
            local platoonUnits = self:GetPlatoonUnits()
            for _, unit in platoonUnits do
                unit:SetAutoMode(true)
            end
            WaitSeconds(10)
            -- find dead units inside the platoon and disband if we find one
            for k,unit in platoonUnits do
                if not unit or unit.Dead or unit:BeenDestroyed() then
                    -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                    self:PlatoonDisbandNoAssign()
                    LOG('* AntiNukePlatoonAI: PlatoonDisbandNoAssign')
                    return
                end
            end
        end
    end,

}
