
-- Hook for debug only
local UvesoDoGameResult = DoGameResult
function DoGameResult(armyIndex, result)
    local Prefs = import('/lua/user/prefs.lua')
    local GameOptions = Prefs.GetFromCurrentProfile('LobbyPresets')[1].GameOptions
    if GameOptions.AIEndlessGameLoop == 'on' then
        if string.find(result, "victory") or string.find(result, "draw") then
            RestartSession()
        end
    end
    UvesoDoGameResult(armyIndex, result)
end
