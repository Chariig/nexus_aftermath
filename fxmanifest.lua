fx_version 'cerulean'
game 'gta5'

name 'nexus_apocalypse'
description 'Nexus: Aftermath - Custom Standalone Apocalypse Framework'
version '2.0.0'
author 'NexusDev'
url 'https://nexus-aftermath.dev'

dependencies {
    'oxmysql',
    'ox_lib',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'shared/*.lua',
    'server/*.lua',
    'modules/echo/server/*.lua',
    'modules/scavengers/server/*.lua',
    'modules/radio/server/*.lua',
    'modules/virus/server/*.lua',
    'modules/tether/server/*.lua',
}

client_scripts {
    'config.lua',
    'shared/*.lua',
    'client/*.lua',
    'modules/echo/client/*.lua',
    'modules/scavengers/client/*.lua',
    'modules/radio/client/*.lua',
    'modules/virus/client/*.lua',
    'modules/tether/client/*.lua',
}

shared_scripts {
    'shared/*.lua',
}

files {
    'locales/*.json',
    'web/hud/index.html',
    'web/hud/script.js',
    'web/hud/style.css',
    'web/inventory/index.html',
    'web/inventory/script.js',
    'web/inventory/style.css',
}

ui_page 'web/hud/index.html'

convar_category 'Nexus: Aftermath' {
    { 1, 'Debug Mode', 'na_debug', 'false', { 'true', 'false' }, 'Enable debug logging' },
    { 2, 'Max Players', 'na_max_players', '64', {}, 'Maximum players' },
    { 3, 'World Tier', 'na_world_tier', 'auto', { 'auto', 'safe', 'unstable', 'critical', 'collapse' }, 'Starting world tier' },
    { 4, 'Infection Rate', 'na_infection_rate', '1.0', {}, 'Global infection rate multiplier (0.0 - 3.0)' },
    { 5, 'Resource Multiplier', 'na_resource_mult', '1.0', {}, 'Global resource spawn multiplier' },
}
