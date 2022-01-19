local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local chance_per_chunk = 15
local noise_multiplier = 1
local random_offset    = 133
local struct_threshold = chance_per_chunk - 1
local scanning_ratio   = 0.00021
local mcl_structures_get_perlin_noise_level = mcl_structures.get_perlin_noise_level

local node_list = {"mcl_core:dirt_with_grass", "mcl_core:dirt", "mcl_core:stone", "mcl_core:granite", "mcl_core:gravel", "mcl_core:diorite"}

local schematic_file = modpath .. "/schematics/mcl_structures_nice_jungle_temple.mts"

local temple_schematic_lua = minetest.serialize_schematic(schematic_file, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic"
local temple_schematic = loadstring(temple_schematic_lua)()
local size = temple_schematic.size
local sx = size.x
local sy = size.y
local sz = size.z
local offset = vector.round(vector.divide(size, 2))
offset.y = 5

local ox = offset.x
local oy = offset.y
local oz = offset.z
local corner_x = sx - 3
local corner_z = sz - 3
local air_offset_x = ox - 6
local air_offset_z = oz - 6

local function is_air(pos)
	local node = minetest.get_node(pos)
	return node.name == "air"
end

local stair_support_node = {
	{name = "mcl_core:cobble"},
	{name = "mcl_core:mossycobble"},
	{name = "mcl_core:stonebrick"},
	{name = "mcl_core:stonebrickmossy"},
	{name = "mcl_core:stonebrickcracked"},
}

local nodes_to_be_supported = {
	"mcl_stairs:stair_cobble",
	"mcl_stairs:stair_stonebrickmossy",
	"mcl_stairs:stair_stonebrickcracked",
}

local function on_placed(p1, rotation, pr, size)
	local p2
	if rotation == "90" or rotation == "270" then
		p2 = {x = p1.x + sz - 1, y = p1.y + sy - 1, z = p1.z + sx - 1}
	else
		p2 = {x = p1.x + sx - 1, y = p1.y + sy - 1, z = p1.z + sz - 1}
	end

	-- Support stairs
	local y = p1.y + 5
	local bottom = mcl_mapgen.get_chunk_beginning(y)
	local stair_list = minetest.find_nodes_in_area({x = p1.x, y = y, z = p1.z}, {x = p2.x, y = y, z = p2.z}, nodes_to_be_supported, false)
	for i = 1, #stair_list do
		local pos = stair_list[i]
		pos.y = y - 1
		while is_air(pos) and pos.y > bottom  do
			minetest.swap_node(pos, stair_support_node[pr:next(1, #stair_support_node)])
			pos.y = pos.y - 1
		end
	end

	-- Initialize some nodes
	local chest_node = "mcl_chests:trapped_chest_small"
	local lever_node = "mesecons_walllever:wall_lever_off"
	local nodes = minetest.find_nodes_in_area(p1, {x = p2.x, y = p1.y + 5, z = p2.z}, {chest_node, lever_node}, true)

	local levers = nodes[lever_node]
	for _, pos in pairs(levers) do
		mcl_structures.init_node_construct(pos)
	end

	-- Add loot into chests TODO: fix items
	local chests = nodes[chest_node]
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

end

local function place(pos, rotation, pr)
	mcl_structures.place_schematic({pos = pos, schematic = temple_schematic, pr = pr, on_placed = on_placed})
end

local mcl_mapgen_clamp_to_chunk = mcl_mapgen.clamp_to_chunk
local function process_pos(pos)
	return {
		x = mcl_mapgen_clamp_to_chunk(pos.x - ox, sx),
		y = mcl_mapgen_clamp_to_chunk(pos.y - oy, sy),
		z = mcl_mapgen_clamp_to_chunk(pos.z - oz, sz),
	}
end

local function get_place_rank(pos)
	local x1 = pos.x + 1
	local x2 = x1 + corner_x
	local z1 = pos.z + 1
	local z2 = z1 + corner_z
	local y2 = pos.y + 1
	local y1 = y2 - 2
	if is_air({x = x1, y = y1, z = z1}) then return -1 end
	if is_air({x = x2, y = y1, z = z1}) then return -1 end
	if is_air({x = x1, y = y1, z = z2}) then return -1 end
	if is_air({x = x2, y = y1, z = z2}) then return -1 end

	local p1 = {x = x1 + air_offset_x, y = y2, z = z1 + air_offset_z}
	local p2 = {x = x2 - air_offset_x, y = y2, z = z2 + air_offset_z}
	local pos_counter_air = #minetest.find_nodes_in_area(p1, p2, {"air", "group:buildable_to", "group:deco_block"}, false)
	local pos_counter_air = pos_counter_air - 2 * (#minetest.find_nodes_in_area(p1, p2, {"group:tree"}, false))

	local p1 = {x = x1 + 1, y = y1, z = z1 + 1}
	local p2 = {x = x2 - 1, y = y1, z = z2 - 1}
	local pos_counter_ground = #minetest.find_nodes_in_area(p1, p2, node_list, false)
	return pos_counter_ground + pos_counter_air
end

mcl_structures.register_structure({
	name = "nice_jungle_temple",
	decoration = {
		deco_type = "simple",
		place_on = node_list,
		flags = "all_floors",
		fill_ratio = scanning_ratio,
		y_min = -20,
		y_max = mcl_mapgen.overworld.max,
		height = 1,
		biomes =
			mcl_mapgen.v6 and {
				"Jungle"
			} or {
				"Jungle",
				"JungleEdge",
				"JungleEdgeM",
				"JungleEdgeM_ocean",
				"JungleEdge_ocean",
				"JungleM",
				"JungleM_ocean",
				"JungleM_shore",
				"Jungle_ocean",
				"Jungle_shore",
		},
	},
	on_finished_chunk = function(minp, maxp, seed, vm_context, pos_list)
		local pr = PseudoRandom(seed + random_offset)
		local random_number = pr:next(1, chance_per_chunk)
		local noise = mcl_structures_get_perlin_noise_level(minp) * noise_multiplier
		if (random_number + noise) < struct_threshold then return end
		local pos
		local count = -1
		for i = 1, #pos_list do
			local pos_i = process_pos(pos_list[i])
			local count_i = get_place_rank(pos_i)
			if count_i > count then
				count = count_i
				pos = pos_i
			end
		end
		if count < 0 then return end
		place(pos, nil, pr)
	end,
	place_function = place,
})
