settlements = {}
settlements.modpath = minetest.get_modpath(minetest.get_current_modname())

local minetest_get_spawn_level = minetest.get_spawn_level

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
if minetest.get_modpath("mobs_mc") then
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
	minetest.log("action","[mcl_villages] Building village at mapchunk " .. minetest.pos_to_string(minp) .. "..." .. minetest.pos_to_string(maxp) .. ", blockseed = " .. tostring(blockseed))
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

-- Disable natural generation in singlenode.
local mg_name = minetest.get_mapgen_setting("mg_name")
if mg_name ~= "singlenode" then
	mcl_mapgen.register_chunk_generator(function(minp, maxp, blockseed)
		-- local str1 = (maxp.y >= 0 and blockseed % 77 == 17) and "YES" or "no"
		-- minetest.log("action","[mcl_villages] " .. str1 .. ": minp=" .. minetest.pos_to_string(minp) .. ", maxp=" .. minetest.pos_to_string(maxp) .. ", blockseed=" .. tostring(blockseed))
		-- don't build settlement underground
		if maxp.y < 0 then return end
		-- randomly try to build settlements
		if blockseed % 77 ~= 17 then return end

		-- don't build settlements on (too) uneven terrain

		-- lame and quick replacement of `heightmap` by kay27 - we maybe need to restore `heightmap` analysis if there will be a way for the engine to avoid cavegen conflicts:
		--------------------------------------------------------------------------
		local height_difference, min, max
		local pr1=PseudoRandom(blockseed)
		for i=1,pr1:next(5,10) do
			local x = pr1:next(0, 40) + minp.x + 19
			local z = pr1:next(0, 40) + minp.z + 19
			local y = minetest_get_spawn_level(x, z)
			if not y then return end
			if y < (min or y+1) then min = y end
			if y > (max or y-1) then max = y end
		end
		height_difference = max - min + 1
		--------------------------------------------------------------------------

		if height_difference > max_height_difference then return end

		build_a_settlement(minp, maxp, blockseed)
	end, mcl_mapgen.priorities.VILLAGES)
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
	mcl_wip.register_experimental_item("mcl_villages:tool")
end
