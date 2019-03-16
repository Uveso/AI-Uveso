-- Default economic builders for skirmish
local IBC = '/lua/editor/InstantBuildConditions.lua'
local SAI = '/lua/ScenarioPlatoonAI.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua').GetDangerZoneRadii()

local MaxCapEngineers = 0.15 -- 15% of all units can be Engineers (categories.MOBILE * categories.ENGINEER)

-- ===================================================-======================================================== --
-- ==                                 Build Engineers TECH 1,2,3 and SACU                                    == --
-- ===================================================-======================================================== --
BuilderGroup {
    -- Build Engineers TECH 1,2,3 and SACU
    BuilderGroupName = 'EngineerFactoryBuilders Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U1 Engineer builder Cap',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 19000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.MOBILE * categories.ENGINEER * categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, 'ENGINEER TECH1' } },
            -- Respect UnitCap
         },
        BuilderType = 'All',
    },
    -- Build more engineers if we don't find idle engineers
    Builder {
        BuilderName = 'U1 Engineer noPool land',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 18400,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.MOBILE * categories.ENGINEER * categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapEngineers / 3 , '<', categories.MOBILE * categories.ENGINEER * categories.TECH1 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1 Engineer noPool air',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 18400,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 5, categories.MOBILE * categories.ENGINEER * categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapEngineers / 3 , '<', categories.MOBILE * categories.ENGINEER * categories.TECH1 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1 Engineer noPool naval',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 18400,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.MOBILE * categories.ENGINEER * categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapEngineers / 3 , '<', categories.MOBILE * categories.ENGINEER * categories.TECH1 } },
        },
        BuilderType = 'Sea',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2 Engineer builder Cap',
        PlatoonTemplate = 'T2BuildEngineer',
        Priority = 18500,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech2' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, 'ENGINEER TECH2' } },
            -- Respect UnitCap
        },
        BuilderType = 'All',
    },
    Builder {
        BuilderName = 'U2 Engineer noPool',
        PlatoonTemplate = 'T2BuildEngineer',
        Priority = 18400,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.MOBILE * categories.ENGINEER * categories.TECH2 } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapEngineers / 3 , '<', categories.MOBILE * categories.ENGINEER * categories.TECH2 } },
        },
        BuilderType = 'All',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3 Engineer builder Cap',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 18500,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech3' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, 'ENGINEER TECH3' } },
            -- Respect UnitCap
        },
        BuilderType = 'All',
    },
    Builder {
        BuilderName = 'U3 Engineer noPool',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 18400,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.MOBILE * categories.ENGINEER * categories.TECH3 - categories.SUBCOMMANDER } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapEngineers / 3 , '<', categories.MOBILE * categories.ENGINEER * categories.TECH3 } },
        },
        BuilderType = 'All',
    },
}
BuilderGroup {
    -- Build Engineers TECH 1,2,3 and SACU
    BuilderGroupName = 'GateFactoryBuilders Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ==================== --
    --    SUB COMMANDERS    --
    -- ==================== --
    Builder {
        BuilderName = 'U3 Sub Commander cap',
        PlatoonTemplate = 'T3LandSubCommander',
        Priority = 18400,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.SUBCOMMANDER } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.SUBCOMMANDER }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 Sub Commander 30',
        PlatoonTemplate = 'T3LandSubCommander',
        Priority = 18400,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 35, categories.SUBCOMMANDER } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { 0.03 , '<', categories.MOBILE * categories.SUBCOMMANDER } },
        },
        BuilderType = 'Gate',
    },
}

-- ===================================================-======================================================== --
-- ==                                          Engineer Transfers                                            == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Engineer Transfer To MainBase',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    -- ============================================ --
    --    Transfer from LocationType to MainBase    --
    -- ============================================ --
    Builder {
        BuilderName = 'U1 Engi Trans to MainBase',
        PlatoonTemplate = 'U1EngineerTransfer',
        Priority = 18300,
        InstanceCount = 3,
        BuilderConditions = {
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*20 } },
            { UCBC, 'BuildNotOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'EngineerManagerUnitsAtLocation', { 'LocationType', '>', 2,  'MOBILE TECH1' } },
        },
        BuilderData = {
            MoveToLocationType = 'MAIN',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Engi Trans to MainBase',
        PlatoonTemplate = 'U2EngineerTransfer',
        Priority = 18300,
        InstanceCount = 3,
        BuilderConditions = {
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*20 } },
            { UCBC, 'BuildNotOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'EngineerManagerUnitsAtLocation', { 'LocationType', '>', 2,  'MOBILE TECH2' } },
        },
        BuilderData = {
            MoveToLocationType = 'MAIN',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U3 Engi Trans to MainBase',
        PlatoonTemplate = 'U3EngineerTransfer',
        Priority = 18300,
        InstanceCount = 3,
        BuilderConditions = {
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*20 } },
            { UCBC, 'BuildNotOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'EngineerManagerUnitsAtLocation', { 'LocationType', '>', 2,  'MOBILE TECH3' } },
        },
        BuilderData = {
            MoveToLocationType = 'MAIN',
        },
        BuilderType = 'Any',
    },
}
