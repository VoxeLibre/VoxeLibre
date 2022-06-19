local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)
-- Warped and Crimson fungus
-- by debiankaios
-- adapted for mcl2 by cora

local function generate_warped_tree(pos)
	minetest.place_schematic(pos,modpath.."/schematics/warped_fungus_1.mts","random",nil,false,"place_center_x,place_center_z")
end

function generate_crimson_tree(pos)
	minetest.place_schematic(pos,modpath.."/schematics/crimson_fungus_1.mts","random",nil,false,"place_center_x,place_center_z")
end

function grow_twisting_vines(pos, moreontop)
	local y = pos.y + 1
		while not (moreontop == 0) do
			if minetest.get_node({x = pos.x, y = y, z = pos.z}).name == "air" then
				minetest.set_node({x = pos.x, y = y, z = pos.z}, {name="mcl_crimson:twisting_vines"})
				moreontop = moreontop - 1
				y = y + 1
			elseif minetest.get_node({x = pos.x, y = y, z = pos.z}).name == "mcl_crimson:twisting_vines" then
				y = y + 1
			else
				moreontop = 0
			end
	end
end

minetest.register_node("mcl_crimson:warped_fungus", {
	description = S("Warped Fungus Mushroom"),
	drawtype = "plantlike",
	tiles = { "farming_warped_fungus.png" },
	inventory_image = "farming_warped_fungus.png",
	wield_image = "farming_warped_fungus.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3,mushroom=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,enderman_takable=1,deco_block=1},
	light_source = 1,
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, -2/16, 3/16 },
	},
	node_placement_prediction = "",
	on_rightclick = function(pos, node, pointed_thing, player, itemstack)
		if pointed_thing:get_wielded_item():get_name() == "mcl_dye:white" then
			local nodepos = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
			if nodepos.name == "mcl_crimson:warped_nylium" or nodepos.name == "mcl_nether:netherrack" then
				local random = math.random(1, 5)
				if random == 1 then
					generate_warped_tree(pos)
				end
			end
		end
	end,
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_crimson:twisting_vines", {
	description = S("Twisting Vines"),
	drawtype = "plantlike",
	tiles = { "twisting_vines_plant.png" },
	inventory_image = "twisting_vines.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	climbable = true,
	buildable_to = true,
	groups = {dig_immediate=3,vines=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,deco_block=1, shearsy = 1},
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, 0.5, 3/16 },
	},
	node_placement_prediction = "",
	on_rightclick = function(pos, node, pointed_thing, itemstack)
		if pointed_thing:get_wielded_item():get_name() == "mcl_crimson:twisting_vines" then
			itemstack:take_item()
			grow_twisting_vines(pos, 1)
		elseif pointed_thing:get_wielded_item():get_name() == "mcl_dye:white" then
			itemstack:take_item()
			grow_twisting_vines(pos, math.random(1, 3))
		end
	end,
	drop = {
		max_items = 1,
		items = {
			{items = {"mcl_crimson:twisting_vines"}, rarity = 3},
		},
	},
	_mcl_shears_drop = true,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = {
		items = {
			{items = {"mcl_crimson:twisting_vines"}, rarity = 3},
		},
		items = {
			{items = {"mcl_crimson:twisting_vines"}, rarity = 1.8181818181818181},
		},
		"mcl_crimson:twisting_vines",
		"mcl_crimson:twisting_vines",
	},
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_crimson:nether_sprouts", {
	description = S("Nether Sprouts"),
	drawtype = "plantlike",
	tiles = { "nether_sprouts.png" },
	inventory_image = "nether_sprouts.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups = {dig_immediate=3,vines=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,deco_block=1, shearsy = 1},
	selection_box = {
		type = "fixed",
		fixed = { -4/16, -0.5, -4/16, 4/16, 0, 4/16 },
	},
	node_placement_prediction = "",
	drop = "",
	_mcl_shears_drop = true,
	_mcl_silk_touch_drop = false,
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_crimson:warped_roots", {
	description = S("Warped Roots"),
	drawtype = "plantlike",
	tiles = { "warped_roots.png" },
	inventory_image = "warped_roots.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups = {dig_immediate=3,vines=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,deco_block=1, shearsy = 1},
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -0.5, -6/16, 6/16, -4/16, 6/16 },
	},
	node_placement_prediction = "",
	_mcl_silk_touch_drop = false,
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_crimson:warped_wart_block", {
	description = S("Warped Wart Block"),
	tiles = {"warped_wart_block.png"},
	groups = {handy = 1, hoe = 7, swordy = 1, deco_block = 1},
	_mcl_hardness = 2,
})

