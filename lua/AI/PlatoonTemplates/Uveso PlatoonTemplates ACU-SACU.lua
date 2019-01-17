
PlatoonTemplate {
    Name = 'SACU Teleport 3 3',
    Plan = 'SACUTeleportAI',
    GlobalSquads = {
        { categories.SUBCOMMANDER, 3, 3, 'Attack', 'None' }
    },        
}
PlatoonTemplate {
    Name = 'SACU Teleport 6 6',
    Plan = 'SACUTeleportAI',
    GlobalSquads = {
        { categories.SUBCOMMANDER, 6, 6, 'Attack', 'None' }
    },        
}
PlatoonTemplate {
    Name = 'SACU Teleport 12 12',
    Plan = 'SACUTeleportAI',
    GlobalSquads = {
        { categories.SUBCOMMANDER, 12, 12, 'Attack', 'None' }
    },        
}

PlatoonTemplate {
    Name = 'AddToRepairShieldsPlatoon',
    Plan = 'PlatoonMerger',
    GlobalSquads = {
        { categories.SUBCOMMANDER , 1, 1, 'support', 'none' }
    },
}
