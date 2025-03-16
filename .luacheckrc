---@diagnostic disable

unused_args = false
allow_defined_top = true
max_line_length = false
redefined = false

globals = {
	"minetest", "core",
}

read_globals = {
	"DIR_DELIM",
	"dump", "dump2",
	"vector",
	"VoxelManip", "VoxelArea",
	"PseudoRandom", "PcgRandom", "PerlinNoise", "PerlinNoiseMap",
	"ItemStack",
	"Settings",
	"unpack",

	table = {
		fields = {
			"copy",
			"indexof",
			"insert_all",
			"key_value_swap",
			"shuffle",
			"update",
			"update_nil",
			"update_deep",
			"merge",
			"merge_deep",
			"pairs_by_keys",
			"intersect",
			"remove_random_element",
		}
	},

	string = {
		fields = {
			"split",
			"trim",
		}
	},

	math = {
		fields = {
			"hypot",
			"sign",
			"factorial"
		}
	},
	------
	--MODS
	------

	--GENERAL
	"default",

	--ENTITIES
	"cmi",

	--HUD
	"sfinv", "sfinv_buttons", "unified_inventory", "cmsg", "inventory_plus",
}
