-- Default economic builders for skirmish
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local IBC = '/lua/editor/InstantBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local MaxCapFactory = 0.024 -- 2.4% of all units can be factories (STRUCTURE * FACTORY)
local MaxCapStructure = 0.14 -- 14% of all units can be structures (STRUCTURE -MASSEXTRACTION -DEFENSE -FACTORY)

local mapSizeX, mapSizeZ = GetMapSize()
local BaseMilitaryZone = math.max( mapSizeX-50, mapSizeZ-50 ) / 2               -- Half the map
local BasePanicZone = BaseMilitaryZone / 2
BasePanicZone = math.max( 60, BasePanicZone )
BasePanicZone = math.min( 120, BasePanicZone )

-- ===================================================-======================================================== --
-- ==                             Build Factories Land/Air/Sea/Quantumgate                                   == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'FactoryBuilders Uveso',
    BuildersType = 'EngineerBuilder',
    -- ================ --
    --    TECH 1 2nd    --
    -- ================ --
    Builder {
        BuilderName = 'U-CDR Land Factory 2nd',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 3600,
        DelayEqualBuildPlattons = {'Factories', 5},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 0.8, 12.0}}, -- Absolut Base income
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION',
                Location = 'LocationType',
                BuildClose = true,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'CDR AIR Factory 1st',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 3600,
        DelayEqualBuildPlattons = {'Factories', 5},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.00, 'STRUCTURE FACTORY AIR', '<','STRUCTURE FACTORY AIR' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.90}}, -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconIncome',  { 0.8, 0.1}}, -- Absolut Base income
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION',
                Location = 'LocationType',
                BuildClose = true,
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Sea Factory 1st',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 3600,
        DelayEqualBuildPlattons = {'Factories', 5},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.00, 'STRUCTURE FACTORY NAVAL', '<','STRUCTURE FACTORY NAVAL' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'Naval Area' } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH1 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 0.8, 0.1}}, -- Absolut Base income
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH1 }},
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION',
                Location = 'LocationType',
                BuildClose = true,
                BuildStructures = {
                    'T1SeaFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Land Factory ECOFULL',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 3600,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 10, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'GreaterThanGameTimeSeconds', { 240 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.85, -0.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapFactory , '<=', categories.STRUCTURE * categories.FACTORY * categories.LAND } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION',
                Location = 'LocationType',
                BuildClose = true,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    -- ================== --
    --    TECH 1 Enemy    --
    -- ================== --
    Builder {
        BuilderName = 'U1 Land Factory Panic',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 3600,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            { UCBC, 'GreaterThanGameTimeSeconds', { 240 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapFactory , '<=', categories.STRUCTURE * categories.FACTORY * categories.LAND } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION',
                Location = 'LocationType',
                BuildClose = true,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'CDR Land Factory Enemy',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 3490,
        DelayEqualBuildPlattons = {'Factories', 1},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.00, 'STRUCTURE FACTORY LAND', '<','STRUCTURE FACTORY LAND' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapFactory , '<=', categories.STRUCTURE * categories.FACTORY * categories.LAND } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION',
                Location = 'LocationType',
                BuildClose = true,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'CDR Air Factory Enemy',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 3500,
        DelayEqualBuildPlattons = {'Factories', 1},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.00, 'STRUCTURE FACTORY AIR', '<','STRUCTURE FACTORY AIR' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveUnitRatio', { 1.0, 'STRUCTURE FACTORY AIR', '<','STRUCTURE FACTORY LAND' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapFactory , '<=', categories.STRUCTURE * categories.FACTORY * categories.LAND } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION',
                Location = 'LocationType',
                BuildClose = true,
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Sea Factory Enemy',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 3500,
        DelayEqualBuildPlattons = {'Factories', 1},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.00, 'STRUCTURE FACTORY NAVAL', '<','STRUCTURE FACTORY NAVAL' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'Naval Area' } },
            { UCBC, 'HaveUnitRatio', { 1.0, 'STRUCTURE FACTORY NAVAL', '<','STRUCTURE FACTORY LAND' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH1 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapFactory , '<=', categories.STRUCTURE * categories.FACTORY * categories.LAND } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                NearMarkerType = 'Naval Area',
                LocationRadius = 90,
                Location = 'LocationType',
                BuildStructures = {
                    'T1Sonar',
                    'T1NavalDefense',
                    'T1SeaFactory',
                    'T1AADefense',
                    'T1NavalDefense',
                },
            }
        }
    },
    -- ================ --
    --    TECH 1 Cap    --
    -- ================ --
    Builder {
        BuilderName = 'U1 Land Factory Cap',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 3500,
        DelayEqualBuildPlattons = {'Factories', 1},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Land' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'GreaterThanGameTimeSeconds', { 120 } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH1' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapFactory , '<=', categories.STRUCTURE * categories.FACTORY * categories.LAND } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION',
                Location = 'LocationType',
                BuildClose = true,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Air Factory Cap',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 3500,
        DelayEqualBuildPlattons = {'Factories', 1},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Air' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 120 } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH1' }},
            { UCBC, 'HaveUnitRatio', { 1.0, 'STRUCTURE FACTORY AIR', '<','STRUCTURE FACTORY LAND' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapFactory , '<=', categories.STRUCTURE * categories.FACTORY * categories.LAND } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION',
                Location = 'LocationType',
                BuildClose = true,
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Sea Factory Cap',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 3500,
        DelayEqualBuildPlattons = {'Factories', 1},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Sea' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 120 } },
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'Naval Area' } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH1' }},
            { UCBC, 'HaveUnitRatio', { 1.0, 'STRUCTURE FACTORY NAVAL', '<','STRUCTURE FACTORY LAND' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH1 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapFactory , '<=', categories.STRUCTURE * categories.FACTORY * categories.LAND } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                NearMarkerType = 'Naval Area',
                LocationRadius = 90,
                Location = 'LocationType',
                BuildStructures = {
                    'T1Sonar',
                    'T1NavalDefense',
                    'T1SeaFactory',
                    'T1AADefense',
                    'T1NavalDefense',
                },
            }
        }
    },
    -- build at lest 4 factories at every naval location
    Builder {
        BuilderName = 'U1 Sea Factory < 4',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 3500,
        DelayEqualBuildPlattons = {'Factories', 1},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.STRUCTURE * categories.FACTORY * categories.NAVAL } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 120 } },
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'Naval Area' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH1 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapFactory , '<=', categories.STRUCTURE * categories.FACTORY * categories.LAND } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                NearMarkerType = 'Naval Area',
                LocationRadius = 90,
                Location = 'LocationType',
                BuildStructures = {
                    'T1Sonar',
                    'T1NavalDefense',
                    'T1SeaFactory',
                    'T1AADefense',
                    'T1NavalDefense',
                },
            }
        }
    },
    -- ==================== --
    --    TECH 1 Minimum    --
    -- ==================== --
    -- Expansion builders don't build factories, so we are doing it here ig we have the eco for it.
    Builder {
        BuilderName = 'U1 Land Factory Min',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 3500,
        DelayEqualBuildPlattons = {'Factories', 1},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, categories.STRUCTURE * categories.FACTORY * categories.LAND}},
            -- Do we need additional conditions to build it ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 600 } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH1' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapFactory , '<=', categories.STRUCTURE * categories.FACTORY * categories.LAND } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION',
                Location = 'LocationType',
                BuildClose = true,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Air Factory Min',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 3500,
        DelayEqualBuildPlattons = {'Factories', 1},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, categories.STRUCTURE * categories.FACTORY * categories.AIR}},
            -- Do we need additional conditions to build it ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 800 } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH1' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapFactory , '<=', categories.STRUCTURE * categories.FACTORY * categories.AIR } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION',
                Location = 'LocationType',
                BuildClose = true,
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Sea Factory Min',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 3500,
        DelayEqualBuildPlattons = {'Factories', 1},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, categories.STRUCTURE * categories.FACTORY * categories.NAVAL}},
            -- Do we need additional conditions to build it ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 800 } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH1' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH1 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapFactory , '<=', categories.STRUCTURE * categories.FACTORY * categories.NAVAL } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                NearMarkerType = 'Naval Area',
                LocationRadius = 90,
                Location = 'LocationType',
                BuildStructures = {
                    'T1Sonar',
                    'T1NavalDefense',
                    'T1SeaFactory',
                    'T1AADefense',
                    'T1NavalDefense',
                },
            }
        }
    },
    -- ==================== --
    --    TECH 1 RECOVER    --
    -- ==================== --
    Builder {
        BuilderName = 'U1 Land Factory RECOVER',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 3000,
        DelayEqualBuildPlattons = {'Factories', 1},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, 'STRUCTURE FACTORY' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 0.6, 9.0}}, -- Absolut Base income 4 100
            -- Don't build it if...
            { UCBC, 'GreaterThanGameTimeSeconds', { 60 } },
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION',
                Location = 'LocationType',
                BuildClose = true,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'CDR Land Factory RECOVER',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 3000,
        DelayEqualBuildPlattons = {'Factories', 1},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, 'STRUCTURE FACTORY' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 0.6, 9.0}}, -- Absolut Base income 4 100
            -- Don't build it if...
            { UCBC, 'GreaterThanGameTimeSeconds', { 60 } },
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION',
                Location = 'LocationType',
                BuildClose = true,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    -- ======================= --
    --    Reclaim Buildings    --
    -- ======================= --
    Builder {
        BuilderName = 'U1 Reclaim T1 FacLand',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 750,
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitCapCheckGreater', { 0.98 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND - categories.TECH1 } },
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {'STRUCTURE FACTORY LAND TECH1'},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U1 Reclaim T2 FacLand',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 750,
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitCapCheckGreater', { 0.98 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH2 } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 } },
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {'STRUCTURE FACTORY LAND TECH2'},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U1 Reclaim T3 FacLand',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 750,
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitCapCheckGreater', { 0.98 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {'STRUCTURE FACTORY LAND TECH3'},
        },
        BuilderType = 'Any',
    },
}
-- ===================================================-======================================================== --
-- ==                             Upgrade Factories Land/Air/Sea                                             == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'FactoryUpgradeBuilders Uveso',
    BuildersType = 'PlatoonFormBuilder',
    -- ================= --
    --    TECH 1 LAND    --
    -- ================= --
    Builder {
        BuilderName = 'U1 Land Factory Upgrade Force 1st',
        PlatoonTemplate = 'T1LandFactoryUpgrade',
        Priority = 3500,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 3.0, 40.0}}, -- Absolut Base income
            -- Don't build it if...
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND - categories.TECH1 } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U1 Land Factory UP always',
        PlatoonTemplate = 'T1LandFactoryUpgrade',
        Priority = 3000,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND - categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U1 Land Factory UP Turbo',
        PlatoonTemplate = 'T1LandFactoryUpgrade',
        Priority = 3000,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.STRUCTURE * categories.FACTORY * categories.LAND - categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.95, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 4, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    -- ================ --
    --    TECH 1 AIR    --
    -- ================ --
    Builder {
        BuilderName = 'U1 Air Factory UP always',
        PlatoonTemplate = 'T1AirFactoryUpgrade',
        Priority = 3000,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH2 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    -- ================== --
    --    TECH 1 NAVAL    --
    -- ================== --
    Builder {
        BuilderName = 'U1 Naval Factory Upgrade Force 1st',
        PlatoonTemplate = 'T1SeaFactoryUpgrade',
        Priority = 3490,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.10}}, -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }}, -- relative baseincome 0=bad, 1=ok, 2=full
            { EBC, 'GreaterThanEconIncome',  { 1.8, 15.0}}, -- Absolut Base income
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * ( categories.TECH2 + categories.TECH3 ) } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U1 Sea Factory UP always',
        PlatoonTemplate = 'T1SeaFactoryUpgrade',
        Priority = 3000,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    -- ================= --
    --    TECH 2 LAND    --
    -- ================= --
    Builder {
        BuilderName = 'U2 Land Factory Upgrade Force 1st',
        PlatoonTemplate = 'T2LandFactoryUpgrade',
        Priority = 3500,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.ENERGYPRODUCTION * ( categories.TECH2 + categories.TECH3 )  }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            -- Don't build it if...
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH2 }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Land Factory UP always',
        PlatoonTemplate = 'T2LandFactoryUpgrade',
        Priority = 3000,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER}}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH2 }},
        },
        BuilderType = 'Any',
    },
    -- ================ --
    --    TECH 2 AIR    --
    -- ================ --
    Builder {
        BuilderName = 'U2 Air Factory UP always',
        PlatoonTemplate = 'T2AirFactoryUpgrade',
        Priority = 3000,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER}}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH2 }},
        },
        BuilderType = 'Any',
    },
    -- ================== --
    --    TECH 2 NAVAL    --
    -- ================== --
    Builder {
        BuilderName = 'U2 Naval Factory Upgrade Force 1st',
        PlatoonTemplate = 'T2SeaFactoryUpgrade',
        Priority = 3490,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH2 } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.10}}, -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * ( categories.TECH2 + categories.TECH3 )  }},
            -- Don't build it if...
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH3 } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH2 }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Sea Factory UP always',
        PlatoonTemplate = 'T2SeaFactoryUpgrade',
        Priority = 3000,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH2 }},
        },
        BuilderType = 'Any',
    },
}
-- ===================================================-======================================================== --
-- ==                                        Build Quantum Gate                                              == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'GateConstruction Uveso',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U-T3 Gate Cap',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 3000,
        DelayEqualBuildPlattons = {'Factories', 1},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Gate' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                Location = 'LocationType',
                AdjacencyCategory = 'MASSEXTRACTION',
                BuildStructures = {
                    'T3QuantumGate',
                },
            }
        }
    },
}
-- ===================================================-======================================================== --
-- ==                                   Build T2 Air Staging Platform                                        == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Air Staging Platform Uveso',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U-T2 Air Staging 1st',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM }},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM }},
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T2AirStagingPlatform',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U-T2 Air Staging',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 0.05, 'STRUCTURE AIRSTAGINGPLATFORM', '<','Mobile AIR' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<=', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T2AirStagingPlatform',
                },
                Location = 'LocationType',
            }
        }
    },
}
