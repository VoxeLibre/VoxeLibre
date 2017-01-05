-- Minetest 0.4 mod: default
-- See README.txt for licensing and other information.
-- The API documentation in here was moved into doc/lua_api.txt

WATER_ALPHA = 160
WATER_VISC = 1
LAVA_VISC = 7

-- Definitions made by this mod that other mods can use too
default = {}
default.gui_slots = "listcolors[#9990;#FFF7;#FFF0;#000;#FFF]"
default.gui_bg = "bgcolor[#080808BB;true]"

default.inventory_header = default.gui_slots .. default.gui_bg

minetest.nodedef_default.stack_max = 64
minetest.craftitemdef_default.stack_max = 64

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
