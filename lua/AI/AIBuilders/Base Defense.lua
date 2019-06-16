local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)
local MaxDefense = 0.12 -- 12% of all units can be defenses (categories.STRUCTURE * categories.DEFENSE)
local MaxCapStructure = 0.12                                                    -- 12% of all units can be structures (STRUCTURE -MASSEXTRACTION -DEFENSE -FACTORY)

-- ===================================================-======================================================== --
-- ==                                       Build T2 & T3 Shields                                            == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U23 Shields Builder',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U2 Shield Ratio',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 15000,
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioAtLocation', { 'LocationType', 1.0, categories.STRUCTURE * categories.SHIELD, '<=',categories.STRUCTURE * categories.TECH3 * (categories.ENERGYPRODUCTION + categories.FACTORY) } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'FactionIndex', { 1, 3, 4 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.SHIELD}},
            -- Respect UnitCap
            { UCBC, 'HaveLessThanUnitsWithCategory', { 30, categories.STRUCTURE * categories.SHIELD * (categories.TECH2 + categories.TECH3) } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL } },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense / 2, '<', categories.STRUCTURE * categories.DEFENSE * categories.SHIELD } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 4,
                BuildClose = true,
                AdjacencyCategory = (categories.ENERGYPRODUCTION * categories.TECH3) + (categories.ENERGYPRODUCTION * categories.EXPERIMENTAL) + (categories.STRUCTURE * categories.FACTORY),
                AvoidCategory = categories.STRUCTURE * categories.SHIELD,
                maxUnits = 1,
                maxRadius = 25,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T2ShieldDefense',
                },
            },
        },
    },
    Builder {
        BuilderName = 'U3 Shield Ratio',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 15000,
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioAtLocation', { 'LocationType', 1.0, categories.STRUCTURE * categories.SHIELD, '<=',categories.STRUCTURE * categories.TECH3 * (categories.ENERGYPRODUCTION + categories.FACTORY) } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'FactionIndex', { 2, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.SHIELD}},
            -- Respect UnitCap
            { UCBC, 'HaveLessThanUnitsWithCategory', { 30, categories.STRUCTURE * categories.SHIELD * (categories.TECH2 + categories.TECH3) } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL } },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense / 2, '<', categories.STRUCTURE * categories.DEFENSE * categories.SHIELD } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 4,
                BuildClose = false,
                AdjacencyCategory = (categories.ENERGYPRODUCTION * categories.TECH3) + (categories.ENERGYPRODUCTION * categories.EXPERIMENTAL) + (categories.STRUCTURE * categories.FACTORY),
                AvoidCategory = categories.STRUCTURE * categories.SHIELD,
                maxUnits = 1,
                maxRadius = 25,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3ShieldDefense',
                }
            }
        }
    },
    Builder {
        BuilderName = 'U3 Paragon Shield',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 15000,
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'AdjacencyCheck', { 'LocationType', categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC  * categories.ENERGYPRODUCTION  * categories.MASSPRODUCTION, 100, 'ueb2304' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 3,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC  * categories.ENERGYPRODUCTION  * categories.MASSPRODUCTION,
                AdjacencyDistance = 100,
                AvoidCategory = categories.STRUCTURE * categories.SHIELD,
                maxUnits = 10,
                maxRadius = 8,
                BuildClose = false,
                BuildStructures = {
                    'T3ShieldDefense',
                },
                Location = 'LocationType',
            }
        }
    },
    -- ===================== --
    --    Reclaim Shields    --
    -- ===================== --
    Builder {
        BuilderName = 'U1 Reclaim T1-T2 Shields',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 500,
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '>', categories.STRUCTURE * categories.DEFENSE } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * categories.TECH3 }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * (categories.TECH1 + categories.TECH2) }},
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {
                        categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * categories.TECH1,
                        categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * categories.TECH2,
                      },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U1 Reclaim T1-T2-T3 Shields',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 500,
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '>', categories.STRUCTURE * categories.DEFENSE } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * categories.EXPERIMENTAL }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.SHIELD - categories.EXPERIMENTAL }},
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {
                        categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * categories.TECH1,
                        categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * categories.TECH2,
                        categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * categories.TECH3,
                      },
        },
        BuilderType = 'Any',
    },
}
-- ===================================================-======================================================== --
-- ==                                      Upgrade T1 & T2 Shields                                           == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U23 Shields Upgrader',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U2 Shield Cybran 1',
        PlatoonTemplate = 'T2Shield1',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Shield', 2},
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.10}}, -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH3 * categories.ENERGYPRODUCTION}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.SHIELD }},
            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Shield Cybran 2',
        PlatoonTemplate = 'T2Shield2',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Shield', 2},
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.10}}, -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH3 * categories.ENERGYPRODUCTION}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.SHIELD }},
            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Shield Cybran 3',
        PlatoonTemplate = 'T2Shield3',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Shield', 2},
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.10}}, -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH3 * categories.ENERGYPRODUCTION}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.SHIELD }},
            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Shield Cybran 4',
        PlatoonTemplate = 'T2Shield4',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Shield', 2},
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.TECH3 * categories.ENERGYPRODUCTION}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.SHIELD }},
            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Shield UEF Seraphim',
        PlatoonTemplate = 'T2Shield',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Shield', 2},
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.TECH3 * categories.ENERGYPRODUCTION}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.SHIELD }},
            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
        },
        BuilderType = 'Any',
    },
}
-- ===================================================-======================================================== --
-- ==                                    T2 Tactical Missile Launcher                                        == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U2 Tactical Missile Launcher minimum',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U2 TML Minimum',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 1000,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.TACTICALMISSILEPLATFORM}},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'STRUCTURE SHIELD, STRUCTURE ENERGYPRODUCTION',
                AdjacencyDistance = 50,
                AvoidCategory = categories.FACTORY,
                maxUnits = 1,
                maxRadius = 10,
                BuildClose = false,
                BuildStructures = {
                    'T2StrategicMissile',
                },
                Location = 'LocationType',
            }
        }
    },
}
BuilderGroup {
    BuilderGroupName = 'U2 Tactical Missile Launcher maximum',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U2 TML Maximum',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 1000,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 6, categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM}},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 12, categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
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
}
BuilderGroup {
    BuilderGroupName = 'U2 Tactical Missile Launcher Builder',                       -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U2 TML AI',
        PlatoonTemplate = 'U2TML',
        Priority = 18000,
        InstanceCount = 20,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM * categories.TECH2} },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
}

