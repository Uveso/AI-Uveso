
local UvesoSpawnSpecialPing = SpawnSpecialPing
function SpawnSpecialPing(data)

    -- fire the original function
    UvesoSpawnSpecialPing(data)
    
    -- check if we have a nuke here
    if data.Type ~= 'nuke' then
        return
    end

    -- delete all pings that are expired
    for i, brain in ArmyBrains do
        if brain.NukedArea then
            for i2, data in brain.NukedArea or {} do
                if data.NukeTime and data.NukeTime > 0 then
                    if data.NukeTime + 50 <  GetGameTimeSeconds() then
                        table.remove(ArmyBrains[i].NukedArea, i)
                    end
                end
            end
        end
    end

    -- add timestamp to nuke ping
    data.NukeTime = GetGameTimeSeconds()
    -- insert new nuke ping
    for i, brain in ArmyBrains do
        ArmyBrains[i].NukedArea = ArmyBrains[i].NukedArea or {}
        table.insert(ArmyBrains[i].NukedArea, data)
    end

end

-- data{
--   ArrowColor="red",
--   Lifetime=10,
--   Location={ 25.589538574219, 46.593200683594, 22.732711791992 },
--   Mesh="nuke_marker",
--   Owner=0,
--   Ring="/textures/ui/common/game/marker/ring_nuke04-blur.dds",
--   Sound="Aeon_Select_Radar",
--   Type="nuke"
--   NukeTime=238.30000305176
-- }
