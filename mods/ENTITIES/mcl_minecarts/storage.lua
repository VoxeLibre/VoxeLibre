local storage = core.get_mod_storage()
local mod = mcl_minecarts

-- Imports
local CART_BLOCK_SIZE = mod.CART_BLOCK_SIZE
assert(CART_BLOCK_SIZE)

local cart_data = {}
local cart_data_fail_cache = {}
local cart_ids = storage:get_keys()

local function get_cart_data(uuid)
	if cart_data[uuid] then return cart_data[uuid] end
	if cart_data_fail_cache[uuid] then return nil end

	local data = core.deserialize(storage:get_string("cart-"..uuid))
	if not data then
		cart_data_fail_cache[uuid] = true
		return nil
	else
		-- Repair broken data
		if not data.distance then data.distance = 0 end
		if data.distance == 0/0 then data.distance = 0 end
		if data.distance == -0/0 then data.distance = 0 end
		data.dir = vector.new(data.dir)
		data.connected_at = vector.new(data.connected_at)
		data.uuid = uuid
	end

	cart_data[uuid] = data
	return data
end
mod.get_cart_data = get_cart_data

-- Preload all cart data into memory
for _,id in pairs(cart_ids) do
	local uuid = string.sub(id,6)
	get_cart_data(uuid)
end

local function save_cart_data(uuid)
	if not cart_data[uuid] then return end
	local data = core.serialize(cart_data[uuid])
	storage:set_string("cart-"..uuid, data)
	--core.log("saved cart data for uuid "..uuid..": "..data)
end
mod.save_cart_data = save_cart_data

function mod.update_cart_data(data)
	local uuid = data.uuid
	cart_data[uuid] = data
	cart_data_fail_cache[uuid] = nil
	save_cart_data(uuid)
end
function mod.destroy_cart_data(uuid)
	storage:set_string("cart-"..uuid,"")
	cart_data[uuid] = nil
	cart_data_fail_cache[uuid] = true
end

function mod.carts()
	return pairs(cart_data)
end

function mod.find_carts_by_block_map(block_map)
	local cart_list = {}
	for _,data in pairs(cart_data) do
		if data and data.connected_at then
			local pos = mod.get_cart_position(data)
			local block = vector.floor(vector.divide(pos,CART_BLOCK_SIZE))
			if block_map[vector.to_string(block)] then
				cart_list[#cart_list + 1] = data
			end
		end
	end
	return cart_list
end

function mod.add_blocks_to_map(block_map, min_pos, max_pos)
	local min = vector.floor(vector.divide(min_pos, CART_BLOCK_SIZE))
	local max = vector.floor(vector.divide(max_pos, CART_BLOCK_SIZE)) + vector.new(1,1,1)
	for z = min.z,max.z do
		for y = min.y,max.y do
			for x = min.x,max.x do
				block_map[ vector.to_string(vector.new(x,y,z)) ] = true
			end
		end
	end
end

core.register_on_shutdown(function()
	for uuid,_ in pairs(cart_data) do
		save_cart_data(uuid)
	end
end)
