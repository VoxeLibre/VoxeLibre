local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

local peaceful = minetest.settings:get_bool("only_peaceful_mobs", false)

local function spawn_witch(p1,p2)
	local c = minetest.find_node_near(p1,15,{"mcl_cauldrons:cauldron"})
	if c then
		local nn = minetest.find_nodes_in_area_under_air(vector.new(p1.x,c.y-1,p1.z),vector.new(p2.x,c.y-1,p2.z),{"mcl_core:sprucewood"})
		local witch
		if not peaceful then
			witch = minetest.add_entity(vector.offset(nn[math.random(#nn)],0,1,0),"mobs_mc:witch"):get_luaentity()
			witch._home = c
			witch.can_despawn = false
		end
		local cat = minetest.add_entity(vector.offset(nn[math.random(#nn)],0,1,0),"mobs_mc:cat"):get_luaentity()
		cat.object:set_properties({textures = {"mobs_mc_cat_black.png"}})
		cat.owner = "!witch!" --so it's not claimable by player
		cat._home = c
		cat.can_despawn = false
		return
	end
end

local function hut_placement_callback(pos,def,pr,p1,p2)
	-- p1.y is the bottom slice only, not a typo, we look for the hut legs
	local legs = minetest.find_nodes_in_area(p1,vector.new(p2.x,p1.y,p2.z), "mcl_core:tree")
	local tree = {}
	-- TODO: port leg generation to VoxelManip?
	for _,leg in pairs(legs) do
		while true do
			local name = minetest.get_node(vector.offset(leg,0,-1,0)).name
			if name == "ignore" then break end
			if name ~= "air" and minetest.get_item_group(name, "water") == 0 then break end
			leg = vector.offset(leg,0,-1,0)
			table.insert(tree,leg)
		end
	end
	minetest.bulk_set_node(tree, {name = "mcl_core:tree", param2 = 2})
	spawn_witch(p1,p2)
end

vl_structures.register_structure("witch_hut",{
	place_on = {"mcl_core:water_source","group:sand","group:grass_block","group:dirt","mclx_core:river_water_source"},
	spawn_by = {"mcl_core:water_source","mclx_core:river_water_source"},
	check_offset = -1,
	num_spawn_by = 3,
	flags = "place_center_x, place_center_z, all_surfaces",
	chunk_probability = 8,
	prepare = { mode="under_air", tolerance=4, clear_bottom=3, padding=0, corners=1, foundation=false },
	y_max = mcl_vars.mg_overworld_max,
	y_min = -5,
	y_offset = 0,
	biomes = { "Swampland", "Swampland_ocean", "Swampland_shore" },
	filenames = { modpath.."/schematics/mcl_structures_witch_hut.mts" },
	after_place = hut_placement_callback,
})
