local AIR = {name = "air"}
local abs = math.abs
local max = math.max

-- fairly strict: air, ignore, or no_paths marker
local function is_air(node)
	return not node or node.name == "air" or node.name == "ignore" or node.name == "mcl_villages:no_paths"
end
-- check if a node is walkable (solid), but not tree/leaves
local function is_solid_not_tree(node)
	if not node or node.name == "air" or node.name == "ignore" or node.name == "mcl_villages:no_paths" then return false end
	local meta = minetest.registered_items[node.name]
	local groups = meta and meta.groups
	return meta and meta.walkable and not (groups and (groups["deco_block"] or groups["tree"] or groups["leaves"] or groups["plant"]))
end
-- check if a node is walkable (solid), but not tree/leaves or buildungs
local function is_solid_not_tree_or_building(node)
	if not node or node.name == "air" or node.name == "ignore" or node.name == "mcl_villages:no_paths" then return false end
	local meta = minetest.registered_items[node.name]
	local groups = meta and meta.groups
	return meta and meta.walkable and not (groups and (groups["deco_block"] or groups["tree"] or groups["leaves"] or groups["plant"] or groups["building_block"]))
end
-- check if a node is tree
local function is_tree(node)
	if not node or node.name == "air" or node.name == "ignore" or node.name == "mcl_villages:no_paths" then return false end
	local meta = minetest.registered_items[node.name]
	local groups = meta and meta.groups
	return groups and (groups["tree"] or groups["leaves"])
end
-- replace a non-solid node, optionally also "additional"
local function make_solid(lvm, cp, with, additional)
	local cur = lvm:get_node_at(cp)
	if not is_solid_not_tree(cur) or (additional and cur.name == additional.name) then
		lvm:set_node_at(cp, with)
	end
end
local function excavate(lvm,xi,yi,zi,pr,keep_trees)
	local pos, n, c = vector.new(xi,yi,zi), nil, 0
	local node = lvm:get_node_at(pos)
	if is_air(node) then return false end -- already empty, nothing to do
	if keep_trees and is_tree(node) then return false end
	pos.y = pos.y-1
	if not is_air(lvm:get_node_at(pos)) then return false end -- below is solid, do not clear above anymore
	-- count empty nodes below otherwise
	for x = xi-1,xi+1 do
		for z = zi-1,zi+1 do
			pos.x, pos.z = x, z
			if is_air(lvm:get_node_at(pos)) then c = c + 1 end
		end
	end
	-- try to completely remove trees overhead
	-- stop randomly depending on fill, to narrow down the caves
	if not keep_trees and not is_tree(node) and (pr:next(0,1e9)/1e9)^2 > c/9.1 then return false end
	lvm:set_node_at(vector.new(xi, yi, zi), AIR)
	return true -- modified
