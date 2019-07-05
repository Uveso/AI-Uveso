
-- ==== Global Form platoons ==== --

PlatoonTemplate {
    Name = 'CDR Attack',
    Plan = 'ACUAttackAIUveso',
    GlobalSquads = {
        { categories.COMMAND, 1, 1, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'U123 SingleAttack',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 1, 1, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'LandAttackHuntUveso Arty 1 20',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.INDIRECTFIRE - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 1, 20, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'LandAttackHuntUveso Tank 1 20',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 1, 20, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'LandAttackHuntUveso 2 2',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 2, 2, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'LandAttackHuntUveso 2 4',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 2, 4, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'LandAttackHuntUveso 6 8',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 6, 8, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'LandAttackHuntUveso 2 10',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 2, 10, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'LandAttackHuntUveso 5 30',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 5, 30, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'LandAttackHuntUveso 10 10',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 10, 10, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'LandAttackHuntUveso 8 30',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 8, 30, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'LandAttackHuntUveso 10 50',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 10, 50, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'LandAttackHuntUveso 20 40',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 20, 40, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U12-LandCap 1 50', 
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * ( categories.TECH1 + categories.TECH2 ) - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 1, 50, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-LandCap 1 50', 
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 1, 50, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'T1 LandIntercept 2 3',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.TECH1 - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 2, 3, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'LandAttackInterceptUveso 2 3',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 2, 3, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'LandAttackInterceptUveso 2 5',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 2, 5, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'LandAttackInterceptUveso 2 20',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 2, 20, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'LandAttackInterceptUveso 1 30',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 1, 30, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'LandAttackInterceptUveso 1 100',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 1, 100, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'U1-ArtyAttack 1 30', 
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.INDIRECTFIRE - categories.EXPERIMENTAL - categories.COMMAND - categories.SUBCOMMANDER, 1, 30, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U1-AntiAirAttack 1 30', 
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.ANTIAIR - categories.EXPERIMENTAL - categories.COMMAND - categories.SUBCOMMANDER, 1, 30, 'Attack', 'none' },
    }
}


PlatoonTemplate {
    Name = 'T4 Interceptor Land 1 1',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.EXPERIMENTAL * categories.LAND * categories.MOBILE - categories.INSIGNIFICANTUNIT, 1, 1, 'attack', 'none' },
    },
}
PlatoonTemplate {
    Name = 'T4ExperimentalLandUveso 1 1',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.EXPERIMENTAL * categories.LAND * categories.MOBILE - categories.INSIGNIFICANTUNIT, 1, 1, 'attack', 'none' },
    },
}
PlatoonTemplate {
    Name = 'T4ExperimentalLandGroupUveso 2 2',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.EXPERIMENTAL * categories.LAND * categories.MOBILE - categories.INSIGNIFICANTUNIT, 2, 2, 'attack', 'none' },
    },
}

PlatoonTemplate {
    Name = 'T4ExperimentalLandGroupUveso 3 5',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.EXPERIMENTAL * categories.LAND * categories.MOBILE - categories.INSIGNIFICANTUNIT, 3, 5, 'attack', 'none' },
    },
}
-- Assist experimentals
PlatoonTemplate {
    Name = 'T3ExperimentalAAGuard',
    Plan = 'GuardUnit',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * (categories.TECH3 + categories.TECH2) * categories.ANTIAIR - categories.SCOUT - categories.ENGINEER, 4, 10, 'guard', 'None' },
        { categories.MOBILE * categories.LAND * categories.TECH1 * categories.ANTIAIR - categories.SCOUT - categories.ENGINEER, 10, 10, 'guard', 'None' }
    },
}
-- Unit cap Trasher
PlatoonTemplate {
    Name = 'U1234-Trash Land 1 50',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 1, 50, 'Attack', 'none' }
    },
}

PlatoonTemplate {
    Name = 'U1 LandDFBot',
    FactionSquads = {
        UEF = {
            { 'uel0106', 1, 1, 'attack', 'None' }
        },
        Aeon = {
            { 'ual0106', 1, 1, 'attack', 'None' }
        },
        Cybran = {
            { 'url0106', 1, 1, 'attack', 'None' }
        },
        Seraphim = {
            --{ 'xsl0101', 1, 1, 'attack', 'none' }
            { 'xsl0201', 1, 1, 'attack', 'none' }
        },
        Nomads = {
            { 'xnl0106', 1, 1, 'attack', 'none' }
        },
    }
}
