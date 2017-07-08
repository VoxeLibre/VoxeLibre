-- Simple solid cubic nodes, most of them are the ground materials and simple building blocks

minetest.register_node("mcl_core:stone", {
	description = "Stone",
	_doc_items_longdesc = "One of the most common blocks in the world, almost the entire underground consists of stone. It sometimes contains ores. Stone may be created when water meets lava.",
	_doc_items_hidden = false,
	tiles = {"default_stone.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	drop = 'mcl_core:cobble',
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:stone_with_coal", {
	description = "Coal Ore",
	_doc_items_longdesc = "Some coal contained in stone, it is very common and can be found inside stone in medium to large clusters at nearly every height.",
	_doc_items_hidden = false,
	tiles = {"mcl_core_coal_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	drop = 'mcl_core:coal_lump',
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 15,
	_mcl_hardness = 3,
})

minetest.register_node("mcl_core:stone_with_iron", {
	description = "Iron Ore",
	_doc_items_longdesc = "Some iron contained in stone, it is prety common and can be found below sea level.",
	tiles = {"mcl_core_iron_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=3, building_block=1, material_stone=1},
	drop = 'mcl_core:stone_with_iron',
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 15,
	_mcl_hardness = 3,
})


minetest.register_node("mcl_core:stone_with_gold", {
	description = "Gold Ore",
	_doc_items_longdesc = "This stone contains pure gold, a rare metal.",
	tiles = {"mcl_core_gold_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1, material_stone=1},
	drop = "mcl_core:stone_with_gold",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 15,
	_mcl_hardness = 3,
})

local redstone_timer = 68.28
local redstone_ore_activate = function(pos)
	minetest.swap_node(pos, {name="mcl_core:stone_with_redstone_lit"})
	local t = minetest.get_node_timer(pos)
	t:start(redstone_timer)
end
minetest.register_node("mcl_core:stone_with_redstone", {
	description = "Redstone Ore",
	_doc_items_longdesc = "Redstone ore is commonly found near the bottom of the world. It glows when it is punched or walked upon.",
	tiles = {"mcl_core_redstone_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1, material_stone=1},
	drop = {
		items = {
			max_items = 1,
			{
				items = {"mesecons:redstone 4"},
				rarity = 2,
			},
			{
				items = {"mesecons:redstone 5"},
			},
		}
	},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_punch = redstone_ore_activate,
	on_walk_over = redstone_ore_activate, -- Uses walkover mod
	_mcl_blast_resistance = 15,
	_mcl_hardness = 3,
})

local redstone_ore_reactivate = function(pos)
	local t = minetest.get_node_timer(pos)
	t:start(redstone_timer)
end
-- Light the redstone ore up when it has been touched
minetest.register_node("mcl_core:stone_with_redstone_lit", {
	description = "Lit Redstone Ore",
	_doc_items_create_entry = false,
	tiles = {"mcl_core_redstone_ore.png"},
	paramtype = "light",
	light_source = 9,
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=4, not_in_creative_inventory=1, material_stone=1},
	drop = {
		items = {
			max_items = 1,
			{
				items = {"mesecons:redstone 4"},
				rarity = 2,
			},
			{
				items = {"mesecons:redstone 5"},
			},
		}
	},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	-- Reset timer after re-punching or stepping on
	on_punch = redstone_ore_reactivate,
	on_walk_over = redstone_ore_reactivate, -- Uses walkover mod
	-- Turn back to normal node after some time has passed
	on_timer = function(pos, elapsed)
		minetest.swap_node(pos, {name="mcl_core:stone_with_redstone"})
	end,
	_mcl_blast_resistance = 15,
	_mcl_hardness = 3,
})

minetest.register_node("mcl_core:stone_with_lapis", {
	description = "Lapis Lazuli Ore",
	_doc_items_longdesc = "Lapis lazuli ore is the ore of lapis lazuli. It can be rarely found in clusters near the bottom of the world.",
	tiles = {"mcl_core_lapis_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=3, building_block=1, material_stone=1},
	drop = {
		max_items = 1,
		items = {
			{items = {'mcl_dye:blue 8'},rarity = 5},
			{items = {'mcl_dye:blue 7'},rarity = 5},
			{items = {'mcl_dye:blue 6'},rarity = 5},
			{items = {'mcl_dye:blue 5'},rarity = 5},
			{items = {'mcl_dye:blue 4'}},
		}
	},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 15,
	_mcl_hardness = 3,
})

minetest.register_node("mcl_core:stone_with_emerald", {
	description = "Emerald Ore",
	_doc_items_longdesc = "Emerald ore is the ore of emeralds. It is very rare and can be found alone, not in clusters.",
	tiles = {"mcl_core_emerald_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1, material_stone=1},
	drop = "mcl_core:emerald",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 15,
	_mcl_hardness = 3,
})

minetest.register_node("mcl_core:stone_with_diamond", {
	description = "Diamond Ore",
	_doc_items_longdesc = "Diamond ore is rare and can be found in clusters near the bottom of the world.",
	tiles = {"mcl_core_diamond_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1, material_stone=1},
	drop = "mcl_core:diamond",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 15,
	_mcl_hardness = 3,
})

minetest.register_node("mcl_core:stonebrick", {
	description = "Stone Bricks",
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"default_stone_brick.png"},
	stack_max = 64,
	groups = {pickaxey=1, stone=1, stonebrick=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	_mcl_blast_resistance = 30,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:stonebrickcarved", {
	description = "Chiseled Stone Bricks",
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_core_stonebrick_carved.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, stonebrick=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	_mcl_blast_resistance = 30,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:stonebrickcracked", {
	description = "Cracked Stone Bricks",
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_core_stonebrick_cracked.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, stonebrick=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	_mcl_blast_resistance = 30,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:stonebrickmossy", {
	description = "Mossy Stone Bricks",
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_core_stonebrick_mossy.png"},
	stack_max = 64,
	groups = {pickaxey=1, stone=1, stonebrick=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	_mcl_blast_resistance = 30,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:granite", {
	description = "Granite",
	_doc_items_longdesc = "Granite is an igneous rock.",
	tiles = {"mcl_core_granite.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:granite_smooth", {
	description = "Polished Granite",
	_doc_items_longdesc = "Polished granite is a decorational building block made from granite.",
	tiles = {"mcl_core_granite_smooth.png"},
	stack_max = 64,
	is_ground_content = false,
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:andesite", {
	description = "Andesite",
	_doc_items_longdesc = "Andesite is an igneous rock.",
	tiles = {"mcl_core_andesite.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:andesite_smooth", {
	description = "Polished Andesite",
	_doc_items_longdesc = "Polished andesite is a decorational building block made from andesite.",
	tiles = {"mcl_core_andesite_smooth.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:diorite", {
	description = "Diorite",
	_doc_items_longdesc = "Diorite is an igneous rock.",
	tiles = {"mcl_core_diorite.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:diorite_smooth", {
	description = "Polished Diorite",
	_doc_items_longdesc = "Polished diorite is a decorational building block made from diorite.",
	tiles = {"mcl_core_diorite_smooth.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:dirt_with_grass", {
	description = "Grass Block",
	_doc_items_longdesc = "A grass block is dirt with a grass cover. Grass blocks are resourceful blocks which allow the growth of all sorts of plants. They can be turned into farmland with a hoe and turned into grass paths with a shovel. In light, the grass slowly spreads onto dirt nearby. Under an opaque block or a liquid, a grass block may turn back to dirt.",
	_doc_items_hidden = false,
	tiles = {"default_grass.png", "default_dirt.png", "default_grass_side.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, soil=1, soil_sapling=2, soil_sugarcane=1, cultivatable=2, spreading_dirt_type=1, enderman_takable=1, building_block=1},
	drop = 'mcl_core:dirt',
	sounds = mcl_sounds.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 0.6,
})

-- NOTE: This block is to be considered equivalent to the grass block
minetest.register_node("mcl_core:dirt_with_grass_snow", {
	description = "Snowy Grass Block",
	_doc_items_create_entry = false,
	tiles = {"default_snow.png", "default_dirt.png", "mcl_core_grass_side_snowed.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, soil=1, soil_sapling=2, soil_sugarcane=1, cultivatable=2, building_block=1, not_in_creative_inventory=1},
	drop = 'mcl_core:dirt',
	sounds = mcl_sounds.node_sound_snow_defaults({
		dug = {name="default_dirt_footstep", gain=1.5},
		dig = {name="default_dig_crumbly", gain=1.0}
	}),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 0.6,
})

minetest.register_node("mcl_core:grass_path", {
	tiles = {"mcl_core_grass_path_top.png", "default_dirt.png", "mcl_core_grass_path_side.png"},
	description = "Grass Path",
	_doc_items_longdesc = "Grass paths are a decorational variant of grass blocks. Their top has a different color and they are a bit lower than grass blocks, making them useful to build footpaths. Grass paths can be created with a shovel. A grass path turns into dirt when it is below a solid block.",
	drop = "mcl_core:dirt",
	is_ground_content = true,
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			-- 15/16 of the normal height
			{-0.5, -0.5, -0.5, 0.5, 0.4375, 0.5},
		}
	},
	groups = {handy=1,shovely=1, cultivatable=2, dirtifies_below_solid=1, not_in_creative_inventory=1, },
	sounds = mcl_sounds.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
	_mcl_blast_resistance = 3.25,
	_mcl_hardness = 0.6,
})

-- TODO: Add particles
minetest.register_node("mcl_core:mycelium", {
	description = "Mycelium",
	_doc_items_longdesc = "Mycelium is a type of dirt and the ideal soil for mushrooms. Unlike other dirt-type blocks, it can not be turned into farmland with a hoe. In light, mycelium slowly spreads over nearby dirt. Under an opaque block or a liquid, it eventually turns back into dirt.",
	tiles = {"mcl_core_mycelium_top.png", "default_dirt.png", "mcl_core_mycelium_side.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, spreading_dirt_type=1, building_block=1},
	drop = 'mcl_core:dirt',
	sounds = mcl_sounds.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 0.6,
})

-- NOTE: This block is to be considered equivalent to mycelium
minetest.register_node("mcl_core:mycelium_snow", {
	description = "Snowy Mycelium",
	_doc_items_create_entry = false,
	-- CHECKME: Are the sides of snowy mycelium supposed to look like this?
	tiles = {"default_snow.png", "default_dirt.png", "mcl_core_grass_side_snowed.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, building_block=1, not_in_creative_inventory=1},
	drop = 'mcl_core:dirt',
	sounds = mcl_sounds.node_sound_snow_defaults({
		dug = {name="default_dirt_footstep", gain=1.5},
		dig = {name="default_dig_crumbly", gain=1.0}
	}),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 0.6,
})

minetest.register_node("mcl_core:podzol", {
	description = "Podzol",
	_doc_items_longdesc = "Podzol is a type of dirt found in taiga forests. Only a few plants are able to survive on it.",
	tiles = {"mcl_core_dirt_podzol_top.png", "default_dirt.png", "mcl_core_dirt_podzol_side.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=3, soil=1, soil_sapling=2, soil_sugarcane=1, enderman_takable=1, building_block=1},
	drop = 'mcl_core:dirt',
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 0.6,
})

-- NOTE: This block is to be considered equivalent to podzol
minetest.register_node("mcl_core:podzol_snow", {
	description = "Snowy Podzol",
	_doc_items_create_entry = false,
	tiles = {"default_snow.png", "default_dirt.png", "mcl_core_grass_side_snowed.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=3, soil=1, soil_sapling=2, soil_sugarcane=1, building_block=1, not_in_creative_inventory=1},
	drop = 'mcl_core:dirt',
	sounds = mcl_sounds.node_sound_snow_defaults({
		dug = {name="default_dirt_footstep", gain=1.5},
		dig = {name="default_dig_crumbly", gain=1.0}
	}),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 0.6,
})

minetest.register_node("mcl_core:dirt", {
	description = "Dirt",
	_doc_items_longdesc = "Dirt acts as a soil for a few plants. When in light, this block may grow a grass or mycelium cover if such blocks are nearby.",
	_doc_items_hidden = false,
	tiles = {"default_dirt.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, soil=1, soil_sapling=2, soil_sugarcane=1, cultivatable=2, enderman_takable=1, building_block=1},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 0.5,
})

minetest.register_node("mcl_core:coarse_dirt", {
	description = "Coarse Dirt",
	_doc_items_longdesc = "Coarse dirt acts as a soil for some plants and is similar to dirt, but it will never grow a cover.",
	tiles = {"mcl_core_coarse_dirt.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, soil=1, soil_sugarcane=1, cultivatable=1, enderman_takable=1, building_block=1},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 0.5,
})

minetest.register_node("mcl_core:gravel", {
	description = "Gravel",
	_doc_items_longdesc = "This block consists of a couple of loose stones and can't support itself.",
	tiles = {"default_gravel.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, falling_node=1, enderman_takable=1, building_block=1, material_sand=1},
	drop = {
		max_items = 1,
		items = {
			{items = {'mcl_core:flint'},rarity = 10},
			{items = {'mcl_core:gravel'}}
		}
	},
	sounds = mcl_sounds.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.45},
	}),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 0.6,
})

-- sandstone --
minetest.register_node("mcl_core:sand", {
	description = "Sand",
	_doc_items_longdesc = "Sand is found in large quantities at beaches and deserts.",
	_doc_items_hidden = false,
	tiles = {"default_sand.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, falling_node=1, sand=1, soil_sugarcane=1, enderman_takable=1, building_block=1, material_sand=1},
	sounds = mcl_sounds.node_sound_sand_defaults(),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 0.5,
})

minetest.register_node("mcl_core:sandstone", {
	description = "Sandstone",
	_doc_items_hidden = false,
	_doc_items_longdesc = "Sandstone is compressed sand and is a rather soft kind of stone.",
	tiles = {"mcl_core_sandstone_top.png", "mcl_core_sandstone_bottom.png", "mcl_core_sandstone_normal.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=2, sandstone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 4,
	_mcl_hardness = 0.8,
})

minetest.register_node("mcl_core:sandstonesmooth", {
	description = "Smooth Sandstone",
	_doc_items_longdesc = "Smooth sandstone is a decorational building block.",
	tiles = {"mcl_core_sandstone_top.png", "mcl_core_sandstone_bottom.png", "mcl_core_sandstone_smooth.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, sandstone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 4,
	_mcl_hardness = 0.8,
})

minetest.register_node("mcl_core:sandstonecarved", {
	description = "Chiseled Sandstone",
	_doc_items_longdesc = "Chiseled sandstone is a decorational building block.",
	tiles = {"mcl_core_sandstone_top.png", "mcl_core_sandstone_bottom.png", "mcl_core_sandstone_carved.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, sandstone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 4,
	_mcl_hardness = 0.8,
})

-- red sandstone --

minetest.register_node("mcl_core:redsand", {
	description = "Red Sand",
	_doc_items_longdesc = "Red sand is found in large quantities in mesa biomes.",
	tiles = {"mcl_core_red_sand.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, falling_node=1, sand=1, soil_sugarcane=1, enderman_takable=1, building_block=1, material_sand=1},
	sounds = mcl_sounds.node_sound_sand_defaults(),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 0.5,
})

minetest.register_node("mcl_core:redsandstone", {
	description = "Red Sandstone",
	_doc_items_longdesc = "Red sandstone is compressed red sand and is a rather soft kind of stone.",
	tiles = {"mcl_core_red_sandstone_top.png", "mcl_core_red_sandstone_bottom.png", "mcl_core_red_sandstone_normal.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, redsandstone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 4,
	_mcl_hardness = 0.8,
})

minetest.register_node("mcl_core:redsandstonesmooth", {
	description = "Smooth Red Sandstone",
	_doc_items_longdesc = "Smooth red sandstone is a decorational building block.",
	tiles = {"mcl_core_red_sandstone_top.png", "mcl_core_red_sandstone_bottom.png", "mcl_core_red_sandstone_smooth.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, redsandstone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 4,
	_mcl_hardness = 0.8,
})

minetest.register_node("mcl_core:redsandstonecarved", {
	description = "Chiseled Red Sandstone",
	_doc_items_longdesc = "Chiseled red sandstone is a decorational building block.",
	tiles = {"mcl_core_red_sandstone_top.png", "mcl_core_red_sandstone_bottom.png", "mcl_core_red_sandstone_carved.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, redsandstone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 4,
	_mcl_hardness = 0.8,
})

---

minetest.register_node("mcl_core:clay", {
	-- Original name: Clay
	description = "Block of Clay",
	_doc_items_longdesc = "A block of clay is a versatile kind of earth commonly found at beaches underwater.",
	_doc_items_hidden = false,
	tiles = {"default_clay.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, enderman_takable=1, building_block=1},
	drop = 'mcl_core:clay_lump 4',
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 0.6,
})

minetest.register_node("mcl_core:brick_block", {
	-- Original name: “Bricks”
	description = "Brick Block",
	_doc_items_longdesc = "Brick blocks are a good building material for building solid houses and can take quite a punch.",
	tiles = {"default_brick.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 2,
})


minetest.register_node("mcl_core:bedrock", {
	description = "Bedrock",
	_doc_items_longdesc = "Bedrock is a very hard type of rock. It can not be broken, destroyed, collected or moved by normal means, unless in Creative Mode.",
	tiles = {"mcl_core_bedrock.png"},
	stack_max = 64,
	groups = {creative_breakable=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	on_blast = function() end,
	drop = '',
	_mcl_blast_resistance = 18000000,
	_mcl_hardness = -1,
})

minetest.register_node("mcl_core:cobble", {
	description = "Cobblestone",
	_doc_items_longdesc = doc.sub.items.temp.build,
	_doc_items_hidden = false,
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_core:mossycobble", {
	description = "Moss Stone",
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"default_mossycobble.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_core:coalblock", {
	description = "Block of Coal",
	_doc_items_longdesc = "Blocks of coal are useful as a compact storage of coal and very useful as a furnace fuel. A block of coal is as efficient as 10 coal.",
	tiles = {"default_coal_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, flammable=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 5,
})

minetest.register_node("mcl_core:ironblock", {
	description = "Block of Iron",
	_doc_items_longdesc = "A block of iron is mostly a decorational block but also useful as a compact storage of iron ingots.",
	tiles = {"default_steel_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=2, building_block=1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 5,
})

minetest.register_node("mcl_core:goldblock", {
	description = "Block of Gold",
	_doc_items_longdesc = "A block of gold is mostly a shiny decorational block but also useful as a compact storage of gold ingots.",
	tiles = {"default_gold_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 5,
})

minetest.register_node("mcl_core:diamondblock", {
	description = "Block of Diamond",
	_doc_items_longdesc = "A block of diamond mostly a shiny decorational block but also useful as a compact storage of diamonds.",
	tiles = {"default_diamond_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 5,
})

minetest.register_node("mcl_core:lapisblock", {
	description = "Lapis Lazuli Block",
	_doc_items_longdesc = "A lapis lazuli block is mostly a decorational block but also useful as a compact storage of lapis lazuli.",
	tiles = {"mcl_core_lapis_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=3, building_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 15,
	_mcl_hardness = 3,
})

minetest.register_node("mcl_core:emeraldblock", {
	description = "Block of Emerald",
	_doc_items_longdesc = "A block of emerald is mostly a shiny decorational block but also useful as a compact storage of emeralds.",
	tiles = {"mcl_core_emerald_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 5,
})

minetest.register_node("mcl_core:obsidian", {
	description = "Obsidian",
	_doc_items_longdesc = "Obsidian is an extremely hard mineral with an enourmous blast-resistance. Obsidian is formed when water meets lava.",
	tiles = {"default_obsidian.png"},
	is_ground_content = true,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	stack_max = 64,
	groups = {pickaxey=5, building_block=1, material_stone=1},
	_mcl_blast_resistance = 6000,
	_mcl_hardness = 50,
})

minetest.register_node("mcl_core:ice", {
	description = "Ice",
	_doc_items_longdesc = "Ice is a translucent solid block usually found in cold areas.",
	drawtype = "glasslike",
	tiles = {"default_ice.png"},
	is_ground_content = true,
	paramtype = "light",
	use_texture_alpha = true,
	stack_max = 64,
	groups = {handy=1,pickaxey=1, building_block=1},
	drop = "",
	sounds = mcl_sounds.node_sound_glass_defaults(),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 0.5,
})

minetest.register_node("mcl_core:packed_ice", {
	description = "Packed Ice",
	_doc_items_longdesc = "Packed ice is a compressed form of ice. It is opaque and solid.",
	tiles = {"mcl_core_ice_packed.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,pickaxey=1, building_block=1},
	drop = "",
	sounds = mcl_sounds.node_sound_glass_defaults(),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 0.5,
})

-- Frosted Ice (4 nodes)
for i=0,3 do
	local ice = {}
	ice.increase_age = function(pos, ice_near, first_melt)
		-- Increase age of frosted age or turn to water source if too old
		local nn = minetest.get_node(pos).name
		local age = tonumber(string.sub(nn, -1))
		if age == nil then return end
		local nextnode
		if age < 3 then
			nextnode = "mcl_core:frosted_ice_"..(age+1)
		else
			nextnode = "mcl_core:water_source"
		end
		minetest.swap_node(pos, { name = nextnode })
		-- Spread aging to neighbor blocks, but not recursively
		if first_melt and i == 3 then
			for j=1, #ice_near do
				ice.increase_age(ice_near[j], false)
			end
		end
	end
	local use_doc = i == 0
	local longdesc
	if use_doc then
		longdesc = "Frosted ice is a short-lived solid translucent block. It melts into a water source within a few seconds."
	end
	minetest.register_node("mcl_core:frosted_ice_"..i, {
		description = "Frosted Ice",
		_doc_items_create_entry = use_doc,
		_doc_items_longdesc = longdesc,
		drawtype = "glasslike",
		tiles = {"mcl_core_frosted_ice_"..i..".png"},
		is_ground_content = false,
		paramtype = "light",
		use_texture_alpha = true,
		stack_max = 64,
		groups = {handy=1, frosted_ice=1, not_in_creative_inventory=1},
		drop = "",
		sounds = mcl_sounds.node_sound_glass_defaults(),
		on_construct = function(pos)
			local timer = minetest.get_node_timer(pos)
			timer:start(1.5)
		end,
		on_timer = function(pos, elapsed)
			local ice_near = minetest.find_nodes_in_area(
				{ x = pos.x - 1, y = pos.y - 1, z = pos.z - 1 },
				{ x = pos.x + 1, y = pos.y + 1, z = pos.z + 1 },
				{ "group:frosted_ice" }
			)
			-- Check condition to increase age
			if (#ice_near < 4 and minetest.get_node_light(pos) > (11 - i)) or math.random(1, 3) == 1 then
				ice.increase_age(pos, ice_near, true)
			end
			local timer = minetest.get_node_timer(pos)
			timer:start(1.5)
		end,
		_mcl_blast_resistance = 2.5,
		_mcl_hardness = 0.5,
	})

	-- Add entry aliases for the Help
	if minetest.get_modpath("doc") and i > 0 then
		doc.add_entry_alias("nodes", "mcl_core:frosted_ice_0", "nodes", "mcl_core:frosted_ice_"..i)
	end
end

local on_snow_construct = function(pos)
	local npos = {x=pos.x, y=pos.y-1, z=pos.z}
	local node = minetest.get_node(npos)
	if node.name == "mcl_core:dirt_with_grass" then
		minetest.swap_node(npos, {name="mcl_core:dirt_with_grass_snow"})
	elseif node.name == "mcl_core:podzol" then
		minetest.swap_node(npos, {name="mcl_core:podzol_snow"})
	elseif node.name == "mcl_core:mycelium" then
		minetest.swap_node(npos, {name="mcl_core:mycelium_snow"})
	end
end
local clear_snow_dirt = function(pos, node)
	if node.name == "mcl_core:dirt_with_grass_snow" then
		minetest.swap_node(pos, {name="mcl_core:dirt_with_grass"})
	elseif node.name == "mcl_core:podzol_snow" then
		minetest.swap_node(pos, {name="mcl_core:podzol"})
	elseif node.name == "mcl_core:mycelium_snow" then
		minetest.swap_node(pos, {name="mcl_core:mycelium"})
	end

end
local after_snow_destruct = function(pos)
	local nn = minetest.get_node(pos).name
	-- No-op if snow was replaced with snow
	if nn == "mcl_core:snow" or nn == "mcl_core:snowblock" then
		return
	end
	local npos = {x=pos.x, y=pos.y-1, z=pos.z}
	local node = minetest.get_node(npos)
	clear_snow_dirt(npos, node)
end

minetest.register_node("mcl_core:snow", {
	description = "Top Snow",
	_doc_items_longdesc = "Top snow is a thin layer of snow.",
	_doc_items_hidden = false,
	tiles = {"default_snow.png"},
	wield_image = "default_snow.png",
	wield_scale = { x=1, y=1, z=1 },
	is_ground_content = true,
	paramtype = "light",
	sunlight_propagates = true,
	buildable_to = true,
	drawtype = "nodebox",
	stack_max = 64,
	floodable = true,
	on_flood = function(pos, oldnode, newnode)
		local npos = {x=pos.x, y=pos.y-1, z=pos.z}
		local node = minetest.get_node(npos)
		clear_snow_dirt(npos, node)
	end,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5,  0.5, -0.5+2/16, 0.5},
		},
	},
	groups = {shovely=1, attached_node=1,deco_block=1, dig_by_piston=1},
	sounds = mcl_sounds.node_sound_snow_defaults(),
	on_construct = on_snow_construct,
	after_destruct = after_snow_destruct,
	drop = "mcl_throwing:snowball 2",
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.1,
})

minetest.register_node("mcl_core:snowblock", {
	description = "Snow",
	_doc_items_longdesc = "This is a full block of snow. Snow of this thickness is usually found in areas of extreme cold.",
	_doc_items_hidden = false,
	tiles = {"default_snow.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {shovely=1, building_block=1},
	sounds = mcl_sounds.node_sound_snow_defaults(),
	on_construct = on_snow_construct,
	after_destruct = after_snow_destruct,
	drop = "mcl_throwing:snowball 4",
	_mcl_blast_resistance = 1,
	_mcl_hardness = 0.2,
})

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_core:stone_with_redstone", "nodes", "mcl_core:stone_with_redstone_lit")
	doc.add_entry_alias("nodes", "mcl_core:water_source", "nodes", "mcl_core:water_flowing")
	doc.add_entry_alias("nodes", "mcl_core:lava_source", "nodes", "mcl_core:lava_flowing")
	doc.add_entry_alias("nodes", "mcl_core:dirt_with_grass", "nodes", "mcl_core:dirt_with_grass_snow")
	doc.add_entry_alias("nodes", "mcl_core:podzol", "nodes", "mcl_core:podzol_snow")
	doc.add_entry_alias("nodes", "mcl_core:mycelium", "nodes", "mcl_core:mycelium_snow")
end

