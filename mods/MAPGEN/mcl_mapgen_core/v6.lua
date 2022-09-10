local WITCH_HUT_HEIGHT = 3 -- Exact Y level to spawn witch huts at. This height refers to the height of the floor

local function register_mgv6_decorations()
	-- Cacti
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:sand"},
		sidelen = 16,
		noise_params = {
			offset = -0.012,
			scale = 0.024,
			spread = {x = 100, y = 100, z = 100},
			seed = 257,
			octaves = 3,
			persist = 0.6
		},
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_core:cactus",
		height = 1,
		height_max = 3,
	})

	-- Sugar canes
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt", "mcl_core:coarse_dirt", "group:grass_block_no_snow", "group:sand", "mcl_core:podzol", "mcl_core:reeds"},
		sidelen = 16,
		noise_params = {
			offset = -0.3,
			scale = 0.7,
			spread = {x = 100, y = 100, z = 100},
			seed = 465,
			octaves = 3,
			persist = 0.7
		},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_core:reeds",
		height = 1,
		height_max = 3,
		spawn_by = { "mcl_core:water_source", "group:frosted_ice" },
		num_spawn_by = 1,
	})

	-- Doubletall grass
	minetest.register_decoration({
		deco_type = "schematic",
		schematic = {
			size = { x=1, y=3, z=1 },
			data = {
				{ name = "air", prob = 0 },
				{ name = "mcl_flowers:double_grass", param1 = 255, },
				{ name = "mcl_flowers:double_grass_top", param1 = 255, },
			},
		},
		place_on = {"group:grass_block_no_snow"},
		sidelen = 8,
		noise_params = {
			offset = -0.0025,
			scale = 0.03,
			spread = {x = 100, y = 100, z = 100},
			seed = 420,
			octaves = 3,
			persist = 0.0,
		},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
	})

	-- Large ferns
	minetest.register_decoration({
		deco_type = "schematic",
		schematic = {
			size = { x=1, y=3, z=1 },
			data = {
				{ name = "air", prob = 0 },
				{ name = "mcl_flowers:double_fern", param1=255, },
				{ name = "mcl_flowers:double_fern_top", param1=255, },
			},
		},
		-- v6 hack: This makes sure large ferns only appear in jungles
		spawn_by = { "mcl_core:jungletree", "mcl_flowers:fern" },
		num_spawn_by = 1,
		place_on = {"group:grass_block_no_snow"},

		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.01,
			spread = {x = 250, y = 250, z = 250},
			seed = 333,
			octaves = 2,
			persist = 0.66,
		},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
	})

	-- Large flowers
	local function register_large_flower(name, seed, offset)
		minetest.register_decoration({
			deco_type = "schematic",
			schematic = {
				size = { x=1, y=3, z=1 },
				data = {
					{ name = "air", prob = 0 },
					{ name = "mcl_flowers:"..name, param1=255, },
					{ name = "mcl_flowers:"..name.."_top", param1=255, },
				},
			},
			place_on = {"group:grass_block_no_snow"},

			sidelen = 16,
			noise_params = {
				offset = offset,
				scale = 0.01,
				spread = {x = 300, y = 300, z = 300},
				seed = seed,
				octaves = 5,
				persist = 0.62,
			},
			y_min = 1,
			y_max = mcl_vars.overworld_max,
			flags = "",
		})
	end

	register_large_flower("rose_bush", 9350, -0.008)
	register_large_flower("peony", 10450, -0.008)
	register_large_flower("lilac", 10600, -0.007)
	register_large_flower("sunflower", 2940, -0.005)

	-- Lily pad
	minetest.register_decoration({
		deco_type = "schematic",
		schematic = {
			size = { x=1, y=3, z=1 },
			data = {
				{ name = "mcl_core:water_source", prob = 0 },
				{ name = "mcl_core:water_source" },
				{ name = "mcl_flowers:waterlily", param1 = 255 },
			},
		},
		place_on = "mcl_core:dirt",
		sidelen = 16,
		noise_params = {
			offset = -0.12,
			scale = 0.3,
			spread = {x = 200, y = 200, z = 200},
			seed = 503,
			octaves = 6,
			persist = 0.7,
		},
		y_min = 0,
		y_max = 0,
		rotation = "random",
	})

	-- Pumpkin
	minetest.register_decoration({
		deco_type = "simple",
		decoration = "mcl_farming:pumpkin",
		param2 = 0,
		param2_max = 3,
		place_on = {"group:grass_block_no_snow"},
		sidelen = 16,
		noise_params = {
			offset = -0.008,
			scale = 0.00666,
			spread = {x = 250, y = 250, z = 250},
			seed = 666,
			octaves = 6,
			persist = 0.666
		},
		y_min = 1,
		y_max = mcl_vars.overworld_max,
	})

	-- Melon
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:grass_block_no_snow"},
		sidelen = 16,
		noise_params = {
			offset = 0.002,
			scale = 0.006,
			spread = {x = 250, y = 250, z = 250},
			seed = 333,
			octaves = 3,
			persist = 0.6
		},
		-- Small trick to make sure melon spawn in jungles
		spawn_by = { "mcl_core:jungletree", "mcl_flowers:fern" },
		num_spawn_by = 1,
		y_min = 1,
		y_max = 40,
		decoration = "mcl_farming:melon",
	})

	-- Tall grass
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:grass_block_no_snow"},
		sidelen = 8,
		noise_params = {
			offset = 0.01,
			scale = 0.3,
			spread = {x = 100, y = 100, z = 100},
			seed = 420,
			octaves = 3,
			persist = 0.6
		},
		y_min = 1,
		y_max = mcl_vars.overworld_max,
		decoration = "mcl_flowers:tallgrass",
	})
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:grass_block_no_snow"},
		sidelen = 8,
		noise_params = {
			offset = 0.04,
			scale = 0.03,
			spread = {x = 100, y = 100, z = 100},
			seed = 420,
			octaves = 3,
			persist = 0.6
		},
		y_min = 1,
		y_max = mcl_vars.overworld_max,
		decoration = "mcl_flowers:tallgrass",
	})

	-- Seagrass and kelp
	local materials = {"dirt","sand"}
	for i=1, #materials do
		local mat = materials[i]

		minetest.register_decoration({
			deco_type = "simple",
			spawn_by = {"group:water"},
			num_spawn_by = 1,
			place_on = {"mcl_core:"..mat},
			sidelen = 8,
			noise_params = {
				offset = 0.04,
				scale = 0.3,
				spread = {x = 100, y = 100, z = 100},
				seed = 421,
				octaves = 3,
				persist = 0.6
			},
			flags = "force_placement",
			place_offset_y = -1,
			y_min = mcl_vars.overworld_min,
			y_max = 0,
			decoration = "mcl_ocean:seagrass_"..mat,
		})
		minetest.register_decoration({
			deco_type = "simple",
			spawn_by = {"group:water"},
			num_spawn_by = 1,
			place_on = {"mcl_core:mat"},
			sidelen = 8,
			noise_params = {
				offset = 0.08,
				scale = 0.03,
				spread = {x = 100, y = 100, z = 100},
				seed = 421,
				octaves = 3,
				persist = 0.6
			},
			flags = "force_placement",
			place_offset_y = -1,
			y_min = mcl_vars.overworld_min,
			y_max = -5,
			decoration = "mcl_ocean:seagrass_"..mat,
		})

		minetest.register_decoration({
			deco_type = "simple",
			spawn_by = {"group:water"},
			num_spawn_by = 1,
			place_on = {"mcl_core:"..mat},
			sidelen = 16,
			noise_params = {
				offset = 0.01,
				scale = 0.01,
				spread = {x = 300, y = 300, z = 300},
				seed = 505,
				octaves = 5,
				persist = 0.62,
			},
			flags = "force_placement",
			place_offset_y = -1,
			y_min = mcl_vars.overworld_min,
			y_max = -6,
			decoration = "mcl_ocean:kelp_"..mat,
			param2 = 16,
			param2_max = 96,
		})
		minetest.register_decoration({
			deco_type = "simple",
			spawn_by = {"group:water"},
			num_spawn_by = 1,
			place_on = {"mcl_core:"..mat},
			sidelen = 16,
			noise_params = {
				offset = 0.01,
				scale = 0.01,
				spread = {x = 100, y = 100, z = 100},
				seed = 506,
				octaves = 5,
				persist = 0.62,
			},
			flags = "force_placement",
			place_offset_y = -1,
			y_min = mcl_vars.overworld_min,
			y_max = -15,
			decoration = "mcl_ocean:kelp_"..mat,
			param2 = 32,
			param2_max = 160,
		})

	end

	-- Wet Sponge
	-- TODO: Remove this when we got ocean monuments
	minetest.register_decoration({
		deco_type = "simple",
		decoration = "mcl_sponges:sponge_wet",
		spawn_by = {"group:water"},
		num_spawn_by = 1,
		place_on = {"mcl_core:dirt","mcl_core:sand"},
		sidelen = 16,
		noise_params = {
			offset = 0.00295,
			scale = 0.006,
			spread = {x = 250, y = 250, z = 250},
			seed = 999,
			octaves = 3,
			persist = 0.666
		},
		flags = "force_placement",
		y_min = mcl_vars.mg_lava_overworld_max + 5,
		y_max = -20,
	})

	-- Add a small amount of tall grass everywhere to avoid areas completely empty devoid of tall grass
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:grass_block_no_snow"},
		sidelen = 8,
		fill_ratio = 0.004,
		y_min = 1,
		y_max = mcl_vars.overworld_max,
		decoration = "mcl_flowers:tallgrass",
	})

	local mushrooms = {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown"}
	local mseeds = { 7133, 8244 }
	for m=1, #mushrooms do
		-- Mushrooms next to trees
		minetest.register_decoration({
			deco_type = "simple",
			place_on = {"group:grass_block_no_snow", "mcl_core:dirt", "mcl_core:podzol", "mcl_core:mycelium", "mcl_core:stone", "mcl_core:andesite", "mcl_core:diorite", "mcl_core:granite"},
			sidelen = 16,
			noise_params = {
				offset = 0.04,
				scale = 0.04,
				spread = {x = 100, y = 100, z = 100},
				seed = mseeds[m],
				octaves = 3,
				persist = 0.6
			},
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			decoration = mushrooms[m],
			spawn_by = { "mcl_core:tree", "mcl_core:sprucetree", "mcl_core:darktree", "mcl_core:birchtree", },
			num_spawn_by = 1,
		})
	end

	-- Dead bushes
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:sand", "mcl_core:podzol", "mcl_core:dirt", "mcl_core:coarse_dirt", "group:hardened_clay"},
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.035,
			spread = {x = 100, y = 100, z = 100},
			seed = 1972,
			octaves = 3,
			persist = 0.6
		},
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_core:deadbush",
	})

	local function register_mgv6_flower(name, seed, offset, y_max)
		if offset == nil then
			offset = 0
		end
		if y_max == nil then
			y_max = mcl_vars.mg_overworld_max
		end
		minetest.register_decoration({
			deco_type = "simple",
			place_on = {"group:grass_block_no_snow"},
			sidelen = 16,
			noise_params = {
				offset = offset,
				scale = 0.006,
				spread = {x = 100, y = 100, z = 100},
				seed = seed,
				octaves = 3,
				persist = 0.6
			},
			y_min = 1,
			y_max = y_max,
			decoration = "mcl_flowers:"..name,
		})
	end

	register_mgv6_flower("tulip_red",  436)
	register_mgv6_flower("tulip_orange", 536)
	register_mgv6_flower("tulip_pink", 636)
	register_mgv6_flower("tulip_white", 736)
	register_mgv6_flower("azure_bluet", 800)
	register_mgv6_flower("dandelion", 8)
	-- Allium is supposed to only appear in flower forest in MC. There are no flower forests in v6.
	-- We compensate by making it slightly rarer in v6.
	register_mgv6_flower("allium", 0, -0.001)
	--[[ Blue orchid is supposed to appear in swamplands. There are no swamplands in v6.
	We emulate swamplands by limiting the height to 5 levels above sea level,
	which should be close to the water. ]]
	register_mgv6_flower("blue_orchid", 64500, nil, mcl_worlds.layer_to_y(67))
	register_mgv6_flower("oxeye_daisy", 3490)
	register_mgv6_flower("poppy", 9439)

	-- Put top snow on snowy grass blocks. The v6 mapgen does not generate the top snow on its own.
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:grass_block_snow"},
		sidelen = 16,
		fill_ratio = 11.0, -- complete coverage
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_core:snow",
	})

