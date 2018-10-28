
local LoadModBuilder = false
-- loop over __active_mods table and search for the mod BlackOps FAF: Unleashed
for index, moddata in __active_mods do
    if moddata.name == 'BlackOps FAF: Unleashed' then
        LOG('* AI-Uveso: BlackOps FAF: Unleashed is installed. Adding BuilderGroups')
        LoadModBuilder = true
        break
    end
end

-- if BlackOps FAF: Unleashed is installed, add the following builder
if LoadModBuilder then

-- Add locals for BuilderConditions
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
-- Hydrocarbon Power Plant upgrade (Black Ops)
BuilderGroup {
    BuilderGroupName = 'HydrocarbonUpgrade BlackOps',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U1 HydroUpgrade',
        PlatoonTemplate = 'T1PowerHydroUpgrade',
        Priority = 200,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.HYDROCARBON * categories.ENERGYPRODUCTION * categories.TECH1 } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.HYDROCARBON * categories.ENERGYPRODUCTION * categories.TECH2 } },
            { EBC, 'GreaterThanEconIncome', { 2, 10 } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
        },
        FormRadius = 10000,
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 HydroUpgrade',
        PlatoonTemplate = 'T2PowerHydroUpgrade',
        Priority = 200,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.HYDROCARBON * categories.ENERGYPRODUCTION * categories.TECH1 } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.HYDROCARBON * categories.ENERGYPRODUCTION * categories.TECH2 } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.HYDROCARBON * categories.ENERGYPRODUCTION * categories.TECH3 } },
            { EBC, 'GreaterThanEconIncome', { 2.6, 60 } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
        },
        FormRadius = 10000,
        BuilderType = 'Any',
    },
}

-- if we don't have BlackOps FAF: Unleashed installed, insert dummy BuilderGroups
else

BuilderGroup {
    BuilderGroupName = 'HydrocarbonUpgrade BlackOps',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
}

end