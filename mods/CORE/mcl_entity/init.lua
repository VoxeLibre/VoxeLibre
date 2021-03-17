MCLEntity = class(MCLObject)

MCLEntity:__getter("meta", MCLMetadata)

local last_inv_id = 0

MCLEntity:__getter("inventory", function(self)
	local info = self.inventory_info
	if not info then
		return
	end
	self.inventory_id = "mcl_entity:" .. last_inv_id
	last_inv_id = last_inv_id + 1
	local inv = minetest.create_detached_inventory(self.inventory_id, self.inventory_callbacks)
	for list, size in pairs(data.sizes) do
		inv:set_size(list, size)
	end
	for list, liststr in pairs(data.lists) do
		inv:set_list(list, liststr)
	end
	return inv
end)

function MCLEntity:on_activate(staticdata)
	local data = minetest.deserialize(staticdata)
	if data then
		self:meta():from_table(data)
		self.inventory_info = data.inventory
	end
end

function MCLEntity:get_staticdata()
	local data = self:meta():to_table()
	local inventory_info = self.inventory_info

	if inventory_info then
		data.inventory = {
			sizes = inventory_info.sizes,
			lists = self:inventory():get_lists()
		}
	end

	return minetest.serialize(data)
end

function MCLEntity:calculate_knockback(...)
	return minetest.calculate_knockback(self.object, ...)
end

function MCLEntity:on_punch(...)
	hp = MCLObject.on_punch(self, ...)

	self.damage_info.info.knockback = self:calculate_knockback(...)
end

function MCLEntity:on_damage(hp_change, source, info)
	MCLObject.on_damage(self, hp_change, source, info)

	if info.knockback then
		self:add_velocity(info.knockback)
	end
end
