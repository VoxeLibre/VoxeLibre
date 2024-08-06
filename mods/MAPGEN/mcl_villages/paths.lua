-------------------------------------------------------------------------------
-- generate paths between buildings
-------------------------------------------------------------------------------

local light_threshold = tonumber(minetest.settings:get("mcl_villages_light_threshold")) or 5

-- This ends up being a nested table.
-- 1st level is the blockseed which is the village
-- 2nd is the distance of the building from the bell
-- 3rd is the pos of the end points
local path_ends = {}

-- Insert end points in to the nested tables
function mcl_villages.store_path_ends(lvm, minp, maxp, pos, blockseed, bell_pos)
	-- We store by distance because we create paths far away from the bell first
	local dist = vector.distance(bell_pos, pos)
	local id = "block_" .. blockseed -- cannot use integers as keys
	local tab = path_ends[id]
	if not tab then
		tab = {}
		path_ends[id] = tab
	end
	if tab[dist] == nil then tab[dist] = {} end
	-- TODO: improve, use LVM data instead of nodes
	local v = vector.zero()
	local i = 0
	for zi = minp.z-2, maxp.z+2 do
		v.z = zi
		for yi = minp.y-2, maxp.y+2 do
			v.y = yi
			for xi = minp.x-2, maxp.x+2 do
				v.x = xi
				local n = lvm:get_node_at(v)
				if n and n.name == "mcl_villages:path_endpoint" then
					i = i + 1
					table.insert(tab[dist], minetest.pos_to_string(v))
					lvm:set_node_at(v, { name = "air" })
				end
			end
		end
	end
end

