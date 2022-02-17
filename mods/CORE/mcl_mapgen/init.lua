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
mcl_mapgen.CS                 = math_max(1, tonumber(minetest.get_mapgen_setting("chunksize")) or 5)
mcl_mapgen.BS                 = math_max(1, core.MAP_BLOCKSIZE or 16)
mcl_mapgen.LIMIT              = math_max(1, tonumber(minetest.get_mapgen_setting("mapgen_limit")) or 31000)
mcl_mapgen.MAX_LIMIT          = 31000 -- MAX_MAP_GENERATION_LIMIT, https://github.com/minetest/minetest/issues/10428
mcl_mapgen.OFFSET             = - math_floor(mcl_mapgen.CS / 2)
mcl_mapgen.OFFSET_NODES       = mcl_mapgen.OFFSET * mcl_mapgen.BS
mcl_mapgen.CS_NODES	      = mcl_mapgen.CS * mcl_mapgen.BS
mcl_mapgen.LAST_BLOCK         = mcl_mapgen.CS - 1
mcl_mapgen.LAST_NODE_IN_BLOCK = mcl_mapgen.BS - 1
mcl_mapgen.LAST_NODE_IN_CHUNK = mcl_mapgen.CS_NODES - 1
mcl_mapgen.HALF_CS_NODES      = math_floor(mcl_mapgen.CS_NODES / 2)
mcl_mapgen.HALF_BS            = math_floor(mcl_mapgen.BS / 2)
mcl_mapgen.CS_3D              = mcl_mapgen.CS^3
mcl_mapgen.CHUNK_WITH_SHELL   = mcl_mapgen.CS + 2
mcl_mapgen.CHUNK_WITH_SHELL_3D = mcl_mapgen.CHUNK_WITH_SHELL^3

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
mcl_mapgen.flat = mcl_mapgen.name == "flat"
mcl_mapgen.superflat = mcl_mapgen.flat and minetest.get_mapgen_setting("mcl_superflat_classic") == "true"
mcl_mapgen.singlenode = mcl_mapgen.name == "singlenode"
mcl_mapgen.normal = not mcl_mapgen.superflat and not mcl_mapgen.singlenode
local flat, superflat, singlenode, normal = mcl_mapgen.flat, mcl_mapgen.superflat, mcl_mapgen.singlenode, mcl_mapgen.normal

minetest_log("action", "[mcl_mapgen] Mapgen mode: " .. (normal and "normal" or (superflat and "superflat" or (flat and "flat" or "singlenode"))))
-------------------------------------------------------------------------------------------------------------------------------------------------

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

local BS, CS             = mcl_mapgen.BS, mcl_mapgen.CS -- Mapblock size (in nodes), Mapchunk size (in blocks)
local offset             = mcl_mapgen.OFFSET -- Central mapchunk offset (in blocks)
local CS_NODES           = mcl_mapgen.CS_NODES
local LAST_BLOCK         = mcl_mapgen.LAST_BLOCK
local LAST_NODE_IN_BLOCK = mcl_mapgen.LAST_NODE_IN_BLOCK
local LAST_NODE_IN_CHUNK = mcl_mapgen.LAST_NODE_IN_CHUNK
local HALF_CS_NODES      = mcl_mapgen.HALF_CS_NODES
local CS_3D              = mcl_mapgen.CS_3D
local CHUNK_WITH_SHELL   = mcl_mapgen.CHUNK_WITH_SHELL
local CHUNK_WITH_SHELL_3D = mcl_mapgen.CHUNK_WITH_SHELL_3D

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

local vm_context -- here will be many references and flags, like: param2, light_data, heightmap, biomemap, heatmap, humiditymap, gennotify, write_lvm, write_param2, shadow
local data, param2_data, light, area
local lvm_buffer, lvm_param2_buffer, lvm_light_buffer = {}, {}, {} -- Static buffer pointers

local all_blocks_in_chunk = {}
for x = -1, LAST_BLOCK+1 do
	for y = -1, LAST_BLOCK+1 do
		for z = -1, LAST_BLOCK+1 do
			all_blocks_in_chunk[CHUNK_WITH_SHELL * (CHUNK_WITH_SHELL * y + z) + x] = vector.new(x, y, z)
		end
	end
end

