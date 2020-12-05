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
},
}
Config.ESXStatus = true -- Enable if using ESX Status