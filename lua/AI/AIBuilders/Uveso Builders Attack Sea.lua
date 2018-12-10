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
-- ==                                        Build T1 T2 T3 SEA                                              == --
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
        Priority = 18600,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 30,  categories.MOBILE * categories.NAVAL } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'UnitCapCheckLess', { 0.97 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U1 Sea AntiAir PANIC',
        PlatoonTemplate = 'T1SeaAntiAir',
        Priority = 18500,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.AIR * ( categories.BOMBER + categories.GROUNDATTACK + categories.ANTINAVY ) }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 30,  categories.MOBILE * categories.NAVAL } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'UnitCapCheckLess', { 0.97 } },
        },
        BuilderType = 'Sea',
    },
    -- ======================== --
    --    TECH 1   EnemyZone    --
    -- ======================== --
    Builder {
        BuilderName = 'U1 Sub',
        PlatoonTemplate = 'T1SeaSub',
        Priority = 160,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 30,  categories.MOBILE * categories.NAVAL } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.97 } },
        },
        BuilderType = 'Sea',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2 Sea Destroyer',
        PlatoonTemplate = 'T2SeaDestroyer',
        Priority = 260,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 30,  categories.MOBILE * categories.NAVAL } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, 'MOBILE NAVAL TECH2' } },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2 Sea Cruiser',
        PlatoonTemplate = 'T2SeaCruiser',
        Priority = 260,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 30,  categories.MOBILE * categories.NAVAL } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, 'MOBILE NAVAL TECH2' } },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2 Sea SubKiller',
        PlatoonTemplate = 'T2SubKiller',
        Priority = 260,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 30,  categories.MOBILE * categories.NAVAL } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, 'MOBILE NAVAL TECH2' } },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2 Sea ShieldBoat',
        PlatoonTemplate = 'T2ShieldBoat',
        Priority = 260,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 30,  categories.MOBILE * categories.NAVAL } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, 'MOBILE NAVAL TECH2' } },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2 Sea CounterIntelBoat',
        PlatoonTemplate = 'T2CounterIntelBoat',
        Priority = 260,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 30,  categories.MOBILE * categories.NAVAL } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, 'MOBILE NAVAL TECH2' } },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Sea',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3 Sea Battleship',
        PlatoonTemplate = 'T3SeaBattleship',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 35,  categories.MOBILE * categories.NAVAL } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 2.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'MOBILE NAVAL TECH3' } },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3 Sea NukeSub',
        PlatoonTemplate = 'T3SeaNukeSub',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 35,  categories.MOBILE * categories.NAVAL } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 2.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'MOBILE NAVAL TECH3' } },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3 Sea MissileBoat',
        PlatoonTemplate = 'T3MissileBoat',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 35,  categories.MOBILE * categories.NAVAL } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 2.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'MOBILE NAVAL TECH3' } },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3 Sea SubKiller',
        PlatoonTemplate = 'T3SubKiller',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 35,  categories.MOBILE * categories.NAVAL } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 2.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'MOBILE NAVAL TECH3' } },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3 Sea Battlecruiser',
        PlatoonTemplate = 'T3Battlecruiser',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 35,  categories.MOBILE * categories.NAVAL } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 2.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'MOBILE NAVAL TECH3' } },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.99 } },
        },
        BuilderType = 'Sea',
    },
