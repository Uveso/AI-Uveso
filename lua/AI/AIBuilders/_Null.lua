local categories = categories
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua').GetDangerZoneRadii()

local MaxCapEngineers = 0.15 -- 15% of all units can be Engineers (categories.MOBILE * categories.ENGINEER)

-- ===================================================-======================================================== --
-- ==                                 Build Engineers TECH 1,2,3 and SACU                                    == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'N1 1 Factory Builders',                             -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'NC Land Factory',
        PlatoonTemplate = 'CommanderBuilder',
        TechRoot = 'FACTORY1',
        Priority = 600,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'N1 Land Factory',
        PlatoonTemplate = 'EngineerBuilder',
        TechRoot = 'FACTORY1',
        Priority = 700,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'N1 1 Engineer Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'N Engineer builder',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 700,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ENGINEER * categories.TECH1 } },
            -- Respect UnitCap
         },
        BuilderType = 'All',
    },
}

BuilderGroup {
    -- Build Power TECH 1,2,3
    BuilderGroupName = 'N1 1 Energy Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'UC Power low trend',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 17900,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'LessThanEnergyTrend', { 0.0 } },
            { EBC, 'GreaterThanEconIncome',  { 0.2, 0.0}}, -- Absolut Base income
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 } },
            -- Respect UnitCap
        },
        InstanceCount = 1,
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.FACTORY * (categories.LAND + categories.AIR),
                AdjacencyDistance = 50,
                BuildClose = true,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },
}

BuilderGroup {
    -- Build MassExtractors / Creators 
    BuilderGroupName = 'N1 MassBuilders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'N Mass',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 1000,
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 1000, -500, 50, 1, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                RepeatBuild = true,
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
}