-- ===================================================-======================================================== --
-- ==                                     T2 Tactical Missile Defenses                                       == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U2 Tactical Missile Defenses Builder',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U2 TMD Panic 1',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 10000,
        BuilderConditions = {
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  280, 'LocationType', 0, categories.TACTICALMISSILEPLATFORM }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * (categories.MASSEXTRACTION + categories.FACTORY),
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2,
                maxUnits = 1,
                maxRadius = 10,
                BuildClose = false,
                BuildStructures = {
                    'T2MissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U2 TMD Panic 2',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 10000,
        BuilderConditions = {
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  280, 'LocationType', 3, categories.TACTICALMISSILEPLATFORM }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 6, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * (categories.MASSEXTRACTION + categories.FACTORY),
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2,
                maxUnits = 1,
                maxRadius = 10,
                BuildClose = false,
                BuildStructures = {
                    'T2MissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U2 TMD Panic 3',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 10000,
        BuilderConditions = {
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  280, 'LocationType', 6, categories.TACTICALMISSILEPLATFORM }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 20, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * (categories.MASSEXTRACTION + categories.FACTORY),
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2,
                maxUnits = 1,
                maxRadius = 10,
                BuildClose = false,
                BuildStructures = {
                    'T2MissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U2 TMD',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 10000,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 20, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2 }},
            { UCBC, 'HaveUnitRatioAtLocation', { 'LocationType', 0.5, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2, '<',categories.STRUCTURE * categories.FACTORY } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * (categories.MASSEXTRACTION + categories.FACTORY),
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2,
                maxUnits = 1,
                maxRadius = 10,
                BuildClose = false,
                BuildStructures = {
                    'T2MissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },
}
-- ===================================================-======================================================== --
-- ==                                    T3 Strategic Missile LAUNCHER                                       == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U3 Strategic Missile Launcher Builder',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U3 SML',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1000,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.90, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconTrend', { 8.0, 500.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.EXPERIMENTAL } },
            { UCBC, 'HaveUnitRatioVersusEnemy', { 2, categories.STRUCTURE * categories.NUKE * categories.TECH3, '<=', categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3 } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.NUKE * categories.STRUCTURE}},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 8, categories.STRUCTURE * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
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
    Builder {
        BuilderName = 'U3 SML Turbo',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 2500,
        InstanceCount = 3,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            { MIBC, 'IsBrainPersonality', { 'uvesooverwhelm', false} }, -- Don't let the Overwhelm AI buid this. Would be a fast nuklear game end :)
            { MIBC, 'IsBrainPersonality', { 'uvesooverwhelmcheat', false} }, -- Don't let the OverwhelmCheat AI buid this. Would be a fast nuklear game end :)
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.NUKE * categories.STRUCTURE}},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 25, categories.STRUCTURE * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
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
}
BuilderGroup {
    -- Add all nukes to a single nuke-platton
    BuilderGroupName = 'U4 Strategic Missile Launcher NukeAI',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'NukePlatoonAI',
        PlatoonTemplate = 'AddToNukePlatoon',
        Priority = 4000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.STRUCTURE * categories.NUKE * (categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL) } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            AIPlan = 'NukePlatoonAI',
        },
        BuilderType = 'Any',
    },
}
-- ===================================================-======================================================== --
-- ==                                    T3 Strategic Missile Defense                                        == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U4 Strategic Missile Defense Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U3 SMD 1st Main',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 18000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.00, 0.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.STRUCTURE * categories.NUKE * categories.SILO } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 5,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3,
                maxUnits = 1,
                maxRadius = 20,
                BuildStructures = {
                    'T3StrategicMissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U3 SMD Enemy Main',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 18000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioAtLocationRadiusVersusEnemy', { 1.20, 'LocationType', 90, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3, '<', categories.SILO * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 5,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3,
                maxUnits = 1,
                maxRadius = 20,
                BuildStructures = {
                    'T3StrategicMissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U3 SMD Enemy Yolona Oss',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 18000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioAtLocationRadiusVersusEnemy', { 3.00, 'LocationType', 90, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3, '<', categories.SILO * categories.NUKE * categories.EXPERIMENTAL * categories.SERAPHIM } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.00, 0.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 5,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3,
                maxUnits = 1,
                maxRadius = 20,
                BuildStructures = {
                    'T3StrategicMissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U3 SMD Enemy Expansion',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 18000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioAtLocationRadiusVersusEnemy', { 1.50, 'LocationType', 90, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3, '<',categories.SILO * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildNotOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * (categories.TECH3 + categories.EXPERIMENTAL) } },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 5,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3,
                maxUnits = 1,
                maxRadius = 20,
                BuildStructures = {
                    'T3StrategicMissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },
}
BuilderGroup {
    -- Add all anti-nukes to a single nuke-platton
    BuilderGroupName = 'U4 Strategic Missile Defense Anti-NukeAI',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U3AntiNukeAI',
        PlatoonTemplate = 'AddToAntiNukePlatoon',
        Priority = 4000,
        FormRadius = 10000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3 } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            AIPlan = 'U3AntiNukeAI',
        },
        BuilderType = 'Any',
    },
}
-- ===================================================-======================================================== --
-- ==                                        T2 T3 T4 Artillery                                              == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U4 Artillery Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U2 Artillery',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 1000,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 6, categories.STRUCTURE * categories.ARTILLERY * categories.TECH2 }},
            { EBC, 'GreaterThanEconStorageRatio', { 0.80, 1.00 }}, -- Ratio from 0 to 1. (1=100%)
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
        },
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                BuildStructures = {
                    'T2Artillery',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U3 Artillery',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Artillery', 20},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.EXPERIMENTAL}},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.90, 1.00 }}, -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconTrend', { 2.0, 300.0 } }, -- relative income
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.ARTILLERY * categories.TECH3 } },
            { UCBC, 'CheckBuildPlattonDelay', { 'Artillery' }},
            -- Respect UnitCap
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
        BuilderName = 'U3 RapidArtillery',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Artillery', 20},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.EXPERIMENTAL}},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.90, 1.00 }}, -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconTrend', { 2.0, 300.0 } }, -- relative income
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.ARTILLERY * categories.TECH3 } },
            { UCBC, 'CheckBuildPlattonDelay', { 'Artillery' }},
            -- Respect UnitCap
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
        BuilderName = 'U4 Artillery',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Artillery', 20},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.EXPERIMENTAL}},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.80, 0.95 }}, -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconTrend', { 2.0, 300.0 } }, -- relative income
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.ARTILLERY * categories.EXPERIMENTAL } },
            { UCBC, 'CheckBuildPlattonDelay', { 'Artillery' }},
            -- Respect UnitCap
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
}
BuilderGroup {
    -- Add all Artilleries to a single platton
    BuilderGroupName = 'U4 Artillery Formers',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U34ArtilleryAI',
        PlatoonTemplate = 'AddToArtilleryPlatoon',
        Priority = 4000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, (categories.STRUCTURE * categories.ARTILLERY * ( categories.TECH3 + categories.EXPERIMENTAL )) + categories.SATELLITE } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            AIPlan = 'U34ArtilleryAI',
        },
        BuilderType = 'Any',
    },
}

