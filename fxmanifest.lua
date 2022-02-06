-- Resource Metadata
fx_version 'cerulean'
games { 'rdr3', 'gta5' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Balurat <balurat@gmail.com>'
description 'Job for Bounty Hunters'
version '1.0.0'

-- What to run
ui_page 'assets/index.html'

client_scripts {
    'client/main.lua'
}
server_scripts {
    'server/main.lua'
}

files {
    'assets/index.html',
    'assets/css/main.css',
    'assets/js/main.js'
}