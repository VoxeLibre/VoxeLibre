-- mods/default/crafting.lua

--
-- Crafting definition
--

minetest.register_craft({
	output = 'default:wood 4',
	recipe = {
		{'default:tree'},
	}
})

minetest.register_craft({
	output = 'default:junglewood 4',
	recipe = {
		{'default:jungletree'},
	}
})

minetest.register_craft({
	output = 'default:acaciawood 4',
	recipe = {
		{'default:acaciatree'},
	}
})

minetest.register_craft({
	output = 'default:sprucewood 4',
	recipe = {
		{'default:sprucetree'},
	}
})



minetest.register_craft({
	output = 'default:mossycobble',
	recipe = {
		{'default:cobble', 'default:vine'},
	}
})

minetest.register_craft({
	output = 'default:stonebrickmossy',
	recipe = {
		{'default:stonebrick', 'default:vine'},
	}
})

minetest.register_craft({
	output = 'default:coarse_dirt 4',
	recipe = {
		{'default:dirt', 'default:gravel'},
		{'default:gravel', 'default:dirt'},
	}
})

minetest.register_craft({
	output = 'default:sandstonesmooth 4',
	recipe = {
		{'default:sandstone','default:sandstone'},
		{'default:sandstone','default:sandstone'},
	}
})

minetest.register_craft({
	output = 'default:redsandstonesmooth 4',
	recipe = {
		{'default:redsandstone','default:redsandstone'},
		{'default:redsandstone','default:redsandstone'},
	}
})

minetest.register_craft({
	output = 'default:stick 4',
	recipe = {
		{'group:wood'},
		{'group:wood'},
	}
})

minetest.register_craft({
	output = 'fences:fence_wood 2',
	recipe = {
		{'default:stick', 'default:stick', 'default:stick'},
		{'default:stick', 'default:stick', 'default:stick'},
	}
})

minetest.register_craft({
	output = 'signs:sign_wall',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
		{'', 'default:stick', ''},
	}
})

minetest.register_craft({
	output = 'default:pick_wood',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'', 'default:stick', ''},
		{'', 'default:stick', ''},
	}
})

minetest.register_craft({
	output = 'default:pick_stone',
	recipe = {
		{'default:cobble', 'default:cobble', 'default:cobble'},
		{'', 'default:stick', ''},
		{'', 'default:stick', ''},
	}
})

minetest.register_craft({
	output = 'default:pick_steel',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'', 'default:stick', ''},
		{'', 'default:stick', ''},
	}
})

minetest.register_craft({
	output = 'default:pick_gold',
	recipe = {
		{'default:gold_ingot', 'default:gold_ingot', 'default:gold_ingot'},
		{'', 'default:stick', ''},
		{'', 'default:stick', ''},
	}
})

minetest.register_craft({
	output = 'default:pick_diamond',
	recipe = {
		{'default:diamond', 'default:diamond', 'default:diamond'},
		{'', 'default:stick', ''},
		{'', 'default:stick', ''},
	}
})

minetest.register_craft({
	output = 'default:shovel_wood',
	recipe = {
		{'group:wood'},
		{'default:stick'},
		{'default:stick'},
	}
})

minetest.register_craft({
	output = 'default:shovel_stone',
	recipe = {
		{'default:cobble'},
		{'default:stick'},
		{'default:stick'},
	}
})

minetest.register_craft({
	output = 'default:shovel_steel',
	recipe = {
		{'default:steel_ingot'},
		{'default:stick'},
		{'default:stick'},
	}
})

minetest.register_craft({
	output = 'default:shovel_gold',
	recipe = {
		{'default:gold_ingot'},
		{'default:stick'},
		{'default:stick'},
	}
})

minetest.register_craft({
	output = 'default:shovel_diamond',
	recipe = {
		{'default:diamond'},
		{'default:stick'},
		{'default:stick'},
	}
})

minetest.register_craft({
	output = 'default:axe_wood',
	recipe = {
		{'group:wood', 'group:wood'},
		{'group:wood', 'default:stick'},
		{'', 'default:stick'},
	}
})

