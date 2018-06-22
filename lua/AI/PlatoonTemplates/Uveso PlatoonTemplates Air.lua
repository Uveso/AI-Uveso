--PanicZone
PlatoonTemplate {
    Name = 'U123-PanicGround 1 500', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * ( categories.GROUNDATTACK + categories.BOMBER ) - categories.EXPERIMENTAL, 1, 500, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-PanicAir 1 500', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.EXPERIMENTAL - categories.GROUNDATTACK - categories.BOMBER, 1, 500, 'Attack', 'none' },
    }
}
--MilitaryZone
PlatoonTemplate {
    Name = 'U123-MilitaryAntiTransport 1 12', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL, 1, 12, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-MilitaryAntiBomber 1 12', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL, 1, 12, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-MilitaryAntiAir 2 500', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL, 2, 500, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-MilitaryAntiGround Gunship 2 500', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY , 2, 500, 'Attack', 'none' }
    }
}
--EnemyZone
PlatoonTemplate {
    Name = 'U123-EnemyAntiAir 10 10', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.GROUNDATTACK - categories.BOMBER, 10, 10, 'Attack', 'none' },
    }
}







PlatoonTemplate {
    Name = 'U123-EnemyAntiAirInterceptor 10 20', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 10, 20, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U123-EnemyAntiGround Bomber 3 5',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 3, 5, 'Attack', 'GrowthFormation' },
    }
}
PlatoonTemplate {
    Name = 'U123-EnemyAntiGround Gunship 3 20',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY , 3, 20, 'Attack', 'none' }
    }
}

-- Bomber
PlatoonTemplate {
    Name = 'U123-ExperimentalAttackBomberGrow 3 100',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 3, 100, 'Attack', 'GrowthFormation' },
    }
}
--
PlatoonTemplate {
    Name = 'U123-TorpedoBomber 1 100',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTINAVY - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL, 1, 100, 'Attack', 'GrowthFormation' },
    }
}

PlatoonTemplate {
    Name = 'U12-AntiAirCap 1 500', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * ( categories.TECH1 + categories.TECH2 ) - categories.TRANSPORTFOCUS, 1, 500, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U12-AntiGroundCap 1 500', 
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * ( categories.GROUNDATTACK + categories.BOMBER ) * ( categories.TECH1 + categories.TECH2 ) - categories.TRANSPORTFOCUS, 1, 500, 'Attack', 'GrowthFormation' },
    }
}
PlatoonTemplate {
    Name = 'U123-ExperimentalAttackGunshipGrow 3 100',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY , 3, 100, 'Attack', 'GrowthFormation' }
    }
}
PlatoonTemplate {
    Name = 'U123-ExperimentalAttackInterceptorGrow 3 100',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 3, 100, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'U4-ExperimentalInterceptor 1 1',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.EXPERIMENTAL * categories.AIR * categories.MOBILE - categories.INSIGNIFICANTUNIT - categories.TRANSPORTFOCUS, 1, 1, 'attack', 'none' }
    },
}

