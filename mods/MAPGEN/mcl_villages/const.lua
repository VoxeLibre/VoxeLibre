-- switch for debugging
function settlements.debug(message)
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
settlements.surface_mat = {}
-------------------------------------------------------------------------------
-- Set array to list
-- https://stackoverflow.com/questions/656199/search-for-an-item-in-a-lua-list
-------------------------------------------------------------------------------
function settlements.grundstellungen()
	settlements.surface_mat = settlements.Set {
		"mcl_core:dirt_with_grass",
		--"mcl_core:dry_dirt_with_grass",
		"mcl_core:dirt_with_grass_snow",
		--"mcl_core:dirt_with_dry_grass",
		"mcl_core:podzol",
		"mcl_core:sand",
		"mcl_core:redsand",
		--"mcl_core:silver_sand",
		"mcl_core:snow"
	}
end
--
-- possible surfaces where buildings can be built
--

--
-- path to schematics
--
schem_path = settlements.modpath.."/schematics/"
--
-- list of schematics
--
local basic_pseudobiome_villages = minetest.settings:get_bool("basic_pseudobiome_villages", true)

settlements.schematic_table = {
	{name = "belltower",	mts = schem_path.."belltower.mts",	hwidth = 5, hdepth = 5, hheight =  9, hsize = 14, max_num = 0 , rplc = basic_pseudobiome_villages },
	{name = "large_house",	mts = schem_path.."large_house.mts",	hwidth = 12, hdepth = 12, hheight =  9, hsize = 14, max_num = 0.08 , rplc = basic_pseudobiome_villages },
	{name = "blacksmith",	mts = schem_path.."blacksmith.mts",	hwidth = 8, hdepth = 11, hheight = 13, hsize = 13, max_num = 0.055, rplc = basic_pseudobiome_villages },
	{name = "butcher",	mts = schem_path.."butcher.mts",	hwidth = 12, hdepth =  8, hheight = 10, hsize = 14, max_num = 0.03 , rplc = basic_pseudobiome_villages },
	{name = "church",	mts = schem_path.."church.mts",		hwidth = 13, hdepth = 13, hheight = 14, hsize = 15, max_num = 0.04 , rplc = basic_pseudobiome_villages },
	{name = "farm",		mts = schem_path.."farm.mts",		hwidth =  9, hdepth =  7, hheight = 13, hsize = 13, max_num = 0.1  , rplc = basic_pseudobiome_villages },
	{name = "lamp",		mts = schem_path.."lamp.mts",		hwidth =  3, hdepth =  4, hheight = 13, hsize = 10, max_num = 0.1  , rplc = false                      },
	{name = "library",	mts = schem_path.."library.mts",	hwidth = 12, hdepth = 12, hheight =  8, hsize = 13, max_num = 0.04 , rplc = basic_pseudobiome_villages },
	{name = "medium_house",	mts = schem_path.."medium_house.mts",	hwidth =  9, hdepth = 12, hheight =  8, hsize = 14, max_num = 0.08 , rplc = basic_pseudobiome_villages },
	{name = "small_house",	mts = schem_path.."small_house.mts",	hwidth =  9, hdepth =  8, hheight =  8, hsize = 13, max_num = 0.7  , rplc = basic_pseudobiome_villages },
	{name = "tavern",	mts = schem_path.."tavern.mts",		hwidth = 12, hdepth = 10, hheight = 10, hsize = 13, max_num = 0.050, rplc = basic_pseudobiome_villages },
	{name = "well",		mts = schem_path.."well.mts",		hwidth =  6, hdepth =  8, hheight =  6, hsize = 10, max_num = 0.045, rplc = basic_pseudobiome_villages },
}

--
-- maximum allowed difference in height for building a sttlement
--
max_height_difference = 56
--
--
--
half_map_chunk_size = 40
--quarter_map_chunk_size = 20
