-- "Core" woods: Acacia, Birch, Jungle, Oak, Dark Oak, Spruce

local modname = core.get_current_modname()
local S = core.get_translator(modname)
local modpath = core.get_modpath(modname)

local math_min, math_random = math.min, math.random

vl_trees.register_wood("oak", {
	schematic = function()
		-- Balloon oak
		if math_random(1, 12) == 1 then
			-- Small balloon oak
			if math_random(1, 12) == 1 then
				return {
					spec = modpath .. "/schematics/mcl_core_oak_balloon.mts",
					--size = {w = 7, h = 11},
				}
			end

			-- Large balloon oak
			local t = math_random(1, 4)
			return {
				spec = modpath .. "/schematics/mcl_core_oak_large_"..t..".mts",
				--size = {w = 7, h = 11},
			}
		end
		-- Small oak
		return {
			spec = modpath .. "/schematics/mcl_core_oak_classic.mts",
			--size = {w = 3, h = 5},
		}
	end,
	trunk = {
		description = S("Oak Log"),
		_doc_items_longdesc = S("The trunk of an oak tree."),
		tiles = {"default_tree_top.png", "default_tree_top.png", "default_tree.png"},
	},
	stripped_trunk = {
		description = S("Stripped Oak Log"),
		_doc_items_longdesc = S("The stripped trunk of an oak tree."),
		tiles = {"mcl_core_stripped_oak_top.png", "mcl_core_stripped_oak_top.png", "mcl_core_stripped_oak_side.png"},
	},
	bark = {
		description = S("Oak Bark"),
		_doc_items_longdesc = S("The wood of an oak tree."),
		tiles = {"default_tree.png"},
	},
	stripped_bark = {
		description = S("Stripped Oak Bark"),
		_doc_items_longdesc = S("The stripped wood of an oak tree."),
		tiles = {"mcl_core_stripped_oak_side.png"},
	},
	planks = {
		description = S("Oak Wood Planks"),
		tiles = {"default_wood.png"},
	},
	leaves = {
		description = S("Oak Leaves"),
		_doc_items_longdesc = S("Oak leaves are grown from oak trees."),
		tiles = {"default_leaves.png"},
		color = "#77ab2f",
	},
	sapling = {
		description = S("Oak Sapling"),
		_doc_items_longdesc = S("When placed on soil (such as dirt) and exposed to light, an oak sapling will grow into an oak after some time."),
		tiles = {"default_sapling.png"},
		inventory_image = "default_sapling.png",
		wield_image = "default_sapling.png",
		selection_box = {
			type = "fixed",
			fixed = {-5/16, -0.5, -5/16, 5/16, 0.5, 5/16},
		},
	},
	fruit = {
		name = "apple",
		description = S("Apple"),
		_doc_items_longdesc = S("Apples are food items which can be eaten."),
		inventory_image = "default_apple.png",
		wield_image = "default_apple.png",
	},
})

vl_trees.register_wood("dark_oak", {
	schematic_2x2 = {
		spec = modpath .. "/schematics/mcl_core_dark_oak.mts",
		size = {w = 4, h = 7},
	},
	trunk = {
		description = S("Dark Oak Log"),
		_doc_items_longdesc = S("The trunk of a dark oak tree."),
		tiles = {"mcl_core_log_big_oak_top.png", "mcl_core_log_big_oak_top.png", "mcl_core_log_big_oak.png"},
	},
	stripped_trunk = {
		description = S("Stripped Dark Oak Log"),
		_doc_items_longdesc = S("The stripped trunk of a dark oak tree."),
		tiles = {"mcl_core_stripped_dark_oak_top.png", "mcl_core_stripped_dark_oak_top.png", "mcl_core_stripped_dark_oak_side.png"},
	},
	bark = {
		description = S("Dark Oak Bark"),
		_doc_items_longdesc = S("The wood of a dark oak tree."),
		tiles = {"mcl_core_log_big_oak.png"},
	},
	stripped_bark = {
		description = S("Stripped Dark Oak Bark"),
		_doc_items_longdesc = S("The stripped wood of a dark oak tree."),
		tiles = {"mcl_core_stripped_dark_oak_side.png"},
	},
	planks = {
		description = S("Dark Oak Wood Planks"),
		tiles = {"mcl_core_planks_big_oak.png"},
	},
	leaves = {
		description = S("Dark Oak Leaves"),
		_doc_items_longdesc = S("Dark oak leaves are grown from dark oak trees."),
		tiles = {"mcl_core_leaves_big_oak.png"},
		color = "#77ab2f",
	},
	sapling = {
		description = S("Dark Oak Sapling"),
		_doc_items_longdesc = S("When placed on soil (such as dirt) and exposed to light, a dark oak sapling will grow into a dark oak after some time."),
		tiles = {"mcl_core_sapling_big_oak.png"},
		inventory_image = "mcl_core_sapling_big_oak.png",
		wield_image = "mcl_core_sapling_big_oak.png",
		selection_box = {
			type = "fixed",
			fixed = {-5/16, -0.5, -5/16, 5/16, 7/16, 5/16},
		},
	},
	fruit = "mcl_core:acorn",
})

