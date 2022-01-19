local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local chance_per_chunk = 11
local noise_multiplier = 1
local random_offset    = 999
local scanning_ratio   = 0.00003
local struct_threshold = chance_per_chunk - 1

local mcl_structures_get_perlin_noise_level = mcl_structures.get_perlin_noise_level

local node_list = {"mcl_core:sand", "mcl_core:sandstone", "mcl_core:redsand", "mcl_colorblocks:hardened_clay_orange"}

local schematic_file = modpath .. "/schematics/mcl_structures_desert_temple.mts"

local temple_schematic_lua = minetest.serialize_schematic(schematic_file, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic"
local temple_schematic = loadstring(temple_schematic_lua)()

local red_temple_schematic_lua = minetest.serialize_schematic(schematic_file, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic"
red_temple_schematic_lua = red_temple_schematic_lua:gsub("mcl_colorblocks:hardened_clay_orange", "mcl_colorblocks:hardened_clay_red")
red_temple_schematic_lua = red_temple_schematic_lua:gsub("mcl_core:sand_stone", "mcl_colorblocks:hardened_clay_orange")
red_temple_schematic_lua = red_temple_schematic_lua:gsub("mcl_core:sand", "mcl_core:redsand")
red_temple_schematic_lua = red_temple_schematic_lua:gsub("mcl_stairs:stair_sandstone", "mcl_stairs:stair_redsandstone")
red_temple_schematic_lua = red_temple_schematic_lua:gsub("mcl_stairs:slab_sandstone", "mcl_stairs:slab_redsandstone")
red_temple_schematic_lua = red_temple_schematic_lua:gsub("mcl_colorblocks:hardened_clay_yellow", "mcl_colorblocks:hardened_clay_pink")
local red_temple_schematic = loadstring(red_temple_schematic_lua)()

local function on_placed(p1, rotation, pr, size)
	local p2 = {x = p1.x + size.x - 1, y = p1.y + size.y - 1, z = p1.z + size.z - 1}
	-- Delete cacti leftovers:
	local cactus_nodes = minetest.find_nodes_in_area_under_air({x = p1.x, y = p1.y + 11, z = p1.z}, {x = p2.x, y = p2.y - 2, z = p2.z}, "mcl_core:cactus", false)
	for _, pos in pairs(cactus_nodes) do
		local node_below = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
		local nn = node_below.name
		if nn == "mcl_core:sandstone" then
			minetest.swap_node(pos, {name="air"})
		end
	end

	-- Find chests.
	local chests = minetest.find_nodes_in_area(p1, {x = p2.x, y = p1.y + 5, z = p2.z}, "mcl_chests:chest")

	-- Add desert temple loot into chests
	for c=1, #chests do
		local lootitems = mcl_loot.get_multi_loot({
		{
			stacks_min = 2,
			stacks_max = 4,
			items = {
				{ itemstring = "mcl_mobitems:bone", weight = 25, amount_min = 4, amount_max=6 },
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 25, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_mobitems:spider_eye", weight = 25, amount_min = 1, amount_max=3 },
				{ itemstring = "mcl_books:book", weight = 20, func = function(stack, pr)
					mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "mcl_mobitems:saddle", weight = 20, },
				{ itemstring = "mcl_core:apple_gold", weight = 20, },
				{ itemstring = "mcl_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_core:iron_ingot", weight = 15, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:emerald", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "", weight = 15, },
				{ itemstring = "mobs_mc:iron_horse_armor", weight = 15, },
				{ itemstring = "mobs_mc:gold_horse_armor", weight = 10, },
				{ itemstring = "mobs_mc:diamond_horse_armor", weight = 5, },
				{ itemstring = "mcl_core:diamond", weight = 5, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_core:apple_gold_enchanted", weight = 2, },
			}
		},
		{
			stacks_min = 4,
			stacks_max = 4,
			items = {
				{ itemstring = "mcl_mobitems:bone", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_mobitems:gunpowder", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_core:sand", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_mobitems:string", weight = 10, amount_min = 1, amount_max = 8 },
			}
		}}, pr)
		mcl_structures.init_node_construct(chests[c])
		local meta = minetest.get_meta(chests[c])
		local inv = meta:get_inventory()
		mcl_loot.fill_inventory(inv, "main", lootitems, pr)
	end

	-- Initialize pressure plates and randomly remove up to 5 plates
	local pplates = minetest.find_nodes_in_area(p1, {x = p2.x, y = p1.y + 5, z = p2.z}, "mesecons_pressureplates:pressure_plate_stone_off")
	local pplates_remove = 5
	for p=1, #pplates do
		if pplates_remove > 0 and pr:next(1, 100) >= 50 then
			-- Remove plate
			minetest.remove_node(pplates[p])
			pplates_remove = pplates_remove - 1
		else
			-- Initialize plate
			minetest.registered_nodes["mesecons_pressureplates:pressure_plate_stone_off"].on_construct(pplates[p])
		end
	end
end

local function place(pos, rotation, pr)
	local pos_below  = {x = pos.x, y = pos.y -  1, z = pos.z}
	local pos_temple = {x = pos.x - 10, y = pos.y - 12, z = pos.z - 10}
	local node_below = minetest.get_node(pos_below)
	local nn = node_below.name
	if string.find(nn, "red") then
		mcl_structures.place_schematic({pos = pos_temple, schematic = red_temple_schematic, pr = pr, on_placed = on_placed})
	else
		mcl_structures.place_schematic({pos = pos_temple, schematic = temple_schematic, pr = pr, on_placed = on_placed})
	end
end

local function get_place_rank(pos)
	local x, y, z = pos.x, pos.y - 1, pos.z
	local p1 = {x = x - 8, y = y, z = z - 8}
	local p2 = {x = x + 8, y = y, z = z + 8}
	local best_pos_list_surface = minetest.find_nodes_in_area(p1, p2, node_list, false)
	local other_pos_list_surface = minetest.find_nodes_in_area(p1, p2, "group:opaque", false)
	p1 = {x = x - 4, y = y -  7, z = z - 4}
	p2 = {x = x + 4, y = y -  3, z = z + 4}
	local best_pos_list_underground = minetest.find_nodes_in_area(p1, p2, node_list, false)
	local other_pos_list_underground = minetest.find_nodes_in_area(p1, p2, "group:opaque", false)
	return 10 * (#best_pos_list_surface) + 2 * (#other_pos_list_surface) + 5 * (#best_pos_list_underground) + #other_pos_list_underground
end

mcl_structures.register_structure({
	name = "desert_temple",
	decoration = {
		deco_type = "simple",
		place_on = node_list,
		flags = "all_floors",
		fill_ratio = scanning_ratio,
		y_min = 3,
		y_max = mcl_mapgen.overworld.max,
		height = 1,
		biomes = not mcl_mapgen.v6 and {
			"ColdTaiga_beach",
			"ColdTaiga_beach_water",
			"Desert",
			"Desert_ocean",
			"ExtremeHills_beach",
			"FlowerForest_beach",
			"Forest_beach",
			"MesaBryce_sandlevel",
			"MesaPlateauF_sandlevel",
			"MesaPlateauFM_sandlevel",
			"Savanna",
			"Savanna_beach",
			"StoneBeach",
			"StoneBeach_ocean",
			"Taiga_beach",
		},
	},
	on_finished_chunk = function(minp, maxp, seed, vm_context, pos_list)
		local pr = PseudoRandom(seed + random_offset)
		local random_number = pr:next(1, chance_per_chunk)
		local noise = mcl_structures_get_perlin_noise_level(minp) * noise_multiplier
		if (random_number + noise) < struct_threshold then return end
		local pos = pos_list[1]
		if #pos_list > 1 then
			local count = get_place_rank(pos)
			for i = 2, #pos_list do
				local pos_i = pos_list[i]
				local count_i = get_place_rank(pos_i)
				if count_i > count then
					count = count_i
					pos = pos_i
				end
			end
		end
		place(pos, nil, pr)
	end,
	place_function = place,
})
