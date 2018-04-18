
OLDExecutePlan = ExecutePlan
function ExecutePlan(aiBrain)
    aiBrain:SetConstantEvaluate(false)
    local behaviors = import('/lua/ai/AIBehaviors.lua')
    WaitSeconds(1)
    if not aiBrain.BuilderManagers.MAIN.FactoryManager:HasBuilderList() then
        aiBrain:SetResourceSharing(true)

        if aiBrain.Sorian then
            aiBrain:SetupUnderEnergyStatTriggerSorian(0.1)
            aiBrain:SetupUnderMassStatTriggerSorian(0.1)
        else
            aiBrain:SetupUnderEnergyStatTrigger(0.1)
            aiBrain:SetupUnderMassStatTrigger(0.1)
        end

        SetupMainBase(aiBrain)

        # Get units out of pool and assign them to the managers
        local mainManagers = aiBrain.BuilderManagers.MAIN

        local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
        for k,v in pool:GetPlatoonUnits() do
            if EntityCategoryContains(categories.ENGINEER, v) then
                mainManagers.EngineerManager:AddUnit(v)
            elseif EntityCategoryContains(categories.FACTORY * categories.STRUCTURE, v) then
                mainManagers.FactoryManager:AddFactory(v)
            end
        end

        if aiBrain.Sorian then
            ForkThread(UnitCapWatchThreadSorian, aiBrain)
            ForkThread(behaviors.NukeCheck, aiBrain)
            -- Debug for Platoon names
            if aiBrain[ScenarioInfo.Options.AIPLatoonNameDebug] then
                ForkThread(LocationRangeManagerThread, aiBrain)
            end
        elseif aiBrain.Uveso then
            ForkThread(LocationRangeManagerThread, aiBrain)
        -- Debug for Platoon names
        elseif aiBrain[ScenarioInfo.Options.AIPLatoonNameDebug] then
            ForkThread(LocationRangeManagerThread, aiBrain)
        else
            ForkThread(UnitCapWatchThread, aiBrain)
        end
    end
    if aiBrain.PBM then
        aiBrain:PBMSetEnabled(false)
    end
end

