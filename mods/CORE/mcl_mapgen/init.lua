mcl_mapgen = {}

local lvm_block_queue, lvm_chunk_queue, node_block_queue, node_chunk_queue = {}, {}, {}, {} -- Generators' queues
local lvm, block, lvm_block, lvm_chunk, param2, nodes_block, nodes_chunk = 0, 0, 0, 0, 0, 0, 0 -- Requirements: 0 means none; greater than 0 means 'required'
local lvm_buffer, lvm_param2_buffer = {}, {} -- Static buffer pointers
local BS, CS = mcl_vars.MAP_BLOCKSIZE, mcl_vars.chunksize -- Mapblock size (in nodes), Mapchunk size (in blocks)
local LAST_BLOCK, LAST_NODE = CS - 1, BS - 1 -- First mapblock in chunk (node in mapblock) has number 0, last has THIS number. It's for runtime optimization
local offset = math.floor(mcl_vars.central_chunk_offset_in_nodes / BS) -- Central mapchunk offset (in blocks)

local DEFAULT_PRIORITY	= 5000

local minetest_log, math_floor = minetest.log, math.floor

function mcl_mapgen.register_chunk_generator(callback_function, priority)
	nodes_chunk = nodes_chunk + 1
	node_chunk_queue[nodes_chunk] = {i = priority or DEFAULT_PRIORITY, f = callback_function}
	table.sort(node_chunk_queue, function(a, b) return (a.i <= b.i) end)
end
function mcl_mapgen.register_chunk_generator_lvm(callback_function, priority)
	lvm = lvm + 1
	lvm_chunk_queue[lvm_chunk] = {i = priority or DEFAULT_PRIORITY, f = callback_function}
	table.sort(lvm_chunk_queue, function(a, b) return (a.i <= b.i) end)
end
function mcl_mapgen.register_block_generator(callback_function, priority)
	block = block + 1
	nodes_block = nodes_block + 1
	node_block_queue[nodes_block] = {i = priority or DEFAULT_PRIORITY, f = callback_function}
	table.sort(node_block_queue, function(a, b) return (a.i <= b.i) end)
end
function mcl_mapgen.register_block_generator_lvm(callback_function, priority)
	block = block + 1
	lvm = lvm + 1
	lvm_block = lvm_block + 1
	lvm_block_queue[lvm_block] = {i = priority or DEFAULT_PRIORITY, f = callback_function}
	table.sort(lvm_block_queue, function(a, b) return (a.i <= b.i) end)
end

local storage = minetest.get_mod_storage()
local blocks = minetest.deserialize(		storage:get_string("mapgen_blocks") or "return {}") or {}
minetest.register_on_shutdown(function()	storage:set_string("mapgen_blocks", minetest.serialize(blocks)) end)