-- ===================================================-======================================================== --
-- ==                                     T1-T3 Base point defense                                           == --
-- ===================================================-======================================================== --

BuilderGroup {
    BuilderGroupName = 'U123 Defense Anti Ground Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U1 Ground Defense always',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 875,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH2 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.45, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 5, categories.STRUCTURE * categories.DEFENSE - categories.ANTIAIR }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                BuildClose = false,
                BuildStructures = {
                    'T1GroundDefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U2 Ground Defense always',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 875,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH2 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.45, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 20, categories.STRUCTURE * categories.DEFENSE - categories.ANTIAIR }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                BuildClose = false,
                BuildStructures = {
                    'T2GroundDefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U3 Ground Defense always',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 875,
        InstanceCount = 3,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.LAND * categories.EXPERIMENTAL } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'CanBuildCategory', { categories.STRUCTURE * categories.LAND * categories.DEFENSE  * categories.DIRECTFIRE } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.45, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 30, categories.STRUCTURE * categories.DEFENSE - categories.ANTIAIR }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                BuildClose = false,
                BuildStructures = {
                    'T3GroundDefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U3 Ground Defense Paragon',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 875,
        InstanceCount = 10,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'CanBuildCategory', { categories.STRUCTURE * categories.LAND * categories.DEFENSE  * categories.DIRECTFIRE } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            -- Don't build it if...
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 40, categories.STRUCTURE * categories.DEFENSE - categories.ANTIAIR }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                BuildClose = false,
                BuildStructures = {
                    'T3GroundDefense',
                },
                Location = 'LocationType',
            }
        }
    },
    -- ============================ --
    --    Reclaim Ground Defense    --
    -- ============================ --
    Builder {
        BuilderName = 'U1 Reclaim T1+T2 PD',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 500,
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '>', categories.STRUCTURE * categories.DEFENSE } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.TECH3 * ( categories.DIRECTFIRE + categories.INDIRECTFIRE ) - categories.ANTIAIR }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * (categories.TECH1 + categories.TECH2) * ( categories.DIRECTFIRE + categories.INDIRECTFIRE ) - categories.ANTIAIR }},
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {
                        categories.STRUCTURE * categories.DEFENSE * categories.TECH1 * ( categories.DIRECTFIRE + categories.INDIRECTFIRE ) - categories.ANTIAIR,
                        categories.STRUCTURE * categories.DEFENSE * categories.TECH2 * ( categories.DIRECTFIRE + categories.INDIRECTFIRE ) - categories.ANTIAIR
                      },
        },
        BuilderType = 'Any',
    },
}

