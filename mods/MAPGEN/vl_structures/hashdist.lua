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
-- additional variants, e.g.,
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
-- It is not sufficient to do this only in 2d, or we may spawn structures in vertically neighboring
-- chunks (as these happen in separate emerges). We want deterministic spawning!
-- Hence, in 2d mode, we additionally have to check the vertical column, which means our approach
-- uses a cylinder. This reduces spawn success rates by about 1/3rd; it is currently not configurable.
--
-- Together with the cylinder rule for 2d and radius, we get the following sizes:
--
-- | Distance |   1.0 |   1.5 |   1.8 |   2.0 |   2.3 |   2.5 |   2.9 |   3.0 |   3.5 |   4.0 |
-- |----------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|
-- |       2D |    15 |    27 |    27 |    39 |    39 |    63 |    75 |    87 |   111 |   147 |
-- |  maxprob | 6.67% | 3.70% | 3.70% | 2.56% | 2.56% | 1.59% | 1.33% | 1.149%| 0.900%| 0.680%|
-- |     cost |     8 |    12 |    12 |    16 |    16 |    24 |    28 |    32 |    40 |    52 |
-- |----------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|
-- |       3D |     7 |    19 |    27 |    33 |    57 |    81 |    93 |   123 |   179 |   257 |
-- |  maxprob | 14.3% | 5.26% | 3.70% | 3.03% | 1.75% | 1.23% | 1.08% | 0.813%| 0.559%| 0.389%|
-- |     cost |     7 |    19 |    27 |    33 |    57 |    81 |    93 |   123 |   179 |   257 |
--
-- As you can see, the 2d/cylinder approach needs fewer cheap hash computations ("cost"),
-- but the cylinders block a larger theoretical volume than in the 3d approach if the ball is
-- small (we fix the cylinder height to a constant of 3).
-- For surface decorations at a high distance, the 2D approach is usually better.
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

local max, min, sqrt, floor, ceil = math.max, math.min, math.sqrt, math.floor, math.ceil
local hash_pos = mcl_util.hash_pos

--- Probability estimates
--- Number of nodes with integer coordinates in radius r
-- @param r number: radius
-- @return number: number of integer nodes in radius
local function in_radius_2d(r)
	assert(r > 0)
	local n = 0
	for x = -floor(r), floor(r) do
		n = n + floor(sqrt(r*r-x*x)) * 2 + 1
	end
	assert(n == n, "NaN in in_radius_2d, float precision issues, please report the radius "..r)
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
	assert(r > 0)
	local n = 0
	for x = -floor(r), floor(r) do
		local r2 = floor(sqrt(r*r-x*x))
		for y = -r2, r2 do
			n = n + floor(sqrt(r*r-x*x-y*y)) * 2 + 1
		end
	end
	assert(n == n, "NaN in in_radius_3d, float precision issues, please report the radius "..r)
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
-- The key idea is `chunk_probability * structure_boost * area_volume`.
-- Because of the volume term, this will often exceed 1 when the desired
-- proability and spacing are unsatisfiable at the same time.
-- When densely packed, the volumes overlap, and there are gaps in circle
-- and sphere packings, with the packing density of random close packings
-- being 0.886 in 2d and 0.64. Here we must assume the packing density is
-- even worse. For simplicity, we assume 0.75 and 0.5, so we use
-- the multipliers 0.5 (1d) 0.5/0.75 = 0.667 (2d) and 0.5/0.5 = 1 (3d).
-- There are many more effects (such as terrain, y limits, etc.) that make
-- these estimates only rough.
--
-- @param def table: structure definition
-- @param sidelen number: sidelen used by the spawning mechanism
-- @return th number: spawning threshold
local function spawn_threshold(def, sidelen)
	if not def.chunk_probability then return nil end
	local p = def.chunk_probability / 100 * structure_boost
	if sidelen ~= 80 then p = p * (sidelen * sidelen) / 6400 end -- chunk to sidelen, pretend 2d
	if def.hash_mindist_2d then
		local r = def.hash_mindist_2d
		local k = in_radius_2d(max(1, r / sidelen))
		local p2 = p + p * (k-1) * 0.667
		if p2 >= 2 then
			if logging and structure_boost == 1 then
				core.log("warning", "Structure "..def.name.." spawning is limited by distance, not by chunk_probability: "..p.." * "..k)
			end
			return 1
		end
		local k2 = 3 --2 * max(1, math.ceil(ry / sidelen)) + 1
		local p3 = p2 + p2 * (k2-1) * 0.5
		if p3 >= 2 then
			if logging and structure_boost == 1 then
				core.log("warning", "Structure "..def.name.." spawning is limited by distance, not by chunk_probability: "..p2.." * "..k2)
			end
			return 1
		end
		return min(p3, 1)
	elseif def.hash_mindist then
		local k = in_radius_3d(def.hash_mindist / sidelen)
		if p * k >= 2 then
			if logging and structure_boost == 1 then
				core.log("warning", "Structure "..def.name.." spawning is limited by distance, not by chunk_probability: "..p.." * "..k)
			end
			return 1
		end
		return min(p * k, 1)
	end
	return min(p, 1)
