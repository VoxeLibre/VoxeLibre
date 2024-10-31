local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

local peaceful = minetest.settings:get_bool("only_peaceful_mobs", false)

local function spawn_witch(pos,def,pr,p1,p2)
	local c = minetest.find_node_near(p1,15,{"group:cauldron"})
	if not c then return end
	local nn = minetest.find_nodes_in_area_under_air(vector.new(p1.x,c.y-1,p1.z),vector.new(p2.x,c.y-1,p2.z),{"group:stone"})
	if #nn == 0 then return end
	local witchobj = not peaceful and minetest.add_entity(vector.offset(nn[math.random(#nn)],0,1,0),"mobs_mc:witch")
	if witchobj then
		local witch = witchobj:get_luaentity()
		witch._home = c
		witch.can_despawn = false
	end
	local catobj = minetest.add_entity(vector.offset(nn[math.random(#nn)],0,1,0),"mobs_mc:cat")
	if catobj then
		local cat = catobj:get_luaentity()
		cat.object:set_properties({textures = {"mobs_mc_cat_black.png"}})
		cat.owner = "!witch!" --so it's not claimable by player
		cat._home = c
		cat.can_despawn = false
	end
end

vl_structures.register_structure("witches_circle",{
	place_on = {"group:grass_block", "group:dirt", "mclx_core:river_water_source"},
	flags = "place_center_x, place_center_z, all_surfaces",
	chunk_probability = 20,
	prepare = { tolerance = 3, clear_bottom = 1, clear_top = 0, padding = 0, corners = 1, foundation = -2 },
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	y_offset = -1,
	force_placement = false,
	biomes = { "Swampland", "Swampland_shore", "RoofedForest", },
	filenames = { modpath.."/schematics/witch_circle.mts" },
	construct_nodes = {"group:wall"}, -- fix wall orientation
	after_place = spawn_witch,
})

