-- Monster eggs!
-- Blocks which spawn silverfish when destroyed.

-- Intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP .. "/intllib.lua")

local spawn_silverfish = function(pos, oldnode, oldmetadata, digger)
	if not minetest.setting_getbool("creative_mode") then
		minetest.add_entity(pos, "mobs_mc:silverfish")
	end
end

-- Template function for registering monster egg blocks
local register_block = function(subname, description, tiles, is_ground_content)
	if is_ground_content == nil then
		is_ground_content = false
	end
	minetest.register_node("mcl_monster_eggs:monter_egg_"..subname, {
		description = description,
		tiles = tiles,
		is_ground_content = is_ground_content,
		groups = {handy = 1, spawns_silverfish = 1, deco_block = 1},
		drop = '',
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_stone_defaults(),
		after_dig_node = spawn_silverfish,
		_mcl_hardness = 0.75,
		_mcl_blast_resistance = 3.75,
	})
end

-- Register all the monster egg blocks
register_block("stone", S("Stone Monster Egg"), {"default_stone.png"}, true)
register_block("cobble", S("Cobblestone Monster Egg"), {"default_cobble.png"})
register_block("stonebrick", S("Stone Bricks Monster Egg"), {"default_stone_brick.png"})
register_block("stonebrickcracked", S("Cracked Stone Bricks Monster Egg"), {"mcl_core_stonebrick_cracked.png"})
register_block("stonebrickmossy", S("Mossy Stone Bricks Monster Egg"), {"mcl_core_stonebrick_mossy.png"})
register_block("stonebrickcarved", S("Chiseled Stone Bricks Monster Egg"), {"mcl_core_stonebrick_carved.png"})


