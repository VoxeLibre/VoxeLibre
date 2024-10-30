local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

local peaceful = minetest.settings:get_bool("only_peaceful_mobs", false)

local function spawn_witch(pos,def,pr,p1,p2)
	local c = minetest.find_node_near(p1,15,{"mcl_cauldrons:cauldron"})
	if c then
		local nn = minetest.find_nodes_in_area_under_air(vector.new(p1.x,c.y-1,p1.z),vector.new(p2.x,c.y-1,p2.z),{"group:stone"})
		local witch
		if not peaceful then
			witch = minetest.add_entity(vector.offset(nn[math.random(#nn)],0,1,0),"mobs_mc:witch"):get_luaentity()
			witch._home = c
			witch.can_despawn = false
		end
		local catobject = minetest.add_entity(vector.offset(nn[math.random(#nn)],0,1,0),"mobs_mc:cat")
		if catobject and catobject:get_pos() then
			local cat=catobject:get_luaentity()
			cat.object:set_properties({textures = {"mobs_mc_cat_black.png"}})
			cat.owner = "!witch!" --so it's not claimable by player
			cat._home = c
			cat.can_despawn = false
		end
		return
	end
end

vl_structures.register_structure("witches_circle",{
	place_on = {"group:grass_block", "group:dirt", "mclx_core:river_water_source"},
	flags = "place_center_x, place_center_z, all_surfaces",
	chunk_probability = 14,
	prepare = { tolerance=4, clear_bottom=1, clear_top=-1, padding=0, corners=3, foundation=-2 },
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	y_offset = -1,
	force_placement = false,
	biomes = { "Swampland", "Swampland_shore", "RoofedForest", },
	filenames = { modpath.."/schematics/witch_circle.mts" },
	construct_nodes = {"group:wall"}, -- fix wall orientation
	after_place = spawn_witch,
})

