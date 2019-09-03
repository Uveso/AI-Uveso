#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/NormalMain.lua
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'uvesonull',
    Builders = {
        -----------------------------------------------------------------------------
        -- ==== ACU ==== --
        -----------------------------------------------------------------------------
        -- Build Main Base (only once). Land/Air factory and basic Energy
        'UC ACU Attack Former',

        'U123 Engineer Builders',            -- Priority = 900
        'UC123 Assistees',

        'U1 MassBuilders',                           -- Priority = 1100
        'U123 ExtractorUpgrades',                      -- Priority = 1100

        'U123 Energy Builders',                       -- Priority = 1100

        'U1 Factory Builders 1st',
        'U1 Factory Builders EXPERIMENTAL',
        'U1 Factory Builders RECOVER',

        'U123 Factory Upgrader Rush',
--        'U1 Gate Builders',
--        'U3 SACU Builder',

--        'U123 Air Transport Builders',

        'U3 Strategic Missile Launcher Builder',
        'U4 Strategic Missile Launcher NukeAI',
        'U4 Strategic Missile Defense Builders',
        'U4 Strategic Missile Defense Anti-NukeAI',

--        'U234 Repair Shields Former',

        -----------------------------------------------------------------------------
        -- ==== Factory ==== --
        -----------------------------------------------------------------------------
        -- Build Land/Air Factories
--        'U1 Factory Builders RUSH',
        -- Upgrade Factories TECH1->TECH2 and TECH2->TECH3
--        'U123 Factory Upgrader Rush',

        -----------------------------------------------------------------------------
        -- ==== Sniper Former ==== --
        -----------------------------------------------------------------------------
--        'U3 SACU Teleport Formers',

    },
    -- Not used by Uveso's AI. We always need intel in case the commander is dead.
    NonCheatBuilders = {

    },

    BaseSettings = {
        FactoryCount = {
            Land = 3,
            Air = 2,
            Sea = 2,
            Gate = 2,
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
        if personality == 'uvesonull' or personality == 'uvesonullcheat' then
            --LOG('### M-FirstBaseFunction '..personality)
            return 1000, 'uvesonull'
        end
        return -1
    end,
}
