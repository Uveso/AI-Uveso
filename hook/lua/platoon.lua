local UvesoOffsetPlatoonLUA = debug.getinfo(1).currentline - 1
SPEW('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..UvesoOffsetPlatoonLUA..'] * AI-Uveso: offset platoon.lua' )
--6844

local UUtils = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua')
local HERODEBUG = false
local CHAMPIONDEBUG = false -- you need to fucus the AI army to see the debug drawing
local NUKEDEBUG = false
local MarkerSwitchDist = 20
local MarkerSwitchDistEXP = 40

CopyOfOldPlatoonClass = Platoon
Platoon = Class(CopyOfOldPlatoonClass) {

    -- Fixed a bug where the ACU stops working when build to close
    -- ToDo remove when merged to FAF 08.May.2022
    ProcessBuildCommand = function(eng, removeLastBuild)
        if not eng or eng.Dead or not eng.PlatoonHandle then
            return
        end
        local aiBrain = eng.PlatoonHandle:GetBrain()
        if not aiBrain.Uveso then
            return CopyOfOldPlatoonClass.ProcessBuildCommand(eng, removeLastBuild)
        end

        if not aiBrain or eng.Dead or not eng.EngineerBuildQueue or table.empty(eng.EngineerBuildQueue) then
            if aiBrain:PlatoonExists(eng.PlatoonHandle) then
                if not eng.AssistSet and not eng.AssistPlatoon and not eng.UnitBeingAssist and not eng.UnitBeingBuiltBehavior then
                    eng.PlatoonHandle:PlatoonDisband()
                end
            end
            if eng then eng.ProcessBuild = nil end
            return
        end

        -- it wasn't a failed build, so we just finished something
        if removeLastBuild then
            table.remove(eng.EngineerBuildQueue, 1)
        end

        eng.ProcessBuildDone = false
        IssueClearCommands({eng})
        local commandDone = false
        local PlatoonPos
        local whatToBuild
        local buildLocation
        local buildRelative
        while not eng.Dead and not commandDone and not table.empty(eng.EngineerBuildQueue)  do
            while not aiBrain:IsOpponentAIRunning() do
                coroutine.yield(10)
            end
            whatToBuild = eng.EngineerBuildQueue[1][1]
            buildLocation = {eng.EngineerBuildQueue[1][2][1], 0, eng.EngineerBuildQueue[1][2][2]}
            if GetTerrainHeight(buildLocation[1], buildLocation[3]) >= GetSurfaceHeight(buildLocation[1], buildLocation[3]) then
                --land
                buildLocation[2] = GetTerrainHeight(buildLocation[1], buildLocation[3])
            else
                --water
                buildLocation[2] = GetSurfaceHeight(buildLocation[1], buildLocation[3])
            end
            buildRelative = eng.EngineerBuildQueue[1][3]
            if not eng.NotBuildingThread then
                eng.NotBuildingThread = eng:ForkThread(eng.PlatoonHandle.WatchForNotBuilding)
            end
            -- see if we can move there first
            if AIUtils.EngineerMoveWithSafePath(aiBrain, eng, buildLocation) then
                if not eng or eng.Dead or not eng.PlatoonHandle or not aiBrain:PlatoonExists(eng.PlatoonHandle) then
                    return
                end
                if eng.PlatoonHandle.UsingTransport then
                    --AIWarn("* AI-Uveso: ProcessBuildCommand: Engineer is using transport")
                    coroutine.yield(3)
                end
                PlatoonPos = eng:GetPosition()
                if VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, buildLocation[1] or 0, buildLocation[3] or 0) >= 30 then
                    -- issue buildcommand to block other engineers from caping mex/hydros or to reserve the buildplace
                    -- check to see if we need to reclaim or capture...
                    AIUtils.EngineerTryReclaimCaptureArea(aiBrain, eng, buildLocation)
                    -- check to see if we can repair
                    AIUtils.EngineerTryRepair(aiBrain, eng, whatToBuild, buildLocation)
                    -- otherwise, go ahead and build the next structure there
                    aiBrain:BuildStructure(eng, whatToBuild, {buildLocation[1], buildLocation[3], 0}, buildRelative)
                    coroutine.yield(3)
                    -- wait until we are close to the buildplace so we have intel
                    while not eng.Dead do
                        PlatoonPos = eng:GetPosition()
                        if VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, buildLocation[1] or 0, buildLocation[3] or 0) < 12 then
                            break
                        end
                        -- check if we are already building in close range
                        -- (ACU can build at higher range than engineers)
                        if eng:IsUnitState("Building") then
                            break
                        end
                        coroutine.yield(1)
                    end
                end
                if not eng or eng.Dead or not eng.PlatoonHandle or not aiBrain:PlatoonExists(eng.PlatoonHandle) then
                    if eng then eng.ProcessBuild = nil end
                    return
                end
                -- if we are already building then we don't need to reclaim, repair or issue the BuildStructure again
                if not eng:IsUnitState("Building") then
                    -- cancel all commands, also the buildcommand for blocking mex to check for reclaim or capture
                    eng.PlatoonHandle:Stop()
                    -- check to see if we need to reclaim or capture...
                    AIUtils.EngineerTryReclaimCaptureArea(aiBrain, eng, buildLocation)
                    -- check to see if we can repair
                    AIUtils.EngineerTryRepair(aiBrain, eng, whatToBuild, buildLocation)
                    -- otherwise, go ahead and build the next structure there
                    aiBrain:BuildStructure(eng, whatToBuild, {buildLocation[1], buildLocation[3], 0}, buildRelative)
                end
                if not eng.NotBuildingThread then
                    eng.NotBuildingThread = eng:ForkThread(eng.PlatoonHandle.WatchForNotBuilding)
                end
                commandDone = true
            else
                -- we can't move there, so remove it from our build queue
                table.remove(eng.EngineerBuildQueue, 1)
            end
        end

        -- final check for if we should disband
        if not eng or eng.Dead or table.empty(eng.EngineerBuildQueue) then
            if eng.PlatoonHandle and aiBrain:PlatoonExists(eng.PlatoonHandle) and not eng.PlatoonHandle.UsingTransport then
                eng.PlatoonHandle:PlatoonDisband()
            end
        end
        if eng then eng.ProcessBuild = nil end
    end,    

-- UVESO's Stuff: ------------------------------------------------------------------------------------

    -- Hook for Mass RepeatBuild
    PlatoonDisband = function(self)
        if not self then return end
        local aiBrain = self:GetBrain()
        if not aiBrain.Uveso then
            return CopyOfOldPlatoonClass.PlatoonDisband(self)
        end
        local eng = self:GetPlatoonUnits()[1]
        --AILog('* AI-Uveso: PlatoonDisband = '..repr(self.PlatoonData.Construction.BuildStructures))
        --AILog('* AI-Uveso: PlatoonDisband = '..repr(self.PlatoonData.Construction))
        if self.UsingTransport then
            AIWarn('* AI-Uveso: PlatoonDisband: Disbanding platoon while transporting!!! Disbanding Blocked!', true, UvesoOffsetPlatoonLUA)
            AIWarn('* AI-Uveso: PlatoonDisband: PlanName '..repr(self.PlanName)..'  -  BuilderName: '..repr(self.BuilderName)..'.', true, UvesoOffsetPlatoonLUA )
            if not self.PlanName or not self.BuilderName then
                AIWarn('* AI-Uveso: PlatoonDisband: PlatoonData = '..repr(self.PlatoonData), true, UvesoOffsetPlatoonLUA)
            end
            local FuncData = debug.getinfo(2)
            if FuncData.name and FuncData.name ~= "" then
                AIWarn('* AI-Uveso: PlatoonDisband: Called from '..FuncData.name..'.', true, UvesoOffsetPlatoonLUA)
            else
                AIWarn('* AI-Uveso: PlatoonDisband: Called from '..FuncData.source..' - line: '..FuncData.currentline.. '  -  (Offset AI-Uveso: ['..(FuncData.currentline - UvesoOffsetPlatoonLUA)..'])', true, UvesoOffsetPlatoonLUA)
            end
        end
        if self.PlatoonData.Construction.RepeatBuild then
            --AILog('* AI-Uveso: PlatoonDisband: Repeat build = '..repr(self.PlatoonData.Construction.BuildStructures[1]))
            -- only repeat build if less then 10% of all structures are extractors
            local UCBC = import('/lua/editor/UnitCountBuildConditions.lua')
            if UCBC.HaveUnitRatioVersusCap(aiBrain, 0.10, '<', categories.STRUCTURE * categories.MASSEXTRACTION) then
                --AILog('* AI-Uveso: PlatoonDisband: HaveUnitRatioVersusCap < ')
                -- only repeat if we have a free mass spot
                local MABC = import('/lua/editor/MarkerBuildConditions.lua')
                if MABC.CanBuildOnMass(aiBrain, 'MAIN', 1000, -500, 1, 0, 'AntiSurface', 1) then  -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
                    --AILog('* AI-Uveso: PlatoonDisband: CanBuildOnMass')
                    coroutine.yield(10)
                    local count = 1
                    while eng and not eng.Dead and not eng:IsIdleState() and aiBrain:PlatoonExists(self) and count < 120 do
                        coroutine.yield(10)
                        count = count + 1
                    end
                    -- disband on low energy
