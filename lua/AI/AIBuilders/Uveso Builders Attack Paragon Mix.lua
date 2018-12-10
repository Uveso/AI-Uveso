local IBC = '/lua/editor/InstantBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local SIBC = '/lua/editor/SorianInstantBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local SBC = '/lua/editor/SorianBuildConditions.lua'

local ExperimentalCount = 3
local mapSizeX, mapSizeZ = GetMapSize()
local BaseMilitaryZone = math.max( mapSizeX-50, mapSizeZ-50 ) / 2 -- Half the map
local BasePanicZone = BaseMilitaryZone / 2
BasePanicZone = math.max( 60, BasePanicZone )
BasePanicZone = math.min( 120, BasePanicZone )
BaseMilitaryZone = math.max( 250, BaseMilitaryZone )

-- ===================================================-======================================================== --
-- ==                                 Mobile Experimental Land/Air/Sea                                       == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Paragon Turbo Builder',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Turbo T4AirExperimental1',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1100,
        InstanceCount = 5,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, 'MOBILE ENGINEER TECH3' }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, 'MOBILE ENGINEER TECH3' }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'CanBuildCategory', { categories.MOBILE * categories.AIR * categories.EXPERIMENTAL - categories.SATELLITE } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = 'SHIELD STRUCTURE',
                BuildStructures = {
                    'T4AirExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Turbo T4SeaExperimental1',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1100,
        InstanceCount = 3,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, 'MOBILE ENGINEER TECH3' }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, 'MOBILE ENGINEER TECH3' }},
            -- Do we need additional conditions to build it ?
            { SBC, 'IsWaterMap', { true } },
            { UCBC, 'CanBuildCategory', { categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = 'SHIELD STRUCTURE',
                BuildStructures = {
                    'T4SeaExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Turbo T4LandExperimental2',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1100,
        InstanceCount = 5,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, 'MOBILE ENGINEER TECH3' }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, 'MOBILE ENGINEER TECH3' }},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = false,
                AdjacencyCategory = 'SHIELD STRUCTURE',
                BuildStructures = {
                    'T4LandExperimental2',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Turbo T4LandExperimental1',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1100,
        InstanceCount = 10,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, 'MOBILE ENGINEER TECH3' }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, 'MOBILE ENGINEER TECH3' }},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = 'SHIELD STRUCTURE',
                BuildStructures = {
                    'T4LandExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
-- ===================================================-======================================================== --
-- ==                                    T2 Tactical Missile LAUNCHER                                       == --
-- ===================================================-======================================================== --
    Builder {
        BuilderName = 'Turbo U2 TML',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 30, categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM }},
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'STRUCTURE SHIELD',
                AdjacencyDistance = 50,
                BuildClose = false,
                BuildStructures = {
                    'T2StrategicMissile',
                },
                Location = 'LocationType',
            }
        }
    },
-- ===================================================-======================================================== --
-- ==                                    T3 Strategic Missile LAUNCHER                                       == --
-- ===================================================-======================================================== --
    Builder {
        BuilderName = 'Turbo U3 SML',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 1100,
        InstanceCount = 6,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 100, categories.STRUCTURE * categories.LAND * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) }},
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AvoidCategory = categories.STRUCTURE * categories.NUKE,
                maxUnits = 1,
                maxRadius = 20,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3StrategicMissile',
                },
            }
        }
    },
-- ===================================================-======================================================== --
-- ==                                          T3/T4 Artillery                                               == --
-- ===================================================-======================================================== --
    Builder {
        BuilderName = 'Turbo U3 Artillery',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1100,
        InstanceCount = 2,
        DelayEqualBuildPlattons = {'Artillery', 20},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.STRUCTURE * categories.LAND * categories.ARTILLERY * categories.TECH3 }},
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T3Artillery',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Turbo U4 RapidArtillery',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1100,
        InstanceCount = 2,
        DelayEqualBuildPlattons = {'Artillery', 20},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.STRUCTURE * categories.LAND * categories.ARTILLERY * categories.EXPERIMENTAL }},
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T3RapidArtillery',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Turbo U4 Artillery',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1100,
        InstanceCount = 2,
        DelayEqualBuildPlattons = {'Artillery', 20},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.STRUCTURE * categories.LAND * categories.ARTILLERY * categories.EXPERIMENTAL }},
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T4Artillery',
                },
                Location = 'LocationType',
            }
        }
    },    
    Builder {
        BuilderName = 'Turbo U4 Satellite',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1100,
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { MIBC, 'FactionIndex', { 1 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 30, categories.STRUCTURE * categories.ORBITALSYSTEM }},
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T4SatelliteExperimental',
                },
                Location = 'LocationType',
            }
        }
    },
