local ESX = nil
local lastJob = nil
local lastGrade = nil
local spawnedVeh = {}
local lastarmor = 0
local lastskin = nil
local pos_before_assist,assisting,assist_target,last_assist = nil, false, nil, nil

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

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	SetNuiFocus(false, false)
	if Config.assist_keys then
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			if IsControlJustPressed(0, Config.assist_keys.accept) then
				if not last_assist then
					ESX.ShowNotification("~r~Noone requested assistance yet")
				elseif not NetworkIsPlayerActive(GetPlayerFromServerId(last_assist)) then
					ESX.ShowNotification("~r~The player that requested assistance is not online anymore")
					last_assist=nil
				else
					TriggerServerEvent("esx_adminmode:acceptAssistKey",last_assist)
				end
			end
			if IsControlJustPressed(0, Config.assist_keys.decline) then
				TriggerEvent("esx_adminmode:hideAssistPopup")
			end
		end
	end)
end
end)

function GetIndexedPlayerList()
	local players = {}
	for k,v in ipairs(GetActivePlayers()) do
		players[tostring(GetPlayerServerId(v))]=GetPlayerName(v)..(v==PlayerId() and " (self)" or "")
	end
	return json.encode(players)
end

RegisterNUICallback("ban", function(data,cb)
	if not data.target or not data.reason then return end
	ESX.TriggerServerCallback("esx_adminmode:ban",function(success,reason)
		if success then ESX.ShowNotification("~g~Successfully banned player") else ESX.ShowNotification(reason) end -- dont ask why i did it this way, im a bit retarded
	end, data.target, data.reason, data.length, data.offline)
end)

RegisterNUICallback("warn", function(data,cb)
	print('warn callback')
	if not data.target or not data.message then return end
	ESX.TriggerServerCallback("esx_adminmode:warn",function(success)
		if success then ESX.ShowNotification("~g~Successfully warned player") else ESX.ShowNotification("~r~Something went wrong") end
	end, data.target, data.message, data.anon)
end)

RegisterNUICallback("kick", function(data,cb)
	if not data.target or not data.message then return end
	ESX.TriggerServerCallback("esx_adminmode:kick",function(success)
		if success then ESX.ShowNotification("~g~Successfully kicked player") else ESX.ShowNotification("~r~Something went wrong") end
	end, data.target, data.message, data.anon)
end)

RegisterNUICallback("unban", function(data,cb)
	if not data.id then return end
	ESX.TriggerServerCallback("esx_adminmode:unban",function(success)
		if success then ESX.ShowNotification("~g~Successfully unbanned player") else ESX.ShowNotification("~r~Something went wrong") end
	end, data.id)
end)

RegisterNUICallback("getListData", function(data,cb)
	if not data.list or not data.page then cb(nil); return end
	ESX.TriggerServerCallback("esx_adminmode:getListData",function(data)
		cb(data)
	end, data.list, data.page)
end)

RegisterNUICallback("hidecursor", function(data,cb)
	SetNuiFocus(false, false)
end)

RegisterNetEvent("esx_adminmode:gotBanned")
AddEventHandler("esx_adminmode:gotBanned",function(rsn)
	Citizen.CreateThread(function()
		local scaleform = RequestScaleformMovie("mp_big_message_freemode")
		while not HasScaleformMovieLoaded(scaleform) do Citizen.Wait(0) end
		BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
		PushScaleformMovieMethodParameterString("~r~BANNED")
		PushScaleformMovieMethodParameterString(rsn)
		PushScaleformMovieMethodParameterInt(5)
		EndScaleformMovieMethod()
		PlaySoundFrontend(-1, "LOSER", "HUD_AWARDS")
		ClearDrawOrigin()
		ESX.UI.HUD.SetDisplay(0)
		while true do
			Citizen.Wait(0)
			DisableAllControlActions(0)
			DisableFrontendThisFrame()
			local ped = GetPlayerPed(-1)
			ESX.UI.Menu.CloseAll()
			SetEntityCoords(ped, 0, 0, 0, 0, 0, 0, false)
			FreezeEntityPosition(ped, true)
			DrawRect(0.0,0.0,2.0,2.0,0,0,0,255)
			DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
		end
		SetScaleformMovieAsNoLongerNeeded(scaleform)
	end)
end)

RegisterNetEvent("esx_adminmode:receiveWarn")
AddEventHandler("esx_adminmode:receiveWarn",function(sender,message)
	TriggerEvent("chat:addMessage",{color={255,255,0},multiline=true,args={"Admin Mode","You received a warning"..(sender~="" and " from "..sender or "").."!\n-> "..message}})
	Citizen.CreateThread(function()
		local scaleform = RequestScaleformMovie("mp_big_message_freemode")
		while not HasScaleformMovieLoaded(scaleform) do Citizen.Wait(0) end
		BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
		PushScaleformMovieMethodParameterString("~y~WARNING")
		PushScaleformMovieMethodParameterString(message)
		PushScaleformMovieMethodParameterInt(5)
		EndScaleformMovieMethod()
		PlaySoundFrontend(-1, "LOSER", "HUD_AWARDS")
		local drawing = true
		Citizen.SetTimeout(Config.warning_screentime,function() drawing = false end)
		while drawing do
			Citizen.Wait(0)
			DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
		end
		SetScaleformMovieAsNoLongerNeeded(scaleform)
	end)
end)

RegisterNetEvent("esx_adminmode:requestedAssist")
AddEventHandler("esx_adminmode:requestedAssist",function(t)
	SendNUIMessage({show=true,window="assistreq",data=Config.popassistformat:format(GetPlayerName(GetPlayerFromServerId(t)),t)})
	last_assist=t
end)

RegisterNetEvent("esx_adminmode:acceptedAssist")
AddEventHandler("esx_adminmode:acceptedAssist",function(t)
	if assisting then return end
	local target = GetPlayerFromServerId(t)
	if target then
		local ped = GetPlayerPed(-1)
		pos_before_assist = GetEntityCoords(ped)
		assisting = true
		assist_target = t
		ESX.Game.Teleport(ped,GetEntityCoords(GetPlayerPed(target))+vector3(0,0.5,0))
	end
end)

RegisterNetEvent("esx_adminmode:assistDone")
AddEventHandler("esx_adminmode:assistDone",function()
	if assisting then
		assisting = false
		if pos_before_assist~=nil then ESX.Game.Teleport(GetPlayerPed(-1),pos_before_assist+vector3(0,0.5,0)); pos_before_assist = nil end
		assist_target = nil
	end
end)

RegisterNetEvent("esx_adminmode:hideAssistPopup")
AddEventHandler("esx_adminmode:hideAssistPopup",function(t)
	SendNUIMessage({hide=true})
	last_assist=nil
end)

RegisterNetEvent("esx_adminmode:showWindow")
AddEventHandler("esx_adminmode:showWindow",function(win)
	if win=="ban" or win=="warn" or win=="kick" then
		SendNUIMessage({show=true,window=win,players=GetIndexedPlayerList()})
	elseif win=="banlist" or win=="warnlist" then
		SendNUIMessage({loading=true,window=win})
		ESX.TriggerServerCallback(win=="banlist" and "esx_adminmode:getBanList" or "esx_adminmode:getWarnList",function(list,pages)
			SendNUIMessage({show=true,window=win,list=list,pages=pages})
		end)
	end
	SetNuiFocus(true, true)
end)

RegisterCommand("decassist",function(a,b,c)
	TriggerEvent("esx_adminmode:hideAssistPopup")
end, false)