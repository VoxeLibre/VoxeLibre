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

--[[ Disable custom node spawning.
--
-- register block for npc spawn
--
minetest.register_node("settlements:junglewood", {
    description = "special junglewood floor",
    tiles = {"default_junglewood.png"},
    groups = {choppy=3, wood=2},
    sounds = default.node_sound_wood_defaults(),
  })

--]]


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
local function build_a_settlement_no_delay(minp, maxp, blockseed)
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

local function ecb_build_a_settlement(blockpos, action, calls_remaining, param)
	if calls_remaining <= 0 then
		build_a_settlement_no_delay(param.minp, param.maxp, param.blockseed)
	end
end

minetest.register_on_generated(function(minp, maxp, blockseed)
	-- needed for manual and automated settlement building
	local heightmap = minetest.get_mapgen_object("heightmap")

	-- randomly try to build settlements
	if blockseed % 77 ~= 17 then return end

	-- don't build settlement underground
	if maxp.y < 0 then return end

	-- don't build settlements on (too) uneven terrain
	local height_difference = settlements.evaluate_heightmap(minp, maxp)
	if height_difference > max_height_difference then return end

	-- new way - slow :((((( 
	minetest.emerge_area(vector.subtract(minp,24), vector.add(maxp,24), ecb_build_a_settlement, {minp = vector.new(minp), maxp=vector.new(maxp), blockseed=blockseed})
	-- old way - wait 3 seconds:
	-- minetest.after(3, ecb_build_a_settlement, nil, 1, 0, {minp = vector.new(minp), maxp=vector.new(maxp), blockseed=blockseed})
end)

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
			build_a_settlement_no_delay(minp, maxp, math.random(0,32767))
		end
	})
end
