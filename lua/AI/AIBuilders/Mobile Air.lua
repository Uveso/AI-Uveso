local categories = categories
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua').GetDangerZoneRadii()

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

-- ===================================================-======================================================== --
-- ==                           Adaptive - Air Fighter/Bomber T1 T2 T3 Builder                               == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U123 Air Builders ADAPTIVE',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U1A Interceptors Minimum',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.ANTIAIR }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1A Bomber Minimum',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.MOBILE * categories.AIR  * categories.BOMBER }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1A Interceptors',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.MOBILE * categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD } },
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER, '<=', categories.MOBILE * categories.AIR } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1A Gunship',
        PlatoonTemplate = 'T1Gunship',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.5, categories.MOBILE * categories.AIR * categories.GROUNDATTACK, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.BOMBER - categories.GROUNDATTACK } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1A Bomber',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.3, categories.MOBILE * categories.AIR * categories.BOMBER, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2A Air Fighter',
        PlatoonTemplate = 'T2FighterBomber',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.11, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 15, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.BOMBER * categories.TECH2 }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.MOBILE * categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2A Air Gunship',
        PlatoonTemplate = 'T2AirGunship',
        Priority = 360,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech2 or aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 360
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.11, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 }},
            { UCBC, 'HaveUnitRatioUveso', { 0.5, categories.MOBILE * categories.AIR * categories.GROUNDATTACK, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.BOMBER - categories.GROUNDATTACK } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2A TorpedoBomber',
        PlatoonTemplate = 'T2AirTorpedoBomber',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.11, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 11, categories.MOBILE * categories.AIR * categories.ANTINAVY }},
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NAVAL } },
            { UCBC, 'HaveUnitRatioUveso', { 0.5, categories.MOBILE * categories.AIR * categories.ANTINAVY, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2A TorpedoBomber AntiNukeSub',
        PlatoonTemplate = 'T2AirTorpedoBomber',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech2 or aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.11, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NUKESUB } },
            { UCBC, 'HaveUnitRatioUveso', { 8.0, categories.MOBILE * categories.AIR * categories.ANTINAVY, '<',categories.NUKESUB } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2A TorpedoBomber WaterMap',
        PlatoonTemplate = 'T2AirTorpedoBomber',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { false, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.11, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 80, categories.MOBILE * categories.AIR * categories.ANTINAVY }},
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NAVAL } },
            { UCBC, 'HaveUnitRatioUveso', { 0.5, categories.MOBILE * categories.AIR * categories.ANTINAVY, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3A Air Fighter min',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 360,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 360
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR * categories.TECH3 - categories.GROUNDATTACK }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3A Air Gunship min',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 360,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 360
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 - categories.HIGHALTAIR }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3A Air Fighter always',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.AIR * categories.HIGHALTAIR } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3A Air Fighter ratio',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER, '<=', categories.MOBILE * categories.AIR } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3A Air Gunship always',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 340,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 340
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.AIR * categories.GROUNDATTACK } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3A Air Gunship ratio',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 340,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 340
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.5, categories.MOBILE * categories.AIR * categories.GROUNDATTACK, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.BOMBER - categories.GROUNDATTACK } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3A Air Bomber',
        PlatoonTemplate = 'T3AirBomber',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.1, categories.MOBILE * categories.AIR * categories.BOMBER, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3A TorpedoBomber',
        PlatoonTemplate = 'T3TorpedoBomber',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.3, categories.MOBILE * categories.AIR * categories.ANTINAVY, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3A TorpedoBomber AntiNukeSub',
        PlatoonTemplate = 'T3TorpedoBomber',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NUKESUB } },
            { UCBC, 'HaveUnitRatioUveso', { 8.0, categories.MOBILE * categories.AIR * categories.ANTINAVY, '<',categories.NUKESUB } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3A TorpedoBomber WaterMap',
        PlatoonTemplate = 'T3TorpedoBomber',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { false, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.5, categories.MOBILE * categories.AIR * categories.ANTINAVY, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
}
-- ===================================================-======================================================== --
-- ==                              Rush - Air Fighter/Bomber T1 T2 T3 Builder                                == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U123 Air Builders RUSH',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U1R Interceptors Minimum',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.ANTIAIR }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1R Bomber Minimum',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.MOBILE * categories.AIR  * categories.BOMBER }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1R Interceptors',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.MOBILE * categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD } },
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER, '<=', categories.MOBILE * categories.AIR } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1R Gunship',
        PlatoonTemplate = 'T1Gunship',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.5, categories.MOBILE * categories.AIR * categories.GROUNDATTACK, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.BOMBER - categories.GROUNDATTACK } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1R Bomber',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.3, categories.MOBILE * categories.AIR * categories.BOMBER, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2R Air Fighter',
        PlatoonTemplate = 'T2FighterBomber',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 15, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.BOMBER * categories.TECH2 }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.MOBILE * categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2R Air Gunship',
        PlatoonTemplate = 'T2AirGunship',
        Priority = 360,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech2 or aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 360
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 }},
            { UCBC, 'HaveUnitRatioUveso', { 0.5, categories.MOBILE * categories.AIR * categories.GROUNDATTACK, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.BOMBER - categories.GROUNDATTACK } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2R TorpedoBomber',
        PlatoonTemplate = 'T2AirTorpedoBomber',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 11, categories.MOBILE * categories.AIR * categories.ANTINAVY }},
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NAVAL } },
            { UCBC, 'HaveUnitRatioUveso', { 0.5, categories.MOBILE * categories.AIR * categories.ANTINAVY, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2R TorpedoBomber AntiNukeSub',
        PlatoonTemplate = 'T2AirTorpedoBomber',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech2 or aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NUKESUB } },
            { UCBC, 'HaveUnitRatioUveso', { 8.0, categories.MOBILE * categories.AIR * categories.ANTINAVY, '<',categories.NUKESUB } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2R TorpedoBomber WaterMap',
        PlatoonTemplate = 'T2AirTorpedoBomber',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { false, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 80, categories.MOBILE * categories.AIR * categories.ANTINAVY }},
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NAVAL } },
            { UCBC, 'HaveUnitRatioUveso', { 0.5, categories.MOBILE * categories.AIR * categories.ANTINAVY, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3R Air Fighter min',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 360,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 360
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR * categories.TECH3 - categories.GROUNDATTACK }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3R Air Gunship min',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 360,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 360
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 - categories.HIGHALTAIR }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3R Air Fighter',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER, '<=', categories.MOBILE * categories.AIR } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3R Air Gunship',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 340,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 340
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.5, categories.MOBILE * categories.AIR * categories.GROUNDATTACK, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.BOMBER - categories.GROUNDATTACK } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3R Air Bomber',
        PlatoonTemplate = 'T3AirBomber',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.1, categories.MOBILE * categories.AIR * categories.BOMBER, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3R TorpedoBomber',
        PlatoonTemplate = 'T3TorpedoBomber',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.3, categories.MOBILE * categories.AIR * categories.ANTINAVY, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3R TorpedoBomber AntiNukeSub',
        PlatoonTemplate = 'T3TorpedoBomber',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NUKESUB } },
            { UCBC, 'HaveUnitRatioUveso', { 8.0, categories.MOBILE * categories.AIR * categories.ANTINAVY, '<',categories.NUKESUB } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3R TorpedoBomber WaterMap',
        PlatoonTemplate = 'T3TorpedoBomber',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { false, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.5, categories.MOBILE * categories.AIR * categories.ANTINAVY, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
}
-- ===================================================-======================================================== --
-- ==                                 Air Fighter/Bomber T1 T2 T3 Builder                                    == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U123 Air Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- =========================== --
    --    TECH 1   MilitaryZone    --
    -- =========================== --
    Builder {
        BuilderName = 'U1 MilitaryZone Fighter',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 18500,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech1 then
                return 18500
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.ANTIAIR }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.TECH3 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1 MilitaryZone Bomber',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 18500,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech1 then
                return 18500
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.95 } },
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.BOMBER }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U1 Interceptors Minimum',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.ANTIAIR }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1 Bomber Minimum',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.MOBILE * categories.AIR  * categories.BOMBER }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'U1 Interceptors',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.MOBILE * categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH1 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
             -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1 Gunship',
        PlatoonTemplate = 'T1Gunship',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH1 }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.MOBILE * categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.MOBILE * categories.AIR  * categories.GROUNDATTACK }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioUveso', { 1.0, categories.MOBILE * categories.AIR * categories.GROUNDATTACK, '<',categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1 Bomber',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.MOBILE * categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH1 }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.MOBILE * categories.AIR  * categories.BOMBER }},
            { UCBC, 'HaveUnitRatioUveso', { 1.0, categories.MOBILE * categories.AIR * categories.BOMBER, '<',categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2 Air Fighter',
        PlatoonTemplate = 'T2FighterBomber',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 15, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.BOMBER * categories.TECH2 }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2 Air Gunship',
        PlatoonTemplate = 'T2AirGunship',
        Priority = 360,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech2 or aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 360
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2 TorpedoBomber < 20',
        PlatoonTemplate = 'T2AirTorpedoBomber',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 }},
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NAVAL } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.MOBILE * categories.AIR * categories.ANTINAVY }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.ANTINAVY * categories.TECH3 }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2 TorpedoBomber AntiNukeSub',
        PlatoonTemplate = 'T2AirTorpedoBomber',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech2 or aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NUKESUB } },
            { UCBC, 'HaveUnitRatioUveso', { 8.0, categories.MOBILE * categories.AIR * categories.ANTINAVY, '<',categories.NUKESUB } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2 TorpedoBomber WaterMap',
        PlatoonTemplate = 'T2AirTorpedoBomber',
        Priority = 360,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech2 then
                return 360
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { false, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 80, categories.MOBILE * categories.AIR * categories.ANTINAVY }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.ANTINAVY * categories.TECH3 }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3 Air Fighter min',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 370,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 370
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR * categories.TECH3 - categories.GROUNDATTACK }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3 Air Gunship min',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 370,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 370
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 - categories.HIGHALTAIR }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3 Air Fighter < Gunship',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 2.50, categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR - categories.GROUNDATTACK, '<=',categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.HIGHALTAIR } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3 Air Gunship < Fighter',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 2.50, categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR - categories.GROUNDATTACK, '>=',categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.HIGHALTAIR } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3 Air Bomber < 20',
        PlatoonTemplate = 'T3AirBomber',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.MOBILE * categories.AIR * categories.BOMBER }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.EXPERIMENTAL }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.MOBILE * categories.AIR  * categories.BOMBER }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3 TorpedoBomber < 20',
        PlatoonTemplate = 'T3TorpedoBomber',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.MOBILE * categories.AIR * categories.ANTINAVY }},
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NAVAL } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.EXPERIMENTAL }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.MOBILE * categories.AIR  * categories.ANTINAVY }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3 TorpedoBomber AntiNukeSub',
        PlatoonTemplate = 'T3TorpedoBomber',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NUKESUB } },
            { UCBC, 'HaveUnitRatioUveso', { 8.0, categories.MOBILE * categories.AIR * categories.ANTINAVY, '<',categories.NUKESUB } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3 TorpedoBomber WaterMap',
        PlatoonTemplate = 'T3TorpedoBomber',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileAirTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { false, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 30.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
}
BuilderGroup {
    BuilderGroupName = 'U123 Air Builders Anti-Experimental',                   -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2E Air Gunship',
        PlatoonTemplate = 'T2AirGunship',
        Priority = 370,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 - categories.HIGHALTAIR }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 50, categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.HIGHALTAIR }},
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.MOBILE * categories.LAND * categories.EXPERIMENTAL } },
            { UCBC, 'HaveUnitRatioVersusEnemy', { 30.0, categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.HIGHALTAIR, '<=', categories.MOBILE * categories.LAND * categories.EXPERIMENTAL } },
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },

        },
        BuilderType = 'Air',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3E Air Fighter EXPResponse',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 345,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.MOBILE * categories.AIR * categories.EXPERIMENTAL } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 80, categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER }},
            { UCBC, 'HaveUnitRatioVersusEnemy', { 30.0, categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER, '<=', categories.MOBILE * categories.AIR * categories.EXPERIMENTAL } },
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3E Air Gunship EXPResponse',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 345,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.MOBILE * categories.LAND * categories.EXPERIMENTAL } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 50, categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.HIGHALTAIR }},
            { UCBC, 'HaveUnitRatioVersusEnemy', { 30.0, categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.HIGHALTAIR, '<=', categories.MOBILE * categories.LAND * categories.EXPERIMENTAL } },
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Air',
    },
}

