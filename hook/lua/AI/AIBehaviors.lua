-- For AI Patch V8 (Patched) fixed issue with AI cdr not building at game start
function CommanderThread(cdr, platoon)
    SetCDRHome(cdr, platoon)

    local aiBrain = cdr:GetAIBrain()
    aiBrain:BuildScoutLocations()
    while not cdr.Dead do
        WaitTicks(1)
        -- Overcharge
        if not cdr.Dead then CDROverCharge(aiBrain, cdr) end
        WaitTicks(1)

        -- Go back to base
        if not cdr.Dead then CDRReturnHome(aiBrain, cdr) end
        WaitTicks(1)

        -- Call platoon resume building deal...
        if not cdr.Dead and cdr:IsIdleState() and not cdr.GoingHome and not cdr:IsUnitState("Building")
        and not cdr:IsUnitState("Attacking") and not cdr:IsUnitState("Repairing")
        and not cdr:IsUnitState("Upgrading") and not cdr:IsUnitState('BlockCommandQueue') then
            if not cdr.EngineerBuildQueue or table.getn(cdr.EngineerBuildQueue) == 0 then
                local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
                aiBrain:AssignUnitsToPlatoon(pool, {cdr}, 'Unassigned', 'None')
            elseif cdr.EngineerBuildQueue and table.getn(cdr.EngineerBuildQueue) ~= 0 then
                if not cdr.NotBuildingThread then
                    cdr.NotBuildingThread = cdr:ForkThread(platoon.WatchForNotBuilding)
                end
            end
        end
    end
end
-- For AI Patch V8 (Patched) fixed issue with AI cdr not building at game start
function CommanderThreadImproved(cdr, platoon)
    local aiBrain = cdr:GetAIBrain()
    aiBrain:BuildScoutLocations()
    -- Added to ensure we know the start locations (thanks to Sorian).
    SetCDRHome(cdr, platoon)

    while not cdr.Dead do
        -- Overcharge
        if not cdr.Dead then CDROverCharge(aiBrain, cdr) end
        WaitTicks(1)

        -- Go back to base
        if not cdr.Dead then CDRReturnHome(aiBrain, cdr) end
        WaitTicks(1)

        -- Call platoon resume building deal...
        if not cdr.Dead and cdr:IsIdleState() and not cdr.GoingHome and not cdr:IsUnitState("Moving")
        and not cdr:IsUnitState("Building") and not cdr:IsUnitState("Guarding")
        and not cdr:IsUnitState("Attacking") and not cdr:IsUnitState("Repairing")
        and not cdr:IsUnitState("Upgrading") and not cdr:IsUnitState("Enhancing")
        and not cdr:IsUnitState('BlockCommandQueue') then
            -- if we have nothing to build...
            if not cdr.EngineerBuildQueue or table.getn(cdr.EngineerBuildQueue) == 0 then
                -- check if the we have still a platton assigned to the CDR
                if cdr.PlatoonHandle then
                    local platoonUnits = cdr.PlatoonHandle:GetPlatoonUnits() or 1
                    -- only disband the platton if we have 1 unit, plan and buildername. (NEVER disband the armypool platoon!!!)
                    if table.getn(platoonUnits) == 1 and cdr.PlatoonHandle.PlanName and cdr.PlatoonHandle.BuilderName then
                        --SPEW('ACU PlatoonHandle found. Plan: '..cdr.PlatoonHandle.PlanName..' - Builder '..cdr.PlatoonHandle.BuilderName..'. Disbanding CDR platoon!')
                        cdr.PlatoonHandle:PlatoonDisband()
                    end
                end
                -- get the global armypool platoon
                local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
                -- assing the CDR to the armypool
                aiBrain:AssignUnitsToPlatoon(pool, {cdr}, 'Unassigned', 'None')
            -- if we have a BuildQueue then continue building
            elseif cdr.EngineerBuildQueue and table.getn(cdr.EngineerBuildQueue) ~= 0 then
                if not cdr.NotBuildingThread then
                    cdr.NotBuildingThread = cdr:ForkThread(platoon.WatchForNotBuilding)
                end
            end
        end
        WaitTicks(1)
    end
