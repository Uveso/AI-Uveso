local UCBC = '/lua/editor/UnitCountBuildConditions.lua'

BuilderGroup {
    BuilderGroupName = 'RepairLowShields',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'RepairLowShield',
        PlatoonTemplate = 'RepairShields 3 16',
        Priority = 1,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 1, categories.SUBCOMMANDER} },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
}