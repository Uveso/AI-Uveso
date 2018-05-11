-- Default economic builders for skirmish
local IBC = '/lua/editor/InstantBuildConditions.lua'
local SAI = '/lua/ScenarioPlatoonAI.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local MaxCapEngineers = 0.10 -- 10% of all units can be Engineers (categories.MOBILE * categories.ENGINEER)

-- ===================================================-======================================================== --
-- ==                                         Build Start Base                                               == --
-- ===================================================-======================================================== --
BuilderGroup {
    -- Build Main Base (only once). Factory and basic Energy
    BuilderGroupName = 'Initial ACU Builders Uveso',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Uveso CDR Initial Default',
        PlatoonAddBehaviors = { 'CommanderBehaviorUveso', },
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 8000,
        BuilderConditions = {
            { IBC, 'NotPreBuilt', {}},
        },
        InstantCheck = true,
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION, FACTORY CONSTRUCTION',
                AdjacencyDistance = 50,
                BuildStructures = {
                    'T1LANDFactory',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Uveso Initial ACU PreBuilt Default',
        PlatoonAddBehaviors = { 'CommanderBehaviorUveso', },
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 8000,
        BuilderConditions = {
            { IBC, 'PreBuiltBase', {}},
        },
        InstantCheck = true,
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1EnergyProduction',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
                    'T1AirFactory',
                    'T1EnergyProduction',
                }
            }
        }
    },
}
-- ===================================================-======================================================== --
-- ==                                 Build Engineers TECH 1,2,3 and SACU                                    == --
-- ===================================================-======================================================== --
BuilderGroup {
    -- Build Engineers TECH 1,2,3 and SACU
    BuilderGroupName = 'EngineerFactoryBuilders Uveso',
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    -- Build the minimum number of engineers to fill EngineerCap
    Builder {
        BuilderName = 'U1 Engineer builder Cap',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 1100,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech1' } },
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
        BuilderName = 'U1 Engineer noIdle',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 1100,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, 'ENGINEER TECH1' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapEngineers, '<=', categories.MOBILE * categories.ENGINEER } },
        },
        BuilderType = 'All',
    },
    -- Build more engineers if we don't find idle engineers
    Builder {
        BuilderName = 'U1 Engineer noIdle ecovampire',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 1100,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, 'ENGINEER TECH1' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapEngineers, '<=', categories.MOBILE * categories.ENGINEER } },
        },
        BuilderType = 'All',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2 Engineer builder Cap',
        PlatoonTemplate = 'T2BuildEngineer',
        Priority = 1100,
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
        -- Build more engineers if we don't find idle engineers
        BuilderName = 'U2 Engineer noIdle',
        PlatoonTemplate = 'T2BuildEngineer',
        Priority = 1100,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanIdleEngineers', { 2, 2 }}, -- count, tech (1=TECH1, 2=Tech2, 3=FieldTech, 4=TECH3, 5=SubCommander)
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.05}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, 'ENGINEER TECH1' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapEngineers, '<=', categories.MOBILE * categories.ENGINEER } },
        },
        BuilderType = 'All',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3 Engineer builder Cap',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 1100,
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
        -- Build more engineers if we don't find idle engineers
        BuilderName = 'U3 Engineer noIdle',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 1100,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanIdleEngineers', { 1, 3 }}, -- count, tech (1=TECH1, 2=Tech2, 3=FieldTech, 4=TECH3, 5=SubCommander)
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.05}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, 'ENGINEER TECH3' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapEngineers, '<=', categories.MOBILE * categories.ENGINEER } },
        },
        BuilderType = 'All',
    },
    -- ==================== --
    --    SUB COMMANDERS    --
    -- ==================== --
    Builder {
        BuilderName = 'U3 Sub Commander cap',
        PlatoonTemplate = 'T3LandSubCommander',
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'SCU' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.05}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapEngineers, '<=', categories.MOBILE * categories.ENGINEER } },
        },
        BuilderType = 'Gate',
    },
}
-- ===================================================-======================================================== --
-- ==                                          Engineer Transfers                                            == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Engineer Transfer To MainBase',
    BuildersType = 'EngineerBuilder',
    -- ============================================ --
    --    Transfer from LocationType to MainBase    --
    -- ============================================ --
    Builder {
        BuilderName = 'U1 Engi Trans to MainBase',
        PlatoonTemplate = 'U1EngineerTransfer',
        Priority = 500,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'GreaterThanGameTimeSeconds', { 180 } },
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
        Priority = 500,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'GreaterThanGameTimeSeconds', { 180 } },
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
        Priority = 500,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'GreaterThanGameTimeSeconds', { 180 } },
            { UCBC, 'BuildNotOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'EngineerManagerUnitsAtLocation', { 'LocationType', '>', 2,  'MOBILE TECH3' } },
        },
        BuilderData = {
            MoveToLocationType = 'MAIN',
        },
        BuilderType = 'Any',
    },
}
