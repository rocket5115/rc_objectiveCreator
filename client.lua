local Peds = {}
local LastPed = nil
local Markers = {}
local ButtonPressedOnMarker = nil

AddEventHandler('rc_co:convertLua', function(tab, cb)
    if cb then
        local p = CreateOC(tab)
        cb(p)
    end
end)

AddEventHandler('rc_co:startCO', function(str)
    if str then
        ConvertOC(str)
    end
end)

local data = {
    {
        ['name'] = 'createnpc',
        's_m_y_airworker',
        -183.7506,
        -1079.427,
        30.13943,
        124.733,
        true
    },
    {
        ['name'] = 'createnpc',
        's_m_m_dockwork_01',
        -207.1754,
        -1114.2286,
        22.86851,
        70.0974,
        true
    },
    {
        ['name'] = 'scenario',
        'WORLD_HUMAN_SMOKING_POT',
        true
    },
    {
        ['name'] = 'marker',
        22,
        -207.1754,
        -1114.2286,
        22.86851,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        1.0, 1.0, 1.0,
        250, 0, 0, 0,
        false, true, false, false,
        true, 46
    },
    {
        ['name'] = 'ignore'
    },
    {
        ['name'] = 'text',
        'Hey there! You\'re late again! Talk with Bob he has a job for you.',
        4000
    },
    {
        ['name'] = 'delay',
        4500
    },
    {
        ['name'] = 'text',
        'He is on the first floor up there.',
        3000
    },
    {
        ['name'] = 'delay',
        3500
    },
    {
        ['name'] = 'notification',
        'You were given a task to complete!'
    },
    {
        ['name'] = 'marker',
        22,
        -183.7506,
        -1079.427,
        30.13943,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        1.0, 1.0, 1.0,
        250, 0, 0, 0,
        false, true, false, false,
        true, 46
    },
    {
        ['name'] = 'ignore'
    },
    {
        ['name'] = 'text',
        "Finally! You are here. Take these papers and bring them to Mike.",
        4500
    },
    {
        ['name'] = 'delay',
        4500
    },
    {
        ['name'] = 'text',
        'What are you waiting for? He is on the top of the construction site.',
        3500
    },
    {
        ['name'] = 'delay',
        3500
    },
    {
        ['name'] = 'notification',
        'Go to the top! And give Mike some notes!'
    }
}

function CreateOC(tab)
    local returnval = "{"

    for i=1, #tab, 1 do
        if tab[i]['name'] == 'goto' then
            returnval = returnval .. 'gt:' .. tab[i][1] .. ',' .. tab[i][2] .. ',' .. tab[i][3]
            if tab[i][4] == true then
                returnval = returnval .. ',t'
            else
                returnval = returnval .. ',f'
            end
            if tab[i][5] == true then
                returnval = returnval .. ',t'
            else
                returnval = returnval .. ',f'
            end
        end
        if tab[i]['name'] == 'ignore' then
            returnval = returnval .. 'cnt:'
        end
        if tab[i]['name'] == 'notification' then
            returnval = returnval .. 'inf:' .. tab[i][1]
        end
        if tab[i]['name'] == 'createnpc' then
            returnval = returnval .. 'cnpc:' .. tab[i][1] .. ',' .. tab[i][2] .. ',' .. tab[i][3] .. ',' .. tab[i][4] .. ',' .. tab[i][5]
            if tab[i][6] == true then
                returnval = returnval .. ',t'
            else
                returnval = returnval .. ',f'
            end
        end
        if tab[i]['name'] == 'loadnpc' then
            if tab[i][1] then
                returnval = returnval .. 'lnpc:' .. tab[i][1]
            else
                returnval = returnval .. 'lnpc:'
            end
        end
        if tab[i]['name'] == 'playanim' then
            returnval = returnval .. 'anim:' .. tab[i][1] .. ',' .. tab[i][2]
            if tab[i][3] then
                returnval = returnval .. ',' .. tab[i][3]
            end
        end
        if tab[i]['name'] == 'scenario' then
            returnval = returnval .. 'scen:' .. tab[i][1]
            if tab[i][2] == true then
                returnval = returnval .. ',t'
            else
                returnval = returnval .. ',f'
            end
        end
        if tab[i]['name'] == 'delay' then
            returnval = returnval .. 'del:' .. tab[i][1]
        end
        if tab[i]['name'] == 'text' then
            returnval = returnval .. 'text:' .. tab[i][1] .. ',' .. tab[i][2]
        end
        if tab[i]['name'] == 'marker' then
            returnval = returnval .. 'mark:'
            for j=1, #tab[i], 1 do
                if type(tab[i][j]) == 'boolean' then
                    if tab[i][j] == true then
                        returnval = returnval .. ',t'
                    else
                        returnval = returnval .. ',f'
                    end
                else
                    if j ~= 1 then
                        returnval = returnval .. ',' .. tab[i][j]
                    else
                        returnval = returnval .. tab[i][j]
                    end
                end
            end
        end
        if i == #tab then
            returnval = returnval .. '}'
        else
            returnval = returnval .. ';' 
        end
    end

    return returnval
