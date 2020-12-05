local ESX = nil
local lastJob = nil
local lastGrade = nil
local spawnedVeh = {}
local lastarmor = 0
local lastskin = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('esx_adminmode:onCommand')
AddEventHandler('esx_adminmode:onCommand', function()
	local xPlayer = ESX.GetPlayerData()
	ESX.TriggerServerCallback("esx_adminmode:checkGroup",function(authed)
		if authed then
			if isOnDuty() then
				offDuty()
			else
				onDuty()
			end
		else
		--[[
		Insert Ban Statement here if you would like to ban the player for cheating.
		The only way they would get to this line is if they manually called the event,
		which would signify cheating.
		--]]
		end
	end)
end)

function DeleteSpawnedVehicles()
	while #spawnedVeh > 0 do
		local vehicle = spawnedVeh[1]
		ESX.Game.DeleteVehicle(vehicle)
		table.remove(spawnedVeh, 1)
	end
end

function onDuty()
	local xPlayer = ESX.GetPlayerData()
	lastJob = xPlayer.job.name
	lastGrade = xPlayer.job.grade
	lastarmor = GetPedArmour(PlayerPedId())
	local info = {}
		ESX.TriggerServerCallback('esx_adminmode:checkGroup', function(group)
		for k, v in ipairs(Config.Groups) do 
			print(v.group)
			if group == v.group then
			info = v
			break
			end
		end
		TriggerServerEvent('esx_adminmode:setJob', info.job, info.grade)
	ESX.Streaming.RequestModel(info.ped, function()	
		SetPlayerModel(PlayerId(), info.ped)
		SetModelAsNoLongerNeeded(info.ped)
		SetPedDefaultComponentVariation(PlayerPedId())
		for k,v in ipairs(info.pedvari) do
			SetPedComponentVariation(GetPlayerPed(-1), v.component, v.texture-1, v.color-1, 0)
		end
		for k,v in ipairs(info.pedprop) do
			if v.texture == 0 then
			ClearPedProp(ped, v.component)
			else
			SetPedPropIndex(GetPlayerPed(-1), v.component, v.texture-1, v.color-1, v.attach)
			end
		end
		TriggerEvent('esx:restoreLoadout')
		if info.god then
			SetEntityInvincible(GetPlayerPed(-1), true)
			SetPlayerInvincible(PlayerId(), true)
			SetEntityOnlyDamagedByPlayer(GetPlayerPed(-1), false)
			SetEntityCanBeDamaged(GetPlayerPed(-1), false)
			SetEntityProofs(GetPlayerPed(-1), true, true, true, true, true, true, true, true)
		end
		if info.heal then
			SetPedCanRagdoll(GetPlayerPed(-1), false)
			ClearPedBloodDamage(GetPlayerPed(-1))
			ResetPedVisibleDamage(GetPlayerPed(-1))
			ClearPedLastWeaponDamage(GetPlayerPed(-1))
			if Config.ESXStatus then
				TriggerEvent('esx_status:set', 'hunger', 1000000)
				TriggerEvent('esx_status:set', 'thirst', 1000000)
				TriggerEvent('esx_status:set', 'drunk', 0)
				TriggerEvent('esx_status:set', 'drug', 0)
			end
			if IsPedMale(PlayerPedId()) then
				SetEntityHealth(PlayerPedId(), 200)
			else
				SetEntityHealth(PlayerPedId(), 100)
			end
		end
				TriggerEvent("chat:addMessage",{color={0,255,0},multiline=false,args={"Admin Mode","Enabled!"}})
				TriggerEvent('esx:restoreLoadout')
		if #spawnedVeh == 0 then	
			ESX.Game.SpawnVehicle(info.car, GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), function(callback_vehicle)
				Citizen.Wait(10)
				table.insert(spawnedVeh, callback_vehicle)
				for extra,enabled in ipairs(ESX.Game.GetVehicleProperties(callback_vehicle).extras) do
					enabled = false
					for _,eID in ipairs(info.extras) do
						if extra == eID then
							enabled = true
						end
					end
				end
				SetVehRadioStation(callback_vehicle, "OFF")
				SetVehicleFixed(callback_vehicle)
				SetVehicleDeformationFixed(callback_vehicle)
				SetVehicleUndriveable(callback_vehicle, 0)
				SetVehicleCanBeVisiblyDamaged(callback_vehicle, 0)
				SetEntityCanBeDamaged(callback_vehicle, 0)
				SetVehicleExclusiveDriver(callback_vehicle, PlayerPedId(), 0)
				SetVehicleExclusiveDriver_2(callback_vehicle, PlayerPedId(), 1)
				SetVehicleEngineOn(callback_vehicle, true, true, false)
				SetEntityProofs(callback_vehicle, 1, 1, 1, 1, 1, 1, 1, 1)
				SetVehicleStrong(callback_vehicle, true)
				SetVehicleLivery(callback_vehicle,info.vehlivery)
				TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
			end)
		end
	end)
	end)
end

function offDuty()
	DeleteSpawnedVehicles()
	TriggerServerEvent('esx_adminmode:setJob', lastJob, lastGrade)
	lastJob = nil
	lastGrade = nil
	-- Ped Change
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
		local isMale = skin.sex == 0
		TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
				TriggerEvent('skinchanger:loadSkin', skin)
				TriggerEvent('esx:restoreLoadout')
				SetPedArmour(PlayerPedId(), lastarmor)
				SetEntityInvincible(GetPlayerPed(-1), false)
				SetPlayerInvincible(PlayerId(), false)
				SetPedCanRagdoll(GetPlayerPed(-1), true)
				ClearPedLastWeaponDamage(GetPlayerPed(-1))
				SetEntityProofs(GetPlayerPed(-1), false, false, false, false, false, false, false, false)
				SetEntityOnlyDamagedByPlayer(GetPlayerPed(-1), true)
				SetEntityCanBeDamaged(GetPlayerPed(-1), true)
				TriggerEvent("chat:addMessage",{color={255,0,0},multiline=false,args={"Admin Mode","Disabled!"}})
			end)
		end)
	end)
end

function isOnDuty()
	for k, v in ipairs(Config.Groups) do 
		if ESX.GetPlayerData().job.name == v.job then
			return true
		end
	end
		return false
end

RegisterCommand("adminmode", function() 
		local xPlayer = ESX.GetPlayerData()
		ESX.TriggerServerCallback("esx_adminmode:checkGroup",function(authed)
		if authed then
			TriggerEvent('esx_adminmode:onCommand')
		else
			TriggerEvent("chat:addMessage",{color={255,0,0},multiline=false,args={"Admin Mode","You do not have permission to use this command!"}})
		end
	end)
end)