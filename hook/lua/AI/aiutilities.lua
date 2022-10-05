local UvesoOffsetAiutilitiesLUA = debug.getinfo(1).currentline - 1
SPEW('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..UvesoOffsetAiutilitiesLUA..'] * AI-Uveso: offset aiutilities.lua')
--2964

local CanGraphAreaTo = import("/mods/AI-Uveso/lua/AI/AIMarkerGenerator.lua").CanGraphAreaTo

-- Hook For AI-Uveso.
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
    --AILog('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] pos ('..math.floor(pos[1])..','..math.floor(pos[3])..') to destination ('..math.floor(destination[1])..','..math.floor(destination[3])..')', true, UvesoOffsetAiutilitiesLUA)
    -- don't check a path if we are in build range
    if VDist2(pos[1], pos[3], destination[1], destination[3]) <= 12 then
        --AIWarn('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] distance to buildplace < 12, no pathing needed. returning TRUE', true, UvesoOffsetAiutilitiesLUA)
        return true
    end

    -- first try to find a path with markers.
    local result, bestPos
    local path, reason = AIAttackUtils.EngineerGenerateSafePathTo(aiBrain, 'Amphibious', pos, destination)
    -- only use CanPathTo for distance closer then 200 and if we can't path with markers
    if reason ~= 'PathOK' then
        --AILog('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] No path found reason:('..reason..')', true, UvesoOffsetAiutilitiesLUA)
        -- we will crash the game if we use CanPathTo() on all engineer movments on a map without markers. So we don't path at all.
        if reason == 'NoGraph' then
            result = true
        -- if we have a Graph (AI markers) but not a path, then there is no path. We need a transporter.
        elseif reason == 'NoPath' then
            --AILog('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] No path found ('..math.floor(pos[1])..','..math.floor(pos[3])..') to ('..math.floor(destination[1])..','..math.floor(destination[3])..')', true, UvesoOffsetAiutilitiesLUA)
        elseif VDist2(pos[1], pos[3], destination[1], destination[3]) < 200 then
            --AIDebug('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] EngineerGenerateSafePathTo returned reason: ('..repr(reason)..') -> executing c-engine function CanPathTo().', true, UvesoOffsetAiutilitiesLUA)
            -- be really sure we don't try a pathing with a destroyed c-object
            if unit.Dead or unit:BeenDestroyed() or IsDestroyed(unit) then
                --AIDebug('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] Unit is death before calling CanPathTo(), returning FALSE', true, UvesoOffsetAiutilitiesLUA)
                return false
            end
            result, bestPos = unit:CanPathTo(destination)
        end
    else
        --AILog('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] Amphibious path found! reason:('..reason..')', true, UvesoOffsetAiutilitiesLUA)
    end

    local bUsedTransports = false
    if ((not result and reason ~= 'PathOK') or VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 40000) -- 200*200=40000
    and unit.PlatoonHandle and not EntityCategoryContains(categories.COMMAND, unit) then
        --AILog('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] No path found trying transports (start)', true, UvesoOffsetAiutilitiesLUA)
        -- If we can't path to our destination, we need, rather than want, transports
        needTransports = true

        local numOwnTransports = aiBrain:GetCurrentUnits(categories.TRANSPORTATION - categories.uea0203)
        if numOwnTransports > 0 then
            --AILog('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] Transporter found:('..numOwnTransports..') -> SendPlatoonWithTransportsNoCheck (start)', true, UvesoOffsetAiutilitiesLUA)
            bUsedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, unit.PlatoonHandle, destination, needTransports, true, false)
            --AILog('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] SendPlatoonWithTransportsNoCheck (end)', true, UvesoOffsetAiutilitiesLUA)
        else
            --AILog('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] numOwnTransports = 0, no transporter found', true, UvesoOffsetAiutilitiesLUA)
        end

        if bUsedTransports then
            --AIWarn('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] No path found used transport (bUsedTransports = true)', true, UvesoOffsetAiutilitiesLUA)
            return true
        elseif VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 262144 then -- 515*515=262144
            --AIWarn('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] No path found trying transports failed (>515*515 FALSE)', true, UvesoOffsetAiutilitiesLUA)
            -- If over 512 and no transports dont try and walk!
            return false
        end
    else
        --AILog('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] no transport used! reason:('..reason..')', true, UvesoOffsetAiutilitiesLUA)
    end

    -- If we're here, we haven't used transports and we can path to the destination
    if result or reason == 'PathOK' then
         --AILog('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] target is reachable, path found! reason:('..reason..')', true, UvesoOffsetAiutilitiesLUA)
