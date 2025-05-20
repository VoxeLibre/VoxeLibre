settlements = {}
settlements.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(settlements.modpath.."/const.lua")
dofile(settlements.modpath.."/utils.lua")
dofile(settlements.modpath.."/foundation.lua")
dofile(settlements.modpath.."/buildings.lua")
dofile(settlements.modpath.."/paths.lua")
--dofile(settlements.modpath.."/convert_lua_mts.lua")
--
-- load settlements on server
--
settlements.grundstellungen()

local S = minetest.get_translator(minetest.get_current_modname())

local villagegen={}
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



--[[ Enable for testing, but use MineClone2's own spawn code if/when merging.
--
-- register inhabitants
--
if minetest.get_modpath("mobs_mc") then
  mcl_mobs:register_spawn("mobs_mc:villager", --name
    {"mcl_core:stonebrickcarved"}, --nodes
    15, --max_light
    0, --min_light
    20, --chance
    7, --active_object_count
    31000, --max_height
    nil) --day_toggle
end
--]]

--
-- on map generation, try to build a settlement
--
local function build_a_settlement(minp, maxp, blockseed)
	local pr = PseudoRandom(blockseed)

	-- fill settlement_info with buildings and their data
	local settlement_info = settlements.create_site_plan(maxp, minp, pr)
	if not settlement_info then return end

	-- evaluate settlement_info and prepair terrain
	settlements.terraform(settlement_info, pr)

	-- evaluate settlement_info and build paths between buildings
	settlements.paths(settlement_info)

	-- evaluate settlement_info and place schematics
	settlements.place_schematics(settlement_info, pr)
end

local function ecb_village(blockpos, action, calls_remaining, param)
	if calls_remaining >= 1 then return end
	local minp, maxp, blockseed = param.minp, param.maxp, param.blockseed
	build_a_settlement(minp, maxp, blockseed)
end

-- Disable natural generation in singlenode.
local mg_name = minetest.get_mapgen_setting("mg_name")
if mg_name ~= "singlenode" then
	mcl_mapgen_core.register_generator("villages", nil, function(minp, maxp, blockseed)
		if maxp.y < 0 then return end

		-- randomly try to build settlements
		if blockseed % 77 ~= 17 then return end
		--minetest.log("Rng good. Generate attempt")

		-- needed for manual and automated settlement building
		-- don't build settlements on (too) uneven terrain
		local n=minetest.get_node_or_nil(minp)
		if n and n.name == "mcl_villages:structblock" then return end
		--minetest.log("No existing village attempt here")

		if villagegen[minetest.pos_to_string(minp)] ~= nil then return end

		--minetest.log("Not in village gen. Put down placeholder: " .. minetest.pos_to_string(minp) .. " || " .. minetest.pos_to_string(maxp))
		minetest.set_node(minp,{name="mcl_villages:structblock"})

		local height_difference = settlements.evaluate_heightmap()
		if not height_difference or height_difference > max_height_difference then
			minetest.log("action", "Do not spawn village here as heightmap not good")
			return
		end
		--minetest.log("Build me a village: " .. minetest.pos_to_string(minp) .. " || " .. minetest.pos_to_string(maxp))
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
minetest.register_craftitem("mcl_villages:tool", {
	description = S("mcl_villages build tool"),
	inventory_image = "default_tool_woodshovel.png",
	-- build ssettlement
	on_place = function(itemstack, placer, pointed_thing)
		if not pointed_thing.under then return end
		if not minetest.check_player_privs(placer, "server") then
			minetest.chat_send_player(placer:get_player_name(), S("Placement denied. You need the “server” privilege to place villages."))
			return
		end
		local minp = vector.subtract(	pointed_thing.under, half_map_chunk_size)
		   local maxp = vector.add(	pointed_thing.under, half_map_chunk_size)
		build_a_settlement(minp, maxp, math.random(0,32767))
	end
})
mcl_wip.register_experimental_item("mcl_villages:tool")
