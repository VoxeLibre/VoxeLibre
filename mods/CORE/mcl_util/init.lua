mcl_util = {}

-- Based on minetest.rotate_and_place

--[[
Attempt to predict the desired orientation of the pillar-like node
defined by `itemstack`, and place it accordingly in one of 3 possible
orientations (X, Y or Z).

Stacks are handled normally if the `infinitestacks`
field is false or omitted (else, the itemstack is not changed).
* `invert_wall`: if `true`, place wall-orientation on the ground and ground-
  orientation on wall

This function is a simplified version of minetest.rotate_and_place.
The Minetest function is seen as inappropriate because this includes mirror
images of possible orientations, causing problems with pillar shadings.
]]
function mcl_util.rotate_axis_and_place(itemstack, placer, pointed_thing, infinitestacks, invert_wall)
	local unode = minetest.get_node_or_nil(pointed_thing.under)
	if not unode then
		return
	end
	local undef = minetest.registered_nodes[unode.name]
	if undef and undef.on_rightclick then
		undef.on_rightclick(pointed_thing.under, unode, placer,
				itemstack, pointed_thing)
		return
	end
	local fdir = minetest.dir_to_facedir(placer:get_look_dir())
	local wield_name = itemstack:get_name()

	local above = pointed_thing.above
	local under = pointed_thing.under
	local is_x = (above.x ~= under.x)
	local is_y = (above.y ~= under.y)
	local is_z = (above.z ~= under.z)

	local anode = minetest.get_node_or_nil(above)
	if not anode then
		return
	end
	local pos = pointed_thing.above
	local node = anode

	if undef and undef.buildable_to then
		pos = pointed_thing.under
		node = unode
	end

	if minetest.is_protected(pos, placer:get_player_name()) then
		minetest.record_protection_violation(pos, placer:get_player_name())
		return
	end

	local ndef = minetest.registered_nodes[node.name]
	if not ndef or not ndef.buildable_to then
		return
	end

	local p2
	if is_y then
		if invert_wall then
			if fdir == 3 or fdir == 1 then
				p2 = 12
			else
				p2 = 6
			end
		end
	elseif is_x then
		if invert_wall then
			p2 = 0
		else
			p2 = 12
		end
	elseif is_z then
		if invert_wall then
			p2 = 0
		else
			p2 = 6
		end
	end
	minetest.set_node(pos, {name = wield_name, param2 = p2})

	if not infinitestacks then
		itemstack:take_item()
		return itemstack
	end
end

-- Wrapper of above function for use as `on_place` callback (Recommended).
-- Similar to minetest.rotate_node.
function mcl_util.rotate_axis(itemstack, placer, pointed_thing)
	mcl_util.rotate_axis_and_place(itemstack, placer, pointed_thing,
		core.setting_getbool("creative_mode"),
		placer:get_player_control().sneak)
	return itemstack
end

-- Moves a single item from one inventory to another
--- source_inventory: Inventory to take the item from
--- source_list: List name of the source inventory from which to take the item
--- source_stack_id: The inventory position ID of the source inventory to take the item from (-1 for first occupied slot)
--- destination_inventory: Put item into this inventory
--- destination_list: List name of the destination inventory to which to put the item into

-- Returns true on success and false on failure
-- Possible failures: No item in source slot, destination inventory full
function mcl_util.move_item(source_inventory, source_list, source_stack_id, destination_inventory, destination_list)
	if source_stack_id == -1 then
		source_stack_id = mcl_util.get_first_occupied_inventory_slot(source_inventory, source_list)
		if source_stack_id == nil then
			return false
		end
	end

	if not source_inventory:is_empty(source_list) then
		local stack = source_inventory:get_stack(source_list, source_stack_id)
		local item = stack:get_name()
		if not stack:is_empty() then
			if not destination_inventory:room_for_item(destination_list, item) then
				return false
			end
			stack:take_item()
			source_inventory:set_stack(source_list, source_stack_id, stack)
			destination_inventory:add_item(destination_list, item)
			return true
		end
	end
	return false
end

