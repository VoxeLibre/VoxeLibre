local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local BLAZE_SPAWNER_MAX_LIGHT = 11

vl_structures.register_structure("nether_outpost",{
	chunk_probability = 5,
	hash_mindist_2d = 60,
	place_on = {"mcl_nether:netherrack","mcl_crimson:crimson_nylium","mcl_crimson:warped_nylium","mcl_blackstone:basalt","mcl_blackstone:soul_soil","mcl_blackstone:blackstone","mcl_nether:soul_sand"},
	flags = "place_center_x, place_center_y, all_floors",
	biomes = {"Nether","SoulsandValley","WarpedForest","CrimsonForest","BasaltDelta"},
	prepare = { tolerance = 20, padding = 4, corners = 5, foundation = true, clear = true, clear_top = 4 },
	y_min = mcl_vars.mg_lava_nether_max - 1,
	y_max = mcl_vars.mg_nether_max - 30,
	filenames = { modpath.."/schematics/mcl_nether_fortresses_nether_outpost.mts" },
	y_offset = 0,
	after_place = function(pos,def,pr,p1,p2)
		local sp = minetest.find_nodes_in_area(p1,p2,{"mcl_mobspawners:spawner"})
		if not sp[1] then return end
		mcl_mobspawners.setup_spawner(sp[1], "mobs_mc:blaze", 0, BLAZE_SPAWNER_MAX_LIGHT, 10, 8, 0)
	end
})
local nbridges = {
		modpath.."/schematics/mcl_nether_fortresses_nether_bridge_1.mts",
		modpath.."/schematics/mcl_nether_fortresses_nether_bridge_2.mts",
		modpath.."/schematics/mcl_nether_fortresses_nether_bridge_3.mts",
		modpath.."/schematics/mcl_nether_fortresses_nether_bridge_4.mts",
}
vl_structures.register_structure("nether_bridge",{
	chunk_probability = 10, -- because of the y restriction these are quite rare
	hash_mindist_2d = 60,
	place_on = {"mcl_nether:nether_lava_source","mcl_nether:netherrack","mcl_crimson:crimson_nylium","mcl_crimson:warped_nylium","mcl_blackstone:basalt","mcl_blackstone:soul_soil","mcl_blackstone:blackstone","mcl_nether:soul_sand"},
	flags = "place_center_x, place_center_y, all_floors",
	prepare = { tolerance = 50, padding = -1, corners = 0, clear_bottom = 8, clear_top = 6 }, -- asymmetric padding would be nice to have
	force_placement = true,
	y_min = mcl_vars.mg_lava_nether_max,
	y_max = mcl_vars.mg_lava_nether_max + 25, -- otherwise, we may see some very long legs
	filenames = nbridges,
	y_offset = function(pr) return pr:next(-12, -8) end,
	after_place = function(pos,def,pr,p1,p2)
		vl_structures.spawn_mobs("mobs_mc:witherskeleton",{"mcl_blackstone:blackstone_chiseled_polished"},p1,p2,pr,5)
		-- p1.y is not a typo, we want to lowest level only
		local legs = minetest.find_nodes_in_area(vector.new(p1.x,p1.y,p1.z),vector.new(p2.x,p1.y,p2.z), "mcl_nether:nether_brick")
		local bricks = {}
		for _,leg in pairs(legs) do
			while true do
				leg = vector.offset(leg,0,-1,0)
				local nodename = minetest.get_node(leg).name
				if nodename == "ignore" or nodename == "mcl_nether:soul_sand" then break end
				if nodename ~= "air" and nodename ~= "mcl_core:lava_source" and minetest.get_item_group(nodename, "solid") ~= 0 then break end
				table.insert(bricks,leg)
			end
		end
		minetest.bulk_swap_node(bricks, {name = "mcl_nether:nether_brick", param2 = 2})
	end
})

