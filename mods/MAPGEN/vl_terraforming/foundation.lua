local abs = math.abs
local max = math.max
local vector_new = vector.new

local is_solid_not_tree = vl_terraforming._is_solid_not_tree
local make_solid_vm = vl_terraforming._make_solid_vm

--- Grow the foundation downwards
-- @param vm VoxelManip: Lua Voxel Manipulator
-- @param xi number: x coordinate
-- @param yi number: y coordinate
-- @param zi number: z coordinate
-- @param pr PcgRandom: random generator
-- @param surface_mat Node: surface material node
-- @param platform_mat Node: platform material node
-- @param stone_mat Node: stone material node
local function grow_foundation_vm(vm,xi,yi,zi,pr,surface_mat,platform_mat,stone_mat)
	local get_node_at = vm.get_node_at
	local pos, n, c = vector_new(xi,yi,zi), nil, 0
	if is_solid_not_tree(get_node_at(vm, pos)) then return false end -- already solid, nothing to do
	pos.y = pos.y + 1
	local cur = get_node_at(vm, pos)
	if not is_solid_not_tree(cur) then return false end -- above is empty, do not fill below
	if cur and cur.name and cur.name ~= surface_mat.name then platform_mat = cur end
	if pr:next(1,4) == 1 then platform_mat = stone_mat end -- randomly switch to stone sometimes
	-- count solid nodes above otherwise
	for x = xi-1,xi+1 do
		for z = zi-1,zi+1 do
			pos.x, pos.z = x, z
			if is_solid_not_tree(get_node_at(vm, pos)) then c = c + 1 end
		end
	end
	-- stop randomly depending on fill, to narrow down the foundation
	-- TODO: allow controlling the random depth with an additional parameter?
	if (pr:next(0,1e9)/1e9)^2 > c/9.1 then return false end
	pos.x, pos.y, pos.z = xi, yi, zi
	if get_node_at(vm, pos).name == "mcl_core:bedrock" then return false end
	vm:set_node_at(pos, platform_mat)
	return true
end
--- Generate a foundation from px,py,pz with size sx,sy,sz (sy < 0) plus some margin
-- TODO: add support for dust_mat (snow)
--
-- Rounding: we model an ellipse. At zero rounding, we want the line go through the corner, at sx/2, sz/2.
-- For this, we need to make ellipse sized 2a=sqrt(2)*sx, 2b=sqrt(2)*sz,
-- Which yields a = sx/sqrt(2), b=sz/sqrt(2) and a^2=sx^2*0.5, b^2=sz^2*0.5
-- To get corners, we decrease a and b by approx. corners each
-- The ellipse condition dx^2/a^2+dz^2/b^2 <= 1 then yields dx^2/(sx^2*0.5) + dz^2/(sz^2*0.5) <= 1
-- We use wx2=sx^-2*2, wz2=sz^-2*2 and then dx^2*wx2+dz^2*wz2 <= 1
--
-- @param vm VoxelManip: Lua Voxel Manipulator
-- @param px number: lowest x
-- @param py number: lowest y
-- @param pz number: lowest z
-- @param sx number: x width
-- @param sy number: y height
-- @param sz number: z depth
-- @param corners number: Corner rounding
-- @param surface_mat Node: surface material node
-- @param platform_mat Node: platform material node
-- @param stone_mat Node: stone material node
-- @param dust_mat Node: dust material, optional
-- @param pr PcgRandom: random generator
function vl_terraforming.foundation_vm(vm, px, py, pz, sx, sy, sz, corners, surface_mat, platform_mat, stone_mat, dust_mat, pr)
	if sx <= 0 or sy >= 0 or sz <= 0 then return end
	local get_node_at = vm.get_node_at
	local set_node_at = vm.set_node_at
	corners = corners or 0
	local wx2, wz2 = max(sx - corners, 1)^-2 * 2, max(sz - corners, 1)^-2 * 2
	local cx, cz = px + sx * 0.5 - 0.5, pz + sz * 0.5 - 0.5
	-- generate a baseplate (2 layers, lower is wider
	local pos = vector_new(px, py, pz)
	for xi = px-1,px+sx do
		local dx2  = max(abs(cx-xi)+0.51,0)^2*wx2
		local dx21 = max(abs(cx-xi)-0.49,0)^2*wx2
		pos.x = xi
		for zi = pz-1,pz+sz do
			local dz2  = max(abs(cz-zi)+0.51,0)^2*wz2
			local dz21 = max(abs(cz-zi)-0.49,0)^2*wz2
			pos.z = zi
			if xi >= px and xi < px+sx and zi >= pz and zi < pz+sz and dx2+dz2 <= 1 then
				pos.y = py
				if get_node_at(vm, pos).name ~= "mcl_core:bedrock" then
					set_node_at(vm, pos, surface_mat)
					if dust_mat then
						pos.y = py + 1
						if get_node_at(vm, pos).name == "air" then set_node_at(vm, pos, dust_mat) end
					end
					pos.y = py - 1
					make_solid_vm(vm, pos, platform_mat)
				end
			elseif dx21+dz21 <= 1 then -- and pr:next(1,4) < 4 then -- TODO: make randomness configurable.
				-- slightly widen the baseplate below, to make easier to enter for mobs
				pos.y = py - 1
				make_solid_vm(vm, pos, surface_mat)
				if dust_mat then
					pos.y = py
					if get_node_at(vm, pos).name == "air" then set_node_at(vm, pos, dust_mat) end
				end
			end
		end
	end
	-- construct additional baseplate below, also try to make it interesting
	for yi = py-2,py-20,-1 do
		local dy2 = max(0,py-2-yi)^2*0.05
		local active = false
		for xi = px-1,px+sx do
			local dx22 = max(abs(cx-xi)-1.49,0)^2*wx2
			for zi = pz-1,pz+sz do
				local dz22 = max(abs(cz-zi)-1.49,0)^2*wz2
				if dx22+dy2+dz22 <= 1 and grow_foundation_vm(vm,xi,yi,zi,pr,surface_mat,platform_mat,stone_mat) then active = true end
			end
		end
		if not active and yi < py + sy then break end
	end
	-- TODO: add back additional steps for easier entering, optional, and less regular?
end
