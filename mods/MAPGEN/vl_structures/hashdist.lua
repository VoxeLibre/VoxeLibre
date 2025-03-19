local structure_boost = tonumber(core.settings:get("vl_structures_boost")) or 1
local logging = core.settings:get_bool("vl_structures_logging", false)

---- Functionality to prevent structures from spawning too close to each other, by kno10.
-- This is based on ideas from Bloom filters and MinHash near-duplicate detection.
-- Each chunk is mapped to a hash code, and only at the smallest hash code within a radius
-- a structure spawn is attempted. If we use a stable hash function, by symmetry,
-- we do not attempt a spawn in any of the neighbors then.
--
-- Initially, we experimented with Manhattan distance, as it is simpler, but to allow for more
-- control we then settled on Euclidean distance, where a non-integer radius allows for
-- additional variants, e.g.
-- ```
-- r=1  1.5    2     2.5      3       3.5
--                            x       xxx
--             x     xxx    xxxxx    xxxxx
--  x   xxx   xxx   xxxxx   xxxxx   xxxxxxx
-- xxx  xxx  xxxxx  xxxxx  xxxxxxx  xxxxxxx
--  x   xxx   xxx   xxxxx   xxxxx   xxxxxxx
--             x     xxx    xxxxx    xxxxx
--                            x       xxx
--  5    9    13     21      29       37
-- ```
--
-- It is not sufficient to do this only in 2d, or we might spawn structures
-- in vertically neighboring chunks (as these happen in separate emerges).
-- Hence, in 2d mode, we additionally have to check the vertical column, which means our approach
-- uses a cylinder. This adds 2*mindist+1 checks, but only on the central x,y.
-- The hash function we currently use, DJB2, was chosen because it is cheap.
--
-- Together with the cylinder rule for 2d and radius, we get the following sizes:
--
-- | Distance |   1.0 |   1.5 |   1.8 |   2.0 |   2.3 |   2.5 |   2.9 |   3.0 |   3.5 |   4.0 |
-- |----------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|
-- |       2D |     5 |     9 |     9 |    65 |    65 |   105 |   105 |   203 |   259 |   441 |
-- |  maxprob |   40% | 22.2% | 22.2% | 3.07% | 3.07% | 1.90% | 1.90% | 0.985%| 0.772%| 0.454%|
-- |     cost |     5 |     9 |     9 |    18 |    18 |    26 |    26 |    36 |    44 |    58 |
-- |----------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|
-- |       3D |     7 |    19 |    27 |    33 |    57 |    81 |    93 |   123 |   179 |   257 |
-- |  maxprob | 28.6% | 10.5% | 7.41% | 6.06% | 3.51% | 2.47% | 2.15% | 1.626%| 1.117%| 0.778%|
-- |     cost |     7 |    19 |    27 |    33 |    57 |    81 |    93 |   123 |   179 |   257 |
--
-- As you can see, the 2d/cyliner approach needs fewer cheap hash computations ("cost"),
-- but the cylinders block a larger theoretical volume than in the 3d approach
-- (it would help to limit cylinder height more).
-- For high distances or high probabilities, the 3d spacing approach is recommended.
--
-- To get more intuitive control of the structure frequency, we would like to be able
-- to control the probability of a spawn attempt, corresponding to the structure frequency
-- in a flat world. By doing multiple attempts within a chunk, we can then try to get closer
-- to this also when there is terrain, but we must not try to hard for the case of a tiny
-- island in the sea: we don't want to cram every structure there.
-- Unfortunately, as we randomly place these balls, we can only try to get close to the true
-- numbers, but we always value simplicity over accuracy, this is just a game.
-- If we have a low spawn rate, our balls will usually be disjoint, and we can simply pretend
-- the structure would cover the entire ball.
-- If we want to choose each chunk with probability p, and each chunk blocks k nodes, and we
-- simply use `k*p`, we may generate too many structures because of overlap.
-- Naively assuming independence, there is a chance of `(k*p)^2` of random overlap.
-- Hence we may want to use `k*p-0.5*k*p*k*p=k*p*(1-0.5*k*p)`, but with some boundary conditions.
--
-- Because we "banned" the neighbors from spawning the structure, we have to transfer this spawn
-- chance to our central node if we want to keep the overall structure density as desired.
-- Hence, in the following, we multiply the threshold with this overlap factor.
--
-- The current implementation uses a fixed sidelen of 80 (the Luanti chunk size), but it would be
-- possible to extend this to other supported sidelens (must be divisors of 80), if you need a
-- similar minimum distance but multiple spawns within chunks.

