minetest.register_node("mcl_nether_gold:nether_gold_ore", {
	description = ("Nether Gold Ore"),
	_doc_items_longdesc = ("Nether gold ore is an ore containing nether gold. It is commonly found around netherrack in the Nether."),
	stack_max = 64,
	tiles = {"mcl_nether_netherrack.png^mcl_nether_gold_ore.png"},
	is_ground_content = true,
	groups = {pickaxey=1, building_block=1, material_stone=1, xp=0},
	drop = {
		max_items = 1,
		items = {
			{items = {'mcl_core:gold_nugget 6'},rarity = 5},
			{items = {'mcl_core:gold_nugget 5'},rarity = 5},
			{items = {'mcl_core:gold_nugget 4'},rarity = 5},
			{items = {'mcl_core:gold_nugget 3'},rarity = 5},
			{items = {'mcl_core:gold_nugget 2'}},
		}
	},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore
})

minetest.register_craft({
	type = "cooking",
	output = 'mcl_core:gold_ingot',
	recipe = 'mcl_nether_gold:nether_gold_ore',
	cooktime = 10,
})

if minetest.settings:get_bool("mcl_generate_ores", true) then
    minetest.register_ore({
        ore_type       = "scatter",
        ore            = "mcl_nether_gold:nether_gold_ore",
        wherein         = {"mcl_nether:netherrack", "mcl_core:stone"},
        clust_scarcity = 850,
        clust_num_ores = 4, -- MC cluster amount: 4-10
        clust_size     = 3,
        y_min = mcl_vars.mg_nether_min,
        y_max = mcl_vars.mg_nether_max,
    })
    minetest.register_ore({
        ore_type       = "scatter",
        ore            = "mcl_nether_gold:nether_gold_ore",
        wherein         = {"mcl_nether:netherrack", "mcl_core:stone"},
        clust_scarcity = 1650,
        clust_num_ores = 8, -- MC cluster amount: 4-10
        clust_size     = 4,
        y_min = mcl_vars.mg_nether_min,
        y_max = mcl_vars.mg_nether_max,
    })
end