end
register_mgv6_decorations()

local function generate_mgv6_structures()
	local chunk_has_igloo = false
	local struct_min, struct_max = -3, 111 --64
	--except end exit portall all v6
	if maxp.y >= struct_min and minp.y <= struct_max then
		-- Generate structures
		local pr = PcgRandom(blockseed)
		perlin_structures = perlin_structures or minetest.get_perlin(329, 3, 0.6, 100)
		-- Assume X and Z lengths are equal
		local divlen = 5
		for x0 = minp.x, maxp.x, divlen do for z0 = minp.z, maxp.z, divlen do
			-- Determine amount from perlin noise
			local amount = math.floor(perlin_structures:get_2d({x=x0, y=z0}) * 9)
			-- Find random positions based on this random
			local p, ground_y
			for i=0, amount do
				p = {x = pr:next(x0, x0+divlen-1), y = 0, z = pr:next(z0, z0+divlen-1)}
				-- Find ground level
				ground_y = nil
				local nn
				for y = struct_max, struct_min, -1 do
					p.y = y
					local checknode = minetest.get_node(p)
					if checknode then
						nn = checknode.name
						local def = minetest.registered_nodes[nn]
						if def and def.walkable then
							ground_y = y
							break
						end
					end
				end

				if ground_y then
					p.y = ground_y+1
					local nn0 = minetest.get_node(p).name
					-- Check if the node can be replaced
					if minetest.registered_nodes[nn0] and minetest.registered_nodes[nn0].buildable_to then
						-- Igloos
						if not chunk_has_igloo and (nn == "mcl_core:snowblock" or nn == "mcl_core:snow" or (minetest.get_item_group(nn, "grass_block_snow") == 1)) then
							if pr:next(1, 4400) == 1 then
								-- Check surface
								local floor = {x=p.x+9, y=p.y-1, z=p.z+9}
								local surface = minetest.find_nodes_in_area({x=p.x,y=p.y-1,z=p.z}, floor, "mcl_core:snowblock")
								local surface2 = minetest.find_nodes_in_area({x=p.x,y=p.y-1,z=p.z}, floor, "mcl_core:dirt_with_grass_snow")
								if #surface + #surface2 >= 63 then
									mcl_structures.call_struct(p, "igloo", nil, pr)
									chunk_has_igloo = true
								end
							end
						end

						-- Fossil
						if nn == "mcl_core:sandstone" or nn == "mcl_core:sand" and not chunk_has_desert_temple and ground_y > 3 then
							local fossil_prob = minecraft_chunk_probability(64, minp, maxp)

							if pr:next(1, fossil_prob) == 1 then
								-- Spawn fossil below desert surface between layers 40 and 49
								local p1 = {x=p.x, y=pr:next(mcl_worlds.layer_to_y(40), mcl_worlds.layer_to_y(49)), z=p.z}
								-- Very rough check of the environment (we expect to have enough stonelike nodes).
								-- Fossils may still appear partially exposed in caves, but this is O.K.
								local p2 = vector.add(p1, 4)
								local nodes = minetest.find_nodes_in_area(p1, p2, {"mcl_core:sandstone", "mcl_core:stone", "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite", "mcl_core:stone_with_coal", "mcl_core:dirt", "mcl_core:gravel"})

								if #nodes >= 100 then -- >= 80%
									mcl_structures.call_struct(p1, "fossil", nil, pr)
								end
							end
						end

						-- Witch hut (v6)
						if ground_y <= 0 and nn == "mcl_core:dirt" then
						local prob = minecraft_chunk_probability(48, minp, maxp)
						if pr:next(1, prob) == 1 then

							local swampland = minetest.get_biome_id("Swampland")
							local swampland_shore = minetest.get_biome_id("Swampland_shore")

						-- Where do witches live?
							-- v6: In Normal biome
							if biomeinfo.get_v6_biome(p) == "Normal" then
								here_be_witches = true
							end
							local here_be_witches = false
							if here_be_witches then

								local r = tostring(pr:next(0, 3) * 90) -- "0", "90", "180" or 270"
								local p1 = {x=p.x-1, y=WITCH_HUT_HEIGHT+2, z=p.z-1}
								local size
								if r == "0" or r == "180" then
									size = {x=10, y=4, z=8}
								else
									size = {x=8, y=4, z=10}
								end
								local p2 = vector.add(p1, size)

								-- This checks free space at the “body” of the hut and a bit around.
								-- ALL nodes must be free for the placement to succeed.
								local free_nodes = minetest.find_nodes_in_area(p1, p2, {"air", "mcl_core:water_source", "mcl_flowers:waterlily"})
								if #free_nodes >= ((size.x+1)*(size.y+1)*(size.z+1)) then
									local place = {x=p.x, y=WITCH_HUT_HEIGHT-1, z=p.z}

									-- FIXME: For some mysterious reason (black magic?) this
									-- function does sometimes NOT spawn the witch hut. One can only see the
									-- oak wood nodes in the water, but no hut. :-/
									mcl_structures.place_structure(place,mcl_structures.registered_structures["witch_hut"],pr)

									local function place_tree_if_free(pos, prev_result)
										local nn = minetest.get_node(pos).name
										if nn == "mcl_flowers:waterlily" or nn == "mcl_core:water_source" or nn == "mcl_core:water_flowing" or nn == "air" then
											minetest.set_node(pos, {name="mcl_core:tree", param2=0})
											return prev_result
										else
											return false
										end
									end
									local offsets
									if r == "0" then
										offsets = {
											{x=1, y=0, z=1},
											{x=1, y=0, z=5},
											{x=6, y=0, z=1},
											{x=6, y=0, z=5},
										}
									elseif r == "180" then
										offsets = {
											{x=2, y=0, z=1},
											{x=2, y=0, z=5},
											{x=7, y=0, z=1},
											{x=7, y=0, z=5},
										}
									elseif r == "270" then
										offsets = {
											{x=1, y=0, z=1},
											{x=5, y=0, z=1},
											{x=1, y=0, z=6},
											{x=5, y=0, z=6},
										}
									elseif r == "90" then
										offsets = {
											{x=1, y=0, z=2},
											{x=5, y=0, z=2},
											{x=1, y=0, z=7},
											{x=5, y=0, z=7},
										}
									end
									for o=1, #offsets do
										local ok = true
										for y=place.y-1, place.y-64, -1 do
											local tpos = vector.add(place, offsets[o])
											tpos.y = y
											ok = place_tree_if_free(tpos, ok)
											if not ok then
												break
											end
										end
									end
								end
							end
						end
						end

						-- Ice spikes in v6
						-- In other mapgens, ice spikes are generated as decorations.
						if nn == "mcl_core:snowblock" then
							local spike = pr:next(1,58000)
							if spike < 3 then
								-- Check surface
								local floor = {x=p.x+4, y=p.y-1, z=p.z+4}
								local surface = minetest.find_nodes_in_area({x=p.x+1,y=p.y-1,z=p.z+1}, floor, {"mcl_core:snowblock"})
								-- Check for collision with spruce
								local spruce_collisions = minetest.find_nodes_in_area({x=p.x+1,y=p.y+2,z=p.z+1}, {x=p.x+4, y=p.y+6, z=p.z+4}, {"mcl_core:sprucetree", "mcl_core:spruceleaves"})

								if #surface >= 9 and #spruce_collisions == 0 then
									mcl_structures.place_structure(p,mcl_structures.registered_structures["ice_spike_large"],pr)
								end
							elseif spike < 100 then
								-- Check surface
								local floor = {x=p.x+6, y=p.y-1, z=p.z+6}
								local surface = minetest.find_nodes_in_area({x=p.x+1,y=p.y-1,z=p.z+1}, floor, {"mcl_core:snowblock", "mcl_core:dirt_with_grass_snow"})

								-- Check for collision with spruce
								local spruce_collisions = minetest.find_nodes_in_area({x=p.x+1,y=p.y+1,z=p.z+1}, {x=p.x+6, y=p.y+6, z=p.z+6}, {"mcl_core:sprucetree", "mcl_core:spruceleaves"})

								if #surface >= 25 and #spruce_collisions == 0 then
									mcl_structures.place_structure(p,mcl_structures.registered_structures["ice_spike_small"],pr)
								end
							end
						end
					end
				end
			end
		end end
	end
