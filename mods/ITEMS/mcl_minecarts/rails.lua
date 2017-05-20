local railuse = "Place them on the ground to build your railway, the rails will automatically connect to each other and will turn into curves, T-junctions, crossings and slopes as needed."

-- Normal rail
minetest.register_node("mcl_minecarts:rail", {
	description = "Rail",
	_doc_items_longdesc = "Rails can be used to build transport tracks for minecarts. Normal rails slightly slow down minecarts due to friction.",
	_doc_items_usagehelp = railuse,
	drawtype = "raillike",
	tiles = {"default_rail.png", "default_rail_curved.png", "default_rail_t_junction.png", "default_rail_crossing.png"},
	is_ground_content = false,
	inventory_image = "default_rail.png",
	wield_image = "default_rail.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
                -- but how to specify the dimensions for curved and sideways rails?
                fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	stack_max = 64,
	groups = {handy=1,pickaxey=1, attached_node=1,rail=1,connect_to_raillike=1,dig_by_water=1,destroy_by_lava_flow=1,transport=1},
	sounds = mcl_sounds.node_sound_defaults(),
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 0.7,
})

minetest.register_craft({
	output = 'mcl_minecarts:rail 16',
	recipe = {
		{'mcl_core:iron_ingot', '', 'mcl_core:iron_ingot'},
		{'mcl_core:iron_ingot', 'mcl_core:stick', 'mcl_core:iron_ingot'},
		{'mcl_core:iron_ingot', '', 'mcl_core:iron_ingot'},
	}
})

-- Rail to speed up
minetest.register_node("mcl_minecarts:golden_rail", {
	description = "Powered Rail",
	_doc_items_longdesc = "Rails can be used to build transport tracks for minecarts. Powered rails will accelerate moving minecarts, up to a maximum speed.",
	_doc_items_usagehelp = railuse,
	drawtype = "raillike",
	tiles = {"carts_rail_pwr.png", "carts_rail_curved_pwr.png", "carts_rail_t_junction_pwr.png", "carts_rail_crossing_pwr.png"},
	inventory_image = "carts_rail_pwr.png",
	wield_image = "carts_rail_pwr.png",
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = "fixed",
		-- but how to specify the dimensions for curved and sideways rails?
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	groups = {handy=1,pickaxey=1, attached_node = 1, rail = 1, connect_to_raillike = 1, dig_by_water = 1,destroy_by_lava_flow=1, transport = 1},
	
	after_place_node = function(pos, placer, itemstack)
		if not mesecon then
			minetest.get_meta(pos):set_string("cart_acceleration", "0.5")
		end
	end,
	sounds = mcl_sounds.node_sound_defaults(),
	mesecons = {
		effector = {
			action_on = function(pos, node)
				mcl_minecarts:boost_rail(pos, 0.5)
			end,
			
			action_off = function(pos, node)
				minetest.get_meta(pos):set_string("cart_acceleration", "0")
			end,
		},
	},
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 0.7,
})

minetest.register_craft({
	output = "mcl_minecarts:golden_rail 6",
	recipe = {
		{"mcl_core:gold_ingot", "", "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", "mcl_core:stick", "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", "mesecons:redstone", "mcl_core:gold_ingot"},
	}
})

