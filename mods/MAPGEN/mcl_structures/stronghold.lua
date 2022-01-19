-- Generate strongholds.

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

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

local superflat = mcl_mapgen.superflat

local size = {x = 13, y = 8, z = 13}
local offset = vector.round(vector.divide(size, 2))

local function place(pos, rotation, pr)
	local p1 = { x = pos.x - offset.x, y = pos.y - offset.y, z = pos.z - offset.z }
	local p2 = vector.add(p1, vector.subtract(size, 1))

	local path = modpath.."/schematics/mcl_structures_end_portal_room_simple.mts"

	mcl_structures.place_schematic({
		pos       = p1,
		schematic = path,
		rotation  = rotation or "0",
		pr        = pr,
	})
	-- Find and setup spawner with silverfish
	local spawners = minetest.find_nodes_in_area(p1, p2, "mcl_mobspawners:spawner")
	for s=1, #spawners do
		mcl_mobspawners.setup_spawner(spawners[s], "mobs_mc:silverfish")
	end

	-- Shuffle stone brick types
	local bricks = minetest.find_nodes_in_area(p1, p2, "mcl_core:stonebrick")
	for b=1, #bricks do
		local r_bricktype = pr:next(1, 100)
		local r_infested = pr:next(1, 100)
		local bricktype
		if r_infested <= 5 then
			if r_bricktype <= 30 then -- 30%
				bricktype = "mcl_monster_eggs:monster_egg_stonebrickmossy"
			elseif r_bricktype <= 50 then -- 20%
				bricktype = "mcl_monster_eggs:monster_egg_stonebrickcracked"
			else -- 50%
				bricktype = "mcl_monster_eggs:monster_egg_stonebrick"
			end
		else
			if r_bricktype <= 30 then -- 30%
				bricktype = "mcl_core:stonebrickmossy"
			elseif r_bricktype <= 50 then -- 20%
				bricktype = "mcl_core:stonebrickcracked"
			end
			-- 50% stonebrick (no change necessary)
		end
		if bricktype then
			minetest.set_node(bricks[b], { name = bricktype })
		end
	end

	-- Also replace stairs
	local stairs = minetest.find_nodes_in_area(p1, p2, {"mcl_stairs:stair_stonebrick", "mcl_stairs:stair_stonebrick_outer", "mcl_stairs:stair_stonebrick_inner"})
	for s=1, #stairs do
		local stair = minetest.get_node(stairs[s])
		local r_type = pr:next(1, 100)
		if r_type <= 30 then -- 30% mossy
			if stair.name == "mcl_stairs:stair_stonebrick" then
				stair.name = "mcl_stairs:stair_stonebrickmossy"
			elseif stair.name == "mcl_stairs:stair_stonebrick_outer" then
				stair.name = "mcl_stairs:stair_stonebrickmossy_outer"
			elseif stair.name == "mcl_stairs:stair_stonebrick_inner" then
				stair.name = "mcl_stairs:stair_stonebrickmossy_inner"
			end
			minetest.set_node(stairs[s], stair)
		elseif r_type <= 50 then -- 20% cracky
			if stair.name == "mcl_stairs:stair_stonebrick" then
				stair.name = "mcl_stairs:stair_stonebrickcracked"
			elseif stair.name == "mcl_stairs:stair_stonebrick_outer" then
				stair.name = "mcl_stairs:stair_stonebrickcracked_outer"
			elseif stair.name == "mcl_stairs:stair_stonebrick_inner" then
				stair.name = "mcl_stairs:stair_stonebrickcracked_inner"
			end
			minetest.set_node(stairs[s], stair)
		end
		-- 50% no change
	end

	-- Randomly add ender eyes into end portal frames, but never fill the entire frame
	local frames = minetest.find_nodes_in_area(p1, p2, "mcl_portals:end_portal_frame")
	local eyes = 0
	for f=1, #frames do
		local r_eye = pr:next(1, 10)
		if r_eye == 1 then
			eyes = eyes + 1
			if eyes < #frames then
				local frame_node = minetest.get_node(frames[f])
				frame_node.name = "mcl_portals:end_portal_frame_eye"
				minetest.set_node(frames[f], frame_node)
			end
		end
	end
end


-- Determine the stronghold positions and store them into the strongholds table.
-- The stronghold positions are based on the world seed.
-- The actual position might be offset by a few blocks because it might be shifted
-- to make sure the end portal room is completely within the boundaries of a mapchunk.
local function init_strongholds()
	if strongholds_inited then
		return
	end
	-- Don't generate strongholds in singlenode
	if mcl_mapgen.singlenode then
		strongholds_inited = true
		return
	end
	local pr = PseudoRandom(mcl_mapgen.seed)
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
				y = mcl_mapgen.overworld.bedrock_max + offset.y
			else
				y = pr:next(mcl_mapgen.overworld.bedrock_max+1+offset.y, mcl_mapgen.overworld.bedrock_min+48+offset.y)
			end
			local pos = {
				x = mcl_mapgen.clamp_to_chunk(math.floor(math.cos(angle) * dist) - offset.x, size.x) + offset.x,
				y = mcl_mapgen.clamp_to_chunk(y - offset.y, size.y) + offset.y,
				z = mcl_mapgen.clamp_to_chunk(math.floor(math.sin(angle) * dist) - offset.z, size.z) + offset.z,
			}
			table.insert(strongholds, { pos = pos, generated = false })

			-- Rotate angle by (360 / amount) degrees.
			-- This will cause the angles to be evenly distributed in the stronghold ring
			angle = math.fmod(angle + ((math.pi*2) / ring.amount), math.pi*2)
		end
	end

	mcl_structures.strongholds = strongholds

	mcl_structures.register_structure({
		name = "stronghold",
		place_function = place,
	})

	strongholds_inited = true
end

init_strongholds()

-- Stronghold generation for register_on_generated.
mcl_mapgen.register_mapgen(function(minp, maxp, blockseed)
	local pr = PseudoRandom(blockseed)
	for s=1, #strongholds do
		if not strongholds[s].generated then
			local pos = strongholds[s].pos
			if minp.x <= pos.x and maxp.x >= pos.x and minp.z <= pos.z and maxp.z >= pos.z and minp.y <= pos.y and maxp.y >= pos.y then
				place(pos, nil, pr)
				strongholds[s].generated = true
			end
		end
	end
end, mcl_mapgen.order.STRONGHOLDS)