vl_structures.register_structure("nether_outpost_with_bridges",{
	chunk_probability = 10,
	hash_mindist_2d = 120,
	place_on = {"mcl_nether:netherrack","mcl_crimson:crimson_nylium","mcl_crimson:warped_nylium","mcl_blackstone:basalt","mcl_blackstone:soul_soil","mcl_blackstone:blackstone","mcl_nether:soul_sand","mcl_nether:nether_lava_source"},
	flags = "place_center_x, place_center_y, all_floors",
	biomes = {"Nether","SoulsandValley","WarpedForest","CrimsonForest","BasaltDelta"},
	prepare = { tolerance = 20, padding = 4, corners = 5, foundation = true, clear_top = 3 },
	y_min = mcl_vars.mg_lava_nether_max - 1,
	y_max = mcl_vars.mg_lava_nether_max + 40,
	-- todo: spawn_by a lot of air?
	filenames = { modpath.."/schematics/mcl_nether_fortresses_nether_outpost.mts" },
	emerge_padding = { vector.new(-38,-8,-38), vector.new(38,0,38) },
	daughters = {
		{
			filenames = { nbridges[1], nbridges[2] },
			pos = vector.new(0,-3,24),
			rotation= 0,
			no_level = true,
			prepare = { tolerance = "off", foundation = false, clear = true, clear_bottom = 16, clear_top = 2, padding = 1, corners = 4 },
		},
		{
			filenames = { nbridges[1], nbridges[2] },
			pos = vector.new(24,-3,0),
			rotation = 90,
			no_level = true,
			prepare = { tolerance = "off", foundation = false, clear = true, clear_bottom = 16, clear_top = 2, padding = 1, corners = 4 },
		},
		{
			filenames = { nbridges[1], nbridges[2] },
			pos = vector.new(0,-3,-25),
			rotation = 180,
			no_level = true,
			prepare = { tolerance = "off", foundation = false, clear = true, clear_bottom = 16, clear_top = 2, padding = 1, corners = 4 },
		},
		{
			filenames = { nbridges[1], nbridges[2] },
			pos = vector.new(-25,-3,0),
			rotation = 270,
			no_level = true,
			prepare = { tolerance = "off", foundation = false, clear = true, clear_bottom = 16, clear_top = 2, padding = 1, corners = 4 },
		},
	},
	after_place = function(pos,def,pr,p1,p2)
		local sp = minetest.find_nodes_in_area(p1,p2,{"mcl_mobspawners:spawner"})
		if not sp[1] then return end
		mcl_mobspawners.setup_spawner(sp[1], "mobs_mc:blaze", 0, BLAZE_SPAWNER_MAX_LIGHT, 10, 8, 0)
		-- the -3 offset needs to be carefully aligned with the bridges above
		local legs = minetest.find_nodes_in_area(vector.offset(pos,-45,-3,-45),vector.offset(pos,45,-3,45), "mcl_nether:nether_brick")
		local bricks = {}
		-- TODO: port leg generation to voxel manipulators?
		for _,leg in pairs(legs) do
			while true do
				leg = vector.offset(leg,0,-1,0)
				local nodename = minetest.get_node(leg).name
				if nodename == "ignore" or nodename == "mcl_nether:soul_sand" then break end
				if nodename ~= "air" and nodename ~= "mcl_core:lava_source" and minetest.get_item_group(nodename, "solid") ~= 0 then break end
				table.insert(bricks,leg)
			end
		end
		minetest.bulk_swap_node(bricks, {name = "mcl_nether:nether_brick", param2 = 2})

		local p1, p2 = vector.offset(pos,-45,12,-45), vector.offset(pos,45,22,45)
		vl_structures.spawn_mobs("mobs_mc:witherskeleton",{"mcl_blackstone:blackstone_chiseled_polished"},p1,p2,pr,5)
	end
})

vl_structures.register_structure_spawn({
	name = "mobs_mc:witherskeleton",
	y_min = mcl_vars.mg_lava_nether_max,
	y_max = mcl_vars.mg_nether_max,
	chance = 15,
	interval = 60,
	limit = 4,
	spawnon = { "mcl_blackstone:blackstone_chiseled_polished" },
})

