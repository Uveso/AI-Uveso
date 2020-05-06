local Prefs = import('/lua/user/prefs.lua')
local AIoptions = Prefs.GetFromCurrentProfile('LobbyPresets')[1].GameOptions

-- Hook for debug only
local UvesoDoGameResult = DoGameResult
function DoGameResult(armyIndex, result)
    LOG('gameresult.lua AIEndlessGameLoop '..repr(AIoptions))
    if AIoptions.AIEndlessGameLoop == 'on' then
        if string.find(result, "victory") or string.find(result, "draw") then
            RestartSession()
        end
    end
    UvesoDoGameResult(armyIndex, result)
end
