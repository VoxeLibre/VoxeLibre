local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

-- TODO: the schematics could use ignore/air to ensure a nice headroom and open entranceway, then we could reduce terraforming?
vl_structures.register_structure("graveyard",{
	place_on = {"group:grass_block","group:dirt","mcl_core:dirt_with_grass"},
	flags = "place_center_x, place_center_z",
	prepare = { tolerance = 2, clear_bottom = 0, clear_top = -2, padding = 1, corners = 2, foundation = -2 },
	chunk_probability = 40,
	y_offset = -3,
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
		local sp = minetest.find_nodes_in_area(p1,p2,{"mcl_mobspawners:spawner"})
		if #sp > 0 then
			mcl_mobspawners.setup_spawner(sp[1], "mobs_mc:zombie", 0, 10, 10, 10, 2)
		end
	end
})
