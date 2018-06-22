-- Default economic builders for skirmish
local IBC = '/lua/editor/InstantBuildConditions.lua'
local SAI = '/lua/ScenarioPlatoonAI.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local MaxCapEngineers = 0.10 -- 10% of all units can be Engineers (categories.MOBILE * categories.ENGINEER)

local mapSizeX, mapSizeZ = GetMapSize()
local BaseMilitaryZone = math.max( mapSizeX-50, mapSizeZ-50 ) / 2               -- Half the map
local BasePanicZone = BaseMilitaryZone / 2
BasePanicZone = math.max( 60, BasePanicZone )
BasePanicZone = math.min( 120, BasePanicZone )
BaseMilitaryZone = math.max( 250, BaseMilitaryZone )

-- ===================================================-======================================================== --
-- ==                                         Build Start Base                                               == --
-- ===================================================-======================================================== --
BuilderGroup {
    -- Build Main Base (only once). Factory and basic Energy
    BuilderGroupName = 'Initial ACU Builders Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'UC CDR Initial Default',
        PlatoonAddBehaviors = { 'CommanderBehaviorUveso', },
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 19500,
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
        BuilderName = 'UC Initial ACU PreBuilt Default',
        PlatoonAddBehaviors = { 'CommanderBehaviorUveso', },
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 19500,
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
    BuilderGroupName = 'EngineerFactoryBuilders Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    -- Build the minimum number of engineers to fill EngineerCap
    Builder {
        BuilderName = 'U1 Engineer builder Cap',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 18500,
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
        Priority = 18400,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanIdleEngineers', { 1, 1 }}, -- count, tech (1=TECH1, 2=Tech2, 3=FieldTech, 4=TECH3, 5=SubCommander)
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.0, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER}}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, 'ENGINEER TECH1' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapEngineers/2, '<=', categories.MOBILE * categories.ENGINEER } },
        },
        BuilderType = 'All',
    },
    Builder {
        BuilderName = 'U1 Engineer noIdle air',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 18400,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanIdleEngineers', { 2, 1 }}, -- count, tech (1=TECH1, 2=Tech2, 3=FieldTech, 4=TECH3, 5=SubCommander)
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapEngineers/2, '<=', categories.MOBILE * categories.ENGINEER } },
        },
        BuilderType = 'Air',
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
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER}}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, 'ENGINEER TECH2' } },
            -- Respect UnitCap
        },
        BuilderType = 'All',
    },
    Builder {
        -- Build more engineers if we don't find idle engineers
        BuilderName = 'U2 Engineer noIdle',
        PlatoonTemplate = 'T2BuildEngineer',
        Priority = 18400,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanIdleEngineers', { 2, 2 }}, -- count, tech (1=TECH1, 2=Tech2, 3=FieldTech, 4=TECH3, 5=SubCommander)
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            -- Don't build it if...
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER}}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'ENGINEER TECH2' } },
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
        Priority = 18500,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech3' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER}}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, 'ENGINEER TECH3' } },
            -- Respect UnitCap
        },
        BuilderType = 'All',
    },
    Builder {
        -- Build more engineers if we don't find idle engineers
        BuilderName = 'U3 Engineer noIdle',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 18400,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanIdleEngineers', { 2, 4 }}, -- count, tech (1=TECH1, 2=Tech2, 3=FieldTech, 4=TECH3, 5=SubCommander)
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'ENGINEER TECH3' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapEngineers, '<=', categories.MOBILE * categories.ENGINEER } },
        },
        BuilderType = 'All',
    },
    Builder {
        -- Build more engineers if we don't find idle engineers
        BuilderName = 'U3 Engineer noIdle ECOFULL',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 18400,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanIdleEngineers', { 3, 4 }}, -- count, tech (1=TECH1, 2=Tech2, 3=FieldTech, 4=TECH3, 5=SubCommander)
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.95, -0.00}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
        Priority = 18400,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'SCU' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 1.00}}, -- Ratio from 0 to 1. (1=100%)
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
    BuilderGroupName = 'Engineer Transfer To MainBase',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
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
        InstanceCount = 2,
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
        InstanceCount = 1,
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
