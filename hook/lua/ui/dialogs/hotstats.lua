local HistoryScoreInterval = 60 -- make an option with this

function create_graph(parent,path,x1,y1,x2,y2)
    local data_nbr=table.getsize(scoreData.historical) -- data_nbr is the number of group of data saved
    --LOG("Number of data found:",data_nbr)
    if data_nbr<=0 then nodata() return nil end
    local player={} -- would be the name/color of the player in the left-top corner
    -- HistoryScoreInterval is the time between to data saved
    -- parent group
    local grp=Group(parent)
    grp.Left:Set(0) grp.Top:Set(0) grp.Right:Set(0) grp.Bottom:Set(0)
    page_active_graph=grp
    -- gray background that receive all
    bg=Bitmap(grp)
    bg.Left:Set(function() return parent.Left() + x1 end)
    bg.Top:Set(function() return parent.Top()+y1 -2 end)
    bg.Right:Set(function() return parent.Left()+x2 +2 end)
    bg.Bottom:Set(function() return parent.Top()+y2 +1  end)
    bg:SetSolidColor("gray")
    bg:SetAlpha(0.95)
    bg2=Bitmap(grp)
    LayoutHelpers.FillParent(bg2,bg)
    -- build parent-name in the left-top of the screen
    local armiesInfo = GetArmiesTable()
    local i=1
    local m=0
    for k, v in armiesInfo.armiesTable do
        m=m+1
        if not v.civilian and v.nickname != nil then
            player[i]={}
            player[i].name=v.nickname
            player[i].color=v.color
            player[i].index=m
            player[i].title_label=UIUtil.CreateText(grp,v.nickname, 14, UIUtil.titleFont)
            player[i].title_label.Left:Set(x1+5)
            player[i].title_label.Top:Set(y1 +23*(i-1)+5)
            player[i].title_label:SetColor("black")
            player[i].title_label2=UIUtil.CreateText(grp,v.nickname, 14, UIUtil.titleFont)
            player[i].title_label2.Left:Set(x1+4)
            player[i].title_label2.Top:Set(y1 +23*(i-1)+4)
            player[i].title_label2:SetColor(v.color)
            local acuKills = return_value(0,player[i].index,{"units","cdr","kills"})
            if acuKills > 0 then
                player[i].killIcon = {}
                for kill = 1, acuKills do
                    local index = kill
                    player[i].killIcon[index] = Bitmap(grp, UIUtil.UIFile('/hotstats/score/commander-kills-icon.dds'))
                    if index == 1 then
                        LayoutHelpers.RightOf(player[i].killIcon[index], player[i].title_label)
                    else
                        LayoutHelpers.RightOf(player[i].killIcon[index], player[i].killIcon[index-1])
                    end
                    modcontrols_tooltips(player[i].killIcon[index],LOC("<LOC SCORE_0063>Number of ACU kills."))
                    player[i].killIcon[index].Depth:Set(bg.Depth()+500)
                end
            end
            i=i+1
        end
    end
    local player_nbr=i-1
    -- searching the highest value
    local maxvalue=0
    local periode=-1
    while periode<data_nbr do
        periode=periode+1
        for index, dat in player do
            local val=return_value(periode,dat.index,path)  -- return the value
            if maxvalue<val then    maxvalue=val end
        end
    end
    --LOG(maxvalue)
    --arranging the highest value to be nice to see
    maxvalue=arrange(maxvalue*1.02)
    -- calculate the scale factor on y
    local factor=(y2-y1)/maxvalue
    --LOG("Value the highest:",maxvalue,"   final time saved:",HistoryScoreInterval*data_nbr,"   scale factor on y:",factor)
    -- drawing the axies/quadrillage
    local j=1
    local quadrillage_horiz={}
    local nbr_quadrillage_horiz=6 -- how many horizontal axies
    local nbr_quadrillage_vertical=8 -- how many vertical axies
    while j<nbr_quadrillage_horiz do
        local tmp=j
        quadrillage_horiz[j]=Bitmap(grp)
        quadrillage_horiz[j].Left:Set(function() return parent.Left() + x1 +1 end)
        quadrillage_horiz[j].Top:Set(function() return parent.Top() +y2 - (y2-y1)*((tmp-1)/(nbr_quadrillage_horiz-2)) -1 end)
        quadrillage_horiz[j].Right:Set(function() return parent.Left()+x2 +2 end)
        quadrillage_horiz[j].Bottom:Set(function() return quadrillage_horiz[tmp].Top() +1  end)
        quadrillage_horiz[j]:SetSolidColor("white")
        quadrillage_horiz[j].Depth:Set(grp.Depth)

        quadrillage_horiz[j].title_label=UIUtil.CreateText(grp,math.floor((j-1)/(nbr_quadrillage_horiz-2)*maxvalue), 14, UIUtil.titleFont)
        quadrillage_horiz[j].title_label.Right:Set(parent.Left() + x1 -8)
        quadrillage_horiz[j].title_label.Bottom:Set(parent.Top() +y2 - (y2-y1)*((tmp-1)/(nbr_quadrillage_horiz-2))+1)
        quadrillage_horiz[j].title_label:SetColor("white")
        j=j+1
    end
    local j=1
    local quadrillage_vertical={}
    while j<nbr_quadrillage_vertical do
        local tmp=j
        quadrillage_vertical[j]=Bitmap(grp)
        quadrillage_vertical[j].Left:Set(function() return parent.Left()+x1 + ((x2-x1))*((tmp-1)/(nbr_quadrillage_vertical-2))+1  end)
        quadrillage_vertical[j].Top:Set(function() return parent.Left()+y1 -1  end)
        quadrillage_vertical[j].Right:Set(function() return quadrillage_vertical[tmp].Left() +1 end)
        quadrillage_vertical[j].Bottom:Set(function() return parent.Top()+y2  end)
        quadrillage_vertical[j]:SetSolidColor("white")
        quadrillage_vertical[j].Depth:Set(grp.Depth)

        quadrillage_vertical[j].title_label=UIUtil.CreateText(grp,tps_format((j-1)/(nbr_quadrillage_vertical-2)*data_nbr*HistoryScoreInterval), 14, UIUtil.titleFont)
        quadrillage_vertical[j].title_label.Left:Set(parent.Left()+x1 + ((x2-x1))*((tmp-1)/(nbr_quadrillage_vertical-2))+1)
        quadrillage_vertical[j].title_label.Top:Set(parent.Top()+y2 +10)
        quadrillage_vertical[j].title_label:SetColor("white")
        j=j+1
    end
    --after having draw the background exist if no data
    local size=1 -- Size of the pixel which compose the line, make the line wider
    -- ============================= the main function creating the graph
    --
    -- everything that needed the graphs are done are at the end of this thread
    if create_anime_graph then KillThread(create_anime_graph) end
    if true then
        create_anime_graph = ForkThread(function()
        local periode=0  -- the number of the saved used
        local x=parent.Left()+ x1  -- the current position on x
        local dist=(x2-x1)/(data_nbr) -- the distance on the screen between two saved
        --LOG("dist:",dist)
        local delta_refresh=(x2-x1)/(6*size) -- the distance in time between the smallest halt possible to make a refresh
        local delta=0 -- counter for refresh and small halt
        local line={} -- containe for the actual periode of time all the data to be draw
        --if graph != nil and graph then graph:Destroy() graph=false end
        graph={} -- will containt a table for each line and each line will be a table of bitmap
        for index, dat in player do     graph[dat.index]={}     end -- init the different line
        local current_player_index=0  -- if 0 we are in replay, otherwise will show the graph to emphasize
        if not gamemain.GetReplayState() then current_player_index=GetFocusArmy() end
        WaitSeconds(0.001) -- give time to refresh and displayed the background
        inc_periode=((data_nbr)/(x2-x1)) -- give the increment on the screen between each periode (i.e. between each saved)
        if inc_periode<1 then inc_periode=1 end -- can not be <1 => use the whole screen
        local nbr=0 -- couting the number of iterancy done
        -- ============ starting
        t=CurrentTime()
        WaitFrames(10)
        t1=CurrentTime()
        --LOG("------- calculating the timing of the frame")
        --LOG("Time to display 1 frame (calculate with 10 frames):",(t1-t)/10,'  t:',t,'   t1:',t1)
        delta_refresh=(x2-x1)*(t1-t)/10*((player_nbr+1)/4)
        --LOG("So refresh all the ",delta_refresh," pixels displayed (delta_refresh:)")
        while periode<data_nbr do
            nbr=nbr+1
            periode=math.floor(nbr*inc_periode) -- calculate the next periode to use (i.e. skip some of them it more value than the screen can display)
            -- prepare the data, calculate the ya=start y position and the yb=end position of the ligne for each player for this periode
            for index, dat in player do
                if periode==1 then val=0 else val=return_value(periode-1,dat.index,path) end
                ya=parent.Top() +y2 - val*factor
                local val=return_value(periode,dat.index,path)
                yb=parent.Top() +y2  - val*factor

                -- put all the data in this table
                line[dat.index]={grp=grp,ya=ya,yb=yb,y=ya,  -- note: y is the current position for this graph; the x is commun to all graph
                    color=dat.color,index=dat.index,
                    y_factor=(yb-ya)/dist*size} -- important: the factor of deplacement for the bitmap
            end
            local sav_x=x
            while (x<(parent.Left()+ x1 + nbr*dist) and x<(x2+parent.Left()))  do
                for name,data in line do
                    graph[data.index][x-x1]=Bitmap(grp)
                    graph[data.index][x-x1].Left:Set(parent.Left() +x)
                    if data.y_factor != 0 then
                    local yn=parent.Top() +data.y+data.y_factor/math.abs(data.y_factor)*size*((math.abs(data.y_factor)+1))
                        if data.y_factor<0 and (yn+size)<data.yb then yn=data.yb-size end
                        if data.y_factor>0 and (yn-size)>data.yb then yn=data.yb-size end
                        graph[data.index][x-x1].Top:Set(yn)
                    else
                        graph[data.index][x-x1].Top:Set(parent.Top() +data.y-size)
                    end
                    graph[data.index][x-x1].Right:Set(graph[data.index][x-x1].Left() +size)
                    graph[data.index][x-x1].Bottom:Set(parent.Top() +data.y)
                    graph[data.index][x-x1]:SetSolidColor(data.color)
                    graph[data.index][x-x1]:Depth(bg.Depth()+5)
                    data.y=data.y+data.y_factor
                end
                x=x+size
                delta=delta+1
                if delta>delta_refresh then
                    WaitFrames(1) -- do the reshresh, should be far smaller to be smooth...
                    delta=0
                end
            end
        end
        for index, data in player do
            graph[data.index][x2]=Bitmap(grp)
            graph[data.index][x2].Left:Set(x2)
            if data.y_factor != 0 then
                val=return_value(math.floor((nbr-1)*inc_periode),data.index,path)
                --LOG("1st:",val)
                ya=parent.Top() +y2 - val*factor
                ya=graph[data.index][x-x1-size].Top()
                local val=return_value(0,data.index,path)
                --LOG("2nd:",val)
                yb=parent.Top() +y2  - val*factor
                if yb<y1 then yb=y1+2 end
                if yb>y2 then yb=y2-2 end
                --local yn=parent.Top() +data.y+data.y_factor/math.abs(data.y_factor)*size*((math.abs(data.y_factor)+1))
                --if data.y_factor<0 and (yn+size)<data.yb then yn=data.yb-size end
                --if data.y_factor>0 and (yn-size)>data.yb then yn=data.yb-size end
                --  graph[data.index][x2].Top:Set(yn)
                --else
                    graph[data.index][x2].Top:Set(parent.Top() +yb)
                --end
                --LOG("x: ",x2,"  ya:",ya,"  yb:",yb)
                graph[data.index][x2].Right:Set(graph[data.index][x2].Left() +size)
                graph[data.index][x2].Bottom:Set(parent.Top() +ya)
                graph[data.index][x2]:SetSolidColor(data.color)
            end
        end
        -- ========= end of the drawing of the graph
        t=CurrentTime()
        --LOG("total time:",t-t1)
        -- display the max value
        local value_graph_label={}
        for index, dat in player do
            value_graph_label[dat.index]={}
            val=math.floor(return_value(periode,dat.index,path))
            value_graph_label[dat.index].title_label=UIUtil.CreateText(grp,val, 14, UIUtil.titleFont)
            value_graph_label[dat.index].title_label.Right:Set(x-1)
            value_graph_label[dat.index].title_label.Bottom:Set(line[dat.index].y-1)
            value_graph_label[dat.index].title_label:SetColor(dat.color)
            value_graph_label[dat.index].title_label:SetDropShadow(true)
        end
        -- pulse the player graph if not in replay  TODO: fix the bug that we are nil when recreating the graph
        if current_player_index != 0 and current_player_index != nil and graph[current_player_index][1] != nil then
            for i,bmp in graph[current_player_index] do
                EffectHelpers.Pulse(bmp,1,.65,1)
            end
        end
        -- for the windows under the mouse on the background
        local infoText = false
        --displays the value when the mouse is over a graph
        bg.HandleEvent = function(self, event)
            local posX = function() return event.MouseX end -- - bg.Left() end
            local posY = function() return event.MouseY  end-- - bg.Top() end
            if infoText != false then
                infoText:Destroy()
                infoText = false
            end
            if posX()>x1 and posX()<x2 and posY()>y1 and posY()<y2 then
                local  value = tps_format((posX()-x1)/(x2-x1)*HistoryScoreInterval*data_nbr) .. " / " .. math.floor(((y2-posY())/factor))
                infoText = UIUtil.CreateText(grp,value, 14, UIUtil.titleFont)
                infoText.Left:Set(function() return posX()-(infoText.Width()/2) end)
                infoText.Bottom:Set(function() return posY()-7 end)
                infoText:SetColor("white")
                infoText:DisableHitTest()
                local infoPopupbg = Bitmap(infoText) -- the borders of the windows
                infoPopupbg:SetSolidColor('white')
                infoPopupbg:SetAlpha(.6)
                infoPopupbg.Depth:Set(function() return infoText.Depth()-2 end)
                local infoPopup = Bitmap(infoText)
                infoPopup:SetSolidColor('black')
                infoPopup:SetAlpha(.6)
                infoPopupbg.Depth:Set(function() return infoText.Depth()-1 end)
                infoPopup.Width:Set(function() return infoText.Width() +8 end)
                infoPopup.Height:Set(function() return infoText.Height()+8 end)
                infoPopup.Left:Set(function() return infoText.Left()-4 end)
                infoPopup.Bottom:Set(function() return infoText.Bottom()+4 end)
                infoPopupbg.Width:Set(function() return infoPopup.Width()+2 end)
                infoPopupbg.Height:Set(function() return infoPopup.Height()+2 end)
                infoPopupbg.Left:Set(function() return infoPopup.Left()-1 end)
                infoPopupbg.Bottom:Set(function() return infoPopup.Bottom() +1 end)
            end
        end
    end)
