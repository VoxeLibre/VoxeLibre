-- maximum allowed difference in height for building a settlement
mcl_villages.max_height_difference = 56

-- legacy type in old schematics
minetest.register_alias("mcl_villages:stonebrickcarved", "mcl_core:stonebrickcarved")

-- possible surfaces where buildings can be built
mcl_villages.surface_mat = {}
mcl_villages.surface_mat["mcl_core:andesite"] = true
mcl_villages.surface_mat["mcl_core:diorite"] = true
mcl_villages.surface_mat["mcl_core:dirt"] = true
mcl_villages.surface_mat["mcl_core:dirt_with_grass"] = true
--mcl_villages.surface_mat["mcl_core:dirt_with_dry_grass"] = true
mcl_villages.surface_mat["mcl_core:dirt_with_grass_snow"] = true
--mcl_villages.surface_mat["mcl_core:dry_dirt_with_grass"] = true
mcl_villages.surface_mat["mcl_core:grass_path"] = true
mcl_villages.surface_mat["mcl_core:granite"] = true
mcl_villages.surface_mat["mcl_core:podzol"] = true
mcl_villages.surface_mat["mcl_core:redsand"] = true
mcl_villages.surface_mat["mcl_core:sand"] = true
mcl_villages.surface_mat["mcl_core:sandstone"] = true
mcl_villages.surface_mat["mcl_core:sandstonesmooth"] = true
mcl_villages.surface_mat["mcl_core:sandstonesmooth2"] = true
--mcl_villages.surface_mat["mcl_core:silver_sand"] = true
--mcl_villages.surface_mat["mcl_core:snow"] = true
mcl_villages.surface_mat["mcl_core:stone"] = true
mcl_villages.surface_mat["mcl_core:stone_with_coal"] = true
mcl_villages.surface_mat["mcl_core:stone_with_iron"] = true
mcl_villages.surface_mat["mcl_colorblocks:hardened_clay"] = true
mcl_villages.surface_mat["mcl_colorblocks:hardened_clay_orange"] = true
mcl_villages.surface_mat["mcl_colorblocks:hardened_clay_red"] = true
mcl_villages.surface_mat["mcl_colorblocks:hardened_clay_white"] = true

-- substitute foundation materials
mcl_villages.foundation_materials = {}
mcl_villages.foundation_materials["mcl_core:sand"] = "mcl_core:sandstone"
mcl_villages.foundation_materials["mcl_core:redsand"] = "mcl_core:redsandstone"

-- substitute stone materials in foundation
mcl_villages.stone_materials = {}

mcl_villages.default_crop = "mcl_farming:wheat_1"

--
-- Biome based block substitutions
--
-- TODO maybe this should be in the biomes?
mcl_villages.biome_map = {
	BambooJungle = "bamboo",
	BambooJungleEdge = "bamboo",
	BambooJungleEdgeM = "bamboo",
	BambooJungleM = "bamboo",

	Jungle = "jungle",
	JungleEdge = "jungle",
	JungleEdgeM = "jungle",
	JungleM = "jungle",

	Desert = "desert",

	Savanna = "acacia",
	SavannaM = "acacia",

	Mesa = "hardened_clay",
	MesaBryce = "hardened_clay ",
	MesaPlateauF = "hardened_clay",
	MesaPlateauFM = "hardened_clay",

	MangroveSwamp = "mangrove",

	RoofedForest = "dark_oak",

	BirchForest = "birch",
	BirchForestM = "birch",

	ColdTaiga = "spruce",
	ExtremeHills = "spruce",
	ExtremeHillsM = "spruce",
	IcePlains = "spruce",
	IcePlainsSpikes = "spruce",
	MegaSpruceTaiga = "spruce",
	MegaTaiga = "spruce",
	Taiga = "spruce",
	["ExtremeHills+"] = "spruce",

	CherryGrove = "cherry",

	-- no change
	--FlowerForest = "oak",
	--Forest = "oak",
	--MushroomIsland = "",
	--Plains = "oak",
	--StoneBeach = "",
	--SunflowerPlains = "oak",
	--Swampland = "oak",
}

