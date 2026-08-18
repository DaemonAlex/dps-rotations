fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'dps-rotations'
description 'DPS rotating-location engine: moves dealers, harvests, and future pools on a deterministic schedule'
author 'DaemonAlex / Del Perro Sands'
version '1.0.0'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server.lua',
}
