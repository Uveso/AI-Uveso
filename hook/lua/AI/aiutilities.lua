

-- Hook For AI-Uveso. Enhancment for BuildOnMassAI
UvesoEngineerMoveWithSafePath = EngineerMoveWithSafePath
function EngineerMoveWithSafePath(aiBrain, unit, destination)
    -- Only use this with AI-Uveso
    if not aiBrain.Uveso then
        return UvesoEngineerMoveWithSafePath(aiBrain, unit, destination)
    end
    if not destination then
        return false
    end
    local pos = unit:GetPosition()
    -- don't check a path if we are in build range
    if VDist2(pos[1], pos[3], destination[1], destination[3]) < 14 then
        return true
    end

    -- first try to find a path with markers. 
    local result, bestPos
    local path, reason = AIAttackUtils.EngineerGenerateSafePathTo(aiBrain, 'Amphibious', pos, destination)
    -- only use CanPathTo for distance closer then 200 and if we can't path with markers
    if reason ~= 'PathOK' then
        -- we will crash the game if we use CanPathTo() on all engineer movments on a map without markers. So we don't path at all.
        if reason == 'NoGraph' then
            result = true
        elseif VDist2(pos[1], pos[3], destination[1], destination[3]) < 200 then
            SPEW('* AI-Uveso: EngineerMoveWithSafePath(): executing CanPathTo(). LUA GenerateSafePathTo returned: ('..repr(reason)..') '..VDist2(pos[1], pos[3], destination[1], destination[3]))
            -- be really sure we don't try a pathing with a destoryed c-object
            if unit.Dead or unit:BeenDestroyed() or IsDestroyed(unit) then
                SPEW('* AI-Uveso: Unit is death before calling CanPathTo()')
                return false
            end
            result, bestPos = unit:CanPathTo(destination)
        end 
    end
    local bUsedTransports = false
    -- Increase check to 300 for transports
    if (not result and reason ~= 'PathOK') or VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 200 * 200
    and unit.PlatoonHandle and not EntityCategoryContains(categories.COMMAND, unit) then
        -- If we can't path to our destination, we need, rather than want, transports
        local needTransports = not result and reason ~= 'PathOK'
        if VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 200 * 200 then
            needTransports = true
        end

        -- Skip the last move... we want to return and do a build
        bUsedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, unit.PlatoonHandle, destination, needTransports, true, false)

        if bUsedTransports then
            return true
        elseif VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 512 * 512 then
            -- If over 512 and no transports dont try and walk!
            return false
        end
    end

    -- If we're here, we haven't used transports and we can path to the destination
    if result or reason == 'PathOK' then
        --LOG('* AI-Uveso: EngineerMoveWithSafePath(): result or reason == PathOK ')
        if reason ~= 'PathOK' then
            path, reason = AIAttackUtils.EngineerGenerateSafePathTo(aiBrain, 'Amphibious', pos, destination)
        end
        if path then
            --LOG('* AI-Uveso: EngineerMoveWithSafePath(): path 0 true')
            local pathSize = table.getn(path)
            -- Move to way points (but not to destination... leave that for the final command)
            for widx, waypointPath in path do
                if pathSize ~= widx then
                    IssueMove({unit}, waypointPath)
                end
            end
        end
        -- If there wasn't a *safe* path (but dest was pathable), then the last move would have been to go there directly
        -- so don't bother... the build/capture/reclaim command will take care of that after we return
        return true
    end
    return false
end

