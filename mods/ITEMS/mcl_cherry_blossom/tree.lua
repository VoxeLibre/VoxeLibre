local S = core.get_translator("mcl_cherry_blossom")
local modpath = core.get_modpath("mcl_cherry_blossom")

vl_trees.register_wood("cherry", {
	schematic = function()
		local r = math.random(3)
		return {
			spec = modpath .. "/schematics/mcl_cherry_blossom_tree_"..r..".mts",
			size = {w = 7, h = 8}
		}
	end,
	trunk = {
		description = S("Cherry Log"),
		_doc_items_longdesc = S("The trunk of a cherry blossom tree."),
		tiles = {"mcl_cherry_blossom_log_top.png", "mcl_cherry_blossom_log_top.png", "mcl_cherry_blossom_log.png"},
	},
	stripped_trunk = {
		description = S("Stripped Cherry Log"),
		_doc_items_longdesc = S("The stripped trunk of a cherry blossom tree."),
		tiles = {"mcl_cherry_blossom_log_top_stripped.png", "mcl_cherry_blossom_log_top_stripped.png", "mcl_cherry_blossom_log_stripped.png"},
	},
	bark = {
		description = S("Cherry Bark"),
		_doc_items_longdesc = S("The wood of a cherry blossom tree."),
		tiles = {"mcl_cherry_blossom_log.png"},
	},
	_bark_stairs = S("Cherry Bark Stairs"),
	_bark_slab = S("Cherry Bark Slab"),
	_bark_double_slab = S("Double Cherry Bark Slab"),
	stripped_bark = {
		description = S("Stripped Cherry Bark"),
		_doc_items_longdesc = S("The stripped wood of a cherry blossom tree."),
		tiles = {"mcl_cherry_blossom_log_stripped.png"},
	},
	planks = {
		description = S("Cherry Wood Planks"),
		tiles = {"mcl_cherry_blossom_planks.png"},
	},
	_planks_stairs = S("Cherry Wood Stairs"),
	_planks_slab = S("Cherry Wood Slab"),
	_planks_double_slab = S("Double Cherry Wood Slab"),
	leaves = {
		description = S("Cherry Leaves"),
		_doc_items_longdesc = S("Cherry leaves are grown from cherry blossom trees."),
		tiles = {"mcl_cherry_blossom_leaves.png"},
		paramtype2 = "none",
	},
	sapling = {
		description = S("Cherry Sapling"),
		_doc_items_longdesc = S("When placed on soil (such as dirt) and exposed to light, an oak sapling will grow into an oak after some time."),
		tiles = {"mcl_cherry_blossom_sapling.png"},
		inventory_image = "mcl_cherry_blossom_sapling.png",
		wield_image = "mcl_cherry_blossom_sapling.png",
		selection_box = {
			type = "fixed",
			fixed = {-4/16, -0.5, -4/16, 4/16, 4/16, 4/16},
		},
	},
	_door = {
		description = S("Cherry Door"),
		inventory_image = "mcl_cherry_blossom_door_inv.png",
		tiles_bottom = "mcl_cherry_blossom_door_bottom.png",
		tiles_top = "mcl_cherry_blossom_door_top.png",
	},
	_trapdoor = {
		description = S("Cherry Trapdoor"),
		wield_image = "mcl_cherry_blossom_trapdoor.png",
		tile_front = "mcl_cherry_blossom_trapdoor.png",
		tile_side = "mcl_cherry_blossom_trapdoor_side.png",
	},
	_fences = {
		[2] = S("Cherry Fence"),
		[3] = S("Cherry Fence Gate"),
		[4] = "mcl_cherry_blossom_planks.png",
	},
})
