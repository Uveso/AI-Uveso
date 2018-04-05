
function CommanderBehaviorUveso(platoon)
    for _, v in platoon:GetPlatoonUnits() do
        if not v.Dead and not v.CommanderThread then
            v.CommanderThread = v:ForkThread(CommanderThreadUveso, platoon)
        end
    end
end

function CommanderThreadUveso(cdr, platoon)
    SetCDRHome(cdr, platoon)

    -- Added to ensure we know the start locations (thanks to Sorian).
    local aiBrain = cdr:GetAIBrain()
    aiBrain:BuildScoutLocations()

    while not cdr.Dead do
        -- Go back to base
        if not cdr.Dead then
            --LOG('* CommanderThreadUveso: CDRReturnHome')
            CDRReturnHome(aiBrain, cdr)
        end
        WaitTicks(5)
        -- Call platoon resume building deal...
        if not cdr.Dead and cdr:IsIdleState() then
            if not cdr.EngineerBuildQueue or table.getn(cdr.EngineerBuildQueue) == 0 then
                --LOG('* CommanderThreadUveso: Idle and no BuildQueue')
                --local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
                --aiBrain:AssignUnitsToPlatoon(pool, {cdr}, 'Unassigned', 'None')
                --if cdr.PlatoonHandle.PlanName then
                    --LOG('* CommanderThreadUveso: Idle and no BuildQueue. Disbanding PlatoonHandle: '..(cdr.PlatoonHandle.PlanName or 'Unknown'))
                --    cdr.PlatoonHandle:PlatoonDisband()
                --end
            elseif cdr.EngineerBuildQueue and table.getn(cdr.EngineerBuildQueue) ~= 0 then
                --LOG('* CommanderThreadUveso: Idle and BuildQueue')
                if not cdr.NotBuildingThread then
                    --LOG('* CommanderThreadUveso: Idle and BuildQueue and NotBuildingThread')
                    cdr.NotBuildingThread = cdr:ForkThread(platoon.WatchForNotBuilding)
                end
            end
        end
        WaitTicks(50)
    end
end
