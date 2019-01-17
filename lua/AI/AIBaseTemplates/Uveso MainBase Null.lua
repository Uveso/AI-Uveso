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
        'ACU Former Uveso',

        'EngineerFactoryBuilders Uveso',            -- Priority = 900
        'Assistees Uveso',

        'MassBuilders Uveso',                           -- Priority = 1100
        'ExtractorUpgrades Uveso',                      -- Priority = 1100

        'EnergyBuilders Uveso',                       -- Priority = 1100

        'FactoryBuilders 1st Uveso',
        'FactoryBuildersExperimental Uveso',
        'FactoryBuilders RECOVER Uveso',

        'FactoryUpgradeBuildersRush Uveso',
        'GateConstruction Uveso',
        'GateFactoryBuilders Uveso',

--        'Air Transport Builder Uveso',

--        'Strategic Missile Launcher Uveso',
--        'Strategic Missile Launcher NukeAI Uveso',
--        'Strategic Missile Defense Uveso',
--        'Strategic Missile Defense Anti-NukeAI Uveso',

        'RepairLowShields',

        -----------------------------------------------------------------------------
        -- ==== Factory ==== --
        -----------------------------------------------------------------------------
        -- Build Land/Air Factories
--        'FactoryBuilders RUSH Uveso',
        -- Upgrade Factories TECH1->TECH2 and TECH2->TECH3
--        'FactoryUpgradeBuildersRush Uveso',

        -----------------------------------------------------------------------------
        -- ==== Sniper Former ==== --
        -----------------------------------------------------------------------------
        'SACU TeleportFormer',

    },
    -- Not used by Uveso's AI. We always need intel in case the commander is dead.
    NonCheatBuilders = {

    },

    BaseSettings = {
        FactoryCount = {
            Land = 5,
            Air = 1,
            Sea = 1,
            Gate = 3,
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
