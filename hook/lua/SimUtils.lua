
function TransferUnfinishedUnitsAfterDeath(units, armies)
    -- Uveso: function is unstable!!! 29.Mar.2021
    -- function was optimized after last check, still crashing
    if 1 == 1 then
        return
    end
    AILog('* AI-Uveso: TransferUnfinishedUnitsAfterDeath() started')
    local unfinishedUnits = {}
    local noUnits = true
    local failedToTransfer = {}
    local failedToTransferCounter = 0
    local modifiedWrecks = {}
    local modifiedUnits = {}
    local createWreckIfTransferFailed = {}

    for _, unit in EntityCategoryFilterDown(categories.EXPERIMENTAL + categories.TECH3 * categories.STRUCTURE * categories.ARTILLERY, units) do
        --This transfer is pretty complex, so we do it only for really important units (EXPs and t3 arty).
        if unit:IsBeingBuilt() then
            unfinishedUnits[unit.EntityId] = unit
            noUnits = nil --have to store units using entityID and not table.insert
        end
    end

    if noUnits or not armies[1] then
        AILog('* AI-Uveso: TransferUnfinishedUnitsAfterDeath() ended, no units found to transfer')
        return
    end

    for key, army in armies do
        if key == 1 then --this is our first try and first army
            local builders = {}

            for ID, unit in unfinishedUnits do
                local bp = unit:GetBlueprint()
                local bplueprintID = bp.BlueprintId
                local buildTime = bp.Economy.BuildTime
                local health = unit:GetHealth()
                local pos = unit:GetPosition()
                local progress = unit:GetFractionComplete()

                --create invisible drone which belongs to allied army. BuildRange = 10000
                local builder = CreateUnitHPR('ZXA0001', army, 5, 20, 5, 0, 0, 0)
                table.insert(builders, builder)

                builder.UnitHealth = health
                builder.UnitPos = pos
                builder.UnitID = ID
                builder.UnitBplueprintID = bplueprintID
                builder.BuildRate = progress * buildTime * 10 --buildRate to reach required progress in 1 tick
                builder.DefaultProgress = math.floor(progress * 1000) --save current progress for some later checks

                --Save all important data because default unit will be destroyed during our first try
                failedToTransfer[ID] = {}
                failedToTransferCounter = failedToTransferCounter + 1
                failedToTransfer[ID].UnitHealth = health
                failedToTransfer[ID].UnitPos = pos
                failedToTransfer[ID].Bp = bp
                failedToTransfer[ID].BplueprintID = bplueprintID
                failedToTransfer[ID].BuildRate = progress * buildTime * 10
                failedToTransfer[ID].DefaultProgress = math.floor(progress * 1000)
                failedToTransfer[ID].Orientation = unit:GetOrientation()

                -- wrecks can prevent drone from starting construction
                local wrecks = GetReclaimablesInRect(unit:GetSkirtRect()) -- returns nil instead of empty table when empty
                if wrecks then 
                    for _, reclaim in wrecks do 
                        if reclaim.IsWreckage then
                            -- collision shape to none to prevent it from blocking, keep track to revert later
                            reclaim:SetCollisionShape('None')
                            table.insert(modifiedWrecks, reclaim)
                        end
                    end
                end

                -- units can prevent drone from starting construction
                local units = GetUnitsInRect(unit:GetSkirtRect()) -- returns nil instead of empty table when empty
                if units then 
                    for _,u in units do
                        -- collision shape to none to prevent it from blocking, keep track to revert later
                        u:SetCollisionShape('None')
                        table.insert(modifiedUnits, u)
                    end
                end

                if progress > 0.5 then --if transfer failed, we have to create wreck manually. progress should be more than 50%
                    createWreckIfTransferFailed[ID] = true
                end

                unit:Destroy() --destroy unfinished unit
-- CRASHED here x 1 (maybe a effect of unit:Destroy())

                IssueBuildMobile({builder}, pos, bplueprintID, {}) --Give command to our drone
-- CRASHED here x 1 (maybe a effect of IssueBuildMobile)
            end

            WaitTicks(3) --Wait some ticks (3 is minimum), IssueBuildMobile() is not instant
