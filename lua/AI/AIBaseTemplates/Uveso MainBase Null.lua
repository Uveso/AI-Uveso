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
        'UC ACU Attack Former',
        'UC ACU Support Platoon',

        'N1 Factory Builders',
        'U123 Factory Upgrader Rush',


        'N1 Engineer Builders',

        'N1 Energy Builders',
        'N1 Hydro Energy Builders',
        'N1 Hydro UP',
--        'U123 EnergyStorage Builders',

        'N1 MassBuilders', 
        'U123 ExtractorUpgrades',
        'U1 MassStorage Builder',

--        'N1 Land Builders',
--        'N2 Land Builders',
--        'N3 Land Builders',

--        'U1 Land Radar Builders',
--        'U1 Land Radar Upgrader',

--        'U1 Land Scout Builders',
--        'U1 Land Scout Formers',
--        'U1 Air Scout Builders',
--        'U13 Air Scout Formers', 


--        'U123 Factory Upgrader Rush',
--        'N1 Transporter',
--        'U1 Land Scout Builders',
        
--        'N2 Land Builders',
--        'N3 Land Builders',
--        'U123 Land Builders Panic',
--        'N123 Land Formers',

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
        if personality == 'uvesonull' then
            return 1000, 'uvesonull'
        end
        return -1
    end,
}
