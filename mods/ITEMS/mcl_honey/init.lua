---------------
---- Honey ----
---------------

-- Variables
local S = minetest.get_translator(minetest.get_current_modname())

-- Honeycomb
minetest.register_craftitem("mcl_honey:honeycomb", {
	description = S("Honeycomb"),
	_doc_items_longdesc = S("Used to craft beehives and protect copper blocks from further oxidation."),
	_doc_items_usagehelp = S("Use on copper blocks to prevent further oxidation."),
	inventory_image = "mcl_honey_honeycomb.png",
	groups = { craftitem = 1 },
})

minetest.register_node("mcl_honey:honeycomb_block", {
	description = S("Honeycomb Block"),
	_doc_items_longdesc = S("Honeycomb Block. Used as a decoration."),
	tiles = {
		"mcl_honey_honeycomb_block.png"
	},
	groups = { handy = 1, deco_block = 1 },
	_mcl_blast_resistance = 0.6,
	_mcl_hardness = 0.6,
})

-- Honey
minetest.register_craftitem("mcl_honey:honey_bottle", {
	description = S("Honey Bottle"),
	_doc_items_longdesc = S("Honey Bottle is used to craft honey blocks and to restore hunger points."),
	_doc_items_usagehelp = S("Drinking will restore 6 hunger points. Can also be used to craft honey blocks."),
	inventory_image = "mcl_honey_honey_bottle.png",
	groups = { craftitem = 1, food = 3, eatable = 6, can_eat_when_full=1 },
	on_place = minetest.item_eat(6, "mcl_potions:glass_bottle"),
	on_secondary_use = minetest.item_eat(6, "mcl_potions:glass_bottle"),
	_mcl_saturation = 1.2,
	stack_max = 16,
})

minetest.register_node("mcl_honey:honey_block", {
	description = S("Honey Block"),
	_doc_items_longdesc = S("Honey Block. Used as a decoration and in redstone. Is sticky on some sides."),
	tiles = {
		"mcl_honey_block_top.png", "mcl_honey_block_bottom.png",
		"mcl_honey_block_side.png", "mcl_honey_block_side.png",
		"mcl_honey_block_side.png", "mcl_honey_block_side.png",
	},
	groups = { handy = 1, deco_block = 1 },
	paramtype2 = "facedir",
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
})

-- Crafting
minetest.register_craft({
	output = "mcl_honey:honeycomb_block",
	recipe = {
		{ "mcl_honey:honeycomb", "mcl_honey:honeycomb" },
		{ "mcl_honey:honeycomb", "mcl_honey:honeycomb" },
	},
})

minetest.register_craft({
	output = "mcl_honey:honey_block",
	recipe = {
		{ "mcl_honey:honey_bottle", "mcl_honey:honey_bottle" },
		{ "mcl_honey:honey_bottle", "mcl_honey:honey_bottle" },
	},
	replacements = {
		{ "mcl_honey:honey_bottle", "mcl_potions:glass_bottle" },
		{ "mcl_honey:honey_bottle", "mcl_potions:glass_bottle" },
		{ "mcl_honey:honey_bottle", "mcl_potions:glass_bottle" },
		{ "mcl_honey:honey_bottle", "mcl_potions:glass_bottle" },
	},
})

minetest.register_craft({
	output = "mcl_honey:honey_bottle 4",
	recipe = {
		{ "mcl_potions:glass_bottle", "mcl_potions:glass_bottle", "mcl_honey:honey_block" },
		{ "mcl_potions:glass_bottle", "mcl_potions:glass_bottle", "" },
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_core:sugar 3",
	recipe = { "mcl_honey:honey_bottle" },
	replacements = {
		{ "mcl_honey:honey_bottle", "mcl_potions:glass_bottle" },
	},
})