vl_trees.register_wood("acacia", {
	schematic = function()
		local t = math_random(1, 7)
		return {
			spec = modpath .. "/schematics/mcl_core_acacia_"..t..".mts",
			size = {w = 7, h = 8},
		}
	end,
	trunk = {
		description = S("Acacia Log"),
		_doc_items_longdesc = S("The trunk of an acacia tree."),
		tiles = {"default_acacia_tree_top.png", "default_acacia_tree_top.png", "default_acacia_tree.png"},
	},
	stripped_trunk = {
		description = S("Stripped Acacia Log"),
		_doc_items_longdesc = S("The stripped trunk of an acacia tree."),
		tiles = {"mcl_core_stripped_acacia_top.png", "mcl_core_stripped_acacia_top.png", "mcl_core_stripped_acacia_side.png"},
	},
	bark = {
		description = S("Acacia Bark"),
		_doc_items_longdesc = S("The wood of an acacia tree."),
		tiles = {"default_acacia_tree.png"},
	},
	stripped_bark = {
		description = S("Stripped Acacia Bark"),
		_doc_items_longdesc = S("The stripped wood of an acacia tree."),
		tiles = {"mcl_core_stripped_acacia_side.png"},
	},
	planks = {
		description = S("Acacia Wood Planks"),
		tiles = {"default_acacia_wood.png"},
	},
	leaves = {
		description = S("Acacia Leaves"),
		_doc_items_longdesc = S("Acacia leaves are grown from acacia trees."),
		tiles = {"default_acacia_leaves.png"},
		color = "#48B518",
	},
	sapling = {
		description = S("Acacia Sapling"),
		_doc_items_longdesc = S("When placed on soil (such as dirt) and exposed to light, an acacia sapling will grow into an acacia after some time."),
		tiles = {"default_acacia_sapling.png"},
		inventory_image = "default_acacia_sapling.png",
		wield_image = "default_acacia_sapling.png",
		selection_box = {
			type = "fixed",
			fixed = {-5/16, -0.5, -5/16, 5/16, 4/16, 5/16},
		},
	},
})

vl_trees.register_wood("birch", {
	schematic = {
		spec = modpath .. "/schematics/mcl_core_birch.mts",
		size = {w = 3, h = 6},
	},
	trunk = {
		description = S("Birch Log"),
		_doc_items_longdesc = S("The trunk of a birch tree."),
		tiles = {"mcl_core_log_birch_top.png", "mcl_core_log_birch_top.png", "mcl_core_log_birch.png"},
	},
	stripped_trunk = {
		description = S("Stripped Birch Log"),
		_doc_items_longdesc = S("The stripped trunk of a birch tree."),
		tiles = {"mcl_core_stripped_birch_top.png", "mcl_core_stripped_birch_top.png", "mcl_core_stripped_birch_side.png"},
	},
	bark = {
		description = S("Birch Bark"),
		_doc_items_longdesc = S("The wood of a birch tree."),
		tiles = {"mcl_core_log_birch.png"},
	},
	stripped_bark = {
		description = S("Stripped Birch Bark"),
		_doc_items_longdesc = S("The stripped wood of a birch tree."),
		tiles = {"mcl_core_stripped_birch_side.png"},
	},
	planks = {
		description = S("Birch Wood Planks"),
		tiles = {"mcl_core_planks_birch.png"},
	},
	leaves = {
		description = S("Birch Leaves"),
		_doc_items_longdesc = S("Birch leaves are grown from birch trees."),
		tiles = {"mcl_core_leaves_birch.png"},
		color = "#68a55f",
	},
	sapling = {
		description = S("Birch Sapling"),
		_doc_items_longdesc = S("When placed on soil (such as dirt) and exposed to light, a birch sapling will grow into a birch after some time."),
		tiles = {"mcl_core_sapling_birch.png"},
		inventory_image = "mcl_core_sapling_birch.png",
		wield_image = "mcl_core_sapling_birch.png",
		selection_box = {
			type = "fixed",
			fixed = {-4/16, -0.5, -4/16, 4/16, 0.5, 4/16},
		},
	},
})

