local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua').GetDangerZoneRadii(true)

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

-- ===================================================-======================================================== --
--                                           LAND Scouts Builder                                                --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U1 Land Scout Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'U1R Land Scout',
        PlatoonTemplate = 'T1LandScout',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Scouts', 10},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.MOBILE * categories.ENGINEER}},
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.SCOUT * categories.LAND } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Scouts' }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.LAND * categories.SCOUT }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.AIR * categories.SCOUT }},
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
}
-- ===================================================-======================================================== --
-- ==                                        Build T1 T2 T3 Land                                             == --
-- ===================================================-======================================================== --
-- ============= --
--    AI-RUSH    --
-- ============= --
BuilderGroup {
    BuilderGroupName = 'U123 Land Formers RUSH',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- =========================== --
    --    TECH 1   Always          --
    -- =========================== --
    Builder {
        BuilderName = 'U1R Early Arty Always',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 18500,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.MOBILE * categories.ENGINEER } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.MOBILE * categories.INDIRECTFIRE }},
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.MOBILE * categories.INDIRECTFIRE } },
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1R Early tank Always',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 18500,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.MOBILE * categories.ENGINEER } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.MOBILE * categories.DIRECTFIRE }},
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.00 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.MOBILE * categories.DIRECTFIRE } },
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    -- =========================== --
    --    TECH 1   Early          --
    -- =========================== --
    Builder {
        BuilderName = 'U1R LABs Early',
        PlatoonTemplate = 'U1 LandDFBot',
        Priority = 19000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND) + (categories.STRUCTURE * categories.DEFENSE) } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.MOBILE * categories.ENGINEER } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.MOBILE * categories.DIRECTFIRE }},
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.LAND * categories.TECH3 - categories.ENGINEER}},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.DIRECTFIRE } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1R Artillery Early',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 18000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND) + (categories.STRUCTURE * categories.DEFENSE) } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.MOBILE * categories.ENGINEER } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.INDIRECTFIRE }},
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.LAND * categories.TECH3 - categories.ENGINEER}},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.INDIRECTFIRE } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U1R Artillery',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 150,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND) + (categories.STRUCTURE * categories.DEFENSE) } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.LAND * (categories.TECH2 + categories.TECH3) - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1R Artillery 1~2',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 550,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND) + (categories.STRUCTURE * categories.DEFENSE) } },
            { UCBC, 'HaveUnitRatioUveso', { 3.00, categories.MOBILE * categories.LAND * categories.TECH1 - categories.ENGINEER, '<=',categories.MOBILE * categories.LAND * categories.TECH2 - categories.ENGINEER } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.LAND * (categories.TECH2 + categories.TECH3) - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2R Artillery',
        PlatoonTemplate = 'T2LandArtillery',
        Priority = 250,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND) + (categories.STRUCTURE * categories.DEFENSE) } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 }},
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.LAND * categories.TECH3 - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2R Artillery 2~3',
        PlatoonTemplate = 'T2LandArtillery',
        Priority = 450,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND) + (categories.STRUCTURE * categories.DEFENSE) } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 }},
            { UCBC, 'HaveUnitRatioUveso', { 3.00, categories.MOBILE * categories.LAND * categories.TECH2 - categories.ENGINEER, '<=',categories.MOBILE * categories.LAND * categories.TECH3 - categories.ENGINEER } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.LAND * categories.TECH3 - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3R Mobile Artillery',
        PlatoonTemplate = 'T3LandArtillery',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 }},
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
}
-- ================= --
--    AI-ADAPTIVE    --
-- ================= --
BuilderGroup {
    BuilderGroupName = 'U123 Land Builders ADAPTIVE',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- =========================== --
    --    TECH 1   Early          --
    -- =========================== --
    Builder {
        BuilderName = 'U1A LABs Early',
        PlatoonTemplate = 'U1 LandDFBot',
        Priority = 19000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND) + (categories.STRUCTURE * categories.DEFENSE) } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.MOBILE * categories.ENGINEER } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.MOBILE * categories.DIRECTFIRE }},
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.DIRECTFIRE } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1A Artillery Early',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 18000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND) + (categories.STRUCTURE * categories.DEFENSE) } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.MOBILE * categories.ENGINEER } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.INDIRECTFIRE }},
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.INDIRECTFIRE } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U1A Artillery',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 150,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND) + (categories.STRUCTURE * categories.DEFENSE) } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.LAND * (categories.TECH2 + categories.TECH3) - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1A Artillery 1~2',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 550,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND) + (categories.STRUCTURE * categories.DEFENSE) } },
            { UCBC, 'HaveUnitRatioUveso', { 3.00, categories.MOBILE * categories.LAND * categories.TECH1 - categories.ENGINEER, '<=',categories.MOBILE * categories.LAND * categories.TECH2 - categories.ENGINEER } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.LAND * (categories.TECH2 + categories.TECH3) - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
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
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND) + (categories.STRUCTURE * categories.DEFENSE) } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 }},
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.LAND * categories.TECH3 - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2A Artillery 2~3',
        PlatoonTemplate = 'T2LandArtillery',
        Priority = 450,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND) + (categories.STRUCTURE * categories.DEFENSE) } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 }},
            { UCBC, 'HaveUnitRatioUveso', { 3.00, categories.MOBILE * categories.LAND * categories.TECH2 - categories.ENGINEER, '<=',categories.MOBILE * categories.LAND * categories.TECH3 - categories.ENGINEER } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.LAND * categories.TECH3 - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
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
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 }},
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
}
-- ===================================================-======================================================== --
-- ==                                         Land panic builder                                             == --
-- ===================================================-======================================================== --
-- ================================== --
--    TECH 1   PanicZone Main Base    --
-- ================================== --
BuilderGroup {
    BuilderGroupName = 'U123 Land Builders Panic',                         -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'U1 PanicZone Arty',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 18600,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 20, (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) }},
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HasNotParagon', {} },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1 PanicZone Tank',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 18600,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 20, (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) }},
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HasNotParagon', {} },
            -- Respect UnitCap
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
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 20, (categories.STRUCTURE + categories.MOBILE) * categories.ANTIAIR }},
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HasNotParagon', {} },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
}
-- ================================== --
--    TECH 1   PanicZone Expansion    --
-- ================================== --
BuilderGroup {
    BuilderGroupName = 'LandAttackBuildersPanicEXP Uveso',                         -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
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
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 10, (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1E PanicPanicExpansion AA',
        PlatoonTemplate = 'T1LandAA',
        Priority = 160,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  50, 'LocationType', 1, categories.MOBILE * categories.AIR - categories.SCOUT - categories.SATELLITE}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 10, categories.ANTIAIR }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
}
-- ===================================================-======================================================== --
-- ==                                         Land ratio builder RUSH                                        == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U123 Land Builders Ratio RUSH',                         -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U1R Ratio Tank',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 160,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 4.0, categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH1, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * (categories.TECH2 + categories.TECH3) - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1R Ratio Bot',
        PlatoonTemplate = 'T1LandDFBot',
        Priority = 160,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 2.0, categories.MOBILE * categories.LAND * categories.BOT * categories.TECH1, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            { MIBC, 'FactionIndex', { 1, 2, 3 , 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * (categories.TECH2 + categories.TECH3) - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1R Ratio AA',
        PlatoonTemplate = 'T1LandAA',
        Priority = 160,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 1.0, categories.MOBILE * categories.LAND * categories.ANTIAIR * categories.TECH1, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * (categories.TECH2 + categories.TECH3) - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2R DFTank',
        PlatoonTemplate = 'T2LandDFTank',
        Priority = 260,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 8.00, categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH2, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * categories.TECH3 - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2R AttackTank',
        PlatoonTemplate = 'T2AttackTank',
        Priority = 260,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 8.00, categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH2, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * categories.TECH3 - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2R Mobile AA',
        PlatoonTemplate = 'T2LandAA',
        Priority = 260,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 2.0, categories.MOBILE * categories.LAND * categories.ANTIAIR * categories.TECH2, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * categories.TECH3 - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3R Siege Assault Bot',
        PlatoonTemplate = 'T3LandBot',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 8.0, categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH3, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3R SniperBots',
        PlatoonTemplate = 'T3SniperBots',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 8.0, categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH3, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3R ArmoredAssault',
        PlatoonTemplate = 'T3ArmoredAssault',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 8.0, categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH3, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3R Mobile AA',
        PlatoonTemplate = 'T3LandAA',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 1.0, categories.MOBILE * categories.LAND * categories.ANTIAIR * categories.TECH3, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3R MobileShields',
        PlatoonTemplate = 'T3MobileShields',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 1.0, categories.MOBILE * categories.LAND * categories.SHIELD, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH3 } },
            { UCBC, 'HaveUnitRatioUveso', { 1.0, categories.MOBILE * categories.LAND * categories.STEALTHFIELD, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH3 } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
}
-- ===================================================-======================================================== --
-- ==                                         Land ratio builder Normal                                      == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U123 Land Builders Ratio',                         -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U1 Ratio Tank',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 160,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 4.0, categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH1, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * (categories.TECH2 + categories.TECH3) - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1 Ratio Bot',
        PlatoonTemplate = 'T1LandDFBot',
        Priority = 160,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 2.0, categories.MOBILE * categories.LAND * categories.BOT * categories.TECH1, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            { MIBC, 'FactionIndex', { 1, 2, 3 , 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * (categories.TECH2 + categories.TECH3) - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1 Ratio AA',
        PlatoonTemplate = 'T1LandAA',
        Priority = 160,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 1.0, categories.MOBILE * categories.LAND * categories.ANTIAIR * categories.TECH1, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH1 } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * (categories.TECH2 + categories.TECH3) - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2 DFTank',
        PlatoonTemplate = 'T2LandDFTank',
        Priority = 260,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 8.00, categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH2, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * categories.TECH3 - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2 AttackTank',
        PlatoonTemplate = 'T2AttackTank',
        Priority = 260,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 8.00, categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH2, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * categories.TECH3 - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2 Mobile AA',
        PlatoonTemplate = 'T2LandAA',
        Priority = 260,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 2.0, categories.MOBILE * categories.LAND * categories.ANTIAIR * categories.TECH2, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * categories.TECH3 - categories.ENGINEER}},
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3 Siege Assault Bot',
        PlatoonTemplate = 'T3LandBot',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 8.0, categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH3, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3 SniperBots',
        PlatoonTemplate = 'T3SniperBots',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 8.0, categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH3, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3 ArmoredAssault',
        PlatoonTemplate = 'T3ArmoredAssault',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 8.0, categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH3, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3 Mobile AA',
        PlatoonTemplate = 'T3LandAA',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 1.0, categories.MOBILE * categories.LAND * categories.ANTIAIR * categories.TECH3, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3 MobileShields',
        PlatoonTemplate = 'T3MobileShields',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 1.0, categories.MOBILE * categories.LAND * categories.SHIELD, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH3 } },
            { UCBC, 'HaveUnitRatioUveso', { 1.0, categories.MOBILE * categories.LAND * categories.STEALTHFIELD, '<',categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH3 } },
            -- Do we need additional conditions to build it ?
            { MIBC, 'CanPathToCurrentEnemy', { true } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Land',
    },
}
-- ===================================================-======================================================== --
--                                         Land Scouts Formbuilder                                              --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U1 Land Scout Formers',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U1 Land Scout',
        PlatoonTemplate = 'T1LandScoutForm',
        Priority = 5000,
        InstanceCount = 8,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.LAND * categories.SCOUT } },
        },
        LocationType = 'LocationType',
        BuilderType = 'Any',
    },
}
-- ===================================================-======================================================== --
-- ==                                         Land Formbuilder                                               == --
-- ===================================================-======================================================== --
-- =============== --
--    PanicZone    --
-- =============== --
BuilderGroup {
    BuilderGroupName = 'U123 Land Formers PanicZone',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U123 AntiCDR PANIC',                                     -- Random Builder Name.
        PlatoonTemplate = 'LandAttackInterceptUveso 1 100',                     -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 95,                                                          -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed with this template.
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.COMMAND,                          -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.COMMAND,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.COMMAND,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.COMMAND }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 PANIC 1 100',                                       -- Random Builder Name.
        PlatoonTemplate = 'LandAttackInterceptUveso 1 100',                     -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 12,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE - categories.SCOUT,        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- ================== --
