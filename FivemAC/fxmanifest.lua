fx_version 'cerulean'
game 'gta5'

name        'Thinking Anti-Cheat'
description 'Thinking AC — Comprehensive security for FiveM'
author      'Custom AC'
version     '2.0.0'

shared_scripts {
    'shared/config.lua',
    'shared/whitelist.lua',
}

client_scripts {
    'client/main.lua',
    'client/detections.lua',
}

server_scripts {
    'server/main.lua',
    'server/bans.lua',
    'server/logs.lua',
    'server/web.lua',
}

files {
    'web/index.html',
    'web/css/style.css',
    'web/js/app.js',
    'web/js/api.js',
}
