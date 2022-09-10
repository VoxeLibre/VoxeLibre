local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)


mcl_structures.register_structure("end_spawn_obsidian_platform",{
	static_pos ={mcl_vars.mg_end_platform_pos},
	place_func = function(pos,def,pr)
		local nn = minetest.find_nodes_in_area(vector.offset(pos,-2,0,-2),vector.offset(pos,2,0,2),{"air","mcl_end:end_stone"})
		minetest.bulk_set_node(nn,{name="mcl_core:obsidian"})
		return true
	end,
})

mcl_structures.register_structure("end_exit_portal",{
	static_pos = { mcl_vars.mg_end_exit_portal_pos },
	filenames = {
		modpath.."/schematics/mcl_structures_end_exit_portal.mts"
	},
	after_place = function(pos,def,pr)
		local nn = minetest.find_nodes_in_area(vector.offset(pos,-5,-1,-5),vector.offset(pos,5,5,5),{"mcl_end:portal_end"})
		minetest.bulk_set_node(nn,{name="air"})
	end
})
mcl_structures.register_structure("end_exit_portal_open",{
	--static_pos = { mcl_vars.mg_end_exit_portal_pos },
	filenames = {
		modpath.."/schematics/mcl_structures_end_exit_portal.mts"
	},
})
