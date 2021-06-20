local categories = categories
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua').GetDangerZoneRadii()

local MaxCapEngineers = 0.15 -- 15% of all units can be Engineers (categories.MOBILE * categories.ENGINEER)
local MaxCapFactory = 0.024 -- 2.4% of all units can be factories (STRUCTURE * FACTORY)

BuilderGroup {
    -- Build Engineers TECH 1,2,3 and SACU
    BuilderGroupName = 'UD Engineer Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    -- panic
    Builder {
        BuilderName = 'UD Engineer builder',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 19100,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 5, categories.MOBILE * categories.ENGINEER * categories.TECH1 }},
            -- Do we need additional conditions to build it ?
            -- Respect UnitCap
         },
        BuilderType = 'All',
    },
}

BuilderGroup {
    -- Build MassExtractors / Creators 
    BuilderGroupName = 'UD MassBuilders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'UDR Mass 1+2',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 19200,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 40, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
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
        BuilderName = 'UDR Mass 3+4',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 17800,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 40, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            { UCBC, 'HaveLessThanUnitsWithCategory', { 4, categories.STRUCTURE * categories.MASSEXTRACTION }},
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
        BuilderName = 'UD Mass 3+4',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17800,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 40, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            { UCBC, 'HaveLessThanUnitsWithCategory', { 4, categories.STRUCTURE * categories.MASSEXTRACTION }},
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
        BuilderName = 'UD Mass 5+',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17900,
        InstanceCount = 1,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 0.0, 10.0}}, -- Absolut Base income 4 60
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 1000, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
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

}

BuilderGroup {
    BuilderGroupName = 'UD Energy Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'DCR Power',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 17900,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION } },            -- Respect UnitCap
            -- When do we want to build this ?
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

    Builder {
        BuilderName = 'UD Power Hydrocarbon',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17895,
        DelayEqualBuildPlattons = {'Energy', 1},
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { MABC, 'CanBuildOnHydro', { 'LocationType', 90, -1000, 100, 1, 'AntiSurface', 1 }},            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.HYDROCARBON } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION } },
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1HydroCarbon',
                }
            }
        }
    },

    Builder {
        BuilderName = 'UD Power income',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17890,
        InstanceCount = 1,                                                      -- Number of plattons that will be formed with this template.
        DelayEqualBuildPlattons = {'Energy', 3},
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'LessThanEconIncome',  { 20000.0, 34.0}}, -- Absolut Base income
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION }},
            -- When do we want to build this ?
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyCategory = categories.FACTORY * categories.STRUCTURE * (categories.AIR + categories.LAND),
                AdjacencyDistance = 50,
                BuildClose = true,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },

    Builder {
        BuilderName = 'UD Power trend',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17890,
        InstanceCount = 1,                                                      -- Number of plattons that will be formed with this template.
        DelayEqualBuildPlattons = {'Energy', 3},
        BuilderConditions = {
            -- Have we the eco to build it ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION }},
            { EBC, 'LessThanEnergyTrend', { 0.0 } },
            -- When do we want to build this ?
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyCategory = categories.FACTORY * categories.STRUCTURE * (categories.AIR + categories.LAND),
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
    BuilderGroupName = 'UD Assistees',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'UD Assist Energy',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 17950,
        InstanceCount = 1,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.ENERGYPRODUCTION }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 60,
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION'},-- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'UD Assist Mass',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 17900,
        InstanceCount = 1,
        BuilderConditions = {
            -- Have we the eco to build it ?
--            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingUpgrade', { 1, categories.STRUCTURE * categories.MASSEXTRACTION }},
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.MASSEXTRACTION }},
            -- When do we want to build this ?
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 80,
                BeingBuiltCategories = {'STRUCTURE MASSEXTRACTION'},        -- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },

}
    
BuilderGroup {
    BuilderGroupName = 'UD ACU Attack Former',                                 -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'UD CDR Attack',                                       -- Random Builder Name.
        PlatoonTemplate = 'CDR Attack',                                         -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 19250,                                                       -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed with this template.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius from main base for new target. (A 5x5 Map is 256 high)
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AttackEnemyStrength = 2000,                                         -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            NodeWeight = 10000,                                                 -- pathfinding with nodes up to a threat of 10000
            TargetSearchCategory = categories.ALLUNITS - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL - (categories.MOBILE * categories.AIR) - categories.STRUCTURE, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Attack these targets.
                categories.COMMAND,
                categories.LAND - categories.ANTIAIR,
                categories.LAND,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.COMMAND,
                categories.LAND - categories.ANTIAIR - categories.ENGINEER,
                categories.LAND - categories.ENGINEER,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { EBC, 'GreaterThanEconIncome',  { 0.0, 32.0}}, -- Absolut Base income
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    
}

BuilderGroup {
    BuilderGroupName = 'UD Factory Builders',                             -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U1 Land Factory RECOVER',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 19300,
        DelayEqualBuildPlattons = {'Factories', 5},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND - categories.SUPPORTFACTORY } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Location = 'LocationType',
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.MASSEXTRACTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'UD Land Factory > 50',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 19300,
        DelayEqualBuildPlattons = {'Factories', 5},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
        },
        BuilderType = 'Any',
        BuilderData = {
            Location = 'LocationType',
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.MASSEXTRACTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
}
BuilderGroup {
    BuilderGroupName = 'D123 Land Builders DUELL',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --

    -- Terror builder, don't activate !!!
    Builder {
        BuilderName = 'D1R Terror mobile Tank',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 100,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'D1R Terror mobile Arty',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 100,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
        },
        BuilderType = 'Land',
    },
}

BuilderGroup {
    BuilderGroupName = 'D123 Land Formers Trasher',                             -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'D1234 panic',
        PlatoonTemplate = 'U1234-Trash Land 50 200',                               -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 60,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            DirectMoveEnemyBase = false, 
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            AttackEnemyStrength = 100000000,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS - categories.AIR,                         -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.ALLUNITS - categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'D1234 military',
        PlatoonTemplate = 'U1234-Trash Land 1 50',                               -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 60,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                       -- Searchradius for new target.
            DirectMoveEnemyBase = false, 
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AttackEnemyStrength = 100000000,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS - categories.AIR,                         -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.MASSEXTRACTION,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.FACTORY * categories.TECH3,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH2,
                categories.STRUCTURE * categories.DEFENSE,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.FACTORY,
                categories.STRUCTURE,
                categories.ALLUNITS - categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'D1234 enemy',
        PlatoonTemplate = 'U1234-Trash Land 1 50',                               -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 60,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            DirectMoveEnemyBase = false, 
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AttackEnemyStrength = 100000000,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS - categories.AIR,                         -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.MASSEXTRACTION,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.FACTORY * categories.TECH3,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH2,
                categories.STRUCTURE * categories.DEFENSE,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.FACTORY,
                categories.STRUCTURE,
                categories.ALLUNITS - categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'D1234 Unit > 200',
        PlatoonTemplate = 'U1234-Trash Land 50 200',                               -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 60,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            DirectMoveEnemyBase = false, 
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            GetTargetsFromBase = false,                                          -- Get targets from base position (true) or platoon position (false)
            AttackEnemyStrength = 100000000,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS - categories.AIR,                         -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.FACTORY * categories.TECH3,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH2,
                categories.STRUCTURE * categories.DEFENSE,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.FACTORY,
                categories.STRUCTURE,
                categories.ALLUNITS - categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 50, categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER }},
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },

}