minetest.register_craft({
	output = 'default:axe_stone',
	recipe = {
		{'default:cobble', 'default:cobble'},
		{'default:cobble', 'default:stick'},
		{'', 'default:stick'},
	}
})

minetest.register_craft({
	output = 'default:axe_steel',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:stick'},
		{'', 'default:stick'},
	}
})

minetest.register_craft({
	output = 'default:axe_gold',
	recipe = {
		{'default:gold_ingot', 'default:gold_ingot'},
		{'default:gold_ingot', 'default:stick'},
		{'', 'default:stick'},
	}
})

minetest.register_craft({
	output = 'default:axe_diamond',
	recipe = {
		{'default:diamond', 'default:diamond'},
		{'default:diamond', 'default:stick'},
		{'', 'default:stick'},
	}
})

minetest.register_craft({
	output = 'default:sword_wood',
	recipe = {
		{'group:wood'},
		{'group:wood'},
		{'default:stick'},
	}
})

minetest.register_craft({
	output = 'default:sword_stone',
	recipe = {
		{'default:cobble'},
		{'default:cobble'},
		{'default:stick'},
	}
})

minetest.register_craft({
	output = 'default:sword_steel',
	recipe = {
		{'default:steel_ingot'},
		{'default:steel_ingot'},
		{'default:stick'},
	}
})

minetest.register_craft({
	output = 'default:sword_gold',
	recipe = {
		{'default:gold_ingot'},
		{'default:gold_ingot'},
		{'default:stick'},
	}
})

minetest.register_craft({
	output = 'default:sword_diamond',
	recipe = {
		{'default:diamond'},
		{'default:diamond'},
		{'default:stick'},
	}
})

minetest.register_craft({
	output = 'default:flint_and_steel',
	recipe = {
		{'default:steel_ingot', ''},
		{'', 'default:flint'},
	}
})

minetest.register_craft({
	output = "default:pole",
	recipe = {
		{'','','default:stick'},
		{'','default:stick','farming:string'},
		{'default:stick','','farming:string'},
	}
})

