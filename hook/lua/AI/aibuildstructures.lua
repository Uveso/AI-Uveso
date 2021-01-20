

-- AI-Uveso: Hook for Replace factory buildtemplate to find a better buildplace not too close to the center of the base
local AntiSpamList = {}
UvesoAIExecuteBuildStructure = AIExecuteBuildStructure
function AIExecuteBuildStructure(aiBrain, builder, buildingType, closeToBuilder, relative, buildingTemplate, baseTemplate, reference, NearMarkerType)
    -- Only use this with AI-Uveso
    if not aiBrain.Uveso then
        return UvesoAIExecuteBuildStructure(aiBrain, builder, buildingType, closeToBuilder, relative, buildingTemplate, baseTemplate, reference, NearMarkerType)
    end
    local factionIndex = aiBrain:GetFactionIndex()
    local whatToBuild = aiBrain:DecideWhatToBuild(builder, buildingType, buildingTemplate)
    local FactionIndexToName = {[1] = 'UEF', [2] = 'AEON', [3] = 'CYBRAN', [4] = 'SERAPHIM', [5] = 'NOMADS', [6] = 'ARM', [7] = 'CORE' }
    local AIFactionName = FactionIndexToName[factionIndex] or 'Unknown'
    -- If the c-engine can't decide what to build, then search the build template manually.
    if not whatToBuild then
        if AntiSpamList[buildingType] then
            return false
        end
        SPEW('* AI-Uveso: AIExecuteBuildStructure: c-function DecideWhatToBuild() failed! - AI-faction: index('..factionIndex..') '..AIFactionName..', Building Type: '..repr(buildingType)..', engineer-faction: '..repr(builder.factionCategory))
        -- Get the UnitId for the actual buildingType
        if not buildingTemplate then
            WARN('* AI-Uveso: AIExecuteBuildStructure: Function was called without a buildingTemplate!')
        end
        local BuildUnitWithID
        for Key, Data in buildingTemplate do
            if Data[1] and Data[2] and Data[1] == buildingType then
                SPEW('* AI-Uveso: AIExecuteBuildStructure: Found template: '..repr(Data[1])..' - Using UnitID: '..repr(Data[2]))
                BuildUnitWithID = Data[2]
                break
            end
        end
        -- If we can't find a template, then return
        if not BuildUnitWithID then
            AntiSpamList[buildingType] = true
            WARN('* AI-Uveso: AIExecuteBuildStructure: No '..repr(builder.factionCategory)..' unit found for template: '..repr(buildingType)..'! ')
            return false
        end
        -- get the needed tech level to build buildingType
        local BBC = __blueprints[BuildUnitWithID].CategoriesHash
        local NeedTech
        if BBC.BUILTBYCOMMANDER or BBC.BUILTBYTIER1COMMANDER or BBC.BUILTBYTIER1ENGINEER then
            NeedTech = 1
        elseif BBC.BUILTBYTIER2COMMANDER or BBC.BUILTBYTIER2ENGINEER then
            NeedTech = 2
        elseif BBC.BUILTBYTIER3COMMANDER or BBC.BUILTBYTIER3ENGINEER then
            NeedTech = 3
        elseif BBC.BUILTBYTIER1FACTORY or BBC.BUILTBYTIER2FACTORY or BBC.BUILTBYTIER3FACTORY  or BBC.BUILTBYQUANTUMGATE then
            WARN('* AI-Uveso: AIExecuteBuildStructure: Unit is buildable by factory !!! BuildUnitWithID:'..repr(BuildUnitWithID))
        else 
            WARN('* AI-Uveso: AIExecuteBuildStructure: Unknown builder category for BuildUnitWithID:'..repr(BuildUnitWithID))
        end
        -- If we can't find a techlevel for the building we want to build, then return
        if not NeedTech then
            WARN('* AI-Uveso: AIExecuteBuildStructure: Can\'t find engineer techlevel for BuildUnitWithID: '..repr(BuildUnitWithID))
            return false
        else
            SPEW('* AI-Uveso: AIExecuteBuildStructure: Need engineer with Techlevel ('..NeedTech..') for BuildUnitWithID: '..repr(BuildUnitWithID))
        end
        -- get the actual tech level from the builder
        local BC = builder:GetBlueprint().CategoriesHash
        if BC.TECH1 or BC.COMMAND then
            HasTech = 1
        elseif BC.TECH2 then
            HasTech = 2
        elseif BC.TECH3 then
            HasTech = 3
        end
        -- If we can't find a techlevel for the building we  want to build, return
        if not HasTech then
            WARN('* AI-Uveso: AIExecuteBuildStructure: Can\'t find techlevel for engineer: '..repr(builder:GetBlueprint().BlueprintId))
            return false
        else
            SPEW('* AI-Uveso: AIExecuteBuildStructure: Engineer ('..repr(builder:GetBlueprint().BlueprintId)..') has Techlevel ('..HasTech..')')
        end

        if HasTech < NeedTech then
            WARN('* AI-Uveso: AIExecuteBuildStructure: TECH'..HasTech..' Unit "'..BuildUnitWithID..'" is assigned to build TECH'..NeedTech..' buildplatoon! ('..repr(buildingType)..')')
            return false
        else
            SPEW('* AI-Uveso: AIExecuteBuildStructure: Engineer with Techlevel ('..HasTech..') can build TECH'..NeedTech..' BuildUnitWithID: '..repr(BuildUnitWithID))
        end
      
        HasFaction = builder.factionCategory
        NeedFaction = string.upper(__blueprints[string.lower(BuildUnitWithID)].General.FactionName)
        if HasFaction ~= NeedFaction then
            WARN('* AI-Uveso: AIExecuteBuildStructure: AI-faction: '..AIFactionName..', ('..HasFaction..') engineers can\'t build ('..NeedFaction..') structures!')
            return false
        else
            SPEW('* AI-Uveso: AIExecuteBuildStructure: AI-faction: '..AIFactionName..', Engineer with faction ('..HasFaction..') can build faction ('..NeedFaction..') - BuildUnitWithID: '..repr(BuildUnitWithID))
        end
       
        local IsRestricted = import('/lua/game.lua').IsRestricted
        if IsRestricted(BuildUnitWithID, GetFocusArmy()) then
            WARN('* AI-Uveso: AIExecuteBuildStructure: Unit is Restricted!!! Building Type: '..repr(buildingType)..', faction: '..repr(builder.factionCategory)..' - Unit:'..BuildUnitWithID)
            AntiSpamList[buildingType] = true
            return false
        end

        WARN('* AI-Uveso: AIExecuteBuildStructure: All checks passed, forcing enginner TECH'..HasTech..' '..HasFaction..' '..builder:GetBlueprint().BlueprintId..' to build TECH'..NeedTech..' '..buildingType..' '..BuildUnitWithID..'')
        whatToBuild = BuildUnitWithID
        --return false
    else
        -- Sometimes the AI is building a unit that is different from the buildingTemplate table. So we validate the unitID here.
        -- Looks like it never occurred, or i missed the warntext. For now, we don't need it
        for Key, Data in buildingTemplate do
            if Data[1] and Data[2] and Data[1] == buildingType then
                if whatToBuild ~= Data[2] then
                    WARN('* AI-Uveso: AIExecuteBuildStructure: Missmatch whatToBuild: '..whatToBuild..' ~= buildingTemplate.Data[2]: '..repr(Data[2]))
                    whatToBuild = Data[2]
                end
                break
            end
        end
    end
    -- find a place to build it (ignore enemy locations if it's a resource)
    -- build near the base the engineer is part of, rather than the engineer location
    local relativeTo
    if closeToBuilder then
        relativeTo = builder:GetPosition()
        --LOG('* AI-Uveso: AIExecuteBuildStructure: Searching for Buildplace near Engineer'..repr(relativeTo))
    else
        if builder.BuilderManagerData and builder.BuilderManagerData.EngineerManager then
            relativeTo = builder.BuilderManagerData.EngineerManager.Location
            --LOG('* AI-Uveso: AIExecuteBuildStructure: Searching for Buildplace near BuilderManager ')
        else
            local startPosX, startPosZ = aiBrain:GetArmyStartPos()
            relativeTo = {startPosX, 0, startPosZ}
            --LOG('* AI-Uveso: AIExecuteBuildStructure: Searching for Buildplace near ArmyStartPos ')
        end
    end
    local location = false
    local buildingTypeReplace
    local whatToBuildReplace

    -- if we wnat to build a factory use the Seraphim Awassa for a bigger build place
    if buildingType == 'T1LandFactory' or buildingType == 'T1AirFactory' then
        buildingTypeReplace = 'T4AirExperimental1'
        whatToBuildReplace = 'xsa0402'
    elseif buildingType == 'T1SeaFactory' then
        buildingTypeReplace = 'T4SeaExperimental1'
        whatToBuildReplace = 'ues0401'
    end

    if IsResource(buildingType) then
        location = aiBrain:FindPlaceToBuild(buildingType, whatToBuild, baseTemplate, relative, closeToBuilder, 'Enemy', relativeTo[1], relativeTo[3], 5)
    else
        location = aiBrain:FindPlaceToBuild(buildingTypeReplace or buildingType, whatToBuildReplace or whatToBuild, baseTemplate, relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
    end

    -- if it's a reference, look around with offsets
    if not location and reference then
        for num,offsetCheck in RandomIter({1,2,3,4,5,6,7,8}) do
            location = aiBrain:FindPlaceToBuild(buildingTypeReplace or buildingType, whatToBuildReplace or whatToBuild, BaseTmplFile['MovedTemplates'..offsetCheck][factionIndex], relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
            if location then
                break
            end
        end
    end

    -- fallback in case we can't find a place to build with experimental template
    if not location and not IsResource(buildingType) then
        location = aiBrain:FindPlaceToBuild(buildingType, whatToBuild, baseTemplate, relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
    end

    -- fallback in case we can't find a place to build with experimental template
    if not location and not IsResource(buildingType) then
        for num,offsetCheck in RandomIter({1,2,3,4,5,6,7,8}) do
            location = aiBrain:FindPlaceToBuild(buildingType, whatToBuild, BaseTmplFile['MovedTemplates'..offsetCheck][factionIndex], relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
            if location then
                break
            end
        end
    end

    -- if we have no place to build, then maybe we have a modded/new buildingType. Lets try 'T1LandFactory' as dummy and search for a place to build near base
    if not location and not IsResource(buildingType) and builder.BuilderManagerData and builder.BuilderManagerData.EngineerManager then
        --LOG('* AI-Uveso: AIExecuteBuildStructure: Find no place to Build! - buildingType '..repr(buildingType)..' - ('..builder.factionCategory..') Trying again with T1LandFactory and RandomIter. Searching near base...')
        relativeTo = builder.BuilderManagerData.EngineerManager.Location
        for num,offsetCheck in RandomIter({1,2,3,4,5,6,7,8}) do
            location = aiBrain:FindPlaceToBuild('T1LandFactory', 'ueb0101', BaseTmplFile['MovedTemplates'..offsetCheck][factionIndex], relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
            if location then
                --LOG('* AI-Uveso: AIExecuteBuildStructure: Yes! Found a place near base to Build! - buildingType '..repr(buildingType))
                break
            end
        end
    end

    -- if we still have no place to build, then maybe we have really no place near the base to build. Lets search near engineer position
    if not location and not IsResource(buildingType) then
        --LOG('* AI-Uveso: AIExecuteBuildStructure: Find still no place to Build! - buildingType '..repr(buildingType)..' - ('..builder.factionCategory..') Trying again with T1LandFactory and RandomIter. Searching near Engineer...')
        relativeTo = builder:GetPosition()
        for num,offsetCheck in RandomIter({1,2,3,4,5,6,7,8}) do
            location = aiBrain:FindPlaceToBuild('T1LandFactory', 'ueb0101', BaseTmplFile['MovedTemplates'..offsetCheck][factionIndex], relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
            if location then
                --LOG('* AI-Uveso: AIExecuteBuildStructure: Yes! Found a place near engineer to Build! - buildingType '..repr(buildingType))
                break
            end
        end
    end

    -- if we have a location, build!
    if location then
        local relativeLoc = BuildToNormalLocation(location)
        if relative then
            relativeLoc = {relativeLoc[1] + relativeTo[1], relativeLoc[2] + relativeTo[2], relativeLoc[3] + relativeTo[3]}
        end
        -- put in build queue.. but will be removed afterwards... just so that it can iteratively find new spots to build
        --LOG('* AI-Uveso: AIExecuteBuildStructure: AI-faction: index('..factionIndex..') '..repr(AIFactionName)..', Building Type: '..repr(buildingType)..', engineer-faction: '..repr(builder.factionCategory))
        AddToBuildQueue(aiBrain, builder, whatToBuild, NormalToBuildLocation(relativeLoc), false)
        return true
    end
    -- At this point we're out of options, so move on to the next thing
    WARN('* AI-Uveso: AIExecuteBuildStructure: c-function FindPlaceToBuild() failed! AI-faction: index('..factionIndex..') '..repr(AIFactionName)..', Building Type: '..repr(buildingType)..', engineer-faction: '..repr(builder.factionCategory))
    return false
end