vl_structures.register_structure("nether_bulwark",{
	chunk_probability = 5,
	hash_mindist_2d = 80,
	place_on = {"mcl_nether:netherrack","mcl_crimson:crimson_nylium","mcl_crimson:warped_nylium","mcl_blackstone:basalt","mcl_blackstone:soul_soil","mcl_blackstone:blackstone","mcl_nether:soul_sand"},
	flags = "place_center_x, place_center_y, all_floors",
	biomes = {"Nether","SoulsandValley","WarpedForest","CrimsonForest"},
	prepare = { tolerance=10, padding=4, corners=5, foundation=-5, clear_top=0 },
	y_min = mcl_vars.mg_lava_nether_max - 1,
	y_max = mcl_vars.mg_nether_max - 30,
	filenames = {
		modpath.."/schematics/mcl_nether_fortresses_nether_bulwark_1.mts",
		modpath.."/schematics/mcl_nether_fortresses_nether_bulwark_2.mts",
		modpath.."/schematics/mcl_nether_fortresses_nether_bulwark_3.mts",
		modpath.."/schematics/mcl_nether_fortresses_nether_bulwark_4.mts",
	},
	daughters = {{
			filenames = {
				modpath.."/schematics/mcl_nether_fortresses_nether_bulwark_interior_1.mts",
				modpath.."/schematics/mcl_nether_fortresses_nether_bulwark_interior_2.mts",
				modpath.."/schematics/mcl_nether_fortresses_nether_bulwark_interior_3.mts",
				modpath.."/schematics/mcl_nether_fortresses_nether_bulwark_interior_4.mts",
			},
			pos = vector.new(0,1,0),
			rotation = "random",
			force_placement = true,
			prepare = { tolerance = -1, foundation = false, clear = false },
		},
	},
	y_offset = 0,
	construct_nodes = {"group:wall"},
	after_place = function(pos,def,pr,p1,p2)
		vl_structures.spawn_mobs("mobs_mc:piglin",{"mcl_blackstone:blackstone_brick_polished","mcl_stairs:slab_blackstone_polished"},p1,p2,pr,5)
		vl_structures.spawn_mobs("mobs_mc:piglin_brute",{"mcl_blackstone:blackstone_brick_polished","mcl_stairs:slab_blackstone_polished"},p1,p2,pr)
		vl_structures.spawn_mobs("mobs_mc:hoglin",{"mcl_blackstone:nether_gold"},p1,p2,pr,4)
	end,
	loot = {
		["mcl_chests:chest_small" ] ={
		{
			stacks_min = 1,
			stacks_max = 2,
			items = {
				--{ itemstring = "FIXME:spectral_arrow", weight = 1, amount_min = 10, amount_max=28 },
				{ itemstring = "mcl_blackstone:blackstone_gilded", weight = 1, amount_min = 8, amount_max=12 },
				{ itemstring = "mcl_core:iron_ingot", weight = 1, amount_min = 4, amount_max=9 },
				{ itemstring = "mcl_core:gold_ingot", weight = 1, amount_min = 4, amount_max=9 },
				{ itemstring = "mcl_core:crying_obsidian", weight = 1, amount_min = 3, amount_max=8 },
				{ itemstring = "mcl_bows:crossbow", weight = 1, func = function(stack, pr)
					mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "mcl_core:goldblock", weight = 1, },
				{ itemstring = "mcl_tools:sword_gold", weight = 1, },
				{ itemstring = "mcl_tools:axe_gold", weight = 1, func = function(stack, pr)mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:helmet_gold", weight = 1, func = function(stack, pr)mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:chestplate_gold", weight = 1, func = function(stack, pr)mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:leggings_gold", weight = 1, func = function(stack, pr)mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:boots_gold", weight = 1, func = function(stack, pr)mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_nether:ancient_debris", weight = 12 }, -- same values as MCLA for now
				{ itemstring = "mcl_nether:netherite_scrap", weight = 4 }, -- until this is rebalanced
			}
		},
		{
			stacks_min = 2,
			stacks_max = 4,
			items = {
				{ itemstring = "mcl_bows:arrow", weight = 4, amount_min = 5, amount_max=17 },
				{ itemstring = "mcl_mobitems:string", weight = 4, amount_min = 1, amount_max=6 },
				{ itemstring = "mcl_core:iron_nugget", weight = 1, amount_min = 2, amount_max = 6 },
				{ itemstring = "mcl_core:gold_nugget", weight = 1, amount_min = 2, amount_max = 6 },
				{ itemstring = "mcl_mobitems:leather", weight = 1, amount_min = 1, amount_max = 3 },
			}
		},
		{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "mcl_compass:lodestone" },
				{ itemstring = "mcl_armor:rib" },
			}
		}}
	},
})

vl_structures.register_structure_spawn({
	name = "mobs_mc:piglin",
	y_min = mcl_vars.mg_nether_min,
	y_max = mcl_vars.mg_nether_max,
	chance = 10,
	interval = 60,
	limit = 9,
	spawnon = {"mcl_blackstone:blackstone_brick_polished", "mcl_stairs:slab_blackstone_polished"},
})

vl_structures.register_structure_spawn({
	name = "mobs_mc:piglin_brute",
	y_min = mcl_vars.mg_nether_min,
	y_max = mcl_vars.mg_nether_max,
	chance = 20,
	interval = 60,
	limit = 4,
	spawnon = {"mcl_blackstone:blackstone_brick_polished", "mcl_stairs:slab_blackstone_polished"},
})
