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

local mg_name = minetest.get_mapgen_setting("mg_name")
local superflat = mg_name == "flat" and minetest.get_mapgen_setting("mcl_superflat_classic") == "true"
local seed = tonumber(minetest.get_mapgen_setting("seed"))

local function init_strongholds()
	local stronghold_positions = {}
	-- Don't generate strongholds in singlenode
	if mg_name == "singlenode" then
		return {}
	end
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
			table.insert(stronghold_positions, pos)

			-- Rotate angle by (360 / amount) degrees.
			-- This will cause the angles to be evenly distributed in the stronghold ring
			angle = math.fmod(angle + ((math.pi*2) / ring.amount), math.pi*2)
		end
	end
	return stronghold_positions
end

-- Stronghold generation for register_on_generated.
local function generate_strongholds(minp, maxp, blockseed)
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

				--vl_structures.call_struct(pos, "end_portal_shrine", nil, pr)
				strongholds[s].generated = true
			end
		end
	end
end

vl_structures.register_structure("end_shrine",{
	static_pos = init_strongholds(),
	prepare = { tolerance = "off", foundation = false, clear = false },
	filenames = {
		minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_end_portal_room_simple.mts"
	},
	after_place = function(pos, def, pr, p1, p2, size, rotation)
		local spawners = minetest.find_nodes_in_area(p1, p2, "mcl_mobspawners:spawner")
		for s=1, #spawners do
			--local meta = minetest.get_meta(spawners[s])
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
	end,
})