minetest.register_node("mcl_crimson:shroomlight", {
	description = S("Shroomlight"),
	tiles = {"shroomlight.png"},
	groups = {handy = 1, hoe = 7, swordy = 1, leafdecay = 5, leaves = 1, deco_block = 1},
	light_source = minetest.LIGHT_MAX,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_crimson:warped_hyphae", {
	description = S("Warped Hyphae"),
	_doc_items_longdesc = S("The stem of a warped hyphae"),
	_doc_items_hidden = false,
	tiles = {
		"warped_hyphae.png",
		"warped_hyphae.png",
		"warped_hyphae_side.png",
		"warped_hyphae_side.png",
		"warped_hyphae_side.png",
		"warped_hyphae_side.png",
	},
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	groups = {handy = 1, axey = 1, tree = 1, building_block = 1, material_wood = 1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
	_mcl_stripped_variant = "mcl_crimson:stripped_warped_hyphae",
})

minetest.register_node("mcl_crimson:warped_nylium", {
	description = S("Warped Nylium"),
	tiles = {
		"warped_nylium.png",
		"mcl_nether_netherrack.png",
		"mcl_nether_netherrack.png^warped_nylium_side.png",
		"mcl_nether_netherrack.png^warped_nylium_side.png",
		"mcl_nether_netherrack.png^warped_nylium_side.png",
		"mcl_nether_netherrack.png^warped_nylium_side.png",
	},
	paramtype2 = "facedir",
	is_ground_content = true,
	drop = "mcl_nether:netherrack",
	groups = {pickaxey=1, building_block=1, material_stone=1},
	_mcl_hardness = 0.4,
	_mcl_blast_resistance = 0.4,
	_mcl_silk_touch_drop = true,
})

--Stem bark, stripped stem and bark

minetest.register_node("mcl_crimson:warped_hyphae_bark", {
	description = S("Warped Hyphae Bark"),
	_doc_items_longdesc = S("This is a decorative block surrounded by the bark of an hyphae."),
	tiles = {"warped_hyphae_side.png"},
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	groups = {handy = 1, axey = 1, bark = 1, building_block = 1, material_wood = 1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	is_ground_content = false,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
	_mcl_stripped_variant = "mcl_crimson:stripped_warped_hyphae_bark",
})

minetest.register_craft({
	output = "mcl_crimson:warped_hyphae_bark 3",
	recipe = {
		{ "mcl_crimson:warped_hyphae", "mcl_crimson:warped_hyphae" },
		{ "mcl_crimson:warped_hyphae", "mcl_crimson:warped_hyphae" },
	},
})

minetest.register_node("mcl_crimson:stripped_warped_hyphae", {
	description = S("Stripped warped hyphae"),
	_doc_items_longdesc = S("The stripped hyphae of a warped fungus"),
	_doc_items_hidden = false,
	tiles = {"warped_stem_stripped_top.png", "warped_stem_stripped_top.png", "warped_stem_stripped_side.png"},
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	groups = {handy = 1, axey = 1, tree = 1, building_block = 1, material_wood = 1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_crimson:stripped_warped_hyphae_bark", {
	description = S("Stripped warped hyphae bark"),
	_doc_items_longdesc = S("The stripped hyphae bark of a warped fungus"),
	tiles = {"crimson_stem_stripped_side.png"},
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	groups = {handy = 1, axey = 1, bark = 1, building_block = 1, material_wood = 1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	is_ground_content = false,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

minetest.register_craft({
	output = "mcl_crimson:stripped_warped_hyphae_bark 3",
	recipe = {
		{ "mcl_crimson:stripped_warped_hyphae", "mcl_crimson:stripped_warped_hyphae" },
		{ "mcl_crimson:stripped_warped_hyphae", "mcl_crimson:stripped_warped_hyphae" },
	},
})

minetest.register_node("mcl_crimson:warped_hyphae_wood", {
	description = S("Warped Hyphae Wood"),
	tiles = {"warped_hyphae_wood.png"},
	groups = {handy = 5,axey = 1, flammable = 3, wood=1,building_block = 1, material_wood = 1, fire_encouragement = 5, fire_flammability = 20},
	paramtype2 = "facedir",
	_mcl_hardness = 2,
})

mcl_stairs.register_stair_and_slab_simple("warped_hyphae_wood", "mcl_crimson:warped_hyphae_wood", S("Warped Stair"), S("Warped Slab"), S("Double Warped Slab"))

minetest.register_craft({
	output = "mcl_crimson:warped_hyphae_wood 4",
	recipe = {
		{"mcl_crimson:warped_hyphae"},
	},
})

minetest.register_craft({
	output = "mcl_crimson:warped_nylium 2",
	recipe = {
		{"mcl_crimson:warped_wart_block"},
		{"mcl_nether:netherrack"},
	},
})

minetest.register_abm({
	label = "mcl_crimson:warped_fungus",
	nodenames = {"mcl_crimson:warped_fungus"},
	interval = 11,
	chance = 128,
	action = function(pos)
		local nodepos = minetest.get_node(vector.offset(pos, 0, -1, 0))
		if nodepos.name == "mcl_crimson:warped_nylium" or nodepos.name == "mcl_nether:netherrack" then
			if pos.y < -28400 then
				generate_warped_tree(pos)
			end
		end
	end
})

minetest.register_node("mcl_crimson:crimson_fungus", {
	description = S("Crimson Fungus Mushroom"),
	drawtype = "plantlike",
	tiles = { "farming_crimson_fungus.png" },
	inventory_image = "farming_crimson_fungus.png",
	wield_image = "farming_crimson_fungus.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3,mushroom=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,enderman_takable=1,deco_block=1},
	light_source = 1,
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, -2/16, 3/16 },
	},
	node_placement_prediction = "",
	on_rightclick = function(pos, node, pointed_thing, player)
		if pointed_thing:get_wielded_item():get_name() == "mcl_dye:white" then
			local nodepos = minetest.get_node(vector.offset(pos, 0, -1, 0))
			if nodepos.name == "mcl_crimson:crimson_nylium" or nodepos.name == "mcl_nether:netherrack" then
				local random = math.random(1, 5)
				if random == 1 then
					generate_crimson_tree(pos)
				end
			end
		end
	end,
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_crimson:crimson_roots", {
	description = S("Crimson Roots"),
	drawtype = "plantlike",
	tiles = { "crimson_roots.png" },
	inventory_image = "crimson_roots.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	groups = {dig_immediate=3,vines=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1,deco_block=1, shearsy = 1},
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -0.5, -6/16, 6/16, -4/16, 6/16 },
	},
	node_placement_prediction = "",
	_mcl_silk_touch_drop = false,
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_crimson:crimson_hyphae", {
	description = S("Crimson Hyphae"),
	_doc_items_longdesc = S("The stem of a crimson hyphae"),
	_doc_items_hidden = false,
	tiles = {
		"crimson_hyphae.png",
		"crimson_hyphae.png",
		"crimson_hyphae_side.png",
		"crimson_hyphae_side.png",
		"crimson_hyphae_side.png",
		"crimson_hyphae_side.png",
	},
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	groups = {handy = 1, axey = 1, tree = 1, building_block = 1, material_wood = 1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
	_mcl_stripped_variant = "mcl_crimson:stripped_crimson_hyphae",
})

--Stem bark, stripped stem and bark

minetest.register_node("mcl_crimson:crimson_hyphae_bark", {
	description = S("Crimson Hyphae Bark"),
	_doc_items_longdesc = S("This is a decorative block surrounded by the bark of an hyphae."),
	tiles = {"crimson_hyphae_side.png"},
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	groups = {handy = 1, axey = 1, bark = 1, building_block = 1, material_wood = 1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	is_ground_content = false,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
	_mcl_stripped_variant = "mcl_crimson:stripped_crimson_hyphae_bark",
})

minetest.register_craft({
	output = "mcl_crimson:crimson_hyphae_bark 3",
	recipe = {
		{ "mcl_crimson:crimson_hyphae", "mcl_crimson:crimson_hyphae" },
		{ "mcl_crimson:crimson_hyphae", "mcl_crimson:crimson_hyphae" },
	},
})

minetest.register_node("mcl_crimson:stripped_crimson_hyphae", {
	description = S("Stripped Crimson Hyphae"),
	_doc_items_longdesc = S("The stripped stem of a crimson hyphae"),
	_doc_items_hidden = false,
	tiles = {"crimson_stem_stripped_top.png", "crimson_stem_stripped_top.png", "crimson_stem_stripped_side.png"},
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	groups = {handy = 1, axey = 1, tree = 1, building_block = 1, material_wood = 1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_crimson:stripped_crimson_hyphae_bark", {
	description =	S("Stripped Crimson Hyphae Bark"),
	_doc_items_longdesc = S("The stripped wood of a crimson hyphae"),
	tiles = {"crimson_stem_stripped_side.png"},
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	groups = {handy = 1, axey = 1, bark = 1, building_block = 1, material_wood = 1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	is_ground_content = false,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

minetest.register_craft({
	output = "mcl_crimson:stripped_crimson_hyphae_bark 3",
	recipe = {
		{ "mcl_crimson:stripped_crimson_hyphae", "mcl_crimson:stripped_crimson_hyphae" },
		{ "mcl_crimson:stripped_crimson_hyphae", "mcl_crimson:stripped_crimson_hyphae" },
	},
})

minetest.register_node("mcl_crimson:crimson_hyphae_wood", {
	description = S("Crimson Hyphae Wood"),
	tiles = {"crimson_hyphae_wood.png"},
	groups = {handy = 5, axey = 1, wood = 1, building_block = 1, material_wood = 1},
	paramtype2 = "facedir",
	_mcl_hardness = 2,
})

minetest.register_node("mcl_crimson:crimson_nylium", {
	description = S("Crimson Nylium"),
	tiles = {
		"crimson_nylium.png",
		"mcl_nether_netherrack.png",
		"mcl_nether_netherrack.png^crimson_nylium_side.png",
		"mcl_nether_netherrack.png^crimson_nylium_side.png",
		"mcl_nether_netherrack.png^crimson_nylium_side.png",
		"mcl_nether_netherrack.png^crimson_nylium_side.png",
	},
	groups = {pickaxey = 1, building_block = 1, material_stone = 1},
	paramtype2 = "facedir",
	is_ground_content = true,
	drop = "mcl_nether:netherrack",
	_mcl_hardness = 0.4,
	_mcl_blast_resistance = 0.4,
	_mcl_silk_touch_drop = true,
})

minetest.register_craft({
	output = "mcl_crimson:crimson_hyphae_wood 4",
	recipe = {
		{"mcl_crimson:crimson_hyphae"},
	},
})

minetest.register_craft({
	output = "mcl_crimson:crimson_nylium 2",
	recipe = {
		{"mcl_nether:nether_wart"},
		{"mcl_nether:netherrack"},
	},
})

mcl_stairs.register_stair_and_slab_simple("crimson_hyphae_wood", "mcl_crimson:crimson_hyphae_wood", "Crimson Stair", "Crimson Slab", "Double Crimson Slab")

minetest.register_abm({
	label = "mcl_crimson:crimson_fungus",
	nodenames = {"mcl_crimson:crimson_fungus"},
	interval = 11,
	chance = 128,
	action = function(pos)
		local nodepos = minetest.get_node(vector.offset(pos, 0, -1, 0))
		if nodepos.name == "mcl_crimson:crimson_nylium" or nodepos.name == "mcl_nether:netherrack" then
			if pos.y < -28400 then
				generate_crimson_tree(pos)
			end
		end
	end
})
