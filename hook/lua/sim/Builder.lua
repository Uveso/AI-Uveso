
OLDBuilder = Builder

Builder = Class(OLDBuilder) {

    Create = function(self, brain, data, locationType)
        -- Only use this with AI-Uveso
        if not brain.Uveso then
            return OLDBuilder.Create(self, brain, data, locationType)
        end
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

