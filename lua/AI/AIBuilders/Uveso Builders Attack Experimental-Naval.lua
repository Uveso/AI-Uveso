local IBC = '/lua/editor/InstantBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local SIBC = '/lua/editor/SorianInstantBuildConditions.lua'
local SBC = '/lua/editor/SorianBuildConditions.lua'

local ExperimentalCount = 3
local mapSizeX, mapSizeZ = GetMapSize()
local BaseMilitaryZone = math.max( mapSizeX-50, mapSizeZ-50 ) / 2 -- Half the map
local BasePanicZone = BaseMilitaryZone / 2
BasePanicZone = math.max( 60, BasePanicZone )
BasePanicZone = math.min( 120, BasePanicZone )
BaseMilitaryZone = math.max( 250, BaseMilitaryZone )

-- ===================================================-======================================================== --
-- ==                                 Mobile Experimental Land/Air/Sea                                       == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Mobile Experimental Builder Naval Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U4 NavalExp1 Minimum',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 160,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*20 } },
            -- When do we want to build this ?
            { EBC, 'GreaterThanEconIncome', { 7.0, 1000.0 }},
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.95 } }, -- Ratio from 0 to 1. (1=100%)
            -- Do we need additional conditions to build it ?
            { SBC, 'IsWaterMap', { true } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.MOBILE * categories.EXPERIMENTAL }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = false,
--                AdjacencyCategory = 'SHIELD STRUCTURE',
                BuildStructures = {
                    'T4SeaExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U4 SeaExperimental1',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 150,
        InstanceCount = 3,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.MOBILE * categories.LAND * categories.EXPERIMENTAL }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, 'ENGINEER TECH3' }},
            { SBC, 'IsWaterMap', { true } },
            { UCBC, 'CanBuildCategory', { categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 1.00, 1.00 }}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = false,
--                AdjacencyCategory = 'SHIELD STRUCTURE',
                BuildStructures = {
                    'T4SeaExperimental1',
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
    BuilderGroupName = 'ExperimentalAttackFormBuildersNaval Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    -- ================== --
    --    BasePanicZone    --
    -- ================== --
    -- ======================= --
    --    BaseMilitaryZone    --
    -- ======================= --
    -- =============== --
    --    EnemyZone    --
    -- =============== --
    -- ================= --
    --    Finish him!    --
    -- ================= --
    Builder {
        BuilderName = 'U123 Experimental Sea 1 1',
        PlatoonTemplate = 'U4-ExperimentalSea 1 1',
        Priority = 1,
        InstanceCount = 10,
        BuilderData = {
            SearchRadius = 10000,                               -- Searchradius for new target.
            AggressiveMove = true,                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 10000,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE + categories.STRUCTURE, -- Only find targets matching these categories.
            PrioritizedCategories = {
                'STRUCTURE',
                'MOBILE',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , 'MOBILE, STRUCTURE' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },

}
