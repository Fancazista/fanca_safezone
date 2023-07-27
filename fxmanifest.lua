fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author "Fancazista"
github "https://github.com/Fancazista/"
docs "https://docs.fanca.live/"
discord "https://discord.gg/2JTRHrMs4m/"
tebex "https://fanca.tebex.io/"

name 'fanca_safezone'
description "Safe zone script"
version '1.1.0'
download "https://github.com/Fancazista/fanca_safezone/"

shared_scripts {
	'@ox_lib/init.lua',
    '@es_extended/imports.lua',

	'config.lua'
}

server_script 'server/**/*'
client_script 'client/**/*'