-- ===================================================-======================================================== --
-- ==                                  T1-T3 Base Anti Air defense                                           == --
-- ===================================================-======================================================== --

BuilderGroup {
    BuilderGroupName = 'U123 Defense Anti Air Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U1 AirFactory AA',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 1500,
        InstanceCount = 1,                                      -- Number of plattons that will be formed.
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioAtLocation', { 'LocationType', 1.0, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR, '<=',categories.STRUCTURE * categories.FACTORY } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR * categories.TECH3 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.FACTORY,
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.ANTIAIR * categories.TECH1,
                maxUnits = 1,
                maxRadius = 10,
                BuildClose = false,
                BuildStructures = {
                    'T1AADefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U2 AirFactory AA',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 1500,
        InstanceCount = 1,                                      -- Number of plattons that will be formed.
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioAtLocation', { 'LocationType', 1.0, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR * categories.TECH2, '<=',categories.STRUCTURE * categories.FACTORY } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 20, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR }},
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR * categories.TECH3 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.FACTORY,
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.ANTIAIR * categories.TECH2,
                maxUnits = 1,
                maxRadius = 10,
                BuildClose = false,
                BuildStructures = {
                    'T2AADefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U3 AirFactory AA',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1500,
        InstanceCount = 2,                                      -- Number of plattons that will be formed.
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioAtLocation', { 'LocationType', 1.0, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR * categories.TECH3, '<=',categories.STRUCTURE * categories.FACTORY } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 32, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.FACTORY,
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.ANTIAIR * categories.TECH3,
                maxUnits = 1,
                maxRadius = 8,
                BuildClose = false,
                BuildStructures = {
                    'T3AADefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U3 AirFactory AA Bomber Response',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1500,
        InstanceCount = 2,                                      -- Number of plattons that will be formed.
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.AIR * categories.BOMBER * categories.TECH3 } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.FACTORY,
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.ANTIAIR * categories.TECH3,
                maxUnits = 1,
                maxRadius = 8,
                BuildClose = false,
                BuildStructures = {
                    'T3AADefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U3 AirFactory AA EXPERIMENTAL Response',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1500,
        InstanceCount = 2,                                      -- Number of plattons that will be formed.
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.AIR * categories.EXPERIMENTAL } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 64, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.FACTORY,
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.ANTIAIR * categories.TECH3,
                maxUnits = 1,
                maxRadius = 8,
                BuildClose = false,
                BuildStructures = {
                    'T3AADefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U3 Paragon AA',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1500,
        InstanceCount = 5,                                      -- Number of plattons that will be formed.
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'AdjacencyCheck', { 'LocationType', categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC  * categories.ENERGYPRODUCTION  * categories.MASSPRODUCTION, 100, 'ueb2304' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 3,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC  * categories.ENERGYPRODUCTION  * categories.MASSPRODUCTION,
                AdjacencyDistance = 100,
                AvoidCategory = categories.STRUCTURE * categories.ANTIAIR * categories.TECH3,
                maxUnits = 10,
                maxRadius = 8,
                BuildClose = false,
                BuildStructures = {
                    'T3AADefense',
                },
                Location = 'LocationType',
            }
        }
    },
    -- ================ --
    --    Reclaim AA    --
    -- ================ --
    Builder {
        BuilderName = 'U1 Reclaim T1+T2 AA',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 500,
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '>', categories.STRUCTURE * categories.DEFENSE } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.TECH3 * categories.ANTIAIR }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * (categories.TECH1 + categories.TECH2) * categories.ANTIAIR }},
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {
                        categories.STRUCTURE * categories.DEFENSE * categories.TECH1 * categories.ANTIAIR,
                        categories.STRUCTURE * categories.DEFENSE * categories.TECH2 * categories.ANTIAIR
                      },
        },
        BuilderType = 'Any',
    },
}