--    MilitaryZone    --
-- ================== --
BuilderGroup {
    BuilderGroupName = 'U123 Land Formers MilitaryZone',                        -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U123 Military Mobile 8 30',                              -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 8 30',                           -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 80,                                                          -- Priority. 1000 is normal.
        InstanceCount = 4,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 200,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ANTIAIR,
                categories.MOBILE,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.EXPERIMENTAL,
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ANTIAIR,
                categories.MOBILE,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Military Structure 2 4',                            -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 2 4',                            -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 80,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                            -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 200,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.STRUCTURE - categories.NAVAL,     -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ANTIAIR,
                categories.STRUCTURE,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.EXPERIMENTAL,
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ANTIAIR,
                categories.STRUCTURE,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.STRUCTURE - categories.NAVAL}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- =============== --
--    EnemyZone    --
-- =============== --
BuilderGroup {
    BuilderGroupName = 'U123 Land Formers EnemyZone',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U123 Unprotected Land 1 2',                              -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 2 2',                            -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 75,                                                          -- Priority. 1000 is normal.
        InstanceCount = 6,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                            -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 0,                                            -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.STRUCTURE + categories.ENGINEER,                        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MASSEXTRACTION,
                categories.ENGINEER,
                categories.STRUCTURE * categories.EXPERIMENTAL* categories.SHIELD,
                categories.STRUCTURE * categories.ARTILLERY,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.FACTORY * categories.TECH3,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 ScoutHunter 2 3',                                   -- Random Builder Name.
        PlatoonTemplate = 'T1 LandIntercept 2 3',                               -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 70,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.LAND * categories.SCOUT,          -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.SCOUT,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.SCOUT,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.LAND * categories.SCOUT } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 AntiDef Early 1 20',                                -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso Arty 1 20',                      -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 70,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                            -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.DEFENSE + categories.MASSEXTRACTION, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.DEFENSE,
                categories.MASSEXTRACTION,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.DEFENSE - categories.ANTIAIR,
                categories.DEFENSE,
                categories.MASSEXTRACTION,
                categories.ALLUNITS - categories.SCOUT,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.DEFENSE + categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 AntiMass Early 1 20',                               -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso Tank 1 20',                      -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 70,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                            -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 80,                                           -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MASSEXTRACTION + categories.DEFENSE, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MASSEXTRACTION,
                categories.DEFENSE,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.DEFENSE - categories.ANTIAIR,
                categories.DEFENSE,
                categories.MASSEXTRACTION,
                categories.ALLUNITS - categories.SCOUT,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
             -- When do we want to form this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.MASSEXTRACTION + categories.DEFENSE } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Enemy 10 50',                                      -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 10 50',                         -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 70,                                                          -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                           -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = (categories.MOBILE * categories.LAND - categories.SCOUT) + (categories.STRUCTURE - categories.NAVAL), -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE,
                categories.STRUCTURE * categories.DEFENSE,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.STRUCTURE * categories.ANTIAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , (categories.MOBILE * categories.LAND - categories.SCOUT) + (categories.STRUCTURE - categories.NAVAL) } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Enemy Base 10 50',                                  -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 10 50',                          -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 60,                                                          -- Priority. 1000 is normal.
        InstanceCount = 10,                                                     -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS,                         -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.FACTORY * categories.TECH3,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH2,
                categories.STRUCTURE * categories.DEFENSE,
                categories.STRUCTURE,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.EXPERIMENTAL,
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ANTIAIR,
                categories.MOBILE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.ALLUNITS } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Enemy Base Suicide 10 50',                                  -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 10 50',                          -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 60,                                                          -- Priority. 1000 is normal.
        InstanceCount = 4,                                                     -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS,                         -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.FACTORY * categories.TECH3,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH2,
                categories.STRUCTURE * categories.DEFENSE,
                categories.STRUCTURE,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.EXPERIMENTAL,
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ANTIAIR,
                categories.MOBILE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.ALLUNITS } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- ==================== --
