local categories = categories
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'

local MaxCapStructure = 0.12                                                    -- 12% of all units can be structures (STRUCTURE -MASSEXTRACTION -DEFENSE -FACTORY)

-- ===================================================-======================================================== --
-- ==                                         Build Hive+Kennel                                              == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U2 Hive+Kennel',                                        -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U2 EngineerSupport',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 16950,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1, 3 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 6, categories.STATIONASSISTPOD }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.FACTORY,
                BuildClose = true,
                AvoidCategory = categories.STATIONASSISTPOD,
                maxUnits = 0,
                maxRadius = 35,
                BuildStructures = {
                    'T2EngineerSupport',
                },
            }
        }
    },
}
-- ===================================================-======================================================== --
-- ==                                        Upgrade Hive+Kennel                                             == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U23 Hive+Kennel Upgrade',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U2 Kennel Upgrade',
        PlatoonTemplate = 'U2KennelUpgrade',
        Priority = 1000,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.ENGINEERSTATION }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Hive Upgrade',
        PlatoonTemplate = 'U2HiveUpgrade',
        Priority = 1000,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 3 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.ENGINEERSTATION }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U3 Hive Upgrade',
        PlatoonTemplate = 'U3HiveUpgrade',
        Priority = 1000,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 3 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.ENGINEERSTATION }},
        },
        BuilderType = 'Any',
    },
}
