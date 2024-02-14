local S = minetest.get_translator("mcl_copper")

local function set_description(descs, s_index, n_index)
	local description

	if type(descs[s_index][n_index]) == "string" then
		description = S(descs[s_index][n_index])
	elseif type(descs[s_index][n_index]) == "table" then
		description = S("@1 "..descs[s_index][n_index][2], S(descs[s_index][n_index][1]))
	else
		return nil
	end

	return description
end

local function set_drop(drop, old_name, index_name)
	if drop and old_name and index_name then
		drop = "mcl_copper:"..old_name:gsub(index_name, drop)
	end

	return drop
end

local function set_groups(name, groups)
	local groups = table.copy(groups)

	if name and groups then
		if name:find("waxed") then
			groups.waxed = 1
		elseif not name:find("oxidized") then
			groups.oxidizable = 1
		end

		if name:find("door") then
			groups.building_block = 0
			groups.mesecon_effector_on = 1
		end
	else
		return nil
	end

	return groups
end

local function set_light_level(light_source, index)
	local ceil, floor_5, floor_7 = math.ceil(index / 2), math.floor(index / 5), math.floor(index / 7)
	if light_source then
		light_source = light_source - 3 * (ceil - 1) - floor_5 - floor_7
	end

	return light_source
end

local function set_tiles(tiles, index)
	if not tiles or not index then
		return
	end

	return tiles[math.ceil(index / 2)]
end

