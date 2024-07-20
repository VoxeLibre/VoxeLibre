-- switch for debugging
function mcl_villages.debug(message)
	-- minetest.chat_send_all(message)
	-- minetest.log("warning", "[mcl_villages] "..message)
	minetest.log("verbose", "[mcl_villages] "..message)
end

--[[ Manually set in 'buildings.lua'
-- material to replace cobblestone with
local wallmaterial = {
	"mcl_core:junglewood",
	"mcl_core:sprucewood",
	"mcl_core:wood",
	"mcl_core:birchwood",
	"mcl_core:acaciawood",
	"mcl_core:stonebrick",
	"mcl_core:cobble",
	"mcl_core:sandstonecarved",
	"mcl_core:sandstone",
	"mcl_core:sandstonesmooth2"
}
--]]
--
-- possible surfaces where buildings can be built
--
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
mcl_villages.surface_mat["mcl_core:snow"] = true
mcl_villages.surface_mat["mcl_core:stone"] = true
mcl_villages.surface_mat["mcl_core:stone_with_coal"] = true
mcl_villages.surface_mat["mcl_core:stone_with_iron"] = true
mcl_villages.surface_mat["mcl_colorblocks:hardened_clay"] = true
mcl_villages.surface_mat["mcl_colorblocks:hardened_clay_orange"] = true
mcl_villages.surface_mat["mcl_colorblocks:hardened_clay_red"] = true
mcl_villages.surface_mat["mcl_colorblocks:hardened_clay_white"] = true

--
-- path to schematics
--
schem_path = mcl_villages.modpath.."/schematics/"
--
-- list of schematics
--
local basic_pseudobiome_villages = minetest.settings:get_bool("basic_pseudobiome_villages", true)

