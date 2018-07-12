
PlatoonTemplate {
    Name = 'T2LandFactoryUpgrade',
    Plan = 'UnitUpgradeAI',
    GlobalSquads = {
        { categories.TECH2 * categories.FACTORY * categories.LAND - categories.SUPPORTFACTORY, 1, 1, 'support', 'none' }
    }
}
PlatoonTemplate {
    Name = 'T2LandSupFactoryUpgrade',
    Plan = 'UnitUpgradeAI',
    GlobalSquads = {
        { categories.TECH2 * categories.SUPPORTFACTORY * categories.LAND, 1, 1, 'support', 'none' }
    }
}

