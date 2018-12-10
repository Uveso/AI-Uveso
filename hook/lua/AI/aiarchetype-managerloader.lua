
-- This hook is for debug-option Platoon-Names. Hook for all AI's
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
        elseif not aiBrain.Uveso then
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
            if aiBrain[ScenarioInfo.Options.AIPLatoonNameDebug] or ScenarioInfo.Options.AIPLatoonNameDebug == 'all' then
                ForkThread(LocationRangeManagerThread, aiBrain)
            end
        elseif aiBrain.Uveso then
            ForkThread(LocationRangeManagerThread, aiBrain)
            ForkThread(EcoManager, aiBrain)
            ForkThread(BaseAlertManager, aiBrain)
        -- Debug for Platoon names
        elseif aiBrain[ScenarioInfo.Options.AIPLatoonNameDebug] or ScenarioInfo.Options.AIPLatoonNameDebug == 'all' then
            ForkThread(LocationRangeManagerThread, aiBrain)
            ForkThread(UnitCapWatchThread, aiBrain)
        else
            ForkThread(UnitCapWatchThread, aiBrain)
        end
    end
    if aiBrain.PBM then
        aiBrain:PBMSetEnabled(false)
    end
end

-- Uveso AI
function EcoManager(aiBrain)
    local Engineers = {}
    local paragons = {}
    local ParaCount = 0
    local ParaComplete = 0
    while true do
        Engineers = aiBrain:GetListOfUnits(categories.ENGINEER - categories.COMMAND - categories.SUBCOMMANDER, false) -- also gets unbuilded units (planed to build)
        MassFabrikators = aiBrain:GetListOfUnits(categories.STRUCTURE * categories.MASSFABRICATION, false) -- also gets unbuilded units (planed to build)
        AntiNuke = aiBrain:GetListOfUnits(categories.STRUCTURE * categories.ANTIMISSILE * categories.SILO * categories.TECH3, false) -- also gets unbuilded units (planed to build)
        paragons = aiBrain:GetListOfUnits(categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC  * categories.ENERGYPRODUCTION  * categories.MASSPRODUCTION, false)
        ParaCount = 0
        ParaComplete = 0
        for unitNum, unit in paragons do
            if unit:GetFractionComplete() >= 1 then
                ParaComplete = ParaComplete + 1
            end
            ParaCount = ParaCount + 1
        end
        if ParaComplete >= 1 then
            aiBrain.HasParagon = true
        else
            aiBrain.HasParagon = false
        end
        -- loop over MassFabrikators and manage pause / unpause
        for _, unit in MassFabrikators do
            -- if the unit is dead, continue with the next unit
            if unit.Dead then continue end
            -- only manage finished buildings
            if unit:GetFractionComplete() >= 1 then
                if aiBrain:GetEconomyTrend('ENERGY') < 0.0 and aiBrain:GetEconomyStoredRatio('ENERGY') < 0.99 then
                    if not unit:IsPaused() then
                        unit:SetPaused( true )
                        break
                    end
                elseif aiBrain:GetEconomyTrend('ENERGY') > 150.0 and aiBrain:GetEconomyStoredRatio('ENERGY') > 0.99 then
                    if unit:IsPaused() then
                        unit:SetPaused( false )
                        break
                    end
                end
            end
        end
        -- loop over Antinukes and manage pause / unpause
        for _, unit in AntiNuke do
            -- if the unit is dead, continue with the next unit
            if unit.Dead then continue end
            -- only manage finished buildings
            if unit:GetFractionComplete() >= 1 then
                if aiBrain:GetEconomyTrend('ENERGY') < 0.0 and aiBrain:GetEconomyStoredRatio('ENERGY') < 0.50 then
                    if not unit:IsPaused() then
                        unit:SetPaused( true )
                        break
                    end
                elseif aiBrain:GetEconomyTrend('ENERGY') > 0.0 and aiBrain:GetEconomyStoredRatio('ENERGY') > 0.50 then
                    if unit:IsPaused() then
                        unit:SetPaused( false )
                        break
                    end
                end
            end
        end
        -- loop over engineers and manage pause / unpause
        for _, unit in Engineers do
            -- if the unit is dead, continue with the next unit
            if unit.Dead then continue end
            -- Only Check units that are assisting
            if not unit.PlatoonHandle.PlatoonData.Assist.AssisteeType then continue end
            -- Is the engineer idle ?
            if aiBrain.HasParagon then
                if unit:IsPaused() then
                    unit:SetPaused( false )
                    break
                end
            -- We have negative eco. Check if we can switch something off
            elseif aiBrain:GetEconomyTrend('MASS') < 0.0 or aiBrain:GetEconomyTrend('ENERGY') < 0.0 then
                -- if this unit is paused, continue with the next unit
                if unit:IsPaused() then continue end
                -- Very low eco, disable everything but energy assister
                if aiBrain:GetEconomyStoredRatio('MASS') < 0.05 or aiBrain:GetEconomyStoredRatio('ENERGY') < 0.60 then
                    -- If we assist a paragon or energy structure, only pause the unit
                    if unit.UnitBeingAssist then
                        if EntityCategoryContains(categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC, unit.UnitBeingAssist) then
                            unit:SetPaused( true )
                            break
                        elseif EntityCategoryContains(categories.STRUCTURE * categories.ENERGYPRODUCTION, unit.UnitBeingAssist) then
                            unit:SetPaused( true )
                            break
                        end
                    end
                    -- if we don't assist a paragon, disband the platoon.
                    unit.PlatoonHandle:Stop()
                    unit.PlatoonHandle:PlatoonDisband()
                    break
                -- Low Eco, disable all engineers exept thosw who are assisting energy buildings
                elseif aiBrain:GetEconomyStoredRatio('MASS') < 0.30 or aiBrain:GetEconomyStoredRatio('ENERGY') < 0.80 then
                    if unit.UnitBeingAssist then
                        if EntityCategoryContains(categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC, unit.UnitBeingAssist) then
                            continue
                        elseif EntityCategoryContains(categories.STRUCTURE * categories.ENERGYPRODUCTION, unit.UnitBeingAssist) then
                            continue
                        end
                    end
                    unit:SetPaused( true )
                    break
                end
            -- We have positive eco. Check if we can switch something on
            elseif aiBrain:GetEconomyTrend('MASS') >= 0.0 and aiBrain:GetEconomyTrend('ENERGY') >= 0.0 then
                -- if this unit is paused, continue with the next unit
                if not unit:IsPaused() then continue end
                if aiBrain:GetEconomyStoredRatio('MASS') >= 0.30 and aiBrain:GetEconomyStoredRatio('ENERGY') >= 0.80 then
                    unit:SetPaused( false )
                    break
                elseif aiBrain:GetEconomyStoredRatio('MASS') >= 0.15 and aiBrain:GetEconomyStoredRatio('ENERGY') >= 0.15 then
                    if unit.UnitBeingAssist then
                        if EntityCategoryContains(categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.EXPERIMENTAL, unit.UnitBeingAssist) then
                            unit:SetPaused( false )
                            break
                        end
                    end
                elseif aiBrain:GetEconomyStoredRatio('MASS') >= 0.05 and aiBrain:GetEconomyStoredRatio('ENERGY') >= 0.05 then
                    -- If we assist energy structure unpause the unit
                    if unit.UnitBeingAssist then
                        if EntityCategoryContains(categories.STRUCTURE * categories.ENERGYPRODUCTION, unit.UnitBeingAssist) then
                            unit:SetPaused( false )
                            break
                        end
                    end
                end
            end
        end
        WaitTicks(5)
    end