end
-- For AI Patch V8 (Patched) fixed issue with AI cdr not building at game start
function CommanderThreadSorian(cdr, platoon)
    if platoon.PlatoonData.aggroCDR then
        local mapSizeX, mapSizeZ = GetMapSize()
        local size = mapSizeX
        if mapSizeZ > mapSizeX then
            size = mapSizeZ
        end
        cdr.Mult = (size / 2) / 100
    end

    SetCDRHome(cdr, platoon)

    local aiBrain = cdr:GetAIBrain()
    aiBrain:BuildScoutLocationsSorian()
    if not SUtils.CheckForMapMarkers(aiBrain) then
        SUtils.AISendChat('all', ArmyBrains[aiBrain:GetArmyIndex()].Nickname, 'badmap')
    end

    moveOnNext = false
    moveWait = 0
    local Mult = cdr.Mult or 1
    local Delay = platoon.PlatoonData.Delay or 165
    local WaitTaunt = 600 + Random(1, 600)
    while not cdr.Dead do
        if Mult > 1 and (SBC.GreaterThanGameTime(aiBrain, 1200) or not SBC.EnemyToAllyRatioLessOrEqual(aiBrain, 1.0) or not SBC.ClosestEnemyLessThan(aiBrain, 750) or not SUtils.CheckForMapMarkers(aiBrain)) then
            Mult = 1
        end
        WaitTicks(1)

        -- Overcharge
        if Mult == 1 and not cdr.Dead and not cdr.Upgrading and SBC.GreaterThanGameTime(aiBrain, Delay) and
        UCBC.HaveGreaterThanUnitsWithCategory(aiBrain,  1, 'FACTORY') and aiBrain:GetNoRushTicks() <= 0 then
            CDROverChargeSorian(aiBrain, cdr)
        end
        WaitTicks(1)

        -- Run Away
        if not cdr.Dead then CDRRunAwaySorian(aiBrain, cdr) end
        WaitTicks(1)

        -- Go back to base
        if not cdr.Dead then CDRReturnHomeSorian(aiBrain, cdr, Mult) end
        WaitTicks(1)

        if not cdr.Dead and cdr:IsIdleState() and moveOnNext then
            CDRHideBehavior(aiBrain, cdr)
            moveOnNext = false
        end
        WaitTicks(1)

        if not cdr.Dead and cdr:IsIdleState() and not cdr.GoingHome and not cdr.Fighting and not cdr.Upgrading and not cdr:IsUnitState("Building")
        and not cdr:IsUnitState("Attacking") and not cdr:IsUnitState("Repairing") and not cdr.UnitBeingBuiltBehavior and not cdr:IsUnitState("Upgrading")
        and not cdr:IsUnitState("Enhancing") and not moveOnNext then
            moveWait = moveWait + 1
            if moveWait >= 10 then
                moveWait = 0
                moveOnNext = true
            end
        else
            moveWait = 0
        end
        WaitTicks(1)

        -- Call platoon resume building deal...
        if not cdr.Dead and cdr:IsIdleState() and not cdr.GoingHome and not cdr.Fighting and not cdr.Upgrading and not cdr:IsUnitState("Building")
        and not cdr:IsUnitState("Attacking") and not cdr:IsUnitState("Repairing") and not cdr.UnitBeingBuiltBehavior and not cdr:IsUnitState("Upgrading")
        and not cdr:IsUnitState("Enhancing") and not (SUtils.XZDistanceTwoVectorsSq(cdr.CDRHome, cdr:GetPosition()) > 100)
        and not cdr:IsUnitState('BlockCommandQueue') then
            if not cdr.EngineerBuildQueue or table.getn(cdr.EngineerBuildQueue) == 0 then
                local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
                aiBrain:AssignUnitsToPlatoon(pool, {cdr}, 'Unassigned', 'None')
            elseif cdr.EngineerBuildQueue and table.getn(cdr.EngineerBuildQueue) ~= 0 then
                if not cdr.NotBuildingThread then
                    cdr.NotBuildingThread = cdr:ForkThread(platoon.WatchForNotBuildingSorian)
                end
            end
        end
        WaitSeconds(1)

        if not cdr.Dead and GetGameTimeSeconds() > WaitTaunt and (not aiBrain.LastVocTaunt or GetGameTimeSeconds() - aiBrain.LastVocTaunt > WaitTaunt) then
            SUtils.AIRandomizeTaunt(aiBrain)
            WaitTaunt = 600 + Random(1, 900)
        end
    end
end
