local min = math.min
local floor = math.floor
local ceil = math.ceil
local vector_copy = vector.copy
local is_liquid = vl_terraforming._is_liquid
local is_solid_not_tree = vl_terraforming._is_solid_not_tree
local get_node = core.get_node

--- Find ground below a given position
-- @param pos vector: Start position
-- @param miny int: Minimum y
-- @param maxy int: Maximum y
-- @return position and material of surface
function vl_terraforming.find_ground(pos, miny, maxy)
	if not pos then return nil, nil end
	pos = vector_copy(pos)
	local cur = get_node(pos)
	if cur.name == "ignore" then
		minetest.log("warning", "find_ground with invalid position (outside of emerged area?) at "..minetest.pos_to_string(pos)
		                     ..": "..tostring(cur and cur.name))
		return nil
	end
	if is_solid_not_tree(cur) then -- find up
		local prev = cur
		while pos.y < maxy do
			pos.y = pos.y + 1
			local cur = get_node(pos)
			if not cur or cur.name == "ignore" then
				-- minetest.log("action", "No ground, "..tostring(cur and cur.name).." over "..tostring(prev and prev.name).." at "..minetest.pos_to_string(pos))
				return nil
			end
			if is_liquid(cur) then
				return nil
			end
			if not is_solid_not_tree(cur) then
				pos.y = pos.y - 1
				return pos, prev
			end
			prev = cur
		end
		return nil
	else -- find down
		while pos.y > miny do
			pos.y = pos.y - 1
			local prev = cur
			local cur = get_node(pos)
			if not cur or cur.name == "ignore" then
				-- minetest.log("action", "No ground, "..tostring(cur and cur.name).." below "..tostring(prev and prev.name).." at "..minetest.pos_to_string(pos))
				return nil
			end
			if is_liquid(cur) then
				return nil
			end
			if is_solid_not_tree(cur) then
				return pos, cur
			end
		end
		return nil
	end
end
local find_ground = vl_terraforming.find_ground

--- Find ground or liquid surface for a given position
-- @param pos vector: Start position
-- @param miny int: Minimum y
-- @param maxy int: Maximum y
-- @return position and material of surface
function vl_terraforming.find_under_air(pos, miny, maxy)
	if not pos then return nil, nil end
	pos = vector_copy(pos)
	local cur = get_node(pos)
	if cur.name == "ignore" then
		minetest.log("warning", "find_under_air with invalid position (outside of emerged area?) at "..minetest.pos_to_string(pos)
		                     ..": "..tostring(cur and cur.name))
		return nil
	end
	if is_solid_not_tree(cur) or is_liquid(cur) then -- find up
		local prev = cur
		while pos.y < maxy do
			pos.y = pos.y + 1
			local cur = get_node(pos)
			if not cur or cur.name == "ignore" then
				-- minetest.log("action", "No ground, "..tostring(cur and cur.name).." over "..tostring(prev and prev.name).." at "..minetest.pos_to_string(pos))
				return nil
			end
			if not is_solid_not_tree(cur) and not is_liquid(cur) then
				pos.y = pos.y - 1
				-- minetest.log("action", "Found surface: "..minetest.pos_to_string(pos).." "..tostring(prev and prev.name).." under "..tostring(cur and cur.name))
				return pos, prev
			end
			prev = cur
		end
		return nil
	else -- find down
		while pos.y > miny do
			pos.y = pos.y - 1
			local prev = cur
			local cur = get_node(pos)
			if not cur or cur.name == "ignore" then
				-- minetest.log("action", "No ground, "..tostring(cur and cur.name).." below "..tostring(prev and prev.name).." at "..minetest.pos_to_string(pos))
				return nil
			end
			if is_solid_not_tree(cur) or is_liquid(cur) then
				-- minetest.log("action", "Found surface: "..minetest.pos_to_string(pos).." "..(cur and cur.name).." over "..(prev and prev.name))
				return pos, cur
			end
		end
		return nil
	end
