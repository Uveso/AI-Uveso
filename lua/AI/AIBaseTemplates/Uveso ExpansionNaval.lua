#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/TurtleExpansion.lua
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'UvesoExpansionNaval',
    Builders = {
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
        -- Build Land/Air/Naval Factories
        'FactoryBuilders Uveso',
        -- Upgrade Factories TECH1->TECH2 and TECH2->TECH3
        'FactoryUpgradeBuildersRush Uveso',

        -----------------------------------------------------------------------------
        -- ==== Land Units BUILDER ==== --
        -----------------------------------------------------------------------------
        -- Build T1 Land Units
        'LandAttackBuildersPanic Uveso',
        'LandAttackBuilders Uveso',
        'LandAttackBuildersRatio Uveso',
        'GateFactoryBuilders Uveso',

        -----------------------------------------------------------------------------
        -- ==== Land Units FORMER==== --
        -----------------------------------------------------------------------------
        'Land FormBuilders Panic',
        'Land FormBuilders MilitaryZone',
        'Land FormBuilders EnemyZone',

        -----------------------------------------------------------------------------
        -- ==== Air Units BUILDER ==== --
        -----------------------------------------------------------------------------
        -- Build as much antiair as the enemy has
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
        
        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS FORMER ==== --
        -----------------------------------------------------------------------------
        'ExperimentalAttackFormBuilders Uveso',

        -----------------------------------------------------------------------------
        -- ==== Structure Shield BUILDER ==== --
        -----------------------------------------------------------------------------
        'Shields Uveso',
        'ShieldUpgrades Uveso',
        'RepairLowShields',

        -----------------------------------------------------------------------------
        -- ==== Defenses BUILDER ==== --
        -----------------------------------------------------------------------------
        'Tactical Missile Defenses Uveso',
        'Strategic Missile Launcher Uveso',
        'Strategic Missile Defense Uveso',

        -----------------------------------------------------------------------------
        -- ==== FireBase BUILDER ==== --
        -----------------------------------------------------------------------------

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
            return 0
        end
        if markerType ~= 'Naval Area' then
            return 0
        end
        return 1000, 'UvesoExpansionNaval'
    end,
}
