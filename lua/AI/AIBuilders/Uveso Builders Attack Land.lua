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
LOG('* AI DEBUG: BasePanicZone= '..math.floor( BasePanicZone * 0.01953125 ) ..' Km - ('..BasePanicZone..' units)' )
LOG('* AI DEBUG: BaseMilitaryZone= '..math.floor( BaseMilitaryZone * 0.01953125 )..' Km - ('..BaseMilitaryZone..' units)' )

-- ===================================================-======================================================== --
-- ==                                        Build T1 T2 T3 Land                                             == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'LandAttackBuilders Uveso',
    BuildersType = 'FactoryBuilder',
    -- ==================== --
    --    TECH 1   Island   --
    -- ==================== --
    Builder {
        BuilderName = 'U1 MilitaryZone Tank',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            { MIBC, 'IsIsland', { true } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.MOBILE * categories.LAND * ( categories.DIRECTFIRE + categories.INDIRECTFIRE ) }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Land',
    },
    -- ======================== --
    --    TECH 1   PanicZone    --
    -- ======================== --
    Builder {
        BuilderName = 'U1 PanicZone Tank',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 1300,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1 PanicZone Arty',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 1300,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1 PanicZone AA',
        PlatoonTemplate = 'T1LandAA',
        Priority = 1300,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.AIR - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 10, categories.MOBILE * categories.LAND * categories.ANTIAIR}},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Land',
    },
    -- =========================== --
    --    TECH 1   MilitaryZone    --
    -- =========================== --
    Builder {
        BuilderName = 'U1 MilitaryZone Tank',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
--            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Land',
    },
    -- ======================== --
    --    TECH 1   EnemyZone    --
    -- ======================== --
    Builder {
        BuilderName = 'U1 EnemyZone Tank',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 1000,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
--            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Land',
    },
    -- ============================================= --
    --    TECH 1   Unit Ratio Tank->Arty->Bot->AA    --
    -- ============================================= --
    Builder {
        BuilderName = 'U1 Ratio Arty',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 1100,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 0.75, 'MOBILE LAND INDIRECTFIRE', '<','MOBILE LAND DIRECTFIRE' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
--            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.70 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1 Ratio Bot',
        PlatoonTemplate = 'T1LandDFBot',
        Priority = 1100,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 0.2, 'MOBILE LAND BOT', '<','MOBILE LAND INDIRECTFIRE' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.70 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1 Ratio AA',
        PlatoonTemplate = 'T1LandAA',
        Priority = 1100,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 0.2, 'MOBILE LAND ANTIAIR', '<','MOBILE LAND INDIRECTFIRE' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.70 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2 DFTank',
        PlatoonTemplate = 'T2LandDFTank',
        Priority = 1001,
        BuilderType = 'Land',
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.8, 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE', '<=', 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
    },
    Builder {
        BuilderName = 'U2 AttackTank',
        PlatoonTemplate = 'T2AttackTank',
        Priority = 1001,
        BuilderType = 'Land',
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.8, 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE', '<=', 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
    },
    Builder {
        BuilderName = 'U2 Amphibious',
        PlatoonTemplate = 'T2LandAmphibious',
        Priority = 1001,
        BuilderType = 'Land',
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.8, 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE', '<=', 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
    },
    Builder {
        BuilderName = 'U2 Artillery',
        PlatoonTemplate = 'T2LandArtillery',
        Priority = 1001,
        BuilderType = 'Land',
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.8, 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE', '<=', 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
    },
    Builder {
        BuilderName = 'U2 Mobile AA',
        PlatoonTemplate = 'T2LandAA',
        Priority = 1001,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH2 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.8, 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE', '<=', 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3 Siege Assault Bot',
        PlatoonTemplate = 'T3LandBot',
        Priority = 1002,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH2 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.8, 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE', '<=', 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3 Mobile Artillery',
        PlatoonTemplate = 'T3LandArtillery',
        Priority = 1002,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH2 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.8, 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE', '<=', 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3 SniperBots',
        PlatoonTemplate = 'T3SniperBots',
        Priority = 1002,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH2 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.8, 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE', '<=', 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3 ArmoredAssault',
        PlatoonTemplate = 'T3ArmoredAssault',
        Priority = 1002,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH2 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.8, 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE', '<=', 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3 Mobile AA',
        PlatoonTemplate = 'T3LandAA',
        Priority = 1002,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH2 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.8, 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE', '<=', 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3 MobileShields',
        PlatoonTemplate = 'T3MobileShields',
        Priority = 1002,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH2 }},
            -- Have we the eco to build it ?
             { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
           { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.8, 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE', '<=', 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Land',
    },
}
-- ===================================================-======================================================== --
-- ==                                         Land Formbuilder                                               == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Land FormBuilders',                                     -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    -- =============== --
    --    PanicZone    --
    -- =============== --
    Builder {
        BuilderName = 'U123 AntiCDR PANIC',                                     -- Random Builder Name.
        PlatoonTemplate = 'LandAttackInterceptUveso 2 5',                       -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 1100,                                                        -- Priority. 1000 is normal.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            RequireTransport = true,                                            -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            IgnoreGroundDefense = false,                                        -- Don't attack if we have more then x ground defense buildings at target position. false = no check
            TargetSearchCategory = categories.COMMAND,                          -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'COMMAND',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.COMMAND }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 PANIC 2 5',                                         -- Random Builder Name.
        PlatoonTemplate = 'LandAttackInterceptUveso 2 5',                       -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 1100,                                                        -- Priority. 1000 is normal.
        InstanceCount = 20,                                                     -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            IgnoreGroundDefense = false,                                        -- Don't attack if we have more then x ground defense buildings at target position. false = no check
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'CDR PANIC ACU',                                          -- Random Builder Name.
        PlatoonTemplate = 'CDR Attack',                                         -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 0,                                                        -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            IgnoreGroundDefense = false,                                        -- Don't attack if we have more then x ground defense buildings at target position. false = no check
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'PoolGreaterAtLocationII', { 'MAIN', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- ================== --
    --    MilitaryZone    --
    -- ================== --
    Builder {
        BuilderName = 'U123 Military 10 10',                                    -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 10 10',                          -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 1000,                                                        -- Priority. 1000 is normal.
        InstanceCount = 10,                                                     -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            IgnoreGroundDefense = false,                                        -- Don't attack if we have more then x ground defense buildings at target position. false = no check
            TargetSearchCategory = categories.MOBILE * categories.LAND  - categories.SCOUT - categories.ENGINEER + categories.STRUCTURE * categories.LAND, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'MOBILE LAND',
                'STRUCTURE LAND',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- =============== --
    --    EnemyZone    --
    -- =============== --
    Builder {
        BuilderName = 'U123 EnemyZone 10 10',                                   -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 10 10',                          -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 900,                                                         -- Priority. 1000 is normal.
        InstanceCount = 10,                                                     -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            IgnoreGroundDefense = false,                                        -- Don't attack if we have more then x ground defense buildings at target position. false = no check
            TargetSearchCategory = categories.MOBILE * categories.LAND + categories.STRUCTURE * categories.LAND, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'MOBILE LAND',
                'STRUCTURE LAND',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 AntiMass SingleHunt',                               -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 2 2',                            -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 900,                                                         -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            IgnoreGroundDefense = 1,                                            -- Don't attack if we have more then x ground defense buildings at target position. false = no check
            TargetSearchCategory = categories.MASSEXTRACTION,                   -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'MASSEXTRACTION TECH1',
                'MASSEXTRACTION TECH2',
                'MASSEXTRACTION TECH3',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'GreaterThanGameTimeSeconds', { 600 } },
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , 'MASSEXTRACTION' } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- ================= --
    --    Finish him!    --
    -- ================= --
    Builder {
        BuilderName = 'U123 Kill Them All!!! STR 10 10',
        PlatoonTemplate = 'LandAttackHuntUveso 10 10',                          -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 800,                                                         -- Priority. 1000 is normal.
        InstanceCount = 20,                                                     -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            IgnoreGroundDefense = false,                                        -- Don't attack if we have more then x ground defense buildings at target position. false = no check
            TargetSearchCategory = categories.MOBILE * categories.LAND + categories.STRUCTURE * categories.LAND, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'STRUCTURE LAND',
                'MOBILE LAND',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , 'STUCTURE' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Kill Them All!!! MOB 10 10',
        PlatoonTemplate = 'LandAttackHuntUveso 10 10',                          -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 700,                                                         -- Priority. 1000 is normal.
        InstanceCount = 1,                                                     -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            IgnoreGroundDefense = false,                                        -- Don't attack if we have more then x ground defense buildings at target position. false = no check
            TargetSearchCategory = categories.MOBILE * categories.LAND + categories.STRUCTURE * categories.LAND, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'MOBILE LAND',
                'STRUCTURE LAND',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- =============================== --
    --    Big LandInterceptor groups   --
    -- =============================== --
    Builder {
        BuilderName = 'U123 BigIntercept STR 30 60',
        PlatoonTemplate = 'LandAttackInterceptUveso 30 60',                     -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 600,                                                        -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            IgnoreGroundDefense = false,                                        -- Don't attack if we have more then x ground defense buildings at target position. false = no check
            TargetSearchCategory = categories.MOBILE * categories.LAND + categories.STRUCTURE * categories.LAND, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'STRUCTURE LAND',
                'MOBILE LAND',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 40, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER}},
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , 'STUCTURE' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 BigIntercept MOB 30 60',
        PlatoonTemplate = 'LandAttackInterceptUveso 30 60',                     -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 600,                                                        -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            IgnoreGroundDefense = false,                                        -- Don't attack if we have more then x ground defense buildings at target position. false = no check
            TargetSearchCategory = categories.MOBILE * categories.LAND + categories.STRUCTURE * categories.LAND, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'MOBILE LAND',
                'STRUCTURE LAND',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 40, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER}},
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , 'MOBILE LAND' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}