end

--- Avoid structures in nearby chunks
-- @param bx number: chunk x
-- @param by number: chunk y
-- @param bz number: chunk z
-- @param mindist number: distance to check
-- @param seed number: Random seed
-- @return Hash code of the position, or nil
local function check_mindist_2d(bx, by, bz, mindist, seed, lim)
	local th = hash_pos(bx, by, bz, seed)
	if th >= lim then return 1e100 end
	-- 2d hashing with constant y
	local mh = hash_pos(bx, --[[0,]] bz, seed)
	local dx = ceil(mindist)
	for x = -dx,dx do
		local dz = ceil(sqrt(mindist*mindist - x*x))
		for z = -dz,dz do
			if x ~= 0 or z ~= 0 then
				if hash_pos(bx + x, --[[0,]] bz + z, seed) <= mh then return 1e100 end -- neighbor chunk wins
			end
		end
	end
	-- now also check vertical neighbor chunks
	if hash_pos(bx, by - 1, bz, seed) <= th then return 1e100 end
	if hash_pos(bx, by + 1, bz, seed) <= th then return 1e100 end
	--core.log("action", "bx "..bx.." by "..by.." bz "..bz.." hash "..bit.tohex(th))
	return th -- no collision, return hash code
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
	local dx = ceil(mindist)
	for x = -dx,dx do
		local dy = ceil(sqrt(mindist*mindist - x*x))
		for y = -dy,dy do
			local dz = ceil(sqrt(mindist*mindist - x*x - y*y))
			for z = -dz,dz do
				if x ~= 0 or y ~= 0 or z ~= 0 then
					if hash_pos(bx+x, by+y, bz+z, seed) <= mh then return 1e100 end -- neighbor chunk wins
				end
			end
		end
	end
	return mh -- no collision, return hash code
end

--- Check if we should spawn a structure at this chunk
-- @param def table: structure definition
-- @param bx number: chunk x coordinate
-- @param by number: chunk y coordinate
-- @param bz number: chunk z coordinate
-- @param sidelen number: spawning sidelen for scaling radius and threshold
-- @param seed number: random seed
function vl_structures.check_hash_distance(def, bx, by, bz, sidelen, seed)
	if not def._hash_spawn_threshold then
		local p = spawn_threshold(def, sidelen)
		def._hash_spawn_threshold = min(p, 1) * 0xFFFFFFFF - 0x80000000 -- map to hash code range
	end
	if def.hash_mindist_2d then
		local r = def.hash_mindist_2d / sidelen
		return check_mindist_2d(bx, by, bz, r, seed, def._hash_spawn_threshold) < def._hash_spawn_threshold
	elseif def.hash_mindist then
		local r = def.hash_mindist / sidelen
		return check_mindist(bx, by, bz, r, seed, def._hash_spawn_threshold) < def._hash_spawn_threshold
	else
		return hash_pos(bx, by, bz, seed) < def._hash_spawn_threshold
	end
end
