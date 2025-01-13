local S = core.get_translator("mcl_cherry_blossom")

-- orig. <https://codeberg.org/mineclonia/mineclonia/src/commit/863e831dd9/mods/ITEMS/mcl_cherry_blossom/init.lua#L50>
--       by cora
core.register_node("mcl_cherry_blossom:pink_petals", {
	description = S("Pink Petals"),
	_doc_items_longdesc = S("Pink Petals are ground decoration of cherry grove biomes."),
	_doc_items_hidden = false,
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = false,
	sunlight_propagates = true,
	floodable = true,
	pointable = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -7/16, 1/2},
	},
	groups = {
		shearsy = 1, handy = 1, flammable = 3, attached_node = 1,
		dig_by_piston = 1, compostability = 30, deco_block = 1
	},
	use_texture_alpha = "clip",
	tiles = {
		"mcl_cherry_blossom_pink_petals.png",
		"mcl_cherry_blossom_pink_petals.png^[transformFY", -- mirror
		"blank.png"
	},
	inventory_image = "mcl_cherry_blossom_pink_petals_inv.png",
	wield_image = "mcl_cherry_blossom_pink_petals_inv.png",
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_hardness = 0,
	_mcl_blast_resistance = 0,
})
