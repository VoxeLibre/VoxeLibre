mcl_playerphysics = {}

local function calculate_physic_product(player, physic)
	local a = minetest.deserialize(player:get_attribute("mcl_playerphysics:physics"))
	local product = 1
	if a == nil or a[physic] == nil then
		return product
	end
	local factors = a[physic]
	if type(factors) == "table" then
		for id, factor in pairs(factors) do
			product = product * factor
		end
	end
	return product
end

function mcl_playerphysics.add_physics_factor(player, physic, id, value)
	local a = minetest.deserialize(player:get_attribute("mcl_playerphysics:physics"))
	if a == nil then
		a = { [physic] = { [id] = value } }
	elseif a[physic] == nil then
		a[physic] = { [id] = value }
	else
		a[physic][id] = value
	end
	player:set_attribute("mcl_playerphysics:physics", minetest.serialize(a))
	local raw_value = calculate_physic_product(player, physic)
	player:set_physics_override({[physic] = raw_value})
end

function mcl_playerphysics.remove_physics_factor(player, physic, id)
	local a = minetest.deserialize(player:get_attribute("mcl_playerphysics:physics"))
	if a == nil or a[physic] == nil then
		-- Nothing to remove
		return
	else
		a[physic][id] = nil
	end
	player:set_attribute("mcl_playerphysics:physics", minetest.serialize(a))
	local raw_value = calculate_physic_product(player, physic)
	player:set_physics_override({[physic] = raw_value})
end
