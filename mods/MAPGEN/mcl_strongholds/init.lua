-- Generate strongholds.

-- A total of 128 strongholds are generated in rings around the world origin.
-- This is the list of rings, starting with the innermost ring first.
local stronghold_rings = {
	-- amount: Number of strongholds in ring.
	-- min, max: Minimum and maximum distance from (X=0, Z=0).
	{ amount = 3, min = 1408, max = 2688 },
	{ amount = 6, min = 4480, max = 5760 },
	{ amount = 10, min = 7552, max = 8832 },
	{ amount = 15, min = 10624, max = 11904 },
	{ amount = 21, min = 13696, max = 14976 },
	{ amount = 28, min = 16768, max = 18048 },
	{ amount = 36, min = 19840, max = 21120 },
	{ amount = 9, min = 22912, max = 24192 },
}

local strongholds = {}
local strongholds_inited = false

local mg_name = minetest.get_mapgen_setting("mg_name")
local superflat = mg_name == "flat" and minetest.get_mapgen_setting("mcl_superflat_classic") == "true"

-- Determine the stronghold positions and store them into the strongholds table.
-- The stronghold positions are based on the world seed.
-- The actual position might be offset by a few blocks because it might be shifted
-- to make sure the end portal room is completely within the boundaries of a mapchunk.
local init_strongholds = function()
	if strongholds_inited then
		return
	end
	-- Don't generate strongholds in singlenode
	if mg_name == "singlenode" then
		strongholds_inited = true
		return
	end
	local seed = tonumber(minetest.get_mapgen_setting("seed"))
	local pr = PseudoRandom(seed)
	for s=1, #stronghold_rings do
		local ring = stronghold_rings[s]

		-- Get random angle
		local angle = pr:next()
		-- Scale angle to 0 .. 2*math.pi
		angle = (angle / 32767) * (math.pi*2)
		for a=1, ring.amount do
			local dist = pr:next(ring.min, ring.max)
			local y
			if superflat then
				y = mcl_vars.mg_bedrock_overworld_max + 3
			else
				y = pr:next(mcl_vars.mg_bedrock_overworld_max+1, mcl_vars.mg_overworld_min+48)
			end
			local pos = { x = math.cos(angle) * dist, y = y, z = math.sin(angle) * dist }
			pos = vector.round(pos)
			table.insert(strongholds, { pos = pos, generated = false })

			-- Rotate angle by (360 / amount) degrees.
			-- This will cause the angles to be evenly distributed in the stronghold ring
			angle = math.fmod(angle + ((math.pi*2) / ring.amount), math.pi*2)
		end
	end

	mcl_structures.register_structures("stronghold", table.copy(strongholds))

	strongholds_inited = true
end

-- Stronghold generation for register_on_generated.
local generate_strongholds = function(minp, maxp, blockseed)
	local pr = PseudoRandom(blockseed)
	for s=1, #strongholds do
		if not strongholds[s].generated then
			local pos = strongholds[s].pos
			if minp.x <= pos.x and maxp.x >= pos.x and minp.z <= pos.z and maxp.z >= pos.z and minp.y <= pos.y and maxp.y >= pos.y then
				-- Make sure the end portal room is completely within the current mapchunk
				-- The original pos is changed intentionally.
				if pos.x - 6 < minp.x then
					pos.x = minp.x + 7
				end
				if pos.x + 6 > maxp.x then
					pos.x = maxp.x - 7
				end
				if pos.y - 4 < minp.y then
					pos.y = minp.y + 5
				end
				if pos.y + 4 > maxp.y then
					pos.y = maxp.y - 5
				end
				if pos.z - 6 < minp.z then
					pos.z = minp.z + 7
				end
				if pos.z + 6 > maxp.z then
					pos.z = maxp.z - 7
				end

				mcl_structures.call_struct(pos, "end_portal_shrine", nil, pr)
				strongholds[s].generated = true
			end
		end
	end
end

init_strongholds()

mcl_mapgen_core.register_generator("strongholds", nil, generate_strongholds, 999999)
