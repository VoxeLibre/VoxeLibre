vl_weaponry = {
	registered_tool_types = {},
	registered_tool_materials = {},
}

local modpath = core.get_modpath(core.get_current_modname())

---Handle a shovel being used to create or remove a grass path.
---@param itemstack ItemStack
---@param user ObjectRef
---@param pointed_thing pointed_thing
---@return ItemStack
function vl_weaponry.make_grass_path(itemstack, user, pointed_thing)
	local node = core.get_node(pointed_thing.under)
	if user and not user:get_player_control().sneak then
		local node_def = core.registered_nodes[node.name]
		if node_def and node_def.on_rightclick then
			return node_def.on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
		end
	end

	if pointed_thing.above.y < pointed_thing.under.y then return itemstack end

	local remove = core.get_item_group(node.name, "path_remove_possible") == 1
		and user:get_player_control().sneak
	local create = core.get_item_group(node.name, "path_creation_possible") == 1
		and not user:get_player_control().sneak
	if not remove and not create then return itemstack end

	local above = vector.offset(pointed_thing.under, 0, 1, 0)
	local above_name = core.get_node(above).name
	if above_name == "ignore" or mcl_util.is_solid_block(above_name) then return itemstack end
	if core.is_protected(pointed_thing.under, user:get_player_name()) then
		core.record_protection_violation(pointed_thing.under, user:get_player_name())
		return itemstack
	end
	if not core.is_creative_enabled(user:get_player_name()) then
		local wear = mcl_autogroup.get_wear(itemstack:get_name(), "shovely")
		if wear then
			itemstack:add_wear(wear)
			tt.reload_itemstack_description(itemstack)
		end
	end
	core.sound_play({ name = "default_grass_footstep", gain = 1 },
		{ pos = above, max_hear_distance = 16 }, true)
	core.swap_node(pointed_thing.under, { name = remove and "mcl_core:dirt" or "mcl_core:grass_path" })
	return itemstack
end

---Handle an axe being used to strip a node with an `_mcl_stripped_variant`.
---@param itemstack ItemStack
---@param user ObjectRef
---@param pointed_thing pointed_thing
---@return ItemStack?
function vl_weaponry.make_stripped_trunk(itemstack, user, pointed_thing)
	if pointed_thing.type ~= "node" then return end
	local node = core.get_node(pointed_thing.under)
	local node_def = core.registered_nodes[node.name]
	if not node_def then
		core.log("warning", "Trying to right click with an axe the unregistered node: " .. node.name)
		return
	end
	if not user:get_player_control().sneak and node_def.on_rightclick then
		return core.item_place(itemstack, user, pointed_thing)
	end
	if core.is_protected(pointed_thing.under, user:get_player_name()) then
		core.record_protection_violation(pointed_thing.under, user:get_player_name())
		return itemstack
	end
	if not node_def._mcl_stripped_variant then return itemstack end

	core.swap_node(pointed_thing.under, { name = node_def._mcl_stripped_variant, param2 = node.param2 })
	if core.get_item_group(node.name, "waxed") ~= 0 then
		awards.unlock(user:get_player_name(), "mcl:wax_off")
	end
	if not core.is_creative_enabled(user:get_player_name()) then
		local wear = mcl_autogroup.get_wear(itemstack:get_name(), "axey")
		if wear then
			itemstack:add_wear(wear)
			tt.reload_itemstack_description(itemstack)
		end
	end
	return itemstack
end

---Handle shears being used to carve a pumpkin.
---@param itemstack ItemStack
---@param user ObjectRef
---@param pointed_thing pointed_thing
---@return ItemStack
function vl_weaponry.carve_pumpkin(itemstack, user, pointed_thing)
	local node = core.get_node(pointed_thing.under)
	if user and not user:get_player_control().sneak then
		local node_def = core.registered_nodes[node.name]
		if node_def and node_def.on_rightclick then
			return node_def.on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
		end
	end
	if pointed_thing.above.y ~= pointed_thing.under.y or node.name ~= "mcl_farming:pumpkin" then
		return itemstack
	end
	if not core.is_creative_enabled(user:get_player_name()) then
		local wear = mcl_autogroup.get_wear(itemstack:get_name(), "shearsy")
		if wear then
			itemstack:add_wear(wear)
			tt.reload_itemstack_description(itemstack)
		end
	end
	core.sound_play({ name = "default_grass_footstep", gain = 1 }, { pos = pointed_thing.above }, true)
	local dir = vector.subtract(pointed_thing.under, pointed_thing.above)
	core.set_node(pointed_thing.under, {
		name = "mcl_farming:pumpkin_face",
		param2 = core.dir_to_facedir(dir),
	})
	core.add_item(pointed_thing.above, "mcl_farming:pumpkin_seeds 4")
	return itemstack
end

dofile(modpath .. "/api.lua")
dofile(modpath .. "/materials.lua")
dofile(modpath .. "/hammer.lua")
dofile(modpath .. "/spear.lua")
dofile(modpath .. "/scythe.lua")
