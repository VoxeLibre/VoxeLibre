-- Minetest 0.4 mod: default
-- See README.txt for licensing and other information.
-- The API documentation in here was moved into doc/lua_api.txt

-- Definitions made by this mod that other mods can use too
mcl_core = {}
mcl_core.gui_slots = "listcolors[#9990;#FFF7;#FFF0;#000;#FFF]"
mcl_core.gui_bg = "bgcolor[#080808BB;true]"
mcl_core.gui_bg_img = ""

mcl_core.inventory_header = mcl_core.gui_slots .. mcl_core.gui_bg

minetest.nodedef_default.stack_max = 64
minetest.craftitemdef_default.stack_max = 64

-- Load files
dofile(minetest.get_modpath("mcl_core").."/functions.lua")
dofile(minetest.get_modpath("mcl_core").."/nodes.lua")
dofile(minetest.get_modpath("mcl_core").."/tools.lua")
dofile(minetest.get_modpath("mcl_core").."/craftitems.lua")
dofile(minetest.get_modpath("mcl_core").."/crafting.lua")
dofile(minetest.get_modpath("mcl_core").."/mapgen.lua")
dofile(minetest.get_modpath("mcl_core").."/player.lua")

-- Aliases
minetest.register_alias("default:desert_sand", "mcl_core:sand")
minetest.register_alias("default:desert_stone", "mcl_core:sandstone")
minetest.register_alias("default:iron_lump", "mcl_core:iron_lump")
minetest.register_alias("default:gold_lump", "mcl_core:gold_lump")
