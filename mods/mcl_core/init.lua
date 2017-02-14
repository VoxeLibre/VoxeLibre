-- Minetest 0.4 mod: default
-- See README.txt for licensing and other information.
-- The API documentation in here was moved into doc/lua_api.txt

-- Definitions made by this mod that other mods can use too
mcl_core = {}
mcl_core.gui_slots = "listcolors[#9990;#FFF7;#FFF0;#000;#FFF]"
mcl_core.gui_bg = "bgcolor[#080808BB;true]"
mcl_core.gui_bg_img = ""

mcl_core.inventory_header = mcl_core.gui_slots .. mcl_core.gui_bg

-- Repair percentage for toolrepair
mcl_core.repair = 0.05

minetest.nodedef_default.stack_max = 64
minetest.craftitemdef_default.stack_max = 64

-- Load files
dofile(minetest.get_modpath("mcl_core").."/functions.lua")
dofile(minetest.get_modpath("mcl_core").."/nodes.lua")
dofile(minetest.get_modpath("mcl_core").."/tools.lua")
dofile(minetest.get_modpath("mcl_core").."/craftitems.lua")
dofile(minetest.get_modpath("mcl_core").."/crafting.lua")
dofile(minetest.get_modpath("mcl_core").."/mapgen.lua")
