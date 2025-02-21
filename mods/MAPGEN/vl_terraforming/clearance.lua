local AIR = vl_terraforming._AIR
local abs = math.abs
local max = math.max
local floor = math.floor
local vector_new = vector.new
local get_node_name = mcl_vars.get_node_name
local swap_node = core.swap_node

local is_air = vl_terraforming._is_air
local immutable = vl_terraforming._immutable
local is_solid_not_tree = vl_terraforming._is_solid_not_tree
local is_tree_not_leaves = vl_terraforming._is_tree_not_leaves
local is_tree_or_leaves = vl_terraforming._is_tree_or_leaves

--- Clear an area for a structure
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
-- @param corners number: corner rounding
-- @param surface_mat Node: surface node material
-- @param dust_mat Node: surface dust material
-- @param pr PcgRandom: random generator
function vl_terraforming.clearance(px, py, pz, sx, sy, sz, corners, surface_mat, dust_mat, pr)
	if sx <= 0 or sy <= 0 or sz <= 0 then return end
	corners = corners or 0
	local wx2, wz2 = max(sx - corners, 1)^-2 * 2, max(sz - corners, 1)^-2 * 2
	local cx, cz = px + sx * 0.5 - 0.5, pz + sz * 0.5 - 0.5
	local min_clear, max_clear = py+sy, py+floor(sy*1.5+2) -- todo: make more parameterizable, but adds another parameter
	-- excavate the needed volume and some headroom
	local vec = vector_new(0, 0, 0) -- single vector, to avoid allocations -- performance!
	for xi = px-1,px+sx do
		local dx = abs(cx-xi)
		local dx2 =  max(dx+0.51,0)^2*wx2
		local dx21 = max(dx-0.49,0)^2*wx2
		vec.x = xi
		for zi = pz-1,pz+sz do
			local dz = abs(cz-zi)
			local dz2 =  max(dz+0.51,0)^2*wz2
			local dz21 = max(dz-0.49,0)^2*wz2
			vec.z = zi
			if xi >= px and xi < px+sx and zi >= pz and zi < pz+sz and dx2+dz2 <= 1 then
				vec.y = py
				if not immutable(get_node_name(vec)) then swap_node(vec, AIR) end
				vec.y = py - 1
				local n = get_node_name(vec)
				if n and n ~= surface_mat.name and is_solid_not_tree(n) then
					swap_node(vec, surface_mat)
				end
				for yi = py+1,min_clear do -- full height for inner area
					vec.y = yi
					if not immutable(get_node_name(vec)) then swap_node(vec, AIR) end
				end
			elseif dx21+dz21 <= 1 then
				-- widen the cave above by 1, to make easier to enter for mobs
				-- todo: make configurable?
				vec.y = py + 1
				if not immutable(get_node_name(vec)) then
					local mat = AIR
					if dust_mat then
						vec.y = py
						if get_node_name(vec) == surface_mat.name then mat = dust_mat end
						vec.y = py + 1
					end
					swap_node(vec, mat)
				end
				for yi = py+2,min_clear-1 do
					vec.y = yi
					local n = get_node_name(vec)
					if not immutable(n) and not (allow_water and is_water(n)) then swap_node(vec, AIR) end
					if yi > py+4 then
						local p = (yi-py) / (max_clear-py)
						--core.log(tostring(p).."^2 "..tostring(p*p).." rand: "..pr:next(0,1e9)/1e9)
						if (pr:next(0,1e9)/1e9) < p then break end
					end
				end
				-- remove some tree parts and fix surfaces down
				for yi = py,py-1,-1 do
					vec.y = yi
					local n = get_node_name(vec)
					if is_tree_not_leaves(n) then
						swap_node(vec, surface_mat)
						if dust_mat and yi == py then
							vec.y = yi + 1
							if is_air(get_node_name(vec)) then swap_node(vec, dust_mat) end
						end
					else
						if n and n ~= surface_mat.name and is_solid_not_tree(n) then
							swap_node(vec, surface_mat)
							if dust_mat then
								vec.y = yi + 1
								if is_air(get_node_name(vec)) then swap_node(vec, dust_mat) end
							end
						end
						break
					end
				end
			end
		end
	end
	-- some extra gaps for entry
	-- todo: make optional instead of hard-coded 25%
	-- todo: only really useful if there is space at px-3,py+3 to px-3,py+5
	--[[
	for xi = px-2,px+sx+1 do
		local dx21 = max(abs(cx-xi)-0.49,0)^2*wx2
		local dx22 = max(abs(cx-xi)-1.49,0)^2*wx2
		for zi = pz-2,pz+sz+1 do
			local dz21 = max(abs(cz-zi)-0.49,0)^2*wz2
			local dz22 = max(abs(cz-zi)-1.49,0)^2*wz2
			if dx21+dz21 > 1 and dx22+dz22 <= 1 and pr:next(1,4) == 1 then
				if py+4 < sy then
					for yi = py+2,py+4 do
						vec = vector_new(xi, yi, zi)
						if not immutable(get_node_name(vec)) then swap_node(vec, v) end
					end
				end
				for yi = py+1,py-1,-1 do
					local n = get_node_name(vector_new(xi, yi, zi))
					if is_tree_not_leaves(n) and not immutable(n) then
						swap_node(vector_new(xi, yi, zi), AIR)
					else
						if n and n ~= surface_mat.name and is_solid_not_tree(n) then
							swap_node(vector_new(xi, yi, zi), surface_mat)
						end
						break
					end
				end
			end
		end
	end
	]]--
	-- cave some additional area overhead, try to make it interesting though
	for yi = min_clear+1,max_clear do
		local dy2 = max(yi-min_clear-1,0)^2*0.05
		local active = false
		for xi = px-2,px+sx+1 do
			local dx22 = max(abs(cx-xi)-1.49,0)^2*wx2
			for zi = pz-2,pz+sz+1 do
				local dz22 = max(abs(cz-zi)-1.49,0)^2*wz2
				local keep_trees = (xi<px or xi>=px+sx) or (zi<pz or zi>=pz+sz) -- TODO make parameter?
				if dx22+dy2+dz22 <= 1 then
					vec.x, vec.y, vec.z = xi, yi, zi
					local nod = get_node_name(vec)
					-- don't break bedrock or air
					if not is_air(nod) and not immutable(nod) then
						local is_tree = is_tree_or_leaves(nod)
						if not keep_trees or not is_tree then
							vec.y = yi-1
							-- do not clear above solid
							local nod_below = get_node_name(vec)
							if is_air(nod_below) or immutable(nod_below) then
								-- try to completely remove trees overhead
								-- stop randomly depending on fill, to narrow down the caves
								if keep_trees or is_tree or (pr:next(0,1e9)/1e9)^0.5 < 1-(dx22+dy2+dz22-0.1) then
									vec.x, vec.y, vec.z = xi, yi, zi
									swap_node(vec, AIR)
									active = true
								end
							end
						end
					end
				end
			end
		end
		if not active then break end
	end
end
