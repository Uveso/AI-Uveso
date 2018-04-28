-- Default economic builders for skirmish
local IBC = '/lua/editor/InstantBuildConditions.lua'
local SAI = '/lua/ScenarioPlatoonAI.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

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
        Priority = 2000,
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
        Priority = 2000,
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
    Builder {
        -- Build the minimum number of engineers to fill EngineerCap
        BuilderName = 'U1 Engineer builder Cap',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 1100,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech1' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'ENGINEER TECH1' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
         },
        BuilderType = 'All',
    },
    Builder {
        -- Build more engineers if we don't find idle engineers
        BuilderName = 'U1 Engineer noIdle',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 1100,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanIdleEngineers', { 4, 1 }}, -- count, tech (1=TECH1, 2=Tech2, 3=FieldTech, 4=TECH3, 5=SubCommander)
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.05}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, 'ENGINEER TECH1' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.12, '<=', categories.MOBILE * categories.ENGINEER } }, -- if we can't build more structures, we dont need more engineers.
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
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech2' } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'ENGINEER TECH2' } },
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
            { UCBC, 'HaveLessThanIdleEngineers', { 2, 2 }}, -- location, count, tech (1=TECH1, 2=Tech2, 3=FieldTech, 4=TECH3, 5=SubCommander)
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.05}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusCap', { 0.12, '<=', categories.MOBILE * categories.ENGINEER } }, -- if we can't build more structures, we dont need more engineers.
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
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech3' } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'ENGINEER TECH3' } },
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
            { UCBC, 'HaveLessThanIdleEngineers', { 3, 4 }}, -- location, count, tech (1=TECH1, 2=Tech2, 3=FieldTech, 4=TECH3, 5=SubCommander)
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.05}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusCap', { 0.12, '<=', categories.MOBILE * categories.ENGINEER } }, -- if we can't build more structures, we dont need more engineers.
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
            { IBC, 'BrainNotLowPowerMode', {} },
            { IBC, 'BrainNotLowMassMode', {} },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0} },
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusCap', { 0.12, '<=', categories.MOBILE * categories.ENGINEER } }, -- if we can't build more structures, we dont need more engineers.
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
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*20 } },
            { UCBC, 'BuildNotOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'EngineerManagerUnitsAtLocation', { 'LocationType', '>', 3,  'MOBILE TECH1' } },
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
        InstanceCount = 5,
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
        Priority = 500,
        InstanceCount = 10,
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
