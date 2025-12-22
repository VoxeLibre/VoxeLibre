local modname = core.get_current_modname()

local S = core.get_translator(modname)

core.register_node("vl_deco:star", {
	description = S("Decorative Star"),
	drawtype = "plantlike",
	tiles = { "vl_deco_star.png" },
	inventory_image = "vl_deco_star.png",
	wield_image = "vl_deco_star.png",
	paramtype = "light",
	light_source = core.LIGHT_MAX,
})

core.register_craft({
	output = "vl_deco:star 3",
	recipe = {
		{ "mcl_nether:glowstone", "mcl_nether:glowstone", "mcl_nether:glowstone" },
		{ "mcl_nether:glowstone", "mcl_mobitems:nether_star", "mcl_nether:glowstone" },
		{ "mcl_nether:glowstone", "mcl_nether:glowstone", "mcl_nether:glowstone" }
	}
})
