-- Template rail function
local register_rail = function(itemstring, tiles, def_extras, creative)
	local groups = {handy=1,pickaxey=1, attached_node=1,rail=1,connect_to_raillike=1,dig_by_water=1,destroy_by_lava_flow=1, transport=1}
	if creative == false then
		groups.not_in_creative_inventory = 1
	end
	local ndef = {
		drawtype = "raillike",
		tiles = tiles,
		is_ground_content = false,
		inventory_image = tiles[1],
		wield_image = tiles[1],
		paramtype = "light",
		walkable = false,
		selection_box = {
			type = "fixed",
			fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
		},
		stack_max = 64,
		groups = groups,
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 3.5,
		_mcl_hardness = 0.7,
	}
	if def_extras then
		for k,v in pairs(def_extras) do
			ndef[k] = v
		end
	end
	minetest.register_node(itemstring, ndef)
end

local railuse = "Place them on the ground to build your railway, the rails will automatically connect to each other and will turn into curves, T-junctions, crossings and slopes as needed."

-- Normal rail
register_rail("mcl_minecarts:rail",
	{"default_rail.png", "default_rail_curved.png", "default_rail_t_junction.png", "default_rail_crossing.png"},
	{
		description = "Rail",
		_doc_items_longdesc = "Rails can be used to build transport tracks for minecarts. Normal rails slightly slow down minecarts due to friction.",
		_doc_items_usagehelp = railuse,
	}
)

-- Powered rail (off = brake mode)
register_rail("mcl_minecarts:golden_rail",
	{"carts_rail_pwr.png", "carts_rail_curved_pwr.png", "carts_rail_t_junction_pwr.png", "carts_rail_crossing_pwr.png"},
	{
		description = "Powered Rail",
		_doc_items_longdesc = "Rails can be used to build transport tracks for minecarts. Powered rails are able to accelerate and brake minecarts.",
		_doc_items_usagehelp = railuse .. "\n" .. "Without redstone power, the rail will brake minecarts. To make this rail accelerate minecarts, power it with redstone power.",
		_rail_acceleration = -3,
		mesecons = {
			conductor = {
				state = mesecon.state.off,
				onstate = "mcl_minecarts:golden_rail_on",
			},
		},
	}
)

-- Powered rail (on = acceleration mode)
register_rail("mcl_minecarts:golden_rail_on",
	{"mcl_minecarts_rail_golden_powered.png", "mcl_minecarts_rail_golden_curved_powered.png", "mcl_minecarts_rail_golden_t_junction_powered.png", "mcl_minecarts_rail_golden_crossing_powered.png"},
	{
		_doc_items_create_entry = false,
		_rail_acceleration = 4,
		mesecons = {
			conductor = {
				state = mesecon.state.on,
				offstate = "mcl_minecarts:golden_rail",
			},
		},
	},
	false
)


-- Crafting
minetest.register_craft({
	output = 'mcl_minecarts:rail 16',
	recipe = {
		{'mcl_core:iron_ingot', '', 'mcl_core:iron_ingot'},
		{'mcl_core:iron_ingot', 'mcl_core:stick', 'mcl_core:iron_ingot'},
		{'mcl_core:iron_ingot', '', 'mcl_core:iron_ingot'},
	}
})

minetest.register_craft({
	output = "mcl_minecarts:golden_rail 6",
	recipe = {
		{"mcl_core:gold_ingot", "", "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", "mcl_core:stick", "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", "mesecons:redstone", "mcl_core:gold_ingot"},
	}
})

-- Aliases
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_minecarts:golden_rail", "nodes", "mcl_minecarts:golden_rail_on")
end

