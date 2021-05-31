#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/NormalMain.lua
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'uvesoeasy',
    Builders = {
        -----------------------------------------------------------------------------
        -- ==== ACU ==== --
        -----------------------------------------------------------------------------
        -- Build Main Base (only once). Land/Air factory and basic Energy
        'UC ACU Attack Former',
        
        -----------------------------------------------------------------------------
        -- ==== Expansion Builders ==== --
        -----------------------------------------------------------------------------

        -----------------------------------------------------------------------------
        -- ==== SCU ==== --
        -----------------------------------------------------------------------------

        -----------------------------------------------------------------------------
        -- ==== Engineer ==== --
        -----------------------------------------------------------------------------
        -- Build Engineers Tech 1,2,3 and SACU
        'U123 Engineer Builders',            -- Priority = 900
        -- Assistees
        'UC123 Assistees',
        -- Reclaim mass
        'U1 Engineer Reclaim',

        -----------------------------------------------------------------------------
        -- ==== Mass ==== --
        -----------------------------------------------------------------------------
        -- Build MassExtractors / Creators
        'U1 MassBuilders',                           -- Priority = 1100
        -- Upgrade MassExtractors from Tech 1 to 2 AND from Tech 2 to 3
        'U123 ExtractorUpgrades',                      -- Priority = 1100
        -- Build Mass Storage (Adjacency)
        'U1 MassStorage Builder',                     -- Priority = 1100

        -----------------------------------------------------------------------------
        -- ==== Energy ==== --
        -----------------------------------------------------------------------------
        -- Build Power Tech 1,2,3
        'U123 Energy Builders',
        'U123 Energy Builders Recover',
        'U123 EnergyStorage Builders',
        'U123 Reclaim Energy Buildings',

        -----------------------------------------------------------------------------
        -- ==== Factory ==== --
        -----------------------------------------------------------------------------
        -- Build Land/Air Factories
        'U1 Factory Builders 1st',
        'U1 Factory Builders EXPERIMENTAL',
        'U1 Factory Builders RECOVER',
        -- Upgrade Factories TECH1->TECH2 and TECH2->TECH3
        'U123 Factory Upgrader Rush',
        -- Build Air Staging Platform to refill and repair air units.
        'U2 Air Staging Platform Builders',
        -- Build Naval Factories
        'U1 Factory Builders Naval',
        -- Upgrade Naval Factories TECH1->TECH2 and TECH2->TECH3
        'U123 Factory Upgrader Naval',

        -----------------------------------------------------------------------------
        -- ==== Land Units BUILDER ==== --
        -----------------------------------------------------------------------------
        -- Build Land Units
        'U123 Land Builders Panic',
        'U123 Land Builders ADAPTIVE',

        -----------------------------------------------------------------------------
        -- ==== Land Units FORMER==== --
        -----------------------------------------------------------------------------
        'U123 Land Formers PanicZone',
--        'U123 Land Formers MilitaryZone',
--        'U123 Land Formers EnemyZone',
        'U123 Land Formers Trasher',
        'U123 Land Formers Guards',

        -----------------------------------------------------------------------------
        -- ==== Hover Units FORMER==== --
        -----------------------------------------------------------------------------
        'U123 Hover Formers PanicZone',
--        'U123 Hover Formers MilitaryZone',
--        'U123 Hover Formers EnemyZone',
        'U123 Hover Formers Trasher',

        -----------------------------------------------------------------------------
        -- ==== Amphibious Units BUILDER ==== --
        -----------------------------------------------------------------------------
        'U123 Amphibious Builders',

        -----------------------------------------------------------------------------
        -- ==== Amphibious Units FORMER==== --
        -----------------------------------------------------------------------------
        'U123 Amphibious Formers PanicZone',
--        'U123 Amphibious Formers MilitaryZone',
--        'U123 Amphibious Formers EnemyZone',
        'U123 Amphibious Formers Trasher',

        -----------------------------------------------------------------------------
        -- ==== Air Units BUILDER ==== --
        -----------------------------------------------------------------------------
        'U123 Air Builders',
        -- Build Air Transporter
        'U123 Air Transport Builders',

        -----------------------------------------------------------------------------
        -- ==== Air Units FORMER==== --
        -----------------------------------------------------------------------------
        'U123 Air Formers PanicZone',
        'U123 Air Formers MilitaryZone',
--        'U123 Air Formers EnemyZone',
        'U123 Air Formers Trasher',
        'U123 TorpedoBomber Formers',

        -----------------------------------------------------------------------------
        -- ==== Sea Units BUILDER ==== --
        -----------------------------------------------------------------------------
        -- Build Naval Units
        'U123 Naval Builders',

        -----------------------------------------------------------------------------
        -- ==== Sea Units FORMER ==== --
        -----------------------------------------------------------------------------
        'U123 Naval Formers PanicZone',
        'U123 Naval Formers MilitaryZone',
--        'U123 Naval Formers EnemyZone',
        'U123 Naval Formers Trasher',

        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS BUILDER ==== --
        -----------------------------------------------------------------------------
        'U4 Land Experimental Builders',
        'U4 Air Experimental Builders',

        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS FORMER ==== --
        -----------------------------------------------------------------------------
        'U4 Land Experimental Formers PanicZone',
--        'U4 Land Experimental Formers MilitaryZone',
--        'U4 Land Experimental Formers EnemyZone',
        'U4 Land Experimental Formers Trasher',
        'U4 Air Experimental Formers PanicZone',
        'U4 Air Experimental Formers MilitaryZone',
--        'U4 Air Experimental Formers EnemyZone',
        'U4 Air Experimental Formers Trasher',

        -----------------------------------------------------------------------------
        -- ==== Structure Shield BUILDER ==== --
        -----------------------------------------------------------------------------
        'U23 Shields Builder',
        'U23 Shields Upgrader',

        -----------------------------------------------------------------------------
        -- ==== Defenses BUILDER ==== --
        -----------------------------------------------------------------------------
        'U2 Tactical Missile Launcher minimum',
        'U2 Tactical Missile Launcher maximum',
        'U2 Tactical Missile Launcher Builder',
        'U2 Tactical Missile Defenses Builder',
        'U3 Strategic Missile Launcher Builder',
        'U4 Strategic Missile Launcher NukeAI',
        'U4 Strategic Missile Defense Builders',
        'U4 Strategic Missile Defense Anti-NukeAI',
        'U234 Artillery Builders',
        'U4 Artillery Formers', -- also needed for UEF SATELLITE
        -- Build Anti Air near AirFactories
        'U123 Defense Anti Air Builders',

        -----------------------------------------------------------------------------
        -- ==== FireBase BUILDER ==== --
        -----------------------------------------------------------------------------
        'U1 FirebaseBuilders',

        -----------------------------------------------------------------------------
        -- ==== Sniper Former ==== --
        -----------------------------------------------------------------------------
--        'U3 SACU Teleport Formers',

        -- We need this even if we have Omni View to get target informations for experimentals attack.
        -----------------------------------------------------------------------------
        -- ==== Scout BUILDER ==== --
        -----------------------------------------------------------------------------
        'U1 Land Scout Builders',
        'U1 Air Scout Builders',

        -----------------------------------------------------------------------------
        -- ==== Scout FORMER ==== --
        -----------------------------------------------------------------------------
        'U1 Land Scout Formers',
        'U13 Air Scout Formers', 

        -----------------------------------------------------------------------------
        -- ==== Intel/CounterIntel BUILDER ==== --
        -----------------------------------------------------------------------------
        'U1 Land Radar Builders',
        'U1 Land Radar Upgrader',
        'U1 Sonar Builders',
        'U1 Sonar Upgraders', 

--        'CounterIntelBuilders',

--        'AeonOptics',
--        'CybranOptics',

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
            Tech1 = 6,
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
        if personality == 'uvesoeasy' then
            return 1000, 'uvesoeasy'
        end
        return -1
    end,
}
