local UvesoOffsetaibuildstructuresLUA = debug.getinfo(1).currentline - 1
SPEW('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..UvesoOffsetaibuildstructuresLUA..'] * AI-Uveso: offset aibuildstructures.lua')
--2964


-- AI-Uveso: Hook for Replace factory buildtemplate to find a better buildplace not too close to the center of the base
local AntiSpamList = {}
local MexPositions = {}
local LastGetMassMarker = {}

UvesoAIExecuteBuildStructure = AIExecuteBuildStructure
function AIExecuteBuildStructure(aiBrain, builder, buildingType, closeToBuilder, relative, buildingTemplate, baseTemplate, reference, NearMarkerType)
    -- Only use this with AI-Uveso
    if not aiBrain.Uveso then
        return UvesoAIExecuteBuildStructure(aiBrain, builder, buildingType, closeToBuilder, relative, buildingTemplate, baseTemplate, reference, NearMarkerType)
    end
    local playableArea = import('/mods/AI-Uveso/lua/AI/AITargetManager.lua').GetPlayableArea()
    local factionIndex = aiBrain:GetFactionIndex()
    local whatToBuild = aiBrain:DecideWhatToBuild(builder, buildingType, buildingTemplate)
    local FactionIndexToName = {[1] = 'UEF', [2] = 'AEON', [3] = 'CYBRAN', [4] = 'SERAPHIM', [5] = 'NOMADS', [6] = 'ARM', [7] = 'CORE' }
    local AIFactionName = FactionIndexToName[factionIndex] or 'Unknown'
    -- If the c-engine can't decide what to build, then search the build template manually.
    if not whatToBuild then
        if AntiSpamList[buildingType] then
            return false
        end
        AIWarn('* AI-Uveso: AIExecuteBuildStructure: c-function DecideWhatToBuild() failed! - AI-faction: index('..factionIndex..') '..AIFactionName..', Building Type: '..repr(buildingType)..', engineer-faction: '..repr(string.upper(builder.Blueprint.General.FactionName)), true, UvesoOffsetaibuildstructuresLUA)
        -- Get the UnitId for the actual buildingType
        if not buildingTemplate then
            AIWarn('* AI-Uveso: AIExecuteBuildStructure: Function was called without a buildingTemplate!', true, UvesoOffsetaibuildstructuresLUA)
        end
        local BuildUnitWithID
        for Key, Data in buildingTemplate do
            if Data[1] and Data[2] and Data[1] == buildingType then
                AIDebug('* AI-Uveso: AIExecuteBuildStructure: Found template: '..repr(Data[1])..' - Using UnitID: '..repr(Data[2]), true, UvesoOffsetaibuildstructuresLUA)
                BuildUnitWithID = Data[2]
                break
            end
        end
        -- If we can't find a template, then return
        if not BuildUnitWithID then
            AntiSpamList[buildingType] = true
            AIWarn('* AI-Uveso: AIExecuteBuildStructure: No '..repr(string.upper(builder.Blueprint.General.FactionName))..' unit found for template: '..repr(buildingType)..'! ', true, UvesoOffsetaibuildstructuresLUA)
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
            AIWarn('* AI-Uveso: AIExecuteBuildStructure: Unit is buildable by factory, not engineer!!! BuildUnitWithID:'..repr(BuildUnitWithID), true, UvesoOffsetaibuildstructuresLUA)
        else 
            AIWarn('* AI-Uveso: AIExecuteBuildStructure: Unknown builder category for BuildUnitWithID:'..repr(BuildUnitWithID), true, UvesoOffsetaibuildstructuresLUA)
        end
        -- If we can't find a techlevel for the building we want to build, then return
        if not NeedTech then
            AIWarn('* AI-Uveso: AIExecuteBuildStructure: Can\'t find engineer techlevel for BuildUnitWithID: '..repr(BuildUnitWithID), true, UvesoOffsetaibuildstructuresLUA)
            return false
        else
            AIDebug('* AI-Uveso: AIExecuteBuildStructure: Need engineer with Techlevel ('..NeedTech..') for BuildUnitWithID: '..repr(BuildUnitWithID), true, UvesoOffsetaibuildstructuresLUA)
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
            AIWarn('* AI-Uveso: AIExecuteBuildStructure: Can\'t find techlevel for engineer: '..repr(builder:GetBlueprint().BlueprintId), true, UvesoOffsetaibuildstructuresLUA)
            return false
        else
            AIDebug('* AI-Uveso: AIExecuteBuildStructure: Engineer ('..repr(builder:GetBlueprint().BlueprintId)..') has Techlevel ('..HasTech..')', true, UvesoOffsetaibuildstructuresLUA)
        end

        if HasTech < NeedTech then
            AIWarn('* AI-Uveso: AIExecuteBuildStructure: TECH'..HasTech..' Unit "'..BuildUnitWithID..'" is assigned to build TECH'..NeedTech..' buildplatoon! ('..repr(buildingType)..')', true, UvesoOffsetaibuildstructuresLUA)
            return false
        else
            AIDebug('* AI-Uveso: AIExecuteBuildStructure: Engineer with Techlevel ('..HasTech..') can build TECH'..NeedTech..' BuildUnitWithID: '..repr(BuildUnitWithID), true, UvesoOffsetaibuildstructuresLUA)
        end
      
        HasFaction = string.upper(builder.Blueprint.General.FactionName)
        NeedFaction = string.upper(__blueprints[string.lower(BuildUnitWithID)].General.FactionName)
        if HasFaction ~= NeedFaction then
            AIWarn('* AI-Uveso: AIExecuteBuildStructure: AI-faction: '..AIFactionName..', ('..HasFaction..') engineers can\'t build ('..NeedFaction..') structures!', true, UvesoOffsetaibuildstructuresLUA)
            return false
        else
            AIDebug('* AI-Uveso: AIExecuteBuildStructure: AI-faction: '..AIFactionName..', Engineer with faction ('..HasFaction..') can build faction ('..NeedFaction..') - BuildUnitWithID: '..repr(BuildUnitWithID), true, UvesoOffsetaibuildstructuresLUA)
        end
       
        local IsRestricted = import('/lua/game.lua').IsRestricted
        if IsRestricted(BuildUnitWithID, aiBrain:GetArmyIndex()) then
            AIWarn('* AI-Uveso: AIExecuteBuildStructure: Unit is Restricted!!! Building Type: '..repr(buildingType)..', faction: '..repr(string.upper(builder.Blueprint.General.FactionName))..' - Unit:'..BuildUnitWithID, true, UvesoOffsetaibuildstructuresLUA)
            AntiSpamList[buildingType] = true
            return false
        else
            AIDebug('* AI-Uveso: AIExecuteBuildStructure: Unit is not restricted. Building Type: '..repr(buildingType)..', faction: '..repr(string.upper(builder.Blueprint.General.FactionName))..' - Unit:'..BuildUnitWithID, true, UvesoOffsetaibuildstructuresLUA)
        end

        AIWarn('* AI-Uveso: AIExecuteBuildStructure: All checks passed, forcing enginner TECH'..HasTech..' '..HasFaction..' '..builder:GetBlueprint().BlueprintId..' to build TECH'..NeedTech..' '..buildingType..' '..BuildUnitWithID..'', true, UvesoOffsetaibuildstructuresLUA)
        whatToBuild = BuildUnitWithID
        --return false
    else
        -- Sometimes the AI is building a unit that is different from the buildingTemplate table. So we validate the unitID here.
        -- Looks like it never occurred, or i missed the warntext. For now, we don't need it
        for Key, Data in buildingTemplate do
            if Data[1] and Data[2] and Data[1] == buildingType then
                if whatToBuild ~= Data[2] then
                    AIWarn('* AI-Uveso: AIExecuteBuildStructure: Missmatch whatToBuild: '..whatToBuild..' ~= buildingTemplate.Data[2]: '..repr(Data[2]), true, UvesoOffsetaibuildstructuresLUA)
                    whatToBuild = Data[2]
                end
                break
            end
        end
    end
    -- find a place to build it (ignore enemy locations if it's a resource)
    -- build near the base the engineer is part of, rather than the engineer location
    local relativeTo
    if reference and type(reference) == "table" then
        relativeTo = reference
    elseif closeToBuilder then
        relativeTo = builder:GetPosition()
        --AILog('* AI-Uveso: AIExecuteBuildStructure: Searching for Buildplace near Engineer'..repr(relativeTo))
    else
        if builder.BuilderManagerData and builder.BuilderManagerData.EngineerManager then
            relativeTo = builder.BuilderManagerData.EngineerManager.Location
            --AILog('* AI-Uveso: AIExecuteBuildStructure: Searching for Buildplace near BuilderManager ')
        else
            local startPosX, startPosZ = aiBrain:GetArmyStartPos()
            relativeTo = {startPosX, 0, startPosZ}
            --AILog('* AI-Uveso: AIExecuteBuildStructure: Searching for Buildplace near ArmyStartPos ')
        end
    end
    local location = false
    local buildingTypeReplace
    local whatToBuildReplace

    if IsResource(buildingType) then
        --AIDebug("* AI-Uveso: AIExecuteBuildStructure: searching relativeTo: ("..relativeTo[1]..", "..relativeTo[3]..")")
        if not LastGetMassMarker[aiBrain.Army] or LastGetMassMarker[aiBrain.Army] + 10 < GetGameTimeSeconds() then
            LastGetMassMarker[aiBrain.Army] = GetGameTimeSeconds()
            --AILog("* AI-Uveso: AIExecuteBuildStructure: creating table with mass positions")
            MexPositions[aiBrain.Army] = {}
            for _, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
                if v.type == 'Mass' then
                    if v.position[1] <= playableArea[1] + 8 or v.position[1] >= playableArea[3] - 8 or v.position[3] <= playableArea[2] + 8 or v.position[3] >= playableArea[4] - 8 then
                        -- mass marker is too close to border, skip it.
                        continue
                    end
                    table.insert(MexPositions[aiBrain.Army], {position = v.position, dist = VDist2( v.position[1], v.position[3], relativeTo[1], relativeTo[3] )})
                end
            end
        else
            --AIDebug("* AI-Uveso: AIExecuteBuildStructure: using cached mass position table")
        end
        --AIDebug("* AI-Uveso: AIExecuteBuildStructure: sort marker by distance to relativeTo")
        table.sort(MexPositions[aiBrain.Army], function(a, b) return a.dist < b.dist end)
        --AIDebug("* AI-Uveso: AIExecuteBuildStructure: find closest free marker")
        for _, v in MexPositions[aiBrain.Army] do
            if v.usedAt then
                --AILog("* AI-Uveso: AIExecuteBuildStructure: position used "..GetGameTimeSeconds() - v.usedAt.." seconds ago")
                continue
            end
            if v.buildBlocked then
                --AILog("* AI-Uveso: AIExecuteBuildStructure: position blocked since "..GetGameTimeSeconds() - v.buildBlocked.." seconds")
                continue
            end
            if aiBrain:CanBuildStructureAt('ueb1103', v.position) then
                --AIDebug("* AI-Uveso: AIExecuteBuildStructure: CanBuildStructureAt ("..v.position[1]..", "..v.position[3]..")")
                threat = aiBrain:GetThreatAtPosition(v.position, 0, true, 'Overall')
                if threat > 5 then
                    --AIWarn("* AI-Uveso: AIExecuteBuildStructure: threat > 5")
                    continue
                end
                --AILog("* AI-Uveso: AIExecuteBuildStructure: found possible marker at ("..v.position[1]..", "..v.position[3]..")")
                --DrawLinePop(relativeTo, v.position, 'ff30D030')
                v.usedAt = GetGameTimeSeconds()
                relativeTo = v.position
                break
            else
                --AIDebug("* AI-Uveso: AIExecuteBuildStructure: Cant! BuildStructureAt ("..v.position[1]..", "..v.position[3]..")")
                v.buildBlocked = GetGameTimeSeconds()
                continue
            end
        end
        location = aiBrain:FindPlaceToBuild(buildingType, whatToBuild, baseTemplate, relative, closeToBuilder, 'Enemy', relativeTo[1], relativeTo[3], 5)
    else
        -- if we want to build a factory use the UEF Quantum Gate or Tempest on water for a bigger build place
        if buildingType == 'T1LandFactory' or buildingType == 'T1AirFactory' then
            buildingTypeReplace = 'T3QuantumGate'
            whatToBuildReplace = 'ueb0304' -- QGW R32 (UEF Quantim Gate)
        elseif buildingType == 'T1SeaFactory' then
            buildingTypeReplace = 'T4SeaExperimental1'
            whatToBuildReplace = 'uas0401' -- Tempest (Aeon Experimental Battleship) 
        end
        location = aiBrain:FindPlaceToBuild(buildingTypeReplace or buildingType, whatToBuildReplace or whatToBuild, baseTemplate, relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
        -- no place to build?, look around with offsets
        if not location then
            --AILog('* AI-Uveso: AIExecuteBuildStructure: Could not find a place to build with buildingType: '..repr(buildingTypeReplace or buildingType)..' - Searching with offset...')
            for num,offsetCheck in RandomIter({1,2,3,4,5,6,7,8}) do
                location = aiBrain:FindPlaceToBuild(buildingTypeReplace or buildingType, whatToBuildReplace or whatToBuild, BaseTmplFile['MovedTemplates'..offsetCheck][factionIndex], relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
                if location then
                    --AILog('* AI-Uveso: AIExecuteBuildStructure: Yes! Found a place with offset to build - buildingType '..repr(buildingTypeReplace or buildingType))
                    break
                end
            end
        end
        -- fallback in case we can't find a place to build with experimental template
        if not location and buildingTypeReplace then
            --AILog('* AI-Uveso: AIExecuteBuildStructure: Could not find a place to build with replaced (bigger) templates - buildingTypeReplace '..repr(buildingTypeReplace)..' - Searching with normal template '..repr(buildingType))
            location = aiBrain:FindPlaceToBuild(buildingType, whatToBuild, baseTemplate, relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
        end
        -- fallback in case we can't find a place to build with experimental template, try with offsets
        if not location and buildingTypeReplace then
            --AILog('* AI-Uveso: AIExecuteBuildStructure: Could not find a place to build with templates - buildingType '..repr(buildingType)..' - Searching with offset...')
            for num,offsetCheck in RandomIter({1,2,3,4,5,6,7,8}) do
                location = aiBrain:FindPlaceToBuild(buildingType, whatToBuild, BaseTmplFile['MovedTemplates'..offsetCheck][factionIndex], relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
                if location then
                --AILog('* AI-Uveso: AIExecuteBuildStructure: Yes! Found a place with offset to build - buildingType '..repr(buildingType))
                break
                end
            end
        end
        -- if we have no place to build, then maybe we have a modded/new buildingType. Lets try 'T1LandFactory' as dummy and search for a place to build near base with offsets
        if not location and builder.BuilderManagerData and builder.BuilderManagerData.EngineerManager then
            --AILog('* AI-Uveso: AIExecuteBuildStructure: Found no place to Build! - buildingType '..repr(buildingType)..' - ('..string.upper(builder.Blueprint.General.FactionName)..') Trying again with T1LandFactory and RandomIter. Searching near base...')
            relativeTo = builder.BuilderManagerData.EngineerManager.Location
            for num,offsetCheck in RandomIter({1,2,3,4,5,6,7,8}) do
                location = aiBrain:FindPlaceToBuild('T1LandFactory', 'ueb0101', BaseTmplFile['MovedTemplates'..offsetCheck][factionIndex], relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
                if location then
                    --AILog('* AI-Uveso: AIExecuteBuildStructure: Yes! Found a place near base to Build! - buildingType '..repr(buildingType))
                    break
                end
            end
        end
        -- if we still have no place to build, then maybe we have really no place near the base to build. Lets search near engineer position
        if not location then
            --AILog('* AI-Uveso: AIExecuteBuildStructure: Found still no place to Build! - buildingType '..repr(buildingType)..' - ('..string.upper(builder.Blueprint.General.FactionName)..') Trying again with T1LandFactory and RandomIter. Searching near Engineer...')
            relativeTo = builder:GetPosition()
            for num,offsetCheck in RandomIter({1,2,3,4,5,6,7,8}) do
                location = aiBrain:FindPlaceToBuild('T1LandFactory', 'ueb0101', BaseTmplFile['MovedTemplates'..offsetCheck][factionIndex], relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
                if location then
                    --AILog('* AI-Uveso: AIExecuteBuildStructure: Yes! Found a place near engineer to Build! - buildingType '..repr(buildingType))
                    break
                end
            end
        end
    end

    -- now, if we have a location, build!
    if location then
        -- convert (x,z) to (x,y,z)
        local relativeLoc = BuildToNormalLocation(location)
        -- if we have searched with relative coordinates, then we need to add the relative build position to the engineers position
        if relative then
            relativeLoc = {relativeLoc[1] + relativeTo[1], relativeLoc[2] + relativeTo[2], relativeLoc[3] + relativeTo[3]}
        end
        --AILog('* AI-Uveso: AIExecuteBuildStructure: Found a place to build! AI-faction: index('..factionIndex..') '..repr(AIFactionName)..', Building Type: '..repr(buildingType)..', engineer-faction: '..repr(string.upper(builder.Blueprint.General.FactionName)))
        -- put in build queue.. but will be removed afterwards... just so that it can iteratively find new spots to build
        AddToBuildQueue(aiBrain, builder, whatToBuild, NormalToBuildLocation(relativeLoc), false)
        return true
    end
    -- At this point we're out of options, so move on to the next thing
    AIWarn('* AI-Uveso: AIExecuteBuildStructure: c-function FindPlaceToBuild() failed! AI-faction: index('..factionIndex..') '..repr(AIFactionName)..', Building Type: '..repr(buildingType)..', engineer-faction: '..repr(string.upper(builder.Blueprint.General.FactionName)).." - Builder: ["..repr(builder.PlatoonHandle.BuilderName).."]", true, UvesoOffsetaibuildstructuresLUA)
    return false
end
