local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('esx_adminmode:setJob')
AddEventHandler('esx_adminmode:setJob', function(job, grade)
		local xPlayer = ESX.GetPlayerFromId(source)
		if isAuthed(xPlayer) then
			xPlayer.setJob(job, grade)
		else
		--[[
		Insert Ban Statement here if you would like to ban the player for cheating.
		The only way they would get to this line is if they manually called the event,
		which would signify cheating.
		--]]
		end
end)

 ESX.RegisterServerCallback("esx_adminmode:checkAuth", function(source,cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		cb(isAuthed(xPlayer))
 end)

 ESX.RegisterServerCallback("esx_adminmode:checkGroup", function(source,cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		local group = xPlayer.getGroup()
		cb(group)
 end)

 function isAuthed(xPlayer)
	for k, v in ipairs(Config.Groups) do 
		if xPlayer.getGroup() == v.group then
			return true
		end
	end
		return false
end