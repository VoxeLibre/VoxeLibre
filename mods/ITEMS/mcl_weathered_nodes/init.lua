local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

--Weathered Stone
minetest.register_node("mcl_weathered_nodes:weathered_stone", {
	description = "Weathered stone",
	_doc_items_longdesc = ("Weathered stone is a decorative block that eventually turns into mossy cobblestone"),
	_doc_items_hidden = false,
	tiles = {"mcl_weathered_nodes_weathered_stone.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1, oxidizable = 1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
	_mcl_oxidized_variant = "mcl_core:mossycobble",
	_mcl_waxed_variant = "mcl_core:stone",
})
