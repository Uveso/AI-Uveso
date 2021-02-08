local categories = categories
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'
local NoRushRadius = ScenarioInfo.norushradius or 30

local MaxCapStructure = 0.12                                                    -- 12% of all units can be structures (STRUCTURE -MASSEXTRACTION -DEFENSE -FACTORY)

-- ===================================================-======================================================== --
-- ==                                       Build Power TECH 1,2,3                                           == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U123 Energy Builders RUSH',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U1R Power <90%',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17900,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 then
                return 17900
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'LessThanEconStorageRatio', { 1.00, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.MASSEXTRACTION }},
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
        BuilderName = 'UCR Power <90%',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 17900,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 then
                return 17900
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'LessThanEconStorageRatio', { 1.00, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.MASSEXTRACTION }},
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
        BuilderName = 'U1R Power low trend',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17899,
        InstanceCount = 2,                                                      -- Number of plattons that will be formed with this template.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 then
                return 17899
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'LessThanEnergyTrend', { 0.0 } },
            { EBC, 'GreaterThanEconIncome',  { 0.3, 0.0}}, -- Absolut Base income
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*2 } },
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
        BuilderName = 'UCR Power low trend',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 17900,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 then
                return 17900
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'LessThanEnergyTrend', { 0.0 } },
            { EBC, 'GreaterThanEconIncome',  { 0.2, 0.0}}, -- Absolut Base income
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
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2R  Power low trend',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 17000,
        DelayEqualBuildPlattons = {'Energy', 20},
        InstanceCount = 2,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech2 then
                return 17000
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { EBC, 'LessThanEnergyTrend', { 0.0 } },
            { EBC, 'GreaterThanEconIncome',  { 0.2, 0.0}}, -- Absolut Base income
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * ( categories.TECH2 + categories.TECH3 ) }},
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
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3R Power Emergency',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 17200,
        DelayEqualBuildPlattons = {'Energy', 5},
        InstanceCount = 3,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech3 then
                return 17200
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { EBC, 'LessThanEconStorageRatio', { 2.00, 0.90}}, -- Ratio from 0 to 1. (1=100%)
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
                    'T3ShieldDefense',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U3R  Power low trend',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 17300,
        DelayEqualBuildPlattons = {'Energy', 5},
        InstanceCount = 2,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech3 then
                return 17300
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
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
                    'T3ShieldDefense',
                },
            }
        }
    },

}

