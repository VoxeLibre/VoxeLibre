--[[ Doors ]]

local wood_longdesc = "Wooden doors are 2-block high barriers which can be opened or closed by hand and by a redstone signal."
local wood_usagehelp = "To open or close a wooden door, rightclick it or supply its lower half with a redstone signal."

--- Oak Door ---
mcl_doors:register_door("mcl_doors:wooden_door", {
	description = "Oak Door",
	_doc_items_longdesc = wood_longdesc,
	_doc_items_usagehelp = wood_usagehelp,
	inventory_image = "door_wood.png",
	groups = {handy=1,axey=1, material_wood=1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 15,
	tiles_bottom = {"door_wood_b.png", "door_wood_b.png"},
	tiles_top = {"door_wood_a.png", "door_wood_a.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mcl_doors:wooden_door 3",
	recipe = {
		{"mcl_core:wood", "mcl_core:wood"},
		{"mcl_core:wood", "mcl_core:wood"},
		{"mcl_core:wood", "mcl_core:wood"}
	}
})

--- Acacia Door --
mcl_doors:register_door("mcl_doors:acacia_door", {
	description = "Acacia Door",
	_doc_items_longdesc = wood_longdesc,
	_doc_items_usagehelp = wood_usagehelp,
	inventory_image = "door_acacia.png",
	groups = {handy=1,axey=1, material_wood=1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 15,
	tiles_bottom = {"door_acacia_b.png", "door_acacia_b.png"},
	tiles_top = {"door_acacia_a.png", "door_acacia_a.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mcl_doors:acacia_door 3",
	recipe = {
		{"mcl_core:acaciawood", "mcl_core:acaciawood"},
		{"mcl_core:acaciawood", "mcl_core:acaciawood"},
		{"mcl_core:acaciawood", "mcl_core:acaciawood"}
	}
})

--- Birch Door --
mcl_doors:register_door("mcl_doors:birch_door", {
	description = "Birch Door",
	_doc_items_longdesc = wood_longdesc,
	_doc_items_usagehelp = wood_usagehelp,
	inventory_image = "door_birch.png",
	groups = {handy=1,axey=1, material_wood=1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 15,
	tiles_bottom = {"door_birch_b.png", "door_birch_b.png"},
	tiles_top = {"door_birch_a.png", "door_birch_a.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mcl_doors:birch_door 3",
	recipe = {
		{"mcl_core:birchwood", "mcl_core:birchwood"},
		{"mcl_core:birchwood", "mcl_core:birchwood"},
		{"mcl_core:birchwood", "mcl_core:birchwood"},
	}
})

--- Dark Oak Door --
mcl_doors:register_door("mcl_doors:dark_oak_door", {
	description = "Dark Oak Door",
	_doc_items_longdesc = wood_longdesc,
	_doc_items_usagehelp = wood_usagehelp,
	inventory_image = "door_dark_oak.png",
	groups = {handy=1,axey=1, material_wood=1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 15,
	tiles_bottom = {"door_dark_oak_b.png", "door_dark_oak_b.png"},
	tiles_top = {"door_dark_oak_a.png", "door_dark_oak_a.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mcl_doors:dark_oak_door 3",
	recipe = {
		{"mcl_core:darkwood", "mcl_core:darkwood"},
		{"mcl_core:darkwood", "mcl_core:darkwood"},
		{"mcl_core:darkwood", "mcl_core:darkwood"},
	}
})

--- Jungle Door --
mcl_doors:register_door("mcl_doors:jungle_door", {
	description = "Jungle Door",
	_doc_items_longdesc = wood_longdesc,
	_doc_items_usagehelp = wood_usagehelp,
	inventory_image = "door_jungle.png",
	groups = {handy=1,axey=1, material_wood=1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 15,
	tiles_bottom = {"door_jungle_b.png", "door_jungle_b.png"},
	tiles_top = {"door_jungle_a.png", "door_jungle_a.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mcl_doors:jungle_door 3",
	recipe = {
		{"mcl_core:junglewood", "mcl_core:junglewood"},
		{"mcl_core:junglewood", "mcl_core:junglewood"},
		{"mcl_core:junglewood", "mcl_core:junglewood"}
	}
})

--- Spruce Door --
mcl_doors:register_door("mcl_doors:spruce_door", {
	description = "Spruce Door",
	_doc_items_longdesc = wood_longdesc,
	_doc_items_usagehelp = wood_usagehelp,
	inventory_image = "door_spruce.png",
	groups = {handy=1,axey=1, material_wood=1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 15,
	tiles_bottom = {"door_spruce_b.png", "door_spruce_b.png"},
	tiles_top = {"door_spruce_a.png", "door_spruce_a.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mcl_doors:spruce_door 3",
	recipe = {
		{"mcl_core:sprucewood", "mcl_core:sprucewood"},
		{"mcl_core:sprucewood", "mcl_core:sprucewood"},
		{"mcl_core:sprucewood", "mcl_core:sprucewood"}
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_doors:wooden_door",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_doors:jungle_door",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_doors:dark_oak_door",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_doors:birch_door",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_doors:acacia_door",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_doors:spruce_door",
	burntime = 10,
})

--- Iron Door ---
mcl_doors:register_door("mcl_doors:iron_door", {
	description = "Iron Door",
	_doc_items_longdesc = "Iron doors are 2-block high barriers which can only be opened or closed by a redstone signal, but not by hand.",
	_doc_items_usagehelp = "To open or close an iron door, supply its lower half with a redstone signal.",
	inventory_image = "door_steel.png",
	groups = {pickaxey=1, mesecon_effector_on=1},
	_mcl_hardness = 5,
	_mcl_blast_resistance = 25,
	tiles_bottom = {"door_steel_b.png^[transformFX", "door_steel_b.png^[transformFX"},
	tiles_top = {"door_steel_a.png^[transformFX", "door_steel_a.png^[transformFX"},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",

	only_redstone_can_open = true,
})

minetest.register_craft({
	output = "mcl_doors:iron_door 3",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"}
	}
})



--[[ Trapdoors ]]

mcl_doors:register_trapdoor("mcl_doors:trapdoor", {
	description = "Wooden Trapdoor",
	_doc_items_longdesc = "Wooden trapdoors are horizontal barriers which can be opened and closed by hand or a redstone signal. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder.",
	_doc_items_usagehelp = "To open or close the trapdoor, rightclick it or send a redstone signal to it.",
	tiles = {"door_trapdoor.png"},
	wield_image = "door_trapdoor.png",
	groups = {handy=1,axey=1, mesecon_effector_on=1, material_wood=1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 15,
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = 'mcl_doors:trapdoor 2',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_doors:trapdoor",
	burntime = 15,
})

mcl_doors:register_trapdoor("mcl_doors:iron_trapdoor", {
	description = "Iron Trapdoor",
	_doc_items_longdesc = "Iron trapdoors are horizontal barriers which can only be opened and closed by redstone signals, but not by hand. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder.",
	tiles = {"iron_trapdoor.png"},
	wield_image = "iron_trapdoor.png",
	groups = {pickaxey=1, mesecon_effector_on=1},
	_mcl_hardness = 5,
	_mcl_blast_resistance = 25,
	sounds = mcl_sounds.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",

	only_redstone_can_open = true,
})

minetest.register_craft({
	output = 'mcl_doors:iron_trapdoor',
	recipe = {
		{'mcl_core:iron_ingot', 'mcl_core:iron_ingot'},
		{'mcl_core:iron_ingot', 'mcl_core:iron_ingot'},
	}
})
