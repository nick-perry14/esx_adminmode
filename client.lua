local ESX = nil
local lastJob = nil
local lastGrade = nil
local spawnedVeh = {}
local lastarmor = 0
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('esx_adminmode:onCommand')
AddEventHandler('esx_adminmode:onCommand', function()
	local xPlayer = ESX.GetPlayerData()
		if xPlayer.job.name == 'admin' or xPlayer.job.name == 'moderator' then
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
			-- God Mode
		else
			lastJob = xPlayer.job.name
			lastGrade = xPlayer.job.grade
			lastarmor = GetPedArmour(PlayerPedId())
			-- Ped Spawning
			ESX.Streaming.RequestModel(-2039072303, function()
				SetPlayerModel(PlayerId(), -2039072303)
				SetModelAsNoLongerNeeded(-2039072303)
				SetPedDefaultComponentVariation(PlayerPedId())
				TriggerEvent('esx:restoreLoadout')
				ESX.TriggerServerCallback("esx_adminmode:checkGroup",function(group)
				if group == 'moderator' then
					TriggerServerEvent('esx_adminmode:setJob', 'moderator', 0)
					TriggerEvent('esx_status:set', 'hunger', 1000000)
					TriggerEvent('esx_status:set', 'thirst', 1000000)
					TriggerEvent('esx_status:set', 'drunk', 0)
					TriggerEvent('esx_status:set', 'drug', 0)
					if #spawnedVeh == 0 then
						ESX.Game.SpawnVehicle("tahoeb", GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), function(callback_vehicle)
						table.insert(spawnedVeh, callback_vehicle)
						SetVehicleExtra(callback_vehicle, 1, 0)
						SetVehicleExtra(callback_vehicle, 2, 0)
						SetVehicleExtra(callback_vehicle, 3, 0)
						SetVehicleExtra(callback_vehicle, 4, 1)
						SetVehicleExtra(callback_vehicle, 5, 0)
						SetVehicleExtra(callback_vehicle, 10, 0)
						SetVehicleExtra(callback_vehicle, 11, 1)
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
						SetVehicleLivery(callback_vehicle,1)
						TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
						end)
					end
					
				else
					TriggerServerEvent('esx_adminmode:setJob', 'admin', 0)
					TriggerEvent('esx_status:set', 'hunger', 1000000)
					TriggerEvent('esx_status:set', 'thirst', 1000000)
					TriggerEvent('esx_status:set', 'drunk', 0)
					TriggerEvent('esx_status:set', 'drug', 0)
					if #spawnedVeh == 0 then
						ESX.Game.SpawnVehicle("tahoeb", GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), function(callback_vehicle)
						table.insert(spawnedVeh, callback_vehicle)
						SetVehicleExtra(callback_vehicle, 1, 0)
						SetVehicleExtra(callback_vehicle, 2, 0)
						SetVehicleExtra(callback_vehicle, 3, 0)
						SetVehicleExtra(callback_vehicle, 4, 1)
						SetVehicleExtra(callback_vehicle, 5, 0)
						SetVehicleExtra(callback_vehicle, 10, 0)
						SetVehicleExtra(callback_vehicle, 11, 1)
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
						SetVehicleLivery(callback_vehicle,0)
						TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
						end)
					end
					
				end
				end)
			end)
			-- Godmode
			SetEntityInvincible(GetPlayerPed(-1), true)
			SetPlayerInvincible(PlayerId(), true)
			SetPedCanRagdoll(GetPlayerPed(-1), false)
			ClearPedBloodDamage(GetPlayerPed(-1))
			ResetPedVisibleDamage(GetPlayerPed(-1))
			ClearPedLastWeaponDamage(GetPlayerPed(-1))
			SetEntityProofs(GetPlayerPed(-1), true, true, true, true, true, true, true, true)
			SetEntityOnlyDamagedByPlayer(GetPlayerPed(-1), false)
			SetEntityCanBeDamaged(GetPlayerPed(-1), false)
			TriggerEvent("chat:addMessage",{color={0,255,0},multiline=false,args={"Admin Mode","Enabled!"}})
			TriggerEvent('esx:restoreLoadout')
		end
end)

function DeleteSpawnedVehicles()
	while #spawnedVeh > 0 do
		local vehicle = spawnedVeh[1]
		ESX.Game.DeleteVehicle(vehicle)
		table.remove(spawnedVeh, 1)
	end
end


RegisterCommand("adminmode", function() 
		local xPlayer = ESX.GetPlayerData()
		ESX.TriggerServerCallback("esx_adminmode:checkGroup",function(group)
		if group == 'moderator' or group == 'admin' or group == 'superadmin' then
			TriggerEvent('esx_adminmode:onCommand')
		else
			TriggerEvent("chat:addMessage",{color={255,0,0},multiline=false,args={"Admin Mode","You do not have permission to use this command!"}})
		end
	end)
end)