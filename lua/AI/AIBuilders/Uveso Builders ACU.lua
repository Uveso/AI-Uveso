local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local mapSizeX, mapSizeZ = GetMapSize()
local BaseMilitaryZone = math.max( mapSizeX-50, mapSizeZ-50 ) / 2               -- Half the map
local BasePanicZone = BaseMilitaryZone / 2
BasePanicZone = math.max( 60, BasePanicZone )
BasePanicZone = math.min( 120, BasePanicZone )
BaseMilitaryZone = math.max( 250, BaseMilitaryZone )

BuilderGroup {
    BuilderGroupName = 'ACU Former Uveso',                                      -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
-- ================ --
--    ACU Former    --
-- ================ --
    Builder {
        BuilderName = 'UC CDR Attack',                                          -- Random Builder Name.
        PlatoonTemplate = 'CDR Attack',                                         -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 21000,                                                       -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed with this template.
        BuilderData = {
            SearchRadius = 250,                                                 -- Searchradius from main base for new target. (A 5x5 Map is 256 high)
--            ReturnToBaseAfterGameTime = 30,                                      -- Use this platoon only for the first 60 miutes.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AttackEnemyStrength = 500,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - (categories.ENGINEER * categories.TECH1 * categories.TECH2) - categories.AIR - categories.SCOUT , -- Only find targets matching these categories.
            PrioritizedCategories = {                                           -- Attack these targets.
                'COMMAND',
                'EXPERIMENTAL',
                'INDIRECTFIRE, DIRECTFIRE',
                'ALLUNITS',
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.AIR } },
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}