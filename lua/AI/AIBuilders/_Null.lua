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
        BuilderName = 'NC Air Factory',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 400,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.MASSEXTRACTION } },
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
                    'T1AirFactory',
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
        Priority = 10,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD } },
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
        BuilderName = 'N Power Low Trend',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 500,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'LessThanEnergyTrend', { 20.0 } },
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
        InstanceCount = 20,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 1000, -500, 50, 1, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = true,                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            Construction = {
                RepeatBuild = true,
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
}
BuilderGroup {
    -- Build MassExtractors / Creators 
    BuilderGroupName = 'N1 Transporter',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'N1 Air Transport 1st',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 18500, 
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - (categories.uea0203 + categories.EXPERIMENTAL) }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
}


BuilderGroup {
    BuilderGroupName = 'N1 Land Builders',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'U1N Tank',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 150,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 50, categories.MOBILE * categories.LAND }},
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1N Bot',
        PlatoonTemplate = 'T1LandDFBot',
        Priority = 150,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 50, categories.MOBILE * categories.LAND }},
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1N Mobile Artillery',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 150,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 50, categories.MOBILE * categories.LAND }},
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
}

BuilderGroup {
    BuilderGroupName = 'N2 Land Builders',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'U2N AttackTank',
        PlatoonTemplate = 'T2AttackTank',
        Priority = 250,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 40, categories.MOBILE } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2N MobileShields',
        PlatoonTemplate = 'T2MobileShields',
        Priority = 250,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 10, (categories.MOBILE * categories.SHIELD) + (categories.MOBILE * categories.STEALTHFIELD) } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
}

BuilderGroup {
    BuilderGroupName = 'N3 Land Builders',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'U3N Mobile Shields',
        PlatoonTemplate = 'T3MobileShields',
        Priority = 250,
        BuilderType = 'Land',
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 10, (categories.MOBILE * categories.SHIELD) + (categories.MOBILE * categories.STEALTHFIELD) } },
            -- Respect UnitCap
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'N123 Land Formers',                              -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U123N Land Attack',                                -- Random Builder Name.
        PlatoonTemplate = 'U1234 NULL 10 20',                            -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 110,                                                         -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 10000,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS - categories.AIR , -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MASSEXTRACTION,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.DEFENSE - categories.ANTIAIR,
                categories.DEFENSE,
                categories.MASSEXTRACTION,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
             -- When do we want to form this ?
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}