-- Moves a single item from one container node into another.
--- source_pos: Position ({x,y,z}) of the node to take the item from
--- source_list: List name of the source inventory from which to take the item
--- source_stack_id: The inventory position ID of the source inventory to take the item from (-1 for first occupied slot)
--- destination_pos: Position ({x,y,z}) of the node to put the item into
--- destination_list: (optional) list name of the destination inventory. If not set, the main or source list will be used
-- Returns true on success and false on failure
function mcl_util.move_item_container(source_pos, source_list, source_stack_id, destination_pos, destination_list)
	local smeta = minetest.get_meta(source_pos)
	local dmeta = minetest.get_meta(destination_pos)

	local sinv = smeta:get_inventory()
	local dinv = dmeta:get_inventory()

	local snodedef = minetest.registered_nodes[minetest.get_node(source_pos).name]
	local dnodedef = minetest.registered_nodes[minetest.get_node(destination_pos).name]

	if source_stack_id == -1 then
		source_stack_id = mcl_util.get_first_occupied_inventory_slot(sinv, source_list)
		if source_stack_id == nil then
			return false
		end
	end

	-- If it's a container, put it into the container
	if dnodedef.groups.container then
		-- Automatically select a destination list if omitted
		if not destination_list then
			if dnodedef.groups.container == 2 or snodedef.groups.continer == 3 then
				destination_list = "main"
			elseif dnodedef.groups.container == 3 then
				local stack = sinv:get_stack(source_list, source_stack_id)
				local def = minetest.registered_nodes[stack:get_name()]
				if stack and (not stack:is_empty()) and (not (def and def.groups and def.groups.shulker_box)) then
					destination_list = "main"
				end
			elseif dnodedef.groups.container == 4 then
				destination_list = "src"
			end
		end
		if destination_list then
			return mcl_util.move_item(sinv, source_list, source_stack_id, dinv, destination_list)
		end
	end
	return false
end

-- Returns the ID of the first non-empty slot in the given inventory list
-- or nil, if inventory is empty.
function mcl_util.get_first_occupied_inventory_slot(inventory, listname)
	for i=1, inventory:get_size(listname) do
		local stack = inventory:get_stack(listname, i)
		if not stack:is_empty() then
			return i
		end
	end
	return nil
end

-- Returns true if item (itemstring or ItemStack) can be used as a furnace fuel.
-- Returns false otherwise
function mcl_util.is_fuel(item)
	return minetest.get_craft_result({method="fuel", width=1, items={item}}).time ~= 0
end

-- For a given position, returns a 2-tuple:
-- 1st return value: true if pos is in void
-- 2nd return value: true if it is in the deadly part of the void
function mcl_util.is_in_void(pos)
	local void, void_deadly
	void = pos.y < mcl_vars.mg_overworld_min
	void_deadly = pos.y < mcl_vars.mg_overworld_min - 64
	return void, void_deadly
end

-- Here come 2 simple converter functions which are important for map generators and mob spawning

-- Takes an Y coordinate as input and returns:
-- 1) The corresponding Minecraft layer (can be nil if void)
-- 2) The corresponding Minecraft dimension ("overworld", "nether" or "end") or "void" if it is in the void
-- If the Y coordinate is not located in any dimension, it will return:
--     nil, "void"
function mcl_util.y_to_layer(y)
	if y >= mcl_vars.mg_overworld_min then
		return y - mcl_vars.mg_overworld_min, "overworld"
	else
		return nil, "void"
	end
end

-- Takes a Minecraft layer and a “dimension” name
-- and returns the corresponding Y coordinate for
-- MineClone 2.
-- minecraft_dimension parameter is ignored at the moment
-- TODO: Implement dimensions
function mcl_util.layer_to_y(layer, minecraft_dimension)
	return layer + mcl_vars.mg_overworld_min
end

-- Returns a on_place function for plants
-- * condition: function(pos, node)
--    * A function which is called by the on_place function to check if the node can be placed
--    * Must return true, if placement is allowed, false otherwise
--    * pos, node: Position and node table of plant node
function mcl_util.generate_on_place_plant_function(condition)
	return function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			-- no interaction possible with entities
			return itemstack
		end

		-- Call on_rightclick if the pointed node defines it
		local node = minetest.get_node(pointed_thing.under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end

		local place_pos
		local def_under = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]
		local def_above = minetest.registered_nodes[minetest.get_node(pointed_thing.above).name]
		if def_under.buildable_to then
			place_pos = pointed_thing.under
		elseif def_above.buildable_to then
			place_pos = pointed_thing.above
		else
			return itemstack
		end

		-- Check placement rules
		if (condition(place_pos, node) == true) then
			local idef = itemstack:get_definition()
			local new_itemstack, success = minetest.item_place_node(itemstack, placer, pointed_thing)

			if success then
				if idef.sounds and idef.sounds.place then
					minetest.sound_play(idef.sounds.place, {pos=above, gain=1})
				end
			end
			itemstack = new_itemstack
		end

		return itemstack
	end
end


