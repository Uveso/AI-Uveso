
-- Hook For AI-Uveso. We need this to build platoons with Amphibious/Hover units only.
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