local max, min, abs, sqrt, floor = math.max, math.min, math.abs, math.sqrt, math.floor
local hash_pos = mcl_util.hash_pos

--- Avoid structures in nearby chunks
-- @param bx number: chunk x
-- @param by number: chunk y
-- @param bz number: chunk z
-- @param mindist number: distance to check
-- @param seed number: Random seed
-- @return Hash code of the position, or nil
local function check_mindist_2d(bx, by, bz, mindist, seed, lim)
	local mh = hash_pos(bx, 0, bz, seed)
	if mh >= lim then return 1e100 end
	local dx = floor(mindist)
	for x = -dx,dx do
		local dz = floor(sqrt(mindist*mindist - x*x))
		for z = -dz,dz do
			if x ~= 0 or z ~= 0 then
				if hash_pos(x + bx, 0, z + bz, seed) <= mh then return 1e100 end -- neighbor chunk wins
			end
		end
	end
	-- now also check vertical, but don't keep the 3d hash
	local th = hash_pos(bx, by, bz, seed)
	for y = by-mindist,by+mindist do
		if y ~= by then
			if hash_pos(bx, y, bz, seed) <= th then return 1e100 end
		end
	end
	return mh -- no collision, return hash code
end

--- Avoid structures in nearby chunks
-- @param bx number: chunk x
-- @param by number: chunk y
-- @param bz number: chunk z
-- @param mindist number: distance to check
-- @param seed number: Random seed
-- @return Hash code of the position
local function check_mindist(bx, by, bz, mindist, seed, lim)
	local mh = hash_pos(bx, by, bz, seed)
	if mh >= lim then return 1e100 end
	local dx = floor(mindist)
	for x = -dx,dx do
		local dy = floor(sqrt(mindist*mindist - x*x))
		for y = -dy,dy do
			local dz = floor(sqrt(mindist*mindist - x*x - y*y))
			for z = -dz,dz do
				if x ~= 0 or y ~= 0 or z ~= 0 then
					if hash_pos(bx+x, by+y, bz+z, seed) <= mh then return 1e100 end -- neighbor chunk wins
				end
			end
		end
	end
	return mh -- no collision, return hash code
end

local _cache_size_2d, _cache_size_3d = {}, {}
--- Number of nodes with integer coordinates in radius r
-- @param r number: radius
-- @return number: number of integer nodes in radius
local function in_radius_2d(r)
	if _cache_size_2d[r] then return _cache_size_2d[r] end
	local n = 0
	assert(r > 0)
	for x = -floor(r), floor(r) do
		n = n + (floor(sqrt(r*r-x*x)) or 0)*2 + 1
	end
	_cache_size_2d[r] = n
	return n
end
-- these are pretty much all the parameters that are interesting to use:
assert(in_radius_2d(1)   == 5)
assert(in_radius_2d(1.5) == 9)
assert(in_radius_2d(2)   == 13)
assert(in_radius_2d(2.5) == 21)
assert(in_radius_2d(2.9) == 25)
assert(in_radius_2d(3)   == 29)
assert(in_radius_2d(3.5) == 37)
assert(in_radius_2d(4)   == 49)

