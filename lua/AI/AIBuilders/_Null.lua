local categories = categories
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua').GetDangerZoneRadii()

local MaxCapEngineers = 0.15 -- 15% of all units can be Engineers (categories.MOBILE * categories.ENGINEER)
local MaxCapFactory = 0.024 -- 2.4% of all units can be factories (STRUCTURE * FACTORY)

-- ===================================================-======================================================== --
-- ==                                 Build Engineers TECH 1,2,3 and SACU                                    == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'N1 Factory Builders',                             -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'NC Land Factory',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Factories', 5},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'N1 Land Factory Mass > 50%',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 1000,
        InstanceCount = 1,                                                      -- Number of plattons that will be formed with this template.
        DelayEqualBuildPlattons = {'Factories', 5},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
            -- Do we need additional conditions to build it ?
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapFactory , '<', categories.STRUCTURE * categories.FACTORY * categories.LAND } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                BuildClose = false,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'N1 Air Factory Mass > 50%',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17880,
        DelayEqualBuildPlattons = {'Factories', 5},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.FACTORY * categories.LAND } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveUnitRatioUveso', { 1.0, categories.STRUCTURE * categories.FACTORY * categories.AIR, '<',categories.STRUCTURE * categories.FACTORY * categories.LAND } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapFactory , '<', categories.STRUCTURE * categories.FACTORY * categories.AIR } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },

}

BuilderGroup {
    BuilderGroupName = 'N1 Engineer Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'N1 Engineer builder',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 10,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 4, categories.MOBILE * categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.ENGINEER * categories.TECH1 } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapEngineers / 3 , '<', categories.MOBILE * categories.ENGINEER * categories.TECH1 } },
         },
        BuilderType = 'All',
    },
    Builder {
        BuilderName = 'N2 Engineer builder',
        PlatoonTemplate = 'T2BuildEngineer',
        Priority = 10,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.MOBILE * categories.ENGINEER * categories.TECH2 - categories.STATIONASSISTPOD } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.ENGINEER * categories.TECH1 } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapEngineers / 3 , '<', categories.MOBILE * categories.ENGINEER * categories.TECH1 } },
         },
        BuilderType = 'All',
    },
    Builder {
        BuilderName = 'N3 Engineer builder',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 10,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.MOBILE * categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.ENGINEER * categories.TECH1 } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapEngineers / 3 , '<', categories.MOBILE * categories.ENGINEER * categories.TECH1 } },
         },
        BuilderType = 'All',
    },
}

BuilderGroup {
    -- Build Power TECH 1,2,3
    BuilderGroupName = 'N1 Energy Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'N1 Power <90%',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 1000,
        InstanceCount = 5,                                                      -- Number of plattons that will be formed with this template.
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'LessThanEconStorageRatio', { 1.00, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
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
        BuilderName = 'N1 Power Low Trend',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 1000,
        InstanceCount = 5,                                                      -- Number of plattons that will be formed with this template.
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'LessThanEnergyTrend', { 50.0 } },
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD }},
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
        BuilderName = 'N2 Power minimum',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 17000,
        InstanceCount = 5,                                                      -- Number of plattons that will be formed with this template.
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
        BuilderName = 'N3 Power minimum',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 17300,
        DelayEqualBuildPlattons = {'Energy', 5},
        InstanceCount = 5,                                                      -- Number of plattons that will be formed with this template.
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
}

BuilderGroup {
    -- Build MassExtractors / Creators 
    BuilderGroupName = 'N1 MassBuilders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'N Mass',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 900,
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 1000, -500, 50, 1, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD }},
            -- Have we the eco to build it ?
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
}

BuilderGroup {
    -- Build MassExtractors / Creators 
    BuilderGroupName = 'N1 Transporter',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'N1 Air Transport 1st',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 18500, 
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - (categories.uea0203 + categories.EXPERIMENTAL) }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
}


