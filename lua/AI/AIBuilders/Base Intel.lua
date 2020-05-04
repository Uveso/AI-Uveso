local categories = categories
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'

local MaxCapStructure = 0.12                                                    -- 12% of all units can be structures (STRUCTURE -MASSEXTRACTION -DEFENSE -FACTORY)

-- ===================================================-======================================================== --
-- ==                                        Radar T1 T3 builder                                             == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U1 Land Radar Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U1 Radar',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17500,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, (categories.RADAR + categories.OMNI) * categories.STRUCTURE}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND } },
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
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 5.2, 400.0 } }, -- relative income
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.OMNI * categories.STRUCTURE } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.OMNI * categories.STRUCTURE }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
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
        BuilderName = 'U1 Reclaim T1+T2 Radar',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.OMNI * categories.STRUCTURE }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.RADAR }},
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.RADAR * (categories.TECH1 + categories.TECH2)},
        },
        BuilderType = 'Any',
    },
}
-- ===================================================-======================================================== --
-- ==                                    Radar T1 Upgrade Land+Air                                           == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U1 Land Radar Upgrader',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U1 Radar Upgrade',
        PlatoonTemplate = 'T1RadarUpgrade',
        Priority = 1000,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH2 } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.RADAR * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Radar Upgrade',
        PlatoonTemplate = 'T2RadarUpgrade',
        Priority = 1000,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.OMNI * categories.STRUCTURE }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.RADAR * categories.TECH2 }},
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
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconIncome', { 12, 1500}},
            { EBC, 'GreaterThanEconStorageRatio', { 0.95, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.OPTICS * categories.AEON}},
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
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
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconIncome', { 12, 1500}},
            { EBC, 'GreaterThanEconStorageRatio', { 0.95, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.OPTICS * categories.CYBRAN}},
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
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