-- Check the distance between locations and set location radius half the distance.
function LocationRangeManagerThread(aiBrain)
    local unitcounterdelayer = 0
    while true do
        -- Check and set the location radius of our main base and expansions
        local BasePositions = BaseRanger(aiBrain)
        -- Check if we have units outside the range of any BaseManager
        -- Get all units from our ArmyPool. These are units without a special platoon or task. They have nothing to do.
        local ArmyUnits = aiBrain:GetListOfUnits(categories.ALLUNITS, false) -- also gets unbuilded units (planed to build)
        -- Loop over every unit that has no platton and is idle
        for _, unit in ArmyUnits do
            -- check if we have name debugging enabled (ScenarioInfo.Options.AIPLatoonNameDebug = Uveso or Sorian or Dilli)
            if aiBrain[ScenarioInfo.Options.AIPLatoonNameDebug] and not EntityCategoryContains(categories.STRUCTURE * categories.FACTORY, unit) then
                if unit.PlatoonHandle then
                    local Plan = unit.PlatoonHandle.PlanName
                    local Builder = unit.PlatoonHandle.BuilderName
                    if Plan or Builder then
                        unit:SetCustomName(''..(Builder or 'Unknown')..' ('..(Plan or 'Unknown')..')')
                    else
                        unit:SetCustomName('')
                    end
                else
                    unit:SetCustomName('')
                end
            end

            local WeAreInRange = false
            local nearestbase
            if not unit.Dead and EntityCategoryContains(categories.MOBILE - categories.COMMAND, unit) and unit:GetFractionComplete() == 1 and unit:IsIdleState() and not unit:IsMoving() and not unit.PlatoonHandle then
                local UnitPos = unit:GetPosition()
                local NeedNavalBase = EntityCategoryContains(categories.NAVAL, unit)
                -- loop over every location and check the distance between the unit and the location
                for location, base in BasePositions do
                    -- If we need a naval base then skip all non naval areas
                    if NeedNavalBase and base.Type ~= 'Naval Area' then
                        continue
                    end
                    -- If we need a land base then skip all naval areas
                    if not NeedNavalBase and base.Type == 'Naval Area' then
                        continue
                    end
                    local dist = VDist2( UnitPos[1], UnitPos[3], base.Pos[1], base.Pos[3] )
                    -- if we are in range of a base, continue. We don't need to move the unit. It's in range of a basemanager
                    if dist < base.Rad then
                        WeAreInRange = true
                        continue
                    end
                    -- remember the nearest base. We will move to it.
                    if not nearestbase or nearestbase.dist > dist then
                        nearestbase = {}
                        nearestbase.Pos = base.Pos
                        nearestbase.dist = dist
                    end
                end
                -- if we are not in range of an base, then move to a base.
                if WeAreInRange == false and not unit.Dead then
                    if nearestbase then
                        if unit.PlatoonHandle and aiBrain:PlatoonExists(unit.PlatoonHandle) then
                            LOG('* AIDEBUG: LocationRangeManagerThread: Found idle Unit outside Basemanager range! Removing platoonhandle: ('..(unit.PlatoonHandle.PlanName or 'Unknown')..')')
                            unit.PlatoonHandle:Stop()
                            unit.PlatoonHandle:PlatoonDisbandNoAssign()
                        end
                        --LOG('* AIDEBUG: LocationRangeManagerThread: Moving idle unit inside next basemanager range: '..unit:GetBlueprint().BlueprintId..'  ')
                        IssueClearCommands({unit})
                        IssueMove({unit}, nearestbase.Pos)
                    end
                end
            end
        end
        -- watching the unit Cap for AI balance.
