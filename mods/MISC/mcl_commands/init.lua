local S = minetest.get_translator("mcl_commands")

local mod_death_messages = minetest.get_modpath("mcl_death_messages")

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/kill.lua")
dofile(modpath.."/setblock.lua")
dofile(modpath.."/seed.lua")
dofile(modpath.."/summon.lua")
dofile(modpath.."/say.lua")
dofile(modpath.."/list.lua")
dofile(modpath.."/sound.lua")

dofile(modpath.."/alias.lua")