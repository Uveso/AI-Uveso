#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/NormalMain.lua
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'Uveso Null',
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

        'FactoryBuildersExp Uveso',
        'FactoryUpgradeBuildersRush Uveso',
        'GateConstruction Uveso',
        'GateFactoryBuilders Uveso',

--        'Air Transport Builder Uveso',

--        'Strategic Missile Launcher NukeAI Uveso',
        'RepairLowShields',

        -----------------------------------------------------------------------------
        -- ==== Factory ==== --
        -----------------------------------------------------------------------------
        -- Build Land/Air Factories
        'FactoryBuildersRush Uveso',
        -- Upgrade Factories TECH1->TECH2 and TECH2->TECH3
--        'FactoryUpgradeBuildersRush Uveso',


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
            return 1000, 'Uveso Null'
        end
        return -1
    end,
}
