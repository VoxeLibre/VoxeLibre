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
			dig_speed_class = def.dig_speed_class,
			enchantability = def.enchantability,
		},
		tool_capabilities = {
			full_punch_interval = def.full_punch_interval,
			max_drop_level = def.max_drop_level,
			damage_groups = { fleshy = def.damage },
			punch_attack_uses = def.uses,
		},
		on_place = vl_tools.axe.make_stripped_trunk,
		sound = { breaks = "default_tool_breaks" },
		_mcl_toollike_wield = true,
		_mcl_diggroups = {
			axey = { speed = def.speed, level = def.level, uses = def.dig_uses or def.uses },
		},
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

vl_tools.axe.register("mcl_tools:axe_wood", {
	description = S("Wooden Axe"),
	icon = "default_tool_woodaxe.png",
	repair_material = "group:wood",

	groups = { dig_speed_class = 2, enchantability = 15 },

	tool_capabilities = {
		full_punch_interval = 1.25,
		max_drop_level = 1,
		damage_groups = { fleshy = 7 },
		punch_attack_uses = 60,
	},

	_mcl_diggroups = {
		axey = { speed = 2, level = 1, uses = 60 },
	},

	fuel_burntime = 10,

	_doc_items_hidden = false,
})

vl_tools.axe.register("mcl_tools:axe_stone", {
	description = S("Stone Axe"),
	icon = "default_tool_stoneaxe.png",
	repair_material = "group:cobble",

	groups = { dig_speed_class = 3, enchantability = 5 },

	tool_capabilities = {
		full_punch_interval = 1.25,
		max_drop_level = 3,
		damage_groups = { fleshy = 9 },
		punch_attack_uses = 132,
	},

	_mcl_diggroups = {
		axey = { speed = 4, level = 3, uses = 132 },
	},
})

vl_tools.axe.register("mcl_tools:axe_iron", {
	description = S("Iron Axe"),
	icon = "default_tool_steelaxe.png",
	repair_material = "mcl_core:iron_ingot",

	groups = { dig_speed_class = 4, enchantability = 14 },

	tool_capabilities = {
		full_punch_interval = 1.11111111,
		max_drop_level = 4,
		damage_groups = { fleshy = 9 },
		punch_attack_uses = 251,
	},

	_mcl_diggroups = {
		axey = { speed = 6, level = 4, uses = 251 },
	},

	cook_result = "mcl_core:iron_nugget",
})

vl_tools.axe.register("mcl_tools:axe_gold", {
	description = S("Golden Axe"),
	icon = "default_tool_goldaxe.png",
	repair_material = "mcl_core:gold_ingot",

	groups = { dig_speed_class = 6, enchantability = 22 },

	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 2,
		damage_groups = { fleshy = 7 },
		punch_attack_uses = 33,
	},

	_mcl_diggroups = {
		axey = { speed = 12, level = 2, uses = 33 },
	},

	cook_result = "mcl_core:gold_nugget",
})

vl_tools.axe.register("mcl_tools:axe_diamond", {
	description = S("Diamond Axe"),
	icon = "default_tool_diamondaxe.png",
	repair_material = "mcl_core:diamond",

	groups = { dig_speed_class = 5, enchantability = 10 },

	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 5,
		damage_groups = { fleshy = 9 },
		punch_attack_uses = 1562,
	},

	_mcl_diggroups = {
		axey = { speed = 8, level = 5, uses = 1562 },
	},

	_mcl_upgradable = true,
	_mcl_upgrade_item = "mcl_tools:axe_netherite",
})

vl_tools.axe.register("mcl_tools:axe_netherite", {
	description = S("Netherite Axe"),
	icon = "default_tool_netheriteaxe.png",
	repair_material = "mcl_nether:netherite_ingot",

	groups = { dig_speed_class = 6, enchantability = 10, fire_immune = 1 },

	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 5,
		damage_groups = { fleshy = 10 },
		punch_attack_uses = 2031,
	},

	_mcl_diggroups = {
		axey = { speed = 9, level = 6, uses = 2031 },
	},

	no_craft = true,
})
