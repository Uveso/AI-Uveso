
-- hook until fix is released
-- https://github.com/FAForever/fa/pull/3248
GetAbilityDesc = {
    ability_radar = function(bp)
        return LOCF('<LOC uvd_Radius>', bp.Intel.RadarRadius)
    end,
    ability_sonar = function(bp)
        return LOCF('<LOC uvd_Radius>', bp.Intel.SonarRadius)
    end,
    ability_omni = function(bp)
        return LOCF('<LOC uvd_Radius>', bp.Intel.OmniRadius)
    end,
    ability_flying = function(bp)
        return LOCF("<LOC uvd_0011>Speed: %0.1f, Turning: %0.1f", bp.Air.MaxAirspeed, bp.Air.TurnSpeed)
    end,
    ability_carrier = function(bp)
        return LOCF('<LOC uvd_StorageSlots>', bp.Transport.StorageSlots)
    end,
    ability_factory = function(bp)
        return LOCF('<LOC uvd_BuildRate>', bp.Economy.BuildRate)
    end,
    ability_upgradable = function(bp)
        return GetShortDesc(__blueprints[bp.General.UpgradesTo])
    end,
    ability_tacticalmissledeflect = function(bp)
        return LOCF('<LOC uvd_Radius>', bp.Defense.AntiMissile.Radius)..', '
             ..LOCF('<LOC uvd_FireRate>', 1 / bp.Defense.AntiMissile.RedirectRateOfFire)
    end,
    --[[ability_transportable = function(bp)
        return LOCF('<LOC uvd_UnitSize>', bp.Transport.TransportClass)
    end,]]
    ability_transport = function(bp)
        local text = LOC('<LOC uvd_Capacity>')
        return bp.Transport and bp.Transport.Class1Capacity and text..bp.Transport.Class1Capacity
            or bp.CategoriesHash.TECH1 and text..'≈6'
            or bp.CategoriesHash.TECH2 and text..'≈12'
            or bp.CategoriesHash.TECH3 and text..'≈28'
            or ''
    end,
    ability_airstaging = function(bp)
        return LOCF('<LOC uvd_RepairRate>', bp.Transport.RepairRate)..', '
             ..LOCF('<LOC uvd_DockingSlots>', bp.Transport.DockingSlots)
    end,
    ability_jamming = function(bp)
        return LOCF('<LOC uvd_Radius>', bp.Intel.JamRadius.Max)..', '
             ..LOCF('<LOC uvd_Blips>', bp.Intel.JammerBlips)
    end,
    ability_personalshield = function(bp)
        return LOCF('<LOC uvd_RegenRate>', bp.Defense.Shield.ShieldRegenRate)
    end,
    ability_shielddome = function(bp)
        return LOCF('<LOC uvd_Radius>', bp.Defense.Shield.ShieldSize)..', '
             ..LOCF('<LOC uvd_RegenRate>', bp.Defense.Shield.ShieldRegenRate)
    end,
    ability_stealthfield = function(bp)
        return LOCF('<LOC uvd_Radius>', bp.Intel.RadarStealthFieldRadius)
    end,
    ability_stealth_sonarfield = function(bp)
        return LOCF('<LOC uvd_Radius>', bp.Intel.SonarStealthFieldRadius)
    end,
    ability_customizable = function(bp)
        local cnt = 0
        for _, v in bp.Enhancements do
            if v.RemoveEnhancements or (not v.Slot) then continue end
            cnt = cnt + 1
        end
        return cnt
    end,
    ability_massive = function(bp)
        return string.format(LOC('<LOC uvd_0010>Damage: %d, Splash: %d'),
            bp.Display.MovementEffects.Land.Footfall.Damage.Amount,
            bp.Display.MovementEffects.Land.Footfall.Damage.Radius)
    end,
    ability_teleport = function(bp)
        return LOCF('<LOC uvd_Delay>', bp.General.TeleportDelay)
    end
}
