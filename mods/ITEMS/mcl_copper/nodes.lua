local S = minetest.get_translator("mcl_copper")

function mcl_copper.register_copper_variants(name, definitions)
	local oxidized_variant, stripped_variant, waxed_variant
	local groups = table.copy(definitions.groups)
	local names = {
		name, "waxed_"..name,
		name.."_exposed", "waxed_"..name.."_exposed",
		name.."_weathered", "waxed_"..name.."_weathered",
		name.."_oxidized", "waxed_"..name.."_oxidized"
	}
	local tiles = {
		"mcl_copper_"..name..".png",
		"mcl_copper_"..name.."_exposed.png",
		"mcl_copper_"..name.."_weathered.png",
		"mcl_copper_"..name.."_oxidized.png"
	}

	for i = 1, #names do
		if names[i]:find("waxed") then
			groups.waxed = 1
			stripped_variant = "mcl_copper:"..names[i-1]
		else
			if not names[i]:find("oxidized") then
				groups.oxidizable = 1
				oxidized_variant = "mcl_copper:"..names[i+2]
			end
			if i ~= 1 then
				stripped_variant = "mcl_copper:"..names[i-2]
			end
			waxed_variant = "mcl_copper:"..names[i+1]
		end

		minetest.register_node("mcl_copper:"..names[i], {
			description = S(mcl_copper.copper_descs[name][i]),
			drawtype = definitions.drawtype or "normal",
			groups = groups,
			is_ground_content = false,
			light_source = nil,
			paramtype = definitions.paramtype or "none",
			paramtype2 = definitions.paramtype2 or "none",
			sounds = mcl_sounds.node_sound_metal_defaults(),
			sunlight_propagates = definitions.sunlight_propagates or false,
			tiles = {tiles[math.ceil(i/2)]},
			_doc_items_longdesc = S(mcl_copper.copper_longdescs[name][math.ceil(i/2)]),
			_mcl_blast_resistance = 6,
			_mcl_hardness = 3,
			_mcl_oxidized_variant = oxidized_variant,
			_mcl_stripped_variant = stripped_variant,
			_mcl_waxed_variant = waxed_variant,
		})

		if definitions._mcl_stairs then
			local subname = mcl_copper.stairs_subnames[name][i]
			groups.building_block = 0

			mcl_stairs.register_slab(subname, "mcl_copper:"..names[i],
				groups, {tiles[math.ceil(i/2)], tiles[math.ceil(i/2)], tiles[math.ceil(i/2)]},
				S(mcl_copper.stairs_descs[subname][1]), nil, nil, nil,
				S(mcl_copper.stairs_descs[subname][2])
			)

			mcl_stairs.register_stair(subname, "mcl_copper:"..names[i],
				groups, {tiles[math.ceil(i/2)], tiles[math.ceil(i/2)], tiles[math.ceil(i/2)],
				tiles[math.ceil(i/2)], tiles[math.ceil(i/2)], tiles[math.ceil(i/2)]},
				S(mcl_copper.stairs_descs[subname][3]), nil, nil, nil, "woodlike"
			)
		end
	end
end

minetest.register_node("mcl_copper:stone_with_copper", {
	description = S("Copper Ore"),
	_doc_items_longdesc = S("Some copper contained in stone, it is pretty common and can be found below sea level."),
	tiles = {"default_stone.png^mcl_copper_ore.png"},
	is_ground_content = true,
	groups = {pickaxey = 3, building_block = 1, material_stone = 1, blast_furnace_smeltable=1},
	drop = "mcl_copper:raw_copper",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,
})

minetest.register_node("mcl_copper:block_raw", {
	description = S("Block of Raw Copper"),
	_doc_items_longdesc = S("A block used for compact raw copper storage."),
	tiles = {"mcl_copper_raw_block.png"},
	is_ground_content = false,
	groups = {pickaxey = 2, building_block = 1, blast_furnace_smeltable = 1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

mcl_copper.register_copper_variants("block", {
	groups = {pickaxey = 2, building_block = 1},
	--_mcl_doors = true,
})
mcl_copper.register_copper_variants("cut", {
	groups = {pickaxey = 2, building_block = 1},
	_mcl_stairs = true,
})
mcl_copper.register_copper_variants("grate", {
	drawtype = "allfaces",
	groups = {pickaxey = 2, building_block = 1, disable_suffocation = 1},
	sunlight_propagates = true,
})
mcl_copper.register_copper_variants("chiseled", {
	groups = {pickaxey = 2, building_block = 1}
})