end
local find_under_air = vl_terraforming.find_under_air

--- Find liquid surface for a given position
-- @param pos vector: Start position
-- @param miny int: Minimum y
-- @param maxy int: Maximum y
-- @return position and material of surface
function vl_terraforming.find_liquid_surface(pos, miny, maxy)
	if not pos then return nil, nil end
	pos = vector_copy(pos)
	local cur = get_node(pos)
	if cur.name == "ignore" then
		minetest.log("warning", "find_liquid_surface with invalid position (outside of emerged area?) at "..minetest.pos_to_string(pos)
		                     ..": "..tostring(cur and cur.name))
		return nil
	end
	if is_liquid(cur) then -- find up
		local prev = cur
		while pos.y < maxy do
			pos.y = pos.y + 1
			local cur = get_node(pos)
			if not cur or cur.name == "ignore" then
				-- minetest.log("action", "No ground, "..tostring(cur and cur.name).." over "..tostring(prev and prev.name).." at "..minetest.pos_to_string(pos))
				return nil
			end
			if not is_liquid(cur) then
				pos.y = pos.y - 1
				-- minetest.log("action", "Found surface: "..minetest.pos_to_string(pos).." "..tostring(prev and prev.name).." under "..tostring(cur and cur.name))
				return pos, prev
			end
			prev = cur
		end
		return nil
	else -- find down
		while pos.y > miny do
			pos.y = pos.y - 1
			local prev = cur
			local cur = get_node(pos)
			if not cur or cur.name == "ignore" then
				-- minetest.log("action", "No ground, "..tostring(cur and cur.name).." below "..tostring(prev and prev.name).." at "..minetest.pos_to_string(pos))
				return nil
			end
			if is_solid_not_tree(cur) then
				-- minetest.log("action", "No ground, "..tostring(cur and cur.name).." below "..tostring(prev and prev.name).." at "..minetest.pos_to_string(pos))
				return nil
			end
			if is_liquid(cur) then
				-- minetest.log("action", "Found surface: "..minetest.pos_to_string(pos).." "..(cur and cur.name).." over "..(prev and prev.name))
				return pos, cur
			end
		end
		return nil
	end
end
local find_liquid_surface = vl_terraforming.find_liquid_surface

--- Find under water surface for a given position
-- @param pos vector: Start position
-- @param miny int: Minimum y
-- @param maxy int: Maximum y
-- @return position and material of surface
function vl_terraforming.find_under_water_surface(pos, miny, maxy)
	if not pos then return nil, nil end
	pos = vector_copy(pos)
	local cur = get_node(pos)
	if cur.name == "ignore" then
		minetest.log("warning", "find_under_water_surface with invalid position (outside of emerged area?) at "..minetest.pos_to_string(pos)
		                     ..": "..tostring(cur and cur.name))
		return nil
	end
	if is_solid_not_tree(cur) then -- find up
		local prev = cur
		while pos.y < maxy do
			pos.y = pos.y + 1
			local cur = get_node(pos)
			if not cur or cur.name == "ignore" then
				-- minetest.log("action", "No ground, "..tostring(cur and cur.name).." over "..tostring(prev and prev.name).." at "..minetest.pos_to_string(pos))
				return nil
			end
			if is_liquid(cur) then
				pos.y = pos.y - 1
				-- minetest.log("action", "Found surface: "..minetest.pos_to_string(pos).." "..tostring(prev and prev.name).." under "..tostring(cur and cur.name))
				return pos, prev
			end
			prev = cur
		end
		return nil
	else -- find down
		while pos.y > miny do
			pos.y = pos.y - 1
			local prev = cur
			local cur = get_node(pos)
			if not cur or cur.name == "ignore" then
				-- minetest.log("action", "No ground, "..tostring(cur and cur.name).." below "..tostring(prev and prev.name).." at "..minetest.pos_to_string(pos))
				return nil
			end
			if is_solid_not_tree(cur) then
				if is_liquid(prev) then
					-- minetest.log("action", "Found surface: "..minetest.pos_to_string(pos).." "..(cur and cur.name).." over "..(prev and prev.name))
					return pos, cur
				else
					-- minetest.log("action", "No ground, "..tostring(cur and cur.name).." below "..tostring(prev and prev.name).." at "..minetest.pos_to_string(pos))
					return nil, nil
				end
			end
		end
		return nil
	end
