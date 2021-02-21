settlements = {}
settlements.modpath = minetest.get_modpath("mcl_villages")

dofile(settlements.modpath.."/const.lua")
dofile(settlements.modpath.."/utils.lua")
dofile(settlements.modpath.."/foundation.lua")
dofile(settlements.modpath.."/buildings.lua")
dofile(settlements.modpath.."/paths.lua")
--dofile(settlements.modpath.."/convert_lua_mts.lua")
--
-- load settlements on server
--
settlements_in_world = settlements.load()
settlements.grundstellungen()


--
-- register block for npc spawn
--
minetest.register_node("mcl_villages:stonebrickcarved", {
	description = ("Chiseled Stone Village Bricks"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_core_stonebrick_carved.png"},
	stack_max = 64,
	drop = "mcl_core:stonebrickcarved",
	groups = {pickaxey=1, stone=1, stonebrick=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})




--[[ Enable for testing, but use MineClone2's own spawn code if/when merging.
--
-- register inhabitants
--
if minetest.get_modpath("mobs_mc") ~= nil then
  mobs:register_spawn("mobs_mc:villager", --name
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

	-- evaluate settlement_info and initialize furnaces and chests
	settlements.initialize_nodes(settlement_info, pr)
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
		-- don't build settlement underground
		if maxp.y < 0 then return end
		-- randomly try to build settlements
		if blockseed % 77 ~= 17 then return end
		-- needed for manual and automated settlement building
		-- don't build settlements on (too) uneven terrain
		local heightmap = minetest.get_mapgen_object("heightmap")
		local height_difference = settlements.evaluate_heightmap()
		if height_difference > max_height_difference then return end

		local param={minp=vector.new(minp), maxp=vector.new(maxp), blockseed=blockseed}
		minetest.emerge_area(minp, maxp, ecb_village, param)
	end)
end
-- manually place villages
if minetest.is_creative_enabled("") then
	minetest.register_craftitem("mcl_villages:tool", {
		description = "mcl_villages build tool",
		inventory_image = "default_tool_woodshovel.png",
		-- build ssettlement
		on_place = function(itemstack, placer, pointed_thing)
			if not pointed_thing.under then return end
			local minp = vector.subtract(	pointed_thing.under, half_map_chunk_size)
		        local maxp = vector.add(	pointed_thing.under, half_map_chunk_size)
			build_a_settlement(minp, maxp, math.random(0,32767))
		end
	})
end