--                    if aiBrain:GetEconomyStoredRatio('ENERGY') < 0.50 or aiBrain:GetEconomyTrend('ENERGY') < 0.0 then
--                        if aiBrain:PlatoonExists(self) then
--                            CopyOfOldPlatoonClass.PlatoonDisband(self)
--                        end
--                    end
                    
                    if aiBrain:PlatoonExists(self) and eng and not eng.Dead then
                        self:EngineerBuildAI()
                    end
                    return
                end
            end
            -- delete the repeat flag so the engineer will not repeat on its next task
            self.PlatoonData.Construction.RepeatBuild = nil
            self:MoveToLocation(aiBrain.BuilderManagers['MAIN'].Position, false)
            coroutine.yield(10)
            local count = 1
            while eng and not eng.Dead and eng:IsUnitState("Moving") and aiBrain:PlatoonExists(self) and count < 120 do
                coroutine.yield(10)
                count = count + 1
            end
        end
        if aiBrain:PlatoonExists(self) then
            CopyOfOldPlatoonClass.PlatoonDisband(self)
        end
    end,

    BaseManagersDistressAI = function(self)
       -- Only use this with AI-Uveso
        local aiBrain = self:GetBrain()
        if not aiBrain.Uveso then
            return CopyOfOldPlatoonClass.BaseManagersDistressAI(self)
        end
        coroutine.yield(10)
        -- We are leaving this forked thread here because we don't need it.
        KillThread(CurrentThread())
    end,

    BuildACUEnhancements = function(platoon, cdr, force)
        local EnhancementsByUnitID = {
            -- UEF
            ['uel0001'] = {'HeavyAntiMatterCannon', 'DamageStabilization', 'Shield', 'ShieldGeneratorField'},
            -- Aeon
            ['ual0001'] = {'CrysalisBeam', 'HeatSink', 'Shield', 'ShieldHeavy'},
            -- Cybran
            ['url0001'] = {'CoolingUpgrade', 'StealthGenerator', 'MicrowaveLaserGenerator', 'CloakingGenerator'},
            -- Seraphim
            ['xsl0001'] = {'RateOfFire', 'DamageStabilization', 'BlastAttack', 'DamageStabilizationAdvanced'},
            -- Nomads
            ['xnl0001'] = {'GunUpgrade', 'Capacitor', 'MovementSpeedIncrease', 'DoubleGuns'},

            -- UEF - Black Ops ACU
            ['eel0001'] = {'GatlingEnergyCannon', 'CombatEngineering', 'ShieldBattery', 'AutomaticBarrelStabalizers', 'AssaultEngineering', 'ImprovedShieldBattery', 'EnhancedPowerSubsystems', 'ApocalypticEngineering', 'AdvancedShieldBattery'},
            -- Aeon
            ['eal0001'] = {'PhasonBeamCannon', 'CombatEngineering', 'ShieldBattery', 'DualChannelBooster', 'AssaultEngineering', 'ImprovedShieldBattery', 'EnergizedMolecularInducer', 'ApocalypticEngineering', 'AdvancedShieldBattery'},
            -- Cybram
            ['erl0001'] = {'EMPArray', 'CombatEngineering', 'ArmorPlating', 'AdjustedCrystalMatrix', 'AssaultEngineering', 'StructuralIntegrityFields', 'EnhancedLaserEmitters', 'ApocalypticEngineering', 'CompositeMaterials'},
            -- Seraphim
            ['esl0001'] = {'PlasmaGatlingCannon', 'CombatEngineering', 'ElectronicsEnhancment', 'PhasedEnergyFields', 'AssaultEngineering', 'PersonalTeleporter', 'SecondaryPowerFeeds', 'ApocalypticEngineering', 'CloakingSubsystems'},
        }
        local CRDBlueprint = cdr:GetBlueprint()
        --AILog('* AI-Uveso: BlueprintId '..repr(CRDBlueprint.BlueprintId))
        local ACUUpgradeList = EnhancementsByUnitID[CRDBlueprint.BlueprintId]
        --AILog('* AI-Uveso: ACUUpgradeList '..repr(ACUUpgradeList))
        local NextEnhancement = false
        local HaveEcoForEnhancement = false
        local wantedEnhancementBP
        for _,enhancement in ACUUpgradeList or {} do
            wantedEnhancementBP = CRDBlueprint.Enhancements[enhancement]
            --AILog('* AI-Uveso: wantedEnhancementBP '..repr(wantedEnhancementBP))
            if not wantedEnhancementBP then
                AIDebug('* AI-Uveso: ACUAttackAIUveso: no enhancement found for  = '..repr(enhancement), true, UvesoOffsetPlatoonLUA)
            elseif cdr:HasEnhancement(enhancement) then
                NextEnhancement = false
                --AILog('* AI-Uveso: * ACUAttackAIUveso: BuildACUEnhancements: Enhancement is already installed: '..enhancement)
            elseif platoon:EcoGoodForUpgrade(cdr, wantedEnhancementBP) then
                --AILog('* AI-Uveso: * ACUAttackAIUveso: BuildACUEnhancements: Eco is good for '..enhancement)
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = true
                    --AILog('* AI-Uveso: * ACUAttackAIUveso: *** Set as Enhancememnt: '..NextEnhancement)
                end
            elseif force then
                --AILog('* AI-Uveso: * ACUAttackAIUveso: BuildACUEnhancements: Eco is bad for '..enhancement..' - Ignoring eco requirement!')
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = true
                end
            else
                --AILog('* AI-Uveso: * ACUAttackAIUveso: BuildACUEnhancements: Eco is bad for '..enhancement)
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = false
                    -- if we don't have the eco for this ugrade, stop the search
                    --AILog('* AI-Uveso: * ACUAttackAIUveso: canceled search. no eco available')
                    break
                end
            end
        end
        if NextEnhancement and HaveEcoForEnhancement then
            --AILog('* AI-Uveso: * ACUAttackAIUveso: BuildACUEnhancements Building '..NextEnhancement)
            if platoon:BuildEnhancement(cdr, NextEnhancement) then
                --AILog('* AI-Uveso: * ACUAttackAIUveso: BuildACUEnhancements returned true'..NextEnhancement)
                return NextEnhancement
            else
                --AILog('* AI-Uveso: * ACUAttackAIUveso: BuildACUEnhancements returned false'..NextEnhancement)
                return false
            end
        end
        return false
    end,
    
    EcoGoodForUpgrade = function(platoon,cdr,enhancement)
        local aiBrain = platoon:GetBrain()
        local BuildRate = cdr:GetBuildRate()
        if not enhancement.BuildTime then
            AIWarn('* AI-Uveso: EcoGoodForUpgrade: Enhancement has no buildtime: '..repr(enhancement), true, UvesoOffsetPlatoonLUA)
        end
        --AILog('* AI-Uveso: cdr:GetBuildRate() '..BuildRate..'')
        local drainMass = (BuildRate / enhancement.BuildTime) * enhancement.BuildCostMass
        local drainEnergy = (BuildRate / enhancement.BuildTime) * enhancement.BuildCostEnergy
        --AILog('* AI-Uveso: drain: m'..drainMass..'  e'..drainEnergy..'')
        --AILog('* AI-Uveso: Pump: m'..math.floor(aiBrain:GetEconomyTrend('MASS')*10)..'  e'..math.floor(aiBrain:GetEconomyTrend('ENERGY')*10)..'')
        if aiBrain.PriorityManager.HasParagon then
            return true
        elseif aiBrain:GetEconomyTrend('MASS')*10 >= drainMass and aiBrain:GetEconomyTrend('ENERGY')*10 >= drainEnergy then
            return true
        end
        return false
    end,
    
    BuildEnhancement = function(platoon,cdr,enhancement)
        --AILog('* AI-Uveso: BuildEnhancement: '..enhancement)
        local aiBrain = platoon:GetBrain()
        IssueClearCommands({cdr})
        local order
        if not cdr:HasEnhancement(enhancement) then
            local tempEnhanceBp = cdr:GetBlueprint().Enhancements[enhancement]
            local unitEnhancements = import('/lua/enhancementcommon.lua').GetEnhancements(cdr.EntityId)
            -- Do we have already a enhancment in this slot ?
            if unitEnhancements[tempEnhanceBp.Slot] and unitEnhancements[tempEnhanceBp.Slot] ~= tempEnhanceBp.Prerequisite then
                -- remove the enhancement
                --AILog('* AI-Uveso: BuildEnhancement: Found enhancement ['..unitEnhancements[tempEnhanceBp.Slot]..'] in Slot ['..tempEnhanceBp.Slot..']. - Removing...')
                order = { TaskName = "EnhanceTask", Enhancement = unitEnhancements[tempEnhanceBp.Slot]..'Remove' }
                IssueScript({cdr}, order)
                coroutine.yield(10)
            end
            AIDebug('* AI-Uveso: BuildEnhancement: '..platoon:GetBrain().Nickname..' IssueScript: '..enhancement, true, UvesoOffsetPlatoonLUA)
            order = { TaskName = "EnhanceTask", Enhancement = enhancement }
            IssueScript({cdr}, order)
        end
        while aiBrain:PlatoonExists(platoon) and not cdr.Dead and not cdr:HasEnhancement(enhancement) do
            if UUtils.ComHealth(cdr) < 50 and UUtils.UnderAttack(cdr) and cdr.WorkProgress < 0.90 then
                AIDebug('* AI-Uveso: BuildEnhancement: '..platoon:GetBrain().Nickname..' Emergency!!! low health < 50% and under attack, canceling Enhancement '..enhancement, true, UvesoOffsetPlatoonLUA)
                IssueStop({cdr})
                IssueClearCommands({cdr})
                return false
            end
            if cdr.WorkProgress < 0.30 and UUtils.UnderAttack(cdr) then
                AIDebug('* AI-Uveso: BuildEnhancement: '..platoon:GetBrain().Nickname..' Emergency!!! WorkProgress < 30% and under attack, canceling Enhancement '..enhancement, true, UvesoOffsetPlatoonLUA)
                IssueStop({cdr})
                IssueClearCommands({cdr})
                return false
            end
            coroutine.yield(3)
        end
        AIDebug('* AI-Uveso: BuildEnhancement: '..platoon:GetBrain().Nickname..' Upgrade finished '..enhancement, true, UvesoOffsetPlatoonLUA)
        return true
    end,

    MakeShortPath = function(self, PlatoonPosition, path)
        -- sometimes we don't have a platoonposition even if the platoon exist.
        if not PlatoonPosition then
            return path
        end
        local dist, shortestDist, shortestIndex
        -- loop over all path nodes and look for the closest one
        for i, nodePos in path do
            dist = VDist2Sq(PlatoonPosition[1], PlatoonPosition[3], nodePos[1], nodePos[3])
            if not shortestDist or shortestDist >= dist then
                shortestDist = dist
                shortestIndex = i
            end
        end
        -- no need to change, the path is ok
        if shortestIndex == 1 then
            return path
        end
        -- only use waypoints from the closest node up to the destination
        local newPath = {}
        for i=shortestIndex, table.getn(path) do
            table.insert(newPath, path[i])
        end
        return newPath
    end,

    MoveWithTransportNoPath = function(self, aiBrain, bAggroMove, target, basePosition, ExperimentalInPlatoon, MaxPlatoonWeaponRange, EnemyThreatCategory)
        local MaxPlatoonWeaponRange = MaxPlatoonWeaponRange or 30
        local EnemyThreatCategory = EnemyThreatCategory or categories.ALLUNITS
        local TargetPosition = table.copy(target:GetPosition())
        local usedTransports = false
        if not aiBrain:PlatoonExists(self) then
            AIWarn('* AI-Uveso: MoveWithTransportNoPath: platoon does not exist', true, UvesoOffsetPlatoonLUA)
            return
        end
        local PlatoonPosition = self:GetPlatoonPosition()
        if not PlatoonPosition then
            AIWarn('* AI-Uveso: MoveWithTransportNoPath: PlatoonPosition is NIL', true, UvesoOffsetPlatoonLUA)
            return
        end
        -- see if we are in danger, fight units that are close to the platoon
        if bAggroMove then
            numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(EnemyThreatCategory, PlatoonPosition, MaxPlatoonWeaponRange + 20 , 'Enemy')
            if numEnemyUnits > 0 then
                return
            end
        end
        self:SetPlatoonFormationOverride('NoFormation')
        while not aiBrain:IsOpponentAIRunning() do
            coroutine.yield(10)
        end
        if not ExperimentalInPlatoon and aiBrain:PlatoonExists(self) then
            usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, TargetPosition, true, false)
        end
        if not usedTransports then
            --AILog('* AI-Uveso: * MoveWithTransportNoPath: SendPlatoonWithTransportsNoCheck failed.')
            local PlatoonPos = self:GetPlatoonPosition() or TargetPosition
            local DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, TargetPosition[1] or 0, TargetPosition[3] or 0)
            local DistanceToBase = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
            if DistanceToBase < DistanceToTarget or DistanceToTarget > 50 then
                --AILog('* AI-Uveso: * MoveWithTransportNoPath: base is nearer then distance to target or distance to target over 50. Return To base')
                self:SimpleReturnToBase(basePosition)
            else
                --AILog('* AI-Uveso: * MoveWithTransportNoPath: Direct move to Target')
                if bAggroMove then
                    self:AggressiveMoveToLocation(TargetPosition)
                else
                    self:MoveToLocation(TargetPosition, false)
                end
            end
        else
            --AILog('* AI-Uveso: * MoveWithTransportNoPath: We got a transport!!')
        end
    end,

    MoveDirect = function(self, aiBrain, bAggroMove, target, MaxPlatoonWeaponRange, EnemyThreatCategory)
        local MaxPlatoonWeaponRange = MaxPlatoonWeaponRange or 30
        local EnemyThreatCategory = EnemyThreatCategory or categories.ALLUNITS
        local platoonUnits = self:GetPlatoonUnits()
        self:SetPlatoonFormationOverride('NoFormation')
        local TargetPosition = table.copy(target:GetPosition())
        local PlatoonPosition
        local Lastdist
        local dist
        local Stuck = 0
        local ATTACKFORMATION = false
        local numEnemyUnits
        if bAggroMove then
            self:AggressiveMoveToLocation(TargetPosition)
        else
            self:MoveToLocation(TargetPosition, false)
        end
        local platoonUnitscheck
        while aiBrain:PlatoonExists(self) do
            while not aiBrain:IsOpponentAIRunning() do
                coroutine.yield(10)
            end
            PlatoonPosition = self:GetPlatoonPosition() or TargetPosition
            dist = VDist2( TargetPosition[1], TargetPosition[3], PlatoonPosition[1], PlatoonPosition[3] )
            if not bAggroMove then
                platoonUnitscheck = self:GetPlatoonUnits()
                if table.getn(platoonUnits) > table.getn(platoonUnitscheck) then
                    --AILog('* AI-Uveso: * MoveDirect: unit in platoon destroyed!!!')
                    ATTACKFORMATION = true
                    self:SetPlatoonFormationOverride('AttackFormation')
                    return
                end
            end
            --AILog('* AI-Uveso: * MoveDirect: dist to next Waypoint: '..dist)
            --AILog('* AI-Uveso: * MoveDirect: dist to target: '..dist)
            if not ATTACKFORMATION and dist < 80 then
                ATTACKFORMATION = true
                --AILog('* AI-Uveso: * MoveDirect: dist < 80 '..dist)
                self:SetPlatoonFormationOverride('AttackFormation')
            end
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
                    --AILog('* AI-Uveso: * MoveDirect: Stucked while moving to target. Stuck='..Stuck)
                    self:Stop()
                    return
                end
            end
            -- If we lose our target, stop moving to it.
            if not target or target.Dead then
                --AILog('* AI-Uveso: * MoveDirect: Lost target while moving to target. ')
                return
            end
            -- see if we are in danger, fight units that are close to the platoon
            if bAggroMove then
                numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(EnemyThreatCategory, PlatoonPosition, MaxPlatoonWeaponRange + 20 , 'Enemy')
                if numEnemyUnits > 0 then
                    return
                end
            end
            coroutine.yield(10)
        end
    end,

    MovePath = function(self, aiBrain, path, bAggroMove, target, MaxPlatoonWeaponRange, EnemyThreatCategory, ExperimentalInPlatoon)
        local distEnd
        local MaxPlatoonWeaponRange = MaxPlatoonWeaponRange or 30
        local EnemyThreatCategory = EnemyThreatCategory or categories.ALLUNITS
        local MarkerSwitchDistance = MarkerSwitchDist
        if ExperimentalInPlatoon then
            MarkerSwitchDistance = MarkerSwitchDistEXP
        end
        local platoonUnits = self:GetPlatoonUnits()
        local PlatoonPosition = self:GetPlatoonPosition()
        path = self:MakeShortPath(PlatoonPosition, path)
        self:SetPlatoonFormationOverride('NoFormation')
        
        local PathNodesCount = table.getn(path)
        if self.MovementLayer == 'Air' then
            -- Air units should not follow the path for the last 3 hops.
            if PathNodesCount - 3 > 0 then
                PathNodesCount = PathNodesCount - 3
            -- if we have a short path, just use the destination as waypoint
            else
                path[1] = path[PathNodesCount]
                PathNodesCount = 1
            end
        end
        if not path[1] then
            if target and not target.Dead and not target:BeenDestroyed() then 
                path =  {table.copy(target:GetPosition())}
            else
                return
            end
        end
        local ATTACKFORMATION = false
        local Lastdist
        local dist
        local Stuck
        local platoonUnitscheck
        for i=1, PathNodesCount do
            Lastdist = false
            Stuck = 0
            --AILog('* AI-Uveso: * MovePath: moving to destination. i: '..i..' coords '..repr(path[i]))
            if bAggroMove then
                self:AggressiveMoveToLocation(path[i])
            else
                self:MoveToLocation(path[i], false)
            end
            if HERODEBUG then
                self:RenamePlatoon('MovePath: moving to path['..i..'] '..repr(path[i]))
            end
            while aiBrain:PlatoonExists(self) do
                while not aiBrain:IsOpponentAIRunning() do
                    coroutine.yield(10)
                end
                PlatoonPosition = self:GetPlatoonPosition() or path[i]
                dist = VDist2( path[i][1], path[i][3], PlatoonPosition[1], PlatoonPosition[3] )
                if not bAggroMove then
                    platoonUnitscheck = self:GetPlatoonUnits()
                    if table.getn(platoonUnits) > table.getn(platoonUnitscheck) then
                        --AILog('* AI-Uveso: * MovePath: unit in platoon destroyed!!!')
                        self:SetPlatoonFormationOverride('AttackFormation')
                    end
                end
                --AILog('* AI-Uveso: * MovePath: dist to next Waypoint: '..dist)
                distEnd = VDist2( path[PathNodesCount][1], path[PathNodesCount][3], PlatoonPosition[1], PlatoonPosition[3] )
                --AILog('* AI-Uveso: * MovePath: dist to Path End: '..distEnd)
                if not ATTACKFORMATION and distEnd < 80 then
                    ATTACKFORMATION = true
                    --AILog('* AI-Uveso: * MovePath: distEnd < 50 '..distEnd)
                    self:SetPlatoonFormationOverride('AttackFormation')
                end
                -- are we closer then 20 units from the next marker ? Then break and move to the next marker
                if dist < MarkerSwitchDistance then
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
                        --AILog('* AI-Uveso: * MovePath: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                        self:Stop()
                        break -- break the while aiBrain:PlatoonExists(self) do loop and move to the next waypoint
                    end
                end
                -- If we lose our target, stop moving to it.
                if not target or target.Dead then
                    if HERODEBUG then
                        self:RenamePlatoon('MovePath: Lost target while moving to Waypoint ')
                    end
                    --AILog('* AI-Uveso: * MovePath: Lost target while moving to Waypoint. '..repr(path[i]))
                    return
                end
                -- see if we are in danger, fight units that are close to the platoon
                if bAggroMove then
                    numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(EnemyThreatCategory, PlatoonPosition, MaxPlatoonWeaponRange + 20 , 'Enemy')
                    if numEnemyUnits > 0 then
                        if HERODEBUG then
                            self:RenamePlatoon('MovePath: cancel move, enemies nearby')
                        end
                        return
                    end
                end
                coroutine.yield(10)
            end
        end
        if HERODEBUG then
            self:RenamePlatoon('MovePath: destination reached; dist:'..distEnd)
        end
    end,

    MoveToLocationInclTransport = function(self, target, TargetPosition, bAggroMove, WantsTransport, basePosition, ExperimentalInPlatoon, MaxPlatoonWeaponRange, EnemyThreatCategory, overridePath, overrideReason)
        local MaxPlatoonWeaponRange = MaxPlatoonWeaponRange or 30
        local EnemyThreatCategory = EnemyThreatCategory or categories.ALLUNITS
        local MarkerSwitchDistance = MarkerSwitchDist
        if ExperimentalInPlatoon then
            MarkerSwitchDistance = MarkerSwitchDistEXP
        end
        local platoonUnits = self:GetPlatoonUnits()
        self:SetPlatoonFormationOverride('NoFormation')
        if not TargetPosition then
            TargetPosition = table.copy(target:GetPosition())
        end
        local aiBrain = self:GetBrain()
        local PlatoonPosition = self:GetPlatoonPosition()
        -- this will be true if we got our units transported to the destination
        local usedTransports = false
        local TransportNotNeeded, bestGoalPos
        -- check, if we can reach the destination without a transport
        local unit = AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        local path, reason
        if overridePath then
            path, reason = overridePath, overrideReason
            path = self:MakeShortPath(PlatoonPosition, path)
        else
            path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer or 'Land' , PlatoonPosition, TargetPosition, 1000, 512)
        end
        if not aiBrain:PlatoonExists(self) then
            return
        end
        -- don't use a transporter if we have a path and the target is closer then 100 map units
        if path and VDist2( PlatoonPosition[1], PlatoonPosition[3], TargetPosition[1], TargetPosition[3] ) < 100 then
            --AILog('* AI-Uveso: * MoveToLocationInclTransport: no transporter used for target distance '..VDist2( PlatoonPosition[1], PlatoonPosition[3], TargetPosition[1], TargetPosition[3] ) )
        -- use a transporter if we don't have a path, or if we want a transport
        elseif not ExperimentalInPlatoon and ((not path and reason ~= 'NoGraph') or WantsTransport)  then
            --AILog('* AI-Uveso: * MoveToLocationInclTransport: SendPlatoonWithTransportsNoCheck')
            if HERODEBUG then
                self:RenamePlatoon('SendPlatoonWithTransportsNoCheck')
                coroutine.yield(1)
            end
            while not aiBrain:IsOpponentAIRunning() do
                coroutine.yield(10)
            end
            usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, TargetPosition, true, false)
        end
        -- if we don't got a transport, try to reach the destination by path or directly
        if not usedTransports then
            if HERODEBUG then
                self:RenamePlatoon('usedTransports = false')
                coroutine.yield(1)
            end
            -- clear commands, so we don't get stuck if we have an unreachable destination
            IssueClearCommands(self:GetPlatoonUnits())
            if path then
                --AILog('* AI-Uveso: * MoveToLocationInclTransport: No transport used, and we dont need it.')
                if table.getn(path) > 1 then
                    --AILog('* AI-Uveso: * MoveToLocationInclTransport: table.getn(path): '..table.getn(path))
                end
                local PathNodesCount = table.getn(path)
                local ATTACKFORMATION = false
                if HERODEBUG then
                    self:RenamePlatoon('PathNodesCount: '..repr(PathNodesCount))
                    coroutine.yield(1)
                end
                for i=1, PathNodesCount do
                    if HERODEBUG then
                        self:RenamePlatoon('move to : path['..i..']')
                        coroutine.yield(1)
                    end
                    --AILog('* AI-Uveso: * MoveToLocationInclTransport: moving to destination. i: '..i..' coords '..repr(path[i]))
                    if bAggroMove then
                        self:AggressiveMoveToLocation(path[i])
                    else
                        self:MoveToLocation(path[i], false)
                    end
                    local PlatoonPosition
                    local Lastdist
                    local dist
                    local Stuck = 0
                    local platoonUnitscheck
                    while aiBrain:PlatoonExists(self) do
                        while not aiBrain:IsOpponentAIRunning() do
                            coroutine.yield(10)
                        end
                        PlatoonPosition = self:GetPlatoonPosition() or nil
                        if not PlatoonPosition then break end
                        dist = VDist2( path[i][1], path[i][3], PlatoonPosition[1], PlatoonPosition[3] )
                        if not bAggroMove then
                            platoonUnitscheck = self:GetPlatoonUnits()
                            if table.getn(platoonUnits) > table.getn(platoonUnitscheck) then
                                --AILog('* AI-Uveso: * MoveToLocationInclTransport: unit in platoon destroyed!!!')
                                self:SetPlatoonFormationOverride('AttackFormation')
                            end
                        end
                        --AILog('* AI-Uveso: * MoveToLocationInclTransport: dist to next Waypoint: '..dist)
                        distEnd = VDist2( path[PathNodesCount][1], path[PathNodesCount][3], PlatoonPosition[1], PlatoonPosition[3] )
                        --AILog('* AI-Uveso: * MoveToLocationInclTransport: dist to Path End: '..distEnd)
                        if not ATTACKFORMATION and distEnd < 80 then
                            ATTACKFORMATION = true
                            --AILog('* AI-Uveso: * MoveToLocationInclTransport: distEnd < 50 '..distEnd)
                            self:SetPlatoonFormationOverride('AttackFormation')
                        end
                        -- are we closer then 20 units from the next marker ? Then break and move to the next marker
                        if dist < MarkerSwitchDistance then
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
                                --AILog('* AI-Uveso: * MoveToLocationInclTransport: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                                self:Stop()
                                break -- break the while aiBrain:PlatoonExists(self) do loop and move to the next waypoint
                            end
                        end
                        -- If we lose our target, stop moving to it.
                        if not target then
                            --AILog('* AI-Uveso: * MoveToLocationInclTransport: Lost target while moving to Waypoint. '..repr(path[i]))
                            self:Stop()
                            if HERODEBUG then
                                self:RenamePlatoon('Lost target')
                                coroutine.yield(1)
                            end
                            return
                        end
                        -- see if we are in danger, fight units that are close to the platoon
                        if bAggroMove then
                            numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(EnemyThreatCategory, PlatoonPosition, MaxPlatoonWeaponRange + 30 , 'Enemy')
                            if numEnemyUnits > 0 then
                                if HERODEBUG then
                                    self:RenamePlatoon('enemy nearby')
                                    coroutine.yield(1)
                                end
                                return
                            end
                        end
                        coroutine.yield(10)
                    end
                end
            else
                if HERODEBUG then
                    self:RenamePlatoon('nopath: '..repr(reason))
                    coroutine.yield(1)
                end
                --AILog('* AI-Uveso: * MoveToLocationInclTransport: No transport used, and we have no Graph to reach the destination. Checking CanPathTo()')
                if reason == 'NoGraph' then
                    local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(self, TargetPosition)
                    if success then
                        --AILog('* AI-Uveso: * MoveToLocationInclTransport: No transport used, found a way with CanPathTo(). moving to destination')
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
                            while not aiBrain:IsOpponentAIRunning() do
                                coroutine.yield(10)
                            end
                            PlatoonPosition = self:GetPlatoonPosition() or nil
                            if not PlatoonPosition then continue end
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
                                    --AILog('* AI-Uveso: * MoveToLocationInclTransport: Stucked while moving to target. Stuck='..Stuck)
                                    self:Stop()
                                    break -- break the while aiBrain:PlatoonExists(self) do loop and move to the next waypoint
                                end
                            end
                            -- If we lose our target, stop moving to it.
                            if not target then
                                --AILog('* AI-Uveso: * MoveToLocationInclTransport: Lost target while moving to target. ')
                                self:Stop()
                                return
                            end
                            coroutine.yield(10)
                        end
                    else
                        --AILog('* AI-Uveso: * MoveToLocationInclTransport: CanPathTo() failed for '..repr(TargetPosition)..' forcing SendPlatoonWithTransportsNoCheck.')
                        if not ExperimentalInPlatoon then
                            usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, TargetPosition, true, false)
                        end
                        if not usedTransports then
                            --AILog('* AI-Uveso: * MoveToLocationInclTransport: CanPathTo() and SendPlatoonWithTransportsNoCheck failed. SimpleReturnToBase!')
                            local PlatoonPos = self:GetPlatoonPosition()
                            local DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, TargetPosition[1] or 0, TargetPosition[3] or 0)
                            local DistanceToBase = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
                            if DistanceToBase < DistanceToTarget and DistanceToTarget > 50 then
                                --AILog('* AI-Uveso: * MoveToLocationInclTransport: base is nearer then distance to target and distance to target over 50. Return To base')
                                self:SimpleReturnToBase(basePosition)
                            else
                                --AILog('* AI-Uveso: * MoveToLocationInclTransport: Direct move to Target')
                                if bAggroMove then
                                    self:AggressiveMoveToLocation(TargetPosition)
                                else
                                    self:MoveToLocation(TargetPosition, false)
                                end
                            end
                        else
                            --AILog('* AI-Uveso: * MoveToLocationInclTransport: CanPathTo() failed BUT we got an transport!!')
                        end

                    end
                else
                    --AILog('* AI-Uveso: * MoveToLocationInclTransport: We have no path but there is a Graph with markers. So why we don\'t get a path ??? (Island or threat too high?) - reason: '..repr(reason))
                end
            end
        else
            if HERODEBUG then
                self:RenamePlatoon('TRANSPORTED')
                coroutine.yield(1)
            end
            --AILog('* AI-Uveso: * MoveToLocationInclTransport: TRANSPORTED.')
        end
    end,

    TransferAIUveso = function(self)
        local aiBrain = self:GetBrain()
        if not aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType] then
            --AILog('* AI-Uveso: * TransferAIUveso: Location ('..self.PlatoonData.MoveToLocationType..') has no BuilderManager!')
            self:PlatoonDisband()
            return
        end
        local eng = self:GetPlatoonUnits()[1]
        if eng and not eng.Dead and eng.BuilderManagerData.EngineerManager then
            --AILog('* AI-Uveso: * TransferAIUveso: '..repr(self.BuilderName))
            eng.BuilderManagerData.EngineerManager:RemoveUnit(eng)
            --AILog('* AI-Uveso: * TransferAIUveso: AddUnit units to - BuilderManagers: '..self.PlatoonData.MoveToLocationType..' - ' .. aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType].EngineerManager:GetNumCategoryUnits('Engineers', categories.ALLUNITS) )
            aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType].EngineerManager:AddUnit(eng, true)
            -- Move the unit to the desired base after transfering BuilderManagers to the new LocationType
            local basePosition = aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType].Position
            --AILog('* AI-Uveso: * TransferAIUveso: Moving transfer-units to - ' .. self.PlatoonData.MoveToLocationType)
            self:MoveToLocationInclTransport(true, basePosition, false, false, basePosition, false)
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
            if not v.Dead and EntityCategoryContains(categories.MOBILE * categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD, v) then
                eng = v
                break
            end
        end
        if eng then
            eng.UnitBeingBuilt = eng
            UUtils.ReclaimAIThread(self,eng,aiBrain)
            eng.UnitBeingBuilt = nil
        end
        self:PlatoonDisband()
    end,

    FinisherAIUveso = function(self)
        local aiBrain = self:GetBrain()
        -- Only use this with AI-Uveso
        if not self.PlatoonData or not self.PlatoonData.LocationType then
            self:PlatoonDisband()
            return
        end
        local eng = self:GetPlatoonUnits()[1]
        local engineerManager = aiBrain.BuilderManagers[self.PlatoonData.LocationType].EngineerManager
        if not engineerManager then
            self:PlatoonDisband()
            return
        end
        local unfinishedUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE + categories.EXPERIMENTAL, engineerManager.Location, engineerManager.Radius, 'Ally')
        local FractionComplete
        for k,v in unfinishedUnits do
            FractionComplete = v:GetFractionComplete()
            if FractionComplete < 1 and table.getn(v:GetGuards()) < 1 then
                self:Stop()
                if not v.Dead and not v:BeenDestroyed() then
                    IssueRepair(self:GetPlatoonUnits(), v)
                end
                break
            end
        end
        local count = 0
        repeat
            coroutine.yield(20)
            if not aiBrain:PlatoonExists(self) then
                return
            end
            count = count + 1
            if eng:IsIdleState() then break end
        until count >= 30
        self:PlatoonDisband()
    end,

    TMLAIUveso = function(self)
        local aiBrain = self:GetBrain()
        local platoonUnits = self:GetPlatoonUnits()
        local TML
        for k, v in platoonUnits do
            if not v.Dead and EntityCategoryContains(categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM * categories.TECH2, v) then
                TML = v
                break
            end
        end
        UUtils.TMLAIThread(self,TML,aiBrain)
        self:PlatoonDisband()
    end,

    PlatoonMerger = function(self)
        --AILog('* AI-Uveso: * PlatoonMerger: called from Builder: '..(self.BuilderName or 'Unknown'))
        local aiBrain = self:GetBrain()
        local PlatoonPlan = self.PlatoonData.AIPlan
        --AILog('* AI-Uveso: * PlatoonMerger: AIPlan: '..(PlatoonPlan or 'Unknown'))
        if not PlatoonPlan then
            return
        end
        -- Get all units from the platoon
        local platoonUnits = self:GetPlatoonUnits()
        -- check if we have already a Platoon with this AIPlan
        local AlreadyMergedPlatoon
        local PlatoonList = aiBrain:GetPlatoonsList()
        for _,Platoon in PlatoonList do
            if Platoon:GetPlan() == PlatoonPlan then
                --AILog('* AI-Uveso: * PlatoonMerger: Found Platton with plan '..PlatoonPlan)
                AlreadyMergedPlatoon = Platoon
                break
            end
            --AILog('* AI-Uveso: * PlatoonMerger: Found '..repr(Platoon:GetPlan()))
        end
        -- If we dont have already a platton for this AIPlan, create one.
        if not AlreadyMergedPlatoon then
            AlreadyMergedPlatoon = aiBrain:MakePlatoon( PlatoonPlan..'Platoon', PlatoonPlan )
            AlreadyMergedPlatoon.PlanName = PlatoonPlan
            AlreadyMergedPlatoon.BuilderName = PlatoonPlan..'Platoon'
