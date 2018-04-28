local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'

BuilderGroup {
    BuilderGroupName = 'U1 Expansion Builder Uveso',
    BuildersType = 'EngineerBuilder',

    Builder {
        BuilderName = 'U1 Vacant Start Location',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 1200,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'ExpansionBaseCheck', { } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MASSEXTRACTION * categories.TECH2 } },
            { UCBC, 'StartLocationNeedsEngineer', { 'LocationType', 1000, -1000, 5, 0, 'StructuresNotMex' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.35, '<=', categories.STRUCTURE - categories.MASSEXTRACTION } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.024, '<=', categories.STRUCTURE * categories.FACTORY * categories.LAND } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
            { UCBC, 'HaveUnitRatioVersusCap', { 0.024, '<=', categories.STRUCTURE * categories.FACTORY * categories.AIR } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = true,
            Construction = {
                BuildClose = false,
                BaseTemplate = 'ExpansionBaseTemplates',
                ExpansionBase = true,
                NearMarkerType = 'Start Location',
                LocationRadius = 1000,
                LocationType = 'LocationType',
                ThreatMin = -1000,
                ThreatMax = 100,
                ThreatRings = 2,
                ThreatType = 'StructuresNotMex',
                ExpansionRadius = 50,
                BuildStructures = {
                    'T1GroundDefense',
                    'T1AADefense',
                    'T1LandFactory',
                    'T1Radar',
                    'T1AirFactory',
                    'T1AADefense',
                    'T1GroundDefense',
                }
            },
        }
    },
    Builder {
        BuilderName = 'U1 Vacant Expansion Area',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 1200,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'ExpansionBaseCheck', { } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MASSEXTRACTION * categories.TECH2 } },
            { UCBC, 'ExpansionAreaNeedsEngineer', { 'LocationType', 1000, -1000, 0, 2, 'StructuresNotMex' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.35, '<=', categories.STRUCTURE - categories.MASSEXTRACTION } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.024, '<=', categories.STRUCTURE * categories.FACTORY * categories.LAND } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
            { UCBC, 'HaveUnitRatioVersusCap', { 0.024, '<=', categories.STRUCTURE * categories.FACTORY * categories.AIR } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = true,
            Construction = {
                BuildClose = false,
                BaseTemplate = 'ExpansionBaseTemplates',
                ExpansionBase = true,
                NearMarkerType = 'Expansion Area',
                LocationRadius = 1000,
                LocationType = 'LocationType',
                ThreatMin = -1000,
                ThreatMax = 100,
                ThreatRings = 2,
                ThreatType = 'StructuresNotMex',
                ExpansionRadius = 50,
                BuildStructures = {
                    'T1GroundDefense',
                    'T1AADefense',
                    'T1LandFactory',
                    'T1Radar',
                    'T1AirFactory',
                }
            },
        }
    },
    Builder {
        BuilderName = 'U1 Naval Builder',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 1200,
        InstanceCount = 4,
        BuilderConditions = {
            { UCBC, 'NavalBaseCheck', { } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MASSEXTRACTION * categories.TECH2 } },
            { UCBC, 'NavalAreaNeedsEngineer', { 'LocationType', 250, -1000, 10, 1, 'AntiSurface' } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.35, '<=', categories.STRUCTURE - categories.MASSEXTRACTION } },
            { UCBC, 'HaveUnitRatioVersusCap', { 0.024, '<=', categories.STRUCTURE * categories.FACTORY * categories.LAND } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
            { UCBC, 'HaveUnitRatioVersusCap', { 0.024, '<=', categories.STRUCTURE * categories.FACTORY * categories.AIR } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = false,
                BaseTemplate = 'ExpansionBaseTemplates',
                ExpansionBase = true,
                NearMarkerType = 'Naval Area',
                LocationRadius = 250,
                LocationType = 'LocationType',
                ThreatMin = -1000,
                ThreatMax = 100,
                ThreatRings = 2,
                ThreatType = 'AntiSurface',
                ExpansionRadius = 70,
                BuildStructures = {
                    'T1SeaFactory',
                    'T1Sonar',
                    'T1NavalDefense',
                    'T1AADefense',
                    'T1SeaFactory',
                    'T1NavalDefense',
                    'T1NavalDefense',
                }
            }
        }
    },
}
