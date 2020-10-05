local categories = categories
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'

local MaxDefense = 0.15 -- 15% of all units can be defenses (categories.STRUCTURE * categories.DEFENSE)

BuilderGroup {
    BuilderGroupName = 'U1 FirebaseBuilders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U1 Firebase Expansion Area',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 0,
        InstanceCount = 1,
        BuilderConditions = {
            { MABC, 'CanBuildFirebase', { 'LocationType', 256, 'Expansion Area', -1000, 5, 1, 'AntiSurface', 1, 'STRATEGIC', 20} },
            { UCBC, 'GreaterThanGameTimeSeconds', { 600 } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = false,
                BaseTemplate = 'ExpansionBaseTemplates',
                FireBase = true,
                FireBaseRange = 256,
                NearMarkerType = 'Expansion Area',
                LocationType = 'LocationType',
                ThreatMin = -1000,
                ThreatMax = 5,
                ThreatRings = 1,
                ThreatType = 'AntiSurface',
                MarkerUnitCount = 1,
                MarkerUnitCategory = 'STRATEGIC',
                MarkerRadius = 20,
                BuildStructures = {
                    'T1Radar',
                    'T1AADefense',
                    'T1LandDefense',
                }
            }
        }
    },
    Builder {
        BuilderName = 'U1 Firebase Defensive Point',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 0,
        InstanceCount = 1,
        BuilderConditions = {
            { MABC, 'CanBuildFirebase', { 'LocationType', 256, 'Expansion Area', -1000, 5, 1, 'AntiSurface', 1, 'STRATEGIC', 20} },
            { UCBC, 'GreaterThanGameTimeSeconds', { 600 } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = false,
                BaseTemplate = 'ExpansionBaseTemplates',
                FireBase = true,
                FireBaseRange = 256,
                NearMarkerType = 'Defensive Point',
                LocationType = 'LocationType',
                ThreatMin = -1000,
                ThreatMax = 5,
                ThreatRings = 1,
                ThreatType = 'AntiSurface',
                MarkerUnitCount = 1,
                MarkerUnitCategory = 'STRATEGIC',
                MarkerRadius = 20,
                BuildStructures = {
                    'T1Radar',
                    'T1AADefense',
                    'T1LandDefense',
                }
            }
        }
    },
    Builder {
        BuilderName = 'U1 Firebase Combat Zone',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 0,
        InstanceCount = 1,
        BuilderConditions = {
            { MABC, 'CanBuildFirebase', { 'LocationType', 256, 'Expansion Area', -1000, 5, 1, 'AntiSurface', 1, 'STRATEGIC', 20} },
            { UCBC, 'GreaterThanGameTimeSeconds', { 600 } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = false,
                BaseTemplate = 'ExpansionBaseTemplates',
                FireBase = true,
                FireBaseRange = 256,
                NearMarkerType = 'Combat Zone',
                LocationType = 'LocationType',
                ThreatMin = -1000,
                ThreatMax = 5,
                ThreatRings = 1,
                ThreatType = 'AntiSurface',
                MarkerUnitCount = 1,
                MarkerUnitCategory = 'STRATEGIC',
                MarkerRadius = 20,
                BuildStructures = {
                    'T1Radar',
                    'T1AADefense',
                    'T1LandDefense',
                }
            }
        }
    },
    Builder {
        BuilderName = 'U1 Firebase Naval Defensive Point',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 0,
        InstanceCount = 1,
        BuilderConditions = {
            { MABC, 'CanBuildFirebase', { 'LocationType', 256, 'Naval Area', -1000, 5, 1, 'AntiSurface', 1, 'STRATEGIC', 20} },
            { UCBC, 'GreaterThanGameTimeSeconds', { 600 } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '<', categories.STRUCTURE * categories.DEFENSE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = false,
                BaseTemplate = 'ExpansionBaseTemplates',
                FireBase = true,
                FireBaseRange = 256,
                NearMarkerType = 'Naval Defensive Point',
                LocationType = 'LocationType',
                ThreatMin = -1000,
                ThreatMax = 5,
                ThreatRings = 1,
                ThreatType = 'AntiSurface',
                MarkerUnitCount = 1,
                MarkerUnitCategory = 'STRATEGIC',
                MarkerRadius = 20,
                BuildStructures = {
                    'T1Sonar',
                    'T1AADefense',
                    'T1NavalDefense',
                }
            }
        }
    },
}