function mcl_copper.register_copper_variants(name, definitions)
	local names, oxidized_variant, stripped_variant, waxed_variant

	if name ~= "cut" then
		names = {
			name, "waxed_"..name,
			name.."_exposed", "waxed_"..name.."_exposed",
			name.."_weathered", "waxed_"..name.."_weathered",
			name.."_oxidized", "waxed_"..name.."_oxidized"
		}
	else
		names = {
			"block_"..name, "waxed_block_"..name,
			"block_exposed_"..name, "waxed_block_exposed_"..name,
			"block_weathered_"..name, "waxed_block_weathered_"..name,
			"block_oxidized_"..name, "waxed_block_oxidized_"..name
		}
	end

	local tiles = {
		"mcl_copper_"..name..".png",
		"mcl_copper_"..name.."_exposed.png",
		"mcl_copper_"..name.."_weathered.png",
		"mcl_copper_"..name.."_oxidized.png"
	}

	for i = 1, #names do
		if names[i]:find("waxed") then
			stripped_variant = "mcl_copper:"..names[i-1]
		else
			if not names[i]:find("oxidized") then
				oxidized_variant = "mcl_copper:"..names[i+2]
			end
			if i ~= 1 then
				stripped_variant = "mcl_copper:"..names[i-2]
			end
			waxed_variant = "mcl_copper:"..names[i+1]
		end

		minetest.register_node("mcl_copper:"..names[i], {
			description = set_description(mcl_copper.copper_descs, name, i),
			drawtype = definitions.drawtype or "normal",
			drop = set_drop(definitions.drop, names[i], name),
			groups = set_groups(names[i], definitions.groups),
			is_ground_content = false,
			light_source = set_light_level(definitions.light_source, i),
			mesecons = definitions.mesecons,
			paramtype = definitions.paramtype or "none",
			paramtype2 = definitions.paramtype2 or "none",
			sounds = mcl_sounds.node_sound_metal_defaults(),
			sunlight_propagates = definitions.sunlight_propagates or false,
			tiles = {set_tiles(tiles, i)},
			_doc_items_longdesc = S(mcl_copper.copper_longdescs[name][math.ceil(i/2)]),
			_mcl_blast_resistance = 6,
			_mcl_hardness = 3,
			_mcl_oxidized_variant = oxidized_variant,
			_mcl_stripped_variant = stripped_variant,
			_mcl_waxed_variant = waxed_variant,
		})

		if definitions._mcl_stairs then
			local subname = mcl_copper.stairs_subnames[name][i]

			mcl_stairs.register_slab(subname, "mcl_copper:"..names[i], set_groups(subname, definitions.groups),
				{set_tiles(tiles, i), set_tiles(tiles, i), set_tiles(tiles, i)},
				set_description(mcl_copper.stairs_descs, subname, 1), nil, nil, nil,
				set_description(mcl_copper.stairs_descs, subname, 2)
			)

			mcl_stairs.register_stair(subname, "mcl_copper:"..names[i], set_groups(subname, definitions.groups),
				{set_tiles(tiles, i), set_tiles(tiles, i), set_tiles(tiles, i),
				set_tiles(tiles, i), set_tiles(tiles, i), set_tiles(tiles, i)},
				set_description(mcl_copper.stairs_descs, subname, 3), nil, nil, nil, "woodlike"
			)
		end

		if definitions._mcl_doors then
			local itemimg, lowertext, uppertext, frontimg, sideimg
			local door_groups = set_groups(names[i]:gsub(name, "door"), definitions.groups)
			local trapdoor_groups = set_groups(names[i]:gsub(name, "trapdoor"), definitions.groups)

			if i % 2 == 1 then
				itemimg = "mcl_copper_item_"..names[i]:gsub(name, "door")..".png"
				lowertext = "mcl_copper_"..names[i]:gsub(name, "door").."_lower.png"
				uppertext = "mcl_copper_"..names[i]:gsub(name, "door").."_upper.png"
				frontimg = "mcl_copper_"..names[i]:gsub(name, "trapdoor")..".png"
				sideimg = "mcl_copper_"..names[i]:gsub(name, "trapdoor").."_side.png"
			else
				itemimg = "mcl_copper_item_"..names[i-1]:gsub(name, "door")..".png"
				lowertext = "mcl_copper_"..names[i-1]:gsub(name, "door").."_lower.png"
				uppertext = "mcl_copper_"..names[i-1]:gsub(name, "door").."_upper.png"
				frontimg = "mcl_copper_"..names[i-1]:gsub(name, "trapdoor")..".png"
				sideimg = "mcl_copper_"..names[i-1]:gsub(name, "trapdoor").."_side.png"
			end

			mcl_doors:register_door("mcl_copper:"..names[i]:gsub(name, "door"), {
				description = S(mcl_copper.doors_descs[i][1]),
				groups = door_groups,
				inventory_image = itemimg,
				only_redstone_can_open = false,
				sounds = mcl_sounds.node_sound_metal_defaults(),
				sound_close = "doors_steel_door_close",
				sound_open = "doors_steel_door_open",
				tiles_bottom = lowertext,
				tiles_top = uppertext,
				_mcl_blast_resistance = 3,
				_mcl_hardness = 3
			})

			mcl_doors:register_trapdoor("mcl_copper:"..names[i]:gsub(name, "trapdoor"), {
				description = S(mcl_copper.doors_descs[i][2]),
				groups = trapdoor_groups,
				only_redstone_can_open = false,
				sounds = mcl_sounds.node_sound_metal_defaults(),
				sound_close = "doors_steel_door_close",
				sound_open = "doors_steel_door_open",
				tile_front = frontimg,
				tile_side = sideimg,
				wield_image = frontimg,
				_mcl_blast_resistance = 3,
				_mcl_hardness = 3
			})
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
	_mcl_doors = true,
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

mcl_copper.register_copper_variants("bulb_off", {
	groups = {pickaxey = 2, building_block = 1},
	mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = node.name:gsub("bulb_off", "bulb_powered_on")})
			end
		},
	},
})

mcl_copper.register_copper_variants("bulb_on", {
	drop = "bulb_off",
	groups = {pickaxey = 2, building_block = 1, not_in_creative_inventory = 1},
	light_source = 14,
	mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = node.name:gsub("bulb_on", "bulb_powered_off")})
			end
		},
	},
	paramtype = "light"
})

mcl_copper.register_copper_variants("bulb_powered_off", {
	drop = "bulb_off",
	groups = {pickaxey = 2, building_block = 1, not_in_creative_inventory = 1},
	mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = node.name:gsub("bulb_powered_off", "bulb_off")})
			end
		}
	}
})

mcl_copper.register_copper_variants("bulb_powered_on", {
	drop = "bulb_off",
	groups = {pickaxey = 2, building_block = 1, not_in_creative_inventory = 1},
	light_source = 14,
	mesecons = {
		effector = {
			action_off = function (pos, node)
				minetest.swap_node(pos, {name = node.name:gsub("bulb_powered_on", "bulb_on")})
			end
		}
	},
	paramtype = "light"
})
