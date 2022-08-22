
-- Hook for debug option AIEndlessGameLoop
local UvesoDoGameResult = DoGameResult
local Restarting
function DoGameResult(armyIndex, result)
    if Restarting then
        return
    end
    local Prefs = import('/lua/user/prefs.lua')
    local GameOptions = Prefs.GetFromCurrentProfile('LobbyPresets')[1].GameOptions
    local AIName = GetArmiesTable().armiesTable[armyIndex].nickname

    local GTS = GetGameTimeSeconds()
    local hours   = math.floor(GTS / 3600);
    local minutes = math.floor((GTS - (hours * 3600)) / 60);
    local seconds = GTS - (hours * 3600) - (minutes * 60);
    LOG('* AI-Uveso: Function DoGameResult(): Game Time ['..string.format("%02d:%02d:%02d", hours, minutes, seconds)..'] --- Player Name: '..AIName..' - Result: '..result)

    local condPos = string.find(result, " ")
    local GameResult
    if condPos > 0 then
        GameResult = string.sub(result, 1, condPos - 1)
    end
    -- calculate if we have a draw; 
    if GameResult == 'victory' or GameResult == 'draw' or GameResult == 'gameOver' then
        Restarting = true
        ForkThread(
            function()
                if GameOptions.AIEndlessGameLoop == 'on' then
                    LOG('* AI-Uveso: Function DoGameResult(): Game Time ['..string.format("%02d:%02d:%02d", hours, minutes, seconds)..'] --- Game ended; GameResult: "'..GameResult..'". Restarting in 5 seconds...')
                    coroutine.yield(50)
                    LOG('* AI-Uveso: Function DoGameResult(): Game Time ['..string.format("%02d:%02d:%02d", hours, minutes, seconds)..'] --- Game ended; Restarting!!!')
                    RestartSession()
                else
                    LOG('* AI-Uveso: Function DoGameResult(): Game Time ['..string.format("%02d:%02d:%02d", hours, minutes, seconds)..'] --- Game ended; GameResult: "'..GameResult..'".')
                    return UvesoDoGameResult(armyIndex, result)
                end
            end
        )
    else
        ForkThread(
            function()
                local count = 0
                -- wait for gameend or do normal gameresult
                LOG('* AI-Uveso: Function DoGameResult(): Game Time ['..string.format("%02d:%02d:%02d", hours, minutes, seconds)..'] --- Searching for game end...')
                while true do
                    if Restarting then
                        return
                    end
                    count = count + 1
                    if count > 100 then
                        break
                    end
                    if Sync.GameEnded then
                        Restarting = true
                        if GameOptions.AIEndlessGameLoop == 'on' then
                            LOG('* AI-Uveso: Function DoGameResult(): Sync.GameEnded after ['..string.format("%02d:%02d:%02d", hours, minutes, seconds)..'] --- maybe DRAW ?. Restarting in 10 seconds...')
                            coroutine.yield(100)
                            LOG('* AI-Uveso: Function DoGameResult(): Sync.GameEnded after ['..string.format("%02d:%02d:%02d", hours, minutes, seconds)..'] --- Restarting!!!')
                            RestartSession()
                        else
                            LOG('* AI-Uveso: Function DoGameResult(): Sync.GameEnded after ['..string.format("%02d:%02d:%02d", hours, minutes, seconds)..'] --- maybe DRAW ?.')
                            return UvesoDoGameResult(armyIndex, result)
                        end
                    end
                    coroutine.yield(1)
                end
                LOG('* AI-Uveso: Function DoGameResult(): Sync.GameEnded after ['..string.format("%02d:%02d:%02d", hours, minutes, seconds)..'] --- Game is continuing!')
                return UvesoDoGameResult(armyIndex, result)
            end
        )
    end
end
