local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local IBC = '/lua/editor/InstantBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)
local mapSizeX, mapSizeZ = GetMapSize()
local BaseMilitaryZone = math.max( mapSizeX-50, mapSizeZ-50 ) / 2 -- Half the map
local BasePanicZone = BaseMilitaryZone / 2
BasePanicZone = math.max( 60, BasePanicZone )
BasePanicZone = math.min( 120, BasePanicZone )
BaseMilitaryZone = math.max( 250, BaseMilitaryZone )

-- ===================================================-======================================================== --
-- ==                                        Build T1 T2 T3 Land                                             == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'SeaFactoryBuilders Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ======================== --
    --    TECH 1   PanicZone    --
    -- ======================== --
    Builder {
        BuilderName = 'U1 Sub PANIC',
        PlatoonTemplate = 'T1SeaSub',
        Priority = 190,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 10, categories.MOBILE * categories.NAVAL  * categories.SUBMERSIBLE }},
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U1 Sea AntiAir PANIC',
        PlatoonTemplate = 'T1SeaAntiAir',
        Priority = 190,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.AIR }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 10, categories.ANTIAIR }},
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    -- =========================== --
    --    TECH 1   MilitaryZone    --
    -- =========================== --
    Builder {
        BuilderName = 'U1 Sub',
        PlatoonTemplate = 'T1SeaSub',
        Priority = 150,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.NAVAL * categories.FACTORY * categories.TECH1 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.92 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U1 Sea Frigate ratio',
        PlatoonTemplate = 'T1SeaFrigate',
        Priority = 170,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            { UCBC, 'HaveUnitRatio', { 0.30, 'MOBILE NAVAL DIRECTFIRE TECH1', '<','MOBILE NAVAL SUBMERSIBLE' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.NAVAL * categories.FACTORY * categories.TECH1 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.92 } },
        },
        BuilderType = 'Sea',
    },

    Builder {
        BuilderName = 'U1 Sea AntiAir ratio',
        PlatoonTemplate = 'T1SeaAntiAir',
        Priority = 170,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            { UCBC, 'HaveUnitRatio', { 0.30, 'MOBILE NAVAL ANTIAIR TECH1', '<','MOBILE NAVAL SUBMERSIBLE' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'NAVAL' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2 Sea Destroyer',
        PlatoonTemplate = 'T2SeaDestroyer',
        Priority = 180,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'NAVAL' } },
            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'MOBILE NAVAL' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2 Sea Cruiser',
        PlatoonTemplate = 'T2SeaCruiser',
        Priority = 180,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'NAVAL' } },
            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'MOBILE NAVAL' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2 Sea SubKiller',
        PlatoonTemplate = 'T2SubKiller',
        Priority = 180,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL SUBMERSIBLE', '<=', 'NAVAL' } },
            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'MOBILE NAVAL' } },
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2 Sea ShieldBoat',
        PlatoonTemplate = 'T2ShieldBoat',
        Priority = 180,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'NAVAL' } },
            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'MOBILE NAVAL' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2 Sea CounterIntelBoat',
        PlatoonTemplate = 'T2CounterIntelBoat',
        Priority = 180,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'NAVAL' } },
            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'MOBILE NAVAL' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3 Sea Battleship',
        PlatoonTemplate = 'T3SeaBattleship',
        Priority = 180,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'MOBILE NAVAL' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3 Sea NukeSub',
        PlatoonTemplate = 'T3SeaNukeSub',
        Priority = 180,
        BuilderConditions = {
            -- When do we want to build this ?
           { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL SUBMERSIBLE', '<=', 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'MOBILE NAVAL' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3 Sea MissileBoat',
        PlatoonTemplate = 'T3MissileBoat',
        Priority = 180,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'MOBILE NAVAL' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3 Sea SubKiller',
        PlatoonTemplate = 'T3SubKiller',
        Priority = 180,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL SUBMERSIBLE', '<=', 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'MOBILE NAVAL' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3 Sea Battlecruiser',
        PlatoonTemplate = 'T3Battlecruiser',
        Priority = 180,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'MOBILE NAVAL' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
}
-- ===================================================-======================================================== --
-- ==                                      NAVAL T1 T2 T3 Formbuilder                                        == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'SeaAttack FormBuilders Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    -- =============== --
    --    PanicZone    --
    -- =============== --
    Builder {
        BuilderName = 'U123 PANIC AntiSea',
        PlatoonTemplate = 'U123 Panic AntiSea 1 500',
        Priority = 90,                                        -- Priority. 1000 is normal.
        InstanceCount = 3,                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BasePanicZone,                       -- Searchradius for new target.
            AggressiveMove = true,                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE * categories.NAVAL, -- Only find targets matching these categories.
            PrioritizedCategories = {
                'STRUCTURE NAVAL DEFENSE',
                'MOBILE NAVAL',
                'STRUCTURE NAVAL',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- ================== --
    --    MilitaryZone    --
    -- ================== --
    Builder {
        BuilderName = 'U123 Military AntiSea',
        PlatoonTemplate = 'U123 Military AntiSea 5 5',
        Priority = 80,                                        -- Priority. 1000 is normal.
        InstanceCount = 3,                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                    -- Searchradius for new target.
            AggressiveMove = false,                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE * categories.NAVAL , -- Only find targets matching these categories.
            TargetSearchCategory = 'NAVAL, MOBILE LAND, STRUCTURE', -- Only find targets matching these categories.
            PrioritizedCategories = {
                'STRUCTURE NAVAL DEFENSE',
                'MOBILE NAVAL',
                'STRUCTURE NAVAL',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- =============== --
    --    EnemyZone    --
    -- =============== --
    Builder {
        BuilderName = 'U123 Enemy AntiSea',
        PlatoonTemplate = 'U123 Enemy AntiSea 10 10',
        Priority = 60,
        InstanceCount = 5,
        BuilderData = {
            SearchRadius = 10000,                               -- Searchradius for new target.
            AggressiveMove = false,                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = (categories.MOBILE - categories.AIR) + categories.STRUCTURE , -- Only find targets matching these categories.
            PrioritizedCategories = {
                'STRUCTURE NAVAL DEFENSE',
                'MOBILE NAVAL',
                'STRUCTURE NAVAL',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 15, categories.MOBILE * categories.NAVAL } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
    -- ================= --
    --    Finish him!    --
    -- ================= --
    Builder {
        BuilderName = 'U123 Sea Kill Them All!!!',
        PlatoonTemplate = 'U123 KILLALL 10 10',
        Priority = 50,
        InstanceCount = 10,
        BuilderData = {
            SearchRadius = 10000,                               -- Searchradius for new target.
            AggressiveMove = true,                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = (categories.MOBILE - categories.AIR) + categories.STRUCTURE , -- Only find targets matching these categories.
            PrioritizedCategories = {
                'STRUCTURE NAVAL DEFENSE',
                'MOBILE NAVAL',
                'STRUCTURE NAVAL',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.5, 'MOBILE NAVAL', '>', 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 15, 'MOBILE NAVAL' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
}