-- ===================================================-======================================================== --
-- ==                                   AirTransport T1 T2 T3 Builder                                        == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U123 Air Transport Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============= --
    --    AllMaps    --
    -- ============= --
    Builder {
        BuilderName = 'U1 Air Transport 1st',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 18500, 
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 18500
            end
        end,
        BuilderConditions = {
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.95}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - (categories.uea0203 + categories.EXPERIMENTAL) }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.TRANSPORTFOCUS * categories.TECH1 } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1 Air Transport pool',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 400, 
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 400
            end
        end,
        BuilderConditions = {
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.95}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - categories.uea0203 } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.AIR * categories.TECH1 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - (categories.uea0203 + categories.EXPERIMENTAL)  }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U1 Air Transport requested',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 400, 
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 400
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.95}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { MIBC, 'ArmyNeedsTransports', {} },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - (categories.uea0203 + categories.EXPERIMENTAL)  }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U2 Air Transport',
        PlatoonTemplate = 'T2AirTransport',
        Priority = 500,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 500
            end
        end,
        BuilderConditions = {
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.95}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 5, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - categories.uea0203 } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - (categories.uea0203 + categories.EXPERIMENTAL) }},
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3 Air Transport',
        PlatoonTemplate = 'T3AirTransport',
        Priority = 600,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 600
            end
        end,
        BuilderConditions = {
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.95}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 8, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - categories.uea0203 } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS - (categories.uea0203 + categories.EXPERIMENTAL) }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.TRANSPORTFOCUS * categories.TECH3 } },
             -- Respect UnitCap
       },
        BuilderType = 'Air',
    },
}
-- ===================================================-======================================================== --
--                                            Air Scouts Builder                                                --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U1 Air Scout Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'U1 Air Scout',
        PlatoonTemplate = 'T1AirScout',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Scouts', 10},
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 1000
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Scouts' }},
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.AIR * categories.SCOUT }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.FACTORY * categories.AIR * categories.TECH3 } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.SCOUT } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'U3 Air Scout',
        PlatoonTemplate = 'T3AirScout',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Scouts', 10},
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 1000
            end
        end,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Scouts' }},
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.INTELLIGENCE * categories.AIR * categories.TECH3 }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.SCOUT } },
            -- Respect UnitCap
        },
        BuilderType = 'Air',
    },
}
-- ===================================================-======================================================== --
--                                          Air Scouts Formbuilder                                              --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U13 Air Scout Formers',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U1 Air Scout Form',
        PlatoonTemplate = 'T1AirScoutForm',
        Priority = 5000,
        InstanceCount = 3,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 5000
            end
        end,
        BuilderConditions = {
            -- When do we want to form this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AIR * categories.SCOUT } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U3 Air Scout Form',
        PlatoonTemplate = 'T3AirScoutForm',
        PlatoonAddBehaviors = { 'AirUnitRefit' },
        Priority = 5000,
        InstanceCount = 5,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 5000
            end
        end,
        BuilderConditions = {
            -- When do we want to form this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AIR * categories.INTELLIGENCE } },
        },
        BuilderType = 'Any',
    },
}
-- ===================================================-======================================================== --
-- ==                                      TorpedoBomber Formbuilder                                         == --
-- ===================================================-======================================================== --
-- ==================== --
--    Torpedo Bomber    --
-- ==================== --
BuilderGroup {
    BuilderGroupName = 'U123 TorpedoBomber Formers',                            -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
-- =============== --
--    PanicZone    --
-- =============== --
    Builder {
        BuilderName = 'U123 PANIC AntiSea TorpedoBomber',                       -- Random Builder Name.
        PlatoonTemplate = 'U123-TorpedoBomber 1 100',
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 90
            end
        end,
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            IgnoreTargetLayerCheck = true,                                      -- Torpedo bomber are the only unit that can fire from AIR to SubWater level
            TargetSearchCategory = categories.NAVAL,                            -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.NAVAL }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
-- ================= --
--    AntiNukeSub    --
-- ================= --
    Builder {
        BuilderName = 'U123 TorpedoBomber AntiNukeSub',
        PlatoonTemplate = 'U123-TorpedoBomber 1 100',
        Priority = 85,
        InstanceCount = 2,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 70
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 1000000,                                      -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            IgnoreTargetLayerCheck = true,                                      -- Torpedo bomber are the only unit that can fire from AIR to SubWater level
            TargetSearchCategory = categories.NAVAL,                            -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.NUKESUB,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , categories.NUKESUB } },
        },
        BuilderType = 'Any',
    },

