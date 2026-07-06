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
			dig_speed_class = def.dig_speed_class,
			enchantability = def.enchantability,
		},
		tool_capabilities = {
			full_punch_interval = def.full_punch_interval,
			max_drop_level = def.max_drop_level,
			damage_groups = { fleshy = def.damage },
			punch_attack_uses = def.uses,
		},
		on_place = vl_tools.shovel.make_grass_path,
		sound = { breaks = "default_tool_breaks" },
		_mcl_toollike_wield = true,
		_mcl_diggroups = {
			shovely = { speed = def.speed, level = def.level, uses = def.dig_uses or def.uses },
		},
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

vl_tools.shovel.register("mcl_tools:shovel_wood", {
	description = S("Wooden Shovel"),
	icon = "default_tool_woodshovel.png",
	repair_material = "group:wood",

	groups = { dig_speed_class = 2, enchantability = 15 },

	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level = 1,
		damage_groups = { fleshy = 2 },
		punch_attack_uses = 30,
	},

	_mcl_diggroups = {
		shovely = { speed = 2, level = 2, uses = 60 },
	},

	fuel_burntime = 10,

	_doc_items_hidden = false,
})

vl_tools.shovel.register("mcl_tools:shovel_stone", {
	description = S("Stone Shovel"),
	icon = "default_tool_stoneshovel.png",
	repair_material = "group:cobble",

	groups = { dig_speed_class = 3, enchantability = 5 },

	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level = 3,
		damage_groups = { fleshy = 3 },
		punch_attack_uses = 66,
	},

	_mcl_diggroups = {
		shovely = { speed = 4, level = 3, uses = 132 },
	},
})

vl_tools.shovel.register("mcl_tools:shovel_iron", {
	description = S("Iron Shovel"),
	icon = "default_tool_steelshovel.png",
	repair_material = "mcl_core:iron_ingot",

	groups = { dig_speed_class = 4, enchantability = 14 },

	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level = 4,
		damage_groups = { fleshy = 4 },
		punch_attack_uses = 126,
	},

	_mcl_diggroups = {
		shovely = { speed = 6, level = 4, uses = 251 },
	},

	cook_result = "mcl_core:iron_nugget",
})

vl_tools.shovel.register("mcl_tools:shovel_gold", {
	description = S("Golden Shovel"),
	icon = "default_tool_goldshovel.png",
	repair_material = "mcl_core:gold_ingot",

	groups = { dig_speed_class = 6, enchantability = 22 },

	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level = 2,
		damage_groups = { fleshy = 2 },
		punch_attack_uses = 17,
	},

	_mcl_diggroups = {
		shovely = { speed = 12, level = 2, uses = 33 },
	},

	cook_result = "mcl_core:gold_nugget",
})

vl_tools.shovel.register("mcl_tools:shovel_diamond", {
	description = S("Diamond Shovel"),
	icon = "default_tool_diamondshovel.png",
	repair_material = "mcl_core:diamond",

	groups = { dig_speed_class = 5, enchantability = 10 },

	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level = 5,
		damage_groups = { fleshy = 5 },
		punch_attack_uses = 781,
	},

	_mcl_diggroups = {
		shovely = { speed = 8, level = 5, uses = 1562 },
	},

	_mcl_upgradable = true,
	_mcl_upgrade_item = "mcl_tools:shovel_netherite",
})

vl_tools.shovel.register("mcl_tools:shovel_netherite", {
	description = S("Netherite Shovel"),
	icon = "default_tool_netheriteshovel.png",
	repair_material = "mcl_nether:netherite_ingot",

	groups = { dig_speed_class = 6, enchantability = 10, fire_immune = 1 },

	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level = 5,
		damage_groups = { fleshy = 5 },
		punch_attack_uses = 1016,
	},

	_mcl_diggroups = {
		shovely = { speed = 9, level = 6, uses = 2031 },
	},

	no_craft = true,
})
