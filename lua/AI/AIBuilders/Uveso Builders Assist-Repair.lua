local IBC = '/lua/editor/InstantBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'

-- ===================================================-======================================================== --
-- ==                                             Assistees                                                  == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Assistees Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    -- =============== --
    --    Factories    --
    -- =============== --
    Builder {
        BuilderName = 'U1 Assist 1st T2 Factory Upgrade',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 200,
        InstanceCount = 20,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH2 , categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * ( categories.TECH2 + categories.TECH3 ) } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00}}, -- Ratio from 0 to 1. (1=100%)
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 50,
                BeingBuiltCategories = {'STRUCTURE LAND FACTORY TECH2'},
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U1 Assist 1st T3 Factory Upgrade',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 200,
        InstanceCount = 20,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 , categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH2 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00}}, -- Ratio from 0 to 1. (1=100%)
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 50,
                BeingBuiltCategories = {'STRUCTURE LAND FACTORY TECH3'},
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U2 Assist 1st T3 Factory Upgrade',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 200,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 , categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH2 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH2 } },
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00}}, -- Ratio from 0 to 1. (1=100%)
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 50,
                BeingBuiltCategories = {'STRUCTURE LAND FACTORY TECH3'},
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    -- ============ --
    --    ENERGY    --
    -- ============ --
    Builder {
        BuilderName = 'UC Assist Energy',
        PlatoonTemplate = 'CommanderAssist',
        Priority = 16300,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) , categories.ENGINEER * categories.MOBILE }},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'LessThanEconStorageRatio', { 0.35, 0.05}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 40,
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U1 Assist Energy Turbo',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 200,
        InstanceCount = 10,
        DelayEqualBuildPlattons = {'Assist Energy', 5},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) , categories.ENGINEER * categories.MOBILE }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 1.00}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Assist Energy' }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 30,
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U2 Assist Energy Turbo',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 200,
        DelayEqualBuildPlattons = {'Assist Energy', 5},
        InstanceCount = 5,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) , categories.ENGINEER * categories.MOBILE }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH2 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.70, -0.00}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Assist Energy' }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 30,
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U3 Assist Energy Turbo',
        PlatoonTemplate = 'T3EngineerAssist',
        Priority = 200,
        DelayEqualBuildPlattons = {'Assist Energy', 5},
        InstanceCount = 5,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) , categories.ENGINEER * categories.MOBILE }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH3 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.90, -0.00}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Assist Energy' }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 30,
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    -- =================== --
    --    Experimentals    --
    -- =================== --
    Builder {
        BuilderName = 'U1 Assist Experimental',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 1,
        DelayEqualBuildPlattons = {'Assist Experimental TECH1', 1},
        InstanceCount = 30,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL, categories.ENGINEER * categories.MOBILE }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 1.0, 10.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 1.00, 1.00}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Assist Experimental TECH1' }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 80,
                BeingBuiltCategories = {'EXPERIMENTAL'},
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U-T2 Assist Experimental',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 200,
        DelayEqualBuildPlattons = {'Assist Experimental TECH2', 1},
        InstanceCount = 50,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL, categories.ENGINEER * categories.MOBILE }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH2 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 0.95}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Assist Experimental TECH2' }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 80,
                BeingBuiltCategories = {'EXPERIMENTAL'},
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U-T3 Assist Experimental',
        PlatoonTemplate = 'T3EngineerAssist',
        Priority = 100,
        DelayEqualBuildPlattons = {'Assist Experimental TECH3', 1},
        InstanceCount = 50,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL, categories.ENGINEER * categories.MOBILE }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH3 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 1.0, 10.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.80, 0.95}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Assist Experimental TECH3' }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 80,
                BeingBuiltCategories = {'EXPERIMENTAL'},
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    -- ============ --
    --    Paragon   --
    -- ============ --
    Builder {
        BuilderName = 'U1 Assist PARA',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 200,
        DelayEqualBuildPlattons = {'AssistParagon', 15},
        InstanceCount = 10,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuilt', { 0, categories.STRUCTURE * categories.ECONOMIC * categories.EXPERIMENTAL }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 1.00}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'AssistParagon' }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 80,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U2 Assist PARA',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 200,
        DelayEqualBuildPlattons = {'AssistParagon', 15},
        InstanceCount = 10,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuilt', { 0, categories.STRUCTURE * categories.ECONOMIC * categories.EXPERIMENTAL }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH2 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 1.00}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'AssistParagon' }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 80,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U3 Assist PARA',
        PlatoonTemplate = 'T3EngineerAssist',
        Priority = 200,
        DelayEqualBuildPlattons = {'AssistParagon', 15},
        InstanceCount = 10,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuilt', { 0, categories.STRUCTURE * categories.ECONOMIC * categories.EXPERIMENTAL }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH3 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 1.00, 1.00}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'AssistParagon' }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 80,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    -- ============== --
    --    Shields     --
    -- ============== --
    Builder {
        BuilderName = 'U1 Assist Shield',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 200,
        InstanceCount = 10,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.SHIELD, categories.STRUCTURE * categories.SHIELD }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'STRUCTURE SHIELD'},
                AssisteeType = 'Structure',
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    -- =============== --
    --    Finisher     --
    -- =============== --
    Builder {
        BuilderName = 'U1 Finisher',
        PlatoonTemplate = 'EngineerFinisher',
        Priority = 50,
        InstanceCount = 4,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnfinishedUnits', { 'LocationType', categories.STRUCTURE - categories.MASSEXTRACTION }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            -- Don't build it if...
        },
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                BeingBuiltCategories = {'STRUCTURE'},
                AssistUntilFinished = true,
                Time = 0,
            },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Finisher',
        PlatoonTemplate = 'T2EngineerFinisher',
        Priority = 50,
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnfinishedUnits', { 'LocationType', categories.STRUCTURE - categories.MASSEXTRACTION }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH2 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 1.00}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
        },
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                BeingBuiltCategories = {'STRUCTURE'},
                AssistUntilFinished = true,
                Time = 0,
            },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U3 Finisher',
        PlatoonTemplate = 'T3EngineerFinisher',
        Priority = 50,
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnfinishedUnits', { 'LocationType', categories.STRUCTURE - categories.MASSEXTRACTION }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH3 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 1.00}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
        },
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                BeingBuiltCategories = {'STRUCTURE'},
                AssistUntilFinished = true,
                Time = 0,
            },
        },
        BuilderType = 'Any',
    },
    -- =============== --
    --    Repair     --
    -- =============== --
    Builder {
        BuilderName = 'U1 Engineer Repair',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'RepairAI',
        Priority = 60,
        InstanceCount = 5,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Engineer Repair',
        PlatoonTemplate = 'T2EngineerBuilder',
        PlatoonAIPlan = 'RepairAI',
        Priority = 60,
        InstanceCount = 1,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH2 } },
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
}
-- ============== --
--    Reclaim     --
-- ============== --
BuilderGroup {
    BuilderGroupName = 'Engineer Reclaim Uveso',                                -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U1 Reclaim Resource 1',
        PlatoonTemplate = 'U1Reclaim',
        Priority = 18000,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.MOBILE * categories.ENGINEER}},
            { EBC, 'LessThanEconStorageRatio', { 0.80, 2.00}}, -- Ratio from 0 to 1. (1=100%)
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U1 Reclaim Resource 2',
        PlatoonTemplate = 'U1Reclaim',
        Priority = 17400,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.MOBILE * categories.ENGINEER}},
            { EBC, 'LessThanEconStorageRatio', { 0.80, 2.00}}, -- Ratio from 0 to 1. (1=100%)
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U1 Reclaim Resource 4',
        PlatoonTemplate = 'U1Reclaim',
        Priority = 17400,
        InstanceCount = 4,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 8, categories.MOBILE * categories.ENGINEER}},
            { EBC, 'LessThanEconStorageRatio', { 0.80, 2.00}}, -- Ratio from 0 to 1. (1=100%)
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
}

