local v6 = mcl_mapgen.v6

local mcl_mushrooms = minetest.get_modpath("mcl_mushrooms")

local c_water = minetest.get_content_id("mcl_core:water_source")
local c_stone = minetest.get_content_id("mcl_core:stone")
local c_sand = minetest.get_content_id("mcl_core:sand")

local c_soul_sand = minetest.get_content_id("mcl_nether:soul_sand")
local c_netherrack = minetest.get_content_id("mcl_nether:netherrack")
local c_nether_lava = minetest.get_content_id("mcl_nether:nether_lava_source")

-- Generate mushrooms in caves manually.
-- Minetest's API does not support decorations in caves yet. :-(
local function generate_underground_mushrooms(minp, maxp, seed)
	if not mcl_mushrooms then return end

	local pr_shroom = PseudoRandom(seed-24359)
	-- Generate rare underground mushrooms
	-- TODO: Make them appear in groups, use Perlin noise
	local min, max = mcl_mapgen.overworld.lava_max + 4, 0
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

-- Generate Nether decorations manually: Eternal fire, mushrooms
-- Minetest's API does not support decorations in caves yet. :-(
local function generate_nether_decorations(minp, maxp, seed)
	local pr_nether = PseudoRandom(seed+667)

	if minp.y > mcl_mapgen.nether.max or maxp.y < mcl_mapgen.nether.min then
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
	if mcl_mushrooms then
		special_deco(rack, function(bpos)
			local l = minetest.get_node_light(bpos, 0.5)
			if bpos.y > mcl_mapgen.nether.lava_max + 6 and l and l <= 12 and pr_nether:next(1,1000) <= 4 then
				-- TODO: Make mushrooms appear in groups, use Perlin noise
				if pr_nether:next(1,2) == 1 then
					minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_brown"})
				else
					minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_red"})
				end
			end
		end)
	end
end

mcl_mapgen.register_mapgen(function(minp, maxp, seed, vm_context)
	local min_y, max_y = minp.y, maxp.y

	-- Nether block fixes:
	-- * Replace water with Nether lava.
	-- * Replace stone, sand dirt in v6 so the Nether works in v6.
	if min_y > mcl_mapgen.nether.max or max_y < mcl_mapgen.nether.min then return end
		if v6 then
			local nodes = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:water_source", "mcl_core:stone", "mcl_core:sand", "mcl_core:dirt"})
			if #nodes < 1 then return end
			vm_context.write = true
			local data = vm_context.data
			local area = vm_context.area
			for n = 1, #nodes do
				local p_pos = area:index(nodes[n].x, nodes[n].y, nodes[n].z)
				if data[p_pos] == c_water then
					data[p_pos] = c_nether_lava
				elseif data[p_pos] == c_stone then
					data[p_pos] = c_netherrack
				elseif data[p_pos] == c_sand or data[p_pos] == c_dirt then
					data[p_pos] = c_soul_sand
				end
			end
		else
	end

	generate_underground_mushrooms(minp, maxp, seed)
	generate_nether_decorations(minp, maxp, seed)
end, 1)
