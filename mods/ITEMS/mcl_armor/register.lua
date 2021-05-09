local S = minetest.get_translator("mcl_armor")

mcl_armor.register_set({
	name = "leather",
	description = "Leather",
	descriptions = {
		head = "Cap",
		torso = "Tunic",
		legs = "Pants",
	},
	durability = 80,
	enchantability = 15,
	points = {
		head = 1,
		torso = 3,
		legs = 2,
		feet = 1,
	},
	craft_material = "mcl_mobitems:leather",
})

mcl_armor.register_set({
	name = "gold",
	description = "Golden",
	durability = 112,
	enchantability = 25,
	points = {
		head = 2,
		torso = 5,
		legs = 3,
		feet = 1,
	},
	craft_material = "mcl_core:gold_ingot",
	cook_material = "mcl_core:gold_nugget",
	sound_equip = "mcl_armor_equip_iron",
	sound_unequip = "mcl_armor_unequip_iron",
})

mcl_armor.register_set({
	name = "chain",
	description = "Chain",
	durability = 240,
	enchantability = 12,
	points = {
		head = 2,
		torso = 5,
		legs = 4,
		feet = 1,
	},
	repair_material = "mcl_core:iron_ingot",
	cook_material = "mcl_core:iron_nugget",
})

mcl_armor.register_set({
	name = "iron",
	description = "Iron",
	durability = 240,
	enchantability = 9,
	points = {
		head = 2,
		torso = 6,
		legs = 5,
		feet = 2,
	},
	craft_material = "mcl_core:iron_ingot",
	cook_material = "mcl_core:iron_nugget",
})

mcl_armor.register_set({
	name = "diamond",
	description = "Diamond",
	durability = 528,
	enchantability = 10,
	points = {
		head = 3,
		torso = 8,
		legs = 6,
		feet = 3,
	},
	toughness = 2,
	craft_material = "mcl_core:diamond",
	upgradable = true,
})

mcl_armor.register_set({
	name = "netherite",
	description = "Netherite",
	durability = 592,
	enchantability = 15,
	points = {
		head = 3,
		torso = 8,
		legs = 6,
		feet = 3,
	},
	toughness = 3,
})

mcl_armor.register_protection_enchantment({
	id = "projectile_protection",
	name = S("Projectile Protection"),
	description = S("Reduces projectile damage."),
	power_range_table = {{1, 16}, {11, 26}, {21, 36}, {31, 46}, {41, 56}},
	incompatible = {blast_protection = true, fire_protection = true, protection = true},
	factor = 2,
	damage_flag = "is_projectile",
})

mcl_armor.register_protection_enchantment({
	id = "blast_protection",
	name = S("Blast Protection"),
	description = S("Reduces explosion damage and knockback."),
	power_range_table = {{5, 13}, {13, 21}, {21, 29}, {29, 37}},
	weight = 2,
	incompatible = {fire_protection = true, protection = true, projectile_protection = true},
	factor = 2,
	damage_flag = "is_explosion",
})

mcl_armor.register_protection_enchantment({
	id = "fire_protection",
	name = S("Fire Protection"),
	description = S("Reduces fire damage."),
	power_range_table = {{5, 13}, {13, 21}, {21, 29}, {29, 37}},
	incompatible = {blast_protection = true, protection = true, projectile_protection = true},
	factor = 2,
	damage_flag = "is_fire",
})

mcl_armor.register_protection_enchantment({
	id = "protection",
	name = S("Protection"),
	description = S("Reduces most types of damage by 4% for each level."),
	power_range_table = {{1, 12}, {12, 23}, {23, 34}, {34, 45}},
	incompatible = {blast_protection = true, fire_protection = true, projectile_protection = true},
	factor = 1,
})

mcl_armor.register_protection_enchantment({
	id = "feather_falling",
	name = S("Feather Falling"),
	description = S("Reduces fall damage."),
	power_range_table = {{5, 11}, {11, 17}, {17, 23}, {23, 29}},
	factor = 3,
	primary = {combat_armor_feet = true},
	damage_type = "fall",
})

-- requires engine change
--[[mcl_enchanting.enchantments.aqua_affinity = {
	name = S("Aqua Affinity"),
	max_level = 1,
	primary = {armor_head = true},
	secondary = {},
	disallow = {non_combat_armor = true},
	incompatible = {},
	weight = 2,
	description = S("Increases underwater mining speed."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{1, 41}},
	inv_combat_tab = true,
	inv_tool_tab = false,
}]]--

mcl_enchanting.enchantments.curse_of_binding = {
	name = S("Curse of Binding"),
	max_level = 1,
	primary = {},
	secondary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true},
	disallow = {},
	incompatible = {},
	weight = 1,
	description = S("Item cannot be removed from armor slots except due to death, breaking or in Creative Mode."),
	curse = true,
	on_enchant = function() end,
	requires_tool = false,
	treasure = true,
	power_range_table = {{25, 50}},
	inv_combat_tab = true,
	inv_tool_tab = false,
}

mcl_enchanting.enchantments.thorns = {
	name = S("Thorns"),
	max_level = 3,
	primary = {combat_armor_chestplate = true},
	secondary = {combat_armor = true},
	disallow = {},
	incompatible = {},
	weight = 1,
	description = S("Reflects some of the damage taken when hit, at the cost of reducing durability with each proc."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{10, 61}, {30, 71}, {50, 81}},
	inv_combat_tab = true,
	inv_tool_tab = false,
}

-- Elytra

minetest.register_tool("mcl_armor:elytra", {
	description = S("Elytra"),
	_doc_items_longdesc = mcl_armor.longdesc,
	_doc_items_usagehelp = mcl_armor.usage,
	inventory_image = "mcl_armor_inv_elytra.png",
	groups = {armor = 1, non_combat_armor = 1, armor_torso = 1, non_combat_torso = 1, mcl_armor_uses = 10, enchantability = 1},
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_leather",
		_mcl_armor_unequip = "mcl_armor_unequip_leather",
	},
	on_place = mcl_armor.equip_on_use,
	on_secondary_use = mcl_armor.equip_on_use,
	_mcl_armor_element = "torso",
	_mcl_armor_texture = "mcl_armor_elytra.png"
})