-- ================== --
--    MilitaryZone    --
-- ================== --
    Builder {
        BuilderName = 'U123 Military AntiSea TorpedoBomber',                    -- Random Builder Name.
        PlatoonTemplate = 'U123-TorpedoBomber 1 100',
        Priority = 80,                                                          -- Priority. 1000 is normal.
        InstanceCount = 6,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 80
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 150,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            IgnoreTargetLayerCheck = true,                                      -- Torpedo bomber are the only unit that can fire from AIR to SubWater level
            TargetSearchCategory = categories.NAVAL,                            -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL,
                categories.MOBILE * categories.NAVAL * categories.ANTIAIR,
                categories.MOBILE * categories.LAND * categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.ANTIAIR,
                categories.MOBILE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.NAVAL }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
-- =============== --
--    EnemyZone    --
-- =============== --
    Builder {
        BuilderName = 'U123 Enemy AntiStructure TorpedoBomber',
        PlatoonTemplate = 'U123-TorpedoBomber 1 100',
        Priority = 70,
        InstanceCount = 2,
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
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 150,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            IgnoreTargetLayerCheck = true,                                      -- Torpedo bomber are the only unit that can fire from AIR to SubWater level
            TargetSearchCategory = categories.NAVAL,                            -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL,
                categories.MOBILE * categories.NAVAL * categories.ANTIAIR,
                categories.STRUCTURE * categories.NAVAL * categories.FACTORY,
                categories.MOBILE * categories.NAVAL * categories.DEFENSE,
                categories.MOBILE * categories.LAND * categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.ANTIAIR,
                categories.MOBILE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , categories.STRUCTURE + categories.MOBILE } },
        },
        BuilderType = 'Any',
    },
