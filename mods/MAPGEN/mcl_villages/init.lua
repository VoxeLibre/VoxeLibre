mcl_villages                     = {}
local chance_per_chunk           = 100
local chunk_offset_top           = 16
local chunk_offset_bottom        = 3
local max_height_difference      = 12
local minp_min                   = -64
local noise_multiplier           = 1
local random_offset              = 1
local random_multiply            = 19
local struct_threshold           = chance_per_chunk
local noise_params = {
	offset = 0,
	scale  = 2,
	spread = {
		x = mcl_mapgen.CS_NODES * chance_per_chunk,
		y = mcl_mapgen.CS_NODES * chance_per_chunk,
		z = mcl_mapgen.CS_NODES * chance_per_chunk,
	},
	seed = 842458,
	octaves = 2,
	persistence = 0.5,
}
local perlin_noise
local modname                    = minetest.get_current_modname()
local modpath                    = minetest.get_modpath(modname)
local S                          = minetest.get_translator(modname)
local basic_pseudobiome_villages = minetest.settings:get_bool("basic_pseudobiome_villages", true)
local schem_path                 = modpath .. "/schematics/"
local schematic_table = {
	{name = "large_house",	mts = schem_path.."large_house.mts",	max_num = 0.08 , rplc = basic_pseudobiome_villages },
	{name = "blacksmith",	mts = schem_path.."blacksmith.mts",	max_num = 0.055, rplc = basic_pseudobiome_villages },
	{name = "butcher",	mts = schem_path.."butcher.mts",	max_num = 0.03 , rplc = basic_pseudobiome_villages },
	{name = "church",	mts = schem_path.."church.mts",		max_num = 0.04 , rplc = basic_pseudobiome_villages },
	{name = "farm",		mts = schem_path.."farm.mts",		max_num = 0.1  , rplc = basic_pseudobiome_villages },
	{name = "lamp",		mts = schem_path.."lamp.mts",		max_num = 0.1  , rplc = false                      },
	{name = "library",	mts = schem_path.."library.mts",	max_num = 0.04 , rplc = basic_pseudobiome_villages },
	{name = "medium_house",	mts = schem_path.."medium_house.mts",	max_num = 0.08 , rplc = basic_pseudobiome_villages },
	{name = "small_house",	mts = schem_path.."small_house.mts",	max_num = 0.7  , rplc = basic_pseudobiome_villages },
	{name = "tavern",	mts = schem_path.."tavern.mts",		max_num = 0.050, rplc = basic_pseudobiome_villages },
	{name = "well",		mts = schem_path.."well.mts",		max_num = 0.045, rplc = basic_pseudobiome_villages },
}
local surface_mat = {
	["mcl_core:dirt_with_dry_grass"]  = { top = "mcl_core:dirt",    bottom = "mcl_core:stone"        },
	["mcl_core:dirt_with_grass"]      = { top = "mcl_core:dirt",    bottom = "mcl_core:stone"        },
	["mcl_core:dirt_with_grass_snow"] = { top = "mcl_core:dirt",    bottom = "mcl_core:stone"        },
	["mcl_core:podzol"]               = { top = "mcl_core:podzol",  bottom = "mcl_core:stone"        },
	["mcl_core:redsand"]              = { top = "mcl_core:redsand", bottom = "mcl_core:redsandstone" },
	["mcl_core:sand"]                 = { top = "mcl_core:sand",    bottom = "mcl_core:sandstone"    },
	["mcl_core:snow"]                 = { top = "mcl_core:dirt",    bottom = "mcl_core:stone"        },
}
local storage  = minetest.get_mod_storage()
local villages = minetest.deserialize(storage:get_string("villages") or "return {}") or {}
local minetest_get_spawn_level              = minetest.get_spawn_level
local minetest_get_node                     = minetest.get_node
local minetest_find_nodes_in_area           = minetest.find_nodes_in_area
local minetest_get_perlin                   = minetest.get_perlin
local math_pi                               = math.pi
local math_cos                              = math.cos
local math_sin                              = math.sin
local math_min                              = math.min
local math_max                              = math.max
local math_floor                            = math.floor
local math_ceil                             = math.ceil
local string_find                           = string.find
local minetest_swap_node                    = minetest.swap_node
local minetest_registered_nodes             = minetest.registered_nodes
local minetest_bulk_set_node                = minetest.bulk_set_node
local air_offset                            = chunk_offset_top - 1
local ground_offset                         = chunk_offset_bottom + 1
local surface_search_list                   = {}
for k, _ in pairs(surface_mat) do
	table.insert(surface_search_list, k)
