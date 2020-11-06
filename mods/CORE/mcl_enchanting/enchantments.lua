-- Taken from https://minecraft.gamepedia.com/Enchanting

-- requires engine change
--[[mcl_enchanting.enchantments.aqua_affinity = {
	name = "Aqua Affinity",
	max_level = 1,
	primary = {armor_head = true},
	secondary = {},
	disallow = {non_combat_armor = true},
	incompatible = {},
	weight = 2,
	description = "Increases underwater mining speed.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}]]--

-- unimplemented
mcl_enchanting.enchantments.bane_of_anthropods = {
	name = "Bane of Anthropods",
	max_level = 5,
	primary = {sword = true},
	secondary = {axe = true},
	disallow = {},
	incompatible = {smite = true, shaprness = true},
	weight = 5,
	description = "Increases damage and applies Slowness IV to arthropod mobs (spiders, cave spiders, silverfish and endermites).",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- unimplemented
mcl_enchanting.enchantments.blast_protection = {
	name = "Blast Protection",
	max_level = 4,
	primary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true},
	secondary = {},
	disallow = {non_combat_armor = true},
	incompatible = {fire_protection = true, protection = true, projectile_protection = true},
	weight = 2,
	description = "Reduces explosion damage and knockback.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- implemented in mcl_armor
mcl_enchanting.enchantments.curse_of_binding = {
	name = "Curse of Binding",
	max_level = 1,
	primary = {},
	secondary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true},
	disallow = {},
	incompatible = {},
	weight = 1,
	description = "Except when in creative mode, items cannot be removed from armor slots except due to death or breaking.",
	curse = true,
	on_enchant = function() end,
	requires_tool = false,
}

-- implemented in mcl_death_drop
mcl_enchanting.enchantments.curse_of_vanishing = {
	name = "Curse of Vanishing",
	max_level = 1,
	primary = {},
	secondary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true, tool = true, weapon = true},
	disallow = {clock = true},
	incompatible = {},
	weight = 1,
	description = "Item destroyed on death.",
	curse = true,
	on_enchant = function() end,
	requires_tool = false,
}

-- unimplemented
mcl_enchanting.enchantments.depth_strider = {
	name = "Depth Strider",
	max_level = 3,
	primary = {},
	secondary = {armor_feet = true},
	disallow = {non_combat_armor = true},
	incompatible = {frost_walker = true},
	weight = 2,
	description = "Increases underwater movement speed.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- implemented via on_enchant
mcl_enchanting.enchantments.efficiency = {
	name = "Efficiency",
	max_level = 5,
	primary = {pickaxe = true, shovel = true, axe = true, hoe = true},
	secondary = {shears = true},
	disallow = {},
	incompatible = {},
	weight = 10,
	description = "Increases mining speed.",
	curse = false,
	on_enchant = function(itemstack, level)
		local tool_capabilities = itemstack:get_tool_capabilities()
		local groupcaps = {}
		for group, capability in pairs(tool_capabilities.groupcaps) do
			local groupname = group .. "_efficiency_" .. level
			capability.times = mcl_autogroup.digtimes[groupname]
			groupcaps[groupname] = capability
		end
		tool_capabilities.groupcaps = groupcaps
		itemstack:get_meta():set_tool_capabilities(tool_capabilities)
	end,
	requires_tool = false,
}

-- unimplemented
mcl_enchanting.enchantments.feather_falling = {
	name = "Feather Falling",
	max_level = 4,
	primary = {armor_feet = true},
	secondary = {},
	disallow = {non_combat_armor = true},
	incompatible = {},
	weight = 5,
	description = "Reduces fall damage.",curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- requires missing MineClone2 feature
--[[mcl_enchanting.enchantments.fire_aspect = {
	name = "Fire Aspect",
	max_level = 2,
	primary = {sword = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = "Sets target on fire.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}]]--

-- unimplemented
mcl_enchanting.enchantments.fire_protection = {
	name = "Fire Protection",
	max_level = 4,
	primary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true},
	secondary = {},
	disallow = {non_combat_armor = true},
	incompatible = {blast_protection = true, protection = true, projectile_protection = true},
	weight = 5,
	description = "Reduces fire damage.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- requires missing MineClone2 feature
--[[mcl_enchanting.enchantments.flame = {
	name = "Flame",
	max_level = 1,
	primary = {bow = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = "Arrows set target on fire.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}]]--

-- implemented in mcl_item_entity
mcl_enchanting.enchantments.fortune = {
	name = "Fortune",
	max_level = 4,
	primary = {pickaxe = true, shovel = true, axe = true, hoe = true},
	secondary = {},
	disallow = {},
	incompatible = {silk_touch = true},
	weight = 2,
	description = "Increases certain block drops.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- implemented via walkover.register_global
mcl_enchanting.enchantments.frost_walker = {
	name = "Frost Walker",
	max_level = 2,
	primary = {},
	secondary = {armor_feet = true},
	disallow = {non_combat_armor = true},
	incompatible = {depth_strider = true},
	weight = 2,
	description = "Turns water beneath the player into frosted ice and prevents the damage the player would take from standing on magma blocks.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

walkover.register_global(function(pos, _, player)
	local boots = player:get_inventory():get_stack("armor", 5)
	local frost_walker = mcl_enchanting.get_enchantment(boots, "frost_walker")
	if frost_walker <= 0 then
		return
	end
	local radius = frost_walker + 2
	local minp = {x = pos.x - radius, y = pos.y, z = pos.z - radius}
	local maxp = {x = pos.x + radius, y = pos.y, z = pos.z + radius}
	local positions = minetest.find_nodes_in_area_under_air(minp, maxp, "mcl_core:water_source")
	for _, p in ipairs(positions) do
		if vector.distance(pos, p) <= radius then
			minetest.set_node(p, {name = "mcl_core:frosted_ice_0"})
		end
	end
end)

-- implemented in mcl_bows
mcl_enchanting.enchantments.infinity = {
	name = "Infinity",
	max_level = 1,
	primary = {bow = true},
	secondary = {},
	disallow = {},
	incompatible = {mending = true},
	weight = 1,
	description = "Shooting consumes no regular arrows.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- implemented via minetest.calculate_knockback
mcl_enchanting.enchantments.knockback = {
	name = "Knockback",
	max_level = 2,
	primary = {sword = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 5,
	description = "Increases knockback.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

local old_calculate_knockback = minetest.calculate_knockback
function minetest.calculate_knockback(player, hitter, time_from_last_punch, tool_capabilities, dir, distance, damage)
	local knockback = old_calculate_knockback(player, hitter, time_from_last_punch, tool_capabilities, dir, distance, damage)
	local luaentity
	if hitter then
		luaentity = hitter:get_luaentity()
	end
	if hitter and hitter:is_player() then
		local wielditem = hitter:get_wielded_item()
		knockback = knockback + 3 * mcl_enchanting.get_enchantment(wielditem, "knockback")
	elseif luaentity and luaentity._knockback then
		knockback = knockback + luaentity._knockback
	end
	return knockback
end

-- unimplemented
mcl_enchanting.enchantments.looting = {
	name = "Looting",
	max_level = 3,
	primary = {sword = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = "Increases mob loot.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- unimplemented
mcl_enchanting.enchantments.luck_of_the_sea = {
	name = "Luck of the Sea",
	max_level = 3,
	primary = {fishing_rod = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = "Increases rate of good loot (enchanting books, etc.)",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- unimplemented
mcl_enchanting.enchantments.lure = {
	name = "Lure",
	max_level = 3,
	primary = {fishing_rod = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = "Decreases wait time until fish/junk/loot \"bites\".",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- unimplemented
mcl_enchanting.enchantments.mending = {
	name = "Mending",
	max_level = 1,
	primary = {},
	secondary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true, tool = true, weapon = true},
	disallow = {},
	incompatible = {infinity = true},
	weight = 2,
	description = "Repair the item while gaining XP orbs.",
	curse = false,
	on_enchant = function() end,
	requires_tool = true,
}

-- implemented in mcl_bows
mcl_enchanting.enchantments.power = {
	name = "Power",
	max_level = 5,
	primary = {},
	secondary = {bow = true},
	disallow = {},
	incompatible = {},
	weight = 10,
	description = "Increases arrow damage.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- unimplemented
mcl_enchanting.enchantments.projectile_protection = {
	name = "Projectile Protection",
	max_level = 4,
	primary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true},
	secondary = {},
	disallow = {non_combat_armor = true},
	incompatible = {blast_protection = true, fire_protection = true, protection = true},
	weight = 5,
	description = "Reduces projectile damage.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- unimplemented
mcl_enchanting.enchantments.protection = {
	name = "Protection",
	max_level = 4,
	primary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true},
	secondary = {},
	disallow = {non_combat_armor = true},
	incompatible = {blast_protection = true, fire_protection = true, projectile_protection = true},
	weight = 10,
	description = "Reduces most types of damage by 4% for each level.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- implemented via minetest.calculate_knockback (together with the Knockback enchantment) and mcl_bows
mcl_enchanting.enchantments.punch = {
	name = "Punch",
	max_level = 2,
	primary = {},
	secondary = {bow = true},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = "Increases arrow knockback.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- unimplemented
mcl_enchanting.enchantments.respiration = {
	name = "Respiration",
	max_level = 3,
	primary = {armor_head = true},
	secondary = {},
	disallow = {non_combat_armor = true},
	incompatible = {},
	weight = 2,
	description = "Extends underwater breathing time.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- implemented via on_enchant
mcl_enchanting.enchantments.sharpness = {
	name = "Sharpness",
	max_level = 5,
	primary = {sword = true},
	secondary = {axe = true},
	disallow = {},
	incompatible = {bane_of_anthropods = true, smite = true},
	weight = 5,
	description = "Increases damage.",
	curse = false,
	on_enchant = function(itemstack, level)
		local tool_capabilities = itemstack:get_tool_capabilities()
		local damage_groups = {}
		for group, damage in pairs(tool_capabilities.damage_groups) do
			damage_groups[group] = damage + level * 0.5
		end
		tool_capabilities.damage_groups = damage_groups
		itemstack:get_meta():set_tool_capabilities(tool_capabilities)
	end,
	requires_tool = false,
}

-- implemented in mcl_item_entity
mcl_enchanting.enchantments.silk_touch = {
	name = "Silk Touch",
	max_level = 1,
	primary = {pickaxe = true, shovel = true, axe = true, hoe = true},
	secondary = {shears = true},
	disallow = {},
	incompatible = {fortune = true},
	weight = 1,
	description = "Mined blocks drop themselves.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- unimplemented
mcl_enchanting.enchantments.smite = {
	name = "Smite",
	max_level = 5,
	primary = {sword = true},
	secondary = {axe = true},
	disallow = {},
	incompatible = {bane_of_anthropods = true, sharpness = true},
	weight = 5,
	description = "Increases damage to undead mobs.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- unimplemented
mcl_enchanting.enchantments.soul_speed = {
	name = "Soul Speed",
	max_level = 3,
	primary = {},
	secondary = {armor_feet = true},
	disallow = {non_combat_armor = true},
	incompatible = {frost_walker = true},
	weight = 2,
	description = "Increases walking speed on soul sand.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- requires missing MineClone2 feature
--[[mcl_enchanting.enchantments.sweeping_edge = {
	name = "Sweeping Edge",
	max_level = 3,
	primary = {sword = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 2,
	description = "Increases sweeping attack damage.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}]]--

-- unimplemented
mcl_enchanting.enchantments.thorns = {
	name = "Thorns",
	max_level = 3,
	primary = {armor_head = true},
	secondary = {armor_torso = true, armor_legs = true, armor_feet = true},
	disallow = {non_combat_armor = true},
	incompatible = {blast_protection = true, fire_protection = true, projectile_protection = true},
	weight = 1,
	description = "Reflects some of the damage taken when hit, at the cost of reducing durability with each proc.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- for tools & weapons implemented via on_enchant; for bows implemented in mcl_bows; for armor implemented in mcl_armor and mcl_tt; for fishing rods implemented in mcl_fishing
mcl_enchanting.enchantments.unbreaking = {
	name = "Unbreaking",
	max_level = 3,
	primary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true, pickaxe = true, shovel = true, axe = true, hoe = true, sword = true, fishing_rod = true, bow = true},
	secondary = {tool = true},
	disallow = {non_combat_armor = true},
	incompatible = {},
	weight = 5,
	description = "Increases item durability.",
	curse = false,
	on_enchant = function(itemstack, level)		
		local tool_capabilities = itemstack:get_tool_capabilities()
		for group, capability in pairs(tool_capabilities.groupcaps) do
			capability.uses = capability.uses * (1 + level)
		end
		tool_capabilities.punch_attack_uses = tool_capabilities.punch_attack_uses * (1 + level)
		itemstack:get_meta():set_tool_capabilities(tool_capabilities)
	end,
	requires_tool = true,
}
