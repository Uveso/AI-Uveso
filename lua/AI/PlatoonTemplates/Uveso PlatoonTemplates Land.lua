
-- ==== Global Form platoons ==== --

PlatoonTemplate {
    Name = 'CDR Attack',
    Plan = 'AttackPrioritizedLandTargetsAIUveso',
    GlobalSquads = {
        { categories.COMMAND, 1, 1, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'U123 SingleAttack',
    Plan = 'AttackPrioritizedLandTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND, 1, 1, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'LandAttackHuntUveso 2 2',
    Plan = 'AttackPrioritizedLandTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND, 2, 2, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'LandAttackHuntUveso 6 8',
    Plan = 'AttackPrioritizedLandTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND, 6, 8, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'LandAttackHuntUveso 2 10',
    Plan = 'AttackPrioritizedLandTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND, 2, 10, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'LandAttackHuntUveso 5 30',
    Plan = 'AttackPrioritizedLandTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND, 5, 30, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'LandAttackHuntUveso 10 10',
    Plan = 'AttackPrioritizedLandTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND, 10, 10, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'LandAttackHuntUveso 20 40',
    Plan = 'AttackPrioritizedLandTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND, 20, 40, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U12-LandCap 1 500', 
    Plan = 'AttackPrioritizedLandTargetsAIUveso', -- is targetting in order from Platoondata.PrioritizedCategories.
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * ( categories.TECH1 + categories.TECH2 ) - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND, 1, 500, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'LandAttackInterceptUveso 2 5',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND, 2, 5, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'LandAttackInterceptUveso 30 60',
    Plan = 'AttackPrioritizedLandTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND, 30, 60, 'Attack', 'none' },
    }
}


PlatoonTemplate {
    Name = 'T4ExperimentalLandUveso 1 1',
    Plan = 'InterceptorAIUveso', -- is targetting in order from Platoondata.PrioritizedCategories.
    GlobalSquads = {
        { categories.EXPERIMENTAL * categories.LAND * categories.MOBILE - categories.INSIGNIFICANTUNIT, 1, 1, 'attack', 'none' }
    },
}
PlatoonTemplate {
    Name = 'T4ExperimentalLandGroupUveso 2 2',
    Plan = 'AttackPrioritizedLandTargetsAIUveso', -- is targetting in order from Platoondata.PrioritizedCategories.
    GlobalSquads = {
        { categories.EXPERIMENTAL * categories.LAND * categories.MOBILE - categories.INSIGNIFICANTUNIT, 2, 2, 'attack', 'AttackFormation' }
    },
}

