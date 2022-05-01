local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

local layer_max = mcl_worlds.layer_to_y(16)
local layer_min = mcl_vars.mg_overworld_min
local copper_mod = minetest.get_modpath("mcl_copper")
local cobble = "mcl_deepslate:deepslate_cobbled"
local stick = "mcl_core:stick"
local mountains = {
	"ExtremeHills", "ExtremeHills_beach", "ExtremeHills_ocean", "ExtremeHills_deep_ocean", "ExtremeHills_underground",
	"ExtremeHills+", "ExtremeHills+_ocean", "ExtremeHills+_deep_ocean", "ExtremeHills+_underground",
	"ExtremeHillsM", "ExtremeHillsM_ocean", "ExtremeHillsM_deep_ocean", "ExtremeHillsM_underground",
}

if minetest.get_modpath("mcl_item_id") then
	mcl_item_id.set_mod_namespace(modname)
end

minetest.register_node("mcl_deepslate:deepslate", {
	description = S("Deepslate"),
	_doc_items_longdesc = S("Deepslate is a stone type found deep underground in the Overworld that functions similar to regular stone but is harder than the stone."),
	_doc_items_hidden = false,
	tiles = { "mcl_deepslate_top.png", "mcl_deepslate_top.png", "mcl_deepslate.png" },
	paramtype2 = "facedir",
	is_ground_content = true,
	stack_max = 64,
	on_place = mcl_util.rotate_axis,
	groups = { pickaxey = 1, stone = 1, building_block = 1, material_stone = 1 },
	drop = cobble,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_3way,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})

local function spawn_silverfish(pos, oldnode, oldmetadata, digger)
	if not minetest.is_creative_enabled("") then
		minetest.add_entity(pos, "mobs_mc:silverfish")
	end
end

minetest.register_node("mcl_deepslate:infested_deepslate", {
	description = S("Infested Deepslate"),
	_doc_items_longdesc = S("An infested block is a block from which a silverfish will pop out when it is broken. It looks identical to its normal counterpart."),
	_tt_help = S("Hides a silverfish"),
	tiles = { "mcl_deepslate_top.png", "mcl_deepslate_top.png", "mcl_deepslate.png" },
	is_ground_content = true,
	groups = { dig_immediate = 3, spawns_silverfish = 1, deco_block = 1 },
	drop = "",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	after_dig_node = spawn_silverfish,
	_mcl_hardness = 0,
	_mcl_blast_resistance = 0.5,
})

minetest.register_node("mcl_deepslate:tuff", {
	description = S("Tuff"),
	_doc_items_longdesc = S("Tuff is an ornamental rock formed from volcanic ash, occurring in underground blobs below Y=16."),
	_doc_items_hidden = false,
	tiles = { "mcl_deepslate_tuff.png" },
	stack_max = 64,
	groups = { pickaxey = 1, deco_block = 1 },
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
	_mcl_silk_touch_drop = true,
})

local function register_deepslate_ore(desc, drop, pick, xp)
	local item = desc:lower()
	local item_string
	if item == "lapis lazuli" then
		item_string = "lapis"
	else 
		item_string = item
	end
	minetest.register_node("mcl_deepslate:deepslate_with_"..item_string, {
		description = S("Deepslate "..desc.." Ore"),
		_doc_items_longdesc = S("Deepslate "..item.." ore is a variant of "..item.." ore that can generate in deepslate and tuff blobs."),
		_doc_items_hidden = false,
		tiles = { "mcl_deepslate_"..item_string.."_ore.png" },
		is_ground_content = true,
		stack_max = 64,
		groups = { pickaxey = pick, building_block = 1, material_stone = 1, xp = xp },
		drop = drop,
		sounds = mcl_sounds.node_sound_stone_defaults(),
		_mcl_blast_resistance = 3,
		_mcl_hardness = 4.5,
		_mcl_silk_touch_drop = true,
		_mcl_fortune_drop = mcl_core.fortune_drop_ore,
	})
end

local deepslate_ores = {
	{ "Coal", "mcl_core:coal_lump", 1, 1 },
	{ "Iron", "mcl_raw_ores:raw_iron", 3, 0 },
	{ "Gold", "mcl_raw_ores:raw_gold", 4, 0 },
	{ "Emerald", "mcl_core:emerald", 4, 6 },
	{ "Diamond", "mcl_core:diamond", 4, 4 },
	{ "Lapis Lazuli", { max_items = 1, items = {
			{ items = { "mcl_dye:blue 8" }, rarity = 5 },
			{ items = { "mcl_dye:blue 7" }, rarity = 5 },
			{ items = { "mcl_dye:blue 6" }, rarity = 5 },
			{ items = { "mcl_dye:blue 5" }, rarity = 5 },
			{ items = { "mcl_dye:blue 4" } },
		}
	}, 3, 6 },
}

