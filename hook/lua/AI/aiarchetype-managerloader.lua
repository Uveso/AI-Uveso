local UvesoOffsetaiarchetypeLUA = debug.getinfo(1).currentline - 1
SPEW('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..UvesoOffsetaiarchetypeLUA..'] * AI-Uveso: offset aiarchetype-managerloader.lua')
--199

local Buff = import('/lua/sim/Buff.lua')
local HighestThreat = {}
local CanGraphAreaTo = import("/mods/AI-Uveso/lua/AI/AIMarkerGenerator.lua").CanGraphAreaTo

-- This hook is for debug-option Platoon-Names. Hook for all AI's
OldExecutePlanFunctionUveso = ExecutePlan
function ExecutePlan(aiBrain)
    if not aiBrain.Uveso then
        -- Debug for Platoon names
        if (aiBrain[ScenarioInfo.Options.AIPLatoonNameDebug] or ScenarioInfo.Options.AIPLatoonNameDebug == 'all') and not aiBrain.BuilderManagers.MAIN.FactoryManager:HasBuilderList() then
            aiBrain:ForkThread(AIPLatoonNameDebugThread, aiBrain)
        end
        -- execute the original function
        return OldExecutePlanFunctionUveso(aiBrain)
    end
    aiBrain:SetConstantEvaluate(false)
    coroutine.yield(10)
    if not aiBrain.BuilderManagers.MAIN.FactoryManager or not aiBrain.BuilderManagers.MAIN.FactoryManager:HasBuilderList() then
        -- we don't share resources with allies
        aiBrain:SetResourceSharing(false)
        --aiBrain:SetupUnderEnergyStatTrigger(0.1)
        --aiBrain:SetupUnderMassStatTrigger(0.1)
        SetupMainBase(aiBrain)
        -- Get units out of pool and assign them to the managers
        local mainManagers = aiBrain.BuilderManagers.MAIN
        local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
        for k,v in pool:GetPlatoonUnits() do
            if EntityCategoryContains(categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD, v) then
                mainManagers.EngineerManager:AddUnit(v)
            elseif EntityCategoryContains(categories.FACTORY * categories.STRUCTURE, v) then
                mainManagers.FactoryManager:AddFactory(v)
            end
        end
        aiBrain:ForkThread(LocationRangeManagerThread)     -- start after 30 seconds
        aiBrain:ForkThread(PriorityManagerThread)          -- start after 1 minute 10 seconds
        aiBrain:ForkThread(EcoManagerThread)               -- start after 4 minutes
        aiBrain:ForkThread(OpponentAIWatchThread)          -- start after 1 seconds
        -- init the Target Manager and HeatMap
        aiBrain:ForkThread(import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').AITargetManagerThread, aiBrain:GetArmyIndex())
    end
    if aiBrain.PBM then
        aiBrain:PBMSetEnabled(false)
    end
end

-- Uveso AI

function EcoManagerThread(aiBrain)
    -- Start Ecomanager at game minute 4
    while GetGameTimeSeconds() < 60*4 + aiBrain:GetArmyIndex() do
        coroutine.yield(10)
    end
    local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
    aiBrain.CheatMult = tonumber(ScenarioInfo.Options.CheatMult)
    aiBrain.BuildMult = tonumber(ScenarioInfo.Options.BuildMult)
    if aiBrain.CheatMult ~= aiBrain.BuildMult then
        aiBrain.CheatMult = math.max(aiBrain.CheatMult,aiBrain.BuildMult)
        aiBrain.BuildMult = math.max(aiBrain.CheatMult,aiBrain.BuildMult)
    end
    if aiBrain.CheatEnabled then
        AILog('* AI-Uveso: Function EcoManagerThread() started! - Cheat(eco)Factor:( '..repr(aiBrain.CheatMult)..' ) - BuildFactor:( '..repr(aiBrain.BuildMult)..' ) - ['..aiBrain.Nickname..']', true, UvesoOffsetaiarchetypeLUA)
    else
        AILog('* AI-Uveso: Function EcoManagerThread() started! - No Cheat(eco) or BuildFactor', true, UvesoOffsetaiarchetypeLUA)
    end
    local lastCall = 0
    local bussy
    -- Set all variables for the ecomanager
    local massNeed = math.floor(aiBrain:GetEconomyRequested('MASS') * 10)
    local massIncome = math.floor(aiBrain:GetEconomyIncome( 'MASS' ) * 10)
    local massTrend = massIncome - massNeed
    local energyNeed = math.floor(aiBrain:GetEconomyRequested('ENERGY') * 10)
    local energyIncome = math.floor(aiBrain:GetEconomyIncome( 'ENERGY' ) * 10)
    local energyTrend = energyIncome - energyNeed
    local safeguard
    -- splitted from table to single variables. (faster)
    local maxEnergyConsumptionUnitindex
    local maxEnergyConsumption
    local minEnergyConsumptionUnitindex
    local minEnergyConsumption
    local maxMassConsumptionUnitindex
    local maxMassConsumption
    local minMassConsumptionUnitindex
    local minMassConsumption
    local EcoUnits = {}
    local BasePanicZone, BaseMilitaryZone, BaseEnemyZone
    local baseposition
    local numUnitsPanicZone
    local AllUnits
    local time, energy, mass
    local function SetArmyPoolBuff(aiBrain, CheatMult, BuildMult)
        -- we are looping over all units with this, so we make it local
        local Buff = Buff
        -- Modify Buildrate buff
        local buffDef = Buffs['CheatBuildRate']
        local buffAffects = buffDef.Affects
        buffAffects.BuildRate.Mult = BuildMult
        -- Modify CheatIncome buff
        buffDef = Buffs['CheatIncome']
        buffAffects = buffDef.Affects
        buffAffects.EnergyProduction.Mult = CheatMult
        buffAffects.MassProduction.Mult = CheatMult
        allUnits = aiBrain:GetListOfUnits(categories.ALLUNITS, false, false)
        for _, unit in allUnits do
            -- Remove old build rate and income buffs
            Buff.RemoveBuff(unit, 'CheatIncome', true) -- true = removeAllCounts
            Buff.RemoveBuff(unit, 'CheatBuildRate', true) -- true = removeAllCounts
            -- Apply new build rate and income buffs
            Buff.ApplyBuff(unit, 'CheatIncome')
            Buff.ApplyBuff(unit, 'CheatBuildRate')
        end
    end
    while aiBrain.Status ~= "Defeat" do
        while not aiBrain:IsOpponentAIRunning() do
            coroutine.yield(10)
        end
        --AILog('* AI-Uveso: Function EcoManagerThread() beat. ['..aiBrain.Nickname..']')
        coroutine.yield(1)
        -- Cheatbuffs
        if personality == 'uvesooverwhelm' then
            -- Check every 60 seconds
            if (GetGameTimeSeconds() > ScenarioInfo.Options.AIOverwhelmDelay * 60) and lastCall+60 < GetGameTimeSeconds() then
                lastCall = GetGameTimeSeconds()
                aiBrain.CheatMult = aiBrain.CheatMult + ScenarioInfo.Options.AIOverwhelmIncrease  -- with the default of 0.025, +0.1 after 4 min. +1.0 after 40 min.
                aiBrain.BuildMult = aiBrain.BuildMult + ScenarioInfo.Options.AIOverwhelmIncrease
                if aiBrain.CheatMult > 8 then aiBrain.CheatMult = 8 end
                if aiBrain.BuildMult > 8 then aiBrain.BuildMult = 8 end
                AIDebug('Setting new values for ['..aiBrain.Nickname..'] aiBrain.CheatMult:'..aiBrain.CheatMult..' - aiBrain.BuildMult:'..aiBrain.BuildMult)
                SetArmyPoolBuff(aiBrain, aiBrain.CheatMult, aiBrain.BuildMult)
            end
        end
        -- Set all variables for the ecomanager
        massNeed = math.floor(aiBrain:GetEconomyRequested('MASS') * 10)
        massIncome = math.floor(aiBrain:GetEconomyIncome( 'MASS' ) * 10)
        massTrend = massIncome - massNeed
        energyNeed = math.floor(aiBrain:GetEconomyRequested('ENERGY') * 10)
        energyIncome = math.floor(aiBrain:GetEconomyIncome( 'ENERGY' ) * 10)
        energyTrend = energyIncome - energyNeed
        -- check if we have enemy units inside the base panic zone.
        BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetDangerZoneRadii()
        baseposition = aiBrain.BuilderManagers['MAIN'].FactoryManager.Location
        numUnitsPanicZone = aiBrain:GetNumUnitsAroundPoint(categories.MOBILE * categories.LAND - categories.SCOUT, baseposition, BasePanicZone, 'Enemy')
        -- ECO manager
        EcoUnits = {}
        bussy = false
        if aiBrain:GetEconomyStoredRatio('ENERGY') < 0.50 then
            AllUnits = aiBrain:GetListOfUnits( (categories.FACTORY - categories.TECH1) + (categories.ENGINEER - categories.POD) + categories.RADAR + categories.OMNI + categories.OPTICS + categories.SONAR + categories.OVERLAYCOUNTERINTEL + categories.COUNTERINTELLIGENCE + categories.MASSFABRICATION + (categories.ENGINEERSTATION - categories.STATIONASSISTPOD) + ((categories.NUKE + categories.TACTICALMISSILEPLATFORM) * categories.SILO ) - categories.COMMAND , false, false) -- also gets unbuilded units (planed to build)
            if energyTrend < 0 then
                --AllUnits = aiBrain:GetListOfUnits(categories.ALLUNITS - categories.COMMAND - categories.SHIELD - categories.MASSEXTRACTION, false, false) -- also gets unbuilded units (planed to build)
                for index, unit in AllUnits do
                    if unit.pausedMass or unit.pausedEnergy then continue end
                    -- filter units that are not finished
                    if unit:GetFractionComplete() < 1 then continue end
                    -- if we build massextractors or energyproduction, don't pause it
                    if unit.UnitBeingBuilt and EntityCategoryContains( ( categories.MASSEXTRACTION + (categories.ENERGYPRODUCTION - categories.EXPERIMENTAL) + categories.ENERGYSTORAGE ) , unit.UnitBeingBuilt) then
                        continue
                    end
                    -- if we build tech1 factories, don't pause it
                    if unit.UnitBeingBuilt and EntityCategoryContains( categories.FACTORY * categories.TECH1 , unit.UnitBeingBuilt) then
                        continue
                    end
                    -- if we build tech 1 units from a factory, don't pause it
                    if unit.UnitBeingBuilt and EntityCategoryContains( categories.MOBILE * categories.TECH1 , unit.UnitBeingBuilt) then
                        continue
                    end
                    -- don't pause any ACU assisting
                    if unit.UnitBeingAssist and EntityCategoryContains( categories.COMMAND, unit.UnitBeingAssist) then
                        continue
                    end
                    if personality == 'uvesorush' then
                        -- If we are rushing, never pause any factory building units
                        if unit.UnitBeingBuilt and EntityCategoryContains( categories.MOBILE, unit.UnitBeingBuilt ) then
                            continue
                        end
                        -- if we build or upgrade  factories, don't pause it
                        if unit.UnitBeingBuilt and EntityCategoryContains( categories.FACTORY, unit.UnitBeingBuilt) then
                            continue
                        end
                    end
                    if unit.pausedMass or unit.pausedEnergy then continue end
                    if EntityCategoryContains( (categories.NUKE + categories.TACTICALMISSILEPLATFORM) * categories.SILO, unit) then
                        -- siloBuildRate is only for debugging, we don't use it inside the code
                        --local siloBuildRate = unit:GetBuildRate() or 1
                        time, energy, mass = unit:GetBuildCosts(unit.SiloProjectile)
--                        AILog('* AI-Uveso: ECO Buildcost time '..time..' - mass '..mass..' - energy '..energy..' - siloBuildRate '..siloBuildRate)
                        energy = (energy / time)
                        mass = (mass / time)
--                        AILog('* AI-Uveso: ECO Buildcost time '..time..' - mass '..mass..' - energy '..energy..' - siloBuildRate '..siloBuildRate)
                        unit.ConsumptionPerSecondEnergy = energy
                    else
                        unit.ConsumptionPerSecondEnergy = unit:GetConsumptionPerSecondEnergy()
                    end
                    if unit.ConsumptionPerSecondEnergy > 0 then
                        table.insert(EcoUnits, unit)
                    end
                end
                -- Disable units until energytrend is positive
                safeguard = table.getn(EcoUnits)
                while energyTrend < 0 do
                    -- find unit with most energy consumption
                    maxEnergyConsumptionUnitindex = nil
                    maxEnergyConsumption = nil
                    if EcoUnits[1] then
                        for index, unit in EcoUnits do
                            if unit.pausedMass or unit.pausedEnergy then continue end
                            if not maxEnergyConsumption or maxEnergyConsumption < unit.ConsumptionPerSecondEnergy then
                                maxEnergyConsumption = unit.ConsumptionPerSecondEnergy
                                maxEnergyConsumptionUnitindex = index
                            end
                        end
                    else
                        break
                    end
                    if maxEnergyConsumptionUnitindex then
--                        AILog(' ')
--                        AILog('* AI-Uveso: ECO energyTrend < 0  ('..energyTrend..')')
                        bussy = true
                        energyTrend = energyTrend + maxEnergyConsumption
                        if EntityCategoryContains(categories.FACTORY + (categories.ENGINEER - categories.POD) + (categories.ENGINEERSTATION - categories.STATIONASSISTPOD) + ((categories.NUKE + categories.TACTICALMISSILEPLATFORM) * categories.SILO), EcoUnits[maxEnergyConsumptionUnitindex]) then
--                            AILog('* AI-Uveso: ECO ['..EcoUnits[maxEnergyConsumptionUnitindex].UnitId..'] ('..LOC(EcoUnits[maxEnergyConsumptionUnitindex].Blueprint.Description)..') unit:SetPaused( true ) Saving ('..maxEnergyConsumption..') energy')
                            EcoUnits[maxEnergyConsumptionUnitindex]:SetPaused( true )
                            EcoUnits[maxEnergyConsumptionUnitindex].pausedEnergy = true
                            EcoUnits[maxEnergyConsumptionUnitindex].managed = true
                        elseif EntityCategoryContains(categories.RADAR + categories.OMNI + categories.OPTICS + categories.SONAR + categories.COUNTERINTELLIGENCE, EcoUnits[maxEnergyConsumptionUnitindex]) then
--                            AILog('* AI-Uveso: ECO ['..EcoUnits[maxEnergyConsumptionUnitindex].UnitId..'] ('..LOC(EcoUnits[maxEnergyConsumptionUnitindex].Blueprint.Description)..') unit:SetScriptBit( IntelToggle, true ) Saving ('..maxEnergyConsumption..') energy')
                            EcoUnits[maxEnergyConsumptionUnitindex]:SetScriptBit('RULEUTC_IntelToggle', true)
                            EcoUnits[maxEnergyConsumptionUnitindex].pausedEnergy = true
                            EcoUnits[maxEnergyConsumptionUnitindex].managed = true
                        elseif EntityCategoryContains(categories.MASSFABRICATION, EcoUnits[maxEnergyConsumptionUnitindex]) then
--                            AILog('* AI-Uveso: ECO ['..EcoUnits[maxEnergyConsumptionUnitindex].UnitId..'] ('..LOC(EcoUnits[maxEnergyConsumptionUnitindex].Blueprint.Description)..') unit:SetScriptBit( ProductionToggle, true ) Saving ('..maxEnergyConsumption..') energy')
                            EcoUnits[maxEnergyConsumptionUnitindex]:SetScriptBit('RULEUTC_ProductionToggle', true)
                            EcoUnits[maxEnergyConsumptionUnitindex].pausedEnergy = true
                            EcoUnits[maxEnergyConsumptionUnitindex].managed = true
                        elseif EntityCategoryContains(categories.OVERLAYCOUNTERINTEL + categories.COUNTERINTELLIGENCE, EcoUnits[maxEnergyConsumptionUnitindex]) then
--                            AILog('* AI-Uveso: ECO ['..EcoUnits[maxEnergyConsumptionUnitindex].UnitId..'] ('..LOC(EcoUnits[maxEnergyConsumptionUnitindex].Blueprint.Description)..') unit:SetScriptBit( JammingToggle, true ) Saving ('..maxEnergyConsumption..') energy')
                            EcoUnits[maxEnergyConsumptionUnitindex]:SetScriptBit('RULEUTC_JammingToggle', true)
                            EcoUnits[maxEnergyConsumptionUnitindex].pausedEnergy = true
                            EcoUnits[maxEnergyConsumptionUnitindex].managed = true
                        else
                            AIWarn('* AI-Uveso: Unit with unknown Category('..LOC(EcoUnits[maxEnergyConsumptionUnitindex].Blueprint.Description)..') ['..EcoUnits[maxEnergyConsumptionUnitindex].UnitId..']', true, UvesoOffsetaiarchetypeLUA)
                        end
                    else
--                        AIDebug('* AI-Uveso: ECO cant pause any unit. break!')
                        break
                    end
--                    AILog('* AI-Uveso: ECO new energyTrend = '..energyTrend..'')
                    -- Never remove this safeguard! Modded units can screw it up and cause a DeadLoop!!!
                    safeguard = safeguard - 1
                    if safeguard < 0 then
                        AIWarn('* AI-Uveso: ECO E safeguard < 0', true, UvesoOffsetaiarchetypeLUA)
                        break
                    end
                end
--                if bussy then
--                    coroutine.yield(5)
--                    energyNeed = math.floor(aiBrain:GetEconomyRequested('ENERGY') * 10)
--                    energyIncome = math.floor(aiBrain:GetEconomyIncome( 'ENERGY' ) * 10)
--                    energyTrendCheck = energyIncome - energyNeed
--                    AILog('*ECO energyTrendCheck = '..energyTrendCheck..'')
--                end
            end
        end
        coroutine.yield(1)
        if bussy then
            --AIWarn('* AI-Uveso: ECOmanager low energy is bussy')
            continue -- while true do
        end
        EcoUnits = {}
        if aiBrain:GetEconomyStoredRatio('ENERGY') >= 0.50 then
            AllUnits = aiBrain:GetListOfUnits( (categories.FACTORY - categories.TECH1) + (categories.ENGINEER - categories.POD) + categories.RADAR + categories.OMNI + categories.OPTICS + categories.SONAR + categories.OVERLAYCOUNTERINTEL + categories.COUNTERINTELLIGENCE + categories.MASSFABRICATION + (categories.ENGINEERSTATION - categories.STATIONASSISTPOD) + ((categories.NUKE + categories.TACTICALMISSILEPLATFORM) * categories.SILO ) - categories.COMMAND , false, false) -- also gets unbuilded units (planed to build)
--            AILog('* AI-Uveso: ECO conomyStoredRatio(ENERGY) > 0.50')
            if energyTrend > 0 then
                --AllUnits = aiBrain:GetListOfUnits(categories.ALLUNITS - categories.COMMAND - categories.SHIELD - categories.MASSEXTRACTION, false, false) -- also gets unbuilded units (planed to build)
                for index, unit in AllUnits do
                    if not unit.pausedEnergy then continue end
                    -- filter units that are not finished
                    if unit:GetFractionComplete() < 1 then continue end
--                    AILog('* AI-Uveso: ECO checking unit ['..index..']  paused:('..repr(unit.pausedMass)..'/'..repr(unit.pausedEnergy)..') '..LOC(unit.Blueprint.Description))
                    if unit.ConsumptionPerSecondEnergy > 0 then
--                        AILog('* AI-Uveso: ECO Adding unit ['..index..'] to table '..LOC(unit.Blueprint.Description))
                        table.insert(EcoUnits, unit)
                    end
                end
                -- Enable units until energytrend is negative
                safeguard = table.getn(EcoUnits)
                while energyTrend > 0 do
--                    AIDebug('* AI-Uveso: ECO safeguard = '..safeguard)
                    -- find unit with most energy consumption
                    minEnergyConsumptionUnitindex = nil
                    minEnergyConsumption = nil
                    if EcoUnits[1] then
                        for index, unit in EcoUnits do
                            if not unit.pausedEnergy then continue end
                            if not minEnergyConsumption or minEnergyConsumption > unit.ConsumptionPerSecondEnergy then
                                minEnergyConsumption = unit.ConsumptionPerSecondEnergy
                                minEnergyConsumptionUnitindex = index
                            end
                        end
                    else
                        break
                    end
                    if minEnergyConsumptionUnitindex then
--                        AILog(' ')
--                        AILog('* AI-Uveso: ECO energyTrend > 0  ('..energyTrend..')')
                        energyTrend = energyTrend - minEnergyConsumption
                        bussy = true
                        if EntityCategoryContains(categories.FACTORY + (categories.ENGINEER - categories.POD) + (categories.ENGINEERSTATION - categories.STATIONASSISTPOD + ((categories.NUKE + categories.TACTICALMISSILEPLATFORM) * categories.SILO)), EcoUnits[minEnergyConsumptionUnitindex]) then
--                            AILog('* AI-Uveso: ECO ['..EcoUnits[minEnergyConsumptionUnitindex].UnitId..'] ('..LOC(EcoUnits[minEnergyConsumptionUnitindex].Blueprint.Description)..') unit:SetPaused( false ) Consuming ('..minEnergyConsumption..') energy')
                            EcoUnits[minEnergyConsumptionUnitindex]:SetPaused( false )
                            EcoUnits[minEnergyConsumptionUnitindex].pausedEnergy = false
                            EcoUnits[minEnergyConsumptionUnitindex].managed = true
                        elseif EntityCategoryContains(categories.RADAR + categories.OMNI + categories.OPTICS + categories.SONAR + categories.COUNTERINTELLIGENCE, EcoUnits[minEnergyConsumptionUnitindex]) then
--                            AILog('* AI-Uveso: ECO ['..EcoUnits[minEnergyConsumptionUnitindex].UnitId..'] ('..LOC(EcoUnits[minEnergyConsumptionUnitindex].Blueprint.Description)..') unit:SetScriptBit( IntelToggle, false ) Consuming ('..minEnergyConsumption..') energy')
                            EcoUnits[minEnergyConsumptionUnitindex]:SetScriptBit('RULEUTC_IntelToggle', false)
                            EcoUnits[minEnergyConsumptionUnitindex].pausedEnergy = false
                            EcoUnits[minEnergyConsumptionUnitindex].managed = true
                        elseif EntityCategoryContains(categories.MASSFABRICATION, EcoUnits[minEnergyConsumptionUnitindex]) then
--                            AILog('* AI-Uveso: ECO ['..EcoUnits[minEnergyConsumptionUnitindex].UnitId..'] ('..LOC(EcoUnits[minEnergyConsumptionUnitindex].Blueprint.Description)..') unit:SetScriptBit( ProductionToggle, false ) Consuming ('..minEnergyConsumption..') energy')
                            EcoUnits[minEnergyConsumptionUnitindex]:SetScriptBit('RULEUTC_ProductionToggle', false)
                            EcoUnits[minEnergyConsumptionUnitindex].pausedEnergy = false
                            EcoUnits[minEnergyConsumptionUnitindex].managed = true
                        elseif EntityCategoryContains(categories.OVERLAYCOUNTERINTEL + categories.COUNTERINTELLIGENCE, EcoUnits[minEnergyConsumptionUnitindex]) then
--                            AILog('* AI-Uveso: ECO ['..EcoUnits[minEnergyConsumptionUnitindex].UnitId..'] ('..LOC(EcoUnits[minEnergyConsumptionUnitindex].Blueprint.Description)..') unit:SetScriptBit( JammingToggle, false ) Consuming ('..minEnergyConsumption..') energy')
                            EcoUnits[minEnergyConsumptionUnitindex]:SetScriptBit('RULEUTC_JammingToggle', false)
                            EcoUnits[minEnergyConsumptionUnitindex].pausedEnergy = false
                            EcoUnits[minEnergyConsumptionUnitindex].managed = true
                        else
                            AIWarn('* AI-Uveso: Unit with unknown Category('..LOC(EcoUnits[minEnergyConsumptionUnitindex].Blueprint.Description)..') ['..EcoUnits[minEnergyConsumptionUnitindex].UnitId..']', true, UvesoOffsetaiarchetypeLUA)
                        end
--                            EcoUnits[minEnergyConsumptionUnitindex]:OnProductionUnpaused()
--                            EcoUnits[minEnergyConsumptionUnitindex]:SetActiveConsumptionActive()
                    else
--                        AIDebug('* AI-Uveso: ECO cant activate any unit. break!')
                        break
                    end
--                    AILog('* AI-Uveso: ECO new energyTrend = '..energyTrend..'')
                    -- Never remove this safeguard! Modded units can screw it up and cause a DeadLoop!!!
                    safeguard = safeguard - 1
                    if safeguard < 0 then
                        AIWarn('* AI-Uveso: ECO E safeguard > 0', true, UvesoOffsetaiarchetypeLUA)
                        break
                    end
                end
--                if bussy then
--                    coroutine.yield(5)
--                    energyNeed = math.floor(aiBrain:GetEconomyRequested('ENERGY') * 10)
--                    energyIncome = math.floor(aiBrain:GetEconomyIncome( 'ENERGY' ) * 10)
--                    energyTrendCheck = energyIncome - energyNeed
--                    AILog('*ECO energyTrendCheck = '..energyTrendCheck..'')
--                end
            end
        end
        coroutine.yield(1)
        if bussy then
            --AIWarn('* AI-Uveso: ECOmanager high energy is bussy')
            continue -- while true do
        end
        EcoUnits = {}
        if aiBrain:GetEconomyStoredRatio('MASS') < 0.15 then
            --AllUnits = aiBrain:GetListOfUnits( (categories.FACTORY - categories.TECH1) + (categories.ENGINEER - categories.POD) + categories.RADAR + categories.OMNI + categories.OPTICS + categories.SONAR + categories.OVERLAYCOUNTERINTEL + categories.COUNTERINTELLIGENCE + categories.MASSFABRICATION + (categories.ENGINEERSTATION - categories.STATIONASSISTPOD) + ((categories.NUKE + categories.TACTICALMISSILEPLATFORM) * categories.SILO ) - categories.COMMAND , false, false) -- also gets unbuilded units (planed to build)
            AllUnits = aiBrain:GetListOfUnits( (categories.ENGINEER - categories.POD) + categories.RADAR + categories.OMNI + categories.OPTICS + categories.SONAR + categories.OVERLAYCOUNTERINTEL + categories.COUNTERINTELLIGENCE + categories.MASSFABRICATION + (categories.ENGINEERSTATION - categories.STATIONASSISTPOD) + ((categories.NUKE + categories.TACTICALMISSILEPLATFORM) * categories.SILO ) - categories.COMMAND , false, false) -- also gets unbuilded units (planed to build)
            if massTrend < 0 then
                --AllUnits = aiBrain:GetListOfUnits(categories.ALLUNITS - categories.COMMAND - categories.SHIELD - categories.MASSEXTRACTION, false, false) -- also gets unbuilded units (planed to build)
                for index, unit in AllUnits do
                    if unit.pausedMass or unit.pausedEnergy then continue end
                    -- filter units that are not finished
                    if unit:GetFractionComplete() < 1 then continue end
                    -- if we build massextractors or energyproduction, don't pause it
                    if unit.UnitBeingBuilt and EntityCategoryContains( ( categories.MASSEXTRACTION + (categories.ENERGYPRODUCTION - categories.EXPERIMENTAL) + categories.ENERGYSTORAGE ) , unit.UnitBeingBuilt) then
                        continue
                    end
                    -- if we build tech1 factories, don't pause it
                    if unit.UnitBeingBuilt and EntityCategoryContains( categories.FACTORY * categories.TECH1 , unit.UnitBeingBuilt) then
                        continue
                    end
                    -- if we build tech 1 units from a factory, don't pause it
                    if unit.UnitBeingBuilt and EntityCategoryContains( categories.MOBILE * categories.TECH1 , unit.UnitBeingBuilt) then
                        continue
                    end
                    -- don't pause any ACU assisting
                    if unit.UnitBeingAssist and EntityCategoryContains( categories.COMMAND, unit.UnitBeingAssist) then
                        continue
                    end
                    if personality == 'uvesorush' then
                        -- If we are rushing, never pause any factory building units
                        if unit.UnitBeingBuilt and EntityCategoryContains( categories.MOBILE, unit.UnitBeingBuilt ) then
                            continue
                        end
                        -- if we build or upgrade  factories, don't pause it
                        if unit.UnitBeingBuilt and EntityCategoryContains( categories.FACTORY, unit.UnitBeingBuilt) then
                            continue
                        end
                    end
                    unit.ConsumptionPerSecondMass = unit:GetConsumptionPerSecondMass()
                    if unit.ConsumptionPerSecondMass > 0 then
--                        AILog('* AI-Uveso: ECO Adding unit ['..index..'] to table '..LOC(unit.Blueprint.Description))
                        table.insert(EcoUnits, unit)
                    end
                end
                -- Disable units until massTrend is positive
                safeguard = table.getn(EcoUnits)
                while massTrend < 0 do
                    -- find unit with most mass consumption
                    maxMassConsumptionUnitindex = nil
                    maxMassConsumption = nil
                    if EcoUnits[1] then
                        for index, unit in EcoUnits do
                            -- Don't pause factories if we have enemies inside the Paniczone
                            if numUnitsPanicZone > 0 and EntityCategoryContains( categories.FACTORY, unit) then continue end
                            if unit.pausedMass or unit.pausedEnergy then continue end
                            if not maxMassConsumption or maxMassConsumption < unit.ConsumptionPerSecondMass then
                                maxMassConsumption = unit.ConsumptionPerSecondMass
                                maxMassConsumptionUnitindex = index
                            end
                        end
                    else
--                        AILog('* AI-Uveso: ECO low mass; EcoUnits empty array. break!')
                        break
                    end
                    if maxMassConsumptionUnitindex then
--                        AILog(' ')
--                        AILog('* AI-Uveso: ECO massTrend < 0  ('..massTrend..')')
                        bussy = true
                        massTrend = massTrend + maxMassConsumption
                        if EntityCategoryContains(categories.FACTORY + categories.ENGINEER + (categories.ENGINEERSTATION - categories.STATIONASSISTPOD + ((categories.NUKE + categories.TACTICALMISSILEPLATFORM) * categories.SILO)), EcoUnits[maxMassConsumptionUnitindex]) then
--                            AILog('* AI-Uveso: ECO ['..EcoUnits[maxMassConsumptionUnitindex].UnitId..'] ('..LOC(EcoUnits[maxMassConsumptionUnitindex].Blueprint.Description)..') unit:SetPaused( true ) Saving ('..maxMassConsumption..') mass')
                            EcoUnits[maxMassConsumptionUnitindex]:SetPaused( true )
                            EcoUnits[maxMassConsumptionUnitindex].pausedMass = true
                            EcoUnits[maxMassConsumptionUnitindex].managed = true
                        elseif EntityCategoryContains(categories.RADAR + categories.OMNI + categories.OPTICS + categories.SONAR + categories.COUNTERINTELLIGENCE, EcoUnits[maxMassConsumptionUnitindex]) then
--                            AILog('* AI-Uveso: ECO ['..EcoUnits[maxMassConsumptionUnitindex].UnitId..'] ('..LOC(EcoUnits[maxMassConsumptionUnitindex].Blueprint.Description)..') unit:SetScriptBit( IntelToggle, true ) Saving ('..maxMassConsumption..') mass')
                            EcoUnits[maxMassConsumptionUnitindex]:SetScriptBit('RULEUTC_IntelToggle', true)
                            EcoUnits[maxMassConsumptionUnitindex].pausedMass = true
                            EcoUnits[maxMassConsumptionUnitindex].managed = true
                        elseif EntityCategoryContains(categories.MASSFABRICATION, EcoUnits[maxMassConsumptionUnitindex]) then
--                            AILog('* AI-Uveso: ECO ['..EcoUnits[maxMassConsumptionUnitindex].UnitId..'] ('..LOC(EcoUnits[maxMassConsumptionUnitindex].Blueprint.Description)..') unit:SetScriptBit( ProductionToggle, true ) Saving ('..maxMassConsumption..') mass')
                            EcoUnits[maxMassConsumptionUnitindex]:SetScriptBit('RULEUTC_ProductionToggle', true)
                            EcoUnits[maxMassConsumptionUnitindex].pausedMass = true
                            EcoUnits[maxMassConsumptionUnitindex].managed = true
                        elseif EntityCategoryContains(categories.OVERLAYCOUNTERINTEL + categories.COUNTERINTELLIGENCE, EcoUnits[maxMassConsumptionUnitindex]) then
--                            AILog('* AI-Uveso: ECO ['..EcoUnits[maxMassConsumptionUnitindex].UnitId..'] ('..LOC(EcoUnits[maxMassConsumptionUnitindex].Blueprint.Description)..') unit:SetScriptBit( JammingToggle, true ) Saving ('..maxMassConsumption..') mass')
                            EcoUnits[maxMassConsumptionUnitindex]:SetScriptBit('RULEUTC_JammingToggle', true)
                            EcoUnits[maxMassConsumptionUnitindex].pausedMass = true
                            EcoUnits[maxMassConsumptionUnitindex].managed = true
                        else
                            AIWarn('* AI-Uveso: Unit with unknown Category('..LOC(EcoUnits[maxMassConsumptionUnitindex].Blueprint.Description)..') ['..EcoUnits[maxMassConsumptionUnitindex].UnitId..']', true, UvesoOffsetaiarchetypeLUA)
                        end
                    else
--                        AIDebug('* AI-Uveso: ECO cant pause any unit. break!')
                        break
                    end
--                    AILog('*ECO new massTrend = '..massTrend..'')
                    -- Never remove this safeguard! Modded units can screw it up and cause a DeadLoop!!!
                    safeguard = safeguard - 1
                    if safeguard < 0 then
                        AIWarn('* AI-Uveso: ECO M safeguard < 0', true, UvesoOffsetaiarchetypeLUA)
                        break
                    end
                end
--                if bussy then
--                    coroutine.yield(5)
--                    massNeed = math.floor(aiBrain:GetEconomyRequested('MASS') * 10)
--                    massIncome = math.floor(aiBrain:GetEconomyIncome( 'MASS' ) * 10)
--                    massTrendCheck = massIncome - massNeed
--                    AILog('* AI-Uveso: ECO massTrendCheck = '..massTrendCheck..'')
--                end
            end
        end
        coroutine.yield(1)
        if bussy then
            --AIWarn('* AI-Uveso: ECOmanager low mass is bussy')
            continue -- while true do
        end
        EcoUnits = {}
        if aiBrain:GetEconomyStoredRatio('MASS') >= 0.15 then
            AllUnits = aiBrain:GetListOfUnits( (categories.FACTORY - categories.TECH1) + (categories.ENGINEER - categories.POD) + categories.RADAR + categories.OMNI + categories.OPTICS + categories.SONAR + categories.OVERLAYCOUNTERINTEL + categories.COUNTERINTELLIGENCE + categories.MASSFABRICATION + (categories.ENGINEERSTATION - categories.STATIONASSISTPOD) + ((categories.NUKE + categories.TACTICALMISSILEPLATFORM) * categories.SILO ) - categories.COMMAND , false, false) -- also gets unbuilded units (planed to build)
            if massTrend > 0 then
                --AllUnits = aiBrain:GetListOfUnits(categories.ALLUNITS - categories.COMMAND - categories.SHIELD - categories.MASSEXTRACTION, false, false) -- also gets unbuilded units (planed to build)
                for index, unit in AllUnits do
                    if not unit.pausedMass then continue end
                    -- filter units that are not finished
                    if unit:GetFractionComplete() < 1 then continue end
--                    AILog('* AI-Uveso: ECO checking unit ['..index..']  paused:('..repr(unit.pausedMass)..'/'..repr(unit.pausedEnergy)..') '..LOC(unit.Blueprint.Description))
                    if unit.ConsumptionPerSecondMass > 0 then
--                        AILog('* AI-Uveso: ECO Adding unit ['..index..'] to table '..LOC(unit.Blueprint.Description))
                        table.insert(EcoUnits, unit)
                    end
                end
                -- Enable units until massTrend is negative
                safeguard = table.getn(EcoUnits)
                while massTrend > 0 do
--                    AIDebug('* AI-Uveso: ECO safeguard = '..safeguard)
                    -- find unit with most mass consumption
                    minMassConsumptionUnitindex = nil
                    minMassConsumption = nil
                    if EcoUnits[1] then
                        for index, unit in EcoUnits do
                            if not unit.pausedMass then continue end
                            if not minMassConsumption or minMassConsumption > unit.ConsumptionPerSecondMass then
                                minMassConsumption = unit.ConsumptionPerSecondMass
                                minMassConsumptionUnitindex = index
                            end
                        end
                    else
--                        AILog('* AI-Uveso: ECO high mass; EcoUnits empty array ')
                        break
                    end
                    if minMassConsumptionUnitindex then
--                        AILog(' ')
--                        AILog('* AI-Uveso: ECO massTrend > 0  ('..massTrend..')')
                        massTrend = massTrend - minMassConsumption
                        bussy = true
                        if EntityCategoryContains(categories.FACTORY + (categories.ENGINEER - categories.POD) + (categories.ENGINEERSTATION - categories.STATIONASSISTPOD + ((categories.NUKE + categories.TACTICALMISSILEPLATFORM) * categories.SILO)), EcoUnits[minMassConsumptionUnitindex]) then
--                            AILog('* AI-Uveso: ECO ['..EcoUnits[minMassConsumptionUnitindex].UnitId..'] ('..LOC(EcoUnits[minMassConsumptionUnitindex].Blueprint.Description)..') unit:SetPaused( false ) Consuming ('..minMassConsumption..') mass')
                            EcoUnits[minMassConsumptionUnitindex]:SetPaused( false )
                            EcoUnits[minMassConsumptionUnitindex].pausedMass = false
                            EcoUnits[minMassConsumptionUnitindex].managed = true
                        elseif EntityCategoryContains(categories.RADAR + categories.OMNI + categories.OPTICS + categories.SONAR + categories.COUNTERINTELLIGENCE, EcoUnits[minMassConsumptionUnitindex]) then
--                            AILog('* AI-Uveso: ECO ['..EcoUnits[minMassConsumptionUnitindex].UnitId..'] ('..LOC(EcoUnits[minMassConsumptionUnitindex].Blueprint.Description)..') unit:SetScriptBit( IntelToggle, false ) Consuming ('..minMassConsumption..') mass')
                            EcoUnits[minMassConsumptionUnitindex]:SetScriptBit('RULEUTC_IntelToggle', false)
                            EcoUnits[minMassConsumptionUnitindex].pausedMass = false
                            EcoUnits[minMassConsumptionUnitindex].managed = true
                        elseif EntityCategoryContains(categories.MASSFABRICATION, EcoUnits[minMassConsumptionUnitindex]) then
--                            AILog('* AI-Uveso: ECO ['..EcoUnits[minMassConsumptionUnitindex].UnitId..'] ('..LOC(EcoUnits[minMassConsumptionUnitindex].Blueprint.Description)..') unit:SetScriptBit( ProductionToggle, false ) Consuming ('..minMassConsumption..') mass')
                            EcoUnits[minMassConsumptionUnitindex]:SetScriptBit('RULEUTC_ProductionToggle', false)
                            EcoUnits[minMassConsumptionUnitindex].pausedMass = false
                            EcoUnits[minMassConsumptionUnitindex].managed = true
                        elseif EntityCategoryContains(categories.OVERLAYCOUNTERINTEL + categories.COUNTERINTELLIGENCE, EcoUnits[minMassConsumptionUnitindex]) then
--                            AILog('* AI-Uveso: ECO ['..EcoUnits[minMassConsumptionUnitindex].UnitId..'] ('..LOC(EcoUnits[minMassConsumptionUnitindex].Blueprint.Description)..') unit:SetScriptBit( JammingToggle, false ) Consuming ('..minMassConsumption..') mass')
                            EcoUnits[minMassConsumptionUnitindex]:SetScriptBit('RULEUTC_JammingToggle', false)
                            EcoUnits[minMassConsumptionUnitindex].pausedMass = false
                            EcoUnits[minMassConsumptionUnitindex].managed = true
                        else
                            AIWarn('* AI-Uveso: Unit with unknown Category('..LOC(EcoUnits[minMassConsumptionUnitindex].Blueprint.Description)..') ['..EcoUnits[minMassConsumptionUnitindex].UnitId..']', true, UvesoOffsetaiarchetypeLUA)
                        end
--                            EcoUnits[minMassConsumptionUnitindex]:OnProductionUnpaused()
--                            EcoUnits[minMassConsumptionUnitindex]:SetActiveConsumptionActive()
                    else
--                        AIDebug('* AI-Uveso: ECO cant activate any unit. break!')
                        break
                    end
--                    AILog('* AI-Uveso: ECO new massTrend = '..massTrend..'')
                    -- Never remove this safeguard! Modded units can screw it up and cause a DeadLoop!!!
                    safeguard = safeguard - 1
                    if safeguard < 0 then
                        AIWarn('* AI-Uveso: ECO M safeguard > 0', true, UvesoOffsetaiarchetypeLUA)
                        break
                    end
                end
--                if bussy then
--                    coroutine.yield(5)
--                    massNeed = math.floor(aiBrain:GetEconomyRequested('MASS') * 10)
--                    massIncome = math.floor(aiBrain:GetEconomyIncome( 'MASS' ) * 10)
--                    massTrendCheck = massIncome - massNeed
--                    AILog('* AI-Uveso: ECO massTrendCheck = '..massTrendCheck..'')
--                end
            end
        end
        coroutine.yield(1)
        if bussy then
            --AIWarn('* AI-Uveso: ECOmanager high mass is bussy')
            continue -- while true do
        end
        EcoUnits = {}
        if aiBrain:GetEconomyStoredRatio('ENERGY') >= 0.60 and aiBrain:GetEconomyStoredRatio('MASS') >= 0.20 then
            AllUnits = aiBrain:GetListOfUnits( (categories.FACTORY - categories.TECH1) + (categories.ENGINEER - categories.POD) + categories.RADAR + categories.OMNI + categories.OPTICS + categories.SONAR + categories.OVERLAYCOUNTERINTEL + categories.COUNTERINTELLIGENCE + categories.MASSFABRICATION + (categories.ENGINEERSTATION - categories.STATIONASSISTPOD) + ((categories.NUKE + categories.TACTICALMISSILEPLATFORM) * categories.SILO ) - categories.COMMAND , false, false) -- also gets unbuilded units (planed to build)
            for index, unit in AllUnits do
                if not unit.managed then
                    continue
                end
                -- filter units that are not finished
                if unit:GetFractionComplete() < 1 then continue end
                if EntityCategoryContains(categories.FACTORY + (categories.ENGINEER - categories.POD) + (categories.ENGINEERSTATION - categories.STATIONASSISTPOD + ((categories.NUKE + categories.TACTICALMISSILEPLATFORM) * categories.SILO)), unit) then
                    unit:SetPaused( false )
                    unit.pausedMass = false
                    unit.pausedEnergy = false
                    unit.managed = false
                elseif EntityCategoryContains(categories.RADAR + categories.OMNI + categories.OPTICS + categories.SONAR + categories.COUNTERINTELLIGENCE, unit) then
                    unit:SetScriptBit('RULEUTC_IntelToggle', false)
                    unit.pausedMass = false
                    unit.pausedEnergy = false
                    unit.managed = false
                elseif EntityCategoryContains(categories.MASSFABRICATION, unit) then
                    unit:SetScriptBit('RULEUTC_ProductionToggle', false)
                    unit.pausedMass = false
                    unit.pausedEnergy = false
                    unit.managed = false
                elseif EntityCategoryContains(categories.OVERLAYCOUNTERINTEL + categories.COUNTERINTELLIGENCE, unit) then
                    unit:SetScriptBit('RULEUTC_JammingToggle', false)
                    unit.pausedMass = false
                    unit.pausedEnergy = false
                    unit.managed = false
                else
                    AIWarn('* AI-Uveso: Unit with unknown Category('..LOC(unit.Blueprint.Description)..') ['..unit.UnitId..']', true, UvesoOffsetaiarchetypeLUA)
                    unit:SetPaused( false )
                    unit.pausedMass = false
                    unit.pausedEnergy = false
                    unit.managed = false
                end
                -- we only check 1 unit per tick.
                break -- for index, unit in AllUnits do
            end
        end
    end
end

function AIPLatoonNameDebugThread(aiBrain)
    local Plan
    local Builder
    while aiBrain.Status ~= "Defeat" do
        coroutine.yield(50)
        ArmyUnits = aiBrain:GetListOfUnits(categories.MOBILE - categories.MOBILESONAR, false, false) -- also gets unbuilded units (planed to build)
        for _, unit in ArmyUnits do
            if unit.Dead then
                continue
            end
            if unit.PlatoonHandle then
                Plan = unit.PlatoonHandle.PlanName
                Builder = unit.PlatoonHandle.BuilderName
                if Plan or Builder then
                    unit:SetCustomName(''..(Builder or 'Unknown'))
                    unit.LastPlatoonHandle = {}
                    unit.LastPlatoonHandle.PlanName = unit.PlatoonHandle.PlanName
                    unit.LastPlatoonHandle.BuilderName = unit.PlatoonHandle.BuilderName
                end
            else
                unit:SetCustomName('Pool')
            end
        end
    end
end

function LocationRangeManagerThread(aiBrain)
    AIDebug('* AI-Uveso: Function LocationRangeManagerThread() started. ['..aiBrain.Nickname..']', true, UvesoOffsetaiarchetypeLUA)
    local unitcounterdelayer = 0
    local ArmyUnits = {}
    -- wait at start of the game for delayed AI message
    while GetGameTimeSeconds() < 15 + aiBrain:GetArmyIndex() do
        coroutine.yield(10)
    end
    if not import('/lua/AI/sorianutilities.lua').CheckForMapMarkers(aiBrain) then
        import('/lua/AI/sorianutilities.lua').AISendChat('all', ArmyBrains[aiBrain:GetArmyIndex()].Nickname, 'badmap')
    end
    local BasePositions, LoopDelay
    local Plan, WeAreInRange, nearestbase
    local Builder, UnitPos, NeedNavalBase, MaxCap

    while aiBrain.Status ~= "Defeat" do
        while not aiBrain:IsOpponentAIRunning() do
            coroutine.yield(10)
        end
        coroutine.yield(50)
        --AILog('* AI-Uveso: Function LocationRangeManagerThread() beat. ['..aiBrain.Nickname..']')
        -- Check and set the location radius of our main base and expansions
        BasePositions = BaseRanger(aiBrain)
        -- Check if we have units outside the range of any BaseManager
        -- Get all units from our ArmyPool. These are units without a special platoon or task. They have nothing to do.
        ArmyUnits = aiBrain:GetListOfUnits(categories.MOBILE - categories.MOBILESONAR, false, false) -- also gets unbuilded units (planed to build)
        -- Loop over every unit that has no platton and is idle
        LoopDelay = 0
        for _, unit in ArmyUnits do
            if unit.Dead then
                continue
            end
            -- check if we have name debugging enabled (ScenarioInfo.Options.AIPLatoonNameDebug = Uveso or Sorian or Dilli)
            if (aiBrain[ScenarioInfo.Options.AIPLatoonNameDebug] or ScenarioInfo.Options.AIPLatoonNameDebug == 'all')  then
                if unit.PlatoonHandle then
                    Plan = unit.PlatoonHandle.PlanName
                    Builder = unit.PlatoonHandle.BuilderName
                    if Plan or Builder then
                        --unit:SetCustomName(''..(Builder or 'Unknown')..' ('..(Plan or 'Unknown')..')')
                        unit:SetCustomName(''..(Builder or 'Unknown'))
                        unit.LastPlatoonHandle = {}
                        unit.LastPlatoonHandle.PlanName = unit.PlatoonHandle.PlanName
                        unit.LastPlatoonHandle.BuilderName = unit.PlatoonHandle.BuilderName
--                    else
--                        if unit.LastPlatoonHandle then
--                            Plan = unit.LastPlatoonHandle.PlanName
--                            Builder = unit.LastPlatoonHandle.BuilderName
--                            unit:SetCustomName('+ no Plan, Old: '..(Builder or 'Unknown')..' ('..(Plan or 'Unknown')..')')
--                        else
--                            unit:SetCustomName('+ Platoon, no Plan')
--                        end
                    end
                else
                    unit:SetCustomName('Pool')
                end
            end
            WeAreInRange = false
            nearestbase = false
            if not unit.Dead
                and EntityCategoryContains(categories.MOBILE - categories.COMMAND - categories.ENGINEER, unit)
                and unit:GetFractionComplete() == 1
                and unit:IsIdleState()
                and not unit:IsMoving()
                and (not unit.PlatoonHandle or (not unit.PlatoonHandle.PlanName and not unit.PlatoonHandle.BuilderName))
            then
                UnitPos = unit:GetPosition()
                NeedNavalBase = EntityCategoryContains(categories.NAVAL, unit)
                -- loop over every location and check the distance between the unit and the location
                for location, base in BasePositions do
                    -- If we need a naval base then skip all non naval areas
                    if NeedNavalBase and base.Type ~= 'Naval Area' then
                        --AILog('* AI-Uveso: Need naval; but got land base: '..base.Type)
                        continue
                    end
                    -- If we need a land base then skip all naval areas
                    if not NeedNavalBase and base.Type == 'Naval Area' then
                        --AILog('* AI-Uveso: Need land; but got naval base: '..base.Type)
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
                -- if we are not in range of an base, then move closer to a base.
                if WeAreInRange == false and not unit.Dead then
                    if nearestbase then
                        if aiBrain[ScenarioInfo.Options.AIPLatoonNameDebug] or ScenarioInfo.Options.AIPLatoonNameDebug == 'all' then
                            unit:SetCustomName('Outside LocationManager')
                        end
                        IssueClearCommands({unit})
                        IssueStop({unit})
                        IssueMove({unit}, { nearestbase.Pos[1] + (Random(-10, 10)), nearestbase.Pos[2], nearestbase.Pos[3] + (Random(-10, 10)) })
                    end
                end
            end
            -- delay the loop after every 50 units. looping over 1000 units will take 2 seconds
            LoopDelay = LoopDelay + 1
            if LoopDelay > 50 then
                LoopDelay = 0
                coroutine.yield(1)
            end
        end

        coroutine.yield(1)

        -- check for factories without a location manager
        ArmyUnits = aiBrain:GetListOfUnits(categories.STRUCTURE * categories.FACTORY, false, false) -- also gets unbuilded units (planed to build)
        for _, factory in ArmyUnits do
            if factory.Dead then
                continue
            end
            if factory:GetFractionComplete() ~= 1 then
                continue
            end
            -- naval factory ?
            if EntityCategoryContains(categories.NAVAL, factory) then
                -- Is this a Naval Factory and assigned to the main base ?
                if factory.BuilderManagerData.FactoryBuildManager.LocationType == 'MAIN' then
                    -- Search the Main base FactoryList and delte the factory from it
                    for k,v in factory.BuilderManagerData.FactoryBuildManager.FactoryList do
                        -- if we found the factory, delete it. It will assign to a new location
                        if v == factory then
                            AIDebug('* AI-Uveso: Function LocationRangeManagerThread(): naval factory is assigned to mainbase. -> removed from main', true, UvesoOffsetaiarchetypeLUA)
                            factory.BuilderManagerData.FactoryBuildManager.FactoryList[k] = nil
                            factory.lost = GetGameTimeSeconds() - 12 -- we know it has no manager, no need to wait
                        end
                    end

                end
            end
            -- no factory manager ?
            if not factory.BuilderManagerData or factory.lost then
                if not factory.lost then
                    factory.lost = GetGameTimeSeconds()
                elseif factory.lost + 10 < GetGameTimeSeconds() then
                    AddFactoryToClosestManager(aiBrain, factory)
                end
            end
            -- Debug, show the actual location where the factory is assigned to as name.
            --factory:SetCustomName(factory.BuilderManagerData.FactoryBuildManager.LocationType or 'Unknown')
        end

        if 1 == 2 then
        -- watching the unit Cap for AI balance.
            unitcounterdelayer = unitcounterdelayer + 1
            if unitcounterdelayer > 12 then
                unitcounterdelayer = 0
                MaxCap = GetArmyUnitCap(aiBrain:GetArmyIndex())
                AILog('  ')
                AILog('* AI-Uveso:  05.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.MOBILE * (categories.ENGINEER - categories.POD) * categories.TECH1, false, false) ) )..' -  Engineers TECH1  - ' )
                AILog('* AI-Uveso:  05.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.MOBILE * (categories.ENGINEER - categories.POD) * categories.TECH2, false, false) ) )..' -  Engineers TECH2  - ' )
                AILog('* AI-Uveso:  05.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.MOBILE * (categories.ENGINEER - categories.POD) * categories.TECH3 - categories.SUBCOMMANDER, false, false) ) )..' -  Engineers TECH3  - ' )
                AILog('* AI-Uveso:  03.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.MOBILE * categories.SUBCOMMANDER, false, false) ) )..' -  SubCommander   - ' )
                AILog('* AI-Uveso:  45.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.MOBILE - ((categories.ENGINEER - categories.POD) * categories.MOBILE), false, false) ) )..' -  Mobile Attack Force  - ' )
                AILog('* AI-Uveso:  10.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE * categories.MASSEXTRACTION, false, false) ) )..' -  Extractors    - ' )
                AILog('* AI-Uveso:  12.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE * categories.DEFENSE, false, false) ) )..' -  Structures Defense   - ' )
                AILog('* AI-Uveso:  12.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - (categories.STRUCTURE * categories.FACTORY), false, false) ) )..' -  Structures all   - ' )
                AILog('* AI-Uveso:  02.4 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE * categories.FACTORY * categories.LAND, false, false) ) )..' -  Factory Land  - ' )
                AILog('* AI-Uveso:  02.4 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE * categories.FACTORY * categories.AIR, false, false) ) )..' -  Factory Air   - ' )
                AILog('* AI-Uveso:  02.4 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE * categories.FACTORY * categories.NAVAL, false, false) ) )..' -  Factory Sea   - ' )
                AILog('* AI-Uveso: ------|------')
                AILog('* AI-Uveso: 100.0 | '..math.floor(100 / MaxCap * table.getn(aiBrain:GetListOfUnits(categories.STRUCTURE + categories.MOBILE, false, false) ) )..' -  Structure + Mobile   - ' )
--                UNITS = aiBrain:GetListOfUnits(categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - (categories.STRUCTURE * categories.FACTORY), false, false)
--                for k,unit in UNITS do
--                    local description = unit:GetBlueprint().Description
--                    local location = unit:GetPosition()
--                    AILog('* AI-Uveso: K='..k..' - Unit= '..description..' - '..repr(location))
--                end
            end
        end
        
--        local SUtils = import('/lua/AI/sorianutilities.lua')
--        SUtils.AIRandomizeTaunt(aiBrain)

    end
end

function BaseRanger(aiBrain)
    local BaseRanger = {}
    local StartPos, NewMax
    local StartRad
    local V1Naval, V2Naval
    local EndPos
    local EndRad
    local dist
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
                StartPos = v.FactoryManager.Location
                StartRad = v.FactoryManager.Radius
                V1Naval = string.find(k, 'Naval Area')
                -- This is the maximum base radius.
                NewMax = 120
                -- Now check against every other baseLocation, and see if we need to reduce our base radius.
                for k2,v2 in aiBrain.BuilderManagers do
                    V2Naval = string.find(k2, 'Naval Area')
                    -- Only check, if base markers are not the same. Exclude compare between land and water locations
                    if v ~= v2 and ((V1Naval and V2Naval) or (not V1Naval and not V2Naval)) then
                        EndPos = v2.FactoryManager.Location
                        EndRad = v2.FactoryManager.Radius
                        dist = VDist2( StartPos[1], StartPos[3], EndPos[1], EndPos[3] )
                        -- If this is true, then we compare our MAIN base versus expansion location
                        if k == 'MAIN' then
                            -- Mainbase can use 66% of the distance to the next location (minimum 90). But only if we have enough space for the second base (>=30)
                            if NewMax > dist/3*2 and dist/3*2 > 90 and dist/3 >= 30 then
                                NewMax = dist/3*2
                                --AILog('* AI-Uveso: Distance from mainbase['..k..']->['..k2..']='..dist..' Mainbase radius='..StartRad..' Set Radius to '..dist/3*2)
                            -- If we have not enough spacee for the second base, then use half the distance as location radius
                            elseif NewMax > dist/2 and dist/2 > 90 and dist/2 >= 30 then
                                NewMax = dist/2
                                --AILog('* AI-Uveso: Distance to location['..k..']->['..k2..']='..dist..' location radius='..StartRad..' Set Radius to '..dist/2)
                            -- We have not enough space for the mainbase. Set it to 90. Wee need this radius for gathering plattons etc
                            else
                                NewMax = 90
                            end
                        -- This is true, then we compare expansion location versus MAIN base
                        elseif k2 == 'MAIN' then
                            -- Expansion can use 33% of the distance to the Mainbase.
                            if NewMax > dist - EndRad and dist - EndRad >= 30 then
                                NewMax = dist - EndRad
                                --AILog('* AI-Uveso: Distance to mainbase['..k..']->['..k2..']='..dist..' Mainbase radius='..EndRad..' Set Radius to '..dist - EndRad)
                            end
                        -- Use as base radius half the way to the next marker.
                        else
                            -- if we dont compare against the mainbase then use 50% of the distance to the next location
                            if NewMax > dist/2 and dist/2 >= 30 then
                                NewMax = dist/2
                                --AILog('* AI-Uveso: Distance to location['..k..']->['..k2..']='..dist..' location radius='..StartRad..' Set Radius to '..dist/2)
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
                -- Add the position and radius to the BaseRanger table
                BaseRanger[k] = {Pos = StartPos, Rad = math.floor(NewMax), Type = BaseType}
            end
        end
        -- store all bases ang radii global inside Scenario.MasterChain
        -- Wee need this to draw the debug circles
        if aiBrain.Uveso then
            if ScenarioInfo.Options.AIPathingDebug == 'pathlocation' then
                Scenario.MasterChain._MASTERCHAIN_.BaseRanger = Scenario.MasterChain._MASTERCHAIN_.BaseRanger or {}
                Scenario.MasterChain._MASTERCHAIN_.BaseRanger[aiBrain:GetArmyIndex()] = BaseRanger
            end
        end
    end
    return BaseRanger
end

function PriorityManagerThread(aiBrain)
    local UCBC = import('/lua/editor/UnitCountBuildConditions.lua')
    local MABC = import('/lua/editor/MarkerBuildConditions.lua')
    local MIBC = import('/lua/editor/MiscBuildConditions.lua')
    aiBrain.PriorityManager = {}
    aiBrain.PriorityManager.NeedEnergyTech1 = true
    aiBrain.PriorityManager.NeedEnergyTech2 = true
    aiBrain.PriorityManager.NeedEnergyTech3 = true
    aiBrain.PriorityManager.NeedEnergyTech4 = true
    aiBrain.PriorityManager.NeedMass = true
    aiBrain.PriorityManager.NeedMobileLand = true
    aiBrain.PriorityManager.NeedMobileHover = true
    aiBrain.PriorityManager.NeedMobileAmphibious = true
    aiBrain.PriorityManager.NeedMobileAir = true
    aiBrain.PriorityManager.NeedMobileNaval = true
    aiBrain.PriorityManager.BuildMobileLandTech1 = true
    aiBrain.PriorityManager.BuildMobileLandTech2 = true
    aiBrain.PriorityManager.BuildMobileLandTech3 = true
    aiBrain.PriorityManager.BuildMobileAirTech1 = true
    aiBrain.PriorityManager.BuildMobileAirTech2 = true
    aiBrain.PriorityManager.BuildMobileAirTech3 = true
    aiBrain.PriorityManager.BuildMobileNavalTech1 = true
    aiBrain.PriorityManager.BuildMobileNavalTech2 = true
    aiBrain.PriorityManager.BuildMobileNavalTech3 = true
    aiBrain.PriorityManager.NoRush1stPhaseActive = false
    aiBrain.PriorityManager.NoRush2ndPhaseActive = false
    while GetGameTimeSeconds() < 5 + aiBrain:GetArmyIndex() do
        coroutine.yield(10)
    end
    AIDebug('* AI-Uveso: Function PriorityManagerThread() started. ['..aiBrain.Nickname..']', true, UvesoOffsetaiarchetypeLUA)
    local paragons = {}
    local paragonComplete
    local EnergyTech1num
    local EnergyTech2num
    local EnergyTech3num
    local LANDSTRUCTURE
    local LANDMOBILE
    local AIRSTRUCTURE
    local AIRMOBILE
    local NAVALSTRUCTURE
    local NAVALMOBILE
    local LandFactoryTech1
    local LandFactoryTech2
    local LandFactoryTech3
    local AirFactoryTech1
    local AirFactoryTech2
    local AirFactoryTech3
    local NavalFactoryTech1
    local NavalFactoryTech2
    local NavalFactoryTech3
    while aiBrain.Status ~= "Defeat" do
        while not aiBrain:IsOpponentAIRunning() do
            coroutine.yield(10)
        end
        coroutine.yield(50)

        -- Check for Paragon
        paragonComplete = 0
        paragons = aiBrain:GetListOfUnits(categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC * categories.ENERGYPRODUCTION * categories.MASSPRODUCTION, false, false)
        for unitNum, unit in paragons do
            if unit:GetFractionComplete() >= 1 then
                paragonComplete = paragonComplete + 1
            end
        end
        if paragonComplete >= 1 then
            aiBrain.PriorityManager.HasParagon = true
        else
            aiBrain.PriorityManager.HasParagon = false
        end

        -- Check for energy need. (EngineerBuilder)
        EnergyTech1num = aiBrain:GetCurrentUnits(categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH1)
        EnergyTech2num = aiBrain:GetCurrentUnits(categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH2)
        EnergyTech3num = aiBrain:GetCurrentUnits(categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3)
        if EnergyTech2num < 2 and EnergyTech3num < 1 and paragonComplete < 1 then
            aiBrain.PriorityManager.NeedEnergyTech1 = true
        else
            aiBrain.PriorityManager.NeedEnergyTech1 = false
        end
        if EnergyTech3num < 1 and paragonComplete < 1 then
            aiBrain.PriorityManager.NeedEnergyTech2 = true
        else
            aiBrain.PriorityManager.NeedEnergyTech2 = false
        end
        if paragonComplete < 1 then
            aiBrain.PriorityManager.NeedEnergyTech3 = true
        else
            aiBrain.PriorityManager.NeedEnergyTech3 = false
        end
        if paragonComplete < 3 then
            aiBrain.PriorityManager.NeedEnergyTech4 = true
        else
            aiBrain.PriorityManager.NeedEnergyTech4 = false
        end


        -- Check for NoRush
        if ScenarioInfo.Options.NoRushOption and ScenarioInfo.Options.NoRushOption ~= 'Off' then
            local norush = tonumber(ScenarioInfo.Options.NoRushOption) * 60
            -- No rush Phase 1 from 0 to x-5 minutes
            if norush - 60 * 5 > GetGameTimeSeconds() then
                --local time = norush - GetGameTimeSeconds()
                --AILog('* AI-Uveso: no rush Phase 1:'.. time)
                aiBrain.PriorityManager.BuildMobileLandTech1 = false
                aiBrain.PriorityManager.BuildMobileLandTech2 = false
                aiBrain.PriorityManager.BuildMobileLandTech3 = false
                aiBrain.PriorityManager.BuildMobileAirTech1 = false
                aiBrain.PriorityManager.BuildMobileAirTech2 = false
                aiBrain.PriorityManager.BuildMobileAirTech3 = false
                aiBrain.PriorityManager.BuildMobileNavalTech1 = false
                aiBrain.PriorityManager.BuildMobileNavalTech2 = false
                aiBrain.PriorityManager.BuildMobileNavalTech3 = false
                aiBrain.PriorityManager.NeedMass = false
                aiBrain.PriorityManager.NoRush1stPhaseActive = true
                aiBrain.PriorityManager.NoRush2ndPhaseActive = true
                continue
            -- No rush Phase 2 from x-3 to x minutes
            elseif norush > GetGameTimeSeconds() then
                --local time = norush - GetGameTimeSeconds()
                --AILog('* AI-Uveso: no rush Phase 2:'.. time)
                aiBrain.PriorityManager.BuildMobileLandTech1 = true
                aiBrain.PriorityManager.BuildMobileLandTech2 = true
                aiBrain.PriorityManager.BuildMobileLandTech3 = true
                aiBrain.PriorityManager.BuildMobileAirTech1 = true
                aiBrain.PriorityManager.BuildMobileAirTech2 = true
                aiBrain.PriorityManager.BuildMobileAirTech3 = true
                aiBrain.PriorityManager.BuildMobileNavalTech1 = true
                aiBrain.PriorityManager.BuildMobileNavalTech2 = true
                aiBrain.PriorityManager.BuildMobileNavalTech3 = true
                aiBrain.PriorityManager.NeedMass = false
                aiBrain.PriorityManager.NoRush1stPhaseActive = true
                aiBrain.PriorityManager.NoRush2ndPhaseActive = false
                continue
            else
            -- No rush Phase 3 - No rush ended
                --local time = norush - GetGameTimeSeconds()
                --AILog('* AI-Uveso: no rush Phase 3:'.. time)
                aiBrain.PriorityManager.NoRush1stPhaseActive = false
                aiBrain.PriorityManager.NoRush2ndPhaseActive = false
            end
        end


        -- Check for mass need. (EngineerBuilder)
        -- Are less then 10% of all structures are extractors ? - Then we need more
        if UCBC.HaveUnitRatioVersusCap(aiBrain, 0.10, '<', categories.STRUCTURE * categories.MASSEXTRACTION)
        -- Do we have a free mass spot ? - Then we can more
        and MABC.CanBuildOnMass(aiBrain, 'MAIN', 1000, -500, 1, 0, 'AntiSurface', 1) then
            aiBrain.PriorityManager.NeedMass = true
        else
            aiBrain.PriorityManager.NeedMass = false
        end
        -- check for layer with least units
        LANDFACTORY = aiBrain:GetCurrentUnits(categories.LAND * categories.FACTORY)
        LANDMOBILE = aiBrain:GetCurrentUnits(categories.LAND * categories.MOBILE - categories.SCOUT - categories.ENGINEER)
        AIRFACTORY = aiBrain:GetCurrentUnits(categories.AIR * categories.FACTORY)
        AIRMOBILE = aiBrain:GetCurrentUnits(categories.AIR * categories.MOBILE - categories.SCOUT - categories.TRANSPORTFOCUS)
        NAVALFACTORY = aiBrain:GetCurrentUnits(categories.NAVAL * categories.FACTORY)
        NAVALMOBILE = aiBrain:GetCurrentUnits(categories.NAVAL * categories.MOBILE)
        --AILog('* AI-Uveso:  '..LANDFACTORY..'/'..AIRFACTORY..'/'..NAVALFACTORY..' - LANDMOBILE: '..LANDMOBILE..' - AIRMOBILE: '..AIRMOBILE..' - NAVALMOBILE: '..NAVALMOBILE..'.')
        -- can we build more units ?
        if UCBC.HaveUnitRatioVersusCap(aiBrain, 0.45, '<', categories.MOBILE) then
            if (LANDMOBILE >= AIRMOBILE) and (LANDMOBILE >= NAVALMOBILE) then
                aiBrain.PriorityManager.NeedMobileLand = false
                aiBrain.PriorityManager.NeedMobileHover = false
                aiBrain.PriorityManager.NeedMobileAmphibious = false
                if AIRFACTORY > 0 then
                    aiBrain.PriorityManager.NeedMobileAir = true
                end
                if NAVALFACTORY > 0 then
                    aiBrain.PriorityManager.NeedMobileNaval = true
                end
            elseif (AIRMOBILE >= LANDMOBILE) and (AIRMOBILE >= NAVALMOBILE) then
                if LANDFACTORY > 0 then
                    aiBrain.PriorityManager.NeedMobileLand = true
                    aiBrain.PriorityManager.NeedMobileHover = true
                    aiBrain.PriorityManager.NeedMobileAmphibious = true
                end
                aiBrain.PriorityManager.NeedMobileAir = false
                if NAVALFACTORY > 0 then
                    aiBrain.PriorityManager.NeedMobileNaval = true
                end
            elseif (NAVALMOBILE >= LANDMOBILE) and (NAVALMOBILE >= AIRMOBILE) then
                if LANDFACTORY > 0 then
                    aiBrain.PriorityManager.NeedMobileLand = true
                    aiBrain.PriorityManager.NeedMobileHover = true
                    aiBrain.PriorityManager.NeedMobileAmphibious = true
                end
                if AIRFACTORY > 0 then
                    aiBrain.PriorityManager.NeedMobileAir = true
                end
                aiBrain.PriorityManager.NeedMobileNaval = false
            else
            end
        -- we can't build more units because of unitcap
        else
            aiBrain.PriorityManager.NeedMobileLand = false
            aiBrain.PriorityManager.NeedMobileHover = false
            aiBrain.PriorityManager.NeedMobileAmphibious = false
            aiBrain.PriorityManager.NeedMobileAir = false
            aiBrain.PriorityManager.NeedMobileNaval = false
        end

        -- check if we have factories to build units
        LandFactoryTech1 = aiBrain:GetCurrentUnits(categories.LAND * categories.FACTORY * categories.TECH1 )
        LandFactoryTech2 = aiBrain:GetCurrentUnits(categories.LAND * categories.FACTORY * categories.TECH2 )
        LandFactoryTech3 = aiBrain:GetCurrentUnits(categories.LAND * categories.FACTORY * categories.TECH3 )

        AirFactoryTech1 = aiBrain:GetCurrentUnits(categories.AIR * categories.FACTORY * categories.TECH1 )
        AirFactoryTech2 = aiBrain:GetCurrentUnits(categories.AIR * categories.FACTORY * categories.TECH2 )
        AirFactoryTech3 = aiBrain:GetCurrentUnits(categories.AIR * categories.FACTORY * categories.TECH3 )

        NavalFactoryTech1 = aiBrain:GetCurrentUnits(categories.NAVAL * categories.FACTORY * categories.TECH1 )
        NavalFactoryTech2 = aiBrain:GetCurrentUnits(categories.NAVAL * categories.FACTORY * categories.TECH2 )
        NavalFactoryTech3 = aiBrain:GetCurrentUnits(categories.NAVAL * categories.FACTORY * categories.TECH3 )

        if UCBC.HaveUnitRatioVersusCap(aiBrain, 0.45, '<', categories.MOBILE) then
            -- Land
            if LandFactoryTech1 > 0 then
                aiBrain.PriorityManager.BuildMobileLandTech1 = true
            else
                aiBrain.PriorityManager.BuildMobileLandTech1 = false
            end
            if LandFactoryTech2 > 0 then
                aiBrain.PriorityManager.BuildMobileLandTech2 = true
            else
                aiBrain.PriorityManager.BuildMobileLandTech2 = false
            end
            if LandFactoryTech3 > 0 then
                aiBrain.PriorityManager.BuildMobileLandTech3 = true
            else
                aiBrain.PriorityManager.BuildMobileLandTech3 = false
            end
            -- Air
            if AirFactoryTech1 > 0 then
                aiBrain.PriorityManager.BuildMobileAirTech1 = true
            else
                aiBrain.PriorityManager.BuildMobileAirTech1 = false
            end
            if AirFactoryTech2 > 0 then
                aiBrain.PriorityManager.BuildMobileAirTech2 = true
            else
                aiBrain.PriorityManager.BuildMobileAirTech2 = false
            end
            if AirFactoryTech3 > 0 then
                aiBrain.PriorityManager.BuildMobileAirTech3 = true
            else
                aiBrain.PriorityManager.BuildMobileAirTech3 = false
            end
            -- Naval
            if NavalFactoryTech1 > 0 then
                aiBrain.PriorityManager.BuildMobileNavalTech1 = true
            else
                aiBrain.PriorityManager.BuildMobileNavalTech1 = false
            end
            if NavalFactoryTech2 > 0 then
                aiBrain.PriorityManager.BuildMobileNavalTech2 = true
            else
                aiBrain.PriorityManager.BuildMobileNavalTech2 = false
            end
            if NavalFactoryTech3 > 0 then
                aiBrain.PriorityManager.BuildMobileNavalTech3 = true
            else
                aiBrain.PriorityManager.BuildMobileNavalTech3 = false
            end
        else
            aiBrain.PriorityManager.BuildMobileLandTech1 = false
            aiBrain.PriorityManager.BuildMobileLandTech2 = false
            aiBrain.PriorityManager.BuildMobileLandTech3 = false
            aiBrain.PriorityManager.BuildMobileAirTech1 = false
            aiBrain.PriorityManager.BuildMobileAirTech2 = false
            aiBrain.PriorityManager.BuildMobileAirTech3 = false
            aiBrain.PriorityManager.BuildMobileNavalTech1 = false
            aiBrain.PriorityManager.BuildMobileNavalTech2 = false
            aiBrain.PriorityManager.BuildMobileNavalTech3 = false
        end
        
    end
end

function AddFactoryToClosestManager(aiBrain, factory)
    AIDebug('* AI-Uveso: AddFactoryToClosestManager: Factory '..factory.UnitId..' is not assigned to a factory manager!', true, UvesoOffsetaiarchetypeLUA)
    local FactoryPos = factory:GetPosition()
    local NavalFactory = EntityCategoryContains(categories.NAVAL, factory)
    local ClosestMarkerBasePos, MarkerBaseName, layer, dist, areatype, BaseRadius
    -- searching for the closest location near the factory (MAIN, Expansion Area)
    if NavalFactory then
        ClosestMarkerBasePos, MarkerBaseName = AIUtils.AIGetClosestMarkerLocation(aiBrain, 'Naval Area', FactoryPos[1], FactoryPos[3])
        layer = 'Water'
    else
        ClosestMarkerBasePos, MarkerBaseName = AIUtils.AIGetClosestMarkerLocation(aiBrain, 'Blank Marker', FactoryPos[1], FactoryPos[3], {'Expansion Area', 'Large Expansion Area'})
        layer = 'Land'
    end
    if not ClosestMarkerBasePos then
        AIWarn('* AI-Uveso: AddFactoryToClosestManager: ClosestMarkerBasePos is NIL for layer '..layer, true, UvesoOffsetaiarchetypeLUA)
    end
    --  if exist, get the distance to the closest Marker Location
    if ClosestMarkerBasePos then
        dist = VDist2(FactoryPos[1], FactoryPos[3], ClosestMarkerBasePos[1], ClosestMarkerBasePos[3])
    else
        dist = 0
    end
    --  if we have already found a manager, get it's BaseRadius
    if aiBrain.BuilderManagers[MarkerBaseName].FactoryManager.Radius then
        BaseRadius = aiBrain.BuilderManagers[MarkerBaseName].FactoryManager.Radius
    else
        BaseRadius = 30
    end
    -- check if the distance from our factory to the closest basemanager is closeer than the managers max range and check if we are on the same land/sea
    if not FactoryPos then
        AIWarn('FactoryPos = NIL', true, UvesoOffsetaiarchetypeLUA)
    end
    if not ClosestMarkerBasePos then
        AIWarn('ClosestMarkerBasePos = NIL', true, UvesoOffsetaiarchetypeLUA)
    end
    
    if dist > BaseRadius or (not ClosestMarkerBasePos) or (not CanGraphAreaTo(FactoryPos, ClosestMarkerBasePos, layer)) then -- needs graph check for land and naval locations
        if NavalFactory then
            MarkerBaseName = 'Naval Area '..Random(1000,5000)
            areatype = 'Naval Area'
        else
            MarkerBaseName = 'Expansion Area '..Random(1000,5000)
            areatype = 'Expansion Area'
        end
        AIWarn('* AI-Uveso: AddFactoryToClosestManager: Found ['..MarkerBaseName..'] Baseradius('..math.floor(BaseRadius)..') but it\'s to not reachable: Distance to base: '..math.floor(dist)..' - Creating new location: '..MarkerBaseName, true, UvesoOffsetaiarchetypeLUA)
        -- creating a marker for the expansion or AIUtils.AIGetClosestMarkerLocation() will not find it.
        Scenario.MasterChain._MASTERCHAIN_.Markers[MarkerBaseName] = {}
        Scenario.MasterChain._MASTERCHAIN_.Markers[MarkerBaseName].color = 'fff4a460'
        Scenario.MasterChain._MASTERCHAIN_.Markers[MarkerBaseName].hint = true
        Scenario.MasterChain._MASTERCHAIN_.Markers[MarkerBaseName].orientation = { 0, 0, 0 }
        Scenario.MasterChain._MASTERCHAIN_.Markers[MarkerBaseName].prop = "/env/common/props/markers/M_Expansion_prop.bp"
        Scenario.MasterChain._MASTERCHAIN_.Markers[MarkerBaseName].type = areatype
        Scenario.MasterChain._MASTERCHAIN_.Markers[MarkerBaseName].position = FactoryPos
        ClosestMarkerBasePos = FactoryPos
    end
    -- get the location type of this marker ( Blank Marker, Naval Area, Expansion Area, Large Expansion Area )
    local LocationType = Scenario.MasterChain._MASTERCHAIN_.Markers[MarkerBaseName].type
    -- Is this a start location ?
    if LocationType == 'Blank Marker' then
        -- Is this our own start location ?
        if MarkerBaseName == 'ARMY_'..aiBrain:GetArmyIndex() then
            -- Our mainbase is called 'MAIN', so rename ARMY_x
            MarkerBaseName = 'MAIN'
            -- FirstBaseFunction does not need an expansion name, so we can use a custom name here
            LocationType = 'Start Area '..aiBrain:GetArmyIndex()
        else
            -- Not our own start area, lets make an large expansion here
            LocationType = 'Large Expansion Area'
        end
    -- This is only for debug in case map markers have wrong .type
    elseif LocationType ~= 'Naval Area' and LocationType ~= 'Expansion Area' and LocationType ~= 'Large Expansion Area' then
        AIWarn('* AI-Uveso: AddFactoryToClosestManager: unknown LocationType '..LocationType..' !', true, UvesoOffsetaiarchetypeLUA)
    end
    AIDebug('* AI-Uveso: AddFactoryToClosestManager: Factory '..factory.UnitId..' is close ('..math.floor(dist)..') to MarkerBaseName '..MarkerBaseName..' ('..LocationType..')', true, UvesoOffsetaiarchetypeLUA)
    -- search for an manager on this location
    if aiBrain.BuilderManagers[MarkerBaseName] then
        AIDebug('* AI-Uveso: AddFactoryToClosestManager: BuilderManagers for MarkerBaseName '..MarkerBaseName..' exist!', true, UvesoOffsetaiarchetypeLUA)
        -- Just a failsafe, normaly we have an FactoryManager if the BuilderManagers on this location is present.
        if aiBrain.BuilderManagers[MarkerBaseName].FactoryManager then
            AIDebug('* AI-Uveso: AddFactoryToClosestManager: FactoryManager at MarkerBaseName '..MarkerBaseName..' exist! -> Adding Factory!', true, UvesoOffsetaiarchetypeLUA)
            -- using AddFactory() from the factory manager to add the factory to the manager.
            aiBrain.BuilderManagers[MarkerBaseName].FactoryManager:AddFactory(factory)
            -- Factory is no longer without an manager
            factory.lost = nil
        end
    else
        -- no basemanager found, create a new one.
        AIDebug('* AI-Uveso: AddFactoryToClosestManager: BuilderManagers for MarkerBaseName '..MarkerBaseName..' does not exist! Creating Manager', true, UvesoOffsetaiarchetypeLUA)
        -- Create the new expansion on the expansion marker position with a radius of 100. 100 is only an default value, it will be changed from BaseRanger() thread
        aiBrain:AddBuilderManagers(ClosestMarkerBasePos, 100, MarkerBaseName, true)
        -- add the factory to the new manager
        AIDebug('* AI-Uveso: AddFactoryToClosestManager: FactoryManager at MarkerBaseName '..MarkerBaseName..' created! -> Adding Factory!', true, UvesoOffsetaiarchetypeLUA)
        aiBrain.BuilderManagers[MarkerBaseName].FactoryManager:AddFactory(factory)
        -- Factory is no longer without an manager
        factory.lost = nil
        -- Search for a basetemplates for the new expansion ( original code can be found in aibuildstructures.lua.AINewExpansionBase() )
        -- Calling the ExpansionFunction inside all /AIBaseTemplates/*.* files to find the right expansion template
        local baseValues = {}
        local highPri = false
        for templateName, baseData in BaseBuilderTemplates do
            local baseValue = baseData.ExpansionFunction(aiBrain, ClosestMarkerBasePos, LocationType)
            table.insert(baseValues, { Base = templateName, Value = baseValue })
            if not highPri or baseValue > highPri then
                highPri = baseValue
            end
        end
        -- create a table with all possible base expansion templates
        local validNames = {}
        for k,v in baseValues do
            if v.Value == highPri then
                table.insert(validNames, v.Base)
            end
        end
        -- get a random name if we have more than one possible base template
        local pick = validNames[ Random(1, table.getn(validNames)) ]
        AIWarn('* AI-Uveso: AddFactoryToClosestManager: picked basetemplate '..pick..' for location '..MarkerBaseName..' ('..LocationType..')', true, UvesoOffsetaiarchetypeLUA)
        -- finaly loading the templates for the new base location. From now on the new factory can work for us :D
        import('/lua/ai/AIAddBuilderTable.lua').AddGlobalBaseTemplate(aiBrain, MarkerBaseName, pick)
    end
end

-- watch if [ALT]+[a] is presed to stop the AI
function OpponentAIWatchThread(aiBrain)
    while GetGameTimeSeconds() < 1 do
        coroutine.yield(10)
    end
    AIDebug('* AI-Uveso: Function OpponentAIWatchThread() started. ['..aiBrain.Nickname..']', true, UvesoOffsetaiarchetypeLUA)
    local AIPaused = false
    local allUnits
    while true do
        coroutine.yield(10)
        -- loop continuously over all units to catch those who are just finished
        if not aiBrain:IsOpponentAIRunning() then
            -- not possible to specify units because of mods, so we scan all units
            allUnits = aiBrain:GetListOfUnits(categories.ALLUNITS)
            for index, unit in allUnits do
                if not unit.Dead then
                    unit:SetFireState(1) --HOLD_FIRE
                end
            end
            AIPaused = true
        elseif AIPaused and aiBrain:IsOpponentAIRunning() then
            -- not possible to specify units because of mods, so we scan all units
            allUnits = aiBrain:GetListOfUnits(categories.ALLUNITS)
            for index, unit in allUnits do
                if not unit.Dead then
                    unit:SetFireState(2) --GROUND_FIRE
                end
            end
            AIPaused = false
        end
    end
end
