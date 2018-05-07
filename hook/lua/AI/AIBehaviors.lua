
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
            CDRReturnHomeUveso(aiBrain, cdr)
        end
        WaitTicks(2)
        -- Call platoon resume building deal...
        if not cdr:IsDead() and cdr:IsIdleState() then
            if cdr.EngineerBuildQueue and table.getn(cdr.EngineerBuildQueue) != 0 then
                --LOG('* CommanderThreadUveso: Idle and BuildQueue')
                if not cdr.NotBuildingThread then
                    cdr.NotBuildingThread = cdr:ForkThread(platoon.WatchForNotBuilding)
                end             
            end
        end        
        WaitTicks(2)
    end
end

function CDRReturnHomeUveso(aiBrain, cdr)
    -- This is a reference... so it will autoupdate
    local cdrPos = cdr:GetPosition()
    local distAway = 120
    local loc = cdr.CDRHome
    if not cdr.Dead and VDist2(cdrPos[1], cdrPos[3], loc[1], loc[3]) > distAway then
        repeat
            CDRRevertPriorityChange(aiBrain, cdr)
            IssueStop({cdr})
            IssueMove({cdr}, loc)
            WaitSeconds(7)
        until cdr.Dead or VDist2(cdrPos[1], cdrPos[3], loc[1], loc[3]) <= distAway
        IssueClearCommands({cdr})
    end
    return
end
