local categories = categories
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

-- ===================================================-======================================================== --
-- ==                                 Economic Experimental (Paragon etc)                                    == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U4 Economic Experimental Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U4 Paragon 1st mass40',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 2000,
        DelayEqualBuildPlattons = {'Paragon', 60},
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 2000
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Paragon' }},
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            --{ MIBC, 'HasNotParagon', {} },
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'CanBuildCategory', { categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*20 } },
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AdjacencyDistance = 120,
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
        BuilderName = 'U4 Paragon 1st 35min',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 2000,
        DelayEqualBuildPlattons = {'Paragon', 60},
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 2000
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Paragon' }},
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            --{ MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'CanBuildCategory', { categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*35 } },
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AdjacencyDistance = 120,
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
        BuilderName = 'U4 Paragon 1st HighTrend',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 2000,
        DelayEqualBuildPlattons = {'Paragon', 60},
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 0
            else
                return 2000
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Paragon' }},
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            --{ MIBC, 'HasNotParagon', {} },
            { EBC, 'GreaterThanEconTrend', { 60.0, 900.0 } },                      -- relative income
            -- When do we want to build this ?
            { UCBC, 'CanBuildCategory', { categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AdjacencyDistance = 120,
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
        BuilderName = 'U4 Paragon 2nd',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 2000,
        DelayEqualBuildPlattons = {'Paragon', 60},
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 2000
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Paragon' }},
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            --{ MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC}},
            { UCBC, 'CanBuildCategory', { categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AdjacencyDistance = 120,
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
        BuilderName = 'U4 Paragon 3nd',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 2000,
        DelayEqualBuildPlattons = {'Paragon', 60},
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.HasParagon then
                return 2000
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Paragon' }},
            -- Have we the eco to build it ?
            --{ MIBC, 'HasParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'CanBuildCategory', { categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AdjacencyDistance = 200,
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
