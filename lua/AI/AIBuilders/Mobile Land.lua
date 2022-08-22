local categories = categories
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetDangerZoneRadii(true)

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

if not categories.STEALTHFIELD then categories.STEALTHFIELD = categories.SHIELD end

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
        DelayEqualBuildPlattons = {'Scouts', 30},
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 1000
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            { UCBC, 'CheckBuildPlattonDelay', { 'Scouts' }},
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.MOBILE * categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.LAND * categories.SCOUT }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.AIR * categories.SCOUT }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.SCOUT * categories.LAND } },
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
    BuilderGroupName = 'U123 Land Builders RUSH',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --

    -- Terror builder, don't activate !!!
    Builder {
        BuilderName = 'U1R Terror mobile Arty',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 0, --160
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },

    Builder {
        BuilderName = 'U1R Tank',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1R Bot',
        PlatoonTemplate = 'T1LandDFBot',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            { MIBC, 'FactionIndex', { 1, 2, 3 , 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.2, categories.MOBILE * categories.LAND * categories.BOT * categories.TECH1, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.BOT } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1R Mobile Artillery',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.5, categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH1, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1R Mobile AA',
        PlatoonTemplate = 'T1LandAA',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.05, categories.MOBILE * categories.LAND * categories.ANTIAIR * categories.TECH1, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2R DFTank',
        PlatoonTemplate = 'T2LandDFTank',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2R AttackTank',
        PlatoonTemplate = 'T2AttackTank',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2R Mobile Artillery',
        PlatoonTemplate = 'T2LandArtillery',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.05, categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH2, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2R Mobile AA',
        PlatoonTemplate = 'T2LandAA',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.05, categories.MOBILE * categories.LAND * categories.ANTIAIR * categories.TECH2, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2R MobileShields',
        PlatoonTemplate = 'T2MobileShields',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech2 or aiBrain.PriorityManager.BuildMobileLandTech3 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconStorageRatio', { 0.0, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.1, (categories.MOBILE * categories.SHIELD) + (categories.MOBILE * categories.STEALTHFIELD), '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE } },
            -- Respect UnitCap
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            { MIBC, 'FactionIndex', { 1, 3, 4, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },
            -- When do we want to build this ?
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3R SniperBots',
        PlatoonTemplate = 'T3SniperBots',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3R ArmoredAssault',
        PlatoonTemplate = 'T3ArmoredAssault',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3R Mobile Artillery',
        PlatoonTemplate = 'T3LandArtillery',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH3 }},
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.1, categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH3, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH3 } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3R Mobile AA',
        PlatoonTemplate = 'T3LandAA',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.05, categories.MOBILE * categories.LAND * categories.ANTIAIR * categories.TECH3, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE * categories.TECH3 } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3R Mobile Shields',
        PlatoonTemplate = 'T3MobileShields',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.1, (categories.MOBILE * categories.SHIELD) + (categories.MOBILE * categories.STEALTHFIELD), '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE } },
            -- Respect UnitCap
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
    -- ============ --
    --    TECH 1    --
    -- ============ --

    -- Terror builder, don't activate !!!
    Builder {
        BuilderName = 'U1A Terror Mobile Arty',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 0,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            -- When do we want to build this ?
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },

    Builder {
        BuilderName = 'U1A Tank',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.MOBILE * categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD } },
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND * (categories.DIRECTFIRE + categories.INDIRECTFIRE)) } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1A Bot',
        PlatoonTemplate = 'T1LandDFBot',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            { MIBC, 'FactionIndex', { 1, 2, 3 , 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.2, categories.MOBILE * categories.LAND * categories.BOT * categories.TECH1, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.BOT } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1A Mobile Artillery',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.1, categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH1, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1A AA',
        PlatoonTemplate = 'T1LandAA',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.05, categories.MOBILE * categories.LAND * categories.ANTIAIR * categories.TECH1, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2A DFTank',
        PlatoonTemplate = 'T2LandDFTank',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND * (categories.DIRECTFIRE + categories.INDIRECTFIRE)) } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2A AttackTank',
        PlatoonTemplate = 'T2AttackTank',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND * (categories.DIRECTFIRE + categories.INDIRECTFIRE)) } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2A Mobile Artillery',
        PlatoonTemplate = 'T2LandArtillery',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.1, categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH2, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2A Mobile AA',
        PlatoonTemplate = 'T2LandAA',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.05, categories.MOBILE * categories.LAND * categories.ANTIAIR * categories.TECH2, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2A MobileShields',
        PlatoonTemplate = 'T2MobileShields',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech2 or aiBrain.PriorityManager.BuildMobileLandTech3 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.1, (categories.MOBILE * categories.SHIELD) + (categories.MOBILE * categories.STEALTHFIELD), '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3A Siege Assault Bot',
        PlatoonTemplate = 'T3LandBot',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            { MIBC, 'FactionIndex', { 1, 3, 4, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND * (categories.DIRECTFIRE + categories.INDIRECTFIRE)) } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3A SniperBots',
        PlatoonTemplate = 'T3SniperBots',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND * (categories.DIRECTFIRE + categories.INDIRECTFIRE)) } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3A ArmoredAssault',
        PlatoonTemplate = 'T3ArmoredAssault',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND * (categories.DIRECTFIRE + categories.INDIRECTFIRE)) } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3A Mobile Artillery',
        PlatoonTemplate = 'T3LandArtillery',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.1, categories.MOBILE * categories.LAND * categories.INDIRECTFIRE * categories.TECH3, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3A Mobile AA MIN',
        PlatoonTemplate = 'T3LandAA',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.MOBILE * categories.LAND * categories.ANTIAIR * categories.TECH3 }},
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3A Mobile AA',
        PlatoonTemplate = 'T3LandAA',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.05, categories.MOBILE * categories.LAND * categories.ANTIAIR * categories.TECH3, '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3A Mobile Shields',
        PlatoonTemplate = 'T3MobileShields',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { true, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioUveso', { 0.1, (categories.MOBILE * categories.SHIELD) + (categories.MOBILE * categories.STEALTHFIELD), '<',categories.MOBILE * categories.LAND * categories.DIRECTFIRE } },
            -- Respect UnitCap
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
        BuilderName = 'U1 PanicZone Mobile Arty extreme',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 19000,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.85 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1 PanicZone Tank Force',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 19000,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.85 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1 PanicZone Bot Force',
        PlatoonTemplate = 'T1LandDFBot',
        Priority = 19000,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.85 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1 PanicZone Mobile AA Force',
        PlatoonTemplate = 'T1LandAA',
        Priority = 19300,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.AIR - categories.SCOUT - categories.SATELLITE}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Respect UnitCap
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 10, categories.ANTIAIR}},
            { UCBC, 'UnitCapCheckLess', { 0.85 } },
        },
        BuilderType = 'Land',
    },