end

-- Generate mushrooms in caves manually.
-- only v6. minetest supports cave decos via "all_floors" flag now
local function generate_underground_mushrooms(minp, maxp, seed)
	local pr_shroom = PseudoRandom(seed-24359)
	-- Generate rare underground mushrooms
	-- TODO: Make them appear in groups, use Perlin noise
	local min, max = mcl_vars.mg_lava_overworld_max + 4, 0
	if minp.y > max or maxp.y < min then
		return
	end

	local bpos
	local stone = minetest.find_nodes_in_area_under_air(minp, maxp, {"mcl_core:stone", "mcl_core:dirt", "mcl_core:mycelium", "mcl_core:podzol", "mcl_core:andesite", "mcl_core:diorite", "mcl_core:granite", "mcl_core:stone_with_coal", "mcl_core:stone_with_iron", "mcl_core:stone_with_gold"})

	for n = 1, #stone do
		bpos = {x = stone[n].x, y = stone[n].y + 1, z = stone[n].z }

		local l = minetest.get_node_light(bpos, 0.5)
		if bpos.y >= min and bpos.y <= max and l and l <= 12 and pr_shroom:next(1,1000) < 4 then
			if pr_shroom:next(1,2) == 1 then
				minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_brown"})
			else
				minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_red"})
			end
		end
	end
