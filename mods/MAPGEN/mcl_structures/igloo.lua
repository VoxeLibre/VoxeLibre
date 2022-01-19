local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

-- local chance_per_chunk = mcl_structures.from_16x16_to_chunk_inverted_chance(4400)
local chance_per_chunk = 100
local noise_multiplier = 1.4
local random_offset    = 555
local struct_threshold = chance_per_chunk - 1
local scanning_ratio   = 0.0003

local mcl_structures_get_perlin_noise_level = mcl_structures.get_perlin_noise_level

local node_list = {"mcl_core:snowblock", "mcl_core:snow", "group:grass_block_snow"}

local schematic_top      = modpath.."/schematics/mcl_structures_igloo_top.mts"
local schematic_basement = modpath.."/schematics/mcl_structures_igloo_basement.mts"

local brick = {
	-- monster egg:
	[false] = {
		-- cracked:
		[false] = "mcl_core:stonebrick",
		[true ] = "mcl_core:stonebrickcracked",
	},
	[true] = {
		[false] = "mcl_monster_eggs:monster_egg_stonebrick",
		[true ] = "mcl_monster_eggs:monster_egg_stonebrickcracked",
	},
}
local dirs = {
	["0"]   = {x=-1, y=0, z= 0},
	["90"]  = {x= 0, y=0, z=-1},
	["180"] = {x= 1, y=0, z= 0},
	["270"] = {x= 0, y=0, z= 1},
}
local tdirs = {
	["0"]   = {x= 1, y=0, z= 0},
	["90"]  = {x= 0, y=0, z=-1},
	["180"] = {x=-1, y=0, z= 0},
	["270"] = {x= 0, y=0, z= 1}
}
local tposes = {
	["0"]   = {x=7, y=-1, z=3},
	["90"]  = {x=3, y=-1, z=1},
	["180"] = {x=1, y=-1, z=3},
	["270"] = {x=3, y=-1, z=7},
}
local chest_offsets = {
	["0"]   = {x=5, y=1, z=5},
	["90"]  = {x=5, y=1, z=3},
	["180"] = {x=3, y=1, z=1},
	["270"] = {x=1, y=1, z=5},
}

local function on_placed(pos, rotation, pr, size)
	local chest_offset = chest_offsets[rotation]
	if not chest_offset then return end
	local lootitems = mcl_loot.get_multi_loot({
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "mcl_core:apple_gold", weight = 1 },
		}
	},
	{
		stacks_min = 2,
		stacks_max = 8,
		items = {
			{ itemstring = "mcl_core:coal_lump", weight = 15, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcl_core:apple", weight = 15, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_farming:wheat_item", weight = 10, amount_min = 2, amount_max = 3 },
			{ itemstring = "mcl_core:gold_nugget", weight = 10, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_mobitems:rotten_flesh", weight = 10 },
			{ itemstring = "mcl_tools:axe_stone", weight = 2 },
			{ itemstring = "mcl_core:emerald", weight = 1 },
		}
	}}, pr)

	local chest_pos = vector.add(pos, chest_offset)
	mcl_structures.init_node_construct(chest_pos)
	local meta = minetest.get_meta(chest_pos)
	local inv = meta:get_inventory()
	mcl_loot.fill_inventory(inv, "main", lootitems, pr)
end

