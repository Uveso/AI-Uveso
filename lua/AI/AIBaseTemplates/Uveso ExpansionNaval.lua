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

        -----------------------------------------------------------------------------
        -- ==== Factory ==== --
        -----------------------------------------------------------------------------
        -- Build Naval Factories
        'FactoryBuildersNaval Uveso',
        -- Upgrade Naval Factories TECH1->TECH2 and TECH2->TECH3
        'FactoryUpgradeBuildersNaval Uveso',

        -----------------------------------------------------------------------------
        -- ==== Sea Units BUILDER ==== --
        -----------------------------------------------------------------------------
        -- Build Naval Units
        'SeaFactoryBuilders Uveso',

        -----------------------------------------------------------------------------
        -- ==== Sea Units FORMER ==== --
        -----------------------------------------------------------------------------
        'Sea FormBuilders PanicZone',
        'Sea FormBuilders MilitaryZone',
        'Sea FormBuilders EnemyZone',
        'Sea FormBuilders Trasher',

        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS BUILDER ==== --
        -----------------------------------------------------------------------------
        'Mobile Experimental Naval Builder Uveso',
        
        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS FORMER ==== --
        -----------------------------------------------------------------------------
        'Sea Experimental FormBuilders Panic',
        'Sea Experimental FormBuilders Military',
        'Sea Experimental FormBuilders EnemyZone',
        'Sea Experimental FormBuilders Trasher',

        -----------------------------------------------------------------------------
        -- ==== Defenses BUILDER ==== --
        -----------------------------------------------------------------------------
        'Tactical Missile Defenses Uveso',

        -----------------------------------------------------------------------------
        -- ==== Intel/CounterIntel BUILDER ==== --
        -----------------------------------------------------------------------------
        'SonarBuilders Uveso',
        'SonarUpgrade Uveso', 

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
        return 1000, 'UvesoExpansionNaval'
    end,
}
