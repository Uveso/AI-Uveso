#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/TurtleExpansion.lua
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'UvesoExpansionAreaLarge',
    Builders = {
        -----------------------------------------------------------------------------
        -- ==== Engineer ==== --
        -----------------------------------------------------------------------------
        -- Build Engineers Tech 1,2,3 and SACU
        'U123 Engineer Builders',            -- Priority = 900
        -- Assistees
        'UC123 Assistees',
        -- Reclaim mass
        'U1 Engineer Reclaim',
        -- Return engineers back to base
        'U123 Engineer Transfer To MainBase',

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
        'U1 Factory Builders Expansions',
        -- Upgrade Factories TECH1->TECH2 and TECH2->TECH3
        'U123 Factory Upgrader Rush',

        -----------------------------------------------------------------------------
        -- ==== Land Units BUILDER ==== --
        -----------------------------------------------------------------------------
        'U123 Land Builders Panic',
        'U123 Land Builders ADAPTIVE',
        'U3 SACU Builder',

        -----------------------------------------------------------------------------
        -- ==== Land Units FORMER==== --
        -----------------------------------------------------------------------------
        'U123 Land Formers PanicZone',
        'U123 Land Formers MilitaryZone',
        'U123 Land Formers EnemyZone',
        'U123 Land Formers Trasher',
        'U123 Land Formers Guards',

        -----------------------------------------------------------------------------
        -- ==== Hover Units FORMER==== --
        -----------------------------------------------------------------------------
        'U123 Hover Formers PanicZone',
        'U123 Hover Formers MilitaryZone',
        'U123 Hover Formers EnemyZone',
        'U123 Hover Formers Trasher',

        -----------------------------------------------------------------------------
        -- ==== Amphibious Units BUILDER ==== --
        -----------------------------------------------------------------------------
        'U123 Amphibious Builders',

        -----------------------------------------------------------------------------
        -- ==== Amphibious Units FORMER==== --
        -----------------------------------------------------------------------------
        'U123 Amphibious Formers PanicZone',
        'U123 Amphibious Formers MilitaryZone',
        'U123 Amphibious Formers EnemyZone',
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
        'U123 Air Formers EnemyZone',
        'U123 Air Formers Trasher',
        'U123 TorpedoBomber Formers',
        
        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS BUILDER ==== --
        -----------------------------------------------------------------------------
        'U4 Land Experimental Builders',
        'U4 Air Experimental Builders',
        
        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS FORMER ==== --
        -----------------------------------------------------------------------------
        'U4 Land Experimental Formers PanicZone',
        'U4 Land Experimental Formers MilitaryZone',
        'U4 Land Experimental Formers EnemyZone',
        'U4 Land Experimental Formers Trasher',
        'U4 Air Experimental Formers PanicZone',
        'U4 Air Experimental Formers MilitaryZone',
        'U4 Air Experimental Formers EnemyZone',
        'U4 Air Experimental Formers Trasher',

        -----------------------------------------------------------------------------
        -- ==== Structure Shield BUILDER ==== --
        -----------------------------------------------------------------------------
        'U23 Shields Builder',
        'U23 Shields Upgrader',
        'U234 Repair Shields Former',

        -----------------------------------------------------------------------------
        -- ==== Defenses BUILDER ==== --
        -----------------------------------------------------------------------------
        'U2 Tactical Missile Defenses Builder',
        'U3 Strategic Missile Launcher Builder',
        'U4 Strategic Missile Defense Builders MAIN',

        -----------------------------------------------------------------------------
        -- ==== FireBase BUILDER ==== --
        -----------------------------------------------------------------------------

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

    },
    -- We need intel in case the commander is dead.
    NonCheatBuilders = {

    },

    BaseSettings = {
        FactoryCount = {
            Land = 2,
            Air = 2,
            Sea = 1,
            Gate = 0,
        },
        EngineerCount = {
            Tech1 = 2,
            Tech2 = 2,
            Tech3 = 1,
            SCU = 0,
        },
        MassToFactoryValues = {
            T1Value = 6,
            T2Value = 15,
            T3Value = 22.5
        },
    },
    ExpansionFunction = function(aiBrain, location, markerType)
        if not aiBrain.Uveso then
            return -1
        end
        if markerType ~= 'Large Expansion Area' then
            return -1
        end
        return 1000, 'UvesoExpansionArea'
    end,
}
