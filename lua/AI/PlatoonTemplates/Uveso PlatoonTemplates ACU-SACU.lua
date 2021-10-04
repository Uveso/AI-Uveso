
PlatoonTemplate {
    Name = 'SACU Teleport 1 1',
    Plan = 'SACUTeleportAI',
    GlobalSquads = {
        { categories.SUBCOMMANDER - categories.ENGINEERPRESET - categories.RASPRESET, 1, 1, 'Attack', 'None' }
    },        
}
PlatoonTemplate {
    Name = 'SACU Teleport 3 3',
    Plan = 'SACUTeleportAI',
    GlobalSquads = {
        { categories.SUBCOMMANDER - categories.ENGINEERPRESET - categories.RASPRESET, 3, 3, 'Attack', 'None' }
    },        
}
PlatoonTemplate {
    Name = 'SACU Teleport 6 6',
    Plan = 'SACUTeleportAI',
    GlobalSquads = {
        { categories.SUBCOMMANDER - categories.ENGINEERPRESET - categories.RASPRESET, 6, 6, 'Attack', 'None' }
    },        
}
PlatoonTemplate {
    Name = 'SACU Teleport 9 9',
    Plan = 'SACUTeleportAI',
    GlobalSquads = {
        { categories.SUBCOMMANDER - categories.ENGINEERPRESET - categories.RASPRESET, 9, 9, 'Attack', 'None' }
    },        
}

PlatoonTemplate {
    Name = 'AddToRepairShieldsPlatoon',
    Plan = 'PlatoonMerger',
    GlobalSquads = {
        { categories.ENGINEERPRESET + categories.RASPRESET, 1, 1, 'support', 'none' }
    },
}

