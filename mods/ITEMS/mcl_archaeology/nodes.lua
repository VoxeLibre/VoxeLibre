local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_node("mcl_archaeology:suspicious_sand", {
	description = S("Suspicious Sand"),
	tiles = {"mcl_archaeology_suspicious_sand.png"},
	groups = { handy = 1, shovely = 1, falling_node = 1,
		   dig_by_piston = 1, dig_immediate_piston = 1 },
	sounds = mcl_sounds.node_sound_sand_defaults(),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

minetest.register_node("mcl_archaeology:suspicious_gravel", {
	description = S("Suspicious Gravel"),
	tiles = {"mcl_archaeology_suspicious_gravel.png"},
	groups = { handy = 1, shovely = 1, falling_node = 1,
		   dig_by_piston = 1, dig_immediate_piston = 1 },
	sounds = mcl_sounds.node_sound_gravel_defaults(),
	_mcl_blast_resistance = 0.6,
	_mcl_hardness = 0.6,
})

minetest.register_node("mcl_archaeology:decorated_pot", {
	description = S("Decorated Pot"),
	tiles = {
		"mcl_archaeology_decorated_pot_top.png",
		"mcl_archaeology_decorated_pot_bottom.png",
		"mcl_archaeology_decorated_pot_side.png",
		"mcl_archaeology_decorated_pot_side.png",
		"mcl_archaeology_decorated_pot_side.png",
		"mcl_archaeology_decorated_pot_side.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, -0.4375, 0.4375, 0.5, 0.4375}, -- base
			{-0.1875, 0.5, -0.1875, 0.1875, 0.5625, 0.1875}, -- neck (bottom part)
			{-0.25, 0.5625, -0.25, 0.25, 0.6875, 0.25}, -- neck (top part)
		}
	},
	--drops = {},
	groups = { handy = 1 },
	_mcl_silk_touch_drop = true -- TODO: different sound when breaking with silk touch
})

-- normal, non-pattern recipe
minetest.register_craft({
	output = "mcl_archaeology:decorated_pot",
	recipe = {
		{"", "group:pottery", ""},
		{"group:pottery", "", "group:pottery"},
		{"", "group:pottery", ""},
	}
})
