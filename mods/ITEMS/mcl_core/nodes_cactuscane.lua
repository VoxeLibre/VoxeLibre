-- Cactus and Sugar Cane
local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_node("mcl_core:cactus", {
	description = S("Cactus"),
	_tt_help = S("Grows on sand").."\n"..minetest.colorize(mcl_colors.YELLOW, S("Contact damage: @1 per half second", 1)),
	_doc_items_longdesc = S("This is a piece of cactus commonly found in dry areas, especially deserts. Over time, cacti will grow up to 3 blocks high on sand or red sand. A cactus hurts living beings touching it with a damage of 1 HP every half second. When a cactus block is broken, all cactus blocks connected above it will break as well."),
	_doc_items_usagehelp = S("A cactus can only be placed on top of another cactus or any sand."),
	drawtype = "nodebox",
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "clip" or true,
	tiles = {"mcl_core_cactus_top.png", "mcl_core_cactus_bottom.png", "mcl_core_cactus_side.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {
		handy = 1, attached_node = 1, deco_block = 1, dig_by_piston = 1,
		plant = 1, enderman_takable = 1, compostability = 50
	},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	node_placement_prediction = "",
	_vl_allow_attach = {all = false},
	node_box = {
		type = "fixed",
		fixed = {
			{-7/16, -8/16, -7/16,  7/16, 8/16,  7/16}, -- Main body
			{-8/16, -8/16, -7/16,  8/16, 8/16, -7/16}, -- Spikes
			{-8/16, -8/16,  7/16,  8/16, 8/16,  7/16}, -- Spikes
			{-7/16, -8/16, -8/16, -7/16, 8/16,  8/16}, -- Spikes
			{7/16,  -8/16,  8/16,  7/16, 8/16, -8/16}, -- Spikes
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {-7/16, -8/16, -7/16,  7/16, 7/16,  7/16}, -- Main body. slightly lower than node box
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-7/16, -8/16, -7/16, 7/16, 8/16, 7/16},
		},
	},
	-- Only allow to place cactus on sand or cactus
	on_place = mcl_util.generate_on_place_plant_function(function(pos, node)
		local node_below = minetest.get_node_or_nil(vector.offset(pos, 0, -1, 0))
		return node_below and (node_below.name == "mcl_core:cactus" or minetest.get_item_group(node_below.name, "sand") == 1)
	end),
	_mcl_blast_resistance = 0.4,
	_mcl_hardness = 0.4,
	_mcl_minecarts_on_enter_side = function(pos, _, _, _, cart_data)
		if mcl_minecarts then
			mcl_minecarts.kill_cart(cart_data)
		end
	end,
})

minetest.register_node("mcl_core:reeds", {
	description = S("Sugar Canes"),
	_tt_help = S("Grows on sand or dirt next to water"),
	_doc_items_longdesc = S("Sugar canes are a plant which has some uses in crafting. Sugar canes will slowly grow up to 3 blocks when they are next to water and are placed on a grass block, dirt, sand, red sand, podzol or coarse dirt. When a sugar cane is broken, all sugar canes connected above will break as well."),
	_doc_items_usagehelp = S("Sugar canes can only be placed top of other sugar canes and on top of blocks on which they would grow."),
	drawtype = "plantlike",
	paramtype2 = "color",
	tiles = {"mcl_core_papyrus.png"},
	palette = "mcl_core_palette_grass.png",
	palette_index = 0,
	inventory_image = "mcl_core_reeds.png",
	wield_image = "mcl_core_reeds.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-7/16, -8/16, -7/16,  7/16, 8/16,  7/16}, -- Main Body
			{-8/16, -8/16, -7/16,  8/16, 8/16, -7/16}, -- Spikes
			{-8/16, -8/16,  7/16,  8/16, 8/16,  7/16}, -- Spikes
			{-7/16, -8/16, -8/16, -7/16, 8/16,  8/16}, -- Spikes
			{7/16,  -8/16,  8/16,  7/16, 8/16, -8/16}, -- Spikes
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-6/16, -8/16, -6/16, 6/16, 8/16, 6/16},
		},
	},
	stack_max = 64,
	groups = {
		dig_immediate = 3, craftitem = 1, deco_block = 1, dig_by_piston = 1,
		plant = 1, non_mycelium_plant = 1, compostability = 50, grass_palette = 1
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	node_placement_prediction = "",
	drop = "mcl_core:reeds", -- to prevent color inheritation
	on_place = mcl_util.generate_on_place_plant_function(function(place_pos, place_node)
		local soil_pos = vector.offset(place_pos, 0, -1, 0)
		local soil_node = minetest.get_node_or_nil(soil_pos)
		if not soil_node then return false end
		local snn = soil_node.name -- soil node name

		-- Placement rules:
		-- * On top of group:soil_sugarcane AND next to water or frosted ice. OR
		-- * On top of sugar canes
		-- * Not inside liquid
		if snn == "mcl_core:reeds" then
			return true
		elseif minetest.get_item_group(snn, "soil_sugarcane") == 0 then
			return false
		end
		local place_node = minetest.get_node(place_pos)
		local pdef = minetest.registered_nodes[place_node.name]
		if pdef and pdef.liquidtype ~= "none" then
			return false
		end

		-- Legal water position rules are the same as for decoration spawn_by rules.
		-- This differs from MC, which does not allow diagonal neighbors
		-- and neighbors 1 layer above.
		if #minetest.find_nodes_in_area(vector.offset(soil_pos, -1, 0, -1), vector.offset(soil_pos, 1, 1, 1), {"group:water", "group:frosted_ice"}) > 0 then
			-- Water found! Sugar canes are happy! :-)
			return true
		end
		-- No water found! Sugar canes are not amuzed and refuses to be placed. :-(
		return false
	end),
	on_construct = function(pos)
		local node = minetest.get_node(pos)
		if node.param2 == 0 then
			node.param2 = mcl_util.get_palette_indexes_from_pos(pos).grass_palette_index
			if node.param2 ~= 0 then
				minetest.set_node(pos, node)
			end
		end
	end,
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
})
