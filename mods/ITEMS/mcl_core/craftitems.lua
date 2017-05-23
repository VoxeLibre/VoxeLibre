-- mods/default/craftitems.lua

--
-- Crafting items
--

minetest.register_craftitem("mcl_core:stick", {
	description = "Stick",
	_doc_items_longdesc = "Sticks are a very versatile crafting material; used in countless crafting recipes.",
	_doc_items_hidden = false,
	inventory_image = "default_stick.png",
	stack_max = 64,
	groups = { craftitem=1, stick=1 },
})

minetest.register_craftitem("mcl_core:paper", {
	description = "Paper",
	_doc_items_longdesc = "Paper is used to craft books and maps.",
	inventory_image = "default_paper.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:coal_lump", {
	description = "Coal",
	_doc_items_longdesc = "“Coal” refers to coal lumps obtained by digging coal ore which can be found underground. Coal is your standard furnace fuel, but it can also be used to make torches, coal blocks and a few other things.",
	_doc_items_hidden = false,
	groups = { coal=1 },
	inventory_image = "default_coal_lump.png",
	stack_max = 64,
	groups = { craftitem=1, coal=1 },
})

minetest.register_craftitem("mcl_core:charcoal_lump", {
	description = "Charcoal",
	_doc_items_longdesc = "Charcoal is an alternative furnace fuel created by cooking wood in a furnace. It has the same burning time as coal and also shares many of its crafting recipes, but it can not be used to create coal blocks.",
	_doc_items_hidden = false,
	groups = { coal=1 },
	inventory_image = "default_charcoal_lump.png",
	stack_max = 64,
	groups = { craftitem=1, coal=1 },
})

minetest.register_craftitem("mcl_core:iron_nugget", {
	description = "Iron Nugget",
	_doc_items_longdesc = "Iron nuggets are very small pieces of molten iron; the main purpose is to create iron ingots.",
	inventory_image = "default_iron_nugget.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:gold_nugget", {
	description = "Gold Nugget",
	_doc_items_longdesc = "Gold nuggets are very small pieces of molten gold; the main purpose is to create gold ingots.",
	inventory_image = "default_gold_nugget.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:diamond", {
	description = "Diamond",
	_doc_items_longdesc = "Diamonds are precious minerals and useful to create the highest tier of armor and tools.",
	inventory_image = "default_diamond.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:clay_lump", {
	description = "Clay",
	_doc_items_longdesc = "Clay is a raw material.",
	_doc_items_hidden = false,
	inventory_image = "default_clay_lump.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:iron_ingot", {
	description = "Iron Ingot",
	_doc_items_longdesc = "Molten iron. It is used to craft armor, tools, and whatnot.",
	inventory_image = "default_steel_ingot.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:gold_ingot", {
	description = "Gold Ingot",
	_doc_items_longdesc = "Molten gold. It is used to craft armor, tools, and whatnot.",
	inventory_image = "default_gold_ingot.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:emerald", {
	description = "Emerald",
	_doc_items_longdesc = "Emeralds are not very useful on their own, but many villagers have a love for emeralds and often use it as a currency in trading.",
	inventory_image = "default_emerald.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:brick", {
	description = "Brick",
	_doc_items_longdesc = "Bricks are used to craft brick blocks.",
	inventory_image = "default_clay_brick.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:flint", {
	description = "Flint",
	_doc_items_longdesc = "Flint is a raw material.",
	inventory_image = "default_flint.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:sugar", {
	description = "Sugar",
	_doc_items_longdesc = "Sugar comes from sugar canes and is used to make sweet foods.",
	inventory_image = "default_sugar.png",
	stack_max = 64,
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_core:bowl",{
	description = "Bowl",
	_doc_items_longdesc = "Bowls are mainly used to hold tasty soups.",
	inventory_image = "default_bowl.png",
	stack_max = 64,
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_core:apple", {
	description = "Apple",
	_doc_items_longdesc = "Apples are food items which can be eaten.",
	wield_image = "default_apple.png",
	inventory_image = "default_apple.png",
	stack_max = 64,
	on_place = minetest.item_eat(4),
	on_secondary_use = minetest.item_eat(4),
	groups = { food = 2, eatable = 4 },
	_mcl_saturation = 2.4,
})

-- TODO: Status effects
minetest.register_craftitem("mcl_core:apple_gold", {
	description = core.colorize("#55FFFF", "Golden Apple"),
	_doc_items_longdesc = "Golden apples are precious food items which can be eaten.",
	wield_image = "default_apple_gold.png",
	inventory_image = "default_apple_gold.png",
	stack_max = 64,
	-- TODO: Reduce to 4 when it's ready
	on_place = minetest.item_eat(8),
	on_secondary_use = minetest.item_eat(8),
	groups = { food = 2, eatable = 8, can_eat_when_full = 1 },
	_mcl_saturation = 9.6,
})