-- For AI Patch V8. Faster transport drop off
function UseTransports(units, transports, location, transportPlatoon)
    local aiBrain
    for k, v in units do
        if not v.Dead then
            aiBrain = v:GetAIBrain()
            break
        end
    end

    if not aiBrain then
        return false
    end

    -- Load transports
    local transportTable = {}
    local transSlotTable = {}
    if not transports then
        return false
    end

    for num, unit in transports do
        local id = unit:GetUnitId()
        if not transSlotTable[id] then
            transSlotTable[id] = GetNumTransportSlots(unit)
        end
        table.insert(transportTable,
            {
                Transport = unit,
                LargeSlots = transSlotTable[id].Large,
                MediumSlots = transSlotTable[id].Medium,
                SmallSlots = transSlotTable[id].Small,
                Units = {}
            }
        )
    end

    local shields = {}
    local remainingSize3 = {}
    local remainingSize2 = {}
    local remainingSize1 = {}
    local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
    for num, unit in units do
        if not unit.Dead then
            if unit:IsUnitState('Attached') then
                aiBrain:AssignUnitsToPlatoon(pool, {unit}, 'Unassigned', 'None')
            elseif EntityCategoryContains(categories.url0306 + categories.DEFENSE, unit) then
                table.insert(shields, unit)
            elseif unit:GetBlueprint().Transport.TransportClass == 3 then
                table.insert(remainingSize3, unit)
            elseif unit:GetBlueprint().Transport.TransportClass == 2 then
                table.insert(remainingSize2, unit)
            elseif unit:GetBlueprint().Transport.TransportClass == 1 then
                table.insert(remainingSize1, unit)
            else
                table.insert(remainingSize1, unit)
            end
        end
    end

    local needed = GetNumTransports(units)
    local largeHave = 0
    for num, data in transportTable do
        largeHave = largeHave + data.LargeSlots
    end

    local leftoverUnits = {}
    local currLeftovers = {}
    local leftoverShields = {}
    transportTable, leftoverShields = SortUnitsOnTransports(transportTable, shields, largeHave - needed.Large)

    transportTable, leftoverUnits = SortUnitsOnTransports(transportTable, remainingSize3, -1)

    transportTable, currLeftovers = SortUnitsOnTransports(transportTable, leftoverShields, -1)

    for _, v in currLeftovers do table.insert(leftoverUnits, v) end
    transportTable, currLeftovers = SortUnitsOnTransports(transportTable, remainingSize2, -1)

    for _, v in currLeftovers do table.insert(leftoverUnits, v) end
    transportTable, currLeftovers = SortUnitsOnTransports(transportTable, remainingSize1, -1)

    for _, v in currLeftovers do table.insert(leftoverUnits, v) end
    transportTable, currLeftovers = SortUnitsOnTransports(transportTable, currLeftovers, -1)

    aiBrain:AssignUnitsToPlatoon(pool, currLeftovers, 'Unassigned', 'None')
    if transportPlatoon then
        transportPlatoon.UsingTransport = true
    end

    local monitorUnits = {}
    for num, data in transportTable do
        if table.getn(data.Units) > 0 then
            IssueClearCommands(data.Units)
            IssueTransportLoad(data.Units, data.Transport)
            for k, v in data.Units do table.insert(monitorUnits, v) end
        end
    end

    local attached = true
    repeat
        coroutine.yield(20)
        local allDead = true
        local transDead = true
        for k, v in units do
            if not v.Dead then
                allDead = false
                break
            end
        end
        for k, v in transports do
            if not v.Dead then
                transDead = false
                break
            end
        end
        if allDead or transDead then return false end
        attached = true
        for k, v in monitorUnits do
            if not v.Dead and not v:IsIdleState() then
                attached = false
                break
            end
        end
    until attached

    -- Any units that aren't transports and aren't attached send back to pool
    for k, unit in units do
        if not unit.Dead and not EntityCategoryContains(categories.TRANSPORTATION, unit) then
            if not unit:IsUnitState('Attached') then
                aiBrain:AssignUnitsToPlatoon(pool, {unit}, 'Unassigned', 'None')
            end
        elseif not unit.Dead and EntityCategoryContains(categories.TRANSPORTATION, unit) and table.getn(unit:GetCargo()) < 1 then
            ReturnTransportsToPool({unit}, true)
            table.remove(transports, k)
        end
    end

    -- If some transports have no units return to pool
    for k, t in transports do
        if not t.Dead and table.getn(t:GetCargo()) < 1 then
            aiBrain:AssignUnitsToPlatoon('ArmyPool', {t}, 'Scout', 'None')
            table.remove(transports, k)
        end
    end

    if table.getn(transports) ~= 0 then
        -- If no location then we have loaded transports then return true
        if location then
            -- Adding Surface Height, so the transporter get not confused, because the target is under the map (reduces unload time)
            location = {location[1], GetSurfaceHeight(location[1],location[3]), location[3]}
            local safePath = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Air', transports[1]:GetPosition(), location, 200)
            if safePath then
                local LastPos
                for _, p in safePath do
                    IssueMove(transports, p)
                    LastPos = p
                end
                IssueMove(transports, location)
                IssueTransportUnload(transports, location)
            else
                IssueMove(transports, location)
                IssueTransportUnload(transports, location)
            end
        else
            return true
        end
    else
        -- If no transports return false
        return false
    end

    local attached = true
    while attached do
        coroutine.yield(20)
        local allDead = true
        for _, v in transports do
            if not v.Dead then
                allDead = false
                break
            end
        end

        if allDead then
            return false
        end

        attached = false
        for num, unit in units do
            if not unit.Dead and unit:IsUnitState('Attached') then
                attached = true
                break
            end
        end
    end

    if transportPlatoon then
        transportPlatoon.UsingTransport = false
    end
    ReturnTransportsToPool(transports, true)

    return true
