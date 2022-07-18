
PlatoonTemplate {
    Name = 'U123 Ship 1 500',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.SUBMERSIBLE - categories.MOBILESONAR - categories.EXPERIMENTAL - categories.CARRIER - categories.NUKE, 1, 500, 'Attack', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U123 Ship 5 5',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.SUBMERSIBLE - categories.MOBILESONAR - categories.EXPERIMENTAL - categories.CARRIER - categories.NUKE, 5, 5, 'Attack', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U123 Ship 2 2',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.SUBMERSIBLE - categories.MOBILESONAR - categories.EXPERIMENTAL - categories.CARRIER - categories.NUKE, 5, 5, 'Attack', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U123 ShipCarrier 10 10',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.SUBMERSIBLE - categories.MOBILESONAR - categories.EXPERIMENTAL, 10, 10, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'U4-ExperimentalSea 1 1',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.EXPERIMENTAL * categories.NAVAL * categories.MOBILE, 1, 1, 'attack', 'none' }
    },
}

PlatoonTemplate {
    Name = 'U123 DirecfireSubs 1 500',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL * categories.SUBMERSIBLE - categories.MOBILESONAR - categories.EXPERIMENTAL - categories.CARRIER - categories.INDIRECTFIRE, 1, 500, 'Attack', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U123 DirecfireSubs 5 5',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL * categories.SUBMERSIBLE - categories.MOBILESONAR - categories.EXPERIMENTAL - categories.CARRIER - categories.INDIRECTFIRE, 5, 5, 'Attack', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U123 DirecfireSubs 10 30',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL * categories.SUBMERSIBLE - categories.MOBILESONAR - categories.INDIRECTFIRE, 10, 30, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'U123 IndirecfireSubs 2 30',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL * categories.SUBMERSIBLE * categories.INDIRECTFIRE - categories.MOBILESONAR, 2, 30, 'Attack', 'none' }
    }
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