end
local funcs = {'inf:', 'gt:', 'cnt:', 'cnpc:', 'lnpc:', 'anim:', 'scen:', 'del:', 'text:', 'mark:'}

local functions = {
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
}

function ConvertOC(oc)
    if string.sub(oc, 1, 1) ~= '{' then
        return
    end
    if string.sub(oc, string.len(oc), string.len(oc)) ~= "}" then
        return
    end
    
    local values = {}
    
    for i=1, string.len(oc), 1 do
        local subx = string.sub(oc, i, i+4)
        local sub = string.sub(oc, i, i+3)
        local sub2 = string.sub(oc, i, i+2)
        local sub3 = string.sub(oc, i, i+1)
        for j=1, #funcs, 1 do
            if sub == funcs[j] then
                table.insert(values, {
                    start = i,
                    ended = i+3,
                    data = sub2
                })                
            end
            if sub2 == funcs[j] then
                table.insert(values, {
                    start = i,
                    ended = i+2,
                    data = sub3
                })
            end
            if subx == funcs[j] then
                table.insert(values, {
                    start = i,
                    ended = i+4,
                    data = string.sub(oc, i, i+3)
                })
            end
        end
    end
    
    local strings = {}
    
    for i=1, #values, 1 do
        if #values ~= i then
            table.insert(strings, {
                data = string.sub(oc, values[i].ended+1, values[i+1].start-2)
            })
        else
            table.insert(strings, {
                data = string.sub(oc, values[i].ended+1, string.len(oc)-1)
            })    
        end
    end
    
    local returnvars = {}
    
    for i=1, #strings, 1 do
        returnvars[#returnvars+1] = {
            type = values[i].data,
            strings = strings[i].data
        }
    end

    local data = returnvars
    local ret = {}
    for i=1, #data, 1 do
        local c = functions[data[i].type]
        local d = string.find
        if c then
            if d(c, 'information') then
                table.insert(ret, function(cb, check)
                    if not check then 
                        local str = data[i].strings
                        TriggerEvent('chat:addMessage', {
                            color = { 255, 0, 0},
                            multiline = true,
                            args = {"Quest", str}
                        })
                        cb('event', true)
                    else
                        cb('event', true)
                    end
                end)
            end
            if d(c, 'WaitTillEnd') then
                table.insert(ret, function(cb)
                    cb('wait', 'DEFINED!')
                end)
            end
            if d(c, 'GoTo') then
                table.insert(ret, function(cb, check)
                    if not check then
                        local returnval = {}
                        local vars = {}

                        for j=1, string.len(data[i].strings), 1 do
                            if string.sub(data[i].strings, j, j) == ',' then
                                table.insert(vars, j)
                            end
                        end

                        table.insert(vars, string.len(data[i].strings)-1)

                        for j=1, #vars, 1 do
                            if j == 1 then
                                table.insert(returnval, tonumber(string.sub(data[i].strings, 1, vars[j]-1)))
                            end
                            if j > 1 and j <= 3 then
                                table.insert(returnval, tonumber(string.sub(data[i].strings, vars[j-1]+1, vars[j]-1)))
                            end
                            if j == 4 or j == 5 then
                                if string.sub(data[i].strings, vars[j]+1, vars[j]+1) == 't' then
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
                end)
            end
            if d(c, 'CreateNPC') then
                table.insert(ret, function(cb, check)
                    if not check then
                        local returnval = {}
                        local vars = {}

                        for j=1, string.len(data[i].strings), 1 do
                            if string.sub(data[i].strings, j, j) == ',' then
                                table.insert(vars, j)
                            end
                        end

                        table.insert(vars, string.len(data[i].strings)-1)

                        for j=1, #vars, 1 do
                            if j == 1 then
                                table.insert(returnval, tostring(string.sub(data[i].strings, 1, vars[j]-1)))
                            end
                            if j > 1 and j <= 5 then
                                table.insert(returnval, tonumber(string.sub(data[i].strings, vars[j-1]+1, vars[j]-1)))
                            end
                            if j == 6 then
                                if string.sub(data[i].strings, vars[j]+1, vars[j]+1) == 't' then
                                    table.insert(returnval, true)
                                else
                                    table.insert(returnval, false)
                                end
                            end
                        end

                        cb('createnpc', returnval)
                    else
                        cb('createnpc', true)
                    end
                end)
            end
            if d(c, 'LoadNPC') then
                table.insert(ret, function(cb, check)
                    if not check then
                        local str = data[i].strings
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
                end)
            end
            if d(c, 'PlayAnim') then
                table.insert(ret, function(cb, check)
                    if not check then
                        local returnval = {}
                        local vars = {}

                        for j=1, string.len(data[i].strings), 1 do
                            if string.sub(data[i].strings, j, j) == ',' then
                                table.insert(vars, j)
                            end
                        end

                        table.insert(vars, string.len(data[i].strings)-1)

                        for j=1, #vars, 1 do
                            if j == 1 then
                                table.insert(returnval, string.sub(data[i].strings, 1, vars[j]-1))
                            end
                            if j == 2 then
                                table.insert(returnval, string.sub(data[i].strings, vars[j-1]+1, string.len(data[i].strings)))
                            end
                            if j == 3 then
                                table.insert(returnval, string.sub(data[i].strings, vars[j]+1, string.len(data[i].strings)))
                            end
                        end    
                        
                        cb('playanim', returnval)
                    else
                        cb('playanim', true)
                    end
                end)
            end
            if d(c, 'Scenario') then
                table.insert(ret, function(cb, check)
                    if not check then
                        local returnval = {}
                        local vars = {}

                        for j=1, string.len(data[i].strings), 1 do
                            if string.sub(data[i].strings, j, j) == ',' then
                                table.insert(vars, j)
                            end
                        end

                        table.insert(vars, string.len(data[i].strings)-1)

                        for j=1, #vars, 1 do
                            if j == 1 then
                                table.insert(returnval, string.sub(data[i].strings, 1, vars[j]-1))
                            end
                            if j == 2 and #vars == 2 then
                                if string.sub(data[i].strings, vars[j]+1, string.len(data[i].strings)) == 't' then
                                    table.insert(returnval, true)
                                else
                                    table.insert(returnval, false)
                                end
                            else
                                if string.sub(data[i].strings, vars[j]+1, vars[j+1]-1) == 't' then
                                    table.insert(returnval, true)
                                else
                                    table.insert(returnval, false)
                                end
                            end
                            if j == 3 then
                                if tonumber(string.sub(data[i].strings, vars[j]+1, string.len(data[i].strings))) then
                                    table.insert(returnval, tonumber(string.sub(data[i].strings, vars[j]+1, string.len(data[i].strings))))
                                else
                                    table.insert(string.sub(data[i].strings, vars[j]+1, string.len(data[i].strings)))
                                end
                            end
                        end    
                        
                        cb('scenario', returnval)
                    else
                        cb('scenario', true)
                    end
                end)
            end
            if d(c, 'Delay') then
                table.insert(ret, function(cb, check)
                    if not check then
                        cb('delay', tonumber(data[i].strings))
                    else
                        cb('delay', true)
                    end
                end)
            end
            if d(c, 'MissionText') then
                table.insert(ret, function(cb, check)
                    if not check then
                        local returnval = {}
                        local vars = {}

                        for j=1, string.len(data[i].strings), 1 do
                            if string.sub(data[i].strings, j, j) == ',' then
                                table.insert(vars, j)
                            end
                        end

                        table.insert(vars, string.len(data[i].strings)-1)

                        for j=1, #vars, 1 do
                            if j == 1 then
                                table.insert(returnval, string.sub(data[i].strings, 1, vars[j]-1))
                            end
                            if j == 2 then
                                table.insert(returnval, tonumber(string.sub(data[i].strings, vars[j-1]+1, string.len(data[i].strings))))
                            end
                        end

                        cb('missiontext', returnval)
                    else
                        cb('misiontext', true)
                    end
                end)
            end
            if d(c, 'Marker') then
                table.insert(ret, function(cb, check)
                    if not check then
                        local returnval = {}
                        local vars = {}

                        for j=1, string.len(data[i].strings), 1 do
                            if string.sub(data[i].strings, j, j) == ',' then
                                table.insert(vars, j)
                            end
                        end

                        table.insert(vars, string.len(data[i].strings)-1)

                        for j=1, #vars, 1 do
                            if j == 1 then
                                table.insert(returnval, tonumber(string.sub(data[i].strings, 1, vars[j]-1)))
                            end
                            if j > 1 and j <= #vars-1 then
                                local p = string.sub(data[i].strings, vars[j-1]+1, vars[j]-1)
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
                                local p = string.sub(data[i].strings, vars[j-1]+1, string.len(data[i].strings))
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
                end)
            end
        end
    end

    local LastAwaitExecuted = 0

    for i=1, #ret, 1 do
        ret[i](function(name, data)
            if name == 'goto' then
                LastAwaitExecuted = i
            end
            if name == 'marker' then
                LastAwaitExecuted = i
            end
            if name == 'wait' then
                if i == 1 or i == #ret then end
                ret[LastAwaitExecuted](function(p)
                    if p == 'goto' then
                        ret[LastAwaitExecuted](function(name2, data)
                            if data[4] then
                                SetNewWaypoint(data[1], data[2])
                            end
                            while true do
                                local c = vector3(data[1], data[2], data[3])
                                Citizen.Wait(500)
                                if Vdist2(c, GetEntityCoords(GetPlayerPed(-1))) < 3.0 then
                                    break
                                end
                            end
                        end)
                    elseif p == 'marker' then
                        ret[LastAwaitExecuted](function(name2, data2)
                            while true do
                                local c = vector3(data2[2], data2[3], data2[4])
                                Citizen.Wait(200)
                                if ButtonPressedOnMarker and ButtonPressedOnMarker['name'] == data2[2] .. data2[14] then
                                    break
                                end
                            end
                        end)
                    end
                end, true)
            elseif name == 'createnpc' then
                local hash = GetHashKey(data[1])
                RequestModel(hash)
                while not HasModelLoaded(hash) do
                    Citizen.Wait(10)
                end
                local ped = CreatePed(1, hash, data[2], data[3], data[4], data[5], data[6], false)
                if data[7] then
                    LastPed = nil
                    Peds[data[7]] = ped
                    LastPed = data[7]
                else
                    LastPed = nil
                    Peds[#Peds+1] = ped
                    LastPed = #Peds
                end
            elseif name == 'loadnpc' then
                if data[1] then
                    if Peds[data[1]] then
                        LastPed = nil
                        LastPed = data[1]
                    end
                end
            elseif name == 'playanim' then
                RequestAnimDict(data[1])
				while not HasAnimDictLoaded(data[1]) do
					Citizen.Wait(1000)
				end
                if data[3] and Peds[data[3]] then
                    TaskPlayAnim(Peds[data[3]], data[1], data[2], 3.0, -3.0, -1, 49, 0, 0, 0, 0)
                else
                    if data[3] and data[3] == 'self' then
                        TaskPlayAnim(GetPlayerPed(-1), data[1], data[2], 3.0, -3.0, -1, 49, 0, 0, 0, 0)
                    else
                        TaskPlayAnim(Peds[LastPed], data[1], data[2], 3.0, -3.0, -1, 49, 0, 0, 0, 0)
                    end
                end
            elseif name == 'scenario' then
                if data[3] and Peds[data[3]] then
                    TaskStartScenarioInPlace(Peds[data[3]], data[1], 0, data[2])
                else
                    if data[3] and data[3] == 'self' then
                        TaskStartScenarioInPlace(GetPlayerPed(-1), data[1], 0, data[2])
                    else
                        TaskStartScenarioInPlace(Peds[LastPed], data[1], 0, data[2])
                    end
                end
            elseif name == 'delay' then
                Citizen.Wait(data)
            elseif name == 'missiontext' then
                MT(data[1], data[2])
            elseif name == 'marker' then
                table.insert(Markers, {
                    type = data[1],
                    coords = {
                        x=data[2],
                        y=data[3],
                        z=data[4],
                    },
                    directions = {
                        x = data[5],
                        y = data[6],
                        z = data[7],
                    },
                    rotations = {
                        x = data[8],
                        y = data[9],
                        z = data[10],
                    },
                    scale = {
                        x = data[11],
                        y = data[12],
                        z = data[13],
                    },
                    red = data[14],
                    green = data[15],
                    blue = data[16],
                    alpha = data[17],
                    p1 = data[18],
                    p2 = data[19],
                    p3 = data[20],
                    p4 = data[21],
                    options = {
                        onButton = (data[22] ~= nil and data[22] ~= false),
                        Button = data[23]
                    }
                })
            end
        end)
    end
end

function MT(p1, p2)
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(p1)
    DrawSubtitleTimed(p2, 1)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        if #Markers == 0 then
            Citizen.Wait(500)
        else
            local coords = GetEntityCoords(PlayerPedId())
            for i=1, #Markers, 1 do
                if Vdist2(coords, vector3(Markers[i].coords.x, Markers[i].coords.y, Markers[i].coords.z)) < 10.0 then
                    DrawMarker(Markers[i].type, 
                    Markers[i].coords.x, Markers[i].coords.y, Markers[i].coords.z,
                    Markers[i].directions.x, Markers[i].directions.y, Markers[i].directions.z,
                    Markers[i].rotations.x, Markers[i].rotations.y, Markers[i].rotations.z,
                    Markers[i].scale.x, Markers[i].scale.y, Markers[i].scale.z,
                    Markers[i].red, Markers[i].green, Markers[i].blue, Markers[i].alpha,
                    Markers[i].p1, Markers[i].p2, 2, Markers[i].p3, false, false, Markers[i].p4)
                    if Markers[i].options and Markers[i].options.onButton then
                        if Vdist2(coords, vector3(Markers[i].coords.x, Markers[i].coords.y, Markers[i].coords.z)) < 1.0 and IsControlJustPressed(1, Markers[i].options.Button) then
                            ButtonPressedOnMarker = {}
                            ButtonPressedOnMarker['name'] = Markers[i].coords.x .. Markers[i].red
                        end
                    end
                end
            end
        end
    end
end)
