minetest.register_node("mcl_farming:mushroom_brown", {
	description = "Brown Mushroom",
	drawtype = "plantlike",
	tiles = { "farming_mushroom_brown.png" },
	inventory_image = "farming_mushroom_brown.png",
	wield_image = "farming_mushroom_brown.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3,mushroom=1,attached_node=1,dig_by_water=1,deco_block=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
	light_source = 1,
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.015, 0.15 },
	},
})

minetest.register_node("mcl_farming:mushroom_red", {
	description = "Red Mushroom",
	drawtype = "plantlike",
	tiles = { "farming_mushroom_red.png" },
	inventory_image = "farming_mushroom_red.png",
	wield_image = "farming_mushroom_red.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3,mushroom=1,attached_node=1,dig_by_water=1,deco_block=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.015, 0.15 },
	},
})

minetest.register_craftitem("mcl_farming:mushroom_stew", {
	description = "Mushroom Stew",
	inventory_image = "farming_mushroom_stew.png",
	on_use = minetest.item_eat(6, "mcl_core:bowl"),
	groups = { food = 2, eatable = 6 },
	stack_max = 1,
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_farming:mushroom_stew",
	recipe = {'mcl_core:bowl', 'mcl_farming:mushroom_brown', 'mcl_farming:mushroom_red'}
})
