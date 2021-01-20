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
        'N1 1 Factory Builders',
        'U123 Factory Upgrader Rush',

        'N1 1 Engineer Builders',
        'N1 1 Energy Builders',
        'N1 MassBuilders', 
        'N1 Transporter',
        'U1 Land Scout Builders',
        
        --'N1 Land Builders',
        'N2 Land Builders',
        'N3 Land Builders',
        'U123 Land Builders Panic',

        'N123 Land Formers',
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