end
function mcl_structures.clearance(lvm, px, py, pz, sx, sy, sz, corners, surface_mat, pr)
	corners = corners or 0
	local wx2, wz2 = max(sx - corners, 1)^-2*2, max(sz - corners, 1)^-2*2
	local cx, cz = px + sx * 0.5 - 0.5, pz + sz * 0.5 - 0.5
	-- excavate the needed volume and some headroom
	for xi = px,px+sx-1 do
		local dx2 = (cx-xi)^2*wx2
		for zi = pz,pz+sz-1 do
			local dz2 = (cz-zi)^2*wz2
			if dx2+dz2 <= 1 then
				lvm:set_node_at(vector.new(xi, py, zi), AIR)
				local n = lvm:get_node_at(vector.new(xi, py-1, zi))
				if n and n.name ~= surface_mat.name and is_solid_not_tree_or_building(n) then
					lvm:set_node_at(vector.new(xi, py-1, zi), surface_mat)
				end
				-- py+1 to py+4 are filled wider below, this is the top of the building only
				for yi = py+5,py+sy do
					lvm:set_node_at(vector.new(xi, yi, zi), AIR)
				end
			end
		end
	end
	-- slightly widen the cave above, to make easier to enter for mobs
	for xi = px-1,px+sx do
		local dx2 = max(abs(cx-xi)-1,0)^2*wx2
		for zi = pz-1,pz+sz do
			local dz2 = max(abs(cz-zi)-1,0)^2*wz2
			if dx2+dz2 <= 1 then
				for yi = py+1,py+4 do
					lvm:set_node_at(vector.new(xi, yi, zi), AIR)
				end
				local n = lvm:get_node_at(vector.new(xi, py, zi))
				for yi = py,py-1,-1 do
					local n = lvm:get_node_at(vector.new(xi, yi, zi))
					if is_tree(n) then
						lvm:set_node_at(vector.new(xi, yi, zi), AIR)
					else
						if n and n.name ~= surface_mat.name and is_solid_not_tree_or_building(n) then
							lvm:set_node_at(vector.new(xi, yi, zi), surface_mat)
						end
						break
					end
				end
			end
		end
	end
	-- some extra gaps for entry
	for xi = px-2,px+sx+1 do
		local dx2 = max(abs(cx-xi)-2,0)^2*wx2
		for zi = pz-2,pz+sz+1 do
			local dz2 = max(abs(cz-zi)-2,0)^2*wz2
			if dx2+dz2 <= 1 and pr:next(1,4) == 1 then
				for yi = py+2,py+4 do
					lvm:set_node_at(vector.new(xi, yi, zi), AIR)
				end
				local n = lvm:get_node_at(vector.new(xi, py+1, zi))
				for yi = py+1,py-1,-1 do
					local n = lvm:get_node_at(vector.new(xi, yi, zi))
					if is_tree(n) then
						lvm:set_node_at(vector.new(xi, yi, zi), AIR)
					else
						if n and n.name ~= surface_mat.name and is_solid_not_tree_or_building(n) then
							lvm:set_node_at(vector.new(xi, py+1, zi), surface_mat)
						end
						break
					end
				end
			end
		end
	end
	-- cave some additional area overhead, try to make it interesting though
	local min_clear, max_clear = sy+5, sy*2+5 -- FIXME: make parameters
	for yi = py+2,py+max_clear do
		local dy2 = (py-yi)^2*0.025
		local active = false
		for xi = px-2,px+sx+1 do
			local dx2 = max(abs(cx-xi)-2,0)^2*wx2
			for zi = pz-2,pz+sz+1 do
				local dz2 = max(abs(cz-zi)-2,0)^2*wz2
				local keep_trees = (xi<px or xi>=px+sx) or (zi<pz or zi>=pz+sz) -- TODO make configurable?
				if dx2+dz2+dy2 <= 1 and excavate(lvm,xi,yi,zi,pr,keep_trees) then active = true end
			end
		end
		if not active and yi > py+min_clear then break end
	end
end
-- TODO: allow controlling the random depth?
-- TODO: add support for dust_mat (snow)
local function grow_foundation(lvm,xi,yi,zi,pr,surface_mat,platform_mat,stone_mat)
	local pos, n, c = vector.new(xi,yi,zi), nil, 0
	if is_solid_not_tree(lvm:get_node_at(pos)) then return false end -- already solid, nothing to do
	pos.y = pos.y+1
	local cur = lvm:get_node_at(pos)
	if not is_solid_not_tree(cur) then return false end -- above is empty, do not fill below
	if cur and cur.name and cur.name ~= surface_mat.name then platform_mat = cur end
	if pr:next(1,5) == 5 then -- randomly switch to stone sometimes
		platform_mat = stone_mat
	end
	-- count solid nodes above otherwise
	for x = xi-1,xi+1 do
		for z = zi-1,zi+1 do
			pos.x, pos.z = x, z
			if is_solid_not_tree(lvm:get_node_at(pos)) then c = c + 1 end
		end
	end
	-- stop randomly depending on fill, to narrow down the foundation
	if (pr:next(0,1e9)/1e9)^2 > c/9.1 then return false end
	lvm:set_node_at(vector.new(xi, yi, zi), platform_mat)
	return true -- modified
