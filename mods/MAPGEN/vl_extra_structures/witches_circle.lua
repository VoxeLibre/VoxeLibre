local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

local peaceful = core.settings:get_bool("only_peaceful_mobs", false)

local function spawn_witch(pos,def,pr,p1,p2)
	local c = core.find_node_near(p1,15,{"group:cauldron"})
	if not c then return end
	local nn = core.find_nodes_in_area_under_air(vector.new(p1.x,c.y-1,p1.z),vector.new(p2.x,c.y-1,p2.z),{"group:stone"})
	if #nn == 0 then return end
	local witchobj = not peaceful and core.add_entity(vector.offset(nn[math.random(#nn)],0,1,0),"mobs_mc:witch")
	if witchobj then
		local witch = witchobj:get_luaentity()
		witch._home = c
		witch.can_despawn = false
	end
	local catobj = core.add_entity(vector.offset(nn[math.random(#nn)],0,1,0),"mobs_mc:cat")
	if catobj then
		local cat = catobj:get_luaentity()
		cat.object:set_properties({textures = {"mobs_mc_cat_black.png"}})
		cat.owner = "!witch!" --so it's not claimable by player
		cat._home = c
		cat.can_despawn = false
	end
end

vl_structures.register_structure("witches_circle",{
	chunk_probability = 1,
	hash_mindist_2d = 120,
	place_on = {"group:grass_block", "group:dirt", "mclx_core:river_water_source"},
	flags = "place_center_x, place_center_z, all_surfaces",
	prepare = { tolerance = 3, clear_bottom = 1, clear_top = 0, padding = 0, corners = 1, foundation = -2 },
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	y_offset = -1,
	force_placement = false,
	biomes = { "Swampland", "Swampland_shore", "RoofedForest", },
	filenames = { modpath.."/schematics/witches_circle.mts" },
	construct_nodes = {"group:wall"}, -- fix wall orientation
	after_place = spawn_witch,
})

