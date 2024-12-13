-- categories.HEAVYASSAULT does not exist then we have an older version of TM
if not categories.HEAVYASSAULT then categories.HEAVYASSAULT = categories.MOBILE end
AILog('* AI-Uveso: init _Mod Total Mayhem.lua BuilderGroups')

local categories = categories
local LoadModBuilder = false
-- loop over __active_mods table and search for the mod Total Mayhem
for index, moddata in __active_mods do
    if moddata.name == 'Total Mayhem' then
        -- only works for TM v1.38+
        if moddata.uid == "fa-total-mayhem-138"
        or moddata.uid == "fa-total-mayhem-139" then
            AILog('* AI-Uveso: Total Mayhem is installed. Adding BuilderGroups')
            LoadModBuilder = true
            break
        end
    end
end
-- if Total Mayhem is installed, add the following builder
if LoadModBuilder then



-- Add locals for BuilderConditions
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local MaxDefense = 0.15         -- 15% of all units can be defenses (categories.STRUCTURE * categories.DEFENSE)
local MaxAttackForce = 0.45     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)
-- ===================================================-======================================================== --
-- ==                                           EngineerBuilder                                              == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Total Mayhem HEAVYASSAULT Builder',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',                                           -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
-- cheap Tech1 land bots
    Builder {
        BuilderName = 'TM1 HEAVY Bot',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 160,
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 }},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.4, 15.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.LAND * categories.TECH1 * categories.HEAVYASSAULT }},
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
       },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 2,
                BuildClose = false,
                AdjacencyCategory = 'SHIELD STRUCTURE',
                BuildStructures = {
                    'H1CheapBot',
                },
                Location = 'LocationType',
            }
        }
    },
-- Tech1 Gunships
    Builder {
        BuilderName = 'TM1 HEAVY Gunship 1st',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 160,
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.LAND * categories.FACTORY }},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.4, 15.0 } },                     -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.AIR * categories.TECH1 * categories.HEAVYASSAULT }},
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
       },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 2,
                BuildClose = false,
                AdjacencyCategory = 'SHIELD STRUCTURE',
                BuildStructures = {
                    'H1GunShip',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'TM1 HEAVY Gunship 2nd',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 160,
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, 'ENGINEER TECH1' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 2.0, 40.0 } },                     -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.MOBILE * categories.AIR * categories.TECH1 * categories.HEAVYASSAULT }},
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
       },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 2,
                BuildClose = false,
                AdjacencyCategory = 'SHIELD STRUCTURE',
                BuildStructures = {
                    'H1GunShip',
                },
                Location = 'LocationType',
            }
        }
    },
}
-- ===================================================-======================================================== --
-- ==                                       FactoryBuilder Panic                                             == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Total Mayhem FactoryBuilder',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',                                            -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'UTM1 HardTanks Panic MK1',
        PlatoonTemplate = 'T1 Tech1 Mayhem Tank',
        Priority = 22010,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  120, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'UTM1 HardTanks Panic MK2',
        PlatoonTemplate = 'T2 Tech1 Mayhem Tank',
        Priority = 22020,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  120, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'UTM1 HardTanks Panic MK3',
        PlatoonTemplate = 'T3 Tech1 Mayhem Tank',
        Priority = 22030,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  120, 'LocationType', 1, categories.MOBILE * categories.LAND - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
-- ===================================================-======================================================== --
-- ==                                          FactoryBuilder                                                == --
-- ===================================================-======================================================== --
    Builder {
        BuilderName = 'UTM1 HardTanks Spam MK1',
        PlatoonTemplate = 'T1 Tech1 Mayhem Tank',
        Priority = 150,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'UTM1 HardTanks Spam MK2',
        PlatoonTemplate = 'T2 Tech1 Mayhem Tank',
        Priority = 250,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'UTM1 HardTanks Spam MK3',
        PlatoonTemplate = 'T3 Tech1 Mayhem Tank',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxAttackForce , '<=', categories.MOBILE } },
        },
        BuilderType = 'Land',
    },
}
-- ===================================================-======================================================== --
-- ==                                         PlatoonFormBuilder                                             == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'Total Mayhem Former',                                   -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
-- land
    Builder {
        BuilderName = 'TM1 HEAVY Land Fearless',
        PlatoonTemplate = 'TM1 HEAVYASSAULT LAND',                              -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 500,                                                         -- Priority. 1000 is normal.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            NeverGuardBases = true,
            NeverGuardEngineers = true,
            UseFormation = 'AttackFormation',
            ThreatWeights = {
                IgnoreStrongerTargetsRatio = 100.0,
            },
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.LAND * categories.TECH1 * categories.HEAVYASSAULT }},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
-- Air
    Builder {
        BuilderName = 'TM1 HEAVY Air Anti-Resource',
        PlatoonTemplate = 'TM1 HEAVYASSAULT AIR',                               -- Template Name. These units will be formed. See: "UvesoPlatoonTemplatesLand.lua"
        Priority = 500,
        InstanceCount = 2,
        BuilderData = {
            SearchRadius = 10000,
            DistressRange = 500,
            PrioritizedCategories = {
                'ENERGYPRODUCTION DRAGBUILD',
                'ENGINEER',
                'MASSEXTRACTION',
                'MOBILE LAND',
                'MASSFABRICATION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'COMMAND',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.AIR * categories.TECH1 * categories.HEAVYASSAULT }},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
-- PD Upgrades
    Builder {
        BuilderName = 'UTM1 PointDefens Upgrade',
        PlatoonTemplate = 'T1PointDefensUpgrade',
        Priority = 4000,
        InstanceCount = 5,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { MIBC, 'FactionIndex', { 1, 3 }},                                  -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.4, 10.0 } },                     -- relative income 4 mass, 100 energy
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.99}},               -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderData = {
            NumAssistees = 2,
        },
        BuilderType = 'Any'
    },
    Builder {
        BuilderName = 'UTM1 PointDefens Upgrade Experimental',
        PlatoonTemplate = 'T1PointDefensUpgradeEXP',
        Priority = 4000,
        InstanceCount = 5,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { MIBC, 'FactionIndex', { 1, 3 }},                                  -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.8, 10.0 } },                     -- relative income 8 mass, 100 energy
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.99}},               -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderData = {
            NumAssistees = 2,
        },
        BuilderType = 'Any'
    },
    Builder {
        BuilderName = 'UTM2 PointDefens Upgrade',
        PlatoonTemplate = 'T2PointDefensUpgrade',
        Priority = 4000,
        InstanceCount = 5,
        BuilderConditions = {
            -- When do we want to build this ?
            -- Do we need additional conditions to build it ?
            { MIBC, 'FactionIndex', { 1, 3 }},                                  -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.8, 10.0 } },                     -- relative income 8 mass, 100 energy
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.99}},               -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderData = {
            NumAssistees = 2,
        },
        BuilderType = 'Any'
    }
}

-- if we don't have Total Mayhem installed, insert dummy BuilderGroups
else


BuilderGroup {
    BuilderGroupName = 'Total Mayhem HEAVYASSAULT Builder',                          -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',                                           -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
}
BuilderGroup {
    BuilderGroupName = 'Total Mayhem FactoryBuilder',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',                                            -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
}
BuilderGroup {
    BuilderGroupName = 'Total Mayhem Former',                       -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
}

end