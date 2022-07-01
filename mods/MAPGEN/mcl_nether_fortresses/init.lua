local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

mcl_structures.register_structure("nether_outpost",{
	place_on = {"mcl_nether:netherrack","mcl_crimson:crimson_nylium","mcl_crimson:warped_nylium","mcl_blackstone:basalt","mcl_blackstone:soul_soil"},
	noise_params = {
		offset = 0,
		scale = 0.00022,
		spread = {x = 250, y = 250, z = 250},
		seed = 333,
		octaves = 1,
		persist = 0.0001,
		flags = "absvalue",
	},
	flags = "all_floors",
	biomes = {"Nether","SoulsandValley","WarpedForest","CrimsonForest","BasaltDelta"},
	sidelen = 15,
	solid_ground = true,
	make_foundation = true,
	y_min = mcl_vars.mg_lava_nether_max - 1,
	y_max = mcl_vars.mg_nether_max - 30,
	filenames = { modpath.."/schematics/nether_outpost.mts" },
	y_offset = 0,
	after_place = function(pos)
		local sp = minetest.find_nodes_in_area(pos,vector.offset(pos,0,20,0),{"mcl_mobspawners:spawner"})
		if not sp[1] then return end
		mcl_mobspawners.setup_spawner(sp[1], "mobs_mc:blaze", 0, minetest.LIGHT_MAX+1, 10, 3, -1)
	end
})
