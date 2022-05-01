globalValues = {
    ['goto'] = 5,
    ['createnpc'] = 7,
    ['ignore'] = 0,
    ['notification'] = 1,
    ['loadnpc'] = 1,
    ['playanim'] = 3,
    ['scenario'] = 3,
    ['delay'] = 1,
    ['text'] = 2,
    ['marker'] = 'custom',
    ['event'] = 'custom',
    ['export'] = 2
}

values = {
    ['goto'] = 'gt:',
    ['createnpc'] = 'cnpc:',
    ['ignore'] = 'cnt:',
    ['notification'] = 'inf:',
    ['loadnpc'] = 'lnpc:',
    ['playanim'] = 'anim:',
    ['scenario'] = 'scen:',
    ['delay'] = 'del:',
    ['text'] = 'text:',
    ['marker'] = 'mark:',
    ['event'] = 'ev:',
    ['export'] = 'exe:'
}

funcs = {'inf:', 'gt:', 'cnt:', 'cnpc:', 'lnpc:', 'anim:', 'scen:', 'del:', 'text:', 'mark:', 'ev:', 'exe:'}

functions = {
    ['inf'] = 'information',
    ['cnt'] = 'WaitTillEnd',
    ['gt'] = 'GoTo',
    ['cnpc'] = 'CreateNPC',
    ['lnpc'] = 'LoadNPC',
    ['anim'] = 'PlayAnim',
    ['scen'] = 'Scenario',
    ['del'] = 'Delay',
    ['text'] = 'MissionText',
    ['mark'] = 'Marker',
    ['ev'] = 'Event',
    ['exe'] = 'ExportEnt',
}

