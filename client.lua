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

function CreateOC(tab)
    local returnval = "{"

    for i=1, #tab, 1 do
        if globalValues[tab[i]['name']] then
            returnval = returnval .. values[tab[i]['name']]
            local it = (type(globalValues[tab[i]['name']]) ~= 'string')
            local treter
            if it then
                treter = globalValues[tab[i]['name']]
            else
                treter = #tab[i]
            end

            for j=1, treter, 1 do
                local typ = tab[i][j]
                if j ~= globalValues[tab[i]['name']] then
                    if type(typ) == 'boolean' then
                        if typ == true then
                            returnval = returnval .. 't,'
                        else
                            returnval = returnval .. 'f,'
                        end
                    else
                        returnval = returnval .. typ .. ','
                    end
                elseif j == globalValues[tab[i]['name']] and typ then
                    if type(typ) == 'boolean' then
                        if typ == true then
                            returnval = returnval .. 't'
                        else
                            returnval = returnval .. 'f'
                        end
                    else
                        returnval = returnval .. typ
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
                    GreaterReadability['information'](cb, check, data[i].strings)
                end)
            end
            if d(c, 'WaitTillEnd') then
                table.insert(ret, function(cb)
                    cb('wait', 'DEFINED!')
                end)
            end
            if d(c, 'GoTo') then
                table.insert(ret, function(cb, check)
                    GreaterReadability['GoTo'](cb, check, data[i].strings)
                end)
            end
            if d(c, 'CreateNPC') then
                table.insert(ret, function(cb, check)
                    GreaterReadability['CreateNPC'](cb, check, data[i].strings)
                end)
            end
            if d(c, 'LoadNPC') then
                table.insert(ret, function(cb, check)
                    GreaterReadability['LoadNPC'](cb, check, data[i].strings)
                end)
            end
            if d(c, 'PlayAnim') then
                table.insert(ret, function(cb, check)
                    GreaterReadability['PlayAnim'](cb, check, data[i].strings)
                end)
            end
            if d(c, 'Scenario') then
                table.insert(ret, function(cb, check)
                    GreaterReadability['Scenario'](cb, check, data[i].strings)
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
                    GreaterReadability['MissionText'](cb, check, data[i].strings)
                end)
            end
            if d(c, 'Marker') then
                table.insert(ret, function(cb, check)
                    GreaterReadability['Marker'](cb, check, data[i].strings)
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

local opened = false

function OpenUI(isOn)
    opened = isOn
    SetNuiFocus(isOn, isOn)
    SendNUIMessage({
        type = 'ui',
        status = isOn
    })
end

RegisterNUICallback('exit', function(data, cb)
    OpenUI(not opened)
end)

local currentSession = {}
local await = false

RegisterNUICallback('elementSelected', function(data, cb)
    if globalValues[data.elementChosen] then
        if globalValues[data.elementChosen] >= #data.data then
            if data.elementChosen == 'marker' or data.elementChosen == 'goto' then
                await = true
            end
            if data.elementChosen == 'ignore' then
                if await then
                    currentSession[#currentSession+1] = {}
                    currentSession[#currentSession] = data.data
                    currentSession[#currentSession]['name'] = data.elementChosen
                else
                    TriggerEvent('chat:addMessage', {
                        color = {255, 0, 0},
                        multiline = true,
                        args = {'QuestCreator', 'Await not in correct place!'}
                    })
                end
            else
                currentSession[#currentSession+1] = {}
                currentSession[#currentSession] = data.data
                currentSession[#currentSession]['name'] = data.elementChosen
            end
        end
    end
end)

Citizen.CreateThread(function()
    local data = {}
    for i=1, #NUIValues, 1 do
        data[i] = {}
        for j=1, #NUIValues[i], 1 do
            data[i][j] = type(NUIValues[i][j])
        end
    end

    Citizen.Wait(500)

    SendNUIMessage({
        type = 'initialize',
        data = data 
    })
end)

RegisterNUICallback('exportCO', function(data, cb)
    if #currentSession > 0 then
        local returnval = CreateOC(currentSession)
        if returnval then
            print('Exported current session to your clipboard!')
            SendNUIMessage({
                type = 'copy',
                fp = true,
                sp = true,
                data = returnval
            })
        end
    end
end)

local LastSession = {}
local Lastawait = false

RegisterNUICallback('clearOC', function(data, cb)
    print('Cleared Current Session!')
    LastSession = currentSession
    Lastawait = await
    currentSession = nil
    currentSession = {}
    await = false
end)

RegisterNUICallback('recoverOC', function(data, cb)
    if LastSession[1] then
        currentSession = LastSession
        await = Lastawait
        print('Recovered Last Session!')
    else
        print('No session to be recovered!')
    end
end)

RegisterNUICallback('executeOC', function(data, cb)
    if currentSession[1] then
        local returnval = CreateOC(currentSession)
        if returnval then
            ConvertOC(returnval)
            print('Succesfully executed OC!')
        end
    end
end)

RegisterCommand('openOC', function(source,args)
    OpenUI(not opened)
end)