end
local find_under_water_surface = vl_terraforming.find_under_water_surface

--- find suitable height for a structure of this size
-- @param cpos vector: center
-- @param miny int: minimum y
-- @param maxy int: maximum y
-- @param size vector: area size
-- @param tolerance number or string: maximum height difference allowed, default 8,
-- @param surface string: "solid" (default), "liquid_surface", "under_air"
-- @param mode string: "median" (default), "min" and "max"
-- @return position over surface, surface material  (or nil, nil)
function vl_terraforming.find_level(cpos, miny, maxy, size, tolerance, surface, mode)
	local _find_ground = find_ground
	if surface == "liquid_surface" or surface == "liquid" then _find_ground = find_liquid_surface end
	if surface == "under_water" or surface == "water" then _find_ground = find_under_water_surface end
	if surface == "under_air" then _find_ground = find_under_air end
	-- begin at center, then top-left and clockwise
	local pos, surface_material = _find_ground(cpos, miny, maxy)
	if not pos then
		-- minetest.log("action", "[vl_terraforming] no ground at starting position "..minetest.pos_to_string(cpos).." surface "..tostring(surface or "default"))
		return nil, nil
	end
	local ys = { pos.y }
	pos.y = pos.y + 1 -- position above surface
	if size.x == 1 and size.z == 1 then return pos end
	-- move to top left corner
	pos.x, pos.z = pos.x - floor((size.x-1)/2), pos.z - floor((size.z-1)/2)
	local pos_c = _find_ground(pos, miny, maxy)
	if pos_c then table.insert(ys, pos_c.y) end
	-- move to top right corner
	pos.x = pos.x + size.x - 1
	local pos_c = _find_ground(pos, miny, maxy)
	if pos_c then table.insert(ys, pos_c.y) end
	-- move to bottom right corner
	pos.z = pos.z + size.z - 1
	local pos_c = _find_ground(pos, miny, maxy)
	if pos_c then table.insert(ys, pos_c.y) end
	-- move to bottom left corner
	pos.x = pos.x - (size.x - 1)
	local pos_c = _find_ground(pos, miny, maxy)
	if pos_c then table.insert(ys, pos_c.y) end
	table.sort(ys)
	if #ys < 5 then return nil, nil end -- not fully supported

	tolerance = tolerance or 6 -- default value
	if mode == "min" then -- ignore the largest when using min
		if ys[#ys-1]-ys[1] > tolerance then return nil, nil end
		cpos.y = ys[1]
	elseif mode == "max" then -- ignore the smallest when using max
		if ys[#ys]-ys[2] > tolerance then return nil, nil end
		cpos.y = ys[#ys]
	else -- median
		if min(ys[#ys-1]-ys[1], ys[#ys]-ys[2]) > tolerance then
			-- minetest.log("action", "[vl_terraforming] ground too uneven: "..#ys.." positions: "..({dump(ys):gsub("[\n\t ]+", " ")})[1]
			--                      .." tolerance "..tostring(#ys > 2 and min(ys[#ys-1]-ys[1], ys[#ys]-ys[2])).." > "..tolerance)
			return nil, nil
		end
		cpos.y = floor(0.5 * (ys[floor(1 + (#ys - 1) * 0.5)] + ys[ceil(1 + (#ys - 1) * 0.5)])) -- rounded
	end
	return cpos, surface_material
end

