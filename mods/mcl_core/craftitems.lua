-- mods/default/craftitems.lua

--
-- Crafting items
--

minetest.register_craftitem("mcl_core:stick", {
	description = "Stick",
	inventory_image = "default_stick.png",
	stack_max = 64,
	groups = { craftitem=1, stick=1 },
})

minetest.register_craftitem("mcl_core:paper", {
	description = "Paper",
	inventory_image = "default_paper.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:coal_lump", {
	description = "Coal",
	groups = { coal=1 },
	inventory_image = "default_coal_lump.png",
	stack_max = 64,
	groups = { craftitem=1, coal=1 },
})

minetest.register_craftitem("mcl_core:charcoal_lump", {
	description = "Charcoal",
	groups = { coal=1 },
	inventory_image = "default_charcoal_lump.png",
	stack_max = 64,
	groups = { craftitem=1, coal=1 },
})

minetest.register_craftitem("mcl_core:iron_nugget", {
	description = "Iron Nugget",
	inventory_image = "default_iron_nugget.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:gold_nugget", {
	description = "Gold Nugget",
	inventory_image = "default_gold_nugget.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:diamond", {
	description = "Diamond",
	inventory_image = "default_diamond.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:clay_lump", {
	description = "Clay",
	inventory_image = "default_clay_lump.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:steel_ingot", {
	description = "Iron Ingot",
	inventory_image = "default_steel_ingot.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:gold_ingot", {
	description = "Gold Ingot",
	inventory_image = "default_gold_ingot.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:emerald", {
	description = "Emerald",
	inventory_image = "default_emerald.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:brick", {
	description = "Brick",
	inventory_image = "default_clay_brick.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:flint", {
	description = "Flint",
	inventory_image = "default_flint.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:gunpowder", {
	description = "Gunpowder",
	inventory_image = "default_gunpowder.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:glowstone_dust", {
	description = "Glowstone Dust",
	inventory_image = "default_glowstone_dust.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_core:sugar", {
	description = "Sugar",
	inventory_image = "default_sugar.png",
	stack_max = 64,
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_core:bowl",{
	description = "Bowl",
	inventory_image = "default_bowl.png",
	stack_max = 64,
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_core:prismarine_crystals", {
	description = "Prismarine Crystals",
	inventory_image = "default_prismarine_crystals.png",
	stack_max = 64,
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_core:prismarine_shard", {
	description = "Prismarine Shard",
	inventory_image = "default_prismarine_shard.png",
	stack_max = 64,
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_core:quartz_crystal", {
	description = "Nether Quartz",
	inventory_image = "default_quartz_crystal.png",
	stack_max = 64,
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_core:apple", {
	description = "Apple",
	wield_image = "default_apple.png",
	inventory_image = "default_apple.png",
	stack_max = 64,
	on_use = minetest.item_eat(4),
	groups = { food = 2 },
})

minetest.register_craftitem("mcl_core:apple_gold", {
	description = core.colorize("#55FFFF", "Golden Apple"),
	wield_image = "default_apple_gold.png",
	inventory_image = "default_apple_gold.png",
	stack_max = 64,
	on_use = minetest.item_eat(8),
	groups = { food = 2 },
})

minetest.register_alias("mcl_core:iron_ingot", "mcl_core:steel_ingot")
