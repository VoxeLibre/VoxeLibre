--MC Heads for minetest
--maikerumine

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

minetest.register_node( "mobs_mc:creeper_head", {
	description = S("Creeper Head (WIP)"),
	tiles = {
		"mobs_creeper_top.png",
		"mobs_creeper_top.png",  --was bottom
		"mobs_creeper_side.png",
		"mobs_creeper_side.png",
		"mobs_creeper_side.png", --was rear
		"mobs_creeper_front.png"
	},
	paramtype2 = "facedir",
			node_box = {
				type = "fixed",
				fixed = {-0.25, -0.5, -0.25, 0.25, 0.00, 0.25},
			},
			
	drawtype = "nodebox",
	paramtype = "light",
	visual_scale = 1.0,
	is_ground_content = false,
	groups = {cracky=2},
	--sounds = default.node_sound_stone_defaults(),
	stack_max = 1,
})

minetest.register_node( "mobs_mc:enderman_head", {
	description = S("Enderman Head (WIP)"),
	tiles = {
		"mobs_endermen_top.png",
		"mobs_endermen_top.png",
		"mobs_endermen_side.png",
		"mobs_endermen_side.png",
		"mobs_endermen_side.png",
		"mobs_endermen_front.png"
	},
	paramtype2 = "facedir",
			node_box = {
				type = "fixed",
				fixed = {-0.25, -0.5, -0.25, 0.25, 0.00, 0.25},
			},
			
	drawtype = "nodebox",
	paramtype = "light",
	visual_scale = 1.0,
	is_ground_content = true,
	groups = {cracky=2},
	--sounds = default.node_sound_stone_defaults(),
	stack_max = 1,
})

minetest.register_node( "mobs_mc:ghast_head", {
	description = S("Ghast Head (WIP)"),
	tiles = {
		"mobs_mc_ghast_white.png",
		"mobs_mc_ghast_white.png",
		"mobs_mc_ghast_white.png",
		"mobs_mc_ghast_white.png",
		"mobs_mc_ghast_white.png",
		"mobs_mc_ghast_front.png"
	},
	paramtype2 = "facedir",
			node_box = {
				type = "fixed",
				fixed = {-0.25, -0.5, -0.25, 0.25, 0.00, 0.25},
			},
			
	drawtype = "nodebox",
	paramtype = "light",
	visual_scale = 1.0,
	is_ground_content = true,
	groups = {cracky=2},
	--sounds = default.node_sound_stone_defaults(),
	stack_max = 1,
})

minetest.register_node( "mobs_mc:skeleton_head", {
	description = S("Skeleton Skull (WIP)"),
	tiles = {
		"mobs_skeleton_top.png",
		"mobs_skeleton_top.png",
		"mobs_skeleton_side.png",
		"mobs_skeleton_side.png",
		"mobs_skeleton_side.png",
		"mobs_skeleton_front.png"
	},
	paramtype2 = "facedir",
			node_box = {
				type = "fixed",
				fixed = {-0.25, -0.5, -0.25, 0.25, 0.00, 0.25},
			},
			
	drawtype = "nodebox",
	paramtype = "light",
	visual_scale = 1.0,
	is_ground_content = false,
	groups = {cracky=2},
	--sounds = default.node_sound_stone_defaults(),
	stack_max = 1,
})

minetest.register_node( "mobs_mc:skeleton2_head", {
	description = S("Wither Skeleton Skull (WIP)"),
	tiles = {
		"mobs_skeleton2_top.png",
		"mobs_skeleton2_top.png",
		"mobs_skeleton2_side.png",
		"mobs_skeleton2_side.png",
		"mobs_skeleton2_side.png",
		"mobs_skeleton2_front.png"
	},
	paramtype2 = "facedir",
			node_box = {
				type = "fixed",
				fixed = {-0.25, -0.5, -0.25, 0.25, 0.00, 0.25},
			},
			
	drawtype = "nodebox",
	paramtype = "light",
	visual_scale = 1.0,
	is_ground_content = true,
	groups = {cracky=2},
	--sounds = default.node_sound_stone_defaults(),
	stack_max = 1,
})

minetest.register_node( "mobs_mc:spider_head", {
	description = S("Spider Head (WIP)"),
	tiles = {
		"mobs_spider_top.png",
		"mobs_spider_top.png",
		"mobs_spider_side.png",
		"mobs_spider_side.png",
		"mobs_spider_side.png",
		"mobs_spider_front.png"
	},
	paramtype2 = "facedir",
			node_box = {
				type = "fixed",
				fixed = {-0.25, -0.5, -0.25, 0.25, 0.00, 0.25},
			},
			
	drawtype = "nodebox",
	paramtype = "light",
	visual_scale = 1.0,
	is_ground_content = true,
	groups = {cracky=2},
	--sounds = default.node_sound_stone_defaults(),
	stack_max = 1,
})

minetest.register_node( "mobs_mc:zombie_head", {
	description = S("Zombie Head (WIP)"),
	tiles = {
		"mobs_zombie_top.png",
		"mobs_zombie_top.png",
		"mobs_zombie_side.png",
		"mobs_zombie_side.png",
		"mobs_zombie_side.png",
		"mobs_zombie_front.png"
	},
	paramtype2 = "facedir",
			node_box = {
				type = "fixed",
				fixed = {-0.25, -0.5, -0.25, 0.25, 0.00, 0.25},
			},
			
	drawtype = "nodebox",
	paramtype = "light",
	visual_scale = 1.0,
	is_ground_content = true,
	groups = {cracky=2},
	--sounds = default.node_sound_stone_defaults(),
	stack_max = 1,
})

minetest.register_node( "mobs_mc:zombiepig_head", {
	description = S("Zombie Pigman Head (WIP)"),
	tiles = {
		"mobs_zombiepig_top.png",
		"mobs_zombiepig_top.png",
		"mobs_zombiepig_side.png",
		"mobs_zombiepig_side.png",
		"mobs_zombiepig_side.png",
		"mobs_zombiepig_front.png"
	},
	paramtype2 = "facedir",
			node_box = {
				type = "fixed",
				fixed = {-0.25, -0.5, -0.25, 0.25, 0.00, 0.25},
			},
			
	drawtype = "nodebox",
	paramtype = "light",
	visual_scale = 1.0,
	is_ground_content = true,
	groups = {cracky=2},
	--sounds = default.node_sound_stone_defaults(),
	stack_max = 1,
})