end

-- Generate Nether decorations manually: Eternal fire, mushrooms, nether wart
-- (only v6)
local nether_wart_chance = 85
local function generate_nether_decorations(minp, maxp, seed)
	local pr_nether = PseudoRandom(seed+667)

	if minp.y > mcl_vars.mg_nether_max or maxp.y < mcl_vars.mg_nether_min then
		return
	end

	minetest.log("action", "[mcl_mapgen_core] Nether decorations " .. minetest.pos_to_string(minp) .. " ... " .. minetest.pos_to_string(maxp))

	-- TODO: Generate everything based on Perlin noise instead of PseudoRandom

	local bpos
	local rack = minetest.find_nodes_in_area_under_air(minp, maxp, {"mcl_nether:netherrack"})
	local magma = minetest.find_nodes_in_area_under_air(minp, maxp, {"mcl_nether:magma"})
	local ssand = minetest.find_nodes_in_area_under_air(minp, maxp, {"mcl_nether:soul_sand"})

	-- Helper function to spawn “fake” decoration
	local function special_deco(nodes, spawn_func)
		for n = 1, #nodes do
			bpos = {x = nodes[n].x, y = nodes[n].y + 1, z = nodes[n].z }

			spawn_func(bpos)
		end
	end
	-- Eternal fire on netherrack
	special_deco(rack, function(bpos)
		-- Eternal fire on netherrack
		if pr_nether:next(1,100) <= 3 then
			minetest.set_node(bpos, {name = "mcl_fire:eternal_fire"})
		end
	end)

	-- Eternal fire on magma cubes
	special_deco(magma, function(bpos)
		if pr_nether:next(1,150) == 1 then
			minetest.set_node(bpos, {name = "mcl_fire:eternal_fire"})
		end
	end)

	-- Mushrooms on netherrack
	-- Note: Spawned *after* the fire because of light level checks
	special_deco(rack, function(bpos)
		local l = minetest.get_node_light(bpos, 0.5)
		if bpos.y > mcl_vars.mg_lava_nether_max + 6 and l and l <= 12 and pr_nether:next(1,1000) <= 4 then
			-- TODO: Make mushrooms appear in groups, use Perlin noise
			if pr_nether:next(1,2) == 1 then
				minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_brown"})
			else
				minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_red"})
			end
		end
	end)

	-- Nether wart on soul sand
	-- TODO: Spawn in Nether fortresses
	special_deco(ssand, function(bpos)
		if pr_nether:next(1, nether_wart_chance) == 1 then
			minetest.set_node(bpos, {name = "mcl_nether:nether_wart"})
		end
	end)
