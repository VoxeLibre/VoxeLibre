-- [bamboo] mod by SmallJoker, Made for MineClone 2 by Michieal (as mcl_bamboo).
-- Parts of mcl_scaffolding were used. Mcl_scaffolding originally created by Cora; Fixed and heavily reworked
-- for mcl_bamboo by Michieal.
-- Creation date: 12-01-2022 (Dec 1st, 2022)
-- License for Media: CC-BY-SA 4.0 (except where noted); Code: GPLv3
-- Copyright (C) 2022 - 2023, Michieal. See License.txt

-- LOCALS
local modname = minetest.get_current_modname()
-- Used everywhere. Often this is just the name, but it makes sense to me as BAMBOO, because that's how I think of it...
-- "BAMBOO" goes here.
local BAMBOO = "mcl_bamboo:bamboo"

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
	label = "Bamboo Grow",
	nodenames = mcl_bamboo.bamboo_index,
	interval = 10,
	chance = 20,
	action = function(pos, _)
		mcl_bamboo.grow_bamboo(pos, false)
	end,
})

if minetest.get_modpath("mesecons_mvps") then
	if mesecons_mvps then
		for x = 1, #mcl_bamboo.bamboo_index do
			mesecon.register_mvps_dropper(mcl_bamboo.bamboo_index[x], mcl_bamboo.break_orphaned)
		end
	end
else
	minetest.register_abm({
		label = "Break Orphaned Bamboo",
		nodenames = mcl_bamboo.bamboo_index,
		interval = 1.5,
		chance = 1,
		action = function(pos, _)
			local node_below = minetest.get_node(vector.offset(pos, 0, -1, 0))
			local node_name = node_below.name

			-- short circuit checks.
			if mcl_bamboo.is_dirt(node_name) or mcl_bamboo.is_bamboo(node_name) or mcl_bamboo.is_bamboo(minetest.get_node(pos).name) == false then
				return
			end

			-- dig the node.
			minetest.remove_node(pos)    -- if that fails, remove the node
			local istack = ItemStack("mcl_bamboo:bamboo")
			local sound_params = {
				pos = pos,
				gain = 1.0, -- default
				max_hear_distance = 10, -- default, uses a Euclidean metric
			}

			minetest.remove_node(pos)
			minetest.sound_play(mcl_sounds.node_sound_wood_defaults().dug, sound_params, true)
			minetest.add_item(pos, istack)
		end,
	})
end

-- Base Aliases.
local SCAFFOLDING_NAME = "mcl_bamboo:scaffolding"
minetest.register_alias("bamboo_block", "mcl_bamboo:bamboo_block")
minetest.register_alias("bamboo_strippedblock", "mcl_bamboo:bamboo_block_stripped")
minetest.register_alias("bamboo", BAMBOO)
minetest.register_alias("bamboo_plank", "mcl_bamboo:bamboo_plank")
minetest.register_alias("bamboo_mosaic", "mcl_bamboo:bamboo_mosaic")

minetest.register_alias("mcl_stairs:stair_bamboo", "mcl_stairs:stair_bamboo_block")
minetest.register_alias("bamboo_stairs", "mcl_stairs:stair_bamboo_block")
minetest.register_alias("bamboo:bamboo", BAMBOO)
minetest.register_alias("scaffold", SCAFFOLDING_NAME)
minetest.register_alias("mcl_scaffolding:scaffolding", SCAFFOLDING_NAME)
minetest.register_alias("mcl_scaffolding:scaffolding_horizontal", SCAFFOLDING_NAME)

minetest.register_alias("bamboo_fence", "mcl_fences:bamboo_fence")
minetest.register_alias("bamboo_fence_gate", "mcl_fences:bamboo_fence_gate")

--[[
todo -- make scaffolds do side scaffold blocks, so that they jut out. (Shelved.)
todo -- Also, make those blocks collapse (break) when a nearby connected scaffold breaks.

waiting on specific things:
todo -- Raft -- need model
todo -- Raft with Chest. same.
todo -- handle bonemeal... (shelved until after redoing the bonemeal api).

-----------------------------------------------------------
todo -- Add in Extras. -- Moved to Official Mod Pack.

Notes:
When bone meal is used on it, it grows by 1–2 blocks. Bamboo can grow up to 12–16 blocks tall.
The top of a bamboo plant requires a light level of 9 or above to grow.

Design Decision - to not make bamboo saplings, and not make them go through a ton of transformations.

--]]