local chunk_scan_range = {
	[-CS_NODES] = {-1          , -1          },
	[ 0       ] = {-1          , LAST_BLOCK+1},
        [ CS_NODES] = {LAST_BLOCK+1, LAST_BLOCK+1},
}

local function is_chunk_finished(minp)
	local center = vector.add(minp, HALF_CS_NODES)
	for check_x = center.x - CS_NODES, center.x + CS_NODES, CS_NODES do
		for check_y = center.y - CS_NODES, center.y + CS_NODES, CS_NODES do
			for check_z = center.z - CS_NODES, center.z + CS_NODES, CS_NODES do
				local pos = vector.new(check_x, check_y, check_z)
				if pos ~= center then
					minetest_get_voxel_manip():read_from_map(pos, pos)
					local node = minetest_get_node(pos)
					if node.name == "ignore" then
						return
					end
				end
			end
		end
	end
	return true
end

local function uint32_t(v)
	if v >= 0 then
		return v % 0x100000000
	end
	return 0x100000000 - (math.abs(v) % 0x100000000)
end

local function get_block_seed(pos, current_seed)
	local current_seed = current_seed or uint32_t(tonumber(seed))
	return uint32_t(uint32_t(23 * pos.x) + uint32_t(42123 * pos.y) + uint32_t(38134234 * pos.z) + current_seed)
end

local function get_block_seed2(pos, current_seed)
	local current_seed = current_seed or uint32_t(tonumber(seed))
	local n = uint32_t(uint32_t(1619 * pos.x) + uint32_t(31337 * pos.y) + uint32_t(52591 * pos.z) + uint32_t(1013 * current_seed))
	n = bit.bxor(bit.rshift(n, 13), n)
	local seed = uint32_t((n * uint32_t(n * n * 60493 + 19990303) + 1376312589))
	return seed
end

local function get_block_seed3(pos, current_seed)
	local current_seed = uint32_t(current_seed or uint32_t(tonumber(seed)))
	local x = uint32_t((pos.x + 32768) * 13)
	local y = uint32_t((pos.y + 32767) * 13873)
	local z = uint32_t((pos.z + 76705) * 115249)
	local seed = uint32_t(bit.bxor(current_seed, x, y, z))
	return seed
end