-- ================================== --
--    TECH 2   PanicZone Main Base    --
-- ================================== --
    Builder {
        BuilderName = 'U2R DFTanks PanicZone',
        PlatoonTemplate = 'T2LandDFTank',
        Priority = 19110,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.AIR - categories.SCOUT - categories.SATELLITE}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U2R ATTTanks PanicZone',
        PlatoonTemplate = 'T2AttackTank',
        Priority = 19110,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.AIR - categories.SCOUT - categories.SATELLITE}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.90 } },
        },
        BuilderType = 'Land',
    },
-- ================================== --
--    TECH 3   PanicZone Main Base    --
-- ================================== --
    Builder {
        BuilderName = 'U3R Siege Assault Bot PanicZone',
        PlatoonTemplate = 'T3LandBot',
        Priority = 19220,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1, 3, 4, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.AIR - categories.SCOUT - categories.SATELLITE}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3R SniperBots PanicZone',
        PlatoonTemplate = 'T3SniperBots',
        Priority = 19220,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.AIR - categories.SCOUT - categories.SATELLITE}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U3R ArmoredAssault PanicZone',
        PlatoonTemplate = 'T3ArmoredAssault',
        Priority = 19220,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.AIR - categories.SCOUT - categories.SATELLITE}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.95 } },
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
        BuilderName = 'U1E PanicExpansion Mobile Arty',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 18999,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'U1E PanicPanicExpansion Mobile AA',
        PlatoonTemplate = 'T1LandAA',
        Priority = 18999,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { MIBC, 'HasNotParagon', {} },
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.AIR - categories.SCOUT - categories.SATELLITE}}, -- radius, LocationType, unitCount, categoryEnemy
            -- Respect UnitCap
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 15, categories.ANTIAIR}},
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 5000
            end
        end,
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
        PlatoonTemplate = 'LandAttackInterceptUveso 2 20',                     -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 301,                                                          -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed with this template.
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
        BuilderName = 'U123 PANIC 2 20',                                        -- Random Builder Name.
        PlatoonTemplate = 'LandAttackInterceptUveso 2 20',                      -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 300,                                                         -- Priority. 1000 is normal.
        InstanceCount = 20,                                                     -- Number of plattons that will be formed.
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
        BuilderName = 'U123 Military Intercept 6 8 (80)',                            -- Random Builder Name.
        PlatoonTemplate = 'LandAttackInterceptUveso 6 8',                       -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 250,                                                         -- Priority. 1000 is normal.
        InstanceCount = 4,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 250
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 80,                                           -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.LAND,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.EXPERIMENTAL * categories.LAND,
                categories.COMMAND,
                categories.INDIRECTFIRE * categories.LAND,
                categories.DIRECTFIRE * categories.LAND,
                categories.ANTIAIR * categories.LAND,
                categories.MOBILE * categories.LAND,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Military Intercept 6 8 (120)',                            -- Random Builder Name.
        PlatoonTemplate = 'LandAttackInterceptUveso 6 8',                       -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 240,                                                         -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 240
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 120,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.LAND,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.EXPERIMENTAL * categories.LAND,
                categories.COMMAND,
                categories.INDIRECTFIRE * categories.LAND,
                categories.DIRECTFIRE * categories.LAND,
                categories.ANTIAIR * categories.LAND,
                categories.MOBILE * categories.LAND,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Military push 4',                            -- Random Builder Name.
        PlatoonTemplate = 'U123-LandCap 1 50',                                  -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 240,                                                         -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 240
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 1000,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.NAVAL - categories.AIR, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.EXPERIMENTAL * categories.LAND,
                categories.COMMAND,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Military push 10',                            -- Random Builder Name.
        PlatoonTemplate = 'U123-LandCap 1 50',                                  -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 240,                                                         -- Priority. 1000 is normal.
        InstanceCount = 10,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 240
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 1000,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.NAVAL - categories.AIR, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.EXPERIMENTAL * categories.LAND,
                categories.COMMAND,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 10, categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER } },
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Military push 20',                            -- Random Builder Name.
        PlatoonTemplate = 'U123-LandCap 1 50',                                  -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 240,                                                         -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 240
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 1000,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.NAVAL - categories.AIR, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.EXPERIMENTAL * categories.LAND,
                categories.COMMAND,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 20, categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER } },
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.LAND - categories.SCOUT}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Military push 40',                            -- Random Builder Name.
        PlatoonTemplate = 'U123-LandCap 1 50',                                  -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 240,                                                         -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 240
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 1000,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.NAVAL - categories.AIR, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.EXPERIMENTAL * categories.LAND,
                categories.COMMAND,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 40, categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER } },
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
        BuilderName = 'U123 Enemy Unprotected Mass Land 2 2',                   -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 2 2',                            -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 230,                                                         -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 260
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = true,                                            -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.STRUCTURE + categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD,                        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
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
                categories.ALLUNITS - categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Enemy Intercept 6 8 (80)',                                      -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 6 8',                         -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 160,                                                          -- Priority. 1000 is normal.
        InstanceCount = 6,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 160
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 80,                                           -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL * categories.LAND,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.STRUCTURE * categories.ANTIAIR,
                categories.STRUCTURE * categories.DEFENSE,
                categories.ALLUNITS - categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.LAND * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.MOBILE * categories.LAND - categories.SCOUT } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Enemy Intercept 6 8 (120)',                                      -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 6 8',                         -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 150,                                                          -- Priority. 1000 is normal.
        InstanceCount = 10,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 150
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 120,                                           -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL * categories.LAND,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.STRUCTURE * categories.ANTIAIR,
                categories.STRUCTURE * categories.DEFENSE,
                categories.ALLUNITS - categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.LAND * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.MOBILE * categories.LAND - categories.SCOUT } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Enemy Intercept 6 8 (200)',                                      -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 6 8',                         -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 140,                                                          -- Priority. 1000 is normal.
        InstanceCount = 10,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 140
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 200,                                           -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL * categories.LAND,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.STRUCTURE * categories.ANTIAIR,
                categories.STRUCTURE * categories.DEFENSE,
                categories.ALLUNITS - categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.LAND * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.MOBILE * categories.LAND - categories.SCOUT } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Enemy Unprotected Land 1 2',                              -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 2 2',                            -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 130,                                                          -- Priority. 1000 is normal.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 130
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = true,                                            -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 25,                                            -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.LAND - categories.STATIONASSISTPOD - categories.POD,                        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
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
                categories.ALLUNITS - categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.LAND * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
            -- When do we want to form this ?
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 AntiDef+mex Early 1 20 (300)',                                -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso Arty 1 20',                      -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 120,                                                          -- Priority. 1000 is normal.
        InstanceCount = 6,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 120
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                            -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 300,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.DEFENSE + categories.MASSEXTRACTION , -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
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
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.LAND * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.DEFENSE } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 AntiMass Early 6 8',                                -- Random Builder Name.
        PlatoonTemplate = 'LandAttackHuntUveso 6 8',                            -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 110,                                                         -- Priority. 1000 is normal.
        InstanceCount = 6,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 110
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = true,                                            -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
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
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.LAND * categories.EXPERIMENTAL }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.MASSEXTRACTION } },
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 60
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            DirectMoveEnemyBase = true, 
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS - categories.AIR,                         -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.COMMAND,
                categories.EXPERIMENTAL,
                categories.FACTORY,
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 60
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            DirectMoveEnemyBase = true, 
            RequireTransport = true,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS - categories.AIR,                         -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.COMMAND,
                categories.EXPERIMENTAL,
                categories.FACTORY,
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 60
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                               -- Searchradius for new target.
            DirectMoveEnemyBase = true, 
            RequireTransport = true,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS - categories.AIR,                         -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.COMMAND,
                categories.EXPERIMENTAL,
                categories.FACTORY,
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 750
            end
        end,
        BuilderData = {
            GuardRadius = 100,
            GuardCategory = categories.MOBILE * categories.LAND * categories.EXPERIMENTAL,
            LocationType = 'LocationType',
        },
        BuilderConditions = {
            -- When do we want to form this ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.MOBILE * categories.LAND * categories.ANTIAIR - categories.EXPERIMENTAL - categories.SCOUT - categories.ENGINEER } },
            { UCBC, 'UnitsNeedGuard', { categories.MOBILE * categories.EXPERIMENTAL * categories.LAND} },
        },
        BuilderType = 'Any',
    },
}
