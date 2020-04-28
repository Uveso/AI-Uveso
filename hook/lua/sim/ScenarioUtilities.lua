
-- For AI Patch V8 (Patched)
function CreateInitialArmyGroup(strArmy, createCommander)
    local tblGroup = CreateArmyGroup(strArmy, 'INITIAL')
    local cdrUnit = false

    if createCommander and (tblGroup == nil or 0 == table.getn(tblGroup)) then
        local factionIndex = GetArmyBrain(strArmy):GetFactionIndex()
        local initialUnitName = import('/lua/factions.lua').Factions[factionIndex].InitialUnit
        cdrUnit = CreateInitialArmyUnit(strArmy, initialUnitName)
        if EntityCategoryContains(categories.COMMAND, cdrUnit) then
            if ScenarioInfo.Options['PrebuiltUnits'] == 'Off' then
                cdrUnit:HideBone(0, true)
                ForkThread(CommanderWarpDelay, cdrUnit, 3, GetArmyBrain(strArmy))
            end

            local rotateOpt = ScenarioInfo.Options['RotateACU']
            if not rotateOpt or rotateOpt == 'On' then
                cdrUnit:RotateTowardsMid()
            elseif rotateOpt == 'Marker' then
                local marker = GetMarker(strArmy) or {}
                if marker['orientation'] then
                    local o = EulerToQuaternion(unpack(marker['orientation']))
                    cdrUnit:SetOrientation(o, true)
                end
            end
        end
    end

    return tblGroup, cdrUnit
end

-- For AI Patch V8 (Patched)
function CommanderWarpDelay(cdrUnit, delay, ArmyBrain)
    if ArmyBrain.BrainType == 'Human' then
        cdrUnit:SetBlockCommandQueue(true)
    end
    WaitSeconds(delay)
    cdrUnit:PlayCommanderWarpInEffect()
end
