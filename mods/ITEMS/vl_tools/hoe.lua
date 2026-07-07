vl_tools.hoe = vl_tools.hoe or {}

local S = core.get_translator("mcl_farming")
local wield_scale = mcl_vars.tool_wield_scale

local hoe_tt = S("Turns block into farmland")
local hoe_longdesc = S("Hoes are essential tools for growing crops. They are used to create farmland in order to plant seeds on it. Hoes can also be used as very weak weapons in a pinch.")
local hoe_usagehelp = S("Use the hoe on a cultivatable block (by rightclicking it) to turn it into farmland. Dirt, grass blocks and grass paths are cultivatable blocks. Using a hoe on coarse dirt turns it into dirt.")

function vl_tools.hoe.create_soil(pos)
	if pos == nil then
		return false
	end
	local node = core.get_node(pos)
	local name = node.name
	local above = core.get_node({x = pos.x, y = pos.y + 1, z = pos.z})
	if core.get_item_group(name, "cultivatable") == 2 then
		if above.name == "air" then
			node.name = "mcl_farming:soil"
			core.set_node(pos, node)
			core.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5}, true)
			return true
		end
	elseif core.get_item_group(name, "cultivatable") == 1 then
		if above.name == "air" then
			node.name = "mcl_core:dirt"
			core.set_node(pos, node)
			core.sound_play("default_dig_crumbly", {pos = pos, gain = 0.6}, true)
			return true
		end
	end
	return false
end

function vl_tools.hoe.on_place_function(wear_divisor)
	return function(itemstack, user, pointed_thing)
		local node = core.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if core.registered_nodes[node.name] and core.registered_nodes[node.name].on_rightclick then
				return core.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		if core.is_protected(pointed_thing.under, user:get_player_name()) then
			core.record_protection_violation(pointed_thing.under, user:get_player_name())
			return itemstack
		end

		if vl_tools.hoe.create_soil(pointed_thing.under) then
			if not core.is_creative_enabled(user:get_player_name()) then
				itemstack:add_wear(65535 / wear_divisor)
				tt.reload_itemstack_description(itemstack)
			end
			return itemstack
		end
	end
end

local function get_hoe_uses(def)
	local diggroups = def._mcl_diggroups or {}
	local hoey = diggroups.hoey or {}
	return hoey.uses
end

function vl_tools.hoe.register(name, def)
	assert(type(name) == "string" and name ~= "", "vl_tools.hoe.register requires a tool name")
	assert(def, "vl_tools.hoe.register requires a definition")
	assert(type(def.icon) == "string" and def.icon ~= "", "vl_tools.hoe.register requires def.icon")
	assert(type(def.repair_material) == "string" and def.repair_material ~= "", "vl_tools.hoe.register requires def.repair_material")

	def = table.copy(def)

	local tool_def = vl_tools.build_tool_def(def, {
		_tt_help = hoe_tt,
		_doc_items_longdesc = hoe_longdesc,
		_doc_items_usagehelp = hoe_usagehelp,
		wield_scale = wield_scale,
		on_place = vl_tools.hoe.on_place_function(get_hoe_uses(def)),
		groups = {
			tool = 1,
			hoe = 1,
		},
		_mcl_toollike_wield = true,
	})

	core.register_tool(name, tool_def)

	if not def.no_craft then
		core.register_craft({
			output = name,
			recipe = {
				{def.repair_material, def.repair_material},
				{"", "mcl_core:stick"},
				{"", "mcl_core:stick"},
			}
		})
		core.register_craft({
			output = name,
			recipe = {
				{def.repair_material, def.repair_material},
				{"mcl_core:stick", ""},
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