for _, p in pairs(deepslate_ores) do
	register_deepslate_ore(p[1], p[2], p[3], p[4])
end
if copper_mod then
	register_deepslate_ore("Copper", "mcl_copper:raw_copper", 4, 4)
end

local redstone_timer = 68.28
local function redstone_ore_activate(pos)
	minetest.swap_node(pos, { name = "mcl_deepslate:deepslate_with_redstone_lit" })
	local t = minetest.get_node_timer(pos)
	t:start(redstone_timer)
end
local function redstone_ore_reactivate(pos)
	local t = minetest.get_node_timer(pos)
	t:start(redstone_timer)
end

minetest.register_node("mcl_deepslate:deepslate_with_redstone", {
	description = S("Deepslate Redstone Ore"),
	_doc_items_longdesc = S("Deepslate redstone ore is a variant of redstone ore that can generate in deepslate and tuff blobs."),
	tiles = { "mcl_deepslate_redstone_ore.png" },
	is_ground_content = true,
	stack_max = 64,
	groups = { pickaxey = 4, building_block = 1, material_stone = 1, xp = 7 },
	drop = {
		items = {
			max_items = 1,
			{ items = { "mesecons:redstone 4" }, rarity = 2 },
			{ items = { "mesecons:redstone 5" } },
		}
	},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_punch = redstone_ore_activate,
	on_walk_over = redstone_ore_activate,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 4.5,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = {
		discrete_uniform_distribution = true,
		items = { "mesecons:redstone" },
		min_count = 4,
		max_count = 5,
	}
})

minetest.register_node("mcl_deepslate:deepslate_with_redstone_lit", {
	description = S("Lit Deepslate Redstone Ore"),
	_doc_items_create_entry = false,
	tiles = { "mcl_deepslate_redstone_ore.png" },
	paramtype = "light",
	light_source = 9,
	is_ground_content = true,
	stack_max = 64,
	groups = { pickaxey = 4, not_in_creative_inventory = 1, material_stone = 1, xp = 7},
	drop = {
		items = {
			max_items = 1,
			{ items = { "mesecons:redstone 4" }, rarity = 2 },
			{ items = { "mesecons:redstone 5" } },
		}
	},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_punch = redstone_ore_reactivate,
	on_walk_over = redstone_ore_reactivate, -- Uses walkover mod
	on_timer = function(pos, elapsed)
		minetest.swap_node(pos, { name = "mcl_deepslate:deepslate_with_redstone" })
	end,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 4.5,
	_mcl_silk_touch_drop = { "mcl_deepslate:deepslate_with_redstone" },
	_mcl_fortune_drop = {
		discrete_uniform_distribution = true,
		items = { "mesecons:redstone" },
		min_count = 4,
		max_count = 5,
	}
})

minetest.register_ore({
    ore_type       = "blob",
    ore            = "mcl_deepslate:deepslate",
    wherein        = { "mcl_core:stone" },
    clust_scarcity = 200,
    clust_num_ores = 100,
    clust_size     = 10,
    y_min          = layer_min,
    y_max          = layer_max,
    noise_params = {
        offset  = 0,
        scale   = 1,
        spread  = { x = 250, y = 250, z = 250 },
        seed    = 12345,
        octaves = 3,
        persist = 0.6,
        lacunarity = 2,
        flags = "defaults",
    }
})

minetest.register_ore({
	ore_type       = "blob",
	ore            = "mcl_deepslate:tuff",
	wherein        = { "mcl_core:stone", "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite", "mcl_deepslate:deepslate" },
	clust_scarcity = 10*10*10,
	clust_num_ores = 58,
	clust_size     = 7,
	y_min          = layer_min,
    y_max          = layer_max,
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_deepslate:infested_deepslate",
	wherein        = "mcl_deepslate:deepslate",
	clust_scarcity = 26 * 26 * 26,
	clust_num_ores = 3,
	clust_size     = 2,
	y_min          = layer_min,
	y_max          = layer_max,
	biomes         = mountains,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:water_source",
	wherein        = "mcl_deepslate:deepslate",
	clust_scarcity = 9000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(5),
	y_max          = layer_max,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein        = "mcl_deepslate:deepslate",
	clust_scarcity = 2000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(1),
	y_max          = mcl_worlds.layer_to_y(10),
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein        = "mcl_deepslate:deepslate",
	clust_scarcity = 9000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(11),
	y_max          = layer_max,
})


