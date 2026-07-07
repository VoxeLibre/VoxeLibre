vl_tools.axe = vl_tools.axe or {}

local S = core.get_translator("mcl_tools")
local wield_scale = mcl_vars.tool_wield_scale

local axe_longdesc = S("An axe is your tool of choice to cut down trees, wood-based blocks and other blocks. Axes deal a lot of damage as well, but they are rather slow.")

-- make_stripped_trunk is used by axes to strip wood logs and strip waxed nodes (oxidation related) on right click.
function vl_tools.axe.make_stripped_trunk(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then return end

	local node = core.get_node(pointed_thing.under)
	local node_name = node.name

	local noddef = core.registered_nodes[node_name]

	if not noddef then
		core.log("warning", "Trying to right click with an axe the unregistered node: " .. tostring(node_name))
		return
	end

	if not placer:get_player_control().sneak and noddef.on_rightclick then
		return core.item_place(itemstack, placer, pointed_thing)
	end
	if core.is_protected(pointed_thing.under, placer:get_player_name()) then
		core.record_protection_violation(pointed_thing.under, placer:get_player_name())
		return itemstack
	end

	if noddef._mcl_stripped_variant == nil then
		return itemstack
	else
		core.swap_node(pointed_thing.under, {name=noddef._mcl_stripped_variant, param2=node.param2})
		if core.get_item_group(node_name, "waxed") ~= 0 then
			awards.unlock(placer:get_player_name(), "mcl:wax_off")
		end
		if not core.is_creative_enabled(placer:get_player_name()) then
			-- Add wear (as if digging a axey node)
			local toolname = itemstack:get_name()
			local wear = mcl_autogroup.get_wear(toolname, "axey")
			if wear then
				itemstack:add_wear(wear)
				tt.reload_itemstack_description(itemstack) -- update tooltip
			end
		end
	end
	return itemstack
end

function vl_tools.axe.register(name, def)
	assert(type(name) == "string" and name ~= "", "vl_tools.axe.register requires a tool name")
	assert(def, "vl_tools.axe.register requires a definition")
	assert(type(def.icon) == "string" and def.icon ~= "", "vl_tools.axe.register requires def.icon")
	assert(type(def.repair_material) == "string" and def.repair_material ~= "", "vl_tools.axe.register requires def.repair_material")

	def = table.copy(def)

	local tool_def = vl_tools.build_tool_def(def, {
		_doc_items_longdesc = axe_longdesc,
		wield_scale = wield_scale,
		groups = {
			tool = 1,
			axe = 1,
		},
		on_place = vl_tools.axe.make_stripped_trunk,
		sound = { breaks = "default_tool_breaks" },
		_mcl_toollike_wield = true,
	})

	core.register_tool(name, tool_def)

	if not def.no_craft then
		core.register_craft({
			output = name,
			recipe = {
				{def.repair_material, def.repair_material},
				{def.repair_material, "mcl_core:stick"},
				{"", "mcl_core:stick"},
			}
		})
		core.register_craft({
			output = name,
			recipe = {
				{def.repair_material, def.repair_material},
				{"mcl_core:stick", def.repair_material},
				{"mcl_core:stick", ""},
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
