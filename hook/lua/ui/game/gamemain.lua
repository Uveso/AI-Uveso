
-- executing beats without throttling any beat.
-- FAF way of throttling beats is desyncing the economic window and shows odd numbers.
function OnBeat()
    for i,v in _beatFunctions do
        if v.fn then v.fn() end
    end
end

local OriginalOnFirstUpdateFunction = OnFirstUpdate
function OnFirstUpdate()
    OriginalOnFirstUpdateFunction()
    ForkThread( 
        function()
            LOG('* AI-Uveso: Changing pathing calculating budget') 
            WaitSeconds(3)
            ConExecute("path_MaxInstantWorkUnits 500")              -- default 500  - Budget for instant pathfinds by the AI
            ConExecute("path_ArmyBudget 1000")                      -- default 1000 - Budget for each army to do pathfinding each tick
            ConExecute("path_BackgroundBudget 1000")                -- default 1000 - Maximum number of steps to run pathfinder in background
            ConExecute("path_UnreachableTimeoutSearchSteps 1000")   -- default 1000 - Maximum number of ticks to allow a single pathfind to take for an unreachable path 
            ConExecute("path_BackgroundUpdate on")                  -- Default on   - on/off
        end
    )
end