minetest.register_craft({
	output = 'default:rail 15',
	recipe = {
		{'default:steel_ingot', '', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:stick', 'default:steel_ingot'},
		{'default:steel_ingot', '', 'default:steel_ingot'},
	}
})

minetest.register_craft({
	output = 'default:chest',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', '', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

minetest.register_craft({
	output = 'default:furnace',
	recipe = {
		{'default:cobble', 'default:cobble', 'default:cobble'},
		{'default:cobble', '', 'default:cobble'},
		{'default:cobble', 'default:cobble', 'default:cobble'},
	}
})

minetest.register_craft({
	output = 'default:haybale',
	recipe = {
		{'farming:wheat_harvested', 'farming:wheat_harvested', 'farming:wheat_harvested'},
		{'farming:wheat_harvested', 'farming:wheat_harvested', 'farming:wheat_harvested'},
		{'farming:wheat_harvested', 'farming:wheat_harvested', 'farming:wheat_harvested'},
	}
})

minetest.register_craft({
	output = 'farming:wheat_harvested 9',
	recipe = {
		{'default:haybale'},
	}
})

minetest.register_craft({
	output = 'default:sea_lantern',
	recipe = {
		{'default:prismarine_shard', 'default:prismarine_cry', 'default:prismarine_shard'},
		{'default:prismarine_cry', 'default:prismarine_cry', 'default:prismarine_cry'},
		{'default:prismarine_shard', 'default:prismarine_cry', 'default:prismarine_shard'},
	}
})

minetest.register_craft({
	output = 'default:prismarine',
	recipe = {
		{'default:prismarine_shard', 'default:prismarine_shard'},
		{'default:prismarine_shard', 'default:prismarine_shard'},
	}
})

minetest.register_craft({
	output = 'default:prismarine_brick',
	recipe = {
		{'default:prismarine_shard', 'default:prismarine_shard', 'default:prismarine_shard'},
		{'default:prismarine_shard', 'default:prismarine_shard', 'default:prismarine_shard'},
		{'default:prismarine_shard', 'default:prismarine_shard', 'default:prismarine_shard'},
	}
})

minetest.register_craft({
	output = 'default:prismarine_dark',
	recipe = {
		{'default:prismarine_shard', 'default:prismarine_shard', 'default:prismarine_shard'},
		{'default:prismarine_shard', 'dye:black', 'default:prismarine_shard'},
		{'default:prismarine_shard', 'default:prismarine_shard', 'default:prismarine_shard'},
	}
})

minetest.register_craft({
	output = 'default:coalblock',
	recipe = {
		{'default:coal_lump', 'default:coal_lump', 'default:coal_lump'},
		{'default:coal_lump', 'default:coal_lump', 'default:coal_lump'},
		{'default:coal_lump', 'default:coal_lump', 'default:coal_lump'},
	}
})

minetest.register_craft({
	output = 'default:coal_lump 9',
	recipe = {
		{'default:coalblock'},
	}
})

minetest.register_craft({
	output = 'default:steelblock',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
	}
})

minetest.register_craft({
	output = 'default:steel_ingot 9',
	recipe = {
		{'default:steelblock'},
	}
})

minetest.register_craft({
	output = 'default:goldblock',
	recipe = {
		{'default:gold_ingot', 'default:gold_ingot', 'default:gold_ingot'},
		{'default:gold_ingot', 'default:gold_ingot', 'default:gold_ingot'},
		{'default:gold_ingot', 'default:gold_ingot', 'default:gold_ingot'},
	}
})

minetest.register_craft({
	output = 'default:gold_ingot 9',
	recipe = {
		{'default:goldblock'},
	}
})

minetest.register_craft({
	output = "default:gold_nugget 9",
	recipe = {{"default:gold_ingot"}},
})

minetest.register_craft({
	output = "default:iron_nugget 9",
	recipe = {{"default:steel_ingot"}},
})

minetest.register_craft({
	output = 'default:sandstone',
	recipe = {
		{'default:sand', 'default:sand'},
		{'default:sand', 'default:sand'},
	}
})

minetest.register_craft({
	output = 'default:redsandstone',
	recipe = {
		{'default:redsand', 'default:redsand'},
		{'default:redsand', 'default:redsand'},
	}
})

minetest.register_craft({
	output = 'default:clay',
	recipe = {
		{'default:clay_lump', 'default:clay_lump'},
		{'default:clay_lump', 'default:clay_lump'},
	}
})

minetest.register_craft({
	output = 'default:brick',
	recipe = {
		{'default:clay_brick', 'default:clay_brick'},
		{'default:clay_brick', 'default:clay_brick'},
	}
})

minetest.register_craft({
	output = 'default:clay_brick 4',
	recipe = {
		{'default:brick'},
	}
})

minetest.register_craft({
	output = 'default:paper 3',
	recipe = {
		{'default:reeds', 'default:reeds', 'default:reeds'},
	}
})

minetest.register_craft({
	output = 'default:book',
	recipe = {
		{'default:paper'},
		{'default:paper'},
		{'default:paper'},
	}
})

minetest.register_craft({
	output = 'default:bookshelf',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'default:book', 'default:book', 'default:book'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

minetest.register_craft({
	output = 'default:ladder',
	recipe = {
		{'default:stick', '', 'default:stick'},
		{'default:stick', 'default:stick', 'default:stick'},
		{'default:stick', '', 'default:stick'},
	}
})

minetest.register_craft({
	output = 'default:stonebrick',
	recipe = {
		{'default:stone', 'default:stone'},
		{'default:stone', 'default:stone'},
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "default:gunpowder",
	recipe = {
		'default:sand',
		'default:gravel',
	}
})

minetest.register_craft({
	output = 'dye:white 3',
	recipe = {
		{'default:bone'},
	}
})

minetest.register_craft({
	output = 'default:lapisblock',
	recipe = {
		{'dye:blue', 'dye:blue', 'dye:blue'},
		{'dye:blue', 'dye:blue', 'dye:blue'},
		{'dye:blue', 'dye:blue', 'dye:blue'},
	}
})

minetest.register_craft({
	output = 'dye:blue 9',
	recipe = {
		{'default:lapisblock'},
	}
})

minetest.register_craft({
	output = "default:emeraldblock",
	recipe = {
		{'default:emerald', 'default:emerald', 'default:emerald'},
		{'default:emerald', 'default:emerald', 'default:emerald'},
		{'default:emerald', 'default:emerald', 'default:emerald'},
	}
})

minetest.register_craft({
	output = 'default:emerald 9',
	recipe = {
		{'default:emeraldblock'},
	}
})

minetest.register_craft({
	output = "default:glowstone",
	recipe = {
		{'default:glowstone_dust', 'default:glowstone_dust'},
		{'default:glowstone_dust', 'default:glowstone_dust'},
	}
})

minetest.register_craft({
	output = 'default:glowstone_dust 4',
	recipe = {
		{'default:glowstone'},
	}
})

minetest.register_craft({
	output = "default:apple_gold",
	recipe = {
		{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"},
		{"default:gold_ingot", 'default:apple', "default:gold_ingot"},
		{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"},
	}
})

minetest.register_craft({
	output = "default:sugar",
	recipe = {
		{"default:reeds"},
	}
})

minetest.register_craft({
	output = 'default:snowblock',
	recipe = {
		{'default:snowball', 'default:snowball'},
		{'default:snowball', 'default:snowball'},
	}
})

minetest.register_craft({
	output = 'default:snow 6',
	recipe = {
		{'default:snowblock', 'default:snowblock', 'default:snowblock'},
	}
})

minetest.register_craft({
	output = 'default:quartz_block',
	recipe = {
		{'default:quartz_crystal', 'default:quartz_crystal'},
		{'default:quartz_crystal', 'default:quartz_crystal'},
	}
})
	
minetest.register_craft({
	output = 'default:quartz_chiseled 2',
	recipe = {
		{'stairs:slab_quartzblock'},
		{'stairs:slab_quartzblock'},
	}
})

minetest.register_craft({
	output = 'default:quartz_pillar 2',
	recipe = {
		{'default:quartz_block'},
		{'default:quartz_block'},
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
	output = "default:glass",
	recipe = "group:sand",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:stone",
	recipe = "default:cobble",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:steel_ingot",
	recipe = "default:stone_with_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:gold_ingot",
	recipe = "default:stone_with_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:clay_brick",
	recipe = "default:clay_lump",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:fish",
	recipe = "default:fish_raw",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:charcoal_lump",
	recipe = "group:tree",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:sponge",
	recipe = "default:sponge_wet",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:coal_lump",
	recipe = "default:stone_with_coal",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:diamond",
	recipe = "default:stone_with_diamond",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:emerald",
	recipe = "default:stone_with_emerald",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "dye:blue",
	recipe = "default:stone_with_lapis",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:gold_nugget",
	recipe = "default:sword_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:gold_nugget",
	recipe = "default:axe_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:gold_nugget",
	recipe = "default:shovel_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:gold_nugget",
	recipe = "default:pick_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:iron_nugget",
	recipe = "default:sword_steel",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:iron_nugget",
	recipe = "default:axe_steel",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:iron_nugget",
	recipe = "default:shovel_steel",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "default:iron_nugget",
	recipe = "default:pick_steel",
	cooktime = 10,
})



--
-- Fuels
--

minetest.register_craft({
	type = "fuel",
	recipe = "default:coalblock",
	burntime = 800,
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:coal_lump",
	burntime = 80,
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:charcoal_lump",
	burntime = 80,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:tree",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:bookshelf",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:fence_wood",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:ladder",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:wood",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "signs:sign_wall",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:chest",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:sapling",
	burntime = 5,
})

--
--Temporary
--
minetest.register_craft({
	output = "default:string",
	recipe = {{"default:paper", "default:paper"}},
})
