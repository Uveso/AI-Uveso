-- Tagada (Balance Team) wrote:
-- Different factions want different ratios of destroyers to frigates eg.
-- Cybran destroyer can't really kite well and cybran frigate is the strongest and that's why cybran should make more frigates compared to other fations.
-- On the other hand Aeon has the best destroyer and the worst frigate so it's the opposite for them.
-- Seraphim destroyers are very good vs frigate/hover and they can kite insanely well so vs frig/hover spam you can make more of them and less frigs.
-- UEF is kind of in the middle, they would rather wait for their destro + shieldboad + missile cruisers mix and keep it safe with
-- enough frigates, then secure some contested territory and destroy expansions with their cruisers.

local categories = categories
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetDangerZoneRadii()

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

-- ===================================================-======================================================== --
-- ==                                        Build T1 T2 T3 SEA                                              == --
-- ===================================================-======================================================== --
-- ============= --
--    AI-RUSH    --
-- ============= --
BuilderGroup {
    BuilderGroupName = 'U123 Naval Builders RUSH',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ===================== --
    --    TECH 1   Always    --
    -- ===================== --
    Builder {
        BuilderName = 'U1R Sub PANIC Always',
        PlatoonTemplate = 'T1SeaSub',
        Priority = 18700,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { -1.0, -1.00 } }, -- relative income
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.MOBILE * categories.NAVAL * categories.SUBMERSIBLE * categories.TECH1  }},
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 10,  categories.MOBILE * categories.NAVAL * categories.SUBMERSIBLE * categories.TECH1 } },
            { UCBC, 'NavalBaseWithLeastUnits', {  100, 'LocationType', categories.MOBILE * categories.NAVAL * categories.SUBMERSIBLE * categories.TECH1 }}, -- radius, LocationType, categoryUnits
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce / 3 , '<', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Sea',
    },
    -- ======================== --
    --    TECH 1   PanicZone    --
    -- ======================== --
    Builder {
        BuilderName = 'U1R Sub PANIC',
        PlatoonTemplate = 'T1SeaSub',
        Priority = 18600,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  80, 'LocationType', 0, categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 30,  categories.MOBILE * categories.NAVAL } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U1R Sea AntiAir PANIC',
        PlatoonTemplate = 'T1SeaAntiAir',
        Priority = 18600,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  80, 'LocationType', 0, categories.MOBILE * categories.AIR * ( categories.BOMBER + categories.GROUNDATTACK + categories.ANTINAVY ) }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 10,  categories.MOBILE * categories.NAVAL } },
        },
        BuilderType = 'Sea',
    },
    -- =========================== --
    --    TECH 1   MilitaryZone    --
    -- =========================== --
    Builder {
        BuilderName = 'U1R Sub Military',
        PlatoonTemplate = 'T1SeaSub',
        Priority = 151,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech1 then
                return 151
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 10,  categories.MOBILE * categories.NAVAL } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U1R Sea Military',
        PlatoonTemplate = 'T1SeaAntiAir',
        Priority = 151,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech1 then
                return 151
            else
                return 0
            end
        end,
        BuilderConditions = {
             { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
           -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 10,  categories.MOBILE * categories.NAVAL } },
        },
        BuilderType = 'Sea',
    },
    -- ======================== --
    --    TECH 1   EnemyZone    --
    -- ======================== --
    Builder {
        BuilderName = 'U1R Sub',
        PlatoonTemplate = 'T1SeaSub',
        Priority = 151,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech1 then
                return 151
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            --{ UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            { UCBC, 'NavalBaseWithLeastUnits', {  100, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U1R Sea Frigate',
        PlatoonTemplate = 'T1SeaFrigate',
        Priority = 151,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech1 then
                return 151
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            --{ UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
           { UCBC, 'NavalBaseWithLeastUnits', {  100, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2R Sea Destroyer',
        PlatoonTemplate = 'T2SeaDestroyer',
        Priority = 251,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech2 then
                return 251
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2R Sea Cruiser',
        PlatoonTemplate = 'T2SeaCruiser',
        Priority = 251,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech2 then
                return 251
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NAVAL } },
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2R Sea SubKiller',
        PlatoonTemplate = 'T2SubKiller',
        Priority = 251,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech2 then
                return 251
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2R Sea ShieldBoat',
        PlatoonTemplate = 'T2ShieldBoat',
        Priority = 251,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech2 then
                return 251
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2R Sea CounterIntelBoat',
        PlatoonTemplate = 'T2CounterIntelBoat',
        Priority = 251,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech2 then
                return 251
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3R Sea Battleship',
        PlatoonTemplate = 'T3SeaBattleship',
        Priority = 351,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech3 then
                return 351
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3R Sea NukeSub',
        PlatoonTemplate = 'T3SeaNukeSub',
        Priority = 351,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech3 then
                return 351
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3R Sea MissileBoat',
        PlatoonTemplate = 'T3MissileBoat',
        Priority = 351,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech3 then
                return 351
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NAVAL } },
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3R Sea SubKiller',
        PlatoonTemplate = 'T3SubKiller',
        Priority = 351,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech3 then
                return 351
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3R Sea Battlecruiser',
        PlatoonTemplate = 'T3Battlecruiser',
        Priority = 351,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech3 then
                return 351
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.01, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
}-- ================= --
--    AI-ADAPTIVE    --
-- ================= --
BuilderGroup {
    BuilderGroupName = 'U123 Naval Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ======================== --
    --    TECH 1   PanicZone    --
    -- ======================== --
    Builder {
        BuilderName = 'U1 Sub PANIC',
        PlatoonTemplate = 'T1SeaSub',
        Priority = 18600,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  60, 'LocationType', 0, categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 20,  categories.MOBILE * categories.NAVAL } },
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U1 Sea AntiAir PANIC',
        PlatoonTemplate = 'T1SeaAntiAir',
        Priority = 18600,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  60, 'LocationType', 0, categories.MOBILE * categories.AIR * ( categories.BOMBER + categories.GROUNDATTACK + categories.ANTINAVY ) }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 20,  categories.MOBILE * categories.NAVAL } },
        },
        BuilderType = 'Sea',
    },
    -- ======================== --
    --    TECH 1   EnemyZone    --
    -- ======================== --
    Builder {
        BuilderName = 'U1 Sub',
        PlatoonTemplate = 'T1SeaSub',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            --{ UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            { UCBC, 'NavalBaseWithLeastUnits', {  100, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U1 Sea Frigate',
        PlatoonTemplate = 'T1SeaFrigate',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            --{ UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            { UCBC, 'NavalBaseWithLeastUnits', {  100, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2 Sea Destroyer',
        PlatoonTemplate = 'T2SeaDestroyer',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.11, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
--            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            { UCBC, 'NavalBaseWithLeastUnits', {  100, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2 Sea Cruiser',
        PlatoonTemplate = 'T2SeaCruiser',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.11, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NAVAL } },
--            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            { UCBC, 'NavalBaseWithLeastUnits', {  100, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2 Sea SubKiller',
        PlatoonTemplate = 'T2SubKiller',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.11, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
--            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            { UCBC, 'NavalBaseWithLeastUnits', {  100, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2 Sea ShieldBoat',
        PlatoonTemplate = 'T2ShieldBoat',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.11, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
--            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            { UCBC, 'NavalBaseWithLeastUnits', {  100, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2 Sea CounterIntelBoat',
        PlatoonTemplate = 'T2CounterIntelBoat',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.11, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
--            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            { UCBC, 'NavalBaseWithLeastUnits', {  100, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Respect UnitCap
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
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
--            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            { UCBC, 'NavalBaseWithLeastUnits', {  100, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3 Sea NukeSub',
        PlatoonTemplate = 'T3SeaNukeSub',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
--            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            { UCBC, 'NavalBaseWithLeastUnits', {  100, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3 Sea MissileBoat',
        PlatoonTemplate = 'T3MissileBoat',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NAVAL } },
--            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            { UCBC, 'NavalBaseWithLeastUnits', {  100, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3 Sea SubKiller',
        PlatoonTemplate = 'T3SubKiller',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
--            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            { UCBC, 'NavalBaseWithLeastUnits', {  100, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3 Sea Battlecruiser',
        PlatoonTemplate = 'T3Battlecruiser',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileNavalTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
--            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.NAVAL, '<=', categories.MOBILE * categories.NAVAL } },
            { UCBC, 'NavalBaseWithLeastUnits', {  100, 'LocationType', categories.MOBILE * categories.NAVAL }}, -- radius, LocationType, categoryUnits
            -- Respect UnitCap
        },
        BuilderType = 'Sea',
    },
}
-- ===================================================-======================================================== --
-- ==                                            Sonar  builder                                              == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U1 Sonar Builders',                                     -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U1 Sonar',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17500,
        InstanceCount = 1,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, (categories.STRUCTURE * categories.SONAR) + categories.MOBILESONAR } }, -- TECH3 sonar is MOBILE not STRUCTURE!!!
            { UCBC, 'HaveLessThanUnitsWithCategory', { 5, (categories.STRUCTURE * categories.SONAR) + categories.MOBILESONAR } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD }},
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
    BuilderGroupName = 'U1 Sonar Upgraders',                                    -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U1 Sonar Upgrade',
        PlatoonTemplate = 'T1SonarUpgrade',
        Priority = 200,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.TECH1 * categories.SONAR }},
            -- Respect UnitCap
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Sonar Upgrade',
        PlatoonTemplate = 'T2SonarUpgrade',
        Priority = 300,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1, 2, 3, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.TECH2 * categories.MOBILESONAR }},
            -- Respect UnitCap
        },
        BuilderType = 'Any',
    },
}
-- ===================================================-======================================================== --
-- ==                                      NAVAL T1 T2 T3 Formbuilder                                        == --
-- ===================================================-======================================================== --
-- =============== --
--    PanicZone    --
-- =============== --
BuilderGroup {
    BuilderGroupName = 'U123 Naval Formers PanicZone',                          -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U123 PANIC Ships',                                       -- Random Builder Name.
        PlatoonTemplate = 'U123 Ship 1 500',                                    -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 10,                                                     -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE - categories.AIR,          -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.NAVAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE - categories.AIR }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 PANIC Subs',                                        -- Random Builder Name.
        PlatoonTemplate = 'U123 DirecfireSubs 1 500',                                    -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 10,                                                     -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = (categories.NAVAL + categories.AMPHIBIOUS) - categories.HOVER, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.NAVAL,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.NAVAL }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- ================== --
--    MilitaryZone    --
-- ================== --
BuilderGroup {
    BuilderGroupName = 'U123 Naval Formers MilitaryZone',                       -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U123 Military Ships',                                   -- Random Builder Name.
        PlatoonTemplate = 'U123 Ship 5 5',                                      -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 80,                                                          -- Priority. 1000 is normal.
        InstanceCount = 10,                                                     -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 80
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 150,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE - categories.AIR,          -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.NAVAL * categories.TECH2 ,
                categories.NAVAL,
                categories.ALLUNITS - categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE - categories.AIR }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'U123 Military Subs',                                     -- Random Builder Name.
        PlatoonTemplate = 'U123 DirecfireSubs 5 5',                                      -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 80,                                                          -- Priority. 1000 is normal.
        InstanceCount = 10,                                                     -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 80
            end
        end,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 150,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = (categories.NAVAL + categories.AMPHIBIOUS) - categories.HOVER, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.NAVAL * categories.TECH2 ,
                categories.NAVAL,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.NAVAL }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- =============== --
--    EnemyZone    --
-- =============== --
BuilderGroup {
    BuilderGroupName = 'U123 Naval Formers EnemyZone',                          -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U123 Kill early',
        PlatoonTemplate = 'U123 Ship 2 2',
        Priority = 70,
        InstanceCount = 3,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 70
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 200,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.NAVAL,    -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.NAVAL,
                categories.NAVAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.NAVAL } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U123 Enemy AntiStructure',
        PlatoonTemplate = 'U123 ShipCarrier 10 10',
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
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.STRUCTURE * categories.NAVAL * categories.DEFENSE,     -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.NAVAL * categories.DEFENSE,
                categories.NAVAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 15, categories.MOBILE * categories.NAVAL } },
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , categories.STRUCTURE * categories.NAVAL * categories.DEFENSE } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U123 Enemy AntiMobile',
        PlatoonTemplate = 'U123 ShipCarrier 10 10',
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
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.MOBILE * categories.NAVAL,        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.NAVAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 15, categories.MOBILE * categories.NAVAL } },
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.MOBILE * categories.NAVAL } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U123 Anti NavalFactories',
        PlatoonTemplate = 'U123 ShipCarrier 10 10',
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
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 1000000,                                      -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.STRUCTURE * categories.FACTORY * categories.NAVAL, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.NAVAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 10, categories.MOBILE * categories.NAVAL } },
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.STRUCTURE * categories.FACTORY * categories.NAVAL } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U123 Anti LAND',
        PlatoonTemplate = 'U123 ShipCarrier 10 10',
        Priority = 1,
        InstanceCount = 10,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 70
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 1000000,                                      -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnoreTargetLayerCheck = true,                                      -- Torpedo bomber are the only unit that can fire from AIR to SubWater level
            TargetSearchCategory = categories.LAND + categories.NAVAL,          -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.NAVAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitsLessAtEnemy', { 2 , categories.NAVAL } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U123 Sub anti all',
        PlatoonTemplate = 'U123 DirecfireSubs 10 30',
        Priority = 1,
        InstanceCount = 10,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 70
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 1000000,                                      -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnoreTargetLayerCheck = true,                                      -- Torpedo bomber are the only unit that can fire from AIR to SubWater level
            TargetSearchCategory = (categories.NAVAL + categories.AMPHIBIOUS) - categories.HOVER, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.NAVAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NAVAL } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U123 Sub Indirectfire',
        PlatoonTemplate = 'U123 IndirecfireSubs 2 30',
        Priority = 1,
        InstanceCount = 10,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 70
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 1000000,                                      -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnoreTargetLayerCheck = true,                                      -- Torpedo bomber are the only unit that can fire from AIR to SubWater level
            TargetSearchCategory = categories.LAND + categories.NAVAL,          -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.NAVAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.NAVAL } },
        },
        BuilderType = 'Any',
    },
}
-- ==================== --
--    Unit Cap Trasher  --
-- ==================== --
BuilderGroup {
    BuilderGroupName = 'U123 Naval Formers Trasher',                            -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U123 Anti Naval cap',
        PlatoonTemplate = 'U123 Ship 1 500',
        Priority = 60,
        InstanceCount = 1,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 60
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 10000,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategoryTargetSearchCategory = categories.ALLUNITS - categories.AIR,                         -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.NAVAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsLessAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.ALLUNITS - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
            { UCBC, 'UnitCapCheckGreater', { 0.95 } },
        },
        BuilderType = 'Any',
    },
}

