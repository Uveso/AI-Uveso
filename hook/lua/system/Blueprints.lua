
-- Permanent Hook. We need this to build platoons with Amphibious/Hover units only.

local OldModBlueprintsFunction = ModBlueprints
function ModBlueprints(all_blueprints)
    OldModBlueprintsFunction(all_blueprints)
    for id,bp in all_blueprints.Unit do
        if bp.Physics and bp.Physics.MotionType then
            -- Adding category 'AMPHIBIOUS' for AI platoon builder
            if bp.Physics.MotionType == 'RULEUMT_Amphibious' then
                -- Add the category to the blueprint Categories table
                if bp.Categories then
                    table.insert(bp.Categories, 'AMPHIBIOUS')
                end
                -- Also add the category to the CategoriesHash table
                if bp.CategoriesHash then
                    bp.CategoriesHash['AMPHIBIOUS'] = true
                end
            end
            -- Adding category 'FLOATING' for AI platoon builder
            if bp.Physics.MotionType == 'RULEUMT_Hover' or bp.Physics.MotionType == 'RULEUMT_AmphibiousFloating' then
                -- Add the category to the blueprint Categories table
                if bp.Categories then
                    table.insert(bp.Categories, 'FLOATING')
                end
                -- Also add the category to the CategoriesHash table
                if bp.CategoriesHash then
                    bp.CategoriesHash['FLOATING'] = true
                end
            end
        end
    end
end

-- For AI Patch V8 adding categories for preset SACUs
function HandleUnitWithBuildPresets(bps, all_bps)

    -- hashing sort categories for quick lookup
    local sortCategories = { ['SORTOTHER'] = true, ['SORTINTEL'] = true, ['SORTSTRATEGIC'] = true, ['SORTDEFENSE'] = true, ['SORTECONOMY'] = true, ['SORTCONSTRUCTION'] = true, }

    local tempBp = {}

    for k, bp in bps do

        for name, preset in bp.EnhancementPresets do
            -- start with clean copy of the original unit BP
            tempBp = table.deepcopy(bp)

            -- create BP table for the assigned preset with required info
            tempBp.EnhancementPresetAssigned = {
                Enhancements = table.deepcopy(preset.Enhancements),
                Name = name,
                BaseBlueprintId = bp.BlueprintId,
            }

            -- change cost of the new unit to match unit base cost + preset enhancement costs. An override is provided for cases where this is not desired.
            local e, m, t = 0, 0, 0
            if not preset.BuildCostEnergyOverride or not preset.BuildCostMassOverride or not preset.BuildTimeOverride then
                for k, enh in preset.Enhancements do
                    -- replaced continue by reversing if statement
                    if tempBp.Enhancements[enh] then
                        e = e + (tempBp.Enhancements[enh].BuildCostEnergy or 0)
                        m = m + (tempBp.Enhancements[enh].BuildCostMass or 0)
                        t = t + (tempBp.Enhancements[enh].BuildTime or 0)
                        -- HUSSAR added name of the enhancement so that preset units cannot be built
                        -- if they have restricted enhancement(s)
                        tempBp.CategoriesHash[enh] = true -- hashing without changing case of enhancements
                    else
                        WARN('*DEBUG: Enhancement '..repr(enh)..' used in preset '..repr(name)..' for unit '..repr(tempBp.BlueprintId)..' does not exist')
                    end
                end
            end
            tempBp.Economy.BuildCostEnergy = preset.BuildCostEnergyOverride or (tempBp.Economy.BuildCostEnergy + e)
            tempBp.Economy.BuildCostMass = preset.BuildCostMassOverride or (tempBp.Economy.BuildCostMass + m)
            tempBp.Economy.BuildTime = preset.BuildTimeOverride or (tempBp.Economy.BuildTime + t)

            -- teleport cost adjustments. Manually enhanced SCU with teleport is cheaper than a prebuild SCU because the latter has its cost
            -- adjusted (up). This code sets bp values used in the code to calculate with different base values than the unit cost.
            if preset.TeleportNoCostAdjustment ~= false then
                -- set teleport cost overrides to cost of base unit
                tempBp.Economy.TeleportEnergyCost = bp.Economy.BuildCostEnergy or 0
                tempBp.Economy.TeleportMassCost = bp.Economy.BuildMassEnergy or 0
            end

            -- Add a sorting category so similar SCUs are grouped together in the build menu
            if preset.SortCategory then
                if sortCategories[preset.SortCategory] or preset.SortCategory == 'None' then
                    for k, v in sortCategories do
                        tempBp.CategoriesHash[k] = false
                    end
                    if preset.SortCategory ~= 'None' then
                        tempBp.CategoriesHash[preset.SortCategory] = true
                    end
                end
            end

            -- change other things relevant things as well
            tempBp.BaseBlueprintId = tempBp.BlueprintId
            tempBp.BlueprintId = tempBp.BlueprintId .. '_' .. name
            tempBp.BuildIconSortPriority = preset.BuildIconSortPriority or tempBp.BuildIconSortPriority or 0
            tempBp.General.UnitName = preset.UnitName or tempBp.General.UnitName
            tempBp.Interface.HelpText = preset.HelpText or tempBp.Interface.HelpText
            tempBp.Description = preset.Description or tempBp.Description
            tempBp.CategoriesHash['ISPREENHANCEDUNIT'] = true
            tempBp.CategoriesHash[string.upper(name..'PRESET')] = true
            --SPEW('BlueprintID '..tempBp.BlueprintId..' added category.'..string.upper(name..'PRESET'))
            -- clean up some data that's not needed anymore
            tempBp.CategoriesHash['USEBUILDPRESETS'] = false
            tempBp.EnhancementPresets = nil
            -- synchronizing Categories with CategoriesHash for compatibility
            tempBp.Categories = table.unhash(tempBp.CategoriesHash)

            table.insert(all_bps.Unit, tempBp)

            BlueprintLoaderUpdateProgress()
        end
    end
end
