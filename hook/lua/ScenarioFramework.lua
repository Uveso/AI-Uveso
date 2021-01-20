
-- sometimes air units are outside the map and the game can't end in gamemodes like "Annihilation"
OldIsHumanUnitFunctionUveso = IsHumanUnit
function IsHumanUnit(self)
    if not self:GetAIBrain().Uveso then
        -- execute the original function
        return OldIsHumanUnitFunctionUveso(self)
    end
    return true
end
