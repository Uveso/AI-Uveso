-- Don't disable units on low energy/mass

OLDEngineerManager = EngineerManager
EngineerManager = Class(OLDEngineerManager) {

    LowMass = function(self)
        -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return OLDEngineerManager.LowMass(self)
        end
    end,

    LowEnergy = function(self)
        -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return OLDEngineerManager.LowEnergy(self)
        end
    end,

}

