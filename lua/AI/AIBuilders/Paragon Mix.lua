local categories = categories
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local SBC = '/lua/editor/SorianBuildConditions.lua'

local MaxDefense = 0.12 -- 12% of all units can be defenses (categories.STRUCTURE * categories.DEFENSE)
local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

-- ===================================================-======================================================== --
-- ==                                 Mobile Experimental Land/Air/Sea                                       == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Paragon Turbo Experimentals',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Turbo T4AirExperimental1',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1100,
        InstanceCount = 5,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'CanBuildCategory', { categories.MOBILE * categories.AIR * categories.EXPERIMENTAL - categories.SATELLITE } },
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            -- Don't build it if...
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
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
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'CanBuildCategory', { categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL } },
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            -- Don't build it if...
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
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
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
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
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
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
        BuilderName = 'Paragon Turbo U2 TML',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 1000,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 30, categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
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
-- ==                                          T3/T4 Artillery                                               == --
-- ===================================================-======================================================== --
    Builder {
        BuilderName = 'Paragon Turbo U34 Artillery',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1100,
        InstanceCount = 2,
        DelayEqualBuildPlattons = {'Artillery', 20},
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.STRUCTURE * categories.LAND * categories.ARTILLERY * categories.TECH3 }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
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
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.STRUCTURE * categories.LAND * categories.ARTILLERY * categories.EXPERIMENTAL }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
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
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.STRUCTURE * categories.LAND * categories.ARTILLERY * categories.EXPERIMENTAL }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
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
            { MIBC, 'FactionIndex', { 1 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            { MIBC, 'HasParagon', {} },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 30, categories.STRUCTURE * categories.ORBITALSYSTEM }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
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
}
-- ===================================================-======================================================== --
-- ==                             Upgrade Factories Land/Air/Sea                                             == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Paragon Turbo FactoryUpgrader',                      -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
-- LAND HQ Factories
    Builder {
        BuilderName = 'U1p L UP HQ 1->2',
        PlatoonTemplate = 'T1LandFactoryUpgrade',
        Priority = 15400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND  * categories.TECH1} },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2p L UP HQ 2->3',
        PlatoonTemplate = 'T2LandFactoryUpgrade',
        Priority = 15400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND  * categories.TECH2} },
        },
        BuilderType = 'Any',
    },
-- AIR HQ Factories
    Builder {
        BuilderName = 'U1p A UP HQ 1->2',
        PlatoonTemplate = 'T1AirFactoryUpgrade',
        Priority = 15400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.AIR  * categories.TECH1} },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2p A UP HQ 2->3',
        PlatoonTemplate = 'T2AirFactoryUpgrade',
        Priority = 15400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.AIR  * categories.TECH1} },
        },
        BuilderType = 'Any',
    },
-- NAVAL HQ Factories
    Builder {
        BuilderName = 'U1p N UP HQ 1->2',
        PlatoonTemplate = 'T1SeaFactoryUpgrade',
        Priority = 15400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.NAVAL  * categories.TECH1} },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2p N UP HQ 2->3',
        PlatoonTemplate = 'T2SeaFactoryUpgrade',
        Priority = 15400,
        BuilderConditions = {
            { MIBC, 'HasParagon', {} },
            -- Don't build it if...
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.NAVAL  * categories.TECH1} },
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
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 8, categories.INTELLIGENCE * categories.AIR * categories.TECH3 }},
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3p Air Fighter < Gunship',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 350,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
--            { UCBC, 'HaveUnitRatioUveso', { 3.00, categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR * categories.TECH3 - categories.GROUNDATTACK, '<=',categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 - categories.HIGHALTAIR } },
            -- Respect UnitCap
--            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3p Air Gunship < Fighter',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 350,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
--            { UCBC, 'HaveUnitRatioUveso', { 3.00, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 - categories.HIGHALTAIR, '<=',categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR - categories.GROUNDATTACK } },
            -- Respect UnitCap
--            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3p Air Bomber < 20',
        PlatoonTemplate = 'T3AirBomber',
        Priority = 350,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
--            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.MOBILE * categories.AIR * categories.BOMBER }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.MOBILE * categories.AIR  * categories.BOMBER }},
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Air',
    },
}
-- ===================================================-======================================================== --
-- ==                                           Land builder                                                 == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Paragon Turbo Land',                      -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'U3P Siege Assault Bot',
        PlatoonTemplate = 'T3LandBot',
        Priority = 350,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            { MIBC, 'FactionIndex', { 1, 3, 4, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3P SniperBots',
        PlatoonTemplate = 'T3SniperBots',
        Priority = 350,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3P ArmoredAssault',
        PlatoonTemplate = 'T3ArmoredAssault',
        Priority = 350,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3P Mobile Artillery',
        PlatoonTemplate = 'T3LandArtillery',
        Priority = 350,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.1, categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH3, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE } },
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3P Mobile AA',
        PlatoonTemplate = 'T3LandAA',
        Priority = 350,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.05, categories.MOBILE * categories.LAND * categories.ANTIAIR * categories.TECH3, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE } },
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3P MobileShields',
        PlatoonTemplate = 'T3MobileShields',
        Priority = 350,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.1, categories.MOBILE * categories.LAND * categories.SHIELD, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH3 } },
            { UCBC, 'HaveUnitRatioUveso', { 0.1, categories.MOBILE * categories.LAND * categories.STEALTHFIELD, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH3 } },
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
}