BuilderGroup {
    BuilderGroupName = 'U123 Naval Builders withPath',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder {
        BuilderName = 'U1N Frigate',
        PlatoonTemplate = 'T1SeaFrigate',
        Priority = 1,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.FACTORY * categories.NAVAL}},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 5, categories.FACTORY * categories.NAVAL - categories.TECH1}},
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U1N Sub',
        PlatoonTemplate = 'T1SeaSub',
        Priority = 1,
        InstanceCount = 3,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.FACTORY * categories.NAVAL * categories.TECH1}},
        },
        BuilderType = 'Sea',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2N Destroyer UEF Aeon',
        PlatoonTemplate = 'T2SeaDestroyer',
        Priority = 1,
        InstanceCount = 2,
        BuilderConditions = {
             { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
           -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 7, categories.FACTORY * categories.NAVAL * categories.TECH3}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.FACTORY * categories.NAVAL - categories.TECH1}},
            { UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 3, categories.STRUCTURE * categories.DEFENSE * categories.ANTINAVY, 'Enemy'}},
            { MIBC, 'FactionIndex', {1, 2}},
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2N Destroyer Cybran Sera',
        PlatoonTemplate = 'T2SeaDestroyer',
        Priority = 1,
        InstanceCount = 2,
        BuilderConditions = {
             { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
           -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 7, categories.FACTORY * categories.NAVAL * categories.TECH3}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.FACTORY * categories.NAVAL - categories.TECH1}},
            { UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 3, categories.STRUCTURE * categories.DEFENSE * categories.ANTINAVY, 'Enemy'}},
            { MIBC, 'FactionIndex', {3, 4}},
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2N Cruiser',
        PlatoonTemplate = 'T2SeaCruiser',
        Priority = 1,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 7, categories.FACTORY * categories.NAVAL * categories.TECH3}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.FACTORY * categories.NAVAL - categories.TECH1}},
            { UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 3, categories.STRUCTURE * categories.DEFENSE * categories.ANTINAVY, 'Enemy'}},
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U1N Sub II',
        PlatoonTemplate = 'T1SeaSub',
        Priority = 1,
        InstanceCount = 3,
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.FACTORY * categories.NAVAL * categories.TECH2}},
        },
        BuilderType = 'Sea',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U1N Sub III',
        PlatoonTemplate = 'T1SeaSub',
        Priority = 1,
        InstanceCount = 0,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.FACTORY * categories.NAVAL * categories.TECH3}},
            { EBC, 'GreaterThanEconTrend', { -1, -2}},
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3N Battleship',
        PlatoonTemplate = 'T3SeaBattleship',
        Priority = 1,
        InstanceCount = 0,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.FACTORY * categories.NAVAL * categories.TECH3}},
            { EBC, 'GreaterThanEconTrend', { 1, 1}},
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2N Destroyer UEF, Aeon',
        PlatoonTemplate = 'T2SeaDestroyer',
        Priority = 1,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.FACTORY * categories.NAVAL * categories.TECH3}},
            { EBC, 'GreaterThanEconTrend', { -1, -2}},
            { MIBC, 'FactionIndex', {1, 2}},
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2N Destroyer Cybran, Sera',
        PlatoonTemplate = 'T2SeaDestroyer',
        Priority = 1,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.FACTORY * categories.NAVAL * categories.TECH3}},
            { EBC, 'GreaterThanEconTrend', { -1, -2}},
            { MIBC, 'FactionIndex', {3, 4}},
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U2N Cruiser III ',
        PlatoonTemplate = 'T2SeaCruiser',
        Priority = 1,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.FACTORY * categories.NAVAL * categories.TECH3}},
            { EBC, 'GreaterThanEconTrend', { -1, -2}},
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3N Battleship II',
        PlatoonTemplate = 'T3SeaBattleship',
        Priority = 1,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.FACTORY * categories.NAVAL * categories.TECH3}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ARTILLERY * categories.STRUCTURE * categories.TECH3}},
            { EBC, 'GreaterThanEconTrend', { -1, -1}},
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3N Nuke Sub',
        PlatoonTemplate = 'T3SeaNukeSub',
        Priority = 1,
        InstanceCount = 1,
        BuilderConditions = {
             { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
           -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.FACTORY * categories.NAVAL * categories.TECH3}},
            { EBC, 'GreaterThanEconTrend', { 5, 200}},
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'U3N Carrier',
        PlatoonTemplate = 'T3SeaCarrier',
        Priority = 1,
        InstanceCount = 1,
        BuilderConditions = {
             { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.NAVAL }}, -- LocationType, categoryUnits
           -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 70, categories.FACTORY * categories.NAVAL * categories.TECH3}},
            { EBC, 'GreaterThanEconTrend', { 10, 100}},
        },
        BuilderType = 'Sea',
    },

}
