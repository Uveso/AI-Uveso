
OldGreaterThanEconStorageRatioFunction = GreaterThanEconStorageRatio
function GreaterThanEconStorageRatio(aiBrain, mStorageRatio, eStorageRatio)
   -- Only use this with AI-Uveso
    if not aiBrain.Uveso then
        return OldGreaterThanEconStorageRatioFunction(aiBrain, mStorageRatio, eStorageRatio)
    end
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    -- If a paragon is present and we not stall mass or energy, return true
    if aiBrain.HasParagon and econ.MassStorageRatio >= 0.01 and econ.EnergyStorageRatio >= 0.01 then
        return true
    elseif econ.MassStorageRatio >= mStorageRatio and econ.EnergyStorageRatio >= eStorageRatio then
        return true
    end
    return false
end

OldGreaterThanEconTrendFunction = GreaterThanEconTrend
function GreaterThanEconTrend(aiBrain, MassTrend, EnergyTrend)
   -- Only use this with AI-Uveso
    if not aiBrain.Uveso then
        return OldGreaterThanEconTrendFunction(aiBrain, MassTrend, EnergyTrend)
    end
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    -- If a paragon is present and we have at least a neutral m+e trend, return true
    if aiBrain.HasParagon and econ.MassTrend >= 0 and econ.EnergyTrend >= 0 then
        return true
    elseif econ.MassTrend >= MassTrend and econ.EnergyTrend >= EnergyTrend then
        return true
    end
    return false
end

OldGreaterThanEconIncomeFunction = GreaterThanEconIncome
function GreaterThanEconIncome(aiBrain, MassIncome, EnergyIncome)
   -- Only use this with AI-Uveso
    if not aiBrain.Uveso then
        return OldGreaterThanEconIncomeFunction(aiBrain, MassIncome, EnergyIncome)
    end
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
