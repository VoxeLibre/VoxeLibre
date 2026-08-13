-- repair crafting recipes for deepslate, as it was removed from the cobble group.
local d = "mcl_deepslate:deepslate_cobbled"

-- furnace
core.register_craft({
	output = "mcl_furnaces:furnace",
	recipe = {
		{ d, d, d },
		{ d, "", d },
		{ d, d, d },
	}
})

-- Piston
core.register_craft({
	output = "mesecons_pistons:piston_normal_off",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{d, "mcl_core:iron_ingot", d},
		{d, "mesecons:redstone", d},
	},
})

-- Dropper
core.register_craft({
	output = "mcl_droppers:dropper",
	recipe = {
		{ d, d, d, },
		{ d, "", d, },
		{ d, "mesecons:redstone", d, },
	}
})

-- Observer
core.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ d, d, d },
		{ "mcl_nether:quartz", "mesecons:redstone", "mesecons:redstone" },
		{ d, d, d },
	},
})
core.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ d, d, d },
		{ "mesecons:redstone", "mesecons:redstone", "mcl_nether:quartz" },
		{ d, d, d },
	},
})
