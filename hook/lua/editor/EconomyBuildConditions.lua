-- canbe removed after the next FAF patch 07.Oct.2022
local GetEconomyTrend = moho.aibrain_methods.GetEconomyTrend
local GetEconomyIncome = moho.aibrain_methods.GetEconomyIncome

GreaterThanEconStorageRatio_FunctionBackupUveso = GreaterThanEconStorageRatio
function GreaterThanEconStorageRatio(aiBrain, mStorageRatio, eStorageRatio)
   -- Only use this with AI-Uveso
    if not aiBrain.Uveso then
        return GreaterThanEconStorageRatio_FunctionBackupUveso(aiBrain, mStorageRatio, eStorageRatio)
    end
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    -- If a paragon is present and we not stall mass or energy, return true
    if aiBrain.PriorityManager.HasParagon and econ.MassStorageRatio >= 0.01 and econ.EnergyStorageRatio >= 0.01 then
        return true
    elseif econ.MassStorageRatio >= mStorageRatio and econ.EnergyStorageRatio >= eStorageRatio then
        return true
    end
    return false
end

GreaterThanEconTrend_FunctionBackupUveso = GreaterThanEconTrend
function GreaterThanEconTrend(aiBrain, MassTrend, EnergyTrend)
   -- Only use this with AI-Uveso
    if not aiBrain.Uveso then
        return GreaterThanEconTrend_FunctionBackupUveso(aiBrain, MassTrend, EnergyTrend)
    end
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    -- If a paragon is present and we have at least a neutral m+e trend, return true
    if aiBrain.PriorityManager.HasParagon and econ.MassTrend >= 0 and econ.EnergyTrend >= 0 then
        return true
    elseif econ.MassTrend >= MassTrend and econ.EnergyTrend >= EnergyTrend then
        return true
    end
    return false
end

GreaterThanEconIncome_FunctionBackupUveso = GreaterThanEconIncome
function GreaterThanEconIncome(aiBrain, MassIncome, EnergyIncome)
   -- Only use this with AI-Uveso
    if not aiBrain.Uveso then
        return GreaterThanEconIncome_FunctionBackupUveso(aiBrain, MassIncome, EnergyIncome)
    end
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    -- If a paragon is present, return true
    if aiBrain.PriorityManager.HasParagon and econ.MassTrend >= 0 and econ.EnergyTrend >= 0 then
        return true
    elseif (econ.MassIncome >= MassIncome and econ.EnergyIncome >= EnergyIncome) then
        return true
    end
    return false
end

--            { UCBC, 'LessThanMassTrend', { 50.0 } },
function LessThanMassTrend(aiBrain, mTrend)
    if GetEconomyTrend(aiBrain, 'MASS') < mTrend then
        return true
    else
        return false
    end
end

--            { UCBC, 'LessThanEnergyTrend', { 50.0 } },
function LessThanEnergyTrend(aiBrain, eTrend)
    if GetEconomyTrend(aiBrain, 'ENERGY') < eTrend then
        return true
    else
        return false
    end
end

--            { UCBC, 'EnergyToMassRatioIncome', { 10.0, '>=',true } },  -- True if we have 10 times more Energy then Mass income ( 100 >= 10 = true )
function EnergyToMassRatioIncome(aiBrain, ratio, compareType)
    return CompareBody(GetEconomyIncome(aiBrain,'ENERGY') / GetEconomyIncome(aiBrain,'MASS'), ratio, compareType)
end
