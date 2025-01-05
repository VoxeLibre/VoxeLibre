local modname = minetest.get_current_modname()
local mod = mcl_minecarts
local S = minetest.get_translator(modname)

-- Powered rail (off = brake mode)
mod.register_curves_rail("mcl_minecarts:golden_rail_v2",{
	"mcl_minecarts_rail_golden.png",
	"mcl_minecarts_rail_golden_curved.png",
	"mcl_minecarts_rail_golden_t_junction.png",
	"mcl_minecarts_rail_golden_t_junction.png",
	"mcl_minecarts_rail_golden_crossing.png"
},{
	description = S("Powered Rail"),
	_tt_help = S("Track for minecarts").."\n"..S("Speed up when powered, slow down when not powered"),
	_doc_items_longdesc = S("Rails can be used to build transport tracks for minecarts. Powered rails are able to accelerate and brake minecarts."),
	_doc_items_usagehelp = mod.text.railuse .. "\n" .. S("Without redstone power, the rail will brake minecarts. To make this rail accelerate"..
		" minecarts, power it with redstone power."),
	_doc_items_create_entry = false,
	_rail_acceleration = -3,
	_max_acceleration_velocity = 8,
	mesecons = {
		conductor = {
			state = mesecon.state.off,
			offstate = "mcl_minecarts:golden_rail_v2",
			onstate  = "mcl_minecarts:golden_rail_v2_on",
			rules = mod.rail_rules_long,
		},
	},
	drop = "mcl_minecarts:golden_rail_v2",
	craft = {
		output = "mcl_minecarts:golden_rail_v2 6",
		recipe = {
			{"mcl_core:gold_ingot", "", "mcl_core:gold_ingot"},
			{"mcl_core:gold_ingot", "mcl_core:stick", "mcl_core:gold_ingot"},
			{"mcl_core:gold_ingot", "mesecons:redstone", "mcl_core:gold_ingot"},
		}
	}
})

-- Powered rail (on = acceleration mode)
mod.register_curves_rail("mcl_minecarts:golden_rail_v2_on",{
	"mcl_minecarts_rail_golden_powered.png",
	"mcl_minecarts_rail_golden_curved_powered.png",
	"mcl_minecarts_rail_golden_t_junction_powered.png",
	"mcl_minecarts_rail_golden_t_junction_powered.png",
	"mcl_minecarts_rail_golden_crossing_powered.png",
},{
	description = S("Powered Rail"),
	_doc_items_create_entry = false,
	_rail_acceleration = function(pos, staticdata)
		if staticdata.velocity ~= 0 then
			return 4
		end

		local dir = mod.get_rail_direction(pos, staticdata.dir, nil, nil, staticdata.railtype)
		local node_a = minetest.get_node(vector.add(pos, dir))
		local node_b = minetest.get_node(vector.add(pos, -dir))
		local has_adjacent_solid = minetest.get_item_group(node_a.name, "solid") ~= 0 or
		                           minetest.get_item_group(node_b.name, "solid") ~= 0 or
		                           minetest.get_item_group(node_a.name, "stair") ~= 0 or
		                           minetest.get_item_group(node_b.name, "stair") ~= 0

		if has_adjacent_solid then
			return 4
		else
			return 0
		end
	end,
	_max_acceleration_velocity = 8,
	groups = {
		not_in_creative_inventory = 1,
	},
	mesecons = {
		conductor = {
			state = mesecon.state.on,
			offstate = "mcl_minecarts:golden_rail_v2",
			onstate  = "mcl_minecarts:golden_rail_v2_on",
			rules = mod.rail_rules_long,
		},
	},
	drop = "mcl_minecarts:golden_rail_v2",
})

