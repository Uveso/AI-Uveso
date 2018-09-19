#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/TurtleExpansion.lua
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'UvesoStartArea',
    Builders = {
        -----------------------------------------------------------------------------
        -- ==== Engineer ==== --
        -----------------------------------------------------------------------------
        -- Build Engineers Tech 1,2,3 and SACU
        'EngineerFactoryBuilders Uveso',            -- Priority = 900
        -- Assistees
        'Assistees Uveso',
        -- Transfers Engineers from LocatonType (Expansions, Firebase etc.) to mainbase
        'Engineer Transfer To MainBase', -- Need to be in Expansion Template

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
        'LandAttackBuilders Uveso',
        'LandAttackBuildersRatio Uveso',

        -----------------------------------------------------------------------------
        -- ==== Land Units FORMER==== --
        -----------------------------------------------------------------------------
        'Land FormBuilders EnemyZone',
        
        -----------------------------------------------------------------------------
        -- ==== Air Units BUILDER ==== --
        -----------------------------------------------------------------------------
        -- Build as much antiair as the enemy has
        'AntiAirBuilders Uveso',
        'AntiExperimentalAirBuilders Uveso',
        -- Build Air Transporter
        'Air Transport Builder Uveso',

        -----------------------------------------------------------------------------
        -- ==== Air Units FORMER==== --
        -----------------------------------------------------------------------------
        'Air FormBuilders',
        
        -----------------------------------------------------------------------------
        -- ==== Sea Units BUILDER ==== --
        -----------------------------------------------------------------------------

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
        'Shields Uveso',
        'ShieldUpgrades Uveso',

        -----------------------------------------------------------------------------
        -- ==== Defenses BUILDER ==== --
        -----------------------------------------------------------------------------
        'Tactical Missile Launcher minimum Uveso',
        'Tactical Missile Launcher Maximum Uveso',
        'Tactical Missile Launcher TacticalAISorian Uveso',
        'Tactical Missile Defenses Uveso',
        'Strategic Missile Launcher Uveso',
        'Strategic Missile Defense Uveso',
        'Artillery Builder Uveso',
        -- Build Anti Air near AirFactories
        'Base Anti Air Defense Uveso',


        -- We need this even if we have Omni View to get target informations for experimentals attack.
        -----------------------------------------------------------------------------
        -- ==== Scout BUILDER ==== --
        -----------------------------------------------------------------------------
        'ScoutBuilder Uveso',

        -----------------------------------------------------------------------------
        -- ==== Scout FORMER ==== --
        -----------------------------------------------------------------------------
        'ScoutFormer Uveso',

        -----------------------------------------------------------------------------
        -- ==== Intel/CounterIntel BUILDER ==== --
        -----------------------------------------------------------------------------
        'RadarUpgrade Uveso',
        
        'CounterIntelBuilders',

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
        if markerType ~= 'Start Location' then
            return 0
        end
        return 1000, 'UvesoStartArea'
    end,
}
