local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

-- Minecart with Chest
mcl_minecarts.register_minecart({
	itemstring = "mcl_minecarts:chest_minecart",
	craft = {
		output = "mcl_minecarts:chest_minecart",
		recipe = {
			{"mcl_chests:chest"},
			{"mcl_minecarts:minecart"},
		},
	},
	entity_id = "mcl_minecarts:chest_minecart",
	description = S("Minecart with Chest"),
	tt_help = nil,
	longdesc = nil,
	usagehelp = nil,
	initial_properties = {
		mesh = "mcl_minecarts_minecart_chest.b3d",
		textures = {
			"mcl_chests_normal.png",
			"mcl_minecarts_minecart.png"
		},
	},
	icon = "mcl_minecarts_minecart_chest.png",
	drop = {"mcl_minecarts:minecart", "mcl_chests:chest"},
	groups = { container = 1 },
	on_rightclick = nil,
	on_activate_by_rail = nil,
	creative = true
})
mcl_entity_invs.register_inv("mcl_minecarts:chest_minecart",S("Minecart"),27,false,true)
