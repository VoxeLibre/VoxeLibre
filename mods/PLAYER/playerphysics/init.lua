playerphysics = {}

local function calculate_attribute_product(player, attribute)
	local a = minetest.deserialize(player:get_attribute("playerphysics:physics"))
	local product = 1
	if a == nil or a[attribute] == nil then
		return product
	end
	local factors = a[attribute]
	if type(factors) == "table" then
		for _, factor in pairs(factors) do
			product = product * factor
		end
	end
	return product
end

function playerphysics.add_physics_factor(player, attribute, id, value)
	local a = minetest.deserialize(player:get_attribute("playerphysics:physics"))
	if a == nil then
		a = { [attribute] = { [id] = value } }
	elseif a[attribute] == nil then
		a[attribute] = { [id] = value }
	else
		a[attribute][id] = value
	end
	player:set_attribute("playerphysics:physics", minetest.serialize(a))
	local raw_value = calculate_attribute_product(player, attribute)
	player:set_physics_override({[attribute] = raw_value})
end

function playerphysics.remove_physics_factor(player, attribute, id)
	local a = minetest.deserialize(player:get_attribute("playerphysics:physics"))
	if a == nil or a[attribute] == nil then
		-- Nothing to remove
		return
	else
		a[attribute][id] = nil
	end
	player:set_attribute("playerphysics:physics", minetest.serialize(a))
	local raw_value = calculate_attribute_product(player, attribute)
	player:set_physics_override({[attribute] = raw_value})
end