--        unitcounterdelayer = unitcounterdelayer + 1
--        if unitcounterdelayer > 60 then
--            unitcounterdelayer = 0
--            local MaxCap = GetArmyUnitCap(aiBrain:GetArmyIndex())
--            LOG('  ')
--            LOG(' 00.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.MOBILE * categories.ENGINEER, true) ) )..' -  Engineers   - ' )
--            LOG(' 50.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.MOBILE - categories.ENGINEER, true) ) )..' -  Mobile Attack Force  - ' )
--            LOG(' 14.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE * categories.MASSEXTRACTION, true) ) )..' -  Extractors    - ' )
--            LOG(' 02.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE * categories.MASSSTORAGE, true) ) )..' -  MASSSTORAGE   - ' )
--            LOG(' 11.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE * categories.ENERGYPRODUCTION, true) ) )..' -  Structures ENERGYPRODUCTION   - ' )
--            LOG(' 20.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE * categories.DEFENSE, true) ) )..' -  Structures Defense   - ' )
--            LOG(' 00.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE - categories.MASSEXTRACTION - categories.ENERGYPRODUCTION - categories.DEFENSE - categories.FACTORY, true) ) )..' -  Structures all   - ' )
--            LOG(' 02.4 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE * categories.FACTORY * categories.LAND, true) ) )..' -  Factory Land  - ' )
--            LOG(' 02.4 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE * categories.FACTORY * categories.AIR, true) ) )..' -  Factory Air   - ' )
--            LOG(' 02.4 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE * categories.FACTORY * categories.NAVAL, true) ) )..' -  Factory Sea   - ' )
--        end
        WaitTicks(50)
    end
end

function BaseRanger(aiBrain)
    local BaseRanger = {}
    if aiBrain.BuilderManagers then
        local BaseLocations = {
            [1] = 'MAIN',
            [2] = 'Naval Area',
            [3] = 'Blank Marker',
            [4] = 'Large Expansion Area',
            [5] = 'Expansion Area',
        }
        -- Check BaseLocations
        for Index, BaseType in BaseLocations do
            -- loop over BuilderManagers and check every location
            for k,v in aiBrain.BuilderManagers do
                -- Check baselocations sorted by BaseLocations Index
                if k ~= BaseType and Scenario.MasterChain._MASTERCHAIN_.Markers[v.FactoryManager.LocationType].type ~= BaseType then
                    -- No BaseLocation. Continue with the next array-key 
                    continue
                end
                -- We found a BaseLocation
                local StartPos = v.FactoryManager.Location
                local StartRad = v.FactoryManager.Radius
                -- This is the maximum base radius.
                local NewMax = 120
                -- Now check against every other baseLocation, and see if we need to reduce our base radius.
                for k2,v2 in aiBrain.BuilderManagers do
                    -- Only check, if start and end marker are not the same.
                    if v ~= v2 then
                        local EndPos = v2.FactoryManager.Location
                        local EndRad = v2.FactoryManager.Radius
                        local dist = VDist2( StartPos[1], StartPos[3], EndPos[1], EndPos[3] )
                        -- This is true, then we compare MAIN base versus expansion location
                        if k == 'MAIN' then
                            -- Mainbase can use 66% of the distance to the next location. But only if we have enough space for the second base (>=30)
                            if NewMax > dist/3*2 and dist/3 >= 30 then
                                NewMax = dist/3*2
                                --LOG('Distance from mainbase['..k..']->['..k2..']='..dist..' Mainbase radius='..StartRad..' Set Radius to '..dist/3*2)
                            -- If we have not enough spacee for the second base, then use half the distance as location radius
                            elseif NewMax > dist/2 and dist/2 >= 30 then
                                NewMax = dist/2
                                --LOG('Distance to location['..k..']->['..k2..']='..dist..' location radius='..StartRad..' Set Radius to '..dist/2)
                            end
                        -- This is true, then we compare expansion location versus MAIN base
                        elseif k2 == 'MAIN' then
                            -- Expansion can use 33% of the distance to the Mainbase.
                            if NewMax > dist - EndRad and dist - EndRad >= 30 then
                                NewMax = dist - EndRad
                                --LOG('Distance to mainbase['..k..']->['..k2..']='..dist..' Mainbase radius='..EndRad..' Set Radius to '..dist - EndRad) 
                            end
                        -- Use as base radius half the way to the next marker
                        else
                            -- if we dont compare against the mainbase then use 50% of the distance to the next location
                            if NewMax > dist/2 and dist/2 >= 30 then
                                NewMax = dist/2
                                --LOG('Distance to location['..k..']->['..k2..']='..dist..' location radius='..StartRad..' Set Radius to '..dist/2) 
                            end
                        end
                    end
                end
                -- Now check for existing managers and set the new value to it
                if v.FactoryManager then
                    v.FactoryManager.Radius = NewMax
                end
                if v.EngineerManager then
                    v.EngineerManager.Radius = NewMax
                end
                if v.PlatoonFormManager then
                    v.PlatoonFormManager.Radius = NewMax
                end
                if v.StrategyManager then
                    v.StrategyManager.Radius = NewMax
                end
                -- Check if we have a terranhigh (or we can't draw the debug baseRanger)
                if StartPos[2] == 0 then
                    StartPos[2] = GetTerrainHeight(StartPos[1], StartPos[3])
                    -- store the TerranHeight inside Factorymanager
                    v.FactoryManager.Location = StartPos
                end
                BaseRanger[k] = {Pos = StartPos, Rad = math.floor(NewMax), Type = BaseType}
            end
        end
        Scenario.MasterChain._MASTERCHAIN_.BaseRanger = Scenario.MasterChain._MASTERCHAIN_.BaseRanger or {}
        Scenario.MasterChain._MASTERCHAIN_.BaseRanger[aiBrain:GetArmyIndex()] = BaseRanger
    end
    return BaseRanger
end
