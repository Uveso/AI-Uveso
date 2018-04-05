HistoryScoreInterval = 10 -- make an option with this

function ScoreHistoryThread()
    while true do
        WaitSeconds(HistoryScoreInterval)
        table.insert(scoreData.historical, table.deepcopy(scoreData.current))
    end
end
