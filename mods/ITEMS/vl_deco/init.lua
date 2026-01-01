local modname = core.get_current_modname()

local S = core.get_translator(modname)

local mod_sounds = core.get_modpath("mcl_sounds")

-- Star

core.register_node("vl_deco:star", {
	description = S("Decorative Star"),
	drawtype = "plantlike",
	tiles = { "vl_deco_star.png" },
	inventory_image = "vl_deco_star.png",
	wield_image = "vl_deco_star.png",
	paramtype = "light",
	light_source = core.LIGHT_MAX,
	groups = { deco_block=1 },
	sounds = mod_sounds and mcl_sounds.node_sound_glass_defaults() or {},
	_mcl_hardness = 0.3,
	_mcl_blast_resistance = 0.3,
})

core.register_craft({
	output = "vl_deco:star 3",
	recipe = {
		{ "mcl_nether:glowstone", "mcl_nether:glowstone", "mcl_nether:glowstone" },
		{ "mcl_nether:glowstone", "mcl_mobitems:nether_star", "mcl_nether:glowstone" },
		{ "mcl_nether:glowstone", "mcl_nether:glowstone", "mcl_nether:glowstone" }
	}
})

-- Scarab
	
local scarab_box = {
	type = "fixed",
	fixed = {{-0.375, -0.3125, 0.5, 0.375, 0.3125, 0.3125}}
}

core.register_node("vl_deco:scarab", {
	collision_box = scarab_box,
	selection_box = scarab_box,
	description = S("Scarab"),
	_doc_items_longdesc = S("Scarab is a collectible item that can only be found in desert temples. It can be placed on walls as decoration."),
	_doc_items_usagehelp = S("Rightclick the side of the block you want to place the scarab on."),
	_doc_items_hidden = false,
	drawtype = "mesh",
	mesh = "vl_deco_scarab.obj",
	tiles = { "vl_deco_scarab.png" },
	inventory_image = "vl_deco_scarab.png",
	wield_image = "vl_deco_scarab.png",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { 
		deco_block=1,
		collectible=1,
		supported_node_facedir=1,
		handy=1,
		pickaxey=1,
		dig_by_water=1,
		destroy_by_lava_flow=1,
		dig_by_piston=1
	},
	sounds = mod_sounds and mcl_sounds.node_sound_metal_defaults() or {},
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	_mcl_hardness = 0.3,
	_mcl_blast_resistance = 0.3,
})