-- ===================================================-======================================================== --
-- ==                                          Factory upgrader                                              == --
-- ===================================================-======================================================== --
    Builder {
        BuilderName = 'Turbo U1 Land Factory UP',
        PlatoonTemplate = 'T1LandFactoryUpgrade',
        Priority = 3000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Turbo U1 Air Factory UP',
        PlatoonTemplate = 'T1AirFactoryUpgrade',
        Priority = 3000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Turbo U1 Naval Factory UP',
        PlatoonTemplate = 'T1SeaFactoryUpgrade',
        Priority = 3000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Turbo U2 Land Factory UP',
        PlatoonTemplate = 'T2LandFactoryUpgrade',
        Priority = 3000,
        InstanceCount = 5,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Turbo U2 Air Factory UP',
        PlatoonTemplate = 'T2AirFactoryUpgrade',
        Priority = 3000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Turbo U2 Naval Factory UP',
        PlatoonTemplate = 'T2SeaFactoryUpgrade',
        Priority = 3000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
    -- =================== --
    --    Experimentals    --
    -- =================== --
}
-- ===================================================-======================================================== --
-- ==                             Upgrade Factories Land/Air/Sea                                             == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Paragon Turbo Factory',                      -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
-- LAND HQ Factories
    Builder {
        BuilderName = 'U1p L UP HQ 1->2',
        PlatoonTemplate = 'T1LandFactoryUpgrade',
        Priority = 15400,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND  * categories.TECH1} },
            -- Have we the eco to build it ?
            { UCBC, 'HasParagon', {} },
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2p L UP HQ 2->3',
        PlatoonTemplate = 'T2LandFactoryUpgrade',
        Priority = 15400,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND  * categories.TECH2} },
            -- Have we the eco to build it ?
            { UCBC, 'HasParagon', {} },
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
-- AIR HQ Factories
    Builder {
        BuilderName = 'U1p A UP HQ 1->2',
        PlatoonTemplate = 'T1AirFactoryUpgrade',
        Priority = 15400,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.AIR  * categories.TECH1} },
            -- Have we the eco to build it ?
            { UCBC, 'HasParagon', {} },
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2p A UP HQ 2->3',
        PlatoonTemplate = 'T2AirFactoryUpgrade',
        Priority = 15400,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.AIR  * categories.TECH1} },
            -- Have we the eco to build it ?
            { UCBC, 'HasParagon', {} },
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
-- NAVAL HQ Factories
    Builder {
        BuilderName = 'U1p N UP HQ 1->2',
        PlatoonTemplate = 'T1SeaFactoryUpgrade',
        Priority = 15400,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.NAVAL  * categories.TECH1} },
            -- Have we the eco to build it ?
            { UCBC, 'HasParagon', {} },
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2p N UP HQ 2->3',
        PlatoonTemplate = 'T2SeaFactoryUpgrade',
        Priority = 15400,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.NAVAL  * categories.TECH1} },
            -- Have we the eco to build it ?
            { UCBC, 'HasParagon', {} },
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
}
-- ===================================================-======================================================== --
-- ==                                            Air builder                                                 == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Paragon Turbo Air',                      -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'U3p Air Scouts',
        PlatoonTemplate = 'T3AirScout',
        Priority = 1000,
        BuilderConditions = {
            { UCBC, 'HasParagon', {} },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 8, categories.INTELLIGENCE * categories.AIR * categories.TECH3 }},
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3p Air Fighter < Gunship',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 3.00, categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR * categories.TECH3 - categories.GROUNDATTACK, '<=',categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 - categories.HIGHALTAIR } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { UCBC, 'HasParagon', {} },
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 1.00 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3p Air Gunship < Fighter',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 3.00, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 - categories.HIGHALTAIR, '<=',categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR - categories.GROUNDATTACK } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { UCBC, 'HasParagon', {} },
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 1.00 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3p Air Bomber < 20',
        PlatoonTemplate = 'T3AirBomber',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.MOBILE * categories.AIR * categories.BOMBER }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.MOBILE * categories.AIR  * categories.BOMBER }},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { UCBC, 'HasParagon', {} },
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Air',
    },
}