local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)
local overworld_bounds = vl_worlds.get_dimension_bounds("overworld")
assert(overworld_bounds)

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

local function hut_placement_callback(pos,def,pr)
	local hl = def.sidelen / 2
	local p1 = vector.offset(pos,-hl,-hl,-hl)
	local p2 = vector.offset(pos,hl,hl,hl)
	local legs = minetest.find_nodes_in_area(vector.offset(pos,-hl,0,-hl),vector.offset(pos,hl,0,hl), "mcl_core:tree")
	local tree = {}
	for _,leg in pairs(legs) do
		while minetest.get_item_group(mcl_vars.get_node(vector.offset(leg,0,-1,0), true, 333333).name, "water") ~= 0 do
			leg = vector.offset(leg,0,-1,0)
			table.insert(tree,leg)
		end
	end
	minetest.bulk_set_node(tree, {name = "mcl_core:tree", param2 = 2})
	spawn_witch(p1,p2)
end

mcl_structures.register_structure("witch_hut",{
	place_on = {"mcl_core:water_source","mclx_core:river_water_source"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z, liquid_surface, force_placement",
	sidelen = 8,
	chunk_probability = 300,
	y_max = overworld_bounds.max,
	y_min = -4,
	y_offset = 0,
	biomes = { "Swampland", "Swampland_ocean", "Swampland_shore" },
	filenames = { modpath.."/schematics/mcl_structures_witch_hut.mts" },
	after_place = hut_placement_callback,
})
