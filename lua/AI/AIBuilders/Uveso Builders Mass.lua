-- Default economic builders for skirmish
local IBC = '/lua/editor/InstantBuildConditions.lua'
local SAI = '/lua/ScenarioPlatoonAI.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local MaxCapMass = 0.10 -- 10% of all units can be mass extractors (STRUCTURE * MASSEXTRACTION)
local MaxCapStructure = 0.14 -- 14% of all units can be structures (STRUCTURE -MASSEXTRACTION -DEFENSE -FACTORY)

-- ============================================================================================================ --
-- ==                                     Build MassExtractors / Creators                                    == --
-- ============================================================================================================ --
BuilderGroup {
    -- Build MassExtractors / Creators 
    BuilderGroupName = 'MassBuilders Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    -- ================== --
    --    TECH 1 - CDR    --
    -- ================== --
    -- If we have a mass spot close to the ACU (no need to move) then build 1 first.
    Builder {
        BuilderName = 'UC Mass 12 1st.',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 19600,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 12, -500, 0, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.MASSEXTRACTION }},
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapMass , '<=', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T1Resource',
                },
            }
        }
    },
    Builder {
        BuilderName = 'UC Mass 12',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 17900,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 12, -500, 0, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.MASSEXTRACTION }},
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapMass , '<=', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T1Resource',
                },
            }
        }
    },
    -- ======================= --
    --    TECH 1 - Engineer    --
    -- ======================= --
    Builder {
        BuilderName = 'U1 Mass 30',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17900,
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 30, -500, 0, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Do we need additional conditions to build it ?
            { UCBC, 'HasNotParagon', {} },
            -- Have we the eco to build it ?
            -- Don't build it if...
--            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapMass , '<=', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = false,                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'U1 Mass 60',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17890,
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 60, -500, 0, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Do we need additional conditions to build it ?
            { UCBC, 'HasNotParagon', {} },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { -0.00, 0.05}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
--            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapMass , '<=', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = false,                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'U1 Mass 128',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17880,
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 128, -500, 0, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Do we need additional conditions to build it ?
            { UCBC, 'HasNotParagon', {} },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { -0.00, 0.05}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
--            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapMass , '<=', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = true,                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'U1 Mass 256',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17870,
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 256, -500, 0, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Do we need additional conditions to build it ?
            { UCBC, 'HasNotParagon', {} },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { -0.00, 0.05}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
--            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapMass , '<=', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = false,                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'U1 Mass 512',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17860,
        InstanceCount = 4,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 512, -500, 0, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Do we need additional conditions to build it ?
            { UCBC, 'HasNotParagon', {} },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { -0.00, 0.05}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
--            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapMass , '<=', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = true,                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'U1 Mass 1000',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17850,
        InstanceCount = 4,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 1000, -500, 0, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Do we need additional conditions to build it ?
            { UCBC, 'HasNotParagon', {} },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { -0.00, 0.05}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
--            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapMass , '<=', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = true,                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'UC Resource RECOVER',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 19200,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 450, -5000, 0, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRings, threatType, maxNum
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.MASSEXTRACTION } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 180 } },
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            NeedGuard = false,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3 Mass Fab',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 16200,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatio', { 0.3, 'MASSFABRICATION', '<=','ENERGYPRODUCTION TECH3' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 1.00}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, 'MASSFABRICATION' } },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapMass , '<=', categories.STRUCTURE * categories.MASSEXTRACTION } },

        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 4,
                AdjacencyCategory = 'ENERGYPRODUCTION TECH3',
                AdjacencyDistance = 50,
                AvoidCategory = categories.MASSFABRICATION,
                maxUnits = 1,
                maxRadius = 15,
                BuildClose = true,
                BuildStructures = {
                    'T3MassCreation',
                },
            }
        }
    },
}
-- ============================================================================================================ --
-- ==                                         Upgrade MassExtractors                                         == --
-- ============================================================================================================ --
BuilderGroup {
    -- Upgrade MassExtractors from Tech 1 to 2 AND from Tech 2 to 3
    BuilderGroupName = 'ExtractorUpgrades Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Extractor upgrade >20 mass',
        PlatoonTemplate = 'AddToMassExtractorUpgradePlatoon',
        Priority = 18600,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MASSEXTRACTION} },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 2.0, -0.0}}, -- Absolut Base income
            -- Don't build it if...
        },
        BuilderData = {
            AIPlan = 'ExtractorUpgradeAI',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Extractor upgrade >4 factories',
        PlatoonTemplate = 'AddToMassExtractorUpgradePlatoon',
        Priority = 18500,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MASSEXTRACTION} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.STRUCTURE * categories.FACTORY} },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 0.1, -0.0}}, -- Absolut Base income
            -- Don't build it if...
        },
        BuilderData = {
            AIPlan = 'ExtractorUpgradeAI',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Extractor upgrade > 4 minutes',
        PlatoonTemplate = 'AddToMassExtractorUpgradePlatoon',
        Priority = 18400,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MASSEXTRACTION} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 4*60 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 0.1, -0.0}}, -- Absolut Base income
            -- Don't build it if...
        },
        BuilderData = {
            AIPlan = 'ExtractorUpgradeAI',
        },
        BuilderType = 'Any',
    },
}
-- ===================================================-======================================================== --
-- ==                                     Build MassStorage/Adjacency                                        == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'MassStorageBuilder Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U1 Mass Storage 1st',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17450,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.MASSSTORAGE }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 180 } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1,  'MASSSTORAGE' }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Location = 'LocationType',
            Construction = {
                BuildClose = false,
                AdjacencyCategory = 'STRUCTURE ENERGYPRODUCTION TECH3, STRUCTURE ENERGYPRODUCTION TECH2, STRUCTURE ENERGYPRODUCTION TECH1',
                LocationType = 'LocationType',
                BuildStructures = {
                    'MassStorage',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Mass Adjacency Engineer',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17440,
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'AdjacencyCheck', { 'LocationType', 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3', 200, 'ueb1106' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.95}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HasNotParagon', {} },
        },
        InstanceCount = 1,
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION TECH3, MASSEXTRACTION TECH2',
                AdjacencyDistance = 200,
                BuildClose = false,
                BuildStructures = {
                    'MassStorage',
                }
            }
        }
    },
    Builder {
        BuilderName = 'U1 Reclaim MassStorage',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.MASSSTORAGE }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH1' }},
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.MASSSTORAGE},
        },
        BuilderType = 'Any',
    },
}
