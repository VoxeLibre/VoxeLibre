local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local chance_per_chunk = 60
local noise_multiplier = 1
local random_offset    = 999
local scanning_ratio   = 0.00001
local struct_threshold = chance_per_chunk - 1

local mcl_structures_get_perlin_noise_level = mcl_structures.get_perlin_noise_level

local node_list = {"mcl_core:sand", "mcl_core:sandstone", "mcl_core:redsand", "mcl_colorblocks:hardened_clay_orange"}

local schematic_file = modpath .. "/schematics/mcl_structures_desert_well.mts"

local well_schematic_lua = minetest.serialize_schematic(schematic_file, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic"
local well_schematic = loadstring(well_schematic_lua)()

local red_well_schematic_lua = minetest.serialize_schematic(schematic_file, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic"
red_well_schematic_lua = red_well_schematic_lua:gsub("mcl_core:sand", "mcl_core:redsand")
red_well_schematic_lua = red_well_schematic_lua:gsub("mcl_stairs:slab_sandstone", "mcl_stairs:slab_redsandstone")
local red_well_schematic = loadstring(red_well_schematic_lua)()

local function place(pos, rotation, pr)
	local pos_below  = {x = pos.x, y = pos.y - 1, z = pos.z}
	local pos_well   = {x = pos.x, y = pos.y - 2, z = pos.z}
	local node_below = minetest.get_node(pos_below)
	local nn = node_below.name
	if string.find(nn, "red") then
		mcl_structures.place_schematic({pos = pos_well, rotaton = rotation, schematic = red_well_schematic, pr = pr})
	else
		mcl_structures.place_schematic({pos = pos_well, rotaton = rotation, schematic = well_schematic, pr = pr})
	end
end

local function get_place_rank(pos)
	local x, y, z = pos.x, pos.y - 1, pos.z
	local p1 = {x = x    , y = y, z = z    }
	local p2 = {x = x + 5, y = y, z = z + 5}
	local post_pos_list_surface = #minetest.find_nodes_in_area(p1, p2, node_list, false)
	local other_pos_list_surface = #minetest.find_nodes_in_area(p1, p2, "group:opaque", false)
	return post_pos_list_surface * 5 + other_pos_list_surface
end

mcl_structures.register_structure({
	name = "desert_well",
	decoration = {
		deco_type = "simple",
		place_on = node_list,
		flags = "all_floors",
		fill_ratio = scanning_ratio,
		y_min = -5,
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
