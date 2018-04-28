local IBC = '/lua/editor/InstantBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local SIBC = '/lua/editor/SorianInstantBuildConditions.lua'

local ExperimentalCount = 3
local mapSizeX, mapSizeZ = GetMapSize()
local BaseMilitaryZone = math.max( mapSizeX-50, mapSizeZ-50 ) / 2 -- Half the map
local BasePanicZone = BaseMilitaryZone / 2
BasePanicZone = math.max( 40, BasePanicZone )
BasePanicZone = math.min( 120, BasePanicZone )

-- ===================================================-======================================================== --
-- ==                                 Mobile Experimental Land/Air/Sea                                       == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Mobile Experimental Builder Uveso',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Uveso T4AirExperimental1',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 800,
        DelayEqualBuildPlattons = {'Experimental', 10},
        InstanceCount = 3,
        BuilderConditions = {
            -- When do we want to build this ?
            { EBC, 'GreaterThanEconTrend', { 2.0, 300.0 } }, -- relative income
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.95, 0.95 }}, -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }}, -- relative baseincome 0=bad, 1=ok, 2=full
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Experimental' }},
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = 'SHIELD STRUCTURE, FACTORY TECH3, FACTORY TECH2, FACTORY TECH1',
                BuildStructures = {
                    'T4AirExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Uveso T4LandExperimental3',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 800,
        DelayEqualBuildPlattons = {'Experimental', 10},
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { EBC, 'GreaterThanEconTrend', { 2.0, 300.0 } }, -- relative income
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.95, 0.95 }}, -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }}, -- relative baseincome 0=bad, 1=ok, 2=full
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Experimental' }},
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = false,
                AdjacencyCategory = 'SHIELD STRUCTURE, FACTORY TECH3, FACTORY TECH2, FACTORY TECH1',
                BuildStructures = {
                    'T4LandExperimental3',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Uveso T4SeaExperimental1',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 800,
        DelayEqualBuildPlattons = {'Experimental', 10},
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { EBC, 'GreaterThanEconTrend', { 2.0, 300.0 } }, -- relative income
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.95, 0.95 }}, -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }}, -- relative baseincome 0=bad, 1=ok, 2=full
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Experimental' }},
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = 'SHIELD STRUCTURE, FACTORY TECH3, FACTORY TECH2, FACTORY TECH1',
                BuildStructures = {
                    'T4SeaExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Uveso T4LandExperimental2',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 800,
        DelayEqualBuildPlattons = {'Experimental', 10},
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { EBC, 'GreaterThanEconTrend', { 2.0, 300.0 } }, -- relative income
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.95, 0.95 }}, -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }}, -- relative baseincome 0=bad, 1=ok, 2=full
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Experimental' }},
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = false,
                AdjacencyCategory = 'SHIELD STRUCTURE, FACTORY TECH3, FACTORY TECH2, FACTORY TECH1',
                BuildStructures = {
                    'T4LandExperimental2',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Uveso T4LandExperimental1',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 800,
        DelayEqualBuildPlattons = {'Experimental', 10},
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { EBC, 'GreaterThanEconTrend', { 2.0, 300.0 } }, -- relative income
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.95, 0.95 }}, -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }}, -- relative baseincome 0=bad, 1=ok, 2=full
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Experimental' }},
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = 'SHIELD STRUCTURE, FACTORY TECH3, FACTORY TECH2, FACTORY TECH1',
                BuildStructures = {
                    'T4LandExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U-T4 LandExp1 Minimum',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 810,
        DelayEqualBuildPlattons = {'Experimental Effi', 10},
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { EBC, 'GreaterThanEconIncome', { 20.0, 1000.0 }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.EXPERIMENTAL * categories.LAND }},
            { UCBC, 'CheckBuildPlattonDelay', { 'Experimental' }},
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = 'SHIELD STRUCTURE, FACTORY TECH3, FACTORY TECH2, FACTORY TECH1',
                BuildStructures = {
                    'T4LandExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
}
-- ===================================================-======================================================== --
-- ==                                 Economic Experimental (Paragon etc)                                    == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Economic Experimental Builder Uveso',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U3 Paragon 1st',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Paragon', 30},
        BuilderConditions = {
            { UCBC, 'NoParagon', { } },
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'CheckBuildPlattonDelay', { 'Paragon' }},
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.EXPERIMENTAL}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC}},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'SHIELD STRUCTURE, STRUCTURE',
                AdjacencyDistance = 80,
                AvoidCategory = categories.ENERGYPRODUCTION * categories.EXPERIMENTAL,
                maxUnits = 1,
                maxRadius = 40,
                BuildClose = false,
                BuildStructures = {
                    'T4EconExperimental',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U3 Paragon 2nd',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 1000,
        BuilderConditions = {
            { UCBC, 'HasParagon', {} },
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.EXPERIMENTAL}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC}},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'SHIELD STRUCTURE, STRUCTURE',
                AdjacencyDistance = 80,
                AvoidCategory = categories.ENERGYPRODUCTION * categories.EXPERIMENTAL,
                maxUnits = 1,
                maxRadius = 40,
                BuildClose = false,
                BuildStructures = {
                    'T4EconExperimental',
                },
                Location = 'LocationType',
            }
        }
    },
}
-- ===================================================-======================================================== --
-- ==                                  Experimental Attack FormBuilder                                       == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'ExperimentalAttackFormBuilders Uveso',
    BuildersType = 'PlatoonFormBuilder',
    -- ================== --
    --    BasePanicZone    --
    -- ================== --
    Builder {
        BuilderName = 'U4 BasePanicZone LAND',
        --PlatoonAddPlans = {'NameUnitsSorian'},
        PlatoonTemplate = 'T4ExperimentalLandUveso 1 1',
        Priority = 1600,                                        -- Priority. 1000 is normal.
        InstanceCount = 2,                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = BasePanicZone,                       -- Searchradius for new target.
            GetTargetsFromBase = true,                          -- Get targets from base position (true) or platoon position (false)
            UseMoveOrder = false,                               -- If true, the unit will first move to the targetposition and then attack it.
            TargetSearchCategory = 'MOBILE LAND, STRUCTURE',    -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE LAND EXPERIMENTAL',
                'MOBILE LAND',
                'STRUCTURE',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL * categories.MOBILE * categories.LAND } },
        },
        BuilderType = 'Any',                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U4 BasePanicZone AIR',
        PlatoonTemplate = 'U4-ExperimentalInterceptor 1 1',
        --PlatoonAddPlans = {'NameUnitsSorian'},
        Priority = 1500,                                        -- Priority. 1000 is normal.
        InstanceCount = 2,                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = BasePanicZone,                       -- Searchradius for new target.
            GetTargetsFromBase = true,                          -- Get targets from base position (true) or platoon position (false)
            UseMoveOrder = false,                               -- If true, the unit will first move to the targetposition and then attack it.
            IgnoreAntiAir = false,                              -- Don't attack if we have more then x anti air buildings at target position.
            TargetSearchCategory = 'MOBILE, STRUCTURE',         -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE AIR EXPERIMENTAL',
                'MOBILE LAND EXPERIMENTAL',
                'LAND ANTIAIR',
                'MOBILE LAND',
                'STRUCTURE',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL * categories.MOBILE * categories.AIR } },
        },
        BuilderType = 'Any',                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- ======================= --
    --    BaseMilitaryZone    --
    -- ======================= --
    Builder {
        BuilderName = 'U4 BaseMilitaryZone LAND',
        --PlatoonAddPlans = {'NameUnitsSorian'},
        PlatoonTemplate = 'T4ExperimentalLandUveso 1 1',
        Priority = 1600,                                        -- Priority. 1000 is normal.
        InstanceCount = 2,                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                    -- Searchradius for new target.
            GetTargetsFromBase = false,                         -- Get targets from base position (true) or platoon position (false)
            UseMoveOrder = false,                               -- If true, the unit will first move to the targetposition and then attack it.
            TargetSearchCategory = 'MOBILE LAND, STRUCTURE',    -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE LAND EXPERIMENTAL',
                'MOBILE LAND',
                'STRUCTURE',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.EXPERIMENTAL * categories.MOBILE * categories.LAND } },
        },
        BuilderType = 'Any',                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U4 BaseMilitaryZone AIR',
        PlatoonTemplate = 'U4-ExperimentalInterceptor 1 1',
        --PlatoonAddPlans = {'NameUnitsSorian'},
        Priority = 1500,                                        -- Priority. 1000 is normal.
        InstanceCount = 2,                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                        -- Searchradius for new target.
            GetTargetsFromBase = true,                          -- Get targets from base position (true) or platoon position (false)
            UseMoveOrder = false,                               -- If true, the unit will first move to the targetposition and then attack it.
            IgnoreAntiAir = false,                              -- Don't attack if we have more then x anti air buildings at target position.
            TargetSearchCategory = 'MOBILE, STRUCTURE',         -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE AIR EXPERIMENTAL',
                'MOBILE LAND EXPERIMENTAL',
                'LAND ANTIAIR',
                'MOBILE LAND',
                'STRUCTURE',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.EXPERIMENTAL * categories.MOBILE * categories.AIR } },
        },
        BuilderType = 'Any',                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- =============== --
    --    EnemyZone    --
    -- =============== --
    Builder {
        BuilderName = 'U4 EnemyZone Mass',
        --PlatoonAddPlans = {'NameUnitsSorian'},
        PlatoonTemplate = 'T4ExperimentalLandGroupUveso 2 2',
        Priority = 1500,                                        -- Priority. 1000 is normal.
        InstanceCount = 1,                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = 10000,                               -- Searchradius for new target.
            GetTargetsFromBase = false,                         -- Get targets from base position (true) or platoon position (false)
            UseMoveOrder = false,                               -- If true, the unit will first move to the targetposition and then attack it.
            TargetSearchCategory = 'STRUCTURE, MOBILE LAND',    -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE LAND EXPERIMENTAL',
                'MASSEXTRACTION',
                'LAND ANTIAIR',
                'STRUCTURE',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.EXPERIMENTAL * categories.MOBILE * categories.LAND } },
        },
        BuilderType = 'Any',                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
     Builder {
        BuilderName = 'U-T4 EnemyZone AntiNUKE',
        --PlatoonAddPlans = {'NameUnitsSorian'},
        PlatoonTemplate = 'T4ExperimentalLandGroupUveso 2 2',
        Priority = 1500,                                        -- Priority. 1000 is normal.
        InstanceCount = 1,                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = 10000,                               -- Searchradius for new target.
            GetTargetsFromBase = false,                         -- Get targets from base position (true) or platoon position (false)
            UseMoveOrder = false,                               -- If true, the unit will first move to the targetposition and then attack it.
            TargetSearchCategory = 'STRUCTURE, MOBILE LAND',    -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE LAND EXPERIMENTAL',
                'STRUCTURE DEFENSE ANTIMISSILE TECH3',
                'STRUCTURE NUKE',
                'STRUCTURE ARTILLERY',
                'STRUCTURE ENERGYPRODUCTION',
                'STRUCTURE LAND ANTIAIR',
                'STRUCTURE LAND DEFENSE',
                'STRUCTURE LAND',
                'STRUCTURE',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.EXPERIMENTAL * categories.MOBILE * categories.LAND } },
        },
        BuilderType = 'Any',                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
     Builder {
        BuilderName = 'U-T4 EnemyBase Land',
        --PlatoonAddPlans = {'NameUnitsSorian'},
        PlatoonTemplate = 'T4ExperimentalLandGroupUveso 2 2',
        Priority = 1500,                                        -- Priority. 1000 is normal.
        InstanceCount = 1,                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = 10000,                               -- Searchradius for new target.
            GetTargetsFromBase = false,                         -- Get targets from base position (true) or platoon position (false)
            UseMoveOrder = false,                               -- If true, the unit will first move to the targetposition and then attack it.
            TargetSearchCategory = 'STRUCTURE, MOBILE LAND',    -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE LAND EXPERIMENTAL',
                'STRUCTURE DEFENSE TECH3',
                'STRUCTURE EXPERIMENTAL',
                'STRUCTURE TECH3',
                'STRUCTURE',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.EXPERIMENTAL * categories.MOBILE * categories.LAND } },
        },
        BuilderType = 'Any',                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U4 EnemyBase Air',
        PlatoonTemplate = 'U4-ExperimentalInterceptor 1 1',
        --PlatoonAddPlans = {'NameUnitsSorian'},
        Priority = 1500,                                        -- Priority. 1000 is normal.
        InstanceCount = 1,                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = 10000,                               -- Searchradius for new target.
            GetTargetsFromBase = false,                         -- Get targets from base position (true) or platoon position (false)
            UseMoveOrder = false,                               -- If true, the unit will first move to the targetposition and then attack it.
            IgnoreAntiAir = false,                              -- Don't attack if we have more then x anti air buildings at target position.
            TargetSearchCategory = 'STRUCTURE, MOBILE',         -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE AIR EXPERIMENTAL',
                'MOBILE LAND EXPERIMENTAL',
                'LAND ANTIAIR',
                'STRUCTURE DEFENSE ANTIMISSILE TECH3',
                'STRUCTURE ARTILLERY',
                'STRUCTURE NUKE',
                'STRUCTURE ENERGYPRODUCTION',
                'STRUCTURE',
                'LAND',
                'AIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.EXPERIMENTAL * categories.MOBILE * categories.AIR } },
        },
        BuilderType = 'Any',                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- ================= --
    --    Finish him!    --
    -- ================= --
    Builder {
        BuilderName = 'U-T4 Land. Kill Them All!!!',
        --PlatoonAddPlans = {'NameUnitsSorian'},
        PlatoonTemplate = 'T4ExperimentalLandGroupUveso 2 2',
        Priority = 1600,                                        -- Priority. 1000 is normal.
        InstanceCount = 20,                                     -- Number of plattons that will be formed.
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = 10000,                               -- Searchradius for new target.
            GetTargetsFromBase = false,                         -- Get targets from base position (true) or platoon position (false)
            UseMoveOrder = false,                               -- If true, the unit will first move to the targetposition and then attack it.
            TargetSearchCategory = 'STRUCTURE, MOBILE LAND',    -- Only find targets matching these categories.
            PrioritizedCategories = {
                'DEFENSE ANTIMISSILE TECH3',
                'ARTILLERY',
                'NUKE',
                'ANTIAIR',
                'ENERGYPRODUCTION',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.5, 'MOBILE', '>', 'MOBILE' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.EXPERIMENTAL * categories.MOBILE * categories.LAND } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U-T4 Air. Kill Them All!!!',
        PlatoonTemplate = 'U4-ExperimentalInterceptor 1 1',
        --PlatoonAddPlans = {'NameUnitsSorian'},
        Priority = 1500,                                        -- Priority. 1000 is normal.
        InstanceCount = 20,                                     -- Number of plattons that will be formed.
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = 10000,                               -- Searchradius for new target.
            GetTargetsFromBase = false,                         -- Get targets from base position (true) or platoon position (false)
            UseMoveOrder = false,                               -- If true, the unit will first move to the targetposition and then attack it.
            IgnoreAntiAir = false,                              -- Don't attack if we have more then x anti air buildings at target position.
            TargetSearchCategory = 'STRUCTURE, MOBILE',         -- Only find targets matching these categories.
            PrioritizedCategories = {
                'DEFENSE ANTIMISSILE TECH3',
                'ARTILLERY',
                'NUKE',
                'ANTIAIR',
                'ENERGYPRODUCTION',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.5, 'MOBILE', '>', 'MOBILE' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.MOBILE * categories.AIR } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
