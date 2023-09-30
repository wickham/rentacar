fx_version "adamant"

description "Rent-a-Car!"
author "ChronoRift, Raider#0101"
version '1.0.0'
repository 'https://github.com/wickham/rentacar'

game "gta5"

client_script {"client/*.lua"}

server_script {'@mysql-async/lib/MySQL.lua', "server/*.lua"}

shared_scripts {'@ox_lib/init.lua', '@shared_lua/shared/vehicle_info.lua', "shared/*.lua"}

ui_page "index.html"

files {'index.html', 'assets/**/*.*'}

dependencies {'ox_lib', 'shared_lua'}

lua54 'yes'
