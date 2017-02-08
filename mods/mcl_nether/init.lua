minetest.register_node("mcl_nether:glowstone", {
	description = "Glowstone",
	tiles = {"mcl_nether_glowstone.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {oddly_breakable_by_hand=3,building_block=1},
	drop = {
	max_items = 1,
	items = {
			{items = {'mcl_nether:glowstone_dust 4'},rarity = 3},
			{items = {'mcl_nether:glowstone_dust 3'},rarity = 3},
			{items = {'mcl_nether:glowstone_dust 2'}},
		}
	},
	-- Real light level: 15 (but Minetest caps at 14)
	light_source = 14,
	sounds = mcl_core.node_sound_glass_defaults(),
})

minetest.register_node("mcl_nether:quartz_ore", {
	description = "Nether Quartz Ore",
	stack_max = 64,
	tiles = {"mcl_nether_quartz_ore.png"},
	is_ground_content = true,
	groups = {cracky=2,building_block=1},
	drop = 'mcl_nether:quartz',
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_nether:netherrack", {
	description = "Netherrack",
	stack_max = 64,
	tiles = {"mcl_nether_netherrack.png"},
	is_ground_content = true,
	groups = {cracky=3,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_nether:nether_brick", {
	-- Original name: Nether Brick
	description = "Nether Brick Block",
	stack_max = 64,
	tiles = {"mcl_nether_nether_brick.png"},
	is_ground_content = false,
	groups = {cracky=2,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_nether:red_nether_brick", {
	-- Original name: Red Nether Brick
	description = "Red Nether Brick Block",
	stack_max = 64,
	tiles = {"mcl_nether_red_nether_brick.png"},
	is_ground_content = false,
	groups = {cracky=2,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})


minetest.register_node("mcl_nether:nether_wart_block", {
	description = "Nether Wart Block",
	stack_max = 64,
	tiles = {"mcl_nether_nether_wart_block.png"},
	is_ground_content = false,
	groups = {oddly_breakable_by_hand=3,building_block=1},
	sounds = mcl_core.node_sound_leaves_defaults(
		{
			footstep={name="default_dirt_footstep", gain=0.7},
			dug={name="default_dirt_footstep", gain=1.5},
		}
	),
})

minetest.register_node("mcl_nether:quartz_block", {
	description = "Block of Quartz",
	stack_max = 64,
	is_ground_content = false,
	tiles = {"mcl_nether_quartz_block_top.png", "mcl_nether_quartz_block_bottom.png", "mcl_nether_quartz_block_side.png"},
	groups = {cracky=3,quartz_block=1,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_nether:quartz_chiseled", {
	description = "Chiseled Quartz Block",
	stack_max = 64,
	is_ground_content = false,
	tiles = {"mcl_nether_quartz_chiseled_top.png", "mcl_nether_quartz_chiseled_top.png", "mcl_nether_quartz_chiseled_side.png"},
	groups = {cracky=3,quartz_block=1,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_nether:quartz_pillar", {
	description = "Pillar Quartz Block",
	stack_max = 64,
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = minetest.rotate_node,
	tiles = {"mcl_nether_quartz_pillar_top.png", "mcl_nether_quartz_pillar_top.png", "mcl_nether_quartz_pillar_side.png"},
	groups = {cracky=3,quartz_block=1,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})



minetest.register_craftitem("mcl_nether:glowstone_dust", {
	description = "Glowstone Dust",
	inventory_image = "mcl_nether_glowstone_dust.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_nether:quartz", {
	description = "Nether Quartz",
	inventory_image = "mcl_nether_quartz.png",
	stack_max = 64,
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_nether:netherbrick", {
	description = "Nether Brick",
	inventory_image = "mcl_nether_netherbrick.png",
	stack_max = 64,
	groups = { craftitem = 1 },
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_nether:quartz",
	recipe = "mcl_nether:quartz_ore",
	cooktime = 10,
})

minetest.register_craft({
	output = 'mcl_nether:quartz_block',
	recipe = {
		{'mcl_nether:quartz', 'mcl_nether:quartz'},
		{'mcl_nether:quartz', 'mcl_nether:quartz'},
	}
})

minetest.register_craft({
	output = 'mcl_nether:quartz_chiseled 2',
	recipe = {
		{'stairs:slab_quartzblock'},
		{'stairs:slab_quartzblock'},
	}
})

minetest.register_craft({
	output = 'mcl_nether:quartz_pillar 2',
	recipe = {
		{'mcl_nether:quartz_block'},
		{'mcl_nether:quartz_block'},
	}
})

minetest.register_craft({
	output = "mcl_nether:glowstone",
	recipe = {
		{'mcl_nether:glowstone_dust', 'mcl_nether:glowstone_dust'},
		{'mcl_nether:glowstone_dust', 'mcl_nether:glowstone_dust'},
	}
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_nether:netherbrick",
	recipe = "mcl_nether:netherrack",
	cooktime = 10,
})

minetest.register_craft({
	output = "mcl_nether:nether_brick",
	recipe = {
		{'mcl_nether:netherbrick', 'mcl_nether:netherbrick'},
		{'mcl_nether:netherbrick', 'mcl_nether:netherbrick'},
	}
})

minetest.register_craft({
	output = "mcl_nether:red_nether_brick",
	recipe = {
		{'mcl_nether:nether_wart', 'mcl_nether:netherbrick'},
		{'mcl_nether:netherbrick', 'mcl_nether:nether_wart'},
	}
})
minetest.register_craft({
	output = "mcl_nether:red_nether_brick",
	recipe = {
		{'mcl_nether:netherbrick', 'mcl_nether:nether_wart'},
		{'mcl_nether:nether_wart', 'mcl_nether:netherbrick'},
	}
})

minetest.register_craft({
	output = "mcl_nether:nether_wart_block",
	recipe = {
		{'mcl_nether:nether_wart', 'mcl_nether:nether_wart', 'mcl_nether:nether_wart'},
		{'mcl_nether:nether_wart', 'mcl_nether:nether_wart', 'mcl_nether:nether_wart'},
		{'mcl_nether:nether_wart', 'mcl_nether:nether_wart', 'mcl_nether:nether_wart'},
	}
})

