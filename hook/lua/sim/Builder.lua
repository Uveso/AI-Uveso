
-- For Platoon debugging. Unremarking the debugline will print all platoons with priority inside game.log
TheOldPlatoonBuilder = PlatoonBuilder
PlatoonBuilder = Class(TheOldPlatoonBuilder) {

    Create = function(self,brain,data,locationType)
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

}


-- For Platoon debugging. Unremarking the debugline will print all platoons with priority inside game.log
TheOldFactoryBuilder = FactoryBuilder
FactoryBuilder = Class(TheOldFactoryBuilder) {

    Create = function(self,brain,data,locationType)
        Builder.Create(self,brain,data,locationType)
        --LOG(repr(data.BuilderType)..' - '..repr(data.Priority)..' - '..repr(data.BuilderName)..' - '..repr(data.PlatoonTemplate))
        local verifyDictionary = { 'PlatoonTemplate', }
        for k,v in verifyDictionary do
            if not self:VerifyDataName(v, data) then return false end
        end
        return true
    end,

}

-- For Platoon debugging. Unremarking the debugline will print all platoons with priority inside game.log
TheOldEngineerBuilder = EngineerBuilder
EngineerBuilder = Class(TheOldEngineerBuilder) {

    Create = function(self,brain,data, locationType)
        PlatoonBuilder.Create(self,brain,data, locationType)
        --LOG(repr(data.BuilderType)..' - '..repr(data.Priority)..' - '..repr(data.BuilderName)..' - '..repr(data.PlatoonTemplate))

        self.EconomyCost = { Mass = 0, Energy = 0 }

        return true
    end,

}
