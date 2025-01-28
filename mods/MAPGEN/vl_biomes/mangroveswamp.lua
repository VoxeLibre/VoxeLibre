-- TODO: move to mcl_mangrove module?
local mod_mcl_mangrove = core.get_modpath("mcl_mangrove")
local mg_seed = core.get_mapgen_setting("seed")

-- Mangrove swamp
vl_biomes.register_biome({
	name = "MangroveSwamp",
	node_top = "mcl_mud:mud",
	depth_top = 1,
	node_filler = "mcl_mud:mud",
	depth_filler = 3,
	node_riverbed = "mcl_core:dirt",
	depth_riverbed = 2,
	y_min = -5, -- was 1, with _shore below
	y_max = 27, -- Note: Limited in height!
	humidity_point = 95,
	heat_point = 94,
	_mcl_biome_type = "hot",
	_mcl_water_temp = "warm",
	_mcl_grass_palette_index = 27,
	_mcl_foliage_palette_index = 6,
	_mcl_water_palette_index = 7,
	_mcl_waterfogcolor = "#3A7A6A",
	_mcl_skycolor = vl_biomes.skycolor.beach,
	_vl_subbiomes = {
		-- removed, as it did not differ _shore = { y_min = -5, y_max = 0, },
		ocean = {
			node_top = "mcl_core:dirt",
			depth_top = 1,
			node_filler = "mcl_core:dirt",
			depth_filler = 3,
			node_riverbed = "mcl_core:gravel",
			depth_riverbed = 2,
			y_max = -6,
			vertical_blend = 1,
		},
	}
})

--- Grow mangrove roots after generation
local bulk_swap_node = core.bulk_swap_node or core.bulk_set_node
local function mangrove_root_gennotify(t, minp, maxp, blockseed)
	for _, pos in ipairs(t) do
		local nn = core.find_nodes_in_area(vector.offset(pos, -8, -1, -8), vector.offset(pos, 8, 0, 8), {"mcl_mangrove:mangrove_roots"})
		if nn and #nn > 0 then
			local pr = PcgRandom(blockseed + mg_seed + 38327)
			for _, v in pairs(nn) do
				local l = pr:next(2, 16)
				local n = core.get_node(vector.offset(v, 0, -1, 0)).name
				if core.get_item_group(n, "water") > 0 then
					local wl = "mcl_mangrove:water_logged_roots"
					if n:find("river") then wl = "mcl_mangrove:river_water_logged_roots" end
					bulk_swap_node(core.find_nodes_in_area(v, vector.offset(v, 0, -l, 0), {"group:water"}), {name = wl})
				elseif n == "mcl_mud:mud" then
					bulk_swap_node(core.find_nodes_in_area(v, vector.offset(v, 0, -l, 0), {"mcl_mud:mud"}), {name = "mcl_mangrove:mangrove_mud_roots"})
				elseif n == "air" then
					bulk_swap_node(core.find_nodes_in_area(v, vector.offset(v, 0, -l, 0), {"air"}), {name = "mcl_mangrove:mangrove_roots"})
				end
			end
		end
	end
end