end

-- For AI Patch V8. fixed return value in case there is reclaim
function EngineerTryReclaimCaptureArea(aiBrain, eng, pos)
    if not pos then
        return false
    end
    local Reclaiming = false
    -- Check if enemy units are at location
    local checkUnits = aiBrain:GetUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) - categories.AIR, pos, 10, 'Enemy')
    -- reclaim units near our building place.
    if checkUnits and table.getn(checkUnits) > 0 then
        for num, unit in checkUnits do
            if unit.Dead or unit:BeenDestroyed() then
                continue
            end
            if not IsEnemy( aiBrain:GetArmyIndex(), unit:GetAIBrain():GetArmyIndex() ) then
                continue
            end
            if unit:IsCapturable() then 
                -- if we can capture the unit/building then do so
                unit.CaptureInProgress = true
                IssueCapture({eng}, unit)
                Reclaiming = true
            else
                -- if we can't capture then reclaim
                unit.ReclaimInProgress = true
                IssueReclaim({eng}, unit)
                Reclaiming = true
            end
        end
    end
    -- reclaim rocks etc or we can't build mexes or hydros
    local Reclaimables = GetReclaimablesInRect(Rect(pos[1], pos[3], pos[1], pos[3]))
    if Reclaimables and table.getn( Reclaimables ) > 0 then
        for k,v in Reclaimables do
            if v.MaxMassReclaim and v.MaxMassReclaim > 0 or v.MaxEnergyReclaim and v.MaxEnergyReclaim > 0 then
                IssueReclaim({eng}, v)
                Reclaiming = true
            end
        end
    end
    return Reclaiming
end

-- AI-Uveso: Helper function for targeting
function ValidateLayer(UnitPos,MovementLayer)
    local TerrainHeight = GetTerrainHeight( UnitPos[1], UnitPos[3] ) -- terran high
    local SurfaceHeight = GetSurfaceHeight( UnitPos[1], UnitPos[3] ) -- water high
    -- Terrain > Surface = Target is on land
    if TerrainHeight >= SurfaceHeight and ( MovementLayer == 'Land' or MovementLayer == 'Amphibious' ) then
        --LOG('AttackLayer '..MovementLayer..' - TerrainHeight > SurfaceHeight. = Target is on land ')
        return true
    end
    -- Terrain < Surface = Target is underwater
    if TerrainHeight < SurfaceHeight and ( MovementLayer == 'Water' or MovementLayer == 'Amphibious' ) then
        --LOG('AttackLayer '..MovementLayer..' - TerrainHeight < SurfaceHeight. = Target is on water ')
        return true
    end
    -- Air can go everywhere
    if MovementLayer == 'Air' then
        return true
    end
    return false
