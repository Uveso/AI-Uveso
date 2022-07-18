
Unit_FunctionBackupUveso = Unit
Unit = Class(Unit_FunctionBackupUveso) {

    -- Hook For AI-Uveso. prevent capturing
    OnStopBeingCaptured = function(self, captor)
        Unit_FunctionBackupUveso.OnStopBeingCaptured(self, captor)
        if self.Brain.Uveso then
            self:Kill()
        end
    end,

--    OnKilled = function(self, instigator, type, overkillRatio)
--        Unit_FunctionBackupUveso.OnKilled(self, instigator, type, overkillRatio)
--        if instigator and IsUnit(instigator) then
--            if self.Army and instigator.Army and self.Army ~= instigator.Army and IsAlly(self.Army, instigator.Army) then
--                local AIMSG = 'Player "'..self.Brain.Nickname..'", please stop killing my units.'
--                table.insert(Sync.AIChat, {group='all', text=AIMSG, sender=self.Brain.Nickname})
--                AIDebug('* AI-Uveso: OnKilled(): '..AIMSG)
--            end
--        end
--    end,

    OnStartReclaim = function(self, target)
        Unit_FunctionBackupUveso.OnStartReclaim(self, target)
        if self.Army and target.Army and self.Army ~= target.Army and IsAlly(self.Army, target.Army) then
            local AIMSG = 'Player "'..self.Brain.Nickname..'", please stop reclaiming my buildings.'
            table.insert(Sync.AIChat, {group='all', text=AIMSG, sender=target.Brain.Nickname})
            AILog('* AI-Uveso: OnStartReclaim(): '..AIMSG)
        end
    end,

    OnReclaimed = function(self, captor)
        Unit_FunctionBackupUveso.OnReclaimed(self, captor)
        if self.Army and captor.Army and self.Army ~= captor.Army and IsAlly(self.Army, captor.Army) then
            local AIMSG = 'Player "'..captor.Brain.Nickname..'" has reclaimed a allied building. Abuse report sent to server.'
            table.insert(Sync.AIChat, {group='all', text=AIMSG, sender=self.Brain.Nickname})
            --GpgNetSend('TeamReclaimReport', GetGameTimeSeconds(), self, captor)
            AIWarn('* AI-Uveso: OnReclaimed(): '..AIMSG)
        end
    end,

}