-- CRASHED here x 3 (maybe a late effect of IssueBuildMobile, unit:Destroy() or u:SetCollisionShape('None'))

            for _, builder in builders do
                builder:SetBuildRate(builder.BuildRate) --Set crazy build rate and consumption = 0
                builder:SetConsumptionPerSecondMass(0)
                builder:SetConsumptionPerSecondEnergy(0)
            end

            WaitTicks(1)

            for _, builder in builders do
                local newUnit = builder:GetFocusUnit()
                local builderProgress = math.floor(builder:GetWorkProgress() * 1000)
                if newUnit and builderProgress == builder.DefaultProgress then --our drone is busy and progress == DefaultProgress. Everything is fine
                    --That's for cases when unit was damaged while being built
                    --For example: default unit had 100/10000 hp but 90% progress.
                    newUnit:SetHealth(newUnit, builder.UnitHealth)

                    failedToTransfer[builder.UnitID] = nil
                    createWreckIfTransferFailed[builder.UnitID] = nil
                    failedToTransferCounter = failedToTransferCounter - 1
                end
                builder:Destroy()
            end

        elseif failedToTransferCounter > 0 then --failed to transfer some units to first army, let's try others.
            --This is just slightly modified version of our first try, no comments here
            local builders = {}

            for ID, data in failedToTransfer do
                local bp = data.Bp
                local bplueprintID = data.BplueprintID
                local buildRate = data.BuildRate
                local health = data.UnitHealth
                local pos = data.UnitPos
                local progress = data.DefaultProgress

                local builder = CreateUnitHPR('ZXA0001', army, 5, 20, 5, 0, 0, 0)
                table.insert(builders, builder)

                builder.UnitHealth = health
                builder.UnitPos = pos
                builder.UnitID = ID
                builder.UnitBplueprintID = bplueprintID
                builder.BuildRate = buildRate
                builder.DefaultProgress = progress

                IssueBuildMobile({builder}, pos, bplueprintID, {})
            end

            WaitTicks(3)

            for _, builder in builders do
                builder:SetBuildRate(builder.BuildRate)
                builder:SetConsumptionPerSecondMass(0)
                builder:SetConsumptionPerSecondEnergy(0)
            end

            WaitTicks(1)

            for _, builder in builders do
                local newUnit = builder:GetFocusUnit()
                local builderProgress = math.floor(builder:GetWorkProgress() * 1000)
                if newUnit and builderProgress == builder.DefaultProgress then
                    newUnit:SetHealth(newUnit, builder.UnitHealth)

                    failedToTransfer[builder.UnitID] = nil
                    createWreckIfTransferFailed[builder.UnitID] = nil
                    failedToTransferCounter = failedToTransferCounter - 1
                end
                builder:Destroy()
            end
        end
    end

    local createWreckage = import('/lua/wreckage.lua').CreateWreckage

    for ID,_ in createWreckIfTransferFailed do --create 50% wreck. Copied from Unit:CreateWreckageProp()
        local data = failedToTransfer[ID]
        local bp = data.Bp
        local pos = data.UnitPos
        local orientation = data.Orientation
        local mass = bp.Economy.BuildCostMass * 0.57 --0.57 to compensate some multipliers in CreateWreckage()
        local energy = 0
        local time = (bp.Wreckage.ReclaimTimeMultiplier or 1) * 2

        local wreck = createWreckage(bp, pos, orientation, mass, energy, time)
    end

    for key, wreck in modifiedWrecks do --revert wrecks collision shape. Copied from Prop.lua SetPropCollision()
        local radius = wreck.CollisionRadius
        local sizex = wreck.CollisionSizeX
        local sizey = wreck.CollisionSizeY
        local sizez = wreck.CollisionSizeZ
        local centerx = wreck.CollisionCenterX
        local centery = wreck.CollisionCenterY
        local centerz = wreck.CollisionCenterZ
        local shape = wreck.CollisionShape

        if radius and shape == 'Sphere' then
            wreck:SetCollisionShape(shape, centerx, centery, centerz, radius)
        else
            wreck:SetCollisionShape(shape, centerx, centery + sizey, centerz, sizex, sizey, sizez)
        end
    end

    for _, u in modifiedUnits do
        if not u:BeenDestroyed() then
            u:RevertCollisionShape()
        end
    end
    AILog('* AI-Uveso: TransferUnfinishedUnitsAfterDeath() ended, units transfered')
end
