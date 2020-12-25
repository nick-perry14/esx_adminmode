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
 
  ESX.RegisterServerCallback("esx_adminmode:checkCanBan", function(source,cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		cb(canBan(xPlayer))
 end)
  ESX.RegisterServerCallback("esx_adminmode:checkCanWarn", function(source,cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		cb(canWarn(xPlayer))
 end)
  ESX.RegisterServerCallback("esx_adminmode:checkCanKick", function(source,cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		cb(canKick(xPlayer))
 end)

 ESX.RegisterServerCallback("esx_adminmode:checkGroup", function(source,cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		local group = xPlayer.getGroup()
		cb(group)
 end)
 
local bancache,namecache = {},{}
local open_assists,active_assists = {},{}

function split(s, delimiter)result = {};for match in (s..delimiter):gmatch("(.-)"..delimiter) do table.insert(result, match) end return result end

Citizen.CreateThread(function() -- startup
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    while ESX==nil do Wait(0) end
    if Config.enable_ban_json or Config.enable_warning_json then
		SetHttpHandler(function(req,res)
			if req.path=="/bans.json" and Config.enable_ban_json then
				MySQL.Async.fetchAll("SELECT * FROM adminmode_bans",{},function(data)
					res.send(json.encode(data))
				end)
			elseif req.path=="/warnings.json" and Config.enable_warning_json then
				MySQL.Async.fetchAll("SELECT * FROM adminmode_warnings",{},function(data)
					res.send(json.encode(data))
				end)
			end
		end)
	end
    MySQL.ready(function()
        refreshNameCache()
        refreshBanCache()
    end)
end)

    ESX.RegisterServerCallback("esx_adminmode:ban", function(source,cb,target,reason,length,offline)
        if not target or not reason then return end
        local xPlayer = ESX.GetPlayerFromId(source)
        local xTarget = ESX.GetPlayerFromId(target)
        if not xPlayer or (not xTarget and not offline) then cb(nil); return end
        if canBan(xPlayer) then
            local success, reason = banPlayer(xPlayer,offline and target or xTarget,reason,length,offline)
            cb(success, reason)
        else logUnfairUse(xPlayer); cb(false) end
    end)

    ESX.RegisterServerCallback("esx_adminmode:warn",function(source,cb,target,message,anon)
        if not target or not message then return end
        local xPlayer = ESX.GetPlayerFromId(source)
        local xTarget = ESX.GetPlayerFromId(target)
        if not xPlayer or not xTarget then cb(nil); return end
        if canWarn(xPlayer) then
            warnPlayer(xPlayer,xTarget,message,anon)
            cb(true)
        else logUnfairUse(xPlayer); cb(false) end
    end)
	ESX.RegisterServerCallback("esx_adminmode:kick",function(source,cb,target,message,anon)
        if not target or not message then return end
        local xPlayer = ESX.GetPlayerFromId(source)
        local xTarget = ESX.GetPlayerFromId(target)
        if not xPlayer or not xTarget then cb(nil); return end
        if canWarn(xPlayer) then
            kickPlayer(xPlayer,xTarget,message,anon)
            cb(true)
        else logUnfairUse(xPlayer); cb(false) end
    end)

    ESX.RegisterServerCallback("esx_adminmode:getWarnList",function(source,cb)
        local xPlayer = ESX.GetPlayerFromId(source)
        -- local start = GetGameTimer() -- debug
        if canWarn(xPlayer) then
            local warnlist = {}
            for k,v in ipairs(MySQL.Sync.fetchAll("SELECT * FROM adminmode_warnings LIMIT @limit",{["@limit"]=Config.page_element_limit})) do
                v.receiver_name=namecache[v.receiver]
                v.sender_name=namecache[v.sender]
                table.insert(warnlist,v)
            end
            cb(json.encode(warnlist),MySQL.Sync.fetchScalar("SELECT CEIL(COUNT(id)/@limit) FROM adminmode_warnings",{["@limit"]=Config.page_element_limit}))
        else logUnfairUse(xPlayer); cb(false) end
        -- TriggerClientEvent("chat:addMessage",source,{multiline=false,args={"[^4DEBUG^7] ^1Admin Mode",("Warnlist loading time: %sms"):format(GetGameTimer()-start)}}) -- debug
    end)

    ESX.RegisterServerCallback("esx_adminmode:getBanList",function(source,cb)
		refreshNameCache()
        local xPlayer = ESX.GetPlayerFromId(source)
        -- local start = GetGameTimer() -- debug
        if canBan(xPlayer) then
            local data = MySQL.Sync.fetchAll("SELECT * FROM adminmode_bans LIMIT @limit",{["@limit"]=Config.page_element_limit})
            local banlist = {}
            for k,v in ipairs(data) do
				
                v.receiver_name = namecache[json.decode(v.receiver)[1]]
                v.sender_name = namecache[v.sender]
                table.insert(banlist,v)
            end
            cb(json.encode(banlist),MySQL.Sync.fetchScalar("SELECT CEIL(COUNT(id)/@limit) FROM adminmode_bans",{["@limit"]=Config.page_element_limit}))
        else logUnfairUse(xPlayer); cb(false) end
        -- TriggerClientEvent("chat:addMessage",source,{multiline=false,args={"[^4DEBUG^7] ^1Admin Mode",("Banlist loading time: %sms"):format(GetGameTimer()-start)}}) -- debug
    end)

    ESX.RegisterServerCallback("esx_adminmode:getListData",function(source,cb,list,page)
        local xPlayer = ESX.GetPlayerFromId(source)
        if canBan(xPlayer) or canWarn(xPlayer)   then
            if list=="banlist" then
                local banlist = {}
                for k,v in ipairs(MySQL.Sync.fetchAll("SELECT * FROM adminmode_bans LIMIT @limit OFFSET @offset",{["@limit"]=Config.page_element_limit,["@offset"]=Config.page_element_limit*(page-1)})) do
                    v.receiver_name = namecache[json.decode(v.receiver)[1]]
                    v.sender_name = namecache[v.sender]
                    table.insert(banlist,v)
                end
                cb(json.encode(banlist))
            else
                local warnlist = {}
                for k,v in ipairs(MySQL.Sync.fetchAll("SELECT * FROM adminmode_warnings LIMIT @limit OFFSET @offset",{["@limit"]=Config.page_element_limit,["@offset"]=Config.page_element_limit*(page-1)})) do
                    v.sender_name=namecache[v.sender]
                    v.receiver_name=namecache[v.receiver]
                    table.insert(warnlist,v)
                end
                cb(json.encode(warnlist))
            end
        else logUnfairUse(xPlayer); cb(nil) end
    end)

    ESX.RegisterServerCallback("esx_adminmode:unban",function(source,cb,id)
        local xPlayer = ESX.GetPlayerFromId(source)
        if canBan(xPlayer) then
            MySQL.Async.execute("UPDATE adminmode_bans SET unbanned=1 WHERE id=@id",{["@id"]=id},function(rc)
                local bannedidentifier = "N/A"
                for k,v in ipairs(bancache) do
                    if v.id==id then
                        bannedidentifier = v.receiver[1]
                        bancache[k].unbanned = true
                        break
                    end
                end
                logAdmin(("Admin ^1%s^7 unbanned ^1%s^7 (%s)"):format(GetPlayerName(xPlayer.source),(bannedidentifier~="N/A" and namecache[bannedidentifier]) and namecache[bannedidentifier] or "N/A",bannedidentifier))
                cb(rc>0)
            end)
        else logUnfairUse(xPlayer); cb(false) end
    end)

AddEventHandler("playerConnecting",function(name, setKick, def)
    local identifiers = GetPlayerIdentifiers(source)
    if #identifiers>0 and identifiers[1]~=nil then
        local banned, data = isBanned(identifiers)
        namecache[identifiers[1]]=GetPlayerName(source)
        if banned then
            print(("[^1"..GetCurrentResourceName().."^7] Banned player %s (%s) tried to join, their ban expires on %s (Ban ID: #%s)"):format(GetPlayerName(source),data.receiver[1],data.length and os.date("%Y-%m-%d %H:%M",data.length) or "PERMANENT",data.id))
            local kickmsg = Config.banformat:format(data.reason,data.length and os.date("%Y-%m-%d %H:%M",data.length) or "PERMANENT",data.sender_name,data.id)
            if Config.backup_kick_method then DropPlayer(source,kickmsg) else def.done(kickmsg) end
        else
            local data = {["@name"]=GetPlayerName(source)}
            for k,v in ipairs(identifiers) do
                data["@"..split(v,":")[1]]=v
            end
            if not data["@steam"] then
                print("[^1"..GetCurrentResourceName().."^7] Player connecting without steamid, skipping identifier storage")
            else
                MySQL.Async.execute("INSERT INTO `adminmode_identifiers` (`steam`, `license`, `ip`, `name`, `xbl`, `live`, `discord`, `fivem`) VALUES (@steam, @license, @ip, @name, @xbl, @live, @discord, @fivem) ON DUPLICATE KEY UPDATE `license`=@license, `ip`=@ip, `name`=@name, `xbl`=@xbl, `live`=@live, `discord`=@discord, `fivem`=@fivem",data)
            end
        end
    else
        if Config.backup_kick_method then DropPlayer(source,"[Admin Mode] No identifiers were found when connecting, please reconnect") else def.done("[Admin Mode] No identifiers were found when connecting, please reconnect") end
    end
end)

AddEventHandler("playerDropped",function(reason)
    if open_assists[source] then open_assists[source]=nil end
    for k,v in ipairs(active_assists) do
        if v==source then
            active_assists[k]=nil
            TriggerClientEvent("chat:addMessage",k,{color={255,0,0},multiline=false,args={"Admin Mode","The admin that was helping you dropped from the server"}})
            return
        elseif k==source then
            TriggerClientEvent("esx_adminmode:assistDone",v)
            TriggerClientEvent("chat:addMessage",v,{color={255,0,0},multiline=false,args={"Admin Mode","The player you were helping dropped from the server, teleporting back..."}})
            active_assists[k]=nil
            return
        end
    end
end)

function refreshNameCache()
    namecache={}
    for k,v in ipairs(MySQL.Sync.fetchAll("SELECT license,name FROM adminmode_identifiers")) do
        namecache[v.license]=v.name
    end
end

function refreshBanCache()
    bancache={}
    for k,v in ipairs(MySQL.Sync.fetchAll("SELECT id,receiver,sender,reason,UNIX_TIMESTAMP(length) AS length,unbanned FROM adminmode_bans")) do
        table.insert(bancache,{id=v.id,sender=v.sender,sender_name=namecache[v.sender]~=nil and namecache[v.sender] or "N/A",receiver=json.decode(v.receiver),reason=v.reason,length=v.length,unbanned=v.unbanned==1})
    end
end

function sendToDiscord(msg)
    if Config.discord_webhook~=nil then
        PerformHttpRequest(Config.discord_webhook, function(a,b,c)end, "POST", json.encode({embeds={{title="Admin Action Log",description=msg:gsub("%^%d",""),color=65280,}}}), {["Content-Type"]="application/json"})
    end
end

function logAdmin(msg)
    for k,v in ipairs(ESX.GetPlayers()) do
        if isAuthed(ESX.GetPlayerFromId(v)) then
            TriggerClientEvent("chat:addMessage",v,{color={255,0,0},multiline=false,args={"Admin Mode",msg}})
            sendToDiscord(msg)
        end
    end
end

function isBanned(identifiers)
    for _,ban in ipairs(bancache) do
        if not ban.unbanned and (ban.length==nil or ban.length>os.time()) then
            for _,bid in ipairs(ban.receiver) do
                for _,pid in ipairs(identifiers) do
                    if bid==pid then return true, ban end
                end
            end
        end
    end
    return false, nil
end

function execOnAdmins(func)
    local ac = 0
    for k,v in ipairs(ESX.GetPlayers()) do
        if isAuthed(ESX.GetPlayerFromId(v)) then
            ac = ac + 1
            func(v)
        end
    end
    return ac
end

function logUnfairUse(xPlayer)
    if not xPlayer then return end
    print(("[^1"..GetCurrentResourceName().."^7] Player %s (%s) tried to use an admin feature"):format(GetPlayerName(xPlayer.source),xPlayer.identifier))
    logAdmin(("Player %s (%s) tried to use an admin feature"):format(GetPlayerName(xPlayer.source),xPlayer.identifier))
end

function banPlayer(xPlayer,xTarget,reason,length,offline)
    local targetidentifiers,offlinename,timestring,data = {},nil,nil,nil
    if offline then
        data = MySQL.Sync.fetchAll("SELECT * FROM adminmode_identifiers WHERE steam=@identifier",{["@identifier"]=xTarget})
        if #data<1 then
            return false, "~r~Identifier is not in identifiers database!"
        end
        offlinename = data[1].name
		for k,v in pairs(data[1]) do
            if k=="license" then table.insert(targetidentifiers,v) end
        end
        for k,v in pairs(data[1]) do
            if k~="name" and k~="license" then table.insert(targetidentifiers,v) end
        end
    else
        targetidentifiers = GetPlayerIdentifiers(xTarget.source)
    end
    if length=="" then length = nil end
    MySQL.Async.execute("INSERT INTO adminmode_bans(id,receiver,sender,length,reason) VALUES(NULL,@receiver,@sender,@length,@reason)",{["@receiver"]=json.encode(targetidentifiers),["@sender"]=getIdent(xPlayer),["@length"]=length,["@reason"]=reason},function(_)
        local banid = MySQL.Sync.fetchScalar("SELECT MAX(id) FROM adminmode_bans")
        logAdmin(("Player ^1%s^7 (%s) has been banned by ^1%s^7, expiration: %s, reason: '%s'"..(offline and " (OFFLINE BAN)" or "")):format(offline and offlinename or GetPlayerName(xTarget.source),offline and data[1].steam or xTarget.identifier, xPlayer == nil and "Console" or GetPlayerName(xPlayer.source),length~=nil and length or "PERMANENT",reason))
        if length~=nil then
            timestring=length
            local year,month,day,hour,minute = string.match(length,"(%d+)/(%d+)/(%d+) (%d+):(%d+)")
            length = os.time({year=year,month=month,day=day,hour=hour,min=minute})
        end
        table.insert(bancache,{id=banid==nil and "1" or banid,sender=xPlayer.identifier,reason=reason,sender_name=GetPlayerName(xPlayer.source),receiver=targetidentifiers,length=length})
        if offline then xTarget = ESX.GetPlayerFromIdentifier(xTarget) end -- just in case the player is on the server, you never know
        if xTarget then
            TriggerClientEvent("esx_adminmode:gotBanned",xTarget.source, reason)
            Citizen.SetTimeout(5000, function()
                DropPlayer(xTarget.source,Config.banformat:format(reason,length~=nil and timestring or "PERMANENT",GetPlayerName(xPlayer.source),banid==nil and "1" or banid))
            end)
        else return false, "~r~Unknown error (MySQL?)" end
        return true, ""
    end)
end

function warnPlayer(xPlayer,xTarget,message,anon)
    MySQL.Async.execute("INSERT INTO adminmode_warnings(id,receiver,sender,message) VALUES(NULL,@receiver,@sender,@message)",{["@receiver"]=xTarget.identifier,["@sender"]=xPlayer.identifier,["@message"]=message})
    TriggerClientEvent("esx_adminmode:receiveWarn",xTarget.source,anon and "" or GetPlayerName(xPlayer.source),message)
    logAdmin(("Admin ^1%s^7 warned ^1%s^7 (%s), Reason: '%s'"):format(GetPlayerName(xPlayer.source),GetPlayerName(xTarget.source),xTarget.identifier,message))
end

function kickPlayer(xPlayer,xTarget,message,anon)
	local playerString = anon and "***REDACTED***" or GetPlayerName(xPlayer.source)
	DropPlayer(xTarget.source, 'You were kicked from the server!\nKicked By: ' .. playerString .. '\nReason: ' .. message)
    logAdmin(("Admin ^1%s^7 kicked ^1%s^7 (%s), Reason: '%s'"):format(GetPlayerName(xPlayer.source),GetPlayerName(xTarget.source),xTarget.identifier,message))
end

AddEventHandler("esx_adminmode:ban",function(sender,target,reason,length,offline)
    if source=="" then -- if it's from server only
        banPlayer(sender,target,reason,length,offline)
    end
end)

AddEventHandler("esx_adminmode:warn",function(sender,target,message,anon)
    if source=="" then -- if it's from server only
        warnPlayer(sender,target,message,anon)
    end
end)

RegisterCommand('assist', function(source, args, user)
    local reason = table.concat(args," ")
    if reason=="" or not reason then TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","Please specify a reason"}}); return end
    if not open_assists[source] and not active_assists[source] then
        local ac = execOnAdmins(function(admin) TriggerClientEvent("esx_adminmode:requestedAssist",admin,source); TriggerClientEvent("chat:addMessage",admin,{color={0,255,255},multiline=Config.chatassistformat:find("\n")~=nil,args={"Admin Mode",Config.chatassistformat:format(GetPlayerName(source),source,reason)}}) end)
        if ac>0 then
            open_assists[source]=reason
            Citizen.SetTimeout(120000,function()
                if open_assists[source] then open_assists[source]=nil
					if GetPlayerName(source)~=nil then
						TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","Your assist request has expired"}})
					end
				end
            end)
            TriggerClientEvent("chat:addMessage",source,{color={0,255,0},multiline=false,args={"Admin Mode","Assist request sent (expires in 120s), write ^1/cassist^7 to cancel your request"}})
        else
            TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","There's no admins on the server"}})
        end
    else
        TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","Someone is already helping your or you already have a pending assist request"}})
    end
end)

RegisterCommand('cassist', function(source, args, user)
    if open_assists[source] then
        open_assists[source]=nil
        TriggerClientEvent("chat:addMessage",source,{color={0,255,0},multiline=false,args={"Admin Mode","Your request was successfuly cancelled"}})
        execOnAdmins(function(admin) TriggerClientEvent("esx_adminmode:hideAssistPopup",admin) end)
    else
        TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","You don't have any pending help requests"}})
    end
end)

RegisterCommand('finassist', function(source, args, user)
    local xPlayer = ESX.GetPlayerFromId(source)
    if isAuthed(xPlayer) then
        local found = false
        for k,v in pairs(active_assists) do
            if v==source then
                found = true
                active_assists[k]=nil
                TriggerClientEvent("chat:addMessage",source,{color={0,255,0},multiline=false,args={"Admin Mode","Assist closed, teleporting back"}})
                TriggerClientEvent("esx_adminmode:assistDone",source)
            end
        end
        if not found then TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","You're not helping anyone"}}) end
    else
        TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","You don't have permissions to use this command!"}})
    end
end)

RegisterCommand('ban', function(source, args, user)
	 local xPlayer = ESX.GetPlayerFromId(source)
	 if canBan(xPlayer) then
		TriggerClientEvent("esx_adminmode:showWindow",source,'ban')
	 else
		TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","You don't have permissions to use this command!"}})
	 end
end)

RegisterCommand('kick', function(source, args, user)
	 local xPlayer = ESX.GetPlayerFromId(source)
	 if canKick(xPlayer) then
		TriggerClientEvent("esx_adminmode:showWindow",source,'kick')
	 else
		TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","You don't have permissions to use this command!"}})
	 end
end)

RegisterCommand('warn', function(source, args, user)
	local xPlayer = ESX.GetPlayerFromId(source)
	 if canWarn(xPlayer) then
		TriggerClientEvent("esx_adminmode:showWindow",source,'warn')
	 else
		TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","You don't have permissions to use this command!"}})
	 end
end)

RegisterCommand('banlist', function(source, args, user)
	local xPlayer = ESX.GetPlayerFromId(source)
	 if canBan(xPlayer) then
		TriggerClientEvent("esx_adminmode:showWindow",source,'banlist')
	 else
		TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","You don't have permissions to use this command!"}})
	 end
end)

RegisterCommand('warnlist', function(source, args, user)
	local xPlayer = ESX.GetPlayerFromId(source)
	 if canWarn(xPlayer) then
		TriggerClientEvent("esx_adminmode:showWindow",source,'warnlist')
	 else
		TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","You don't have permissions to use this command!"}})
	 end
end)

RegisterCommand('bansrefresh', function(source, args, user)
	local xPlayer = ESX.GetPlayerFromId(source)
	 if canBan(xPlayer) then
		TriggerClientEvent("chat:addMessage",source,{color={0,255,0},multiline=false,args={"Admin Mode","Refreshing ban & name cache..."}})
        refreshNameCache()
        refreshBanCache()
	 else
		TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","You don't have permissions to use this command!"}})
	 end
end)
-- Staff Chat
RegisterCommand('sc', function(source, args, rawCommand)
    local playerName = GetPlayerName(source)
    local msg = rawCommand:sub(4)
    local name = getIdentity(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	msg = trimSpace(msg)
	if isAuthed(xPlayer) then
		if msg ~= "" then
			local xPlayers = ESX.GetPlayers()
			for i=1, #xPlayers, 1 do
				local target = ESX.GetPlayerFromId(xPlayers[i])
				if isAuthed(target) then
					TriggerClientEvent("chat:addMessage",source,{color={102,255,0},multiline=false,args={"(Staff Chat) " .. playerName, msg}})
				end
			end
		end
	else
		TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode", "You don't have permissions to use this command!"}})
		return
	end
end, false)

RegisterCommand('assists', function(source, args, user)
	local xPlayer = ESX.GetPlayerFromId(source)
	 if isAuthed(xPlayer) then
		local openassistsmsg,activeassistsmsg = "",""
		for k,v in pairs(open_assists) do
			openassistsmsg=openassistsmsg.."^5ID "..k.." ("..GetPlayerName(k)..")^7 - "..v.."\n"
		end
		for k,v in pairs(active_assists) do
			activeassistsmsg=activeassistsmsg.."^5ID "..k.." ("..GetPlayerName(k)..")^7 - "..v.." ("..GetPlayerName(v)..")\n"
		end
		TriggerClientEvent("chat:addMessage",source,{color={0,255,0},multiline=true,args={"Admin Mode","Pending assists:\n"..(openassistsmsg~="" and openassistsmsg or "^1No pending assists")}})
		TriggerClientEvent("chat:addMessage",source,{color={0,255,0},multiline=true,args={"Admin Mode","Active assists:\n"..(activeassistsmsg~="" and activeassistsmsg or "^1No active assists")}})
	 else
		TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","You don't have permissions to use this command!"}})
	 end
end)

function acceptAssist(xPlayer,target)
    if isAuthed(xPlayer) then
        local source = xPlayer.source
        for k,v in pairs(active_assists) do
            if v==source then
                TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","You're already helping someone"}})
                return
            end
        end
        if open_assists[target] and not active_assists[target] then
            open_assists[target]=nil
            active_assists[target]=source
            TriggerClientEvent("esx_adminmode:acceptedAssist",source,target)
            TriggerClientEvent("esx_adminmode:hideAssistPopup",source)
            TriggerClientEvent("chat:addMessage",source,{color={0,255,0},multiline=false,args={"Admin Mode","Teleporting to player..."}})
        elseif not open_assists[target] and active_assists[target] and active_assists[target]~=source then
            TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","Someone is already helping this player"}})
        else
            TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","Player with that id did not request help"}})
        end
    else
        TriggerClientEvent("chat:addMessage",source,{color={255,0,0},multiline=false,args={"Admin Mode","You don't have permissions to use this command!"}})
    end
end

RegisterCommand('accassist', function(source, args, user)
    local xPlayer = ESX.GetPlayerFromId(source)
    local target = tonumber(args[1])
    acceptAssist(xPlayer,target)
	TriggerClientEvent("esx_adminmode:hideAssistPopup", -1)
end)

RegisterServerEvent("esx_adminmode:acceptAssistKey")
AddEventHandler("esx_adminmode:acceptAssistKey",function(target)
    if not target then return end
    local _source = source
    acceptAssist(ESX.GetPlayerFromId(_source),target)
end)

function getIdent(xPlayer)
    if xPlayer == nil then
		return "Console"
	else
		return xPlayer.identifier
	end
end

function canKick(xPlayer)
	for k, v in ipairs(Config.Groups) do 
		if xPlayer.getGroup() == v.group then
			return v.kick 
		end
	end
		return false
end

function canBan(xPlayer)
	for k, v in ipairs(Config.Groups) do 
		if xPlayer.getGroup() == v.group then
			return v.ban 
		end
	end
		return false
end

function canWarn(xPlayer)
	for k, v in ipairs(Config.Groups) do 
		if xPlayer.getGroup() == v.group then
			return v.warn
		end
	end
		return false
end

function isAuthed(xPlayer)
	for k, v in ipairs(Config.Groups) do 
		if xPlayer.getGroup() == v.group then
			return true
		end
	end
		return false
end
