local storage = minetest.get_mod_storage()
local mod = mcl_lightning_rods
local BLOCK_SIZE = 64

-- Helper functions
function vector_floor(v)
	return vector.new( math.floor(v.x), math.floor(v.y), math.floor(v.z) )
end
function vector_min(a,b)
	return vector.new( math.min(a.x,b.x), math.min(a.y,b.y), math.min(a.z,b.z) )
end
function vector_max(a,b)
	return vector.new( math.max(a.x,b.x), math.max(a.y,b.y), math.max(a.z,b.z) )
end

local function read_voxel_area(pos1, pos2)
	local vm = minetest.get_voxel_manip()
	local minp, maxp = vm:read_from_map(pos1, pos2)
	local data = vm:get_data()
	local area = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})

	return vm,data,area
end

local function load_index(x,y,z)
	local idx_key = string.format("%d-%d,%d,%d",BLOCK_SIZE,x,y,z)
	local idx_str = storage:get_string(idx_key)
	if idx_str and idx_str ~= "" then
		local idx = minetest.deserialize(idx_str)
		return idx or {}
	end

	return {}
end
local function load_index_vector(pos)
	return load_index(pos.x,pos.y,pos.z)
end

local function save_index(x,y,z, idx)
	local idx_str = minetest.serialize(idx)
	local idx_key = string.format("%d-%d,%d,%d",BLOCK_SIZE,x,y,z)
	storage:set_string(idx_key, idx_str)
end
local function save_index_vector(pos, idx)
	return save_index(pos.x,pos.y,pos.z, idx)
end

-- Remove duplicates and verify all locations have a lightning attractor present
local function clean_index(idx, drop)
	local new_idx = {}
	local exists = {}
	for _,p in ipairs(idx) do
		local key = string.format("%d,%d,%d",p.x,p.y,p.z)
		if not exists[key] then
			exists[key] = true

			local node = minetest.get_node(p)
			if minetest.get_item_group(node.name, "attracts_lightning") ~= 0 or (drop and vector.distance(p,drop) < 0.1 ) then
				new_idx[#new_idx + 1] = p
			end
		end
	end
	return new_idx
end

function mod.find_attractors_in_area(pos1, pos2)
	-- Normalize the search area into large, regular blocks
	local pos1_r = vector_floor(pos1 / BLOCK_SIZE)
	local pos2_r = vector_floor(pos2 / BLOCK_SIZE)
	local min = vector_min(pos1_r, pos2_r)
	local max = vector_max(pos1_r, pos2_r)

	local results = {}
	for z = min.z,max.z do
		for y = min.y,max.y do
			for x = min.x,max.x do
				local idx = load_index(x,y,z)

				-- Make sure every indexed position actually has a lightning attractor present
				for _,pos in ipairs(idx) do
					local node = minetest.get_node(pos)
					if minetest.get_item_group(node.name, "attracts_lightning") ~= 0 then
						results[#results + 1] = pos
					end
				end
			end
		end
	end
	return results
end
local function find_closest_position_in_list(pos, list)
	local dist = nil
	local best = nil
	for _,p in ipairs(list) do
		local p_dist = vector.distance(p,pos)
		if not dist or p_dist < dist then
			dist = p_dist
			best = p
		end
	end
	return best
end

function mod.find_closest_attractor(pos, search_size)
	local attractor_positions = mod.find_attractors_in_area(
		vector.offset(pos, -search_size, -search_size, -search_size),
		vector.offset(pos,  search_size,  search_size,  search_size)
	)
	return find_closest_position_in_list(pos, attractor_positions)
end

function mod.unregister_lightning_attractor(pos)
	-- Verify the node no longer attracts lightning
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "attracts_lightning") ~= 0 then return end

	-- Get the existing index data (if any)
	local pos_r = vector_floor(pos / BLOCK_SIZE)
	local idx = load_index_vector(pos_r)

	-- Clean the index and drop this node
	idx = clean_index(idx, pos)
	save_index_vector(pos_r, idx)
end
function mod.register_lightning_attractor(pos)
	-- Verify the node attracts lightning
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "attracts_lightning") == 0 then return end

	-- Get the existing index data (if any)
	local pos_r = vector_floor(pos / BLOCK_SIZE)
	local idx = load_index_vector(pos_r)
	for _,p in ipairs(idx) do
		-- Don't need to change anything if the rod is already registered
		if vector.distance(p,pos) < 0.1 then return end
	end

	-- Add and save the rod position
	idx[#idx + 1] = pos

	-- Clean and save the index data
	clean_index(idx)
	save_index_vector(pos_r, idx)
end

-- Constants used for content id index
local IS_ATTRACTOR = {}
local IS_NOT_ATTRACTOR = {}
function mod.index_block(pos)
	local pos_r = vector_floor(pos1 / BLOCK_SIZE)
	local pos1 = vector.multiply(pos_r,BLOCK_SIZE)
	local pos2 = vector.offset(pos,BLOCK_SIZE - 1,BLOCK_SIZE - 1,BLOCK_SIZE - 1)

	-- We are completely rebuilding the index data so there is no nead to load
	-- the existing data
	local idx = {}

	-- Setup voxel manipulator
	local _,data,area = read_voxel_area()

	-- Indexes to speed things up
	local cid_attractors = {}

	-- Iterate over the area and look for lightning attractors
	local minx = pos1.x
	local maxx = pos1.x
	for z = pos1.z,pos2.z do
		for y = pos1.y,pos2.y do
			for x = minx,maxx do
				local vi = area:index(x,y,z)
				local cid = data[vi]
				local attr = cid_attractors[cid]
				if attr then
					if attr == IS_ATTRACTOR then
						idx[#idx + 1] = vector.new(x,y,z)
					end
				else
					-- Lookup data and cache for later
					local name = minetest.get_name_from_content_id(cid)
					if minetest.get_item_group(name, "attracts_lightning") then
						cid_attractors = IS_ATTRACTOR
						idx[#idx + 1] = vector.new(x,y,z)
					else
						cid_attractors = IS_NOT_ATTRACTOR
					end
				end
			end
		end
	end

	-- Save for later use
	save_index_vector(pos_r, idx)
end

