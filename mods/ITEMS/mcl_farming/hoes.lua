local S = core.get_translator(core.get_current_modname())

vl_tools.hoe.register("mcl_farming:hoe_wood", {
	description = S("Wood Hoe"),
	icon = "farming_tool_woodhoe.png",
	repair_material = "group:wood",

	groups = { enchantability = 15 },

	tool_capabilities = {
		full_punch_interval = 1,
		damage_groups = { fleshy = 1 },
		punch_attack_uses = 60,
	},

	_mcl_diggroups = {
		hoey = { speed = 2, level = 1, uses = 60 },
	},

	fuel_burntime = 10,

	_doc_items_hidden = false,
})

vl_tools.hoe.register("mcl_farming:hoe_stone", {
	description = S("Stone Hoe"),
	icon = "farming_tool_stonehoe.png",
	repair_material = "group:cobble",

	groups = { enchantability = 5 },

	tool_capabilities = {
		full_punch_interval = 0.5,
		damage_groups = { fleshy = 1 },
		punch_attack_uses = 132,
	},

	_mcl_diggroups = {
		hoey = { speed = 4, level = 3, uses = 132 },
	},
})

vl_tools.hoe.register("mcl_farming:hoe_iron", {
	description = S("Iron Hoe"),
	icon = "farming_tool_steelhoe.png",
	repair_material = "mcl_core:iron_ingot",

	groups = { enchantability = 14 },

	tool_capabilities = {
		full_punch_interval = 0.33333333,
		damage_groups = { fleshy = 2 },
		punch_attack_uses = 251,
	},

	_mcl_diggroups = {
		hoey = { speed = 6, level = 4, uses = 251 },
	},

	cook_result = "mcl_core:iron_nugget",
})

vl_tools.hoe.register("mcl_farming:hoe_gold", {
	description = S("Gold Hoe"),
	icon = "farming_tool_goldhoe.png",
	repair_material = "mcl_core:gold_ingot",

	groups = { enchantability = 22 },

	tool_capabilities = {
		full_punch_interval = 0.25,
		damage_groups = { fleshy = 1 },
		punch_attack_uses = 33,
	},

	_mcl_diggroups = {
		hoey = { speed = 12, level = 2, uses = 33 },
	},

	cook_result = "mcl_core:gold_nugget",
})

vl_tools.hoe.register("mcl_farming:hoe_diamond", {
	description = S("Diamond Hoe"),
	icon = "farming_tool_diamondhoe.png",
	repair_material = "mcl_core:diamond",

	groups = { enchantability = 15 },

	tool_capabilities = {
		full_punch_interval = 0.25,
		damage_groups = { fleshy = 3 },
		punch_attack_uses = 1562,
	},

	_mcl_diggroups = {
		hoey = { speed = 8, level = 5, uses = 1562 },
	},

	_mcl_upgradable = true,
	_mcl_upgrade_item = "mcl_farming:hoe_netherite",
})

vl_tools.hoe.register("mcl_farming:hoe_netherite", {
	description = S("Netherite Hoe"),
	icon = "farming_tool_netheritehoe.png",
	repair_material = "mcl_nether:netherite_ingot",

	groups = { enchantability = 15, fire_immune = 1 },

	tool_capabilities = {
		full_punch_interval = 0.25,
		damage_groups = { fleshy = 4 },
		punch_attack_uses = 2031,
	},

	_mcl_diggroups = {
		hoey = { speed = 8, level = 5, uses = 2031 },
	},

	no_craft = true,
})
