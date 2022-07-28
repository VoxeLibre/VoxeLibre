
local S = minetest.get_translator("mcl_core")

local register_tree_trunk = function(subname, description_trunk, description_bark, longdesc, tile_inner, tile_bark)
minetest.register_node("mcl_mangrove:"..subname, {
		description = description_trunk,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		tiles = {tile_inner, tile_inner, tile_bark},
		paramtype2 = "facedir",
		on_place = mcl_util.rotate_axis,
		stack_max = 64,
		groups = {handy=1,axey=1, tree=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		on_rotate = on_rotate,
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
	})

	minetest.register_craft({
		output = "mcl_mangrove:"..subname.."_bark 3",
		recipe = {
			{ "mcl_mangrove:"..subname, "mcl_mangrove:"..subname },
			{ "mcl_mangrove:"..subname, "mcl_mangrove:"..subname },
		}
	})
end

local register_wooden_planks = function(subname, description, tiles)
minetest.register_node("mcl_mangrove:"..subname, {
		description = description,
		_doc_items_longdesc = doc.sub.items.temp.build,
		_doc_items_hidden = false,
		tiles = tiles,
		stack_max = 64,
		is_ground_content = false,
		groups = {handy=1,axey=1, flammable=3,wood=1,building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		_mcl_blast_resistance = 3,
		_mcl_hardness = 2,
	})
end

local register_leaves = function(subname, description, longdesc, tiles, sapling, drop_apples, sapling_chances, leafdecay_distance)
	local drop
	if leafdecay_distance == nil then
		leafdecay_distance = 4
	end
	local apple_chances = {200, 180, 160, 120, 40}
	local stick_chances = {50, 45, 30, 35, 10}

	local function get_drops(fortune_level)
		local drop = {
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
			}
		}
		if drop_apples then
			table.insert(drop.items, {
				items = {"mcl_core:apple"},
				rarity = apple_chances[fortune_level + 1]
			})
		end
		return drop
	end
minetest.register_node("mcl_mangrove:"..subname, {
		description = description,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		drawtype = "allfaces_optional",
		waving = 2,
		place_param2 = 1, -- Prevent leafdecay for placed nodes
		tiles = tiles,
		paramtype = "light",
		stack_max = 64,
		groups = {handy=1,shearsy=1,swordy=1, leafdecay=leafdecay_distance, flammable=2, leaves=1, deco_block=1, dig_by_piston=1, fire_encouragement=30, fire_flammability=60},
		_mcl_shears_drop = true,
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 0.2,
		_mcl_hardness = 0.2,
		_mcl_silk_touch_drop = true,
		_mcl_fortune_drop = { get_drops(1), get_drops(2), get_drops(3), get_drops(4) },
	})
end

local function register_sapling(subname, description, longdesc, tt_help, texture, selbox)
	minetest.register_node("mcl_mangrove:"..subname, {
		description = description,
		_tt_help = tt_help,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		drawtype = "plantlike",
		waving = 1,
		visual_scale = 1.0,
		tiles = {texture},
		inventory_image = texture,
		wield_image = texture,
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		selection_box = {
			type = "fixed",
			fixed = selbox
		},
		stack_max = 64,
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
		on_place = mcl_util.generate_on_place_plant_function(function(pos, node)
			local node_under = minetest.get_node_or_nil({x=pos.x,y=pos.y-1,z=pos.z})
			if not node_under then return false end
			local nn = node_under.name
			return ((minetest.get_item_group(nn, "grass_block") == 1) or
					nn=="mcl_core:podzol" or nn=="mcl_core:podzol_snow" or
					nn=="mcl_core:dirt")
		end),
		node_placement_prediction = "",
		_mcl_blast_resistance = 0,
		_mcl_hardness = 0,
	})
end


------------------------------------------

---plank,tree,leaves and sampling--

register_tree_trunk("mangrove_tree", S("Mangrove Wood"), S("Mangrove Bark"), S("The trunk of an Mangrove tree."), "mcl_mangrove_log_top.png", "mcl_mangrove_log.png")
register_wooden_planks("mangrove_wood", S("Mangrove Wood Planks"), {"mcl_mangrove_planks.png"})
register_sapling("propagule", S("mangrove_propagule"),
	S("When placed on soil (such as dirt) and exposed to light, an propagule will grow into an mangrove after some time."),
	S("Needs soil and light to grow"),
	"mcl_mangrove_propagule_item.png", {-5/16, -0.5, -5/16, 5/16, 0.5, 5/16})
register_leaves("mangroveleaves", S("Mangrove Leaves"), S("mangrove leaves are grown from mangrove trees."), {"mcl_mangrove_leaves.png"}, "", true, {20, 16, 12, 10})


--other---

--stripped mangrove wood--
minetest.register_node("mcl_mangrove:mangrove_stripped_trunk", {
	description = "The stripped wood of an Mangove tree",
	_doc_items_longdesc = "The stripped wood of an Mangove tree",
	_doc_items_hidden = false,
	tiles ={"mcl_stripped_mangrove_log_top.png","mcl_stripped_mangrove_log_side.png",},
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	stack_max = 64,
	groups = {handy=1, axey=1, tree=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	on_rotate = on_rotate,
	_mcl_blast_resistance = 2,
	_mcl_hardness = 2,
})

--doors and trapdoors--

mcl_doors:register_door("mcl_mangrove:mangrove_door", {
	description = ("Mangrove Door"),
	_doc_items_longdesc = wood_longdesc,
	_doc_items_usagehelp = wood_usagehelp,
	inventory_image = "mcl_mangrove_doors.png",
	groups = {handy=1,axey=1, material_wood=1, flammable=-1},
	_mcl_hardness = 3,
	_mcl_blast_resistance = 3,
	tiles_bottom = {"mcl_mangrove_door_bottom.png", "mcl_mangrove_planks.png"},
	tiles_top = {"mcl_mangrove_door_top.png", "mcl_mangrove_planks.png"},
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "mcl_doors:mangrove_door 3",
	recipe = {
		{"mcl_mangrove:mangrove_wood", "mcl_mangrove:mangrove_wood"},
		{"mcl_mangrove:mangrove_wood", "mcl_mangrove:mangrove_wood"},
		{"mcl_mangrove:mangrove_wood", "mcl_mangrove:mangrove_wood"},
	}
})

local woods = {
	-- id, desc, texture, craftitem
	{ "trapdoor", S("Mangrove Trapdoor"), "mcl_mangrove_trapdoor.png", "mcl_mangrove_planks.png", "mcl_mangrove:mangrove_wood" },}

for w=1, #woods do
	mcl_doors:register_trapdoor("mcl_mangrove:"..woods[w][1], {
		description = woods[w][2],
		_doc_items_longdesc = S("Wooden trapdoors are horizontal barriers which can be opened and closed by hand or a redstone signal. They occupy the upper or lower part of a block, depending on how they have been placed. When open, they can be climbed like a ladder."),
		_doc_items_usagehelp = S("To open or close the trapdoor, rightclick it or send a redstone signal to it."),
		tile_front = woods[w][3],
		tile_side = woods[w][4],
		wield_image = woods[w][3],
		groups = {handy=1,axey=1, mesecon_effector_on=1, material_wood=1, flammable=-1},
		_mcl_hardness = 3,
		_mcl_blast_resistance = 3,
		sounds = mcl_sounds.node_sound_wood_defaults(),
	})

minetest.register_craft({
		output = "mcl_doors:"..woods[w][1].." 2",
		recipe = {
			{woods[w][5], woods[w][5], woods[w][5]},
			{woods[w][5], woods[w][5], woods[w][5]},
		}
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "mcl_doors:"..woods[w][1],
		burntime = 15,
	})
end

-------------------------------

--fence and fence gates--

mcl_fences.register_fence_and_fence_gate(
	"mangrove_wood_fence",
	S("Mangrove Wood Fence"), S("Mangrove Wood Plank Fence"),
	"mcl_mangrove_fence.png",
	{handy=1,axey=1, flammable=2,fence_wood=1, fire_encouragement=5, fire_flammability=20},
	minetest.registered_nodes["mcl_core:wood"]._mcl_hardness,
	minetest.registered_nodes["mcl_core:wood"]._mcl_blast_resistance,
	{"group:fence_wood"},
	mcl_sounds.node_sound_wood_defaults(), "mcl_mangrove_mangrove_wood_fence_gate_open", "mcl_mangrove_mangrove_wood_fence_gate_close", 1, 1,
	"mcl_mangrove_fence_gate.png")

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

---stairs and slabs---

local woods = {
	{ "mangrove_wood", "mcl_mangrove_planks.png", S("Mangrove Wood Stairs"), S("Mangrove Wood Slab"), S("Double Mangrove Wood Slab") },}

for w=1, #woods do
	local wood = woods[w]
	mcl_stairs.register_stair(wood[1], "mcl_core:"..wood[1],
		{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
		{wood[2]},
		wood[3],
		mcl_sounds.node_sound_wood_defaults(), 3, 2,
		"woodlike")
	mcl_stairs.register_slab(wood[1], "mcl_core:"..wood[1],
		{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
		{wood[2]},
		wood[4],
		mcl_sounds.node_sound_wood_defaults(), 3, 2,
		wood[5])
end

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
	stack_max = 64,
	drawtype = "mesh",
	mesh = "node.obj",
	groups = {
		handy = 1, hoey = 1, shearsy = 1, axey = 1,  swordy = 1, dig_by_piston = 0,
		leaves = 1, leafdecay = leafdecay_distance, deco_block = 1,
		flammable = 10, fire_encouragement = 30, fire_flammability = 60,
		compostability = 30
	},
	drop = "mcl_mangrove:mangrove_roots",
	_mcl_shears_drop = true,
	sounds = mcl_sounds.node_sound_leaves_defaults(),			_mcl_blast_resistance = 0.7,
	_mcl_hardness = 0.7,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = { "mcl_mangrove:mangrove_roots 1", "mcl_mangrove:mangrove_roots 2", "mcl_mangrove:mangrove_roots 3", "mcl_mangrove:mangrove_roots 4" },
})

--water can be placed in mangrove roots--
minetest.override_item("mcl_buckets:bucket_water",{
		on_place = function(itemstack, user, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick (pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		-- Place on roots
		if pointed_thing.under and node.name == "mcl_mangrove:mangrove_roots" then
			local protname = user:get_player_name()
			if minetest.is_protected(pointed_thing.under, protname) then
				minetest.record_protection_violation(pointed_thing.under, protname)
				return itemstack
			end
			minetest.set_node(pointed_thing.under, { name = "mcl_mangrove:water_logged_roots", param2 = node.param2 })
			minetest.sound_play("mcl_potions_bottle_pour", {pos=pointed_thing.under, gain=0.9, max_hear_range=16}, true)
				if minetest.is_creative_enabled(user:get_player_name()) then
					return itemstack
				else
					return "mcl_buckets:bucket_empty"
			end
		end
end
})

----flower_potted----------------
mcl_flowerpots.register_potted_flower("mcl_mangrove:propagule", {
	name = "propagule",
	desc = S("Mangrove Propagule"),
	image = "mcl_mangrove_propagule.png",
})

--------------------------------------
--------------------propagule------------------------------

--nodes to be changed into--

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


------------------------
-- node changer--
minetest.override_item("mcl_mangrove:propagule",{
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

-- Place on mud
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
end
})

----------------------------------------------------------------

--water can be taken from mangrove water roots--
minetest.override_item("mcl_buckets:bucket_empty",{
		on_place = function(itemstack, user, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick (pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		-- Place on water roots
		if pointed_thing.under and node.name == "mcl_mangrove:water_logged_roots" then
			local protname = user:get_player_name()
			if minetest.is_protected(pointed_thing.under, protname) then
				minetest.record_protection_violation(pointed_thing.under, protname)
				return itemstack
			end
			minetest.set_node(pointed_thing.under, { name = "mcl_mangrove:mangrove_roots", param2 = node.param2 })
			minetest.sound_play("mcl_potions_bottle_pour", {pos=pointed_thing.under, gain=0.9, max_hear_range=16}, true)
				if minetest.is_creative_enabled(user:get_player_name()) then
					return itemstack
				else
					return "mcl_buckets:bucket_water"
			end
		end
end
})
local water_tex = "default_water_source_animated.png^[verticalframe:16:0"


minetest.register_node("mcl_mangrove:water_logged_roots", {
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
	stack_max = 64,
		groups = {
		handy = 1, hoey = 1, shearsy = 1, swordy = 1, water=3, liquid=3, puts_out_fire=1, dig_by_piston = 1,
		leaves = 1, leafdecay = leafdecay_distance, deco_block = 1,  not_in_creative_inventory=1, fire_encouragement = 0, fire_flammability = 0,
	},
	_mcl_blast_resistance = 100,
	-- Hardness intentionally set to infinite instead of 100 (Minecraft value) to avoid problems in creative mode
	_mcl_hardness = -1,
	after_dig_node = function(pos)
		local node = minetest.get_node(pos)
		if minetest.get_item_group(node.name, "water") == 0 then
			minetest.set_node(pos, {name="mcl_core:water_source"})
		end
	end,
})

------------------------
if minetest.get_modpath("mcl_mud") then
minetest.register_node("mcl_mangrove:mangrove_mud_roots", {
	description = S("Muddy Mangrove Roots"),
	_tt_help = S("crafted with Mud and Mangrove roots"),
	_doc_items_longdesc = S("Muddy Mangrove Roots is a block from mangrove swamp.It drowns player a bit inside it"),
	stack_max = 64,
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

--------craft----------

minetest.register_craft({
		output = "mcl_mangrove:mangrove_mud_roots",
		recipe = {
			{"mcl_mangrove:mangrove_roots", "mcl_mud:mud",},
		}
	})

end

------hanging_propagule-----------
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

------------tree_growth_abm------------

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

----------------------------------------------------------
