
local UvesoUnit = Unit
Unit = Class(UvesoUnit) {

    -- For AI Patch V8. Only fork a thread if we need to
    StopRocking = function(self)
        if self.StartRockThread then
            KillThread(self.StartRockThread)
            self.StopRockThread = self:ForkThread(self.EndRockingThread)
        end
    end,
    -- For AI Patch V8. Need to hook the deathThread to remoce the DestroyAllBuildEffects() call
    DeathThread = function(self, overkillRatio, instigator)
        local isNaval = EntityCategoryContains(categories.NAVAL, self)
        local shallSink = self:ShallSink()

        WaitSeconds(utilities.GetRandomFloat(self.DestructionExplosionWaitDelayMin, self.DestructionExplosionWaitDelayMax))

        if not self.BagsDestroyed then
            self:DestroyAllBuildEffects()
            self:DestroyAllTrashBags()
            self.BagsDestroyed = true
        end

        -- Stop any motion sounds we may have
        self:StopUnitAmbientSound('AmbientMove')
        self:StopUnitAmbientSound('AmbientMoveLand')
        self:StopUnitAmbientSound('AmbientMoveWater')

        -- BOOM!
        if self.PlayDestructionEffects then
            self:CreateDestructionEffects(overkillRatio)
        end

        -- Flying bits of metal and whatnot. More bits for more overkill.
        if self.ShowUnitDestructionDebris and overkillRatio then
            self.CreateUnitDestructionDebris(self, true, true, overkillRatio > 2)
        end

        if shallSink then
            self.DisallowCollisions = true

            -- Bubbles and stuff coming off the sinking wreck.
            self:ForkThread(self.SinkDestructionEffects)

            -- Avoid slightly ugly need to propagate this through callback hell...
            self.overkillRatio = overkillRatio

            if isNaval and self:GetBlueprint().Display.AnimationDeath then
                -- Waits for wreck to hit bottom or end of animation
                if self:GetFractionComplete() > 0.5 then
                    self:SeabedWatcher()
                else
                    self:DestroyUnit(overkillRatio)
                end
            else
                -- A non-naval unit or boat with no sinking animation dying over water needs to sink, but lacks an animation for it. Let's make one up.
                local this = self
                self:StartSinking(
                    function()
                        this:DestroyUnit(overkillRatio)
                    end
                )

                -- Wait for the sinking callback to actually destroy the unit.
                return
            end
        elseif self.DeathAnimManip then -- wait for non-sinking animations
            WaitFor(self.DeathAnimManip)
        end

        -- If we're not doing fancy sinking rubbish, just blow the damn thing up.
        self:DestroyUnit(overkillRatio)
    end,
    -- For AI Patch V8 add function to clear bags
    OnDestroy = function(self)
        self.Dead = true

        if self:GetFractionComplete() < 1 then
            self:SendNotifyMessage('cancelled')
        end

        -- Clear out our sync data
        UnitData[self.EntityId] = false
        Sync.UnitData[self.EntityId] = false

        -- Don't allow anyone to stuff anything else in the table
        self.Sync = false

        -- Let the user layer know this id is gone
        Sync.ReleaseIds[self.EntityId] = true

        -- Destroy everything added to the trash
        self.Trash:Destroy()
        -- Destroy all extra trashbags in case the DeathTread() has not already destroyed it (modded DeathThread etc.)
        if not self.BagsDestroyed then
            self:DestroyAllBuildEffects()
            self:DestroyAllTrashBags()
        end
        
        if self.TeleportDrain then
            RemoveEconomyEvent(self, self.TeleportDrain)
        end

        RemoveAllUnitEnhancements(self)

        -- remove all callbacks from the unit
        if self.EventCallbacks then
            self.EventCallbacks = nil
        end

        ChangeState(self, self.DeadState)
    end,
    -- For AI Patch V8 sestroy also all bags
    DestroyAllTrashBags = function(self)
        -- Some bags should really be managed by their classes
        -- but for mod compatibility reasons we delete them all here.
        for _, v in self.EffectsBag or {} do
            v:Destroy()
        end
        for k, v in self.ShieldEffectsBag or {} do
            v:Destroy()
        end
        for _, v in self.ReleaseEffectsBag or {} do
            v:Destroy()
        end
        for _, v in self.AmbientExhaustEffectsBag or {} do
            v:Destroy()
        end
        for k, v in self.OmniEffectsBag or {} do
            v:Destroy()
        end
        for k, v in self.AdjacencyBeamsBag or {} do
            v.Trash:Destroy()
            self.AdjacencyBeamsBag[k] = nil
        end
        for _, v in self.IntelEffectsBag or {} do
            v:Destroy()
        end
        for _, v in self.TeleportDestChargeBag or {} do
            v:Destroy()
        end
        for _, v in self.TeleportSoundChargeBag or {} do
            v:Destroy()
        end
        for _, EffectsBag in self.DamageEffectsBag or {} do
            for _, v in EffectsBag do
                v:Destroy()
            end
        end
        for _, v in self.IdleEffectsBag or {} do
            v:Destroy()
        end
        for _, v in self.TopSpeedEffectsBag or {} do
            v:Destroy()
        end
        for _, v in self.BeamExhaustEffectsBag or {} do
            v:Destroy()
        end
        for _, v in self.MovementEffectsBag or {} do
            v:Destroy()
        end
        for _, v in self.TransportBeamEffectsBag or {} do
            v:Destroy()
        end
    end,

    -- Hook For AI-Uveso. prevent capturing
    OnStopBeingCaptured = function(self, captor)
        UvesoUnit.OnStopBeingCaptured(self, captor)
        local aiBrain = self:GetAIBrain()
        if aiBrain.Uveso then
            self:Kill()
        end
    end,

}
