
    -- For AI Patch V5 (patched). patch for missing StrategyManager
function AddBuilderTable(aiBrain, locationType, builderTable, tableName)
    aiBrain.BuilderManagers[locationType].BuilderHandles = aiBrain.BuilderManagers[locationType].BuilderHandles or {}
    aiBrain.BuilderManagers[locationType].BuilderHandles[tableName] = {}

    local builders = aiBrain.BuilderManagers[locationType].BuilderHandles[tableName]

    local managers = aiBrain.BuilderManagers[locationType]

    local tableType, builderFunction

    if builderTable.BuildersType == 'PlatoonFormBuilder' then
        tableType = 'PlatoonFormManager'
    elseif builderTable.BuildersType == 'EngineerBuilder' then
        tableType = 'EngineerManager'
    elseif builderTable.BuildersType == 'FactoryBuilder' then
        tableType = 'FactoryManager'
    elseif builderTable.BuildersType == 'StrategyBuilder' and managers.StrategyManager then
        tableType = 'StrategyManager'
    else
        WARN('*AI ERROR: Invalid BuildersType ('..repr(builderTable.BuildersType)..') for table of builder to add to brain')
        return
    end

    for k,v in builderTable do
        if k != 'BuildersType' and k != 'BuilderGroupName' then
            if type(v) != 'string' then
                error('*AI ERROR: Invalid builder type in BuilderGroup - ' .. tableName)
            end
            if not Builders[v] then
                WARN('*AI ERROR: Invalid Builder named - ' .. v)
            end
            table.insert(builders, managers[tableType]:AddBuilder(Builders[v], locationType))
        end
    end
end
