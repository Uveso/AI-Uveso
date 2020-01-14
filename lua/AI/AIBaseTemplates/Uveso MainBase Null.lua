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

        'U123 Engineer Builders',

        'U1 MassBuilders',
        'U1 Mass Capture',

        'U123 Energy Builders',

        'U1 Factory Builders 1st',
        'U1 Factory Builders RECOVER',
        'U1 Factory Builders ADAPTIVE',

        'U123 Air Builders ADAPTIVE',
        'U123 Air Builders Anti-Experimental',

        'U123 Air Formers PanicZone',

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
        if personality == 'uvesonull' or personality == 'uvesonullcheat' then
            --LOG('### M-FirstBaseFunction '..personality)
            return 1000, 'uvesonull' -- AIPersonality
        end
        return -1
    end,
}
