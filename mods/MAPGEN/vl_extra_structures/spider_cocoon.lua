local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

vl_structures.register_structure("cocoon",{
	chunk_probability = 0.5,
	hash_mindist = 120,
	place_on = {"group:material_stone"},
	flags = "place_center_x, place_center_z, all_floors",
	y_max = -10,
	y_min = mcl_vars.mg_overworld_min,
	y_offset = 2,
	spawn_by = "air",
	check_offset = 1,
	num_spawn_by = 6,
	force_placement = false,
	prepare = { foundation = false, clear = false, clear_top = 0, padding = -1, corners = 1 }, -- TODO: make clear/foundation not use grass
	filenames = {
		modpath.."/schematics/cocoon_1.mts"
	},
	after_place = function(p,def,pr,p1,p2)
		if mcl_mobspawners then
			local spawner = core.find_nodes_in_area(p1,p2,{"mcl_mobspawners:spawner"})
			if #spawner > 0 then
				mcl_mobspawners.setup_spawner(spawner[1], "mobs_mc:cave_spider", 0, 7, 4, 15, -3)
			end
		end
		-- p2.y is the top slice only, not a typo, we look for the rope
		local cs = core.find_nodes_in_area(vector.new(p1.x,p2.y,p1.z), p2, "mcl_wool:white")
		local rope = {}
		-- TODO: port to VoxelManip?
		for _,c in pairs(cs) do
			while true do
				c = vector.offset(c,0,1,0)
				local name = core.get_node(c).name
				if name == "ignore" then break end
				if name ~= "air" then break end
				table.insert(rope,c)
			end
		end
		core.bulk_swap_node(rope, {name = "mcl_wool:white", param2 = 2})
		-- remove some of the spiderwebs to add variation
		local ws = core.find_nodes_in_area(p1, p2, "mcl_core:cobweb")
		local clear = {}
		for i = 1,math.floor(#ws/4) do
			if #ws == 0 then break end
			local idx = pr:next(1,#ws)
			table.insert(clear, ws[idx])
			table.remove(ws, idx)
		end
		core.bulk_swap_node(clear, {name = "air"})
	end,
	loot = {
		["mcl_chests:chest_small"] = {
			{
				stacks_min = 2,
				stacks_max = 4,
				items = {
					{ itemstring = "mcl_mobitems:bone", weight = 10, amount_min = 2, amount_max = 4 },
					{ itemstring = "mcl_farming:potato_item_poison", weight = 7, amount_min = 2, amount_max = 6 },
					{ itemstring = "mcl_mobitems:rotten_flesh", weight = 5, amount_min = 5, amount_max = 24 },
					{ itemstring = "mcl_farming:potato_item", weight = 3, amount_min = 1, amount_max = 5 },
					{ itemstring = "mcl_tnt:tnt", weight = 1, amount_min = 1, amount_max = 2 },
				}
			},
			{
				stacks_min = 2,
				stacks_max = 4,
				items = {
					{ itemstring = "mcl_core:iron_ingot", weight = 90, amount_min = 1, amount_max = 2 },
					{ itemstring = "mcl_core:iron_nugget", weight = 50, amount_min = 1, amount_max = 10 },
					{ itemstring = "mcl_core:emerald", weight = 40, amount_min = 1, amount_max = 5 },
					{ itemstring = "mcl_core:lapis", weight = 20, amount_min = 1, amount_max = 10 },
					{ itemstring = "mcl_core:gold_ingot", weight = 10, amount_min = 1, amount_max = 1 },
					{ itemstring = "mcl_core:gold_nugget", weight = 10, amount_min = 1, amount_max = 4 },
					{ itemstring = "mcl_experience:bottle", weight = 5, amount_min = 1, amount_max = 1 },
					{ itemstring = "mcl_core:diamond", weight = 5, amount_min = 1, amount_max = 1 },
				}
			},{
				stacks_min = 1,
				stacks_max = 1,
				items = {
					--{ itemstring = "FIXME TREASURE MAP", weight = 8, amount_min = 1, amount_max = 5 },
					{ itemstring = "mcl_core:paper", weight = 20, amount_min = 1, amount_max = 10 },
					{ itemstring = "mcl_mobitems:bone", weight = 10, amount_min = 2, amount_max = 4 },
					{ itemstring = "mcl_mobitems:rotten_flesh", weight = 5, amount_min = 3, amount_max = 8 },
					{ itemstring = "mcl_books:book", weight = 5, amount_min = 1, amount_max = 1 },
					{ itemstring = "mcl_clock:clock", weight = 1, amount_min = 1, amount_max = 1 },
					{ itemstring = "mcl_compass:compass", weight = 1, amount_min = 1, amount_max = 1 },
					{ itemstring = "mcl_maps:empty_map", weight = 1, amount_min = 1, amount_max = 1 },
				}
			},
		}
	}
})