mcl_villages.schematic_table = {
	{name = "belltower",	mts = schem_path.."new_villages/belltower.mts",	hwidth = 9, hdepth = 9, hheight =  7, hsize = 12, max_num = 0.01 , rplc = basic_pseudobiome_villages, yadjust = 1, yadjust = 1 },
	--{name = "old_belltower",	mts = schem_path.."belltower.mts",	hwidth = 5, hdepth = 5, hheight =  6, hsize = 8, max_num = 0, rplc = basic_pseudobiome_villages, yadjust = 1 },
	--{name = "large_house",	mts = schem_path.."large_house.mts",	hwidth = 12, hdepth = 12, hheight =  10, hsize = 18, max_num = 0.08 , rplc = basic_pseudobiome_villages },
	--{name = "blacksmith",	mts = schem_path.."blacksmith.mts",	hwidth = 8, hdepth = 11, hheight = 8, hsize = 15, max_num = 0.01 , rplc = basic_pseudobiome_villages },
	{name = "new_blacksmith",	mts = schem_path.."new_villages/blacksmith.mts",	hwidth = 9, hdepth = 11, hheight = 8, hsize = 15, max_num = 0.01 , rplc = basic_pseudobiome_villages, yadjust = 1 },
	{name = "weaponsmith",	mts = schem_path.."new_villages/weaponsmith.mts",	hwidth = 11, hdepth = 9, hheight = 6, hsize = 15, max_num = 0.01 , rplc = basic_pseudobiome_villages, yadjust = 1 },
	{name = "toolsmith",	mts = schem_path.."new_villages/toolsmith.mts",	hwidth = 9, hdepth = 11, hheight = 6, hsize = 15, max_num = 0.01 , rplc = basic_pseudobiome_villages, yadjust = 1 },
	{name = "tannery",	mts = schem_path.."new_villages/leather_worker.mts",	hwidth = 8, hdepth = 8, hheight = 7, hsize = 12, max_num = 0.01 , rplc = basic_pseudobiome_villages, yadjust = 1 },
	--{name = "butcher",	mts = schem_path.."butcher.mts",	hwidth = 12, hdepth =  8, hheight = 10, hsize = 15, max_num = 0.01 , rplc = basic_pseudobiome_villages },
	--{name = "church",	mts = schem_path.."church.mts",		hwidth = 13, hdepth = 14, hheight = 15, hsize = 20, max_num = 0.01 , rplc = basic_pseudobiome_villages },
	{name = "newchurch",	mts = schem_path.."new_villages/church.mts",		hwidth = 14, hdepth = 16, hheight = 13, hsize = 22, max_num = 0.01 , rplc = basic_pseudobiome_villages, yadjust = 1 },
	{name = "chapel",	mts = schem_path.."new_villages/chapel.mts",		hwidth = 9, hdepth = 10, hheight = 6, hsize = 14, max_num = 0.01 , rplc = basic_pseudobiome_villages, yadjust = 1 },
	--{name = "farm",		mts = schem_path.."farm.mts",		hwidth =  9, hdepth =  7, hheight = 8, hsize = 12, max_num = 0.1  , rplc = basic_pseudobiome_villages, yadjust = 0 },
	--{name = "lamp",		mts = schem_path.."lamp.mts",		hwidth =  3, hdepth =  4, hheight = 6, hsize = 6, max_num = 0.001  , rplc = false                      },
	{name = "lamp_1",	mts = schem_path.."new_villages/lamp_1.mts",	hwidth =  1, hdepth =  1, hheight = 4, hsize = 4, max_num = 0.001  , rplc = false, yadjust = 1 },
	{name = "lamp_2",	mts = schem_path.."new_villages/lamp_2.mts",	hwidth =  1, hdepth =  2, hheight = 6, hsize = 5, max_num = 0.001  , rplc = false, yadjust = 1 },
	{name = "lamp_3",	mts = schem_path.."new_villages/lamp_3.mts",	hwidth =  3, hdepth =  3, hheight = 4, hsize = 6, max_num = 0.001  , rplc = false, yadjust = 1 },
	{name = "lamp_4",	mts = schem_path.."new_villages/lamp_4.mts",	hwidth =  1, hdepth =  2, hheight = 5, hsize = 5, max_num = 0.001  , rplc = false, yadjust = 1 },
	{name = "lamp_5",	mts = schem_path.."new_villages/lamp_5.mts",	hwidth =  1, hdepth =  1, hheight = 2, hsize = 4, max_num = 0.001  , rplc = false, yadjust = 1 },
	{name = "lamp_6",	mts = schem_path.."new_villages/lamp_6.mts",	hwidth =  1, hdepth =  1, hheight = 3, hsize = 4, max_num = 0.001  , rplc = false, yadjust = 1 },
	--{name = "library",	mts = schem_path.."library.mts",	hwidth = 12, hdepth = 12, hheight =  9, hsize = 18, max_num = 0.01 , rplc = basic_pseudobiome_villages },
	{name = "newlibrary",	mts = schem_path.."new_villages/library.mts",	hwidth = 14, hdepth = 14, hheight =  7, hsize = 21, max_num = 0.01 , rplc = basic_pseudobiome_villages, yadjust = 1 },
	--{name = "medium_house",	mts = schem_path.."medium_house.mts",	hwidth =  9, hdepth = 12, hheight =  9, hsize = 16, max_num = 0.08 , rplc = basic_pseudobiome_villages },
	--{name = "small_house",	mts = schem_path.."small_house.mts",	hwidth =  9, hdepth =  8, hheight =  9, hsize = 13, max_num = 0.3  , rplc = basic_pseudobiome_villages },
	{name = "house_1_bed",	mts = schem_path.."new_villages/house_1_bed.mts",	hwidth =  9, hdepth =  8, hheight =  7, hsize = 13, max_num = 0.3  , rplc = basic_pseudobiome_villages, yadjust = 1 },
	{name = "house_2_bed",	mts = schem_path.."new_villages/house_2_bed.mts",	hwidth =  11, hdepth =  8, hheight =  7, hsize = 15, max_num = 0.2  , rplc = basic_pseudobiome_villages, yadjust = 1 },
	{name = "house_3_bed",	mts = schem_path.."new_villages/house_3_bed.mts",	hwidth =  11, hdepth =  13, hheight =  9, hsize = 18, max_num = 0.1  , rplc = basic_pseudobiome_villages, yadjust = 1 },
	{name = "house_4_bed",	mts = schem_path.."new_villages/house_4_bed.mts",	hwidth =  11, hdepth =  13, hheight =  10, hsize = 18, max_num = 0.1  , rplc = basic_pseudobiome_villages, yadjust = 1 },
	{name = "mason",	mts = schem_path.."new_villages/mason.mts",	hwidth =  8, hdepth =  8, hheight =  7, hsize = 12, max_num = 0.01  , rplc = basic_pseudobiome_villages, yadjust = 1 },
	{name = "mill",		mts = schem_path.."new_villages/mill.mts",	hwidth =  8, hdepth =  8, hheight =  7, hsize = 12, max_num = 0.01  , rplc = basic_pseudobiome_villages, yadjust = 1 },
	{name = "cartographer",	mts = schem_path.."new_villages/cartographer.mts",	hwidth =  9, hdepth = 12, hheight =  6, hsize = 16, max_num = 0.01  , rplc = basic_pseudobiome_villages, yadjust = 2 },
	{name = "fletcher",	mts = schem_path.."new_villages/fletcher.mts",	hwidth =  8, hdepth =  8, hheight =  7, hsize = 12, max_num = 0.01  , rplc = basic_pseudobiome_villages, yadjust = 1 },
	{name = "new_butcher",	mts = schem_path.."new_villages/butcher.mts",	hwidth =  8, hdepth = 14, hheight =  9, hsize = 17, max_num = 0.01  , rplc = basic_pseudobiome_villages, yadjust = 1 },
	{name = "fish_farm",	mts = schem_path.."new_villages/fishery.mts",	hwidth =  10, hdepth =  7, hheight =  9, hsize = 13, max_num = 0.01  , rplc = basic_pseudobiome_villages, yadjust=-2 },
	--{name = "tavern",	mts = schem_path.."tavern.mts",		hwidth = 12, hdepth = 10, hheight = 13, hsize = 17, max_num = 0.050, rplc = basic_pseudobiome_villages },
	--{name = "well",		mts = schem_path.."well.mts",		hwidth =  6, hdepth =  8, hheight =  7, hsize = 11, max_num = 0.01, rplc = basic_pseudobiome_villages },
	{name = "new_well",	mts = schem_path.."new_villages/well.mts",	hwidth =  6, hdepth =  6, hheight =  8, hsize = 9, max_num = 0.01, rplc = basic_pseudobiome_villages, yadjust=-1 },
	{name = "new_farm",	mts = schem_path.."new_villages/farm.mts", hwidth=10, hdepth=9, hheight=6, hsize=14, max_num = 0.1, rplc = basic_pseudobiome_villages, yadjust = 1 },
	{name = "farm_small",	mts = schem_path.."new_villages/farm_small_1.mts", hwidth=10, hdepth=9, hheight=6, hsize=14, max_num = 0.1, rplc = basic_pseudobiome_villages, yadjust = 1 },
	{name = "farm_small2",	mts = schem_path.."new_villages/farm_small_2.mts", hwidth=9, hdepth=9, hheight=3, hsize=14, max_num = 0.1, rplc = basic_pseudobiome_villages, yadjust = 1 },
	{name = "farm_large",	mts = schem_path.."new_villages/farm_large_1.mts", hwidth=13, hdepth=13, hheight=4, hsize=19, max_num = 0.1, rplc = basic_pseudobiome_villages, yadjust = 1 },
}