--            AlreadyMergedPlatoon:UniquelyNamePlatoon(PlatoonPlan)
        end
        -- Add our unit(s) to the platoon
        aiBrain:AssignUnitsToPlatoon( AlreadyMergedPlatoon, platoonUnits, 'support', 'none' )
        -- transfer platoondata
        AlreadyMergedPlatoon.PlatoonData.SearchRadius = self.PlatoonData.SearchRadius
        AlreadyMergedPlatoon.PlatoonData.GetTargetsFromBase = self.PlatoonData.GetTargetsFromBase
        AlreadyMergedPlatoon.PlatoonData.IgnorePathing = self.PlatoonData.IgnorePathing
        AlreadyMergedPlatoon.PlatoonData.DirectMoveEnemyBase = self.PlatoonData.DirectMoveEnemyBase
        AlreadyMergedPlatoon.PlatoonData.RequireTransport = self.PlatoonData.RequireTransport
        AlreadyMergedPlatoon.PlatoonData.AggressiveMove = self.PlatoonData.AggressiveMove
        AlreadyMergedPlatoon.PlatoonData.AttackEnemyStrength = self.PlatoonData.AttackEnemyStrength
        AlreadyMergedPlatoon.PlatoonData.TargetSearchCategory = self.PlatoonData.TargetSearchCategory
        AlreadyMergedPlatoon.PlatoonData.MoveToCategories = self.PlatoonData.MoveToCategories
        AlreadyMergedPlatoon.PlatoonData.WeaponTargetCategories = self.PlatoonData.WeaponTargetCategories
        AlreadyMergedPlatoon.PlatoonData.TargetHug = self.PlatoonData.TargetHug
        -- Disband this platoon, it's no longer needed.
        self:PlatoonDisbandNoAssign()
    end,

    ExtractorUpgradeAI = function(self)
        --AILog('* AI-Uveso: +++ ExtractorUpgradeAI: START')
        local aiBrain = self:GetBrain()
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        local ratio = 0.0
                          -- 0    3     6     10    15    20    25    30  >600  >1000
                          -- 1    2     3     4     5     6     7     8     9
        local RatioTable = {0.0, 0.10, 0.10, 0.15, 0.20, 0.25, 0.30, 0.40, 0.50, 1.0}
        if personality == 'uvesorush' then
            --RatioTable = {0.00, 0.10, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.40, 0.80}
            RatioTable = {0.00, 0.05, 0.10, 0.15, 0.20, 0.30, 0.40, 0.50, 0.50, 0.75}
        end
        local platoonUnits
        local MassExtractorUnitList
        while aiBrain:PlatoonExists(self) do
            while not aiBrain:IsOpponentAIRunning() do
                coroutine.yield(10)
            end
            --AILog('* AI-Uveso: +++ ExtractorUpgradeAI: PULSE')
            if aiBrain.PriorityManager.HasParagon then
                -- if we have a paragon, upgrade mex as fast as possible. Mabye we lose the paragon and need mex again.
                ratio = RatioTable[10]
            elseif aiBrain:GetEconomyIncome('MASS') * 10 > 1000 then
                --AILog('* AI-Uveso: Mass over 1000. Eco running with 50%')
                ratio = RatioTable[10]
            elseif aiBrain:GetEconomyIncome('MASS') * 10 > 600 then
                --AILog('* AI-Uveso: Mass over 600. Eco running with 35%')
                ratio = RatioTable[9]
            elseif GetGameTimeSeconds() > 1800 then -- 30 * 60
                ratio = RatioTable[8]
            elseif GetGameTimeSeconds() > 1500 then -- 25 * 60
                ratio = RatioTable[7]
            elseif GetGameTimeSeconds() > 1200 then -- 20 * 60
                ratio = RatioTable[6]
            elseif GetGameTimeSeconds() > 900 then -- 15 * 60
                ratio = RatioTable[5]
            elseif GetGameTimeSeconds() > 600 then -- 10 * 60
                ratio = RatioTable[4]
            elseif GetGameTimeSeconds() > 360 then -- 6 * 60
                ratio = RatioTable[3]
            elseif GetGameTimeSeconds() > 180 then -- 3 * 60
                ratio = RatioTable[2]
            elseif GetGameTimeSeconds() <= 360 then -- 1-5
                ratio = RatioTable[1]
            end
            platoonUnits = self:GetPlatoonUnits()
            MassExtractorUnitList = aiBrain:GetListOfUnits(categories.MASSEXTRACTION * (categories.TECH1 + categories.TECH2 + categories.TECH3), false, false)
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
                            if not UUtils.ExtractorUpgrade(self, aiBrain, MassExtractorUnitList, ratio, 'TECH2', UnitUpgradeTemplates, StructureUpgradeTemplates) then
                                -- We can't upgrade a TECH2 extractor. Try to upgrade from TECH1 to TECH2
                                UUtils.ExtractorUpgrade(self, aiBrain, MassExtractorUnitList, ratio, 'TECH1', UnitUpgradeTemplates, StructureUpgradeTemplates)
                            end
                        else
                            -- We have less than 90% TECH2 extractors compared to TECH1. Upgrade more TECH1
                            UUtils.ExtractorUpgrade(self, aiBrain, MassExtractorUnitList, ratio, 'TECH1', UnitUpgradeTemplates, StructureUpgradeTemplates)
                        end
                    end
                end
            end
            -- Check the Eco every x Ticks
            coroutine.yield(10)
            -- find dead units inside the platoon and disband if we find one
            for k,v in self:GetPlatoonUnits() do
                if not v or v.Dead or v:BeenDestroyed() then
                    -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                    --AILog('* AI-Uveso: +++ ExtractorUpgradeAI: Found Dead unit, self:PlatoonDisbandNoAssign()')
                    -- needs PlatoonDisbandNoAssign, or extractors will stop upgrading if the platton is disbanded
                    coroutine.yield(1)
                    self:PlatoonDisbandNoAssign()
                    return
                end
            end
        end
        -- No return here. We will never reach this position. After disbanding this platoon, the forked 'ExtractorUpgradeAI' thread will be terminated from outside.
    end,

    SimpleReturnToBase = function(self, basePosition)
        if not basePosition or type(basePosition) ~= 'table' then
            AIWarn('* AI-Uveso: SimpleReturnToBase: basePosition nil or not a table ['..repr(basePosition)..']', true, UvesoOffsetPlatoonLUA)
            return
        end
        local aiBrain = self:GetBrain()
        local PlatoonPosition
        local Lastdist
        local dist
        local Stuck = 0
        self:Stop()
        self:MoveToLocation(basePosition, false)
        while aiBrain:PlatoonExists(self) do
            while not aiBrain:IsOpponentAIRunning() do
                coroutine.yield(10)
            end
            PlatoonPosition = self:GetPlatoonPosition()
            if not PlatoonPosition then
                --AILog('* AI-Uveso: SimpleReturnToBase: no Platoon Position')
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
            coroutine.yield(10)
        end
        if aiBrain:PlatoonExists(self) then
            self:PlatoonDisband()
        end
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
                --AILog('* AI-Uveso: ForceReturnToNearestBaseAIUveso Can\'t return to This base. Wrong movementlayer: '..repr(v.FactoryManager.LocationType))
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
        if HERODEBUG then
            self:RenamePlatoon('Disbanding in 3 sec.')
        end
        coroutine.yield(30)
        if HERODEBUG then
            self:RenamePlatoon('Disbanded')
        end
        if aiBrain:PlatoonExists(self) then
            self:PlatoonDisband()
        end
    end,

    ForceReturnToNavalBaseAIUveso = function(self, basePosition)
        local aiBrain = self:GetBrain()
        local platPos = self:GetPlatoonPosition() or basePosition
        local nearestbase = false
        for k,v in aiBrain.BuilderManagers do
            -- check if we can move to this base
            if not AIUtils.ValidateLayer(v.FactoryManager.Location, 'Water') then
                --AILog('* AI-Uveso: ForceReturnToNavalBaseAIUveso Can\'t return to This base. Wrong movementlayer: '..repr(v.FactoryManager.LocationType))
                continue
            end
            local dist = VDist2( platPos[1], platPos[3], v.FactoryManager.Location[1], v.FactoryManager.Location[3] )
            if not nearestbase or nearestbase.dist > dist then
                nearestbase = {}
                nearestbase.Pos = v.FactoryManager.Location
                nearestbase.dist = dist
                --AILog('* AI-Uveso: ForceReturnToNavalBaseAIUveso closest base found in dist:'..dist)
            end
        end
        if not nearestbase then
            AIWarn('* AI-Uveso: ForceReturnToNavalBaseAIUveso no closest base found', true, UvesoOffsetPlatoonLUA)
            nearestbase = {}
            nearestbase.Pos = basePosition
        end
        local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer or 'Water' , self:GetPlatoonPosition(), nearestbase.Pos, 1000, 512)
        -- clear commands, so we don't get stuck if we have an unreachable destination
        IssueClearCommands(self:GetPlatoonUnits())
        if path then
            if table.getn(path) > 1 then
                --AILog('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: table.getn(path): '..table.getn(path))
            end
            --AILog('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: moving to destination by path.')
            for i=1, table.getn(path) do
                --AILog('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: moving to destination. i: '..i..' coords '..repr(path[i]))
                self:MoveToLocation(path[i], false)
                --AILog('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: moving to Waypoint')
                local PlatoonPosition
                local Lastdist
                local dist
                local Stuck = 0
                while aiBrain:PlatoonExists(self) do
                    while not aiBrain:IsOpponentAIRunning() do
                        coroutine.yield(10)
                    end
                    PlatoonPosition = self:GetPlatoonPosition()
                    dist = VDist2( path[i][1], path[i][3], PlatoonPosition[1], PlatoonPosition[3] )
                    -- are we closer then 20 units from the next marker ? Then break and move to the next marker
                    if dist < MarkerSwitchDist then
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
                            --AILog('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                            self:Stop()
                            break
                        end
                    end
                    coroutine.yield(10)
                end
            end
        else
            --AILog('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: we have no Graph to reach the destination. Checking CanPathTo()')
            if reason == 'NoGraph' then
                local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(self, basePosition)
                if success then
                    --AILog('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: found a way with CanPathTo(). moving to destination')
                    self:MoveToLocation(basePosition, false)
                else
                    --AILog('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: CanPathTo() failed for '..repr(basePosition)..'.')
                end
            end
        end
        local oldDist = 100000
        local platPos = self:GetPlatoonPosition() or basePosition
        local Stuck = 0
        while aiBrain:PlatoonExists(self) do
            while not aiBrain:IsOpponentAIRunning() do
                coroutine.yield(10)
            end
            self:MoveToLocation(nearestbase.Pos, false)
            --AILog('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: Waiting for moving to base')
            platPos = self:GetPlatoonPosition() or nearestbase.Pos
            dist = VDist2(platPos[1], platPos[3], nearestbase.Pos[1], nearestbase.Pos[3])
            if dist < 20 then
                --AILog('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: We are home! disband!')
                -- Wait some second, so all platoon units have time to reach the base.
                coroutine.yield(50)
                self:Stop()
                break
            end
            -- if we haven't moved in 5 seconds... leave the loop
            if oldDist - dist < 0 then
                break
            end
            oldDist = dist
            Stuck = Stuck + 1
            if Stuck > 4 then
                self:Stop()
                break
            end
            coroutine.yield(50)
        end
        -- Disband the platoon so the locationmanager can assign a new task to the units.
        coroutine.yield(30)
        self:PlatoonDisband()
    end,

    U3AntiNukeAI = function(self)
        local aiBrain = self:GetBrain()
        local platoonUnits
        while aiBrain:PlatoonExists(self) do
            platoonUnits = self:GetPlatoonUnits()
            -- find dead units inside the platoon and disband if we find one
            for k,unit in platoonUnits do
                if not unit or unit.Dead or unit:BeenDestroyed() then
                    -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                    -- needs PlatoonDisbandNoAssign, or launcher will stop building nukes if the platton is disbanded
                    self:PlatoonDisbandNoAssign()
                    --AILog('* AI-Uveso: * U3AntiNukeAI: PlatoonDisband')
                    return
                else
                    unit:SetAutoMode(true)
                end
            end
            coroutine.yield(50)
        end
    end,

    U34ArtilleryAI = function(self)
        local aiBrain = self:GetBrain()
        local realArtyTargetUnit, allArtyHaveTarget
        local x, y, z
        self:SetPrioritizedTargetList('Attack',
            {
                categories.COMMAND,
                categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.SHIELD - categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ECONOMIC * categories.ENERGYPRODUCTION * categories.MASSPRODUCTION * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ARTILLERY * (categories.TECH3 + categories.EXPERIMENTAL),
                categories.STRUCTURE * categories.ORBITALSYSTEM,
                categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * (categories.TECH3 + categories.EXPERIMENTAL),
                categories.STRUCTURE * categories.NUKE,
                categories.MOBILE * categories.EXPERIMENTAL - categories.AIR - categories.INSIGNIFICANTUNIT,
                categories.ALLUNITS
            }
        )
        while aiBrain:PlatoonExists(self) do
            while not aiBrain:IsOpponentAIRunning() do
                coroutine.yield(10)
            end
            coroutine.yield(20)
            if aiBrain.targets.artilleryTargets then
                for targetIndex, artyTarget in pairs(aiBrain.targets.artilleryTargets) do
                    if not artyTarget.underWater then
                        --AILog("* AI-Uveso: U34ArtilleryAI(): processing target["..targetIndex.."]: priority:"..artyTarget.priority.."  protectedByShield:"..artyTarget.protectedByShield.."  distToBase :"..math.floor(artyTarget.distToBase).."")
                        realArtyTargetUnit = aiBrain:GetUnitsAroundPoint(artyTarget.categories, artyTarget.pos, 1, 'Enemy')[1]
                        if realArtyTargetUnit and not realArtyTargetUnit.CaptureInProgress and not realArtyTargetUnit.ReclaimInProgress then
                            allArtyHaveTarget = true
                            for artyIndex, arty in pairs(self:GetPlatoonUnits()) do
                                if not arty.Dead then
                                    x, y, z = arty:GetPositionXYZ()
                                    distanceToArtillery = VDist2( x, z, artyTarget.pos[1], artyTarget.pos[3] )
                                    artilleryMinRange = arty.Blueprint.Weapon[1].MinRadius
                                    artilleryMaxRange = arty.Blueprint.Weapon[1].MaxRadius
                                    if not arty.Dead and distanceToArtillery > artilleryMinRange and distanceToArtillery < artilleryMaxRange then
                                    -- does the arty has a target ?
                                        if not arty.actualTarget or arty.actualTarget.Dead or GetGameTimeSeconds() - arty.lastTargetting > 60 then
                                            --AILog("* AI-Uveso: U34ArtilleryAI(): ["..artyIndex.."] attacking ["..targetIndex.."] ")
                                            IssueStop({arty})
                                            IssueClearCommands({arty})
                                            IssueAttack({arty}, realArtyTargetUnit)
                                            arty.actualTarget = realArtyTargetUnit
                                            arty.lastTargetting = GetGameTimeSeconds()
                                            allArtyHaveTarget = false
                                        end
                                    end
                                end
                            end
                            if allArtyHaveTarget then
                                break -- break for targetIndex, artyTarget in pairs(aiBrain.targets.artilleryTargets) do
                            end
                        end
                    end
                end
            end
        end
    end,

    U4SatelliteAI = function(self)
        local aiBrain = self:GetBrain()
        local satPos
        local realSatTargetUnit
        local targetAvailable
        local closestTarget
        local actualPriority
        local dist
        local closestTargetDist
        self:SetPrioritizedTargetList('Attack',
            {
                categories.COMMAND,
                categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.SHIELD - categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ECONOMIC * categories.ENERGYPRODUCTION * categories.MASSPRODUCTION * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ARTILLERY * (categories.TECH3 + categories.EXPERIMENTAL),
                categories.STRUCTURE * categories.ORBITALSYSTEM,
                categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * (categories.TECH3 + categories.EXPERIMENTAL),
                categories.STRUCTURE * categories.NUKE,
                categories.MOBILE * categories.EXPERIMENTAL - categories.AIR - categories.INSIGNIFICANTUNIT,
                categories.MOBILE * categories.ENGINEER - categories.COMMAND - categories.STATIONASSISTPOD,
                categories.STRUCTURE * categories.MASSEXTRACTION,
                categories.STRUCTURE * categories.FACTORY,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.ALLUNITS
            }
        )
        while aiBrain:PlatoonExists(self) do
            while not aiBrain:IsOpponentAIRunning() do
                coroutine.yield(10)
            end
            coroutine.yield(20)
            -- loop over every satellite and check if we need a new target, then attack it
            --AILog("* AI-Uveso: U4SatelliteAI(): *****************************************************************************************************")
            for satIndex, sat in pairs(self:GetPlatoonUnits()) do
                --AILog("* AI-Uveso: U4SatelliteAI(): [S:"..satIndex.."] search targets for sat "..satIndex)
                satPos = sat:GetPosition()
                -- is the satellite free for a new target? or retarget after 60 seconds.
                if not sat.actualTarget or sat.actualTarget.Dead or GetGameTimeSeconds() - sat.lastTargetting > 60 then
                    -- reset the target if its dead or time for a new target
                    sat.actualTarget = false
                    -- loop over all targets
                    for targetIndex, satTarget in pairs(aiBrain.targets.satelliteTargets) do
                        if not satTarget.underWater then
                            realSatTargetUnit = aiBrain:GetUnitsAroundPoint(satTarget.categories, satTarget.pos, 1, 'Enemy')[1]
                            if realSatTargetUnit and not realSatTargetUnit.CaptureInProgress and not realSatTargetUnit.ReclaimInProgress then
                                -- check if the (unshielded) target is already targeted by a sat
                                targetAvailable = true
                                if satTarget.protectedByShield < 1 or satTarget.priority < 50 then 
                                    for _, s in pairs(self:GetPlatoonUnits()) do
                                        if realSatTargetUnit == s.actualTarget then
                                            --AILog("* AI-Uveso: U4SatelliteAI(): [S:"..satIndex.."] unprotected target is already attacked by another satellite")
                                            targetAvailable = false
                                            break -- break for for i, s in pairs(self:GetPlatoonUnits()) do
                                        end
                                    end
                                end
                                -- target is free or has shields
                                closestTarget = false
                                if targetAvailable then
                                    -- if the target is protected by shields or if the target has high priority, attack it.
                                    if satTarget.protectedByShield >= 1 or satTarget.priority >= 50  then
                                        --AILog("* AI-Uveso: U4SatelliteAI(): [S:"..satIndex.."] protected target: priority: "..satTarget.priority.." - protectedByShield:"..satTarget.protectedByShield.." - shieldRadius: "..repr(satTarget.shieldRadius or 0).." - distToBase: "..math.floor(satTarget.distToBase).." - name: "..satTarget.name.."" )
                                        closestTarget = realSatTargetUnit
                                    else
                                        -- find the closest target for the satellite
                                        actualPriority = satTarget.priority
                                        --AILog("* AI-Uveso: U4SatelliteAI(): [S:"..satIndex.."] search for targets with the same actualPriority "..actualPriority)
                                        closestTargetDist = false
                                        for cI, cTarget in pairs(aiBrain.targets.satelliteTargets) do
                                            if not cTarget.underWater and cTarget.protectedByShield < 1 then
                                                -- has the target the same priority?
                                                if cTarget.priority == actualPriority then
                                                    -- check for the closest target
                                                    dist = VDist2(cTarget.pos[1], cTarget.pos[3], satPos[1], satPos[3])
                                                    if not closestTargetDist or dist < closestTargetDist then
                                                        realSatTargetUnit = aiBrain:GetUnitsAroundPoint(cTarget.categories, cTarget.pos, 1, 'Enemy')[1]
                                                        if realSatTargetUnit and not realSatTargetUnit.CaptureInProgress and not realSatTargetUnit.ReclaimInProgress then
                                                            -- check if the target is already attacked by an satellite
                                                            targetAvailable = true
                                                            for _, s in pairs(self:GetPlatoonUnits()) do
                                                                if realSatTargetUnit == s.actualTarget then
                                                                    --AILog("* AI-Uveso: U4SatelliteAI(): [S:"..satIndex.."] actualPriority target is already attacked by another satellite")
                                                                    targetAvailable = false
                                                                    break -- break for _, s in pairs(self:GetPlatoonUnits()) do
                                                                end
                                                            end
                                                            if targetAvailable then
                                                                --AILog("* AI-Uveso: U4SatelliteAI(): [S:"..satIndex.."] possible target: priority: "..cTarget.priority.." - protectedByShield:"..cTarget.protectedByShield.." - shieldRadius: "..repr(cTarget.shieldRadius or 0).." - distToSat: "..math.floor(dist).." - name: "..cTarget.name.."" )
                                                                closestTarget = realSatTargetUnit
                                                                closestTargetDist = dist
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end -- for cI, cTarget in pairs(aiBrain.targets.satelliteTargets) do
                                    end
                                end
                                --AILog("* AI-Uveso: U4SatelliteAI(): [S:"..satIndex.."] end searching for priority targets, actualPriority: "..actualPriority.." - dist:"..repr(closestTargetDist) )
                                if closestTarget then
                                    --AILog("* AI-Uveso: U4SatelliteAI(): [S:"..satIndex.."] attacking target:" )
                                    -- attack closestTarget
                                    IssueStop({sat})
                                    IssueClearCommands({sat})
                                    IssueAttack({sat}, closestTarget)
                                    sat.actualTarget = closestTarget
                                    sat.lastTargetting = GetGameTimeSeconds()
                                    break -- for targetIndex, satTarget in pairs(aiBrain.targets.satelliteTargets) do
                                end
                            end
                        end
                    end -- for targetIndex, satTarget in pairs(aiBrain.targets.satelliteTargets) do
                else
                    --AILog("* AI-Uveso: U4SatelliteAI(): [S:"..satIndex.."] Sat has already a target!")
                end -- if not sat.actualTarget
            end -- for satIndex, sat in pairs(self:GetPlatoonUnits()) do
            --AILog("* AI-Uveso: U4SatelliteAI(): -----------------------------------------------------------------------------------------------------")
        end
    end,

    ShieldRepairAI = function(self)
        local aiBrain = self:GetBrain()
        local BuilderManager = aiBrain.BuilderManagers['MAIN']
        local lastSHIELD = 0
        local lastSUB = 0
        local numSUB
        local SUBCOMs
        local platoonUnits
        local numAssisters
        local ShieldWithleastAssisters
        local shieldPos = ShieldWithleastAssisters:GetPosition() or nil
        local closest
        local bestUnit
        local unitPos
        local dist
        local Shields
        local lasthighestHealth
        local highestHealth
        local numSHIELD = 0

        while aiBrain:PlatoonExists(self) do
            platoonUnits = self:GetPlatoonUnits()
            numSUB = table.getn(platoonUnits) or 0
            Shields = AIUtils.GetOwnUnitsAroundPoint(aiBrain, categories.STRUCTURE * categories.SHIELD, BuilderManager.Position, 256)
            lasthighestHealth = false
            highestHealth = false
            numSHIELD = 0
            -- get the shield with the highest health
            for k,Shield in Shields do
                if not Shield or Shield.Dead then continue end
                if not highestHealth or Shield.MyShield:GetMaxHealth() > highestHealth then
                    highestHealth = Shield.MyShield:GetMaxHealth()
                end
                numSHIELD = numSHIELD + 1
            end
            for k,Shield in Shields do
                if not Shield or Shield.Dead then continue end
                if (not lasthighestHealth or Shield.MyShield:GetMaxHealth() > lasthighestHealth) and Shield.MyShield:GetMaxHealth() < highestHealth then
                    lasthighestHealth = Shield.MyShield:GetMaxHealth()
                end
            end
            if numSUB ~= lastSUB or numSHIELD ~= lastSHIELD then
                self:Stop()
                -- Wait for stopping assist
                coroutine.yield(1)
                lastSUB = numSUB
                lastSHIELD = numSHIELD
                for i,unit in self:GetPlatoonUnits() do
--                    IssueClearCommands({unit})
                    unit.AssistSet = nil
                    unit.UnitBeingAssist = nil
                end
                while aiBrain:PlatoonExists(self) do
                    while not aiBrain:IsOpponentAIRunning() do
                        coroutine.yield(10)
                    end
                    ShieldWithleastAssisters = false
                    -- get a shield with highest Health and lowest assistees
                    numAssisters = nil
                    -- Fist check all shields with the highest health
                    for k,Shield in Shields do
                        if not Shield or Shield.Dead or Shield.MyShield:GetMaxHealth() ~= highestHealth then continue end
                        if not numAssisters or table.getn(Shield:GetGuards()) < numAssisters  then
                            numAssisters = table.getn(Shield:GetGuards())
                            -- set a maximum of 10 assisters per shield
                            if numAssisters < 10 then
                                ShieldWithleastAssisters = Shield
                            end
                        end
                    end
                    -- If we have assister on all high shilds then spread the remaining SUBCOMs over lower shields
                    if not ShieldWithleastAssisters and lasthighestHealth and lasthighestHealth ~= highestHealth then
                        for k,Shield in Shields do
                            if not Shield or Shield.Dead or Shield.MyShield:GetMaxHealth() ~= lasthighestHealth then continue end
                            if not numAssisters or table.getn(Shield:GetGuards()) < numAssisters  then
                                numAssisters = table.getn(Shield:GetGuards())
                                ShieldWithleastAssisters = Shield
                            end
                        end
                    end
                    
                    if not ShieldWithleastAssisters then
                        --AILog('* AI-Uveso: *ShieldRepairAI: not ShieldWithleastAssisters. break!')
                        break
                    end
                    shieldPos = ShieldWithleastAssisters:GetPosition() or nil
                    -- search for the closest idle unit
                    closest = false
                    bestUnit = false
                    for i,unit in self:GetPlatoonUnits() do
                        if not unit or unit.Dead or unit:BeenDestroyed() then
                            self:PlatoonDisbandNoAssign()
                            return
                        end
                        if unit.AssistSet then continue end
                        unitPos = unit:GetPosition() or nil
                        if unitPos and shieldPos then
                            dist = VDist2(shieldPos[1], shieldPos[3], unitPos[1], unitPos[3])
                            if not closest or dist < closest then
                                closest = dist
                                bestUnit = unit
                            end
                        end
                    end
                    if not bestUnit then
                        --AILog('* AI-Uveso: *ShieldRepairAI: not bestUnit. break!')
                        break
                    end
                    IssueClearCommands({bestUnit})
                    coroutine.yield(1)
                    IssueGuard({bestUnit}, ShieldWithleastAssisters)
                    bestUnit.AssistSet = true
                    bestUnit.UnitBeingAssist = ShieldWithleastAssisters
                    coroutine.yield(1)
                end
            end
            coroutine.yield(30)
        end
    end,

    NukePlatoonAI = function(self)
        local aiBrain = self:GetBrain()
        local mapSizeX, mapSizeZ = GetMapSize()
        local platoonUnits
        local LauncherFull
        local LauncherReady
        local LauncherCount
        local EnemyAntiMissile
        local EnemyUnits
        local EnemyTargetPositions
        local MissileCount
        local EnemyTarget
        local NukeSiloAmmoCount
        local TargetPosition
        local realnukeTargetUnit
        local TargetPos
        local ToClose

        while aiBrain:PlatoonExists(self) do
            coroutine.yield(1)
            while not aiBrain:IsOpponentAIRunning() do
                coroutine.yield(10)
            end
            ---------------------------------------------------------------------------------------------------
            -- Count Launchers, set them to automode, count stored missiles
            ---------------------------------------------------------------------------------------------------
            LauncherFull = {}
            LauncherReady = {}
            HighMissileCountLauncherReady = {}
            MissileCount = 0
            LauncherCount = 0
            HighestMissileCount = 0
            NukeSiloAmmoCount = 0
            NukeLaunched = false
            coroutine.yield(100)
            platoonUnits = self:GetPlatoonUnits()
            AILog('* AI-Uveso: * NukePlatoonAI: While loop PULSE', NUKEDEBUG, UvesoOffsetPlatoonLUA)
            for _, Launcher in platoonUnits do
                -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                -- needs PlatoonDisbandNoAssign, or launcher will stop building nukes if the platton is disbanded
                if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                    self:PlatoonDisbandNoAssign()
                    return
                end
                Launcher:SetAutoMode(true)
                IssueClearCommands({Launcher})
                NukeSiloAmmoCount = Launcher:GetNukeSiloAmmoCount() or 0
                if not HighMissileCountLauncherReady.MissileCount or HighMissileCountLauncherReady.MissileCount < NukeSiloAmmoCount then
                    HighMissileCountLauncherReady = {Launcher}
                    HighMissileCountLauncherReady.MissileCount = NukeSiloAmmoCount
                end
                -- check if the launcher is full:
                local bp = Launcher:GetBlueprint()
                local weapon = bp.Weapon[1]
                local MaxLoad = weapon.MaxProjectileStorage or 5
                local WorkProgress = math.floor(Launcher:GetWorkProgress() * 100)
                AILog('* AI-Uveso: * NukePlatoonAI: launcher '.._..' can load '..MaxLoad..' missiles ( loaded: '..NukeSiloAmmoCount..' ) ( constructing: '..WorkProgress..'% )', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                if NukeSiloAmmoCount >= MaxLoad then
                    AILog('* AI-Uveso: * NukePlatoonAI: launcher can load '..MaxLoad..' missiles and has '..NukeSiloAmmoCount..' = FULL ', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                    table.insert(LauncherFull, Launcher)
                end
                if NukeSiloAmmoCount > 0 then
                    table.insert(LauncherReady, Launcher)
                    MissileCount = MissileCount + NukeSiloAmmoCount
                end
                LauncherCount = LauncherCount + 1
                -- count experimental launcher seraphim
            end
            EnemyAntiMissile = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * ((categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3) + (categories.SHIELD * categories.EXPERIMENTAL)), Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
            AILog('* AI-Uveso: ************************************************************************************************', NUKEDEBUG, UvesoOffsetPlatoonLUA)
            AILog('* AI-Uveso: * NukePlatoonAI: Checking for Targets. Launcher:('..LauncherCount..') Ready:('..table.getn(LauncherReady)..') Full:('..table.getn(LauncherFull)..') - Missiles:('..MissileCount..') - EnemyAntiMissile:('..table.getn(EnemyAntiMissile)..')', NUKEDEBUG, UvesoOffsetPlatoonLUA)
            -- Don't check all nuke functions if we have no missile.
            if LauncherCount < 1 or ( table.getn(LauncherReady) < 1 and table.getn(LauncherFull) < 1 ) then
                AILog('* AI-Uveso: * NukePlatoonAI: No launcher ready. Target search loop stoped', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                continue
            end
            ---------------------------------------------------------------------------------------------------
            -- Unprotected Target, launch a single nuke on primary targets.
            ---------------------------------------------------------------------------------------------------
            AILog('* AI-Uveso: * NukePlatoonAI: Unprotected Target ', NUKEDEBUG, UvesoOffsetPlatoonLUA)
            if aiBrain.targets.nukeTargets and table.getn(LauncherReady) > 0 then
                AILog("* AI-Uveso: * NukePlatoonAI(): LauncherReady > 0", NUKEDEBUG, UvesoOffsetPlatoonLUA)
                for _, nukeTarget in pairs(aiBrain.targets.nukeTargets) do
                    if nukeTarget.protectedBySMD == 0 then
                        AILog("* AI-Uveso: * NukePlatoonAI():["..nukeTarget.name.."] nuke targets: priority: "..nukeTarget.priority.." - protectedBySMD:"..nukeTarget.protectedBySMD.." - shieldRadius: "..repr(nukeTarget.shieldRadius or 0).." - name: "..nukeTarget.name.."", NUKEDEBUG, UvesoOffsetPlatoonLUA )
                        if nukeTarget.name ~= "EcoValue" then
                            realnukeTargetUnit = aiBrain:GetUnitsAroundPoint(nukeTarget.categories, nukeTarget.pos, 1, 'Enemy')[1]
                        else
                            realnukeTargetUnit = false
                        end
                        if (realnukeTargetUnit and not realnukeTargetUnit.Dead) or nukeTarget.name == "EcoValue" then
                            AILog("* AI-Uveso: * NukePlatoonAI():["..nukeTarget.name.."] Found a real target ("..repr(realnukeTargetUnit ~= nil)..") or EcoValue ("..repr(nukeTarget.name == "EcoValue")..")", NUKEDEBUG, UvesoOffsetPlatoonLUA)
                            -- Only shoot if the target is not protected by antimissile or experimental shields
                            if nukeTarget.name ~= "EcoValue" and EntityCategoryContains(categories.MOBILE * categories.EXPERIMENTAL, realnukeTargetUnit) then
                                -- Lead target function for moving units
                                AILog("* AI-Uveso: * NukePlatoonAI():["..nukeTarget.name.."] LeadNukeTarget", NUKEDEBUG, UvesoOffsetPlatoonLUA)
                                if HighMissileCountLauncherReady and not HighMissileCountLauncherReady.Dead then
                                    TargetPos = self:LeadNukeTarget(HighMissileCountLauncherReady, realnukeTargetUnit)
                                elseif table.getn(LauncherReady) > 0 then
                                    TargetPos = self:LeadNukeTarget(LauncherReady, realnukeTargetUnit)
                                end
                            else
                                AILog("* AI-Uveso: * NukePlatoonAI():["..nukeTarget.name.."] Unleaded NukeTarget", NUKEDEBUG, UvesoOffsetPlatoonLUA)
                                TargetPos = nukeTarget.pos
                            end
                            if TargetPos then
                                AILog("* AI-Uveso: * NukePlatoonAI():["..nukeTarget.name.."] TargetPos: ("..TargetPos[1]..", "..TargetPos[3]..")", NUKEDEBUG, UvesoOffsetPlatoonLUA)
                                -- Only shoot if we are not damaging our own structures
                                if aiBrain:GetNumUnitsAroundPoint(categories.STRUCTURE - categories.TECH1, TargetPos, 32 , 'Ally') <= 3 then
                                    AILog("* AI-Uveso: * NukePlatoonAI():["..nukeTarget.name.."] no friendly units in range.", NUKEDEBUG, UvesoOffsetPlatoonLUA)
                                    if self:NukeSingleAttack(HighMissileCountLauncherReady, TargetPos) then
                                        NukeLaunched = true
                                        AILog("* AI-Uveso: * NukePlatoonAI():["..nukeTarget.name.."] FIRE HighMissileCountLauncherReady: priority: "..nukeTarget.priority.." - name: "..nukeTarget.name.."" , NUKEDEBUG, UvesoOffsetPlatoonLUA)
                                    elseif self:NukeSingleAttack(LauncherReady, TargetPos) then
                                        NukeLaunched = true
                                        AILog("* AI-Uveso: * NukePlatoonAI():["..nukeTarget.name.."] FIRE LauncherReady: priority: "..nukeTarget.priority.." - name: "..nukeTarget.name.."", NUKEDEBUG, UvesoOffsetPlatoonLUA )
                                    else
                                        AILog("* AI-Uveso: * NukePlatoonAI():["..nukeTarget.name.."] Fn NukeSingleAttack did not fire! priority: "..nukeTarget.priority.." - name: "..nukeTarget.name.."", NUKEDEBUG, UvesoOffsetPlatoonLUA )
                                    end
                                else
                                    AILog("* AI-Uveso: * NukePlatoonAI():["..nukeTarget.name.."] Launcher cant fire; friendly units in range! cout: "..aiBrain:GetNumUnitsAroundPoint(categories.STRUCTURE - categories.TECH1, TargetPos, 32 , 'Ally'), NUKEDEBUG, UvesoOffsetPlatoonLUA)
                                end
                            else
                                AILog("* AI-Uveso: * NukePlatoonAI():["..nukeTarget.name.."] no TargetPos!", NUKEDEBUG, UvesoOffsetPlatoonLUA)
                            end
                        else
                            AIWarn("* AI-Uveso: * NukePlatoonAI():["..nukeTarget.name.."] No real target found", NUKEDEBUG, UvesoOffsetPlatoonLUA)
                        end
                        if NukeLaunched then
                            break
                        end
                    else
                        AILog("* AI-Uveso: * NukePlatoonAI():["..nukeTarget.name.."] is protected by SMD!", NUKEDEBUG, UvesoOffsetPlatoonLUA)
                        -- targets are sorted with unprotected targets first. If we get the first protected target then we don't need to continue
                        break
                    end
                end
            else
                AILog("* AI-Uveso: * NukePlatoonAI(): aiBrain.targets.nukeTargets = 0 or no launcher ready", NUKEDEBUG, UvesoOffsetPlatoonLUA)
            end
            ---------------------------------------------------------------------------------------------------
            -- Jericho! Check if we can attack multiple targets at the same time
            ---------------------------------------------------------------------------------------------------
            AILog('* AI-Uveso: * NukePlatoonAI: Jericho ', NUKEDEBUG, UvesoOffsetPlatoonLUA)
            if not NukeLaunched and aiBrain.targets.nukeTargets and table.getn(LauncherReady) > 0 then
                EnemyTargetPositions = {}
                AILog('* AI-Uveso: * NukePlatoonAI: (Jericho) Searching for EnemyTargetPositions', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                for _, nukeTarget in pairs(aiBrain.targets.nukeTargets) do
                    -- get position of the possible next target
                    ToClose = false
                    -- loop over all already attacked targets
                    for _, ETargetPosition in EnemyTargetPositions do
                        -- Check if the target is closer then 40 to an already attacked target
                        if VDist2(nukeTarget.pos[1],nukeTarget.pos[3],ETargetPosition[1],ETargetPosition[3]) < 40 then
                            ToClose = true
                            break -- break out of the EnemyTargetPositions loop
                        end
                    end
                    if not ToClose then
                        AILog('* AI-Uveso: * NukePlatoonAI: (Jericho) Adding Target "'..nukeTarget.name..'" to target list', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                        table.insert(EnemyTargetPositions, nukeTarget.pos)
                    else
                        AILog('* AI-Uveso: * NukePlatoonAI: (Jericho) Target to close to other target in list "'..nukeTarget.name..'"', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                    end
                end
                ---------------------------------------------------------------------------------------------------
                -- Now, if we have targets start Jericho bombardment
                ---------------------------------------------------------------------------------------------------
                AILog('* AI-Uveso: * NukePlatoonAI: (Jericho) Checking for Launcher:('..LauncherCount..') Ready:('..table.getn(LauncherReady)..') Full:('..table.getn(LauncherFull)..') - Missiles:('..MissileCount..') - Enemy Targets:('..table.getn(EnemyTargetPositions)..')', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                if EnemyTargetPositions[1] then
                    AILog('* AI-Uveso: * NukePlatoonAI: Jericho!', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                    -- loop over all targets
                    if self:NukeJerichoAttack(aiBrain, LauncherReady, EnemyTargetPositions) then
                        NukeLaunched = true
                    end
                end
            end
            ---------------------------------------------------------------------------------------------------
            -- Wait some seconds before we start the next missile
            ---------------------------------------------------------------------------------------------------
            if NukeLaunched == true then
                AIWarn('* AI-Uveso: * NukePlatoonAI: nuke launched, waiting for impact...', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                coroutine.yield(450)-- wait 45 seconds for the missile flight, then get new targets
                AIWarn('* AI-Uveso: * NukePlatoonAI: nuke should have reached the tearget, next loop.', NUKEDEBUG, UvesoOffsetPlatoonLUA)
            end
        end -- while aiBrain:PlatoonExists(self) do
        AIWarn('* AI-Uveso: * NukePlatoonAI: Function END', NUKEDEBUG, UvesoOffsetPlatoonLUA)
    end,
    
    LeadNukeTarget = function(self, launcher, target)
        if not launcher or launcher.Dead then
            return false
        end
        if not launcher.GetPosition then
            --AIWarn('* AI-Uveso: * LeadNukeTarget: launcher has no GetPosition() function ?!?', true, UvesoOffsetPlatoonLUA)
            --AIWarn(repr(launcher), true, UvesoOffsetPlatoonLUA)
            return false
        end
        local LauncherPos = launcher:GetPosition()
        local aiBrain = self:GetBrain()
        local TargetPos
        -- Get target position in 1 second intervals.
        -- This allows us to get speed and direction from the target
        local TargetStartPosition=0
        local Target1SecPos=0
        local Target2SecPos=0
        local XmovePerSec=0
        local YmovePerSec=0
        local XmovePerSecCheck=-1
        local YmovePerSecCheck=-1
        -- Check if the target is runing straight or circling
        -- If x/y and xcheck/ycheck are equal, we can be sure the target is moving straight
        -- in one direction. At least for the last 2 seconds.
        local LoopSaveGuard = 0
        AILog("* AI-Uveso: ** LeadNukeTarget(): START Loop", NUKEDEBUG, UvesoOffsetPlatoonLUA)
        while target and not target.Dead and (XmovePerSec ~= XmovePerSecCheck or YmovePerSec ~= YmovePerSecCheck) and LoopSaveGuard < 10 and aiBrain:PlatoonExists(self) do
            AILog("* AI-Uveso: ** LeadNukeTarget(): START Loop no:"..repr(LoopSaveGuard), NUKEDEBUG, UvesoOffsetPlatoonLUA)
            if not target or target.Dead then return false end
            -- 1st position of target
            TargetPos = target:GetPosition()
            TargetStartPosition = {TargetPos[1], 0, TargetPos[3]}
            coroutine.yield(10)
            -- 2nd position of target after 1 second
            TargetPos = target:GetPosition()
            Target1SecPos = {TargetPos[1], 0, TargetPos[3]}
            XmovePerSec = (TargetStartPosition[1] - Target1SecPos[1])
            YmovePerSec = (TargetStartPosition[3] - Target1SecPos[3])
            coroutine.yield(10)
            -- 3rd position of target after 2 seconds to verify straight movement
            TargetPos = target:GetPosition()
            Target2SecPos = {TargetPos[1], TargetPos[2], TargetPos[3]}
            XmovePerSecCheck = (Target1SecPos[1] - Target2SecPos[1])
            YmovePerSecCheck = (Target1SecPos[3] - Target2SecPos[3])
            --We leave the while-do check after 10 loops (20 seconds) and try collateral damage
            --This can happen if a player try to fool the targetingsystem by circling a unit.
            LoopSaveGuard = LoopSaveGuard + 1
        end
        if not target or target.Dead then
            AILog("* AI-Uveso: ** LeadNukeTarget(): not target or target.Dead", NUKEDEBUG, UvesoOffsetPlatoonLUA)
            return false
        end
        local NukeStart = 10
        local NukeLand = 5
        local FlightDistance = VDist2(LauncherPos[1], LauncherPos[3], TargetPos[1], TargetPos[3])
        local MissileImpactTime = NukeStart + NukeLand + FlightDistance / 30
        AILog("* AI-Uveso: ** LeadNukeTarget(): MissileImpactTime: "..MissileImpactTime, NUKEDEBUG, UvesoOffsetPlatoonLUA)
        -- Create missile impact corrdinates based on movePerSec * MissileImpactTime
        local MissileImpactX = Target2SecPos[1] - (XmovePerSec * MissileImpactTime)
        local MissileImpactY = Target2SecPos[3] - (YmovePerSec * MissileImpactTime)
        if LoopSaveGuard >=9 and TargetPos then
            AILog("* AI-Uveso: ** LeadNukeTarget(): LoopSaveGuard: "..repr(LoopSaveGuard), NUKEDEBUG, UvesoOffsetPlatoonLUA)
            return TargetPos
        end
        AILog('* AI-Uveso: ** LeadNukeTarget: TargetPos: ('..MissileImpactX..', '..MissileImpactY..')', NUKEDEBUG, UvesoOffsetPlatoonLUA)
        return {MissileImpactX, Target2SecPos[2], MissileImpactY}
    end,

    NukeSingleAttack = function(self, Launchers, EnemyTargetPosition)
        AILog('* AI-Uveso: ** NukeSingleAttack: Launcher count: '..table.getn(Launchers), NUKEDEBUG, UvesoOffsetPlatoonLUA)
        if table.getn(Launchers) <= 0 then
            AILog('* AI-Uveso: ** NukeSingleAttack: No Launcher ready.', NUKEDEBUG, UvesoOffsetPlatoonLUA)
            return false
        end
        -- loop over all nuke launcher
        for k, Launcher in Launchers do
            if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                -- needs PlatoonDisbandNoAssign, or launcher will stop building nukes if the platton is disbanded
                AILog('* AI-Uveso: ** NukeSingleAttack: Found destroyed launcher inside platoon. Disbanding...', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                self:PlatoonDisbandNoAssign()
                return
            end
            -- check if the target is closer then 20000
            LauncherPos = Launcher:GetPosition() or nil
            if not LauncherPos then
                AILog('* AI-Uveso: ** NukeSingleAttack: no Launcher Pos. Skiped', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                continue
            end
            if not EnemyTargetPosition then
                AILog('* AI-Uveso: ** NukeSingleAttack: no Target Pos. Skiped', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                continue
            end
            if VDist2(LauncherPos[1],LauncherPos[3],EnemyTargetPosition[1],EnemyTargetPosition[3]) > 20000 then
                AILog('* AI-Uveso: ** NukeSingleAttack: Target out of range. Skiped', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                -- Target is out of range, skip this launcher
                continue
            end
            -- Attack the target
            AILog('* AI-Uveso: ** NukeSingleAttack: Attacking Enemy Position! ('..EnemyTargetPosition[1]..', '..EnemyTargetPosition[3]..')', NUKEDEBUG, UvesoOffsetPlatoonLUA)
            IssueNuke({Launcher}, EnemyTargetPosition)
            -- stop seraching for available launchers and check the next target
            return true
        end
    end,

    NukeJerichoAttack = function(self, aiBrain, Launchers, EnemyTargetPositions)
        AILog('* AI-Uveso: ** NukeJerichoAttack: Launcher: '..table.getn(Launchers), NUKEDEBUG, UvesoOffsetPlatoonLUA)
        if table.getn(Launchers) <= 0 then
            AILog('* AI-Uveso: ** NukeSingleAttack: Launcher empty', NUKEDEBUG, UvesoOffsetPlatoonLUA)
            return false
        end
        local NukeLaunched = false
        for _, ActualTargetPos in EnemyTargetPositions do
            -- loop over all nuke launcher
            for k, Launcher in Launchers do
                if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                    -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                    -- needs PlatoonDisbandNoAssign, or launcher will stop building nukes if the platton is disbanded
                    AILog('* AI-Uveso: ** NukeJerichoAttack: Found destroyed launcher inside platoon. Disbanding...', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                    if aiBrain:PlatoonExists(self) then
                        self:PlatoonDisbandNoAssign()
                    end
                    return
                end
                -- check if the target is closer then 20000
                LauncherPos = Launcher:GetPosition() or nil
                if not LauncherPos then
                    AILog('* AI-Uveso: ** NukeJerichoAttack: no Launcher Pos. Skiped', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                    continue
                end
                if not ActualTargetPos then
                    AILog('* AI-Uveso: ** NukeJerichoAttack: no Target Pos. Skiped', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                    continue
                end
                if VDist2(LauncherPos[1],LauncherPos[3],ActualTargetPos[1],ActualTargetPos[3]) > 20000 then
                    AILog('* AI-Uveso: ** NukeJerichoAttack: Target out of range. Skiped', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                    -- Target is out of range, skip this launcher
                    continue
                end
                -- Attack the target
                AILog('* AI-Uveso: ** NukeJerichoAttack: Attacking Enemy Position!', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                IssueNuke({Launcher}, ActualTargetPos)
                NukeLaunched = true
                -- remove the launcher from the table, so it can't be used for the next target
                table.remove(Launchers, k)
                -- stop seraching for available launchers and check the next target
                break -- for k, Launcher in Launcher do
            end
            AILog('* AI-Uveso: ** NukeJerichoAttack: Launcher after shoot: '..table.getn(Launchers), NUKEDEBUG, UvesoOffsetPlatoonLUA)
            if table.getn(Launchers) < 1 then
                AILog('* AI-Uveso: ** NukeJerichoAttack: All Launchers are bussy! Break!', NUKEDEBUG, UvesoOffsetPlatoonLUA)
                -- stop seraching for targets, we don't hava a launcher ready.
                break -- for _, ActualTargetPos in EnemyTargetPositions do
            end
        end
        if table.getn(Launchers) >= 1 then
            AILog('* AI-Uveso: ** NukeJerichoAttack: Unused Launchers. Doing Jericho again...', NUKEDEBUG, UvesoOffsetPlatoonLUA)
            -- we have still launchers ready, let's do Jericho attack again!
            self:NukeJerichoAttack(aiBrain, Launchers, EnemyTargetPositions)
        end
        return NukeLaunched
    end,

    SACUTeleportAI = function(self)
        --AILog('* AI-Uveso: * SACUTeleportAI: Start ')
        -- SACU need to move out of the gate first
        coroutine.yield(50)
        local aiBrain = self:GetBrain()
        local platoonUnits
        local platoonPosition = self:GetPlatoonPosition()
        local TargetPosition
        AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        -- start upgrading all SubCommanders as teleporter
        while aiBrain:PlatoonExists(self) do
            while not aiBrain:IsOpponentAIRunning() do
                coroutine.yield(10)
            end
            local allEnhanced = true
            platoonUnits = self:GetPlatoonUnits()
            for k, unit in platoonUnits do
                IssueClearCommands({unit})
                coroutine.yield(1)
                if not unit.Dead then
                    for k, Assister in platoonUnits do
                        if not Assister.Dead and Assister ~= unit then
                            -- only assist if we have the energy for it
                            if aiBrain:GetEconomyTrend('ENERGY')*10 > 5000 or aiBrain.PriorityManager.HasParagon then
                                --AILog('* AI-Uveso: * SACUTeleportAI: IssueGuard({Assister}, unit) ')
                                IssueGuard({Assister}, unit)
                            end
                        end
                    end
                    self:BuildSACUEnhancements(unit)
                    coroutine.yield(1)
                    if not unit:HasEnhancement('Teleporter') then
                        --AILog('* AI-Uveso: * SACUTeleportAI: Not teleporter enhanced')
                        allEnhanced = false
                    else
                        --AILog('* AI-Uveso: * SACUTeleportAI: Has teleporter installed')
                    end
                end
            end
            if allEnhanced == true then
                --AILog('* AI-Uveso: * SACUTeleportAI: allEnhanced == true ')
                break
            end
            coroutine.yield(50)
        end
        --
        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                table.insert(MoveToCategories, v )
            end
        else
            --AILog('* AI-Uveso: * SACUTeleportAI: MoveToCategories missing in platoon '..self.BuilderName)
        end
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                table.insert(WeaponTargetCategories, v )
            end
        elseif self.PlatoonData.MoveToCategories then
            WeaponTargetCategories = MoveToCategories
        end
        self:SetPrioritizedTargetList('Attack', WeaponTargetCategories)
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        local maxRadius = self.PlatoonData.SearchRadius or 100
        -- search for a target
        local Target
        while not Target and aiBrain:PlatoonExists(self) do
            coroutine.yield(50)
            Target, _, _, _ = AIUtils.AIFindNearestCategoryTeleportLocation(aiBrain, platoonPosition, maxRadius, MoveToCategories, TargetSearchCategory, false)
        end
        platoonUnits = self:GetPlatoonUnits()
        if Target and not Target.Dead then
            TargetPosition = Target:GetPosition()
            for k, unit in platoonUnits do
                if not unit.Dead then
                    if not unit:HasEnhancement('Teleporter') then
                        --AIWarn('* AI-Uveso: * SACUTeleportAI: Unit has no transport enhancement!')
                        continue
                    end
                    coroutine.yield(2)
                    IssueTeleport({unit}, UUtils.RandomizePosition(TargetPosition))
                end
            end
        else
            --AILog('* AI-Uveso: SACUTeleportAI: No target, disbanding platoon!')
            self:PlatoonDisband()
            return
        end
        coroutine.yield(30)
        -- wait for the teleport of all unit
        local count = 0
        local UnitTeleporting = 0
        while aiBrain:PlatoonExists(self) do
            while not aiBrain:IsOpponentAIRunning() do
                coroutine.yield(10)
            end
            platoonUnits = self:GetPlatoonUnits()
            UnitTeleporting = 0
            for k, unit in platoonUnits do
                if not unit.Dead then
                    if unit:IsUnitState('Teleporting') then
                        UnitTeleporting = UnitTeleporting + 1
                    end
                end
            end
            --AILog('* AI-Uveso: SACUTeleportAI: Units Teleporting :'..UnitTeleporting )
            if UnitTeleporting == 0 then
                break
            end
            coroutine.yield(10)
        end        
        -- Fight
        coroutine.yield(1)
        for k, unit in platoonUnits do
            if not unit.Dead then
                IssueClearCommands({unit})
                coroutine.yield(2)
                IssueMove({unit}, TargetPosition)
            end
        end
        coroutine.yield(50)
        self:HeroFightPlatoon()
        if aiBrain:PlatoonExists(self) then
            self:PlatoonDisband()
        end
    end,

    BuildSACUEnhancements = function(platoon,unit)
        local EnhancementsByUnitID = {
            -- UEF
            ['uel0301'] = {'ResourceAllocation', 'AdvancedCoolingUpgrade'},
            -- Aeon
            ['ual0301'] = {'StabilitySuppressant', 'Teleporter'},
            -- Cybram
            ['url0301'] = {'ResourceAllocation', 'EMPCharge'},
            -- Seraphim
            ['xsl0301'] = {'DamageStabilization', 'Shield', 'Teleporter'},
            -- Nomads
            ['xnl0301'] = {'ResourceAllocation'},
        }
        local CRDBlueprint = unit:GetBlueprint()
        --AILog('* AI-Uveso: BlueprintId RAW:'..repr(CRDBlueprint.BlueprintId))
        --AILog('* AI-Uveso: BlueprintId clean: '..repr(string.gsub(CRDBlueprint.BlueprintId, "(%a+)(%d+)_(%a+)", "%1".."%2")))
        local ACUUpgradeList = EnhancementsByUnitID[string.gsub(CRDBlueprint.BlueprintId, "(%a+)(%d+)_(%a+)", "%1".."%2")]
        --AILog('* AI-Uveso: ACUUpgradeList '..repr(ACUUpgradeList))
        local NextEnhancement = false
        local HaveEcoForEnhancement = false
        for _,enhancement in ACUUpgradeList or {} do
            local wantedEnhancementBP = CRDBlueprint.Enhancements[enhancement]
            --AILog('* AI-Uveso: wantedEnhancementBP '..repr(wantedEnhancementBP))
            if not wantedEnhancementBP then
                AIDebug('* AI-Uveso: BuildSACUEnhancements: no enhancement found for ('..string.gsub(CRDBlueprint.BlueprintId, "(%a+)(%d+)_(%a+)", "%1".."%2")..') = '..repr(enhancement), true, UvesoOffsetPlatoonLUA)
            elseif unit:HasEnhancement(enhancement) then
                NextEnhancement = false
                --AILog('* AI-Uveso: * ACUAttackAIUveso: BuildSACUEnhancements: Enhancement is already installed: '..enhancement)
            elseif platoon:EcoGoodForUpgrade(unit, wantedEnhancementBP) then
                --AILog('* AI-Uveso: * ACUAttackAIUveso: BuildSACUEnhancements: Eco is good for '..enhancement)
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = true
                    --AILog('* AI-Uveso: * ACUAttackAIUveso: *** Set as Enhancememnt: '..NextEnhancement)
                end
            else
                --AILog('* AI-Uveso: * ACUAttackAIUveso: BuildSACUEnhancements: Eco is bad for '..enhancement)
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = false
                    -- if we don't have the eco for this ugrade, stop the search
                    --AILog('* AI-Uveso: * ACUAttackAIUveso: canceled search. no eco available')
                end
            end
        end
        if NextEnhancement and HaveEcoForEnhancement then
            --AILog('* AI-Uveso: * ACUAttackAIUveso: BuildSACUEnhancements Building '..NextEnhancement)
            if platoon:BuildEnhancement(unit, NextEnhancement) then
                --AILog('* AI-Uveso: * ACUAttackAIUveso: BuildSACUEnhancements returned true'..NextEnhancement)
            else
                --AILog('* AI-Uveso: * ACUAttackAIUveso: BuildSACUEnhancements returned false'..NextEnhancement)
            end
            return
        end
        --AILog('* AI-Uveso: * ACUAttackAIUveso: BuildSACUEnhancements returned false')
        return
    end,

    RenamePlatoon = function(self, text)
        for k, v in self:GetPlatoonUnits() do
            if v and not v.Dead then
                v:SetCustomName(text..' '..math.floor(GetGameTimeSeconds()))
            end
        end
    end,

    AirSuicideAI = function(self)
        --AILog('* AI-Uveso: *AirSuicideAI: START')
        AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        local aiBrain = self:GetBrain()
        -- Search all platoon units and activate Stealth and Cloak (mostly Modded units)
        local platoonUnits = self:GetPlatoonUnits()
        local PlatoonStrength = table.getn(platoonUnits)
        if platoonUnits and PlatoonStrength > 0 then
            for k, v in platoonUnits do
                if not v.Dead then
                    if v:TestToggleCaps('RULEUTC_StealthToggle') then
                        --AILog('* AI-Uveso: * AirSuicideAI: Switching RULEUTC_StealthToggle')
                        v:SetScriptBit('RULEUTC_StealthToggle', false)
                    end
                    if v:TestToggleCaps('RULEUTC_CloakToggle') then
                        --AILog('* AI-Uveso: * AirSuicideAI: Switching RULEUTC_CloakToggle')
                        v:SetScriptBit('RULEUTC_CloakToggle', false)
                    end
                    -- prevent units from reclaiming while attack moving
                    v:RemoveCommandCap('RULEUCC_Reclaim')
                    v:RemoveCommandCap('RULEUCC_Repair')
                end
            end
        end
        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                table.insert(MoveToCategories, v )
            end
        else
            --AILog('* AI-Uveso: * AirSuicideAI: MoveToCategories missing in platoon '..self.BuilderName)
        end
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                table.insert(WeaponTargetCategories, v )
            end
        elseif self.PlatoonData.MoveToCategories then
            WeaponTargetCategories = MoveToCategories
        end
        self:SetPrioritizedTargetList('Attack', WeaponTargetCategories)
        local target
        local bAggroMove = self.PlatoonData.AggressiveMove
        local path
        local reason
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
        local GetTargetsFromBase = self.PlatoonData.GetTargetsFromBase
        local GetTargetsFrom = basePosition
        local LastTargetCheck
        local DistanceToBase = 0
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        local UnitWithPath, UnitNoPath, path, reason
        while aiBrain:PlatoonExists(self) do
            while not aiBrain:IsOpponentAIRunning() do
                coroutine.yield(10)
            end
            PlatoonPos = self:GetPlatoonPosition()
            if not GetTargetsFromBase then
                GetTargetsFrom = PlatoonPos
            else
                DistanceToBase = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
                if DistanceToBase > maxRadius then
                    target = nil
                end
            end
            -- only get a new target and make a move command if the target is dead
            if not target or target.Dead or target:BeenDestroyed() then
                UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRange(aiBrain, self, 'Attack', GetTargetsFrom, maxRadius, MoveToCategories, TargetSearchCategory, false )
                if UnitWithPath then
                    --AILog('* AI-Uveso: *AirSuicideAI: found UnitWithPath')
                    self:Stop()
                    target = UnitWithPath
                    LastTargetPos = target:GetPosition()
                    if LastTargetPos then
                        self:MoveToLocation(LastTargetPos, false)
                        self.AirSuicideTargetPos = LastTargetPos
                    end
                elseif UnitNoPath then
                    --AILog('* AI-Uveso: *AirSuicideAI: found UnitNoPath')
                    self:Stop()
                    target = UnitNoPath
                    LastTargetPos = target:GetPosition()
                    if LastTargetPos then
                        self:MoveToLocation(LastTargetPos, false)
                        self.AirSuicideTargetPos = LastTargetPos
                    end
                else
                    --AILog('* AI-Uveso: *AirSuicideAI: no target found '..repr(reason))
                    -- we have no target return to main base
                    self:Stop()
                    if self.MovementLayer == 'Air' then
                        if VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0) > 30 then
                            --AILog('* AI-Uveso: *AirSuicideAI: moving to base ')
                            self:MoveToLocation(basePosition, false)
                        else
                            -- we are at home and we don't have a target. Disband!
                            if aiBrain:PlatoonExists(self) then
                                --AILog('* AI-Uveso: *AirSuicideAI: Disbanding platoon')
                                self:PlatoonDisband()
                                return
                            end
                        end
                    else
                        self:SimpleReturnToBase(basePosition)
                    end
                end
            -- targed exists and is not dead
            end
            coroutine.yield(1)
            -- force all units inside the platoon to move to the target
            for k, v in platoonUnits do
                if self.AirSuicideTargetPos then
                    IssueMove({v}, self.AirSuicideTargetPos)
                end
            end

            local LastPlatoonPos = false
            local CrashFlightDistance
            while aiBrain:PlatoonExists(self) and self.AirSuicideTargetPos do
                while not aiBrain:IsOpponentAIRunning() do
                    coroutine.yield(10)
                end
                PlatoonPos = self:GetPlatoonPosition()
                CrashFlightDistance = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, self.AirSuicideTargetPos[1] or 0, self.AirSuicideTargetPos[3] or 0)
                if CrashFlightDistance <= 100 then
                    local FlightElevation
                    local unitpos
                    while aiBrain:PlatoonExists(self) do
                        for k, v in platoonUnits do
                            unitpos = v:GetPosition()
                            if v.FlightElevation then
                                FlightElevation = v.FlightElevation
                            else
                                FlightElevation = v:GetBlueprint().Physics.Elevation
                                v.FlightElevation = FlightElevation
                            end
                            CrashFlightDistance = VDist2(unitpos[1] or 0, unitpos[3] or 0, self.AirSuicideTargetPos[1] or 0, self.AirSuicideTargetPos[3] or 0)
                            --AILog('* AI-Uveso: *AirSuicideAI: CrashFlightDistance: '..CrashFlightDistance)
                            if CrashFlightDistance/5 <= FlightElevation then
                                v:SetElevation(CrashFlightDistance/5)
                                if CrashFlightDistance < 2 then
                                    v:Kill()
                                end
                            end
                        end
                        coroutine.yield(1)
                    end

                end
                coroutine.yield(1)
            end
        end
    end,

    HeroFightPlatoon = function(self)
        local aiBrain = self:GetBrain()
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')

        -- this will set self.MovementLayer to the platoon
        AIAttackUtils.GetMostRestrictiveLayer(self)

        -- get categories where we want to move this platoon - (primary platoon targets)
        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                table.insert(MoveToCategories, v )
            end
        else
            AILog('* AI-Uveso: * HeroFightPlatoon: MoveToCategories missing in platoon '..self.BuilderName, true, UvesoOffsetPlatoonLUA)
        end

        -- get categories at what we want a unit to shoot at - (primary unit targets)
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                table.insert(WeaponTargetCategories, v )
            end
        elseif self.PlatoonData.MoveToCategories then
            WeaponTargetCategories = MoveToCategories
        end
        self:SetPrioritizedTargetList('Attack', WeaponTargetCategories)

        -- calcuate maximum weapon range for every unit inside this platoon
        -- also switch on things like stealth and cloak
        local MaxPlatoonWeaponRange
        local ExperimentalInPlatoon = false
        local UnitBlueprint
        local YawMin = 0
        local YawMax = 0
        local TargetHug = self.PlatoonData.TargetHug
        local HasMainRearWeapon
        for _, unit in self:GetPlatoonUnits() do
            -- continue with the next unit if this unit is dead
            if unit.Dead then continue end
            UnitBlueprint = unit:GetBlueprint()
            -- remove INSIGNIFICANTUNIT units from the platoon (drones, buildbots etc)
            if UnitBlueprint.CategoriesHash.INSIGNIFICANTUNIT then
                --AIDebug('* AI-Uveso: HeroFightPlatoon: -- unit ['..repr(unit.UnitId)..'] is a INSIGNIFICANTUNIT.  Removing from platoon...  - '..repr( unit:GetBlueprint().General.UnitName or "Unknown" )..' ('..repr( unit:GetBlueprint().Description or "Unknown" )..'')
                aiBrain:AssignUnitsToPlatoon(pool, {unit}, 'Unassigned', 'None')
                continue
            end
            -- remove POD units from the platoon
            if UnitBlueprint.CategoriesHash.POD then
                --AIDebug('* AI-Uveso: HeroFightPlatoon: -- unit ['..repr(unit.UnitId)..'] is a POD UNIT.  Removing from platoon...  - '..repr( unit:GetBlueprint().General.UnitName or "Unknown" )..' ('..repr( unit:GetBlueprint().Description or "Unknown" )..'')
                aiBrain:AssignUnitsToPlatoon(pool, {unit}, 'Unassigned', 'None')
                continue
            end
            -- remove DRONE units from the platoon
            if UnitBlueprint.CategoriesHash.DRONE then
                --AIDebug('* AI-Uveso: HeroFightPlatoon: -- unit ['..repr(unit.UnitId)..'] is a DRONE UNIT.  Removing from platoon...  - '..repr( unit:GetBlueprint().General.UnitName or "Unknown" )..' ('..repr( unit:GetBlueprint().Description or "Unknown" )..'')
                aiBrain:AssignUnitsToPlatoon(pool, {unit}, 'Unassigned', 'None')
                continue
            end
            -- remove OPERATION units from the platoon
            if UnitBlueprint.CategoriesHash.OPERATION then
                --AIDebug('* AI-Uveso: HeroFightPlatoon: -- unit ['..repr(unit.UnitId)..'] is a OPERATION UNIT.  Removing from platoon...  - '..repr( unit:GetBlueprint().General.UnitName or "Unknown" )..' ('..repr( unit:GetBlueprint().Description or "Unknown" )..'')
                aiBrain:AssignUnitsToPlatoon(pool, {unit}, 'Unassigned', 'None')
                continue
            end
            -- Seraphim land Experimentals should always move close to the target
            if UnitBlueprint.CategoriesHash.EXPERIMENTAL and UnitBlueprint.CategoriesHash.SERAPHIM and UnitBlueprint.CategoriesHash.LAND then
                TargetHug = true
            end
            -- get the maximum weapopn range of this unit
            for _, weapon in UnitBlueprint.Weapon or {} do
                -- filter dummy weapons
                if weapon.Damage < 1 or weapon.MaxRadius < 1 then
                    continue
                end
                -- filter anti air weapons if we have a land platoon
                if self.MovementLayer == "Land" then
                    if weapon.WeaponCategory == 'Anti Air' then
                        --AIWarn("* AI-Uveso: HeroFightPlatoon: -- Land unit ["..repr(unit.UnitId).."] ignoring AntiAir Weapon "..repr(weapon.DisplayName))
                        continue
                    end
                end
                HasMainRearWeapon = false
                if UnitBlueprint.CategoriesHash.EXPERIMENTAL and UnitBlueprint.Physics.StandUpright then
                    -- for Experiemtnals with 2 legs
                    unit.HasMainRearWeapon = false
                elseif not unit.HasMainRearWeapon then
                    -- check weapon angle    pitch ^    yaw >
                    YawMin = false
                    YawMax = false
                    if weapon.HeadingArcCenter and weapon.HeadingArcRange then
                        if weapon.TurretYaw and weapon.TurretYawRange then
                            YawMin = weapon.HeadingArcCenter + weapon.TurretYaw - weapon.TurretYawRange
                            YawMax = weapon.HeadingArcCenter + weapon.TurretYaw + weapon.HeadingArcRange
                        else
                            YawMin = weapon.HeadingArcCenter - weapon.HeadingArcRange
                            YawMax = weapon.HeadingArcCenter + weapon.HeadingArcRange
                        end
                    elseif weapon.TurretYaw and weapon.TurretYawRange then
                        YawMin = weapon.TurretYaw - weapon.TurretYawRange
                        YawMax = weapon.TurretYaw + weapon.TurretYawRange
                    end
                    if YawMin and YawMax then
                        -- front unit side
                        if YawMin <= -180 and YawMax >= 180 then
                            --AILog('* AI-Uveso: Unit ['..unit.UnitId..'] can fire 360° front')
                            HasMainRearWeapon = true
                        end
                        -- left unit side
                        if YawMin <= -225 and YawMax >= -135 then
                            --AILog('* AI-Uveso: Unit ['..unit.UnitId..'] can fire 90° rear (left)')
                            HasMainRearWeapon = true
                        end
                        -- right unit side
                        if YawMin <= 135 and YawMax >= 225 then
                            --AILog('* AI-Uveso: Unit ['..unit.UnitId..'] can fire 90° rear (right)')
                            HasMainRearWeapon = true
                        end
                        -- back unit side
                        if YawMin <= -202.5 and YawMax >= 202.5 then
                            --AILog('* AI-Uveso: Unit ['..unit.UnitId..'] can fire 45° rear')
                            HasMainRearWeapon = true
                        end
                    end
                end
               
                -- unit can have MainWeaponDamage entry from the last platoon
                if not unit.MainWeaponDamage or weapon.Damage >= unit.MainWeaponDamage then
                    -- use the range from the biggest weapon
                    unit.MainWeaponDamage = weapon.Damage
                    if HasMainRearWeapon then
                        unit.HasMainRearWeapon = HasMainRearWeapon
                    end
                    -- exclude missiles
                    if weapon.WeaponCategory ~= 'Missile' then
                        -- save the weaponrange 
                        unit.MaxWeaponRange = weapon.MaxRadius * 0.9 -- maxrange minus 10%
                        -- save the weapon balistic arc, we need this later to check if terrain is blocking the weapon line of sight
                        if weapon.BallisticArc == 'RULEUBA_LowArc' then
                            unit.WeaponArc = 'low'
                        elseif weapon.BallisticArc == 'RULEUBA_HighArc' then
                            unit.WeaponArc = 'high'
                        else
                            unit.WeaponArc = 'none'
                        end
                        -- check for the overall range of the platoon
                        if not MaxPlatoonWeaponRange or MaxPlatoonWeaponRange > unit.MaxWeaponRange then
                            MaxPlatoonWeaponRange = unit.MaxWeaponRange
                        end
                    else
                        -- save a backup weapon in case we have only missiles or longrange weapons
                        unit.MaxWeaponRangeBackup = weapon.MaxRadius * 0.9 -- maxrange minus 10%
                        if weapon.BallisticArc == 'RULEUBA_LowArc' then
                            unit.WeaponArcBackup = 'low'
                        elseif weapon.BallisticArc == 'RULEUBA_HighArc' then
                            unit.WeaponArcBackup = 'high'
                        else
                            unit.WeaponArcBackup = 'none'
                        end
                    end
                end
            end
            -- in case we have not a normal weapons, use the backupweapon if available
            if not unit.MaxWeaponRange and unit.MaxWeaponRangeBackup then
                unit.MaxWeaponRange = unit.MaxWeaponRangeBackup
                unit.WeaponArc = unit.WeaponArcBackup
            end
            -- Search all platoon units and activate Stealth and Cloak (mostly Modded units)
            if unit:TestToggleCaps('RULEUTC_StealthToggle') then
                unit:SetScriptBit('RULEUTC_StealthToggle', false)
            end
            if unit:TestToggleCaps('RULEUTC_CloakToggle') then
                unit:SetScriptBit('RULEUTC_CloakToggle', false)
            end
            -- search if we have an experimental inside the platoon so we can't use transports
            if not ExperimentalInPlatoon and EntityCategoryContains(categories.EXPERIMENTAL, unit) then
                ExperimentalInPlatoon = true
            end
            -- ToDo: prevent units from reclaiming while attack moving (maybe not working !?!)
            unit:RemoveCommandCap('RULEUCC_Reclaim')
            unit:RemoveCommandCap('RULEUCC_Repair')
            -- create a table for individual unit position
            unit.smartPos = {0,0,0}
            unit.UnitMassCost = UnitBlueprint.Economy.BuildCostMass
            -- we have no weapon; check if we have a shield, stealth field or cloak field
            if not unit.MaxWeaponRange then
                -- does the unit has no weapon but a shield ?
                if UnitBlueprint.CategoriesHash.SHIELD then
                    --AILog('* AI-Uveso: Scanning: unit ['..repr(unit.UnitId)..'] Is a IsShieldOnlyUnit')
                    unit.IsShieldOnlyUnit = true
                end
                if UnitBlueprint.Intel.RadarStealthField then
                    --AILog('* AI-Uveso: Scanning: unit ['..repr(unit.UnitId)..'] Is a RadarStealthField Unit')
                    unit.IsShieldOnlyUnit = true
                end
                if UnitBlueprint.Intel.CloakField then
                    --AILog('* AI-Uveso: Scanning: unit ['..repr(unit.UnitId)..'] Is a CloakField Unit')
                    unit.IsShieldOnlyUnit = true
                end
                if UnitBlueprint.CategoriesHash.ANTIAIR then
                    --AILog('* AI-Uveso: Scanning: unit ['..repr(unit.UnitId)..'] Is a IsShieldOnlyUnit')
                    unit.IsShieldOnlyUnit = true
                end
            end
            -- debug for modded units that have no weapon and no shield or stealth/cloak
            -- things like seraphim restauration field
            if not unit.MaxWeaponRange and not unit.IsShieldOnlyUnit then
                AIWarn('* AI-Uveso: Scanning: unit ['..repr(unit.UnitId)..'] has no MaxWeaponRange and no stealth/cloak - '..repr(self.BuilderName))
                -- Don't know what to do with this unit, lets move it behind the platoon
                unit.IsShieldOnlyUnit = true
            end
            unit.IamLost = 0
        end
        if not MaxPlatoonWeaponRange then
            if aiBrain:PlatoonExists(self) then
                self:PlatoonDisband()
            end
            return
        end
        
        -- we only see targets from this targetcategories.
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory
        if not TargetSearchCategory then
            AIWarn('* AI-Uveso: Missing TargetSearchCategory in builder: '..repr(self.BuilderName), true, UvesoOffsetPlatoonLUA)
            TargetSearchCategory = categories.ALLUNITS
        end
        -- additional variables we need inside the platoon loop
        local TargetInPlatoonRange
        local target
        local TargetPos
        local LastTargetPos
        local UnitWithPath
        local UnitNoPath
        local path
        local reason
        local unitPos
        local alpha
        local x
        local y
        local smartPos = {}
        local UnitToCover = nil
        local CoverIndex = 0
        local UnitMassCost = {}
        local maxRadius = self.PlatoonData.SearchRadius or 100
        local WantsTransport = self.PlatoonData.RequireTransport
        local GetTargetsFromBase = self.PlatoonData.GetTargetsFromBase
        local DirectMoveEnemyBase = self.PlatoonData.DirectMoveEnemyBase
        local NoTargetChange = self.PlatoonData.NoTargetChange
        local basePosition
        local PlatoonCenterPosition = self:GetPlatoonPosition()
        local bAggroMove = self.PlatoonData.AggressiveMove
        if TargetHug then
            bAggroMove = false
        end
        if self.MovementLayer == 'Water' then
            -- we could search for the nearest naval base here, but buildposition is almost at the same location
            basePosition = PlatoonCenterPosition
        else
            -- land and air units are assigned to mainbase
            basePosition = aiBrain.BuilderManagers['MAIN'].Position
        end
        local GetTargetsFrom = basePosition
        if DirectMoveEnemyBase then
            local ClosestEnemyBaseDistance
            local ClosestEnemyBaseLocation
            for index, brain in ArmyBrains do
                if brain.BuilderManagers['MAIN'] then
                    if brain.BuilderManagers['MAIN'].FactoryManager.Location then
                        local Baselocation = aiBrain.BuilderManagers['MAIN'].Position
                        local EnemyBaseLocation = brain.BuilderManagers['MAIN'].Position
                        local dist = VDist2( Baselocation[1], Baselocation[3], EnemyBaseLocation[1], EnemyBaseLocation[3] )
                        if dist < 10 then continue end
                        if not ClosestEnemyBaseDistance or ClosestEnemyBaseDistance > dist then
                            ClosestEnemyBaseLocation = EnemyBaseLocation
                            ClosestEnemyBaseDistance = dist
                        end
                    end
                end
            end
            if ClosestEnemyBaseLocation then
                GetTargetsFrom = ClosestEnemyBaseLocation
            end
        end
        -- platoon loop
        --self:RenamePlatoon('MAIN loop')
        while aiBrain:PlatoonExists(self) do
            while not aiBrain:IsOpponentAIRunning() do
                coroutine.yield(10)
            end
            -- remove the Blocked flag from all unts. (at this point we don't have a target or the target is dead or we clean a leftover from the last platoon call)
            for _, unit in self:GetPlatoonUnits() or {} do
                unit.Blocked = false
            end
            -- wait a bit here, so continue commands can't deadloop/freeze the game
            coroutine.yield(3)
            if self.UsingTransport then
                continue
            end
            PlatoonCenterPosition = self:GetPlatoonPosition()
            if not PlatoonCenterPosition[1] then
                if aiBrain:PlatoonExists(self) then
                    self:PlatoonDisband()
                end
                return
            end
            -- set target search center position
            if not GetTargetsFromBase then
                GetTargetsFrom = PlatoonCenterPosition
            end
            -- Search for a target (don't remove the :BeenDestroyed() call!)
            if not target or target.Dead or target:BeenDestroyed() then
                -- if we have amphibious units, try first a land path, so we don't need to go under water
                if self.MovementLayer == "Amphibious" then
                    -- set platoon to land layer
                    self.MovementLayer = "Land"
                    -- search for a land path
                    UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRange(aiBrain, self, 'Attack', GetTargetsFrom, maxRadius, MoveToCategories, TargetSearchCategory, false )
                    -- reset platoon to amphibious layer
                    self.MovementLayer = "Amphibious"
                else
                    UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRange(aiBrain, self, 'Attack', GetTargetsFrom, maxRadius, MoveToCategories, TargetSearchCategory, false )
                end
                target = UnitWithPath or UnitNoPath
            end
            -- remove target, if we are out of base range
            DistanceToBase = VDist2(PlatoonCenterPosition[1] or 0, PlatoonCenterPosition[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
            if GetTargetsFromBase and DistanceToBase > maxRadius then
                target = nil
                path = nil
                if HERODEBUG then
                    self:RenamePlatoon('target to far from base')
                    coroutine.yield(10)
                end
           end
            -- check if the platoon died while the targetting function was searching for targets
            if not aiBrain:PlatoonExists(self) then
                return
            end
            -- move to the target
            if target and not target.Dead and not target:BeenDestroyed() then
                LastTargetPos = table.copy(target:GetPosition())
                -- are we outside weaponrange ? then move to the target
                if VDist2( PlatoonCenterPosition[1], PlatoonCenterPosition[3], LastTargetPos[1], LastTargetPos[3] ) > MaxPlatoonWeaponRange then
                    --self:RenamePlatoon('move to target -> out of weapon range')
                    -- if we have a path then use the waypoints 
                    if UnitWithPath and path and not self.PlatoonData.IgnorePathing then
                        --self:RenamePlatoon('move to target -> with waypoints')
                        -- move to the target with waypoints
                        if self.MovementLayer == 'Air' then
                            if HERODEBUG then
                                self:RenamePlatoon('MovePath (Air)')
                                coroutine.yield(10)
                            end
                            self:MovePath(aiBrain, path, bAggroMove, target, MaxPlatoonWeaponRange, categories.ALLUNITS - categories.AIR, ExperimentalInPlatoon)
                        elseif self.MovementLayer == 'Water' then
                            if HERODEBUG then
                                self:RenamePlatoon('MovePath (Water)')
                                coroutine.yield(10)
                            end
                            self:MovePath(aiBrain, path, bAggroMove, target, MaxPlatoonWeaponRange, categories.ALLUNITS - categories.AIR, ExperimentalInPlatoon)
                        else
                            if HERODEBUG then
                                self:RenamePlatoon('MovePath with transporter layer('..self.MovementLayer..')')
                                coroutine.yield(10)
                            end
                            self:MoveToLocationInclTransport(target, LastTargetPos, bAggroMove, WantsTransport, basePosition, ExperimentalInPlatoon, MaxPlatoonWeaponRange, categories.ALLUNITS - categories.AIR, path, reason)
                        end
                    -- if we don't have a path, but UnitWithPath is true, then we have no map markers but PathCanTo() found a direct path
                    elseif UnitWithPath then
                        --self:RenamePlatoon('move to target -> without waypoints')
                        -- move to the target without waypoints
                        if self.MovementLayer == 'Air' then
                            if HERODEBUG then
                                self:RenamePlatoon('UWP MoveDirect (Air)')
                                coroutine.yield(10)
                            end
                                self:MoveDirect(aiBrain, bAggroMove, target, MaxPlatoonWeaponRange, categories.ALLUNITS - categories.AIR)
                        elseif self.MovementLayer == 'Water' then
                            if HERODEBUG then
                                self:RenamePlatoon('UWP MoveDirect (Water)')
                                coroutine.yield(10)
                            end
                            self:MoveDirect(aiBrain, bAggroMove, target, MaxPlatoonWeaponRange, categories.ALLUNITS - categories.AIR)
                        else
                            if HERODEBUG then
                                self:RenamePlatoon('UWP MoveDirect with transporter layer('..self.MovementLayer..')')
                                coroutine.yield(10)
                            end
                            self:MoveToLocationInclTransport(target, LastTargetPos, bAggroMove, WantsTransport, basePosition, ExperimentalInPlatoon, MaxPlatoonWeaponRange, categories.ALLUNITS - categories.AIR, path, reason)
                        end
                    -- move to the target without waypoints using a transporter
                    elseif UnitNoPath then
                        -- we have a target but no path, Air can flight to it
                        if self.MovementLayer == 'Air' then
                            if HERODEBUG then
                                self:RenamePlatoon('UNP MoveDirect (Air)')
                                coroutine.yield(10)
                            end
                            self:MoveDirect(aiBrain, bAggroMove, target, MaxPlatoonWeaponRange, categories.ALLUNITS - categories.AIR)
                        -- we have a target but no path, Naval can never reach it
                        elseif self.MovementLayer == 'Water' then
                            if HERODEBUG then
                                self:RenamePlatoon('UNP No Naval path (Water)')
                                coroutine.yield(10)
                            end
                            target = nil
                            path = nil
                        else
                            self:Stop()
                            if HERODEBUG then
                                self:RenamePlatoon('UWP MoveOnlyWithTransport layer('..self.MovementLayer..')')
                                coroutine.yield(10)
                            end
                            --self:RenamePlatoon('MoveOnlyWithTransport')
                            self:MoveWithTransportNoPath(aiBrain, bAggroMove, target, basePosition, ExperimentalInPlatoon, MaxPlatoonWeaponRange, categories.ALLUNITS - categories.AIR)
                        end
                    end
                end
            else
                target = nil
                path = nil
                LastTargetPos = nil
                -- no target, land units just wait for new targets, air and naval units return to their base
                if HERODEBUG then
                    self:RenamePlatoon('No target returning home')
                    coroutine.yield(10)
                end
                if self.MovementLayer == 'Air' then
                    --self:RenamePlatoon('move to base')
                    if VDist2(PlatoonCenterPosition[1] or 0, PlatoonCenterPosition[3] or 0, basePosition[1] or 0, basePosition[3] or 0) > 40 then
                        self:SetPlatoonFormationOverride('NoFormation')
                        self:SimpleReturnToBase(basePosition)
                        if HERODEBUG then
                            self:RenamePlatoon('returning (Air)')
                            coroutine.yield(10)
                        end
                        if aiBrain:PlatoonExists(self) then
                            self:PlatoonDisband()
                        end
                        return
                    else
                        -- we are at home and we don't have a target. Disband!
                        if aiBrain:PlatoonExists(self) then
                            if HERODEBUG then
                                self:RenamePlatoon('PlatoonDisband 1')
                                coroutine.yield(10)
                            end
                            self:PlatoonDisband()
                            return
                        end
                    end
                elseif self.MovementLayer == 'Water' then
                    -- if we get targets from base then we are here to protect the base. Return to cover the base.
                    if GetTargetsFromBase or self.alternativPlan then
                        if HERODEBUG then
                            self:RenamePlatoon('No BaseTarget, returning Home')
                            coroutine.yield(10)
                        end
                        self:ForceReturnToNavalBaseAIUveso(basePosition)
                        if aiBrain:PlatoonExists(self) then
                            self:PlatoonDisband()
                        end
                        return
                    else
                        if HERODEBUG then
                            self:RenamePlatoon('move to New targets')
                            coroutine.yield(10)
                        end
                        -- no more targets found with platoonbuilder template settings. Set new targets to the platoon and continue
                        self.BuilderName = "old "..self.BuilderName
                        self.alternativPlan = true
                        self.PlatoonData.GetTargetsFromBase = false
                        self.PlatoonData.DirectMoveEnemyBase = false
                        self.PlatoonData.AggressiveMove = true
                        self.PlatoonData.SearchRadius = 10000
                        self.PlatoonData.AttackEnemyStrength = 1000000
                        self.PlatoonData.TargetSearchCategory = categories.ALLUNITS - categories.AIR
                        self.PlatoonData.MoveToCategories = { categories.ALLUNITS - categories.AIR }
                        self.PlatoonData.WeaponTargetCategories = { categories.EXPERIMENTAL, categories.COMMAND, categories.ALLUNITS }
                        coroutine.yield(10)
                        self:HeroFightPlatoon()
                        if aiBrain:PlatoonExists(self) then
                            self:PlatoonDisband()
                        end
                        return
                    end
                else
                    -- if we get targets from base then we are here to protect the base. Return to cover the base.
                    if GetTargetsFromBase or self.alternativPlan then
                        if HERODEBUG then
                            self:RenamePlatoon('No BaseTarget, returning Home')
                            coroutine.yield(10)
                        end
                        self:ForceReturnToNearestBaseAIUveso()
                        if aiBrain:PlatoonExists(self) then
                            self:PlatoonDisband()
                        end
                        return
                    else
                        if HERODEBUG then
                            self:RenamePlatoon('move to New targets')
                            coroutine.yield(10)
                        end
                        -- no more targets found with platoonbuilder template settings. Set new targets to the platoon and continue
                        self.BuilderName = "old "..self.BuilderName
                        self.alternativPlan = true
                        self.PlatoonData.GetTargetsFromBase = false
                        self.PlatoonData.DirectMoveEnemyBase = false
                        self.PlatoonData.AggressiveMove = true
                        self.PlatoonData.RequireTransport = false
                        self.PlatoonData.SearchRadius = 10000
                        self.PlatoonData.AttackEnemyStrength = 1000000
                        self.PlatoonData.TargetSearchCategory = categories.LAND
                        self.PlatoonData.MoveToCategories = { categories.ALLUNITS }
                        self.PlatoonData.WeaponTargetCategories = { categories.EXPERIMENTAL, categories.COMMAND, categories.ALLUNITS }
                        coroutine.yield(10)
                        self:HeroFightPlatoon()
                        if aiBrain:PlatoonExists(self) then
                            self:PlatoonDisband()
                        end
                        return
                    end
                end
            end
            -- in case we are using a transporter, do nothing. Wait for the transport!
            while self.UsingTransport do
                if HERODEBUG then
                    self:RenamePlatoon('Waiting for Transport')
                end
                coroutine.yield(10)
            end
            -- stop the platoon, now we are moving units instead of the platoon
            if aiBrain:PlatoonExists(self) then
                self:Stop()
                coroutine.yield(1)
            else
                return
            end
            -- fight
            if HERODEBUG then
                self:RenamePlatoon('moved, now fighting')
                coroutine.yield(10)
            end
            coroutine.yield(1)
            LastTargetPos = nil
            --self:RenamePlatoon('MICRO loop')
            while aiBrain:PlatoonExists(self) do
                while not aiBrain:IsOpponentAIRunning() do
                    coroutine.yield(10)
                end 
                if HERODEBUG then
                    self:RenamePlatoon('microing in 5 ticks')
                end
                -- wait a bit here, so continue commands can't deadloop/freeze the game
                coroutine.yield(10)
                --AILog('* AI-Uveso: * HeroFightPlatoon: Starting micro loop')
                PlatoonCenterPosition = self:GetPlatoonPosition()
                if not PlatoonCenterPosition then
                    --AIWarn('* AI-Uveso: PlatoonCenterPosition not existent')
                    if aiBrain:PlatoonExists(self) then
                        if HERODEBUG then
                            self:RenamePlatoon('PlatoonDisband 3')
                            coroutine.yield(10)
                        end
                        self:PlatoonDisband()
                    end
                    return
                end
                if HERODEBUG then
                    self:RenamePlatoon('AIFindNearestCategoryTargetInCloseRange')
                end
                -- get a target on every loop, so we can see targets that are moving closer
                if TargetHug or NoTargetChange then
                    if target and not target.Dead and not target:BeenDestroyed() then
                        TargetInPlatoonRange = target
                    else
                        TargetInPlatoonRange = AIUtils.AIFindNearestCategoryTargetInCloseRange(self, aiBrain, 'Attack', PlatoonCenterPosition, MaxPlatoonWeaponRange + 50, MoveToCategories, TargetSearchCategory, false)
                    end
                else
                    TargetInPlatoonRange = AIUtils.AIFindNearestCategoryTargetInCloseRange(self, aiBrain, 'Attack', PlatoonCenterPosition, MaxPlatoonWeaponRange + 50, {categories.ALLUNITS}, categories.ALLUNITS, false)
                end
                -- check if the target is in range
                if TargetInPlatoonRange then
                    LastTargetPos = TargetInPlatoonRange:GetPosition()
                    if self.MovementLayer == 'Air' then
                        if VDist2( PlatoonCenterPosition[1], PlatoonCenterPosition[3], LastTargetPos[1], LastTargetPos[3] ) > MaxPlatoonWeaponRange + 80 then
                            -- Air target is to far away, remove it and lets get a new main target 
                            TargetInPlatoonRange = false
                        end
                    else
                        if VDist2( PlatoonCenterPosition[1], PlatoonCenterPosition[3], LastTargetPos[1], LastTargetPos[3] ) > MaxPlatoonWeaponRange + 80 then
                            -- land/naval target is to far away, remove it and lets get a new main target 
                            if HERODEBUG then
                                AILog("TargetInPlatoonRange out of MaxPlatoonWeaponRange + 80 ("..(MaxPlatoonWeaponRange + 80)..") range: "..VDist2( PlatoonCenterPosition[1], PlatoonCenterPosition[3], LastTargetPos[1], LastTargetPos[3] ), true, UvesoOffsetPlatoonLUA)
                            end
                            TargetInPlatoonRange = false
                        end
                    end
                end

                if HERODEBUG then
                    if TargetInPlatoonRange then
                        if TargetInPlatoonRange.Dead then
                            self:RenamePlatoon('TargetInPlatoonRange = Dead')
                        else
                            self:RenamePlatoon('TargetInPlatoonRange true')
                        end
                    else
                        self:RenamePlatoon('TargetInPlatoonRange = NIL')
                    end
                    coroutine.yield(10)
                end

                if TargetInPlatoonRange and not TargetInPlatoonRange.Dead then
                    --AILog('* AI-Uveso: * HeroFightPlatoon: TargetInPlatoonRange: ['..repr(TargetInPlatoonRange.UnitId)..']')
                    if AIUtils.IsNukeBlastArea(aiBrain, LastTargetPos) then
                        -- continue the "while aiBrain:PlatoonExists(self) do" loop
                        continue
                    end
                    if self.MovementLayer == 'Air' then
                        -- remove target, if we are out of base range
                        DistanceToBase = VDist2(PlatoonCenterPosition[1] or 0, PlatoonCenterPosition[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
                        if GetTargetsFromBase and DistanceToBase > maxRadius then
                            TargetInPlatoonRange = nil
                            if HERODEBUG then
                                self:RenamePlatoon('micro attack AIR DistanceToBase > maxRadius')
                                coroutine.yield(10)
                            end
                            break
                        end
                        -- else attack
                        if HERODEBUG then
                            self:RenamePlatoon('micro attack AIR')
                            coroutine.yield(10)
                        end
                        if not TargetInPlatoonRange.Dead then
                            self:AttackTarget(TargetInPlatoonRange)
                        end
                    else
                        if HERODEBUG then
                            self:RenamePlatoon('micro attack Land')
                            coroutine.yield(10)
                        end
                        --AILog('* AI-Uveso: * HeroFightPlatoon: Fight micro LAND start')
                        --self:RenamePlatoon('Fight micro LAND start')
                        -- bring all platoon units in optimal range to the target
                        UnitMassCost = {}
                        ------------------------------------------------------------------------------
                        -- First micro turn for attack untis, second turn is for cover/shield units --
                        ------------------------------------------------------------------------------
                        for _, unit in self:GetPlatoonUnits() or {} do
                            if unit.Dead then
                                continue
                            end
                            -- don't move shield units in the first turn
                            if unit.IsShieldOnlyUnit then
                                continue
                            end
                            -- clear move commands if we have queued more than 2
                            if table.getn(unit:GetCommandQueue()) > 1 then
                                IssueClearCommands({unit})
                            end
                            unitPos = unit:GetPosition()
                            if unit.Blocked then
                                -- Weapoon fire is blocked, move to the target as close as possible.
                                smartPos = { LastTargetPos[1] + (Random(-5, 5)/10), LastTargetPos[2], LastTargetPos[3] + (Random(-5, 5)/10) }
                            else
                                alpha = math.atan2 (LastTargetPos[3] - unitPos[3] ,LastTargetPos[1] - unitPos[1])
                                x = LastTargetPos[1] - math.cos(alpha) * (unit.MaxWeaponRange or MaxPlatoonWeaponRange)
                                y = LastTargetPos[3] - math.sin(alpha) * (unit.MaxWeaponRange or MaxPlatoonWeaponRange)
                                smartPos = { x, GetTerrainHeight( x, y), y }
                            end
                            -- if we need to get as close to the target as possible, then just run to the target position
                            if TargetHug then
                                IssueMove({unit}, { LastTargetPos[1] + Random(-1, 1), LastTargetPos[2], LastTargetPos[3] + Random(-1, 1) } )
                            -- check if the move position is new or target has moved
                            -- if we don't have a rear weapon then attack (will move in circles otherwise)
                            elseif not unit.HasMainRearWeapon and VDist2( unitPos[1], unitPos[3], LastTargetPos[1], LastTargetPos[3] ) > (unit.MaxWeaponRange or MaxPlatoonWeaponRange) then
                                if HERODEBUG then
                                    self:RenamePlatoon('micro attack Land No RearWeapon')
                                    coroutine.yield(10)
                                end
                                if not TargetInPlatoonRange.Dead then
                                    IssueAttack({unit}, TargetInPlatoonRange)
                                end
                            elseif unit.HasMainRearWeapon and ( VDist2( smartPos[1], smartPos[3], unit.smartPos[1], unit.smartPos[3] ) > 0.7 or VDist2( LastTargetPos[1], LastTargetPos[3], unit.TargetPos[1], unit.TargetPos[3] ) > 0.7 ) then
                                if HERODEBUG then
                                    self:RenamePlatoon('micro attack Land has RearWeapon')
                                    coroutine.yield(10)
                                end
                                -- in case we have a new target, delete the Blocked flag
                                if unit.TargetPos ~= LastTargetPos then
                                    unit.Blocked = false
                                end
                                -- check if we are far away from the platoon. maybe we have a stucked unit here
                                -- can also be a unit that needs to deploy for weapon fire
                                if VDist2( unitPos[1], unitPos[3], PlatoonCenterPosition[1], PlatoonCenterPosition[3] ) > 100.0 then
                                    if not unit:IsMoving() then
                                        unit.IamLost = unit.IamLost + 1
                                    end
                                else
                                    unit.IamLost = 0
                                end
                                if unit.IamLost > 5 then
                                    AIDebug('* AI-Uveso: We have a LOST (stucked) unit. Killing it!!! Distance to platoon: '..math.floor(VDist2( unitPos[1], unitPos[3], PlatoonCenterPosition[1], PlatoonCenterPosition[3]))..' pos: ( '..math.floor(unitPos[1])..' , '..math.floor(unitPos[3])..' )', true, UvesoOffsetPlatoonLUA )
                                    -- stucked units can't be unstucked, even with a forked thread and hammering movement commands. Let's kill it !!!
                                    unit:Kill()
                                end
                                IssueMove({unit}, smartPos )
                                if HERODEBUG then
                                    unit:SetCustomName('Fight micro moving')
                                    coroutine.yield(10)
                                end
                                unit.smartPos = smartPos
                                unit.TargetPos = LastTargetPos
                            -- in case we don't move, check if we can fire at the target
                            else
                                if aiBrain:CheckBlockingTerrain(unitPos, LastTargetPos, unit.WeaponArc) then
                                    if HERODEBUG then
                                        unit:SetCustomName('WEAPON BLOCKED!!! ['..repr(TargetInPlatoonRange.UnitId)..']')
                                        coroutine.yield(10)
                                    end
                                    unit.Blocked = true
                                else
                                    if HERODEBUG then
                                        unit:SetCustomName('SHOOTING ['..repr(TargetInPlatoonRange.UnitId)..']')
                                        coroutine.yield(10)
                                    end
                                    unit.Blocked = false
                                    if not TargetInPlatoonRange.Dead then
                                        -- set the target as focus, we are in range, the unit will shoot without attack command
                                        if EntityCategoryContains(categories.WALL, TargetInPlatoonRange) then
                                            IssueAttack({unit}, TargetInPlatoonRange)
                                        else
                                            unit:SetFocusEntity(TargetInPlatoonRange)
                                        end
                                    end
                                end
                            end
                            -- use this table later to decide what unit we want to cover with shields
                            table.insert(UnitMassCost, {UnitMassCost = unit.UnitMassCost, smartPos = unit.smartPos, TargetPos = unit.TargetPos})
                        end -- end micro first turn 
                        if not UnitMassCost[1] then
                            -- we can just disband the platoon everywhere on the map.
                            -- the location manager will return these units to the nearest base for reassignment.
                            --self:RenamePlatoon('no Fighters -> Disbanded')
                            if aiBrain:PlatoonExists(self) then
                                if HERODEBUG then
                                    self:RenamePlatoon('PlatoonDisband 4')
                                    coroutine.yield(10)
                                end
                                self:PlatoonDisband()
                            end
                            return
                        end
                        table.sort(UnitMassCost, function(a, b) return a.UnitMassCost > b.UnitMassCost end)
                        ----------------------------------------------
                        -- Second micro turn for cover/shield units --
                        ----------------------------------------------
                        UnitToCover = nil
                        CoverIndex = 0
                        for _, unit in self:GetPlatoonUnits() do
                            if unit.Dead then continue end
                            -- don't use attack units here
                            if not unit.IsShieldOnlyUnit then
                                continue
                            end
                            unitPos = unit:GetPosition()
                            -- select a unit we want to cover. units with high mass cost first
                            CoverIndex = CoverIndex + 1
                            if not UnitMassCost[CoverIndex] then
                                if CoverIndex ~= 1 then
                                    CoverIndex = 1
                                end
                            end
                            UnitToCover = UnitMassCost[CoverIndex]
                            -- calculate a position behind the unit we want to cover (behind unit from enemy view)
                            if UnitToCover.smartPos and UnitToCover.TargetPos then
                                alpha = math.atan2 (UnitToCover.smartPos[3] - UnitToCover.TargetPos[3] ,UnitToCover.smartPos[1] - UnitToCover.TargetPos[1])
                                x = UnitToCover.smartPos[1] + math.cos(alpha) * 4
                                y = UnitToCover.smartPos[3] + math.sin(alpha) * 4
                                smartPos = { x, GetTerrainHeight( x, y), y }
                            else
                                smartPos = PlatoonCenterPosition
                            end
                            -- check if the move position is new or target has moved
                            if VDist2( smartPos[1], smartPos[3], unit.smartPos[1], unit.smartPos[3] ) > 0.7 then
                                -- clear move commands if we have queued more than 2
                                if table.getn(unit:GetCommandQueue()) > 1 then
                                    IssueClearCommands({unit})
                                end
                                -- if our target is dead, jump out of the "for _, unit in self:GetPlatoonUnits() do" loop
                                IssueMove({unit}, smartPos )
                                unit.smartPos = smartPos
                            end

                        end
                    end
                else
                    if HERODEBUG then
                        self:RenamePlatoon('no micro target')
                        coroutine.yield(10)
                    end
                    --AILog('* AI-Uveso: * HeroFightPlatoon: Fight micro No Target')
                    self:Stop()
                    -- break the fight loop and get new targets
                    break
                end
           end  -- fight end
        end
        if HERODEBUG then
            self:RenamePlatoon('PlatoonExists = false')
            coroutine.yield(10)
        end

        if aiBrain:PlatoonExists(self) then
            if HERODEBUG then
                self:RenamePlatoon('PlatoonDisband 5')
                coroutine.yield(10)
            end
            self:PlatoonDisband()
        end
    end,

    ACUChampionPlatoon = function(self)
        --AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        self.MovementLayer = 'Land'
        local aiBrain = self:GetBrain()
        -- table for target and debug information
        aiBrain.ACUChampion = {}
        -- save the cration time, we want to wait 10 seconds before we issue any enhancement or platoon disband
        self.created = GetGameTimeSeconds()
        -- removing the debug function thread for line drawing
        if not CHAMPIONDEBUG then
            aiBrain.ACUChampion.RemoveDebugDrawThread = true
        end
        local PlatoonUnits = self:GetPlatoonUnits()
        local cdr = PlatoonUnits[1]
        -- There should be only the commander inside this platoon. Check it.
        if not cdr or not EntityCategoryContains(categories.COMMAND, cdr) then
            cdr = false
            AIWarn('* AI-Uveso: ACUChampionPlatoon: Platoon formed but Commander unit not found!', true, UvesoOffsetPlatoonLUA)
            for k,v in self:GetPlatoonUnits() or {} do
                if EntityCategoryContains(categories.COMMAND, v) then
                    AIWarn('* AI-Uveso: ACUChampionPlatoon: Commander found in platoon on index: '..k, true, UvesoOffsetPlatoonLUA)
                    cdr = v
                else
                    AIWarn('* AI-Uveso: ACUChampionPlatoon: Platoon unit Index '..k..' is not a commander!', true, UvesoOffsetPlatoonLUA)
                end
            end
            if not cdr then
                AIWarn('* AI-Uveso: ACUChampionPlatoon: PlatoonDisband (no ACU in platoon).', true, UvesoOffsetPlatoonLUA)
                self:PlatoonDisband()
                return
            end
        end
        -- ACU is in Support squad, but we want it in Attack squad
        aiBrain:AssignUnitsToPlatoon(self, {cdr}, 'Attack', 'None')

        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                table.insert(MoveToCategories, v )
            end
        else
            AIWarn('* AI-Uveso: * ACUChampionPlatoon: MoveToCategories missing in platoon '..self.BuilderName, true, UvesoOffsetPlatoonLUA)
        end
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                table.insert(WeaponTargetCategories, v )
            end
        elseif self.PlatoonData.MoveToCategories then
            WeaponTargetCategories = MoveToCategories
        end
        self:SetPrioritizedTargetList('Attack', WeaponTargetCategories)
        -- switch the automatic overcharge off
        cdr:SetAutoOvercharge(false)
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        local maxRadius = self.PlatoonData.SearchRadius or 512
        local DoNotDisband = self.PlatoonData.DoNotDisband
        -- make sure maxRadius is not over 512
        maxRadius = math.min( 512, maxRadius )
        local OverchargeWeapon
        cdr.CDRHome = aiBrain.BuilderManagers['MAIN'].Position
        cdr.smartPos = cdr:GetPosition()
        cdr.position = cdr.smartPos
--        cdr.HealthOLD = 100
        cdr.LastDamaged = 0
        cdr.LastMoved = GetGameTimeSeconds()

        local UnitBlueprint = cdr:GetBlueprint()
        for _, weapon in UnitBlueprint.Weapon or {} do
            -- filter dummy weapons
            if weapon.Damage == 0
            or weapon.WeaponCategory == 'Missile'
            or weapon.WeaponCategory == 'Anti Navy'
            or weapon.WeaponCategory == 'Anti Air'
            or weapon.WeaponCategory == 'Defense'
            or weapon.WeaponCategory == 'Teleport' then
                continue
            end
            -- check if the weapon is only enabled by an enhancment
            if weapon.EnabledByEnhancement then
                WeaponEnabled = false
                -- check if we have the enhancement
                for k, v in SimUnitEnhancements[cdr.EntityId] or {} do
                    if v == weapon.EnabledByEnhancement then
                        -- enhancement is installed, the weapon is valid
                        WeaponEnabled = true
                        --AILog('* AI-Uveso: * ACUChampionPlatoon: Weapon: '..weapon.EnabledByEnhancement..' - is installed by an enhancement!')
                        -- no need to search for other enhancements
                        break
                    end
                end
                -- if the wepon is not installed, continue with the next weapon
                if not WeaponEnabled then
                    --AILog('* AI-Uveso: * ACUChampionPlatoon: Weapon: '..weapon.EnabledByEnhancement..' - is not installed.')
                    continue
                end
            end
            --AIWarn('* AI-Uveso: * ACUChampionPlatoon: Weapon: '..weapon.DisplayName..' - WeaponCategory: '..weapon.WeaponCategory..' - MaxRadius:'..weapon.MaxRadius..'')
            if weapon.OverChargeWeapon then
                OverchargeWeapon = weapon
            end
            if not cdr.MaxWeaponRange or cdr.MaxWeaponRange < weapon.MaxRadius then
                cdr.MaxWeaponRange = weapon.MaxRadius
            end
        end
        UnitBlueprint = nil
        --AIWarn('* AI-Uveso: * ACUChampionPlatoon: cdr.MaxWeaponRange: '..cdr.MaxWeaponRange)

        -- set playableArea so we know where the map border is.
        local playableArea = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetPlayableArea()

        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        local Braveness = 0
        local RangeToBase
        local MainBaseTargetWithPath
        local MainBaseTargetWithPathPos
        local MoveToTarget
        local MoveToTargetPos
        local OverchargeTarget
        local OverchargeTargetPos
        local FocusTarget
        local FocusTargetPos
        local ACUCloseRange
        local ACUCloseRangePos
        local TargetCloseRange
        local TargetCloseRangePos
        local smartPos = {}
        local unitPos
        local alpha
        local NavigatorGoal
        local UnderAttack
        local CDRHealth
        local InstalledEnhancementsCount = 0
        local UnitT1, UnitT2, UnitT3, UnitT4, Threat, Shielded
        local EnemyBehindMe, ReachedBase
        local BraveDEBUG = {}
        
        local DebugText, LastDebugText
        -- count enhancements
        for i, name in SimUnitEnhancements[cdr.EntityId] or {} do
            InstalledEnhancementsCount = InstalledEnhancementsCount + 1
            --AIWarn('* AI-Uveso: * ACUChampionPlatoon: Found enhancement: '..name..' - InstalledEnhancementsCount = '..InstalledEnhancementsCount..'')
        end

        -- Make a seperate Thread for base targets
        self:ForkThread(self.ACUChampionBaseTargetThread, aiBrain, cdr)

        -- Main platoon loop
        while aiBrain:PlatoonExists(self) and not cdr.Dead do
            while not aiBrain:IsOpponentAIRunning() do
                IssueClearCommands({cdr})
                coroutine.yield(10)
            end
            -- wait here to prevent deadloops and heavy CPU load
            coroutine.yield(30) -- not working with 1, 2, 3, works good with 10, 
            cdr.position = cdr:GetPosition()
            -- Debug Draw Position
            if CHAMPIONDEBUG then
                aiBrain.ACUChampion.CDRposition = {cdr.position, cdr.MaxWeaponRange}
            end
            --------------------------------------------------------------------------------------------------------------------------------
            -- Braveness decides if the ACU will attack or withdraw. Positive numbers lead to attack, negative lead to fall back to base. --
            --------------------------------------------------------------------------------------------------------------------------------

            Braveness = 0
            Shielded = false
            BraveDEBUG = {}
            -- We gain 1 Braveness if we have full health -------------------------------------------------------------------------------------------------------------------------
            CDRHealth = UUtils.ComHealth(cdr)
            if CDRHealth == 100 then
                Braveness = Braveness + 1
                BraveDEBUG['Health100%'] = 1
            end

            -- We gain 1 Braveness for every 7% health we have over 30% health (+10 on 100% health) -------------------------------------------------------------------------------
            CDRHealth = UUtils.ComHealth(cdr)
            Braveness = Braveness + math.floor( (CDRHealth - 30) / 7 )
            BraveDEBUG['Health'] = math.floor( (CDRHealth - 30)  / 7 )

            -- We gain 1 Braveness (max +3) for every 12 friendly T1 units nearby --------------------------------------------------------------------------------------------------
            UnitT1 = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH1, cdr.position, 25, 'Ally' )
            UnitT2 = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH2, cdr.position, 25, 'Ally' )
            UnitT3 = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH3, cdr.position, 25, 'Ally' )
            UnitT4 = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.EXPERIMENTAL, cdr.position, 25, 'Ally' )
            -- Tech1 ~25 dps -- Tech2 ~90 dps = 3 x T1 -- Tech3 ~333 dps = 13 x T1 -- Tech4 ~2000 dps = 80 x T1
            Threat = UnitT1 + UnitT2 * 3 + UnitT3 * 13 + UnitT4 * 80
            if Threat > 0 then
                Braveness = Braveness + math.min( 3, math.floor(Threat / 12) )
                BraveDEBUG['Ally'] = math.min( 3, math.floor(Threat / 12) )
            end

            -- We gain 0.5 Braveness if we have at least 5 Anti Air units in close range --------------------------------------------------------------------------------------------
            Threat = aiBrain:GetNumUnitsAroundPoint( categories.MOBILE * categories.ANTIAIR, cdr.position, 30, 'Ally' )
            if Threat > 0 then
                Braveness = Braveness + 0.5
                BraveDEBUG['AllyAA'] = 0.5
            end

            -- We gain 1 Braveness if overcharge is available ---------------------------------------------------------------------------------------------------------------------
            if OverchargeWeapon then
                if aiBrain:GetEconomyStored('ENERGY') >= OverchargeWeapon.EnergyRequired then
                    Braveness = Braveness + 1
                    BraveDEBUG['OC'] = 1
                end
            end

            -- We gain 1 Braveness for every enhancement --------------------------------------------------------------------------------------------------------------------------
            Braveness = Braveness + InstalledEnhancementsCount * 0.5
            BraveDEBUG['Enhance'] = InstalledEnhancementsCount * 0.5

            -- We gain 0.1 Braveness for every tactical missile defense nearby ----------------------------------------------------------------------------------------------------
            UnitT2 = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2, cdr.position, 28, 'Ally' )
            if UnitT2 > 0 then
                Braveness = Braveness + UnitT2 * 0.1
                Shielded = true
                BraveDEBUG['TMD'] = UnitT2 * 0.1
            end

            -- We gain 0.5 Braveness for every Tech2 and 1 Braveness for every tech3 shield nearby --------------------------------------------------------------------------------
            UnitT1 = aiBrain:GetNumUnitsAroundPoint( categories.MOBILE * categories.SHIELD * (categories.TECH2 + categories.TECH3), cdr.position, 12, 'Ally' )
            UnitT2 = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.SHIELD * categories.TECH2, cdr.position, 12, 'Ally' )
            UnitT3 = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.SHIELD * categories.TECH3, cdr.position, 21, 'Ally' )
            UnitT4 = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL, cdr.position, 30, 'Ally' )
            Threat = UnitT1 * 0.5 + UnitT2 * 0.5 + UnitT3 * 1 + UnitT4 * 2
            if Threat > 0 then
                Braveness = Braveness + Threat
                Shielded = true
                BraveDEBUG['Shield'] = Threat
            end


            -- We lose 1 Braveness for every 3 t1 enemy units in close range ------------------------------------------------------------------------------------------------------
            UnitT1 = aiBrain:GetNumUnitsAroundPoint( (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH1, cdr.position, 40, 'Enemy' )
            UnitT2 = aiBrain:GetNumUnitsAroundPoint( (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH2, cdr.position, 40, 'Enemy' )
            UnitT3 = aiBrain:GetNumUnitsAroundPoint( (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH3, cdr.position, 40, 'Enemy' )
            UnitT4 = aiBrain:GetNumUnitsAroundPoint( (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.EXPERIMENTAL, cdr.position, 40, 'Enemy' )
            -- Tech1 ~25 dps -- Tech2 ~90 dps = 3 x T1 -- Tech3 ~333 dps = 13 x T1 -- Tech4 ~2000 dps = 80 x T1
            Threat = UnitT1 + UnitT2 * 3 + UnitT3 * 13 + UnitT4 * 80
            if Threat > 0 then
                Braveness = Braveness - math.floor(Threat / 3)
                BraveDEBUG['Enemy'] = - math.floor(Threat / 3)
            end

            -- We lose 5 Braveness for every additional enemy ACU nearby (+0 for 1 ACU, +5 for 2 ACUs, +10 for 3 ACUs
            UnitT1 = aiBrain:GetNumUnitsAroundPoint( categories.COMMAND, cdr.position, 60, 'Enemy' )
            Threat = UnitT1 - 1
            if Threat > 0 then
                Braveness = Braveness - math.floor(Threat * 5)
                BraveDEBUG['EnemyACU'] = - math.floor(Threat * 5)
            end

            -- We lose 12 Braveness for every T2 Point Defense nearby
            UnitT1 = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.DEFENSE * categories.TECH1, cdr.position, 50, 'Enemy' )
            UnitT2 = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.DEFENSE * categories.TECH2, cdr.position, 75, 'Enemy' )
            UnitT3 = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.DEFENSE * categories.TECH3, cdr.position, 95, 'Enemy' )
            UnitT4 = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.DEFENSE * categories.EXPERIMENTAL, cdr.position, 120, 'Enemy' )
            -- Tech1 ~150 dps -- Tech2 ~130 dps = 1 x T1 -- Tech3 ~260 dps = 2 x T1 -- Tech4 ~2000 dps = 80 x T1
            Threat = UnitT1 + UnitT2 * 1 + UnitT3 * 2 + UnitT4 * 13
            if Threat > 0 then
                Braveness = Braveness - math.floor(Threat * 12)
                BraveDEBUG['PD'] = - math.floor(Threat * 12)
            end

            -- We lose 1 Braveness if we got damaged in the last 4 seconds --------------------------------------------------------------------------------------------------------
            UnderAttack = UUtils.UnderAttack(cdr)
            if UnderAttack then
                Braveness = Braveness - 1
                BraveDEBUG['Hitted'] = - 1
            end

            -- We lose 1 Braveness for every 20 map units that we are away from the main base (a 5x5 map has 256x256 map units) ---------------------------------------------------
            RangeToBase = VDist2(cdr.position[1], cdr.position[3], cdr.CDRHome[1], cdr.CDRHome[3])
            Braveness = Braveness - math.floor(RangeToBase/20)
            BraveDEBUG['Range'] = - math.floor(RangeToBase/20)

            -- We lose 3 bravness in range of an enemy tactical missile launcher, we lose 10 in case we are at low health
            if aiBrain.ACUChampion.EnemyTMLPos then
                CDRHealth = UUtils.ComHealth(cdr)
                if CDRHealth > 60 then
                    Braveness = Braveness - 3
                    BraveDEBUG['TML'] = - 3
                else
                    Braveness = Braveness - 10
                    BraveDEBUG['TML'] = - 10
                end
            end

            -- We lose 10 bravness in case the enemy has T3 bomber or gunships
            if aiBrain.ACUChampion.numAirEnemyUnits > 2 then
                Braveness = Braveness - 10
                BraveDEBUG['Bomber6'] = 10
            end

            -- We lose again 10 bravness in case the enemy has more than 12 Tech2/3 bomber or gunships
            if aiBrain.ACUChampion.numAirEnemyUnits > 5 then
                Braveness = Braveness - 10
                BraveDEBUG['Bomber12'] = 10
            end

            -- We lose 10 bravness in case the enemy has one experimental
            if aiBrain.ACUChampion.numExperimentalEnemyUnits > 0 then
                Braveness = Braveness - 10
                BraveDEBUG['Experimentals'] = 10
            end

            -- We lose 10 bravness in case the enemy has more than 2 Tech3 units
            if aiBrain.ACUChampion.numT3EnemyUnits > 2 then
                Braveness = Braveness - 10
                BraveDEBUG['T3Units'] = 10
            end

            -- We lose all Braveness if we have under 20% health -------------------------------------------------------------------------------------------------------------------------
            CDRHealth = UUtils.ComHealth(cdr)
            if CDRHealth < 20 then
                Braveness = -20
            end

            ---------------
            -- Targeting --
            ---------------
            MoveToTarget = false
            MoveToTargetPos = false
            -- Targets from the ACUChampionBaseTargetThread
            MainBaseTargetWithPath = aiBrain.ACUChampion.MainBaseTargetWithPath
            MainBaseTargetWithPathPos = aiBrain.ACUChampion.MainBaseTargetWithPathPos[2]
            FocusTarget = aiBrain.ACUChampion.FocusTarget
            FocusTargetPos = aiBrain.ACUChampion.FocusTargetPos[2]
            OverchargeTarget = aiBrain.ACUChampion.OverchargeTarget
            OverchargeTargetPos = aiBrain.ACUChampion.OverchargeTargetPos[2]
            TargetCloseRange = aiBrain.ACUChampion.MainBaseTargetCloseRange
            TargetCloseRangePos = aiBrain.ACUChampion.MainBaseTargetCloseRangePos[2]
            ACUCloseRange = aiBrain.ACUChampion.MainBaseTargetACUCloseRange
            ACUCloseRangePos = aiBrain.ACUChampion.MainBaseTargetACUCloseRangePos[2]

            -- start micro only if the ACU is closer to our base than any other enemy unit
            if FocusTarget then
                MoveToTarget = FocusTarget
                MoveToTargetPos = FocusTargetPos
            -- we don't have a dfocussed target, is there a enemy ACU in close range ? 
            elseif ACUCloseRange then
                MoveToTarget = ACUCloseRange
                MoveToTargetPos = ACUCloseRangePos
            -- do we have a target with path and a target with ignored pathing? What target is closer ?
            elseif MainBaseTargetWithPathPos and TargetCloseRangePos then
                -- is the TargetWithPath closer than the TargetCloseRange 
                if VDist2( cdr.CDRHome[1], cdr.CDRHome[3], MainBaseTargetWithPathPos[1], MainBaseTargetWithPathPos[3] ) < VDist2( cdr.CDRHome[1], cdr.CDRHome[3], TargetCloseRangePos[1], TargetCloseRangePos[3] ) then
                    -- is the TargetWithPath further away than our ACU to our base ?
                    if VDist2( cdr.CDRHome[1], cdr.CDRHome[3], MainBaseTargetWithPathPos[1], MainBaseTargetWithPathPos[3] ) > VDist2( cdr.CDRHome[1], cdr.CDRHome[3], cdr.position[1], cdr.position[3] ) then
                        MoveToTarget = MainBaseTargetWithPath
                        MoveToTargetPos = MainBaseTargetWithPathPos
                    end
                -- TargetCloseRange is closer than the TargetWithPath 
                else
                    -- is the TargetCloseRange further away than our ACU to our base ?
                    if VDist2( cdr.CDRHome[1], cdr.CDRHome[3], TargetCloseRangePos[1], TargetCloseRangePos[3] ) > VDist2( cdr.CDRHome[1], cdr.CDRHome[3], cdr.position[1], cdr.position[3] ) then
                        MoveToTarget = TargetCloseRange
                        MoveToTargetPos = TargetCloseRangePos
                    end
                end
            -- Do we have a target with path and is the target not closer to my base then me ?
            elseif MainBaseTargetWithPathPos and VDist2( cdr.CDRHome[1], cdr.CDRHome[3], MainBaseTargetWithPathPos[1], MainBaseTargetWithPathPos[3] ) > VDist2( cdr.CDRHome[1], cdr.CDRHome[3], cdr.position[1], cdr.position[3] ) then
                MoveToTarget = MainBaseTargetWithPath
                MoveToTargetPos = MainBaseTargetWithPathPos
            -- Do we have a target without path and is the target not closer to my base then me ?
            elseif TargetCloseRange and VDist2( cdr.CDRHome[1], cdr.CDRHome[3], TargetCloseRangePos[1], TargetCloseRangePos[3] ) > VDist2( cdr.CDRHome[1], cdr.CDRHome[3], cdr.position[1], cdr.position[3] ) then
                MoveToTarget = TargetCloseRange
                MoveToTargetPos = TargetCloseRangePos
            end

            ------------------
            -- Enhancements --
            ------------------

            -- check if we are close to Main base, then decide if we can enhance
            if VDist2(cdr.position[1], cdr.position[3], cdr.CDRHome[1], cdr.CDRHome[3]) < 60 then
                -- only upgrade if we are good at health
                local check = true
                if self.created + 10 > GetGameTimeSeconds() then
                    check = false
                end
                if personality == 'uvesorush' then
                    if self.created + 60*3 > GetGameTimeSeconds() then
                        check = false
                    end
                end
                if CDRHealth < 20 then
                    check = false
                end
                if UnderAttack then
                    check = false
                end
                if FocusTarget then
                    check = false
                end
                if aiBrain.ACUChampion.EnemyInArea > 0 then
                    check = false
                end
                if aiBrain.ACUChampion.EnemyTMLPos and not Shielded then
                    check = false
                end
                -- Only upgrade with full Energy storage
                if aiBrain:GetEconomyStoredRatio('ENERGY') < 1.00 then
                    check = false
                end
                -- First enhancement needs at least +300 energy
                if aiBrain:GetEconomyTrend('ENERGY')*10 < 300 then
                    check = false
                end
                -- Enhancement 3 and all other should only be done if we have good eco. (Black Ops ACU!)
                if InstalledEnhancementsCount >= 2 and (aiBrain:GetEconomyStoredRatio('MASS') < 0.40 or not Shielded) then
                    check = false
                end
                if check then
                    -- in case we have engineers inside the platoon, let them assist the ACU
                    for _, unit in self:GetPlatoonUnits() do
                        if unit.Dead then continue end
                        -- exclude the ACU
                        if unit.CDRHome then
                            continue
                        end
                        if EntityCategoryContains(categories.ENGINEER - categories.POD, unit) then
                            --AILog('Engineer ASSIST ACU')
                            -- NOT working for enhancements
                            IssueGuard({unit}, cdr)
                        end
                        
                    end
                    -- will only start enhancing if ECO is good
                    local InstalledEnhancement = self:BuildACUEnhancements(cdr, InstalledEnhancementsCount < 1)
                    --local InstalledEnhancement = self:BuildACUEnhancements(cdr, false)
                    -- do we have succesfull installed the enhancement ?
                    if InstalledEnhancement then
                        AIDebug('* AI-Uveso: * ACUChampionPlatoon: enhancement '..InstalledEnhancement..' installed', true, UvesoOffsetPlatoonLUA)
                        -- count enhancements
                        InstalledEnhancementsCount = 0
                        for i, name in SimUnitEnhancements[cdr.EntityId] or {} do
                            InstalledEnhancementsCount = InstalledEnhancementsCount + 1
                            AIDebug('* AI-Uveso: * ACUChampionPlatoon: Found enhancement: '..name..' - InstalledEnhancementsCount = '..InstalledEnhancementsCount..'', true, UvesoOffsetPlatoonLUA)
                        end
                        -- check if we have installed a weapon
                        local tempEnhanceBp = cdr:GetBlueprint().Enhancements[InstalledEnhancement]
                        -- Is it a weapon with a new max range ?
                        if tempEnhanceBp.NewMaxRadius then
                            -- set the new max range
                            if not cdr.MaxWeaponRange or cdr.MaxWeaponRange < tempEnhanceBp.NewMaxRadius then
                                cdr.MaxWeaponRange = tempEnhanceBp.NewMaxRadius -- maxrange minus 10%
                                AIDebug('* AI-Uveso: * ACUChampionPlatoon: New cdr.MaxWeaponRange: '..cdr.MaxWeaponRange..' ['..InstalledEnhancement..']', true, UvesoOffsetPlatoonLUA)
                            end
                        else
                            --DebugArray(tempEnhanceBp)
                        end
                    end
                end
            end

            --------------
            -- Movement --
            --------------

            if not aiBrain:PlatoonExists(self) or cdr.Dead then
                self:PlatoonDisband()
                return
            end
            -- is any enemy closer to our base then our ACU ?
            if TargetCloseRangePos then
                EnemyBehindMe = VDist2( cdr.CDRHome[1], cdr.CDRHome[3], TargetCloseRangePos[1], TargetCloseRangePos[3] ) < VDist2( cdr.CDRHome[1], cdr.CDRHome[3], cdr.position[1], cdr.position[3] )
                if EnemyBehindMe then
                    BraveDEBUG['Behind'] = 1
                end
            elseif MainBaseTargetWithPathPos then
                EnemyBehindMe = VDist2( cdr.CDRHome[1], cdr.CDRHome[3], MainBaseTargetWithPathPos[1], MainBaseTargetWithPathPos[3] ) < VDist2( cdr.CDRHome[1], cdr.CDRHome[3], cdr.position[1], cdr.position[3] )
                if EnemyBehindMe then
                    BraveDEBUG['Behind'] = 2
                end
            else
                EnemyBehindMe = false
                BraveDEBUG['Behind'] = 0
            end
            NavigatorGoal = cdr:GetNavigator():GetGoalPos()
            -- Run away from nuke explosions
            local InNukeBlastArea = AIUtils.IsNukeBlastArea(aiBrain, cdr.position)
            if InNukeBlastArea then
                alpha = math.atan2 (InNukeBlastArea[3] - cdr.position[3] ,InNukeBlastArea[1] - cdr.position[1])
                x = InNukeBlastArea[1] - math.cos(alpha) * 50
                y = InNukeBlastArea[3] - math.sin(alpha) * 50
                smartPos = { x, GetTerrainHeight( x, y), y }
                BraveDEBUG['Reason'] = 'Evade from Nuke Blast'
            -- Run away from experimentals. (move out of experimental wepon range)
            -- MKB Max distance to experimental DistBase/2 or EnemyExperimentalWepRange + 100. whatever is bigger
            elseif aiBrain.ACUChampion.EnemyExperimentalPos and VDist2( cdr.position[1], cdr.position[3], aiBrain.ACUChampion.EnemyExperimentalPos[1][1], aiBrain.ACUChampion.EnemyExperimentalPos[1][3] ) < aiBrain.ACUChampion.EnemyExperimentalWepRange + 30 then
                alpha = math.atan2 (aiBrain.ACUChampion.EnemyExperimentalPos[1][3] - cdr.position[3] ,aiBrain.ACUChampion.EnemyExperimentalPos[1][1] - cdr.position[1])
                x = aiBrain.ACUChampion.EnemyExperimentalPos[1][1] - math.cos(alpha) * (aiBrain.ACUChampion.EnemyExperimentalWepRange + 30)
                y = aiBrain.ACUChampion.EnemyExperimentalPos[1][3] - math.sin(alpha) * (aiBrain.ACUChampion.EnemyExperimentalWepRange + 30)
                smartPos = { x, GetTerrainHeight( x, y), y }
                BraveDEBUG['Reason'] = 'Evade from EXPERIMENTAL'
            -- Move to the enemy if Braveness is positive or if we are inside our base
            elseif not EnemyBehindMe and Braveness >= 0 and MoveToTargetPos then
                ReachedBase = false
                BraveDEBUG['ReachedBase'] = 0
                -- if the target has moved or we got a new target, delete the Weapon Blocked flag.
                if cdr.LastMoveToTargetPos ~= MoveToTargetPos then
                    cdr.WeaponBlocked = false
                    cdr.LastMoveToTargetPos = MoveToTargetPos
                end
                -- Set different move destination if weapon fire is blocked
                if cdr.WeaponBlocked then
                    -- Weapoon fire is blocked, move to the target as close as possible.
                    smartPos = { MoveToTargetPos[1], MoveToTargetPos[2], MoveToTargetPos[3] }
                    BraveDEBUG['Reason'] = 'Weapon Blocked'
                else
                    -- go closeer to the target depending on ACU health
                    local RangeMod = CDRHealth/10
                    if RangeMod < 0 then RangeMod = 0 end
                    if RangeMod > 10 then RangeMod = 10 end
                    -- Weapoon fire is not blocked, move to the target at Max Weapon Range.
                    alpha = math.atan2 (MoveToTargetPos[3] - cdr.position[3] ,MoveToTargetPos[1] - cdr.position[1])
                    x = MoveToTargetPos[1] - math.cos(alpha) * (cdr.MaxWeaponRange * 0.9 - RangeMod)
                    y = MoveToTargetPos[3] - math.sin(alpha) * (cdr.MaxWeaponRange * 0.9 - RangeMod)
                    smartPos = { x, GetTerrainHeight( x, y), y }
                    BraveDEBUG['Reason'] = 'Attack target'
                end
            -- Back to base if Braveness is negative
            else
                -- decide if we move to our base or if we need to evade
                if VDist2( cdr.position[1], cdr.position[3], cdr.CDRHome[1], cdr.CDRHome[3] ) > 30 and not ReachedBase then
                    -- move to main base
                    smartPos = cdr.CDRHome
                    BraveDEBUG['Reason'] = 'go home >30'
                -- evade from focus target
                elseif not EnemyBehindMe and CDRHealth > 30 and FocusTargetPos and MoveToTargetPos then
                    ReachedBase = true
                    BraveDEBUG['ReachedBase'] = 1
                    alpha = math.atan2 (MoveToTargetPos[3] - cdr.position[3] ,MoveToTargetPos[1] - cdr.position[1])
                    x = MoveToTargetPos[1] - math.cos(alpha) * (50)
                    y = MoveToTargetPos[3] - math.sin(alpha) * (50)
                    smartPos = { x, GetTerrainHeight( x, y), y }
                    BraveDEBUG['Reason'] = 'Evade from FocusTarget'
                -- in case we got attacked but don't have a target to shoot at or low health
                elseif CDRHealth < 30 or aiBrain.ACUChampion.EnemyInArea then
                    ReachedBase = true
                    BraveDEBUG['ReachedBase'] = 1
                    local lessEnemyAreaPos
                    if (aiBrain.ACUChampion.EnemyInArea > 0 or FocusTargetPos) and aiBrain.ACUChampion.AreaTable then
                        local MostEnemyAreaIndex
                        local MostEnemyArea
                        for index, pos in aiBrain.ACUChampion.AreaTable do
                            if not MostEnemyArea or MostEnemyArea < aiBrain.ACUChampion.AreaTable[index][4] then
                                MostEnemyArea = aiBrain.ACUChampion.AreaTable[index][4]
                                MostEnemyAreaIndex = index
                            end
                        end
                        local countMin = false
                        local mirrorIndex
                        for index = 4, 3, -1 do
                            mirrorIndex = MostEnemyAreaIndex + index
                            if mirrorIndex > 8 then mirrorIndex = mirrorIndex - 8 end
                            if not countMin or countMin > aiBrain.ACUChampion.AreaTable[mirrorIndex][4] then
                                countMin = aiBrain.ACUChampion.AreaTable[mirrorIndex][4]
                                lessEnemyAreaPos = {aiBrain.ACUChampion.AreaTable[mirrorIndex][1], aiBrain.ACUChampion.AreaTable[mirrorIndex][2], aiBrain.ACUChampion.AreaTable[mirrorIndex][3]}
                                --AILog('lessEnemyAreaPos + = mirrorIndex: '..mirrorIndex..' - countMin:'..countMin)
                            end
                            mirrorIndex = MostEnemyAreaIndex - index
                            if mirrorIndex < 1 then mirrorIndex = mirrorIndex + 8 end
                            if not countMin or countMin > aiBrain.ACUChampion.AreaTable[mirrorIndex][4] then
                                countMin = aiBrain.ACUChampion.AreaTable[mirrorIndex][4]
                                lessEnemyAreaPos = {aiBrain.ACUChampion.AreaTable[mirrorIndex][1], aiBrain.ACUChampion.AreaTable[mirrorIndex][2], aiBrain.ACUChampion.AreaTable[mirrorIndex][3]}
                                --AILog('lessEnemyAreaPos - = mirrorIndex: '..mirrorIndex..' - countMin:'..countMin)
                            end
                        end
                    end
                    if lessEnemyAreaPos then
                        smartPos = lessEnemyAreaPos
                        BraveDEBUG['Reason'] = 'Evade to lessEnemyAreaPos'
                    else
                        ReachedBase = false
                        smartPos = UUtils.RandomizePosition(cdr.CDRHome)
                        BraveDEBUG['Reason'] = 'Evade to cdr.CDRHom'
                    end
                else
                    ReachedBase = true
                    BraveDEBUG['ReachedBase'] = 1
                    if VDist2( cdr.position[1], cdr.position[3], cdr.CDRHome[1], cdr.CDRHome[3] ) > 30 then
                        smartPos = cdr.CDRHome
                        BraveDEBUG['Reason'] = 'dance go home'
                    elseif VDist2( cdr.position[1], cdr.position[3], NavigatorGoal[1], NavigatorGoal[3] ) <= 0.7 then
                        -- we are at home and not under attack, dance
                        smartPos = UUtils.RandomizePosition(cdr.CDRHome)
                        BraveDEBUG['Reason'] = 'dance at home'
                    else
                        BraveDEBUG['Reason'] = 'dance at home Navigator'
                    end
                end
            end

            if CHAMPIONDEBUG then
                cdr:SetCustomName('Braveness: '..Braveness..' - '..BraveDEBUG['Reason'])
                DebugText = 'Full:'..(BraveDEBUG['Health100%'] or "--")..' '
                DebugText = DebugText..'Heal:'..(BraveDEBUG['Health'] or "--")..' '
                DebugText = DebugText..'Ally:'..(BraveDEBUG['Ally'] or "--")..' '
                DebugText = DebugText..'AlAA:'..(BraveDEBUG['AllyAA'] or "--")..' '
                DebugText = DebugText..'Over:'..(BraveDEBUG['OC'] or "--")..' '
                DebugText = DebugText..'Enh:'..(BraveDEBUG['Enhance'] or "--")..' '
                DebugText = DebugText..'TMD:'..(BraveDEBUG['TMD'] or "--")..' '
                DebugText = DebugText..'Shield:'..(BraveDEBUG['Shield'] or "--")..' '
                DebugText = DebugText..'Enemy:'..(BraveDEBUG['Enemy'] or "--")..' '
                DebugText = DebugText..'PD:'..(BraveDEBUG['PD'] or "--")..' '
                DebugText = DebugText..'EnemyACU:'..(BraveDEBUG['EnemyACU'] or "--")..' '   -- -0 -5
                DebugText = DebugText..'Behind:'..(BraveDEBUG['Behind'] or "--")..' '
                DebugText = DebugText..'Hitted:'..(BraveDEBUG['Hitted'] or "--")..' '
                DebugText = DebugText..'Range:'..(BraveDEBUG['Range'] or "--")..' '         -- -0 -12
                DebugText = DebugText..'TML:'..(BraveDEBUG['TML'] or "--")..' '
                DebugText = DebugText..'Bomber6:'..(BraveDEBUG['Bomber6'] or "--")..' '
                DebugText = DebugText..'Bomber12:'..(BraveDEBUG['Bomber12'] or "--")..' '
                DebugText = DebugText..'RBase:'..(BraveDEBUG['ReachedBase'] or "--")..' '
                DebugText = DebugText..'Exp:'..(BraveDEBUG['Experimentals'] or "--")..' '
                DebugText = DebugText..'T3:'..(BraveDEBUG['T3Units'] or "--")..' '
                DebugText = DebugText..'Braveness: '..Braveness..' - '
                DebugText = DebugText..'ACTION: '..(BraveDEBUG['Reason'] or "--")..' '
                if DebugText != LastDebugText then
                    LastDebugText = DebugText
                    AILog(DebugText, true, UvesoOffsetPlatoonLUA)
                end
            end
            
            -- clear move commands if we have queued more than 2
            if table.getn(cdr:GetCommandQueue()) > 2 then
                IssueClearCommands({cdr})
                --AIWarn('* AI-Uveso: ACUChampionPlatoon: IssueClearCommands({cdr}) ) 2'..table.getn(cdr:GetCommandQueue()))
            end

            -- fire overcharge
            if OverchargeWeapon then
                -- Do we have the energy in general to overcharge ?
                if aiBrain:GetEconomyStored('ENERGY') >= OverchargeWeapon.EnergyRequired then
                    -- only shoot when we have low mass (then we don't need energy) or at full energy (max damage) or when in danger
                    if aiBrain:GetEconomyStoredRatio('MASS') < 0.05 or aiBrain:GetEconomyStoredRatio('ENERGY') > 0.99 or CDRHealth < 60 then
                        if OverchargeTarget and not OverchargeTarget.Dead and not OverchargeTarget:BeenDestroyed() then
                            IssueOverCharge({cdr}, OverchargeTarget)
                        end
                    end
                end
            end

            -- in case we are in range of an enemy TMl, always move to different positions
            if aiBrain.ACUChampion.EnemyTMLPos or UnderAttack then
                smartPos = UUtils.RandomizePositionTML(smartPos)
            end
            -- in case we are not moving for 4 seconds, force moving (maybe blocked line of sight)
            if not cdr:IsUnitState("Moving") then
                if cdr.LastMoved + 4 < GetGameTimeSeconds() then
                    smartPos = UUtils.RandomizePositionTML(smartPos)
                    cdr.LastMoved = GetGameTimeSeconds()
                end
            else
                cdr.LastMoved = GetGameTimeSeconds()
            end

            -- check if we have already a move position
            if not smartPos[1] then
                smartPos = cdr.position
            end
            -- Validate move position, make sure it's not out of map
            if smartPos[1] < playableArea[1] then
                smartPos[1] = playableArea[1]
            elseif smartPos[1] > playableArea[3] then
                smartPos[1] = playableArea[3]
            end
            if smartPos[3] < playableArea[2] then
                smartPos[3] = playableArea[2]
            elseif smartPos[3] > playableArea[4] then
                smartPos[3] = playableArea[4]
            end
            -- check if the move position is new, then issue a move command
            -- ToDo in case we are under fire we should move in zig-zag to evade
            if VDist2( smartPos[1], smartPos[3], NavigatorGoal[1], NavigatorGoal[3] ) > 0.7 then
                IssueClearCommands({cdr})
                IssueMove({cdr}, smartPos )
                if CHAMPIONDEBUG then
                    aiBrain.ACUChampion.moveto = {cdr.position, smartPos}
                end
            elseif VDist2( cdr.position[1], cdr.position[3], NavigatorGoal[1], NavigatorGoal[3] ) <= 0.7 then
                if CHAMPIONDEBUG then
                    aiBrain.ACUChampion.moveto = false
                end
            end

            -- fire primary weapon
            if FocusTargetPos and aiBrain:CheckBlockingTerrain(cdr.position, FocusTargetPos, 'low') then
                cdr.WeaponBlocked = true
            else
                cdr.WeaponBlocked = false
            end
            if not cdr.WeaponBlocked and FocusTarget and not FocusTarget.Dead and not FocusTarget:BeenDestroyed() then
                IssueAttack({cdr}, FocusTarget)
            end

            -- At home, no target and not under attack ? Then we can maybe disband
            if VDist2( cdr.position[1], cdr.position[3], cdr.CDRHome[1], cdr.CDRHome[3] ) < 30 and not MoveToTarget and not UnderAttack then
                -- in case we have no Factory left, recover!
                if not aiBrain:GetListOfUnits(categories.STRUCTURE * categories.FACTORY * categories.LAND - categories.SUPPORTFACTORY, false)[1] then
                    --AIWarn('* AI-Uveso: ACUChampionPlatoon: PlatoonDisband (no HQ Factory)')
                    aiBrain.ACUChampion.CDRposition = false
                    aiBrain.ACUChampion.moveto = false
                    aiBrain.ACUChampion.MainBaseTargetWithPath = false
                    aiBrain.ACUChampion.MainBaseTargetWithPathPos = false
                    aiBrain.ACUChampion.MainBaseTargetCloseRange = false
                    aiBrain.ACUChampion.MainBaseTargetCloseRangePos = false
                    aiBrain.ACUChampion.MainBaseTargetACUCloseRange = false
                    aiBrain.ACUChampion.MainBaseTargetACUCloseRangePos = false
                    aiBrain.ACUChampion.OverchargeTargetPos = false
                    aiBrain.ACUChampion.FocusTarget = false
                    aiBrain.ACUChampion.FocusTargetPos = false
                    aiBrain.ACUChampion.EnemyTMLPos = false
                    aiBrain.ACUChampion.EnemyExperimentalPos = false
                    aiBrain.ACUChampion.AreaTable = false
                    aiBrain.ACUChampion.numAirEnemyUnits = false
                    aiBrain.ACUChampion.OverchargeTarget = false
                    aiBrain.ACUChampion.Assistees = false
                    if CHAMPIONDEBUG then
                        cdr:SetCustomName('Engineer Recover')
                    end
                    self:PlatoonDisband()
                    return
                end

                -- no target in platoon max range ? Disband; Maybe another platoon has more max range
                if self.created + 30 < GetGameTimeSeconds() and Braveness > 0 and CDRHealth >= 100 and not aiBrain.ACUChampion.MainBaseTargetCloseRange and not DoNotDisband then
                    --AIWarn('* AI-Uveso: ACUChampionPlatoon: PlatoonDisband (no targets in range)')
                    aiBrain.ACUChampion.CDRposition = false
                    aiBrain.ACUChampion.moveto = false
                    aiBrain.ACUChampion.MainBaseTargetWithPath = false
                    aiBrain.ACUChampion.MainBaseTargetWithPathPos = false
                    aiBrain.ACUChampion.MainBaseTargetCloseRange = false
                    aiBrain.ACUChampion.MainBaseTargetCloseRangePos = false
                    aiBrain.ACUChampion.MainBaseTargetACUCloseRange = false
                    aiBrain.ACUChampion.MainBaseTargetACUCloseRangePos = false
                    aiBrain.ACUChampion.OverchargeTargetPos = false
                    aiBrain.ACUChampion.FocusTarget = false
                    aiBrain.ACUChampion.FocusTargetPos = false
                    aiBrain.ACUChampion.EnemyTMLPos = false
                    aiBrain.ACUChampion.EnemyExperimentalPos = false
                    aiBrain.ACUChampion.AreaTable = false
                    aiBrain.ACUChampion.numAirEnemyUnits = false
                    aiBrain.ACUChampion.OverchargeTarget = false
                    aiBrain.ACUChampion.Assistees = false
                    if CHAMPIONDEBUG then
                        cdr:SetCustomName('Engineer')
                    end
                    self:PlatoonDisband()
                    return
                end
            end
            ----------------------------------------------
            -- Second micro part for cover/shield units --
            ----------------------------------------------
            aiBrain.ACUChampion.Assistees = {}
            local debugIndex = 0
            local DistToACU = 0
            for index, unit in self:GetPlatoonUnits() do
                if unit.Dead then continue end
                -- exclude the ACU
                if unit.CDRHome then
                    continue
                end
                -- check and save if a unit has shield or stealth or cloak, so we can place the unit behind the ACU
                if not unit.HasShield then
                    UnitBlueprint = unit:GetBlueprint()
                    -- We need to cover other units with the shield, so only count non personal shields.
                    if UnitBlueprint.CategoriesHash.SHIELD and not UnitBlueprint.Defense.Shield.PersonalShield then
                        unit.HasShield = 1
                    elseif UnitBlueprint.Intel.RadarStealthField then
                        unit.HasShield = 1
                    elseif UnitBlueprint.Intel.CloakField then
                        unit.HasShield = 1
                    else
                        unit.HasShield = 0
                    end
                end
                -- Positive numbers will move units behind the ACU, negative numbers in front of the ACU
                if unit.HasShield == 1 then
                    -- Shield units
                    DistToACU = 5
                elseif EntityCategoryContains(categories.LAND * categories.ANTIAIR, unit) then
                    -- Mobile Land Anti Air
                    DistToACU = 20
                elseif EntityCategoryContains(categories.AIR, unit) then
                    -- Air units
                    DistToACU = 1
                elseif EntityCategoryContains(categories.ENGINEER - categories.POD, unit) then
                    DistToACU = 10
                else
                    -- land units -6 means the unit will stay in front of the ACU
                    DistToACU = -6
                end
                --AILog('Valid Unit in ACU platoon: '..unit.UnitId)
                unitPos = unit:GetPosition()
                -- for debug lines
                debugIndex = debugIndex + 1
                aiBrain.ACUChampion.Assistees[debugIndex] = {unitPos, cdr.position }
                if not unit.smartPos then
                    unit.smartPos = unitPos
                end
                -- calculate a position behind the unit we want to cover (behind unit from enemy view)
                if NavigatorGoal and FocusTargetPos then
                    if unit.Blocked then
                        -- Weapoon fire is blocked, move to the target as close as possible.
                        smartPos = { FocusTargetPos[1] + (Random(-5, 5)/10), FocusTargetPos[2], FocusTargetPos[3] + (Random(-5, 5)/10) }
                    else
                        alpha = math.atan2 (FocusTargetPos[3] - unitPos[3] ,FocusTargetPos[1] - unitPos[1])
                        x = FocusTargetPos[1] - math.cos(alpha) * (unit.MaxWeaponRange or 15)
                        y = FocusTargetPos[3] - math.sin(alpha) * (unit.MaxWeaponRange or 15)
                        smartPos = { x, GetTerrainHeight( x, y), y }
                    end
                else
                    -- Move so our support units are between ACU and base
                    alpha = math.atan2 (cdr.CDRHome[3] - cdr.position[3] ,cdr.CDRHome[1] - cdr.position[1])
                    x = cdr.smartPos[1] + math.cos(alpha) * DistToACU
                    y = cdr.smartPos[3] + math.sin(alpha) * DistToACU
                    smartPos = { x, GetTerrainHeight( x, y), y }
                end
                -- check if the move position is new
                if VDist2( smartPos[1], smartPos[3], unit.smartPos[1], unit.smartPos[3] ) > 0.7 then
                    -- clear move commands if we have queued more than 2
                    if table.getn(unit:GetCommandQueue()) > 1 then
                        IssueClearCommands({unit})
                    end
                    IssueMove({unit}, smartPos )
                    unit.smartPos = smartPos
                elseif FocusTargetPos then
                    if aiBrain:CheckBlockingTerrain(unitPos, FocusTargetPos, 'low') then
                        unit.Blocked = true
                    else
                        unit.Blocked = false
                        if not FocusTarget.Dead then
                            -- set the target as focus, we are in range, the unit will shoot without attack command
                            unit:SetFocusEntity(FocusTarget)
                        end
                    end
                end
            end

        end
    end,

    ACUChampionBaseTargetThread = function(platoon, aiBrain, cdr)
        local MoveToCategories = {}
        if platoon.PlatoonData.MoveToCategories then
            for k,v in platoon.PlatoonData.MoveToCategories do
                table.insert(MoveToCategories, v )
            end
        end
        local SearchRadius = platoon.PlatoonData.SearchRadius or 250
        local TargetSearchCategory = platoon.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        local SelfArmyIndex = aiBrain:GetArmyIndex()
        local ValidUnit, NavigatorGoal, FocusTarget, TargetsInACURange, blip, UnitCloseRange
        local EnemyACU, EnemyACUPos, EnemyUnit, EnemyUnitPos, OverchargeVictims, MostUnitAround
        local TargetPosition, AreaTable, EnemyTML, EnemyTMLPos, ACUCloseRange
        local UnitT1, EnemyExperimental, EnemyExperimentalPos, UnitBlueprint, MaxWeaponRange
        local UnitWithPath, UnitNoPath, path, reason
        local numAirEnemyUnits, numExperimentalEnemyUnits, numT3EnemyUnits
        local playableArea = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetPlayableArea()
        while aiBrain:PlatoonExists(platoon) and not cdr.Dead do
            -- wait here to prevent deadloops and heavy CPU load
            coroutine.yield(7)

            -- get the closest target to mainbase with path
            ValidUnit = false
            UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRange(aiBrain, platoon, 'Attack', cdr.CDRHome, SearchRadius, {TargetSearchCategory}, TargetSearchCategory, false )
            if UnitWithPath then
                blip = UnitWithPath:GetBlip(SelfArmyIndex)
                if blip then
                    if blip:IsOnRadar(SelfArmyIndex) or blip:IsSeenEver(SelfArmyIndex) then
                        if not blip:BeenDestroyed() and not blip:IsKnownFake(SelfArmyIndex) and not blip:IsMaybeDead(SelfArmyIndex) then
                            aiBrain.ACUChampion.MainBaseTargetWithPath = UnitWithPath
                            ValidUnit = true
                        end
                    end
                end
            end
            if not ValidUnit then
                aiBrain.ACUChampion.MainBaseTargetWithPath = false
            end
            -- draw a line from base to the base target
            if aiBrain.ACUChampion.MainBaseTargetWithPath then
                aiBrain.ACUChampion.MainBaseTargetWithPathPos = {cdr.CDRHome, aiBrain.ACUChampion.MainBaseTargetWithPath:GetPosition()}
            else
                aiBrain.ACUChampion.MainBaseTargetWithPathPos = false
            end

            coroutine.yield(1)

            -- get the closest target to mainbase ignoring path
            ValidUnit = false
            UnitCloseRange = AIUtils.AIFindNearestCategoryTargetInCloseRange(platoon, aiBrain, 'Attack', cdr.CDRHome, SearchRadius, {TargetSearchCategory}, TargetSearchCategory, false)
            if UnitCloseRange then
                blip = UnitCloseRange:GetBlip(SelfArmyIndex)
                if blip then
                    if blip:IsOnRadar(SelfArmyIndex) or blip:IsSeenEver(SelfArmyIndex) then
                        if not blip:BeenDestroyed() and not blip:IsKnownFake(SelfArmyIndex) and not blip:IsMaybeDead(SelfArmyIndex) then
                            aiBrain.ACUChampion.MainBaseTargetCloseRange = UnitCloseRange
                            ValidUnit = true
                        end
                    end
                end
            end
            if not ValidUnit then
                aiBrain.ACUChampion.MainBaseTargetCloseRange = false
            end
            -- draw a line from base to the base target
            if aiBrain.ACUChampion.MainBaseTargetCloseRange then
                aiBrain.ACUChampion.MainBaseTargetCloseRangePos = {cdr.CDRHome, aiBrain.ACUChampion.MainBaseTargetCloseRange:GetPosition()}
            else
                aiBrain.ACUChampion.MainBaseTargetCloseRangePos = false
            end

            coroutine.yield(1)

            -- get the closest ACU target to mainbase ignoring path
            -- get units around point, acu wiht lowest health = target
            ValidUnit = false
            ACUCloseRange = AIUtils.AIFindNearestCategoryTargetInCloseRange(platoon, aiBrain, 'Attack', cdr.position, cdr.MaxWeaponRange, {categories.COMMAND}, categories.COMMAND, false)
            if ACUCloseRange then
                blip = ACUCloseRange:GetBlip(SelfArmyIndex)
                if blip then
                    if blip:IsOnRadar(SelfArmyIndex) or blip:IsSeenEver(SelfArmyIndex) then
                        if not blip:BeenDestroyed() and not blip:IsKnownFake(SelfArmyIndex) and not blip:IsMaybeDead(SelfArmyIndex) then
                            aiBrain.ACUChampion.MainBaseTargetACUCloseRange = ACUCloseRange
                            ValidUnit = true
                        end
                    end
                end
            end
            if not ValidUnit then
                aiBrain.ACUChampion.MainBaseTargetACUCloseRange = false
            end
            -- draw a line from base to the base target
            if aiBrain.ACUChampion.MainBaseTargetACUCloseRange then
                aiBrain.ACUChampion.MainBaseTargetACUCloseRangePos = {cdr.CDRHome, aiBrain.ACUChampion.MainBaseTargetACUCloseRange:GetPosition()}
            else
                aiBrain.ACUChampion.MainBaseTargetACUCloseRangePos = false
            end

            coroutine.yield(1)

            -- get the closest target to the ACU
            EnemyACU = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.COMMAND)
            if EnemyACU then
                EnemyACUPos = EnemyACU:GetPosition()
                -- out of range ?
                if VDist2( cdr.position[1], cdr.position[3], EnemyACUPos[1], EnemyACUPos[3] ) > cdr.MaxWeaponRange then
                    EnemyACU = false
                end
            end
            EnemyUnit = platoon:FindClosestUnit('Attack', 'Enemy', true, TargetSearchCategory)
            if EnemyUnit then
                EnemyUnitPos = EnemyUnit:GetPosition()
                -- out of range ?
                if VDist2( cdr.position[1], cdr.position[3], EnemyUnitPos[1], EnemyUnitPos[3] ) > cdr.MaxWeaponRange then
                    EnemyUnit = false
                end 
            end
            if EnemyACU then
                aiBrain.ACUChampion.FocusTarget = EnemyACU
                aiBrain.ACUChampion.FocusTargetPos = {cdr.position, EnemyACU:GetPosition()}
            elseif EnemyUnit then
                aiBrain.ACUChampion.FocusTarget = EnemyUnit
                aiBrain.ACUChampion.FocusTargetPos = {cdr.position, EnemyUnit:GetPosition()}
            else
                aiBrain.ACUChampion.FocusTarget = false
                aiBrain.ACUChampion.FocusTargetPos = false
            end

            coroutine.yield(1)

            -- get target for overcharge 
            TargetsInACURange = aiBrain:GetUnitsAroundPoint(TargetSearchCategory, cdr.position, cdr.MaxWeaponRange, 'Enemy')
            OverchargeVictims = {}
            for i, Target in TargetsInACURange do
                if Target.Dead or Target:BeenDestroyed() then
                    continue
                end
                TargetPosition = Target:GetPosition()
                if VDist2( cdr.position[1], cdr.position[3], TargetPosition[1], TargetPosition[3] ) < cdr.MaxWeaponRange then
                    table.insert(OverchargeVictims, {Target, TargetPosition, 0})
                end
            end
            -- count the unit with most units around (overcharge splat radius = 2.5)
            ValidUnit = false
            MostUnitAround = 0
            for IndexA, UnitA in OverchargeVictims do
                for IndexB, UnitB in OverchargeVictims do
                    if IndexA ~= IndexB and VDist2( UnitA[2][1], UnitA[2][3], UnitB[2][1], UnitB[2][3] ) < 2.5 then
                        UnitA[3] = UnitA[3] + 1
                        if UnitA[3] > MostUnitAround then
                            MostUnitAround = UnitA[3]
                            aiBrain.ACUChampion.OverchargeTarget = UnitA[1]
                            ValidUnit = true
                        end
                    end
                end
            end
            if not ValidUnit then
                aiBrain.ACUChampion.OverchargeTarget = false
            end
            -- draw a line for overcharge target
            if aiBrain.ACUChampion.OverchargeTarget then
                aiBrain.ACUChampion.OverchargeTargetPos = {cdr.position, aiBrain.ACUChampion.OverchargeTarget:GetPosition()}
            else
                aiBrain.ACUChampion.OverchargeTargetPos = false
            end

            coroutine.yield(1)

            -- Find free spots around the ACU for evading
            AreaTable = {
                {cdr.position[1]-12, cdr.position[2], cdr.position[3]-30}, -- 1
                {cdr.position[1]+12, cdr.position[2], cdr.position[3]-30}, -- 2
                {cdr.position[1]+30, cdr.position[2], cdr.position[3]-12}, -- 4         1 2
                {cdr.position[1]+30, cdr.position[2], cdr.position[3]+12}, -- 6       3     4
                {cdr.position[1]+12, cdr.position[2], cdr.position[3]+30}, -- 8       5     6
                {cdr.position[1]-12, cdr.position[2], cdr.position[3]+30}, -- 7         7 8
                {cdr.position[1]-30, cdr.position[2], cdr.position[3]+12}, -- 5
                {cdr.position[1]-30, cdr.position[2], cdr.position[3]-12}, -- 3
            }
            aiBrain.ACUChampion.EnemyInArea = 0
            for index, pos in AreaTable do
                UnitT1 = aiBrain:GetNumUnitsAroundPoint( categories.DIRECTFIRE + categories.INDIRECTFIRE + categories.DEFENSE, pos, 25, 'Enemy' )
                aiBrain.ACUChampion.EnemyInArea = aiBrain.ACUChampion.EnemyInArea + UnitT1
                -- mimic the map border as enemy units, so the ACU will not get to close to the border
                if pos[1] <= playableArea[1] + 1 then                  -- left border
                    UnitT1 = 1
                elseif pos[1] >= playableArea[3] -1 then               -- right border
                    UnitT1 = 1
                end
                if pos[3] <= playableArea[2] + 1then                   -- top border
                    UnitT1 = 1
                elseif pos[3] >= playableArea[4] -1 then               -- bottom border
                    UnitT1 = 1
                end
                AreaTable[index][4] = UnitT1
            end
            aiBrain.ACUChampion.AreaTable = AreaTable

            coroutine.yield(1)

            -- Enemy tactical missile threat
            EnemyTML = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.TACTICALMISSILEPLATFORM)
            if EnemyTML then
                EnemyTMLPos = EnemyTML:GetPosition()
                -- in range ?
                if VDist2( cdr.position[1], cdr.position[3], EnemyTMLPos[1], EnemyTMLPos[3] ) < 256 then
                    --aiBrain.ACUChampion.EnemyTML = EnemyTML
                    aiBrain.ACUChampion.EnemyTMLPos = {EnemyTMLPos, cdr.position}
                else
                    aiBrain.ACUChampion.EnemyTMLPos = false
                end
            end

            coroutine.yield(1)

            -- Enemy Experimental threat
            EnemyExperimental = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.MOBILE * categories.EXPERIMENTAL)
            if EnemyExperimental then
                EnemyExperimentalPos = EnemyExperimental:GetPosition()
                UnitBlueprint = EnemyExperimental:GetBlueprint()
                MaxWeaponRange = false
                for _, weapon in UnitBlueprint.Weapon or {} do
                    -- filter dummy weapons
                    if weapon.Damage == 0 or weapon.WeaponCategory == 'Missile' or weapon.WeaponCategory == 'Teleport' then
                        continue
                    end
                    if not MaxWeaponRange or MaxWeaponRange < weapon.MaxRadius then
                        MaxWeaponRange = weapon.MaxRadius
                    end
                end
                -- in range ?
                aiBrain.ACUChampion.EnemyExperimentalPos = {EnemyExperimentalPos, cdr.position}
                aiBrain.ACUChampion.EnemyExperimentalWepRange = MaxWeaponRange
            else
                aiBrain.ACUChampion.EnemyExperimentalPos = false
                aiBrain.ACUChampion.EnemyExperimentalWepRange = false
            end

            coroutine.yield(1)

            -- Enemy Bomber/gunship threat
            numAirEnemyUnits = aiBrain:GetNumUnitsAroundPoint(categories.MOBILE * categories.AIR * (categories.BOMBER + categories.GROUNDATTACK) - categories.TECH1, Vector(playableArea[3]/2,0,playableArea[4]/2), playableArea[3]+playableArea[4] , 'Enemy')
            aiBrain.ACUChampion.numAirEnemyUnits = numAirEnemyUnits

            -- Enemy Experimental threat
            numExperimentalEnemyUnits = aiBrain:GetNumUnitsAroundPoint(categories.MOBILE * categories.EXPERIMENTAL, Vector(playableArea[3]/2,0,playableArea[4]/2), playableArea[3]+playableArea[4] , 'Enemy')
            aiBrain.ACUChampion.numExperimentalEnemyUnits = numExperimentalEnemyUnits

            -- Enemy T3 threat
            numT3EnemyUnits = aiBrain:GetNumUnitsAroundPoint(categories.MOBILE * categories.TECH3, Vector(playableArea[3]/2,0,playableArea[4]/2), playableArea[3]+playableArea[4] , 'Enemy')
            aiBrain.ACUChampion.numT3EnemyUnits = numT3EnemyUnits

        end
    end,

}
