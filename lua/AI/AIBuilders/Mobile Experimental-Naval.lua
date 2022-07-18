local categories = categories
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetDangerZoneRadii()

-- ===================================================-======================================================== --
-- ==                                 Mobile Experimental Land/Air/Sea                                       == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U4 Naval Experimental Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U4 NavalExp1 Minimum',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 160,
        DelayEqualBuildPlattons = {'MobileExperimental', 10},
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'MobileExperimental' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome', { 7.0, 600.0 }},                    -- Base income
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { MIBC, 'ItsTimeForGameender', {} },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.MOBILE * categories.EXPERIMENTAL }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = false,
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
        DelayEqualBuildPlattons = {'MobileExperimental', 10},
        InstanceCount = 3,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'MobileExperimental' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome', { 7.0, 600.0 }},                    -- Base income
            { EBC, 'GreaterThanEconStorageRatio', { 0.95, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { MIBC, 'ItsTimeForGameender', {} },
            { UCBC, 'CanBuildCategory', { categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.LAND * categories.EXPERIMENTAL }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = false,
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
-- =============== --
--    PanicZone    --
-- =============== --
BuilderGroup {
    BuilderGroupName = 'U4 Naval Experimental Formers PanicZone',                   -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U4 BasePanicZone SEA',                                   -- Random Builder Name.
        PlatoonTemplate = 'U4-ExperimentalInterceptor 1 1',                     -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        --PlatoonAddPlans = {'NameUnitsSorian'},
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 90
            end
        end,
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                       -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE - categories.SCOUT,        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- ================== --
--    MilitaryZone    --
-- ================== --
BuilderGroup {
    BuilderGroupName = 'U4 Naval Experimental Formers MilitaryZone',                -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U4 BaseMilitaryZone Sea',                                -- Random Builder Name.
        PlatoonTemplate = 'U4-ExperimentalSea 1 1',                             -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        --PlatoonAddPlans = {'NameUnitsSorian'},
        Priority = 80,                                                          -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 80
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                       -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE - categories.AIR,                           -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE - categories.AIR }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- =============== --
--    EnemyZone    --
-- =============== --
BuilderGroup {
    BuilderGroupName = 'U4 Naval Experimental Formers EnemyZone',              -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U4 EnemyZone Sea',                                       -- Random Builder Name.
        PlatoonTemplate = 'U4-ExperimentalSea 1 1',                             -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        --PlatoonAddPlans = {'NameUnitsSorian'},
        Priority = 70,                                                          -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 70
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                       -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.NAVAL,                           -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.TECH3,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.MOBILE  * categories.NAVAL} },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- ============ --
--    Sniper    --
-- ============ --

-- ==================== --
--    Unit Cap Trasher  --
-- ==================== --
BuilderGroup {
    BuilderGroupName = 'U4 Naval Experimental Formers Trasher',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U4 SEA Trasher',                                         -- Random Builder Name.
        --PlatoonAddPlans = {'NameUnitsSorian'},
        PlatoonTemplate = 'U4-ExperimentalSea 1 1',                             -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 60,                                                          -- Priority. 1000 is normal.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 60
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                       -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS,                         -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.MOBILE } },
            { UCBC, 'UnitCapCheckGreater', { 0.90 } },
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.ALLUNITS - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- =========== --
--    Guards   --
-- =========== --

