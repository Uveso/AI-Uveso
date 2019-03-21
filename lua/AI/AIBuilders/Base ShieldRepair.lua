local UCBC = '/lua/editor/UnitCountBuildConditions.lua'

BuilderGroup {
    BuilderGroupName = 'U234 Repair Shields Former',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'RepairLowShield 12',
        PlatoonTemplate = 'AddToRepairShieldsPlatoon',
        Priority = 1,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ShieldRepairAI',
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitsLessInPlatoon', { 'ShieldRepairAI', 12 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 1, categories.SUBCOMMANDER} },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'RepairLowShield 18',
        PlatoonTemplate = 'AddToRepairShieldsPlatoon',
        Priority = 1,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ShieldRepairAI',
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL } },
            { UCBC, 'UnitsLessInPlatoon', { 'ShieldRepairAI', 18 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 1, categories.SUBCOMMANDER} },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
}