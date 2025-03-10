-- TODO: overall, these pools tend to be very circular, can we make them more interesting?
-- TODO: use the new vl_terraforming API?

local mg_name = core.get_mapgen_setting("mg_name")

local get_node_name = mcl_vars.get_node_name

local adjacents = {
	vector.new(1,0,0),
	vector.new(1,0,1),
	vector.new(1,0,-1),
	vector.new(-1,0,0),
	vector.new(-1,0,1),
	vector.new(-1,0,-1),
	vector.new(0,0,1),
	vector.new(0,0,-1),
	vector.new(0,-1,0)
}

local function makelake(pos, size, liquid, placein, border, pr, noair)
	local p1, p2 = vector.offset(pos,-size,0,-size), vector.offset(pos,size,0,size)
	local e1, e2 = vector.offset(pos,-size,-1,-size), vector.offset(pos,size,15,size)
	core.emerge_area(e1, e2, function(_, _, calls_remaining)
		if calls_remaining ~= 0 then return end
		local nn = core.find_nodes_in_area(p1, p2, placein)
		if #nn == 0 then return end
		table.sort(nn, function(a, b)
		   return vector.distance(pos, a) < vector.distance(pos, b)
		end)
		local y = pos.y
		local lq, air = {}, {}
		local r = pr:next(1,math.ceil(#nn * 0.7)) -- circle is pi/4 of the square
		for i=1,r do
			table.insert(lq, nn[i])
			for j = 1, 25 do
				table.insert(air, vector.offset(nn[i], 0, j, 0))
			end
		end
		core.bulk_swap_node(lq, { name = liquid })
		core.bulk_swap_node(air, { name = "air" })
		local br = {}
		for k,v in pairs(lq) do
			for kk,vv in pairs(adjacents) do
				local pp = vector.add(v,vv)
				local an = get_node_name(pp)
				if #br == 0 and core.get_item_group(an.name, "solid") > 0 then border = an end
				if not noair and an ~= liquid then
					table.insert(br,pp)
				end
			end
		end
		if border.name == "mcl_core:dirt_with_grass" and not border.param2 then
			local biome = mg_name ~= "v6" and core.registered_biomes[core.get_biome_name(core.get_biome_data(nn[1]).biome)]
			local p2 = biome and biome._mcl_grass_palette_index and biome._mcl_grass_palette_index or nil
			border = { name = "mcl_core:dirt_with_grass", param2 = p2 } -- deliberate copy
		end
		core.bulk_swap_node(br, border)
		return true
	end)
	return true
end

mcl_structures.register_structure("lavapool", {
	place_on = { "group:sand", "group:dirt", "group:stone" },
	terrain_feature = true,
	noise_params = {
		offset = 0,
		scale = 0.0000022,
		spread = vector.new(250, 250, 250),
		seed = 78375213,
		octaves = 3,
		persist = 0.001,
		flags = "absvalue",
	},
	flags = "place_center_x, place_center_z",
	y_max = mcl_vars.mg_overworld_max,
	y_min = core.get_mapgen_setting("water_level"),
	place_func = function(pos, _, pr)
		return makelake(pos, 5, "mcl_core:lava_source",
			{ "group:material_stone", "group:sand", "group:dirt" },
			{ name = "mcl_core:stone" }, pr)
	end
})

mcl_structures.register_structure("water_lake", {
	place_on = { "group:dirt", "group:stone" },
	terrain_feature = true,
	noise_params = {
		offset = 0,
		scale = 0.000032,
		spread = vector.new(250, 250, 250),
		seed = 756641353,
		octaves = 3,
		persist = 0.001,
		flags = "absvalue",
	},
	flags = "place_center_x, place_center_z",
	y_max = mcl_vars.mg_overworld_max,
	y_min = core.get_mapgen_setting("water_level"),
	place_func = function(pos, _, pr)
		return makelake(pos, 5, "mcl_core:water_source",
			{ "group:material_stone", "group:sand", "group:dirt", "group:grass_block"},
			{ name = "mcl_core:dirt_with_grass" }, pr)
	end
})

mcl_structures.register_structure("water_lake_mangrove_swamp", {
	place_on = { "mcl_mud:mud" },
	biomes = { "MangroveSwamp" },
	terrain_feature = true,
	noise_params = {
		offset = 0,
		scale = 0.0032,
		spread = vector.new(250, 250, 250),
		seed = 6343241353,
		octaves = 3,
		persist = 0.001,
		flags = "absvalue",
	},
	flags = "place_center_x, place_center_z",
	y_max = mcl_vars.mg_overworld_max,
	y_min = core.get_mapgen_setting("water_level"),
	place_func = function(pos, _, pr)
		return makelake(pos, 3, "mcl_core:water_source",
			{ "group:material_stone", "group:sand", "group:dirt", "group:grass_block", "mcl_mud:mud"},
			{ name = "mcl_mud:mud" }, pr, true)
	end
})

