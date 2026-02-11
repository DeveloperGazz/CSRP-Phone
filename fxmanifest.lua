fx_version 'cerulean'
game 'gta5'

author 'CSRP Development'
description 'Standalone Phone System with PMA Voice Integration'
version '1.0.0'

shared_scripts {
    'config.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/server.lua'
}

client_scripts {
    'client/client.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}
