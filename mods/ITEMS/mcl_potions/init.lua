minetest.register_craftitem("mcl_potions:fermented_spider_eye", {
	description = "Fermented Spider Eye",
	wield_image = "mcl_potions_spider_eye_fermented.png",
	inventory_image = "mcl_potions_spider_eye_fermented.png",
	groups = { brewitem = 1 },
	stack_max = 64,
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_potions:fermented_spider_eye",
	recipe = { "mcl_farming:mushroom_brown", "mcl_core:sugar", "mcl_mobitems:spider_eye" },
})

minetest.register_craftitem("mcl_potions:glass_bottle", {
	description = "Glass Bottle",
	inventory_image = "vessels_glass_bottle_inv.png",
	wield_image = "vessels_glass_bottle_inv.png",
	groups = {brewitem=1},
})

minetest.register_craft( {
	output = "mcl_potions:glass_bottle 3",
	recipe = {
		{ "mcl_core:glass", "", "mcl_core:glass" },
		{ "", "mcl_core:glass", "" }
	}
})

minetest.register_craftitem("mcl_potions:speckled_melon", {
	description = "Glistering Melon",
	stack_max = 64,
	groups = { brewitem = 1 },
	inventory_image = "mcl_potions_melon_speckled.png",
})

minetest.register_craft({
	output = "mcl_potions:speckled_melon",
	recipe = {
		{'mcl_core:gold_nugget', 'mcl_core:gold_nugget', 'mcl_core:gold_nugget'},
		{'mcl_core:gold_nugget', 'mcl_farming:melon_item', 'mcl_core:gold_nugget'},
		{'mcl_core:gold_nugget', 'mcl_core:gold_nugget', 'mcl_core:gold_nugget'},
	}
})

minetest.register_craftitem("mcl_potions:dragon_breath", {
	description = "Dragon's Breath",
	wield_image = "mcl_potions_dragon_breath.png",
	inventory_image = "mcl_potions_dragon_breath.png",
	groups = { brewitem = 1 },
	stack_max = 64,
})
