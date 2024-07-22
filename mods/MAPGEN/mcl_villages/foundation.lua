local foundation_materials = {}
foundation_materials["mcl_core:sand"] = "mcl_core:sandstone"
foundation_materials["mcl_core:redsand"] = "mcl_core:redsandstone"

local function is_air(node)
	return not node or node.name == "air" or node.name == "ignore" or node.name == "mcl_villages:no_paths"
end
local function is_solid(node)
	if not node or node.name == "air" or node.name == "ignore" or node.name == "mcl_villages:no_paths" then return false end
	--if string.find(node.name,"leaf") then return false end
	--if string.find(node.name,"tree") then return false end
	local ndef = minetest.registered_nodes[node.name]
	return ndef and ndef.walkable
end
local function make_solid(lvm, cp, with, except)
	local cur = lvm:get_node_at(cp)
	if not is_solid(cur) or (except and cur.name == except.name) then
		lvm:set_node_at(cp, with)
	end
end
local function excavate(lvm,xi,yi,zi,pr)
	local pos, n, c = vector.new(xi,yi,zi), nil, 0
	local node = lvm:get_node_at(pos)
	if is_air(node) then return false end -- already empty, nothing to do
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
	if not string.find(node.name, "leaf") and not string.find(node.name, "tree") then
		-- stop randomly depending on fill, to narrow down the caves
		if (pr:next(0,1e9)/1e9)^2 > c/9.1 then return false end
	end
	lvm:set_node_at(vector.new(xi, yi, zi),{name="air"})
	return true -- modified
end
local function grow_foundation(lvm,xi,yi,zi,pr,surface_mat,platform_mat)
	local pos, n, c = vector.new(xi,yi,zi), nil, 0
	if is_solid(lvm:get_node_at(pos)) then return false end -- already solid, nothing to do
	pos.y = pos.y+1
	local cur = lvm:get_node_at(pos)
	if not is_solid(cur) then return false end -- above is empty, do not fill below
	if cur and cur.name and cur.name ~= surface_mat.name then platform_mat = cur end
	if pr:next(1,5) == 5 then -- randomly switch to stone sometimes
		platform_mat = { name = "mcl_core:stone" }
	end
	-- count solid nodes above otherwise
	for x = xi-1,xi+1 do
		for z = zi-1,zi+1 do
			pos.x, pos.z = x, z
			if is_solid(lvm:get_node_at(pos)) then c = c + 1 end
		end
	end
	-- stop randomly depending on fill, to narrow down the foundation
	if (pr:next(0,1e9)/1e9)^2 > c/9.1 then return false end
	lvm:set_node_at(vector.new(xi, yi, zi), platform_mat)
	return true -- modified
end
-------------------------------------------------------------------------------
-- function clear space above baseplate
-------------------------------------------------------------------------------
function mcl_villages.terraform(lvm, settlement, pr)
	-- TODO: further optimize by using raw data arrays instead of set_node_at. But OK for a first draft.
	--local lvm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	--local lvm = VoxelManip()

	-- we make the foundations 1 node wider than requested, to have one node for path laying
	for i, building in ipairs(settlement) do
		--lvm:read_from_map(vector.new(pos.x-2, pos.y-20, pos.z-2), vector.new(pos.x+sx+2, pos.y+sy+20, pos.z+sz+2))
		--lvm:get_data()
		if not building.no_clearance then
			local pos, size = building.pos, building.size
			pos = vector.offset(pos, -math.floor(size.x/2)-1, 0, -math.floor(size.z/2)-1)
			mcl_villages.clearance(lvm, pos.x, pos.y, pos.z, size.x+2, size.y, size.z+2, pr)
		end
		--lvm:write_to_map(false)
	end
	for i, building in ipairs(settlement) do
		if not building.no_ground_turnip then
			local pos, size = building.pos, building.size
			local surface_mat = building.surface_mat
			local platform_mat = building.platform_mat or { name = foundation_materials[surface_mat.name] or "mcl_core:dirt" }
			building.platform_mat = platform_mat -- remember for use in schematic placement
			pos = vector.offset(pos, -math.floor(size.x/2)-1, 0, -math.floor(size.z/2)-1)
			mcl_villages.foundation(lvm, pos.x, pos.y, pos.z, size.x+2, -4, size.z+2, surface_mat, platform_mat, pr)
		end
	end
