local categories = categories
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'

local MaxCapStructure = 0.12                                                    -- 12% of all units can be structures (STRUCTURE -MASSEXTRACTION -DEFENSE -FACTORY)

-- ===================================================-======================================================== --
-- ==                                       Build Power TECH 1,2,3                                           == --
-- ===================================================-======================================================== --
BuilderGroup {
    -- Build Power TECH 1,2,3
    BuilderGroupName = 'U123 Energy Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U1 Power low trend',
        PlatoonTemplate = 'EngineerBuilder',
        TechRoot = 'ENERGY1',
        Priority = 17899,
        InstanceCount = 2,                                                      -- Number of plattons that will be formed with this template.
        DelayEqualBuildPlattons = {'Energy', 3},
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'LessThanEnergyTrend', { 0.0 } },
            { EBC, 'GreaterThanEconIncome',  { 0.5, 0.0}}, -- Absolut Base income
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*2 } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 } },
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
        BuilderName = 'UC Power low trend',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 17900,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'LessThanEnergyTrend', { 0.0 } },
            { EBC, 'GreaterThanEconIncome',  { 0.2, 0.0}}, -- Absolut Base income
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 } },
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
        BuilderName = 'UC Power MassRatio',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 15000,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'EnergyToMassRatioIncome', { 10.0, '<=' } },  -- True if we have less than 10 times more Energy then Mass income ( 100 <= 10 = true )
            { EBC, 'GreaterThanEconIncome',  { 0.6, 0.0}}, -- Absolut Base income
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
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
        BuilderName = 'U1 Power MassRatio 5',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17870,
        InstanceCount = 3,                                                      -- Number of plattons that will be formed with this template.
        DelayEqualBuildPlattons = {'Energy', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'EnergyToMassRatioIncome', { 5.0, '<=' } },  -- True if we have less than 10 times more Energy then Mass income ( 100 <= 10 = true )
            { EBC, 'GreaterThanEconIncome',  { 1.0, 6.0}}, -- Absolut Base income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 180 } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
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
        BuilderName = 'U1 Power MassRatio 10',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17870,
        InstanceCount = 2,                                                      -- Number of plattons that will be formed with this template.
        DelayEqualBuildPlattons = {'Energy', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'EnergyToMassRatioIncome', { 10.0, '<=' } },  -- True if we have less than 10 times more Energy then Mass income ( 100 <= 10 = true )
            { EBC, 'GreaterThanEconIncome',  { 1.0, 6.0}}, -- Absolut Base income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 180 } },
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
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
        BuilderName = 'U1 Power MassRatio 15',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17870,
        InstanceCount = 1,                                                      -- Number of plattons that will be formed with this template.
        DelayEqualBuildPlattons = {'Energy', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'EnergyToMassRatioIncome', { 15.0, '<=' } },  -- True if we have less than 10 times more Energy then Mass income ( 100 <= 10 = true )
            { EBC, 'GreaterThanEconIncome',  { 1.0, 6.0}}, -- Absolut Base income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 180 } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
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
        BuilderName = 'U1 Power Hydrocarbon',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17881,
        DelayEqualBuildPlattons = {'Energy', 1},
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'GreaterThanEconIncome',  { 0.4, 2.0}}, -- Absolut Base income 4 60
            -- When do we want to build this ?
            { MABC, 'CanBuildOnHydro', { 'LocationType', 90, -1000, 100, 1, 'AntiSurface', 1 }},            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
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
        BuilderName = 'UC Energy RECOVER',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 19200,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION } },
            -- Respect UnitCap
        },
        InstanceCount = 1,
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.FACTORY * (categories.LAND + categories.AIR),
                AdjacencyDistance = 50,
                BuildClose = false,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Energy RECOVER',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 19200,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION } },
            -- Respect UnitCap
        },
        InstanceCount = 1,
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.FACTORY * (categories.LAND + categories.AIR),
                AdjacencyDistance = 50,
                BuildClose = false,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2 Power minimum',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 17000,
        DelayEqualBuildPlattons = {'Energy', 20},
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * ( categories.TECH2 + categories.TECH3 ) }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.ENERGYPRODUCTION * ( categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL ) } },
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = false,
                AdjacencyCategory = (categories.STRUCTURE * categories.SHIELD) + (categories.FACTORY * (categories.TECH3 + categories.TECH2 + categories.TECH1)),
                AvoidCategory = categories.ENERGYPRODUCTION * categories.TECH2,
                maxUnits = 1,
                maxRadius = 10,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T2EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U2 Power Push 1000',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 16900,
        DelayEqualBuildPlattons = {'Energy', 20},
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'LessThanEnergyTrend', { 100.0 } },
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, -0.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * ( categories.TECH2 + categories.TECH3 ) }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH2 - categories.STATIONASSISTPOD }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * ( categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL ) } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = false,
                AdjacencyCategory = (categories.STRUCTURE * categories.SHIELD) + (categories.FACTORY * (categories.TECH3 + categories.TECH2 + categories.TECH1)),
                AvoidCategory = categories.ENERGYPRODUCTION * categories.TECH2,
                maxUnits = 1,
                maxRadius = 10,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T2EnergyProduction',
                },
            }
        }
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3 Power minimum',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 17300,
        DelayEqualBuildPlattons = {'Energy', 5},
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.ENERGYPRODUCTION * categories.TECH3 } },
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = false,
                AdjacencyCategory = (categories.STRUCTURE * categories.SHIELD) + (categories.FACTORY * (categories.TECH3 + categories.TECH2 + categories.TECH1)),
                AvoidCategory = categories.ENERGYPRODUCTION * categories.TECH3,
                maxUnits = 1,
                maxRadius = 15,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U3 Power Emergency',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 17200,
        DelayEqualBuildPlattons = {'Energy', 5},
        InstanceCount = 3,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'LessThanEconStorageRatio', { 2.00, 0.80}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = false,
                AdjacencyCategory = (categories.STRUCTURE * categories.SHIELD) + (categories.FACTORY * (categories.TECH3 + categories.TECH2 + categories.TECH1)),
                AvoidCategory = categories.ENERGYPRODUCTION * categories.TECH3,
                maxUnits = 1,
                maxRadius = 15,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U3 Power Push 6000',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 17100,
        DelayEqualBuildPlattons = {'Energy', 5},
        InstanceCount = 4,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'LessThanEnergyTrend', { 600.0 } },
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 3, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = false,
                AdjacencyCategory = (categories.STRUCTURE * categories.SHIELD) + (categories.FACTORY * (categories.TECH3 + categories.TECH2 + categories.TECH1)),
                AvoidCategory = categories.ENERGYPRODUCTION * categories.TECH3,
                maxUnits = 1,
                maxRadius = 15,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U3 Power Push 30000',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 17000,
        DelayEqualBuildPlattons = {'Energy', 5},
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'LessThanEnergyTrend', { 3000.0 } },
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 3, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = false,
                AdjacencyCategory = (categories.STRUCTURE * categories.SHIELD) + (categories.FACTORY * (categories.TECH3 + categories.TECH2 + categories.TECH1)),
                AvoidCategory = categories.ENERGYPRODUCTION * categories.TECH3,
                maxUnits = 1,
                maxRadius = 15,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3EnergyProduction',
                },
            }
        }
    },
    -- =================== --
    --    EnergyStorage    --
    -- =================== --
    Builder {
        BuilderName = 'U1 Energy Storage RECOVER',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17750,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, -0.01 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1,  categories.STRUCTURE * categories.ENERGYSTORAGE }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.COMMAND }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYSTORAGE }},
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Location = 'LocationType',
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                LocationType = 'LocationType',
                BuildStructures = {
                    'EnergyStorage',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Energy Storage 7min',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17750,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 60 * 7 } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1,  categories.STRUCTURE * categories.ENERGYSTORAGE }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.ENERGYSTORAGE }},
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Location = 'LocationType',
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                LocationType = 'LocationType',
                BuildStructures = {
                    'EnergyStorage',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Energy Storage 10min',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17750,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 60 * 10 } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1,  categories.STRUCTURE * categories.ENERGYSTORAGE }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.ENERGYSTORAGE }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Location = 'LocationType',
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                LocationType = 'LocationType',
                BuildStructures = {
                    'EnergyStorage',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Energy Storage 15min',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17750,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 60 * 15 } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1,  categories.STRUCTURE * categories.ENERGYSTORAGE }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 5, categories.STRUCTURE * categories.ENERGYSTORAGE }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Location = 'LocationType',
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                LocationType = 'LocationType',
                BuildStructures = {
                    'EnergyStorage',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U2 Energy Storage ratio',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 17440,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.STRUCTURE * categories.ENERGYSTORAGE }},
            { UCBC, 'HaveUnitRatioUveso', { 1.0, categories.STRUCTURE * categories.ENERGYSTORAGE, '<', categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Location = 'LocationType',
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                LocationType = 'LocationType',
                BuildStructures = {
                    'EnergyStorage',
                },
            }
        }
    },
    -- ======================= --
    --    Reclaim Buildings    --
    -- ======================= --
    Builder {
        BuilderName = 'U1 Reclaim T1 Pgens',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.TECH1 * categories.ENERGYPRODUCTION - categories.HYDROCARBON }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.TECH1 * categories.ENERGYPRODUCTION - categories.HYDROCARBON},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U1 Reclaim T1 Pgens cap',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { UCBC, 'UnitCapCheckGreater', { 0.95 } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 1.0 } }, -- relative income
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.TECH1 * categories.ENERGYPRODUCTION - categories.HYDROCARBON }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) }},
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.TECH1 * categories.ENERGYPRODUCTION - categories.HYDROCARBON},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U1 Reclaim T2 Pgens',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.TECH2 * categories.ENERGYPRODUCTION - categories.HYDROCARBON }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.TECH2 * categories.ENERGYPRODUCTION - categories.HYDROCARBON},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U1 Reclaim T2 Pgens cap',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { UCBC, 'UnitCapCheckGreater', { 0.95 } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 50.0 } }, -- relative income
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.TECH2 * categories.ENERGYPRODUCTION - categories.HYDROCARBON }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.TECH2 * categories.ENERGYPRODUCTION - categories.HYDROCARBON},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U1 Reclaim E storage cap',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { UCBC, 'UnitCapCheckGreater', { 0.95 } },
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.STRUCTURE * categories.ENERGYSTORAGE }},
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.ENERGYSTORAGE},
        },
        BuilderType = 'Any',
    },
}
