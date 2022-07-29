local S = minetest.get_translator("mcl_mangrove")

local function get_drops(fortune_level)
	local apple_chances = {200, 180, 160, 120, 40}
	local stick_chances = {50, 45, 30, 35, 10}
	local sapling_chances = {20, 16, 12, 10}
	return {
		max_items = 1,
		items = {
			{
				items = {sapling},
				rarity = sapling_chances[fortune_level + 1] or sapling_chances[fortune_level]
			},
			{
				items = {"mcl_core:stick 1"},
				rarity = stick_chances[fortune_level + 1]
			},
			{
				items = {"mcl_core:stick 2"},
				rarity = stick_chances[fortune_level + 1]
			},
			{
				items = {"mcl_core:apple"},
				rarity = apple_chances[fortune_level + 1]
			}
		}
	}
end

minetest.register_node("mcl_mangrove:mangrove_tree", {
	description = S("Mangrove Wood"),
	_doc_items_longdesc = S("The trunk of an Mangrove tree."),
	_doc_items_hidden = false,
	tiles = {"mcl_mangrove_log_top.png", "mcl_mangrove_log_top.png", "mcl_mangrove_log.png"},
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	groups = {handy=1,axey=1, tree=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_place = mcl_util.rotate_axis,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})
minetest.register_node("mcl_mangrove:mangrove_tree_bark", {
	description = S("Mangrove Bark"),
	_doc_items_longdesc = S("The bark of an Mangrove tree."),
	_doc_items_hidden = false,
	tiles = {"mcl_mangrove_log.png", "mcl_mangrove_log.png", "mcl_mangrove_log.png"},
	paramtype2 = "facedir",
	groups = {handy=1,axey=1, tree=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_place = mcl_util.rotate_axis,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_mangrove:mangrove_wood", {
	description = S("Mangrove Wood Planks"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	_doc_items_hidden = false,
	tiles = {"mcl_mangrove_planks.png"},

	is_ground_content = false,
	groups = {handy=1,axey=1, flammable=3,wood=1,building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_mangrove:mangroveleaves", {
	description = S("Mangrove Leaves"),
	_doc_items_longdesc = S("mangrove leaves are grown from mangrove trees."),
	_doc_items_hidden = false,
	drawtype = "allfaces_optional",
	waving = 2,
	place_param2 = 1, -- Prevent leafdecay for placed nodes
	tiles = {"mcl_mangrove_leaves.png"},
	paramtype = "light",
	groups = {handy=1,shearsy=1,swordy=1, leafdecay=10, flammable=2, leaves=1, deco_block=1, dig_by_piston=1, fire_encouragement=30, fire_flammability=60},
	_mcl_shears_drop = true,
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = { get_drops(1), get_drops(2), get_drops(3), get_drops(4) },
})



minetest.register_node("mcl_mangrove:propagule", {
	description = S("mangrove_propagule"),
	_tt_help = S("Needs soil and light to grow"),
	_doc_items_longdesc = S("When placed on soil (such as dirt) and exposed to light, an propagule will grow into an mangrove after some time."),
	_doc_items_hidden = false,
	drawtype = "plantlike",
	waving = 1,
	visual_scale = 1.0,
	tiles = {"mcl_mangrove_propagule_item.png"},
	inventory_image = "mcl_mangrove_propagule_item.png",
	wield_image = "mcl_mangrove_propagule_item.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-5/16, -0.5, -5/16, 5/16, 0.5, 5/16}
	},

	groups = {
		plant = 1, sapling = 1, non_mycelium_plant = 1, attached_node = 1,
		deco_block = 1, dig_immediate = 3, dig_by_water = 0, dig_by_piston = 1,
		destroy_by_lava_flow = 1, compostability = 30
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("stage", 0)
	end,
	node_placement_prediction = "",
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
	on_place = function(itemstack, user, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick (pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		-- Place on dirt
		if pointed_thing.under and node.name == "mcl_core:dirt"  then
			local protname = user:get_player_name()
			if minetest.is_protected(pointed_thing.under, protname) then
				minetest.record_protection_violation(pointed_thing.under, protname)
				return itemstack
			end
			minetest.set_node(pointed_thing.under, { name = "mcl_mangrove:propagule_dirt", param2 = node.param2 })
			minetest.sound_play(mcl_sounds.node_sound_leaves_defaults{pos=pointed_thing.under, gain=0.5, max_hear_range=16}, true)
			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:take_item(1) -- 1 use
				return itemstack
			end
		end

-- Place on dirt _with_grass
		if pointed_thing.under and node.name == "mcl_core:dirt_with_grass"  then
			local protname = user:get_player_name()
			if minetest.is_protected(pointed_thing.under, protname) then
				minetest.record_protection_violation(pointed_thing.under, protname)
				return itemstack
			end
			minetest.set_node(pointed_thing.under, { name = "mcl_mangrove:propagule_dirt_with_grass", param2 = node.param2 })
			minetest.sound_play(mcl_sounds.node_sound_leaves_defaults{pos=pointed_thing.under, gain=0.5, max_hear_range=16}, true)
			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:take_item(1) -- 1 use
				return itemstack
			end
		end

		if pointed_thing.under and node.name == "mcl_mud:mud" then
			local protname = user:get_player_name()
			if minetest.is_protected(pointed_thing.under, protname) then
				minetest.record_protection_violation(pointed_thing.under, protname)
				return itemstack
			end
			minetest.set_node(pointed_thing.under, { name = "mcl_mangrove:propagule_mud", param2 = node.param2 })
			minetest.sound_play(mcl_sounds.node_sound_leaves_defaults{pos=pointed_thing.under, gain=0.5, max_hear_range=16}, true)
			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:take_item(1) -- 1 use
				return itemstack
			end
		end
		return mcl_util.generate_on_place_plant_function(function(pos, node)
			local node_under = minetest.get_node_or_nil({x=pos.x,y=pos.y-1,z=pos.z})
			if not node_under then return false end
			local nn = node_under.name
			return ((minetest.get_item_group(nn, "grass_block") == 1) or
					nn=="mcl_core:podzol" or nn=="mcl_core:podzol_snow" or
					nn=="mcl_core:dirt")
		end)
	end
})

minetest.register_node("mcl_mangrove:mangrove_stripped_trunk", {
	description = "The stripped wood of an Mangove tree",
	_doc_items_longdesc = "The stripped wood of an Mangove tree",
	_doc_items_hidden = false,
	tiles ={"mcl_stripped_mangrove_log_top.png","mcl_stripped_mangrove_log_side.png",},
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,

	groups = {handy=1, axey=1, tree=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_rotate = on_rotate,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_mangrove:mangrove_roots", {
	description = "Mangrove_Roots",
	_doc_items_longdesc = "Mangrove roots are decorative blocks that form as part of mangrove trees.",
	_doc_items_hidden = false,
	waving = 0,
	place_param2 = 1, -- Prevent leafdecay for placed nodes
	tiles = {
		"mcl_mangrove_roots_top.png", "mcl_mangrove_roots_top.png",
		"mcl_mangrove_roots_side.png", "mcl_mangrove_roots_side.png",
		"mcl_mangrove_roots_side.png", "mcl_mangrove_roots_side.png"
	},
	paramtype = "light",

	drawtype = "mesh",
	mesh = "node.obj",
	groups = {
		handy = 1, hoey = 1, shearsy = 1, axey = 1, swordy = 1, dig_by_piston = 0,
		leaves = 1, deco_block = 1,flammable = 10, fire_encouragement = 30, fire_flammability = 60,	compostability = 30
	},
	drop = "mcl_mangrove:mangrove_roots",
	_mcl_shears_drop = true,
	sounds = mcl_sounds.node_sound_leaves_defaults(),			_mcl_blast_resistance = 0.7,
	_mcl_hardness = 0.7,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = { "mcl_mangrove:mangrove_roots 1", "mcl_mangrove:mangrove_roots 2", "mcl_mangrove:mangrove_roots 3", "mcl_mangrove:mangrove_roots 4" },
})

mcl_flowerpots.register_potted_flower("mcl_mangrove:propagule", {
	name = "propagule",
	desc = S("Mangrove Propagule"),
	image = "mcl_mangrove_propagule.png",
})

minetest.register_node("mcl_mangrove:propagule_dirt", {
	description = "propagule_dirt",
	_doc_items_longdesc = "",
	_tt_help = "",
	drawtype = "plantlike_rooted",
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 1,
	tiles = { "default_dirt.png" },
	special_tiles = { { name = "mcl_mangrove_propagule_item.png" } },
	inventory_image = "mcl_mangrove_propagule_item.png",
	wield_image = "mcl_mangrove_propagule.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
			{ -0.5, 0.5, -0.5, 0.5, 1.0, 0.5 },
		}
	},
	groups = {
		plant = 1, sapling = 1, non_mycelium_plant = 1, attached_node = 1, not_in_creative_inventory=1,
		deco_block = 1, dig_immediate = 3, dig_by_water = 0, dig_by_piston = 1,
		destroy_by_lava_flow = 1, compostability = 30
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	drop = "mcl_mangrove:propagule",
	node_placement_prediction = "",
	node_dig_prediction = "mcl_core:dirt",
	after_dig_node = function(pos)
		local node = minetest.get_node(pos)
		if minetest.get_item_group(node.name, "dirt") == 0 then
			minetest.set_node(pos, {name="mcl_core:dirt"})
		end
	end,
	_mcl_hardness = 0,
	_mcl_blast_resistance = 0,
	_mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_mangrove:propagule_mud", {
	description = "propagule_mud",
	_doc_items_longdesc = "",
	_tt_help = "",
	drawtype = "plantlike_rooted",
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 1,
	tiles = {"mcl_mud.png"},
	special_tiles = { { name = "mcl_mangrove_propagule_item.png" } },
	inventory_image = "mcl_mangrove_propagule_item.png",
	wield_image = "mcl_mangrove_propagule.png",
	collision_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, 0.5 - 2/16, 0.5 },
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
			{ -0.5, 0.5, -0.5, 0.5, 1.0, 0.5 },
		}
	},
	groups = {
		plant = 1, sapling = 1, non_mycelium_plant = 1, attached_node = 1, not_in_creative_inventory=1,
		deco_block = 1, dig_immediate = 3, dig_by_water = 0, dig_by_piston = 1,
		destroy_by_lava_flow = 1, compostability = 30
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	drop = "mcl_mangrove:propagule",
	node_placement_prediction = "",
	node_dig_prediction = "mcl_mud:mud",
	after_dig_node = function(pos)
		local node = minetest.get_node(pos)
		if minetest.get_item_group(node.name, "dirt") == 0 then
			minetest.set_node(pos, {name="mcl_mud:mud"})
		end
	end,
	_mcl_hardness = 0,
	_mcl_blast_resistance = 0,
	_mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_mangrove:propagule_dirt_with_grass", {
	description = "propagule_dirt_with_grass_",
	_doc_items_longdesc = "",
	_tt_help = "",
	drawtype = "plantlike_rooted",
	paramtype = "meshoption",
	paramtype2 = "color",
	tiles = {"mcl_core_grass_block_top.png", { name="default_dirt.png", color="white" }},
	overlay_tiles = {"mcl_core_grass_block_top.png", "", {name="mcl_core_grass_block_side_overlay.png", tileable_vertical=false}},
	palette = "mcl_core_palette_grass.png",
	palette_index = 0,
	color = "#8EB971",
	special_tiles = { { name = "mcl_mangrove_propagule_item.png" } },
	inventory_image = "mcl_mangrove_propagule_item.png",
	wield_image = "mcl_mangrove_propagule.png",
	collision_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, 0.5 - 2/16, 0.5 },
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
			{ -0.5, 0.5, -0.5, 0.5, 1.0, 0.5 },
		}
	},
	groups = {
		plant = 1, sapling = 1, non_mycelium_plant = 1, attached_node = 1, not_in_creative_inventory=1,
		deco_block = 1, dig_immediate = 3, dig_by_water = 0, dig_by_piston = 1,
		destroy_by_lava_flow = 1, compostability = 30
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	drop = "mcl_mangrove:propagule",
	node_placement_prediction = "",
	node_dig_prediction = "mcl_core:dirt_with_grass",
	after_dig_node = function(pos)
		local node = minetest.get_node(pos)
		if minetest.get_item_group(node.name, "dirt") == 0 then
			minetest.set_node(pos, {name="mcl_core:dirt_with_grass"})
		end
	end,
	_mcl_hardness = 0,
	_mcl_blast_resistance = 0,
	_mcl_silk_touch_drop = true,
})

local water_tex = "default_water_source_animated.png^[verticalframe:16:0"

local wlroots = {
	description = ("water_logged_mangrove_roots"),
	_doc_items_entry_name = S("water_logged_roots"),
	_doc_items_longdesc =
		("Mangrove roots are decorative blocks that form as part of mangrove trees.").."\n\n"..
		("Mangrove roots, despite being a full block, can be waterlogged and do not flow water out").."\n\n"..
		("These cannot be crafted yet only occure when get in contact of water."),
	_doc_items_hidden = false,
	tiles = {
		"("..water_tex..")^mcl_mangrove_roots_top.png", "("..water_tex..")^mcl_mangrove_roots_top.png",
		"("..water_tex..")^mcl_mangrove_roots_side.png", "("..water_tex..")^mcl_mangrove_roots_side.png",
		"("..water_tex..")^mcl_mangrove_roots_side.png", "("..water_tex..")^mcl_mangrove_roots_side.png"
	},
	sounds = mcl_sounds.node_sound_water_defaults(),
	use_texture_alpha = USE_TEXTURE_ALPHA,
	is_ground_content = false,
	paramtype = "light",
	walkable = true,
	pointable = true,
	diggable = true,
	buildable_to = flase,
	liquids_pointable = true,
	drop = "mcl_mangrove:mangrove_roots",

		groups = {
		handy = 1, hoey = 1, water=3, liquid=3, puts_out_fire=1, dig_by_piston = 1, deco_block = 1,  not_in_creative_inventory=1 },
	_mcl_blast_resistance = 100,
	_mcl_hardness = -1, -- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	after_dig_node = function(pos)
		local node = minetest.get_node(pos)
		if minetest.get_item_group(node.name, "water") == 0 then
			minetest.set_node(pos, {name="mcl_core:water_source"})
		end
	end,
}
minetest.register_node("mcl_mangrove:water_logged_roots", wlroots)
local rwlroots = table.copy(wlroots)
water_tex = "default_river_water_source_animated.png^[verticalframe:16:0"
rwlroots.tiles = {
	"("..water_tex..")^mcl_mangrove_roots_top.png", "("..water_tex..")^mcl_mangrove_roots_top.png",
	"("..water_tex..")^mcl_mangrove_roots_side.png", "("..water_tex..")^mcl_mangrove_roots_side.png",
	"("..water_tex..")^mcl_mangrove_roots_side.png", "("..water_tex..")^mcl_mangrove_roots_side.png"
}
minetest.register_node("mcl_mangrove:river_water_logged_roots",rwlroots)

minetest.register_node("mcl_mangrove:mangrove_mud_roots", {
	description = S("Muddy Mangrove Roots"),
	_tt_help = S("crafted with Mud and Mangrove roots"),
	_doc_items_longdesc = S("Muddy Mangrove Roots is a block from mangrove swamp.It drowns player a bit inside it"),
	tiles = {
		"mcl_mud.png^mcl_mangrove_roots_top.png", "mcl_mud.png^mcl_mangrove_roots_top.png",
		"mcl_mud.png^mcl_mangrove_roots_side.png", "mcl_mud.png^mcl_mangrove_roots_side.png",
		"mcl_mud.png^mcl_mangrove_roots_side.png", "mcl_mud.png^mcl_mangrove_roots_side.png",
	},
	is_ground_content = true,
	groups = {handy = 1, shovely = 1, axey = 1, building_block = 1},
	sounds = mcl_sounds.node_sound_sand_defaults(),
	_mcl_blast_resistance = 0.7,
	_mcl_hardness = 0.7,
})

minetest.register_node("mcl_mangrove:hanging_propagule_1", {
	description = S("Hanging Propagule"),
	_tt_help = S("Grows on Mangrove leaves"),
	_doc_items_longdesc = "",
	_doc_items_usagehelp = "",
	groups = {
			plant = 1, not_in_creative_inventory=1, non_mycelium_plant = 1,
			deco_block = 1, dig_immediate = 3, dig_by_water = 0, dig_by_piston = 1,
			destroy_by_lava_flow = 1, compostability = 30
		},
	paramtype = "light",
	paramtype2 = "",
	on_rotate = false,
	walkable = false,
	drop = "mcl_mangrove:propagule",
	use_texture_alpha = "clip",
	drawtype = 'mesh',
	mesh = 'propagule_hanging.obj',
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- Base
		},
	},
	tiles = {"mcl_mangrove_propagule_hanging.png"},
	inventory_image = "mcl_mangrove_propagule.png",
	wield_image = "mcl_mangrove_propagule.png",
})

