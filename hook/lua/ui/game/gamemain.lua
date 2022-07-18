
--local originalCreateUI = CreateUI
--function CreateUI(isReplay)
--    -- call the original function first to set up the rest of the game UI
--    originalCreateUI(isReplay)
--    -- inject keybinding to call functions on the fly
--    if not isReplay then
--        local replacementMap = {
--            ['Ctrl-q']         = {action = 'UI_Lua import("/lua/ui/game/gamemain.lua").KeyTestFunction("Test123abc")'},
--        }
--        IN_AddKeyMapTable(replacementMap)
--    end
--end

--function KeyTestFunction(value)
--    AILog('** "Ctrl-q" KeyTestFunction('..value..')')
----    local selection = ValidateUnitsList(GetSelectedUnits())
--end

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
            --AILog('* AI-Uveso: Changing path calculating budget')
            coroutine.yield(50)
            -- can cause desyncs in replays if called to early
            -- thisis also triggering a player x is cheating message, i will remove this for now
            --ConExecute("path_MaxInstantWorkUnits 500")              -- default 500  - Budget for instant pathfinds by the AI
            --ConExecute("path_ArmyBudget 1000")                      -- default 1000 - Budget for each army to do pathfinding each tick
            --ConExecute("path_BackgroundBudget 1000")                -- default 1000 - Maximum number of steps to run pathfinder in background
            --ConExecute("path_UnreachableTimeoutSearchSteps 1000")   -- default 1000 - Maximum number of ticks to allow a single pathfind to take for an unreachable path 
            --ConExecute("path_BackgroundUpdate on")                  -- Default on   - on/off
            --ConExecute("d3d_windowscursor")                         -- Fix for Nvidia Mousedriver 21.Dec.2020
            local GameOptions = Prefs.GetFromCurrentProfile('LobbyPresets')[1].GameOptions
            SPEW('* AI-Uveso: OnFirstUpdate: GameOptions '..repr(GameOptions))
            if GameOptions.AIEndlessGameLoop == 'on' then
                while GetGameTimeSeconds() < 7 do                      -- wait until game second 30 before setting screen
                    coroutine.yield(10)
                end
                local ScenarioInfo = SessionGetScenarioInfo()
                -- set camera zoom, so we can see the whole map
                GetCamera('WorldCamera'):SetTargetZoom(ScenarioInfo.size[2] * 2)
                -- wait for the camera movement to zoom out
                coroutine.yield(60)
                -- set cam position to the middle of the map
                local currentCamSettings = GetCamera('WorldCamera'):SaveSettings()
                currentCamSettings.Focus = Vector (ScenarioInfo.size[1] / 2, 0, ScenarioInfo.size[2] / 2) 
                GetCamera('WorldCamera'):RestoreSettings(currentCamSettings)
                coroutine.yield(10)
                ConExecute("WLD_GameSpeed 20")                          -- increase gamespeed
                if GameOptions.OmniCheat == 'on' then                   -- If we have AI-omniview on, also enable it for players
                    ConExecute("SallyShears")                           -- Omniview for all (also players)
                end
            end
        end
    )
    ForkThread( 
        function()
            --AILog(repr(__EngineStats))
            coroutine.yield(30)
            local CTask, CTaskThread, CScriptObject, CLuaTask, Entity, Prop, CDecalHandle, Unit, Platoon, ReconBlip = 0,0,0,0,0,0,0,0,0,0
            local SCTask, SCTaskThread, SCScriptObject, SCLuaTask, SEntity, SProp, SCDecalHandle, SReconBlip = 0,0,0,0,0,0,0,0
            local LastPrint, GTS, hours, minutes, seconds, fps, reserved, use, desiredrate, SystemTime, LastSystemTime, simrate, simspeed
            LastPrint = 0
            LastSystemTime = GetSystemTimeSeconds() + GetGameTimeSeconds()
            for k, v in __EngineStats.Children do
                if v.Name == 'Instance Counts' then
                    for k2, v2 in v.Children do
                        if v2.Name == 'class Moho::CTask' then
                            SCTask = v2.Value or 0
                        elseif v2.Name == 'class Moho::CTaskThread' then
                            SCTaskThread = v2.Value or 0
                        elseif v2.Name == 'class Moho::CScriptObject' then
                            SCScriptObject = v2.Value or 0
                        elseif v2.Name == 'class Moho::CLuaTask' then
                            SCLuaTask = v2.Value or 0
                        elseif v2.Name == 'class Moho::Entity' then
                            SEntity = v2.Value or 0
                        elseif v2.Name == 'class Moho::Prop' then
                            SProp = v2.Value or 0
                        elseif v2.Name == 'class Moho::CDecalHandle' then
                            SCDecalHandle = v2.Value or 0
                        elseif v2.Name == 'class Moho::ReconBlip' then
                            SReconBlip = v2.Value or 0
                        end
                    end
                end
            end

            while true do

                GTS = GetGameTimeSeconds()
                if LastPrint + 60 < GTS then
                    SystemTime = GetSystemTimeSeconds()
                    LastPrint = LastPrint + 60
                    timedilatation = (SystemTime - LastSystemTime)
                    LastSystemTime = SystemTime
                    hours   = math.floor(GTS / 3600);
                    minutes = math.floor((GTS - (hours * 3600)) / 60);
                    seconds = GTS - (hours * 3600) - (minutes * 60);
                    desiredrate = GetGameSpeed()
                    simrate = GetSimRate()
                    simspeed = 100/timedilatation*60

                    for k, v in __EngineStats.Children do
                        if v.Name == 'Instance Counts' then
                            for k2, v2 in v.Children do
                                if v2.Name == 'class Moho::CTask' then
                                    CTask = v2.Value or 0
                                elseif v2.Name == 'class Moho::CTaskThread' then
                                    CTaskThread = v2.Value or 0
                                elseif v2.Name == 'class Moho::CScriptObject' then
                                    CScriptObject = v2.Value or 0
                                elseif v2.Name == 'class Moho::CLuaTask' then
                                    CLuaTask = v2.Value or 0
                                elseif v2.Name == 'class Moho::Entity' then
                                    Entity = v2.Value or 0
                                elseif v2.Name == 'class Moho::Prop' then
                                    Prop = v2.Value or 0
                                elseif v2.Name == 'class Moho::CDecalHandle' then
                                    CDecalHandle = v2.Value or 0
                                elseif v2.Name == 'class Moho::Unit' then
                                    Unit = v2.Value or 0
                                elseif v2.Name == 'class Moho::CPlatoon' then
                                    Platoon = v2.Value or 0
                                elseif v2.Name == 'class Moho::ReconBlip' then
                                    ReconBlip = v2.Value or 0
                                end
                            end
                        elseif v.Name == 'Heap' then
                            for k2, v2 in v.Children do
                                -- FAF game.exe
                                if v2.Name == 'Reserved' then
                                    reserved = v2.Value or 0
                                elseif v2.Name == 'Committed' then
                                    use = v2.Value or 0
                                -- Steam game.exe
                                elseif v2.Name == 'InUse' then
                                    reserved = v2.Value or 0
                                elseif v2.Name == 'TotalCheck' then
                                    use = v2.Value or 0
                                end
                            end
                        elseif v.Name == 'Frame' then
                            for k2, v2 in v.Children do
                                if v2.Name == 'FPS' then
                                    fps = v2.Value or 0
                                end
                            end
                        end
                    end

--                    if desiredrate == 9 then
--                        WARN('RESET')
--                        SEntity = Entity
--                        SProp = Prop
--                        SCScriptObject = CScriptObject
--                        SCTask = CTask
--                        SCTaskThread = CTaskThread
--                        SCLuaTask = CLuaTask
--                        SCDecalHandle = CDecalHandle
--                        SReconBlip = ReconBlip
--                    end
--        PrintText('* AI-Uveso: Gametime: ', 16, 'ffd0d0d0', 5 , 'center') ;

                    SPEW(string.format('Gametime: %02d:%02d:%02d --- Unit: %02d --- Platoon: %02d --- FPS: %02d --- Memory: %s / %s --- Speed: %+d / %+d --- SimSpeed: %02d%% ( 60 Game = %02d System Seconds )'
                                        , hours, minutes, seconds, Unit, Platoon, fps, reserved, use, desiredrate, simrate, simspeed, timedilatation))
                    SPEW(string.format(' Entity: %05d --- Prop: %05d --- CScriptObject: %05d --- CTask: %05d --- CTaskThread: %05d --- CLuaTask: %05d --- CDecalHandle: %05d --- ReconBlip: %05d'
                                        ,Entity, Prop, CScriptObject, CTask, CTaskThread, CLuaTask, CDecalHandle, ReconBlip))
--                    AILog(string.format(' Entity: %05d --- Prop: %05d --- CScriptObject: %05d --- CTask: %05d --- CTaskThread: %05d --- CLuaTask: %05d --- CDecalHandle: %05d --- ReconBlip: %05d'
--                                        ,Entity-SEntity, Prop-SProp, CScriptObject-SCScriptObject, CTask-SCTask, CTaskThread-SCTaskThread, CLuaTask-SCLuaTask, CDecalHandle-SCDecalHandle, ReconBlip-SReconBlip))
                end
                coroutine.yield(5)
            end
        end
    )
end
