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
	sounds = mcl_sounds.node_sound_metal_defaults(),
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


-- Powered rail
local powered_rail_template = {
	description = "Powered Rail",
	_doc_items_longdesc = "Rails can be used to build transport tracks for minecarts. Powered rails are able to accelerate and brake minecarts.",
	_doc_items_usagehelp = railuse .. "\n" .. "Without redstone power, the rail will brake minecarts. To make this rail accelerate minecarts, power it with redstone power.",
	drawtype = "raillike",
	tiles = {"carts_rail_pwr.png", "carts_rail_curved_pwr.png", "carts_rail_t_junction_pwr.png", "carts_rail_crossing_pwr.png"},
	inventory_image = "carts_rail_pwr.png",
	wield_image = "carts_rail_pwr.png",
	paramtype = "light",
	is_ground_content = false,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	groups = {handy=1,pickaxey=1, attached_node = 1, rail = 1, connect_to_raillike = 1, dig_by_water = 1,destroy_by_lava_flow=1, transport = 1},

	sounds = mcl_sounds.node_sound_metal_defaults(),
	mesecons = {
		conductor = {
			state = mesecon.state.off,
			onstate = "mcl_minecarts:golden_rail_on",
		},
	},

	_rail_acceleration = -3,
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 0.7,
}
minetest.register_node("mcl_minecarts:golden_rail", powered_rail_template)


-- Powered rail (activated by redstone)
local powered_rail_on = table.copy(powered_rail_template)
powered_rail_on.description = nil
powered_rail_on._doc_items_create_entry = false
powered_rail_on._doc_items_longdesc = nil
powered_rail_on._doc_items_usagehelp = nil
powered_rail_on.tiles = {"mcl_minecarts_rail_golden_powered.png", "mcl_minecarts_rail_golden_curved_powered.png", "mcl_minecarts_rail_golden_t_junction_powered.png", "mcl_minecarts_rail_golden_crossing_powered.png"}
powered_rail_on.inventory_image = "mcl_minecarts_rail_golden_powered.png"
powered_rail_on.wield_image = "mcl_minecarts_rail_golden_powered.png"
powered_rail_on.groups.not_in_creative_inventory = 1
powered_rail_on.groups.transport = nil
powered_rail_on.mesecons = {
	conductor = {
		state = mesecon.state.on,
		offstate = "mcl_minecarts:golden_rail",
	}
}
powered_rail_on._rail_acceleration = 4

minetest.register_node("mcl_minecarts:golden_rail_on", powered_rail_on)

if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_minecarts:golden_rail", "nodes", "mcl_minecarts:golden_rail_on")
end

minetest.register_craft({
	output = "mcl_minecarts:golden_rail 6",
	recipe = {
		{"mcl_core:gold_ingot", "", "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", "mcl_core:stick", "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", "mesecons:redstone", "mcl_core:gold_ingot"},
	}
})

