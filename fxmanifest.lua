fx_version 'adamant'

game 'gta5'

description 'ESX Admin Mode'

version '1.0'

client_scripts {
	'client.lua',
	'config.lua',
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
	'server.lua',
	'config.lua',
}

files {
    "html/index.html",
    "html/script.js",
    "html/style.css",
    "html/jquery.datetimepicker.min.css",
    "html/jquery.datetimepicker.full.min.js",
    "html/date.format.js"
}

ui_page "html/index.html"

dependencies {
	'es_extended'
}