BuilderGroup {
    BuilderGroupName = 'N1 Land Builders',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'U1N Tank',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 150,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH1 }},
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1N Bot',
        PlatoonTemplate = 'T1LandDFBot',
        Priority = 150,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * categories.BOT }},
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1N Mobile Artillery',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 150,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * categories.INDIRECTFIRE }},
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1N Mobile AA',
        PlatoonTemplate = 'T1LandAA',
        Priority = 150,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * categories.ANTIAIR }},
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
}

BuilderGroup {
    BuilderGroupName = 'N2 Land Builders',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'U2N Tank',
        PlatoonTemplate = 'T2LandDFTank',
        Priority = 150,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH1 }},
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2N Mobile AA',
        PlatoonTemplate = 'T2LandAA',
        Priority = 150,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * categories.ANTIAIR }},
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2N Mobile Shiled',
        PlatoonTemplate = 'T2MobileShields',
        Priority = 150,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, (categories.MOBILE * categories.SHIELD) + (categories.MOBILE * categories.STEALTHFIELD) }},
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
}

BuilderGroup {
    BuilderGroupName = 'N3 Land Builders',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'U3N Bot',
        PlatoonTemplate = 'T3LandBot',
        Priority = 150,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * categories.BOT }},
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3N Mobile AA',
        PlatoonTemplate = 'T3LandAA',
        Priority = 150,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * categories.ANTIAIR }},
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3N Mobile Shiled',
        PlatoonTemplate = 'T3MobileShields',
        Priority = 150,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, (categories.MOBILE * categories.SHIELD) + (categories.MOBILE * categories.STEALTHFIELD) }},
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
}

BuilderGroup {
    BuilderGroupName = 'N123 Land Formers',                              -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U123N Land Attack',                                -- Random Builder Name.
        PlatoonTemplate = 'U1234-Trash Land 1 50',                            -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 110,                                                         -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 10000,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS - categories.AIR , -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MASSEXTRACTION,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.DEFENSE - categories.ANTIAIR,
                categories.DEFENSE,
                categories.MASSEXTRACTION,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
             -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 2, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}

BuilderGroup {
    BuilderGroupName = 'N1 Hydro Energy Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'N1 Hydro Power',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17895,
        DelayEqualBuildPlattons = {'Energy', 10},
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 0.4, 2.0}}, -- Absolut Base income 4 60
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ECONOMIC * categories.HYDROCARBON }},
            -- When do we want to build this ?
            { MABC, 'CanBuildOnHydro', { 'LocationType', 90, -1000, 100, 1, 'AntiSurface', 1 }},            -- Do we need additional conditions to build it ?
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
}

BuilderGroup {
	BuilderGroupName = 'N1 Hydro UP',
	BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'N1 HydroUpgrade',
        PlatoonTemplate = 'Upgrade-HC1',
        Priority = 200,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.HYDROCARBON * categories.ENERGYPRODUCTION * categories.TECH1 } },
        },
        FormRadius = 10000,
        BuilderType = 'Any',
    },

	Builder {
		BuilderName = 'Upgrade-HydroT2PGen',
		PlatoonTemplate = 'Upgrade-HC1',
		Priority = 19000,
		BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.HYDROCARBON * categories.ENERGYPRODUCTION * categories.TECH1 } },
		},
		FormRadius = 10000,
		BuilderType = 'Any',
	},
	Builder {
		BuilderName = 'Upgrade-HydroT3PGen',
		PlatoonTemplate = 'Upgrade-HC2',
		Priority = 19000,
		BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.HYDROCARBON * categories.ENERGYPRODUCTION * categories.TECH2 } },
		},
		FormRadius = 10000,
		BuilderType = 'Any',
	},
	Builder {
		BuilderName = 'Upgrade-HydroT4PGen',
		PlatoonTemplate = 'Upgrade-HC3',
		Priority = 19000,
		BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.HYDROCARBON * categories.ENERGYPRODUCTION * categories.TECH3 } },
		},
		FormRadius = 10000,
		BuilderType = 'Any',
	},
}