GreaterReadability = {
    ['ExportEnt'] = function(cb, check, str)
        if not check then
            local name, data = nil, nil
            for i=1, string.len(str), 1 do
                if string.sub(str, i, i) == ',' then
                    name = string.sub(str, 1, i-1)
                    data = string.sub(str, i+1, string.len(str))
                end
            end
            cb('export', name, data)
        else
            cb('export', true)
        end
    end,
    ['Event'] = function(cb, check, name, ...)
        if not check then
            cb('GEvent', name, ...)
        else
            cb('GEvent', true)
        end
    end,
    ['information'] = function(cb, check, str)
        if not check then 
            TriggerEvent('chat:addMessage', {
                color = { 255, 0, 0},
                multiline = true,
                args = {"Quest", str}
            })
            cb('event', true)
        else
            cb('event', true)
        end
    end,
    ['GoTo'] = function(cb, check, str)
        if not check then
            local returnval = {}
            local vars = {}

            for j=1, string.len(str), 1 do
                if string.sub(str, j, j) == ',' then
                    table.insert(vars, j)
                end
            end

            table.insert(vars, string.len(str)-1)

            for j=1, #vars, 1 do
                if j == 1 then
                    table.insert(returnval, tonumber(string.sub(str, 1, vars[j]-1)))
                end
                if j > 1 and j <= 3 then
                    table.insert(returnval, tonumber(string.sub(str, vars[j-1]+1, vars[j]-1)))
                end
                if j == 4 or j == 5 then
                    if string.sub(str, vars[j]+1, vars[j]+1) == 't' then
                        table.insert(returnval, true)
                    else
                        table.insert(returnval, false)
                    end
                end
            end
            cb('goto', returnval)
        else
            cb('goto', true)
        end
    end,
    ['CreateNPC'] = function(cb, check, str)
        if not check then
            local returnval = {}
            local vars = {}

            for j=1, string.len(str), 1 do
                if string.sub(str, j, j) == ',' then
                    table.insert(vars, j)
                end
            end

            table.insert(vars, string.len(str)-1)

            for j=1, #vars, 1 do
                if j == 1 then
                    table.insert(returnval, tostring(string.sub(str, 1, vars[j]-1)))
                end
                if j > 1 and j <= 5 then
                    table.insert(returnval, tonumber(string.sub(str, vars[j-1]+1, vars[j]-1)))
                end
                if j == 6 then
                    if string.sub(str, vars[j]+1, vars[j+1]-1) == 't' then
                        table.insert(returnval, true)
                    else
                        table.insert(returnval, false)
                    end
                end
                if j == 7 then
                    table.insert(returnval, string.sub(str, vars[j-1]+1, string.len(str)))
                end
            end

            cb('createnpc', returnval)
        else
            cb('createnpc', true)
        end
    end,
    ['LoadNPC'] = function(cb, check, str)
        if not check then
            if str ~= nil and str ~= '' then
                if tonumber(str) then
                    cb('loadnpc', tonumber(str))
                else
                    cb('loadnpc', str)
                end
            else
                cb('loadnpc')
            end
        else
            cb('loadnpc', true)
        end
    end,
    ['PlayAnim'] = function(cb, check, str)
        if not check then
            local returnval = {}
            local vars = {}

            for j=1, string.len(str), 1 do
                if string.sub(str, j, j) == ',' then
                    table.insert(vars, j)
                end
            end

            table.insert(vars, string.len(str)-1)

            for j=1, #vars, 1 do
                if j == 1 then
                    table.insert(returnval, string.sub(str, 1, vars[j]-1))
                end
                if j == 2 then
                    table.insert(returnval, string.sub(str, vars[j-1]+1, string.len(str)))
                end
                if j == 3 then
                    table.insert(returnval, string.sub(str, vars[j]+1, string.len(str)))
                end
            end    
            
            cb('playanim', returnval)
        else
            cb('playanim', true)
        end
    end,
    ['Scenario'] = function(cb, check, str)
        if not check then
            local returnval = {}
            local vars = {}

            for j=1, string.len(str), 1 do
                if string.sub(str, j, j) == ',' then
                    table.insert(vars, j)
                end
            end

            table.insert(vars, string.len(str)-1)

            for j=1, #vars, 1 do
                if j == 1 then
                    table.insert(returnval, string.sub(str, 1, vars[j]-1))
                end
                if j == 2 and #vars == 2 then
                    if string.sub(str, vars[j]+1, string.len(str)) == 't' then
                        table.insert(returnval, true)
                    else
                        table.insert(returnval, false)
                    end
                elseif (j ~= 2 or #vars ~= 2) and vars[j+1] then
                    if string.sub(str, vars[j]+1, vars[j+1]-1) == 't' then
                        table.insert(returnval, true)
                    else
                        table.insert(returnval, false)
                    end
                end
                if j == 3 then
                    if tonumber(string.sub(str, vars[j]+1, string.len(str))) then
                        table.insert(returnval, tonumber(string.sub(str, vars[j]+1, string.len(str))))
                    else
                        table.insert(returnval, string.sub(str, vars[j]+1, string.len(str)))
                    end
                end
            end    
            
            cb('scenario', returnval)
        else
            cb('scenario', true)
        end
    end,
    ['MissionText'] = function(cb, check, str)
        if not check then
            local returnval = {}
            local vars = {}

            for j=1, string.len(str), 1 do
                if string.sub(str, j, j) == ',' then
                    table.insert(vars, j)
                end
            end

            table.insert(vars, string.len(str)-1)

            for j=1, #vars, 1 do
                if j == 1 then
                    table.insert(returnval, string.sub(str, 1, vars[j]-1))
                end
                if j == 2 then
                    table.insert(returnval, tonumber(string.sub(str, vars[j-1]+1, string.len(str))))
                end
            end

            cb('missiontext', returnval)
        else
            cb('misiontext', true)
        end
    end,
    ['Marker'] = function(cb, check, str)
        if not check then
            local returnval = {}
            local vars = {}

            for j=1, string.len(str), 1 do
                if string.sub(str, j, j) == ',' then
                    table.insert(vars, j)
                end
            end

            table.insert(vars, string.len(str)-1)

            for j=1, #vars, 1 do
                if j == 1 then
                    table.insert(returnval, tonumber(string.sub(str, 1, vars[j]-1)))
                end
                if j > 1 and j <= #vars-1 then
                    local p = string.sub(str, vars[j-1]+1, vars[j]-1)
                    if tonumber(p) then
                        table.insert(returnval, tonumber(p))
                    end
                    if p == 't' then
                        table.insert(returnval, true)
                    end
                    if p == 'f' then
                        table.insert(returnval, false)
                    end
                    if not tonumber(p) and p ~= 't' and p ~= 'f' then
                        table.insert(returnval, p)
                    end
                end
                if j == #vars then
                    local p = string.sub(str, vars[j-1]+1, string.len(str))
                    if tonumber(p) then
                        table.insert(returnval, tonumber(p))
                    end
                    if p == 't' then
                        table.insert(returnval, true)
                    end
                    if p == 'f' then
                        table.insert(returnval, false)
                    end
                end
            end

            cb('marker', returnval)
        else
            cb('marker', true)
        end
    end
}

NUIValues = {
    [1] = {
        ''
    },
    [2] = {
        '', 0
    },
    [3] = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,0, true, true, true, true, true, 0
    },
    [4] = {
        '', 0, 0, 0, 0, true, ''
    },
    [5] = {
        '', '', ''
    },
    [6] = {
        '', '', ''
    },
    [7] = {
        ''
    },
    [8] = {
        0, 0, 0
    },
    [9] = {
        nil
    },
    [10] = {
        0
    },
    [11] = {
        '', {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
    },
    [12] = {
        '', ''
    }
}