end

local function math_round(x)
	return (x < 0) and math_ceil(x - 0.5) or math_floor(x + 0.5)
end

local function find_surface(pos, minp, maxp)
	local x, z = pos.x, pos.z
	local y_top = maxp.y
	local y_max = y_top - air_offset
	if #minetest_find_nodes_in_area({x=x, y=y_max, z=z}, {x=x, y=y_top, z=z}, "air") < chunk_offset_top then return end
	y_max = y_max - 1
	local y_bottom = minp.y
	local y_min = y_bottom + chunk_offset_bottom
	local nodes = minetest_find_nodes_in_area({x=x, y=y_min, z=z}, {x=x, y=y_max, z=z}, surface_search_list)
	for _, surface_pos in pairs(nodes) do
		local node_name_from_above = minetest_get_node({x=surface_pos.x, y=surface_pos.y+1, z=surface_pos.z}).name
		if string_find(node_name_from_above, "air"   )
		or string_find(node_name_from_above, "snow"  )
		or string_find(node_name_from_above, "fern"  )
		or string_find(node_name_from_above, "flower")
		or string_find(node_name_from_above, "bush"  )
		or string_find(node_name_from_above, "tree"  )
		or string_find(node_name_from_above, "grass" )
		then
			return surface_pos, minetest_get_node(surface_pos).name
		end
	end
end

