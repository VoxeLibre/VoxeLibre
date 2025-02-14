local S = minetest.get_translator(minetest.get_current_modname())

local function register_raw_ore(ore, item_desc, item_longdesc, block_desc, block_longdesc)
	local raw_ingot = "mcl_raw_ores:raw_"..ore
	local texture = "mcl_raw_ores_raw_"..ore

	minetest.register_craftitem(raw_ingot, {
		description = item_desc,
		_doc_items_longdesc = item_longdesc,
		inventory_image = texture..".png",
		groups = { craftitem = 1, blast_furnace_smeltable = 1 },
	})

	minetest.register_node(raw_ingot.."_block", {
		description = block_desc,
		_doc_items_longdesc = block_longdesc,
		tiles = { texture.."_block.png" },
		is_ground_content = false,
		groups = { pickaxey = 2, building_block = 1, blast_furnace_smeltable = 1 },
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 5,
	})

	minetest.register_craft({
		output = raw_ingot.."_block",
		recipe = {
			{ raw_ingot, raw_ingot, raw_ingot },
			{ raw_ingot, raw_ingot, raw_ingot },
			{ raw_ingot, raw_ingot, raw_ingot },
		},
	})

	minetest.register_craft({
		type = "cooking",
		output = "mcl_core:"..ore.."_ingot",
		recipe = raw_ingot,
		cooktime = 10,
	})

	minetest.register_craft({
		type = "cooking",
		output = "mcl_core:"..ore.."block",
		recipe = raw_ingot.."_block",
		cooktime = 90,
	})

	minetest.register_craft({
		output = raw_ingot.." 9",
		recipe = {
			{ raw_ingot.."_block" },
		},
	})
end

register_raw_ore("iron", S("Raw Iron"), S("Raw iron. Mine an iron ore to get it."), S("Block of Raw Iron"),
	S("A block of raw iron is mostly a decorative block but also useful as a compact storage of raw iron."))
register_raw_ore("gold", S("Raw Gold"), S("Raw gold. Mine a gold ore to get it."), S("Block of Raw Gold"),
	S("A block of raw gold is mostly a decorative block but also useful as a compact storage of raw gold."))
