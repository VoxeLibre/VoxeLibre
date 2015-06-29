minetest.register_node("farming:mushroom_brown", {
	description = "Brown Mushroom",
	drawtype = "plantlike",
	tiles = { "farming_mushroom_brown.png" },
	inventory_image = "farming_mushroom_brown.png",
	wield_image = "farming_mushroom_brown.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {snappy=3,flammable=2,mushroom=1,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.015, 0.15 },
	},
})

minetest.register_node("farming:mushroom_red", {
	description = "Red Mushroom",
	drawtype = "plantlike",
	tiles = { "farming_mushroom_red.png" },
	inventory_image = "farming_mushroom_red.png",
	wield_image = "farming_mushroom_red.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {snappy=3,flammable=2,mushroom=1,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -0.15, -0.5, -0.15, 0.15, 0.015, 0.15 },
	},
})

minetest.register_craftitem("farming:mushroom_stew", {
	description = "Mushroom Stew",
    inventory_image = "farming_mushroom_stew.png",
	on_use = minetest.item_eat(6),
	stack_max = 64,
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:mushroom_stew",
	recipe = {'default:bowl', 'farming:mushroom_brown', 'farming:mushroom_red'}
})