end

-- AI-Uveso: Helper function for targeting
function IsNukeBlastArea(aiBrain, TargetPosition)
    -- check if the target is inside a nuke blast radius
    if aiBrain.NukedArea then
        for i, data in aiBrain.NukedArea or {} do
            if data.NukeTime + 50 <  GetGameTimeSeconds() then
                table.remove(aiBrain.NukedArea, i)
            elseif VDist2(TargetPosition[1], TargetPosition[3], data.Location[1], data.Location[3]) < 40 then
                return true
            end
        end
    end
    return false
end

-- AI-Uveso: Target function
function AIFindNearestCategoryTargetInRange(aiBrain, platoon, squad, position, maxRange, MoveToCategories, TargetSearchCategory, enemyBrain)
    if not maxRange then
        --LOG('* AI-Uveso: AIFindNearestCategoryTargetInRange: function called with empty "maxRange"' )
        return false, false, false, 'NoRange'
    end
    if not TargetSearchCategory then
        --LOG('* AI-Uveso: AIFindNearestCategoryTargetInRange: function called with empty "TargetSearchCategory"' )
        return false, false, false, 'NoCat'
    end
    if not position then
        --LOG('* AI-Uveso: AIFindNearestCategoryTargetInRange: function called with empty "position"' )
        return false, false, false, 'NoPos'
    end
    if not platoon then
        LOG('* AI-Uveso: AIFindNearestCategoryTargetInRange: function called with no "platoon"' )
        return false, false, false, 'NoPos'
    end
    local AttackEnemyStrength = platoon.PlatoonData.AttackEnemyStrength or 300
    local platoonUnits = platoon:GetPlatoonUnits()
    local PlatoonStrength = table.getn(platoonUnits)

    if type(TargetSearchCategory) == 'string' then
        TargetSearchCategory = ParseEntityCategory(TargetSearchCategory)
    end
    local enemyIndex = false
    local MyArmyIndex = aiBrain:GetArmyIndex()
    if enemyBrain then
        enemyIndex = enemyBrain:GetArmyIndex()
    end

    local RangeList = { [1] = maxRange }
    if maxRange > 512 then
        RangeList = {
            [1] = 30,
            [1] = 64,
            [2] = 128,
            [2] = 192,
            [3] = 256,
            [3] = 384,
            [4] = 512,
            [5] = maxRange,
        }
    elseif maxRange > 256 then
        RangeList = {
            [1] = 30,
            [1] = 64,
            [2] = 128,
            [2] = 192,
            [3] = 256,
            [4] = maxRange,
        }
    elseif maxRange > 64 then
        RangeList = {
            [1] = 30,
            [2] = maxRange,
        }
    end
    local path = false
    local reason = false
    local UnitWithPath = false
    local UnitNoPath = false
    local count = 0
    local TargetsInRange, EnemyStrength, TargetPosition, category, distance, targetRange, success, bestGoalPos
    for _, range in RangeList do
        TargetsInRange = aiBrain:GetUnitsAroundPoint(TargetSearchCategory, position, range, 'Enemy')
        --DrawCircle(position, range, '0000FF')
        for _, v in MoveToCategories do
            category = v
            if type(category) == 'string' then
                category = ParseEntityCategory(category)
            end
            distance = maxRange
            --LOG('* AIFindNearestCategoryTargetInRange: numTargets '..table.getn(TargetsInRange)..'  ')
            for num, Target in TargetsInRange do
                if Target.Dead or Target:BeenDestroyed() then
                    continue
                end
                TargetPosition = Target:GetPosition()
                targetRange = VDist2(position[1],position[3],TargetPosition[1],TargetPosition[3])
                --LOG('* AIFindNearestCategoryTargetInRange: targetRange '..repr(targetRange))
                if targetRange < distance then
                    EnemyStrength = 0
                    -- check if thisis the right enemy
                    if not EntityCategoryContains(category, Target) then continue end
                    -- check if the target is on the same layer then the attacker
                    if platoon.MovementLayer ~= 'Air' and not ValidateLayer(TargetPosition, platoon.MovementLayer) then continue end
                    -- check if the Target is still alive, matches our target priority and can be attacked from our platoon
                    if not platoon:CanAttackTarget(squad, Target) then continue end
                    --LOG('* AIFindNearestCategoryTargetInRange: canAttack '..repr(canAttack))
                    if not Target.Dead then
                        -- yes... we need to check if we got friendly units with GetUnitsAroundPoint(_, _, _, 'Enemy')
                        if not IsEnemy( MyArmyIndex, Target:GetAIBrain():GetArmyIndex() ) then continue end
                        -- check if the target is inside a nuke blast radius
                        if IsNukeBlastArea(aiBrain, TargetPosition) then continue end
                        -- check if we have a special player as enemy
                        if enemyBrain and enemyIndex and enemyBrain ~= enemyIndex then continue end
                        if Target.ReclaimInProgress then
                            --WARN('* AIFindNearestCategoryTargetInRange: ReclaimInProgress !!! Ignoring the target.')
                            continue
                        end
                        if Target.CaptureInProgress then
                            --WARN('* AIFindNearestCategoryTargetInRange: CaptureInProgress !!! Ignoring the target.')
                            continue
                        end
                        if not aiBrain:PlatoonExists(platoon) then
                            return false, false, false, 'NoPlatoonExists'
                        end
                        if platoon.MovementLayer == 'Land' then
                            EnemyStrength = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE + categories.GROUNDATTACK) , TargetPosition, 50, 'Enemy' )
                        elseif platoon.MovementLayer == 'Air' then
                            EnemyStrength = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * categories.ANTIAIR , TargetPosition, 60, 'Enemy' )
                        elseif platoon.MovementLayer == 'Water' then
                            EnemyStrength = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE + categories.GROUNDATTACK + categories.ANTINAVY) , TargetPosition, 50, 'Enemy' )
                        elseif platoon.MovementLayer == 'Amphibious' then
                            EnemyStrength = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE + categories.GROUNDATTACK + categories.ANTINAVY) , TargetPosition, 50, 'Enemy' )
                        end
                        --LOG('PlatoonStrength / 100 * AttackEnemyStrength <= '..(PlatoonStrength / 100 * AttackEnemyStrength)..' || EnemyStrength = '..EnemyStrength)
                        -- Only attack if we have a chance to win
                        if PlatoonStrength / 100 * AttackEnemyStrength < EnemyStrength then continue end
                        --coroutine.yield(1)
                        --LOG('* AIFindNearestCategoryTargetInRange: PlatoonGenerateSafePathTo ')
                        path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, platoon.MovementLayer, position, TargetPosition, platoon.PlatoonData.NodeWeight or 10 )
                        -- Check if we found a path with markers
                        if path then
                            UnitWithPath = Target
                            distance = targetRange
                            --LOG('* AIFindNearestCategoryTargetInRange: Possible target with path. distance '..distance..'  ')
                        -- We don't find a path with markers
                        else
                            -- NoPath happens if we have markers, but can't find a way to the destination. (We need transport)
                            if reason == 'NoPath' then
                                UnitNoPath = Target
                                distance = targetRange
                                --LOG('* AIFindNearestCategoryTargetInRange: Possible target no path. distance '..distance..'  ')
                            -- NoGraph means we have no Map markers. Lets try to path with c-engine command CanPathTo()
                            elseif reason == 'NoGraph' then
                                --coroutine.yield(1)
                                local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(platoon, TargetPosition)
                                -- check if we found a path with c-engine command.
                                if success then
                                    UnitWithPath = Target
                                    distance = targetRange
                                    --LOG('* AIFindNearestCategoryTargetInRange: Possible target with CanPathTo(). distance '..distance..'  ')
                                    -- break out of the loop, so we don't use CanPathTo too often.
                                    break
                                -- There is no path to the target.
                                else
                                    UnitNoPath = Target
                                    distance = targetRange
                                    --LOG('* AIFindNearestCategoryTargetInRange: Possible target failed CanPathTo(). distance '..distance..'  ')
                                end
                            end
                        end
                    end
                end
                count = count + 1
                if count > 300 then -- 300 
                    coroutine.yield(1)
                    count = 0
                end
                -- DEBUG; use the first target if we can path to it.
                --if UnitWithPath then
                --    return UnitWithPath, UnitNoPath, path, reason
                --end
                -- DEBUG; use the first target if we can path to it.
            end
            if UnitWithPath then
                return UnitWithPath, UnitNoPath, path, reason
            end
        end
    end
    if UnitNoPath then
        return UnitWithPath, UnitNoPath, path, reason
    end
    return false, false, false, 'NoUnitFound'