mcl_doors:register_door("mcl_mangrove:mangrove_door", {
	description = ("Mangrove Door"),
	_doc_items_longdesc = "",
	_doc_items_usagehelp = "",
	inventory_image = "mcl_mangrove_doors.png",
	groups = {handy=1,axey=1, material_wood=1, flammable=-1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 3,
	tiles_bottom = {"mcl_mangrove_door_bottom.png", "mcl_mangrove_planks.png"},
	tiles_top = {"mcl_mangrove_door_top.png", "mcl_mangrove_planks.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

mcl_doors:register_trapdoor(":mcl_doors:mangrove_trapdoor", {
	description = S("Mangrove Trapdoor"),
	_doc_items_longdesc = S("Wooden trapdoors are horizontal barriers which can be opened and closed by hand or a redstone signal. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder."),
	_doc_items_usagehelp = S("To open or close the trapdoor, rightclick it or send a redstone signal to it."),
	tile_front = "mcl_mangrove_trapdoor.png",
	tile_side = "mcl_mangrove_planks.png",
	wield_image = "mcl_mangrove_trapdoor.png",
	groups = {handy=1,axey=1, mesecon_effector_on=1, material_wood=1, flammable=-1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 3,
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

mcl_fences.register_fence_and_fence_gate(
	"mangrove_wood_fence",
	S("Mangrove Wood Fence"),
	S("Mangrove Wood Plank Fence"),
	"mcl_mangrove_fence.png",
	{handy=1,axey=1, flammable=2,fence_wood=1, fire_encouragement=5, fire_flammability=20},
	minetest.registered_nodes["mcl_core:wood"]._mcl_hardness,
	minetest.registered_nodes["mcl_core:wood"]._mcl_blast_resistance,
	{"group:fence_wood"},
	mcl_sounds.node_sound_wood_defaults(), "mcl_mangrove_mangrove_wood_fence_gate_open", "mcl_mangrove_mangrove_wood_fence_gate_close", 1, 1,
	"mcl_mangrove_fence_gate.png")

mcl_stairs.register_stair("mangrove_wood", "mcl_core:stair_mangrove",
	{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
	{"mcl_mangrove_planks.png"},
	S("Mangrove Wood Stairs"),
	mcl_sounds.node_sound_wood_defaults(), 3, 2,
	"woodlike")

mcl_stairs.register_slab("mangrove_wood", "mcl_core:slab_mangrove",
	{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
	{"mcl_mangrove_planks.png"},
	S("Mangrove Wood Slab"),
	mcl_sounds.node_sound_wood_defaults(), 3, 2,
	S("Double Mangrove Wood Slab"))

minetest.register_craft({
	output = "mcl_mangrove:mangrove_tree_bark 3",
	recipe = {
		{ "mcl_mangrove:mangrove_tree", "mcl_mangrove:mangrove_tree" },
		{ "mcl_mangrove:mangrove_tree", "mcl_mangrove:mangrove_tree" },
	}
})

minetest.register_craft({
	output = "mcl_mangrove:mangrove_mud_roots",
	recipe = {
		{"mcl_mangrove:mangrove_roots", "mcl_mud:mud",},
	}
})

minetest.register_craft({
	output = "mcl_doors:mangrove_door 3",
	recipe = {
		{"mcl_mangrove:mangrove_wood", "mcl_mangrove:mangrove_wood"},
		{"mcl_mangrove:mangrove_wood", "mcl_mangrove:mangrove_wood"},
		{"mcl_mangrove:mangrove_wood", "mcl_mangrove:mangrove_wood"},
	}
})

minetest.register_craft({
	output = "mcl_doors:trapdoor_mangrove 2",
	recipe = {
		{"mcl_mangrove:mangrove_wood","mcl_mangrove:mangrove_wood","mcl_mangrove:mangrove_wood"},
		{"mcl_mangrove:mangrove_wood","mcl_mangrove:mangrove_wood","mcl_mangrove:mangrove_wood"},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_doors:trapdoor_mangrove",
	burntime = 15,
})

minetest.register_craft({
		output = "mcl_mangrove:mangrove_wood_fence_gate",
		recipe = {
			{"mcl_core:stick", "mcl_mangrove:mangrove_wood", "mcl_core:stick"},
			{"mcl_core:stick", "mcl_mangrove:mangrove_wood", "mcl_core:stick"},
		}
	})

minetest.register_craft({
		output = "mcl_mangrove:mangrove_wood_fence 3",
		recipe = {
			{"mcl_mangrove:mangrove_wood", "mcl_core:stick", "mcl_mangrove:mangrove_wood"},
			{"mcl_mangrove:mangrove_wood", "mcl_core:stick", "mcl_mangrove:mangrove_wood"},
		}
	})

minetest.register_craft({
		output = "mcl_mangrove:mangrove_wood 4",
		recipe = {
			{"mcl_mangrove:mangrove_tree"},
		}
	})

minetest.register_craft({
	type = "fuel",
	recipe = "group:fence_wood",
	burntime = 15,
})

local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
}

minetest.register_abm({
	label = "Waterlog mangrove roots",
	nodenames = {"mcl_mangrove:mangrove_roots"},
	neighbors = {"group:water"},
	interval = 5,
	chance = 5,
	action = function(pos,value)
		for _,v in pairs(adjacents) do
			local n = minetest.get_node(vector.add(pos,v)).name
			if minetest.get_item_group(n,"water") > 0 then
				if n:find("river") then
					minetest.swap_node(pos,{name="mcl_mangrove:river_water_logged_roots"})
					return
				else
					minetest.swap_node(pos,{name="mcl_mangrove:water_logged_roots"})
					return
				end
			end
		end
	end
})

local propagule_nodes = {
	"mcl_mangrove:propagule_dirt",
	"mcl_mangrove:propagule_mud",
	"mcl_mangrove:propagule_dirt_with_grass"
}


--minetest.register_abm({
--	label = "Mangrove_tree_growth",
--	nodenames = propagule_nodes,
--	interval = 2,
--	chance = 1,
--	action = function(pos,value)
--		local path = minetest.get_modpath("mcl_mangrove") .. --"/schematics/mcl_mangrove_tree_1.mts",
--		minetest.place_schematic({x = pos.x - 3, y = pos.y - 0, z = pos.z - 4}, --path, -"random", nil, false)
--end
--})
