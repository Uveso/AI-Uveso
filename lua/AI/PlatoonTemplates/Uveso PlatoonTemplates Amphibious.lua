
-- ==== Global Form platoons ==== --

PlatoonTemplate {
    Name = 'U123 Amphibious 1 10',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AMPHIBIOUS - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 1, 10, 'Attack', 'none' }
    }
}

PlatoonTemplate {
    Name = 'U1 LandSquads Amphibious',
    FactionSquads = {
        UEF = {
--            { 'abc0000', 1, 1, 'attack', 'none' }
        },
        Aeon = {
            { 'ual0201', 1, 1, 'attack', 'none' }
        },
        Cybran = {
--            { 'abc0000', 1, 1, 'attack', 'none' }
        },
        Seraphim = {
            { 'xsl0103', 1, 1, 'attack', 'none' }
        },
        Nomads = {
            { 'xnl0106', 1, 1, 'attack', 'none' },
        },
    }
}

PlatoonTemplate {
    Name = 'U2 LandSquads Amphibious',
    FactionSquads = {
        UEF = {
            { 'uel0203', 1, 1, 'attack', 'none' }
        },
        Aeon = {
            { 'xal0203', 1, 1, 'attack', 'none' }
        },
        Cybran = {
            { 'url0203', 1, 1, 'attack', 'none' }
        },
        Seraphim = {
            { 'xsl0203', 1, 1, 'attack', 'none' }
        },
        Nomads = {
            { 'xnl0203', 1, 1, 'attack', 'none' },
            { 'xnl0111', 1, 1, 'attack', 'none' }
        },
    }
}

PlatoonTemplate {
    Name = 'U3 LandSquads Amphibious',
    FactionSquads = {
        UEF = {
            { 'xel0305', 1, 1, 'attack', 'none' }
        },
        Aeon = {
            { 'dal0310', 1, 1, 'attack', 'none' }
        },
        Cybran = {
            { 'xrl0305', 1, 1, 'attack', 'none' }
        },
        Seraphim = {
            { 'xsl0303', 1, 1, 'attack', 'none' }
        },
        Nomads = {
            { 'xnl0303', 1, 1, 'attack', 'none' }
        },
    }
}
