mcl_mapgen = {}

local order = { -- mcl_mapgen.order...
	DEFAULT		=    5000,
	CHORUS		=  100000,
	BUILDINGS	=  200000,
	VILLAGES	=  900000,
	DUNGEONS	=  950000,
	STRONGHOLDS	=  999999,
	OCEAN_MONUMENT	= 1000000,
	LARGE_BUILDINGS	= 2000000,
}

local math_floor		= math.floor
local math_max			= math.max
local minetest_get_node		= minetest.get_node
local minetest_get_voxel_manip	= minetest.get_voxel_manip
local minetest_log		= minetest.log
local minetest_pos_to_string	= minetest.pos_to_string

-- Calculate mapgen_edge_min/mapgen_edge_max
mcl_mapgen.CS		= math_max(1, tonumber(minetest.get_mapgen_setting("chunksize"))	or 5)
mcl_mapgen.BS		= math_max(1, core.MAP_BLOCKSIZE					or 16)
mcl_mapgen.LIMIT	= math_max(1, tonumber(minetest.get_mapgen_setting("mapgen_limit"))	or 31000)
mcl_mapgen.MAX_LIMIT	= math_max(1, core.MAX_MAP_GENERATION_LIMIT				or 31000) -- might be set to 31000 or removed, see https://github.com/minetest/minetest/issues/10428
mcl_mapgen.OFFSET	= - math_floor(mcl_mapgen.CS / 2)
mcl_mapgen.OFFSET_NODES	= mcl_mapgen.OFFSET * mcl_mapgen.BS
mcl_mapgen.CS_NODES	= mcl_mapgen.CS * mcl_mapgen.BS

local central_chunk_min_pos = mcl_mapgen.OFFSET * mcl_mapgen.BS
local central_chunk_max_pos = central_chunk_min_pos + mcl_mapgen.CS_NODES - 1

local ccfmin = central_chunk_min_pos - mcl_mapgen.BS -- Fullminp/fullmaxp of central chunk, in nodes
local ccfmax = central_chunk_max_pos + mcl_mapgen.BS

local mapgen_limit_b = math_floor(math.min(mcl_mapgen.LIMIT, mcl_mapgen.MAX_LIMIT) / mcl_mapgen.BS)
local mapgen_limit_min = - mapgen_limit_b	* mcl_mapgen.BS
local mapgen_limit_max =  (mapgen_limit_b + 1)	* mcl_mapgen.BS - 1

local numcmin = math_max(math_floor((ccfmin - mapgen_limit_min) / mcl_mapgen.CS_NODES), 0) -- Number of complete chunks from central chunk
local numcmax = math_max(math_floor((mapgen_limit_max - ccfmax) / mcl_mapgen.CS_NODES), 0) -- fullminp/fullmaxp to effective mapgen limits.

mcl_mapgen.EDGE_MIN = central_chunk_min_pos - numcmin * mcl_mapgen.CS_NODES
mcl_mapgen.EDGE_MAX = central_chunk_max_pos + numcmax * mcl_mapgen.CS_NODES

minetest_log("action", "[mcl_mapgen] World edges: mcl_mapgen.EDGE_MIN = " .. tostring(mcl_mapgen.EDGE_MIN) .. ", mcl_mapgen.EDGE_MAX = " .. tostring(mcl_mapgen.EDGE_MAX))
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Mapgen variables
local overworld, end_, nether = {}, {}, {}
local seed = minetest.get_mapgen_setting("seed")
mcl_mapgen.seed = seed
mcl_mapgen.name = minetest.get_mapgen_setting("mg_name")
mcl_mapgen.v6 = mcl_mapgen.name == "v6"
mcl_mapgen.superflat = mcl_mapgen.name == "flat" and minetest.get_mapgen_setting("mcl_superflat_classic") == "true"
mcl_mapgen.singlenode = mcl_mapgen.name == "singlenode"
mcl_mapgen.normal = not mcl_mapgen.superflat and not mcl_mapgen.singlenode
local superflat, singlenode, normal = mcl_mapgen.superflat, mcl_mapgen.singlenode, mcl_mapgen.normal

