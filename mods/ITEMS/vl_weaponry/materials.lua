local S = core.get_translator(core.get_current_modname())

local function material(tool_types, craft_material, repair_material, stats, extra)
	local definition = {
		tool_types = tool_types,
		craft_material = craft_material,
		repair_material = repair_material,
		stat_modifiers = stats,
	}
	return table.update(definition, extra or {})
end

vl_weaponry.register_tool_material("wood", material(
	{
		["vl_weaponry:hammer"] = {
			item_name = "vl_weaponry:hammer_wood",
			description = S("Wooden Hammer"),
			inventory_image = "vl_tool_woodhammer.png",
		},
		["vl_weaponry:spear"] = {
			item_name = "vl_weaponry:spear_wood",
			description = S("Wooden Spear"),
			inventory_image = "vl_tool_woodspear.png",
		},
		["vl_weaponry:scythe"] = {
			item_name = "vl_weaponry:scythe_wood",
			description = S("Wooden Scythe"),
			inventory_image = "vl_tool_woodscythe.png",
		},
	}, "group:wood", "group:wood", {
		durability = { add = 60 },
		dig_speed = { multiply = 2 },
		harvest_level = { add = 1 },
		damage = { add = 0 },
		attack_interval = { add = 0 },
		thrown_damage = { add = 0 },
		enchantability = { add = 15 },
	}, { dig_speed_class = 2, burn_time = 10 }
))

vl_weaponry.register_tool_material("stone", material(
	{
		["vl_weaponry:hammer"] = {
			item_name = "vl_weaponry:hammer_stone",
			description = S("Stone Hammer"),
			inventory_image = "vl_tool_stonehammer.png",
		},
		["vl_weaponry:spear"] = {
			item_name = "vl_weaponry:spear_stone",
			description = S("Stone Spear"),
			inventory_image = "vl_tool_stonespear.png",
		},
		["vl_weaponry:scythe"] = {
			item_name = "vl_weaponry:scythe_stone",
			description = S("Stone Scythe"),
			inventory_image = "vl_tool_stonescythe.png",
		},
	}, "group:cobble", "group:cobble", {
		durability = { add = 132 },
		dig_speed = { multiply = 4 },
		harvest_level = { add = 3 },
		damage = { add = 1 },
		attack_interval = { add = 0.1 },
		thrown_damage = { add = 1 },
		enchantability = { add = 5 },
	}, { dig_speed_class = 3 }
))

vl_weaponry.register_tool_material("iron", material(
	{
		["vl_weaponry:hammer"] = {
			item_name = "vl_weaponry:hammer_iron",
			description = S("Iron Hammer"),
			inventory_image = "vl_tool_steelhammer.png",
		},
		["vl_weaponry:spear"] = {
			item_name = "vl_weaponry:spear_iron",
			description = S("Iron Spear"),
			inventory_image = "vl_tool_steelspear.png",
		},
		["vl_weaponry:scythe"] = {
			item_name = "vl_weaponry:scythe_iron",
			description = S("Iron Scythe"),
			inventory_image = "vl_tool_steelscythe.png",
		},
	}, "mcl_core:iron_ingot", "mcl_core:iron_ingot", {
		durability = { add = 251 },
		dig_speed = { multiply = 6 },
		harvest_level = { add = 4 },
		damage = { add = 2 },
		attack_interval = { add = 0 },
		thrown_damage = { add = 2 },
		enchantability = { add = 14 },
	}, { dig_speed_class = 4, smelting_output = "mcl_core:iron_nugget" }
))

vl_weaponry.register_tool_material("gold", material(
	{
		["vl_weaponry:hammer"] = {
			item_name = "vl_weaponry:hammer_gold",
			description = S("Golden Hammer"),
			inventory_image = "vl_tool_goldhammer.png",
		},
		["vl_weaponry:spear"] = {
			item_name = "vl_weaponry:spear_gold",
			description = S("Golden Spear"),
			inventory_image = "vl_tool_goldspear.png",
		},
		["vl_weaponry:scythe"] = {
			item_name = "vl_weaponry:scythe_gold",
			description = S("Golden Scythe"),
			inventory_image = "vl_tool_goldscythe.png",
		},
	}, "mcl_core:gold_ingot", "mcl_core:gold_ingot", {
		durability = { add = 133 },
		dig_speed = { multiply = 12 },
		harvest_level = { add = 2 },
		damage = { add = 0 },
		attack_interval = { add = -0.2 },
		thrown_damage = { add = 0 },
		enchantability = { add = 22 },
	}, { dig_speed_class = 6, smelting_output = "mcl_core:gold_nugget" }
))

vl_weaponry.register_tool_material("netherite", material(
	{
		["vl_weaponry:hammer"] = {
			item_name = "vl_weaponry:hammer_netherite",
			description = S("Netherite Hammer"),
			inventory_image = "vl_tool_netheritehammer.png",
		},
		["vl_weaponry:spear"] = {
			item_name = "vl_weaponry:spear_netherite",
			description = S("Netherite Spear"),
			inventory_image = "vl_tool_netheritespear.png",
		},
		["vl_weaponry:scythe"] = {
			item_name = "vl_weaponry:scythe_netherite",
			description = S("Netherite Scythe"),
			inventory_image = "vl_tool_netheritescythe.png",
		},
	}, nil, "mcl_nether:netherite_ingot", {
		durability = { add = 2031 },
		dig_speed = { multiply = 9.5 },
		harvest_level = { add = 6 },
		damage = { add = 5 },
		attack_interval = { add = 0 },
		thrown_damage = { add = 7 },
		enchantability = { add = 10 },
	}, {
		dig_speed_class = 6,
		craftable = false,
		fire_immune = true,
	}
))

vl_weaponry.register_tool_material("diamond", material(
	{
		["vl_weaponry:hammer"] = {
			item_name = "vl_weaponry:hammer_diamond",
			description = S("Diamond Hammer"),
			inventory_image = "vl_tool_diamondhammer.png",
			upgrade_item = "vl_weaponry:hammer_netherite",
		},
		["vl_weaponry:spear"] = {
			item_name = "vl_weaponry:spear_diamond",
			description = S("Diamond Spear"),
			inventory_image = "vl_tool_diamondspear.png",
			upgrade_item = "vl_weaponry:spear_netherite",
		},
		["vl_weaponry:scythe"] = {
			item_name = "vl_weaponry:scythe_diamond",
			description = S("Diamond Scythe"),
			inventory_image = "vl_tool_diamondscythe.png",
			upgrade_item = "vl_weaponry:scythe_netherite",
		},
	}, "mcl_core:diamond", "mcl_core:diamond", {
		durability = { add = 1562 },
		dig_speed = { multiply = 8 },
		harvest_level = { add = 5 },
		damage = { add = 3 },
		attack_interval = { add = 0 },
		thrown_damage = { add = 3 },
		enchantability = { add = 10 },
	}, {
		dig_speed_class = 5,
	}
))
