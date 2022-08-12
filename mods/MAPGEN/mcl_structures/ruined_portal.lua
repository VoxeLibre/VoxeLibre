local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local function get_replacements(b,c,pr)
	local r = {}
	if not b then return r end
	for k,v in pairs(b) do
		if pr:next(1,100) < c then table.insert(r,v) end
	end
	return r
end

local def = {
	place_on = {"group:grass_block","group:dirt","mcl_core:dirt_with_grass","group:grass_block","group:sand","group:grass_block_snow","mcl_core:snow"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z, all_floors",
	solid_ground = true,
	make_foundation = true,
	chunk_probability = 800,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	sidelen = 10,
	y_offset = -5,
	filenames = {
		modpath.."/schematics/mcl_structures_ruined_portal_1.mts",
		modpath.."/schematics/mcl_structures_ruined_portal_2.mts",
		modpath.."/schematics/mcl_structures_ruined_portal_3.mts",
		modpath.."/schematics/mcl_structures_ruined_portal_4.mts",
		modpath.."/schematics/mcl_structures_ruined_portal_5.mts",
		modpath.."/schematics/mcl_structures_ruined_portal_99.mts",
	},
	after_place = function(pos,def,pr)
		local hl = def.sidelen / 2
		local p1 = vector.offset(pos,-hl,-hl,-hl)
		local p2 = vector.offset(pos,hl,hl,hl)
		local gold = minetest.find_nodes_in_area(p1,p2,{"mcl_core:goldblock"})
		local lava = minetest.find_nodes_in_area(p1,p2,{"mcl_core:lava_source"})
		local rack = minetest.find_nodes_in_area(p1,p2,{"mcl_nether:netherrack"})
		local brick = minetest.find_nodes_in_area(p1,p2,{"mcl_core:stonebrick"})
		local obby = minetest.find_nodes_in_area(p1,p2,{"mcl_core:obsidian"})
		minetest.bulk_set_node(get_replacements(gold,30,pr),{name="air"})
		minetest.bulk_set_node(get_replacements(lava,20,pr),{name="mcl_nether:magma"})
		minetest.bulk_set_node(get_replacements(rack,7,pr),{name="mcl_nether:magma"})
		minetest.bulk_set_node(get_replacements(obby,30,pr),{name="mcl_core:crying_obsidian"})
		minetest.bulk_set_node(get_replacements(obby,10,pr),{name="air"})
		minetest.bulk_set_node(get_replacements(brick,50,pr),{name="mcl_core:stonebrickcracked"})
		brick = minetest.find_nodes_in_area(p1,p2,{"mcl_core:stonebrick"})
		minetest.bulk_set_node(get_replacements(brick,50,pr),{name="mcl_core:stonebrickmossy"})
	end,
	loot = {
		["mcl_chests:chest_small" ] ={{
			stacks_min = 2,
			stacks_max = 6,
			items = {
				{ itemstring = "mcl_core:iron_nugget", weight = 40, amount_min = 9, amount_max = 18 },
				{ itemstring = "mcl_core:flint", weight = 40, amount_min = 1, amount_max=4 },
				{ itemstring = "mcl_core:obsidian", weight = 40, amount_min = 1, amount_max=2 },
				{ itemstring = "mcl_fire:fire_charge", weight = 40, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_fire:flint_and_steel", weight = 40, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_core:gold_nugget", weight = 15, amount_min = 4, amount_max = 24 },
				{ itemstring = "mcl_core:apple_gold", weight = 15, },

				{ itemstring = "mcl_books:book", weight = 1, func = function(stack, pr)
					mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				--{ itemstring = "mcl_bamboo:bamboo", weight = 15, amount_min = 1, amount_max=3 }, --FIXME BAMBOO

				{ itemstring = "mcl_core:diamond", weight = 3, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_mobitems:saddle", weight = 3, },
				{ itemstring = "mcl_core:emerald", weight = 2, amount_min = 1, amount_max = 3 },

				{ itemstring = "mcl_mobitems:iron_horse_armor", weight = 1, },
				{ itemstring = "mcl_mobitems:gold_horse_armor", weight = 1, },
				{ itemstring = "mcl_mobitems:diamond_horse_armor", weight = 1, },
				{ itemstring = "mcl_core:apple_gold", weight = 15, },
			}
		}}
	}
}
mcl_structures.register_structure("ruined_portal_overworld",def)
local ndef = table.copy(def)
ndef.y_min=mcl_vars.mg_lava_nether_max +10
ndef.y_max=mcl_vars.mg_nether_max - 15
ndef.place_on = {"mcl_nether:netherrack","group:soul_block","mcl_blackstone:basalt,mcl_blackstone:blackstone","mcl_crimson:crimson_nylium","mcl_crimson:warped_nylium"},
mcl_structures.register_structure("ruined_portal_nether",ndef)