local vm_context-- here will be many references and flags, like: param2, light_data, heightmap, biomemap, heatmap, humiditymap, gennotify, write_lvm, write_param2, shadow
local data, data2, area
local current_blocks = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
	local minp, maxp, blockseed = minp, maxp, blockseed
	minetest_log("verbose", "[mcl_mapgen] New chunk: minp=" .. minetest.pos_to_string(minp) .. ", maxp=" .. minetest.pos_to_string(maxp) .. ", blockseed=" .. blockseed)

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")

	if lvm > 0 then
		vm_context = {lvm_param2_buffer = lvm_param2_buffer, vm = vm, emin = emin, emax = emax, minp = minp, maxp = maxp, blockseed = blockseed}
		data = vm:get_data(lvm_buffer)
		vm_context.data = data
		area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		vm_context.area = area
		for _, v in pairs(lvm_chunk_queue) do
			vm_context = v.f(vm_context)
		end
	end

	if block > 0 then
		local x0, y0, z0 = minp.x, minp.y, minp.z
		local bx0, by0, bz0 = math_floor(x0/BS), math_floor(y0/BS), math_floor(z0/BS)
		local x1, y1, z1, x2, y2, z2 = emin.x, emin.y, emin.z, emax.x, emax.y, emax.z
		local x, y, z = x1, y1, z1 -- iterate 7x7x7 mapchunk, {x,y,z} - first node pos. of mapblock
		local bx, by, bz -- block coords (in blocs)
		local box, boy, boz -- block offsets in chunks (in blocks)
		while x < x2 do
			bx = math_floor(x/BS)
			local block_pos_offset_removed = bx - offset
			box = block_pos_offset_removed % CS
			if not blocks[bx] then blocks[bx]={} end
			local total_mapgen_block_writes_through_x = (box > 0 and box < LAST_BLOCK) and 4 or 8
			while y < y2 do
				by = math_floor(y/BS)
				block_pos_offset_removed = by - offset
				boy = block_pos_offset_removed % CS
				if not blocks[bx][by] then blocks[bx][by]={} end
				local total_mapgen_block_writes_through_y = (boy > 0 and boy < LAST_BLOCK) and math_floor(total_mapgen_block_writes_through_x / 2) or total_mapgen_block_writes_through_x
				while z < z2 do
					bz = math_floor(z/BS)
					block_pos_offset_removed = bz - offset
					boz = block_pos_offset_removed % CS
					local total_mapgen_block_writes = (boz > 0 and boz < LAST_BLOCK) and math_floor(total_mapgen_block_writes_through_y / 2) or total_mapgen_block_writes_through_y
					local current_mapgen_block_writes = blocks[bx][by][bz] and (blocks[bx][by][bz] + 1) or 1
					if current_mapgen_block_writes == total_mapgen_block_writes then
						-- this block shouldn't be overwritten anymore, no need to keep it in memory
						blocks[bx][by][bz] = nil
						vm_context.seed = blockseed + box * 7 + boy * 243 + boz * 11931
						if lvm_block > 0 then
							vm_context.minp, vm_content.maxp = {x=x, y=y, z=z}, {x=x+LAST_NODE, y=y+LAST_NODE, z=z+LAST_NODE}
							for _, v in pairs(lvm_block_queue) do
								vm_context = v.f(vm_context)
							end
						end
						if nodes_block > 0 then
							current_blocks[#current_blocks+1] = { minp = {x=x, y=y, z=z}, maxp = {x=pos.x+LAST_NODE, y=pos.y+LAST_NODE, z=pos.z+LAST_NODE}, seed = seed }
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

	if vm_context.write then
		vm:set_data(data)
	end
	if vm_context.write_param2 then
		vm:set_param2_data(data2)
	end
	vm:calc_lighting(p1, p2, shadow)
	vm:write_to_map()
	vm:update_liquids()

	for _, v in pairs(node_chunk_queue) do
		v.f(minp, maxp, blockseed)
	end

	for i, b in pairs(current_blocks) do
		for _, v in pairs(node_block_queue) do
			v.f(b.minp, b.maxp, b.seed)
		end
		current_blocks[id] = nil
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

-- Calculate mapgen_edge_min/mapgen_edge_max
local function calculate_mapgen_basics()
	mcl_mapgen.CS		= math.max(1, tonumber(minetest.get_mapgen_setting("chunksize"))	or 5)
	mcl_mapgen.BS		= math.max(1, core.MAP_BLOCKSIZE					or 16)
	mcl_mapgen.LIMIT	= math.max(1, tonumber(minetest.get_mapgen_setting("mapgen_limit"))	or 31000)
	mcl_mapgen.MAX_LIMIT	= math.max(1, core.MAX_MAP_GENERATION_LIMIT				or 31000)
	mcl_mapgen.OFFSET	= - math.floor(mcl_mapgen.CS / 2)
	mcl_mapgen.OFFSET_NODES	= mcl_mapgen.OFFSET * mcl_mapgen.BS
	mcl_mapgen.CS_NODES	= mcl_mapgen.CS * mcl_mapgen.BS

	local central_chunk_min_pos = mcl_mapgen.OFFSET * mcl_mapgen.BS
	local central_chunk_max_pos = central_chunk_min_pos + mcl_mapgen.CS_NODES - 1

	local ccfmin = central_chunk_min_pos - mcl_mapgen.BS -- Fullminp/fullmaxp of central chunk, in nodes
	local ccfmax = central_chunk_max_pos + mcl_mapgen.BS

	local mapgen_limit_b = math.floor(math.min(mcl_mapgen.LIMIT, mcl_mapgen.MAX_LIMIT) / mcl_mapgen.BS)
	local mapgen_limit_min = - mapgen_limit_b	* mcl_mapgen.BS
	local mapgen_limit_max =  (mapgen_limit_b + 1)	* mcl_mapgen.BS - 1

	local numcmin = math.max(math.floor((ccfmin - mapgen_limit_min) / mcl_vars.chunk_size_in_nodes), 0) -- Number of complete chunks from central chunk
	local numcmax = math.max(math.floor((mapgen_limit_max - ccfmax) / mcl_vars.chunk_size_in_nodes), 0) -- fullminp/fullmaxp to effective mapgen limits.

	mcl_mapgen.EDGE_MIN = central_chunk_min_pos - numcmin * mcl_mapgen.CS_NODES
	mcl_mapgen.EDGE_MAX = central_chunk_max_pos + numcmax * mcl_mapgen.CS_NODES
end

local function coordinate_to_block(x)
	return math_floor(x / mcl_mapgen.BS)
end

local function coordinate_to_chunk(x)
	return math_floor((coordinate_to_block(x) - central_chunk_offset) / mcl_vars.chunksize)
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

calculate_mapgen_basics()

local k_positive = math.ceil(mcl_mapgen.MAX_LIMIT / mcl_vars.chunk_size_in_nodes)
local k_positive_z = k_positive * 2
local k_positive_y = k_positive_z * k_positive_z

function mcl_mapgen.get_chunk_number(pos) -- unsigned int
	local c = mcl_mapgen.pos_to_chunk(pos)
	return
		(c.y + k_positive) * k_positive_y +
		(c.z + k_positive) * k_positive_z +
		 c.x + k_positive
end

