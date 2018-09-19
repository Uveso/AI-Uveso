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
LOG('* AI DEBUG: BasePanicZone= '..math.floor( BasePanicZone * 0.01953125 ) ..' Km - ('..BasePanicZone..' units)' )
LOG('* AI DEBUG: BaseMilitaryZone= '..math.floor( BaseMilitaryZone * 0.01953125 )..' Km - ('..BaseMilitaryZone..' units)' )

-- ===================================================-======================================================== --
-- ==                                        Build T1 T2 T3 Land                                             == --
-- ===================================================-======================================================== --
-- ============= --
--    AI-RUSH    --
-- ============= --
BuilderGroup {
    BuilderGroupName = 'LandAttackBuildersRush Uveso',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U1R Arty',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 150,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.92 } },
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2R Arty',
        PlatoonTemplate = 'T2LandArtillery',
        Priority = 250,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.93 } },
        },
        BuilderType = 'Land',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3R Arty',
        PlatoonTemplate = 'T3LandArtillery',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'MOBILE LAND INDIRECTFIRE TECH1' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.94 } },
        },
        BuilderType = 'Land',
    },
}
-- ================= --
--    AI-ADAPTIVE    --
-- ================= --
BuilderGroup {
    BuilderGroupName = 'LandAttackBuilders Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- =========================== --
    --    TECH 1   MilitaryZone    --
    -- =========================== --
    Builder {
        BuilderName = 'U1A MilitaryZone Arty',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 150,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE', '<=', 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.92 } },
        },
        BuilderType = 'Land',
    },
    -- ======================== --
    --    TECH 1   EnemyZone    --
    -- ======================== --
    Builder {
        BuilderName = 'U1A EnemyZone Arty',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 140,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE', '<=', 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.92 } },
        },
        BuilderType = 'Land',
    },
    -- ==================== --
    --    TECH 1   Island   --
    -- ==================== --
    Builder {
        BuilderName = 'U1A Island Tank',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 150,
        BuilderConditions = {
            -- When do we want to build this ?
            { MIBC, 'IsIsland', { true } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.MOBILE * categories.LAND * ( categories.DIRECTFIRE + categories.INDIRECTFIRE ) }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE', '<=', 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.92 } },
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2A Artillery',
        PlatoonTemplate = 'T2LandArtillery',
        Priority = 250,
        BuilderType = 'Land',
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
--            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE', '<=', 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.93 } },
        },
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3A Mobile Artillery',
        PlatoonTemplate = 'T3LandArtillery',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 1.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
--            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE', '<=', 'LAND MOBILE DIRECTFIRE, LAND MOBILE INDIRECTFIRE' } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.94 } },
        },
        BuilderType = 'Land',
    },
}
-- ===================================================-======================================================== --
-- ==                                         Land panic builder                                             == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'LandAttackBuildersPanic Uveso',                         -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ================================== --
    --    TECH 1   PanicZone Main Base    --
    -- ================================== --
    Builder {
        BuilderName = 'U1 PanicZone Arty',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 18600,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1 PanicZone/2 AA',
        PlatoonTemplate = 'T1LandAA',
        Priority = 18600,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.AIR - categories.SCOUT - categories.SATELLITE}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
}
BuilderGroup {
    BuilderGroupName = 'LandAttackBuildersPanicEXP Uveso',                         -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ================================== --
    --    TECH 1   PanicZone Expansion    --
    -- ================================== --
    Builder {
        BuilderName = 'U1E PanicExpansion Arty',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 160,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  50, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1E PanicPanicExpansion AA',
        PlatoonTemplate = 'T1LandAA',
        Priority = 155,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  50, 'LocationType', 1, categories.MOBILE * categories.AIR - categories.SCOUT - categories.SATELLITE}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
}
-- ===================================================-======================================================== --
-- ==                                         Land ratio builder                                             == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'LandAttackBuildersRatio Uveso',                         -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U1 Ratio Tank',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 170,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 0.80, 'MOBILE LAND DIRECTFIRE TECH1', '<','MOBILE LAND INDIRECTFIRE TECH1' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.92 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1 Ratio Bot',
        PlatoonTemplate = 'T1LandDFBot',
        Priority = 170,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 0.3, 'MOBILE LAND BOT TECH1', '<','MOBILE LAND INDIRECTFIRE TECH1' } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'FactionIndex', { 1, 2, 3 , 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.92 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1 Ratio AA',
        PlatoonTemplate = 'T1LandAA',
        Priority = 170,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 0.1, 'MOBILE LAND ANTIAIR TECH1', '<','MOBILE LAND INDIRECTFIRE TECH1' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.92 } },
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2 DFTank',
        PlatoonTemplate = 'T2LandDFTank',
        Priority = 270,
        BuilderType = 'Land',
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 2.00, 'MOBILE LAND DIRECTFIRE TECH2', '<','MOBILE LAND INDIRECTFIRE TECH2' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.93 } },
        },
    },
    Builder {
        BuilderName = 'U2 AttackTank',
        PlatoonTemplate = 'T2AttackTank',
        Priority = 270,
        BuilderType = 'Land',
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 2.00, 'MOBILE LAND DIRECTFIRE TECH2', '<','MOBILE LAND INDIRECTFIRE TECH2' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.93 } },
        },
    },
    Builder {
        BuilderName = 'U2 Amphibious',
        PlatoonTemplate = 'T2LandAmphibious',
        Priority = 270,
        BuilderType = 'Land',
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 2.0, 'MOBILE LAND DIRECTFIRE TECH2', '<','MOBILE LAND INDIRECTFIRE TECH2' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.93 } },
        },
    },
    Builder {
        BuilderName = 'U2 Mobile AA',
        PlatoonTemplate = 'T2LandAA',
        Priority = 270,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 2.0, 'MOBILE LAND ANTIAIR TECH2', '<','MOBILE LAND INDIRECTFIRE TECH2' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.93 } },
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3 Siege Assault Bot',
        PlatoonTemplate = 'T3LandBot',
        Priority = 370,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 2.0, 'MOBILE LAND DIRECTFIRE TECH3', '<','MOBILE LAND INDIRECTFIRE TECH3' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 1.5, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.94 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3 SniperBots',
        PlatoonTemplate = 'T3SniperBots',
        Priority = 370,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 2.0, 'MOBILE LAND DIRECTFIRE TECH3', '<','MOBILE LAND INDIRECTFIRE TECH3' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 1.5, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.94 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3 ArmoredAssault',
        PlatoonTemplate = 'T3ArmoredAssault',
        Priority = 370,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 2.0, 'MOBILE LAND DIRECTFIRE TECH3', '<','MOBILE LAND INDIRECTFIRE TECH3' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 1.5, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.94 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3 Mobile AA',
        PlatoonTemplate = 'T3LandAA',
        Priority = 370,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 2.0, 'MOBILE LAND ANTIAIR TECH3', '<','MOBILE LAND INDIRECTFIRE TECH3' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 1.5, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.94 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3 MobileShields',
        PlatoonTemplate = 'T3MobileShields',
        Priority = 0,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 2.0, 'MOBILE LAND SHIELD TECH3', '<','MOBILE LAND INDIRECTFIRE TECH3' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 1.5, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.80 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
            { UCBC, 'UnitCapCheckLess', { 0.94 } },
        },
        BuilderType = 'Land',
    },
}
-- ===================================================-======================================================== --
-- ==                                         Land Formbuilder                                               == --
-- ===================================================-======================================================== --
-- =============== --
--    PanicZone    --
-- =============== --
BuilderGroup {
    BuilderGroupName = 'Land FormBuilders Panic',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U123 AntiCDR PANIC',                                     -- Random Builder Name.
        PlatoonTemplate = 'LandAttackInterceptUveso 2 5',                       -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 90,                                                          -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed with this template.
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                       -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
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
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 10,                                                     -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'EXPERIMENTAL',
                'MOBILE LAND INDIRECTFIRE',
                'MOBILE LAND DIRECTFIRE',
                'STRUCTURE DEFENSE',
                'MOBILE LAND ANTIAIR',
                'STRUCTURE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 PANIC 2 20',                                        -- Random Builder Name.
        PlatoonTemplate = 'LandAttackInterceptUveso 2 20',                      -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 10,                                                     -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'EXPERIMENTAL',
                'MOBILE LAND INDIRECTFIRE',
                'MOBILE LAND DIRECTFIRE',
                'STRUCTURE DEFENSE',
                'MOBILE LAND ANTIAIR',
                'STRUCTURE ANTIAIR',
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
        Priority = 0,                                                            -- Priority. 1000 is normal.
        InstanceCount = 0,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'EXPERIMENTAL',
                'MOBILE LAND INDIRECTFIRE',
                'MOBILE LAND DIRECTFIRE',
                'STRUCTURE DEFENSE',
                'MOBILE LAND ANTIAIR',
                'STRUCTURE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- ================== --
--    MilitaryZone    --
-- ================== --
BuilderGroup {
    BuilderGroupName = 'Land FormBuilders MilitaryZone',                        -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U123 Military 10 10',                                    -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 10 10',                          -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 70,                                                          -- Priority. 1000 is normal.
        InstanceCount = 4,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 200,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT + categories.STRUCTURE - categories.NAVAL, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'EXPERIMENTAL',
                'MOBILE LAND INDIRECTFIRE',
                'MOBILE LAND DIRECTFIRE',
                'MOBILE LAND ANTIAIR',
                'STRUCTURE DEFENSE',
                'STRUCTURE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.LAND - categories.SCOUT + categories.STRUCTURE - categories.NAVAL}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- =============== --
--    EnemyZone    --
-- =============== --
BuilderGroup {
    BuilderGroupName = 'Land FormBuilders EnemyZone',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U123 AntiMass Enemy 10 10',                              -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 10 10',                          -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 60,                                                          -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = false,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MASSEXTRACTION + categories.STRUCTURE - categories.NAVAL, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'MASSEXTRACTION TECH1',
                'MASSEXTRACTION TECH2',
                'MASSEXTRACTION TECH3',
                'STRUCTURE TECH1',
                'STRUCTURE TECH2',
                'STRUCTURE TECH3',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , 'MASSEXTRACTION' } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Enemy 10 10',                                       -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 10 10',                          -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 50,                                                          -- Priority. 1000 is normal.
        InstanceCount = 20,                                                     -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 200,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT + categories.STRUCTURE - categories.NAVAL, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'EXPERIMENTAL',
                'MOBILE LAND INDIRECTFIRE',
                'MOBILE LAND DIRECTFIRE',
                'STRUCTURE DEFENSE',
                'MOBILE LAND ANTIAIR',
                'STRUCTURE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- ================= --
    --    Finish him!    --
    -- ================= --
    Builder {
        BuilderName = 'U123 Kill Them All!!! STR 10 10',
        PlatoonTemplate = 'LandAttackHuntUveso 10 10',                          -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 40,                                                          -- Priority. 1000 is normal.
        InstanceCount = 20,                                                     -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 200,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE * categories.LAND + categories.STRUCTURE - categories.NAVAL, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'EXPERIMENTAL',
                'STRUCTURE TECH1',
                'STRUCTURE TECH2',
                'STRUCTURE TECH3',
                'MOBILE LAND INDIRECTFIRE',
                'MOBILE LAND DIRECTFIRE',
                'MOBILE LAND ANTIAIR',
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
    -- =============================== --
    --    Big LandInterceptor groups   --
    -- =============================== --
    Builder {
        BuilderName = 'U123 BigIntercept 30 500',
        PlatoonTemplate = 'LandAttackInterceptUveso 30 500',                     -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 30,                                                          -- Priority. 1000 is normal.
        InstanceCount = 20,                                                     -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 200,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE * categories.LAND + categories.STRUCTURE - categories.NAVAL, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'EXPERIMENTAL',
                'STRUCTURE TECH3',
                'STRUCTURE TECH2',
                'STRUCTURE TECH1',
                'MOBILE LAND INDIRECTFIRE',
                'MOBILE LAND DIRECTFIRE',
                'MOBILE LAND ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 30, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER}},
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , 'STUCTURE, MOBILE' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- ================== --
    --    Trash Tech 1    --
    -- ================== --
    Builder {
        BuilderName = 'U12 UnitCap Ground',
        PlatoonTemplate = 'U12-LandCap 1 500',                     -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 30,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                     -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 200,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE * categories.LAND + categories.STRUCTURE - categories.NAVAL, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 20, categories.MOBILE * categories.LAND * categories.TECH3 }},
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- =============================== --
    --    Paragon  --
    -- =============================== --
    Builder {
        BuilderName = 'U123 Paragon 30 500',
        PlatoonTemplate = 'LandAttackInterceptUveso 30 500',                     -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 30,                                                          -- Priority. 1000 is normal.
        InstanceCount = 20,                                                     -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 200,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE * categories.LAND + categories.STRUCTURE - categories.NAVAL, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'FACTORY TECH3',
                'STRUCTURE EXPERIMENTAL',
                'STRUCTURE TECH3',
                'STRUCTURE',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}