mcl_mapgen_core.register_decoration({
	name = "vl_biomes:mangrove_tree_1",
	deco_type = "schematic",
	place_on = {"mcl_mud:mud"},
	sidelen = 80,
	fill_ratio = 0.0065,
	biomes = {"MangroveSwamp", "MangroveSwamp_shore"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_mangrove .. "/schematics/mcl_mangrove_tree_1.mts",
	flags = "place_center_x, place_center_z, force_placement",
	rotation = "random",
	gen_callback = mangrove_root_gennotify,
})

mcl_mapgen_core.register_decoration({
	name = "vl_biomes:mangrove_tree_2",
	deco_type = "schematic",
	place_on = {"mcl_mud:mud"},
	sidelen = 80,
	fill_ratio = 0.0045,
	biomes = {"MangroveSwamp", "MangroveSwamp_shore"},
	y_min = -1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_mangrove .. "/schematics/mcl_mangrove_tree_2.mts",
	flags = "place_center_x, place_center_z, force_placement",
	rotation = "random",
	gen_callback = mangrove_root_gennotify,
})

mcl_mapgen_core.register_decoration({
	name = "vl_biomes:mangrove_tree_3",
	deco_type = "schematic",
	place_on = {"mcl_mud:mud"},
	sidelen = 80,
	fill_ratio = 0.023,
	biomes = {"MangroveSwamp", "MangroveSwamp_shore"},
	y_min = -1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_mangrove .. "/schematics/mcl_mangrove_tree_3.mts",
	flags = "place_center_x, place_center_z, force_placement",
	rotation = "random",
	gen_callback = mangrove_root_gennotify,
})

mcl_mapgen_core.register_decoration({
	name = "vl_biomes:mangrove_tree_4",
	deco_type = "schematic",
	place_on = {"mcl_mud:mud"},
	sidelen = 80,
	fill_ratio = 0.023,
	biomes = {"MangroveSwamp", "MangroveSwamp_shore"},
	y_min = -1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_mangrove .. "/schematics/mcl_mangrove_tree_4.mts",
	flags = "place_center_x, place_center_z, force_placement",
	rotation = "random",
	gen_callback = mangrove_root_gennotify,
})

mcl_mapgen_core.register_decoration({
	name = "vl_biomes:mangrove_tree_5",
	deco_type = "schematic",
	place_on = {"mcl_mud:mud"},
	sidelen = 80,
	fill_ratio = 0.023,
	biomes = {"MangroveSwamp", "MangroveSwamp_shore"},
	y_min = -1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_mangrove .. "/schematics/mcl_mangrove_tree_5.mts",
	flags = "place_center_x, place_center_z, force_placement",
	rotation = "random",
	gen_callback = mangrove_root_gennotify,
})

mcl_mapgen_core.register_decoration({
	name = "vl_biomes:mangrove_bee_nest",
	deco_type = "schematic",
	place_on = {"mcl_mud:mud"},
	sidelen = 80,
	--[[noise_params = {
		offset = 0.01,
		scale = 0.00001,
		spread = vector.new(250, 250, 250),
		seed = 2,
		octaves = 3,
		persist = 0.33
	},]]--
	fill_ratio = 0.0005,
	biomes = {"MangroveSwamp"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_mangrove .. "/schematics/mcl_mangrove_bee_nest.mts",
	flags = "place_center_x, place_center_z, force_placement",
	rotation = "random",
	spawn_by = "group:flower",
	rank = 1550,
	gen_callback = mangrove_root_gennotify,
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_mud:mud"},
	sidelen = 80,
	fill_ratio = 0.045,
	biomes = {"MangroveSwamp", "MangroveSwamp_shore"},
	y_min = 0,
	y_max = 0,
	decoration = "mcl_mangrove:water_logged_roots",
	flags = "place_center_x, place_center_z, force_placement",
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_mangrove:mangrove_roots"},
	spawn_by = {"group:water"},
	num_spawn_by = 2,
	sidelen = 80,
	fill_ratio = 10,
	biomes = {"MangroveSwamp", "MangroveSwamp_shore"},
	y_min = 0,
	y_max = 0,
	decoration = "mcl_mangrove:water_logged_roots",
	flags = "place_center_x, place_center_z, force_placement, all_ceilings",
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_mud:mud"},
	sidelen = 80,
	fill_ratio = 0.045,
	biomes = {"MangroveSwamp", "MangroveSwamp_shore"},
	place_offset_y = -1,
	decoration = "mcl_mangrove:mangrove_mud_roots",
	flags = "place_center_x, place_center_z, force_placement",
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_mud:mud"},
	sidelen = 80,
	fill_ratio = 0.008,
	biomes = {"MangroveSwamp", "MangroveSwamp_shore"},
	decoration = "mcl_core:deadbush",
	flags = "place_center_x, place_center_z",
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_core:water_source"},
	sidelen = 80,
	fill_ratio = 0.035,
	biomes = {"MangroveSwamp", "MangroveSwamp_shore"},
	decoration = "mcl_flowers:waterlily",
	flags = "place_center_x, place_center_z, liquid_surface",
})
