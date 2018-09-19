
-- Permanent Hook. We need this to build platoons with Amphibious units only.

local OldModBlueprints = ModBlueprints
function ModBlueprints(all_blueprints)
    OldModBlueprints(all_blueprints)
    for id,bp in all_blueprints.Unit do
        -- Add category 'AMPHIBIOUS' for AI platoon builder
        if bp.Physics and bp.Physics.MotionType and (bp.Physics.MotionType == 'RULEUMT_Amphibious' or bp.Physics.MotionType == 'RULEUMT_Hover' or bp.Physics.MotionType == 'RULEUMT_AmphibiousFloating') then
            -- Add the category to the blueprint Categories table
            table.insert(bp.Categories, 'AMPHIBIOUS')
            -- Also add the category to the CategoriesHash table
            bp.CategoriesHash['AMPHIBIOUS'] = true
        end
    end
end
