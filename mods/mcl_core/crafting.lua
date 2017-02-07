-- mods/default/crafting.lua

--
-- Crafting definition
--

minetest.register_craft({
	output = 'mcl_core:wood 4',
	recipe = {
		{'mcl_core:tree'},
	}
})

minetest.register_craft({
	output = 'mcl_core:darkwood 4',
	recipe = {
		{'mcl_core:darktree'},
	}
})

minetest.register_craft({
	output = 'mcl_core:junglewood 4',
	recipe = {
		{'mcl_core:jungletree'},
	}
})

minetest.register_craft({
	output = 'mcl_core:acaciawood 4',
	recipe = {
		{'mcl_core:acaciatree'},
	}
})

minetest.register_craft({
	output = 'mcl_core:sprucewood 4',
	recipe = {
		{'mcl_core:sprucetree'},
	}
})

minetest.register_craft({
	output = 'mcl_core:birchwood 4',
	recipe = {
		{'mcl_core:birchtree'},
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'mcl_core:mossycobble',
	recipe = { 'mcl_core:cobble', 'mcl_core:vine' },
})

minetest.register_craft({
	type = 'shapeless',
	output = 'mcl_core:stonebrickmossy',
	recipe = { 'mcl_core:stonebrick', 'mcl_core:vine' },
})

minetest.register_craft({
	output = 'mcl_core:coarse_dirt 4',
	recipe = {
		{'mcl_core:dirt', 'mcl_core:gravel'},
		{'mcl_core:gravel', 'mcl_core:dirt'},
	}
})
minetest.register_craft({
	output = 'mcl_core:coarse_dirt 4',
	recipe = {
		{'mcl_core:gravel', 'mcl_core:dirt'},
		{'mcl_core:dirt', 'mcl_core:gravel'},
	}
})

minetest.register_craft({
	output = 'mcl_core:sandstonesmooth 4',
	recipe = {
		{'mcl_core:sandstone','mcl_core:sandstone'},
		{'mcl_core:sandstone','mcl_core:sandstone'},
	}
})

minetest.register_craft({
	output = 'mcl_core:redsandstonesmooth 4',
	recipe = {
		{'mcl_core:redsandstone','mcl_core:redsandstone'},
		{'mcl_core:redsandstone','mcl_core:redsandstone'},
	}
})

minetest.register_craft({
	output = 'mcl_core:granite_smooth 4',
	recipe = {
		{'mcl_core:granite', 'mcl_core:granite'},
		{'mcl_core:granite', 'mcl_core:granite'}
	},
})

minetest.register_craft({
	output = 'mcl_core:andesite_smooth 4',
	recipe = {
		{'mcl_core:andesite', 'mcl_core:andesite'},
		{'mcl_core:andesite', 'mcl_core:andesite'}
	},
})

minetest.register_craft({
	output = 'mcl_core:diorite_smooth 4',
	recipe = {
		{'mcl_core:diorite', 'mcl_core:diorite'},
		{'mcl_core:diorite', 'mcl_core:diorite'}
	},
})

minetest.register_craft({
	type = "shapeless",
	output = 'mcl_core:granite',
	recipe = {'mcl_core:diorite', 'mcl_core:quartz_crystal'},
})

minetest.register_craft({
	type = "shapeless",
	output = 'mcl_core:andesite 2',
	recipe = {'mcl_core:diorite', 'mcl_core:cobble'},
})

minetest.register_craft({
	output = 'mcl_core:diorite 2',
	recipe = {
		{'mcl_core:cobble', 'mcl_core:quartz_crystal'},
		{'mcl_core:quartz_crystal', 'mcl_core:cobble'},
	}
})
minetest.register_craft({
	output = 'mcl_core:diorite 2',
	recipe = {
		{'mcl_core:quartz_crystal', 'mcl_core:cobble'},
		{'mcl_core:cobble', 'mcl_core:quartz_crystal'},
	}
})

minetest.register_craft({
	output = "mcl_core:bone_block",
	recipe = {
		{ "mcl_dye:white", "mcl_dye:white", "mcl_dye:white" },
		{ "mcl_dye:white", "mcl_dye:white", "mcl_dye:white" },
		{ "mcl_dye:white", "mcl_dye:white", "mcl_dye:white" },
	},
})

minetest.register_craft({
	output = "mcl_dye:white 9",
	recipe = {
		{ "mcl_core:bone_block" },
	},
})

minetest.register_craft({
	output = 'mcl_core:stick 4',
	recipe = {
		{'group:wood'},
		{'group:wood'},
	}
})

minetest.register_craft({
	output = 'signs:sign_wall 3',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
		{'', 'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_core:pick_wood',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'', 'mcl_core:stick', ''},
		{'', 'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_core:pick_stone',
	recipe = {
		{'mcl_core:cobble', 'mcl_core:cobble', 'mcl_core:cobble'},
		{'', 'mcl_core:stick', ''},
		{'', 'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_core:pick_steel',
	recipe = {
		{'mcl_core:steel_ingot', 'mcl_core:steel_ingot', 'mcl_core:steel_ingot'},
		{'', 'mcl_core:stick', ''},
		{'', 'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_core:pick_gold',
	recipe = {
		{'mcl_core:gold_ingot', 'mcl_core:gold_ingot', 'mcl_core:gold_ingot'},
		{'', 'mcl_core:stick', ''},
		{'', 'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_core:pick_diamond',
	recipe = {
		{'mcl_core:diamond', 'mcl_core:diamond', 'mcl_core:diamond'},
		{'', 'mcl_core:stick', ''},
		{'', 'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_core:shovel_wood',
	recipe = {
		{'group:wood'},
		{'mcl_core:stick'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_core:shovel_stone',
	recipe = {
		{'mcl_core:cobble'},
		{'mcl_core:stick'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_core:shovel_steel',
	recipe = {
		{'mcl_core:steel_ingot'},
		{'mcl_core:stick'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_core:shovel_gold',
	recipe = {
		{'mcl_core:gold_ingot'},
		{'mcl_core:stick'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_core:shovel_diamond',
	recipe = {
		{'mcl_core:diamond'},
		{'mcl_core:stick'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_core:axe_wood',
	recipe = {
		{'group:wood', 'group:wood'},
		{'group:wood', 'mcl_core:stick'},
		{'', 'mcl_core:stick'},
	}
})
minetest.register_craft({
	output = 'mcl_core:axe_wood',
	recipe = {
		{'group:wood', 'group:wood'},
		{'mcl_core:stick', 'group:wood'},
		{'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_core:axe_stone',
	recipe = {
		{'mcl_core:cobble', 'mcl_core:cobble'},
		{'mcl_core:cobble', 'mcl_core:stick'},
		{'', 'mcl_core:stick'},
	}
})
minetest.register_craft({
	output = 'mcl_core:axe_stone',
	recipe = {
		{'mcl_core:cobble', 'mcl_core:cobble'},
		{'mcl_core:stick', 'mcl_core:cobble'},
		{'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_core:axe_steel',
	recipe = {
		{'mcl_core:steel_ingot', 'mcl_core:steel_ingot'},
		{'mcl_core:steel_ingot', 'mcl_core:stick'},
		{'', 'mcl_core:stick'},
	}
})
minetest.register_craft({
	output = 'mcl_core:axe_steel',
	recipe = {
		{'mcl_core:steel_ingot', 'mcl_core:steel_ingot'},
		{'mcl_core:stick', 'mcl_core:steel_ingot'},
		{'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_core:axe_gold',
	recipe = {
		{'mcl_core:gold_ingot', 'mcl_core:gold_ingot'},
		{'mcl_core:gold_ingot', 'mcl_core:stick'},
		{'', 'mcl_core:stick'},
	}
})
minetest.register_craft({
	output = 'mcl_core:axe_gold',
	recipe = {
		{'mcl_core:gold_ingot', 'mcl_core:gold_ingot'},
		{'mcl_core:stick', 'mcl_core:gold_ingot'},
		{'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_core:axe_diamond',
	recipe = {
		{'mcl_core:diamond', 'mcl_core:diamond'},
		{'mcl_core:diamond', 'mcl_core:stick'},
		{'', 'mcl_core:stick'},
	}
})
minetest.register_craft({
	output = 'mcl_core:axe_diamond',
	recipe = {
		{'mcl_core:diamond', 'mcl_core:diamond'},
		{'mcl_core:stick', 'mcl_core:diamond'},
		{'mcl_core:stick', ''},
	}
})

minetest.register_craft({
	output = 'mcl_core:sword_wood',
	recipe = {
		{'group:wood'},
		{'group:wood'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_core:sword_stone',
	recipe = {
		{'mcl_core:cobble'},
		{'mcl_core:cobble'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_core:sword_steel',
	recipe = {
		{'mcl_core:steel_ingot'},
		{'mcl_core:steel_ingot'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_core:sword_gold',
	recipe = {
		{'mcl_core:gold_ingot'},
		{'mcl_core:gold_ingot'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_core:sword_diamond',
	recipe = {
		{'mcl_core:diamond'},
		{'mcl_core:diamond'},
		{'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_core:shears',
	recipe = {
		{ 'mcl_core:steel_ingot', '' },
		{ '', 'mcl_core:steel_ingot', },
	}
})
minetest.register_craft({
	output = 'mcl_core:shears',
	recipe = {
		{ '', 'mcl_core:steel_ingot', },
		{ 'mcl_core:steel_ingot', '' },
	}
})

minetest.register_craft({
	output = 'mcl_core:rail 16',
	recipe = {
		{'mcl_core:steel_ingot', '', 'mcl_core:steel_ingot'},
		{'mcl_core:steel_ingot', 'mcl_core:stick', 'mcl_core:steel_ingot'},
		{'mcl_core:steel_ingot', '', 'mcl_core:steel_ingot'},
	}
})

minetest.register_craft({
	output = 'mcl_core:haybale',
	recipe = {
		{'mcl_farming:wheat_harvested', 'mcl_farming:wheat_harvested', 'mcl_farming:wheat_harvested'},
		{'mcl_farming:wheat_harvested', 'mcl_farming:wheat_harvested', 'mcl_farming:wheat_harvested'},
		{'mcl_farming:wheat_harvested', 'mcl_farming:wheat_harvested', 'mcl_farming:wheat_harvested'},
	}
})

minetest.register_craft({
	output = 'mcl_farming:wheat_harvested 9',
	recipe = {
		{'mcl_core:haybale'},
	}
})

minetest.register_craft({
	output = 'mcl_core:sea_lantern',
	recipe = {
		{'mcl_core:prismarine_shard', 'mcl_core:prismarine_crystals', 'mcl_core:prismarine_shard'},
		{'mcl_core:prismarine_crystals', 'mcl_core:prismarine_crystals', 'mcl_core:prismarine_crystals'},
		{'mcl_core:prismarine_shard', 'mcl_core:prismarine_crystals', 'mcl_core:prismarine_shard'},
	}
})

minetest.register_craft({
	output = 'mcl_core:prismarine',
	recipe = {
		{'mcl_core:prismarine_shard', 'mcl_core:prismarine_shard'},
		{'mcl_core:prismarine_shard', 'mcl_core:prismarine_shard'},
	}
})

minetest.register_craft({
	output = 'mcl_core:prismarine_brick',
	recipe = {
		{'mcl_core:prismarine_shard', 'mcl_core:prismarine_shard', 'mcl_core:prismarine_shard'},
		{'mcl_core:prismarine_shard', 'mcl_core:prismarine_shard', 'mcl_core:prismarine_shard'},
		{'mcl_core:prismarine_shard', 'mcl_core:prismarine_shard', 'mcl_core:prismarine_shard'},
	}
})

minetest.register_craft({
	output = 'mcl_core:prismarine_dark',
	recipe = {
		{'mcl_core:prismarine_shard', 'mcl_core:prismarine_shard', 'mcl_core:prismarine_shard'},
		{'mcl_core:prismarine_shard', 'mcl_dye:black', 'mcl_core:prismarine_shard'},
		{'mcl_core:prismarine_shard', 'mcl_core:prismarine_shard', 'mcl_core:prismarine_shard'},
	}
})

minetest.register_craft({
	output = 'mcl_core:coalblock',
	recipe = {
		{'mcl_core:coal_lump', 'mcl_core:coal_lump', 'mcl_core:coal_lump'},
		{'mcl_core:coal_lump', 'mcl_core:coal_lump', 'mcl_core:coal_lump'},
		{'mcl_core:coal_lump', 'mcl_core:coal_lump', 'mcl_core:coal_lump'},
	}
})

minetest.register_craft({
	output = 'mcl_core:coal_lump 9',
	recipe = {
		{'mcl_core:coalblock'},
	}
})

minetest.register_craft({
	output = 'mcl_core:steelblock',
	recipe = {
		{'mcl_core:steel_ingot', 'mcl_core:steel_ingot', 'mcl_core:steel_ingot'},
		{'mcl_core:steel_ingot', 'mcl_core:steel_ingot', 'mcl_core:steel_ingot'},
		{'mcl_core:steel_ingot', 'mcl_core:steel_ingot', 'mcl_core:steel_ingot'},
	}
})

minetest.register_craft({
	output = 'mcl_core:steel_ingot 9',
	recipe = {
		{'mcl_core:steelblock'},
	}
})

minetest.register_craft({
	output = 'mcl_core:goldblock',
	recipe = {
		{'mcl_core:gold_ingot', 'mcl_core:gold_ingot', 'mcl_core:gold_ingot'},
		{'mcl_core:gold_ingot', 'mcl_core:gold_ingot', 'mcl_core:gold_ingot'},
		{'mcl_core:gold_ingot', 'mcl_core:gold_ingot', 'mcl_core:gold_ingot'},
	}
})

minetest.register_craft({
	output = 'mcl_core:gold_ingot 9',
	recipe = {
		{'mcl_core:goldblock'},
	}
})

minetest.register_craft({
	output = "mcl_core:gold_nugget 9",
	recipe = {{"mcl_core:gold_ingot"}},
})

minetest.register_craft({
	output = "mcl_core:iron_nugget 9",
	recipe = {{"mcl_core:steel_ingot"}},
})

minetest.register_craft({
	output = "mcl_core:gold_ingot",
	recipe = {
		{"mcl_core:gold_nugget", "mcl_core:gold_nugget", "mcl_core:gold_nugget"},
		{"mcl_core:gold_nugget", "mcl_core:gold_nugget", "mcl_core:gold_nugget"},
		{"mcl_core:gold_nugget", "mcl_core:gold_nugget", "mcl_core:gold_nugget"},
	}
})

minetest.register_craft({
	output = "mcl_core:steel_ingot",
	recipe = {
		{"mcl_core:iron_nugget", "mcl_core:iron_nugget", "mcl_core:iron_nugget"},
		{"mcl_core:iron_nugget", "mcl_core:iron_nugget", "mcl_core:iron_nugget"},
		{"mcl_core:iron_nugget", "mcl_core:iron_nugget", "mcl_core:iron_nugget"},
	}
})

minetest.register_craft({
	output = 'mcl_core:sandstone',
	recipe = {
		{'mcl_core:sand', 'mcl_core:sand'},
		{'mcl_core:sand', 'mcl_core:sand'},
	}
})

minetest.register_craft({
	output = 'mcl_core:redsandstone',
	recipe = {
		{'mcl_core:redsand', 'mcl_core:redsand'},
		{'mcl_core:redsand', 'mcl_core:redsand'},
	}
})

minetest.register_craft({
	output = 'mcl_core:clay',
	recipe = {
		{'mcl_core:clay_lump', 'mcl_core:clay_lump'},
		{'mcl_core:clay_lump', 'mcl_core:clay_lump'},
	}
})

minetest.register_craft({
	output = 'mcl_core:brick_block',
	recipe = {
		{'mcl_core:brick', 'mcl_core:brick'},
		{'mcl_core:brick', 'mcl_core:brick'},
	}
})

minetest.register_craft({
	output = 'mcl_core:paper 3',
	recipe = {
		{'mcl_core:reeds', 'mcl_core:reeds', 'mcl_core:reeds'},
	}
})

minetest.register_craft({
	output = 'mcl_core:ladder 3',
	recipe = {
		{'mcl_core:stick', '', 'mcl_core:stick'},
		{'mcl_core:stick', 'mcl_core:stick', 'mcl_core:stick'},
		{'mcl_core:stick', '', 'mcl_core:stick'},
	}
})

minetest.register_craft({
	output = 'mcl_core:stonebrick 4',
	recipe = {
		{'mcl_core:stone', 'mcl_core:stone'},
		{'mcl_core:stone', 'mcl_core:stone'},
	}
})

minetest.register_craft({
	output = 'mcl_core:lapisblock',
	recipe = {
		{'mcl_dye:blue', 'mcl_dye:blue', 'mcl_dye:blue'},
		{'mcl_dye:blue', 'mcl_dye:blue', 'mcl_dye:blue'},
		{'mcl_dye:blue', 'mcl_dye:blue', 'mcl_dye:blue'},
	}
})

minetest.register_craft({
	output = 'mcl_dye:blue 9',
	recipe = {
		{'mcl_core:lapisblock'},
	}
})

minetest.register_craft({
	output = "mcl_core:emeraldblock",
	recipe = {
		{'mcl_core:emerald', 'mcl_core:emerald', 'mcl_core:emerald'},
		{'mcl_core:emerald', 'mcl_core:emerald', 'mcl_core:emerald'},
		{'mcl_core:emerald', 'mcl_core:emerald', 'mcl_core:emerald'},
	}
})

minetest.register_craft({
	output = 'mcl_core:emerald 9',
	recipe = {
		{'mcl_core:emeraldblock'},
	}
})

minetest.register_craft({
	output = "mcl_core:diamondblock",
	recipe = {
		{'mcl_core:diamond', 'mcl_core:diamond', 'mcl_core:diamond'},
		{'mcl_core:diamond', 'mcl_core:diamond', 'mcl_core:diamond'},
		{'mcl_core:diamond', 'mcl_core:diamond', 'mcl_core:diamond'},
	}
})

minetest.register_craft({
	output = 'mcl_core:diamond 9',
	recipe = {
		{'mcl_core:diamondblock'},
	}
})

minetest.register_craft({
	output = "mcl_core:glowstone",
	recipe = {
		{'mcl_core:glowstone_dust', 'mcl_core:glowstone_dust'},
		{'mcl_core:glowstone_dust', 'mcl_core:glowstone_dust'},
	}
})

minetest.register_craft({
	output = 'mcl_core:glowstone_dust 4',
	recipe = {
		{'mcl_core:glowstone'},
	}
})

minetest.register_craft({
	output = "mcl_core:apple_gold",
	recipe = {
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot", "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", 'mcl_core:apple', "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot", "mcl_core:gold_ingot"},
	}
})

minetest.register_craft({
	output = "mcl_core:sugar",
	recipe = {
		{"mcl_core:reeds"},
	}
})

minetest.register_craft({
	output = "mcl_core:bowl 4",
	recipe = {
		{"group:wood", "", "group:wood"},
		{"", "group:wood", ""},
	}
})

minetest.register_craft({
	output = 'mcl_core:snowblock',
	recipe = {
		{'mcl_throwing:snowball', 'mcl_throwing:snowball'},
		{'mcl_throwing:snowball', 'mcl_throwing:snowball'},
	}
})

minetest.register_craft({
	output = 'mcl_core:snow 6',
	recipe = {
		{'mcl_core:snowblock', 'mcl_core:snowblock', 'mcl_core:snowblock'},
	}
})

minetest.register_craft({
	output = 'mcl_core:quartz_block',
	recipe = {
		{'mcl_core:quartz_crystal', 'mcl_core:quartz_crystal'},
		{'mcl_core:quartz_crystal', 'mcl_core:quartz_crystal'},
	}
})
	
minetest.register_craft({
	output = 'mcl_core:quartz_chiseled 2',
	recipe = {
		{'stairs:slab_quartzblock'},
		{'stairs:slab_quartzblock'},
	}
})

minetest.register_craft({
	output = 'mcl_core:quartz_pillar 2',
	recipe = {
		{'mcl_core:quartz_block'},
		{'mcl_core:quartz_block'},
	}
})


--
-- Crafting (tool repair)
--
minetest.register_craft({
	type = "toolrepair",
	additional_wear = -0.05,
})

--
-- Cooking recipes
--

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:glass",
	recipe = "group:sand",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:stone",
	recipe = "mcl_core:cobble",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:stonebrickcracked",
	recipe = "mcl_core:stonebrick",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:steel_ingot",
	recipe = "mcl_core:stone_with_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:gold_ingot",
	recipe = "mcl_core:stone_with_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:quartz_crystal",
	recipe = "mcl_core:quartz_ore",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:brick",
	recipe = "mcl_core:clay_lump",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:charcoal_lump",
	recipe = "group:tree",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:sponge",
	recipe = "mcl_core:sponge_wet",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:coal_lump",
	recipe = "mcl_core:stone_with_coal",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:diamond",
	recipe = "mcl_core:stone_with_diamond",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:emerald",
	recipe = "mcl_core:stone_with_emerald",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_dye:blue",
	recipe = "mcl_core:stone_with_lapis",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:gold_nugget",
	recipe = "mcl_core:sword_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:gold_nugget",
	recipe = "mcl_core:axe_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:gold_nugget",
	recipe = "mcl_core:shovel_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:gold_nugget",
	recipe = "mcl_core:pick_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:iron_nugget",
	recipe = "mcl_core:sword_steel",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:iron_nugget",
	recipe = "mcl_core:axe_steel",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:iron_nugget",
	recipe = "mcl_core:shovel_steel",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:iron_nugget",
	recipe = "mcl_core:pick_steel",
	cooktime = 10,
})



--
-- Fuels
--

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_core:coalblock",
	burntime = 800,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_core:coal_lump",
	burntime = 80,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_core:charcoal_lump",
	burntime = 80,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:tree",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_core:ladder",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:wood",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_core:pick_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_core:shovel_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_core:sword_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_core:axe_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:sapling",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_core:bowl",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_core:stick",
	burntime = 5,
})
