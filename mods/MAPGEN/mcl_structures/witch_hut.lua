local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

local peaceful = minetest.settings:get_bool("only_peaceful_mobs", false)

local function spawn_witch(p1,p2)
	local c = minetest.find_node_near(p1,15,{"group:cauldron"})
	if not c then return end
	local nn = minetest.find_nodes_in_area_under_air(vector.new(p1.x,c.y-1,p1.z),vector.new(p2.x,c.y-1,p2.z),{"mcl_core:sprucewood"})
	local witchobj = not peaceful and #nn > 0 and minetest.add_entity(vector.offset(nn[math.random(#nn)],0,1,0),"mobs_mc:witch")
	if witchobj then
		local witch = witchobj:get_luaentity()
		witch._home = c
		witch.can_despawn = false
	end
	local catobj = #nn > 0 and minetest.add_entity(vector.offset(nn[math.random(#nn)],0,1,0),"mobs_mc:cat")
	if catobj then
		local cat=catobj:get_luaentity()
		cat.object:set_properties({textures = {"mobs_mc_cat_black.png"}})
		cat.owner = "!witch!" --so it's not claimable by player
		cat._home = c
		cat.can_despawn = false
	end
end

local function hut_placement_callback(pos,def,pr,p1,p2)
	-- p1.y is the bottom slice only, not a typo, we look for the hut legs
	local legs = minetest.find_nodes_in_area(p1,vector.new(p2.x,p1.y,p2.z), "mcl_core:sprucetree")
	if #legs == 0 then -- old schematic?
		legs = minetest.find_nodes_in_area(p1,vector.new(p2.x,p1.y,p2.z), "mcl_core:tree")
	end
	local tree = {}
	for _,leg in pairs(legs) do
		while true do
			local name = minetest.get_node(vector.offset(leg,0,-1,0)).name
			if name == "ignore" then break end
			if name ~= "air" and minetest.get_item_group(name, "water") == 0 then break end
			leg = vector.offset(leg,0,-1,0)
			table.insert(tree,leg)
		end
	end
	minetest.bulk_swap_node(tree, {name = "mcl_core:sprucetree", param2 = 2})
	spawn_witch(p1,p2)
	vl_structures.construct_nodes(p1, p2, {"mcl_brewing:stand_000"})
	-- TODO: add some bottles etc. to the brewing stand?
end

vl_structures.register_structure("witch_hut",{
	chunk_probability = 10, -- rare biome
	hash_mindist_2d = 80,
	place_on = {"mcl_core:water_source","group:sand","group:grass_block","group:dirt","mclx_core:river_water_source"},
	spawn_by = {"mcl_core:water_source","mclx_core:river_water_source"},
	check_offset = -1,
	num_spawn_by = 3,
	flags = "place_center_x, place_center_z, all_surfaces",
	prepare = { surface = "under_air", tolerance = 3, clear_bottom = 3, padding = 0, corners = 1, foundation = false, mode = "max" },
	y_max = mcl_vars.mg_overworld_max,
	y_min = -5,
	y_offset = -1,
	biomes = { "Swampland", "Swampland_ocean", "Swampland_shore" },
	filenames = {
		modpath.."/schematics/mcl_structures_witch_hut.mts",
	},
	after_place = hut_placement_callback,
})
