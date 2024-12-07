local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

vl_structures.register_structure("graveyard",{
	place_on = {"group:grass_block","group:dirt","mcl_core:dirt_with_grass"},
	flags = "place_center_x, place_center_z",
	prepare = { tolerance = 3, clear_bottom = 1, clear_top = 0, padding = 0, corners = 1, foundation = -2 },
	y_offset = function(pr) return -(pr:next(3,3)) end,
	chunk_probability = 40,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "BirchForest", "Forest", "Plains", "Taiga" },
	filenames = {
		modpath.."/schematics/mcl_extra_structures_graveyard_1.mts",
		modpath.."/schematics/mcl_extra_structures_graveyard_2.mts",
	},
	loot = {
		["mcl_barrels:barrel_closed"] ={{
			stacks_min = 2,
			stacks_max = 6,
			items = {
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 16, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_core:gold_ingot", weight = 3, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_core:iron_ingot", weight = 5, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:diamond", weight = 1, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_tools:sword_diamond", weight = 15, },
				{ itemstring = "mcl_tools:pick_diamond", weight = 15, },
				{ itemstring = "mcl_tools:shovel_iron", weight = 15, },
				{ itemstring = "mcl_torches:torch", weight = 15, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_armor:chestplate_diamond", weight = 1 },
				{ itemstring = "mcl_armor:leggings_iron", weight = 2 },
			}
		}}
	},
	after_place = function(pos, _, pr, p1, p2)
		for _,n in pairs(minetest.find_nodes_in_area(p1,p2,{"group:wall"})) do
			mcl_walls.update_wall(n)
		end
		local sp = minetest.find_nodes_in_area(pos,vector.offset(pos,0,3,0),{"mcl_mobspawners:spawner"})
		if not sp[1] then return end
		mcl_mobspawners.setup_spawner(sp[1], "mobs_mc:zombie", 0, minetest.LIGHT_MAX+1, 10, 3, -1)
	end
})
