local S = minetest.get_translator(minetest.get_current_modname())

-- Simple solid cubic nodes, most of them are the ground materials and simple building blocks

local translucent_ice = minetest.settings:get_bool("mcl_translucent_ice", false)
local ice_drawtype, ice_texture_alpha
if translucent_ice then
	ice_drawtype = "glasslike"
	ice_texture_alpha = minetest.features.use_texture_alpha_string_modes and "blend" or true
else
	ice_drawtype = "normal"
	ice_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false
end

mcl_core.fortune_drop_ore = {
	discrete_uniform_distribution = true,
	min_count = 2,
	max_count = 1,
	get_chance = function(fortune_level) return 1 - 2 / (fortune_level + 2) end,
	multiply = true,
}

minetest.register_node("mcl_core:stone", {
	description = S("Stone"),
	_doc_items_longdesc = S("One of the most common blocks in the world, almost the entire underground consists of stone. It sometimes contains ores. Stone may be created when water meets lava."),
	_doc_items_hidden = false,
	tiles = {"default_stone.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	drop = "mcl_core:cobble",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
	_mcl_silk_touch_drop = true,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if awards and awards.unlock and digger and digger:is_player() then
			awards.unlock(digger:get_player_name(), "mcl:stoneAge")
		end
	end,
})

minetest.register_node("mcl_core:stone_with_coal", {
	description = S("Coal Ore"),
	_doc_items_longdesc = S("Some coal contained in stone, it is very common and can be found inside stone in medium to large clusters at nearly every height."),
	_doc_items_hidden = false,
	tiles = {"mcl_core_coal_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1, xp=1, blast_furnace_smeltable=1},
	drop = "mcl_core:coal_lump",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,
})

minetest.register_node("mcl_core:stone_with_iron", {
	description = S("Iron Ore"),
	_doc_items_longdesc = S("Some iron contained in stone, it is prety common and can be found below sea level."),
	tiles = {"mcl_core_iron_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=3, building_block=1, material_stone=1, blast_furnace_smeltable=1},
	drop = "mcl_raw_ores:raw_iron",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,
})


minetest.register_node("mcl_core:stone_with_gold", {
	description = S("Gold Ore"),
	_doc_items_longdesc = S("This stone contains pure gold, a rare metal."),
	tiles = {"mcl_core_gold_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1, material_stone=1, blast_furnace_smeltable=1},
	drop = "mcl_raw_ores:raw_gold",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,
})

local redstone_timer = 68.28
local function redstone_ore_activate(pos, node, puncher, pointed_thing)
	minetest.swap_node(pos, {name="mcl_core:stone_with_redstone_lit"})
	local t = minetest.get_node_timer(pos)
	t:start(redstone_timer)
	if puncher and pointed_thing then
		return minetest.node_punch(pos, node, puncher, pointed_thing)
	end
end
minetest.register_node("mcl_core:stone_with_redstone", {
	description = S("Redstone Ore"),
	_doc_items_longdesc = S("Redstone ore is commonly found near the bottom of the world. It glows when it is punched or walked upon."),
	tiles = {"mcl_core_redstone_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1, material_stone=1, xp=7, blast_furnace_smeltable=1},
	drop = {
		items = {
			max_items = 1,
			{
				items = {"mesecons:redstone 4"},
				rarity = 2,
			},
			{
				items = {"mesecons:redstone 5"},
			},
		}
	},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_punch = redstone_ore_activate,
	on_walk_over = redstone_ore_activate, -- Uses walkover mod
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = {
		discrete_uniform_distribution = true,
		items = {"mesecons:redstone"},
		min_count = 4,
		max_count = 5,
	}
})

local function redstone_ore_reactivate(pos, node, puncher, pointed_thing)
	local t = minetest.get_node_timer(pos)
	t:start(redstone_timer)
	if puncher and pointed_thing then
		return minetest.node_punch(pos, node, puncher, pointed_thing)
	end
end
-- Light the redstone ore up when it has been touched
minetest.register_node("mcl_core:stone_with_redstone_lit", {
	description = S("Lit Redstone Ore"),
	_doc_items_create_entry = false,
	tiles = {"mcl_core_redstone_ore.png"},
	paramtype = "light",
	light_source = 9,
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=4, not_in_creative_inventory=1, material_stone=1, xp=7, blast_furnace_smeltable=1},
	drop = {
		items = {
			max_items = 1,
			{
				items = {"mesecons:redstone 4"},
				rarity = 2,
			},
			{
				items = {"mesecons:redstone 5"},
			},
		}
	},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	-- Reset timer after re-punching or stepping on
	on_punch = redstone_ore_reactivate,
	on_walk_over = redstone_ore_reactivate, -- Uses walkover mod
	-- Turn back to normal node after some time has passed
	on_timer = function(pos, elapsed)
		minetest.swap_node(pos, {name="mcl_core:stone_with_redstone"})
	end,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = {"mcl_core:stone_with_redstone"},
	_mcl_fortune_drop = {
		discrete_uniform_distribution = true,
		items = {"mesecons:redstone"},
		min_count = 4,
		max_count = 5,
	}
})

minetest.register_node("mcl_core:stone_with_lapis", {
	description = S("Lapis Lazuli Ore"),
	_doc_items_longdesc = S("Lapis lazuli ore is the ore of lapis lazuli. It can be rarely found in clusters near the bottom of the world."),
	tiles = {"mcl_core_lapis_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=3, building_block=1, material_stone=1, xp=6, blast_furnace_smeltable=1},
	drop = {
		max_items = 1,
		items = {
			{items = {"mcl_core:lapis 8"},rarity = 5},
			{items = {"mcl_core:lapis 7"},rarity = 5},
			{items = {"mcl_core:lapis 6"},rarity = 5},
			{items = {"mcl_core:lapis 5"},rarity = 5},
			{items = {"mcl_core:lapis 4"}},
		}
	},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,
})

minetest.register_node("mcl_core:stone_with_emerald", {
	description = S("Emerald Ore"),
	_doc_items_longdesc = S("Emerald ore is the ore of emeralds. It is very rare and can be found alone, not in clusters."),
	tiles = {"mcl_core_emerald_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1, material_stone=1, xp=6, blast_furnace_smeltable=1},
	drop = "mcl_core:emerald",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,
})

minetest.register_node("mcl_core:stone_with_diamond", {
	description = S("Diamond Ore"),
	_doc_items_longdesc = S("Diamond ore is rare and can be found in clusters near the bottom of the world."),
	tiles = {"mcl_core_diamond_ore.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1, material_stone=1, xp=4, blast_furnace_smeltable=1},
	drop = "mcl_core:diamond",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = mcl_core.fortune_drop_ore,
})

minetest.register_node("mcl_core:stonebrick", {
	description = S("Stone Bricks"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"default_stone_brick.png"},
	stack_max = 64,
	groups = {pickaxey=1, stone=1, stonebrick=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:stonebrickcarved", {
	description = S("Chiseled Stone Bricks"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_core_stonebrick_carved.png"},
	stack_max = 64,
	groups = {pickaxey=1, stone=1, stonebrick=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:stonebrickcracked", {
	description = S("Cracked Stone Bricks"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_core_stonebrick_cracked.png"},
	stack_max = 64,
	groups = {pickaxey=1, stone=1, stonebrick=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:stonebrickmossy", {
	description = S("Mossy Stone Bricks"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_core_stonebrick_mossy.png"},
	stack_max = 64,
	groups = {pickaxey=1, stone=1, stonebrick=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:stone_smooth", {
	description = S("Polished Stone"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_stairs_stone_slab_top.png"},
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_core:granite", {
	description = S("Granite"),
	_doc_items_longdesc = S("Granite is an igneous rock."),
	tiles = {"mcl_core_granite.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:granite_smooth", {
	description = S("Polished Granite"),
	_doc_items_longdesc = S("Polished granite is a decorative building block made from granite."),
	tiles = {"mcl_core_granite_smooth.png"},
	stack_max = 64,
	is_ground_content = false,
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:andesite", {
	description = S("Andesite"),
	_doc_items_longdesc = S("Andesite is an igneous rock."),
	tiles = {"mcl_core_andesite.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:andesite_smooth", {
	description = S("Polished Andesite"),
	_doc_items_longdesc = S("Polished andesite is a decorative building block made from andesite."),
	tiles = {"mcl_core_andesite_smooth.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:diorite", {
	description = S("Diorite"),
	_doc_items_longdesc = S("Diorite is an igneous rock."),
	tiles = {"mcl_core_diorite.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_core:diorite_smooth", {
	description = S("Polished Diorite"),
	_doc_items_longdesc = S("Polished diorite is a decorative building block made from diorite."),
	tiles = {"mcl_core_diorite_smooth.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

-- Grass Block
minetest.register_node("mcl_core:dirt_with_grass", {
	description = S("Grass Block"),
	_doc_items_longdesc = S("A grass block is dirt with a grass cover. Grass blocks are resourceful blocks which allow the growth of all sorts of plants. They can be turned into farmland with a hoe and turned into grass paths with a shovel. In light, the grass slowly spreads onto dirt nearby. Under an opaque block or a liquid, a grass block may turn back to dirt."),
	_doc_items_hidden = false,
	paramtype2 = "color",
	tiles = {"mcl_core_grass_block_top.png", { name="default_dirt.png", color="white" }, { name="default_dirt.png^mcl_dirt_grass_shadow.png", color="white" }},
	overlay_tiles = {"", "", {name="mcl_core_grass_block_side_overlay.png", tileable_vertical=false}},
	palette = "mcl_core_palette_grass.png",
	palette_index = 0,
	color = "#7CBD6B",
	is_ground_content = true,
	stack_max = 64,
	groups = {
		handy = 1, shovely = 1, dirt = 2, grass_block = 1, grass_block_no_snow = 1,
		soil = 1, soil_sapling = 2, soil_sugarcane = 1, cultivatable = 2,
		spreading_dirt_type = 1, enderman_takable = 1, building_block = 1,
		compostability = 30, path_creation_possible = 1, grass_palette = 1
	},
	drop = "mcl_core:dirt",
	sounds = mcl_sounds.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.1},
	}),
	on_construct = function(pos)
		local node = minetest.get_node(pos)
		if node.param2 == 0 then
			local p2 = mcl_util.get_palette_indexes_from_pos(pos).grass_palette_index
			if node.param2 ~= p2 then
				node.param2 = p2
				minetest.swap_node(pos, node)
			end
		end
		return mcl_core.on_snowable_construct(pos)
	end,
	_mcl_snowed = "mcl_core:dirt_with_grass_snow",
	_mcl_blast_resistance = 0.6,
	_mcl_hardness = 0.6,
	_mcl_silk_touch_drop = true,
})
mcl_core.register_snowed_node("mcl_core:dirt_with_grass_snow", "mcl_core:dirt_with_grass", nil, nil, true, S("Dirt with Snow"), 1)

minetest.register_node("mcl_core:grass_path", {
	tiles = {"mcl_core_grass_path_top.png", "default_dirt.png", "mcl_core_grass_path_side.png"},
	description = S("Grass Path"),
	_doc_items_longdesc = S("Grass paths are a decorative variant of grass blocks. Their top has a different color and they are a bit lower than grass blocks, making them useful to build footpaths. Grass paths can be created by right clicking with a shovel. A grass path turns into dirt when it is below a solid block or when shift+right clicked with a shovel."),
	drop = "mcl_core:dirt",
	is_ground_content = true,
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			-- 15/16 of the normal height
			{-0.5, -0.5, -0.5, 0.5, 0.4375, 0.5},
		}
	},
	groups = {handy=1,shovely=1, cultivatable=2, dirtifies_below_solid=1, dirtifier=1, deco_block=1, path_remove_possible=1 },
	sounds = mcl_sounds.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.1},
	}),
	_mcl_blast_resistance = 0.65,
	_mcl_hardness = 0.65,
})

-- TODO: Add particles
minetest.register_node("mcl_core:mycelium", {
	description = S("Mycelium"),
	_doc_items_longdesc = S("Mycelium is a type of dirt and the ideal soil for mushrooms. Unlike other dirt-type blocks, it can not be turned into farmland with a hoe. In light, mycelium slowly spreads over nearby dirt. Under an opaque block or a liquid, it eventually turns back into dirt."),
	tiles = {"mcl_core_mycelium_top.png", "default_dirt.png", {name="mcl_core_mycelium_side.png", tileable_vertical=false}},
	is_ground_content = true,
	stack_max = 64,
	groups = { handy = 1, shovely = 1, dirt = 2, spreading_dirt_type = 1, enderman_takable = 1,  building_block = 1, soil_sapling = 2, path_creation_possible=1, mycelium=1},
	drop = "mcl_core:dirt",
	sounds = mcl_sounds.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.1},
	}),

	on_construct = mcl_core.on_snowable_construct,
	_mcl_snowed = "mcl_core:mycelium_snow",
	_mcl_blast_resistance = 0.6,
	_mcl_hardness = 0.6,
	_mcl_silk_touch_drop = true,
})
mcl_core.register_snowed_node("mcl_core:mycelium_snow", "mcl_core:mycelium", nil, nil, false, S("Mycelium with Snow"))

local PARTICLE_ABM_DISTANCE = 16

--if minetest.settings:get("mcl_node_particles") == "full" then
minetest.register_abm({
	label = "Townaura particles",
	nodenames = {"group:mycelium"},
	interval = 2,
	chance = 30,
	action = function(pos, node)
		local player_near = false
		for _,player in pairs(minetest.get_connected_players()) do
			if vector.distance(player:get_pos(), pos) < PARTICLE_ABM_DISTANCE then
				player_near = true
			end
		end
		if player_near then
			local apos = {x=pos.x-2, y=pos.y+0.51, z=pos.z-2}
			local apos2 = {x=pos.x+2, y=pos.y+0.51, z=pos.z+2}
			local acc = { x = 0, y = 0, z = 0 }
			minetest.add_particlespawner({
				time = 2,
				amount = 5,
				minpos = apos,
				maxpos = apos2,
				minvel = vector.new(-3/10, 0, -3/10),
				maxvel = vector.new(3/10, 10/60, 3/10),
				minacc = acc,
				expirationtime = 4,
				collisiondetection = true,
				collision_removal = true,
				size = 1,
				texture = "mcl_core_mycelium_particle.png",
			})
		end
	end,
})
--end

minetest.register_node("mcl_core:podzol", {
	description = S("Podzol"),
	_doc_items_longdesc = S("Podzol is a type of dirt found in taiga forests. Only a few plants are able to survive on it."),
	tiles = {"mcl_core_dirt_podzol_top.png", "default_dirt.png", {name="mcl_core_dirt_podzol_side.png", tileable_vertical=false}},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=3, dirt=2,soil=1, soil_sapling=2, soil_sugarcane=1, enderman_takable=1, building_block=1,path_creation_possible=1},
	drop = "mcl_core:dirt",
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	on_construct = mcl_core.on_snowable_construct,
	_mcl_snowed = "mcl_core:podzol_snow",
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	_mcl_silk_touch_drop = true,
})
mcl_core.register_snowed_node("mcl_core:podzol_snow", "mcl_core:podzol", nil, nil, false, S("Podzol with Snow"))

minetest.register_node("mcl_core:dirt", {
	description = S("Dirt"),
	_doc_items_longdesc = S("Dirt acts as a soil for a few plants. When in light, this block may grow a grass or mycelium cover if such blocks are nearby."),
	_doc_items_hidden = false,
	tiles = {"default_dirt.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, dirt=1,soil=1, soil_sapling=2, soil_sugarcane=1, cultivatable=2, enderman_takable=1, building_block=1, path_creation_possible=1},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

minetest.register_node("mcl_core:coarse_dirt", {
	description = S("Coarse Dirt"),
	_doc_items_longdesc = S("Coarse dirt acts as a soil for some plants and is similar to dirt, but it will never grow a cover."),
	tiles = {"mcl_core_coarse_dirt.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = { handy = 1,shovely = 1, dirt = 3, soil = 1, soil_sugarcane = 1, cultivatable = 1, enderman_takable = 1, building_block = 1, soil_sapling = 2, path_creation_possible=1},
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

minetest.register_node("mcl_core:gravel", {
	description = S("Gravel"),
	_doc_items_longdesc = S("This block consists of a couple of loose stones and can't support itself."),
	tiles = {"default_gravel.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, falling_node=1, enderman_takable=1, building_block=1, material_sand=1},
	drop = {
		max_items = 1,
		items = {
			{items = {"mcl_core:flint"},rarity = 10},
			{items = {"mcl_core:gravel"}}
		}
	},
	sounds = mcl_sounds.node_sound_gravel_defaults(),
	_mcl_blast_resistance = 0.6,
	_mcl_hardness = 0.6,
	_mcl_silk_touch_drop = true,
	_mcl_fortune_drop = {
		[1] = {
			max_items = 1,
			items = {
				{items = {"mcl_core:flint"},rarity = 7},
				{items = {"mcl_core:gravel"}}
			}
		},
		[2] = {
			max_items = 1,
			items = {
				{items = {"mcl_core:flint"},rarity = 4},
				{items = {"mcl_core:gravel"}}
			}
		},
		[3] = "mcl_core:flint",
	},
	_vl_crushing_drop = { "mcl_core:greysand" },
})

minetest.register_node("mcl_core:greysand", {
	description = S("Grey Sand"),
	_doc_items_longdesc = S("Grey sand is found where stone erosion takes place."),
	_doc_items_hidden = false,
	tiles = {"mcl_core_grey_sand.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, falling_node=1, sand=1, soil_sugarcane=1, enderman_takable=1, building_block=1, material_sand=1},
	sounds = mcl_sounds.node_sound_sand_defaults(),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

-- sandstone --
minetest.register_node("mcl_core:sand", {
	description = S("Sand"),
	_doc_items_longdesc = S("Sand is found in large quantities at beaches and deserts."),
	_doc_items_hidden = false,
	tiles = {"default_sand.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, falling_node=1, sand=1, soil_sugarcane=1, enderman_takable=1, building_block=1, material_sand=1},
	sounds = mcl_sounds.node_sound_sand_defaults(),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

minetest.register_node("mcl_core:sandstone", {
	description = S("Sandstone"),
	_doc_items_hidden = false,
	_doc_items_longdesc = S("Sandstone is compressed sand and is a rather soft kind of stone."),
	tiles = {"mcl_core_sandstone_top.png", "mcl_core_sandstone_bottom.png", "mcl_core_sandstone_normal.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, sandstone=1, normal_sandstone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 0.8,
	_mcl_hardness = 0.8,
	_vl_crushing_drop = { "mcl_core:sand" },
})

minetest.register_node("mcl_core:sandstonesmooth", {
	description = S("Cut Sandstone"),
	_doc_items_longdesc = S("Cut sandstone is a decorative building block."),
	tiles = {"mcl_core_sandstone_top.png", "mcl_core_sandstone_bottom.png", "mcl_core_sandstone_smooth.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, sandstone=1, normal_sandstone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 0.8,
	_mcl_hardness = 0.8,
})

minetest.register_node("mcl_core:sandstonecarved", {
	description = S("Chiseled Sandstone"),
	_doc_items_longdesc = S("Chiseled sandstone is a decorative building block."),
	tiles = {"mcl_core_sandstone_top.png", "mcl_core_sandstone_bottom.png", "mcl_core_sandstone_carved.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, sandstone=1, normal_sandstone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 0.8,
	_mcl_hardness = 0.8,
})

minetest.register_node("mcl_core:sandstonesmooth2", {
	description = S("Smooth Sandstone"),
	_doc_items_hidden = false,
	_doc_items_longdesc = S("Smooth sandstone is compressed sand and is a rather soft kind of stone."),
	tiles = {"mcl_core_sandstone_top.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, sandstone=1, normal_sandstone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,
})

-- red sandstone --

minetest.register_node("mcl_core:redsand", {
	description = S("Red Sand"),
	_doc_items_longdesc = S("Red sand is found in large quantities in mesa biomes."),
	tiles = {"mcl_core_red_sand.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, falling_node=1, sand=1, soil_sugarcane=1, enderman_takable=1, building_block=1, material_sand=1},
	sounds = mcl_sounds.node_sound_sand_defaults(),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

minetest.register_node("mcl_core:redsandstone", {
	description = S("Red Sandstone"),
	_doc_items_longdesc = S("Red sandstone is compressed red sand and is a rather soft kind of stone."),
	tiles = {"mcl_core_red_sandstone_top.png", "mcl_core_red_sandstone_bottom.png", "mcl_core_red_sandstone_normal.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, sandstone=1, red_sandstone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 0.8,
	_mcl_hardness = 0.8,
	_vl_crushing_drop = { "mcl_core:redsand" },
})

minetest.register_node("mcl_core:redsandstonesmooth", {
	description = S("Cut Red Sandstone"),
	_doc_items_longdesc = S("Cut red sandstone is a decorative building block."),
	tiles = {"mcl_core_red_sandstone_top.png", "mcl_core_red_sandstone_bottom.png", "mcl_core_red_sandstone_smooth.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, sandstone=1, red_sandstone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 0.8,
	_mcl_hardness = 0.8,
})

minetest.register_node("mcl_core:redsandstonecarved", {
	description = S("Chiseled Red Sandstone"),
	_doc_items_longdesc = S("Chiseled red sandstone is a decorative building block."),
	tiles = {"mcl_core_red_sandstone_top.png", "mcl_core_red_sandstone_bottom.png", "mcl_core_red_sandstone_carved.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, sandstone=1, red_sandstone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 0.8,
	_mcl_hardness = 0.8,
})

minetest.register_node("mcl_core:redsandstonesmooth2", {
	description = S("Smooth Red Sandstone"),
	_doc_items_longdesc = S("Smooth red sandstone is a decorative building block."),
	tiles = {"mcl_core_red_sandstone_top.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, sandstone=1, red_sandstone=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,
})

---

minetest.register_node("mcl_core:clay", {
	description = S("Clay"),
	_doc_items_longdesc = S("Clay is a versatile kind of earth commonly found at beaches underwater."),
	_doc_items_hidden = false,
	tiles = {"default_clay.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, enderman_takable=1, building_block=1},
	drop = "mcl_core:clay_lump 4",
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0.6,
	_mcl_hardness = 0.6,
	_mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_core:brick_block", {
	-- Original name: “Bricks”
	description = S("Brick Block"),
	_doc_items_longdesc = S("Brick blocks are a good building material for building solid houses and can take quite a punch."),
	tiles = {"default_brick.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,
})


minetest.register_node("mcl_core:bedrock", {
	description = S("Bedrock"),
	_doc_items_longdesc = S("Bedrock is a very hard type of rock. It can not be broken, destroyed, collected or moved by normal means, unless in Creative Mode.").."\n"..
		S("In the End dimension, starting a fire on this block will create an eternal fire."),
	tiles = {"mcl_core_bedrock.png"},
	stack_max = 64,
	groups = {creative_breakable=1, building_block=1, material_stone=1, unbreakable=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	on_blast = function() end,
	drop = "",
	_mcl_blast_resistance = 3600000,
	_mcl_hardness = -1,

	-- Eternal fire on top of bedrock, if in the End dimension
	after_destruct = function(pos)
		pos.y = pos.y + 1
		if minetest.get_node(pos).name == "mcl_fire:eternal_fire" then
			minetest.remove_node(pos)
		end
	end,
	_on_ignite = function(player, pointed_thing)
		local pos = pointed_thing.under
		local dim = mcl_worlds.pos_to_dimension(pos)
		local flame_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
		local fn = minetest.get_node(flame_pos)
		local pname = player:get_player_name()
		if minetest.is_protected(flame_pos, pname) then
			return minetest.record_protection_violation(flame_pos, pname)
		end
		if dim == "end" and fn.name == "air" and pointed_thing.under.y < pointed_thing.above.y then
			minetest.set_node(flame_pos, {name = "mcl_fire:eternal_fire"})
			return true
		else
			return false
		end
	end,
})

minetest.register_node("mcl_core:cobble", {
	description = S("Cobblestone"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	_doc_items_hidden = false,
	tiles = {"default_cobble.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1, cobble=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,
	_vl_crushing_drop = { "mcl_core:gravel" }
})

minetest.register_node("mcl_core:mossycobble", {
	description = S("Mossy Cobblestone"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"default_mossycobble.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2,
})

minetest.register_node("mcl_core:coalblock", {
	description = S("Block of Coal"),
	_doc_items_longdesc = S("Blocks of coal are useful as a compact storage of coal and very useful as a furnace fuel. A block of coal is as efficient as 10 coal."),
	tiles = {"default_coal_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, flammable=1, building_block=1, material_stone=1, fire_encouragement=5, fire_flammability=5},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

minetest.register_node("mcl_core:charcoalblock", {
	description = S("Block of Charcoal"),
	_doc_items_longdesc = S("Blocks of charcoal are useful as a compact storage of charcoal and very useful as a furnace fuel. A block of charcoal is as efficient as 10 charcoal."),
	tiles = {"mcl_core_charcoal_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, flammable=1, building_block=1, material_stone=1, fire_encouragement=5, fire_flammability=5},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

minetest.register_node("mcl_core:ironblock", {
	description = S("Block of Iron"),
	_doc_items_longdesc = S("A block of iron is mostly a decorative block but also useful as a compact storage of iron ingots."),
	tiles = {"default_steel_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=2, building_block=1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

minetest.register_node("mcl_core:goldblock", {
	description = S("Block of Gold"),
	_doc_items_longdesc = S("A block of gold is mostly a shiny decorative block but also useful as a compact storage of gold ingots."),
	tiles = {"default_gold_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 3,
})

minetest.register_node("mcl_core:diamondblock", {
	description = S("Block of Diamond"),
	_doc_items_longdesc = S("A block of diamond is mostly a shiny decorative block but also useful as a compact storage of diamonds."),
	tiles = {"default_diamond_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

minetest.register_node("mcl_core:lapisblock", {
	description = S("Lapis Lazuli Block"),
	_doc_items_longdesc = S("A lapis lazuli block is mostly a decorative block but also useful as a compact storage of lapis lazuli."),
	tiles = {"mcl_core_lapis_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=3, building_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
})

minetest.register_node("mcl_core:emeraldblock", {
	description = S("Block of Emerald"),
	_doc_items_longdesc = S("A block of emerald is mostly a shiny decorative block but also useful as a compact storage of emeralds."),
	tiles = {"mcl_core_emerald_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=4, building_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
})

minetest.register_node("mcl_core:obsidian", {
	description = S("Obsidian"),
	_doc_items_longdesc = S("Obsidian is an extremely hard mineral with an enourmous blast-resistance. Obsidian is formed when water meets lava."),
	tiles = {"default_obsidian.png"},
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	stack_max = 64,
	groups = {pickaxey=5, building_block=1, material_stone=1},
	_mcl_blast_resistance = 1200,
	_mcl_hardness = 50,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if awards and awards.unlock and digger and digger:is_player() then
			awards.unlock(digger:get_player_name(), "mcl:obsidian")
		end
	end,
})

minetest.register_node("mcl_core:crying_obsidian", {
	description = S("Crying Obsidian"),
	_doc_items_longdesc = S("Crying obsidian is a luminous obsidian that can generate as part of ruined portals."),
	tiles = {"default_obsidian.png^mcl_core_crying_obsidian.png"},
	is_ground_content = false,
	light_source = 10,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	stack_max = 64,
	groups = {pickaxey=5, building_block=1, material_stone=1},
	_mcl_blast_resistance = 1200,
	_mcl_hardness = 50,
})

minetest.register_node("mcl_core:ice", {
	description = S("Ice"),
	_doc_items_longdesc = S("Ice is a solid block usually found in cold areas. It melts near block light sources at a light level of 12 or higher. When it melts or is broken while resting on top of another block, it will turn into a water source."),
	drawtype = ice_drawtype,
	tiles = {"default_ice.png"},
	is_ground_content = true,
	paramtype = "light",
	use_texture_alpha = ice_texture_alpha,
	stack_max = 64,
	groups = {handy=1,pickaxey=1, slippery=3, building_block=1, ice=1, oxidizable=1,},
    _mcl_oxidized_seasonal_variant = "mcl_core:water_source",
    _mcl_oxidized_season_disallowed = {"fall", "winter"},
	drop = "",
	sounds = mcl_sounds.node_sound_ice_defaults(),
	node_dig_prediction = "mcl_core:water_source",
	after_dig_node = function(pos, oldnode)
		mcl_core.melt_ice(pos)
	end,
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	_mcl_silk_touch_drop = true,
})

minetest.register_node("mcl_core:packed_ice", {
	description = S("Packed Ice"),
	_doc_items_longdesc = S("Packed ice is a compressed form of ice. It is opaque and solid."),
	tiles = {"mcl_core_ice_packed.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,pickaxey=1, slippery=3, building_block=1, ice=1},
	drop = "",
	sounds = mcl_sounds.node_sound_ice_defaults(),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	_mcl_silk_touch_drop = true,
})

-- Frosted Ice (4 nodes)
for i=0,3 do
	local ice = {}
	function ice.increase_age(pos, ice_near, first_melt)
		-- Increase age of frosted age or turn to water source if too old
		local nn = minetest.get_node(pos).name
		local age = tonumber(string.sub(nn, -1))
		local dim = mcl_worlds.pos_to_dimension(pos)
		if age == nil then return end
		if age < 3 then
			minetest.swap_node(pos, { name = "mcl_core:frosted_ice_"..(age+1) })
		else
			if dim ~= "nether" then
				minetest.set_node(pos, { name = "mcl_core:water_source" })
			else
				minetest.remove_node(pos)
			end
		end
		-- Spread aging to neighbor blocks, but not recursively
		if first_melt and i == 3 then
			for j=1, #ice_near do
				ice.increase_age(ice_near[j], false)
			end
		end
	end
	local use_doc = i == 0
	local longdesc
	if use_doc then
		longdesc = S("Frosted ice is a short-lived solid block. It melts into a water source within a few seconds.")
	end
	minetest.register_node("mcl_core:frosted_ice_"..i, {
		description = S("Frosted Ice"),
		_doc_items_create_entry = use_doc,
		_doc_items_longdesc = longdesc,
		drawtype = ice_drawtype,
		tiles = {"mcl_core_frosted_ice_"..i..".png"},
		is_ground_content = false,
		paramtype = "light",
		use_texture_alpha = ice_texture_alpha,
		stack_max = 64,
		groups = {handy=1, frosted_ice=1, slippery=3, not_in_creative_inventory=1, ice=1},
		drop = "",
		sounds = mcl_sounds.node_sound_ice_defaults(),
		on_construct = function(pos)
			local timer = minetest.get_node_timer(pos)
			timer:start(1.5)
		end,
		on_timer = function(pos, elapsed)
			local ice_near = minetest.find_nodes_in_area(
				{ x = pos.x - 1, y = pos.y - 1, z = pos.z - 1 },
				{ x = pos.x + 1, y = pos.y + 1, z = pos.z + 1 },
				{ "group:frosted_ice" }
			)
			-- Check condition to increase age
			if (#ice_near < 4 and minetest.get_node_light(pos) > (11 - i)) or math.random(1, 3) == 1 then
				ice.increase_age(pos, ice_near, true)
			end
			local timer = minetest.get_node_timer(pos)
			timer:start(1.5)
		end,
		_mcl_blast_resistance = 0.5,
		_mcl_hardness = 0.5,
	})

	-- Add entry aliases for the Help
	if minetest.get_modpath("doc") and i > 0 then
		doc.add_entry_alias("nodes", "mcl_core:frosted_ice_0", "nodes", "mcl_core:frosted_ice_"..i)
	end
end

for i=1,8 do
	local id, desc, longdesc, usagehelp, tt_help, help, walkable, drawtype, node_box
	if i == 1 then
		id = "mcl_core:snow"
		desc = S("Top Snow")
		tt_help = S("Stackable")
		longdesc = S("Top snow is a layer of snow. It melts near light sources other than the sun with a light level of 12 or higher.").."\n"..S("Top snow can be stacked and has one of 8 different height levels. At levels 2-8, top snow is collidable. Top snow drops 2-9 snowballs, depending on its height.")
		usagehelp = S("This block can only be placed on full solid blocks and on another top snow (which increases its height).")
		walkable = false
	else
		id = "mcl_core:snow_"..i
		help = false
		if minetest.get_modpath("doc") then
			doc.add_entry_alias("nodes", "mcl_core:snow", "nodes", id)
		end
		walkable = true
	end
	if i ~= 8 then
		drawtype = "nodebox"
		node_box = {
			type = "fixed",
			fixed = { -0.5, -0.5, -0.5, 0.5, -0.5 + (2*i)/16, 0.5 },
		}
	end
	local function on_place(itemstack, placer, pointed_thing)
		-- Placement is only allowed on top of solid blocks
		if pointed_thing.type ~= "node" then
			-- no interaction possible with entities
			return itemstack
		end
		local def = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]
		local above = pointed_thing.above
		local under = pointed_thing.under
		local unode = minetest.get_node(under)

		-- Check special rightclick action of pointed node
		if def and def.on_rightclick then
			if not placer:get_player_control().sneak then
				return def.on_rightclick(under, unode, placer, itemstack,
					pointed_thing) or itemstack, false
			end
		end

		-- Get position where snow would be placed
		local target
		if def and def.buildable_to then
			target = under
		else
			target = above
		end
		local tnode = minetest.get_node(target)

		-- Stack snow
		local g = minetest.get_item_group(tnode.name, "top_snow")
		if g > 0 then
			local itemstring = itemstack:get_name()
			local itemcount = itemstack:get_count()
			local fakestack = ItemStack(itemstring.." "..itemcount)
			if i+g < 8 then
				fakestack:set_name("mcl_core:snow_"..(i+g))
			else
				-- To stack `mcl_core:snow_8', just replacing it with `mcl_core:snowblock' Issue#4483
				if i+g == 9 then
				   fakestack:set_count(itemcount + 1)
				end
				fakestack:set_name("mcl_core:snowblock")
			end
			itemstack = minetest.item_place(fakestack, placer, pointed_thing)
			minetest.sound_play(mcl_sounds.node_sound_snow_defaults().place, {pos = pointed_thing.under}, true)
			itemstack:set_name(itemstring)
			return itemstack
		end

		-- Place snow normally
		local below = {x=target.x, y=target.y-1, z=target.z}
		local bnode = minetest.get_node(below)

		if minetest.get_item_group(bnode.name, "solid") == 1 then
			minetest.sound_play(mcl_sounds.node_sound_snow_defaults().place, {pos = below}, true)
			return minetest.item_place_node(itemstack, placer, pointed_thing)
		else
			return itemstack
		end
	end

	minetest.register_node(id, {
		description = desc,
		_tt_help = tt_help,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		_doc_items_create_entry = help,
		_doc_items_hidden = false,
		tiles = {"default_snow.png"},
		wield_image = "default_snow.png",
		wield_scale = { x=1, y=1, z=i },
		is_ground_content = true,
		paramtype = "light",
		sunlight_propagates = true,
		buildable_to = true,
		node_placement_prediction = "", -- to prevent client flickering when stacking snow
		drawtype = drawtype,
		stack_max = 64,
		walkable = walkable,
		floodable = true,
		on_flood = function(pos, oldnode, newnode)
			local npos = {x=pos.x, y=pos.y-1, z=pos.z}
			local node = minetest.get_node(npos)
			mcl_core.clear_snow_dirt(npos, node)
		end,
		node_box = node_box,
		groups = {shovely=2, supported_node=1, deco_block=1, dig_by_piston=1, snow_cover=1, top_snow=i},
		sounds = mcl_sounds.node_sound_snow_defaults(),
		on_construct = mcl_core.on_snow_construct,
		on_place = on_place,
		after_destruct = mcl_core.after_snow_destruct,
		drop = "mcl_throwing:snowball "..(i+1),
		_mcl_blast_resistance = 0.1,
		_mcl_hardness = 0.1,
		_mcl_silk_touch_drop = {"mcl_core:snow " .. i},
	})
end

minetest.register_node("mcl_core:snowblock", {
	description = S("Snow"),
	_doc_items_longdesc = S("This is a full block of snow. Snow of this thickness is usually found in areas of extreme cold."),
	_doc_items_hidden = false,
	tiles = {"default_snow.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {shovely=2, building_block=1, snow_cover=1},
	sounds = mcl_sounds.node_sound_snow_defaults(),
	on_construct = mcl_core.on_snow_construct,
	after_destruct = mcl_core.after_snow_destruct,
	drop = "mcl_throwing:snowball 4",
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.2,
	_mcl_silk_touch_drop = true,
})

-- Stonecutter recipes
mcl_stonecutter.register_recipe("mcl_core:stone", "mcl_core:stonebrick")
mcl_stonecutter.register_recipe("mcl_core:stone", "mcl_core:stonebrickcarved")
mcl_stonecutter.register_recipe("mcl_core:stonebrick", "mcl_core:stonebrickcarved")
mcl_stonecutter.register_recipe("mcl_core:granite", "mcl_core:granite_smooth")
mcl_stonecutter.register_recipe("mcl_core:andesite", "mcl_core:andesite_smooth")
mcl_stonecutter.register_recipe("mcl_core:diorite", "mcl_core:diorite_smooth")
mcl_stonecutter.register_recipe("mcl_core:sandstone", "mcl_core:sandstonesmooth")
mcl_stonecutter.register_recipe("mcl_core:sandstone", "mcl_core:sandstonecarved")
mcl_stonecutter.register_recipe("mcl_core:redsandstone", "mcl_core:redsandstonesmooth")
mcl_stonecutter.register_recipe("mcl_core:redsandstone", "mcl_core:redsandstonecarved")


-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_core:stone_with_redstone", "nodes", "mcl_core:stone_with_redstone_lit")
	doc.add_entry_alias("nodes", "mcl_core:water_source", "nodes", "mcl_core:water_flowing")
	doc.add_entry_alias("nodes", "mcl_core:lava_source", "nodes", "mcl_core:lava_flowing")
end