--        if reason ~= 'PathOK' then
--            path, reason = AIAttackUtils.EngineerGenerateSafePathTo(aiBrain, 'Amphibious', pos, destination)
--        end
        if path then
            --AIWarn('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] target is reachable, path found! moving waypoints, returning TRUE', true, UvesoOffsetAiutilitiesLUA)
            -- Move to way points (but not to destination... leave that for the final command)
            for widx, waypointPath in path do
                IssueMove({unit}, waypointPath)
            end
            --IssueMove({unit}, destination)
        else
            --AIWarn('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] target is reachable, CanPathTo found! moving direct, returning TRUE', true, UvesoOffsetAiutilitiesLUA)
            IssueMove({unit}, destination)
        end
        return true
    end
    --AIWarn('* AI-Uveso: EngineerMoveWithSafePath(): unit ['..repr(unit.EntityId)..'] target is not reachable, cancel MoveWithSafePath, returning FALSE', true, UvesoOffsetAiutilitiesLUA)
    return false
end

-- AI-Uveso: Helper function for targeting
function ValidateLayer(UnitPos,MovementLayer)
    -- Air can go everywhere
    if MovementLayer == 'Air' then
        return true
    end
    local TerrainHeight = GetTerrainHeight( UnitPos[1], UnitPos[3] ) -- terran high
    local SurfaceHeight = GetSurfaceHeight( UnitPos[1], UnitPos[3] ) -- water high
    -- Terrain > Surface = Target is on land
    if TerrainHeight >= SurfaceHeight and ( MovementLayer == 'Land' or MovementLayer == 'Amphibious' ) then
        --AILog('AttackLayer '..MovementLayer..' - TerrainHeight > SurfaceHeight. = Target is on land ')
        return true
    end
    -- Terrain < Surface = Target is underwater
    if TerrainHeight < SurfaceHeight and ( MovementLayer == 'Water' or MovementLayer == 'Amphibious' ) then
        --AILog('AttackLayer '..MovementLayer..' - TerrainHeight < SurfaceHeight. = Target is on water ')
        return true
    end
    return false
end

function ValidateAttackLayer(position, TargetPosition)
    -- check if attacker and target are both over or under water
    local TerrainHeight = GetTerrainHeight( position[1], position[3] ) -- terran high
    local SurfaceHeight = GetSurfaceHeight( position[1], position[3] ) -- water high
    local Land1 = false
    if TerrainHeight >= SurfaceHeight then
        Land1 = true
    end

    TerrainHeight = GetTerrainHeight( position[1], position[3] ) -- terran high
    SurfaceHeight = GetSurfaceHeight( position[1], position[3] ) -- water high
    local Land2 = false
    if TerrainHeight >= SurfaceHeight then
        Land2 = true
    end
    
    if Land1 == Land2 then
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
                return data.Location
            end
        end
    end
    return false
end

