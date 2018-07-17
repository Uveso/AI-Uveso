
-- For AI Patch V2. Fix Support factory upgrade
PlatoonTemplate {
    Name = 'T2LandFactoryUpgrade',
    Plan = 'UnitUpgradeAI',
    GlobalSquads = {
        { categories.TECH2 * categories.FACTORY * categories.LAND - categories.SUPPORTFACTORY, 1, 1, 'support', 'none' }
    }
}
-- For AI Patch V2. Fix Support factory upgrade
PlatoonTemplate {
    Name = 'T2LandSupFactoryUpgrade',
    Plan = 'UnitUpgradeAI',
    GlobalSquads = {
        { categories.TECH2 * categories.SUPPORTFACTORY * categories.LAND, 1, 1, 'support', 'none' }
    }
}
-- For AI Patch V2. Fix Support factory upgrade
PlatoonTemplate {
    Name = 'T2AirFactoryUpgrade',
    Plan = 'UnitUpgradeAI',
    GlobalSquads = {
        { categories.TECH2 * categories.FACTORY * categories.AIR - categories.SUPPORTFACTORY, 1, 1, 'support', 'none' }
    }
}
-- For AI Patch V2. Fix Support factory upgrade
PlatoonTemplate {
    Name = 'T2AirSupFactoryUpgrade',
    Plan = 'UnitUpgradeAI',
    GlobalSquads = {
        { categories.TECH2 * categories.SUPPORTFACTORY * categories.AIR, 1, 1, 'support', 'none' }
    }
}
-- For AI Patch V2. Fix Support factory upgrade
PlatoonTemplate {
    Name = 'T2SeaFactoryUpgrade',
    Plan = 'UnitUpgradeAI',
    GlobalSquads = {
        { categories.TECH2 * categories.FACTORY * categories.NAVAL - categories.SUPPORTFACTORY, 1, 1, 'support', 'none' }
    }
}
-- For AI Patch V2. Fix Support factory upgrade
PlatoonTemplate {
    Name = 'T2SeaSupFactoryUpgrade',
    Plan = 'UnitUpgradeAI',
    GlobalSquads = {
        { categories.TECH2 * categories.SUPPORTFACTORY * categories.NAVAL, 1, 1, 'support', 'none' }
    }
}
