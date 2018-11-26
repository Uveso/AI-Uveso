
function CommanderBehaviorUveso(platoon)
    local aiBrain = platoon:GetPlatoonUnits()[1]:GetAIBrain()
    local Commanders = aiBrain:GetListOfUnits(categories.COMMAND, false, false)
    --LOG(' Commander no. '..table.getn(Commanders))
    for _, v in Commanders do
        if not v.Dead and not v.CommanderThread then
            v.CommanderThread = v:ForkThread(CommanderThreadUveso, platoon)
            --LOG('Forking Commander Behavior Thread')
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
        if not cdr.Dead and cdr:GetHealth() < cdr:GetMaxHealth() then
            CDRReturnHomeUveso(aiBrain, cdr)
        end
        WaitTicks(1)
        -- Call platoon resume building deal...
        if not cdr.Dead and cdr:IsIdleState() then
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
            elseif cdr.EngineerBuildQueue and table.getn(cdr.EngineerBuildQueue) != 0 then
                if not cdr.NotBuildingThread then
                    cdr.NotBuildingThread = cdr:ForkThread(platoon.WatchForNotBuilding)
                end             
            end
        end        
        WaitTicks(1)
    end
end

function CDRReturnHomeUveso(aiBrain, cdr)
    local cdrPos = cdr:GetPosition()
    local distAway = 20
    if not cdr.Dead and VDist2(cdrPos[1], cdrPos[3], cdr.CDRHome[1], cdr.CDRHome[3]) > distAway then
        repeat
            CDRRevertPriorityChange(aiBrain, cdr)
            IssueStop({cdr})
            IssueMove({cdr}, cdr.CDRHome)
            WaitSeconds(7)
        until cdr.Dead or VDist2(cdrPos[1], cdrPos[3], cdr.CDRHome[1], cdr.CDRHome[3]) <= distAway
        IssueClearCommands({cdr})
    end
    return
end
