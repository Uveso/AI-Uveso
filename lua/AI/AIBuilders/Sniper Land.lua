local categories = categories
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetDangerZoneRadii()

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

-- ===================================================-======================================================== --
-- ==                                         Land Formbuilder                                               == --
-- ===================================================-======================================================== --
-- ==================== --
--    SACU Teleporter   --
-- ==================== --
BuilderGroup {
    BuilderGroupName = 'U3 SACU Teleport Formers',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
-- ================= --
--    SACU Former    --
-- ================= --
    Builder {
        BuilderName = 'U3 Teleport 1',
        PlatoonTemplate = 'SACU Teleport 1 1',
        Priority = 21000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 50000,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE - categories.NAVAL,     -- Only find targets matching these categories.
            TargetHug = true,                                                   -- Tries to get as close to the target as possible
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.OPTICS,
                categories.STRUCTURE * categories.MASSEXTRACTION * categories.TECH3,
                categories.FACTORY * categories.TECH3,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.ALLUNITS - categories.AIR,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.COMMAND,
                categories.DEFENSE - categories.ANTIAIR,
                categories.EXPERIMENTAL,
                categories.ALLUNITS - categories.SCOUT,
            },
        },
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 2, 4 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 1000.0 } }, -- relative income (wee need 10000 energy for a teleport. x3 SACU's
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.SUBCOMMANDER} },
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , categories.STRUCTURE } },
            -- Respect UnitCap
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U3 Teleport 3',
        PlatoonTemplate = 'SACU Teleport 3 3',
        Priority = 21000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 50000,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE - categories.NAVAL,     -- Only find targets matching these categories.
            TargetHug = true,                                                   -- Tries to get as close to the target as possible
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.MASSEXTRACTION * categories.TECH3,
                categories.FACTORY * categories.TECH3,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.ALLUNITS - categories.AIR,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.COMMAND,
                categories.DEFENSE - categories.ANTIAIR,
                categories.EXPERIMENTAL,
                categories.ALLUNITS - categories.SCOUT,
            },
        },
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 2, 4 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 3000.0 } }, -- relative income (wee need 10000 energy for a teleport. x3 SACU's
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 3, categories.SUBCOMMANDER} },
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , categories.STRUCTURE } },
            -- Respect UnitCap
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U3 Teleport 6',
        PlatoonTemplate = 'SACU Teleport 6 6',
        Priority = 21000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 50000,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE - categories.NAVAL,     -- Only find targets matching these categories.
            TargetHug = true,                                                   -- Tries to get as close to the target as possible
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.MASSEXTRACTION * categories.TECH3,
                categories.FACTORY * categories.TECH3,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.ALLUNITS - categories.AIR,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.COMMAND,
                categories.DEFENSE - categories.ANTIAIR,
                categories.EXPERIMENTAL,
                categories.ALLUNITS - categories.SCOUT,
            },
        },
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 2, 4 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 6000.0 } }, -- relative income (wee need 10000 energy for a teleport. x3 SACU's
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 6, categories.SUBCOMMANDER} },
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , categories.STRUCTURE } },
            -- Respect UnitCap
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U3 Teleport 9',
        PlatoonTemplate = 'SACU Teleport 9 9',
        Priority = 21000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 50000,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE - categories.NAVAL,     -- Only find targets matching these categories.
            TargetHug = true,                                                   -- Tries to get as close to the target as possible
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.MASSEXTRACTION * categories.TECH3,
                categories.FACTORY * categories.TECH3,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.ALLUNITS - categories.AIR,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.COMMAND,
                categories.DEFENSE - categories.ANTIAIR,
                categories.EXPERIMENTAL,
                categories.ALLUNITS - categories.SCOUT,
            },
        },
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 2, 4 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 9000.0 } }, -- relative income (wee need 10000 energy for a teleport. x3 SACU's
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 9, categories.SUBCOMMANDER} },
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , categories.STRUCTURE } },
            -- Respect UnitCap
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U3 SACU CAP 3 7',
        PlatoonTemplate = 'SACU Fight 3 7',
        Priority = 500,
        InstanceCount = 2,
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 50000,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                              -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE - categories.NAVAL,     -- Only find targets matching these categories.
            TargetHug = true,                                                  -- Tries to get as close to the target as possible
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.MASSEXTRACTION * categories.TECH3,
                categories.FACTORY * categories.TECH3,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.ALLUNITS - categories.AIR,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.COMMAND,
                categories.DEFENSE - categories.ANTIAIR,
                categories.EXPERIMENTAL,
                categories.ALLUNITS - categories.SCOUT,
            },
        },
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 9, categories.SUBCOMMANDER} },
            -- Respect UnitCap
        },
        BuilderType = 'Any',
    },
}