minetest.register_on_generated(function(minp, maxp, chunkseed)
	local minp, maxp, chunkseed = minp, maxp, chunkseed
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
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

	local current_blocks = {}
	local current_chunks = {}
	if safe_functions > 0 then
		local ready_blocks = table.copy(all_blocks_in_chunk)
		local p0 = vector.new(minp)
		local center = vector.add(p0, HALF_CS_NODES)
		for x = -CS_NODES, CS_NODES, CS_NODES do
			for y = -CS_NODES, CS_NODES, CS_NODES do
				for z = -CS_NODES, CS_NODES, CS_NODES do
					if x ~= 0 or y ~= 0 or z ~= 0 then
						local offset = vector.new(x, y, z)
						local pos = center + offset
						minetest_get_voxel_manip():read_from_map(pos, pos)
						local node = minetest_get_node(pos)
						local is_generated = node.name ~= "ignore"
						if is_generated then
							local adjacent_chunk_pos = p0 + offset
							if is_chunk_finished(adjacent_chunk_pos) then
								current_chunks[#current_chunks + 1] = adjacent_chunk_pos
							end
						else
							local scan_range_x = chunk_scan_range[x]
							for cut_x = scan_range_x[1], scan_range_x[2] do
								local scan_range_y = chunk_scan_range[y]
								for cut_y = scan_range_y[1], scan_range_y[2] do
									local scan_range_z = chunk_scan_range[z]
									for cut_z = scan_range_z[1], scan_range_z[2] do
										ready_blocks[CHUNK_WITH_SHELL * (CHUNK_WITH_SHELL * cut_y + cut_z) + cut_x] = nil
									end
								end
							end
						end
					end
				end
			end
		end
		local number_of_blocks = 0
		for k, offset in pairs(ready_blocks) do
			if queue_blocks_lvm_counter > 0 or nodes_block > 0 then
				local block_minp = p0 + vector.multiply(offset, BS)
				local block_maxp = vector.add(block_minp, LAST_NODE_IN_BLOCK)
				local blockseed = get_block_seed3(block_minp)
				vm_context.minp, vm_context.maxp, vm_context.blockseed = block_minp, block_maxp, blockseed
				--                                                                            --
				--  mcl_mapgen.register_mapgen_block_lvm(function(vm_context), order_number)  --
				--                                                                            --
				for _, v in pairs(queue_blocks_lvm) do
					v.callback_function(vm_context)
				end
				if nodes_block > 0 then
					current_blocks[#current_blocks + 1] = { minp = block_minp, maxp = block_maxp, blockseed = blockseed }
				end
			end
			number_of_blocks = number_of_blocks + 1
		end
		if number_of_blocks == CHUNK_WITH_SHELL_3D then
			current_chunks[#current_chunks + 1] = p0
		end
	end

	if #queue_unsafe_engine > 0 then
		vm_context.minp, vm_context.maxp = minp, maxp
		--     * U N S A F E                                                      --
		--  mcl_mapgen.register_on_generated(function(vm_context), order_number)  --
		--                                                    * U N S A F E       --
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
			vm:calc_lighting(minp, maxp, (vm_context.shadow ~= nil) or true)
			vm:write_to_map()
			vm:update_liquids()
		elseif vm_context.calc_lighting then
			vm:calc_lighting(minp, maxp, (vm_context.shadow ~= nil) or true)
		end
	end

	for i, chunk_minp in pairs(current_chunks) do
		local chunk_maxp = vector.add(chunk_minp, LAST_NODE_IN_CHUNK)
		local current_chunk_seed = get_block_seed3(vector.subtract(chunk_minp, BS))
		area = VoxelArea:new({MinEdge=minp, MaxEdge=maxp})
		vm_context = {
			data              = data,
			param2_data       = param2_data,
	                light             = light,
			area              = area,
			lvm_buffer        = lvm_buffer,
			lvm_param2_buffer = lvm_param2_buffer,
			lvm_light_buffer  = lvm_light_buffer,
			emin              = chunk_minp,
			emax              = chunk_maxp,
			minp              = chunk_minp,
			maxp              = chunk_maxp,
			chunkseed         = current_chunk_seed,
		}
		--                                                                        --
		--  mcl_mapgen.register_mapgen_lvm(function(vm_context), order_number)    --
		--                                                                        --
		for _, v in pairs(queue_chunks_lvm) do
			vm_context = v.f(vm_context)
		end
		--                                                                                         --
		--  mcl_mapgen.register_mapgen(function(minp, maxp, chunkseed, vm_context), order_number)  --
		--                                                                                         --
		for _, v in pairs(queue_chunks_nodes) do
			v.f(chunk_minp, chunk_maxp, current_chunk_seed, vm_context)
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
	end

	for _, b in pairs(current_blocks) do
		--                                                                                     --
		--  mcl_mapgen.register_mapgen_block(function(minp, maxp, blockseed), order_number)    --
		--                                                                                     --
		for _, v in pairs(queue_blocks_nodes) do
			v.f(b.minp, b.maxp, b.blockseed)
		end
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
if superflat then
	nether.flat_floor = nether.bedrock_bottom_max + 4
	nether.flat_ceiling = nether.bedrock_bottom_max + 52
elseif flat then
	nether.flat_floor = nether.lava_max + 4
	nether.flat_ceiling = nether.lava_max + 52
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
	if tonumber(x) then
		return x - ((x + central_chunk_min_pos) % CS_NODES)
	end
	if x.x then
		return {
			x = mcl_mapgen.get_chunk_beginning(x.x),
			y = mcl_mapgen.get_chunk_beginning(x.y),
			z = mcl_mapgen.get_chunk_beginning(x.z)
		}
	end
end

function mcl_mapgen.get_chunk_ending(x)
	if tonumber(x) then
		return mcl_mapgen.get_chunk_beginning(x) + LAST_NODE_IN_CHUNK
	end
	if x.x then
		return {
			x = mcl_mapgen.get_chunk_beginning(x.x) + LAST_NODE_IN_CHUNK,
			y = mcl_mapgen.get_chunk_beginning(x.y) + LAST_NODE_IN_CHUNK,
			z = mcl_mapgen.get_chunk_beginning(x.z) + LAST_NODE_IN_CHUNK
		}
	end
end

mcl_mapgen.get_block_seed = get_block_seed
mcl_mapgen.get_block_seed2 = get_block_seed2
mcl_mapgen.get_block_seed3 = get_block_seed3
