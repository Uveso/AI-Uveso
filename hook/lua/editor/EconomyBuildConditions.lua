function GreaterThanEconStorageRatio(aiBrain, mStorageRatio, eStorageRatio)
    -- If a paragon is present, return true
    if aiBrain.HasParagon then
        return true
    end
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if (econ.MassStorageRatio >= mStorageRatio and econ.EnergyStorageRatio >= eStorageRatio) then
        return true
    end
    return false
end

function GreaterThanEconTrend(aiBrain, MassTrend, EnergyTrend)
    -- If a paragon is present, return true
    if aiBrain.HasParagon then
        return true
    end
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if (econ.MassTrend >= MassTrend and econ.EnergyTrend >= EnergyTrend) then
        return true
    end
    return false
end

function GreaterThanEconIncome(aiBrain, MassIncome, EnergyIncome)
    -- If a paragon is present, return true
    if aiBrain.HasParagon then
        return true
    end
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if (econ.MassIncome >= MassIncome and econ.EnergyIncome >= EnergyIncome) then
        return true
    end
    return false
end


