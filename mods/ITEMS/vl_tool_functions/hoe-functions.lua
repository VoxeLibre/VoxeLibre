
--HOE FUNCTIONS

--create_soil turns dirt to soil and soil to dirt based on node group definitions.
local function create_soil(pos, inv)
	if pos == nil then
		return false
	end
	local node = minetest.get_node(pos)
	local name = node.name
	local above = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
	if minetest.get_item_group(name, "cultivatable") == 2 then
		if above.name == "air" then
			node.name = "mcl_farming:soil"
			minetest.set_node(pos, node)
			minetest.sound_play("default_dig_crumbly", { pos = pos, gain = 0.5 }, true)
			return true
		end
	elseif minetest.get_item_group(name, "cultivatable") == 1 then
		if above.name == "air" then
			node.name = "mcl_core:dirt"
			minetest.set_node(pos, node)
			minetest.sound_play("default_dig_crumbly", { pos = pos, gain = 0.6 }, true)
			return true
		end
	end
	return false
end

-- hoe_on_place_function is the function that hoes call each time they are right clicked (e.g from mcl_farming	on_place = hoe_on_place_function(uses.wood or 60),). Layers in additional checks and handles triggring the tools item wear.
local hoe_on_place_function = function(wear_divisor)
	return function(itemstack, user, pointed_thing)
		-- Call on_rightclick if the pointed node defines it
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		if minetest.is_protected(pointed_thing.under, user:get_player_name()) then
			minetest.record_protection_violation(pointed_thing.under, user:get_player_name())
			return itemstack
		end

		if create_soil(pointed_thing.under, user:get_inventory()) then
			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:add_wear(65535/wear_divisor)
				tt.reload_itemstack_description(itemstack) -- update tooltip
			end
			return itemstack
		end
	end
end

