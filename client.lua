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

AddEventHandler('rc_co:inj', function(tab) -- I've added it in github, might work or not, who knows!
    if tab then
        local p = CreateOC(tab)
        Citizen.Wait(100)
        ConvertOC(p)
     end
end)

local data = { -- sample of what this script is supposed to do, you have ['name'] which is type of function 
    {
        ['name'] = 'createnpc',
        'a_m_o_ktown_01',
        GetEntityCoords(PlayerPedId()).x,
        GetEntityCoords(PlayerPedId()).y,
        GetEntityCoords(PlayerPedId()).z,
        GetEntityHeading(PlayerPedId()),
        true
    },
    {
        ['name'] = 'goto',
        100.0,
        200.0,
        300.0,
        true
    },
    {
        ['name'] = 'ignore'
    },
    {
        ['name'] = 'notification',
        'Hejka misiu kochany'
    },
    {
        ['name'] = 'goto',
        100.0,
        200.0,
        300.0,
        true
    }
}

function CreateOC(tab) -- frankencode that is supposed to translate lua table to my great .oc file, I will work on this later, don't judge!
    local returnval = "{"

    for i=1, #tab, 1 do
        if tab[i]['name'] == 'goto' then
            returnval = returnval .. 'gt:' .. tab[i][1] .. ',' .. tab[i][2] .. ',' .. tab[i][3]
            if tab[i][4] == true then
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
        if i == #tab then
            returnval = returnval .. '}'
        else
            returnval = returnval .. ';' 
        end
    end

    return returnval
end
local funcs = {'inf:', 'gt:', 'cnt:', 'cnpc:'} -- functions in .oc file, information, go to, contineu, Create NPC

local functions = { -- Same as before but to not mess it with actual text in like informations or smt, Idk.
    ['inf'] = 'TriggerEvent',
    ['cnt'] = 'WaitTillEnd',
    ['gt'] = 'GoTo',
    ['cnpc'] = 'CreateNPC',
}

function ConvertOC(oc) -- Translates .oc file to something that LUA can read
    if string.sub(oc, 1, 1) ~= '{' then --use LUA to create other language and use LUA to read it again, but you need this other language to be able to read it
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
            if d(c, 'TriggerEvent') then
                table.insert(ret, function(cb, check)
                    if not check then 
                        local str = data[i].strings
                        TriggerEvent('chat:addMessage', {
                            color = { 255, 0, 0},
                            multiline = true,
                            args = {"RC_OC", str}
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
        end
    end

    for i=1, #ret, 1 do -- this executes statements, 1 by 1
        ret[i](function(name, data)
            if name == 'wait' then
                if i == 1 or i == #ret then end
                ret[i-1](function(p)
                    if p == 'goto' then
                        ret[i-1](function(name2, data)
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
                    end
                end, true)
            elseif name == 'createnpc' then
                local hash = GetHashKey(data[1])
                RequestModel(hash)
                while not HasModelLoaded(hash) do
                    Citizen.Wait(10)
                end
                local ped = CreatePed(1, hash, data[2], data[3], data[4], data[5], data[6], false)
            end
        end)
    end
end
