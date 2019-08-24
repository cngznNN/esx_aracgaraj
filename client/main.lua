ESX = nil
spawnPrice = Config.Price

-- THREADS
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        for i=1, #Config.Zones.Pos, 1 do
            DrawMarker(27,Config.Zones.Pos[i].x,Config.Zones.Pos[i].y,Config.Zones.Pos[i].z - 0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 255, 82, 94, 255, false, true, 2, nil, nil, false)
            DrawMarker(36,Config.Zones.Pos[i].x,Config.Zones.Pos[i].y,Config.Zones.Pos[i].z - 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 255, true, true, 2, nil, nil, false)
        end        
    end
end)

Citizen.CreateThread(function()
    for i=1, #Config.Zones.Pos, 1 do
        local blip = AddBlipForCoord(Config.Zones.Pos[i].x,Config.Zones.Pos[i].y,Config.Zones.Pos[i].z )
        SetBlipSprite(blip, 524)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 37)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(_U('blipname'))
        EndTextCommandSetBlipName(blip)     
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = GetPlayerPed(-1)
        local x, y, z = table.unpack(GetEntityCoords(ped))
        for i=1, #Config.Zones.Pos, 1 do
            if Vdist(x, y, z, Config.Zones.Pos[i].x,Config.Zones.Pos[i].y,Config.Zones.Pos[i].z) < 1.8 then
                FloatingHelpText(_U('help_text'))
                if IsControlJustPressed(1, 51) then
                    ShowPlayerMenu()
                end
            end         
        end   
        Citizen.Wait(0)
    end
end)


-- FUNCTIONS

function FloatingHelpText(text)   
    BeginTextCommandDisplayHelp("STRING") 
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end

function ShowPlayerMenu()
    TriggerServerEvent('esx_aracgaraj:getOwnedVehicles')
end

-- ETC...

_vehicles = {}

RegisterNetEvent('esx_aracgaraj:getOwnedVehicles')
AddEventHandler('esx_aracgaraj:getOwnedVehicles', function(vehicles, plate)
    local _elements = {}
    for i=1, #vehicles, 1 do
        table.insert(_elements, {label = GetDisplayNameFromVehicleModel(vehicles[i].model) .. ' [<span style="color: orange;">' .. plate[i] .. '</span>] ' .. '[<span style="color: green;">' .. _U('money_icon') .. spawnPrice .. '</span>]', value = "Vehicle" .. i})             
    end

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'menu',
        {
            title = _U('menu_title'),
            align = 'top-left',
            elements = _elements 
        },     

        function(data, menu)            
            menu.close()
            menu.close()

            for i=1, #vehicles, 1 do              
                if data.current.value == "Vehicle" .. i then    
                    _vehicles = vehicles[i]
                    TriggerServerEvent('esx_aracgaraj:cikarma')
                end    
            end       
        end,
    function(data, menu)
        menu.close()
    end
    )
end)

RegisterNetEvent('esx_aracgaraj:cikarma')
AddEventHandler('esx_aracgaraj:cikarma', function(state)   
    if state == false then
        ESX.ShowNotification(_U('enough_money'))
    else
        local coords  = GetEntityCoords(PlayerPedId())
        local heading = GetEntityHeading(PlayerPedId())    
        local vehicles = _vehicles
        local vehicleData = vehicles

        ESX.ShowNotification(_U('spawn_car_message'))
        ESX.Game.SpawnVehicle(vehicles.model, {
            x = coords.x,
            y = coords.y,
            z = coords.z
          }, heading, function (_vehicle)
          ESX.Game.SetVehicleProperties(_vehicle, vehicleData)
          TaskWarpPedIntoVehicle(PlayerPedId(), _vehicle, -1)
          TriggerServerEvent("esx_aracgaraj:oncekiarac",NetworkGetNetworkIdFromEntity(_vehicle))
        end)
    end
end)

RegisterNetEvent('esx_aracgaraj:oncekiarac')
AddEventHandler('esx_aracgaraj:oncekiarac', function (carid)
	ESX.Game.DeleteVehicle(NetworkGetEntityFromNetworkId(carid))
end)