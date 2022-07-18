local categories = categories
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetDangerZoneRadii()

-- ===================================================-======================================================== --
-- ==                                      Mobile Experimental Air                                           == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U4 Air Experimental Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U4 AirExp1 Minimum',
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
            { UCBC, 'CanBuildCategory', { categories.MOBILE * categories.AIR * categories.EXPERIMENTAL - categories.SATELLITE } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.LAND * categories.EXPERIMENTAL }},
       },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                BuildStructures = {
                    'T4AirExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U4 AirExperimental1',
        PlatoonTemplate = 'T3EngineerBuilderNoSUB',
        Priority = 150,
        DelayEqualBuildPlattons = {'MobileExperimental', 10},
        InstanceCount = 6,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'MobileExperimental' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome', { 7.0, 600.0 }},                    -- Base income
            { EBC, 'GreaterThanEconStorageRatio', { 0.90, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { MIBC, 'ItsTimeForGameender', {} },
            { UCBC, 'CanBuildCategory', { categories.MOBILE * categories.AIR * categories.EXPERIMENTAL - categories.SATELLITE } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.LAND * categories.EXPERIMENTAL }},
       },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                BuildStructures = {
                    'T4AirExperimental1',
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
    BuilderGroupName = 'U4 Air Experimental Formers PanicZone',               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U4 BasePanicZone AIR',                                   -- Random Builder Name.
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
                categories.COMMAND,
                categories.ANTIAIR,
                categories.MOBILE,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.ANTIAIR,
                categories.COMMAND,
                categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.MOBILE } },
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- ================== --
--    MilitaryZone    --
-- ================== --
BuilderGroup {
    BuilderGroupName = 'U4 Air Experimental Formers MilitaryZone',               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U4 BaseMilitaryZone AIR',                                -- Random Builder Name.
        PlatoonTemplate = 'U4-ExperimentalInterceptor 1 1',                     -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
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
            TargetSearchCategory = categories.MOBILE - categories.SCOUT,        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.COMMAND,
                categories.ANTIAIR,
                categories.MOBILE,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.EXPERIMENTAL,
                categories.COMMAND,
                categories.ANTIAIR,
                categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.EXPERIMENTAL + categories.COMMAND}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- =============== --
--    EnemyZone    --
-- =============== --
BuilderGroup {
    BuilderGroupName = 'U4 Air Experimental Formers EnemyZone',              -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U4 Unprotected Air Solo',                                -- Random Builder Name.
        PlatoonTemplate = 'U4-ExperimentalInterceptor 1 1',                     -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        --PlatoonAddPlans = {'NameUnitsSorian'},
        Priority = 75,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 75
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 25,                                            -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE,                                 -- Only find targets matching these categories.
            TargetHug = true,                                                   -- Tries to get as close to the target as possible
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.OPTICS,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.FACTORY * categories.TECH3,
                categories.STRUCTURE * categories.MASSEXTRACTION * categories.TECH3,
                categories.STRUCTURE,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.COMMAND,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.DEFENSE * categories.ANTIAIR,
                categories.EXPERIMENTAL,
                categories.STRUCTURE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.EXPERIMENTAL * categories.MOBILE } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U4 Suicide STRUCTURE',                                   -- Random Builder Name.
        PlatoonTemplate = 'U4-AirSuicide 1 1',                                  -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        --PlatoonAddPlans = {'NameUnitsSorian'},
        Priority = 70,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
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
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                       -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE,                        -- Only find targets matching these categories.
            TargetHug = true,                                                   -- Tries to get as close to the target as possible
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.OPTICS,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.FACTORY * categories.TECH3,
                categories.STRUCTURE * categories.MASSEXTRACTION * categories.TECH3,
                categories.STRUCTURE,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.COMMAND,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.DEFENSE * categories.ANTIAIR,
                categories.EXPERIMENTAL,
                categories.STRUCTURE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.MOBILE } },
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
    BuilderGroupName = 'U4 Air Experimental Formers Trasher',                   -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U4 AIR Trasher',                                         -- Random Builder Name.
        --PlatoonAddPlans = {'NameUnitsSorian'},
        PlatoonTemplate = 'U4-ExperimentalInterceptor 1 1',                     -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
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
            DirectMoveEnemyBase = true, 
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS,                         -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.OPTICS,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.FACTORY * categories.TECH3,
                categories.STRUCTURE * categories.MASSEXTRACTION * categories.TECH3,
                categories.STRUCTURE,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.COMMAND,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.DEFENSE * categories.ANTIAIR,
                categories.EXPERIMENTAL,
                categories.STRUCTURE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitCapCheckGreater', { 0.98 } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- =========== --
--    Guards   --
-- =========== --

-- ===================== --
--    Air Crash Suicide  --
-- ===================== --
BuilderGroup {
    BuilderGroupName = 'U4 Suicide Air Crash',                                  -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U4 Suicide AIR exp',                                     -- Random Builder Name.
        PlatoonTemplate = 'U4-Suicide 1 1',                                     -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 10000,                                                       -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 10000
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                       -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE,                        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ARTILLERY,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.ANTIAIR,
                categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.STRUCTURE * categories.EXPERIMENTAL * (categories.ECONOMIC + categories.SHIELD + categories.ARTILLERY) } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U4 Suicide AIR T3',                                      -- Random Builder Name.
        PlatoonTemplate = 'U4-Suicide 1 1',                                     -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 9000,                                                        -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 10000
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                       -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE,                        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.TECH3 * categories.ARTILLERY,
                categories.STRUCTURE * categories.TECH3 * categories.NUKE,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.ANTIAIR,
                categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.STRUCTURE * categories.TECH3 * (categories.ARTILLERY + categories.NUKE + categories.OPTICS) } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
