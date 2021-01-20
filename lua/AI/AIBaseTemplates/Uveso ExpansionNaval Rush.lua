#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/TurtleExpansion.lua
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'UvesoExpansionNavalRush',
    Builders = {
        -----------------------------------------------------------------------------
        -- ==== Engineer ==== --
        -----------------------------------------------------------------------------
        -- Build Engineers Tech 1,2,3 and SACU
        'U123 Engineer Builders',            -- Priority = 900
        -- Assistees
        'UC123 Assistees',

        -----------------------------------------------------------------------------
        -- ==== Factory ==== --
        -----------------------------------------------------------------------------
        -- Build Naval Factories
        'U1 Factory Builders Naval',
        -- Upgrade Naval Factories TECH1->TECH2 and TECH2->TECH3
        'U123 Factory Upgrader Naval',

        -----------------------------------------------------------------------------
        -- ==== Sea Units BUILDER ==== --
        -----------------------------------------------------------------------------
        -- Build Naval Units
        'U123 Naval Builders RUSH',

        -----------------------------------------------------------------------------
        -- ==== Sea Units FORMER ==== --
        -----------------------------------------------------------------------------
        'U123 Naval Formers PanicZone',
        'U123 Naval Formers MilitaryZone',
        'U123 Naval Formers EnemyZone',
        'U123 Naval Formers Trasher',

        -----------------------------------------------------------------------------
        -- ==== Air Units FORMER==== --
        -----------------------------------------------------------------------------
        'U123 TorpedoBomber Formers',

        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS BUILDER ==== --
        -----------------------------------------------------------------------------
        'U4 Naval Experimental Builders',
        
        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS FORMER ==== --
        -----------------------------------------------------------------------------
        'U4 Naval Experimental Formers PanicZone',
        'U4 Naval Experimental Formers MilitaryZone',
        'U4 Naval Experimental Formers EnemyZone',
        'U4 Naval Experimental Formers Trasher',

        -----------------------------------------------------------------------------
        -- ==== Defenses BUILDER ==== --
        -----------------------------------------------------------------------------
        'U2 Tactical Missile Defenses Builder',

        -----------------------------------------------------------------------------
        -- ==== Intel/CounterIntel BUILDER ==== --
        -----------------------------------------------------------------------------
        'U1 Sonar Builders',
        'U1 Sonar Upgraders', 

    },

    BaseSettings = {
        FactoryCount = {
            Land = 0,
            Air = 0,
            Sea = 3,
            Gate = 0,
        },
        EngineerCount = {
            Tech1 = 2,
            Tech2 = 1,
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
        if markerType ~= 'Naval Area' then
            return -1
        end
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        if personality == 'uvesorush' then
            return 1000, 'UvesoExpansionNavalRush'
        end
        return -1
    end,
}
