-- mods/default/nodes.lua

local WATER_ALPHA = 160
local WATER_VISC = 1
local LAVA_VISC = 7

--
-- Node definitions
--

minetest.register_node("mcl_core:barrier", {
	description = "Barrier",
	drawtype = "airlike",
	paramtype = "light",
	inventory_image = "default_barrier.png",
	wield_image = "default_barrier.png",
	stack_max = 64,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = { not_in_creative_inventory = 1, oddly_breakable_by_hand = 5 },
	on_blast = function() end,
})

minetest.register_node("mcl_core:stone", {
	description = "Stone",
	tiles = {"default_stone.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {cracky=3, stone=1, building_block=1, deco_block=1},
	drop = 'mcl_core:cobble',
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:stone_with_coal", {
	description = "Coal Ore",
	tiles = {"default_stone.png^default_mineral_coal.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {cracky=3, building_block=1},
	drop = 'mcl_core:coal_lump',
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:stone_with_iron", {
	description = "Iron Ore",
	tiles = {"default_stone.png^default_mineral_iron.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {cracky=2, building_block=1},
	drop = 'mcl_core:stone_with_iron',
	sounds = mcl_core.node_sound_stone_defaults(),
})


minetest.register_node("mcl_core:stone_with_gold", {
	description = "Gold Ore",
	tiles = {"default_stone.png^default_mineral_gold.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {cracky=2, building_block=1},
	drop = "mcl_core:stone_with_gold",
	sounds = mcl_core.node_sound_stone_defaults(),
})

local redstone_timer = 68.28
local redstone_ore_activate = function(pos)
	minetest.swap_node(pos, {name="mcl_core:stone_with_redstone_lit"})
	local t = minetest.get_node_timer(pos)
	t:start(redstone_timer)
end
minetest.register_node("mcl_core:stone_with_redstone", {
	description = "Redstone Ore",
	tiles = {"default_stone.png^default_mineral_redstone.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {cracky=2, building_block=1},
	drop = {
		items = {
			max_items = 1,
			{
				items = {"mesecons:redstone 4"},
				rarity = 2,
			},
			{
				items = {"mesecons:redstone 5"},
			},
		}
	},
	sounds = mcl_core.node_sound_stone_defaults(),
	on_punch = redstone_ore_activate,
	on_walk_over = redstone_ore_activate, -- Uses walkover mod
})

local redstone_ore_reactivate = function(pos)
	local t = minetest.get_node_timer(pos)
	t:start(redstone_timer)
end
-- Light the redstone ore up when it has been touched
minetest.register_node("mcl_core:stone_with_redstone_lit", {
	description = "Lit Redstone Ore",
	tiles = {"default_stone.png^default_mineral_redstone.png"},
	paramtype = "light",
	light_source = 9,
	is_ground_content = true,
	stack_max = 64,
	groups = {cracky=2, not_in_creative_inventory=1},
	drop = {
		items = {
			max_items = 1,
			{
				items = {"mesecons:redstone 4"},
				rarity = 2,
			},
			{
				items = {"mesecons:redstone 5"},
			},
		}
	},
	sounds = mcl_core.node_sound_stone_defaults(),
	-- Reset timer after re-punching or stepping on
	on_punch = redstone_ore_reactivate,
	on_walk_over = redstone_ore_reactivate, -- Uses walkover mod
	-- Turn back to normal node after some time has passed
	on_timer = function(pos, elapsed)
		minetest.swap_node(pos, {name="mcl_core:stone_with_redstone"})
	end,
})

minetest.register_node("mcl_core:stone_with_lapis", {
	description = "Lapis Lazuli Ore",
	tiles = {"default_stone.png^default_mineral_lapis.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {cracky=2, building_block=1},
	drop = {
		max_items = 1,
		items = {
			{items = {'mcl_dye:blue 8'},rarity = 5},
			{items = {'mcl_dye:blue 7'},rarity = 5},
			{items = {'mcl_dye:blue 6'},rarity = 5},
			{items = {'mcl_dye:blue 5'},rarity = 5},
			{items = {'mcl_dye:blue 4'}},
		}
	},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:stone_with_emerald", {
	description = "Emerald Ore",
	tiles = {"default_stone.png^default_mineral_emerald.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {cracky=2, building_block=1},
	drop = "mcl_core:emerald",
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:stone_with_diamond", {
	description = "Diamond Ore",
	tiles = {"default_stone.png^default_mineral_diamond.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {cracky=1, building_block=1},
	drop = "mcl_core:diamond",
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:stonebrick", {
	description = "Stone Bricks",
	tiles = {"default_stone_brick.png"},
	stack_max = 64,
	groups = {cracky=3, stone=1, stonebrick=1, building_block=1, deco_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:stonebrickcarved", {
	description = "Chiseled Stone Bricks",
	tiles = {"default_stonebrick_carved.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {cracky=3, stone=1, stonebrick=1, building_block=1, deco_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:stonebrickcracked", {
	description = "Cracked Stone Bricks",
	tiles = {"default_stonebrick_cracked.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {cracky=3, stone=1, stonebrick=1, building_block=1, deco_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:stonebrickmossy", {
	description = "Mossy Stone Bricks",
	tiles = {"default_stonebrick_mossy.png"},
	stack_max = 64,
	groups = {cracky=3, stone=1, stonebrick=1, building_block=1, deco_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:granite", {
	description = "Granite",
	tiles = {"default_granite.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {cracky=3, stone=1, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:granite_smooth", {
	description = "Polished Granite",
	tiles = {"default_granite_smooth.png"},
	stack_max = 64,
	groups = {cracky=3, stone=1, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:andesite", {
	description = "Andesite",
	tiles = {"default_andesite.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {cracky=3, stone=1, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:andesite_smooth", {
	description = "Polished Andesite",
	tiles = {"default_andesite_smooth.png"},
	stack_max = 64,
	groups = {cracky=3, stone=1, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:diorite", {
	description = "Diorite",
	tiles = {"default_diorite.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {cracky=3, stone=1, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:diorite_smooth", {
	description = "Polished Diorite",
	tiles = {"default_diorite_smooth.png"},
	stack_max = 64,
	groups = {cracky=3, stone=1, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:dirt_with_grass", {
	description = "Grass Block",
	tiles = {"default_grass.png", "default_dirt.png", "default_dirt.png^default_grass_side.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {crumbly=3, soil=1, soil_sapling=2, soil_sugarcane=1, cultivatable=2, building_block=1},
	drop = 'mcl_core:dirt',
	sounds = mcl_core.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
})

minetest.register_node("mcl_core:grass_path", {
	tiles = {"mcl_core_grass_path_top.png", "mcl_core_grass_path_side.png"},
	description = "Grass Path",
	drop = "mcl_core:dirt",
	is_ground_content = true,
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			-- 15/16 of the normal height
			{-0.5, -0.5, -0.5, 0.5, 0.4375, 0.5},
		}
	},
	groups = { crumbly=3, not_in_creative_inventory=1, },
	sounds = mcl_core.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
})

-- TODO: Add particles
minetest.register_node("mcl_core:mycelium", {
	description = "Mycelium",
	tiles = {"default_mycelium_top.png", "default_dirt.png", "default_mycelium_side.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {crumbly=3, building_block=1},
	drop = 'mcl_core:dirt',
	sounds = mcl_core.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
})

minetest.register_node("mcl_core:podzol", {
	description = "Podzol",
	tiles = {"default_dirt_podzol_top.png", "default_dirt.png", "default_dirt_podzol_side.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {crumbly=3, soil=1, soil_sapling=2, soil_sugarcane=1, building_block=1},
	drop = 'mcl_core:dirt',
	sounds = mcl_core.node_sound_dirt_defaults(),
})

minetest.register_node("mcl_core:dirt", {
	description = "Dirt",
	tiles = {"default_dirt.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {crumbly=3, soil=1, soil_sapling=2, soil_sugarcane=1, cultivatable=2, building_block=1},
	sounds = mcl_core.node_sound_dirt_defaults(),
})

minetest.register_node("mcl_core:coarse_dirt", {
	description = "Coarse Dirt",
	tiles = {"default_coarse_dirt.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {crumbly=3, soil=1, soil_sugarcane=1, cultivatable=1, building_block=1},
	sounds = mcl_core.node_sound_dirt_defaults(),
})

minetest.register_node("mcl_core:gravel", {
	description = "Gravel",
	tiles = {"default_gravel.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {crumbly=2, falling_node=1, building_block=1},
	drop = {
		max_items = 1,
		items = {
			{items = {'mcl_core:flint'},rarity = 10},
			{items = {'mcl_core:gravel'}}
		}
	},
	sounds = mcl_core.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.45},
	}),
})

-- sandstone --
minetest.register_node("mcl_core:sand", {
	description = "Sand",
	tiles = {"default_sand.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {crumbly=3, falling_node=1, sand=1, soil_sugarcane=1, building_block=1},
	sounds = mcl_core.node_sound_sand_defaults(),
})

minetest.register_node("mcl_core:sandstone", {
	description = "Sandstone",
	tiles = {"default_sandstone_top.png", "default_sandstone_bottom.png", "default_sandstone_normal.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {crumbly=2,cracky=2,sandstone=1, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:sandstonesmooth", {
	description = "Smooth Sandstone",
	tiles = {"default_sandstone_top.png", "default_sandstone_bottom.png", "default_sandstone_smooth.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {crumbly=2,cracky=2,sandstone=1, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:sandstonecarved", {
	description = "Chiseled Sandstone",
	tiles = {"default_sandstone_top.png", "default_sandstone_bottom.png", "default_sandstone_carved.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {crumbly=2,cracky=2,sandstone=1, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

-- red sandstone --

minetest.register_node("mcl_core:redsand", {
	description = "Red Sand",
	tiles = {"default_red_sand.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {crumbly=3, falling_node=1, sand=1, soil_sugarcane=1, building_block=1},
	sounds = mcl_core.node_sound_sand_defaults(),
})

minetest.register_node("mcl_core:redsandstone", {
	description = "Red Sandstone",
	tiles = {"default_redsandstone_top.png", "default_redsandstone_bottom.png", "default_redsandstone_normal.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {crumbly=2,cracky=2,redsandstone=1, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:redsandstonesmooth", {
	description = "Smooth Red Sandstone",
	tiles = {"default_redsandstone_top.png", "default_redsandstone_bottom.png", "default_redsandstone_smooth.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {crumbly=2,cracky=2,redsandstone=1, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:redsandstonecarved", {
	description = "Chiseled Red Sandstone",
	tiles = {"default_redsandstone_top.png", "default_redsandstone_bottom.png", "default_redsandstone_carved.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {crumbly=2,cracky=2,redsandstone=1, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

---

minetest.register_node("mcl_core:clay", {
	-- Original name: Clay
	description = "Block of Clay",
	tiles = {"default_clay.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {crumbly=3, building_block=1},
	drop = 'mcl_core:clay_lump 4',
	sounds = mcl_core.node_sound_dirt_defaults({
		footstep = "",
	}),
})

minetest.register_node("mcl_core:brick_block", {
	-- Original name: “Bricks”
	description = "Brick Block",
	tiles = {"default_brick.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {cracky=3, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:haybale", {
	description = "Hay Bale",
	tiles = {"default_hayblock_top.png", "default_hayblock_top.png", "default_hayblock_side.png"},
	is_ground_content = false,
	stack_max = 64,
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = minetest.rotate_node,
	groups = {oddly_breakable_by_hand=3,flammable=2, building_block=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_core:bone_block", {
	description = "Bone Block",
	tiles = {"mcl_core_bone_block_top.png", "mcl_core_bone_block_top.png", "mcl_core_bone_block_side.png"},
	is_ground_content = false,
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
	groups = {cracky=2, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:sea_lantern", {
	description = "Sea Lantern",
	paramtype2 = "facedir",
	is_ground_content = false,
	stack_max = 64,
	-- Real light level: 15 (but Minetest caps at 14)
	light_source = 14,
	drop = {
		max_items = 1,
		items = {
			{ items = {'mcl_core:prismarine_cry 3'}, rarity = 2 },
			{ items = {'mcl_core:prismarine_cry 2'}}
		}
	},
	tiles = {{name="default_sea_lantern.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=1.25}}},
	groups = {oddly_breakable_by_hand=3, building_block=1},
	sounds = mcl_core.node_sound_glass_defaults(),
})

minetest.register_node("mcl_core:prismarine", {
	description = "Prismarine",
	stack_max = 64,
	is_ground_content = false,
	tiles = {{name="default_prismarine_anim.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=45.0}}},
	groups = {cracky=3, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:prismarine_brick", {
	description = "Prismarine Bricks",
	stack_max = 64,
	is_ground_content = false,
	tiles = {"default_prismarine_bricks.png"},
	groups = {cracky=2, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:prismarine_dark", {
	description = "Dark Prismarine",
	stack_max = 64,
	is_ground_content = false,
	tiles = {"default_prismarine_dark.png"},
	groups = {cracky=2, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})




-- Oak tree --
minetest.register_node("mcl_core:tree", {
	description = "Oak Wood",
	tiles = {"default_tree_top.png", "default_tree_top.png", "default_tree.png"},
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
	stack_max = 64,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2, building_block=1},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_node("mcl_core:sapling", {
	description = "Oak Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_sapling.png"},
	inventory_image = "default_sapling.png",
	wield_image = "default_sapling.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	stack_max = 64,
	groups = {snappy=2,dig_immediate=3,attached_node=1,dig_by_water=1,deco_block=1},
	sounds = mcl_core.node_sound_defaults(),
})

minetest.register_node("mcl_core:leaves", {
	description = "Oak Leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_leaves.png"},
	paramtype = "light",
	stack_max = 64,
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1, deco_block=1},
	drop = {
		max_items = 1,
		items = {
			{
				-- player will get sapling with 1/20 chance
				items = {'mcl_core:sapling'},
				rarity = 20,
			},
			{
				-- player will get apple with 1/200 chance
				items = {'mcl_core:apple'},
				rarity = 200,
			},
		}
	},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

-- Dark oak tree --
minetest.register_node("mcl_core:darktree", {
	description = "Dark Oak Wood",
	tiles = {"default_log_big_oak_top.png", "default_log_big_oak_top.png", "default_log_big_oak.png"},
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
	stack_max = 64,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2,building_block=1},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_node("mcl_core:darksapling", {
	description = "Dark Oak Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_sapling_big_oak.png"},
	inventory_image = "default_sapling_big_oak.png",
	wield_image = "default_sapling_big_oak.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	stack_max = 64,
	groups = {snappy=2,dig_immediate=3,attached_node=1,dig_by_water=1,deco_block=1},
	sounds = mcl_core.node_sound_defaults(),
})

minetest.register_node("mcl_core:darkleaves", {
	description = "Dark Oak Leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_leaves_big_oak.png"},
	paramtype = "light",
	stack_max = 64,
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1, deco_block=1},
	drop = {
		max_items = 1,
		items = {
			{
				-- player will get sapling with 1/20 chance
				items = {'mcl_core:darksapling'},
				rarity = 20,
			},
			{
				-- player will get apple with 1/200 chance
				items = {'mcl_core:apple'},
				rarity = 200,
			},
		}
	},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

-- Jungle Tree --

minetest.register_node("mcl_core:jungletree", {
	description = "Jungle Wood",
	tiles = {"default_jungletree_top.png", "default_jungletree_top.png", "default_jungletree.png"},
	stack_max = 64,
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2,building_block=1},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_node("mcl_core:junglewood", {
	description = "Jungle Wood Planks",
	tiles = {"default_junglewood.png"},
	stack_max = 64,
	is_ground_content = false,
	groups = {choppy=2,oddly_breakable_by_hand=2,flammable=3,wood=1,building_block=1},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_node("mcl_core:jungleleaves", {
	description = "Jungle Leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_jungleleaves.png"},
	paramtype = "light",
	stack_max = 64,
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1, deco_block=1},
	drop = {
		max_items = 1,
		items = {
			{
				items = {'mcl_core:junglesapling'},
				rarity = 40,
			},
		}
	},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_core:junglesapling", {
	description = "Jungle Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_junglesapling.png"},
	inventory_image = "default_junglesapling.png",
	wield_image = "default_junglesapling.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	stack_max = 64,
	groups = {snappy=2,dig_immediate=3,attached_node=1,dig_by_water=1,deco_block=1},
	sounds = mcl_core.node_sound_defaults(),
})


-- Accacia Tree --

minetest.register_node("mcl_core:acaciatree", {
	description = "Acacia Wood",
	tiles = {"default_acaciatree_top.png", "default_acaciatree_top.png", "default_acaciatree.png"},
	stack_max = 64,
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2,building_block=1},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_node("mcl_core:acaciawood", {
	description = "Acacia Wood Planks",
	tiles = {"default_acaciawood.png"},
	stack_max = 64,
	is_ground_content = false,
	groups = {choppy=2,oddly_breakable_by_hand=2,flammable=3,wood=1,building_block=1},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_node("mcl_core:acacialeaves", {
	description = "Acacia Leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_acacialeaves.png"},
	paramtype = "light",
	stack_max = 64,
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1, deco_block=1},
	drop = {
		max_items = 1,
		items = {
			{
				items = {'mcl_core:acaciasapling'},
				rarity = 20,
			},
		}
	},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_core:acaciasapling", {
	description = "Acacia Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_acaciasapling.png"},
	inventory_image = "default_acaciasapling.png",
	wield_image = "default_acaciasapling.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	stack_max = 64,
	groups = {snappy=2,dig_immediate=3,attached_node=1,dig_by_water=1,deco_block=1},
	sounds = mcl_core.node_sound_defaults(),
})

-- Spruce Tree --

minetest.register_node("mcl_core:sprucetree", {
	description = "Spruce Wood",
	tiles = {"default_sprucetree_top.png", "default_sprucetree_top.png", "default_sprucetree.png"},
	stack_max = 64,
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2,building_block=1},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_node("mcl_core:sprucewood", {
	description = "Spruce Wood Planks",
	tiles = {"default_sprucewood.png"},
	stack_max = 64,
	is_ground_content = false,
	groups = {choppy=2,oddly_breakable_by_hand=2,flammable=3,wood=1,building_block=1},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_node("mcl_core:spruceleaves", {
	description = "Spruce Leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_spruceleaves.png"},
	paramtype = "light",
	stack_max = 64,
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1, deco_block=1},
	drop = {
		max_items = 1,
		items = {
			{
				-- player will get sapling with 1/20 chance
				items = {'mcl_core:sprucesapling'},
				rarity = 20,
			},
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {''},
			}
		}
	},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_core:sprucesapling", {
	description = "Spruce Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_sprucesapling.png"},
	inventory_image = "default_sprucesapling.png",
	wield_image = "default_sprucesapling.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	stack_max = 64,
	groups = {snappy=2,dig_immediate=3,attached_node=1,dig_by_water=1,deco_block=1},
	sounds = mcl_core.node_sound_defaults(),
})

minetest.register_node("mcl_core:birchtree", {
	description = "Birch Wood",
	tiles = {"default_log_birch_top.png", "default_log_birch_top.png", "default_log_birch.png"},
	stack_max = 64,
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2,building_block=1},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_node("mcl_core:birchwood", {
	description = "Birch Wood Planks",
	tiles = {"default_planks_birch.png"},
	stack_max = 64,
	is_ground_content = false,
	groups = {choppy=2,oddly_breakable_by_hand=2,flammable=3,wood=1,building_block=1},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_node("mcl_core:birchleaves", {
	description = "Birch Leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"default_leaves_birch.png"},
	paramtype = "light",
	stack_max = 64,
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1, deco_block=1},
	drop = {
		max_items = 1,
		items = {
			{
				-- player will get sapling with 1/20 chance
				items = {'mcl_core:birchsapling'},
				rarity = 20,
			},
		}
	},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_core:birchsapling", {
	description = "Birch Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_sapling_birch.png"},
	inventory_image = "default_sapling_birch.png",
	wield_image = "default_sapling_birch.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	stack_max = 64,
	groups = {snappy=2,dig_immediate=3,attached_node=1,dig_by_water=1,deco_block=1},
	sounds = mcl_core.node_sound_defaults(),
})

minetest.register_node("mcl_core:junglegrass", {
	description = "Double Tallgrass",
	drawtype = "plantlike",
	visual_scale = 1.3,
	tiles = {"default_junglegrass.png"},
	inventory_image = "default_junglegrass.png",
	wield_image = "default_junglegrass.png",
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	is_ground_content = true,
	stack_max = 64,
	groups = {dig_immediate=3,flammable=2,attached_node=1,dig_by_water=1,deco_block=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
	},
	drop = {
		max_items = 1,
		items = {
			{
				items = {'mcl_farming:wheat_seed'},
				rarity = 8,
			},
		}
	},
})

minetest.register_node("mcl_core:cactus", {
	description = "Cactus",
	drawtype = "nodebox",
	tiles = {"default_cactus_top.png", "default_cactus_bottom.png", "default_cactus_side.png","default_cactus_side.png","default_cactus_side.png","default_cactus_side.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {oddly_breakable_by_hand=2,deco_block=1},
	sounds = mcl_core.node_sound_wood_defaults(),
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-7/16, -8/16, -7/16,  7/16, 8/16,  7/16}, -- Main Body
			{-8/16, -8/16, -7/16,  8/16, 8/16, -7/16}, -- Spikes
			{-8/16, -8/16,  7/16,  8/16, 8/16,  7/16}, -- Spikes
			{-7/16, -8/16, -8/16, -7/16, 8/16,  8/16}, -- Spikes
			{7/16,  -8/16,  8/16,  7/16, 8/16, -8/16}, -- Spikes
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-7/16, -8/16, -7/16, 7/16, 8/16, 7/16},
		},
	},
		
			
})

minetest.register_node("mcl_core:reeds", {
	description = "Sugar Canes",
	drawtype = "plantlike",
	tiles = {"default_papyrus.png"},
	inventory_image = "default_sugar_cane.png",
	wield_image = "default_sugar_cane.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-7/16, -8/16, -7/16,  7/16, 8/16,  7/16}, -- Main Body
			{-8/16, -8/16, -7/16,  8/16, 8/16, -7/16}, -- Spikes
			{-8/16, -8/16,  7/16,  8/16, 8/16,  7/16}, -- Spikes
			{-7/16, -8/16, -8/16, -7/16, 8/16,  8/16}, -- Spikes
			{7/16,  -8/16,  8/16,  7/16, 8/16, -8/16}, -- Spikes
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-7/16, -8/16, -7/16, 7/16, 8/16, 7/16},
		},
	},
	stack_max = 64,
	groups = {dig_immediate=3,craftitem=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})


minetest.register_node("mcl_core:quartz_ore", {
	description = "Nether Quartz Ore",
	stack_max = 64,
 	tiles = {"default_quartz_ore.png"},
	is_ground_content = false,
	groups = {cracky=3,building_block=1},
	drop = 'mcl_core:quartz_crystal',
	sounds = mcl_core.node_sound_stone_defaults(),
})
	 
minetest.register_node("mcl_core:quartz_block", {
	description = "Block of Quartz",
	stack_max = 64,
	tiles = {"default_quartz_block_top.png", "default_quartz_block_bottom.png", "default_quartz_block_side.png"},
	groups = {snappy=1,cracky=1,level=2,quartz_block=1,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:quartz_chiseled", {
	description = "Chiseled Quartz Block",
	stack_max = 64,
	is_ground_content = false,
	tiles = {"default_quartz_chiseled_top.png", "default_quartz_chiseled_top.png", "default_quartz_chiseled_side.png"},
	groups = {snappy=1,cracky=1,level=2,quartz_block=1,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:quartz_pillar", {
	description = "Pillar Quartz Block",
	stack_max = 64,
	paramtype2 = "facedir",
	is_ground_content = true,
	on_place = minetest.rotate_node,
	tiles = {"default_quartz_pillar_top.png", "default_quartz_pillar_top.png", "default_quartz_pillar_side.png"},
	groups = {snappy=1,cracky=1,level=2,quartz_block=1,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:bedrock", {
	description = "Bedrock",
	tiles = {"default_bedrock.png"},
	stack_max = 64,
	groups = {oddly_breakable_by_hand=5,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
	is_ground_content = false,
	on_blast = function() end,
	drop = '',
})

minetest.register_node("mcl_core:slimeblock", {
	description = "Slime Block",
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.25, -0.25, 0.25, 0.25, 0.25}, 
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		}
	},
	tiles = {"default_slimeblock.png"},
	paramtype = "light",
	use_texture_alpha = true,
	sunlight_propagates = true,
	stack_max = 64,
	-- According to Minecraft Wiki, bouncing off a slime block from a height off 255 blocks should result in a bounce height of 50 blocks
	-- bouncy=44 makes the player bounce up to 49.6. This value was chosen by experiment.
	groups = {oddly_breakable_by_hand=3,bouncy=44,fall_damage_add_percent=-100,deco_block=1},
})

minetest.register_node("mcl_core:glass", {
	description = "Glass",
	drawtype = "glasslike",
	is_ground_content = false,
	tiles = {"default_glass.png"},
	paramtype = "light",
	sunlight_propagates = true,
	stack_max = 64,
	groups = {cracky=3,oddly_breakable_by_hand=3,building_block=1},
	sounds = mcl_core.node_sound_glass_defaults(),
	drop = "",
})

---- colored glass
mcl_core.add_glass( "Red Stained Glass",  "basecolor_red", "red")
mcl_core.add_glass( "Green Stained Glass",  "unicolor_dark_green", "green")
mcl_core.add_glass( "Blue Stained Glass",  "basecolor_blue", "blue")
mcl_core.add_glass( "Light Blue Stained Glass",  "unicolor_light_blue", "light_blue")
mcl_core.add_glass( "Black Stained Glass",  "basecolor_black", "black")
mcl_core.add_glass( "White Stained Glass",  "basecolor_white", "white")
mcl_core.add_glass( "Yellow Stained Glass",  "basecolor_yellow", "yellow")
mcl_core.add_glass( "Brown Stained Glass",  "unicolor_dark_orange", "brown")
mcl_core.add_glass( "Orange Stained Glass",  "excolor_orange", "orange")
mcl_core.add_glass( "Pink Stained Glass",  "unicolor_light_red", "pink")
mcl_core.add_glass( "Gray Stained Glass",  "unicolor_darkgrey", "gray")
mcl_core.add_glass( "Lime Stained Glass",  "basecolor_green", "lime")
mcl_core.add_glass( "Light Gray Stained Glass",  "basecolor_grey", "silver")
mcl_core.add_glass( "Magenta Stained Glass",  "basecolor_magenta", "magenta")
mcl_core.add_glass( "Purple Stained Glass",  "excolor_violet", "purple")
mcl_core.add_glass( "Cyan Stained Glass",  "basecolor_cyan", "cyan")

minetest.register_node("mcl_core:rail", {
	description = "Rail",
	drawtype = "raillike",
	tiles = {"default_rail.png", "default_rail_curved.png", "default_rail_t_junction.png", "default_rail_crossing.png"},
	is_ground_content = false,
	inventory_image = "default_rail.png",
	wield_image = "default_rail.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
                -- but how to specify the dimensions for curved and sideways rails?
                fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	stack_max = 64,
	groups = {cracky=3,oddly_breakable_by_hand=3,attached_node=1,rail=1,connect_to_raillike=1,dig_by_water=1,transport=1},
	sounds = mcl_core.node_sound_defaults(),
})

minetest.register_node("mcl_core:ladder", {
	description = "Ladder",
	drawtype = "signlike",
	is_ground_content = false,
	tiles = {"default_ladder.png"},
	inventory_image = "default_ladder.png",
	wield_image = "default_ladder.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	climbable = true,
	selection_box = {
		type = "wallmounted",
		--wall_top = = <default>
		--wall_bottom = = <default>
		--wall_side = = <default>
	},
	stack_max = 64,
	groups = {choppy=2,oddly_breakable_by_hand=3,deco_block=1},
	sounds = mcl_core.node_sound_wood_defaults(),
})


minetest.register_node("mcl_core:vine", {
	description = "Vines",
	drawtype = "signlike",
	tiles = {"default_vine.png"},
	inventory_image = "default_vine.png",
	wield_image = "default_vine.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	climbable = true,
	selection_box = {
		type = "wallmounted",
	},
	stack_max = 64,
	groups = {choppy=2,oddly_breakable_by_hand=3,flammable=2,deco_block=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
	drop = "",
	after_dig_node = function(pos, oldnode, oldmetadata, user)
	local item = user:get_wielded_item()
		if item:get_name() == "mcl_core:shears" then 
			user:get_inventory():add_item("main", ItemStack(oldnode.name))
		end
		local next_find = true
		local ptr = 1
		while next_find == true do 
			local pos2 = {x=pos.x, y=pos.y-ptr, z=pos.z}
			local node = minetest.get_node(pos2)
			if node.name == "mcl_core:vine" and check_attached_node(pos2, node) == false then
				drop_attached_node(pos2)
				core.check_for_falling(pos2)
				ptr = ptr + 1
			else
				next_find = false
			end
		end
	end
})



minetest.register_node("mcl_core:wood", {
	description = "Oak Wood Planks",
	tiles = {"default_wood.png"},
	stack_max = 64,
	is_ground_content = false,
	groups = {choppy=2,oddly_breakable_by_hand=2,flammable=3,wood=1,building_block=1},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_node("mcl_core:darkwood", {
	description = "Dark Oak Wood Planks",
	tiles = {"default_planks_big_oak.png"},
	stack_max = 64,
	is_ground_content = false,
	groups = {choppy=2,oddly_breakable_by_hand=2,flammable=3,wood=1,building_block=1},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_node("mcl_core:water_flowing", {
	description = "Flowing Water",
	inventory_image = minetest.inventorycube("default_water.png"),
	drawtype = "flowingliquid",
	tiles = {name="default_water_flowing_animated.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=2.0}},
	special_tiles = {
		{
			image="default_water_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=64, aspect_h=64, length=2.0}
		},
		{
			image="default_water_flowing_animated.png",
			backface_culling=true,
			animation={type="vertical_frames", aspect_w=64, aspect_h=64, length=2.0}
		},
	},
	alpha = WATER_ALPHA,
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 4,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mcl_core:water_flowing",
	liquid_alternative_source = "mcl_core:water_source",
	liquid_viscosity = WATER_VISC,
	liquid_range = 7,
	freezemelt = "mcl_core:snow",
	post_effect_color = {a=64, r=100, g=100, b=200},
	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1, freezes=1, melt_around=1},
})

minetest.register_node("mcl_core:water_source", {
	description = "Still Water",
	inventory_image = minetest.inventorycube("default_water.png"),
	drawtype = "liquid",
	tiles = {
		{name="default_water_source_animated.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=5.0}}
	},
	special_tiles = {
		-- New-style water source material (mostly unused)
		{
			name="default_water_source_animated.png",
			animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=5.0},
			backface_culling = false,
		}
	},
	alpha = WATER_ALPHA,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 4,
	liquidtype = "source",
	liquid_alternative_flowing = "mcl_core:water_flowing",
	liquid_alternative_source = "mcl_core:water_source",
	liquid_viscosity = WATER_VISC,
	liquid_range = 7,
	freezemelt = "mcl_core:ice",
	post_effect_color = {a=64, r=100, g=100, b=200},
	stack_max = 64,
	groups = {water=3, liquid=3, puts_out_fire=1, freezes=1, not_in_creative_inventory=1},
})

minetest.register_node("mcl_core:lava_flowing", {
	description = "Flowing Lava",
	inventory_image = minetest.inventorycube("default_lava.png"),
	drawtype = "flowingliquid",
	tiles = {"default_lava.png"},
	special_tiles = {
		{
			image="default_lava_flowing_animated.png",
			backface_culling=false,
			animation={type="vertical_frames", aspect_w=64, aspect_h=64, length=3.3}
		},
		{
			image="default_lava_flowing_animated.png",
			backface_culling=true,
			animation={type="vertical_frames", aspect_w=64, aspect_h=64, length=3.3}
		},
	},
	paramtype = "light",
	paramtype2 = "flowingliquid",
	-- Real light level: 15 (but Minetest caps at 14)
	light_source = 14,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	--[[ Drowning in Minecraft deals 2 damage per second.
	In Minetest, drowning damage is dealt every 2 seconds so this
	translates to 4 drowning damage ]]
	drowning = 4,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mcl_core:lava_flowing",
	liquid_alternative_source = "mcl_core:lava_source",
	liquid_viscosity = LAVA_VISC,
	liquid_renewable = false,
	liquid_range = 4,
	damage_per_second = 4*2,
	post_effect_color = {a=192, r=255, g=64, b=0},
	groups = {lava=3, liquid=2, igniter=3, not_in_creative_inventory=1},
})

minetest.register_node("mcl_core:lava_source", {
	description = "Still Lava",
	inventory_image = minetest.inventorycube("default_lava.png"),
	drawtype = "liquid",
	tiles = {
		{name="default_lava_source_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}}
	},
	special_tiles = {
		-- New-style lava source material (mostly unused)
		{
			name="default_lava_source_animated.png",
			animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=3.0},
			backface_culling = false,
		}
	},
	paramtype = "light",
	-- Real light level: 15 (but Minetest caps at 14)
	light_source = 14,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 4,
	liquidtype = "source",
	liquid_alternative_flowing = "mcl_core:lava_flowing",
	liquid_alternative_source = "mcl_core:lava_source",
	liquid_viscosity = LAVA_VISC,
	liquid_renewable = false,
	liquid_range = 4,
	damage_per_second = 4*2,
	post_effect_color = {a=192, r=255, g=64, b=0},
	stack_max = 64,
	groups = {lava=3, liquid=2, igniter=3, not_in_creative_inventory=1},
})

minetest.register_node("mcl_core:cobble", {
	description = "Cobblestone",
	tiles = {"default_cobble.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {cracky=3, stone=2, building_block=1, deco_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:mossycobble", {
	description = "Moss Stone",
	tiles = {"default_mossycobble.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {cracky=3, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:coalblock", {
	description = "Block of Coal",
	tiles = {"default_coal_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {cracky=2, flammable=1, building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:steelblock", {
	description = "Block of Iron",
	tiles = {"default_steel_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {cracky=1,level=2,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:goldblock", {
	description = "Block of Gold",
	tiles = {"default_gold_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {cracky=1,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:diamondblock", {
	description = "Block of Diamond",
	tiles = {"default_diamond_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {cracky=1,level=3,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:lapisblock", {
	description = "Lapis Lazul Block",
	tiles = {"default_lapis_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {cracky=1,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:emeraldblock", {
	description = "Block of Emerald",
	tiles = {"default_emerald_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {cracky=1,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_core:obsidian", {
	description = "Obsidian",
	tiles = {"default_obsidian.png"},
	is_ground_content = true,
	sounds = mcl_core.node_sound_stone_defaults(),
	stack_max = 64,
	groups = {cracky=4,level=2,oddly_breakable_by_hand=4,building_block=1},
})

minetest.register_node("mcl_core:dry_shrub", {
	description = "Dead Bush",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"default_dry_shrub.png"},
	inventory_image = "default_dry_shrub.png",
	wield_image = "default_dry_shrub.png",
	paramtype = "light",
	walkable = false,
	stack_max = 64,
	groups = {dig_immediate=3,flammable=3,attached_node=1,dig_by_water=1,deco_block=1},
	drop = {
		max_items = 1,
		items = {
			{
				items = {"mcl_core:stick 2"},
				rarity = 2,
			},
			{
				items = {"mcl_core:stick 1"},
				rarity = 2,
			},
		}
	},
	sounds = mcl_core.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-1/3, -1/2, -1/3, 1/3, 1/6, 1/3},
	},
})

minetest.register_node("mcl_core:grass", {
	description = "Tall Grass",
	drawtype = "plantlike",
	tiles = {"default_tallgrass.png"},
	inventory_image = "default_tallgrass.png",
	wield_image = "default_tallgrass.png",
	drop = {
		max_items = 1,
		items = {
			{
				items = {'mcl_farming:wheat_seed'},
				rarity = 8,
			},
		}
	},
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	is_ground_content = true,
	groups = {snappy=3,flammable=3,attached_node=1,dig_immediate=3,dig_by_water=1,deco_block=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
	after_dig_node = function(pos, oldnode, oldmetadata, user)
	local item = user:get_wielded_item()
		if item:get_name() == "mcl_core:shears" then 
			user:get_inventory():add_item("main", ItemStack(oldnode.name))
		end
	end
})

minetest.register_node("mcl_core:glowstone", {
	description = "Glowstone",
	tiles = {"default_glowstone.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {oddly_breakable_by_hand=3,building_block=1},
	drop = {
	max_items = 1,
	items = {
			{items = {'mcl_core:glowdust 4'},rarity = 3},
			{items = {'mcl_core:glowdust 3'},rarity = 3},
			{items = {'mcl_core:glowdust 2'}},
		}
	},
	-- Real light level: 15 (but Minetest caps at 14)
	light_source = 14,
	sounds = mcl_core.node_sound_glass_defaults(),
})

minetest.register_node("mcl_core:sponge", {
	description = "Sponge",
	drawtype = "normal",
	is_ground_content = false,
	tiles = {"default_sponge.png"},
	paramtype = 'light',
	walkable = true,
	pointable = true,
	diggable = true,
	buildable_to = false,
	stack_max = 64,
	sounds = mcl_core.node_sound_dirt_defaults(),
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=3,building_block=1},
	   	on_place = function(itemstack, placer, pointed_thing)
		local pn = placer:get_player_name()
		if pointed_thing.type ~= "node" then
			return itemstack
		end
		if minetest.is_protected(pointed_thing.above, pn) then
			return itemstack
		end
			local change = false
			local on_water = false
			local pos = pointed_thing.above
		-- verifier si il est dans l'eau ou a cotée
		if string.find(minetest.get_node(pointed_thing.above).name, "water_source") 
		or  string.find(minetest.get_node(pointed_thing.above).name, "water_flowing") then
			on_water = true
		end
		for i=-1,1 do
			local p = {x=pos.x+i, y=pos.y, z=pos.z}
			local n = minetest.get_node(p)
			-- On verifie si il y a de l'eau
			if (n.name=="mcl_core:water_flowing") or (n.name == "mcl_core:water_source") then
				on_water = true
			end
		end
		for i=-1,1 do
			local p = {x=pos.x, y=pos.y+i, z=pos.z}
			local n = minetest.get_node(p)
			-- On verifie si il y a de l'eau
			if (n.name=="mcl_core:water_flowing") or (n.name == "mcl_core:water_source") then
				on_water = true
			end
		end
		for i=-1,1 do
			local p = {x=pos.x, y=pos.y, z=pos.z+i}
			local n = minetest.get_node(p)
			-- On verifie si il y a de l'eau
			if (n.name=="mcl_core:water_flowing") or (n.name == "mcl_core:water_source") then
				on_water = true
			end
		end
			local p, n
			if on_water == true then
				for i=-3,3 do
					for j=-3,3 do
						for k=-3,3 do
							p = {x=pos.x+i, y=pos.y+j, z=pos.z+k}
							n = minetest.get_node(p)
							-- On Supprime l'eau
							if (n.name=="mcl_core:water_flowing") or (n.name == "mcl_core:water_source")then
								minetest.add_node(p, {name="air"})
								change = true
							end
						end
					end
				end
			end
			p = {x=pos.x, y=pos.y, z=pos.z}
			n = minetest.get_node(p)
			if change == true then
				minetest.add_node(pointed_thing.above, {name = "mcl_core:sponge_wet"})	
			else
				minetest.add_node(pointed_thing.above, {name = "mcl_core:sponge"})	
			end
		return itemstack
		
	end
})

minetest.register_node("mcl_core:sponge_wet", {
	description = "Wet Sponge",
	drawtype = "normal",
	is_ground_content = false,
	tiles = {"default_sponge_wet.png"},
	paramtype = 'light',
	walkable = true,
	pointable = true,
	diggable = true,
	buildable_to = false,
	stack_max = 64,
	sounds = mcl_core.node_sound_dirt_defaults(),
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=3,building_block=1},
})


minetest.register_node("mcl_core:ice", {
	description = "Ice",
	drawtype = "glasslike",
	tiles = {"default_ice.png"},
	is_ground_content = true,
	paramtype = "light",
	use_texture_alpha = true,
	stack_max = 64,
	groups = {cracky=3,oddly_breakable_by_hand=2,building_block=1},
	drop = "",
	sounds = mcl_core.node_sound_glass_defaults(),
})

minetest.register_node("mcl_core:packed_ice", {
	description = "Packed Ice",
	drawtype = "glasslike",
	tiles = {"default_ice_packed.png"},
	is_ground_content = true,
	paramtype = "light",
	use_texture_alpha = true,
	stack_max = 64,
	groups = {cracky=3,oddly_breakable_by_hand=2,building_block=1},
	drop = "",
	sounds = mcl_core.node_sound_glass_defaults(),
})

-- Frosted Ice (4 nodes)
for i=0,3 do
	local ice = {}
	ice.increase_age = function(pos, ice_near, first_melt)
		-- Increase age of frosted age or turn to water source if too old
		local nn = minetest.get_node(pos).name
		local age = tonumber(string.sub(nn, -1))
		if age == nil then return end
		local nextnode
		if age < 3 then
			nextnode = "mcl_core:frosted_ice_"..(age+1)
		else
			nextnode = "mcl_core:water_source"
		end
		minetest.swap_node(pos, { name = nextnode })
		-- Spread aging to neighbor blocks, but not recursively
		if first_melt and i == 3 then
			for j=1, #ice_near do
				ice.increase_age(ice_near[j], false)
			end
		end
	end
	minetest.register_node("mcl_core:frosted_ice_"..i, {
		description = "Frosted Ice",
		drawtype = "glasslike",
		tiles = {"default_frosted_ice_"..i..".png"},
		is_ground_content = false,
		paramtype = "light",
		use_texture_alpha = true,
		stack_max = 64,
		groups = {cracky=2, frosted_ice=1, not_in_creative_inventory=1},
		drop = "",
		sounds = mcl_core.node_sound_glass_defaults(),
		on_construct = function(pos)
			local timer = minetest.get_node_timer(pos)
			timer:start(1.5)
		end,
		on_timer = function(pos, elapsed)
			local ice_near = minetest.find_nodes_in_area(
				{ x = pos.x - 1, y = pos.y - 1, z = pos.z - 1 },
				{ x = pos.x + 1, y = pos.y + 1, z = pos.z + 1 },
				{ "group:frosted_ice" }
			)
			-- Check condition to increase age
			if (#ice_near < 4 and minetest.get_node_light(pos) > (11 - i)) or math.random(1, 3) == 1 then
				ice.increase_age(pos, ice_near, true)
			end
			local timer = minetest.get_node_timer(pos)
			timer:start(1.5)
		end,
	})
end

minetest.register_node("mcl_core:snow", {
	description = "Top Snow",
	tiles = {"default_snow.png"},
	is_ground_content = true,
	paramtype = "light",
	buildable_to = true,
	drawtype = "nodebox",
	stack_max = 16,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5,  0.5, -0.5+2/16, 0.5},
		},
	},
	groups = {crumbly=3,falling_node=1,deco_block=1},
	sounds = mcl_core.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
	drop = "mcl_throwing:snowball 2",
})

minetest.register_node("mcl_core:snowblock", {
	description = "Snow",
	tiles = {"default_snow.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {crumbly=3,building_block=1},
	sounds = mcl_core.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
	drop = "mcl_throwing:snowball 4",
})

minetest.register_node("mcl_core:cobweb", {
       description = "Cobweb",
       drawtype = "plantlike",
	paramtype2 = "degrotate",
       visual_scale = 1.1,
	   stack_max = 64,
       tiles = {"web.png"},
       inventory_image = "web.png",
       paramtype = "light",
       sunlight_propagates = true,
       liquid_viscosity = 14,
       liquidtype = "source",
       liquid_alternative_flowing = "mcl_core:cobweb",
       liquid_alternative_source = "mcl_core:cobweb",
       liquid_renewable = false,
       liquid_range = 0,
       walkable = false,
       groups = {snappy=1,liquid=3,deco_block=1},
       drop = "mcl_mobitems:string",
})

