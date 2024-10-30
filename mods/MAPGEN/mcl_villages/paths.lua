-------------------------------------------------------------------------------
-- generate paths between buildings
-------------------------------------------------------------------------------
local light_threshold = tonumber(minetest.settings:get("mcl_villages_light_threshold")) or 5

local get_node = core.get_node
local swap_node = core.swap_node

-- This ends up being a nested table.
-- 1st level is the blockseed which is the village
-- 2nd is the distance of the building from the bell
-- 3rd is the pos of the end points
local path_ends = {}

-- simple function to increase "no_paths" walls
function mcl_villages.clean_no_paths(minp, maxp)
	local no_paths_nodes = minetest.find_nodes_in_area(minp, maxp, { "mcl_villages:no_paths" })
	if #no_paths_nodes > 0 then
		minetest.bulk_swap_node(no_paths_nodes, { name = "air" })
	end
end

-- simple function to increase "no_paths" walls
function mcl_villages.increase_no_paths(minp, maxp)
	local p = vector.zero()
	for z = minp.z, maxp.z do
		p.z = z
		for x = minp.x, maxp.x do
			p.x = x
			for y = minp.y, maxp.y - 1 do
				p.y = y
				local n = get_node(p)
				if n and n.name == "mcl_villages:no_paths" then
					p.y = y + 1
					n = get_node(p)
					if n and n.name == "air" then
						swap_node(p, {name = "mcl_villages:no_paths" })
					end
				end
			end
		end
	end
end

-- Insert end points in to the nested tables
function mcl_villages.store_path_ends(minp, maxp, pos, blockseed, bell_pos)
	-- We store by distance because we create paths far away from the bell first
	local dist = vector.distance(bell_pos, pos)
	local id = "block_" .. blockseed -- cannot use integers as keys
	-- TODO: benchmark best way
	local tab = {}
	local v = vector.zero()
	for zi = minp.z, maxp.z do
		v.z = zi
		for yi = minp.y, maxp.y do
			v.y = yi
			for xi = minp.x, maxp.x do
				v.x = xi
				local n = get_node(v)
				if n and n.name == "mcl_villages:path_endpoint" then
					table.insert(tab, vector.copy(v))
					swap_node(v, { name = "air" })
				end
			end
		end
	end
	if not path_ends[id] then path_ends[id] = {} end
	table.insert(path_ends[id], {dist, minetest.pos_to_string(pos), tab})
end

