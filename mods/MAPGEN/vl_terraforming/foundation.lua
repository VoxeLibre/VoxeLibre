local abs = math.abs
local max = math.max
local vector_new = vector.new
local get_node_name = mcl_vars.get_node_name
local swap_node = core.swap_node

local is_air = vl_terraforming._is_air
local is_solid_not_tree = vl_terraforming._is_solid_not_tree
local immutable = vl_terraforming._immutable
local make_solid = vl_terraforming._make_solid

--- Grow the foundation downwards
-- @param xi number: x coordinate
-- @param yi number: y coordinate
-- @param zi number: z coordinate
-- @param pr PcgRandom: random generator
-- @param surface_mat Node: surface material node
-- @param platform_mat Node: platform material node
-- @param stone_mat Node: stone material node
local function grow_foundation(xi,yi,zi,pr,surface_mat,platform_mat,stone_mat)
	local pos, c = vector_new(xi,yi,zi), 0
	if is_solid_not_tree(get_node_name(pos)) then return false end -- already solid, nothing to do
	pos.y = pos.y + 1
	local cur, p1, p2 = get_node_name(pos)
	if not is_solid_not_tree(cur) then return false end -- above is empty, do not fill below
	if cur and cur ~= surface_mat.name then platform_mat = { name=cur, param1=p1, param2=p2 } end
	if pr:next(1,4) == 1 then platform_mat = stone_mat end -- randomly switch to stone sometimes
	-- count solid nodes above otherwise
	for x = xi-1,xi+1 do
		for z = zi-1,zi+1 do
			pos.x, pos.z = x, z
			if is_solid_not_tree(get_node_name(pos)) then c = c + 1 end
		end
	end
	-- stop randomly depending on fill, to narrow down the foundation
	-- TODO: allow controlling the random depth with an additional parameter?
	if (pr:next(0,1e9)/1e9)^2 > c/9.1 then return false end
	pos.x, pos.y, pos.z = xi, yi, zi
	if immutable(get_node_name(pos)) then return false end
	swap_node(pos, platform_mat)
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
function vl_terraforming.foundation(px, py, pz, sx, sy, sz, corners, surface_mat, platform_mat, stone_mat, dust_mat, pr)
	if sx <= 0 or sy >= 0 or sz <= 0 then return end
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
				if not immutable(get_node_name(pos)) then
					swap_node(pos, surface_mat)
					if dust_mat then
						pos.y = py + 1
						if is_air(get_node_name(pos)) then swap_node(pos, dust_mat) end
					end
					pos.y = py - 1
					make_solid(pos, platform_mat)
				end
			elseif dx21+dz21 <= 1 then -- and pr:next(1,4) < 4 then -- TODO: make randomness configurable.
				-- slightly widen the baseplate below, to make easier to enter for mobs
				pos.y = py - 1
				make_solid(pos, surface_mat)
				if dust_mat then
					pos.y = py
					if is_air(get_node_name(pos)) then swap_node(pos, dust_mat) end
				end
			end
		end
	end
	-- construct additional baseplate below, also try to make it interesting
	for yi = py-2,py-20,-1 do
		local dy2 = max(0,py-2-yi)^2*0.10
		local active = false
		for xi = px-1,px+sx do
			local dx22 = max(abs(cx-xi)-1.49,0)^2*wx2
			for zi = pz-1,pz+sz do
				local dz22 = max(abs(cz-zi)-1.49,0)^2*wz2
				if dx22+dy2+dz22 <= 1 and grow_foundation(xi,yi,zi,pr,surface_mat,platform_mat,stone_mat) then active = true end
			end
		end
		if not active and yi < py + sy then break end
	end
	-- TODO: add back additional steps for easier entering, optional, and less regular?
end