PlatoonTemplate {
    Name = 'SACU Fight 3 7',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.SUBCOMMANDER - categories.ENGINEERPRESET - categories.RASPRESET, 3, 7, 'Attack', 'None' }
    },        
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'U3 SACU RAMBO',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.RAMBOPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU RAMBO preset 12345',
    FactionSquads = {
        UEF = {
            { 'uel0301_RAMBO', 1, 1, 'Attack', 'None' }
        },
        Aeon = {
            { 'ual0301_RAMBO', 1, 1, 'Attack', 'None' }
        },
        Cybran = {
            { 'url0301_RAMBO', 1, 1, 'Attack', 'None' }
        },
        Seraphim = {
            { 'xsl0301_RAMBO', 1, 1, 'Attack', 'none' }
        },
        Nomads = {
            { 'xnl0301_RAMBO', 1, 1, 'Attack', 'none' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'U3 SACU ENGINEER',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.ENGINEERPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU ENGINEER preset 12345',
    FactionSquads = {
        UEF = {
            { 'uel0301_ENGINEER', 1, 1, 'Attack', 'None' }
        },
        Aeon = {
            { 'ual0301_ENGINEER', 1, 1, 'Attack', 'None' }
        },
        Cybran = {
            { 'url0301_ENGINEER', 1, 1, 'Attack', 'None' }
        },
        Seraphim = {
            { 'xsl0301_ENGINEER', 1, 1, 'Attack', 'None' }
        },
        Nomads = {
            { 'xnl0301_ENGINEER', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'U3 SACU RAS',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.RASPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU RAS preset 123x5',
    FactionSquads = {
        UEF = {
            { 'uel0301_RAS', 1, 1, 'Attack', 'None' }
        },
        Aeon = {
            { 'ual0301_RAS', 1, 1, 'Attack', 'None' }
        },
        Cybran = {
            { 'url0301_RAS', 1, 1, 'Attack', 'None' }
        },
        Nomads = {
            { 'xnl0301_RAS', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'U3 SACU COMBAT',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.COMBATPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU COMBAT preset 1x34x',
    FactionSquads = {
        UEF = {
            { 'uel0301_COMBAT', 1, 1, 'Attack', 'None' }
        },
        Cybran = {
            { 'url0301_COMBAT', 1, 1, 'Attack', 'None' }
        },
        Seraphim = {
            { 'xsl0301_COMBAT', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'U3 SACU NANOCOMBAT',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.NANOCOMBATPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU NANOCOMBAT preset x2x4x',
    FactionSquads = {
        Aeon = {
            { 'ual0301_NANOCOMBAT', 1, 1, 'Attack', 'None' }
        },
        Seraphim = {
            { 'xsl0301_NANOCOMBAT', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'U3 SACU BUBBLESHIELD',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.BUBBLESHIELDPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU BUBBLESHIELD preset 1xxxx',
    FactionSquads = {
        UEF = {
            { 'uel0301_BUBBLESHIELD', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'U3 SACU INTELJAMMER',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.INTELJAMMERPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU INTELJAMMER preset 1xxxx',
    FactionSquads = {
        UEF = {
            { 'uel0301_INTELJAMMER', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'U3 SACU SIMPLECOMBAT',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.SIMPLECOMBATPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU SIMPLECOMBAT preset x2xxx',
    FactionSquads = {
        Aeon = {
            { 'ual0301_SIMPLECOMBAT', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'U3 SACU SHIELDCOMBAT',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.SHIELDCOMBATPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU SHIELDCOMBAT preset x2xxx',
    FactionSquads = {
        Aeon = {
            { 'ual0301_SHIELDCOMBAT', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'U3 SACU ANTIAIR',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.ANTIAIRPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU ANTIAIR preset xx3xx',
    FactionSquads = {
        Cybran = {
            { 'url0301_ANTIAIR', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------
PlatoonTemplate {
    Name = 'U3 SACU STEALTH',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.STEALTHPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU STEALTH preset xx3xx',
    FactionSquads = {
        Cybran = {
            { 'url0301_STEALTH', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'U3 SACU CLOAK',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.CLOAKPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU CLOAK preset xx3xx',
    FactionSquads = {
        Cybran = {
            { 'url0301_CLOAK', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------
PlatoonTemplate {
    Name = 'U3 SACU MISSILE',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.MISSILEPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU MISSILE preset xxx4x',
    FactionSquads = {
        Seraphim = {
            { 'xsl0301_MISSILE', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'U3 SACU ADVANCEDCOMBAT',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.ADVANCEDCOMBATPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU ADVANCEDCOMBAT preset xxx4x',
    FactionSquads = {
        Seraphim = {
            { 'xsl0301_ADVANCEDCOMBAT', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'U3 SACU ROCKET',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.ROCKETPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU ROCKET preset xxxx5',
    FactionSquads = {
        Nomads = {
            { 'xnl0301_ROCKET', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'U3 SACU ANTINAVAL',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.ANTINAVALPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU ANTINAVAL preset xxxx5',
    FactionSquads = {
        Nomads = {
            { 'xnl0301_ANTINAVAL', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------
PlatoonTemplate {
    Name = 'U3 SACU AMPHIBIOUS',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.AMPHIBIOUSPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU AMPHIBIOUS preset xxxx5',
    FactionSquads = {
        Nomads = {
            { 'xnl0301_AMPHIBIOUS', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------
PlatoonTemplate {
    Name = 'U3 SACU GUNSLINGER',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.GUNSLINGERPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU GUNSLINGER preset  xxxx5',
    FactionSquads = {
        Nomads = {
            { 'xnl0301_GUNSLINGER', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------
PlatoonTemplate {
    Name = 'U3 SACU NATURALPRODUCER',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.NATURALPRODUCERPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU NATURALPRODUCER preset xxxx5',
    FactionSquads = {
        Nomads = {
            { 'xnl0301_NATURALPRODUCER', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------
PlatoonTemplate {
    Name = 'U3 SACU DEFAULT',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.DEFAULTPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU DEFAULT preset xxxx5',
    FactionSquads = {
        Nomads = {
            { 'xnl0301_DEFAULT', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------
PlatoonTemplate {
    Name = 'U3 SACU HEAVYTROOPER',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.HEAVYTROOPERPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU HEAVYTROOPER preset xxxx5',
    FactionSquads = {
        Nomads = {
            { 'xnl0301_HEAVYTROOPER', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------
PlatoonTemplate {
    Name = 'U3 SACU FASTCOMBAT',
    Plan = 'HeroFightPlatoon',
    GlobalSquads = {
        { categories.FASTCOMBATPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U3 SACU FASTCOMBAT preset xxxx5',
    FactionSquads = {
        Nomads = {
            { 'xnl0301_FASTCOMBAT', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------
PlatoonTemplate {
    Name = 'AddEngineerToACUChampionPlatoon',
    Plan = 'PlatoonMerger',
    GlobalSquads = {
        { categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD, 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'AddShieldToACUChampionPlatoon',
    Plan = 'PlatoonMerger',
    GlobalSquads = {
        { (categories.MOBILE * categories.SHIELD) + (categories.MOBILE * categories.STEALTHFIELD) * (categories.TECH2 + categories.TECH3), 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'AddSACUToACUChampionPlatoon',
    Plan = 'PlatoonMerger',
    GlobalSquads = {
        { categories.SUBCOMMANDER, 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'AddTankToACUChampionPlatoon',
    Plan = 'PlatoonMerger',
    GlobalSquads = {
        { categories.MOBILE * categories.DIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL, 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'AddArtyToACUChampionPlatoon',
    Plan = 'PlatoonMerger',
    GlobalSquads = {
        { categories.MOBILE * categories.INDIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL, 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'AddFIREToACUChampionPlatoon',
    Plan = 'PlatoonMerger',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'AddAAToACUChampionPlatoon',
    Plan = 'PlatoonMerger',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.ANTIAIR, 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'AddGunshipACUChampionPlatoon',
    Plan = 'PlatoonMerger',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.TRANSPORTFOCUS, 1, 1, 'support', 'none' }
    },
}


