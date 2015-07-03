-- Minetest 0.4 mod: default
-- See README.txt for licensing and other information.
local init = os.clock()
-- The API documentation in here was moved into doc/lua_api.txt

WATER_ALPHA = 160
WATER_VISC = 1
LAVA_VISC = 7
LIGHT_MAX = 20

-- Show the ModPack Name :D
print(" __  __ _             _____ _                           ___   ___  _  _   ")
print("|  \\/  (_)           / ____| |                         / _ \\ |__ \\| || |  ")
print("| \\  / |_ _ __   ___| |    | | ___  _ __   ___  __   _| | | |   ) | || |_ ")
print("| |\\/| | | '_ \\ / _ \\ |    | |/ _ \\| '_ \\ / _ \\ \\ \\ / / | | |  / /|__   _|")
print("| |  | | | | | |  __/ |____| | (_) | | | |  __/  \\ V /| |_| | / /_   | |  ")
print("|_|  |_|_|_| |_|\\___|\\_____|_|\\___/|_| |_|\\___|   \\_/  \\___(_)____|  |_|  ")
                                                                           
                                                                           

-- Definitions made by this mod that other mods can use too
default = {}

-- Load files
dofile(minetest.get_modpath("default").."/functions.lua")
dofile(minetest.get_modpath("default").."/nodes.lua")
dofile(minetest.get_modpath("default").."/tools.lua")
dofile(minetest.get_modpath("default").."/craftitems.lua")
dofile(minetest.get_modpath("default").."/crafting.lua")
dofile(minetest.get_modpath("default").."/mapgen.lua")
dofile(minetest.get_modpath("default").."/player.lua")

-- Aliases
minetest.register_alias("default:desert_sand", "default:sand")
minetest.register_alias("default:desert_stone", "default:sandstone")
minetest.register_alias("default:iron_lump", "default:stone_with_iron")
minetest.register_alias("default:gold_lump", "default:stone_with_gold")

local time_to_load= os.clock() - init
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))