vl_trees.register_wood("jungle", {
	schematic = {
		spec = modpath .. "/schematics/mcl_core_jungle_tree.mts",
		size = {w = 3, h = 8},
	},
	schematic_2x2 = function()
		local t = math_random(1, 2)
		return {
			spec = modpath .. "/schematics/mcl_core_jungle_tree_huge_"..t..".mts",
			size = {w = 3, h = 8},
		}
	end,
	drop_chances = {
		sapling = {40, 26, 32, 24, 10},
	},
	trunk = {
		description = S("Jungle Log"),
		_doc_items_longdesc = S("The trunk of a jungle tree."),
		tiles = {"default_jungletree_top.png", "default_jungletree_top.png", "default_jungletree.png"},
	},
	stripped_trunk = {
		description = S("Stripped Jungle Log"),
		_doc_items_longdesc = S("The stripped trunk of a jungle tree."),
		tiles = {"mcl_core_stripped_jungle_top.png", "mcl_core_stripped_jungle_top.png", "mcl_core_stripped_jungle_side.png"},
	},
	bark = {
		description = S("Jungle Bark"),
		_doc_items_longdesc = S("The wood of a jungle tree."),
		tiles = {"default_jungletree.png"},
	},
	stripped_bark = {
		description = S("Stripped Jungle Bark"),
		_doc_items_longdesc = S("The stripped wood of a jungle tree."),
		tiles = {"mcl_core_stripped_jungle_side.png"},
	},
	planks = {
		description = S("Jungle Wood Planks"),
		tiles = {"default_junglewood.png"},
	},
	leaves = {
		description = S("Jungle Leaves"),
		_doc_items_longdesc = S("Jungle leaves are grown from jungle trees."),
		tiles = {"default_jungleleaves.png"},
		color = "#30bb0b",
	},
	sapling = {
		description = S("Jungle Sapling"),
		_doc_items_longdesc = S("When placed on soil (such as dirt) and exposed to light, a jungle sapling will grow into a jungle tree after some time. When there are 4 jungle saplings in a 2×2 square, they will grow to a huge jungle tree."),
		tiles = {"default_junglesapling.png"},
		inventory_image = "default_junglesapling.png",
		wield_image = "default_junglesapling.png",
		selection_box = {
			type = "fixed",
			fixed = {-5/16, -0.5, -5/16, 5/16, 0.5, 5/16},
		},
	},
})

vl_trees.register_wood("spruce", {
	schematic = function()
		local t = math_random(1, 3)
		return {
			spec = modpath .. "/schematics/mcl_core_spruce_"..t..".mts",
			size = {w = 5, h = 11},
		}
	end,
	schematic_2x2 = function()
		local path
		if math_random(2) == 2 then
			-- Mega Spruce Taiga (full canopy)
			local r = math_random(4)
			path = modpath .. "/schematics/mcl_core_spruce_huge_"..r..".mts"
		else
			-- Mega Taiga (leaves only at top)
			local r = math_random(3)
			path = modpath .. "/schematics/mcl_core_spruce_huge_up_"..r..".mts"
		end

		return {
			spec = path,
			size = {w = 6, h = 20},
		}
	end,
	trunk = {
		description = S("Spruce Log"),
		_doc_items_longdesc = S("The trunk of a spruce tree."),
		tiles = {"mcl_core_log_spruce_top.png", "mcl_core_log_spruce_top.png", "mcl_core_log_spruce.png"},
	},
	stripped_trunk = {
		description = S("Stripped Spruce Log"),
		_doc_items_longdesc = S("The stripped trunk of a spruce tree."),
		tiles = {"mcl_core_stripped_spruce_top.png", "mcl_core_stripped_spruce_top.png", "mcl_core_stripped_spruce_side.png"},
	},
	bark = {
		description = S("Spruce Bark"),
		_doc_items_longdesc = S("The wood of a spruce tree."),
		tiles = {"mcl_core_log_spruce.png"},
	},
	stripped_bark = {
		description = S("Stripped Spruce Bark"),
		_doc_items_longdesc = S("The stripped wood of a spruce tree."),
		tiles = {"mcl_core_stripped_spruce_side.png"},
	},
	planks = {
		description = S("Spruce Wood Planks"),
		tiles = {"mcl_core_planks_spruce.png"},
	},
	leaves = {
		description = S("Spruce Leaves"),
		_doc_items_longdesc = S("Spruce leaves are grown from spruce trees."),
		tiles = {"mcl_core_leaves_spruce.png"},
		color = "#619961",
		paramtype2 = "none",
	},
	sapling = {
		description = S("Spruce Sapling"),
		_doc_items_longdesc = S("When placed on soil (such as dirt) and exposed to light, a spruce sapling will grow into a spruce after some time. When there are 4 spruce saplings in a 2×2 square, they will grow to a huge spruce."),
		tiles = {"mcl_core_sapling_spruce.png"},
		inventory_image = "mcl_core_sapling_spruce.png",
		wield_image = "mcl_core_sapling_spruce.png",
		selection_box = {
			type = "fixed",
			fixed = {-4/16, -0.5, -4/16, 4/16, 0.5, 4/16},
		},
		_after_grow = function(pos, _, is_2x2)
			if not is_2x2 then return end

			-- generate podzol underneath
			pos = vector.offset(pos, -0.5, 0, -0.5) -- center from northeast
			local pos1, pos2 = vector.offset(pos, -6, -4, -6), vector.offset(pos, 6, 4, 6)
			local nn = core.find_nodes_in_area_under_air(pos1, pos2, {"group:dirt"})
			table.sort(nn, function(a, b) return vector.distance(pos, a) < vector.distance(pos, b) end)
			for i = 1, math_random(math_min(#nn, 2), #nn) do
				core.set_node(nn[i], {name="mcl_core:podzol"})
			end
		end,
	},
})
