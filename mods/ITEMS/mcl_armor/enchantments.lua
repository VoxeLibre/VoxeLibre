local S = minetest.get_translator("mcl_armor")

mcl_enchanting.enchantments.protection = {
	name = S("Protection"),
	max_level = 4,
	primary = {armor_points = true},
	secondary = {},
	disallow = {non_combat_armor = true},
	incompatible = {blast_protection = true, fire_protection = true, projectile_protection = true},
	weight = 10,
	description = S("Reduces most types of damage by 4% for each level."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{1, 12}, {12, 23}, {23, 34}, {34, 45}},
	inv_combat_tab = true,
	inv_tool_tab = false,
}

mcl_enchanting.enchantments.blast_protection = {
	name = S("Blast Protection"),
	max_level = 4,
	primary = {armor_points = true},
	secondary = {},
	disallow = {},
	incompatible = {fire_protection = true, protection = true, projectile_protection = true},
	weight = 2,
	description = S("Reduces explosion damage and knockback."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{5, 13}, {13, 21}, {21, 29}, {29, 37}},
	inv_combat_tab = true,
	inv_tool_tab = false,
}

mcl_enchanting.enchantments.fire_protection = {
	name = S("Fire Protection"),
	max_level = 4,
	primary = {armor_points = true},
	secondary = {},
	disallow = {},
	incompatible = {blast_protection = true, protection = true, projectile_protection = true},
	weight = 5,
	description = S("Reduces fire damage."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{10, 18}, {18, 26}, {26, 34}, {34, 42}},
	inv_combat_tab = true,
	inv_tool_tab = false,
}

mcl_enchanting.enchantments.projectile_protection = {
	name = S("Projectile Protection"),
	max_level = 4,
	primary = {armor_points = true},
	secondary = {},
	disallow = {},
	incompatible = {blast_protection = true, fire_protection = true, protection = true},
	weight = 5,
	description = S("Reduces projectile damage."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{1, 16}, {11, 26}, {21, 36}, {31, 46}, {41, 56}},
	inv_combat_tab = true,
	inv_tool_tab = false,
}

mcl_enchanting.enchantments.feather_falling = {
	name = S("Feather Falling"),
	max_level = 4,
	primary = {armor_feet = true},
	secondary = {},
	disallow = {non_combat_armor = true},
	incompatible = {},
	weight = 5,
	description = S("Reduces fall damage."),curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{5, 11}, {11, 17}, {17, 23}, {23, 29}},
	inv_combat_tab = true,
	inv_tool_tab = false,
}

mcl_enchanting.enchantments.thorns = {
	name = S("Thorns"),
	max_level = 3,
	primary = {armor_points = true},
	secondary = {},
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

mcl_enchanting.enchantments.curse_of_binding = {
	name = S("Curse of Binding"),
	max_level = 1,
	primary = {},
	secondary = {armor = true},
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

mcl_enchanting.enchantments.frost_walker = {
	name = S("Frost Walker"),
	max_level = 2,
	primary = {},
	secondary = {boots = true},
	disallow = {non_combat_armor = true},
	incompatible = {depth_strider = true},
	weight = 2,
	description = S("Turns water beneath the player into frosted ice and prevents the damage from magma blocks."),
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = true,
	power_range_table = {{10, 25}, {20, 35}},
	inv_combat_tab = true,
	inv_tool_tab = false,
}

walkover.register_global(function(pos, _, player)
	local boots = MCLItemStack(mcl_object_mgr.get(player):equipment():boots())
	if not boots:has_enchantment("frost_walker") then
		return
	end
	local radius = boots:get_enchantment("frost_walker") + 2
	local minp = {x = pos.x - radius, y = pos.y, z = pos.z - radius}
	local maxp = {x = pos.x + radius, y = pos.y, z = pos.z + radius}
	local positions = minetest.find_nodes_in_area_under_air(minp, maxp, "mcl_core:water_source")
	for _, p in ipairs(positions) do
		if vector.distance(pos, p) <= radius then
			minetest.set_node(p, {name = "mcl_core:frosted_ice_0"})
		end
	end
end)
