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
	description = "Except when in creative mode, items cannot be removed from armor slots except due to death or breaking.",
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
	on_enchant = function(itemstack, level, itemdef)
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

-- unimplemented
mcl_enchanting.enchantments.fire_aspect = {
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
}

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

-- unimplemented
mcl_enchanting.enchantments.flame = {
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
}

-- unimplemented
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

-- unimplemented
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

-- unimplemented
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

-- unimplemented
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

-- unimplemented
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

-- unimplemented
mcl_enchanting.enchantments.sharpness = {
	name = "Sharpness",
	max_level = 5,
	primary = {sword = true},
	secondary = {axe = true},
	disallow = {},
	incompatible = {bane_of_anthropods = true, smite = true},
	weight = 5,
	description = "Increases damage and applies Slowness IV to arthropod mobs (spiders, cave spiders, silverfish and endermites).",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- unimplemented
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
	description = "Incerases walking speed on soul sand.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
}

-- unimplemented
mcl_enchanting.enchantments.sweeping_edge = {
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
}

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
	on_enchant = function(itemstack, level, itemdef)		
		local new_capabilities = itemstack:get_tool_capabilities()
		for group, capability in pairs(new_capabilities.groupcaps) do
			capability.uses = capability.uses * (1 + level)
		end
		new_capabilities.punch_attack_uses = new_capabilities.punch_attack_uses * (1 + level)
		itemstack:get_meta():set_tool_capabilities(new_capabilities)
	end,
	requires_tool = true,
}

--[[
local pickaxes = {"mcl_tools:pick_wood", "mcl_tools:pick_stone", "mcl_tools:pick_gold", "mcl_tools:pick_iron", "mcl_tools:pick_diamond"}
local pickaxes_better_than_iron = {"mcl_tools:pick_iron", "mcl_tools:pick_diamond"}
local pickaxes_better_than_stone = {"mcl_tools:pick_stone", "mcl_tools:pick_gold", "mcl_tools:pick_iron", "mcl_tools:pick_diamond"}
local shovels = {"mcl_tools:shovel_wood", "mcl_tools:shovel_stone", "mcl_tools:shovel_gold", "mcl_tools:shovel_iron", "mcl_tools:shovel_diamond"}

local silk_touch_tool_lists = {
	["mcl_books:bookshelf"] = true,
	["mcl_core:clay"] = true,
	["mcl_core:stone_with_coal"] = pickaxes,
	["group:coral_block"] = pickaxes,
	["group:coral"] = true,
	["group:coral_fan"] = true,
	["mcl_core:stone_with_diamond"] = pickaxes_better_than_iron,
	["mcl_core:stone_with_emerald"] = pickaxes_better_than_iron,
	["mcl_chests:ender_chest"] = pickaxes,
	["group:glass"] = true,
	["mcl_nether:glowstone"] = true,
	["mcl_core:dirt_with_grass"] = true,
	["mcl_core:gravel"] = true,
	["mcl_core:ice"] = true,
	["mcl_core:stone_with_lapis"] = pickaxes_better_than_stone,
	["group:leaves"] = true,
	["mcl_farming:melon"] = true,
	["group:huge_mushroom"] = true,
	["mcl_core:mycelium"] = true,
	["mcl_nether:quartz_ore"] = pickaxes,
	["mcl_core:packed_ice"] = true,
	["mcl_core:podzol"] = true,
	["mcl_core:stone_with_redstone"] = pickaxes_better_than_iron,
	["mcl_ocean:sea_lantern"] = true,
	["group:top_snow"] = shovels,
	["mcl_core:snowblock"] = shovels,
	["mcl_core:stone"] = pickaxes,
}

minetest.register_on_mods_loaded(function()
	local old_handle_node_drops = minetest.handle_node_drops
	function minetest.handle_node_drops(pos, drops, digger)
		if digger and digger:is_player() then
			local wielditem = digger:get_wielded_item()
			local tooldef = wielditem:get_definition()
			if tooldef._silk_touch then
				local nodename = minetest.get_node(pos).name
				local nodedef = minetest.registered_nodes[nodename]
				local silk_touch_spec = silk_touch_tool_lists[nodename]
				local suitable_tool = false
				local tool_list
				if silk_touch_spec == true then
					suitable_tool = true
				elseif silk_touch_spec then
					tool_list = silk_touch_spec
				else
					for k, v in pairs(nodedef.groups) do
						if v > 0 then
							local group_spec = silk_touch_tool_lists["group:" .. k]
							if group_spec == true then
								suitable_tool = true
							elseif group_spec then
								toollist = group_spec
								break
							end
						end
					end
				end
				if tool_list and not suitable_tool then
					suitable_tool = (table.indexof(tool_list, tooldef._original_tool) ~= -1)
				end
				if suitable_tool then
					drops = {nodename}
				end
			end
		end
		old_handle_node_drops(pos, drops, digger)
	end
end) 
--]] 