end

local function remove_mgv6_broken_plants(minp,maxp)
	--[[ Remove broken double plants caused by v6 weirdness.
	v6 might break the bottom part of double plants because of how it works.
	There are 3 possibilities:
	1) Jungle: Top part is placed on top of a jungle tree or fern (=v6 jungle grass).
		This is because the schematic might be placed even if some nodes of it
		could not be placed because the destination was already occupied.
		TODO: A better fix for this would be if schematics could abort placement
		altogether if ANY of their nodes could not be placed.
	2) Cavegen: Removes the bottom part, the upper part floats
	3) Mudflow: Same as 2) ]]

	local plants = minetest.find_nodes_in_area(minp, maxp, "group:double_plant")
	for n = 1, #plants do
		local node = vm:get_node_at(plants[n])
		local is_top = minetest.get_item_group(node.name, "double_plant") == 2
		if is_top then
			local p_pos = area:index(plants[n].x, plants[n].y-1, plants[n].z)
			if p_pos then
				node = vm:get_node_at({x=plants[n].x, y=plants[n].y-1, z=plants[n].z})
				local is_bottom = minetest.get_item_group(node.name, "double_plant") == 1
				if not is_bottom then
					p_pos = area:index(plants[n].x, plants[n].y, plants[n].z)
					data[p_pos] = c_air
					lvm_used = true
				end
			end
		end
	end
