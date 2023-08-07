local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

minetest.register_node("mcl_lush_caves:moss", {
	description = S("Moss"),
	_doc_items_longdesc = S("Moss is a green block found in lush caves"),
	_doc_items_entry_name = "moss",
	_doc_items_hidden = false,
	tiles = {"mcl_lush_caves_moss_block.png"},
	is_ground_content = false,
	groups = {handy=1, hoey=2, dirt=1, soil=1, soil_sapling=2, enderman_takable=1, building_block=1,flammable=1,fire_encouragement=60, fire_flammability=20, grass_block_no_snow = 1 },
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0.1,
	_mcl_hardness = 0.1,
})

minetest.register_node("mcl_lush_caves:moss_carpet", {
	description = S("Moss carpet"),
	_doc_items_longdesc = S("Moss carpet"),
	_doc_items_entry_name = "moss_carpet",

	is_ground_content = false,
	tiles = {"mcl_lush_caves_moss_carpet.png"},
	wield_image ="mcl_lush_caves_moss_carpet.png",
	wield_scale = { x=1, y=1, z=0.5 },
	groups = {handy=1, carpet=1,supported_node=1,flammable=1,fire_encouragement=60, fire_flammability=20, deco_block=1, dig_by_water=1 },
	sounds = mcl_sounds.node_sound_wool_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
		},
	},
	_mcl_hardness = 0.1,
	_mcl_blast_resistance = 0.1,
})

minetest.register_node("mcl_lush_caves:hanging_roots", {
	description = S("Hanging roots"),
	_doc_items_create_entry = S("Hanging roots"),
	_doc_items_entry_name = S("Hanging roots"),
	_doc_items_longdesc = S("Hanging roots"),
	paramtype = "light",
	--paramtype2 = "meshoptions",
	place_param2 = 3,
	sunlight_propagates = true,
	walkable = false,
	drawtype = "plantlike",
	--drop = "mcl_farming:wheat_seeds",
	tiles = {"mcl_lush_caves_hanging_roots.png"},
	inventory_image = "mcl_lush_caves_hanging_roots.png",
	wield_image = "mcl_lush_caves_hanging_roots.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		},
	},
	groups = { shearsy = 1, dig_immediate=3, plant=1, supported_node=0,	dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1, cultivatable=1 },
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_blast_hardness = 0,
})

minetest.register_node("mcl_lush_caves:cave_vines", {
	description = S("Cave vines"),
	_doc_items_create_entry = S("Cave vines"),
	_doc_items_entry_name = S("Cave vines"),
	_doc_items_longdesc = S("Cave vines"),
	paramtype = "light",
	--paramtype2 = "meshoptions",
	place_param2 = 3,
	sunlight_propagates = true,
	walkable = false,
	drawtype = "plantlike",
	--drop = "mcl_farming:wheat_seeds",
	tiles = {"mcl_lush_caves_cave_vines.png"},
	inventory_image = "mcl_lush_caves_cave_vines.png",
	wield_image = "mcl_lush_caves_cave_vines.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		},
	},
	groups = { shearsy = 1, dig_immediate=3, plant=1, supported_node=0,	dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1, cultivatable=1 },
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_blast_hardness = 0,
})

minetest.register_node("mcl_lush_caves:cave_vines_lit", {
	description = S("Cave vines"),
	_doc_items_create_entry = S("Cave vines"),
	_doc_items_entry_name = S("Cave vines"),
	_doc_items_longdesc = S("Cave vines"),
	paramtype = "light",
	--paramtype2 = "meshoptions",
	place_param2 = 3,
	sunlight_propagates = true,
	walkable = false,
	drawtype = "plantlike",
	--drop = "mcl_farming:wheat_seeds",
	light_source = 9,
	tiles = {"mcl_lush_caves_cave_vines_lit.png"},
	inventory_image = "mcl_lush_caves_cave_vines_lit.png",
	wield_image = "mcl_lush_caves_cave_vines_lit.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
		},
	},
	groups = { shearsy = 1, handy = 1, plant=1, supported_node=0, dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1 },
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_blast_hardness = 1,
	drop = "mcl_lush_caves:glow_berry",
	on_dig = function(pos)
		minetest.add_item(pos,"mcl_lush_caves:glow_berry")
		minetest.set_node(pos,{name="mcl_lush_caves:cave_vines"})
	end,
})