end
    if create_anime_graph2 then KillThread(create_anime_graph2) end
        create_anime_graph2 = ForkThread(function()
        local periode=0  -- the number of the saved used
        local x=parent.Left()+ x1  -- the current position on x
        local dist=(x2-x1)/(data_nbr) -- the distance on the screen between two saved
        --LOG("dist:",dist)
        local delta_refresh=(x2-x1)/(6*size) -- the distance in time between the smallest halt possible to make a refresh
        local delta=0 -- counter for refresh and small halt
        local line={} -- containe for the actual periode of time all the data to be draw
        --if graph != nil and graph then graph:Destroy() graph=false end
        graph2={} -- will containt a table for each line and each line will be a table of bitmap
        for index, dat in player do     graph2[dat.index]={}    end -- init the different line
        local current_player_index=0  -- if 0 we are in replay, otherwise will show the graph to emphasize
        if not gamemain.GetReplayState() then current_player_index=GetFocusArmy() end
        WaitSeconds(0.001) -- give time to refresh and displayed the background
        inc_periode=((data_nbr)/(x2-x1)) -- give the increment on the screen between each periode (i.e. between each saved)
        if inc_periode<1 then inc_periode=1 end -- can not be <1 => use the whole screen
        local nbr=1 -- couting the number of iterancy done
        -- ============ starting
        t=CurrentTime()
        WaitFrames(10)
        t1=CurrentTime()
        --LOG("------- calculating the timing of the frame")
        --LOG("Time to display 1 frame (calculate with 10 frames):",(t1-t)/10,'  t:',t,'   t1:',t1)
        delta_refresh=(x2-x1)*(t1-t)/10*((player_nbr+1)/4)
        --LOG("So refresh all the ",delta_refresh," pixels displayed (delta_refresh:)")
        while periode<data_nbr do
            nbr=nbr+1
            periode=math.floor(nbr*inc_periode) -- calculate the next periode to use (i.e. skip some of them it more value than the screen can display)
            local tot=0
            -- prepare the data, calculate the ya=start y position and the yb=end position of the ligne for each player for this periode
            for index, dat in player do
                if periode==1 then val=0 else val=return_value(periode-1,dat.index,path) end
                if val==nil or val<0.01 or val==false then val=0 end
                ya=val
                local val=return_value(periode,dat.index,path) --{"general","currentunits","count"}
                if val==nil or val<0.01 or val==false then val=0 end
                yb=val
                -- put all the data in this table
                line[dat.index]={grp=grp,ya=ya,yb=yb,y=ya,  -- note: y is the current position for this graph; the x is commun to all graph
                    color=dat.color,index=dat.index,value=val,
                    y_factor=(yb-ya)/dist*size} -- important: the factor of deplacement for the bitmap
            end
            local totaux=0
            local sav_x=x
            while (x<(parent.Left()+ x1 + nbr*dist) and x<(x2+parent.Left()))  do
                totaux=0
                for name,data in line do
                    totaux=totaux+ data.ya+(data.yb - data.ya)*((x-sav_x)/dist)
                    --data.ya*(1-data.yb*(x/sav_x)/data.ya)
                end
                local factor=0
                if totaux != 0 then  factor=(y2-y1)/totaux end
                local ya_draw=y2
                local yb_draw=0
                for name,data in line do
                    yb_draw=ya_draw
                    ya_draw=ya_draw-(data.ya+(data.yb - data.ya)*((x-sav_x)/dist))*factor
                    --if ya_draw>y2 or ya_draw<0 then ya_draw=y2 end
                    --if yb_draw>y2 or ya_draw<0 then yb_draw=y2 end
                    --LOG(ya_draw, '     ',yb_draw)
                    --data.ya*(1-data.yb*(x/sav_x)/data.ya)*factor
                    --data.ya*factor*(x/sva_x)
                    graph2[data.index][x-x1]=Bitmap(grp)
                    graph2[data.index][x-x1].Left:Set(parent.Left() +x)
                    --local yn=parent.Top() +data.y+data.y_factor/math.abs(data.y_factor)*size*((math.abs(data.y_factor)+1))
                    graph2[data.index][x-x1].Top:Set(parent.Top()+ya_draw)
                    graph2[data.index][x-x1].Right:Set(graph2[data.index][x-x1].Left() +size)
                    graph2[data.index][x-x1].Bottom:Set(parent.Top() +yb_draw) --+data.y)
                    graph2[data.index][x-x1]:SetSolidColor(data.color)
                    graph2[data.index][x-x1]:Depth(bg.Depth()+1)
                    -- graph2[data.index][x-x1]:SetAlpha(.15)
                    graph2[data.index][x-x1]:SetAlpha(.15)
                end
                x=x+size
                delta=delta+1
                if delta>delta_refresh then
                    WaitFrames(1) -- do the reshresh, should be far smaller to be smooth...
                    delta=0
                end
            end
        end
        -- ========= end of the drawing of the graph
        t=CurrentTime()
        --LOG("total time:",t-t1)
        local j=1
    local quadrillage_horiz2={}
    local nbr_quadrillage_horiz2=4 -- how many horizontal axies
    while j<nbr_quadrillage_horiz2 do
        local tmp=j
        quadrillage_horiz2[j]={}
        quadrillage_horiz2[j].title_label=UIUtil.CreateText(grp,(math.floor((j-1)/(nbr_quadrillage_horiz2-2)*100)).." %", 14, UIUtil.titleFont)
        quadrillage_horiz2[j].title_label.Left:Set(parent.Left() + x2 +10)
        quadrillage_horiz2[j].title_label.Bottom:Set(parent.Top() +y2 - (y2-y1-15)*((tmp-1)/(nbr_quadrillage_horiz2-2))+1)
        quadrillage_horiz2[j].title_label:SetColor("gray")
        j=j+1
    end
    end)
    return grp
end