end
local AIR = {name = "air"}
function mcl_villages.clearance(lvm, px, py, pz, sx, sy, sz, pr)
	-- excavate the needed volume, some headroom, and add a baseplate
	for xi = px,px+sx-1 do
		for zi = pz,pz+sz-1 do
			lvm:set_node_at(vector.new(xi, py+1, zi),AIR)
			-- py+2 to py+5 are filled larger below!
			for yi = py+6,py+sy do
				lvm:set_node_at(vector.new(xi, yi, zi),AIR)
			end
		end
	end
	-- slightly widen the cave, to make easier to enter for mobs
	for xi = px-1,px+sx do
		for zi = pz-1,pz+sz do
			for yi = py+2,py+5 do
				lvm:set_node_at(vector.new(xi, yi, zi),AIR)
			end
		end
	end
	-- some extra gaps
	for xi = px-2,px+sx+1 do
		for zi = pz-2,pz+sz+1 do
			if pr:next(1,4) == 1 then
				for yi = py+3,py+5 do
					lvm:set_node_at(vector.new(xi, yi, zi),AIR)
				end
			end
		end
	end
	-- cave some additional area overhead, try to make it interesting though
	for yi = py+3,py+sy*3 do
		local active = false
		for xi = px-2,px+sx+1 do
			for zi = pz-2,pz+sz+1 do
				if excavate(lvm,xi,yi,zi,pr) then active = true end
			end
		end
		if not active and yi > py+sy+5 then break end
	end
end
function mcl_villages.foundation(lvm, px, py, pz, sx, sy, sz, surface_mat, platform_mat, pr)
	-- generate a baseplate
	for xi = px,px+sx-1 do
		for zi = pz,pz+sz-1 do
			lvm:set_node_at(vector.new(xi, py, zi), surface_mat)
			make_solid(lvm, vector.new(xi, py - 1, zi), platform_mat)
		end
	end
	-- slightly widen the baseplate, to make easier to enter for mobs
	for xi = px,px+sx-1 do
		make_solid(lvm, vector.new(xi, py-1, pz-1),    surface_mat, platform_mat)
		make_solid(lvm, vector.new(xi, py-1, pz),      platform_mat)
		make_solid(lvm, vector.new(xi, py-1, pz+sz-1), platform_mat)
		make_solid(lvm, vector.new(xi, py-1, pz+sz),   surface_mat, platform_mat)
	end
	for zi = pz,pz+sz-1 do
		make_solid(lvm, vector.new(px-1,    py-1, zi), surface_mat, platform_mat)
		make_solid(lvm, vector.new(px,      py-1, zi), platform_mat)
		make_solid(lvm, vector.new(px+sx-1, py-1, zi), platform_mat)
		make_solid(lvm, vector.new(px+sx,   py-1, zi), surface_mat, platform_mat)
	end
	-- make some additional steps, along both x sides
	for xi = px,px+sx-1 do
		local cp = vector.new(xi, py-3, pz-1)
		if is_solid(lvm:get_node_at(cp)) then
			cp = vector.new(xi, py-2, pz-1)
			make_solid(lvm, cp, surface_mat, platform_mat)
			cp.z = pz-2
			make_solid(lvm, cp, surface_mat, platform_mat)
		end
		local cp = vector.new(xi, py-3, pz+sz)
		if is_solid(lvm:get_node_at(cp)) then
			cp = vector.new(xi, py-2, pz+sz)
			make_solid(lvm, cp, surface_mat, platform_mat)
			cp.z = pz + sz + 1
			make_solid(lvm, cp, surface_mat, platform_mat)
		end
	end
	-- make some additional steps, along both z sides
	for zi = pz,pz+sz-1 do
		local cp = vector.new(px-1, py-3, zi)
		if is_solid(lvm:get_node_at(cp)) then
			cp = vector.new(px-1, py-2, zi)
			make_solid(lvm, cp, surface_mat, platform_mat)
			cp.x = px-2
			make_solid(lvm, cp, surface_mat, platform_mat)
		end
		local cp = vector.new(px+sx, py-3, zi)
		if is_solid(lvm:get_node_at(cp)) then
			cp = vector.new(px+sx, py-2, zi)
			make_solid(lvm, cp, surface_mat, platform_mat)
			cp.x = px+sx+1
			make_solid(lvm, cp, surface_mat, platform_mat)
		end
	end
	-- construct additional baseplate below, also try to make it interesting
	for yi = py-2,py-20,-1 do
		local active = false
		for xi = px-1,px+sx do
			for zi = pz-1,pz+sz do
				if grow_foundation(lvm,xi,yi,zi,pr,surface_mat,platform_mat) then active = true end
			end
		end
		if not active and yi < py + sy then break end
	end
end
