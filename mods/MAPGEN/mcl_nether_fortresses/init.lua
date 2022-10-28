local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)
local peaceful = minetest.settings:get_bool("only_peaceful_mobs", false)


local function spawn_mobs(mob,spawnon,p1,p2,pr,n)
	if peaceful then return end
	n = n or 1
	local sp = minetest.find_nodes_in_area_under_air(p1,p2,spawnon)
	if sp and #sp > 0 then
		for i=1,n do
			local pos = vector.offset(sp[pr:next(1,#sp)],0,1,0)
			if pos then
				minetest.add_entity(pos,mob)
			end
		end
	end
end

mcl_structures.register_structure("nether_outpost",{
	place_on = {"mcl_nether:netherrack","mcl_crimson:crimson_nylium","mcl_crimson:warped_nylium","mcl_blackstone:basalt","mcl_blackstone:soul_soil","mcl_blackstone:blackstone","mcl_nether:soul_sand"},
	fill_ratio = 0.01,
	chunk_probability = 900,
	flags = "all_floors",
	biomes = {"Nether","SoulsandValley","WarpedForest","CrimsonForest","BasaltDelta"},
	sidelen = 24,
	solid_ground = true,
	make_foundation = true,
	y_min = mcl_vars.mg_lava_nether_max - 1,
	y_max = mcl_vars.mg_nether_max - 30,
	filenames = { modpath.."/schematics/mcl_nether_fortresses_nether_outpost.mts" },
	y_offset = 0,
	after_place = function(pos)
		local sp = minetest.find_nodes_in_area(pos,vector.offset(pos,0,20,0),{"mcl_mobspawners:spawner"})
		if not sp[1] then return end
		mcl_mobspawners.setup_spawner(sp[1], "mobs_mc:blaze", 0, minetest.LIGHT_MAX+1, 10, 8, 0)
	end
})

mcl_structures.register_structure("nether_bridge",{
	place_on = {"mcl_nether:nether_lava_source","mcl_nether:netherrack","mcl_crimson:crimson_nylium","mcl_crimson:warped_nylium","mcl_blackstone:basalt","mcl_blackstone:soul_soil","mcl_blackstone:blackstone","mcl_nether:soul_sand","mcl_core:bedrock"},
	fill_ratio = 0.01,
	chunk_probability = 100,
	flags = "all_floors",
	sidelen = 38,
	solid_ground = false,
	make_foundation = false,
	y_min = mcl_vars.mg_nether_min - 4,
	y_max = mcl_vars.mg_lava_nether_max - 20,
	filenames = {
		modpath.."/schematics/mcl_nether_fortresses_nether_bridge_1.mts",
		modpath.."/schematics/mcl_nether_fortresses_nether_bridge_2.mts",
		modpath.."/schematics/mcl_nether_fortresses_nether_bridge_3.mts",
		modpath.."/schematics/mcl_nether_fortresses_nether_bridge_4.mts",
	},
	y_offset = function(pr) return pr:next(15,20) end,
	after_place = function(pos,def,pr)
		local p1 = vector.offset(pos,-14,0,-14)
		local p2 = vector.offset(pos,14,24,14)
		spawn_mobs("mobs_mc:witherskeleton",{"mcl_blackstone:blackstone_chiseled_polished"},p1,p2,pr,5)
	end
})

mcl_structures.register_structure("nether_bulwark",{
	place_on = {"mcl_nether:netherrack","mcl_crimson:crimson_nylium","mcl_crimson:warped_nylium","mcl_blackstone:basalt","mcl_blackstone:soul_soil","mcl_blackstone:blackstone","mcl_nether:soul_sand"},
	fill_ratio = 0.01,
	chunk_probability = 900,
	flags = "all_floors",
	biomes = {"Nether","SoulsandValley","WarpedForest","CrimsonForest"},
	sidelen = 36,
	solid_ground = true,
	make_foundation = true,
	y_min = mcl_vars.mg_lava_nether_max - 1,
	y_max = mcl_vars.mg_nether_max - 30,
	filenames = {
		modpath.."/schematics/mcl_nether_fortresses_nether_bulwark.mts"
	},
	daughters = {{
			files = {
				modpath.."/schematics/mcl_nether_fortresses_nether_bulwark_interior_1.mts",
				modpath.."/schematics/mcl_nether_fortresses_nether_bulwark_interior_2.mts",
				modpath.."/schematics/mcl_nether_fortresses_nether_bulwark_interior_3.mts",
				modpath.."/schematics/mcl_nether_fortresses_nether_bulwark_interior_4.mts",
			},
			pos = vector.new(5,0,5),
		},
	},
	y_offset = 0,
	construct_nodes = {"group:wall"},
	after_place = function(pos,def,pr)
		local p1 = vector.offset(pos,-14,0,-14)
		local p2 = vector.offset(pos,14,24,14)
		spawn_mobs("mobs_mc:piglin",{"mcl_blackstone:blackstone_brick_polished","mcl_stairs:slab_blackstone_polished"},p1,p2,pr,5)
		spawn_mobs("mobs_mc:piglin_brute",{"mcl_blackstone:blackstone_brick_polished","mcl_stairs:slab_blackstone_polished"},p1,p2,pr)
		spawn_mobs("mobs_mc:hoglin",{"mcl_blackstone:nether_gold"},p1,p2,pr,4)
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
			}
		}}
	},
})