-- AI-Uveso: Target function
function AIFindNearestCategoryTargetInRange(aiBrain, platoon, squad, position, maxRange, MoveToCategories, TargetSearchCategory, enemyBrain)
    --AILog('* AIFindNearestCategoryTargetInRange: calling function '..platoon.BuilderName)
    local EntityCategoryContains = EntityCategoryContains
    local VDist2Sq = VDist2Sq
    local CanGraphAreaTo = CanGraphAreaTo
    local platoonUnits = platoon:GetPlatoonUnits()
    local IgnoreTargetLayerCheck = platoon.PlatoonData.IgnoreTargetLayerCheck
    local path, reason
    local enemyIndex = false
    local MyArmyIndex = aiBrain:GetArmyIndex()
    if enemyBrain then
        enemyIndex = enemyBrain:GetArmyIndex()
    end
    local heatMap = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetHeatMapForArmy(MyArmyIndex)
    local GetHeatMapGridIndexFromPosition = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetHeatMapGridIndexFromPosition
    local x, z
    local RangeList = { [1] = maxRange }
    if maxRange > 1024 then
        RangeList = {
            [1] = 30,
            [2] = 60,
            [3] = 100,
            [4] = 150,
            [5] = 210,
            [6] = 280,
            [7] = 360,
            [8] = 450,
            [9] = 600,
            [10] = 800,
            [11] = maxRange,
        }
    elseif maxRange > 512 then
        RangeList = {
            [1] = 30,
            [2] = 60,
            [3] = 100,
            [4] = 150,
            [5] = 210,
            [6] = 280,
            [7] = 360,
            [8] = 450,
            [9] = maxRange,
        }
    elseif maxRange > 256 then
        RangeList = {
            [1] = 30,
            [2] = 60,
            [3] = 100,
            [4] = 150,
            [5] = 210,
            [6] = maxRange,
        }
    elseif maxRange > 64 then
        RangeList = {
            [1] = 30,
            [2] = 60,
            [3] = maxRange,
        }
    end
    local path = false
    local reason = false
    local ReturnReason = 'got no reason'
    local UnitWithPath = false
    local UnitNoPath = false
    local count = 0
    local alreadyChecked = {}
    local TargetsInRange, EnemyStrength, TargetPosition, distance, targetRange, success, bestGoalPos, blip
    local PlatoonStrength = 0
    local unitCat
    for _, unit in platoon:GetPlatoonUnits() do
        unitCat = unit.Blueprint.CategoriesHash
        if unitCat.TECH1 then
            PlatoonStrength = PlatoonStrength + 1
        elseif unitCat.TECH2 then
            PlatoonStrength = PlatoonStrength + 3
        elseif unitCat.TECH3 then
            PlatoonStrength = PlatoonStrength + 13
        elseif unitCat.EXPERIMENTAL then
            PlatoonStrength = PlatoonStrength + 80
        elseif unitCat.COMMAND then
            PlatoonStrength = PlatoonStrength + 20
        else
            AIWarn('* AIFindNearestCategoryTargetInRange: cant identify a unit for PlatoonStrength '..repr(unit.UnitId), true, UvesoOffsetAiutilitiesLUA)
        end
    end
    if PlatoonStrength <= 0 then
        AIWarn('* AIFindNearestCategoryTargetInRange: no PlatoonStrength ???'..repr(platoon:GetPlatoonUnits()), true, UvesoOffsetAiutilitiesLUA)
    end
    local AttackEnemyStrength = platoon.PlatoonData.AttackEnemyStrength or 100
    if AttackEnemyStrength <= 0 then
        AIWarn('* AIFindNearestCategoryTargetInRange: no AttackEnemyStrength for platoon '..platoon.BuilderName..' ??? ', true, UvesoOffsetAiutilitiesLUA)
    end
    for _, range in RangeList do
        TargetsInRange = aiBrain:GetUnitsAroundPoint(TargetSearchCategory, position, range, 'Enemy')
        --AILog('* AIFindNearestCategoryTargetInRange: numTargets '..table.getn(TargetsInRange)..' in range: '..range..' '..platoon.BuilderName)
        for num, Target in TargetsInRange do
            if alreadyChecked[Target.EntityId] then continue end
            alreadyChecked[Target.EntityId] = true
            distance = range * range
            for _, category in MoveToCategories do
                if Target.Dead or Target:BeenDestroyed() then continue end
                TargetPosition = Target:GetPosition()
                targetRange = VDist2Sq(position[1],position[3],TargetPosition[1],TargetPosition[3])
                --AILog('* AIFindNearestCategoryTargetInRange: targetRange '..repr(targetRange))
                if targetRange < distance then
                    if not EntityCategoryContains(category, Target) then continue end
                    -- we can't attack units while reclaim or capture is in progress
                    if Target.CaptureInProgress then continue end
                    if Target.ReclaimInProgress then continue end
                    -- check if the target is on the same layer then the attacker
                    if not IgnoreTargetLayerCheck then
                        if not ValidateAttackLayer(position, TargetPosition) then continue end
                        if platoon.MovementLayer == 'Land' and EntityCategoryContains(categories.AIR, Target) then continue end
                        if platoon.MovementLayer == 'Water' and not ValidateLayer(TargetPosition, 'Water' ) then continue end
                    end
                    -- check if the Target is still alive, matches our target priority and can be attacked from our platoon
                    if not platoon:CanAttackTarget(squad, Target) then continue end
                    -- check if we have a special player as enemy
                    if enemyBrain and enemyIndex and enemyBrain ~= enemyIndex then continue end
                    -- yes... we need to check if we got friendly units with GetUnitsAroundPoint(_, _, _, 'Enemy')
                    if not IsEnemy( MyArmyIndex, Target.Army ) then continue end
                    -- check if the target is inside a nuke blast radius
                    if IsNukeBlastArea(aiBrain, TargetPosition) then continue end
                    -- Only attack if we have a chance to win
                    x, z = GetHeatMapGridIndexFromPosition(TargetPosition)
                    EnemyStrength = heatMap[x][z].threatRing[platoon.MovementLayer]
                    --AILog('PlatoonStrength = '..PlatoonStrength..' || EnemyStrength = '..EnemyStrength.." ||  AttackEnemyStrength = "..AttackEnemyStrength.." || "..(PlatoonStrength / 100 * AttackEnemyStrength).." > "..EnemyStrength.." ("..repr( not (PlatoonStrength / 100 * AttackEnemyStrength < EnemyStrength) )..")")
                    --INFO: PlatoonStrength / 100 * AttackEnemyStrength <= 0 || EnemyStrength = 44 - Attack: false
                    if PlatoonStrength / 100 * AttackEnemyStrength < EnemyStrength then continue end
                    -- make sure we are not hunting rabbits (fake units, units that are maybe dead but still on radar)
                    blip = Target:GetBlip(MyArmyIndex)
                    -- do we have a "blip" for the target on the radar ?
                    if blip then
                        -- is the target on radar or was it ever seen by a scout?
                        if blip:IsOnRadar(MyArmyIndex) or blip:IsSeenEver(MyArmyIndex) then
                            -- check if the target is not a fake or maybe already dead
                            if not blip:BeenDestroyed() and not blip:IsKnownFake(MyArmyIndex) and not blip:IsMaybeDead(MyArmyIndex) then
                                if not Target.Dead then
                                    if not aiBrain:PlatoonExists(platoon) then
                                        return false, false, false, 'NoPlatoonExists'
                                    end
                                    -- Check if we found a path with markers
                                    -- Check if we can graph to the target (cheap pathing). Needed for naval + 2 lakes or land + islands
                                    if CanGraphAreaTo(position, TargetPosition, platoon.MovementLayer) then
                                        UnitWithPath = Target
                                        distance = targetRange
                                        ReturnReason = reason
                                        --AILog('* AIFindNearestCategoryTargetInRange: Possible target with path. distance '..distance..'  ')
                                    -- We don't find a path with markers
                                    elseif not UnitWithPath then
                                        UnitNoPath = Target
                                        distance = targetRange
                                        ReturnReason = reason
                                        --AILog('* AIFindNearestCategoryTargetInRange: Possible target no path. distance '..distance..'  ')
                                    end
                                end
                            end
                        end
                    end
                end
                -- DEBUG; use the first target we can path to it.
                --if UnitWithPath then
                --    return UnitWithPath, UnitNoPath, path, ReturnReason
                --end
                -- DEBUG; use the first target we can path to it.
            end
            count = count + 1
            if count > 300 then -- 300
                --AIWarn('* AIFindNearestCategoryTargetInRange: count: '..count..'  ', true, UvesoOffsetAiutilitiesLUA)
                coroutine.yield(1)
                count = 0
            end
        end
        if UnitWithPath then
            --AIWarn('* AIFindNearestCategoryTargetInRange: UnitWithPath! count: '..count..'  ', true, UvesoOffsetAiutilitiesLUA)
            path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, platoon.MovementLayer, position, TargetPosition, platoon.PlatoonData.NodeWeight or 10 )
            if reason ~= "PathOK" then
                --AIWarn('* AIFindNearestCategoryTargetInRange: CanGraphAreaTo = true but PlatoonGenerateSafePathTo = false - reason '..reason..'  ', true, UvesoOffsetAiutilitiesLUA)
                return false, UnitWithPath, false, ReturnReason
            end
            return UnitWithPath, false, path, ReturnReason
        end
    end
    if UnitNoPath then
        --AIWarn('* AIFindNearestCategoryTargetInRange: UnitNoPath! count: '..count..'  ', true, UvesoOffsetAiutilitiesLUA)
        return false, UnitNoPath, false, ReturnReason
    end
    --AILog('* AI-Uveso: AIFindNearestCategoryTargetInRange NoUnitFound. AIPlan('..repr(platoon.PlanName)..'), BuilderName('..repr(platoon.BuilderName)..')')
    return false, false, false, 'NoUnitFound'