if minetest.settings:get_bool("mcl_generate_ores", true) then
	local stonelike = { "mcl_core:stone", "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite" }
	local function register_ore_mg(ore, scarcity, num, size, y_min, y_max, biomes)
		biomes = biomes or ""
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = ore,
			wherein        = { "mcl_deepslate:deepslate", "mcl_deepslate:tuff" },
			clust_scarcity = scarcity,
			clust_num_ores = num,
			clust_size     = size,
			y_min          = y_min,
			y_max          = y_max,
			biomes		   = biomes,
		})
	end
	local ore_mapgen = {
		{ "coal", 1575, 5, 3, layer_min, layer_max },
		{ "coal", 1530, 8, 3, layer_min, layer_max },
		{ "coal", 1500, 12, 3, layer_min, layer_max },
		{ "iron", 830, 5, 3, layer_min, layer_max },
		{ "gold", 4775, 5, 3, layer_min, layer_max },
		{ "gold", 6560, 7, 3, layer_min, layer_max },
		{ "diamond", 10000, 4, 3, layer_min, mcl_worlds.layer_to_y(12) },
		{ "diamond", 5000, 2, 3, layer_min, mcl_worlds.layer_to_y(12) },
		{ "diamond", 10000, 8, 3, layer_min, mcl_worlds.layer_to_y(12) },
		{ "diamond", 20000, 1, 1, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
		{ "diamond", 20000, 2, 2, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
		{ "redstone", 500, 4, 3, layer_min, mcl_worlds.layer_to_y(13) },
		{ "redstone", 800, 7, 4, layer_min, mcl_worlds.layer_to_y(13) },
		{ "redstone", 1000, 4, 3, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
		{ "redstone", 1600, 7, 4, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
		{ "lapis", 10000, 7, 4, mcl_worlds.layer_to_y(14), layer_max },
		{ "lapis", 12000, 6, 3, mcl_worlds.layer_to_y(10), mcl_worlds.layer_to_y(13) },
		{ "lapis", 14000, 5, 3, mcl_worlds.layer_to_y(6), mcl_worlds.layer_to_y(9) },
		{ "lapis", 16000, 4, 3, mcl_worlds.layer_to_y(2), mcl_worlds.layer_to_y(5) },
		{ "lapis", 18000, 3, 2, mcl_worlds.layer_to_y(0), mcl_worlds.layer_to_y(2) },
	}
	for _, o in pairs(ore_mapgen) do
		register_ore_mg("mcl_deepslate:deepslate_with_"..o[1], o[2], o[3], o[4], o[5], o[6])
	end
	if minetest.get_mapgen_setting("mg_name") == "v6" then
		register_ore_mg("mcl_deepslate:deepslate_with_emerald", 14340, 1, 1, layer_min, layer_max)
	else
		register_ore_mg("mcl_deepslate:deepslate_with_emerald", 16384, 1, 1, mcl_worlds.layer_to_y(4), layer_max, mountains)
	end
	if copper_mod then
		register_ore_mg("mcl_deepslate:deepslate_with_copper", 830, 5, 3, layer_min, layer_max)
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = "mcl_copper:stone_with_copper",
			wherein        = stonelike,
			clust_scarcity = 830,
			clust_num_ores = 5,
			clust_size     = 3,
			y_min          = mcl_vars.mg_overworld_min,
			y_max          = mcl_worlds.layer_to_y(39),
		})
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = "mcl_copper:stone_with_copper",
			wherein        = stonelike,
			clust_scarcity = 1660,
			clust_num_ores = 4,
			clust_size     = 2,
			y_min          = mcl_worlds.layer_to_y(40),
			y_max          = mcl_worlds.layer_to_y(63),
		})
	end
end

