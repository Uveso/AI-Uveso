local categories = categories
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'
local NoRushRadius = ScenarioInfo.norushradius or 30
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua').GetDangerZoneRadii()

local MaxCapMass = 0.10 -- 10% of all units can be mass extractors (STRUCTURE * MASSEXTRACTION)
local MaxCapStructure = 0.12                                                    -- 12% of all units can be structures (STRUCTURE -MASSEXTRACTION -DEFENSE -FACTORY)

-- ============================================================================================================ --
-- ==                                     Build MassExtractors / Creators                                    == --
-- ============================================================================================================ --
BuilderGroup {
    -- Build MassExtractors / Creators 
    BuilderGroupName = 'U1 MassBuilders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    -- ================== --
    --    TECH 1 - CDR    --
    -- ================== --
    Builder {
        BuilderName = 'UC Mass 12 initial',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 19400,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedMass then
                return 19400
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 12, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.MASSEXTRACTION }},
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                },
            }
        }
    },
    Builder {
        BuilderName = 'UC Mass 12',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 19100,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedMass then
                return 19100
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 12, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.MASSEXTRACTION }},
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                },
            }
        }
    },
    Builder {
        BuilderName = 'UC Mass 12 NoRush',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 19100,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 19100
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 12, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.MASSEXTRACTION }},
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Mass x NoRush',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17900,
        DelayEqualBuildPlattons = {'Mass', 05},
        InstanceCount = 2,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 17900
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Mass' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { -9.99, 0.01 } },             -- Ratio from 0 to 1. (1=100%)
            --{ MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', NoRushRadius, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
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
        InstanceCount = 2,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedMass then
                return 17900
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { -9.99, 0.01 } },             -- Ratio from 0 to 1. (1=100%)
            --{ MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 30, false, false, false, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Don't build it if...
            --{ UCBC, 'GreaterThanGameTimeSeconds', { 60*30 } },
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
    Builder {
        BuilderName = 'U1 Mass 60',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17880,
        InstanceCount = 2,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedMass then
                return 17880
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { -9.99, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            --{ MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 60, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Don't build it if...
            --{ UCBC, 'GreaterThanGameTimeSeconds', { 60*30 } },
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
    Builder {
        BuilderName = 'U1 Mass 1000 6+',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17850,
        InstanceCount = 2,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedMass then
                return 17850
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { -9.99, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            --{ MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 1000, false, false, false, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
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
    Builder {
        BuilderName = 'U1 Mass 1000 8+',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17830,
        InstanceCount = 2,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedMass then
                return 17830
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { -9.99, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            --{ MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 1000, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Don't build it if...
            --{ UCBC, 'GreaterThanGameTimeSeconds', { 60*4 } },
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
    Builder {
        BuilderName = 'U1 Mass 1000 10+',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17810,
        InstanceCount = 2,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedMass then
                return 17810
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { -9.99, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            --{ MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 1000, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Don't build it if...
            --{ UCBC, 'GreaterThanGameTimeSeconds', { 60*30 } },
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
    Builder {
        BuilderName = 'UC Resource RECOVER',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 19100,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedMass then
                return 19100
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 60, -5000, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRings, threatType, maxNum
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.MASSEXTRACTION } },
            { UCBC, 'GreaterThanGameTimeSeconds', { 2*60 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'U1 Resource RECOVER',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 19100,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedMass then
                return 19100
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 60, -5000, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRings, threatType, maxNum
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.MASSEXTRACTION } },
            { UCBC, 'GreaterThanGameTimeSeconds', { 2*60 } },
        },
        BuilderType = 'Any',
        BuilderData = {
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
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 16200,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 16200
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            --{ MIBC, 'HasNotParagon', {} },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 1.00}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.3, categories.STRUCTURE * categories.MASSFABRICATION, '<=',categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.MASSFABRICATION } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.STRUCTURE * categories.MASSEXTRACTION * categories.TECH2 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapMass , '<', categories.STRUCTURE * (categories.MASSEXTRACTION + categories.MASSFABRICATION) } },

        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 4,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
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
    Builder {
        BuilderName = 'U1 Reclaim T1+T2 Massfabrikation',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.MASSFABRICATION * categories.TECH3 }},
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.MASSFABRICATION * (categories.TECH1 + categories.TECH2) }},
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.MASSFABRICATION * (categories.TECH1 + categories.TECH2)},
        },
        BuilderType = 'Any',
    },
}
-- ============================================================================================================ --
-- ==                                         Upgrade MassExtractors                                         == --
-- ============================================================================================================ --
BuilderGroup {
    -- Upgrade MassExtractors from Tech 1 to 2 AND from Tech 2 to 3
    BuilderGroupName = 'U123 ExtractorUpgrades',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Extractor upgrade >40 mass',
        PlatoonTemplate = 'AddToMassExtractorUpgradePlatoon',
        Priority = 18400,
        InstanceCount = 1,
        FormRadius = 10000,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 18400
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 4.0, -0.0}}, -- Absolut Base income
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MASSEXTRACTION} },
            { UCBC, 'GreaterThanGameTimeSeconds', { 1*60 } },
        },
        BuilderData = {
            AIPlan = 'ExtractorUpgradeAI',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Extractor upgrade >4 factories',
        PlatoonTemplate = 'AddToMassExtractorUpgradePlatoon',
        Priority = 18400,
        InstanceCount = 1,
        FormRadius = 10000,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 18400
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MASSEXTRACTION} },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.STRUCTURE * categories.FACTORY} },
        },
        BuilderData = {
            AIPlan = 'ExtractorUpgradeAI',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Extractor upgrade > 6 minutes',
        PlatoonTemplate = 'AddToMassExtractorUpgradePlatoon',
        Priority = 18400,
        InstanceCount = 1,
        FormRadius = 10000,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 18400
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MASSEXTRACTION} },
            { UCBC, 'GreaterThanGameTimeSeconds', { 6*60 } },
        },
        BuilderData = {
            AIPlan = 'ExtractorUpgradeAI',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Extractors > 5',
        PlatoonTemplate = 'AddToMassExtractorUpgradePlatoon',
        Priority = 18400,
        InstanceCount = 1,
        FormRadius = 10000,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 18400
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MASSEXTRACTION} },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.MASSEXTRACTION} },
            { UCBC, 'GreaterThanGameTimeSeconds', { 5*60 } },
        },
        BuilderData = {
            AIPlan = 'ExtractorUpgradeAI',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Extractors > Full storage',
        PlatoonTemplate = 'AddToMassExtractorUpgradePlatoon',
        Priority = 18400,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { EBC, 'GreaterThanEconTrend', { 0.1, 0.1 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.80, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'GreaterThanGameTimeSeconds', { 1*60 } },
        },
        BuilderData = {
            AIPlan = 'ExtractorUpgradeAI',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Extractors NoRush1stPhaseActive',
        PlatoonTemplate = 'AddToMassExtractorUpgradePlatoon',
        Priority = 18400,
        InstanceCount = 1,
        FormRadius = 10000,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 18400
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MASSEXTRACTION} },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.MASSEXTRACTION} },
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
    BuilderGroupName = 'U1 MassStorage Builder',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U1 Mass Storage RECOVER',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 18000,
        DelayEqualBuildPlattons = {'MASSSTORAGE', 3},
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 18000
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.COMMAND }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.MASSSTORAGE }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1,  categories.STRUCTURE * categories.MASSSTORAGE }},
            -- Respect UnitCap
        },
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.MASSEXTRACTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                AdjacencyDistance = 100,
                BuildClose = false,
                BuildStructures = {
                    'MassStorage',
                }
            }
        },
        BuilderType = 'Any'
    },
    Builder {
        BuilderName = 'U1 Mass Storage 1st',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17450,
        DelayEqualBuildPlattons = {'MASSSTORAGE', 3},
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 17450
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'MASSSTORAGE' }},
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.MASSSTORAGE }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1,  categories.STRUCTURE * categories.MASSSTORAGE }},
            { UCBC, 'GreaterThanGameTimeSeconds', { 60 * 5 } },
            -- Respect UnitCap
        },
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.MASSEXTRACTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                AdjacencyDistance = 100,
                BuildClose = false,
                BuildStructures = {
                    'MassStorage',
                }
            }
        },
        BuilderType = 'Any'
    },
    Builder {
        BuilderName = 'U1 Mass Adjacency Engineer',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17879,
        DelayEqualBuildPlattons = {'MASSSTORAGE', 5},
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 17879
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'MASSSTORAGE' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.1, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1,  categories.STRUCTURE * categories.MASSSTORAGE }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 16, categories.STRUCTURE * categories.MASSSTORAGE }},
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapMass , '<', categories.STRUCTURE * (categories.MASSEXTRACTION + categories.MASSFABRICATION + categories.MASSSTORAGE) } },
            { UCBC, 'AdjacencyCheck', { 'LocationType', categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH2 + categories.TECH3), 60, 'ueb1106' } },
            -- Respect UnitCap
        },
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH2 + categories.TECH3),
                AdjacencyDistance = 60,
                BuildClose = false,
                BuildStructures = {
                    'MassStorage',
                }
            }
        },
        BuilderType = 'Any'
    },
    Builder {
        BuilderName = 'U2 Mass Adjacency Engineer',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 17878,
        DelayEqualBuildPlattons = {'MASSSTORAGE', 5},
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 17878
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'MASSSTORAGE' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.1, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1,  categories.STRUCTURE * categories.MASSSTORAGE }},
            { UCBC, 'AdjacencyCheck', { 'LocationType', categories.MASSEXTRACTION * categories.TECH3, 60, 'ueb1106' } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 32, categories.STRUCTURE * categories.MASSSTORAGE }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapMass , '<', categories.STRUCTURE * (categories.MASSEXTRACTION + categories.MASSFABRICATION + categories.MASSSTORAGE) } },
        },
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION TECH3',
                AdjacencyDistance = 60,
                BuildClose = false,
                BuildStructures = {
                    'MassStorage',
                }
            }
        },
        BuilderType = 'Any'
    },
    Builder {
        BuilderName = 'U1 Reclaim MassStorage',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 790
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            --{ MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.MASSSTORAGE }},
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.MASSSTORAGE},
        },
        BuilderType = 'Any'
    },
}
