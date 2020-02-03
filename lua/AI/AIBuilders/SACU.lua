local categories = categories
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.RAMBOPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 12, categories.ENGINEERPRESET + categories.RASPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 12, categories.ENGINEERPRESET + categories.RASPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.COMBATPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.NANOCOMBATPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.BUBBLESHIELDPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.INTELJAMMERPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.SIMPLECOMBATPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.SHIELDCOMBATPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.ANTIAIRPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STEALTHPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.CLOAKPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MISSILEPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.ADVANCEDCOMBATPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.ROCKETPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.ANTINAVALPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.AMPHIBIOUSPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.GUNSLINGERPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.NATURALPRODUCERPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.DEFAULTPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.HEAVYTROOPERPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.FASTCOMBATPRESET } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.75}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.FASTCOMBATPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
}
