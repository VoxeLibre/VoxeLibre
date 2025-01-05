local modname = minetest.get_current_modname()
local mod = mcl_minecarts
local S = minetest.get_translator(modname)

local rail_rules_short = mesecon.rules.pplate

-- Detector rail (off)
mod.register_curves_rail("mcl_minecarts:detector_rail_v2",{
	"mcl_minecarts_rail_detector.png",
	"mcl_minecarts_rail_detector_curved.png",
	"mcl_minecarts_rail_detector_t_junction.png",
	"mcl_minecarts_rail_detector_t_junction.png",
	"mcl_minecarts_rail_detector_crossing.png"
},{
	description = S("Detector Rail"),
	_tt_help = S("Track for minecarts").."\n"..S("Emits redstone power when a minecart is detected"),
	_doc_items_longdesc = S("Rails can be used to build transport tracks for minecarts. A detector rail is able to detect a minecart above it and powers redstone mechanisms."),
	_doc_items_usagehelp = mod.text.railuse .. "\n" .. S("To detect a minecart and provide redstone power, connect it to redstone trails or redstone mechanisms and send any minecart over the rail."),
	mesecons = {
		receptor = {
			state = mesecon.state.off,
			rules = rail_rules_short,
		},
	},
	_mcl_minecarts_on_enter = function(pos, cart)
		local node = minetest.get_node(pos)
		local node_def = minetest.registered_nodes[node.name]
		node.name = "mcl_minecarts:detector_rail_v2_on"..node_def._mcl_minecarts.suffix
		minetest.set_node( pos, node )
		mesecon.receptor_on(pos)
	end,
	craft = {
		output = "mcl_minecarts:detector_rail_v2 6",
		recipe = {
			{"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
			{"mcl_core:iron_ingot", "mesecons_pressureplates:pressure_plate_stone_off", "mcl_core:iron_ingot"},
			{"mcl_core:iron_ingot", "mesecons:redstone", "mcl_core:iron_ingot"},
		}
	}
})

-- Detector rail (on)
mod.register_curves_rail("mcl_minecarts:detector_rail_v2_on",{
	"mcl_minecarts_rail_detector_powered.png",
	"mcl_minecarts_rail_detector_curved_powered.png",
	"mcl_minecarts_rail_detector_t_junction_powered.png",
	"mcl_minecarts_rail_detector_t_junction_powered.png",
	"mcl_minecarts_rail_detector_crossing_powered.png"
},{
	description = S("Detector Rail"),
	groups = {
		not_in_creative_inventory = 1,
	},
	_doc_items_create_entry = false,
	mesecons = {
		receptor = {
			state = mesecon.state.on,
			rules = rail_rules_short,
		},
	},
	_mcl_minecarts_on_leave = function(pos, cart)
		local node = minetest.get_node(pos)
		local node_def = minetest.registered_nodes[node.name]
		node.name = "mcl_minecarts:detector_rail_v2"..node_def._mcl_minecarts.suffix
		minetest.set_node( pos, node )
		mesecon.receptor_off(pos)
	end,
	drop = "mcl_minecarts:detector_rail_v2",
})

