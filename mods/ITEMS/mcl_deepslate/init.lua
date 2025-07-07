local modname = core.get_current_modname()
local S = core.get_translator(modname)

local copper_mod = core.get_modpath("mcl_copper")
local cobble = "mcl_deepslate:deepslate_cobbled"

-- runtime_depends
assert(core.get_modpath("mcl_mobs"), "mcl_deepslate requires mcl_mobs at runtime")

local function spawn_silverfish(pos, _,_,_)
	if not core.is_creative_enabled("") then
		mcl_mobs.spawn(pos, "mobs_mc:silverfish")
	end
end

core.register_node("mcl_deepslate:deepslate", {
	description = S("Deepslate"),
	_doc_items_longdesc = S("Deepslate is a stone type found deep underground in the Overworld that functions similar to regular stone but is harder than the stone."),
	_doc_items_hidden = false,
	tiles = { "mcl_deepslate_top.png", "mcl_deepslate_top.png", "mcl_deepslate.png" },
	paramtype2 = "facedir",
	is_ground_content = true,
	on_place = mcl_util.rotate_axis,
	groups = { pickaxey = 1, stone = 1, building_block = 1, material_stone = 1 },
	drop = cobble,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_3way,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})

core.register_node("mcl_deepslate:infested_deepslate", {
	description = S("Infested Deepslate"),
	_doc_items_longdesc = S("An infested block is a block from which a silverfish will pop out when it is broken. It looks identical to its normal counterpart."),
	_tt_help = S("Hides a silverfish"),
	tiles = { "mcl_deepslate_top.png", "mcl_deepslate_top.png", "mcl_deepslate.png" },
	is_ground_content = true,
	groups = { dig_immediate = 3, spawns_silverfish = 1, deco_block = 1 },
	drop = "",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	after_dig_node = spawn_silverfish,
	_mcl_hardness = 1.5,
	_mcl_blast_resistance = 0.75,
})

core.register_node("mcl_deepslate:tuff", {
	description = S("Tuff"),
	_doc_items_longdesc = S("Tuff is an ornamental rock formed from volcanic ash, occurring in underground blobs below Y=16."),
	_doc_items_hidden = false,
	tiles = { "mcl_deepslate_tuff.png" },
	groups = { pickaxey = 1, deco_block = 1 },
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
	_mcl_silk_touch_drop = true,
})