end

function AIFindNearestCategoryTargetInCloseRange(platoon, aiBrain, squad, position, maxRange, MoveToCategories, TargetSearchCategory)
    --AILog('* AIFindNearestCategoryTargetInCloseRange: calling function'..platoon.BuilderName)
    local CanGraphAreaTo = CanGraphAreaTo
    local IgnoreTargetLayerCheck = platoon.PlatoonData.IgnoreTargetLayerCheck
    local MyArmyIndex = aiBrain:GetArmyIndex()
    if maxRange < 30 then
        maxRange = 30
    end
    local RangeList = {
        [1] = 30,
        [2] = maxRange,
        [3] = maxRange + 50,
    }
    local TargetUnit = false
    local TargetsInRange, TargetPosition, distance, targetRange
    local alreadyChecked = {}
    for _, range in RangeList do
        TargetsInRange = aiBrain:GetUnitsAroundPoint(TargetSearchCategory, position, range, 'Enemy')
        --AILog('* AIFindNearestCategoryTargetInCloseRange: numTargets '..table.getn(TargetsInRange)..' in rangeRing: ('..range..') - '..platoon.BuilderName)
        --DrawCircle(position, range, '0000FF')
        for num, Target in TargetsInRange do
            distance = range * range
            for _, category in MoveToCategories do
                if Target.Dead or Target:BeenDestroyed() then continue end
                if alreadyChecked[Target.EntityId] then continue end
                alreadyChecked[Target.EntityId] = true
                if Target.ReclaimInProgress then continue end
                if Target.CaptureInProgress then continue end
                -- yes... we need to check if we got friendly units with GetUnitsAroundPoint(_, _, _, 'Enemy')
                TargetPosition = Target:GetPosition()
                targetRange = VDist2Sq(position[1],position[3],TargetPosition[1],TargetPosition[3])
                if targetRange < distance then
                    if not IsEnemy( MyArmyIndex, Target.Army ) then continue end
                    if not EntityCategoryContains(category, Target) then continue end
                    if not platoon:CanAttackTarget(squad, Target) then continue end
                    -- check if the target is inside a nuke blast radius
                    if IsNukeBlastArea(aiBrain, TargetPosition) then continue end
                    -- check if the target is on the same layer then the attacker
                    if not IgnoreTargetLayerCheck then
                        if not ValidateAttackLayer(position, TargetPosition) then continue end
                        if platoon.MovementLayer ~= 'Air' and EntityCategoryContains(categories.AIR, Target) then continue end
                        if platoon.MovementLayer == 'Water' and not ValidateLayer(TargetPosition, 'Water' ) then continue end
                    end
                    -- Check if we can graph to the target (cheap pathing). Needed for naval + 2 lakes or land + islands
                    if not CanGraphAreaTo(position, TargetPosition, platoon.MovementLayer) then continue end
                    --AILog('* AIFindNearestCategoryTargetInCloseRange: closer target in range: ('..targetRange..') - '..platoon.BuilderName)
                    TargetUnit = Target
                    distance = targetRange
                end
            end
        end
        if TargetUnit then
            --AILog('* AIFindNearestCategoryTargetInCloseRange: Final target in range: ('..targetRange..') - '..platoon.BuilderName)
            return TargetUnit
        end
        coroutine.yield(1)
    end
    --AILog('* AIFindNearestCategoryTargetInCloseRange: no target!!!')
    return TargetUnit
