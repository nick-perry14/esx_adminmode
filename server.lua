local ESX = nil
RegisterNetEvent("passengertoggle")
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('esx_adminmode:setJob')
AddEventHandler('esx_adminmode:setJob', function(lastjob, lastgrade)
		local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.setJob(lastjob, lastgrade)
end)

 ESX.RegisterServerCallback("esx_adminmode:checkGroup", function(source,cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		local group = xPlayer.getGroup()
		cb(group)
 end)