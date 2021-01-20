local categories = categories
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

-- ===================================================-======================================================== --
-- ==                                             Assistees                                                  == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'UC123 Assistees',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    -- =============== --
    --    Factories    --
    -- =============== --
    Builder {
        BuilderName = 'U1 Assist 1st T2 Factory Upgrade',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 200,
        InstanceCount = 20,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.80}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD } },
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH2 , categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * ( categories.TECH2 + categories.TECH3 ) } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 80,
                BeingBuiltCategories = {'STRUCTURE LAND FACTORY TECH2'},        -- Unitcategories must be type string
                AssistUntilFinished = true,
                PermanentAssist = true,
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
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.80}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD } },
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 , categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH2 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 80,
                BeingBuiltCategories = {'STRUCTURE LAND FACTORY TECH3'},        -- Unitcategories must be type string
                AssistUntilFinished = true,
                PermanentAssist = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U2 Assist 1st T3 Factory Upgrade',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 200,
        InstanceCount = 10,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.80}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 , categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH2 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 80,
                BeingBuiltCategories = {'STRUCTURE LAND FACTORY TECH3'},        -- Unitcategories must be type string
                AssistUntilFinished = true,
                PermanentAssist = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U2 Assist Factory Upgrade',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 200,
        InstanceCount = 20,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.80}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.FACTORY}},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 80,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRUCTURE FACTORY'},                   -- Unitcategories must be type string
                AssistUntilFinished = true,
                PermanentAssist = true,
                Time = 0,
            },
        }
    },
    -- Permanent assist
    Builder {
        BuilderName = 'T2 Gate Assist',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 900,
        InstanceCount = 10,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, categories.SUBCOMMANDER } },
        },
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssistRange = 120,
                AssisteeType = 'Factory',
                BeingBuiltCategories = {'SUBCOMMANDER'},
                PermanentAssist = true,
                AssistClosestUnit = false,                                       -- Assist the closest unit instead unit with the least number of assisters
                AssistUntilFinished = true,
                Time = 0,
            },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'T1 Assist Factory unit build',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 600,
        InstanceCount = 10,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.80}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*15 } },
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, categories.MOBILE - categories.SUBCOMMANDER } },
        },
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 120,
                BeingBuiltCategories = {'MOBILE INDIRECTFIRE, MOBILE DIRECTFIRE, MOBILE ANTIAIR'},                   -- Unitcategories must be type string
                AssistClosestUnit = false,                                       -- Assist the closest unit instead unit with the least number of assisters
                AssistUntilFinished = true,
                Time = 0,
            },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'T2 Assist Factory unit build',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 600,
        InstanceCount = 10,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.80}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*15 } },
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, categories.MOBILE - categories.SUBCOMMANDER } },
        },
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 120,
                BeingBuiltCategories = {'MOBILE INDIRECTFIRE, MOBILE DIRECTFIRE, MOBILE ANTIAIR'},                   -- Unitcategories must be type string
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                AssistUntilFinished = true,
                Time = 0,
            },
        },
        BuilderType = 'Any',
    },

    -- ============ --
    --    ENERGY    --
    -- ============ --
    Builder {
        BuilderName = 'UC Assist Energy',
        PlatoonTemplate = 'CommanderAssist',
        Priority = 17900,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.25}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 30,
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},-- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'UC Assist Hydro',
        PlatoonTemplate = 'CommanderAssist',
        Priority = 19100,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.HYDROCARBON }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 50,
                BeingBuiltCategories = {'STRUCTURE HYDROCARBON'},-- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U1 Assist Energy Turbo',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 200,
        InstanceCount = 15,
        BuilderConditions = {
             -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.25}}, -- Ratio from 0 to 1. (1=100%)
           -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD } },
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 80,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},-- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U2 Assist Energy Turbo',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 200,
        InstanceCount = 10,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.25}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH2 - categories.STATIONASSISTPOD } },
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 80,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},-- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U3 Assist Energy Turbo',
        PlatoonTemplate = 'T3EngineerAssistNoSUB',
        Priority = 200,
        InstanceCount = 5,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.25}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD } },
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 80,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},-- Unitcategories must be type string
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
        Priority = 500,
        InstanceCount = 5,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome', { 20.0, 100.0 }},                    -- Base income
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuilt', { 0, categories.STRUCTURE * categories.ECONOMIC * categories.EXPERIMENTAL }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 120,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},               -- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U2 Assist PARA',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 500,
        InstanceCount = 5,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome', { 30.0, 100.0 }},                    -- Base income
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuilt', { 0, categories.STRUCTURE * categories.ECONOMIC * categories.EXPERIMENTAL }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 120,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},               -- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U3 Assist PARA',
        PlatoonTemplate = 'T3EngineerAssistNoSUB',
        Priority = 500,
        InstanceCount = 5,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome', { 40.0, 100.0 }},                    -- Base income
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuilt', { 0, categories.STRUCTURE * categories.ECONOMIC * categories.EXPERIMENTAL }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 120,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},               -- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U1 Assist PARA+',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 500,
        InstanceCount = 10,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ECONOMIC * categories.EXPERIMENTAL}},
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuilt', { 0, categories.STRUCTURE * categories.ECONOMIC * categories.EXPERIMENTAL }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 120,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},               -- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U2 Assist PARA+',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 500,
        InstanceCount = 10,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ECONOMIC * categories.EXPERIMENTAL}},
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuilt', { 0, categories.STRUCTURE * categories.ECONOMIC * categories.EXPERIMENTAL }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 120,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},               -- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U3 Assist PARA+',
        PlatoonTemplate = 'T3EngineerAssist',
        Priority = 500,
        InstanceCount = 10,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ECONOMIC * categories.EXPERIMENTAL}},
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuilt', { 0, categories.STRUCTURE * categories.ECONOMIC * categories.EXPERIMENTAL }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 120,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},               -- Unitcategories must be type string
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
        InstanceCount = 50,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.80}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD } },
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 100,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'EXPERIMENTAL'},                        -- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U2 Assist Experimental',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 200,
        InstanceCount = 50,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.80}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH2 - categories.STATIONASSISTPOD } },
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL * (categories.ECONOMIC + categories.SHIELD + categories.MOBILE ) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 100,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC, EXPERIMENTAL SHIELD, EXPERIMENTAL MOBILE'},-- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder {
        BuilderName = 'U3 Assist Experimental',
        PlatoonTemplate = 'T3EngineerAssistNoSUB',
        Priority = 200,
        InstanceCount = 15,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.80}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD } },
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL * (categories.ECONOMIC + categories.SHIELD + categories.MOBILE ) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 100,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC, EXPERIMENTAL SHIELD, EXPERIMENTAL MOBILE'},-- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },

    -- ================ --
    --    Artillery     --
    -- ================ --
    Builder {
        BuilderName = 'U1 Assist Arty',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 200,
        InstanceCount = 10,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.80}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD } },
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.ARTILLERY }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'STRUCTURE ARTILLERY'},                    -- Unitcategories must be type string
                AssisteeType = 'Structure',
                AssistRange = 100,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
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
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.80}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD } },
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.SHIELD }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'STRUCTURE SHIELD'},                    -- Unitcategories must be type string
                AssisteeType = 'Structure',
                AssistRange = 100,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    -- =================== --
    --    General Assist   --
    -- =================== --
    Builder {
        BuilderName = 'U1 Engineer Assist Engineer',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 1,
        InstanceCount = 50,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingAssistanceGreater', { 'LocationType', 0, categories.ALLUNITS } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.80}}, -- Ratio from 0 to 1. (1=100%)
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'ALLUNITS'},                    -- Unitcategories must be type string
                PermanentAssist = false,
                AssisteeType = 'Engineer',
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                Time = 30,
            },
        }
    },
    Builder {
        BuilderName = 'U2 Engineer Assist Engineer',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 1,
        InstanceCount = 50,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingAssistanceGreater', { 'LocationType', 0, categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.80}}, -- Ratio from 0 to 1. (1=100%)
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'TECH2', 'TECH3', 'EXPERIMENTAL'},               -- Unitcategories must be type string
                PermanentAssist = false,
                AssisteeType = 'Engineer',
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                Time = 30,
            },
        }
    },
    Builder {
        BuilderName = 'U3 Engineer Assist Engineer',
        PlatoonTemplate = 'T3EngineerAssistNoSUB',
        Priority = 1,
        InstanceCount = 50,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingAssistanceGreater', { 'LocationType', 0, categories.TECH3 + categories.EXPERIMENTAL } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.80}}, -- Ratio from 0 to 1. (1=100%)
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                BeingBuiltCategories = {'TECH3', 'EXPERIMENTAL'},               -- Unitcategories must be type string
                AssistLocation = 'LocationType',
                PermanentAssist = false,
                AssisteeType = 'Engineer',
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                Time = 30,
            },
        }
    },

    -- =============== --
    --    Finisher     --
    -- =============== --
    Builder {
        BuilderName = 'U1 Finisher',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'FinisherAI',
        Priority = 50,
        InstanceCount = 4,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD } },
            { UCBC, 'UnfinishedUnitsAtLocation', { 'LocationType' }},
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Finisher',
        PlatoonTemplate = 'T2EngineerBuilder',
        PlatoonAIPlan = 'FinisherAI',
        Priority = 50,
        InstanceCount = 4,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH2 - categories.STATIONASSISTPOD } },
            { UCBC, 'UnfinishedUnitsAtLocation', { 'LocationType' }},
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U3 Finisher',
        PlatoonTemplate = 'T3EngineerBuilder',
        PlatoonAIPlan = 'FinisherAI',
        Priority = 50,
        InstanceCount = 2,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD } },
            { UCBC, 'UnfinishedUnitsAtLocation', { 'LocationType' }},
        },
        BuilderData = {
            LocationType = 'LocationType',
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
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD } },
            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},
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
        InstanceCount = 3,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH2 - categories.STATIONASSISTPOD } },
            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},
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
    BuilderGroupName = 'U1 Engineer Reclaim',                                -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U1 Reclaim RECOVER mass',
        PlatoonTemplate = 'U1Reclaim',
        Priority = 19600,
        InstanceCount = 1,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 19600
            end
        end,
        BuilderConditions = {
            --{ MIBC, 'HasNotParagon', {} },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.COMMAND }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U1 Reclaim RECOVER energy',
        PlatoonTemplate = 'U1Reclaim',
        Priority = 19500,
        InstanceCount = 1,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 19500
            end
        end,
        BuilderConditions = {
            --{ MIBC, 'HasNotParagon', {} },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.COMMAND }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION } },
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U1 Reclaim Resource 1',
        PlatoonTemplate = 'U1Reclaim',
        Priority = 18000,
        InstanceCount = 1,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 18000
            end
        end,
        BuilderConditions = {
            --{ MIBC, 'HasNotParagon', {} },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 8, categories.MOBILE * categories.ENGINEER - categories.STATIONASSISTPOD}},
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
        InstanceCount = 1,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 17400
            end
        end,
        BuilderConditions = {
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            --{ MIBC, 'HasNotParagon', {} },
            -- Have we the eco to build it ?
            { EBC, 'LessThanEconStorageRatio', { 0.80, 2.00}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 11, categories.MOBILE * categories.ENGINEER - categories.STATIONASSISTPOD}},
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U1 Reclaim Resource 3',
        PlatoonTemplate = 'U1Reclaim',
        Priority = 17400,
        InstanceCount = 2,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 17400
            end
        end,
        BuilderConditions = {
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            --{ MIBC, 'HasNotParagon', {} },
            -- Have we the eco to build it ?
            { EBC, 'LessThanEconStorageRatio', { 0.80, 2.00}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.ENGINEER * categories.TECH2 - categories.STATIONASSISTPOD}},
            -- Don't build it if...
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
        InstanceCount = 6,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 17400
            end
        end,
        BuilderConditions = {
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            --{ MIBC, 'HasNotParagon', {} },
            -- Have we the eco to build it ?
            { EBC, 'LessThanEconStorageRatio', { 0.80, 2.00}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD}},
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
}

