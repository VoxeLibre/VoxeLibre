local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

vl_structures.register_structure("obelisk_sand",{
	place_on = {"group:sand"},
	flags = "place_center_x, place_center_z",
	chunk_probability = 12,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	y_offset = -3,
	prepare = { tolerance = 3, padding = 0, clear = false },
	biomes = { "Desert" },
	filenames = {
		modpath.."/schematics/obelisk_sand_1.mts",
		modpath.."/schematics/obelisk_sand_2.mts",
	},
})

vl_structures.register_structure("obelisk_light",{
	place_on = {"group:sand"},
	flags = "place_center_x, place_center_z",
	chunk_probability = 25,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	y_offset = -2,
	prepare = { tolerance = 2, padding = 0, clear = false },
	biomes = { "Desert" },
	filenames = {
		modpath.."/schematics/obelisk_fire.mts",
	},
	after_place = function(p,_,pr,p1,p2)
		for _,n in pairs(minetest.find_nodes_in_area(p1,p2,{"group:wall"})) do
			mcl_walls.update_wall(n)
		end
	end,
})

vl_structures.register_structure("obelisk_cobble",{
	place_on = {"group:grass_block", "group:dirt"},
	flags = "place_center_x, place_center_z",
	chunk_probability = 25,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	y_offset = -2,
	prepare = { tolerance = 2, padding = 0, clear = false },
	biomes = { "Plains", "SunflowerPlains", "Forest", "FlowerForest", "BrichForest", "Taiga", "RoofedForest", "MegaTaiga", "MegaSpruceTaiga", },
	filenames = {
		modpath.."/schematics/obelisk_cobble.mts",
		modpath.."/schematics/obelisk_cobble_broken.mts",
	},
})

