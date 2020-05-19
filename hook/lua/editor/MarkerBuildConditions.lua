
--original:
-- Condition Actual:0.001953125 name: CanBuildOnMass
--Optimized
-- Condition Actual:0.000244140625 name: CanBuildOnMass
local LastGetMassMarker = -1
local MassMarker = {}
local LastMassBOOL = false
function CanBuildOnMass(aiBrain, locationType, distance, threatMin, threatMax, threatRings, threatType, maxNum )
    if LastGetMassMarker < GetGameTimeSeconds() then
        LastGetMassMarker = GetGameTimeSeconds()+10
        local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
        if not engineerManager then
            --WARN('*AI WARNING: CanBuildOnMass: Invalid location - ' .. locationType)
            return false
        end
        local position = engineerManager.Location
        MassMarker = {}
        for _, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
            if v.type == 'Mass' then
                if v.position[1] <= 8 or v.position[1] >= ScenarioInfo.size[1] - 8 or v.position[3] <= 8 or v.position[3] >= ScenarioInfo.size[2] - 8 then
                    -- mass marker is too close to border, skip it.
                    continue
                end
                table.insert(MassMarker, {Position = v.position, Distance = VDist2( v.position[1], v.position[3], position[1], position[3] ) })
            end
        end
        table.sort(MassMarker, function(a,b) return a.Distance < b.Distance end)
    end
    LastMassBOOL = false
    for _, v in MassMarker do
        if v.Distance > distance then
            break
        end
        if aiBrain:CanBuildStructureAt('ueb1103', v.Position) then
            if threatMin and threatMax and threatRings then
                threat = aiBrain:GetThreatAtPosition(v.Position, threatRings, true, threatType or 'Overall')
                --LOG(_..' Checking marker with max distance ['..distance..']. Actual marker has distance: ('..(v.Distance)..'). threat '..threat)
                if threat < threatMin or threat > threatMax then
                    continue
                end
            end
            LastMassBOOL = true
            break
        end
    end
    --LOG('*AI WARNING: CanBuildOnMass: for distance ('..distance..')returned - ' .. repr(LastMassBOOL))

    return LastMassBOOL
end

local LastGetHydroMarker = 0
local HydroMarker = {}
local LastHydroBOOL = false
--                { MABC, 'CanBuildOnHydro', { 'LocationType', 1000, -1000, 100, 1, 'AntiSurface', 1 }},
function CanBuildOnHydro(aiBrain, locationType, distance, threatMin, threatMax, threatRings, threatType, maxNum)
    if LastGetHydroMarker < GetGameTimeSeconds() then
        LastGetHydroMarker = GetGameTimeSeconds()+10
        local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
        if not engineerManager then
            --WARN('*AI WARNING: CanBuildOnHydro: Invalid location - ' .. locationType)
            return false
        end
        local position = engineerManager.Location
        HydroMarker = {}
        for _, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
            if v.type == 'Hydrocarbon' then
                table.insert(HydroMarker, {Position = v.position, Distance = VDist2( v.position[1], v.position[3], position[1], position[3] ) })
            end
        end
        table.sort(HydroMarker, function(a,b) return a.Distance < b.Distance end)
    end
    local threatCheck = false
    if threatMin and threatMax and threatRings then
        threatCheck = true
    end
    LastHydroBOOL = false
    for _, v in HydroMarker do
        if aiBrain:CanBuildStructureAt('ueb1102', v.Position) then
            if threatCheck then
                threat = aiBrain:GetThreatAtPosition(v.Position, threatRings, true, threatType or 'Overall')
                if threat < threatMin or threat > threatMax then
                    continue
                end
            end
            LastHydroBOOL = true
            break
        end
    end
    return LastHydroBOOL
end

