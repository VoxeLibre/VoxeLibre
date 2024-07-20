mcl_villages = {}
mcl_villages.modpath = minetest.get_modpath(minetest.get_current_modname())

local village_chance = tonumber(minetest.settings:get("mcl_villages_village_chance")) or 5

dofile(mcl_villages.modpath.."/const.lua")
dofile(mcl_villages.modpath.."/utils.lua")
dofile(mcl_villages.modpath.."/foundation.lua")
dofile(mcl_villages.modpath.."/buildings.lua")
dofile(mcl_villages.modpath.."/paths.lua")

local S = minetest.get_translator(minetest.get_current_modname())

--
-- register block for npc spawn
--
minetest.register_node("mcl_villages:stonebrickcarved", {
	description = S("Chiseled Stone Village Bricks"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_core_stonebrick_carved.png"},
	drop = "mcl_core:stonebrickcarved",
	groups = {pickaxey=1, stone=1, stonebrick=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_villages:structblock", {drawtype="airlike",groups = {not_in_creative_inventory=1},})

--
-- on map generation, try to build a settlement
--
local function build_a_settlement(minp, maxp, blockseed)
	if mcl_villages.village_exists(blockseed) then return end

	local pr = PseudoRandom(blockseed)
	local settlement_info = mcl_villages.create_site_plan(minp, maxp, pr)
	if not settlement_info then return end

	--mcl_villages.terraform(settlement_info, pr)
	mcl_villages.place_schematics(settlement_info, pr)
	mcl_villages.paths(settlement_info)
	mcl_villages.add_village(blockseed, settlement_info)
end

local function ecb_village(blockpos, action, calls_remaining, param)
	if calls_remaining >= 1 then return end
	local minp, maxp, blockseed = param.minp, param.maxp, param.blockseed
	build_a_settlement(minp, maxp, blockseed)
end

local villagegen={}
-- Disable natural generation in singlenode.
local mg_name = minetest.get_mapgen_setting("mg_name")
if mg_name ~= "singlenode" then
	mcl_mapgen_core.register_generator("villages", nil, function(minp, maxp, blockseed)
		if maxp.y < 0 or village_chance == 0 then return end
		local pr = PseudoRandom(blockseed)
		if pr:next(0, 100) > village_chance then return end
		local n=minetest.get_node_or_nil(minp)
		--if n and n.name == "mcl_villages:structblock" then return end
		if n and n.name ~= "air" then return end
		minetest.set_node(minp,{name="mcl_villages:structblock"})

		--[[minetest.emerge_area(
				minp, maxp, --vector.offset(minp, -16, -16, -16), vector.offset(maxp, 16, 16, 16),
				ecb_village,
				{ minp = vector.copy(minp), maxp = vector.copy(maxp), blockseed = blockseed }
		)]]--
		villagegen[minetest.pos_to_string(minp)]={minp=vector.new(minp), maxp=vector.new(maxp), blockseed=blockseed}
	end)
end

minetest.register_lbm({
	name = "mcl_villages:structblock",
	run_at_every_load = true,
	nodenames = {"mcl_villages:structblock"},
	action = function(pos, node)
		minetest.set_node(pos, {name = "air"})
		if not villagegen[minetest.pos_to_string(pos)] then return end
		local minp=villagegen[minetest.pos_to_string(pos)].minp
		local maxp=villagegen[minetest.pos_to_string(pos)].maxp
		minetest.emerge_area(minp, maxp, ecb_village, villagegen[minetest.pos_to_string(minp)])
		villagegen[minetest.pos_to_string(minp)]=nil
	end
})
-- manually place villages
if minetest.is_creative_enabled("") then
	minetest.register_craftitem("mcl_villages:tool", {
		description = S("mcl_villages build tool"),
		inventory_image = "default_tool_woodshovel.png",
		-- build settlement
		on_place = function(itemstack, placer, pointed_thing)
			if not pointed_thing.under then return end
			if not minetest.check_player_privs(placer, "server") then
				minetest.chat_send_player(placer:get_player_name(), S("Placement denied. You need the “server” privilege to place villages."))
				return
			end
			local minp = vector.subtract(pointed_thing.under, half_map_chunk_size)
	        local maxp = vector.add(pointed_thing.under, half_map_chunk_size)
			build_a_settlement(minp, maxp, math.random(0,32767))
		end
	})
	mcl_wip.register_experimental_item("mcl_villages:tool")
end