local function place_lamp(pos, pr)
	local lamp_index = pr:next(1, #mcl_villages.schematic_lamps)
	local schema = mcl_villages.schematic_lamps[lamp_index]
	local schem_lua = mcl_villages.substitute_materials(pos, schema.schem_lua, pr)
	local schematic = loadstring(schem_lua)()

	minetest.place_schematic(vector.offset(pos, 0, schema.yadjust or 0, 0), schematic, "0",
		{["air"] = "ignore"}, -- avoid destroying stairs etc.
		true,
		{ place_center_x = true, place_center_y = false, place_center_z = true }
	)
end

local function smooth_path(path, passes, minp, maxp)
	-- bridge over water/laver
	for i = 2, #path - 1 do
		while true do
			local cur = path[i]
			local node = get_node(cur).name
			if node == "air" and vector.in_area(cur, minp, maxp) then
				local under = get_node(vector.offset(path[i], 0, -1, 0)).name
				local udef = minetest.registered_nodes[under]
				-- do not build paths over leaves
				if udef and (udef.groups.leaves or 0) > 0 then
					swap_node(path[i], {name="mcl_villages:no_paths"})
					return -- bad path
				end
				break
			else
				local ndef = minetest.registered_nodes[node]
				if not ndef then break end -- ignore
				if (ndef.groups.water or 0) > 0 or (ndef.groups.lava or 0) > 0 then
					cur.y = cur.y + 1
				else
					break
				end
			end
		end
	end
	-- Smooth out bumps in path to reduce weird stairs
	local any_changed = false
	for pass = 1, passes do
		local changed = false
		for i = 2, #path - 1 do
			local prev_y = path[i - 1].y
			local y = path[i].y
			local next_y = path[i + 1].y
			local bump = get_node(path[i]).name
			local bdef = minetest.registered_nodes[bump]

			-- TODO: also replace bamboo underneath with dirt here?
			if bdef and ((bdef.groups.water or 0) > 0 or (bdef.groups.lava or 0) > 0) then
				-- ignore in this pass
			elseif (y > next_y + 1 and y <= prev_y) -- large step
			    or (y > prev_y + 1 and y <= next_y) -- large step
			    or (y > prev_y and y > next_y) then
				-- Remove peaks to flatten path
				path[i].y = math.max(prev_y, next_y)
				swap_node(path[i], { name = "air" })
				changed = true
			elseif (y < next_y - 1 and y >= prev_y) -- large step
			    or (y < prev_y - 1 and y >= next_y) -- large step
			    or (y < prev_y and y < next_y) then
				-- Fill in dips to flatten path
				path[i].y = math.min(prev_y, next_y) - 1 -- to replace below first
				swap_node(path[i], { name = "mcl_core:dirt" }) -- todo: use sand/sandstone in desert?, use slabs?
				path[i].y = path[i].y + 1 -- above dirt
				changed = true
			end
		end
		if changed then any_changed = true else break end
	end
	-- by delaying this, we allow making bridges over deep dips:
	--[[
	if any_changed then
		-- we may not yet have filled a gap
		for i = 2, #path - 1 do
			local below = vector.offset(path[y], 0, -1, 0)
			local bdef = minetest.registered_nodes[get_node(path[i]).name]
			if bdef and not bdef.walkable then
				swap_node(path[i], { name = "mcl_core:dirt" }) -- todo: use sand/sandstone in desert?, use slabs?
			end
		end
	end]]
	return path
end

local function place_path(path, pr, stair, slab)
	-- find water/lava below
	for i = 2, #path - 1 do
		local prev_y = path[i - 1].y
		local y = path[i].y
		local next_y = path[i + 1].y
		local bump = get_node(path[i]).name
		local bdef = minetest.registered_nodes[bump]

		if bdef and ((bdef.groups.water or 0) > 0 or (bdef.groups.lava or 0) > 0) then
			-- Find air
			local up_pos = vector.copy(path[i])
			while true do
				up_pos.y = up_pos.y + 1
				local up_node = get_node(up_pos).name
				local udef = minetest.registered_nodes[up_node]
				if udef and (udef.groups.water or 0) == 0 and (udef.groups.lava or 0) == 0 then
					swap_node(up_pos, { name = "air" })
					path[i] = up_pos
					break
				elseif not udef then break end -- ignore node encountered
			end
		end
	end

	for i, pos in ipairs(path) do
		local n0 = get_node(pos).name
		if n0 ~= "air" then swap_node(pos, { name = "air" }) end

		local under_pos = vector.offset(pos, 0, -1, 0)
		local n = get_node(under_pos).name
		local ndef = minetest.registered_nodes[n]
		local groups = ndef and ndef.groups or {}
		local done = false
		if i > 1 and pos.y > path[i - 1].y then
			-- stairs up
			if (groups.stair or 0) == 0 then
				done = true
				local param2 = minetest.dir_to_facedir(vector.subtract(pos, path[i - 1]))
				swap_node(under_pos, { name = stair, param2 = param2 })
			end
		elseif i < #path-1 and pos.y > path[i + 1].y then
			-- stairs down
			if (groups.stair or 0) == 0 then
				done = true
				local param2 = minetest.dir_to_facedir(vector.subtract(pos, path[i + 1]))
				swap_node(under_pos, { name = stair, param2 = param2 })
			end
		elseif (groups.stair or 0) == 0 and i > 1 and pos.y < path[i - 1].y then
			-- stairs down
			local n2 = get_node(vector.offset(path[i - 1], 0, -1, 0)).name
			if not minetest.get_item_group(n2, "stair") then
				done = true
				local param2 = minetest.dir_to_facedir(vector.subtract(path[i - 1], pos))
				if i < #path - 1 then -- uglier, but easier to walk up?
					param2 = minetest.dir_to_facedir(vector.subtract(pos, path[i + 1]))
				end
				minetest.add_node(pos, { name = stair, param2 = param2 })
				pos.y = pos.y + 1
			end
		elseif (groups.stair or 0) == 0 and i < #path-1 and pos.y < path[i + 1].y then
			-- stairs up
			local n2 = get_node(vector.offset(path[i + 1], 0, -1, 0)).name
			if not minetest.get_item_group(n2, "stair") then
				done = true
				local param2 = minetest.dir_to_facedir(vector.subtract(path[i + 1], pos))
				if i > 1 then -- uglier, but easier to walk up?
					param2 = minetest.dir_to_facedir(vector.subtract(pos, path[i - 1]))
				end
				swap_node(pos, { name = stair, param2 = param2 })
				pos.y = pos.y + 1
			end
		end

		-- flat
		if not done then
			if (groups.water or 0) > 0 then
				swap_node(under_pos, { name = slab })
			elseif (groups.lava or 0) > 0 then
				swap_node(under_pos, { name = "mcl_stairs:slab_stone" })
			elseif (groups.sand or 0) > 0 then
				swap_node(under_pos, { name = "mcl_core:sandstonesmooth2" })
			elseif (groups.soil or 0) > 0 and (groups.dirtifies_below_solid or 0) == 0 then
				swap_node(under_pos, { name = "mcl_core:grass_path" })
			end
		end

		-- Clear space for villagers to walk
		for j = 1, 2 do
			local over_pos = vector.offset(pos, 0, j, 0)
			if get_node(over_pos).name ~= "air" then
				swap_node(over_pos, { name = "air" })
			end
		end
	end

	-- Do lamps afterwards so we don't put them where a path will be laid
	for _, pos in ipairs(path) do
		if minetest.get_node_light(pos, 0) < light_threshold then
			local nn = minetest.find_nodes_in_area_under_air(vector.offset(pos, -1, -1, -1), vector.offset(pos, 1, 1, 1),
				{ "group:material_sand", "group:material_stone", "group:grass_block", "group:wood_slab" }
			)
			-- todo: shuffle nn?
			for _, npos in ipairs(nn) do
				local node = get_node(npos).name
				if node ~= "mcl_core:grass_path" and minetest.get_item_group(node, "stair") == 0 then
					if minetest.get_item_group(node, "wood_slab") ~= 0 then
						minetest.add_node(vector.offset(npos, 0, 1, 0), { name = "mcl_torches:torch", param2 = 1 })
					else
						place_lamp(npos, pr)
					end
					break
				end
			end
		end
	end
end

-- FIXME: ugly
function get_biome_stair_slab(biome_name)
	-- Use the same stair and slab throughout the entire village
	-- The quotes are necessary to be matched as JSON strings
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
	-- The quotes are to match what is in JSON schemas, but we don't want them now
	return  stair:gsub('"', ""), slab:gsub('"', "")
end

-- Work out which end points should be connected
-- works from the outside of the village in
function mcl_villages.paths(blockseed, biome_name, minp, maxp)
	local pr = PcgRandom(blockseed)
	local pathends = path_ends["block_" .. blockseed]
	if pathends == nil then
		minetest.log("warning", string.format("[mcl_villages] Tried to set paths for block seed that doesn't exist %d", blockseed))
		return
	end

	-- Stair and slab style of the village
	local stair, slab = get_biome_stair_slab(biome_name)

	table.sort(pathends, function(a, b) return a[1] > b[1] end)
	--minetest.log("action", "path ends: "..dump(pathends,""))
	-- find ways to connect
	local connected, to_place = {}, {}
	for _, tmp in ipairs(pathends) do
		local from, from_eps = tmp[2], tmp[3]
		-- ep == end_point
		for _, from_ep_pos in ipairs(from_eps) do
			-- TODO: add back some logic as before that ensures some longer paths, too?
			local cand = {}
			for _, tmp in ipairs(pathends) do
				local to, to_eps = tmp[2], tmp[3]
				if from ~= to and not connected[from .. "-" .. to] and not connected[to .. "-" .. from] then
					for _, to_ep_pos in ipairs(to_eps) do
						local dist = vector.distance(from_ep_pos, to_ep_pos)
						table.insert(cand, {dist, from, from_ep_pos, to, to_ep_pos})
					end
				end
			end
			table.sort(cand, function(a,b) return a[1] < b[1] end)
			--minetest.log("action", "candidates: "..dump(cand,""))
			for _, pair in ipairs(cand) do
				local dist, from, from_ep_pos, to, to_ep_pos = unpack(pair)
				local path = minetest.find_path(from_ep_pos, to_ep_pos, 10, 4, 4)
				if path then smooth_path(path, 3, minp, maxp) end
				path = minetest.find_path(from_ep_pos, to_ep_pos, 10, 2, 2)
				if path then smooth_path(path, 1, minp, maxp) end
				path = minetest.find_path(from_ep_pos, to_ep_pos, 12, 1, 1)
				if path then
					--minetest.log("path "..from.." to "..to.." len "..tostring(#path))
					path = smooth_path(path, 1, minp, maxp)
					if path then
						connected[from .. "-" .. to] = 1
						table.insert(to_place, pair)
						goto continue -- add only one path per building
					end
				end
			end
		end
		::continue::
	end

	--minetest.log("action", "to_place: "..dump(to_place,""))
	-- now lay the actual paths
	for _, cand in ipairs(to_place) do
		local dist, from, from_ep_pos, to, to_ep_pos = unpack(cand)
		local path = minetest.find_path(from_ep_pos, to_ep_pos, 12, 1, 1)
		if path then
			path = place_path(path, pr, stair, slab)
		else
			minetest.log("warning",
				string.format(
					"[mcl_villages] No good path from %s to %s, distance %d",
					minetest.pos_to_string(from_ep_pos),
					minetest.pos_to_string(to_ep_pos),
					dist
				)
			)
		end
	end

	path_ends["block_" .. blockseed] = nil
end