--    Unit Cap Trasher  --
-- ==================== --
BuilderGroup {
    BuilderGroupName = 'U123 Land Formers Trasher',                             -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U1234 Unit > 50',
        PlatoonTemplate = 'U1234-Trash Land 1 50',                               -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 60,                                                          -- Priority. 1000 is normal.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 300,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS,                         -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.FACTORY * categories.TECH3,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH2,
                categories.STRUCTURE * categories.DEFENSE,
                categories.STRUCTURE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 50, categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER }},
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U12 UnitCap Ground',
        PlatoonTemplate = 'U12-LandCap 1 50',                                   -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 60,                                                          -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS,                         -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.FACTORY * categories.TECH3,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH2,
                categories.STRUCTURE * categories.DEFENSE,
                categories.STRUCTURE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitCapCheckGreater', { 0.95 } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 UnitCap Ground',
        PlatoonTemplate = 'U123-LandCap 1 50',                                  -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 60,                                                          -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                               -- Searchradius for new target.
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS,                         -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.FACTORY * categories.TECH3,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH2,
                categories.STRUCTURE * categories.DEFENSE,
                categories.STRUCTURE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitCapCheckGreater', { 0.95 } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}

-- =========== --
--    Guards   --
-- =========== --
BuilderGroup {
    BuilderGroupName = 'U123 Land Formers Guards',                              -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'LandExperimentalGuard Uveso',
        PlatoonTemplate = 'T3ExperimentalAAGuard',
        PlatoonAIPlan = 'GuardUnit',
        Priority = 750,
        InstanceCount = 10,
        BuilderData = {
            GuardRadius = 70,
            GuardCategory = categories.MOBILE * categories.LAND * categories.EXPERIMENTAL,
            LocationType = 'LocationType',
        },
        BuilderConditions = {
            -- When do we want to form this ?
--            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.MOBILE * categories.LAND * categories.ANTIAIR - categories.SCOUT - categories.ENGINEER } },
            { UCBC, 'UnitsNeedGuard', { categories.MOBILE * categories.EXPERIMENTAL * categories.LAND} },
        },
        BuilderType = 'Any',
    },
}