mcl_villages.vl_to_mcla = {
	{ '"mcl_core:tree"', '"mcl_trees:tree_oak"'},
	{ '"mcl_core:darktree"', '"mcl_trees:tree_dark_oak"'},
	{ '"mcl_core:wood"', '"mcl_trees:wood_oak"'},
	{ '"mcl_core:darkwood"', '"mcl_trees:wood_dark_oak"'},
	{ '"mcl_fences:fence', '"mcl_fences:oak_fence'},
	{ '"mcl_stairs:stair_wood"', '"mcl_stairs:stair_oak"'},
	{ '"mcl_stairs:stair_wood_', '"mcl_stairs:stair_oak_'},
	{ '"mcl_stairs:slab_wood"', '"mcl_stairs:slab_oak"'},
	{ '"mcl_stairs:slab_wood_', '"mcl_stairs:slab_oak_'},
	{ '"mcl_doors:wooden_door_', '"mcl_doors:door_oak_'},
	{ '"mcl_doors:trapdoor_', '"mcl_doors:trapdoor_oak_'},
	{ '"xpanes:bar', '"mcl_panes:bar' },
	{ '"xpanes:pane', '"mcl_panes:pane' },
	{ '"mcl_itemframes:item_frame"', '"mcl_itemframes:frame"' },
	{ '"mesecons_pressureplates:pressure_plate_wood_', '"mesecons_pressureplates:pressure_plate_oak_'},
	-- tree types
	{ '"mcl_core:([a-z]*)tree"', '"mcl_trees:tree_%1"'},
	{ '"mcl_core:([a-z]*)wood"', '"mcl_trees:wood_%1"'},
	{ '"mcl_stairs:stair_darkwood"', '"mcl_stairs:stair_dark_oak"'},
	{ '"mcl_stairs:stair_([a-z]*)wood"', '"mcl_stairs:stair_%1"'},
	{ '"mcl_bamboo:bamboo_fence', '"mcl_fences:bamboo_fence'},
	{ '"mcl_bamboo:bamboo_plank', '"mcl_core:bamboowood'},
	{ '"mcl_bamboo:bamboo_block', '"mcl_core:bambootree'},
	{ '"mcl_stairs:stair_bamboo_plank', '"mcl_stairs:stair_bamboo'},
	{ '"mcl_bamboo:pressure_plate_bamboo_wood_', '"mesecons_pressureplates:pressure_plate_bamboo_'},
	{ '"mcl_bamboo:bamboo_trapdoor', '"mcl_doors:trapdoor_bamboo'},
	{ '"mcl_bamboo:bamboo_door', '"mcl_doors:door_bamboo'},
}
mcl_villages.mcla_to_vl = {
	-- bidirectional
	{ '"mcl_trees:tree_oak"', '"mcl_core:tree"'},
	{ '"mcl_trees:tree_dark_oak"', '"mcl_core:darktree"'},
	{ '"mcl_trees:wood_oak"', '"mcl_core:wood"'},
	{ '"mcl_trees:wood_dark_oak"', '"mcl_core:darkwood"'},
	{ '"mcl_fences:oak_fence', '"mcl_fences:fence'},
	{ '"mcl_stairs:stair_oak"', '"mcl_stairs:stair_wood"'},
	{ '"mcl_stairs:stair_oak_bark', '"mcl_stairs:stair_tree_bark'},
	{ '"mcl_stairs:stair_oak_', '"mcl_stairs:stair_wood_'},
	{ '"mcl_stairs:slab_oak"', '"mcl_stairs:slab_wood"'},
	{ '"mcl_stairs:slab_oak_', '"mcl_stairs:slab_wood_'},
	{ '"mcl_doors:door_oak_', '"mcl_doors:wooden_door_'},
	{ '"mcl_doors:trapdoor_oak_', '"mcl_doors:trapdoor_'},
	{ '"mcl_panes:bar', '"xpanes:bar'},
	{ '"mcl_panes:pane', '"xpanes:pane'},
	{ '"mcl_itemframes:frame"', '"mcl_itemframes:item_frame"'},
	{ '"mesecons_pressureplates:pressure_plate_oak_', '"mesecons_pressureplates:pressure_plate_wood_'},
	-- tree types
	{ '"mcl_trees:tree_([a-z]*)"', '"mcl_core:%1tree"'},
	{ '"mcl_trees:wood_([a-z]*)"', '"mcl_core:%1wood"'},
	{ '"mcl_stairs:stair_birch(["_])', '"mcl_stairs:stair_birchwood%1'},
	{ '"mcl_stairs:stair_spruce(["_])', '"mcl_stairs:stair_sprucewood%1'},
	{ '"mcl_stairs:stair_dark_oak(["_])', '"mcl_stairs:stair_darkwood%1'},
	{ '"mcl_stairs:stair_jungle(["_])', '"mcl_stairs:stair_junglewood%1'},
	{ '"mcl_stairs:stair_acacia(["_])', '"mcl_stairs:stair_acaciawood%1'},
	{ '"mcl_fences:bamboo_fence', '"mcl_bamboo:bamboo_fence'},
	{ '"mcl_core:bamboowood', '"mcl_bamboo:bamboo_plank'},
	{ '"mcl_core:bambootree', '"mcl_bamboo:bamboo_block'},
	{ '"mcl_stairs:stair_bamboo', '"mcl_stairs:stair_bamboo_plank'},
	{ '"mesecons_pressureplates:pressure_plate_bamboo_', '"mcl_bamboo:pressure_plate_bamboo_wood_'},
	{ '"mcl_doors:trapdoor_bamboo', '"mcl_bamboo:bamboo_trapdoor'},
	{ '"mcl_doors:door_bamboo', '"mcl_bamboo:bamboo_door'},
}
mcl_villages.material_substitions = {
	desert = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_sandstonesmooth2%1"' }, -- divert from MCLA, no version 1?
		{
			'"mesecons_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mesecons_pressureplates:pressure_plate_birchwood_%1"',
		},
		{ '"mcl_doors:trapdoor_oak([^"]*)"', '"mcl_doors:birch_trapdoor%1"' },
		{ '"mcl_doors:door_oak([^"]*)"', '"mcl_doors:birch_door%1"' },

		{ "mcl_core:cobble", "mcl_core:sandstone" },
		{ '"mcl_stairs:stair_cobble([^"]*)"', '"mcl_stairs:stair_sandstone%1"' },
		{ '"mcl_walls:cobble([^"]*)"', '"mcl_walls:sandstone%1"' },
		{ '"mcl_stairs:slab_cobble([^"]*)"', '"mcl_stairs:slab_sandstone%1"' },

		{ '"mcl_core:stonebrick"', '"mcl_core:redsandstone"' },
		{ '"mcl_core:stonebrick_([^"]+)"', '"mcl_core:redsandstone_%1"' },
		{ '"mcl_walls:stonebrick([^"]*)"', '"mcl_walls:redsandstone%1"' },
		{ '"mcl_stairs:stair_stonebrick"', '"mcl_stairs:stair_redsandstone"' },
		{ '"mcl_stairs:stair_stonebrick_([^"]+)"', '"mcl_stairs:stair_redsandstone_%1"' },

		{ '"mcl_stairs:slab_brick_block([^"]*)"', '"mcl_core:redsandstonesmooth2%1"' },
		{ '"mcl_core:brick_block"', '"mcl_core:redsandstonesmooth2"' },

		{ "mcl_trees:tree_oak", "mcl_core:redsandstonecarved" },
		{ "mcl_trees:wood_oak", "mcl_core:redsandstonesmooth" },
		{ '"mcl_fences:oak_fence([^"]*)"', '"mcl_fences:birch_fence%1"' },
		{ '"mcl_stairs:stair_oak_bark([^"]*)"', '"mcl_stairs:stair_sandstonesmooth2%1"' },
		{ '"mcl_stairs:stair_oak([^"]*)"', '"mcl_stairs:stair_sandstonesmooth2%1"' }, -- divert from MCLA, no version 1?
		{ '"mcl_core:leaves"', '"air"' }, -- addition to MCLA
	},
	spruce = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_sprucewood%1"' },
		{
			'"mesecons_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mesecons_pressureplates:pressure_plate_sprucewood_%1"',
		},
		{ '"mcl_doors:trapdoor_oak([^"]*)"', '"mcl_doors:spruce_trapdoor%1"' },
		{ '"mcl_doors:door_oak([^"]*)"', '"mcl_doors:spruce_door%1"' },
		{ "mcl_trees:tree_oak", "mcl_trees:tree_spruce" },
		{ "mcl_trees:wood_oak", "mcl_trees:wood_spruce" },
		{ '"mcl_fences:oak_fence([^"]*)"', '"mcl_fences:spruce_fence%1"' },
		{ '"mcl_stairs:stair_oak([^"]*)"', '"mcl_stairs:stair_spruce%1"' },
		{ '"mcl_core:leaves"', '"mcl_core:spruceleaves"' }, -- addition to MCLA
	},
	birch = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_birchwood%1"' },
		{
			'"mesecons_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mesecons_pressureplates:pressure_plate_birchwood_%1"',
		},
		{ '"mcl_doors:trapdoor_oak([^"]*)"', '"mcl_doors:birch_trapdoor%1"' },
		{ '"mcl_doors:door_oak([^"]*)"', '"mcl_doors:birch_door%1"' },
		{ "mcl_trees:tree_oak", "mcl_core:stripped_birch" }, -- divert from MCLA, use stripped birch, what is the name in MCLA?
		{ "mcl_trees:wood_oak", "mcl_trees:wood_birch" },
		{ '"mcl_fences:oak_fence([^"]*)"', '"mcl_fences:birch_fence%1"' },
		{ '"mcl_stairs:stair_oak([^"]*)"', '"mcl_stairs:stair_birch%1"' },
		{ '"mcl_core:leaves"', '"mcl_core:birchleaves"' }, -- addition to MCLA
	},
	acacia = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_acaciawood%1"' },
		{
			'"mesecons_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mesecons_pressureplates:pressure_plate_acaciawood_%1"',
		},
		{ '"mcl_doors:trapdoor_oak([^"]*)"', '"mcl_doors:acacia_trapdoor%1"' },
		{ '"mcl_doors:door_oak([^"]*)"', '"mcl_doors:acacia_door%1"' },
		{ "mcl_trees:tree_oak", "mcl_trees:tree_acacia" },
		{ "mcl_trees:wood_oak", "mcl_trees:wood_acacia" },
		{ '"mcl_fences:oak_fence([^"]*)"', '"mcl_fences:acacia_fence%1"' },
		{ '"mcl_stairs:stair_oak([^"]*)"', '"mcl_stairs:stair_acacia%1"' },
		{ '"mcl_core:leaves"', '"mcl_core:acacialeaves"' }, -- addition to MCLA
	},
	dark_oak = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_darkwood%1"' },
		{
			'"mesecons_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mesecons_pressureplates:pressure_plate_darkwood_%1"',
		},
		{ '"mcl_doors:trapdoor_oak([^"]*)"', '"mcl_doors:dark_oak_trapdoor%1"' },
		{ '"mcl_doors:door_oak([^"]*)"', '"mcl_doors:dark_oak_door%1"' },
		{ "mcl_trees:tree_oak", "mcl_trees:tree_dark_oak" },
		{ "mcl_trees:wood_oak", "mcl_trees:wood_dark_oak" },
		{ '"mcl_fences:oak_fence([^"]*)"', '"mcl_fences:dark_oak_fence%1"' },
		{ '"mcl_stairs:stair_oak([^"]*)"', '"mcl_stairs:stair_dark_oak%1"' },
		{ '"mcl_core:leaves"', '"mcl_core:darkleaves"' }, -- addition to MCLA
	},
	jungle = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_junglewood%1"' },
		{
			'"mesecons_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mesecons_pressureplates:pressure_plate_junglewood_%1"',
		},
		{ '"mcl_doors:trapdoor_oak([^"]*)"', '"mcl_doors:jungle_trapdoor%1"' },
		{ '"mcl_doors:door_oak([^"]*)"', '"mcl_doors:jungle_door%1"' },
		{ "mcl_trees:tree_oak", "mcl_trees:tree_jungle" },
		{ "mcl_trees:wood_oak", "mcl_trees:wood_jungle" },
		{ '"mcl_fences:oak_fence([^"]*)"', '"mcl_fences:jungle_fence%1"' },
		{ '"mcl_stairs:stair_oak([^"]*)"', '"mcl_stairs:stair_jungle%1"' },
		{ '"mcl_core:leaves"', '"mcl_core:jungleleaves"' }, -- addition to MCLA
	},
	bamboo = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_bamboo_plank%1"' }, -- divert from MCLA
		{
			'"mesecons_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mesecons_pressureplates:pressure_plate_bamboo_%1"',
		},
		{ '"mcl_doors:trapdoor_oak([^"]*)"', '"mcl_doors:trapdoor_bamboo%1"' },
		{ '"mcl_doors:door_oak([^"]*)"', '"mcl_doors:door_bamboo%1"' },

		{ "mcl_core:cobble", "mcl_core:andesite" },
		{ '"mcl_stairs:stair_cobble([^"]*)"', '"mcl_stairs:stair_andesite%1"' },
		{ '"mcl_walls:cobble([^"]*)"', '"mcl_walls:andesite%1"' },
		{ '"mcl_stairs:slab_cobble([^"]*)"', '"mcl_stairs:slab_andesite%1"' },
		{ "mcl_trees:tree_oak", "mcl_trees:tree_bamboo" },
		{ "mcl_trees:wood_oak", "mcl_trees:wood_bamboo" },
		{ '"mcl_fences:oak_fence([^"]*)"', '"mcl_fences:bamboo_fence%1"' },
		{ '"mcl_stairs:stair_oak([^"]*)"', '"mcl_stairs:stair_bamboo%1"' },
		{ '"mcl_core:leaves"', '"air"' }, -- addition to MCLA
	},
	cherry = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_cherry_blossom%1"' },
		{
			'"mesecons_pressureplates:pressure_plate_oak_([^"]+)"',
			'"mesecons_pressureplates:pressure_plate_cherry_blossom_%1"',
		},
		{ '"mcl_doors:trapdoor_oak([^"]*)"', '"mcl_doors:trapdoor_cherry_blossom%1"' },
		{ '"mcl_doors:door_oak([^"]*)"', '"mcl_doors:door_cherry_blossom%1"' },
		{ "mcl_trees:tree_oak", "mcl_trees:tree_cherry_blossom" },
		{ "mcl_trees:wood_oak", "mcl_trees:wood_cherry_blossom" },
		{ '"mcl_fences:oak_fence([^"]*)"', '"mcl_fences:cherry_blossom_fence%1"' },
		{ '"mcl_stairs:stair_oak([^"]*)"', '"mcl_stairs:stair_cherry_blossom%1"' },
		{ '"mcl_core:leaves"', '"mcl_core:leaves"' }, -- addition to MCLA
	},
}
