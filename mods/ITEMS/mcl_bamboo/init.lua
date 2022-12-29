-- [bamboo] mod by SmallJoker, Made for MineClone 2 by Michieal (as mcl_bamboo).
-- Parts of mcl_scaffolding were used. Mcl_scaffolding originally created by Cora; Fixed and heavily reworked
-- for mcl_bamboo by Michieal.
-- Creation date: 12-01-2022 (Dec 1st, 2022)
-- License for everything: CC-BY-SA 4.0
-- Bamboo max height: 12-16

-- LOCALS
local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local bamboo = "mcl_bamboo:bamboo"

mcl_bamboo = {}

-- BAMBOO GLOBALS
dofile(minetest.get_modpath(modname) .. "/globals.lua")
-- BAMBOO Base Nodes
dofile(minetest.get_modpath(modname) .. "/bamboo_base.lua")
-- BAMBOO ITEMS
dofile(minetest.get_modpath(modname) .. "/bamboo_items.lua")
-- BAMBOO RECIPES
dofile(minetest.get_modpath(modname) .. "/recipes.lua")

-- ------------------------------------------------------------

--ABMs
minetest.register_abm({
	nodenames = {bamboo, bamboo .. "_1", bamboo .. "_2", bamboo .. "_3"},
	interval = 40,
	chance = 40,
	action = function(pos, node)
		mcl_bamboo.grow_bamboo(pos, node)
	end,
})

-- Base Aliases.
minetest.register_alias("bamboo_block", "mcl_bamboo:bamboo_block")
minetest.register_alias("bamboo_strippedblock", "mcl_bamboo:bamboo_block_stripped")
minetest.register_alias("bamboo", "mcl_bamboo:bamboo")
minetest.register_alias("bamboo_plank", "mcl_bamboo:bamboo_plank")
minetest.register_alias("bamboo_mosaic", "mcl_bamboo:bamboo_mosaic")

minetest.register_alias("mcl_stairs:stair_bamboo", "mcl_stairs:stair_bamboo_block")
minetest.register_alias("bamboo:bamboo", "mcl_bamboo:bamboo")
minetest.register_alias("mcl_scaffolding:scaffolding", "mcl_bamboo:scaffolding")
minetest.register_alias("mcl_scaffolding:scaffolding_horizontal", "mcl_bamboo:scaffolding")

--[[
todo -- make scaffolds do side scaffold blocks, so that they jut out.
todo -- Also, make those blocks collapse (break) when a nearby connected scaffold breaks.
todo -- Add Flourish to the endcap node for bamboo. Fix the flourish to not look odd or plain.
todo -- mash all of that together so that it drops as one item.
todo -- fix scaffolding placing, instead of using on_rightclick first.

waiting on specific things:
todo -- Raft -- need model
todo -- Raft with Chest. same.
todo -- handle bonemeal...

-----------------------------------------------------------
todo -- Add in Extras. -- Moved to Official Mod Pack.

Notes:
When bone meal is used on it, it grows by 1–2 blocks. Bamboo can grow up to 12–16 blocks tall.
The top of a bamboo plant requires a light level of 9 or above to grow.

Design Decision - to not make bamboo saplings, and not make them go through a ton of transformations.

--]]
