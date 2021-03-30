
-- For AI Patch V9. Reoved unstable funcion
function TransferUnfinishedUnitsAfterDeath(units, armies)
    -- Uveso: function is unstable!!! 29.Mar.2021
    if 1 == 1 then
        return
    end
    LOG('* AI-Uveso: CRASHTRACE TransferUnfinishedUnitsAfterDeath START')
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
        LOG('* AI-Uveso: CRASHTRACE TransferUnfinishedUnitsAfterDeath END 1')
        return
    end
    LOG('* AI-Uveso: CRASHTRACE TransferUnfinishedUnitsAfterDeath unfinishedUnits count...')

    for key, army in armies do
        LOG('* AI-Uveso: CRASHTRACE TransferUnfinishedUnitsAfterDeath looping over army '..key)
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
                builder:SetCanTakeDamage(false)
                builder:SetCanBeKilled(false)

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

                for _, reclaim in GetReclaimablesInRect(unit:GetSkirtRect()) or {} do --wrecks can prevent drone from starting construction
                    if reclaim.IsWreckage then 
                        LOG('* AI-Uveso: CRASHTRACE 393 reclaim:SetCollisionShape')
--                        coroutine.yield(3)
                        if not reclaim:BeenDestroyed() and reclaim.SetCollisionShape then
                            reclaim:SetCollisionShape('None') --so we set collision shape 'None'
                            table.insert(modifiedWrecks, reclaim) --and save wrecks to revert our changes later
                        else
                            LOG('* AI-Uveso: CRASHTRACE 393 unit(reclaim) not present')
                        end
                    end
                end       
               
                for _,u in GetUnitsInRect(unit:GetSkirtRect()) or {} do --same as for wrecks
                    LOG('* AI-Uveso: CRASHTRACE 400 GetUnitsInRect loop')
--                    coroutine.yield(3)
                    if IsUnit(u) and not u:BeenDestroyed() and u.SetCollisionShape then
                        LOG('* AI-Uveso: CRASHTRACE 400 u:SetCollisionShape')
                        u:SetCollisionShape('None')
                        table.insert(modifiedUnits, u)
                    else
                        LOG('* AI-Uveso: CRASHTRACE 400 unit(u) not present')
                    end
                end 
                
                if progress > 0.5 then --if transfer failed, we have to create wreck manually. progress should be more than 50%
                    createWreckIfTransferFailed[ID] = true    
                end
                
                LOG('* AI-Uveso: CRASHTRACE 400 coroutine.yield(5)')
                coroutine.yield(5)

                LOG('* AI-Uveso: CRASHTRACE 405 unit:Destroy()')
                if not unit or unit:BeenDestroyed() then
                    LOG('* AI-Uveso: CRASHTRACE 405 unit:Destroy() ALREADY DESTROYED coroutine.yield(5)')
                    coroutine.yield(5)
                end
                unit:Destroy() --destroy unfinished unit
                
                LOG('* AI-Uveso: CRASHTRACE 405 coroutine.yield(5)')
                coroutine.yield(5)
-- CRASHED here x 1 (maybe a effect of unit:Destroy())

                LOG('* AI-Uveso: CRASHTRACE 410 IssueBuildMobile pos:'..repr(pos)..' - bplueprintID:'..repr(bplueprintID)..' - builder.BuildRate:'..repr(builder.BuildRate))
                LOG('* AI-Uveso: CRASHTRACE 410 coroutine.yield(5)')
                coroutine.yield(5)
                LOG('* AI-Uveso: CRASHTRACE 410 IssueBuildMobile')
                if not builder or builder:BeenDestroyed() then
                    LOG('* AI-Uveso: CRASHTRACE 410 IssueBuildMobile builder ALREADY DESTROYED coroutine.yield(5)')
                    coroutine.yield(5)
                end
                IssueBuildMobile({builder}, pos, bplueprintID, {}) --Give command to our drone 
-- CRASHED here x 1 (maybe a effect of IssueBuildMobile)
            end

            LOG('* AI-Uveso: CRASHTRACE 412 coroutine.yield(3)')
            coroutine.yield(3) --Wait some ticks (3 is minimum), IssueBuildMobile() is not instant