end
-- generate a foundations around px,py,pz with size sx,sy,sz (sy < 0)
-- TODO: add support for dust_mat (snow)
-- Rounding: we model an ellipse. At zero rounding, we want the line go through the corner, at sx/2, sz/2.
-- For this, we need to make ellipse sized 2a=sqrt(2)*sx, 2b=sqrt(2)*sz,
-- Which yields a = sx/sqrt(2), b=sz/sqrt(2) and a^2=sx^2*0.5, b^2=sz^2*0.5
-- To get corners, we decrease a and b by approx. corners each
-- The ellipse condition dx^2/a^2+dz^2/b^2 <= 1 then yields dx^2/(sx^2*0.5) + dz^2/(sz^2*0.5) <= 1
-- We use wx2=(sx^2)^-2*2, wz2=(sz^2)^-2*2 and then dx^2*wx2+dz^2*wz2 <= 1
function mcl_structures.foundation(lvm, px, py, pz, sx, depth, sz, corners, surface_mat, platform_mat, stone_mat, pr)
	corners = corners or 0
	local wx2, wz2 = max(sx - corners, 1)^-2*2, max(sz - corners, 1)^-2*2
	local cx, cz = px + sx * 0.5 - 0.5, pz + sz * 0.5 - 0.5
	-- generate a baseplate
	for xi = px,px+sx-1 do
		local dx2 = (cx-xi)^2*wx2
		for zi = pz,pz+sz-1 do
			local dz2 = (cz-zi)^2*wz2
			if dx2+dz2 <= 1 then
				lvm:set_node_at(vector.new(xi, py, zi), surface_mat)
				make_solid(lvm, vector.new(xi, py-1, zi), platform_mat)
			end
		end
	end
	-- slightly widen the baseplate below, to make easier to enter for mobs
	if corners and corners > 0 then
		for xi = px-1,px+sx do
			local dx2 = max(abs(cx-xi)-1,0)^2*wx2
			-- TODO: compute the z value ranges directly?
			for zi = pz-1,pz+sz do
				local dz2 = max(abs(cz-zi)-1,0)^2*wz2
				if dx2+dz2 <= 1 then
					make_solid(lvm, vector.new(xi, py-1, zi), surface_mat)
				end
			end
		end
	else
		for xi = px+1,px+sx-1-1 do
			make_solid(lvm, vector.new(xi, py-1, pz-1),    surface_mat, platform_mat)
			make_solid(lvm, vector.new(xi, py-1, pz),      platform_mat)
			make_solid(lvm, vector.new(xi, py-1, pz+sz-1), platform_mat)
			make_solid(lvm, vector.new(xi, py-1, pz+sz),   surface_mat, platform_mat)
		end
		for zi = pz+1,pz+sz-1-1 do
			make_solid(lvm, vector.new(px-1,    py-1, zi), surface_mat, platform_mat)
			make_solid(lvm, vector.new(px,      py-1, zi), platform_mat)
			make_solid(lvm, vector.new(px+sx-1, py-1, zi), platform_mat)
			make_solid(lvm, vector.new(px+sx,   py-1, zi), surface_mat, platform_mat)
		end
		-- make some additional steps, along both x sides
		for xi = px+1,px+sx-2 do
			local cp = vector.new(xi, py-3, pz-1)
			if is_solid_not_tree(lvm:get_node_at(cp)) then
				cp = vector.new(xi, py-2, pz-1)
				make_solid(lvm, cp, surface_mat, platform_mat)
				cp.z = pz-2
				make_solid(lvm, cp, surface_mat, platform_mat)
			end
			local cp = vector.new(xi, py-3, pz+sz)
			if is_solid_not_tree(lvm:get_node_at(cp)) then
				cp = vector.new(xi, py-2, pz+sz)
				make_solid(lvm, cp, surface_mat, platform_mat)
				cp.z = pz + sz + 1
				make_solid(lvm, cp, surface_mat, platform_mat)
			end
		end
		-- make some additional steps, along both z sides
		for zi = pz+1,pz+sz-2 do
			local cp = vector.new(px-1, py-3, zi)
			if is_solid_not_tree(lvm:get_node_at(cp)) then
				cp = vector.new(px-1, py-2, zi)
				make_solid(lvm, cp, surface_mat, platform_mat)
				cp.x = px-2
				make_solid(lvm, cp, surface_mat, platform_mat)
			end
			local cp = vector.new(px+sx, py-3, zi)
			if is_solid_not_tree(lvm:get_node_at(cp)) then
				cp = vector.new(px+sx, py-2, zi)
				make_solid(lvm, cp, surface_mat, platform_mat)
				cp.x = px+sx+1
				make_solid(lvm, cp, surface_mat, platform_mat)
			end
		end
	end
	-- construct additional baseplate below, also try to make it interesting
	for yi = py-2,py-20,-1 do
		local dy2 = (py-yi)^2*0.025
		local active = false
		for xi = px-1,px+sx do
			local dx2 = max(abs(cx-xi)-1,0)^2*wx2
			for zi = pz-1,pz+sz do
				local dz2 = max(abs(cz-zi)-1,0)^2*wz2
				if dx2+dy2+dz2 <= 1 then
					if grow_foundation(lvm,xi,yi,zi,pr,surface_mat,platform_mat,stone_mat) then active = true end
				end
			end
		end
		if not active and yi < py + depth then break end
	end
