-- Don't disable units on low energy/mass for AI-Uveso

TheOldEngineerManager = EngineerManager
EngineerManager = Class(TheOldEngineerManager) {

    LowMass = function(self)
        -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return TheOldEngineerManager.LowMass(self)
        end
    end,

    LowEnergy = function(self)
        -- Only use this with AI-Uveso
        if not self.Brain.Uveso then
            return TheOldEngineerManager.LowEnergy(self)
        end
    end,

}
