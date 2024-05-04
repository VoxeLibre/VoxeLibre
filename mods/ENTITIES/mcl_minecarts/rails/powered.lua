local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local mod = mcl_minecarts
local S = minetest.get_translator(modname)

-- Powered rail (off = brake mode)
mod.register_straight_rail("mcl_minecarts:golden_rail_v2",{ "mcl_minecarts_rail_golden.png" },{
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
	mesecons_sloped = {
		conductor = {
			state = mesecon.state.off,
			offstate = "mcl_minecarts:golden_rail_v2_sloepd",
			onstate  = "mcl_minecarts:golden_rail_v2_on_sloped",
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
mod.register_straight_rail("mcl_minecarts:golden_rail_v2_on",{ "mcl_minecarts_rail_golden_powered.png" },{
	_doc_items_create_entry = false,
	_rail_acceleration = 4,
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
	mesecons_sloped = {
		conductor = {
			state = mesecon.state.on,
			offstate = "mcl_minecarts:golden_rail_v2_sloped",
			onstate  = "mcl_minecarts:golden_rail_v2_on_sloped",
			rules = mod.rail_rules_long,
		},
	},
	drop = "mcl_minecarts:golden_rail_v2",
})