--- Number of nodes with integer coordinates in radius r
-- @param r number: radius
-- @return number: number of integer nodes in radius
local function in_radius_3d(r)
	if _cache_size_3d[r] then return _cache_size_3d[r] end
	local n = 0
	assert(r > 0)
	for x = -floor(r), floor(r) do
		local r2 = floor(sqrt(r*r-x*x)) or 0
		for y = -r2, r2 do
			n = n + floor(sqrt(r*r-x*x-y*y))*2 + 1
		end
	end
	_cache_size_3d[r] = n
	return n
end
-- These are a number of parameters that may be interesting to use
assert(in_radius_3d(1)   == 7)
assert(in_radius_3d(1.5) == 19)
assert(in_radius_3d(1.8) == 27)
assert(in_radius_3d(2)   == 33)
assert(in_radius_3d(2.3) == 57)
assert(in_radius_3d(2.5) == 81)
assert(in_radius_3d(2.9) == 93)
assert(in_radius_3d(3)   == 123)
assert(in_radius_3d(3.5) == 179)
assert(in_radius_3d(4)   == 257)

--- Compute the spawn attempt threshold for a particular structure
-- The key idea is chunk_probability * cover_area * structure_boost
-- We then "boost" this by the number of neighbors, as discussed above.
-- This may be larger than 1, this is fine -- it means we cannot achieve the
-- desired chunk probability while keeping the minimum distances.
--
-- @param def table: structure definition
-- @return th number: spawning threshold
local function spawn_threshold(def)
	if not def.chunk_probability then return nil end
	local p = def.chunk_probability / 100 * structure_boost
	if (def.hash_mindist_2d or 0) > 0 then
		local k = in_radius_2d(def.hash_mindist_2d)
		if p * k >= 2 then
			if logging and structure_boost == 1 then
				core.log("warning", "Structure "..def.name.." spawning is limited by distance, not by chunk_probability: "..p.." * "..k)
			end
			return 1
		end
		local p2 = p + p * (k-1) * max(0, 1 - 0.5 * k * p)
		local k2 = 2*def.hash_mindist_2d+1
		if p2 * k2 >= 2 then
			if logging and structure_boost == 1 then
				core.log("warning", "Structure "..def.name.." spawning is limited by distance, not by chunk_probability: "..p2.." * "..k2)
			end
			return 1
		end
		return min(p2 + p2 * (k2-1) * max(0, 1 - 0.5 * k2 * p2), 1)
	elseif (def.hash_mindist or 0) > 0 then
		local k = in_radius_3d(def.hash_mindist)
		if p * k >= 2 then
			if logging and structure_boost == 1 then
				core.log("warning", "Structure "..def.name.." spawning is limited by distance, not by chunk_probability: "..p.." * "..k)
			end
			return 1
		end
		return min(p + p * (k-1) * max(0, 1 - 0.5 * k * p), 1)
	end
	return min(p, 1)
end

--- Check if we should spawn a structure at this chunk
-- @param def table: structure definition
-- @param bx number: chunk x coordinate
-- @param by number: chunk y coordinate
-- @param bz number: chunk z coordinate
function vl_structures.check_hash_distance(def, bx, by, bz, seed)
	if not def._hash_spawn_threshold then
		local p = spawn_threshold(def)
		def._hash_spawn_threshold = min(p, 1) * 0xFFFFFFFF - 0x80000000 -- map to hash code range
		if def.hash_mindist then core.log("action", def.name.." p "..p.." thresh "..def._hash_spawn_threshold) end
	end
	if (def.hash_mindist_2d or 0) > 0 then
		return check_mindist_2d(bx, by, bz, def.hash_mindist_2d, seed, def._hash_spawn_threshold) < def._hash_spawn_threshold
	elseif (def.hash_mindist or 0) > 0 then
		return check_mindist(bx, by, bz, def.hash_mindist, seed, def._hash_spawn_threshold) < def._hash_spawn_threshold
	else
		return hash_pos(bx, by, bz, seed) < def._hash_spawn_threshold
	end
	return true
end
