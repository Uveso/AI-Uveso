local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local IBC = '/lua/editor/InstantBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local ExperimentalCount = 3
local mapSizeX, mapSizeZ = GetMapSize()
local BaseMilitaryZone = math.max( mapSizeX-50, mapSizeZ-50 ) / 2 -- Half the map
local BasePanicZone = BaseMilitaryZone / 2
BasePanicZone = math.max( 60, BasePanicZone )
BasePanicZone = math.min( 120, BasePanicZone )

-- ===================================================-======================================================== --
-- ==                                        Build T1 T2 T3 Land                                             == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'SeaFactoryBuilders Uveso',
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    -- Panic builder, in case the enemy is in front of our base 
    Builder {
        BuilderName = 'U1 Sub PANIC',
        PlatoonTemplate = 'T1SeaSub',
        Priority = 1100,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    -- Default T1 builder will not respect eco and build as long as we have less units then the enemy
    Builder {
        BuilderName = 'U1 Sub',
        PlatoonTemplate = 'T1SeaSub',
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 10, categories.MOBILE * categories.NAVAL * categories.SUBMERSIBLE } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 50, categories.MOBILE * categories.NAVAL }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.NAVAL * categories.FACTORY * categories.TECH1 }},
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U1 Sea Frigate ratio Sub',
        PlatoonTemplate = 'T1SeaFrigate',
        Priority = 1001,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 10, categories.MOBILE * categories.NAVAL - categories.SUBMERSIBLE } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 50, categories.MOBILE * categories.NAVAL }},
--            { UCBC, 'HaveUnitRatio', { 1.0, 'NAVAL MOBILE ANTIAIR', '<','NAVAL MOBILE SUBMERSIBLE' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.NAVAL * categories.FACTORY * categories.TECH1 }},
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },

    Builder {
        BuilderName = 'U1 Sea AntiAir',
        PlatoonTemplate = 'T1SeaAntiAir',
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.4, 'MOBILE NAVAL ANTIAIR', '<=', 'MOBILE AIR' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 30, 'MOBILE NAVAL SUBMERSIBLE' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.25}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'NAVAL' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { ExperimentalCount, categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL }},
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
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.25}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'MOBILE NAVAL' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { ExperimentalCount, categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL }},
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2 Sea Cruiser',
        PlatoonTemplate = 'T2SeaCruiser',
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.25}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'MOBILE NAVAL' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { ExperimentalCount, categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL }},
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2 Sea SubKiller',
        PlatoonTemplate = 'T2SubKiller',
        Priority = 1100,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL SUBMERSIBLE', '<=', 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.25}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
--            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'MOBILE NAVAL' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { ExperimentalCount, categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL }},
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2 Sea ShieldBoat',
        PlatoonTemplate = 'T2ShieldBoat',
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.25}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'MOBILE NAVAL' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { ExperimentalCount, categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL }},
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2 Sea CounterIntelBoat',
        PlatoonTemplate = 'T2CounterIntelBoat',
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.25}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'MOBILE NAVAL' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.50, '<=', categories.MOBILE -categories.ENGINEER -categories.SCOUT } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { ExperimentalCount, categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL }},
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
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.25}}, -- Ratio from 0 to 1. (1=100%)
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
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
           { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL SUBMERSIBLE', '<=', 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.25}}, -- Ratio from 0 to 1. (1=100%)
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
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.25}}, -- Ratio from 0 to 1. (1=100%)
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
        Priority = 1100,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL SUBMERSIBLE', '<=', 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.25}}, -- Ratio from 0 to 1. (1=100%)
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
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.1, 'MOBILE NAVAL', '<=', 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.25}}, -- Ratio from 0 to 1. (1=100%)
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
    BuilderGroupName = 'SeaAttack FormBuilders Uveso',
    BuildersType = 'PlatoonFormBuilder',
    -- =============== --
    --    PanicZone    --
    -- =============== --
    Builder {
        BuilderName = 'U123 PANIC AntiSea',
        PlatoonTemplate = 'U123 Panic AntiSea 1 500',
        Priority = 2000,                                        -- Priority. 1000 is normal.
        InstanceCount = 3,                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BasePanicZone,                       -- Searchradius for new target.
            AggressiveMove = true,                              -- If true, the unit will attack everything while moving to the target.
            IgnoreGroundDefense = false,                        -- Don't attack if we have more then x ground defense buildings at target position. false = no check
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
        Priority = 2000,                                        -- Priority. 1000 is normal.
        InstanceCount = 3,                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                    -- Searchradius for new target.
            AggressiveMove = false,                             -- If true, the unit will attack everything while moving to the target.
            IgnoreGroundDefense = false,                        -- Don't attack if we have more then x ground defense buildings at target position. false = no check
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
        Priority = 1000,
        InstanceCount = 5,
        BuilderData = {
            SearchRadius = 10000,                               -- Searchradius for new target.
            AggressiveMove = false,                              -- If true, the unit will attack everything while moving to the target.
            IgnoreGroundDefense = false,                        -- Don't attack if we have more then x ground defense buildings at target position. false = no check
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
        Priority = 1000,
        InstanceCount = 10,
        BuilderData = {
            SearchRadius = 10000,                               -- Searchradius for new target.
            AggressiveMove = true,                              -- If true, the unit will attack everything while moving to the target.
            IgnoreGroundDefense = false,                        -- Don't attack if we have more then x ground defense buildings at target position. false = no check
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