local function register_deepslate_variant(item, desc, longdesc)
	local texture = desc:lower():gsub("% ", "_")
	minetest.register_node("mcl_deepslate:deepslate_"..item, {
		description = S(desc),
		_doc_items_longdesc = S(longdesc),
		_doc_items_hidden = false,
		tiles = { "mcl_"..texture..".png" },
		stack_max = 64,
		groups = { pickaxey = 1, building_block = 1, material_stone = 1 },
		sounds = mcl_sounds.node_sound_stone_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3.5,
		_mcl_silk_touch_drop = true,
	})
	if item == "bricks" or item == "tiles" then
		minetest.register_node("mcl_deepslate:deepslate_"..item.."_cracked", {
			description = S("Cracked "..desc),
			_doc_items_longdesc = S("Cracked "..desc:lower().." are a cracked variant."),
			_doc_items_hidden = false,
			tiles = { "mcl_cracked_"..texture..".png" },
			stack_max = 64,
			groups = { pickaxey = 1, building_block = 1, material_stone = 1 },
			sounds = mcl_sounds.node_sound_stone_defaults(),
			_mcl_blast_resistance = 6,
			_mcl_hardness = 3.5,
			_mcl_silk_touch_drop = true,
		})
	end
	if item ~= "chiseled" then
		mcl_stairs.register_stair_and_slab_simple("deepslate_"..item, "mcl_deepslate:deepslate_"..item, S(desc.." Stairs"), S(desc.." Slab"), S("Double "..desc.." Slab"))
		mcl_walls.register_wall("mcl_deepslate:deepslate"..item.."wall", S(desc.." Wall"), "mcl_deepslate:deepslate_"..item)
	end
end

local deepslate_variants = {
	{ "cobbled", "Cobbled Deepslate", "Cobbled deepslate is a stone variant that functions similar to cobblestone or blackstone." },
	{ "polished", "Polished Deepslate", "Polished deepslate is the stone-like polished version of deepslate." }, 
	{ "bricks", "Deepslate Bricks", "Deepslate bricks are the brick version of deepslate." },
	{ "tiles", "Deepslate Tiles", "Deepslate tiles are a decorative variant of deepslate." },
	{ "chiseled", "Chiseled Deepslate", "Chiseled deepslate is the chiseled version of deepslate." },
}
for _, dv in pairs(deepslate_variants) do
	register_deepslate_variant(dv[1], dv[2], dv[3])
end
for i = 1, 3 do
	local s = "mcl_deepslate:deepslate_"..deepslate_variants[i][1]
	minetest.register_craft({
		output = "mcl_deepslate:deepslate_"..deepslate_variants[i+1][1].." 4",
		recipe = { { s, s }, { s, s } } 
	})
end
for _, p in pairs({ "bricks", "tiles" }) do
	minetest.register_craft({
		type = "cooking",
		output = "mcl_deepslate:deepslate_"..p.."_cracked",
		recipe = "mcl_deepslate:deepslate_"..p,
		cooktime = 10,
	})
end
minetest.register_craft({
	type = "cooking",
	output = "mcl_deepslate:deepslate",
	recipe = cobble,
	cooktime = 10,
})
minetest.register_craft({
	output = "mcl_deepslate:deepslate_chiseled",
	recipe = {
		{ "mcl_stairs:slab_deepslate_cobbled" },
		{ "mcl_stairs:slab_deepslate_cobbled" },
	}
})
minetest.register_craft({
	output = "mcl_brewing:stand_000",
	recipe = {
		{ "", "mcl_mobitems:blaze_rod", "" },
		{ cobble, cobble, cobble },
	}
})
minetest.register_craft({
	output = "mcl_furnaces:furnace",
	recipe = {
		{ cobble, cobble, cobble },
		{ cobble, "", cobble },
		{ cobble, cobble, cobble },
	}
})
minetest.register_craft({
	output = "mcl_tools:pick_stone",
	recipe = {
		{ cobble, cobble, cobble },
		{ "", stick, "" },
		{ "", stick, "" },
	}
})
minetest.register_craft({
	output = "mcl_tools:shovel_stone",
	recipe = {
		{ cobble },
		{ stick },
		{ stick },
	}
})
minetest.register_craft({
	output = "mcl_tools:axe_stone",
	recipe = {
		{ cobble, cobble },
		{ cobble, stick },
		{ "", stick },
	}
})
minetest.register_craft({
	output = "mcl_tools:axe_stone",
	recipe = {
		{ cobble, cobble },
		{ stick, cobble },
		{ stick, "" },
	}
})
minetest.register_craft({
	output = "mcl_tools:sword_stone",
	recipe = {
		{ cobble },
		{ cobble },
		{ stick },
	}
})
minetest.register_craft({
	output = "mcl_farming:hoe_stone",
	recipe = {
		{ cobble, cobble },
		{ "", stick },
		{ "", stick }
	}
})
minetest.register_craft({
	output = "mcl_farming:hoe_stone",
	recipe = {
		{ cobble, cobble },
		{ stick, "" },
		{ stick, "" }
	}
})
