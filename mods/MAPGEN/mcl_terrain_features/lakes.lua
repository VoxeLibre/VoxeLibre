-- TODO: overall, these pools tend to be very circular in open terrain, can we make them more interesting?
-- TODO: use the new vl_terraforming API to (A) avoid grass under dirt and (B) remove plants over stone
-- TODO: remove burnable nodes around lava lakes to avoid forest fires
-- TODO: add decorations in water, e.g., seagrass
-- TODO: instead of adding a border outside, shrink the placement area instead as necessary? This is nicer if there is, e.g., a tree in the lake

local mg_name = core.get_mapgen_setting("mg_name")

local get_node_name = mcl_vars.get_node_name
local get_node_name_raw = mcl_vars.get_node_name_raw

local overworld_bounds = vl_worlds.get_dimension_bounds("overworld")
assert(overworld_bounds)

local adjacents = {
	vector.new(1,0,0),
	vector.new(1,0,1),
	vector.new(1,0,-1),
	vector.new(-1,0,0),
	vector.new(-1,0,1),
	vector.new(-1,0,-1),
	vector.new(0,0,1),
	vector.new(0,0,-1)
}
local AIR = { name = "air" }

local function makelake(pos, size, def_liquid, placein, def_border, def_floor, pr, noair)
	local e1, e2 = vector.offset(pos,-size-1,-2,-size-1), vector.offset(pos,size+1,25,size+1)
	core.emerge_area(e1, e2, function(_, _, calls_remaining)
		if calls_remaining ~= 0 then return end
		local nnt = core.find_nodes_in_area(vector.offset(pos,-size,0,-size), vector.offset(pos,size,0,size), placein)
		-- keep only nodes with nothing walkable above within circle
		local sq = size * size
		local nn = {}
		for _, n in ipairs(nnt) do
			if (n.x-pos.x)^2 + (n.y-pos.y)^2 <= sq then -- circle only
				-- check y-2 below to not terrace too much
				local below = core.registered_nodes[get_node_name_raw(n.x, n.y - 2, n.z)]
				if below and below.walkable then
					-- check y+2 to not cut into terrain too much
					local aboven = get_node_name_raw(n.x, n.y + 2, n.z)
					local above = core.registered_nodes[aboven]
					if above and not (above.walkable and (above.groups.plant or 0) == 0) then
						local j = #nn > 0 and pr:next(1, #nn + 1) or 1 -- insert position for shuffling
						if j == #nn + 1 then
							nn[#nn + 1] = n -- append
						else
							nn[#nn + 1], nn[j] = nn[j], n -- swap insert for shuffling
						end
					end
				end
			end
		end
		if #nn == 0 then return end
		-- sort; but on ties the order was shuffled above
		table.sort(nn, function(a, b) return vector.distance(pos, a) < vector.distance(pos, b) end)
		local liquid, floor, air, border = {}, {}, {}, {}
		local r = pr:next(math.max(1, #nn * 0.1),#nn)
		for i=1,r do
			liquid[#liquid + 1] = nn[i]
			if not noair then
				for j = 1, 25 do
					local above = vector.offset(nn[i], 0, j, 0)
					-- TODO: do not stop on plants above lava?
					if get_node_name(above) == "air" then break end
					air[#air+1] = above
				end
			end
			-- Close holes in the floor, also replace dirt with grass
			local below = vector.offset(nn[i], 0, -1, 0)
			local bname = get_node_name(below)
			if bname == "mcl_core:dirt_with_grass" or not (core.registered_nodes[bname] or {}).walkable then
				floor[#floor + 1] = below
			end
		end
		-- Place water and air first, to determine border
		core.bulk_swap_node(liquid, def_liquid)
		core.bulk_swap_node(air, AIR)
		-- Determine border. Not very elegant, nodes are checked up to 8 times...
		for k,v in pairs(liquid) do
			for _,vv in pairs(adjacents) do
				local pp = vector.add(v,vv)
				local bn = get_node_name(pp)
				if bn ~= def_liquid.name then
					local bdef = core.registered_nodes[bn]
					if bdef and (bdef.groups.material_stone or 0) == 0 then
						border[#border + 1] = pp
					end
				end
			end
		end
		local biome = mg_name ~= "v6" and core.registered_biomes[core.get_biome_name(core.get_biome_data(nn[1]).biome)]
		local bordern = def_border or { name = biome and biome.node_top or "mcl_core:dirt_with_grass" }
		local floorn = def_floor or { name = biome and biome.node_filler or biome.node_top or "mcl_core:stone" }
		if bordern and bordern.name == "mcl_core:dirt_with_grass" and not bordern.param2 then
			local p2 = biome and biome._mcl_grass_palette_index and biome._mcl_grass_palette_index or nil
			bordern = { name = bordern.name, param2 = p2 } -- deliberate copy
		end
		core.bulk_swap_node(border, bordern)
		core.bulk_swap_node(floor, floorn)
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
	y_max = overworld_bounds.max,
	y_min = core.get_mapgen_setting("water_level"),
	place_func = function(pos, _, pr)
		return makelake(pos, 5, { name = "mcl_core:lava_source" },
			{ "group:material_stone", "group:sand", "group:dirt" },
			{ name = "mcl_core:stone" }, { name = "mcl_core:stone" }, pr)
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
	y_max = overworld_bounds.max,
	y_min = core.get_mapgen_setting("water_level"),
	place_func = function(pos, _, pr)
		return makelake(pos, 5, { name = "mclx_core:river_water_source" },
			{ "group:material_stone", "group:sand", "group:dirt", "group:grass_block"},
			nil, { name = "mcl_core:sand" }, pr)
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
	y_max = overworld_bounds.max,
	y_min = core.get_mapgen_setting("water_level"),
	place_func = function(pos, _, pr)
		return makelake(pos, 3, { name = "mcl_core:water_source" },
			{ "group:material_stone", "group:sand", "group:dirt", "group:grass_block", "mcl_mud:mud"},
			nil, { name = "mcl_mud:mud" }, pr, true)
	end
})
