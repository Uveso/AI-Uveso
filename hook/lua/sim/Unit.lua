
Unit_FunctionBackupUveso = Unit
Unit = Class(Unit_FunctionBackupUveso) {

    -- Hook For AI-Uveso. prevent capturing
    OnStopBeingCaptured = function(self, captor)
        Unit_FunctionBackupUveso.OnStopBeingCaptured(self, captor)
        if self.Brain.Uveso then
            self:Kill()
        end
    end,

    -- Hook For AI-Uveso. warn on reclaim start
    OnStartReclaim = function(self, target)
        Unit_FunctionBackupUveso.OnStartReclaim(self, target)
        if target.Brain.Uveso then
            if self.Army and target.Army and self.Army ~= target.Army and IsAlly(self.Army, target.Army) then
                local AIMSG = 'Player "'..self.Brain.Nickname..'", please stop reclaiming my buildings.'
                table.insert(Sync.AIChat, {group='all', text=AIMSG, sender=target.Brain.Nickname})
                AILog('* AI-Uveso: OnStartReclaim(): '..AIMSG)
            end
        end
    end,

    -- Hook For AI-Uveso. reprot abuse after reclaim
    OnReclaimed = function(self, captor)
        Unit_FunctionBackupUveso.OnReclaimed(self, captor)
        if self.Brain.Uveso then
            if self.Army and captor.Army and self.Army ~= captor.Army and IsAlly(self.Army, captor.Army) then
                local AIMSG = 'Player "'..captor.Brain.Nickname..'" has reclaimed a allied building. Abuse report sent to server.'
                table.insert(Sync.AIChat, {group='all', text=AIMSG, sender=self.Brain.Nickname})
                --GpgNetSend('TeamReclaimReport', GetGameTimeSeconds(), self, captor)
                AIWarn('* AI-Uveso: OnReclaimed(): '..AIMSG)
            end
        end
    end,

}
