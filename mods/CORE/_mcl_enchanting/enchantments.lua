-- Taken from https://minecraft.gamepedia.com/Enchanting

mcl_enchanting.enchantments = {
	-- unimplemented
	aqua_affinity = {
		name = "Aqua Affinity",
		max_level = 1,
		primary = {armor_head = true},
		secondary = {},
		disallow = {non_combat_armor = true},
		incompatible = {},
		weight = 2,
		description = "Increases underwater mining speed."
	},
	-- unimplemented
	bane_of_anthropods = {
		name = "Bane of Anthropods",
		max_level = 5,
		primary = {sword = true},
		secondary = {axe = true},
		disallow = {},
		incompatible = {smite = true, shaprness = true},
		weight = 5,
		description = "Increases damage and applies Slowness IV to arthropod mobs (spiders, cave spiders, silverfish and endermites)."
	},
	-- unimplemented
	blast_protection = {
		name = "Blast Protection",
		max_level = 4,
		primary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true},
		secondary = {},
		disallow = {non_combat_armor = true},
		incompatible = {fire_protection = true, protection = true, projectile_protection = true},
		weight = 2,
		description = "Reduces explosion damage and knockback."
	},
	-- unimplemented
	curse_of_binding = {
		name = "Curse of Binding",
		max_level = 1,
		primary = {},
		secondary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true},
		disallow = {},
		incompatible = {},
		weight = 1,
		description = "Except when in creative mode, items cannot be removed from armor slots except due to death or breaking."
	},
	-- unimplemented
	curse_of_vanishing = {
		name = "Curse of Vanishing",
		max_level = 1,
		primary = {},
		secondary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true, tool = true, weapon = true},
		disallow = {clock = true},
		incompatible = {},
		weight = 1,
		description = "Except when in creative mode, items cannot be removed from armor slots except due to death or breaking."
	},
	-- unimplemented
	depth_strider = {
		name = "Depth Strider",
		max_level = 3,
		primary = {},
		secondary = {armor_feet = true},
		disallow = {non_combat_armor = true},
		incompatible = {frost_walker = true},
		weight = 2,
		description = "Increases underwater movement speed."
	},
	-- unimplemented
	efficiency = {
		name = "Efficiency",
		max_level = 5,
		primary = {pickaxe = true, shovel = true, axe = true, hoe = true},
		secondary = {shears = true},
		disallow = {},
		incompatible = {},
		weight = 10,
		description = "Increases mining speed."
	},
	-- unimplemented
	feather_falling = {
		name = "Feather Falling",
		max_level = 4,
		primary = {armor_feet = true},
		secondary = {},
		disallow = {non_combat_armor = true},
		incompatible = {},
		weight = 5,
		description = "Reduces fall damage."
	},
	-- unimplemented
	fire_aspect = {
		name = "Fire Aspect",
		max_level = 2,
		primary = {sword = true},
		secondary = {},
		disallow = {},
		incompatible = {},
		weight = 2,
		description = "Sets target on fire."
	},
	-- unimplemented
	fire_protection = {
		name = "Fire Protection",
		max_level = 4,
		primary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true},
		secondary = {},
		disallow = {non_combat_armor = true},
		incompatible = {blast_protection = true, protection = true, projectile_protection = true},
		weight = 5,
		description = "Reduces fire damage."
	},
	-- unimplemented
	flame = {
		name = "Flame",
		max_level = 1,
		primary = {bow = true},
		secondary = {},
		disallow = {},
		incompatible = {},
		weight = 2,
		description = "Arrows set target on fire."
	},
	-- unimplemented
	fortune = {
		name = "Fortune",
		max_level = 4,
		primary = {pickaxe = true, shovel = true, axe = true, hoe = true},
		secondary = {},
		disallow = {},
		incompatible = {silk_touch = true},
		weight = 2,
		description = "Increases certain block drops."
	},
	-- unimplemented
	frost_walker = {
		name = "Frost Walker",
		max_level = 2,
		primary = {},
		secondary = {armor_feet = true},
		disallow = {non_combat_armor = true},
		incompatible = {depth_strider = true},
		weight = 2,
		description = "Turns water beneath the player into frosted ice and prevents the damage the player would take from standing on magma blocks."
	},
	-- unimplemented
	infinity = {
		name = "Infinity",
		max_level = 1,
		primary = {bow = true},
		secondary = {},
		disallow = {},
		incompatible = {mending = true},
		weight = 1,
		description = "Shooting consumes no regular arrows."
	},
	-- unimplemented
	knockback = {
		name = "Knockback",
		max_level = 2,
		primary = {sword = true},
		secondary = {},
		disallow = {},
		incompatible = {},
		weight = 5,
		description = "Increases knockback."
	},
	-- unimplemented
	looting = {
		name = "Looting",
		max_level = 3,
		primary = {sword = true},
		secondary = {},
		disallow = {},
		incompatible = {},
		weight = 2,
		description = "Increases mob loot."
	},
	-- unimplemented
	luck_of_the_sea = {
		name = "Luck of the Sea",
		max_level = 3,
		primary = {fishing_rod = true},
		secondary = {},
		disallow = {},
		incompatible = {},
		weight = 2,
		description = "Increases rate of good loot (enchanting books, etc.)"
	},
	-- unimplemented
	lure = {
		name = "Lure",
		max_level = 3,
		primary = {fishing_rod = true},
		secondary = {},
		disallow = {},
		incompatible = {},
		weight = 2,
		description = "Decreases wait time until fish/junk/loot \"bites\"."
	},
	-- unimplemented
	mending = {
		name = "Mending",
		max_level = 1,
		primary = {},
		secondary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true, tool = true, weapon = true},
		disallow = {non_combat_armor = true, compass = true, clock = true},
		incompatible = {infinity = true},
		weight = 2,
		description = "Repair the item while gaining XP orbs."
	},
	-- unimplemented
	power = {
		name = "Power",
		max_level = 5,
		primary = {},
		secondary = {bow = true},
		disallow = {},
		incompatible = {},
		weight = 10,
		description = "Increases arrow damage."
	},
	-- unimplemented
	projectile_protection = {
		name = "Projectile Protection",
		max_level = 4,
		primary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true},
		secondary = {},
		disallow = {non_combat_armor = true},
		incompatible = {blast_protection = true, fire_protection = true, protection = true},
		weight = 5,
		description = "Reduces projectile damage."
	},
	-- unimplemented
	protection = {
		name = "Protection",
		max_level = 4,
		primary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true},
		secondary = {},
		disallow = {non_combat_armor = true},
		incompatible = {blast_protection = true, fire_protection = true, projectile_protection = true},
		weight = 10,
		description = "Reduces most types of damage by 4% for each level."
	},
	-- unimplemented
	punch = {
		name = "Punch",
		max_level = 2,
		primary = {},
		secondary = {bow = true},
		disallow = {},
		incompatible = {},
		weight = 2,
		description = "Increases arrow knockback."
	},
	-- unimplemented
	respiration = {
		name = "Respiration",
		max_level = 3,
		primary = {armor_head = true},
		secondary = {},
		disallow = {non_combat_armor = true},
		incompatible = {},
		weight = 2,
		description = "Extends underwater breathing time."
	},
	-- unimplemented
	sharpness = {
		name = "Sharpness",
		max_level = 5,
		primary = {sword = true},
		secondary = {axe = true},
		disallow = {},
		incompatible = {bane_of_anthropods = true, smite = true},
		weight = 5,
		description = "Increases damage and applies Slowness IV to arthropod mobs (spiders, cave spiders, silverfish and endermites)."
	},
	-- unimplemented
	silk_touch = {
		name = "Silk Touch",
		max_level = 1,
		primary = {pickaxe = true, shovel = true, axe = true, hoe = true},
		secondary = {shears = true},
		disallow = {},
		incompatible = {fortune = true},
		weight = 1,
		description = "Mined blocks drop themselves."
	},
	-- unimplemented
	smite = {
		name = "Smite",
		max_level = 5,
		primary = {sword = true},
		secondary = {axe = true},
		disallow = {},
		incompatible = {bane_of_anthropods = true, sharpness = true},
		weight = 5,
		description = "Increases damage to undead mobs."
	},
	-- unimplemented
	soul_speed = {
		name = "Soul Speed",
		max_level = 3,
		primary = {},
		secondary = {armor_feet = true},
		disallow = {non_combat_armor = true},
		incompatible = {frost_walker = true},
		weight = 2,
		description = "Incerases walking speed on soul sand."
	},
	-- unimplemented
	sweeping_edge = {
		name = "Sweeping Edge",
		max_level = 3,
		primary = {sword = true},
		secondary = {},
		disallow = {},
		incompatible = {},
		weight = 2,
		description = "Increases sweeping attack damage."
	},
	-- unimplemented
	thorns = {
		name = "Thorns",
		max_level = 3,
		primary = {armor_head = true},
		secondary = {armor_torso = true, armor_legs = true, armor_feet = true},
		disallow = {non_combat_armor = true},
		incompatible = {blast_protection = true, fire_protection = true, projectile_protection = true},
		weight = 1,
		description = "Reflects some of the damage taken when hit, at the cost of reducing durability with each proc."
	},
	-- unimplemented
	unbreaking = {
		name = "Unbreaking",
		max_level = 3,
		primary = {armor_head = true, armor_torso = true, armor_legs = true, armor_feet = true, pickaxe = true, shovel = true, axe = true, hoe = true, sword = true, fishing_rod = true, bow = true},
		secondary = {tool = true},
		disallow = {non_combat_armor = true},
		incompatible = {},
		weight = 5,
		description = "Increases item durability."
	},
}
