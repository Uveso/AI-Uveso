local AIDefaultPlansList = import("/lua/aibrainplans.lua").AIPlansList
local AIUtils = import("/lua/ai/aiutilities.lua")

local Utilities = import("/lua/utilities.lua")
local ScenarioUtils = import("/lua/sim/scenarioutilities.lua")
local Behaviors = import("/lua/ai/aibehaviors.lua")
local AIBuildUnits = import("/lua/ai/aibuildunits.lua")

local FactoryManager = import("/lua/sim/factorybuildermanager.lua")
local PlatoonFormManager = import("/lua/sim/platoonformmanager.lua")
local BrainConditionsMonitor = import("/lua/sim/brainconditionsmonitor.lua")
local EngineerManager = import("/lua/sim/engineermanager.lua")

local SUtils = import("/lua/ai/sorianutilities.lua")
local TransferUnitsOwnership = import("/lua/simutils.lua").TransferUnitsOwnership
local TransferUnfinishedUnitsAfterDeath = import("/lua/simutils.lua").TransferUnfinishedUnitsAfterDeath
local CalculateBrainScore = import("/lua/sim/score.lua").CalculateBrainScore
local Factions = import('/lua/factions.lua').GetFactions(true)

local CoroutineYield = coroutine.yield

local StandardBrain = import("/lua/aibrain.lua").AIBrain

local UvesoAIBrainClass = import("/lua/aibrains/base-ai.lua").AIBrain

AIBrain = Class(UvesoAIBrainClass) {

     -- Hook AI-Uveso, set self.Uveso = true
     OnCreateAI = function(self, planName)
         UvesoAIBrainClass.OnCreateAI(self, planName)
         local per = ScenarioInfo.ArmySetup[self.Name].AIPersonality
         if string.find(per, 'uveso') then
             AILog('* AI-Uveso: OnCreateAI() found AI-Uveso  Name: ('..self.Name..') - personality: ('..per..') ')
             self.Uveso = true
         end
     end,

     BaseMonitorThread = function(self)
         coroutine.yield(10)
         -- We are leaving this forked thread here because we don't need it.
         KillThread(CurrentThread())
     end,

     CanPathToCurrentEnemy = function(self)
         coroutine.yield(10)
         -- We are leaving this forked thread here because we don't need it.
         KillThread(CurrentThread())
     end,

     EconomyMonitor = function(self)
         coroutine.yield(10)
         -- We are leaving this forked thread here because we don't need it.
         KillThread(self.EconomyMonitorThread)
         self.EconomyMonitorThread = nil
     end,

    ExpansionHelpThread = function(self)
         AILog('* AI-Uveso: Function called: ExpansionHelpThread')
         coroutine.yield(10)
         -- We are leaving this forked thread here because we don't need it.
         KillThread(CurrentThread())
     end,

     SetupAttackVectorsThread = function(self)
         AILog('* AI-Uveso: Function called: SetupAttackVectorsThread')
        -- Only use this with AI-Uveso
         coroutine.yield(10)
         -- We are leaving this forked thread here because we don't need it.
         KillThread(CurrentThread())
     end,

     ParseIntelThread = function(self)
         AILog('* AI-Uveso: Function called: ParseIntelThread')
         coroutine.yield(10)
         -- We are leaving this forked thread here because we don't need it.
         KillThread(CurrentThread())
     end,


}