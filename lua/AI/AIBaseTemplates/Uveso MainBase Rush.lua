#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/NormalMain.lua
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'Uveso Rush',
    Builders = {
        -----------------------------------------------------------------------------
        -- ==== ACU ==== --
        -----------------------------------------------------------------------------
        -- Build Main Base (only once). Land/Air factory and basic Energy
        'ACU Former Uveso',

        -----------------------------------------------------------------------------
        -- ==== Expansion Builders ==== --
        -----------------------------------------------------------------------------
        -- Build an Expansion
        'U1 Expansion Builder Uveso',

        -----------------------------------------------------------------------------
        -- ==== SCU ==== --
        -----------------------------------------------------------------------------

        -----------------------------------------------------------------------------
        -- ==== Engineer ==== --
        -----------------------------------------------------------------------------
        -- Build Engineers Tech 1,2,3 and SACU
        'EngineerFactoryBuilders Uveso',            -- Priority = 900
        -- Assistees
        'Assistees Uveso',
        -- Reclaim mass
        'Engineer Reclaim Uveso',

        -----------------------------------------------------------------------------
        -- ==== Mass ==== --
        -----------------------------------------------------------------------------
        -- Build MassExtractors / Creators
        'MassBuilders Uveso',                           -- Priority = 1100
        -- Upgrade MassExtractors from Tech 1 to 2 AND from Tech 2 to 3
        'ExtractorUpgrades Uveso',                      -- Priority = 1100
        -- Build Mass Storage (Adjacency)
        'MassStorageBuilder Uveso',                     -- Priority = 1100

        -----------------------------------------------------------------------------
        -- ==== Energy ==== --
        -----------------------------------------------------------------------------
        -- Build Power Tech 1,2,3
        'EnergyBuilders Uveso',                       -- Priority = 1100

        -----------------------------------------------------------------------------
        -- ==== Factory ==== --
        -----------------------------------------------------------------------------
        -- Build Land/Air Factories
        'FactoryBuildersRush Uveso',
        'GateConstruction Uveso',
        -- Upgrade Factories TECH1->TECH2 and TECH2->TECH3
        'FactoryUpgradeBuildersRush Uveso',
        -- Build Air Staging Platform to refill and repair air units.
        'Air Staging Platform Uveso',

        -----------------------------------------------------------------------------
        -- ==== Land Units BUILDER ==== --
        -----------------------------------------------------------------------------
        -- Build Land Units
        'LandAttackBuildersPanic Uveso',
        'LandAttackBuildersRush Uveso',
        'LandAttackBuildersRatio Uveso',

        -----------------------------------------------------------------------------
        -- ==== Land Units FORMER==== --
        -----------------------------------------------------------------------------
        'Land FormBuilders Panic',
        'Land FormBuilders MilitaryZone',
        'Land FormBuilders EnemyZone',

        -----------------------------------------------------------------------------
        -- ==== Air Units BUILDER ==== --
        -----------------------------------------------------------------------------
        -- Build Air Units
        'AntiAirBuilders Uveso',
        -- Build Air Transporter
        'Air Transport Builder Uveso',

        -----------------------------------------------------------------------------
        -- ==== Air Units FORMER==== --
        -----------------------------------------------------------------------------
        'Air FormBuilders',

        -----------------------------------------------------------------------------
        -- ==== Sea Units BUILDER ==== --
        -----------------------------------------------------------------------------
        -- Build Naval Units
        'SeaFactoryBuilders Uveso',

        -----------------------------------------------------------------------------
        -- ==== Sea Units FORMER ==== --
        -----------------------------------------------------------------------------
        'SeaAttack FormBuilders Uveso',

        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS BUILDER ==== --
        -----------------------------------------------------------------------------
        'Mobile Experimental Builder Uveso',
        'Economic Experimental Builder Uveso',
        'Paragon Turbo Builder',
        'Paragon Turbo Factory',

        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS FORMER ==== --
        -----------------------------------------------------------------------------
        'ExperimentalAttackFormBuilders Uveso',

        -----------------------------------------------------------------------------
        -- ==== Structure Shield BUILDER ==== --
        -----------------------------------------------------------------------------
--        'Shields Uveso',
--        'ShieldUpgrades Uveso',

        -----------------------------------------------------------------------------
        -- ==== Defenses BUILDER ==== --
        -----------------------------------------------------------------------------
--        'Tactical Missile Launcher minimum Uveso',
--        'Tactical Missile Launcher Maximum Uveso',
--        'Tactical Missile Launcher Uveso',
        'Tactical Missile Defenses Uveso',
--        'Strategic Missile Launcher Uveso',
--        'Strategic Missile Launcher NukeAI Uveso',
        'Strategic Missile Defense Uveso',
        'Strategic Missile Defense Anti-NukeAI Uveso',
--        'Artillery Builder Uveso',
--        'Artillery Platoon Former',
        -- Build Anti Air near AirFactories
--        'Base Anti Air Defense Uveso',

        -----------------------------------------------------------------------------
        -- ==== FireBase BUILDER ==== --
        -----------------------------------------------------------------------------
--        'U1 FirebaseBuilders',

        -- We need this even if we have Omni View to get target informations for experimentals attack.
        -----------------------------------------------------------------------------
        -- ==== Scout BUILDER ==== --
        -----------------------------------------------------------------------------
        'LandScoutBuilder Uveso',
        'AirScoutBuilder Uveso',

        -----------------------------------------------------------------------------
        -- ==== Scout FORMER ==== --
        -----------------------------------------------------------------------------
        'LandScoutFormer Uveso',
        'AirScoutFormer Uveso', 

        -----------------------------------------------------------------------------
        -- ==== Intel/CounterIntel BUILDER ==== --
        -----------------------------------------------------------------------------
        'RadarBuilders Uveso',
        'RadarUpgrade Uveso',

        'CounterIntelBuilders',

        'AeonOptics',
        'CybranOptics',

    },
    -- Not used by Uveso's AI. We always need intel in case the commander is dead.
    NonCheatBuilders = {

    },

    BaseSettings = {
        FactoryCount = {
            Land = 5,
            Air = 5,
            Sea = 3,
            Gate = 1,
        },
        EngineerCount = {
            Tech1 = 4,
            Tech2 = 3,
            Tech3 = 3,
            SCU = 1,
        },
        MassToFactoryValues = {
            T1Value = 6,
            T2Value = 15,
            T3Value = 22.5
        },
    },
    ExpansionFunction = function(aiBrain, location, markerType)
        return -1
    end,
    FirstBaseFunction = function(aiBrain)
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        if personality == 'uvesorush' or personality == 'uvesorushcheat' then
            --LOG('### M-FirstBaseFunction '..personality)
            return 1000, 'Uveso Rush'
        end
        return -1
    end,
}
