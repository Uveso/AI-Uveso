#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/TurtleExpansion.lua
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'UvesoExpansionArea',
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
        -- ==== Energy ==== --
        -----------------------------------------------------------------------------
        -- Build Power Tech 1,2,3
        'EnergyBuilders Uveso',                       -- Priority = 1100

        -----------------------------------------------------------------------------
        -- ==== Factory ==== --
        -----------------------------------------------------------------------------
        -- Build Land/Air Factories
        'FactoryBuildersExpansions',
        -- Upgrade Factories TECH1->TECH2 and TECH2->TECH3
        'FactoryUpgradeBuildersRush Uveso',

        -----------------------------------------------------------------------------
        -- ==== Land Units BUILDER ==== --
        -----------------------------------------------------------------------------
        'LandAttackBuildersPanic Uveso',
        'LandAttackBuilders Uveso',
        'LandAttackBuildersRatio Uveso',
        'GateFactoryBuilders Uveso',

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
        if markerType ~= 'Expansion Area' then
            return -1
        end
        return 1000, 'UvesoExpansionArea'
    end,
}
