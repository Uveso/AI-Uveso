-- hook until AI patch is out
OLDBuilder = Builder
Builder = Class(OLDBuilder) {

    Create = function(self, brain, data, locationType)
        # make sure the table of strings exist, they are required for the builder
        local verifyDictionary = { 'Priority', 'BuilderName' }
        for k,v in verifyDictionary do
            if not self:VerifyDataName(v, data) then return false end
        end

        self.Priority = data.Priority
        self.OriginalPriority = self.Priority

        self.Brain = brain

        self.BuilderName = data.BuilderName
        
        self.DelayEqualBuildPlattons = data.DelayEqualBuildPlattons

        self.ReportFailure = data.ReportFailure

        self:SetupBuilderConditions(data, locationType)

        self.BuilderStatus = false

        return true
    end,

}

-- For Platoon debugging
OLDPlatoonBuilder = PlatoonBuilder
PlatoonBuilder = Class(OLDPlatoonBuilder) {

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
