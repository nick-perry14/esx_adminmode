Config = {}
Config.Groups = {
{
group = 'superadmin', -- Group Name
job = 'admin', -- Job to set when on duty
grade = 0, -- Grade of job to set when on duty
car ='tahoeb', -- car model name
vehlivery = 0, -- Car Livery ID
extras = {4,11}, -- Enabled Car Extras
ped = -2039072303, -- Ped Hash
pedvari = {{component=8,texture=2,color=1},{component=3,texture=2,color=1},{component=9,texture=2,color=1},{component=8,texture=1,color=1}}, -- Ped Variation ID in table, {componentid, the textureID, the colorID}
pedprop = {{component=0,texture=2,color=2,attach=true},},
god= true, -- God the player on admin mode
heal= true, -- heal the player on admin mode (includes hunger/thirst/drugs if ESXStatus is Enabled)
kick= false, -- Can the player kick other players?
warn= true, -- Can the player warn other players?
ban= true, -- Can the player ban other players?
},
}

Config.ESXStatus = true -- Enable if using ESX Status
Config.banformat = "You have been banned from =167= FiveM\nReason: %s\nExpires: %s\nBanned by: %s (Ban ID: #%s)" -- message shown when banned (1st %s = reason, 2nd %s = expire, 3rd %s = banner, 4th %s = ban id)
Config.popassistformat = "Player %s is requesting help\nWrite <span class='text-success'>/accassist %s</span> to accept or <span class='text-danger'>/decassist</span> to decline" -- popup assist message format
Config.chatassistformat = "Player %s is requesting help\nWrite ^2/accassist %s^7 to accept or ^1/decassist^7 to decline\n^4Reason^7: %s" -- chat assist message format
Config.enable_ban_json = false -- http://<server-ip>:<server-port>/el_bwh/bans.json
Config.enable_warning_json = false -- http://<server-ip>:<server-port>/el_bwh/warnings.json
Config.assist_keys = {accept=208,decline=207} -- keys for accepting/declining assist messages (default = page up, page down) - https://docs.fivem.net/game-references/controls/
-- Config.assist_keys = nil -- coment the line above and uncomment this one to disable assist keys
Config.warning_screentime = 7.5 * 1000 -- warning display length (in ms)
Config.backup_kick_method = false -- set this to true if banned players don't get kicked
Config.discord_webhook = nil -- set to nil to disable, otherwise put "<your webhook url here>" <-- with the quotes!
Config.page_element_limit = 250