local function register_deepslate_ore(item_string, drop, cooked, pick, xp, orename, oredesc)
	local nodename = "mcl_deepslate:deepslate_with_"..item_string
	core.register_node(nodename, {
		description = orename,
		_doc_items_longdesc = oredesc,
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

	core.register_craft({
		type = "cooking",
		output = cooked,
		recipe = nodename,
		cooktime = 10,
	})
end

local lapis_drops = {
	max_items = 1, items = {
		{ items = { "mcl_core:lapis 8" }, rarity = 5 },
		{ items = { "mcl_core:lapis 7" }, rarity = 5 },
		{ items = { "mcl_core:lapis 6" }, rarity = 5 },
		{ items = { "mcl_core:lapis 5" }, rarity = 5 },
		{ items = { "mcl_core:lapis 4" } }
	}
}

local deepslate_ores = {
	{ "coal", "mcl_core:coal_lump", "mcl_core:coal_lump", 1, 1,
		S("Deepslate Coal Ore"), S("Deepslate coal ore is a variant of coal ore that can generate in deepslate and tuff blobs.") },
	{ "iron", "mcl_raw_ores:raw_iron", "mcl_core:iron_ingot", 3, 0,
		S("Deepslate Iron Ore"), S("Deepslate iron ore is a variant of iron ore that can generate in deepslate and tuff blobs.") },
	{ "gold", "mcl_raw_ores:raw_gold", "mcl_core:gold_ingot", 4, 0,
		S("Deepslate Gold Ore"), S("Deepslate gold ore is a variant of gold ore that can generate in deepslate and tuff blobs.") },
	{ "emerald", "mcl_core:emerald", "mcl_core:emerald", 4, 6,
		S("Deepslate Emerald Ore"), S("Deepslate emerald ore is a variant of emerald ore that can generate in deepslate and tuff blobs.") },
	{ "diamond", "mcl_core:diamond", "mcl_core:diamond", 4, 4,
		S("Deepslate Diamond Ore"), S("Deepslate diamond ore is a variant of diamond ore that can generate in deepslate and tuff blobs.") },
	{ "lapis", lapis_drops, "mcl_core:lapis", 3, 6,
		S("Deepslate Lapis Lazuli Ore"), S("Deepslate lapis lazuli ore is a variant of lapis lazuli ore that can generate in deepslate and tuff blobs.") },
}

for _, p in pairs(deepslate_ores) do
	register_deepslate_ore(p[1], p[2], p[3], p[4], p[5], p[6], p[7])
end

if copper_mod then
	register_deepslate_ore("copper", "mcl_copper:raw_copper", "mcl_copper:copper_ingot", 3, 4,
		S("Deepslate Copper Ore"), S("Deepslate copper ore is a variant of copper ore that can generate in deepslate and tuff blobs."))
end

local redstone_timer = 68.28

local function redstone_ore_activate(pos, node, puncher, pointed_thing)
	core.swap_node(pos, { name = "mcl_deepslate:deepslate_with_redstone_lit" })
	local t = core.get_node_timer(pos)
	t:start(redstone_timer)
	if puncher and pointed_thing then
		return core.node_punch(pos, node, puncher, pointed_thing)
	end
end

local function redstone_ore_reactivate(pos, node, puncher, pointed_thing)
	local t = core.get_node_timer(pos)
	t:start(redstone_timer)
	if puncher and pointed_thing then
		return core.node_punch(pos, node, puncher, pointed_thing)
	end
end

core.register_node("mcl_deepslate:deepslate_with_redstone", {
	description = S("Deepslate Redstone Ore"),
	_doc_items_longdesc = S("Deepslate redstone ore is a variant of redstone ore that can generate in deepslate and tuff blobs."),
	tiles = { "mcl_deepslate_redstone_ore.png" },
	is_ground_content = true,
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

core.register_node("mcl_deepslate:deepslate_with_redstone_lit", {
	description = S("Lit Deepslate Redstone Ore"),
	_doc_items_create_entry = false,
	tiles = { "mcl_deepslate_redstone_ore.png" },
	paramtype = "light",
	light_source = 9,
	is_ground_content = true,
	groups = { pickaxey = 4, not_in_creative_inventory = 1, material_stone = 1, xp = 7 },
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
	on_timer = function(pos, _)
		core.swap_node(pos, { name = "mcl_deepslate:deepslate_with_redstone" })
	end,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 4.5,
	_mcl_silk_touch_drop = { "mcl_deepslate:deepslate_with_redstone" },
	_mcl_fortune_drop = {
		discrete_uniform_distribution = true,
		items = { "mesecons:redstone" },
		min_count = 4,
		max_count = 5,
	},
})

local function register_deepslate_variant(item, texture, desc, longdesc, stair, slab, dslab, wall)
	local def = {
		description = desc,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		tiles = { "mcl_"..texture..".png" },
		groups = { pickaxey = 1, building_block = 1, material_stone = 1 },
		sounds = mcl_sounds.node_sound_stone_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3.5,
		_mcl_silk_touch_drop = true,
	}
	core.register_node("mcl_deepslate:deepslate_"..item, table.copy(def))

	if stair and slab and dslab then
		mcl_stairs.register_stair_and_slab_simple("deepslate_"..item, "mcl_deepslate:deepslate_"..item, stair, slab, dslab)
	end
	if wall then
		mcl_walls.register_wall("mcl_deepslate:deepslate"..item.."wall", wall, "mcl_deepslate:deepslate_"..item)
	end
end

local deepslate_variants = {
	-- Do not reorder the below. Doing so will break the cobbled->polished->bricks->tiles craft recipes.
	{ "cobbled", "cobbled_deepslate",
		S("Cobbled Deepslate"), S("Cobbled deepslate is a stone variant that functions similar to cobblestone or blackstone."),
		S("Cobbled Deepslate Stairs"), S("Cobbled Deepslate Slab"), S("Double Cobbled Deepslate Slab"), S("Cobbled Deepslate Wall"),
	},
	{ "polished", "polished_deepslate",
		S("Polished Deepslate"), S("Polished deepslate is the stone-like polished version of deepslate."),
		S("Polished Deepslate Stairs"), S("Polished Deepslate Slab"), S("Double Polished Deepslate Slab"), S("Polished Deepslate Wall"),
	},
	{ "bricks", "deepslate_bricks",
		S("Deepslate Bricks"), S("Deepslate bricks are the brick version of deepslate."),
		S("Deepslate Bricks Stairs"), S("Deepslate Bricks Slab"), S("Double Deepslate Bricks Slab"), S("Deepslate Bricks Wall"),
	},
	{ "tiles", "deepslate_tiles",
		S("Deepslate Tiles"), S("Deepslate tiles are a decorative variant of deepslate."),
		S("Deepslate Tiles Stairs"), S("Deepslate Tiles Slab"), S("Double Deepslate Tiles Slab"), S("Deepslate Tiles Wall"),
	},
	-- Do not reorder the above. Doing so will break the cobbled->polished->bricks->tiles craft recipes.

	{ "bricks_cracked", "cracked_deepslate_bricks",
		S("Cracked Deepslate Bricks"), S("Cracked deepslate bricks are a cracked brick version of deepslate."),
		nil, nil, nil, nil,
	},
	{ "tiles_cracked", "cracked_deepslate_tiles",
		S("Cracked Deepslate Tiles"), S("Cracked deepslate tiles are a cracked decorative variant of deepslate."),
		nil, nil, nil, nil,
	},
	{ "chiseled", "chiseled_deepslate",
		S("Chiseled Deepslate"), S("Chiseled deepslate is the chiseled version of deepslate."),
		nil, nil, nil, nil,
	},
}

for _, dv in pairs(deepslate_variants) do
	register_deepslate_variant(dv[1], dv[2], dv[3], dv[4], dv[5], dv[6], dv[7], dv[8])
end

for i = 1, 3 do
	local s = "mcl_deepslate:deepslate_"..deepslate_variants[i][1]
	core.register_craft({
		output = "mcl_deepslate:deepslate_"..deepslate_variants[i+1][1].." 4",
		recipe = { { s, s }, { s, s } }
	})
	mcl_stonecutter.register_recipe(
		"mcl_deepslate:deepslate_"..deepslate_variants[i][1],
		"mcl_deepslate:deepslate_"..deepslate_variants[i+1][1]
	)
end

for _, p in pairs({ "bricks", "tiles" }) do
	core.register_craft({
		type = "cooking",
		output = "mcl_deepslate:deepslate_"..p.."_cracked",
		recipe = "mcl_deepslate:deepslate_"..p,
		cooktime = 10,
	})
end

core.register_craft({
	type = "cooking",
	output = "mesecons:redstone",
	recipe = "mcl_deepslate:deepslate_with_redstone",
	cooktime = 10,
})

core.register_craft({
	type = "cooking",
	output = "mcl_deepslate:deepslate",
	recipe = cobble,
	cooktime = 10,
})

core.register_craft({
	output = "mcl_deepslate:deepslate_chiseled",
	recipe = {
		{ "mcl_stairs:slab_deepslate_cobbled" },
		{ "mcl_stairs:slab_deepslate_cobbled" },
	},
})

mcl_stonecutter.register_recipe("mcl_deepslate:deepslate_cobbled", "mcl_deepslate:deepslate_chiseled")
