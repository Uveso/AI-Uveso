local categories = categories
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetDangerZoneRadii()

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

-- ===================================================-======================================================== --
-- ==                                     Build T1 T2 T3 Amphibious                                          == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U123 Amphibious Builders',                              -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U1 Amphibious',
        PlatoonTemplate = 'U1 LandSquads Amphibious',
        Priority = 150,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech1 then
                return 150
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { false, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.MOBILE * categories.ENGINEER - categories.STATIONASSISTPOD - categories.POD } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.INDIRECTFIRE } },
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND) + (categories.STRUCTURE * categories.DEFENSE) } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'U2 Amphibious',
        PlatoonTemplate = 'U2 LandSquads Amphibious',
        Priority = 250,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech2 then
                return 250
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { false, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.11, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 }},
            { UCBC, 'HaveUnitRatioVersusEnemy', { 1.0, categories.MOBILE * categories.LAND - categories.ENGINEER, '<=', (categories.MOBILE * categories.LAND) + (categories.STRUCTURE * categories.DEFENSE) } },
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3 Amphibious',
        PlatoonTemplate = 'U3 LandSquads Amphibious',
        Priority = 350,
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.BuildMobileLandTech3 then
                return 350
            else
                return 0
            end
        end,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemy', { false, 'LocationType' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },                      -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.12, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            -- Respect UnitCap
        },
        BuilderType = 'Land',
    },
}

-- ===================================================-======================================================== --
-- ==                                       Amphibious Formbuilder                                           == --
-- ===================================================-======================================================== --
-- =============== --
--    PanicZone    --
-- =============== --
BuilderGroup {
    BuilderGroupName = 'U123 Amphibious Formers PanicZone',                     -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U123 Amphibious PANIC 1 10',                             -- Random Builder Name.
        PlatoonTemplate = 'U123 Amphibious 1 10',                               -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 100,                                                       -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 12,                                                      -- Number of plattons that will be formed with this template.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 100
            end
        end,
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE - categories.AIR - categories.SCOUT,        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL - categories.AIR,
                categories.MOBILE - categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE - categories.AIR - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- ================== --
--    MilitaryZone    --
-- ================== --
BuilderGroup {
    BuilderGroupName = 'U123 Amphibious Formers MilitaryZone',                  -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U123 Amphibious Military 1 10',                          -- Random Builder Name.
        PlatoonTemplate = 'U123 Amphibious 1 10',                               -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
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
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 300,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.STRUCTURE + (categories.MOBILE - categories.AIR),    -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL,
                categories.MOBILE * categories.NAVAL * categories.ANTIAIR,
                categories.MOBILE * categories.LAND * categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.ANTIAIR - categories.AIR,
                categories.MOBILE - categories.AIR,
                categories.ALLUNITS - categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { MIBC, 'CanPathToCurrentEnemy', { false, 'LocationType' } },
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.STRUCTURE + (categories.MOBILE - categories.AIR) }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- =============== --
--    EnemyZone    --
-- =============== --
BuilderGroup {
    BuilderGroupName = 'U123 Amphibious Formers EnemyZone',                     -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U123 Amphibious Enemy 1 10',                             -- Random Builder Name.
        PlatoonTemplate = 'U123 Amphibious 1 10',                               -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 80,                                                        -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 80
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 500,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.STRUCTURE + (categories.MOBILE - categories.AIR),    -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL,
                categories.MOBILE * categories.NAVAL * categories.ANTIAIR,
                categories.STRUCTURE * categories.NAVAL * categories.FACTORY,
                categories.MOBILE * categories.NAVAL * categories.DEFENSE,
                categories.MOBILE * categories.LAND * categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.ANTIAIR - categories.AIR,
                categories.MOBILE - categories.AIR,
                categories.ALLUNITS - categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { MIBC, 'CanPathToCurrentEnemy', { false, 'LocationType' } },
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , categories.STRUCTURE + (categories.MOBILE - categories.AIR) } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- ============ --
--    Sniper    --
-- ============ --

-- ==================== --
--    Unit Cap Trasher  --
-- ==================== --
BuilderGroup {
    BuilderGroupName = 'U123 Amphibious Formers Trasher',                       -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'U123 Amphibious Trasher 1 10',                           -- Random Builder Name.
        PlatoonTemplate = 'U123 Amphibious 1 10',                               -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 70,                                                          -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        PriorityFunction = function(self, aiBrain)
            if aiBrain.PriorityManager.NoRush1stPhaseActive then
                return 0
            else
                return 70
            end
        end,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS - categories.AIR,                         -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL - categories.AIR,
                categories.TECH3 - categories.AIR,
                categories.ALLUNITS - categories.AIR,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { MIBC, 'CanPathToCurrentEnemy', { false, 'LocationType' } },
            { UCBC, 'UnitCapCheckGreater', { 0.95 } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}

-- =========== --
--    Guards   --
-- =========== --
