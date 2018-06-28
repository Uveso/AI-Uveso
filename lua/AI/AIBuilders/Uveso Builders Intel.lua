local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local IBC = '/lua/editor/InstantBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'

-- ===================================================-======================================================== --
-- ==                                 Scouts T1 T2 T3 Builder Land+Air                                       == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'ScoutBuilder Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ========================= --
    --    Land Scouts Builder    --
    -- ========================= --
    Builder {
        BuilderName = 'U1 Land Scout Always',
        PlatoonTemplate = 'T1LandScout',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Scouts', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.MOBILE * categories.ENGINEER}},
            -- Do we need additional conditions to build it ?
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.SCOUT * categories.LAND } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Scouts' }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 4, categories.LAND * categories.SCOUT }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.AIR * categories.SCOUT }},
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    -- ======================== --
    --    Air Scouts Builder    --
    -- ======================== --
    Builder {
        BuilderName = 'U1 Air Scout',
        PlatoonTemplate = 'T1AirScout',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Scouts', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.SCOUT } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Scouts' }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.AIR * categories.SCOUT }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.FACTORY * categories.AIR * categories.TECH3 } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3 Air Scout',
        PlatoonTemplate = 'T3AirScout',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Scouts', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.SCOUT } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Scouts' }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.INTELLIGENCE * categories.AIR * categories.TECH3 }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
}
-- ===================================================-======================================================== --
-- ==                                   Scouts T1 T3 Former Land+Air                                         == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'ScoutFormer Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    -- ======================== --
    --    Land Scouts Former    --
    -- ======================== --
    Builder {
        BuilderName = 'U1 Land Scout',
        PlatoonTemplate = 'T1LandScoutForm',
        Priority = 5000,
        InstanceCount = 8,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.LAND * categories.SCOUT } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
        },
        LocationType = 'LocationType',
        BuilderType = 'Any',
    },
    -- ======================= --
    --    Air Scouts Former    --
    -- ======================= --
    Builder {
        BuilderName = 'U1 Air Scout Form',
        PlatoonTemplate = 'T1AirScoutForm',
        Priority = 5000,
        InstanceCount = 3,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AIR * categories.SCOUT } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U3 Air Scout Form',
        PlatoonTemplate = 'T3AirScoutForm',
        PlatoonAddBehaviors = { 'AirUnitRefit' },
        Priority = 5000,
        InstanceCount = 5,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AIR * categories.INTELLIGENCE } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderType = 'Any',
    },
}
-- ===================================================-======================================================== --
-- ==                                        Radar T1 T3 builder                                             == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'RadarBuilders Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U1 Radar',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17500,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, (categories.RADAR + categories.OMNI) * categories.STRUCTURE}},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH1' }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION,
                AdjacencyDistance = 50,
                BuildStructures = {
                    'T1Radar',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U3 Radar',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.OMNI * categories.STRUCTURE }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconTrend', { 5.2, 400.0 } }, -- relative income
            -- Don't build it if...
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.OMNI * categories.STRUCTURE } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.OMNI * categories.STRUCTURE } },
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                AdjacencyDistance = 50,
                BuildStructures = {
                    'T3Radar',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U3 Radar Backup',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 0,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.OMNI * categories.STRUCTURE } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.OMNI * categories.STRUCTURE }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.90, 0.95 } }, -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconTrend', { 5.2, 800.0 } }, -- relative income
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.OMNI * categories.STRUCTURE } },
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                AdjacencyDistance = 50,
                BuildStructures = {
                    'T3Radar',
                },
                Location = 'LocationType',
            }
        }
    },
}
-- ===================================================-======================================================== --
-- ==                                    Radar T1 Upgrade Land+Air                                           == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'RadarUpgrade Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U1 Radar Upgrade',
        PlatoonTemplate = 'T1RadarUpgrade',
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'ENERGYPRODUCTION TECH3' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.RADAR * categories.TECH1 }},
            -- Respect UnitCap
        },
        BuilderType = 'Any',
    },
}
-- =============================================-==================================================== --
-- ==                                    Special Optics                                            == --
-- =============================================-==================================================== --

BuilderGroup {
    BuilderGroupName = 'AeonOptics',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U3 Optics Construction Aeon',
        PlatoonTemplate = 'AeonT3EngineerBuilder',
        Priority = 750,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.OPTICS * categories.AEON}},
            { EBC, 'GreaterThanEconIncome', { 12, 1500}},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
            { EBC, 'GreaterThanEconStorageRatio', { 0.95, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'ENERGYPRODUCTION',
                AdjacencyDistance = 100,
                BuildClose = false,
                BuildStructures = {
                    'T3Optics',
                },
                Location = 'LocationType',
            }
        }
    }
}

BuilderGroup {
    BuilderGroupName = 'CybranOptics',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U3 Optics Construction Cybran',
        PlatoonTemplate = 'CybranT3EngineerBuilder',
        Priority = 750,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.OPTICS * categories.CYBRAN}},
            { EBC, 'GreaterThanEconIncome', { 12, 1500}},
            { EBC, 'GreaterThanEconStorageRatio', { 0.95, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'ENERGYPRODUCTION',
                AdjacencyDistance = 100,
                BuildClose = false,
                BuildStructures = {
                    'T3Optics',
                },
                Location = 'LocationType',
            }
        }
    }
}
