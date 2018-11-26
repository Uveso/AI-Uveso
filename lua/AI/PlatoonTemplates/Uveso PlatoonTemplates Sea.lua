
PlatoonTemplate {
    Name = 'U123 Panic AntiSea 1 500',
    Plan = 'AttackPrioritizedSeaTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.MOBILESONAR - categories.EXPERIMENTAL - categories.CARRIER - categories.NUKE, 1, 500, 'Attack', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U123 Military AntiSea 5 5',
    Plan = 'AttackPrioritizedSeaTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.MOBILESONAR - categories.EXPERIMENTAL - categories.CARRIER - categories.NUKE, 5, 5, 'Attack', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U123 Enemy Dual 2 2',
    Plan = 'AttackPrioritizedSeaTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL * categories.SUBMERSIBLE - categories.MOBILESONAR - categories.EXPERIMENTAL - categories.CARRIER - categories.NUKE, 1, 1, 'Attack', 'none' },
        { categories.MOBILE * categories.NAVAL * categories.ANTIAIR - categories.MOBILESONAR - categories.EXPERIMENTAL - categories.CARRIER - categories.NUKE, 0, 1, 'Attack', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U123 Enemy AntiSea 10 10',
    Plan = 'AttackPrioritizedSeaTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.MOBILESONAR - categories.EXPERIMENTAL, 10, 10, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'U123 KILLALL 10 10',
    Plan = 'AttackPrioritizedSeaTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.MOBILESONAR, 10, 10, 'Attack', 'none' }
    }
}