end

function AIFindNearestCategoryTargetInRangeCDR(aiBrain, position, maxRange, MoveToCategories, TargetSearchCategory, enemyBrain)
    if type(TargetSearchCategory) == 'string' then
        TargetSearchCategory = ParseEntityCategory(TargetSearchCategory)
    end
    local enemyIndex = false
    local MyArmyIndex = aiBrain:GetArmyIndex()
    if enemyBrain then
        enemyIndex = enemyBrain:GetArmyIndex()
    end
    local RangeList = {
        [1] = 30,
        [1] = 64,
        [2] = 128,
        [4] = maxRange,
    }
    local TargetUnit = false
    local basePostition = aiBrain.BuilderManagers['MAIN'].Position
    local TargetsInRange, EnemyStrength, TargetPosition, category, distance, targetRange, baseTargetRange, canAttack
    for _, range in RangeList do
        TargetsInRange = aiBrain:GetUnitsAroundPoint(TargetSearchCategory, position, range, 'Enemy')
        --DrawCircle(position, range, '0000FF')
        for _, v in MoveToCategories do
            category = v
            if type(category) == 'string' then
                category = ParseEntityCategory(category)
            end
            distance = maxRange
            --LOG('* AIFindNearestCategoryTargetInRange: numTargets '..table.getn(TargetsInRange)..'  ')
            for num, Target in TargetsInRange do
                if Target.Dead or Target:BeenDestroyed() then
                    continue
                end
                TargetPosition = Target:GetPosition()
                EnemyStrength = 0
                -- check if the target is inside a nuke blast radius
                if IsNukeBlastArea(aiBrain, TargetPosition) then continue end
                -- check if we have a special player as enemy
                if enemyBrain and enemyIndex and enemyBrain ~= enemyIndex then continue end
                -- check if the Target is still alive, matches our target priority and can be attacked from our platoon
                if not Target.Dead and EntityCategoryContains(category, Target) then
                    -- yes... we need to check if we got friendly units with GetUnitsAroundPoint(_, _, _, 'Enemy')
                    if not IsEnemy( MyArmyIndex, Target:GetAIBrain():GetArmyIndex() ) then continue end
                    if Target.ReclaimInProgress then
                        --WARN('* AIFindNearestCategoryTargetInRange: ReclaimInProgress !!! Ignoring the target.')
                        continue
                    end
                    if Target.CaptureInProgress then
                        --WARN('* AIFindNearestCategoryTargetInRange: CaptureInProgress !!! Ignoring the target.')
                        continue
                    end
                    targetRange = VDist2(position[1],position[3],TargetPosition[1],TargetPosition[3])
                    baseTargetRange = VDist2(basePostition[1],basePostition[3],TargetPosition[1],TargetPosition[3])
                    -- check if the target is in range of the ACU and in range of the base
                    if targetRange < distance and baseTargetRange < maxRange then
                        TargetUnit = Target
                        distance = targetRange
                    end
                end
            end
            if TargetUnit then
                return TargetUnit
            end
           coroutine.yield(10)
        end
        coroutine.yield(1)
    end
    return TargetUnit
