local IBC = '/lua/editor/InstantBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local SIBC = '/lua/editor/SorianInstantBuildConditions.lua'

local ExperimentalCount = 3
local mapSizeX, mapSizeZ = GetMapSize()
local BaseMilitaryZone = math.max( mapSizeX-50, mapSizeZ-50 ) / 2 -- Half the map
local BasePanicZone = BaseMilitaryZone / 2
BasePanicZone = math.max( 40, BasePanicZone )
BasePanicZone = math.min( 120, BasePanicZone )

-- ===================================================-======================================================== --
-- ==                                 Mobile Experimental Land/Air/Sea                                       == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Paragon Turbo Builder',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Turbo T4AirExperimental1',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 1100,
        DelayEqualBuildPlattons = {'Experimental', 10},
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = 'SHIELD STRUCTURE',
                BuildStructures = {
                    'T4AirExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Turbo T4LandExperimental3',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 1100,
        DelayEqualBuildPlattons = {'Experimental', 10},
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = false,
                AdjacencyCategory = 'SHIELD STRUCTURE',
                BuildStructures = {
                    'T4LandExperimental3',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Turbo T4SeaExperimental1',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 1100,
        DelayEqualBuildPlattons = {'Experimental', 10},
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = 'SHIELD STRUCTURE',
                BuildStructures = {
                    'T4SeaExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Turbo T4LandExperimental2',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 1100,
        DelayEqualBuildPlattons = {'Experimental', 10},
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = false,
                AdjacencyCategory = 'SHIELD STRUCTURE',
                BuildStructures = {
                    'T4LandExperimental2',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Turbo T4LandExperimental1',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 1100,
        DelayEqualBuildPlattons = {'Experimental', 10},
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 10,
                BuildClose = true,
                AdjacencyCategory = 'SHIELD STRUCTURE',
                BuildStructures = {
                    'T4LandExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
-- ===================================================-======================================================== --
-- ==                                    T3 Strategic Missile LAUNCHER                                       == --
-- ===================================================-======================================================== --
    Builder {
        BuilderName = 'Turbo U3 SML',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 1100,
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T3StrategicMissile',
                },
                Location = 'LocationType',
            }
        }
    },
-- ===================================================-======================================================== --
-- ==                                          T3/T4 Artillery                                               == --
-- ===================================================-======================================================== --
    Builder {
        BuilderName = 'Turbo U3 Artillery',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 1100,
        DelayEqualBuildPlattons = {'Artillery', 20},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T3Artillery',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Turbo U3 RapidArtillery',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 1100,
        DelayEqualBuildPlattons = {'Artillery', 20},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T3RapidArtillery',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Turbo U4 Artillery',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 1100,
        DelayEqualBuildPlattons = {'Artillery', 20},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T4Artillery',
                },
                Location = 'LocationType',
            }
        }
    },    
    Builder {
        BuilderName = 'Turbo U4 Satellite',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 1100,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 0, 'ENGINEER TECH3' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T4SatelliteExperimental',
                },
                Location = 'LocationType',
            }
        }
    },
}