--
-- maximum allowed difference in height for building a settlement
--
max_height_difference = 56
--
--
--
half_map_chunk_size = 40
--quarter_map_chunk_size = 20

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

	-- no change, but try to convert MCLA material
	-- FlowerForest = "oak",
	-- Forest = "oak",
	-- MushroomIsland = "oak",
	-- Plains = "oak",
	-- StoneBeach = "oak",
	-- SunflowerPlains = "oak",
	-- Swampland = "oak",
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
}
mcl_villages.mcla_to_vl = {
	-- oneway
	{ '"mcl_villages:no_paths"', '"air"'}, -- TODO: support these
	{ '"mcl_villages:path_endpoint"', '"air"'}, -- TODO: support these
	{ '"mcl_villages:crop_root', '"mcl_farming:potato'}, -- TODO: support biome specific farming
	{ '"mcl_villages:crop_grain', '"mcl_farming:wheat'}, -- TODO: support biome specific farming
	{ '"mcl_villages:crop_gourd', '"mcl_farming:pumpkin'}, -- TODO: support biome specific farming
	{ '"mcl_villages:crop_flower_0"', '"mcl_flowers:tulip_red"'}, -- TODO: support biome specific farming
	{ '"mcl_villages:crop_flower_1"', '"mcl_flowers:tulip_orange"'}, -- TODO: support biome specific farming
	{ '"mcl_villages:crop_flower_2"', '"mcl_flowers:tulip_pink"'}, -- TODO: support biome specific farming
	{ '"mcl_villages:crop_flower_3"', '"mcl_flowers:tulip_white"'}, -- TODO: support biome specific farming
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
	{ '"mcl_stairs:stair_bamboo(["_])', '"mcl_stairs:stair_bamboowood%1'},
}
mcl_villages.material_substitions = {
	desert = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_sandstonesmooth%1"' },
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
		{ '"mcl_stairs:stair_oak([^"]*)"', '"mcl_stairs:stair_sandstonesmooth%1"' },
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
	},
	bamboo = {
		{ '"mcl_stairs:slab_oak([^"]*)"', '"mcl_stairs:slab_bamboo_block%1"' },
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
	},
}