end

function AIFindNearestCategoryTeleportLocation(aiBrain, position, maxRange, MoveToCategories, TargetSearchCategory, enemyBrain)
    if type(TargetSearchCategory) == 'string' then
        TargetSearchCategory = ParseEntityCategory(TargetSearchCategory)
    end
    local enemyIndex = false
    if enemyBrain then
        enemyIndex = enemyBrain:GetArmyIndex()
    end
    local TargetUnit = false
    local TargetsInRange, TargetPosition, category, distance, targetRange, AntiteleportUnits

    TargetsInRange = aiBrain:GetUnitsAroundPoint(TargetSearchCategory, position, maxRange, 'Enemy')
    --LOG('* AIFindNearestCategoryTeleportLocation: numTargets '..table.getn(TargetsInRange)..'  ')
    --DrawCircle(position, range, '0000FF')
    for _, v in MoveToCategories do
        category = v
        if type(category) == 'string' then
            category = ParseEntityCategory(category)
        end
        distance = maxRange
        for num, Target in TargetsInRange do
            if Target.Dead or Target:BeenDestroyed() then
                continue
            end
            TargetPosition = Target:GetPosition()
            -- check if the target is inside a nuke blast radius
            if IsNukeBlastArea(aiBrain, TargetPosition) then continue end
            -- check if we have a special player as enemy
            if enemyBrain and enemyIndex and enemyBrain ~= enemyIndex then continue end
            -- check if the Target is still alive, matches our target priority and can be attacked from our platoon
            if not Target.Dead and EntityCategoryContains(category, Target) then
                -- yes... we need to check if we got friendly units with GetUnitsAroundPoint(_, _, _, 'Enemy')
                if not IsEnemy( aiBrain:GetArmyIndex(), Target:GetAIBrain():GetArmyIndex() ) then continue end
                targetRange = VDist2(position[1],position[3],TargetPosition[1],TargetPosition[3])
                -- check if the target is in range of the ACU and in range of the base
                if targetRange < distance then
                    -- Check if the target is protected by antiteleporter
                    if categories.ANTITELEPORT then 
                        AntiteleportUnits = aiBrain:GetUnitsAroundPoint(categories.ANTITELEPORT, TargetPosition, 60, 'Enemy')
                        --LOG('* AIFindNearestCategoryTeleportLocation: numAntiteleportUnits '..table.getn(AntiteleportUnits)..'  ')
                        local scrambled = false
                        for i, unit in AntiteleportUnits do
                            -- If it's an ally, then we skip.
                            if not IsEnemy( aiBrain:GetArmyIndex(), unit:GetAIBrain():GetArmyIndex() ) then continue end
                            local NoTeleDistance = unit:GetBlueprint().Defense.NoTeleDistance
                            if NoTeleDistance then
                                local AntiTeleportTowerPosition = unit:GetPosition()
                                local dist = VDist2(TargetPosition[1], TargetPosition[3], AntiTeleportTowerPosition[1], AntiTeleportTowerPosition[3])
                                if dist and NoTeleDistance >= dist then
                                    --LOG('* AIFindNearestCategoryTeleportLocation: Teleport Destination Scrambled 1 '..repr(TargetPosition)..' - '..repr(AntiTeleportTowerPosition))
                                    scrambled = true
                                    break
                                end
                            end
                        end
                        if scrambled then
                            continue
                        end
                    end
                    --LOG('* AIFindNearestCategoryTeleportLocation: Found a target that is not Teleport Scrambled')
                    TargetUnit = Target
                    distance = targetRange
                end
            end
        end
        if TargetUnit then
            return TargetUnit
        end
       coroutine.yield(10)
    end
    return TargetUnit
end