end

local function basic(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	if not (minp.y <= mcl_vars.mg_nether_max and maxp.y >= mcl_vars.mg_nether_min) then
		return
	end
		-- Nether block fixes:
	-- * Replace water with Nether lava.
	-- * Replace stone, sand dirt in v6 so the Nether works in v6.
	local nodes = minetest.find_nodes_in_area(emin, emax, {"group:water"})
	for _, n in pairs(nodes) do
		data[area:index(n.x, n.y, n.z)] = c_nether_lava
		lvm_used = true
	end
	nodes = minetest.find_nodes_in_area(emin, emax, {"mcl_core:water_source", "mcl_core:stone", "mcl_core:sand", "mcl_core:dirt"})
	for n=1, #nodes do
		local p_pos = area:index(nodes[n].x, nodes[n].y, nodes[n].z)
		if data[p_pos] == c_water then
			data[p_pos] = c_nether_lava
			lvm_used = true
		elseif data[p_pos] == c_stone then
			data[p_pos] = c_netherrack
			lvm_used = true
		elseif data[p_pos] == c_sand or data[p_pos] == c_dirt then
			data[p_pos] = c_soul_sand
			lvm_used = true
		end
	end
end

local function end_fixes(minp,maxp)
	if not ( minp.y <= mcl_vars.mg_end_max and maxp.y >= mcl_vars.mg_end_min ) then
		return
	end
	local nodes = minetest.find_nodes_in_area(emin, emax, {"mcl_core:water_source", "mcl_core:stone", "mcl_core:sand", "mcl_core:dirt"})
	if #nodes > 0 then
		lvm_used = true
		for _,n in pairs(nodes) do
			data[area:index(n.x, n.y, n.z)] = c_air
		end
	end
end

local function basic_node(minp, maxp, blockseed)
	if mg_name ~= "singlenode" then
		-- Generate special decorations
		if mg_name == "v6" then
			generate_underground_mushrooms(minp, maxp, blockseed)
			generate_nether_decorations(minp, maxp, blockseed)
			end_fixes(minp,maxp)
			remove_mgv6_broken_plants(minp,maxp,blockseed)
			generate_mgv6_structures(minp, maxp, blockseed, minetest.get_mapgen_object("biomemap"))
		end
	end
end

mcl_mapgen_core.register_generator("mgv6-fixes", basic, basic_node, 10, true)
