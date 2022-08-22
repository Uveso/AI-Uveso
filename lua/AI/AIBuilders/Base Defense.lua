local categories = categories
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush2ndPhaseActive then
                return 0
            else
                return 15000
            end
        end,
        BuilderConditions = {
            -- Aeon can't upgrade its T2 Shields, so we don't build them
            { MIBC, 'FactionIndex', { 1, 3, 4, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.SHIELD}},
            { UCBC, 'HaveUnitRatioAtLocation', { 'LocationType', 1.5, categories.STRUCTURE * categories.SHIELD, '<=',categories.STRUCTURE * categories.TECH3 * (categories.ENERGYPRODUCTION + categories.FACTORY) } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 30, categories.STRUCTURE * categories.SHIELD * (categories.TECH2 + categories.TECH3) } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL } },
            -- Respect UnitCap
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
                maxUnits = 0,
                maxRadius = 20,
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush2ndPhaseActive then
                return 0
            else
                return 15000
            end
        end,
        BuilderConditions = {
            -- All other factions will upgrade from T2 Shields
            { MIBC, 'FactionIndex', { 2 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.SHIELD}},
            { UCBC, 'HaveUnitRatioAtLocation', { 'LocationType', 1.5, categories.STRUCTURE * categories.SHIELD, '<=',categories.STRUCTURE * categories.TECH3 * (categories.ENERGYPRODUCTION + categories.FACTORY) } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 30, categories.STRUCTURE * categories.SHIELD * (categories.TECH2 + categories.TECH3) } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL } },
            -- Respect UnitCap
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
                maxUnits = 0,
                maxRadius = 20,
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 15000
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            --{ MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'AdjacencyCheck', { 'LocationType', categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC  * categories.ENERGYPRODUCTION  * categories.MASSPRODUCTION, 100, 'ueb2304' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense / 2, '<', categories.STRUCTURE * categories.DEFENSE * categories.SHIELD } },
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
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '>', categories.STRUCTURE * categories.DEFENSE } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * categories.TECH3 }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * (categories.TECH1 + categories.TECH2) }},
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
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '>', categories.STRUCTURE * categories.DEFENSE } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL } },
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
            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH3 * categories.ENERGYPRODUCTION}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.SHIELD }},
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
            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH3 * categories.ENERGYPRODUCTION}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.SHIELD }},
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
            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH3 * categories.ENERGYPRODUCTION}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.SHIELD }},
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
            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.TECH3 * categories.ENERGYPRODUCTION}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.SHIELD }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 ShieldUpgrade',
        PlatoonTemplate = 'T2Shield',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Shield', 2},
        InstanceCount = 10,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.TECH3 * categories.ENERGYPRODUCTION}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.SHIELD }},
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
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
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
                maxUnits = 0,
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 1000
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
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
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM * categories.TECH2} },
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
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2 }},
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  280, 'LocationType', 0, categories.TACTICALMISSILEPLATFORM }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * (categories.MASSEXTRACTION + categories.FACTORY),
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2,
                maxUnits = 0,
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
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 6, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2 }},
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  280, 'LocationType', 1, categories.TACTICALMISSILEPLATFORM }}, -- radius, LocationType, unitCount, categoryEnemy
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
                maxUnits = 0,
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
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 9, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2 }},
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  280, 'LocationType', 2, categories.TACTICALMISSILEPLATFORM }}, -- radius, LocationType, unitCount, categoryEnemy
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
                maxUnits = 0,
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
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
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
                maxUnits = 0,
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
        BuilderName = 'U3 SML 1st',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1000,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 2.0, 500.0}}, -- Absolut Base income 20 5000
            -- When do we want to build this ?
            { MIBC, 'ItsTimeForGameender', {} },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.NUKE * categories.STRUCTURE}},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AvoidCategory = categories.STRUCTURE * categories.NUKE,
                maxUnits = 0,
                maxRadius = 20,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3StrategicMissile',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U3 SML 2nd',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1000,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 1000
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconIncome',  { 4.0, 1000.0}}, -- Absolut Base income 40 10000
            -- When do we want to build this ?
            { MIBC, 'ItsTimeForGameender', {} },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.ENERGYPRODUCTION * categories.TECH3 } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.NUKE * categories.STRUCTURE}},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) }},
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AvoidCategory = categories.STRUCTURE * categories.NUKE,
                maxUnits = 0,
                maxRadius = 20,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3StrategicMissile',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U3 SML Ratio',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1000,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 1000
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconIncome',  { 4.0, 1000.0}}, -- Absolut Base income 40 10000
            -- When do we want to build this ?
            { MIBC, 'ItsTimeForGameender', {} },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.ENERGYPRODUCTION * categories.TECH3 } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.NUKE * categories.STRUCTURE}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.NUKE } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.STRUCTURE * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) }},
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AvoidCategory = categories.STRUCTURE * categories.NUKE,
                maxUnits = 0,
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 2500
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            --{ MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            { MIBC, 'ItsTimeForGameender', {} },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.NUKE * categories.STRUCTURE}},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 25, categories.STRUCTURE * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) }},
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AvoidCategory = categories.STRUCTURE * categories.NUKE,
                maxUnits = 0,
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
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { MIBC, 'ItsTimeForGameender', {} },
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.STRUCTURE * categories.NUKE * (categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL) } },
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
    BuilderGroupName = 'U4 Strategic Missile Defense Builders MAIN',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U3 SMD 1st Main Eco',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 18000,
        BuilderConditions = {
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome', { 3.8, 150.0 }},                    -- Base income
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            -- When do we want to build this ?
            { MIBC, 'ItsTimeForGameender', {} },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * (categories.TECH3 + categories.EXPERIMENTAL) } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * (categories.TECH3 + categories.EXPERIMENTAL) } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 5,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3,
                maxUnits = 0,
                maxRadius = 20,
                BuildStructures = {
                    'T3StrategicMissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U3 SMD 1st Main Enemy',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 18000,
        BuilderConditions = {
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.STRUCTURE * categories.NUKE * categories.SILO } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * (categories.TECH3 + categories.EXPERIMENTAL) } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * (categories.TECH3 + categories.EXPERIMENTAL) } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 5,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3,
                maxUnits = 0,
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
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioAtLocationRadiusVersusEnemy', { 1.00, 'LocationType', 180, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3, '<', categories.SILO * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * (categories.TECH3 + categories.EXPERIMENTAL) } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 5,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3,
                maxUnits = 0,
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
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioAtLocationRadiusVersusEnemy', { 3.00, 'LocationType', 180, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3, '<', categories.SILO * categories.NUKE * categories.EXPERIMENTAL * categories.SERAPHIM } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 5,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3,
                maxUnits = 0,
                maxRadius = 20,
                BuildStructures = {
                    'T3StrategicMissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U3 SMD Enemy NukeSub',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 18000,
        BuilderConditions = {
            { UCBC, 'BuildNotOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioAtLocationRadiusVersusEnemy', { 0.50, 'LocationType', 180, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3, '<', categories.NUKESUB } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 5,
            Construction = {
                BuildClose = false,
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
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * (categories.TECH3 + categories.EXPERIMENTAL) } },
            { UCBC, 'HaveUnitRatioAtLocationRadiusVersusEnemy', { 0.80, 'LocationType', 90, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3, '<',categories.SILO * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) } },
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
                maxUnits = 0,
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
    BuilderGroupName = 'U4 Strategic Missile Defense Builders Naval',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U3 SMD 1st Naval',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 18000,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            -- When do we want to build this ?
            { MIBC, 'ItsTimeForGameender', {} },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * (categories.TECH3 + categories.EXPERIMENTAL) } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * (categories.TECH3 + categories.EXPERIMENTAL) } },
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * (categories.TECH3 + categories.EXPERIMENTAL) } },

        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 5,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3,
                maxUnits = 0,
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
    BuilderGroupName = 'U234 Artillery Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U2 Artillery',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 1000,
        BuilderType = 'Any',
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 1000
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 8, categories.STRUCTURE * categories.ARTILLERY * categories.TECH2 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
        },
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = (categories.ENERGYPRODUCTION * categories.EXPERIMENTAL) + (categories.STRUCTURE * categories.FACTORY),
                AvoidCategory = categories.STRUCTURE * categories.ARTILLERY * categories.TECH2,
                maxUnits = 0,
                maxRadius = 35,
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
        Priority = 1010,
        DelayEqualBuildPlattons = {'Artillery', 20},
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 1010
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Artillery' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconIncome',  { 4.0, 1000.0}}, -- Absolut Base income 40 10000
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { MIBC, 'ItsTimeForGameender', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ARTILLERY * categories.TECH3 } },
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 1000
            end
        end,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 2 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            { UCBC, 'CheckBuildPlattonDelay', { 'Artillery' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconIncome',  { 4.0, 1000.0}}, -- Absolut Base income 40 10000
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { MIBC, 'ItsTimeForGameender', {} },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ARTILLERY } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.EXPERIMENTAL}},
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
        BuilderName = 'U4 Artillery', -- UEF T4 Arty, Seraphim T4 Nuke
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Artillery', 20},
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 1000
            end
        end,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1, 4 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            { UCBC, 'CheckBuildPlattonDelay', { 'Artillery' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconIncome',  { 4.0, 1000.0}}, -- Absolut Base income 40 10000
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { MIBC, 'ItsTimeForGameender', {} },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ARTILLERY } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.EXPERIMENTAL}},
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
        BuilderName = 'U4 Satellite',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 875,
        InstanceCount = 2,
        DelayEqualBuildPlattons = {'MobileExperimental', 10},
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            { UCBC, 'CheckBuildPlattonDelay', { 'MobileExperimental' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconIncome',  { 4.0, 1000.0}}, -- Absolut Base income 40 10000
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { MIBC, 'ItsTimeForGameender', {} },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.SATELLITE * categories.EXPERIMENTAL } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                BuildStructures = {
                    'T4SatelliteExperimental',
                },
                Location = 'LocationType',
            }
        }
    },
}
BuilderGroup {
    -- Add all Artilleries to a single platton
    BuilderGroupName = 'U34 Artillery Formers',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U34ArtilleryAI',
        PlatoonTemplate = 'AddToArtilleryPlatoon',
        Priority = 4000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.STRUCTURE * categories.ARTILLERY * ( categories.TECH3 + categories.EXPERIMENTAL ) } },
        },
        BuilderData = {
            AIPlan = 'U34ArtilleryAI',
        },
        BuilderType = 'Any',
    },
}
BuilderGroup {
    -- Add all Satellites to a single platton
    BuilderGroupName = 'U4 Satellite Formers',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U3SatelliteAI',
        PlatoonTemplate = 'AddToSatellitePlatoon',
        Priority = 4000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MOBILE * categories.SATELLITE * categories.EXPERIMENTAL } },
        },
        BuilderData = {
            AIPlan = 'U4SatelliteAI',
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
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH2 - categories.STATIONASSISTPOD }},
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 5, categories.STRUCTURE * categories.DEFENSE - categories.ANTIAIR }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = (categories.ENERGYPRODUCTION * categories.EXPERIMENTAL) + (categories.STRUCTURE * categories.FACTORY),
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE - categories.ANTIAIR,
                maxUnits = 0,
                maxRadius = 35,
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
        InstanceCount = 2,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH2 - categories.STATIONASSISTPOD }},
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 20, categories.STRUCTURE * categories.DEFENSE - categories.ANTIAIR }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = (categories.ENERGYPRODUCTION * categories.EXPERIMENTAL) + (categories.STRUCTURE * categories.FACTORY),
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE - categories.ANTIAIR,
                maxUnits = 0,
                maxRadius = 10,
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
        InstanceCount = 2,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'CanBuildCategory', { categories.STRUCTURE * categories.LAND * categories.DEFENSE * categories.DIRECTFIRE * categories.TECH3 } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.LAND * categories.EXPERIMENTAL } },
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 30, categories.STRUCTURE * categories.DEFENSE - categories.ANTIAIR }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = (categories.ENERGYPRODUCTION * categories.EXPERIMENTAL) + (categories.STRUCTURE * categories.FACTORY),
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE - categories.ANTIAIR,
                maxUnits = 0,
                maxRadius = 35,
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
        InstanceCount = 6,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 875
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            --{ MIBC, 'HasParagon', {} },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            -- When do we want to build this ?
            { UCBC, 'CanBuildCategory', { categories.STRUCTURE * categories.LAND * categories.DEFENSE * categories.DIRECTFIRE * categories.TECH3 } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 40, categories.STRUCTURE * categories.DEFENSE - categories.ANTIAIR }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = (categories.ENERGYPRODUCTION * categories.EXPERIMENTAL) + (categories.STRUCTURE * categories.FACTORY),
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE - categories.ANTIAIR,
                maxUnits = 0,
                maxRadius = 35,
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
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '>', categories.STRUCTURE * categories.DEFENSE } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.TECH3 * ( categories.DIRECTFIRE + categories.INDIRECTFIRE ) - categories.ANTIAIR }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * (categories.TECH1 + categories.TECH2) * ( categories.DIRECTFIRE + categories.INDIRECTFIRE ) - categories.ANTIAIR }},
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
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioAtLocation', { 'LocationType', 1.0, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR, '<=',categories.STRUCTURE * categories.FACTORY } },
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
                maxUnits = 0,
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
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioAtLocation', { 'LocationType', 1.0, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR * categories.TECH2, '<=',categories.STRUCTURE * categories.FACTORY } },
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
                maxUnits = 0,
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
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 32, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR }},
            { UCBC, 'HaveUnitRatioAtLocation', { 'LocationType', 1.0, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR * categories.TECH3, '<=',categories.STRUCTURE * categories.FACTORY } },
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
                maxUnits = 0,
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
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR }},
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.AIR * categories.BOMBER * categories.TECH3 } },
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
                maxUnits = 0,
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
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 64, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR }},
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.AIR * categories.EXPERIMENTAL } },
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
                maxUnits = 0,
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 1500
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            --{ MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'AdjacencyCheck', { 'LocationType', categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC  * categories.ENERGYPRODUCTION  * categories.MASSPRODUCTION, 100, 'ueb2304' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 3,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC  * categories.ENERGYPRODUCTION  * categories.MASSPRODUCTION,
                AdjacencyDistance = 100,
                AvoidCategory = categories.STRUCTURE * categories.ANTIAIR * categories.TECH3,
                maxUnits = 10,
                maxRadius = 2,
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
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '>', categories.STRUCTURE * categories.DEFENSE } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.TECH3 * categories.ANTIAIR }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * (categories.TECH1 + categories.TECH2) * categories.ANTIAIR }},
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