end
-- return position and material of surface
function mcl_structures.find_ground(lvm, pos)
	if not pos then return nil, nil end
	pos = vector.copy(pos)
	local cur = lvm:get_node_at(pos)
	if not cur or cur.name == "ignore" then
		local e1, e2 = lvm:get_emerged_area()
		minetest.log("warning","find_ground with invalid position (outside of emerged area?) at "..minetest.pos_to_string(pos)..": "..tostring(cur and cur.name).." area: "..minetest.pos_to_string(e1).." "..minetest.pos_to_string(e2))
		return nil
	end
	if is_solid_not_tree(cur) then -- find up
		local prev = cur
		while true do
			pos.y = pos.y + 1
			local cur = lvm:get_node_at(pos)
			if not cur or cur.name == "ignore" then
				minetest.log("action", "No ground, "..tostring(cur and cur.name).." over "..tostring(prev and prev.name).." at "..minetest.pos_to_string(pos))
				return nil
			end
			if not is_solid_not_tree(cur) then
				pos.y = pos.y - 1
				return pos, prev
			end
			prev = cur
		end
	else -- find down
		while true do
			pos.y = pos.y - 1
			local prev = cur
			local cur = lvm:get_node_at(pos)
			if not cur or cur.name == "ignore" then
				minetest.log("action", "No ground, "..tostring(cur and cur.name).." below "..tostring(prev and prev.name).." at "..minetest.pos_to_string(pos))
				return nil
			end
			if is_solid_not_tree(cur) then
				return pos, cur
			end
		end
	end
end
-- find suitable height for a structure of this size
-- @param lvm VoxelManip: to read data
-- @param cpos vector: center
-- @param size vector: area size
-- @param tolerance number: maximum height difference allowed, default 8
-- @return position, surface material
function mcl_structures.find_level(lvm, cpos, size, tolerance)
	local cpos, surface_material = mcl_structures.find_ground(lvm, cpos)
	if not cpos then return nil, nil end
	local ys = {cpos.y}
	local pos = vector.offset(cpos, -math.floor((size.x-1)/2), 0, -math.floor((size.z-1)/2)) -- top left
	local pos_c = mcl_structures.find_ground(lvm, pos)
	if pos_c then table.insert(ys, pos_c.y) end
	local pos_c = mcl_structures.find_ground(lvm, vector.offset(pos, size.x-1, 0, 0))
	if pos_c then table.insert(ys, pos_c.y) end
	local pos_c = mcl_structures.find_ground(lvm, vector.offset(pos, 0,        0, size.z-1))
	if pos_c then table.insert(ys, pos_c.y) end
	local pos_c = mcl_structures.find_ground(lvm, vector.offset(pos, size.x-1, 0, size.z-1))
	if pos_c then table.insert(ys, pos_c.y) end
	table.sort(ys)
	-- well supported base, not too uneven?
	if #ys <= 4 or math.max(ys[#ys-1]-ys[1], ys[#ys]-ys[2]) > (tolerance or 8) then
		minetest.log("action", "[mcl_structures] ground too uneven: "..#ys.." positions, trimmed difference "..(#ys < 2 and "" or math.max(ys[#ys-1]-ys[1], ys[#ys]-ys[2])))
		return nil, nil
	end
	cpos.y = math.round(0.5*(ys[math.floor(#ys * 0.5)] + ys[math.ceil(#ys * 0.5)])) + 1 -- median, rounded, over surface
	return cpos, surface_material
end

