local storage = minetest.get_mod_storage()
local mod = mcl_minecarts

local cart_data = {}
local cart_data_fail_cache = {}

function mod.get_cart_data(uuid)
	if cart_data[uuid] then return cart_data[uuid] end
	if cart_data_fail_cache[uuid] then return nil end

	local data = minetest.deserialize(storage:get_string("cart-"..uuid))
	if not data then
		cart_data_fail_cache[uuid] = true
		return nil
	end

	cart_data[uuid] = data
	return data
end
local function save_cart_data(uuid)
	if not cart_data[uuid] then return end
	storage:set_string("cart-"..uuid,minetest.serialize(cart_data[uuid]))
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