minetest.register_node("mcl_lush_caves:rooted_dirt", {
	description = S("Rooted dirt"),
	_doc_items_longdesc = S("Rooted dirt"),
	_doc_items_hidden = false,
	tiles = {"mcl_lush_caves_rooted_dirt.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, dirt=1, building_block=1, path_creation_possible=1},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

minetest.register_craftitem("mcl_lush_caves:glow_berry", {
	description = S("Glow berry"),
	_doc_items_longdesc = S("This is a food item which can be eaten."),
	stack_max = 64,
	inventory_image = "mcl_lush_caves_glow_berries.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = {food = 2, eatable = 2, compostability = 50},
	_mcl_saturation = 1.2,
})

minetest.register_node("mcl_lush_caves:azalea_leaves", {
	description = S("Azalea Leaves"),
	_doc_items_longdesc = S("Leaves of an Azalea tree"),
	_doc_items_hidden = false,
	drawtype = "allfaces_optional",
	waving = 2,
	place_param2 = 1, -- Prevent leafdecay for placed nodes
	tiles = { "mcl_lush_caves_azalea_leaves.png" },
	paramtype = "light",
	groups = {
		hoey = 1, shearsy = 1, dig_by_piston = 1,
		leaves = 1, leafdecay = 5, deco_block = 1,
		flammable = 2, fire_encouragement = 30, fire_flammability = 60,
		compostability = 30
	},
	drop = {
			max_items = 1,
			items = {
				--{
				--	items = {sapling},
				--	rarity = 10
				--},
				{
					items = {"mcl_core:stick 1"},
					rarity = 3
				},
				{
					items = {"mcl_core:stick 2"},
					rarity = 6
				},
			}
		},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	_mcl_shears_drop = true,
	_mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_lush_caves:azalea_leaves_flowering", {
	description = S("Flowering Azalea Leaves"),
	_doc_items_longdesc = S("The Flowering Leaves of an Azalea tree"),
	_doc_items_hidden = false,
	drawtype = "allfaces_optional",
	waving = 2,
	place_param2 = 1, -- Prevent leafdecay for placed nodes
	tiles = { "mcl_lush_caves_azalea_leaves_flowering.png" },
	paramtype = "light",
	groups = {
		hoey = 1, shearsy = 1, dig_by_piston = 1,
		leaves = 1, leafdecay = 5, deco_block = 1,
		flammable = 2, fire_encouragement = 30, fire_flammability = 60,
		compostability = 30
	},
	drop = {
			max_items = 1,
			items = {
				--{
				--	items = {sapling},
				--	rarity = 10
				--},
				{
					items = {"mcl_core:stick 1"},
					rarity = 3
				},
				{
					items = {"mcl_core:stick 2"},
					rarity = 6
				},
			}
		},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	_mcl_shears_drop = true,
	_mcl_silk_touch_drop = true,
})


minetest.register_node("mcl_lush_caves:spore_blossom", {
	description = S("Spore blossom"),
	_doc_items_longdesc = S("Spore blossom"),
	_doc_items_hidden = false,
	tiles = {"mcl_lush_caves_spore_blossom.png"},
	drawtype = "plantlike",
	param2type = "meshoptions",
	place_param2 = 4,
	is_ground_content = true,
	groups = {handy = 1, plant = 1},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {{ -3/16, -2/16, -3/16, 3/16, 8/16, 3/16 }},
	},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	on_place = mcl_util.generate_on_place_plant_function(function(place_pos, place_node,stack)
		local above = vector.offset(place_pos,0,1,0)
		local snn = minetest.get_node_or_nil(above).name
		if not snn then return false end
		if minetest.get_item_group(snn,"soil_sapling") > 0 then
			return true
		end
	end)
})

--[[
minetest.register_node("mcl_lush_caves:azalea", {
	description = S("Azalea"),
	inventory_image = "mcl_lush_caves_azalea_plant.png",
	drawtype = "allfaces_optional",
--	drawtype = "nodebox",
--	node_box = {
--		type = "fixed",
--		fixed = {
--			{ -16/16, -0/16, -16/16,  16/16, 16/16,  16/16 },
--			{ -2/16, -16/16, -2/16,  2/16,  0/16,  2/16 },
--		}
--	},
	--tiles = { "blank.png" },
	tiles = {
		"mcl_lush_caves_azalea_top.png",
		"mcl_lush_caves_azalea_top.png",
		"mcl_lush_caves_azalea_side.png",
		"mcl_lush_caves_azalea_side.png",
		"mcl_lush_caves_azalea_side.png",
		"mcl_lush_caves_azalea_side.png",
	},
	is_ground_content = false,
	groups = { handy=1 },
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
	use_texture_alpha = "clip",
})

minetest.register_node("mcl_lush_caves:azalea_flowering", {
	description = S("Flowering azalea"),
	inventory_image = "mcl_lush_caves_azalea_flowering_top.png",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -16/16, -4/16, -16/16,  16/16, 16/16,  16/16 },
			{ -2/16, -16/16, -2/16,  2/16,  -4/16,  2/16 },
		}
	},
	--tiles = { "blank.png" },
	tiles = {
		"mcl_lush_caves_azalea_flowering_top.png",
		"mcl_lush_caves_azalea_flowering_top.png",
		"mcl_lush_caves_azalea_flowering_side.png",
		"mcl_lush_caves_azalea_flowering_side.png",
		"mcl_lush_caves_azalea_flowering_side.png",
		"mcl_lush_caves_azalea_flowering_side.png",
	},
	is_ground_content = false,
	groups = { handy=1 },
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
	use_texture_alpha = "clip",
})
--]]
