local foundation_materials = {}
foundation_materials["mcl_core:sand"] = "mcl_core:sandstone"
--"mcl_core:sandstonecarved"

local function is_air(node)
	return not node or node.name == "air" or node.name == "ignore"
end
local function is_solid(node)
	if not node or node.name == "air" or node.name == "ignore" then return false end
	--if string.find(node.name,"leaf") then return false end
	--if string.find(node.name,"tree") then return false end
	local ndef = minetest.registered_nodes[node.name]
	return ndef and ndef.walkable
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
		if pr:next(0,905) > c * 100 then return false end
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
	if cur and cur.name and cur.name ~= surface_mat then platform_mat = cur.name end
	if pr:next(1,5) == 5 then -- randomly switch to stone sometimes
		platform_mat = "mcl_core:stone"
	end
	-- count solid nodes above otherwise
	for x = xi-1,xi+1 do
		for z = zi-1,zi+1 do
			pos.x, pos.z = x, z
			if is_solid(lvm:get_node_at(pos)) then c = c + 1 end
		end
	end
	-- stop randomly depending on fill, to narrow down the foundation
	if pr:next(0,905) > c * 100 then return false end
	lvm:set_node_at(vector.new(xi, yi, zi),{name=platform_mat})
	return true -- modified
end
-------------------------------------------------------------------------------
-- function clear space above baseplate
-------------------------------------------------------------------------------
function mcl_villages.terraform(settlement_info, pr)
	local fheight, fwidth, fdepth, schematic_data
	--local lvm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local lvm = VoxelManip()

	for i, built_house in ipairs(settlement_info) do
		-- pick right schematic_info to current built_house
		for j, schem in ipairs(mcl_villages.schematic_table) do
			if settlement_info[i]["name"] == schem["name"] then
				schematic_data = schem
			        break
			end
		end
		local pos = settlement_info[i]["pos"]
		if settlement_info[i]["rotat"] == "0" or settlement_info[i]["rotat"] == "180" then
			fwidth, fdepth = schematic_data["hwidth"], schematic_data["hdepth"]
		else
			fwidth, fdepth = schematic_data["hdepth"], schematic_data["hwidth"]
		end
		fheight = schematic_data["hheight"]  -- remove trees and leaves above

		-- use biome-specific materials
		local surface_mat = settlement_info[i]["surface_mat"]
		mcl_villages.debug("Surface material: " .. tostring(surface_mat))
		local platform_mat = foundation_materials[surface_mat] or "mcl_core:dirt"
		mcl_villages.debug("Foundation material: " .. tostring(platform_mat))

		lvm:read_from_map(vector.new(pos.x-2, pos.y-20, pos.z-2), vector.new(pos.x+fwidth+2, pos.y+fheight+20, pos.z+fdepth+2))
		-- TODO: further optimize by using raw data arrays instead of set_node_at. But OK for a first draft.
		lvm:get_data()
		-- excavate the needed volume, some headroom, and add a baseplate
		local p2 = vector.new(pos)
		for xi = pos.x,pos.x+fwidth-1 do
			for zi = pos.z,pos.z+fdepth-1 do
				lvm:set_node_at(vector.new(xi, pos.y+1, zi),{name="air"})
				-- pos.y+2 to pos.y+5 are filled larger below!
				for yi = pos.y+6,pos.y+fheight do
					lvm:set_node_at(vector.new(xi, yi, zi),{name="air"})
				end
				local cp = vector.new(xi, pos.y, zi)
				local cur = lvm:get_node_at(cp)
				if not is_solid(cur) or cur.name == platform_mat then
					lvm:set_node_at(cp, {name=surface_mat})
				end
				local cp = vector.new(xi, pos.y - 1, zi)
				local cur = lvm:get_node_at(cp)
				if not is_solid(cur) then
					lvm:set_node_at(cp, {name=platform_mat})
				end
			end
		end
		-- slightly widen the cave, to make easier to enter for mobs
		for xi = pos.x-1,pos.x+fwidth do
			for zi = pos.z-1,pos.z+fdepth do
				for yi = pos.y+2,pos.y+5 do
					lvm:set_node_at(vector.new(xi, yi, zi),{name="air"})
				end
			end
		end
		-- some extra gaps
		for xi = pos.x-2,pos.x+fwidth+1 do
			for zi = pos.z-2,pos.z+fdepth+1 do
				if pr:next(1,4) == 1 then
					for yi = pos.y+3,pos.y+5 do
						lvm:set_node_at(vector.new(xi, yi, zi),{name="air"})
					end
				end
			end
		end
		-- slightly widen the baseplate, to make easier to enter for mobs
		for xi = pos.x,pos.x+fwidth-1 do
			local cp = vector.new(xi, pos.y-1, pos.z)
			local cur = lvm:get_node_at(cp)
			if not is_solid(cur) then
				lvm:set_node_at(cp, {name=platform_mat})
			end
			local cp = vector.new(xi, pos.y-1, pos.z-1)
			local cur = lvm:get_node_at(cp)
			if not is_solid(cur) or cur.name == platform_mat then
				lvm:set_node_at(cp, {name=surface_mat})
			end
			local cp = vector.new(xi, pos.y-1, pos.z+fdepth-1)
			local cur = lvm:get_node_at(cp)
			if not is_solid(cur) then
				lvm:set_node_at(cp, {name=platform_mat})
			end
			local cp = vector.new(xi, pos.y-1, pos.z+fdepth)
			local cur = lvm:get_node_at(cp)
			if not is_solid(cur) or cur.name == platform_mat then
				lvm:set_node_at(cp, {name=surface_mat})
			end
		end
		for zi = pos.z,pos.z+fdepth-1 do
			local cp = vector.new(pos.x, pos.y-1, zi)
			local cur = lvm:get_node_at(cp)
			if not is_solid(cur) then
				lvm:set_node_at(cp, {name=platform_mat})
			end
			local cp = vector.new(pos.x-1, pos.y-1, zi)
			local cur = lvm:get_node_at(cp)
			if not is_solid(cur) or cur.name == platform_mat then
				lvm:set_node_at(cp, {name=surface_mat})
			end
			local cp = vector.new(pos.x+fwidth-1, pos.y-1, zi)
			local cur = lvm:get_node_at(cp)
			if not is_solid(cur) then
				lvm:set_node_at(cp, {name=platform_mat})
			end
			local cp = vector.new(pos.x+fwidth, pos.y-1, zi)
			local cur = lvm:get_node_at(cp)
			if not is_solid(cur) or cur.name == platform_mat then
				lvm:set_node_at(cp, {name=surface_mat})
			end
		end
		-- make some additional steps, along both x sides
		for xi = pos.x,pos.x+fwidth-1 do
			local cp = vector.new(xi, pos.y-3, pos.z-1)
			if is_solid(lvm:get_node_at(cp)) then
				cp = vector.new(xi, pos.y-2, pos.z-1)
				local cur = lvm:get_node_at(cp)
				if not is_solid(cur) or cur.name == platform_mat then
					lvm:set_node_at(cp, {name=surface_mat})
				end
				cp.z = pos.z-2
				cur = lvm:get_node_at(cp)
				if not is_solid(cur) or cur.name == platform_mat then
					lvm:set_node_at(cp, {name=surface_mat})
				end
			end
			local cp = vector.new(xi, pos.y-3, pos.z+fdepth)
			if is_solid(lvm:get_node_at(cp)) then
				cp = vector.new(xi, pos.y-2, pos.z+fdepth)
				local cur = lvm:get_node_at(cp)
				if not is_solid(cur) or cur.name == platform_mat then
					lvm:set_node_at(cp, {name=surface_mat})
				end
				cp.z = pos.z + fdepth + 1
				cur = lvm:get_node_at(cp)
				if not is_solid(cur) or cur.name == platform_mat then
					lvm:set_node_at(cp, {name=surface_mat})
				end
			end
		end
		-- make some additional steps, along both z sides
		for zi = pos.z,pos.z+fdepth-1 do
			local cp = vector.new(pos.x-1, pos.y-3, zi)
			if is_solid(lvm:get_node_at(cp)) then
				cp = vector.new(pos.x-1, pos.y-2, zi)
				local cur = lvm:get_node_at(cp)
				if not is_solid(cur) or cur.name == platform_mat then
					lvm:set_node_at(cp, {name=surface_mat})
				end
				cp.x = pos.x-2
				cur = lvm:get_node_at(cp)
				if not is_solid(cur) or cur.name == platform_mat then
					lvm:set_node_at(cp, {name=surface_mat})
				end
			end
			local cp = vector.new(pos.x+fwidth, pos.y-3, zi)
			if is_solid(lvm:get_node_at(cp)) then
				cp = vector.new(pos.x+fwidth, pos.y-2, zi)
				local cur = lvm:get_node_at(cp)
				if not is_solid(cur) or cur.name == platform_mat then
					lvm:set_node_at(cp, {name=surface_mat})
				end
				cp.x = pos.x+fwidth+1
				cur = lvm:get_node_at(cp)
				if not is_solid(cur) or cur.name == platform_mat then
					lvm:set_node_at(cp, {name=surface_mat})
				end
			end
		end
		-- cave some additional area overhead, try to make it interesting though
		for yi = pos.y+3,pos.y+fheight*3 do
			local active = false
			for xi = pos.x-2,pos.x+fwidth+1 do
				for zi = pos.z-2,pos.z+fdepth+1 do
					if excavate(lvm,xi,yi,zi,pr) then
						active = true
					end
				end
			end
			if not active and yi > pos.y+fheight+5 then break end
		end
		-- construct additional baseplate below, also try to make it interesting
		for yi = pos.y-2,pos.y-20,-1 do
			local active = false
			for xi = pos.x-1,pos.x+fwidth do
				for zi = pos.z-1,pos.z+fdepth do
					if grow_foundation(lvm,xi,yi,zi,pr,surface_mat,platform_mat) then
						active = true
					end
				end
			end
			if not active and yi < pos.y-5 then break end
		end
		lvm:write_to_map(false)
	end
end
