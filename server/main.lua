ESX = nil

spawnPrice = Config.Price

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_aracgaraj:getOwnedVehicles')
AddEventHandler('esx_aracgaraj:getOwnedVehicles', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner', {
		['@owner'] = xPlayer.identifier
	}, function (result)
        local vehicles = {}
        local plate = {}

		for i=1, #result, 1 do
			local vehicleData = json.decode(result[i].vehicle)
            table.insert(vehicles, vehicleData)
            table.insert(plate, result[i].plate)
		end       

		TriggerClientEvent('esx_aracgaraj:getOwnedVehicles', xPlayer.source, vehicles, plate)
    end)    
end)


local oncekiarac = {}
RegisterServerEvent("esx_aracgaraj:oncekiarac")
AddEventHandler("esx_aracgaraj:oncekiarac",function(carid)
	if oncekiarac[source] ~= nil then
		TriggerClientEvent("esx_aracgaraj:oncekiarac",-1,oncekiarac[source])
	end
	oncekiarac[source] = carid
end)


RegisterServerEvent('esx_aracgaraj:cikarma')
AddEventHandler('esx_aracgaraj:cikarma', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local money = xPlayer.getMoney()

    if money < spawnPrice then
        TriggerClientEvent('esx_aracgaraj:cikarma', source, false)
    else
        xPlayer.removeMoney(spawnPrice)
        TriggerClientEvent('esx_aracgaraj:cikarma', source, true)
    end   
end)