local categories = categories
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'

BuilderGroup {
    BuilderGroupName = 'U234 Repair Shields Former',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'RepairLowShield 3',
        PlatoonTemplate = 'AddToRepairShieldsPlatoon',
        Priority = 1,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ShieldRepairAI',
        },
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 1, categories.SUBCOMMANDER} },
            { UCBC, 'UnitsLessInPlatoon', { 'ShieldRepairAI', 3 } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'RepairLowShield 6',
        PlatoonTemplate = 'AddToRepairShieldsPlatoon',
        Priority = 1,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ShieldRepairAI',
        },
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 1, categories.SUBCOMMANDER} },
            { UCBC, 'UnitsLessInPlatoon', { 'ShieldRepairAI', 8 } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.EXPERIMENTAL } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'RepairLowShield 10',
        PlatoonTemplate = 'AddToRepairShieldsPlatoon',
        Priority = 1,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ShieldRepairAI',
        },
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 1, categories.SUBCOMMANDER} },
            { UCBC, 'UnitsLessInPlatoon', { 'ShieldRepairAI', 12 } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL } },
        },
        BuilderType = 'Any',
    },
}