local function place_lamp(pos, pr)
	local lamp_index = pr:next(1, #mcl_villages.schematic_lamps)
	local schema = mcl_villages.schematic_lamps[lamp_index]
	local schem_lua = mcl_villages.substitute_materials(pos, schema.schem_lua, pr)
	local schematic = loadstring(schem_lua)()

	minetest.place_schematic(
		vector.offset(pos, 0, schema.yadjust or 0, 0),
		schematic,
		"0",
		{["air"] = "ignore"}, -- avoid destroying stairs etc.
		true,
		{ place_center_x = true, place_center_y = false, place_center_z = true }
	)
end

local function smooth_path(path)
	-- Smooth out bumps in path or stairs can look naf
	for pass = 1, 3 do
	for i = 2, #path - 1 do
		local prev_y = path[i - 1].y
		local y = path[i].y
		local next_y = path[i + 1].y
		local bump_node = minetest.get_node(path[i])

		-- TODO: replace bamboo underneath with dirt here?
		if minetest.get_item_group(bump_node.name, "water") ~= 0 then
			-- ignore in this pass
		elseif y >= next_y + 2 and y <= prev_y then
			minetest.swap_node(vector.offset(path[i], 0, -1, 0), { name = "air" })
			path[i].y = path[i].y - 1
		elseif y <= next_y - 2 and y >= prev_y then
			minetest.swap_node(path[i], { name = "mcl_core:dirt" })
			path[i].y = path[i].y + 1
		elseif y >= prev_y + 2 and y <= next_y then
			minetest.swap_node(vector.offset(path[i], 0, -1, 0), { name = "air" })
			path[i].y = path[i].y - 1
		elseif y <= prev_y - 2 and y >= prev_y then
			minetest.swap_node(path[i], { name = "mcl_core:dirt" })
			path[i].y = path[i].y + 1
		elseif y < prev_y and y < next_y then
			-- Fill in dip to flatten path
			minetest.swap_node(path[i], { name = "mcl_core:dirt" })
			path[i].y = path[i].y + 1
		elseif y > prev_y and y > next_y then
			-- Remove peak to flatten path
			minetest.swap_node(vector.offset(path[i], 0, -1, 0), { name = "air" })
			path[i].y = path[i].y - 1
		end
	end
	end
end

local function place_path(path, pr, stair, slab)
	-- Smooth out bumps in path or stairs can look naf
	for i = 2, #path - 1 do
		local prev_y = path[i - 1].y
		local y = path[i].y
		local next_y = path[i + 1].y
		local bump_node = minetest.get_node(path[i])

		if minetest.get_item_group(bump_node.name, "water") ~= 0 then
			-- Find air
			local found_surface = false
			local up_pos = path[i]
			while not found_surface do
				up_pos = vector.offset(up_pos, 0, 1, 0)
				local up_node = minetest.get_node(up_pos)
				if up_node and minetest.get_item_group(up_node.name, "water") == 0 then
					found_surface = true
					minetest.swap_node(up_pos, { name = "air" })
					path[i] = up_pos
				end
			end
		elseif y < prev_y and y < next_y then
			-- Fill in dip to flatten path
			-- TODO: do not break other path/stairs
			minetest.swap_node(path[i], { name = "mcl_core:dirt" })
			path[i] = vector.offset(path[i], 0, 1, 0)
		elseif y > prev_y and y > next_y then
			-- TODO: do not break other path/stairs
			-- Remove peak to flatten path
			minetest.swap_node(vector.offset(path[i], 0, -1, 0), { name = "air" })
			path[i].y = path[i].y - 1
		end
	end

	for i, pos in ipairs(path) do
		-- replace decorations, grass and flowers, with air
		local n0 = minetest.get_node(pos)
		if n0.name ~= "air" then
			minetest.swap_node(pos, { name = "air" })
		end

		local under_pos = vector.offset(pos, 0, -1, 0)
		local n = minetest.get_node(under_pos)
		local done = false
		local is_stair = minetest.get_item_group(n.name, "stair") ~= 0

		if i > 1 and pos.y > path[i - 1].y then
			-- stairs up
			if not is_stair then
				done = true
				local param2 = minetest.dir_to_facedir(vector.subtract(pos, path[i - 1]))
				minetest.swap_node(under_pos, { name = stair, param2 = param2 })
			end
		elseif i < #path-1 and pos.y > path[i + 1].y then
			-- stairs down
			if not is_stair then
				done = true
				local param2 = minetest.dir_to_facedir(vector.subtract(pos, path[i + 1]))
				minetest.swap_node(under_pos, { name = stair, param2 = param2 })
			end
		elseif not is_stair and i > 1 and pos.y < path[i - 1].y then
			-- stairs down
			local n2 = minetest.get_node(vector.offset(path[i - 1], 0, -1, 0))
			is_stair = minetest.get_item_group(n2.name, "stair") ~= 0
			if not is_stair then
				done = true
				local param2 = minetest.dir_to_facedir(vector.subtract(path[i - 1], pos))
				if i < #path - 1 then -- uglier, but easier to walk up?
					param2 = minetest.dir_to_facedir(vector.subtract(pos, path[i + 1]))
				end
				minetest.add_node(pos, { name = stair, param2 = param2 })
				pos.y = pos.y + 1
			end
		elseif not is_stair and i < #path-1 and pos.y < path[i + 1].y then
			-- stairs up
			local n2 = minetest.get_node(vector.offset(path[i + 1], 0, -1, 0))
			is_stair = minetest.get_item_group(n2.name, "stair") ~= 0
			if not is_stair then
				done = true
				local param2 = minetest.dir_to_facedir(vector.subtract(path[i + 1], pos))
				if i > 1 then -- uglier, but easier to walk up?
					param2 = minetest.dir_to_facedir(vector.subtract(pos, path[i - 1]))
				end
				minetest.add_node(pos, { name = stair, param2 = param2 })
				pos.y = pos.y + 1
			end
		end

		-- flat
		if not done then
			if minetest.get_item_group(n.name, "water") ~= 0 then
				minetest.add_node(under_pos, { name = slab })
			elseif n.name == "mcl_core:sand" or n.name == "mcl_core:redsand" then
				minetest.swap_node(under_pos, { name = "mcl_core:sandstonesmooth2" })
			elseif minetest.get_item_group(n.name, "soil") > 0
				and minetest.get_item_group(n.name, "dirtifies_below_solid") == 0
				then
					minetest.swap_node(under_pos, { name = "mcl_core:grass_path" })
			end
		end

		-- Clear space for villagers to walk
		for j = 1, 2 do
			local over_pos = vector.offset(pos, 0, j, 0)
			local m = minetest.get_node(over_pos)
			if m.name ~= "air" then
				minetest.swap_node(over_pos, { name = "air" })
			end
		end
	end

	-- Do lamps afterwards so we don't put them where a path will be laid
	for _, pos in ipairs(path) do
		if minetest.get_node_light(pos, 0) < light_threshold then
			local nn = minetest.find_nodes_in_area_under_air(
				vector.offset(pos, -1, -1, -1),
				vector.offset(pos, 1, 1, 1),
				{ "group:material_sand", "group:material_stone", "group:grass_block", "group:wood_slab" }
			)
			for _, npos in ipairs(nn) do
				local node = minetest.get_node(npos)
				if node.name ~= "mcl_core:grass_path" and minetest.get_item_group(node.name, "stair") == 0 then
					if minetest.get_item_group(node.name, "wood_slab") ~= 0 then
						local over_pos = vector.offset(npos, 0, 1, 0)
						minetest.add_node(over_pos, { name = "mcl_torches:torch", param2 = 1 })
					else
						place_lamp(npos, pr)
					end
					break
				end
			end
		end
	end
end

-- Work out which end points should be connected
-- works from the outside of the village in
function mcl_villages.paths(blockseed, biome_name)
	local pr = PseudoRandom(blockseed)
	local pathends = path_ends["block_" .. blockseed]

	if pathends == nil then
		minetest.log("warning", string.format("[mcl_villages] Tried to set paths for block seed that doesn't exist %d", blockseed))
		return
	end

	-- Use the same stair and slab throughout the entire village
	local stair, slab = '"mcl_stairs:stair_oak"', '"mcl_stairs:slab_oak_top"'

	-- Change stair and slab for biome
	if mcl_villages.biome_map[biome_name] and mcl_villages.material_substitions[mcl_villages.biome_map[biome_name]] then
		for _, sub in pairs(mcl_villages.material_substitions[mcl_villages.biome_map[biome_name]]) do
			stair = stair:gsub(sub[1], sub[2])
			slab = slab:gsub(sub[1], sub[2])
		end
	end
	-- translate MCLA values to VL
	for _, sub in pairs(mcl_villages.mcla_to_vl) do
		stair = stair:gsub(sub[1], sub[2])
		slab = slab:gsub(sub[1], sub[2])
	end
	-- The quotes are to match what is in schemas, but we don't want them now
	stair = stair:gsub('"', "")
	slab = slab:gsub('"', "")

	-- Keep track of connections
	local connected = {}

	-- get a list of reverse sorted keys, which are distances
	local dist_keys = {}
	for k in pairs(pathends) do
		table.insert(dist_keys, k)
	end
	table.sort(dist_keys, function(a, b)
		return a > b
	end)
	--minetest.log("Planning paths with "..#dist_keys.." nodes")

	for i, from in ipairs(dist_keys) do
		-- ep == end_point
		for _, from_ep in ipairs(pathends[from]) do
			local from_ep_pos = minetest.string_to_pos(from_ep)
			local closest_pos
			local closest_bld
			local best = 10000000

			-- Most buildings only do other buildings that are closer to the bell
			-- for the bell do any end points that don't have paths near them
			local lindex = i + 1
			if i == 0 then
				lindex = 1
			end

			for j = lindex, #dist_keys do
				local to = dist_keys[j]
				if from ~= to and connected[from .. "-" .. to] == nil and connected[to .. "-" .. from] == nil then
					for _, to_ep in ipairs(pathends[to]) do
						local to_ep_pos = minetest.string_to_pos(to_ep)

						local dist = vector.distance(from_ep_pos, to_ep_pos)
						if dist < best then
							best = dist
							closest_pos = to_ep_pos
							closest_bld = to
						end
					end
				end
			end

			if closest_pos then
				local path = minetest.find_path(from_ep_pos, closest_pos, 64, 2, 2)
				if path then smooth_path(path) end
				if not path then
					path = minetest.find_path(from_ep_pos, closest_pos, 64, 3, 3)
					if path then smooth_path(path) end
				end
				path = minetest.find_path(from_ep_pos, closest_pos, 64, 1, 1)
				if path and #path > 0 then
					place_path(path, pr, stair, slab)
					connected[from .. "-" .. closest_bld] = 1
				else
					minetest.log(
						"warning",
						string.format(
							"[mcl_villages] No path from %s to %s, distance %d",
							minetest.pos_to_string(from_ep_pos),
							minetest.pos_to_string(closest_pos),
							vector.distance(from_ep_pos, closest_pos)
						)
					)
				end
			end
		end
	end

	-- Loop again to blow away no path nodes
	for _, from in ipairs(dist_keys) do
		for _, from_ep in ipairs(pathends[from]) do
			local from_ep_pos = minetest.string_to_pos(from_ep)
			local no_paths_nodes = minetest.find_nodes_in_area(
				vector.offset(from_ep_pos, -32, -32, -32),
				vector.offset(from_ep_pos, 32, 32, 32),
				{ "mcl_villages:no_paths" }
			)
			if #no_paths_nodes > 0 then
				minetest.bulk_set_node(no_paths_nodes, { name = "air" })
			end
		end
	end

	path_ends["block_" .. blockseed] = nil
end
