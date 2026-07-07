local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

-- mods/default/tools.lua

--
-- Tool definition
--

--[[
dig_speed_class group:
- 1: Painfully slow
- 2: Very slow
- 3: Slow
- 4: Fast
- 5: Very fast
- 6: Extremely fast
- 7: Instantaneous
]]

-- Help texts
local sword_longdesc = S("Swords are great in melee combat, as they are fast, deal high damage and can endure countless battles. Swords can also be used to cut down a few particular blocks, such as cobwebs.")
-- local sword_use = S("To slash multiple enemies, hold the sword in your hand, then use (rightclick) an enemy.")
-- TODO slash attack not implemented yet

local wield_scale = mcl_vars.tool_wield_scale

-- Swords
minetest.register_tool("mcl_tools:sword_wood", {
	description = S("Wooden Sword"),
	_doc_items_longdesc = sword_longdesc,
	_doc_items_hidden = false,
	inventory_image = "default_tool_woodsword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=2, enchantability=15 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=1,
		damage_groups = {fleshy=4},
		punch_attack_uses = 60,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:wood",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 2, level = 1, uses = 60 },
		swordy_cobweb = { speed = 2, level = 1, uses = 60 }
	},
})
minetest.register_tool("mcl_tools:sword_stone", {
	description = S("Stone Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_stonesword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=3, enchantability=5 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=3,
		damage_groups = {fleshy=5},
		punch_attack_uses = 132,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:cobble",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 4, level = 3, uses = 132 },
		swordy_cobweb = { speed = 4, level = 3, uses = 132 }
	},
})
minetest.register_tool("mcl_tools:sword_iron", {
	description = S("Iron Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_steelsword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=4, enchantability=14 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=4,
		damage_groups = {fleshy=6},
		punch_attack_uses = 251,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:iron_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 6, level = 4, uses = 251 },
		swordy_cobweb = { speed = 6, level = 4, uses = 251 }
	},
})
minetest.register_tool("mcl_tools:sword_gold", {
	description = S("Golden Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_goldsword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=6, enchantability=22 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=2,
		damage_groups = {fleshy=4},
		punch_attack_uses = 33,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:gold_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 12, level = 2, uses = 33 },
		swordy_cobweb = { speed = 12, level = 2, uses = 33 }
	},
})
minetest.register_tool("mcl_tools:sword_diamond", {
	description = S("Diamond Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_diamondsword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=5, enchantability=10 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=5,
		damage_groups = {fleshy=7},
		punch_attack_uses = 1562,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:diamond",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 8, level = 5, uses = 1562 },
		swordy_cobweb = { speed = 8, level = 5, uses = 1562 }
	},
	_mcl_upgradable = true,
	_mcl_upgrade_item = "mcl_tools:sword_netherite"
})
minetest.register_tool("mcl_tools:sword_netherite", {
	description = S("Netherite Sword"),
	_doc_items_longdesc = sword_longdesc,
	inventory_image = "default_tool_netheritesword.png",
	wield_scale = wield_scale,
	groups = { weapon=1, sword=1, dig_speed_class=5, enchantability=10, fire_immune=1 },
	tool_capabilities = {
		full_punch_interval = 0.625,
		max_drop_level=5,
		damage_groups = {fleshy=9},
		punch_attack_uses = 2031,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_nether:netherite_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 8, level = 5, uses = 2031 },
		swordy_cobweb = { speed = 8, level = 5, uses = 2031 }
	},
})

vl_tools.pickaxe.register("mcl_tools:pick_wood", {
	description = S("Wooden Pickaxe"),
	icon = "default_tool_woodpick.png",
	repair_material = "group:wood",

	groups = { dig_speed_class = 2, enchantability = 15 },

	tool_capabilities = {
		full_punch_interval = 0.83333333, -- 1 / 1.2
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
		full_punch_interval = 0.83333333, -- 1 / 1.2
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
		full_punch_interval = 0.83333333, -- 1 / 1.2
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
		full_punch_interval = 0.83333333, -- 1 / 1.2
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
		full_punch_interval = 0.83333333, -- 1 / 1.2
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
		full_punch_interval = 0.83333333, -- 1 / 1.2
		max_drop_level = 5,
		damage_groups = { fleshy = 6 },
		punch_attack_uses = 1016,
	},

	_mcl_diggroups = {
		pickaxey = { speed = 9.5, level = 6, uses = 2031 },
	},

	no_craft = true,
})

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
		full_punch_interval = 1.11111111, -- 1 / 0.9
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

vl_tools.shears.register("mcl_tools:shears", {
	description = S("Shears"),
	icon = "default_tool_shears.png",
	repair_material = "mcl_core:iron_ingot",

	groups = { dig_speed_class = 4, enchantability = -1 },

	tool_capabilities = {
		full_punch_interval = 0.5,
		max_drop_level = 1,
	},

	_mcl_diggroups = {
		shearsy = { speed = 1.5, level = 1, uses = 238 },
		shearsy_wool = { speed = 5, level = 1, uses = 238 },
		shearsy_cobweb = { speed = 15, level = 1, uses = 238 },
	},
})

dofile(modpath.."/crafting.lua")
dofile(modpath.."/aliases.lua")