minetest_log("action", "[mcl_mapgen] Mapgen mode: " .. (normal and "normal" or (superflat and "superflat" or "singlenode")))
----------------------------------------------------------------------------------------------------------------------------

-- Generator queues
local queue_unsafe_engine = {}
local queue_chunks_nodes  = {}
local queue_chunks_lvm    = {}
local queue_blocks_nodes  = {}
local queue_blocks_lvm    = {}

-- Requirements. 0 means 'none', greater than 0 means 'required'
local block                    = 0
local queue_blocks_lvm_counter = 0
local lvm_chunk                = 0
local param2                   = 0
local nodes_block              = 0
local nodes_chunk              = 0
local safe_functions           = 0

local BS, CS = mcl_mapgen.BS, mcl_mapgen.CS -- Mapblock size (in nodes), Mapchunk size (in blocks)
local LAST_BLOCK, LAST_NODE = CS - 1, BS - 1 -- First mapblock in chunk (node in mapblock) has number 0, last has THIS number. It's for runtime optimization
local offset = mcl_mapgen.OFFSET -- Central mapchunk offset (in blocks)
local CS_NODES = mcl_mapgen.CS_NODES -- 80

local CS_3D = CS * CS * CS

local DEFAULT_ORDER = order.DEFAULT

function mcl_mapgen.register_on_generated(callback_function, order)
	queue_unsafe_engine[#queue_unsafe_engine+1] = {i = order or DEFAULT_ORDER, f = callback_function}
	table.sort(queue_unsafe_engine, function(a, b) return (a.i <= b.i) end)
end
function mcl_mapgen.register_mapgen(callback_function, order)
	nodes_chunk = nodes_chunk + 1
	safe_functions = safe_functions + 1
	queue_chunks_nodes[nodes_chunk] = {i = order or DEFAULT_ORDER, f = callback_function}
	table.sort(queue_chunks_nodes, function(a, b) return (a.i <= b.i) end)
end
function mcl_mapgen.register_mapgen_lvm(callback_function, order)
	lvm_chunk = lvm_chunk + 1
	safe_functions = safe_functions + 1
	queue_chunks_lvm[lvm_chunk] = {i = order or DEFAULT_ORDER, f = callback_function}
	table.sort(queue_chunks_lvm, function(a, b) return (a.i <= b.i) end)
end
function mcl_mapgen.register_mapgen_block(callback_function, order)
	block = block + 1
	nodes_block = nodes_block + 1
	safe_functions = safe_functions + 1
	queue_blocks_nodes[nodes_block] = {i = order or DEFAULT_ORDER, f = callback_function}
	table.sort(queue_blocks_nodes, function(a, b) return (a.i <= b.i) end)
end
function mcl_mapgen.register_mapgen_block_lvm(callback_function, order)
	block = block + 1
	queue_blocks_lvm_counter = queue_blocks_lvm_counter + 1
	safe_functions = safe_functions + 1
	queue_blocks_lvm[queue_blocks_lvm_counter] = {order = order or DEFAULT_ORDER, callback_function = callback_function}
	table.sort(queue_blocks_lvm, function(a, b) return (a.order <= b.order) end)
end

local storage = minetest.get_mod_storage()
local blocks = minetest.deserialize(storage:get_string("mapgen_blocks") or "return {}") or {}
local chunks = minetest.deserialize(storage:get_string("mapgen_chunks") or "return {}") or {}
minetest.register_on_shutdown(function()
	storage:set_string("mapgen_chunks", minetest.serialize(chunks))
	storage:set_string("mapgen_blocks", minetest.serialize(blocks))
end)

local vm_context -- here will be many references and flags, like: param2, light_data, heightmap, biomemap, heatmap, humiditymap, gennotify, write_lvm, write_param2, shadow
local data, param2_data, light, area
local current_blocks = {}
local current_chunks = {}
local lvm_buffer, lvm_param2_buffer, lvm_light_buffer = {}, {}, {} -- Static buffer pointers

minetest.register_on_generated(function(minp, maxp, chunkseed)
	local minp, maxp, chunkseed = minp, maxp, chunkseed
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	minetest_log("warning", "[mcl_mapgen] New_chunk=" .. minetest_pos_to_string(minp) .. "..." .. minetest_pos_to_string(maxp) .. ", shell=" .. minetest_pos_to_string(emin) .. "..." .. minetest_pos_to_string(emax) .. ", chunkseed=" .. tostring(chunkseed))

	data = vm:get_data(lvm_buffer)
	area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	vm_context = {
		data              = data,
		param2_data       = param2_data,
                light             = light,
		area              = area,
		lvm_buffer        = lvm_buffer,
		lvm_param2_buffer = lvm_param2_buffer,
		lvm_light_buffer  = lvm_light_buffer,
		vm                = vm,
		emin              = emin,
		emax              = emax,
		minp              = minp,
		maxp              = maxp,
		chunkseed         = chunkseed,
	}

	if safe_functions > 0 then
		local x0, y0, z0 = minp.x, minp.y, minp.z
		local bx0, by0, bz0 = math_floor(x0/BS), math_floor(y0/BS), math_floor(z0/BS)
		local bx1, by1, bz1 = bx0 + LAST_BLOCK, by0 + LAST_BLOCK, bz0 + LAST_BLOCK -- only for entire chunk check

		-- Keep `chunkseed` in `chunks[cx][cy][cz].seed` for further safe usage:
		local cx0, cy0, cz0 = math_floor((bx0-offset)/CS), math_floor((by0-offset)/CS), math_floor((bz0-offset)/CS)
		if not chunks[cx0] then chunks[cx0] = {} end
		if not chunks[cx0][cy0] then chunks[cx0][cy0] = {} end
		if not chunks[cx0][cy0][cz0] then
			chunks[cx0][cy0][cz0] = {seed = chunkseed, counter = 0}
		else
			chunks[cx0][cy0][cz0].seed = chunkseed
		end

		local x1, y1, z1, x2, y2, z2 = emin.x, emin.y, emin.z, emax.x, emax.y, emax.z
		local x, y, z = x1, y1, z1 -- iterate 7x7x7 mapchunk, {x,y,z} - first node pos. of mapblock
		local bx, by, bz -- block coords (in blocs)
		local box, boy, boz -- block offsets in chunks (in blocks)
		while x < x2 do
			bx = math_floor(x/BS)
			local block_pos_offset_removed = bx - offset
			local cx = math_floor(block_pos_offset_removed / CS)
			box = block_pos_offset_removed % CS
			if not blocks[bx] then blocks[bx]={} end

			-- We don't know how many calls, including this one, will overwrite this block content!
			-- Start calculating it with `total_mapgen_block_writes_through_x` variable.
			-- It can be `8 or less`, if we (speaking of `x` axis) are on chunk edge now,
			-- or it can be `4 or less` - if we are in the middle of the chunk by `x` axis:

			local total_mapgen_block_writes_through_x = (box > 0 and box < LAST_BLOCK) and 4 or 8
			while y < y2 do
				by = math_floor(y/BS)
				block_pos_offset_removed = by - offset
				local cy = math_floor(block_pos_offset_removed / CS)
				boy = block_pos_offset_removed % CS
				if not blocks[bx][by] then blocks[bx][by]={} end

				-- Here we just divide `total_mapgen_block_writes_through_x` by 2,
				-- if we are (speaking of `y` axis now) in the middle of the chunk now.
				-- Or we don't divide it, if not.
				-- So, basing on `total_mapgen_block_writes_through_x`,
				--- we calculate `total_mapgen_block_writes_through_y` this way:

				local total_mapgen_block_writes_through_y = (boy > 0 and boy < LAST_BLOCK) and math_floor(total_mapgen_block_writes_through_x / 2) or total_mapgen_block_writes_through_x
				while z < z2 do
					bz = math_floor(z/BS)
					block_pos_offset_removed = bz - offset
					local cz = math_floor(block_pos_offset_removed / CS)
					boz = block_pos_offset_removed % CS

					-- Now we do absolutely the same for `z` axis, basing on our previous result
					-- from `total_mapgen_block_writes_through_y` variable.
					-- And our final result is in `total_mapgen_block_writes`.
					-- It can be still 8, derived from `x` calculation, but it can be less!
					-- It can be even 1, if we are in safe 3x3x3 area of mapchunk:

					local total_mapgen_block_writes = (boz > 0 and boz < LAST_BLOCK) and math_floor(total_mapgen_block_writes_through_y / 2) or total_mapgen_block_writes_through_y

					-- Get current number of writes from the table, or just set it to 1, if accessing first time:

					local current_mapgen_block_writes = blocks[bx][by][bz] and (blocks[bx][by][bz] + 1) or 1

					-- And compare:

					if current_mapgen_block_writes == total_mapgen_block_writes then
						-- this block shouldn't be overwritten anymore, no need to keep it in memory
						blocks[bx][by][bz] = nil
						if not chunks[cx] then chunks[cx] = {} end
						if not chunks[cx][cy] then chunks[cx][cy] = {} end
						if not chunks[cx][cy][cz] then
							if not chunks[cx][cy][cz] then chunks[cx][cy][cz] = {counter = 1} end
						else
							chunks[cx][cy][cz].counter = chunks[cx][cy][cz].counter + 1
							if chunks[cx][cy][cz].counter >= CS_3D then
								current_chunks[#current_chunks+1] = { x = cx, y = cy, z = cz, s = chunks[cx][cy][cz].seed }
								-- this chunk shouldn't be overwritten anymore, no need to keep it in memory
								chunks[cx][cy][cz] = nil
								if next(chunks[cx][cy]) == nil then chunks[cx][cy] = nil end
								if next(chunks[cx]) == nil then chunks[cx] = nil end
							end
						end
						local blockseed = seed + bx * 7 + by * 243 + bz * 11931
						if queue_blocks_lvm_counter > 0 then
							vm_context.blockseed = blockseed
							vm_context.minp, vm_context.maxp = {x=x, y=y, z=z}, {x=x+LAST_NODE, y=y+LAST_NODE, z=z+LAST_NODE}
							for _, v in pairs(queue_blocks_lvm) do
								v.callback_function(vm_context)
							end
						end
						if nodes_block > 0 then
							current_blocks[#current_blocks+1] = { minp = {x=x, y=y, z=z}, maxp = {x=x+LAST_NODE, y=y+LAST_NODE, z=z+LAST_NODE}, seed = blockseed }
						end
					else
						blocks[bx][by][bz] = current_mapgen_block_writes
					end
					z = z + BS
				end
				if next(blocks[bx][by]) == nil then blocks[bx][by] = nil end
				z = z1
				y = y + BS
			end
			if next(blocks[bx]) == nil then blocks[bx] = nil end
			y = y1
			x = x + BS
		end
	end

	if #queue_unsafe_engine > 0 then
		for _, v in pairs(queue_unsafe_engine) do
			v.f(vm_context)
		end
		if vm_context.write then
			vm:set_data(data)
		end
		if vm_context.write_param2 then
			vm:set_param2_data(vm_context.param2_data)
		end
		if vm_context.write_light then
			vm:set_light_data(light)
		end
		if vm_context.write or vm_context.write_param2 or vm_context.write_light then
			vm:calc_lighting(minp, maxp, (vm_context.shadow ~= nil) or true) -- TODO: check boundaries
			vm:write_to_map()
			vm:update_liquids()
		elseif vm_context.calc_lighting then
			vm:calc_lighting(minp, maxp, (vm_context.shadow ~= nil) or true)
		end
	end

	for i, b in pairs(current_chunks) do
		local cx, cy, cz, seed = b.x, b.y, b.z, b.s
		local bx, by, bz = cx * CS + offset, cy * CS + offset, cz * CS + offset
		local x, y, z = bx * BS, by * BS, bz * BS
		local minp = {x = x, y = y, z = z}
		local maxp = {x = x + CS_NODES - 1, y = y + CS_NODES - 1, z = z + CS_NODES - 1}
		area = VoxelArea:new({MinEdge=minp, MaxEdge=maxp})
		vm_context = {
			data              = data,
			param2_data       = param2_data,
	                light             = light,
			area              = area,
			lvm_buffer        = lvm_buffer,
			lvm_param2_buffer = lvm_param2_buffer,
			lvm_light_buffer  = lvm_light_buffer,
			emin              = minp,
			emax              = maxp,
			minp              = minp,
			maxp              = maxp,
			chunkseed         = seed,
		}
		for _, v in pairs(queue_chunks_lvm) do
			vm_context = v.f(vm_context)
		end
		for _, v in pairs(queue_chunks_nodes) do
			v.f(minp, maxp, seed, vm_context)
		end
		if vm_context.write or vm_context.write_param2 or vm_context.write_light then
			if vm_context.write then
				vm:set_data(data)
			end
			if vm_context.write_param2 then
				vm:set_param2_data(param2_data)
			end
			if vm_context.write_light then
				vm:set_light_data(light)
			end
			-- caused error from torches (?)
			-- vm:calc_lighting(minp, maxp, vm_context.shadow or true)
			vm:write_to_map()
			vm:update_liquids()
		elseif vm_context.calc_lighting then
			vm:calc_lighting(minp, maxp, (vm_context.shadow ~= nil) or true)
		end
		current_chunks[i] = nil
	end

	for i, b in pairs(current_blocks) do
		for _, v in pairs(queue_blocks_nodes) do
			v.f(b.minp, b.maxp, b.seed)
		end
		current_blocks[i] = nil
	end
end)

minetest.register_on_generated = mcl_mapgen.register_chunk_generator

function mcl_mapgen.get_far_node(p)
	local p = p
	local node = minetest_get_node(p)
	if node.name ~= "ignore" then return node end
	minetest_get_voxel_manip():read_from_map(p, p)
	return minetest_get_node(p)
end

local function coordinate_to_block(x)
	return math_floor(x / BS)
end

local function coordinate_to_chunk(x)
	return math_floor((coordinate_to_block(x) - offset) / CS)
end

function mcl_mapgen.pos_to_block(pos)
	return {
		x = coordinate_to_block(pos.x),
		y = coordinate_to_block(pos.y),
		z = coordinate_to_block(pos.z)
	}
end

function mcl_mapgen.pos_to_chunk(pos)
	return {
		x = coordinate_to_chunk(pos.x),
		y = coordinate_to_chunk(pos.y),
		z = coordinate_to_chunk(pos.z)
	}
end

local k_positive = math.ceil(mcl_mapgen.MAX_LIMIT / mcl_mapgen.CS_NODES)
local k_positive_z = k_positive * 2
local k_positive_y = k_positive_z * k_positive_z

function mcl_mapgen.get_chunk_number(pos) -- unsigned int
	local c = mcl_mapgen.pos_to_chunk(pos)
	return
		(c.y + k_positive) * k_positive_y +
		(c.z + k_positive) * k_positive_z +
		 c.x + k_positive
end

mcl_mapgen.minecraft_height_limit = 256

mcl_mapgen.bedrock_is_rough = normal

--[[ Realm stacking (h is for height)
- Overworld (h>=256)
- Void (h>=1000)
- Realm Barrier (h=11), to allow escaping the End
- End (h>=256)
- Void (h>=1000)
- Nether (h=128)
- Void (h>=1000)
]]

-- Overworld
overworld.min = -62
if superflat then
	mcl_mapgen.ground = tonumber(minetest.get_mapgen_setting("mgflat_ground_level")) or 8
	overworld.min = ground - 3
end
-- if singlenode then mcl_mapgen.overworld.min = -66 end -- DONT KNOW WHY
overworld.max = mcl_mapgen.EDGE_MAX

overworld.bedrock_min = overworld.min
overworld.bedrock_max = overworld.bedrock_min + (mcl_mapgen.bedrock_is_rough and 4 or 0)

mcl_mapgen.lava = normal
overworld.lava_max = overworld.min + (normal and 10 or 0)


-- The Nether (around Y = -29000)
nether.min = -29067 -- Carefully chosen to be at a mapchunk border
nether.max = nether.min + 128
nether.bedrock_bottom_min = nether.min
nether.bedrock_top_max = nether.max
if not superflat then
	nether.bedrock_bottom_max = nether.bedrock_bottom_min + 4
	nether.bedrock_top_min = nether.bedrock_top_max - 4
	nether.lava_max = nether.min + 31
else
	-- Thin bedrock in classic superflat mapgen
	nether.bedrock_bottom_max = nether.bedrock_bottom_min
	nether.bedrock_top_min = nether.bedrock_top_max
	nether.lava_max = nether.min + 2
end
if mcl_mapgen.name == "flat" then
	if superflat then
		nether.flat_floor = nether.bedrock_bottom_max + 4
		nether.flat_ceiling = nether.bedrock_bottom_max + 52
	else
		nether.flat_floor = nether.lava_max + 4
		nether.flat_ceiling = nether.lava_max + 52
	end
end

-- The End (surface at ca. Y = -27000)
end_.min = -27073 -- Carefully chosen to be at a mapchunk border
end_.max = overworld.min - 2000
end_.platform_pos = { x = 100, y = end_.min + 74, z = 0 }

-- Realm barrier used to safely separate the End from the void below the Overworld
mcl_mapgen.realm_barrier_overworld_end_max = end_.max
mcl_mapgen.realm_barrier_overworld_end_min = end_.max - 11

-- Use MineClone 2-style dungeons for normal mapgen
mcl_mapgen.dungeons = normal

mcl_mapgen.overworld = overworld
mcl_mapgen.end_ = end_
mcl_mapgen["end"] = mcl_mapgen.end_
mcl_mapgen.nether = nether

mcl_mapgen.order = order

function mcl_mapgen.get_voxel_manip(vm_context)
	if vm_context.vm then
		return vm
	end
	vm_context.vm = minetest.get_voxel_manip(vm_context.emin, vm_context.emax)
	vm_context.emin, vm_context.emax = vm_context.vm:read_from_map(vm_context.emin, vm_context.emax)
	vm_context.area = VoxelArea:new({MinEdge=vm_context.emin, MaxEdge=vm_context.emax})
	return vm_context.vm
end

function mcl_mapgen.clamp_to_chunk(x, size)
	if not size then
		minetest.log("warning", "[mcl_mapgen] Couldn't clamp " .. tostring(x) .. " - missing size")
		return x
	end
	if size > CS_NODES then
		minetest.log("warning", "[mcl_mapgen] Couldn't clamp " .. tostring(x) .. " - given size " .. tostring(size) .. " greater than chunk size " .. tostring(mcl_mapgen.CS_NODES))
		return x
	end
	local offset_in_chunk = (x + central_chunk_min_pos) % CS_NODES
	local x2_in_chunk = offset_in_chunk + size
	if x2_in_chunk <= CS_NODES then
		return x
	end
	local overflow = x2_in_chunk - CS_NODES
	if overflow > size / 2 then
		local next_x = x + (size - overflow)
		if next_x < mcl_mapgen.EDGE_MAX then
			return next_x
		end
	end
	return x - overflow
end

function mcl_mapgen.get_chunk_beginning(x)
	return x - ((x + central_chunk_min_pos) % CS_NODES)
end