end

function LocationRangeManagerThread(aiBrain)
    local unitcounterdelayer = 0
    local ArmyUnits = {}
    while true do
        -- loop over all location managers
        for baseLocation, managers in aiBrain.BuilderManagers do
            -- get all factories from this location
            local Factories = managers.FactoryManager.FactoryList
            -- loop over all factories
            for k,factory in Factories do
                -- is our factory not building or upgrading ?
                if factory and not factory.Dead and not factory:BeenDestroyed() and factory:IsUnitState('Building') == false and factory:IsUnitState('Upgrading') == false then
                    -- check if our factory is more then 30 seconds inactice
                    if factory.LastActive and GetGameTimeSeconds() - factory.LastActive > 30 then
                        SPEW('* Uveso-AI: LocationRangeManagerThread: Factory '..k..' at location ('..baseLocation..') is not working for '.. math.floor(GetGameTimeSeconds() - factory.LastActive) ..' seconds. Restarting factory... ')
                        -- fork a new build thread for our factory
                        managers.FactoryManager:ForkThread(managers.FactoryManager.DelayBuildOrder, factory, factory.BuilderManagerData.BuilderType, 1)
                    end
                end
            end
        end
        -- Check and set the location radius of our main base and expansions
        local BasePositions = BaseRanger(aiBrain)
        -- Check if we have units outside the range of any BaseManager
        -- Get all units from our ArmyPool. These are units without a special platoon or task. They have nothing to do.
        ArmyUnits = aiBrain:GetListOfUnits(categories.MOBILE - categories.MOBILESONAR, false) -- also gets unbuilded units (planed to build)
        -- Loop over every unit that has no platton and is idle
        local LoopDelay = 0
        for _, unit in ArmyUnits do
            if unit.Dead then
                continue
            end
            -- check if we have name debugging enabled (ScenarioInfo.Options.AIPLatoonNameDebug = Uveso or Sorian or Dilli)
            if (aiBrain[ScenarioInfo.Options.AIPLatoonNameDebug] or ScenarioInfo.Options.AIPLatoonNameDebug == 'all')  then
                if unit.PlatoonHandle then
                    local Plan = unit.PlatoonHandle.PlanName
                    local Builder = unit.PlatoonHandle.BuilderName
                    if Plan or Builder then
                        unit:SetCustomName(''..(Builder or 'Unknown')..' ('..(Plan or 'Unknown')..')')
                    else
                        unit:SetCustomName('+')
                    end
                else
                    unit:SetCustomName('-')
                end
            end
            local WeAreInRange = false
            local nearestbase
            if not unit.Dead
                and EntityCategoryContains(categories.MOBILE - categories.COMMAND - categories.ENGINEER, unit)
                and unit:GetFractionComplete() == 1
                and unit:IsIdleState()
                and not unit:IsMoving()
                and (not unit.PlatoonHandle or (not unit.PlatoonHandle.PlanName and not unit.PlatoonHandle.BuilderName))
            then
                local UnitPos = unit:GetPosition()
                local NeedNavalBase = EntityCategoryContains(categories.NAVAL, unit)
                -- loop over every location and check the distance between the unit and the location
                for location, base in BasePositions do
                    -- If we need a naval base then skip all non naval areas
                    if NeedNavalBase and base.Type ~= 'Naval Area' then
                        --LOG('Need naval; but got land base: '..base.Type)
                        continue
                    end
                    -- If we need a land base then skip all naval areas
                    if not NeedNavalBase and base.Type == 'Naval Area' then
                        --LOG('Need land; but got naval base: '..base.Type)
                        continue
                    end
                    local dist = VDist2( UnitPos[1], UnitPos[3], base.Pos[1], base.Pos[3] )
                    -- if we are in range of a base, continue. We don't need to move the unit. It's in range of a basemanager
                    if dist < base.Rad then
                        WeAreInRange = true
                        break
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
                        if aiBrain[ScenarioInfo.Options.AIPLatoonNameDebug] or ScenarioInfo.Options.AIPLatoonNameDebug == 'all' then
                            unit:SetCustomName('Outside LocationManager')
                        end
                        IssueClearCommands({unit})
                        IssueStop({unit})
                        IssueMove({unit}, nearestbase.Pos)
                    end
                end
            end
            -- delay the loop after every 50 units. looping over 1000 units will take 2 seconds
            LoopDelay = LoopDelay + 1
            if LoopDelay > 50 then
                LoopDelay = 0
                WaitTicks(1)
            end
        end
        if 1 == 2 then
        -- watching the unit Cap for AI balance.
            unitcounterdelayer = unitcounterdelayer + 1
            if unitcounterdelayer > 12 then
                unitcounterdelayer = 0
                local MaxCap = GetArmyUnitCap(aiBrain:GetArmyIndex())
                LOG('  ')
                LOG(' 05.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.MOBILE * categories.ENGINEER * categories.TECH1, true) ) )..' -  Engineers TECH1  - ' )
                LOG(' 05.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.MOBILE * categories.ENGINEER * categories.TECH2, true) ) )..' -  Engineers TECH2  - ' )
                LOG(' 05.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.MOBILE * categories.ENGINEER * categories.TECH3 - categories.SUBCOMMANDER, true) ) )..' -  Engineers TECH3  - ' )
                LOG(' 03.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.MOBILE * categories.SUBCOMMANDER, true) ) )..' -  SubCommander   - ' )
                LOG(' 45.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.MOBILE - categories.ENGINEER, true) ) )..' -  Mobile Attack Force  - ' )
                LOG(' 10.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE * categories.MASSEXTRACTION, true) ) )..' -  Extractors    - ' )
                LOG(' 12.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE * categories.DEFENSE, true) ) )..' -  Structures Defense   - ' )
                LOG(' 12.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY, true) ) )..' -  Structures all   - ' )
                LOG(' 02.4 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE * categories.FACTORY * categories.LAND, true) ) )..' -  Factory Land  - ' )
                LOG(' 02.4 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE * categories.FACTORY * categories.AIR, true) ) )..' -  Factory Air   - ' )
                LOG(' 02.4 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE * categories.FACTORY * categories.NAVAL, true) ) )..' -  Factory Sea   - ' )
                LOG('------|------')
                LOG('100.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE + categories.MOBILE, true) ) )..' -  Structure + Mobile   - ' )
            end
        end
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
                local V1Naval = string.find(k, 'Naval Area')
                -- This is the maximum base radius.
                local NewMax = 120
                -- Now check against every other baseLocation, and see if we need to reduce our base radius.
                for k2,v2 in aiBrain.BuilderManagers do
                    local V2Naval = string.find(k2, 'Naval Area')
                    -- Only check, if start and end marker are not the same.
                    if v ~= v2 and ((V1Naval and V2Naval) or (not V1Naval and not V2Naval)) then
                        local EndPos = v2.FactoryManager.Location
                        local EndRad = v2.FactoryManager.Radius
                        local dist = VDist2( StartPos[1], StartPos[3], EndPos[1], EndPos[3] )
                        -- This is true, then we compare MAIN base versus expansion location
                        if k == 'MAIN' then
                            -- Mainbase can use 66% of the distance to the next location (minimum 90). But only if we have enough space for the second base (>=30)
                            if NewMax > dist/3*2 and dist/3*2 > 90 and dist/3 >= 30 then
                                NewMax = dist/3*2
                                --LOG('Distance from mainbase['..k..']->['..k2..']='..dist..' Mainbase radius='..StartRad..' Set Radius to '..dist/3*2)
                            -- If we have not enough spacee for the second base, then use half the distance as location radius
                            elseif NewMax > dist/2 and dist/2 > 90 and dist/2 >= 30 then
                                NewMax = dist/2
                                --LOG('Distance to location['..k..']->['..k2..']='..dist..' location radius='..StartRad..' Set Radius to '..dist/2)
                            -- We have not enough space for the mainbase. Set it to 90. Wee need this radius for gathering plattons etc
                            else
                                NewMax = 90
                            end
                        -- This is true, then we compare expansion location versus MAIN base
                        elseif k2 == 'MAIN' then
                            -- Expansion can use 33% of the distance to the Mainbase.
                            if NewMax > dist - EndRad and dist - EndRad >= 30 then
                                NewMax = dist - EndRad
                                --LOG('Distance to mainbase['..k..']->['..k2..']='..dist..' Mainbase radius='..EndRad..' Set Radius to '..dist - EndRad) 
                            end
                        -- Use as base radius half the way to the next marker. Exclude compare between land and water locations
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
        if aiBrain.Uveso then
            Scenario.MasterChain._MASTERCHAIN_.BaseRanger = Scenario.MasterChain._MASTERCHAIN_.BaseRanger or {}
            Scenario.MasterChain._MASTERCHAIN_.BaseRanger[aiBrain:GetArmyIndex()] = BaseRanger
        end
    end
    return BaseRanger
end

function BaseAlertManager(aiBrain)
    local mapSizeX, mapSizeZ = GetMapSize()
    local BaseMilitaryZone = math.max( mapSizeX-50, mapSizeZ-50 ) / 2               -- Half the map
    BaseMilitaryZone = math.max( 250, BaseMilitaryZone )
    local GetEnemyUnitsInSphereOnRadar = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua').GetEnemyUnitsInSphereOnRadar
    local targets = {}
    local baseposition, radius
    local ClosestTarget
    local distance
    while true do
        ClosestTarget = nil
        distance = 1024
        WaitTicks(50)
        if not baseposition then
            if aiBrain:PBMHasPlatoonList() then
                for k,v in aiBrain.PBM.Locations do
                    if v.LocationType == 'MAIN' then
                        baseposition = v.Location
                        radius = v.Radius
                        break
                    end
                end
            elseif aiBrain.BuilderManagers['MAIN'] then
                baseposition = aiBrain.BuilderManagers['MAIN'].FactoryManager:GetLocationCoords()
                radius = aiBrain.BuilderManagers['MAIN'].FactoryManager:GetLocationRadius()
            end
            if not baseposition then
                continue
            end 
        end
        -- Search for experimentals in BasePanicZone
        targets = aiBrain:GetUnitsAroundPoint(categories.EXPERIMENTAL - categories.AIR, baseposition, 120, 'Enemy')
        for _, unit in targets do
            if not unit.Dead then
                if not IsEnemy( aiBrain:GetArmyIndex(), unit:GetAIBrain():GetArmyIndex() ) then continue end
                local TargetPosition = unit:GetPosition()
                local targetRange = VDist2(baseposition[1], baseposition[3], TargetPosition[1], TargetPosition[3])
                if targetRange < distance then
                    distance = targetRange
                    ClosestTarget = unit
                end
            end
        end
        WaitTicks(1)
        -- Search for experimentals in BaseMilitaryZone
        if not ClosestTarget then
            targets = aiBrain:GetUnitsAroundPoint(categories.EXPERIMENTAL - categories.AIR, baseposition, BaseMilitaryZone, 'Enemy')
            for _, unit in targets do
                if not unit.Dead then
                    if not IsEnemy( aiBrain:GetArmyIndex(), unit:GetAIBrain():GetArmyIndex() ) then continue end
                    local TargetPosition = unit:GetPosition()
                    local targetRange = VDist2(baseposition[1], baseposition[3], TargetPosition[1], TargetPosition[3])
                    if targetRange < distance then
                        distance = targetRange
                        ClosestTarget = unit
                    end
                end
            end
        end
        WaitTicks(1)
        -- Search for experimentals in EnemyZone
        if not ClosestTarget then
            targets = aiBrain:GetUnitsAroundPoint(categories.EXPERIMENTAL - categories.AIR, baseposition, 1024, 'Enemy')
            for _, unit in targets do
                if not unit.Dead then
                    if not IsEnemy( aiBrain:GetArmyIndex(), unit:GetAIBrain():GetArmyIndex() ) then continue end
                    local TargetPosition = unit:GetPosition()
                    local targetRange = VDist2(baseposition[1], baseposition[3], TargetPosition[1], TargetPosition[3])
                    if targetRange < distance then
                        distance = targetRange
                        ClosestTarget = unit
                    end
                end
            end
        end
        aiBrain.PrimaryTarget = ClosestTarget
    end
end
