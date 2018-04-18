
PlatoonTemplate {
    Name = 'U123-AntiSubPanic 1 500',
    Plan = 'AttackPrioritizedSeaTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.EXPERIMENTAL - categories.CARRIER - categories.NUKE, 1, 500, 'Attack', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U123 Military AntiSea 5 5',
    Plan = 'AttackPrioritizedSeaTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.EXPERIMENTAL - categories.CARRIER - categories.NUKE, 5, 5, 'Attack', 'none' }
    },
}
PlatoonTemplate {
    Name = 'U123 Enemy Sub 10 10',
    Plan = 'AttackPrioritizedSeaTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL  * categories.SUBMERSIBLE - categories.ENGINEER, 10, 10, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'U123 Enemy Ship 10 10',
    Plan = 'AttackPrioritizedSeaTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL  - categories.SUBMERSIBLE - categories.ENGINEER, 10, 10, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'U123 KILLALL 10 10',
    Plan = 'AttackPrioritizedSeaTargetsAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.ENGINEER, 10, 10, 'Attack', 'none' }
    }
}