local function on_placed_top(p1, rotation, pr, size)
	local y = p1.y + 1
	local pos = {x = p1.x, y = y, z = p1.z}
	local dim = mcl_mapgen[mcl_worlds.pos_to_dimension(pos)]
	local bottom_of_dimension = (dim and dim.min or mcl_mapgen.EDGE_MIN) + 10
	local bottom_of_chunk = mcl_mapgen.get_chunk_beginning(y)
	local buffer = y - math.max(bottom_of_chunk, bottom_of_dimension)
	if buffer < 20 then return end

	local depth = pr:next(19, buffer)
	local bpos = {x=pos.x, y=pos.y-depth, z=pos.z}
	local dir = dirs[rotation]
	if not dir then return end
	local tdir = tdirs[rotation]

	-- Trapdoor position
	local tpos = vector.add(pos, tposes[rotation])
	local ladder_param2 = minetest.dir_to_wallmounted(tdir)

	-- Check how deep we can actuall dig
	local real_depth = 0
	for y = 1, depth - 5 do
		local node = minetest.get_node({x=tpos.x,y=tpos.y-y,z=tpos.z})
		local def = minetest.registered_nodes[node.name]
		if (not def) or (not def.walkable) or (def.liquidtype ~= "none") then
			bpos.y = tpos.y-y+1
			break
		end
		real_depth = real_depth + 1
	end
	if real_depth < 6 then return end

	-- Generate ladder to basement
	for y=1, real_depth-1 do
		minetest.set_node({x=tpos.x-1,y=tpos.y-y,z=tpos.z  }, {name = brick[pr:next(1, 10) == 1][pr:next(1, 3) == 1]})
		minetest.set_node({x=tpos.x+1,y=tpos.y-y,z=tpos.z  }, {name = brick[pr:next(1, 10) == 1][pr:next(1, 3) == 1]})
		minetest.set_node({x=tpos.x  ,y=tpos.y-y,z=tpos.z-1}, {name = brick[pr:next(1, 10) == 1][pr:next(1, 3) == 1]})
		minetest.set_node({x=tpos.x  ,y=tpos.y-y,z=tpos.z+1}, {name = brick[pr:next(1, 10) == 1][pr:next(1, 3) == 1]})
		minetest.set_node({x=tpos.x  ,y=tpos.y-y,z=tpos.z  }, {name="mcl_core:ladder", param2=ladder_param2})
	end

	-- Place basement
	local def = {
		pos = bpos,
		schematic = schematic_basement,
		rotation = rotation,
		pr = pr,
		on_placed = on_placed,
	}
	mcl_structures.place_schematic(def)

	minetest.after(5, function(tpos, dir)
		minetest.swap_node(tpos, {name="mcl_doors:trapdoor", param2=20+minetest.dir_to_facedir(dir)}) -- TODO: more reliable param2
	end, tpos, dir)
end

local function place(pos, rotation, pr)
	local def = {
		pos = {x = pos.x, y = pos.y - 1, z = pos.z},
		schematic = schematic_top,
		rotation = rotation or tostring(pr:next(0,3)*90),
		pr = pr,
		on_placed = on_placed_top,
	}
	-- FIXME: This spawns bookshelf instead of furnace. Fix this!
	-- Furnace does not work atm because apparently meta is not set. :-(
	mcl_structures.place_schematic(def)
end

local function get_place_rank(pos)
	local x, y, z = pos.x, pos.y, pos.z
	local p1 = {x = x    , y = y, z = z    }
	local p2 = {x = x + 9, y = y, z = z + 9}
	local best_pos_list_surface = #minetest.find_nodes_in_area(p1, p2, node_list, false)
	local other_pos_list_surface = #minetest.find_nodes_in_area(p1, p2, "group:opaque", false)
	return 10 * (best_pos_list_surface) + other_pos_list_surface - 640
end

mcl_structures.register_structure({
	name = "igloo",
	decoration = {
		deco_type = "simple",
		place_on = node_list,
		flags = "all_floors",
		fill_ratio = scanning_ratio,
		y_min = -33,
		y_max = mcl_mapgen.overworld.max,
		height = 1,
	},
	on_finished_chunk = function(minp, maxp, seed, vm_context, pos_list)
		local pr = PseudoRandom(seed + random_offset)
		local random_number = pr:next(1, chance_per_chunk)
		local noise = mcl_structures_get_perlin_noise_level(minp) * noise_multiplier
		if (random_number + noise) < struct_threshold then return end
		local pos
		local count = -1
		for i = 1, #pos_list do
			local pos_i = vector.subtract(pos_list[i], {x = 4, y = 1, z = 4})
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