-- ===================================================-======================================================== --
-- ==                                         Sea ratio builder                                              == --
-- ===================================================-======================================================== --
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U1 Sea Frigate ratio',
        PlatoonTemplate = 'T1SeaFrigate',
        Priority = 170,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 0.80, 'MOBILE NAVAL FRIGATE TECH1', '<','MOBILE NAVAL SUBMERSIBLE TECH1' } },
            { UCBC, 'NavalBaseWithLeastUnits', {  60, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 35,  categories.MOBILE * categories.NAVAL } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.97 } },
        },
        BuilderType = 'Sea',
    },
}
-- ===================================================-======================================================== --
-- ==                                            Sonar  builder                                              == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'SonarBuilders Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U1 Sonar',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17500,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, (categories.SONAR * categories.STRUCTURE - categories.TECH3) + (categories.MOBILESONAR * categories.TECH3) } }, -- TECH3 sonar is MOBILE not STRUCTURE!!!
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH1' }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION,
                AdjacencyDistance = 50,
                BuildStructures = {
                    'T1Sonar',
                },
                Location = 'LocationType',
            }
        }
    },
}
BuilderGroup {
    BuilderGroupName = 'SonarUpgrade Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U1 Sonar Upgrade',
        PlatoonTemplate = 'T1SonarUpgrade',
        Priority = 200,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SONAR * categories.TECH1}},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Sonar Upgrade',
        PlatoonTemplate = 'T2SonarUpgrade',
        Priority = 300,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SONAR * categories.TECH2}},
            -- Do we need additional conditions to build it ?
            { MIBC, 'FactionIndex', { 1, 2, 3, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderType = 'Any',
    },
}
-- ===================================================-======================================================== --
-- ==                                      NAVAL T1 T2 T3 Formbuilder                                        == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'SeaAttack FormBuilders Uveso',                          -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    -- =============== --
    --    PanicZone    --
    -- =============== --
    Builder {
        BuilderName = 'U123 PANIC AntiSea',
        PlatoonTemplate = 'U123 Panic AntiSea 1 500',
        Priority = 90,                                        -- Priority. 1000 is normal.
        InstanceCount = 5,                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BasePanicZone,                       -- Searchradius for new target.
            AggressiveMove = false,                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = (categories.MOBILE + categories.STRUCTURE) * categories.NAVAL, -- Only find targets matching these categories.
            PrioritizedCategories = {
                'STRUCTURE NAVAL DEFENSE',
                'MOBILE NAVAL',
                'STRUCTURE NAVAL',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, (categories.MOBILE + categories.STRUCTURE) * categories.NAVAL }}, -- radius, LocationType, unitCount, categoryEnemy
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
        InstanceCount = 6,                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                    -- Searchradius for new target.
            AggressiveMove = false,                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 150,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = (categories.MOBILE + categories.STRUCTURE) * categories.NAVAL, -- Only find targets matching these categories.
            PrioritizedCategories = {
                'STRUCTURE NAVAL DEFENSE',
                'MOBILE NAVAL',
                'STRUCTURE NAVAL',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, (categories.MOBILE + categories.STRUCTURE) * categories.NAVAL }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 6, categories.MOBILE * categories.NAVAL } },
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
        BuilderName = 'U123 Kill early',
        PlatoonTemplate = 'U123 Enemy Dual 2 2',
        Priority = 10000,
        InstanceCount = 1,
        BuilderData = {
            SearchRadius = 10000,                               -- Searchradius for new target.
            AggressiveMove = true,                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 200,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE + categories.STRUCTURE, -- Only find targets matching these categories.
            PrioritizedCategories = {
                'STRUCTURE',
                'MOBILE',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 5, categories.MOBILE * categories.NAVAL } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U123 Enemy AntiStructure',
        PlatoonTemplate = 'U123 Enemy AntiSea 10 10',
        Priority = 60,
        InstanceCount = 2,
        BuilderData = {
            SearchRadius = 10000,                               -- Searchradius for new target.
            AggressiveMove = false,                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.STRUCTURE * categories.NAVAL, -- Only find targets matching these categories.
            PrioritizedCategories = {
                'STRUCTURE NAVAL DEFENSE',
                'STRUCTURE NAVAL',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 15, categories.MOBILE * categories.NAVAL } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , 'STRUCTURE NAVAL' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U123 Enemy AntiMobile',
        PlatoonTemplate = 'U123 Enemy AntiSea 10 10',
        Priority = 50,
        InstanceCount = 2,
        BuilderData = {
            SearchRadius = 10000,                               -- Searchradius for new target.
            AggressiveMove = false,                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE * categories.NAVAL, -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE NAVAL',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 15, categories.MOBILE * categories.NAVAL } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , 'MOBILE NAVAL' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
    -- ================= --
    --    Finish him!    --
    -- ================= --
    Builder {
        BuilderName = 'U123 Sea Finish him!',
        PlatoonTemplate = 'U123 Panic AntiSea 1 500',
        Priority = 50,
        InstanceCount = 10,
        BuilderData = {
            SearchRadius = 10000,                               -- Searchradius for new target.
            AggressiveMove = true,                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 500,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = (categories.MOBILE + categories.STRUCTURE) * categories.NAVAL, -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE NAVAL',
                'STRUCTURE NAVAL DEFENSE',
                'STRUCTURE NAVAL',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 20, categories.MOBILE * categories.NAVAL } },
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.5, 'MOBILE NAVAL', '>', 'MOBILE NAVAL' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , 'MOBILE NAVAL' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
    -- ==================== --
    --    Kill Them All!    --
    -- ==================== --
    Builder {
        BuilderName = 'U123 Anti NavalFactories',
        PlatoonTemplate = 'U123 Enemy AntiSea 10 10',
        Priority = 1,
        InstanceCount = 1,
        BuilderData = {
            SearchRadius = 10000,                               -- Searchradius for new target.
            AggressiveMove = false,                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 1000000,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.STRUCTURE * categories.FACTORY * categories.NAVAL, -- Only find targets matching these categories.
            PrioritizedCategories = {
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 10, categories.MOBILE * categories.NAVAL } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , 'STRUCTURE FACTORY NAVAL' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
    },
}