local function get_treasures(pr)
	local loottable = {{
		stacks_min = 3,
		stacks_max = 8,
		items = {
			{ itemstring = "mcl_core:diamond"           , weight =  3, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_core:iron_ingot"        , weight = 10, amount_min = 1, amount_max = 5 },
			{ itemstring = "mcl_core:gold_ingot"        , weight =  5, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_farming:bread"          , weight = 15, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_core:apple"             , weight = 15, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_tools:pick_iron"        , weight =  5,                                },
			{ itemstring = "mcl_tools:sword_iron"       , weight =  5,                                },
			{ itemstring = "mcl_armor:chestplate_iron"  , weight =  5,                                },
			{ itemstring = "mcl_armor:helmet_iron"      , weight =  5,                                },
			{ itemstring = "mcl_armor:leggings_iron"    , weight =  5,                                },
			{ itemstring = "mcl_armor:boots_iron"       , weight =  5,                                },
			{ itemstring = "mcl_core:obsidian"          , weight =  5, amount_min = 3, amount_max = 7 },
			{ itemstring = "mcl_core:sapling"           , weight =  5, amount_min = 3, amount_max = 7 },
			{ itemstring = "mcl_mobitems:saddle"        , weight =  3,                                },
			{ itemstring = "mobs_mc:iron_horse_armor"   , weight =  1,                                },
			{ itemstring = "mobs_mc:gold_horse_armor"   , weight =  1,                                },
			{ itemstring = "mobs_mc:diamond_horse_armor", weight =  1,                                },
		}
	}}
	local items = mcl_loot.get_multi_loot(loottable, pr)
	return items
end

local function fill_chest(pos, pr)
	local meta = minetest.get_meta(pos)
	minetest.registered_nodes["mcl_chests:chest_small"].on_construct(pos)
	local inv = minetest.get_inventory( {type="node", pos=pos} )
	local items = get_treasures(pr)
	mcl_loot.fill_inventory(inv, "main", items, pr)
end

local possible_rotations = {"0", "90", "180", "270"}

local function get_random_rotation(pr)
	return possible_rotations[pr:next(1, #possible_rotations)]
end

local function create_site_plan(minp, maxp, pr)
	local plan = {}
	local building_all_info
	local center = vector.add(minp, mcl_mapgen.HALF_CS_NODES)
	local center_surface, surface_material = find_surface(center, minp, maxp)
	if not center_surface then return end

	local number_of_buildings = pr:next(10, 25)
	local shuffle = {}
	local count_buildings = {}
	for i = 1, #schematic_table do
		shuffle[i] = i
		count_buildings[i] = 0
	end
	for i = #shuffle, 2, -1 do
		local j = pr:next(1, i)
		shuffle[i], shuffle[j] = shuffle[j], shuffle[i]
	end
	local number_built = 1
	local shuffle_index = pr:next(1, #schematic_table)

	-- first building is townhall in the center
	plan[#plan + 1] = {
		pos         = center_surface,
		building    = schematic_table[shuffle_index],
		rotation    = get_random_rotation(pr),
		surface_mat = surface_material,
	}
	count_buildings[1] = count_buildings[1] + 1
	-- now some buildings around in a circle, radius = size of town center
	local x, z, r = center_surface.x, center_surface.z, schematic_table[1].hsize
	-- draw j circles around center and increase radius by random(2, 5)
	for k = 1, 20 do
		-- set position on imaginary circle
		for j = 0, 360, 15 do
			local angle = j * math_pi / 180
			local pos_surface, surface_material = find_surface(
				{
					x = math_round(x + r * math_cos(angle)),
					z = math_round(z + r * math_sin(angle))
				},
				minp,
				maxp
			)
			if pos_surface then
				shuffle_index = (shuffle_index % (#schematic_table)) + 1
				local schematic_index = shuffle[shuffle_index]
				local schematic = schematic_table[schematic_index]
				if count_buildings[schematic_index] < schematic.max_num * number_of_buildings then
					local hsize2 = schematic.hsize^2
					local is_distance_ok = true
					for _, built_house in pairs(plan) do
						local pos = built_house.pos
						local building = built_house.building
						local distance2 = (pos_surface.x - pos.x)^2 + (pos_surface.z - pos.z)^2
						if distance2 < building.hsize^2 or distance2 < hsize2 then
							is_distance_ok = false
							break
						end
					end
					if is_distance_ok then
						plan[#plan + 1] = {
							pos         = pos_surface,
							building    = schematic,
							rotation    = get_random_rotation(pr),
							surface_mat = surface_material,
						}
						count_buildings[schematic_index] = count_buildings[schematic_index] + 1
						number_built = number_built + 1
						break
					end
				end
			end
			if number_built >= number_of_buildings then
				break
			end
		end
		if number_built >= number_of_buildings then
			break
		end
		r = r + pr:next(2, 5)
	end
	return plan
end

local function ground(pos1, pos2, minp, maxp, pr, mat)
	local pos1, pos2 = pos1, pos2
	local x1, x2, z1, z2, y = pos1.x, pos2.x, pos1.z, pos2.z, pos1.y - 1
	local pos_list_dirt = {}
	local pos_list_stone = {}
	for x0 = x1, x2 do
		for z0 = z1, z2 do
			local finish = false
			local y1 = y - pr:next(2, 4)
			for y0 = y, y1, -1 do
				local p0 = {x = x0, y = y0, z = z0}
				local node = minetest_get_node(p0)
				local node_name = node.name
				if node_name ~= "air" and not string_find(node_name, "water") and not string_find(node_name, "flower") then
					finish = true
					break
				end
				pos_list_dirt[#pos_list_dirt + 1] = p0
			end
			if not finish then
				for y0 = y1 - 1, math_max(minp.y, y - pr:next(17, 27)), -1 do
					local p0 = {x = x0, y = y0, z = z0}
					local node = minetest_get_node(p0)
					local node_name = node.name
					if node_name ~= "air" and not string_find(node_name, "water") and not string_find(node_name, "flower") then
						break
					end
					pos_list_stone[#pos_list_stone + 1] = p0
				end
			end
		end
	end
	minetest_bulk_set_node(pos_list_dirt,  {name = surface_mat[mat].top})
	minetest_bulk_set_node(pos_list_stone, {name = surface_mat[mat].bottom})
end

local function terraform(plan, minp, maxp, pr)
	local fheight, fwidth, fdepth, schematic_data, pos, rotation, swap_wd, build_material
	for _, built_house in pairs(plan) do
		schematic_data = built_house.building
		pos            = built_house.pos
		rotation       = built_house.rotation
		build_material = built_house.surface_mat
		swap_wd        = rotation == "90" or rotation == "270"
		fwidth         = swap_wd and schematic_data.hdepth or schematic_data.hwidth
		fdepth         = swap_wd and schematic_data.hwidth or schematic_data.hdepth
		fheight        = schematic_data.hheight
		local pos2 = {
			x = pos.x + fwidth - 1,
			y = math_min(pos.y + fheight + 4, maxp.y),
			z = pos.z + fdepth - 1
		}
		ground(pos, {x = pos2.x, y = pos.y + 1, z = pos2.z}, minp, maxp, pr, build_material)
		local node_list = {}
		for xi = pos.x, pos2.x do
			for zi = pos.z, pos2.z do
				for yi = pos.y + 1, pos2.y do
					node_list[#node_list + 1] = {x = xi, y = yi, z = zi}
				end
			end
		end
		minetest_bulk_set_node(node_list, {name = "air"})
	end
end

local function paths(plan, minp, maxp)
	local starting_point = find_surface({x = plan[1].pos.x + 2, z = plan[1].pos.z + 2}, minp, maxp)
	if not starting_point then return end
	starting_point.y = starting_point.y + 1
	for i = 2, #plan do
		local p = plan[i]
		local end_point = p.pos
		end_point.y = end_point.y + 1
		local path = minetest.find_path(starting_point, end_point, mcl_mapgen.CS_NODES, 2, 2, "A*_noprefetch")
		if path then
			for _, pos in pairs(path) do
				pos.y = pos.y - 1
			        local surface_mat = minetest.get_node(pos).name
				if surface_mat == "mcl_core:sand" or surface_mat == "mcl_core:redsand" then
					minetest.swap_node(pos, {name = "mcl_core:sandstonesmooth2"})
				else
					minetest.swap_node(pos, {name = "mcl_core:grass_path"})
				end
			end
		end
        end
end

local function init_nodes(p1, rotation, pr, size)
	local p2 = vector.subtract(vector.add(p1, size), 1)
	local nodes = minetest.find_nodes_in_area(p1, p2, {"mcl_itemframes:item_frame", "mcl_furnaces:furnace", "mcl_anvils:anvil", "mcl_chests:chest", "mcl_villages:stonebrickcarved"})
	for _, pos in pairs(nodes) do
		local name = minetest_get_node(pos).name
		local def = minetest_registered_nodes[minetest_get_node(pos).name]
		def.on_construct(pos)
		if name == "mcl_chests:chest" then
			minetest_swap_node(pos, {name = "mcl_chests:chest_small"})
			fill_chest(pos, pr)
		end
	end
end

local function place_schematics(plan, pr)
	for _, built_house in pairs(plan) do
		local pos = built_house.pos
		local rotation = built_house.rotation
		local platform_material = built_house.surface_mat
		local replace_wall = built_house.building.rplc
		local schem_lua = built_house.building.preloaded_schematic
		if replace_wall then
			--Note, block substitution isn't matching node names exactly; so nodes that are to be substituted that have the same prefixes cause bugs.
			-- Example: Attempting to swap out 'mcl_core:stonebrick'; which has multiple, additional sub-variants: (carved, cracked, mossy). Will currently cause issues, so leaving disabled.
			if platform_material == "mcl_core:snow" or platform_material == "mcl_core:dirt_with_grass_snow" or platform_material == "mcl_core:podzol" then
				schem_lua = schem_lua:gsub("mcl_core:tree", "mcl_core:sprucetree")
				schem_lua = schem_lua:gsub("mcl_core:wood", "mcl_core:sprucewood")
			elseif platform_material == "mcl_core:sand" or platform_material == "mcl_core:redsand" then
				schem_lua = schem_lua:gsub("mcl_core:tree", "mcl_core:sandstonecarved")
				schem_lua = schem_lua:gsub("mcl_core:cobble", "mcl_core:sandstone")
				schem_lua = schem_lua:gsub("mcl_core:wood", "mcl_core:sandstonesmooth")
				schem_lua = schem_lua:gsub("mcl_core:brick_block", "mcl_core:redsandstone")
			end
		end
		schem_lua = schem_lua:gsub("mcl_core:dirt_with_grass", platform_material)
		schem_lua = schem_lua:gsub("mcl_stairs:stair_wood_outer", "mcl_stairs:slab_wood")
		schem_lua = schem_lua:gsub("mcl_stairs:stair_stone_rough_outer", "air")

		local schematic = loadstring(schem_lua)()
		-- build foundation for the building an make room above
		-- place schematic
		mcl_structures.place_schematic({
			pos = pos,
			schematic = schematic,
			rotation = rotation,
			on_placed = init_nodes,
			pr = pr,
		})
	end
end

--
-- register block for npc spawn
--
local function spawn_villager(pos)
	minetest.add_entity({x = pos.x, y = pos.y + 1, z = pos.z}, "mobs_mc:villager")
end
minetest.register_node("mcl_villages:stonebrickcarved", {
	description = S("Chiseled Stone Village Bricks"),
	_doc_items_longdesc = doc.sub.items.temp.build,
	tiles = {"mcl_core_stonebrick_carved.png"},
	stack_max = 64,
	drop = "mcl_core:stonebrickcarved",
	groups = {pickaxey=1, stone=1, stonebrick=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = false,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
	on_construct = spawn_villager,
})

minetest.register_abm({
	label = "Spawn villagers",
	nodenames = {"mcl_villages:stonebrickcarved"},
	interval = 60,
	chance = 3,
	action = function(pos, node)
		-- check the space above
		local p = table.copy(pos)
		p.y = p.y + 1
		if minetest_get_node(p).name ~= "air" then return end
		p.y = p.y + 1
		if minetest_get_node(p).name ~= "air" then return end
		p.y = p.y - 1
		local villagers_counter = 0
		for _, obj in pairs(minetest.get_objects_inside_radius(p, 40)) do
			local lua_entity = obj:get_luaentity()
			if luaentity and luaentity.name == "mobs_mc:villager" then
				villagers_counter = villagers_counter + 1
				if villagers_counter > 7 then return end
			end
		end
		spawn_villager(pos)
	end
})



--
-- on map generation, try to build a settlement
--
local function build_a_village(minp, maxp, pr, placer)
	minetest.log("action","[mcl_villages] Building village at mapchunk " .. minetest.pos_to_string(minp) .. "..." .. minetest.pos_to_string(maxp))
	local pr = pr or PseudoRandom(mcl_mapgen.get_block_seed3(minp))
	local plan = create_site_plan(minp, maxp, pr)
	if not plan then
		if placer then
			if placer:is_player() then
				minetest.chat_send_player(placer:get_player_name(), S("Map chunk @1 to @2 is not suitable for placing villages.", minetest.pos_to_string(minp), minetest.pos_to_string(maxp)))
			end
		end
		return
	end
	paths(plan, minp, maxp)
	terraform(plan, minp, maxp, pr)
	place_schematics(plan, pr)
	villages[#villages + 1] = minp
	storage:set_string("villages", minetest.serialize(villages))
end

-- Disable natural generation in singlenode.
if not mcl_mapgen.singlenode then
	local scan_last_node = mcl_mapgen.LAST_BLOCK * mcl_mapgen.BS - 1
	local scan_offset    = mcl_mapgen.BS
	mcl_mapgen.register_mapgen(function(minp, maxp, chunkseed)
		if minp.y < minp_min then return end
		local pr = PseudoRandom(chunkseed * random_multiply + random_offset)
		local random_number = pr:next(1, chance_per_chunk)
		perlin_noise = perlin_noise or minetest_get_perlin(noise_params)
		local noise = perlin_noise:get_3d(minp) * noise_multiplier
		if (random_number + noise) < struct_threshold then return end
		local min, max = 9999999, -9999999
		for i = 1, pr:next(5,10) do
			local surface_point = find_surface(
				vector.add(
					vector.new(
						pr:next(scan_offset, scan_last_node),
						0,
						pr:next(scan_offset, scan_last_node)
					),
					minp
				),
				minp,
				maxp
			)
			if not surface_point then return end
			local y = surface_point.y
			min = math_min(y, min)
			max = math_max(y, max)
		end
		local height_difference = max - min
		if height_difference > max_height_difference then return end
		build_a_village(minp, maxp, chunkkseed)
	end, mcl_mapgen.order.VILLAGES)
end

for k, v in pairs(schematic_table) do
	local schem_lua = minetest.serialize_schematic(
		v.mts,
		"lua",
		{
			lua_use_comments = false,
			lua_num_indent_spaces = 0,
		}
	):gsub("mcl_core:stonebrickcarved", "mcl_villages:stonebrickcarved") .. " return schematic"
	v.preloaded_schematic = schem_lua
	local loaded_schematic = loadstring(schem_lua)()
	local size = loaded_schematic.size
	v.hwidth = size.x
	v.hheight = size.y
	v.hdepth = size.z
	v.hsize = math.ceil(math.sqrt((size.x/2)^2 + (size.y/2)^2) * 2 + 1)
	mcl_structures.register_structure({
		name = v.name,
		place_function = function(pos, rotation, pr, placer)
			local minp = mcl_mapgen.get_chunk_beginning(pos)
			local maxp = mcl_mapgen.get_chunk_ending(pos)
			local surface_pos, surface_material = find_surface(pos, minp, maxp)
			local plan = {
				[1] = {
					pos         = pos,
					building    = schematic_table[k],
					rotation    = rotation,
					surface_mat = surface_material or "mcl_core:snow",
				}
			}
			if surface_material then
				terraform(plan, minp, maxp, pr)
			end
			place_schematics(plan, pr)
		end
	})
end

mcl_structures.register_structure({
	name = "village",
	place_function = function(pos, rotation, pr, placer)
		local minp = mcl_mapgen.get_chunk_beginning(pos)
		local maxp = mcl_mapgen.get_chunk_ending(pos)
		build_a_village(minp, maxp, pr, placer)
	end
})

function mcl_villages.get_villages()
	return villages
end
