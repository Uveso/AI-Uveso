local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local IBC = '/lua/editor/InstantBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

local ExperimentalCount = 10
local mapSizeX, mapSizeZ = GetMapSize()
local BaseMilitaryZone = math.max( mapSizeX-50, mapSizeZ-50 ) / 2 -- Half the map
local BasePanicZone = BaseMilitaryZone / 2
BasePanicZone = math.max( 60, BasePanicZone )
BasePanicZone = math.min( 120, BasePanicZone )
BaseMilitaryZone = math.max( 250, BaseMilitaryZone )

-- ===================================================-======================================================== --
-- ==                                 Air Fighter/Bomber T1 T2 T3 Builder                                    == --
-- ===================================================-======================================================== --

    
BuilderGroup {
    BuilderGroupName = 'AntiAirBuilders Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- =========================== --
    --    TECH 1   MilitaryZone    --
    -- =========================== --
    Builder {
        BuilderName = 'U1 MilitaryZone AIR',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 150,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.AIR - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.TECH3 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
            { UCBC, 'HasNotParagon', {} },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Air',
    },
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U1 Interceptors Minimum',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 15,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.ANTIAIR }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.TECH3 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1 Bomber Minimum',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 150,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.MOBILE * categories.AIR  * categories.BOMBER }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.AIR * categories.BOMBER * categories.TECH3 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'U1 Interceptors',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 150,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.MOBILE * categories.ENGINEER}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH1 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1 Gunship',
        PlatoonTemplate = 'T1Gunship',
        Priority = 150,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.MOBILE * categories.AIR  * categories.GROUNDATTACK }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.MOBILE * categories.ENGINEER}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH1 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'HaveUnitRatio', { 1.0, 'MOBILE AIR GROUNDATTACK', '<','MOBILE AIR HIGHALTAIR ANTIAIR' } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1 Bomber',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 150,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.MOBILE * categories.AIR  * categories.BOMBER }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.MOBILE * categories.ENGINEER}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH1 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'HaveUnitRatio', { 1.0, 'MOBILE AIR BOMBER', '<','MOBILE AIR HIGHALTAIR ANTIAIR' } },
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Air',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2 Air Fighter < Gunship',
        PlatoonTemplate = 'T2FighterBomber',
        Priority = 250,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 }},
            { UCBC, 'HaveUnitRatio', { 4.00, 'MOBILE AIR HIGHALTAIR ANTIAIR', '<=','MOBILE AIR GROUNDATTACK' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR * categories.TECH3 }},
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.97 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2 Air Gunship < Fighter',
        PlatoonTemplate = 'T2AirGunship',
        Priority = 250,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 }},
            { UCBC, 'HaveUnitRatio', { 0.25, 'MOBILE AIR GROUNDATTACK', '<','MOBILE AIR HIGHALTAIR ANTIAIR' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 }},
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.97 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2 TorpedoBomber PANIC',
        PlatoonTemplate = 'T2AirTorpedoBomber',
        Priority = 250,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 }},
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , 'NAVAL' } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.AIR * categories.ANTINAVY * categories.TECH2 }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.MOBILE * categories.ENGINEER}},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.96 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2 TorpedoBomber < 20',
        PlatoonTemplate = 'T2AirTorpedoBomber',
        Priority = 250,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 }},
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , 'NAVAL' } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.MOBILE * categories.AIR * categories.ANTINAVY * categories.TECH2 }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.MOBILE * categories.AIR  * categories.ANTINAVY }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, 'MOBILE AIR ANTINAVY', '<=', 'NAVAL' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
            { UCBC, 'UnitCapCheckLess', { 0.96 } },
        },
        BuilderType = 'Air',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3 Air Scouts',
        PlatoonTemplate = 'T3AirScout',
        Priority = 1000,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.INTELLIGENCE * categories.AIR * categories.TECH3 }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.INTELLIGENCE * categories.AIR } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3 Air Fighter < Gunship',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 3.00, categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR * categories.TECH3 - categories.GROUNDATTACK, '<=',categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 - categories.HIGHALTAIR } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 200.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.97 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3 Air Gunship < Fighter',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatio', { 3.00, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 - categories.HIGHALTAIR, '<=',categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR * categories.TECH3 - categories.GROUNDATTACK } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 200.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.97 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3 Air Bomber < 20',
        PlatoonTemplate = 'T3AirBomber',
        Priority = 350,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.EXPERIMENTAL }},
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.MOBILE * categories.AIR * categories.BOMBER }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.MOBILE * categories.AIR  * categories.BOMBER }},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 200.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.97 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3 TorpedoBomber < 20',
        PlatoonTemplate = 'T3TorpedoBomber',
        Priority = 350,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.EXPERIMENTAL }},
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , 'NAVAL' } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.MOBILE * categories.AIR * categories.ANTINAVY }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.MOBILE * categories.AIR  * categories.ANTINAVY }},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 200.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.97 } },
        },
        BuilderType = 'Air',
    },
}
-- ===================================================-======================================================== --
-- ==                                   AirTransport T1 T2 T3 Builder                                        == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Air Transport Builder Uveso',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============= --
    --    AllMaps    --
    -- ============= --
    Builder {
        BuilderName = 'U1 Air Transport 1st',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 170, 
        DelayEqualBuildPlattons = {'Transporter', 5},
        BuilderConditions = {
            -- When do we want to build this ?
            { MIBC, 'ArmyNeedsTransports', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.90}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Transporter' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS }},
            { UCBC, 'HaveUnitRatioVersusCap', { 0.45, '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1 Air Transport 1st Island',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 170, 
        DelayEqualBuildPlattons = {'Transporter', 5},
        BuilderConditions = {
            -- When do we want to build this ?
            { MIBC, 'ArmyNeedsTransports', {} },
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.80}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Transporter' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS }},
            { UCBC, 'HaveUnitRatioVersusCap', { 0.45, '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1 Air Transport minimum',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 170, 
        DelayEqualBuildPlattons = {'Transporter', 5},
        BuilderConditions = {
            -- When do we want to build this ?
            { MIBC, 'ArmyNeedsTransports', {} },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS * categories.TECH1 }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.MOBILE * categories.AIR * categories.ANTIAIR }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.90}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Transporter' }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 4, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - categories.uea0203 }},
            { UCBC, 'HaveUnitRatioVersusCap', { 0.45, '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2 Air Transport minimum',
        PlatoonTemplate = 'T2AirTransport',
        Priority = 170,
        BuilderConditions = {
            -- When do we want to build this ?
            { MIBC, 'ArmyNeedsTransports', {} },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS * categories.TECH2 }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.MOBILE * categories.AIR * categories.ANTIAIR }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.90}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 4, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - categories.uea0203 }},
            { UCBC, 'HaveUnitRatioVersusCap', { 0.45, '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3 Air Transport minimum',
        PlatoonTemplate = 'T3AirTransport',
        Priority = 170,
        BuilderConditions = {
            -- When do we want to build this ?
            { MIBC, 'ArmyNeedsTransports', {} },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS * categories.TECH3 }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.MOBILE * categories.AIR * categories.ANTIAIR }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.90}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 4, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - categories.uea0203 }},
            { UCBC, 'HaveUnitRatioVersusCap', { 0.45, '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Air',
    },
    -- ============== --
    --    NoIsland    --
    -- ============== --
    Builder {
        BuilderName = 'U1 Air Transport NoIsland',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 170, 
        BuilderConditions = {
            -- When do we want to build this ?
            { MIBC, 'ArmyNeedsTransports', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtEnemy', { 1 , 'NAVAL' } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.MOBILE * categories.AIR * categories.ANTIAIR }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.90}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'TRANSPORTFOCUS TECH1' } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - categories.uea0203 }},
            { UCBC, 'HaveUnitRatioVersusCap', { 0.45, '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2 Air Transport NoIsland',
        PlatoonTemplate = 'T2AirTransport',
        Priority = 170,
        BuilderConditions = {
            -- When do we want to build this ?
            { MIBC, 'ArmyNeedsTransports', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtEnemy', { 1 , 'NAVAL' } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.MOBILE * categories.AIR * categories.ANTIAIR }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.90}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'TRANSPORTFOCUS TECH2' } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - categories.uea0203 }},
            { UCBC, 'HaveUnitRatioVersusCap', { 0.45, '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3 Air Transport NoIsland',
        PlatoonTemplate = 'T3AirTransport',
        Priority = 170,
        BuilderConditions = {
            -- When do we want to build this ?
            { MIBC, 'ArmyNeedsTransports', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsLessAtEnemy', { 1 , 'NAVAL' } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.MOBILE * categories.AIR * categories.ANTIAIR }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.90}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'TRANSPORTFOCUS TECH3' } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - categories.uea0203 }},
            { UCBC, 'HaveUnitRatioVersusCap', { 0.45, '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Air',
    },
    -- ============== --
    --    IsIsland    --
    -- ============== --
    Builder {
        BuilderName = 'U1 Air Transport Island',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 170,
        BuilderConditions = {
            -- When do we want to build this ?
            { MIBC, 'ArmyNeedsTransports', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , 'NAVAL' } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.MOBILE * categories.AIR * categories.ANTIAIR }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.90}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'TRANSPORTFOCUS TECH1' } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 12, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - categories.uea0203 }},
            { UCBC, 'HaveUnitRatioVersusCap', { 0.45, '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2 Air Transport Island',
        PlatoonTemplate = 'T2AirTransport',
        Priority = 170,
        BuilderConditions = {
            -- When do we want to build this ?
            { MIBC, 'ArmyNeedsTransports', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , 'NAVAL' } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.MOBILE * categories.AIR * categories.ANTIAIR }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.90}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'TRANSPORTFOCUS TECH2' } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 12, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - categories.uea0203 }},
            { UCBC, 'HaveUnitRatioVersusCap', { 0.45, '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3 Air Transport Island',
        PlatoonTemplate = 'T3AirTransport',
        Priority = 170,
        BuilderConditions = {
            -- When do we want to build this ?
            { MIBC, 'ArmyNeedsTransports', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , 'NAVAL' } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.MOBILE * categories.AIR * categories.ANTIAIR }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.90}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'TRANSPORTFOCUS TECH3' } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 12, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - categories.uea0203 }},
            { UCBC, 'HaveUnitRatioVersusCap', { 0.45, '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Air',
    },
}
-- ===================================================-======================================================== --
-- ==                                          Air Formbuilder                                               == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Air FormBuilders',                                      -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    -- =============== --
    --    PanicZone    --
    -- =============== --
    Builder {
        BuilderName = 'U123 PANIC AntiGround',
        PlatoonTemplate = 'U123-PanicGround 1 500',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                       -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE - categories.AIR,          -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE LAND EXPERIMENTAL',
                'MOBILE LAND ANTIAIR',
                'MOBILE LAND INDIRECTFIRE',
                'MOBILE LAND DIRECTFIRE',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE - categories.AIR }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 PANIC AntiAir',
        PlatoonTemplate = 'U123-PanicAir 1 500',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                       -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.AIR - categories.SCOUT , -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE AIR ANTIAIR HIGHALTAIR',
                'MOBILE AIR ANTIAIR',
                'MOBILE AIR BOMBER',
                'MOBILE AIR TRANSPORTFOCUS',
                'MOBILE AIR GROUNDATTACK',
                'MOBILE AIR DIRECTFIRE',
                'MOBILE AIR INDIRECTFIRE',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.AIR }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- ================== --
    --    MilitaryZone    --
    -- ================== --
    Builder {
        BuilderName = 'U123 Military AntiTransport',
        PlatoonTemplate = 'U123-MilitaryAntiTransport 1 12',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 80,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 300,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.AIR  * categories.TRANSPORTFOCUS,          -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE AIR TRANSPORTFOCUS',
                'MOBILE AIR BOMBER',
                'MOBILE AIR ANTIAIR',
                'MOBILE AIR ANTIAIR HIGHALTAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Military AntiBomber',
        PlatoonTemplate = 'U123-MilitaryAntiBomber 1 12',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 80,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 300,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.AIR * categories.BOMBER,          -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE AIR BOMBER',
                'MOBILE AIR TRANSPORTFOCUS',
                'MOBILE AIR ANTIAIR',
                'MOBILE AIR ANTIAIR HIGHALTAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR * categories.BOMBER }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Military AntiAir',
        PlatoonTemplate = 'U123-MilitaryAntiAir 2 500',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 70,                                                          -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius from main base for new target. (A 5x5 Map is 256 high)
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AttackEnemyStrength = 300,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            TargetSearchCategory = categories.MOBILE * categories.AIR - categories.SCOUT , -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE AIR ANTIAIR HIGHALTAIR',
                'MOBILE AIR ANTIAIR',
                'MOBILE AIR BOMBER',
                'MOBILE AIR TRANSPORTFOCUS',
                'MOBILE AIR GROUNDATTACK',
                'MOBILE AIR DIRECTFIRE',
                'MOBILE AIR INDIRECTFIRE',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Military AntiArty',                                 -- Random Builder Name.
        PlatoonTemplate = 'U123-Gunship-Intercept 3 5',                         -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesAir.lua"
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 70,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 500,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                              -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH3, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'ANTIAIR LAND',
                'ANTIAIR NAVAL',
                'INDIRECTFIRE',
                'DIRECTFIRE',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH3 }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Military AntiGround',                               -- Random Builder Name.
        PlatoonTemplate = 'U123-Gunship+Bomber-Intercept 3 5',                  -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesAir.lua"
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 70,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 200,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                              -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.LAND * categories.DIRECTFIRE, -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'ANTIAIR LAND',
                'ANTIAIR NAVAL',
                'INDIRECTFIRE',
                'DIRECTFIRE',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.LAND * categories.DIRECTFIRE }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- =============== --
    --    EnemyZone    --
    -- =============== --
    Builder {
        BuilderName = 'U123 AntiAir EnemyZone',                                 -- Random Builder Name.
        PlatoonTemplate = 'U123-Fighter-Intercept 3 5',                         -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesAir.lua"
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 60,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius from main base for new target. (A 5x5 Map is 256 high)
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AttackEnemyStrength = 80,                                           -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            IgnorePathing = false,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.AIR - categories.SCOUT , -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE AIR ANTIAIR HIGHALTAIR',
                'MOBILE AIR ANTIAIR',
                'MOBILE AIR BOMBER',
                'MOBILE AIR TRANSPORTFOCUS',
                'MOBILE AIR GROUNDATTACK',
                'MOBILE AIR DIRECTFIRE',
                'MOBILE AIR INDIRECTFIRE',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 60, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.EXPERIMENTAL - categories.SCOUT }},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'UnitsLessAtEnemy', { 1 , 'MOBILE EXPERIMENTAL AIR' } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 AntiMass Bomber',                                   -- Random Builder Name.
        PlatoonTemplate = 'U123-Bomber-Intercept 3 5',                          -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesAir.lua"
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 60,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 33,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MASSEXTRACTION,                   -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'ANTIAIR LAND',
                'ANTIAIR NAVAL',
                'MASSEXTRACTION',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 30, categories.MOBILE * categories.AIR * categories.BOMBER - categories.EXPERIMENTAL }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , 'MASSEXTRACTION' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 AntiMass Gunship',                                  -- Random Builder Name.
        PlatoonTemplate = 'U123-Gunship-Intercept 3 5',                         -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesAir.lua"
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 60,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 33,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                              -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MASSEXTRACTION,                   -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'ANTIAIR LAND',
                'ANTIAIR NAVAL',
                'MASSEXTRACTION',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 30, categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , 'MASSEXTRACTION' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'UnitsLessAtEnemy', { 1 , 'MOBILE EXPERIMENTAL LAND' } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 AntiNaval',
        PlatoonTemplate = 'U123-TorpedoBomber 1 100',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 60,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE + categories.NAVAL,     -- Only find targets matching these categories.
            PrioritizedCategories = {
                'NAVAL ANTIAIR',
                'NAVAL DEFENSE',
                'MOBILE NAVAL',
                'STRUCTURE NAVAL',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , 'NAVAL' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- ====================== --
    --    AntiExperimental    --
    -- ====================== --
    Builder {
        BuilderName = 'U123 AntiExperimental Interceptor Grow',
        PlatoonTemplate = 'U123-ExperimentalAttackInterceptorGrow 3 100',
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 4,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 500,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.AIR * categories.EXPERIMENTAL, -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE AIR EXPERIMENTAL',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 AntiExperimental Bomber Grow',
        PlatoonTemplate = 'U123-ExperimentalAttackBomberGrow 3 100',
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 4,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 500,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.EXPERIMENTAL - categories.AIR, -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE LAND EXPERIMENTAL',
                'STRUCTURE LAND EXPERIMENTAL',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.EXPERIMENTAL - categories.AIR }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 AntiExperimental Gunship Grow',
        PlatoonTemplate = 'U123-ExperimentalAttackGunshipGrow 3 100',
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 4,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 500,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.EXPERIMENTAL - categories.AIR, -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE AIR EXPERIMENTAL',
                'MOBILE LAND EXPERIMENTAL',
                'STRUCTURE LAND EXPERIMENTAL',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.EXPERIMENTAL - categories.AIR}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- ================== --
    --    Trash Tech 1    --
    -- ================== --
    Builder {
        BuilderName = 'U12 UnitCap AntiAir',
        PlatoonTemplate = 'U12-AntiAirCap 1 500',
        Priority = 70,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 10000,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = 'MOBILE AIR',                                -- Only find targets matching these categories.
            PrioritizedCategories = {
                'ANTIAIR',
                'EXPERIMENTAL',
                'TECH3',
                'TECH2',
                'TECH1',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.AIR * categories.TECH3 - categories.GROUNDATTACK }},
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U12 UnitCap AntiGround 500',
        PlatoonTemplate = 'U12-AntiGroundCap 1 500',
        Priority = 70,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 10000,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = 'STRUCTURE',                                 -- Only find targets matching these categories.
            PrioritizedCategories = {
                'ANTIAIR',
                'STRUCTURE DEFENSE ANTIMISSILE TECH3',
                'STRUCTURE ARTILLERY',
                'STRUCTURE NUKE',
                'STRUCTURE ENERGYPRODUCTION TECH3',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 }},
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U12 UnitCap AntiGround 30',
        PlatoonTemplate = 'U12-AntiGroundCap 30 40',
        Priority = 70,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 10000,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = 'STRUCTURE',                                 -- Only find targets matching these categories.
            PrioritizedCategories = {
                'ANTIAIR',
                'STRUCTURE DEFENSE ANTIMISSILE TECH3',
                'STRUCTURE ARTILLERY',
                'STRUCTURE NUKE',
                'STRUCTURE ENERGYPRODUCTION TECH3',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 100, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH2 }},
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- ==================== --
    --    Kill Them All!    --
    -- ==================== --
    Builder {
        BuilderName = 'U123 Air Kill Them All!!!',
        PlatoonTemplate = 'U123-Fighter-Intercept 3 5',
        Priority = 50,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = 'MOBILE AIR',                                -- Only find targets matching these categories.
            PrioritizedCategories = {
                'ANTIAIR',
                'MOBILE AIR EXPERIMENTAL',
                'MOBILE AIR BOMBER',
                'MOBILE AIR ANTIAIR HIGHALTAIR',
                'MOBILE AIR ANTIAIR',
                'MOBILE AIR TRANSPORTFOCUS',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 2.0, 'MOBILE AIR', '>', 'MOBILE AIR' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Ground Kill Them All!!!',
        PlatoonTemplate = 'U123-Gunship+Bomber-Intercept 3 5',
        Priority = 50,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = 'STRUCTURE, MOBILE LAND',                    -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MASSEXTRACTION TECH1',
                'MASSEXTRACTION TECH2',
                'MASSEXTRACTION TECH3',
                'ANTIAIR',
                'MOBILE LAND EXPERIMENTAL',
                'STRUCTURE DEFENSE ANTIMISSILE TECH3',
                'STRUCTURE ARTILLERY',
                'STRUCTURE NUKE',
                'STRUCTURE ENERGYPRODUCTION TECH3',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 2.0, 'MOBILE LAND', '>', 'MOBILE LAND' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Torpedo Kill Them All!!!',
        PlatoonTemplate = 'U123-Torpedo-Intercept 3 5',
        Priority = 50,                                                          -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = 'STRUCTURE NAVAL, MOBILE NAVAL',-- Only find targets matching these categories.
            PrioritizedCategories = {
                'ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 2.0, 'MOBILE NAVAL', '>', 'MOBILE NAVAL' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- ==================== --
    --    Unit Cap Trasher  --
    -- ==================== --
    Builder {
        BuilderName = 'U123 Fighter Cap',
        PlatoonTemplate = 'U123-Fighter-Intercept 40 60',
        Priority = 50,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 10000,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = 'MOBILE AIR',                                -- Only find targets matching these categories.
            PrioritizedCategories = {
                'MOBILE AIR EXPERIMENTAL',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'UnitCapCheckGreater', { .95 } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Gunship+Bomber Cap',
        PlatoonTemplate = 'U123-Gunship+Bomber-Intercept 40 60',
        Priority = 50,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 200,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = 'STRUCTURE, MOBILE LAND',                    -- Only find targets matching these categories.
            PrioritizedCategories = {
                'EXPERIMENTAL SHIELD',
                'MOBILE LAND EXPERIMENTAL',
                'EXPERIMENTAL',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'UnitCapCheckGreater', { .95 } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Torpedo Cap',
        PlatoonTemplate = 'U123-Torpedo-Intercept 3 5',
        Priority = 50,                                                          -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = 'NAVAL',                                     -- Only find targets matching these categories.
            PrioritizedCategories = {
                'EXPERIMENTAL',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'UnitCapCheckGreater', { .95 } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- =============================== --
    --    Paragon  --
    -- =============================== --
    Builder {
        BuilderName = 'U123 ParagonAir 30 500',
        PlatoonTemplate = 'U123-Gunship+Bomber-Intercept 40 60',
        Priority = 50,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 500,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = 'STRUCTURE, MOBILE LAND',                    -- Only find targets matching these categories.
            PrioritizedCategories = {
                'EXPERIMENTAL SHIELD',
                'MOBILE LAND EXPERIMENTAL',
                'EXPERIMENTAL',
                'FACTORY TECH3',
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


