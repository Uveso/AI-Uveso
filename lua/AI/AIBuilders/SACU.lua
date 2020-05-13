local categories = categories

-- categories that do not exist if nomads are not running.
if not categories.ROCKETPRESET then categories.ROCKETPRESET = categories.RAMBOPRESET end
if not categories.ANTINAVALPRESET then categories.ANTINAVALPRESET = categories.RAMBOPRESET end
if not categories.AMPHIBIOUSPRESET then categories.AMPHIBIOUSPRESET = categories.RAMBOPRESET end
if not categories.GUNSLINGERPRESET then categories.GUNSLINGERPRESET = categories.RAMBOPRESET end
if not categories.NATURALPRODUCERPRESET then categories.NATURALPRODUCERPRESET = categories.RAMBOPRESET end
if not categories.DEFAULTPRESET then categories.DEFAULTPRESET = categories.RAMBOPRESET end
if not categories.HEAVYTROOPERPRESET then categories.HEAVYTROOPERPRESET = categories.RAMBOPRESET end
if not categories.FASTCOMBATPRESET then categories.FASTCOMBATPRESET = categories.RAMBOPRESET end

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua').GetDangerZoneRadii()

BuilderGroup {
    BuilderGroupName = 'U3 SACU Builder',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'U3 SubCommander RAMBO',
        PlatoonTemplate = 'U3 SACU RAMBO preset 12345',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.RAMBOPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.RAMBOPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander ENGINEER',
        PlatoonTemplate = 'U3 SACU ENGINEER preset 12345',
        Priority = 18399,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 12, categories.ENGINEERPRESET + categories.RASPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.ENGINEERPRESET + categories.RASPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander RAS',
        PlatoonTemplate = 'U3 SACU RAS preset 123x5',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 12, categories.ENGINEERPRESET + categories.RASPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.ENGINEERPRESET + categories.RASPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander COMBAT',
        PlatoonTemplate = 'U3 SACU COMBAT preset 1x34x',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.COMBATPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.COMBATPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander NANOCOMBAT',
        PlatoonTemplate = 'U3 SACU NANOCOMBAT preset x2x4x',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.NANOCOMBATPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.NANOCOMBATPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander BUBBLESHIELD',
        PlatoonTemplate = 'U3 SACU BUBBLESHIELD preset 1xxxx',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.BUBBLESHIELDPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.BUBBLESHIELDPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander INTELJAMMER',
        PlatoonTemplate = 'U3 SACU INTELJAMMER preset 1xxxx',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.INTELJAMMERPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.INTELJAMMERPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander SIMPLECOMBAT',
        PlatoonTemplate = 'U3 SACU SIMPLECOMBAT preset x2xxx',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.SIMPLECOMBATPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.SIMPLECOMBATPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander SHIELDCOMBAT',
        PlatoonTemplate = 'U3 SACU SHIELDCOMBAT preset x2xxx',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.SHIELDCOMBATPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.SHIELDCOMBATPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander ANTIAIR',
        PlatoonTemplate = 'U3 SACU ANTIAIR preset xx3xx',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.ANTIAIRPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.ANTIAIRPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander STEALTH',
        PlatoonTemplate = 'U3 SACU STEALTH preset xx3xx',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STEALTHPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STEALTHPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander CLOAK',
        PlatoonTemplate = 'U3 SACU CLOAK preset xx3xx',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.CLOAKPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.CLOAKPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander MISSILE',
        PlatoonTemplate = 'U3 SACU MISSILE preset xxx4x',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MISSILEPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.MISSILEPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander ADVANCEDCOMBAT',
        PlatoonTemplate = 'U3 SACU ADVANCEDCOMBAT preset xxx4x',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.ADVANCEDCOMBATPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.ADVANCEDCOMBATPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander ROCKET',
        PlatoonTemplate = 'U3 SACU ROCKET preset xxxx5',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.ROCKETPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.ROCKETPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander ANTINAVAL',
        PlatoonTemplate = 'U3 SACU ANTINAVAL preset xxxx5',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.ANTINAVALPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.ANTINAVALPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander AMPHIBIOUS',
        PlatoonTemplate = 'U3 SACU AMPHIBIOUS preset xxxx5',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.AMPHIBIOUSPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.AMPHIBIOUSPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander GUNSLINGER',
        PlatoonTemplate = 'U3 SACU GUNSLINGER preset  xxxx5',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.GUNSLINGERPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.GUNSLINGERPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander NATURALPRODUCER',
        PlatoonTemplate = 'U3 SACU NATURALPRODUCER preset xxxx5',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.NATURALPRODUCERPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.NATURALPRODUCERPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander DEFAULT',
        PlatoonTemplate = 'U3 SACU DEFAULT preset xxxx5',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.DEFAULTPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.DEFAULTPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander HEAVYTROOPER',
        PlatoonTemplate = 'U3 SACU HEAVYTROOPER preset xxxx5',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.HEAVYTROOPERPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.HEAVYTROOPERPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander FASTCOMBAT',
        PlatoonTemplate = 'U3 SACU FASTCOMBAT preset xxxx5',
        Priority = 18400,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.FASTCOMBATPRESET } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.FASTCOMBATPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
}
