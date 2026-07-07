vl_tools.shovel = vl_tools.shovel or {}

local S = core.get_translator("mcl_tools")
local wield_scale = mcl_vars.tool_wield_scale

local shovel_longdesc = S("Shovels are tools for digging coarse blocks, such as dirt, sand and gravel. They can also be used to turn grass blocks to grass paths. Shovels can be used as weapons, but they are very weak.")
local shovel_use = S("To turn a grass block into a grass path, hold the shovel in your hand, then use (rightclick) the top or side of a grass block. This only works when there's air above the grass block.")

function vl_tools.shovel.make_grass_path(itemstack, placer, pointed_thing)
	local node = core.get_node(pointed_thing.under)
	if placer and not placer:get_player_control().sneak then
		if core.registered_nodes[node.name] and core.registered_nodes[node.name].on_rightclick then
			return core.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
		end
	end

	if pointed_thing.above.y < pointed_thing.under.y then
		return itemstack
	end

	if core.get_item_group(node.name, "path_remove_possible") == 1 and placer:get_player_control().sneak then
		local above = table.copy(pointed_thing.under)
		above.y = above.y + 1
		if core.get_node(above).name == "air" then
			if core.is_protected(pointed_thing.under, placer:get_player_name()) then
				core.record_protection_violation(pointed_thing.under, placer:get_player_name())
				return itemstack
			end

			if not core.is_creative_enabled(placer:get_player_name()) then
				local toolname = itemstack:get_name()
				local wear = mcl_autogroup.get_wear(toolname, "shovely")
				if wear then
					itemstack:add_wear(wear)
					tt.reload_itemstack_description(itemstack)
				end
			end
			core.sound_play({name = "default_grass_footstep", gain = 1}, {pos = above, max_hear_distance = 16}, true)
			core.swap_node(pointed_thing.under, {name = "mcl_core:dirt"})
		end
	end

	if core.get_item_group(node.name, "path_creation_possible") == 1 and not placer:get_player_control().sneak then
		local above = table.copy(pointed_thing.under)
		above.y = above.y + 1
		if core.get_node(above).name == "air" then
			if core.is_protected(pointed_thing.under, placer:get_player_name()) then
				core.record_protection_violation(pointed_thing.under, placer:get_player_name())
				return itemstack
			end

			if not core.is_creative_enabled(placer:get_player_name()) then
				local toolname = itemstack:get_name()
				local wear = mcl_autogroup.get_wear(toolname, "shovely")
				if wear then
					itemstack:add_wear(wear)
					tt.reload_itemstack_description(itemstack)
				end
			end
			core.sound_play({name = "default_grass_footstep", gain = 1}, {pos = above, max_hear_distance = 16}, true)
			core.swap_node(pointed_thing.under, {name = "mcl_core:grass_path"})
		end
	end
	return itemstack
end

function vl_tools.shovel.register(name, def)
	assert(type(name) == "string" and name ~= "", "vl_tools.shovel.register requires a tool name")
	assert(def, "vl_tools.shovel.register requires a definition")
	assert(type(def.icon) == "string" and def.icon ~= "", "vl_tools.shovel.register requires def.icon")
	assert(type(def.repair_material) == "string" and def.repair_material ~= "", "vl_tools.shovel.register requires def.repair_material")

	def = table.copy(def)

	local tool_def = vl_tools.build_tool_def(def, {
		_doc_items_longdesc = shovel_longdesc,
		_doc_items_usagehelp = shovel_use,
		wield_scale = wield_scale,
		groups = {
			tool = 1,
			shovel = 1,
		},
		on_place = vl_tools.shovel.make_grass_path,
		sound = { breaks = "default_tool_breaks" },
		_mcl_toollike_wield = true,
	})

	core.register_tool(name, tool_def)

	if not def.no_craft then
		core.register_craft({
			output = name,
			recipe = {
				{def.repair_material},
				{"mcl_core:stick"},
				{"mcl_core:stick"},
			}
		})
	end

	if def.fuel_burntime then
		core.register_craft({
			type = "fuel",
			recipe = name,
			burntime = def.fuel_burntime,
		})
	end

	if def.cook_result then
		core.register_craft({
			type = "cooking",
			output = def.cook_result,
			recipe = name,
			cooktime = def.cooktime or 10,
		})
	end
end
