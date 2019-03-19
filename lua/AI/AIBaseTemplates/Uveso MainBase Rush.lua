#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/NormalMain.lua
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'uvesorush',
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
        'FactoryBuilders 1st Uveso',
        'FactoryBuilders RUSH Uveso',
        'FactoryBuilders RECOVER Uveso',
--        'GateConstruction Uveso',
        -- Upgrade Factories TECH1->TECH2 and TECH2->TECH3
        'FactoryUpgradeBuildersRush Uveso',
        -- Build Air Staging Platform to refill and repair air units.
--        'Air Staging Platform Uveso',

        -----------------------------------------------------------------------------
        -- ==== Land Units BUILDER ==== --
        -----------------------------------------------------------------------------
        'LandAttackBuildersPanic Uveso',
        'LandAttackBuildersRush Uveso',
        'LandAttackBuildersRatio Uveso',

        -----------------------------------------------------------------------------
        -- ==== Land Units FORMER==== --
        -----------------------------------------------------------------------------
        'Land FormBuilders PanicZone',
        'Land FormBuilders MilitaryZone',
        'Land FormBuilders EnemyZone',
        'Land FormBuilders Trasher',
        'Land FormBuilders Guards',

        -----------------------------------------------------------------------------
        -- ==== Hover Units FORMER==== --
        -----------------------------------------------------------------------------
        'Hover FormBuilders PanicZone',
        'Hover FormBuilders MilitaryZone',
        'Hover FormBuilders EnemyZone',
        'Hover FormBuilders Trasher',

        -----------------------------------------------------------------------------
        -- ==== Amphibious Units FORMER==== --
        -----------------------------------------------------------------------------
        'Amphibious FormBuilders PanicZone',
        'Amphibious FormBuilders MilitaryZone',
        'Amphibious FormBuilders EnemyZone',
        'Amphibious FormBuilders Trasher',

        -----------------------------------------------------------------------------
        -- ==== Air Units BUILDER ==== --
        -----------------------------------------------------------------------------
        'AntiAirBuilders Uveso',
        -- Build Air Transporter
        'Air Transport Builder Uveso',

        -----------------------------------------------------------------------------
        -- ==== Air Units FORMER==== --
        -----------------------------------------------------------------------------
        'Air FormBuilders PanicZone',
        'Air FormBuilders MilitaryZone',
        'Air FormBuilders EnemyZone',
        'Air FormBuilders Trasher',

        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS BUILDER ==== --
        -----------------------------------------------------------------------------
        'Mobile Experimental Land Builder Uveso',
        'Mobile Experimental Air Builder Uveso',
        'Economic Experimental Builder Uveso',
--        'Paragon Turbo Builder',
--        'Paragon Turbo Factory',

        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS FORMER ==== --
        -----------------------------------------------------------------------------
        'Land Experimental FormBuilders PanicZone',
        'Land Experimental FormBuilders MilitaryZone',
        'Land Experimental FormBuilders EnemyZone',
        'Land Experimental FormBuilders Trasher',
        'Air Experimental FormBuilders PanicZone',
        'Air Experimental FormBuilders Military',
        'Air Experimental FormBuilders EnemyZone',
        'Air Experimental FormBuilders Trasher',

        -----------------------------------------------------------------------------
        -- ==== Structure Shield BUILDER ==== --
        -----------------------------------------------------------------------------
        'Shields Uveso',
        'ShieldUpgrades Uveso',

        -----------------------------------------------------------------------------
        -- ==== Defenses BUILDER ==== --
        -----------------------------------------------------------------------------
        'Tactical Missile Launcher minimum Uveso',
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

        -----------------------------------------------------------------------------
        -- ==== Sniper Former ==== --
        -----------------------------------------------------------------------------
--        'SACU TeleportFormer',

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

--        'AeonOptics',
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
            return 1000, 'uvesorush'
        end
        return -1
    end,
}
