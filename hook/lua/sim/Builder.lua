-- For Platoon debugging. Unremarking the debugline will print all platoons with priority inside game.log

CopyOfPlatoonBuilderForUveso = PlatoonBuilder
PlatoonBuilder = Class(CopyOfPlatoonBuilderForUveso) {

    Create = function(self,brain,data,locationType)
       -- Only use this with AI-Uveso
        if not brain.Uveso then
            return CopyOfPlatoonBuilderForUveso.Create(self,brain,data,locationType)
        end
        Builder.Create(self,brain,data,locationType)
        --LOG(repr(data.BuilderType)..' - '..repr(data.Priority)..' - '..repr(data.BuilderName)..' - '..repr(data.PlatoonTemplate))
        local verifyDictionary = { 'PlatoonTemplate', }
        for k,v in verifyDictionary do
            if not self:VerifyDataName(v, data) then return false end
        end

        # Setup for instances to be stored inside a table rather than creating new
        self.InstanceCount = {}
        local num = 1
        while num <= (data.InstanceCount or 1) do
            table.insert(self.InstanceCount, { Status = 'Available', PlatoonHandle = false })
            num = num + 1
        end
        return true
    end,

    CalculatePriority = function(self, builderManager)
       -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return CopyOfPlatoonBuilderForUveso.CalculatePriority(self, builderManager)
        end
        self.PriorityAltered = false
        if Builders[self.BuilderName].PriorityFunction then
            --LOG('Calculate new Priority '..self.BuilderName..' - '..self.Priority)
            local newPri = Builders[self.BuilderName]:PriorityFunction(self.Brain)
            if newPri != self.Priority then
                --LOG('* AI-Uveso: PlatoonBuilder New Priority:  [[  '..self.Priority..' -> '..newPri..'  ]]  -  '..self.BuilderName..'.')
                self.Priority = newPri
                self.PriorityAltered = true
            end
            --LOG('CopyOfPlatoonBuilderForUveso New Priority '..self.BuilderName..' - '..self.Priority)
        end
        return self.PriorityAltered
    end,

}

-- For Platoon debugging. Unremarking the debugline will print all platoons with priority inside game.log
CopyOfFactoryBuilderForUveso = FactoryBuilder
FactoryBuilder = Class(CopyOfFactoryBuilderForUveso) {

    Create = function(self,brain,data,locationType)
       -- Only use this with AI-Uveso
        if not brain.Uveso then
            return CopyOfFactoryBuilderForUveso.Create(self,brain,data,locationType)
        end
        Builder.Create(self,brain,data,locationType)
        --LOG(repr(data.BuilderType)..' - '..repr(data.Priority)..' - '..repr(data.BuilderName)..' - '..repr(data.PlatoonTemplate))
        local verifyDictionary = { 'PlatoonTemplate', }
        for k,v in verifyDictionary do
            if not self:VerifyDataName(v, data) then return false end
        end
        return true
    end,

    CalculatePriority = function(self, builderManager)
       -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return CopyOfFactoryBuilderForUveso.CalculatePriority(self, builderManager)
        end
        self.PriorityAltered = false
        if Builders[self.BuilderName].PriorityFunction then
            --LOG('Calculate new Priority '..self.BuilderName..' - '..self.Priority)
            local newPri = Builders[self.BuilderName]:PriorityFunction(self.Brain)
            if newPri != self.Priority then
                --LOG('* AI-Uveso: FactoryBuilder New Priority:  [[  '..self.Priority..' -> '..newPri..'  ]]  -  '..self.BuilderName..'.')
                self.Priority = newPri
                self.PriorityAltered = true
            end
            --LOG('CopyOfFactoryBuilderForUveso New Priority '..self.BuilderName..' - '..self.Priority)
        end
        return self.PriorityAltered
    end,

}

-- For Platoon debugging. Unremarking the debugline will print all platoons with priority inside game.log
CopyOfEngineerBuilderForUveso = EngineerBuilder
EngineerBuilder = Class(CopyOfEngineerBuilderForUveso) {

    Create = function(self,brain,data, locationType)
       -- Only use this with AI-Uveso
        if not brain.Uveso then
            return CopyOfEngineerBuilderForUveso.Create(self,brain,data, locationType)
        end
        PlatoonBuilder.Create(self,brain,data, locationType)
        --LOG(repr(data.BuilderType)..' - '..repr(data.Priority)..' - '..repr(data.BuilderName)..' - '..repr(data.PlatoonTemplate))

        self.EconomyCost = { Mass = 0, Energy = 0 }

        return true
    end,

    CalculatePriority = function(self, builderManager)
       -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return CopyOfEngineerBuilderForUveso.CalculatePriority(self, builderManager)
        end
        self.PriorityAltered = false
        if Builders[self.BuilderName].PriorityFunction then
            --LOG('Calculate new Priority '..self.BuilderName..' - '..self.Priority)
            local newPri = Builders[self.BuilderName]:PriorityFunction(self.Brain)
            if newPri != self.Priority then
                --LOG('* AI-Uveso: EngineerBuilder New Priority:  [[  '..self.Priority..' -> '..newPri..'  ]]  -  '..self.BuilderName..'.')
                self.Priority = newPri
                self.PriorityAltered = true
            end
            --LOG('CopyOfEngineerBuilderForUveso New Priority '..self.BuilderName..' - '..self.Priority)
        end
        return self.PriorityAltered
    end,

}
