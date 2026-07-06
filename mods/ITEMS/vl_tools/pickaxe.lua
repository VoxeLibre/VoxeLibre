vl_tools.pickaxe = vl_tools.pickaxe or {}

local S = core.get_translator("mcl_tools")
local wield_scale = mcl_vars.tool_wield_scale

local pickaxe_longdesc = S("Pickaxes are mining tools to mine hard blocks, such as stone. A pickaxe can also be used as weapon, but it is rather inefficient.")

function vl_tools.pickaxe.register(name, def)
	assert(type(name) == "string" and name ~= "", "vl_tools.pickaxe.register requires a tool name")
	assert(def, "vl_tools.pickaxe.register requires a definition")
	assert(type(def.icon) == "string" and def.icon ~= "", "vl_tools.pickaxe.register requires def.icon")
	assert(type(def.repair_material) == "string" and def.repair_material ~= "", "vl_tools.pickaxe.register requires def.repair_material")

	def = table.copy(def)

	local tool_def = vl_tools.build_tool_def(def, {
		_doc_items_longdesc = pickaxe_longdesc,
		wield_scale = wield_scale,
		groups = {
			tool = 1,
			pickaxe = 1,
			dig_speed_class = def.dig_speed_class,
			enchantability = def.enchantability,
		},
		tool_capabilities = {
			full_punch_interval = def.full_punch_interval,
			max_drop_level = def.max_drop_level,
			damage_groups = { fleshy = def.damage },
			punch_attack_uses = def.uses,
		},
		sound = { breaks = "default_tool_breaks" },
		_mcl_toollike_wield = true,
		_mcl_diggroups = {
			pickaxey = { speed = def.speed, level = def.level, uses = def.dig_uses or def.uses },
		},
	})

	core.register_tool(name, tool_def)

	if not def.no_craft then
		core.register_craft({
			output = name,
			recipe = {
				{def.repair_material, def.repair_material, def.repair_material},
				{"", "mcl_core:stick", ""},
				{"", "mcl_core:stick", ""},
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

vl_tools.pickaxe.register("mcl_tools:pick_wood", {
	description = S("Wooden Pickaxe"),
	icon = "default_tool_woodpick.png",
	repair_material = "group:wood",

	groups = { dig_speed_class = 2, enchantability = 15 },

	tool_capabilities = {
		full_punch_interval = 0.83333333,
		max_drop_level = 1,
		damage_groups = { fleshy = 2 },
		punch_attack_uses = 30,
	},

	_mcl_diggroups = {
		pickaxey = { speed = 2, level = 1, uses = 60 },
	},

	fuel_burntime = 10,

	_doc_items_hidden = false,
})

vl_tools.pickaxe.register("mcl_tools:pick_stone", {
	description = S("Stone Pickaxe"),
	icon = "default_tool_stonepick.png",
	repair_material = "group:cobble",

	groups = { dig_speed_class = 3, enchantability = 5 },

	tool_capabilities = {
		full_punch_interval = 0.83333333,
		max_drop_level = 3,
		damage_groups = { fleshy = 3 },
		punch_attack_uses = 66,
	},

	_mcl_diggroups = {
		pickaxey = { speed = 4, level = 3, uses = 132 },
	},
})

vl_tools.pickaxe.register("mcl_tools:pick_iron", {
	description = S("Iron Pickaxe"),
	icon = "default_tool_steelpick.png",
	repair_material = "mcl_core:iron_ingot",

	groups = { dig_speed_class = 4, enchantability = 14 },

	tool_capabilities = {
		full_punch_interval = 0.83333333,
		max_drop_level = 4,
		damage_groups = { fleshy = 4 },
		punch_attack_uses = 126,
	},

	_mcl_diggroups = {
		pickaxey = { speed = 6, level = 4, uses = 251 },
	},

	cook_result = "mcl_core:iron_nugget",
})

vl_tools.pickaxe.register("mcl_tools:pick_gold", {
	description = S("Golden Pickaxe"),
	icon = "default_tool_goldpick.png",
	repair_material = "mcl_core:gold_ingot",

	groups = { dig_speed_class = 6, enchantability = 22 },

	tool_capabilities = {
		full_punch_interval = 0.83333333,
		max_drop_level = 2,
		damage_groups = { fleshy = 2 },
		punch_attack_uses = 17,
	},

	_mcl_diggroups = {
		pickaxey = { speed = 12, level = 2, uses = 33 },
	},

	cook_result = "mcl_core:gold_nugget",
})

vl_tools.pickaxe.register("mcl_tools:pick_diamond", {
	description = S("Diamond Pickaxe"),
	icon = "default_tool_diamondpick.png",
	repair_material = "mcl_core:diamond",

	groups = { dig_speed_class = 5, enchantability = 10 },

	tool_capabilities = {
		full_punch_interval = 0.83333333,
		max_drop_level = 5,
		damage_groups = { fleshy = 5 },
		punch_attack_uses = 781,
	},

	_mcl_diggroups = {
		pickaxey = { speed = 8, level = 5, uses = 1562 },
	},

	_mcl_upgradable = true,
	_mcl_upgrade_item = "mcl_tools:pick_netherite",
})

vl_tools.pickaxe.register("mcl_tools:pick_netherite", {
	description = S("Netherite Pickaxe"),
	icon = "default_tool_netheritepick.png",
	repair_material = "mcl_nether:netherite_ingot",

	groups = { dig_speed_class = 6, enchantability = 10, fire_immune = 1 },

	tool_capabilities = {
		full_punch_interval = 0.83333333,
		max_drop_level = 5,
		damage_groups = { fleshy = 6 },
		punch_attack_uses = 1016,
	},

	_mcl_diggroups = {
		pickaxey = { speed = 9.5, level = 6, uses = 2031 },
	},

	no_craft = true,
})
