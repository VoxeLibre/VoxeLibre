--[[ Doors ]]

local wood_longdesc = "Wooden doors are 2-block high barriers which can be opened or closed by hand and by a redstone signal."
local wood_usagehelp = "To open or close a wooden door, rightclick it or supply its lower half with a redstone signal."

--- Oak Door ---
mcl_doors:register_door("mcl_doors:wooden_door", {
	description = "Oak Door",
	_doc_items_longdesc = wood_longdesc,
	_doc_items_usagehelp = wood_usagehelp,
	inventory_image = "doors_item_wood.png",
	groups = {handy=1,axey=1, material_wood=1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 15,
	tiles_bottom = {"mcl_doors_door_wood_lower.png", "mcl_doors_door_wood_side_lower.png"},
	tiles_top = {"mcl_doors_door_wood_upper.png", "mcl_doors_door_wood_side_upper.png"},
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
	inventory_image = "mcl_doors_door_acacia.png",
	groups = {handy=1,axey=1, material_wood=1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 15,
	tiles_bottom = {"mcl_doors_door_acacia_lower.png", "mcl_doors_door_acacia_side_lower.png"},
	tiles_top = {"mcl_doors_door_acacia_upper.png", "mcl_doors_door_acacia_side_upper.png"},
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
	inventory_image = "mcl_doors_door_birch.png",
	groups = {handy=1,axey=1, material_wood=1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 15,
	tiles_bottom = {"mcl_doors_door_birch_lower.png", "mcl_doors_door_birch_side_lower.png"},
	tiles_top = {"mcl_doors_door_birch_upper.png", "mcl_doors_door_birch_side_upper.png"},
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
	inventory_image = "mcl_doors_door_dark_oak.png",
	groups = {handy=1,axey=1, material_wood=1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 15,
	tiles_bottom = {"mcl_doors_door_dark_oak_lower.png", "mcl_doors_door_dark_oak_side_lower.png"},
	tiles_top = {"mcl_doors_door_dark_oak_upper.png", "mcl_doors_door_dark_oak_side_upper.png"},
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
	inventory_image = "mcl_doors_door_jungle.png",
	groups = {handy=1,axey=1, material_wood=1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 15,
	tiles_bottom = {"mcl_doors_door_jungle_lower.png", "mcl_doors_door_jungle_side_lower.png"},
	tiles_top = {"mcl_doors_door_jungle_upper.png", "mcl_doors_door_jungle_side_upper.png"},
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
	inventory_image = "mcl_doors_door_spruce.png",
	groups = {handy=1,axey=1, material_wood=1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 15,
	tiles_bottom = {"mcl_doors_door_spruce_lower.png", "mcl_doors_door_spruce_side_lower.png"},
	tiles_top = {"mcl_doors_door_spruce_upper.png", "mcl_doors_door_spruce_side_upper.png"},
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
	inventory_image = "doors_item_steel.png",
	groups = {pickaxey=1, mesecon_effector_on=1},
	_mcl_hardness = 5,
	_mcl_blast_resistance = 25,
	tiles_bottom = {"mcl_doors_door_iron_lower.png^[transformFX", "mcl_doors_door_iron_side_lower.png"},
	tiles_top = {"mcl_doors_door_iron_upper.png^[transformFX", "mcl_doors_door_iron_side_upper.png"},
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
local woods = {
	-- id, desc, texture, craftitem
	{ "trapdoor", "Oak Trapdoor", "doors_trapdoor.png", "mcl_core:wood" },
	{ "acacia_trapdoor", "Acacia Trapdoor", "mcl_doors_trapdoor_acacia.png", "mcl_core:acaciawood" },
	{ "birch_trapdoor", "Birch Trapdoor", "mcl_doors_trapdoor_birch.png", "mcl_core:birchwood" },
	{ "spruce_trapdoor", "Spruce Trapdoor", "mcl_doors_trapdoor_spruce.png", "mcl_core:sprucewood" },
	{ "dark_oak_trapdoor", "Dark Oak Trapdoor", "mcl_doors_trapdoor_dark_oak.png", "mcl_core:darkwood" },
	{ "jungle_trapdoor", "Jungle Trapdoor", "mcl_doors_trapdoor_jungle.png", "mcl_core:junglewood" },
}

for w=1, #woods do
	mcl_doors:register_trapdoor("mcl_doors:"..woods[w][1], {
		description = woods[w][2],
		_doc_items_longdesc = "Wooden trapdoors are horizontal barriers which can be opened and closed by hand or a redstone signal. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder.",
		_doc_items_usagehelp = "To open or close the trapdoor, rightclick it or send a redstone signal to it.",
		tile_front = woods[w][3],
		tile_side = woods[w][3],
		wield_image = woods[w][3],
		groups = {handy=1,axey=1, mesecon_effector_on=1, material_wood=1},
		_mcl_hardness = 3,
		_mcl_blast_resistance = 15,
		sounds = mcl_sounds.node_sound_wood_defaults(),
	})

	minetest.register_craft({
		output = "mcl_doors:"..woods[w][1].." 2",
		recipe = {
			{woods[w][4], woods[w][4], woods[w][4]},
			{woods[w][4], woods[w][4], woods[w][4]},
		}
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "mcl_doors:"..woods[w][1],
		burntime = 15,
	})
end

mcl_doors:register_trapdoor("mcl_doors:iron_trapdoor", {
	description = "Iron Trapdoor",
	_doc_items_longdesc = "Iron trapdoors are horizontal barriers which can only be opened and closed by redstone signals, but not by hand. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder.",
	tile_front = "doors_trapdoor_steel.png",
	tile_side = "doors_trapdoor_steel.png",
	wield_image = "doors_trapdoor_steel.png",
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
