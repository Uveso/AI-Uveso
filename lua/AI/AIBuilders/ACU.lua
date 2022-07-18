local categories = categories
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetDangerZoneRadii()

BuilderGroup {
    BuilderGroupName = 'UC ACU Attack Former',                                 -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
-- ================ --
--    ACU Former    --
-- ================ --
    Builder {
        BuilderName = 'UC CDR Attack 50',                                       -- Random Builder Name.
        PlatoonTemplate = 'Uveso CDR Attack',                                         -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 19250,                                                       -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed with this template.
        BuilderData = {
            SearchRadius = 50, 			                                        -- Searchradius from main base for new target. (A 5x5 Map is 256 high)
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AttackEnemyStrength = 2000,                                         -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            NodeWeight = 10000,                                                 -- pathfinding with nodes up to a threat of 10000
            TargetSearchCategory = categories.ALLUNITS - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL - (categories.MOBILE * categories.AIR) - categories.STRUCTURE, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Attack these targets.
                categories.COMMAND,
                categories.LAND - categories.ANTIAIR,
                categories.LAND,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.COMMAND,
                categories.LAND - categories.ANTIAIR - categories.ENGINEER,
                categories.LAND - categories.ENGINEER,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  50, 'LocationType', 0, categories.ALLUNITS - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL - (categories.MOBILE * categories.AIR) - categories.STRUCTURE }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'UC CDR Attack PANIC',                                    -- Random Builder Name.
        PlatoonTemplate = 'Uveso CDR Attack',                                         -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 19250,                                                       -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed with this template.
        BuilderData = {
            SearchRadius = BasePanicZone, 			                            -- Searchradius from main base for new target. (A 5x5 Map is 256 high)
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AttackEnemyStrength = 2000,                                         -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            NodeWeight = 10000,                                                 -- pathfinding with nodes up to a threat of 10000
            TargetSearchCategory = categories.ALLUNITS - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL - (categories.MOBILE * categories.AIR) - categories.STRUCTURE, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Attack these targets.
                categories.COMMAND,
                categories.LAND - categories.ANTIAIR,
                categories.LAND,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.COMMAND,
                categories.LAND - categories.ANTIAIR - categories.ENGINEER,
                categories.LAND - categories.ENGINEER,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*3 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.ALLUNITS - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL - (categories.MOBILE * categories.AIR) - categories.STRUCTURE }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Don't build it if...
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.STRUCTURE * categories.FACTORY * categories.LAND - categories.SUPPORTFACTORY } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'UC CDR Attack Military',                                 -- Random Builder Name.
        PlatoonTemplate = 'Uveso CDR Attack',                                         -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 19250,                                                       -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed with this template.
        BuilderData = {
            SearchRadius = BaseMilitaryZone, 	                                -- Searchradius from main base for new target. (A 5x5 Map is 256 high)
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AttackEnemyStrength = 2000,                                         -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            NodeWeight = 10000,                                                 -- pathfinding with nodes up to a threat of 10000
            TargetSearchCategory = categories.ALLUNITS - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL - (categories.MOBILE * categories.AIR) - categories.STRUCTURE, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Attack these targets.
                categories.COMMAND,
                categories.LAND - categories.ANTIAIR,
                categories.LAND,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.COMMAND,
                categories.LAND - categories.ANTIAIR - categories.ENGINEER,
                categories.LAND - categories.ENGINEER,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*4 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.ALLUNITS - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL - (categories.MOBILE * categories.AIR) - categories.STRUCTURE }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Don't build it if...
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND - categories.SUPPORTFACTORY } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'UC CDR Attack Enemy',                                 -- Random Builder Name.
        PlatoonTemplate = 'Uveso CDR Attack',                                         -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 19250,                                                       -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed with this template.
        BuilderData = {
            SearchRadius = BaseEnemyZone, 	                                -- Searchradius from main base for new target. (A 5x5 Map is 256 high)
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AttackEnemyStrength = 2000,                                         -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            NodeWeight = 10000,                                                 -- pathfinding with nodes up to a threat of 10000
            DoNotDisband = true,                                                -- permanent platoon
            TargetSearchCategory = categories.ALLUNITS - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL - (categories.MOBILE * categories.AIR) - categories.STRUCTURE, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Attack these targets.
                categories.COMMAND,
                categories.LAND - categories.ANTIAIR,
                categories.LAND,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.COMMAND,
                categories.LAND - categories.ANTIAIR - categories.ENGINEER,
                categories.LAND - categories.ENGINEER,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*8 } },
            -- Do we need additional conditions to build it ?
            -- Don't build it if...
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND - categories.SUPPORTFACTORY } },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'UC CDR Enhancer',                                        -- Random Builder Name.
        PlatoonTemplate = 'Uveso CDR Attack',                                         -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 17800,                                                       -- Priority. Higher priotity will be build more often then lower priotity.
        DelayEqualBuildPlattons = {'ACUFORM', 10},
        InstanceCount = 5,                                                      -- Number of plattons that will be formed with this template.
        BuilderData = {
            SearchRadius = 30, 	                                                -- Searchradius from main base for new target. (A 5x5 Map is 256 high)
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AttackEnemyStrength = 2000,                                         -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            NodeWeight = 10000,                                                 -- pathfinding with nodes up to a threat of 10000
            TargetSearchCategory = categories.ALLUNITS - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL - (categories.MOBILE * categories.AIR) - categories.STRUCTURE, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Attack these targets.
                categories.COMMAND,
                categories.LAND - categories.ANTIAIR,
                categories.LAND,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.COMMAND,
                categories.LAND - categories.ANTIAIR - categories.ENGINEER,
                categories.LAND - categories.ENGINEER,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'CheckBuildPlattonDelay', { 'ACUFORM' }},
            -- When do we want to build this ?
            { EBC, 'GreaterThanEconIncome',  { 0.6, 50.0}}, -- Absolut Base income Mass 6, Energy 500
            -- Do we need additional conditions to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'UC CDR Low health',                                        -- Random Builder Name.
        PlatoonTemplate = 'Uveso CDR Attack',                                         -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 17800,                                                       -- Priority. Higher priotity will be build more often then lower priotity.
        DelayEqualBuildPlattons = {'ACUFORM', 10},
        InstanceCount = 5,                                                      -- Number of plattons that will be formed with this template.
        BuilderData = {
            SearchRadius = BasePanicZone, 	                                                -- Searchradius from main base for new target. (A 5x5 Map is 256 high)
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AttackEnemyStrength = 2000,                                         -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            NodeWeight = 10000,                                                 -- pathfinding with nodes up to a threat of 10000
            TargetSearchCategory = categories.ALLUNITS - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL - (categories.MOBILE * categories.AIR) - categories.STRUCTURE, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Attack these targets.
                categories.COMMAND,
                categories.LAND - categories.ANTIAIR,
                categories.LAND,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.COMMAND,
                categories.LAND - categories.ANTIAIR - categories.ENGINEER,
                categories.LAND - categories.ENGINEER,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            { UCBC, 'CDRHealthLessThan', { 30 }},
            -- Do we need additional conditions to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
    Builder {
        BuilderName = 'UC CDR Rush',                                            -- Random Builder Name.
        PlatoonTemplate = 'Uveso CDR Attack',                                   -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 19250,                                                       -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed with this template.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius from main base for new target. (A 5x5 Map is 256 high)
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AttackEnemyStrength = 2000,                                         -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            NodeWeight = 10000,                                                 -- pathfinding with nodes up to a threat of 10000
            TargetSearchCategory = categories.ALLUNITS - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL - (categories.MOBILE * categories.AIR) - categories.STRUCTURE, -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Attack these targets.
                categories.COMMAND,
                categories.LAND - categories.ANTIAIR,
                categories.LAND,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          -- Override weapon target priorities
                categories.COMMAND,
                categories.LAND - categories.ANTIAIR - categories.ENGINEER,
                categories.LAND - categories.ENGINEER,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { EBC, 'GreaterThanEconIncome',  { 0.0, 32.0}}, -- Absolut Base income
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}

-- ===================================================-======================================================== --
-- ==                                           ACU Assistees                                                == --
-- ===================================================-======================================================== --

BuilderGroup {
    BuilderGroupName = 'UC ACU Support Platoon',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'UC Engineer to ACU Platoon',
        PlatoonTemplate = 'AddEngineerToACUChampionPlatoon',
        Priority = 0,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ACUChampionPlatoon',
        },
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 1, categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD } },
            { UCBC, 'UnitsLessInPlatoon', { 'ACUChampionPlatoon', 1, categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'UC Shield to ACU Platoon',
        PlatoonTemplate = 'AddShieldToACUChampionPlatoon',
        Priority = 10000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ACUChampionPlatoon',
        },
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, (categories.MOBILE * categories.SHIELD) + (categories.MOBILE * categories.STEALTHFIELD) * (categories.TECH2 + categories.TECH3) } },
            { UCBC, 'UnitsLessInPlatoon', { 'ACUChampionPlatoon', 2, (categories.MOBILE * categories.SHIELD) + (categories.MOBILE * categories.STEALTHFIELD) * (categories.TECH2 + categories.TECH3) } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'UC SACU to ACU Platoon',
        PlatoonTemplate = 'AddSACUToACUChampionPlatoon',
        Priority = 10000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ACUChampionPlatoon',
        },
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.SUBCOMMANDER} },
            { UCBC, 'UnitsLessInPlatoon', { 'ACUChampionPlatoon', 1, categories.SUBCOMMANDER } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'UC Tank to ACU Platoon',
        PlatoonTemplate = 'AddTankToACUChampionPlatoon',
        Priority = 10000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ACUChampionPlatoon',
        },
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MOBILE * categories.DIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL } },
            { UCBC, 'UnitsLessInPlatoon', { 'ACUChampionPlatoon', 1, categories.MOBILE * categories.DIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'UC AntiAir to ACU Platoon',
        PlatoonTemplate = 'AddAAToACUChampionPlatoon',
        Priority = 10000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ACUChampionPlatoon',
        },
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MOBILE * categories.LAND * categories.ANTIAIR - categories.EXPERIMENTAL } },
            { UCBC, 'UnitsLessInPlatoon', { 'ACUChampionPlatoon', 3, categories.MOBILE * categories.LAND * categories.ANTIAIR - categories.EXPERIMENTAL } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'UC Gunship to ACU Platoon',
        PlatoonTemplate = 'AddGunshipACUChampionPlatoon',
        Priority = 10000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ACUChampionPlatoon',
        },
        BuilderConditions = {
            -- Have we the eco to build it ?
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL } },
            { UCBC, 'UnitsLessInPlatoon', { 'ACUChampionPlatoon', 3, categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL } },
        },
        BuilderType = 'Any',
    },
}
