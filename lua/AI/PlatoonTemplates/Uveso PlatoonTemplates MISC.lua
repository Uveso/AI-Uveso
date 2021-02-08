
PlatoonTemplate {
    Name = 'AddToMassExtractorUpgradePlatoon',
    Plan = 'PlatoonMerger',
    GlobalSquads = {
        { categories.MASSEXTRACTION * (categories.TECH1 + categories.TECH2 + categories.TECH3) , 1, 300, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'AddToNukePlatoon',
    Plan = 'PlatoonMerger',
    GlobalSquads = {
        { categories.STRUCTURE * categories.NUKE * (categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL) , 1, 300, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'AddToAntiNukePlatoon',
    Plan = 'PlatoonMerger',
    GlobalSquads = {
        { categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3 , 1, 300, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'AddToArtilleryPlatoon',
    Plan = 'PlatoonMerger',
    GlobalSquads = {
        { (categories.STRUCTURE * categories.ARTILLERY * ( categories.TECH3 + categories.EXPERIMENTAL )) + categories.SATELLITE , 1, 300, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U1EngineerTransfer',
    Plan = 'TransferAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD, 1, 1, 'support', 'none' },
    },
}
PlatoonTemplate {
    Name = 'U2EngineerTransfer',
    Plan = 'TransferAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.ENGINEER * categories.TECH2 - categories.STATIONASSISTPOD, 1, 1, 'support', 'none' },
    },
}
PlatoonTemplate {
    Name = 'U3EngineerTransfer',
    Plan = 'TransferAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD, 1, 1, 'support', 'none' },
    },
}
PlatoonTemplate {
    Name = 'U1Reclaim',
    Plan = 'ReclaimAIUveso',
    GlobalSquads = {
        { categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD, 1, 1, "support", "None" }
    },
}
PlatoonTemplate {
    Name = 'U2TML',
    Plan = 'TMLAIUveso',
    GlobalSquads = {
        { categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM * categories.TECH2 , 1, 300, 'support', 'none' }
    },
}

PlatoonTemplate {
    Name = 'T3EngineerBuilderNoSUB',
    Plan = 'EngineerBuildAI',
    GlobalSquads = {
        { categories.ENGINEER * categories.TECH3 - categories.SUBCOMMANDER - categories.STATIONASSISTPOD, 1, 1, 'support', 'None' }
    },
}
PlatoonTemplate {
    Name = 'T3EngineerAssistNoSUB',
    Plan = 'ManagerEngineerAssistAI',
    GlobalSquads = {
        { categories.ENGINEER * categories.TECH3 - categories.SUBCOMMANDER - categories.STATIONASSISTPOD, 1, 1, 'support', 'None' }
    },
}
PlatoonTemplate {
    Name = 'EngineerAssistGROUP',
    Plan = 'ManagerEngineerAssistAI',
    GlobalSquads = {
        { categories.ENGINEER * categories.TECH1 - categories.SUBCOMMANDER - categories.STATIONASSISTPOD, 1, 10, 'support', 'None' }
    },
}

PlatoonTemplate {
    Name = 'U2 ShieldUpgrade',
    FactionSquads = {
        UEF = {
            { 'ueb4202', 1, 1, 'Attack', 'None' }
        },
        -- We can't upgrade Aeon shields jet
        --Aeon = {
        --    { 'uab4202', 1, 1, 'Attack', 'None' }
        --},
        Cybran = {
            { 'urb4202', 1, 1, 'Attack', 'None' }
        },
        Seraphim = {
            { 'xsb4202', 1, 1, 'Attack', 'none' }
        },
        Nomads = {
            { 'xnb4202', 1, 1, 'Attack', 'none' }
        },
    }
}


