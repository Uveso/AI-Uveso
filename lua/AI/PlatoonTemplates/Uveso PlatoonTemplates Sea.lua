
PlatoonTemplate {
    Name = 'U123 Panic AntiSea 1 500',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.MOBILESONAR - categories.EXPERIMENTAL - categories.CARRIER - categories.NUKE, 1, 500, 'Attack', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U123 Military AntiSea 5 5',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.MOBILESONAR - categories.EXPERIMENTAL - categories.CARRIER - categories.NUKE, 5, 5, 'Attack', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U123 Enemy Dual 2 2',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL * categories.SUBMERSIBLE - categories.MOBILESONAR - categories.EXPERIMENTAL - categories.CARRIER - categories.NUKE, 1, 1, 'Attack', 'none' },
        { categories.MOBILE * categories.NAVAL * categories.ANTIAIR - categories.MOBILESONAR - categories.EXPERIMENTAL - categories.CARRIER - categories.NUKE, 0, 1, 'Attack', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U123 Enemy AntiSea 10 10',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.MOBILESONAR - categories.EXPERIMENTAL, 10, 10, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'U123 KILLALL 10 10',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.MOBILESONAR, 10, 10, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'U4-ExperimentalSea 1 1',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.EXPERIMENTAL * categories.NAVAL * categories.MOBILE, 1, 1, 'attack', 'none' }
    },
}

-- Fix: This Template is missing in Nomads Mod
PlatoonTemplate {
    Name = 'T3SubKiller',
    FactionSquads = {
        Seraphim = {
            { 'xss0304', 1, 1, 'attack', 'None' },
        },
    },
}