-- ==================== --
--    Unit Cap Trasher  --
-- ==================== --
    Builder {
        BuilderName = 'U123 TorpedoBomber cap',
        PlatoonTemplate = 'U123-TorpedoBomber 1 100',
        Priority = 60,
        InstanceCount = 3,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 60
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 300,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            IgnoreTargetLayerCheck = true,                                      -- Torpedo bomber are the only unit that can fire from AIR to SubWater level
            TargetSearchCategory = categories.NAVAL,                            -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NAVAL * categories.FACTORY,
                categories.STRUCTURE * categories.NAVAL,
                categories.MOBILE * categories.LAND * categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.ANTIAIR,
                categories.MOBILE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 15, categories.MOBILE * categories.AIR * categories.ANTINAVY } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U123 Torpedo Suicide',
        PlatoonTemplate = 'U123-Torpedo-Intercept 3 5',
        Priority = 50,                                                          -- Priority. 1000 is normal.
        InstanceCount = 4,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 50
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            IgnoreTargetLayerCheck = true,                                      -- Torpedo bomber are the only unit that can fire from AIR to SubWater level
            TargetSearchCategory = categories.NAVAL,                            -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NAVAL * categories.FACTORY,
                categories.STRUCTURE * categories.NAVAL,
                categories.MOBILE * categories.LAND * categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.ANTIAIR,
                categories.MOBILE,
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
-- ===================================================-======================================================== --
-- ==                                          Air Formbuilder                                               == --
-- ===================================================-======================================================== --
-- =============== --
--    PanicZone    --
-- =============== --
BuilderGroup {
    BuilderGroupName = 'U123 Air Formers PanicZone',                            -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U123 PanicZone Fighter',                                 -- Random Builder Name.
        PlatoonTemplate = 'U123-Fighter 1 500',                                 -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
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
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.AIR - categories.SCOUT - categories.POD, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.AIR - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 PanicZone Gunship',                                 -- Random Builder Name.
        PlatoonTemplate = 'U123-Gunship 1 500',                                 -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
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
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE - categories.SCOUT - categories.POD,        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.AIR,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 PanicZone Bomber',                                  -- Random Builder Name.
        PlatoonTemplate = 'U123-Bomber 1 500',                                  -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
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
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE - categories.AIR - categories.SCOUT, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE - categories.AIR - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 PanicZone FighterBomber',                           -- Random Builder Name.
        PlatoonTemplate = 'U123-FighterBomber 1 500',                           -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
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
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE - categories.SCOUT - categories.POD,        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.AIR,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.ALLUNITS,
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
    BuilderGroupName = 'U123 Air Formers MilitaryZone',                         -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.

-- AntiExperimental

    Builder {
        BuilderName = 'U123 AntiExperimental Fighter',                          -- Random Builder Name.
        PlatoonTemplate = 'U123-Fighter 1 500',                                 -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 89,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 89
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.EXPERIMENTAL * categories.AIR,    -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.EXPERIMENTAL * categories.AIR }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 AntiExperimental Gunship',                          -- Random Builder Name.
        PlatoonTemplate = 'U123-Gunship 1 500',                                 -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 89,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 89
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.EXPERIMENTAL,                     -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.AIR,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 AntiExperimental Bomber',                           -- Random Builder Name.
        PlatoonTemplate = 'U123-Bomber 1 500',                                  -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 89,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 89
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.EXPERIMENTAL - categories.AIR,    -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.EXPERIMENTAL - categories.AIR }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 AntiExperimental FighterBomber',                    -- Random Builder Name.
        PlatoonTemplate = 'U123-FighterBomber 1 500',                           -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 89,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 89
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.EXPERIMENTAL,                     -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.AIR,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },

-- AntiAir

    Builder {
        BuilderName = 'U123 Military AntiAir 10',
        PlatoonTemplate = 'U123-Fighter-Intercept 10',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 80,                                                          -- Priority. 1000 is normal.
        InstanceCount = 4,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 80
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius from main base for new target. (A 5x5 Map is 256 high)
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AttackEnemyStrength = 1000000,                                      -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                              -- If true, the platoon will not use AI pathmarkers and move directly to the target
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            TargetSearchCategory = categories.MOBILE * categories.AIR - categories.SCOUT - categories.POD, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.EXPERIMENTAL,
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR * categories.BOMBER,
                categories.MOBILE * categories.AIR * categories.GROUNDATTACK,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.MOBILE * categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Military AntiAir 20',
        PlatoonTemplate = 'U123-Fighter-Intercept 20',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 81,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 81
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius from main base for new target. (A 5x5 Map is 256 high)
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AttackEnemyStrength = 200,                                           -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            TargetSearchCategory = categories.MOBILE * categories.AIR - categories.SCOUT - categories.POD, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.EXPERIMENTAL,
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR * categories.BOMBER,
                categories.MOBILE * categories.AIR * categories.GROUNDATTACK,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.MOBILE * categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Military AntiAir 30 50',
        PlatoonTemplate = 'U123-Fighter-Intercept 30 50',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 82,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 82
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius from main base for new target. (A 5x5 Map is 256 high)
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AttackEnemyStrength = 300,                                           -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            TargetSearchCategory = categories.MOBILE * categories.AIR - categories.SCOUT - categories.POD, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.EXPERIMENTAL,
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR * categories.BOMBER,
                categories.MOBILE * categories.AIR * categories.GROUNDATTACK,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.MOBILE * categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Military AntiTransport',
        PlatoonTemplate = 'U123-MilitaryAntiTransport 1 12',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 85,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 85
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 300,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.AIR - categories.SCOUT - categories.POD, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR * categories.BOMBER,
                categories.MOBILE * categories.AIR * categories.ANTIAIR,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Military AntiBomber',
        PlatoonTemplate = 'U123-MilitaryAntiBomber 1 12',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 85,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 85
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 300,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.AIR - categories.SCOUT - categories.POD, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.AIR * categories.BOMBER,
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR * categories.ANTIAIR,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR * categories.BOMBER }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },

-- AntiLand
    Builder {
        BuilderName = 'U123 Military AntiArty 1 2',                             -- Random Builder Name.
        PlatoonTemplate = 'U123-Bomber-Intercept 1 2',                          -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesAir.lua"
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 92,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 92
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 500,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.AIR - categories.SCOUT,      -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.ANTIAIR,
                categories.INDIRECTFIRE * categories.TECH3,
                categories.INDIRECTFIRE * categories.TECH2,
                categories.INDIRECTFIRE * categories.TECH1,
                categories.COMMAND,
                categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD,
                categories.SHIELD,
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
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.LAND * categories.INDIRECTFIRE }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Military AntiGround',                               -- Random Builder Name.
        PlatoonTemplate = 'U123-Gunship-Intercept 3 5',                  -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesAir.lua"
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 80,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
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
            AggressiveMove = false,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 200,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.SCOUT - categories.POD,      -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.LAND * categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.COMMAND,
                categories.EXPERIMENTAL,
                categories.ANTIAIR,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ENERGYPRODUCTION,
                categories.MASSEXTRACTION,
                categories.FACTORY,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE - categories.AIR - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- =============== --
--    EnemyZone    --
-- =============== --
BuilderGroup {
    BuilderGroupName = 'U123 Air Formers EnemyZone',                            -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
-- AntiAir
    Builder {
        BuilderName = 'U123 Enemy ScoutHunter EnemyZone 1 2',                         -- Random Builder Name.
        PlatoonTemplate = 'U123-Fighter-Intercept 1 2',                         -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesAir.lua"
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 66,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 66
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius from main base for new target. (A 5x5 Map is 256 high)
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AttackEnemyStrength = 200,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.AIR * categories.SCOUT,           -- Only find targets matching these categories.
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
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.AIR * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 60, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.EXPERIMENTAL - categories.SCOUT }},
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Enemy AntiAir EnemyZone',                                 -- Random Builder Name.
        PlatoonTemplate = 'U123-Fighter-Intercept 3 5',                         -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesAir.lua"
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 64,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 64
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius from main base for new target. (A 5x5 Map is 256 high)
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AttackEnemyStrength = 80,                                           -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            IgnorePathing = false,                                              -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.AIR - categories.SCOUT - categories.POD,      -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.EXPERIMENTAL * categories.AIR,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.MOBILE * categories.AIR * categories.ANTIAIR,
                categories.MOBILE * categories.AIR * categories.BOMBER,
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR * categories.GROUNDATTACK,
                categories.MOBILE * categories.AIR * categories.DIRECTFIRE,
                categories.MOBILE * categories.AIR * categories.INDIRECTFIRE,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.AIR * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 60, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.EXPERIMENTAL - categories.SCOUT }},
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
-- AntiLand
    Builder {
        BuilderName = 'U12 Enemy AntiMass Gunship',                                   -- Random Builder Name.
        PlatoonTemplate = 'U12-Gunship-Intercept 3 5',                          -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesAir.lua"
        Priority = 67,                                                          -- Priority. 1000 is normal.
        InstanceCount = 4,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 67
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 33,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.SCOUT - categories.POD,      -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MASSEXTRACTION,
                categories.OPTICS,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.MASSEXTRACTION,
                categories.COMMAND,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.SHIELD,
                categories.ANTIAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
            -- When do we want to form this ?
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U12 Enemy AntiMass Bomber 3 5',                                   -- Random Builder Name.
        PlatoonTemplate = 'U12-Bomber-Intercept 3 5',                          -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesAir.lua"
        Priority = 67,                                                          -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 67
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 33,                                           -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                              -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.AIR - categories.SCOUT,      -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MASSEXTRACTION,
                categories.OPTICS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.MASSEXTRACTION,
                categories.SHIELD,
                categories.ANTIAIR,
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
            -- When do we want to form this ?
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U12 Enemy Unprotected Gunship 3 5',                            -- Random Builder Name.
        PlatoonTemplate = 'U12-Gunship-Intercept 3 5',                          -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesAir.lua"
        Priority = 68,                                                          -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 68
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 0,                                            -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                              -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.SCOUT - categories.POD,      -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MASSEXTRACTION,
                categories.OPTICS,
                categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD,
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
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.MASSEXTRACTION,
                categories.COMMAND,
                categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD,
                categories.SHIELD,
                categories.ANTIAIR,
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
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
            -- When do we want to form this ?
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U12 Enemy Unprotected Bomber 1 3',                             -- Random Builder Name.
        PlatoonTemplate = 'U12-Bomber-Intercept 1 3',                           -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesAir.lua"
        Priority = 68,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 68
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 0,                                            -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                              -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.AIR - categories.SCOUT,      -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MASSEXTRACTION,
                categories.OPTICS,
                categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD,
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
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.COMMAND,
                categories.ANTIAIR,
                categories.OPTICS,
                categories.MASSEXTRACTION,
                categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD,
                categories.SHIELD,
                categories.ANTIAIR,
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
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
            -- When do we want to form this ?
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Enemy AntiGround Bomber',                                 -- Random Builder Name.
        PlatoonTemplate = 'U123-Bomber-Intercept 15 20',                        -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesAir.lua"
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 62,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 62
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                              -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.AIR - categories.SCOUT,      -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL* categories.SHIELD,
                categories.OPTICS,
                categories.STRUCTURE * categories.ARTILLERY,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.FACTORY * categories.TECH3,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.COMMAND,
                categories.ANTIAIR,
                categories.OPTICS,
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
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 30, categories.MOBILE * categories.AIR * categories.BOMBER - categories.EXPERIMENTAL }},
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Enemy AntiGround Gunship',                                 -- Random Builder Name.
        PlatoonTemplate = 'U123-Gunship-Intercept 15 20',                        -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesAir.lua"
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               -- Adds a ForkThread() to this platton. See: "AIBehaviors.lua"
        Priority = 60,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 60
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                              -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.SCOUT - categories.POD,      -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.MASSEXTRACTION * categories.TECH3,
                categories.STRUCTURE * categories.MASSEXTRACTION * categories.TECH2,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.OPTICS,
                categories.STRUCTURE * categories.ARTILLERY,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.FACTORY * categories.TECH3,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.COMMAND,
                categories.ANTIAIR,
                categories.OPTICS,
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
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 30, categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.EXPERIMENTAL }},
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- ==================== --
--    Unit Cap Trasher  --
-- ==================== --
BuilderGroup {
    BuilderGroupName = 'U123 Air Formers Trasher',                              -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U1234 Bomber > 50',
        PlatoonTemplate = 'U123-Bomber-Intercept 1 50',
        Priority = 50,                                                        -- Priority. 1000 is normal.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 50
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.AIR - categories.SCOUT,      -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MASSEXTRACTION,
                categories.OPTICS,
                categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD,
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
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.COMMAND,
                categories.ANTIAIR,
                categories.OPTICS,
                categories.STRUCTURE * categories.EXPERIMENTAL* categories.SHIELD,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.MASSEXTRACTION,
                categories.STRUCTURE * categories.ARTILLERY,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.STRUCTURE * categories.FACTORY,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 50, categories.MOBILE * categories.AIR * ( categories.GROUNDATTACK + categories.BOMBER ) - categories.EXPERIMENTAL - categories.ANTINAVY }},
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U12 Cap AntiAir TECH3 5+',
        PlatoonTemplate = 'U12-AntiAirCap 1 500',
        Priority = 50,                                                          -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 50
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                              -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.AIR - categories.SCOUT - categories.POD,      -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.ANTIAIR,
                categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.MOBILE * categories.AIR * categories.TECH3 }},
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U12 Cap AntiGround TECH3 5+',
        PlatoonTemplate = 'U12-AntiGroundCap 1 500',
        Priority = 50,                                                        -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 50
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.AIR - categories.SCOUT - categories.POD,      -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.OPTICS,
                categories.MASSEXTRACTION,
                categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD,
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
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.COMMAND,
                categories.ANTIAIR,
                categories.OPTICS,
                categories.STRUCTURE * categories.EXPERIMENTAL* categories.SHIELD,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.MASSEXTRACTION,
                categories.STRUCTURE * categories.ARTILLERY,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.STRUCTURE * categories.FACTORY,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.MOBILE * categories.AIR * categories.TECH3 - categories.HIGHALTAIR }},
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Cap Fighter 30',
        PlatoonTemplate = 'U123-Fighter-Intercept 1 30',
        Priority = 50,                                                        -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 50
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                              -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.AIR - categories.POD,                              -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL * categories.AIR,
                categories.ANTIAIR * categories.AIR,
                categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitCapCheckGreater', { 0.90 } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.HIGHALTAIR }},
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Cap Fighter 50',
        PlatoonTemplate = 'U123-Fighter-Intercept 1 50',
        Priority = 50,                                                        -- Priority. 1000 is normal.
        InstanceCount = 4,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 50
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.AIR - categories.POD,                              -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL * categories.AIR,
                categories.ANTIAIR * categories.AIR,
                categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 70, categories.MOBILE * categories.AIR * categories.HIGHALTAIR }},
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Cap Gunship',
        PlatoonTemplate = 'U123-Gunship-Intercept 1 50',
        Priority = 50,                                                        -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 50
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            DirectMoveEnemyBase = true, 
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.SCOUT - categories.POD,      -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MASSEXTRACTION,
                categories.OPTICS,
                categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD,
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
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.COMMAND,
                categories.ANTIAIR,
                categories.OPTICS,
                categories.STRUCTURE * categories.EXPERIMENTAL* categories.SHIELD,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.MASSEXTRACTION,
                categories.STRUCTURE * categories.ARTILLERY,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.STRUCTURE * categories.FACTORY,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitCapCheckGreater', { 0.90 } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 AirSuicide 5 10',                                  -- Random Builder Name.
        PlatoonTemplate = 'U123-AirSuicide 5 10',                             -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 30,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 30
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            DirectMoveEnemyBase = true, 
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE,        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.OPTICS,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.ARTILLERY - categories.TECH1 - categories.TECH2,
                categories.STRUCTURE * categories.MASSEXTRACTION * categories.TECH3,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH2,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH1,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.COMMAND,
                categories.ANTIAIR,
                categories.OPTICS,
                categories.STRUCTURE * categories.EXPERIMENTAL* categories.SHIELD,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.MASSEXTRACTION,
                categories.STRUCTURE * categories.ARTILLERY,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.STRUCTURE * categories.FACTORY,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitCapCheckGreater', { 0.75 } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    -- ============ --
    --    SNIPE     --
    -- ============ --
    Builder {
        BuilderName = 'U123 engineer Bomber',                                   -- Random Builder Name.
        PlatoonTemplate = 'U123-Bomber-Intercept 1 2',                          -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesAir.lua"
        Priority = 89,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 89
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 10,                                           -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                              -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.AIR - categories.SCOUT,      -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.ENGINEER - categories.POD,
                categories.MASSEXTRACTION,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.MOBILE * categories.ENGINEER - categories.POD,
                categories.MASSEXTRACTION,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 FighterBomber ACU',                                 -- Random Builder Name.
        PlatoonTemplate = 'U2-FighterBomber 13 15',                             -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesAir.lua"
        Priority = 89,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 89
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 1000000,                                      -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                              -- If true, the platoon will not use AI pathmarkers and move directly to the target
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
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.COMMAND } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}


