
-- For Platoon debugging. Unremarking the debugline will print all platoons with priority inside game.log
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
