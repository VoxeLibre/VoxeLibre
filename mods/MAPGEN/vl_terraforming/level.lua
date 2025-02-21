local min = math.min
local floor = math.floor
local ceil = math.ceil
local vector_copy = vector.copy
local is_liquid = vl_terraforming._is_liquid
local is_solid_not_tree = vl_terraforming._is_solid_not_tree
local get_node_name = mcl_vars.get_node_name

--- Find ground below a given position
-- @param pos vector: Start position
-- @param miny int: Minimum y
-- @param maxy int: Maximum y
-- @return position and material of surface
function vl_terraforming.find_ground(pos, miny, maxy)
	if not pos then return nil end
	pos = vector_copy(pos)
	local cur, p1, p2 = get_node_name(pos)
	if cur == "ignore" then
		core.log("warning", "find_ground with invalid position (outside of emerged area?) at "..core.pos_to_string(pos)..": "..cur)
		return nil
	end
	if is_solid_not_tree(cur) then -- find up
		local prev, pp1, pp2 = cur, p1, p2
		while pos.y < maxy do
			pos.y = pos.y + 1
			local cur, p1, p2 = get_node_name(pos)
			if cur == "ignore" then
				-- core.log("action", "No ground, "..cur.." over "..prev.." at "..core.pos_to_string(pos))
				return nil
			end
			if is_liquid(cur) then
				return nil
			end
			if not is_solid_not_tree(cur) then
				pos.y = pos.y - 1
				return pos, prev, pp1, pp2
			end
			prev, pp1, pp2 = cur, p1, p2
		end
		return nil
	else -- find down
		while pos.y > miny do
			pos.y = pos.y - 1
			-- local prev = cur
			local cur, p1, p2 = get_node_name(pos)
			if cur == "ignore" then
				-- core.log("action", "No ground, "..cur.." below "..prev.." at "..core.pos_to_string(pos))
				return nil
			end
			if is_liquid(cur) then
				return nil
			end
			if is_solid_not_tree(cur) then
				return pos, cur, p1, p2
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
	if not pos then return nil end
	pos = vector_copy(pos)
	local cur, p1, p2 = get_node_name(pos)
	if cur == "ignore" then
		core.log("warning", "find_under_air with invalid position (outside of emerged area?) at "..core.pos_to_string(pos)..": "..cur)
		return nil
	end
	if is_solid_not_tree(cur) or is_liquid(cur) then -- find up
		local prev, pp1, pp2 = cur, p1, p2
		while pos.y < maxy do
			pos.y = pos.y + 1
			local cur, p1, p2 = get_node_name(pos)
			if cur == "ignore" then
				-- core.log("action", "No ground, "..cur.." over "..prev.." at "..core.pos_to_string(pos))
				return nil
			end
			if not is_solid_not_tree(cur) and not is_liquid(cur) then
				pos.y = pos.y - 1
				-- core.log("action", "Found surface: "..core.pos_to_string(pos).." "..prev.." under "..cur)
				return pos, prev, pp1, pp2
			end
			prev, pp1, pp2 = cur, p1, p2
		end
		return nil
	else -- find down
		while pos.y > miny do
			pos.y = pos.y - 1
			-- local prev = cur
			local cur, p1, p2 = get_node_name(pos)
			if cur == "ignore" then
				-- core.log("action", "No ground, "..cur.." below "..prev.." at "..core.pos_to_string(pos))
				return nil
			end
			if is_solid_not_tree(cur) or is_liquid(cur) then
				-- core.log("action", "Found surface: "..core.pos_to_string(pos).." "..cur.." over "..prev)
				return pos, cur, p1, p2
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
	if not pos then return nil end
	pos = vector_copy(pos)
	local cur, p1, p2 = get_node_name(pos)
	if cur == "ignore" then
		core.log("warning", "find_liquid_surface with invalid position (outside of emerged area?) at "..core.pos_to_string(pos)..": "..cur)
		return nil
	end
	if is_liquid(cur) then -- find up
		local prev, pp1, pp2 = cur, p1, p2
		while pos.y < maxy do
			pos.y = pos.y + 1
			local cur, p1, p2 = get_node_name(pos)
			if cur == "ignore" then
				-- core.log("action", "No ground, "..cur.." over "..prev.." at "..core.pos_to_string(pos))
				return nil
			end
			if not is_liquid(cur) then
				pos.y = pos.y - 1
				-- core.log("action", "Found surface: "..core.pos_to_string(pos).." "..prev.." under "..cur)
				return pos, prev, pp1, pp2
			end
			prev, pp1, pp2 = cur, p1, p2
		end
		return nil
	else -- find down
		while pos.y > miny do
			pos.y = pos.y - 1
			-- local prev = cur
			local cur, p1, p2 = get_node_name(pos)
			if cur == "ignore" then
				-- core.log("action", "No ground, "..cur.." below "..prev.." at "..core.pos_to_string(pos))
				return nil
			end
			if is_solid_not_tree(cur) then
				-- core.log("action", "No ground, "..cur.." below "..prev.." at "..core.pos_to_string(pos))
				return nil
			end
			if is_liquid(cur) then
				-- core.log("action", "Found surface: "..core.pos_to_string(pos).." "..cur.." over "..prev)
				return pos, cur, p1, p2
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
	if not pos then return nil end
	pos = vector_copy(pos)
	local cur, p1, p2 = get_node_name(pos)
	if cur == "ignore" then
		core.log("warning", "find_under_water_surface with invalid position (outside of emerged area?) at "..core.pos_to_string(pos)..": "..cur)
		return nil
	end
	if is_solid_not_tree(cur) then -- find up
		local prev, pp1, pp2 = cur, p1, p2
		while pos.y < maxy do
			pos.y = pos.y + 1
			local cur, p1, p2 = get_node_name(pos)
			if cur == "ignore" then
				-- core.log("action", "No ground, "..cur.." over "..prev.." at "..core.pos_to_string(pos))
				return nil
			end
			if is_liquid(cur) then
				pos.y = pos.y - 1
				-- core.log("action", "Found surface: "..core.pos_to_string(pos).." "..prev.." under "..cur)
				return pos, prev, pp1, pp2
			end
			prev, pp1, pp2 = cur, p1, p2
		end
		return nil
	else -- find down
		while pos.y > miny do
			pos.y = pos.y - 1
			local prev = cur
			local cur, p1, p2 = get_node_name(pos)
			if cur == "ignore" then
				-- core.log("action", "No ground, "..cur.." below "..prev.." at "..core.pos_to_string(pos))
				return nil
			end
			if is_solid_not_tree(cur) then
				if is_liquid(prev) then
					-- core.log("action", "Found surface: "..core.pos_to_string(pos).." "..cur.." over "..prev)
					return pos, cur, p1, p2
				else
					-- core.log("action", "No ground, "..cur.." below "..prev.." at "..core.pos_to_string(pos))
					return nil
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
-- @return position over surface, surface material (or nil)
function vl_terraforming.find_level(cpos, miny, maxy, size, tolerance, surface, mode)
	local _find_ground = find_ground
	if surface == "liquid_surface" or surface == "liquid" then _find_ground = find_liquid_surface end
	if surface == "under_water" or surface == "water" then _find_ground = find_under_water_surface end
	if surface == "under_air" then _find_ground = find_under_air end
	-- begin at center, then top-left and clockwise
	local pos, surface_material, surface_p1, surface_p2 = _find_ground(cpos, miny, maxy)
	if not pos then
		-- core.log("action", "[vl_terraforming] no ground at starting position "..core.pos_to_string(cpos).." surface "..tostring(surface or "default"))
		return nil
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
	if #ys < 5 then return nil end -- not fully supported

	tolerance = tolerance or 6 -- default value
	if mode == "min" then -- ignore the largest when using min
		if ys[#ys-1]-ys[1] > tolerance then return nil end
		cpos.y = ys[1]
	elseif mode == "max" then -- ignore the smallest when using max
		if ys[#ys]-ys[2] > tolerance then return nil end
		cpos.y = ys[#ys]
	else -- median
		if min(ys[#ys-1]-ys[1], ys[#ys]-ys[2]) > tolerance then
			-- core.log("action", "[vl_terraforming] ground too uneven: "..#ys.." positions: "..({dump(ys):gsub("[\n\t ]+", " ")})[1]
			--                      .." tolerance "..tostring(#ys > 2 and min(ys[#ys-1]-ys[1], ys[#ys]-ys[2])).." > "..tolerance)
			return nil
		end
		cpos.y = floor(0.5 * (ys[floor(1 + (#ys - 1) * 0.5)] + ys[ceil(1 + (#ys - 1) * 0.5)])) -- rounded
	end
	return cpos, surface_material, surface_p1, surface_p2
end

