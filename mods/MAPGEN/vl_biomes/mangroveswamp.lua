-- TODO: move to mcl_mangrove module?
local mod_mcl_mangrove = core.get_modpath("mcl_mangrove")
local mg_seed = core.get_mapgen_setting("seed")

local get_node_name_raw = mcl_vars.get_node_name_raw

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
	_vl_biome_type = "hot",
	_vl_water_temp = "warm",
	_vl_grass_palette = "mangroveswamp",
	_vl_foliage_palette = "mangroveswamp",
	_vl_water_palette = "mangroveswamp",
	_vl_water_fogcolor = "#3A7A6A",
	_vl_skycolor = vl_biomes.skycolor.beach,
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
	local pr = PcgRandom(blockseed + mg_seed + 38327)
	for _, pos in ipairs(t) do
		local nn = core.find_nodes_in_area(minp, maxp, {"mcl_mangrove:mangrove_roots"})
		if nn and #nn > 0 then
			for _, v in pairs(nn) do
				local l = pr:next(2, 16)
				local n = get_node_name_raw(v.x, v.y-1, v.z)
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

vl_biomes.register_decoration({
	name = "vl_biomes:mangrove_tree_1",
	biomes = {"MangroveSwamp"}, -- "MangroveSwamp_shore"},
	schematic = mod_mcl_mangrove .. "/schematics/mcl_mangrove_tree_1.mts",
	y_min = 1,
	place_on = {"mcl_mud:mud"},
	place_offset_y = 1,
	fill_ratio = 0.0065,
	flags = "place_center_x, place_center_z, force_placement", -- not default. force_placement
	gen_callback = mangrove_root_gennotify,
	-- already in schematic: _vl_foliage_palette = "mangroveswamp",
})

vl_biomes.register_decoration({
	name = "vl_biomes:mangrove_tree_2",
	biomes = {"MangroveSwamp"}, -- "MangroveSwamp_shore"},
	schematic = mod_mcl_mangrove .. "/schematics/mcl_mangrove_tree_2.mts",
	y_min = -1,
	place_on = {"mcl_mud:mud"},
	place_offset_y = 1,
	fill_ratio = 0.0045,
	flags = "place_center_x, place_center_z, force_placement", -- not default. force_placement
	gen_callback = mangrove_root_gennotify,
	-- already in schematic: _vl_foliage_palette = "mangroveswamp",
})

vl_biomes.register_decoration({
	name = "vl_biomes:mangrove_tree_3",
	biomes = {"MangroveSwamp"}, -- "MangroveSwamp_shore"},
	schematic = mod_mcl_mangrove .. "/schematics/mcl_mangrove_tree_3.mts",
	y_min = -1,
	place_on = {"mcl_mud:mud"},
	place_offset_y = 1,
	fill_ratio = 0.023,
	flags = "place_center_x, place_center_z, force_placement", -- not default. force_placement
	gen_callback = mangrove_root_gennotify,
	-- already in schematic: _vl_foliage_palette = "mangroveswamp",
})

vl_biomes.register_decoration({
	name = "vl_biomes:mangrove_tree_4",
	biomes = {"MangroveSwamp"}, -- "MangroveSwamp_shore"},
	schematic = mod_mcl_mangrove .. "/schematics/mcl_mangrove_tree_4.mts",
	y_min = -1,
	place_on = {"mcl_mud:mud"},
	place_offset_y = 1,
	fill_ratio = 0.023,
	flags = "place_center_x, place_center_z, force_placement", -- not default. force_placement
	gen_callback = mangrove_root_gennotify,
	-- already in schematic: _vl_foliage_palette = "mangroveswamp",
})

vl_biomes.register_decoration({
	biomes = {"MangroveSwamp"}, -- "MangroveSwamp_shore"},
	name = "vl_biomes:mangrove_tree_5",
	schematic = mod_mcl_mangrove .. "/schematics/mcl_mangrove_tree_5.mts",
	y_min = -1,
	place_on = {"mcl_mud:mud"},
	place_offset_y = 1,
	fill_ratio = 0.023,
	flags = "place_center_x, place_center_z, force_placement", -- not default. force_placement
	gen_callback = mangrove_root_gennotify,
	-- already in schematic: _vl_foliage_palette = "mangroveswamp",
})

vl_biomes.register_decoration({
	name = "vl_biomes:mangrove_bee_nest",
	biomes = {"MangroveSwamp"},
	schematic = mod_mcl_mangrove .. "/schematics/mcl_mangrove_bee_nest.mts",
	place_on = {"mcl_mud:mud"},
	place_offset_y = 1,
	spawn_by = "group:flower",
	fill_ratio = 0.0005,
	flags = "place_center_x, place_center_z, force_placement", -- not default. force_placement
	rank = 1550,
	gen_callback = mangrove_root_gennotify,
	-- already in schematic: _vl_foliage_palette = "mangroveswamp",
})

vl_biomes.register_decoration({
	biomes = {"MangroveSwamp"}, --"MangroveSwamp_shore"},
	decoration = "mcl_mangrove:water_logged_roots",
	y_min = 0,
	y_max = 0,
	place_on = {"mcl_mud:mud"},
	fill_ratio = 0.045,
	flags = "place_center_x, place_center_z, force_placement", -- not default. force_placement
})

vl_biomes.register_decoration({
	biomes = {"MangroveSwamp"}, --"MangroveSwamp_shore"},
	decoration = "mcl_mangrove:water_logged_roots",
	y_min = 0,
	y_max = 0,
	place_on = {"mcl_mangrove:mangrove_roots"},
	spawn_by = {"group:water"},
	num_spawn_by = 2,
	fill_ratio = 10,
	flags = "place_center_x, place_center_z, force_placement, all_ceilings", -- not default: all_ceilings
})

vl_biomes.register_decoration({
	biomes = {"MangroveSwamp"}, --"MangroveSwamp_shore"},
	decoration = "mcl_mangrove:mangrove_mud_roots",
	place_on = {"mcl_mud:mud"},
	place_offset_y = -1,
	fill_ratio = 0.045,
})

vl_biomes.register_decoration({
	biomes = {"MangroveSwamp"}, --"MangroveSwamp_shore"},
	decoration = "mcl_core:deadbush",
	place_on = {"mcl_mud:mud"},
	fill_ratio = 0.008,
})

vl_biomes.register_decoration({
	biomes = {"MangroveSwamp"}, --"MangroveSwamp_shore"},
	decoration = "mcl_flowers:waterlily",
	place_on = {"mcl_core:water_source"},
	fill_ratio = 0.035,
})