end

function AIFindNearestCategoryTeleportLocation(aiBrain, position, maxRange, MoveToCategories, TargetSearchCategory, enemyBrain)
    local enemyIndex = false
    if enemyBrain then
        enemyIndex = enemyBrain:GetArmyIndex()
    end
    local MyArmyIndex = aiBrain:GetArmyIndex()
    local TargetUnit = false
    local TargetsInRange, TargetPosition, distance, targetRange, AntiteleportUnits, scrambled
    local NoTeleDistance, AntiTeleportTowerPosition, dist
    TargetsInRange = aiBrain:GetUnitsAroundPoint(TargetSearchCategory, position, maxRange, 'Enemy')
    --AILog('* AIFindNearestCategoryTeleportLocation: numTargets '..table.getn(TargetsInRange)..'  ')
    --DrawCircle(position, range, '0000FF')
    for _, category in MoveToCategories do
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
                if not IsEnemy( MyArmyIndex, Target.Army ) then continue end
                targetRange = VDist2(position[1],position[3],TargetPosition[1],TargetPosition[3])
                -- check if the target is in range of the ACU and in range of the base
                if targetRange < distance then
                    -- Check if the target is protected by antiteleporter
                    if categories.ANTITELEPORT then
                        AntiteleportUnits = aiBrain:GetUnitsAroundPoint(categories.ANTITELEPORT, TargetPosition, 60, 'Enemy')
                        --AILog('* AIFindNearestCategoryTeleportLocation: numAntiteleportUnits '..table.getn(AntiteleportUnits)..'  ')
                        scrambled = false
                        for i, unit in AntiteleportUnits do
                            -- If it's an ally, then we skip.
                            if not IsEnemy( MyArmyIndex, unit.Army ) then continue end
                            NoTeleDistance = unit:GetBlueprint().Defense.NoTeleDistance
                            if NoTeleDistance then
                                AntiTeleportTowerPosition = unit:GetPosition()
                                dist = VDist2(TargetPosition[1], TargetPosition[3], AntiTeleportTowerPosition[1], AntiTeleportTowerPosition[3])
                                if dist and NoTeleDistance >= dist then
                                    --AILog('* AIFindNearestCategoryTeleportLocation: Teleport Destination Scrambled 1 '..repr(TargetPosition)..' - '..repr(AntiTeleportTowerPosition))
                                    scrambled = true
                                    break
                                end
                            end
                        end
                        if scrambled then
                            continue
                        end
                    end
                    --AILog('* AIFindNearestCategoryTeleportLocation: Found a target that is not Teleport Scrambled')
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
