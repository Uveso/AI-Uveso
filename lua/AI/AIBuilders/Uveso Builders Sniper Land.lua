local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local IBC = '/lua/editor/InstantBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

local mapSizeX, mapSizeZ = GetMapSize()
local BaseMilitaryZone = math.max( mapSizeX-50, mapSizeZ-50 ) / 2               -- Half the map
local BasePanicZone = BaseMilitaryZone / 2
BasePanicZone = math.max( 60, BasePanicZone )
BasePanicZone = math.min( 120, BasePanicZone )
BaseMilitaryZone = math.max( 250, BaseMilitaryZone )
LOG('* Uveso-AI: BasePanicZone= '..math.floor( BasePanicZone * 0.01953125 ) ..' Km - ('..BasePanicZone..' units)' )
LOG('* Uveso-AI: BaseMilitaryZone= '..math.floor( BaseMilitaryZone * 0.01953125 )..' Km - ('..BaseMilitaryZone..' units)' )

-- ===================================================-======================================================== --
-- ==                                        Build T1 T2 T3 Land                                             == --
-- ===================================================-======================================================== --
--BuilderGroup {
--    BuilderGroupName = 'LandAttackBuildersRush Uveso',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
--    BuildersType = 'FactoryBuilder',
--}
-- ===================================================-======================================================== --
-- ==                                         Land Formbuilder                                               == --
-- ===================================================-======================================================== --
-- ======================== --
--    Land Scouts Former    --
-- ======================== --
BuilderGroup {
    BuilderGroupName = 'SACU TeleportFormer',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
-- ================= --
--    SACU Former    --
-- ================= --
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
            TargetSearchCategory = 'STRUCTURE',                                 -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'STRUCTURE EXPERIMENTAL ECONOMIC',
                'STRUCTURE EXPERIMENTAL SHIELD',
                'STRUCTURE EXPERIMENTAL',
                'FACTORY TECH3',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 9, categories.SUBCOMMANDER} },
            -- Do we need additional conditions to build it ?
            { MIBC, 'FactionIndex', { 2, 4 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 2200.0 } }, -- relative income
            -- Don't build it if...
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
            TargetSearchCategory = 'STRUCTURE',                                 -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'STRUCTURE EXPERIMENTAL ECONOMIC',
                'STRUCTURE EXPERIMENTAL SHIELD',
                'STRUCTURE EXPERIMENTAL',
                'FACTORY TECH3',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 16, categories.SUBCOMMANDER} },
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , categories.STRUCTURE } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'FactionIndex', { 2, 4 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 2200.0 } }, -- relative income
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U3 Teleport 12',
        PlatoonTemplate = 'SACU Teleport 12 12',
        Priority = 21000,
        InstanceCount = 2,
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 50000,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = 'STRUCTURE',                                 -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'STRUCTURE EXPERIMENTAL ECONOMIC',
                'STRUCTURE EXPERIMENTAL SHIELD',
                'STRUCTURE EXPERIMENTAL',
                'FACTORY TECH3',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 25, categories.SUBCOMMANDER} },
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , categories.STRUCTURE } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'FactionIndex', { 2, 4 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 2200.0 } }, -- relative income
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderType = 'Any',
    },
}