BuilderGroup {
    BuilderGroupName = 'U123 Energy Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U1 Power <90%',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17900,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 then
                return 17900
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'LessThanEconStorageRatio', { 1.00, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.MASSEXTRACTION }},
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
        BuilderName = 'UC Power <90%',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 17900,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 then
                return 17900
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'LessThanEconStorageRatio', { 1.00, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.MASSEXTRACTION }},
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
        BuilderName = 'U1 Power low trend',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17899,
        InstanceCount = 2,                                                      -- Number of plattons that will be formed with this template.
        DelayEqualBuildPlattons = {'Energy', 3},
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 then
                return 17899
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'LessThanEnergyTrend', { 0.0 } },
            { EBC, 'GreaterThanEconIncome',  { 0.3, 0.0}}, -- Absolut Base income
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*2 } },
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 then
                return 17900
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'LessThanEnergyTrend', { 0.0 } },
            { EBC, 'GreaterThanEconIncome',  { 0.2, 0.0}}, -- Absolut Base income
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
        BuilderName = 'UC Power MassRatio 10',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 17879,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 then
                return 17879
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'EnergyToMassRatioIncome', { 10.0, '<=' } },  -- True if we have less than 10 times more Energy then Mass income ( 100 <= 10 = true )
            { EBC, 'GreaterThanEconIncome',  { 0.6, 0.0}}, -- Absolut Base income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
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
                    'T1EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Power MassRatio 5',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17881,
        InstanceCount = 3,                                                      -- Number of plattons that will be formed with this template.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 then
                return 17881
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            { EBC, 'EnergyToMassRatioIncome', { 5.0, '<=' } },  -- True if we have less than 10 times more Energy then Mass income ( 100 <= 10 = true )
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
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
                    'T1EnergyProduction',
                    'T1EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Power MassRatio 10',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17883,
        InstanceCount = 2,                                                      -- Number of plattons that will be formed with this template.
        DelayEqualBuildPlattons = {'Energy', 3},
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 then
                return 17883
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { EBC, 'EnergyToMassRatioIncome', { 10.0, '<=' } },  -- True if we have less than 10 times more Energy then Mass income ( 100 <= 10 = true )
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 120 } },
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD }},
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
                    'T1EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'U1 Power MassRatio 15',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17885,
        InstanceCount = 1,                                                      -- Number of plattons that will be formed with this template.
        DelayEqualBuildPlattons = {'Energy', 3},
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 then
                return 17885
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { EBC, 'EnergyToMassRatioIncome', { 15.0, '<=' } },  -- True if we have less than 10 times more Energy then Mass income ( 100 <= 10 = true )
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 180 } },
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
        Priority = 17895,
        DelayEqualBuildPlattons = {'Energy', 1},
        InstanceCount = 1,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 and not aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 17895
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 0.4, 2.0}}, -- Absolut Base income 4 60
            -- When do we want to build this ?
            { MABC, 'CanBuildOnHydro', { 'LocationType', 90, -1000, 100, 1, 'AntiSurface', 1 }},            -- Do we need additional conditions to build it ?
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
        BuilderName = 'U1 Power Hydrocarbon NoRush',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17895,
        DelayEqualBuildPlattons = {'Energy', 1},
        InstanceCount = 1,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 17895
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 0.4, 2.0}}, -- Absolut Base income 4 60
            -- When do we want to build this ?
            { MABC, 'CanBuildOnHydro', { 'LocationType', NoRushRadius, -1000, 100, 1, 'AntiSurface', 1 }},            -- Do we need additional conditions to build it ?
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 then
                return 19200
            else
                return 0
            end
        end,
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 then
                return 19200
            else
                return 0
            end
        end,
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech2 then
                return 17000
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, -0.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * ( categories.TECH2 + categories.TECH3 ) }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.ENERGYPRODUCTION * ( categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL ) } },            -- Respect UnitCap
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech2 then
                return 16900
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { EBC, 'LessThanEnergyTrend', { 100.0 } },
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, -0.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * ( categories.TECH2 + categories.TECH3 ) }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH2 - categories.STATIONASSISTPOD }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * ( categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL ) } },
            { MIBC, 'HasNotParagon', {} },
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech3 then
                return 17300
            else
                return 0
            end
        end,
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
                    'T3ShieldDefense',
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech3 then
                return 17200
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { EBC, 'LessThanEconStorageRatio', { 2.00, 0.90}}, -- Ratio from 0 to 1. (1=100%)
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
                    'T3ShieldDefense',
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech3 then
                return 17100
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
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
                    'T3ShieldDefense',
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech3 then
                return 17000
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
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
                    'T3ShieldDefense',
                },
            }
        }
    },
}
-- ===================================================-======================================================== --
-- ==                                        Build EnergyStorage                                             == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U123 EnergyStorage Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U1 Energy Storage RECOVER no ACU',
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 17750
            end
        end,
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 17750
            end
        end,
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
            { UCBC, 'HaveLessThanUnitsWithCategory', { 12, categories.STRUCTURE * categories.ENERGYSTORAGE }},
            { UCBC, 'HaveUnitRatioUveso', { 1.0, categories.STRUCTURE * categories.ENERGYSTORAGE, '<', categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
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
}
-- ===================================================-======================================================== --
-- ==                                      Reclaim Energy Buildings                                          == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U123 Reclaim Energy Buildings',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U1 Reclaim T1 Pgens',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 then
                return 0
            else
                return 790
            end
        end,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.00, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.TECH1 * categories.ENERGYPRODUCTION - categories.HYDROCARBON }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * ( categories.TECH2 + categories.TECH3 )}},
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.TECH1 * categories.ENERGYPRODUCTION - categories.HYDROCARBON},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Reclaim T1 Pgens',
        PlatoonTemplate = 'T2EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 then
                return 0
            else
                return 790
            end
        end,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.00, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.TECH1 * categories.ENERGYPRODUCTION - categories.HYDROCARBON }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * ( categories.TECH2 + categories.TECH3 )}},
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech1 then
                return 0
            else
                return 790
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { UCBC, 'UnitCapCheckGreater', { 0.95 } },
            { EBC, 'GreaterThanEconStorageRatio', { 0.00, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.TECH1 * categories.ENERGYPRODUCTION - categories.HYDROCARBON }},
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech2 then
                return 0
            else
                return 790
            end
        end,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.00, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.TECH2 * categories.ENERGYPRODUCTION - categories.HYDROCARBON }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * ( categories.TECH3 + categories.EXPERIMENTAL )}},
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NeedEnergyTech2 then
                return 0
            else
                return 790
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { UCBC, 'UnitCapCheckGreater', { 0.95 } },
            { EBC, 'GreaterThanEconStorageRatio', { 0.00, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.TECH2 * categories.ENERGYPRODUCTION - categories.HYDROCARBON }},
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
            { UCBC, 'UnitCapCheckGreater', { 0.99 } },
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
