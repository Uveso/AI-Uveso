

OLDAIBrain = AIBrain

AIBrain = Class(OLDAIBrain) {

    OnCreateAI = function(self, planName)
        self:CreateBrainShared(planName)

        local civilian = false
        for name, data in ScenarioInfo.ArmySetup do
            if name == self.Name then
                civilian = data.Civilian
                break
            end
        end

        if not civilian then
            local per = ScenarioInfo.ArmySetup[self.Name].AIPersonality

            -- Flag this brain as a possible brain to have skirmish systems enabled on
            self.SkirmishSystems = true

            local cheatPos = string.find(per, 'cheat')
            if cheatPos then
                AIUtils.SetupCheat(self, true)
                ScenarioInfo.ArmySetup[self.Name].AIPersonality = string.sub(per, 1, cheatPos - 1)
            end
            LOG('* OnCreateAI: AIPersonality: ('..per..')')
            if string.find(per, 'sorian') then
                self.Sorian = true
            end
            if string.find(per, 'uveso') then
                self.Uveso = true
            end
            if string.find(per, 'dilli') then
                self.Dilli = true
            end
            if DiskGetFileInfo('/lua/AI/altaiutilities.lua') then
                self.Duncan = true
            end


            self.CurrentPlan = self.AIPlansList[self:GetFactionIndex()][1]
            self.EvaluateThread = self:ForkThread(self.EvaluateAIThread)
            self.ExecuteThread = self:ForkThread(self.ExecuteAIThread)

            self.PlatoonNameCounter = {}
            self.PlatoonNameCounter['AttackForce'] = 0
            self.BaseTemplates = {}
            self.RepeatExecution = true
            self:InitializeEconomyState()
            self.IntelData = {
                ScoutCounter = 0,
            }

            -- Flag enemy starting locations with threat?
            if ScenarioInfo.type == 'skirmish' then
                if self.Sorian then
                    -- Gives the initial threat a type so initial land platoons will actually attack it.
                    self:AddInitialEnemyThreatSorian(200, 0.005, 'Economy')
                else
                    self:AddInitialEnemyThreat(200, 0.005)
                end
            end
        end
        self.UnitBuiltTriggerList = {}
        self.FactoryAssistList = {}
        self.DelayEqualBuildPlattons = {}
        self.BrainType = 'AI'
    end,

}
