-- Don't disable units on low energy/mass for AI-Uveso

UvesoEngineerManager = EngineerManager
EngineerManager = Class(UvesoEngineerManager) {

    -- Hook For AI-Uveso. Don't need this, we have our own ecomanagement
    LowMass = function(self)
        -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return UvesoEngineerManager.LowMass(self)
        end
    end,

    -- Hook For AI-Uveso. Don't need this, we have our own ecomanagement
    LowEnergy = function(self)
        -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return UvesoEngineerManager.LowEnergy(self)
        end
    end,

}
