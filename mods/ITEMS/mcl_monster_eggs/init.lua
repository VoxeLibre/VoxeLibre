-- Monster eggs!
-- Blocks which spawn silverfish when destroyed.

-- Intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP .. "/intllib.lua")

local spawn_silverfish = function(pos, oldnode, oldmetadata, digger)
	if not minetest.settings:get_bool("creative_mode") then
		minetest.add_entity(pos, "mobs_mc:silverfish")
	end
end

-- Template function for registering monster egg blocks
local register_block = function(subname, description, tiles, is_ground_content)
	if is_ground_content == nil then
		is_ground_content = false
	end
	minetest.register_node("mcl_monster_eggs:monster_egg_"..subname, {
		description = description,
		tiles = tiles,
		is_ground_content = is_ground_content,
		groups = {handy = 1, spawns_silverfish = 1, deco_block = 1},
		drop = '',
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_stone_defaults(),
		after_dig_node = spawn_silverfish,
		_doc_items_longdesc = S("An infested block is a block from which a silverfish will pop out when it is broken. It looks identical to its normal counterpart."),
		_mcl_hardness = 0.75,
		_mcl_blast_resistance = 3.75,
	})
end

-- Register all the monster egg blocks
register_block("stone", S("Infested Stone"), {"default_stone.png"}, true)
register_block("cobble", S("Infested Cobblestone"), {"default_cobble.png"})
register_block("stonebrick", S("Infested Stone Bricks"), {"default_stone_brick.png"})
register_block("stonebrickcracked", S("Infested Cracked Stone Bricks"), {"mcl_core_stonebrick_cracked.png"})
register_block("stonebrickmossy", S("Infested Mossy Stone Bricks"), {"mcl_core_stonebrick_mossy.png"})
register_block("stonebrickcarved", S("Infested Chiseled Stone Bricks"), {"mcl_core_stonebrick_carved.png"})