-- CRASHED here x 3 (maybe a late effect of IssueBuildMobile, unit:Destroy() or u:SetCollisionShape('None'))

            LOG('* AI-Uveso: CRASHTRACE 413 coroutine.yield(4)')
            coroutine.yield(4)

            LOG('* AI-Uveso: CRASHTRACE 414 builder in builders START')

            for _, builder in builders do
                LOG('* AI-Uveso: CRASHTRACE 414 builder in builders (buildrate: '..repr(builder.BuildRate)..' ... LOOP')
                coroutine.yield(3)
                builder:SetBuildRate(builder.BuildRate) --Set crazy build rate and consumption = 0
                builder:SetConsumptionPerSecondMass(0)
                builder:SetConsumptionPerSecondEnergy(0)
                coroutine.yield(3)
                LOG('* AI-Uveso: CRASHTRACE 414 builder in builders... END')
            end
            
            LOG('* AI-Uveso: CRASHTRACE 415 coroutine.yield(1)')
            coroutine.yield(1)
            
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
                LOG('* AI-Uveso: CRASHTRACE 415 builder:Destroy()')
                builder:Destroy()
            end
            LOG('* AI-Uveso: CRASHTRACE 416 builder finished')

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

            coroutine.yield(3)
            
            for _, builder in builders do
                builder:SetBuildRate(builder.BuildRate)
                builder:SetConsumptionPerSecondMass(0)
                builder:SetConsumptionPerSecondEnergy(0)
            end
            
            coroutine.yield(1)
            
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
    LOG('* AI-Uveso: CRASHTRACE TransferUnfinishedUnitsAfterDeath CreateWreckage...')

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
    LOG('* AI-Uveso: CRASHTRACE TransferUnfinishedUnitsAfterDeath SetCollisionShape...')

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
            LOG('* AI-Uveso: CRASHTRACE 512 wreck:SetCollisionShape')
            LOG('* AI-Uveso: CRASHTRACE 512 Shape Data: shape '..repr(shape)..' - centerx '..repr(centerx)..' - centery '..repr(centery)..' - centerz '..repr(centerz)..' - radius '..repr(radius)..'')
            if not centerx then
                LOG('* AI-Uveso: CRASHTRACE 512 wreck:SetCollisionShape: centerx is not present')
                continue
            end
            if not centery then
                LOG('* AI-Uveso: CRASHTRACE 512 wreck:SetCollisionShape: centery is not present')
                continue
            end
            if not centerz then
                LOG('* AI-Uveso: CRASHTRACE 512 wreck:SetCollisionShape: centerz is not present')
                continue
            end
            if not radius then
                LOG('* AI-Uveso: CRASHTRACE 512 wreck:SetCollisionShape: radius is not present')
                continue
            end
            if wreck:BeenDestroyed() then
                LOG('* AI-Uveso: CRASHTRACE 512 wreck:SetCollisionShape: wreck has been destroyed!')
                continue
            end
--            coroutine.yield(3)
            wreck:SetCollisionShape(shape, centerx, centery, centerz, radius)
        elseif shape == 'Box' then
            LOG('* AI-Uveso: CRASHTRACE 514 wreck:SetCollisionShape')
            LOG('* AI-Uveso: CRASHTRACE 514 Shape Data: shape '..repr(shape)..' - centerx '..repr(centerx)..' - centery '..repr(centery)..' - centerz '..repr(centerz)..' - sizex '..repr(sizex)..' - sizey '..repr(sizey)..' - sizez '..repr(sizez)..'')
            if not centerx then
                LOG('* AI-Uveso: CRASHTRACE 514 wreck:SetCollisionShape: centerx is not present')
                continue
            end
            if not centery then
                LOG('* AI-Uveso: CRASHTRACE 514 wreck:SetCollisionShape: centery is not present')
                continue
            end
            if not centerz then
                LOG('* AI-Uveso: CRASHTRACE 514 wreck:SetCollisionShape: centerz is not present')
                continue
            end
            if not sizex then
                LOG('* AI-Uveso: CRASHTRACE 514 wreck:SetCollisionShape: sizex is not present')
                continue
            end
            if not sizey then
                LOG('* AI-Uveso: CRASHTRACE 514 wreck:SetCollisionShape: sizey is not present')
                continue
            end
            if not sizez then
                LOG('* AI-Uveso: CRASHTRACE 514 wreck:SetCollisionShape: sizez is not present')
                continue
            end
            if wreck:BeenDestroyed() then
                LOG('* AI-Uveso: CRASHTRACE 514 wreck:SetCollisionShape: wreck has been destroyed!')
                continue
            end
--           coroutine.yield(3)
            wreck:SetCollisionShape(shape, centerx, centery + sizey, centerz, sizex, sizey, sizez)
        else
            LOG('* AI-Uveso: CRASHTRACE 519 wreck:SetCollisionShape: NO Sphere or Box Shape found')
        end
    end
    LOG('* AI-Uveso: CRASHTRACE TransferUnfinishedUnitsAfterDeath RevertCollisionShape...')

    for _, u in modifiedUnits do
        if not u:BeenDestroyed() then
            u:RevertCollisionShape()
        end   
    end    
    LOG('* AI-Uveso: CRASHTRACE TransferUnfinishedUnitsAfterDeath END 2')

    LOG('* AI-Uveso: CRASHTRACE 525 coroutine.yield(4)')
    coroutine.yield(4)
    LOG('* AI-Uveso: CRASHTRACE 526 coroutine.yield(3)')
    coroutine.yield(3)

    LOG('* AI-Uveso: CRASHTRACE TransferUnfinishedUnitsAfterDeath END 3')

end