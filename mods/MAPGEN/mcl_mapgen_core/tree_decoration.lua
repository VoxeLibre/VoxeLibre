-- Generate tree decorations in the bounding box. This adds:
-- * Cocoa at jungle trees
-- * Jungle tree vines
-- * Oak vines in swamplands

local minetest_find_nodes_in_area = minetest.find_nodes_in_area
local minetest_find_node_near = minetest.find_node_near
local minetest_get_node_light = minetest.get_node_light
local minetest_dir_to_facedir = minetest.dir_to_facedir
local minetest_dir_to_wallmounted = minetest.dir_to_wallmounted
local table_copy = table.copy
local vector_subtract = vector.subtract
local vector_add = vector.add
local math_max = math.max
local math_ceil = math.ceil
local math_abs = math.abs

local c_air = minetest.CONTENT_AIR
local c_cocoas
local c_jungleleaves = minetest.get_content_id("mcl_core:jungleleaves")
local c_leaves       = minetest.get_content_id("mcl_core:leaves")
local c_vine         = minetest.get_content_id("mcl_core:vine")

if minetest.get_modpath("mcl_cocoas") then
	c_cocoas = {
		minetest.get_content_id("mcl_cocoas:cocoa_1"),
		minetest.get_content_id("mcl_cocoas:cocoa_2"),
		minetest.get_content_id("mcl_cocoas:cocoa_3"),
	}
end

local swampland
local swampland_shore
local jungle
local jungle_shore
local jungle_m
local jungle_m_shore
local jungle_edge
local jungle_edge_shore
local jungle_edge_m
local jungle_edge_m_shore

local perlin_vines, perlin_vines_fine, perlin_vines_upwards, perlin_vines_length, perlin_vines_density

local dirs = {
	{x =  1, y = 0, z =  0},
	{x = -1, y = 0, z =  0},
	{x =  0, y = 0, z =  1},
	{x =  0, y = 0, z = -1},
}

local function generate_tree_decorations(vm_context)
	local maxp = vm_context.maxp
	if maxp.y < 0 then return end
	local minp = vm_context.minp

	local data = vm_context.data
	vm_context.param2_data = vm_context.param2_data or vm_context.vm:get_param2_data(vm_context.lvm_param2_buffer)
	local param2_data = vm_context.param2_data
	local area = vm_context.area

	local biomemap = vm_context.biomemap

	local pr = PseudoRandom(vm_context.chunkseed)

	local oaktree, oakleaves, jungletree, jungleleaves = {}, {}, {}, {}

	-- Modifier for Jungle M biome: More vines and cocoas
	local dense_vegetation = false

	if biomemap then
		swampland           = swampland or minetest.get_biome_id("Swampland")
		swampland_shore     = swampland_shore or minetest.get_biome_id("Swampland_shore")
		jungle              = jungle or minetest.get_biome_id("Jungle")
		jungle_shore        = jungle_shore or minetest.get_biome_id("Jungle_shore")
		jungle_m            = jungle_m or minetest.get_biome_id("JungleM")
		jungle_m_shore      = jungle_m_shore or minetest.get_biome_id("JungleM_shore")
		jungle_edge         = jungle_edge or minetest.get_biome_id("JungleEdge")
		jungle_edge_shore   = jungle_edge_shore or minetest.get_biome_id("JungleEdge_shore")
		jungle_edge_m       = jungle_edge_m or minetest.get_biome_id("JungleEdgeM")
		jungle_edge_m_shore = jungle_edge_m_shore or minetest.get_biome_id("JungleEdgeM_shore")

		-- Biome map available: Check if the required biome (jungle or swampland)
		-- is in this mapchunk. We are only interested in trees in the correct biome.
		-- The nodes are added if the correct biome is *anywhere* in the mapchunk.
		-- TODO: Strictly generate vines in the correct biomes only.
		local swamp_biome_found, jungle_biome_found = false, false
		for b=1, #biomemap do
			local id = biomemap[b]

			if not swamp_biome_found and (id == swampland or id == swampland_shore) then
				oaktree = minetest_find_nodes_in_area(minp, maxp, {"mcl_core:tree"})
				oakleaves = minetest_find_nodes_in_area(minp, maxp, {"mcl_core:leaves"})
				swamp_biome_found = true
			end
			if not jungle_biome_found and (id == jungle or id == jungle_shore or id == jungle_m or id == jungle_m_shore or id == jungle_edge or id == jungle_edge_shore or id == jungle_edge_m or id == jungle_edge_m_shore) then
				jungletree = minetest_find_nodes_in_area(minp, maxp, {"mcl_core:jungletree"})
				jungleleaves = minetest_find_nodes_in_area(minp, maxp, {"mcl_core:jungleleaves"})
				jungle_biome_found = true
			end
			if not dense_vegetation and (id == jungle_m or id == jungle_m_shore) then
				dense_vegetation = true
			end
			if swamp_biome_found and jungle_biome_found and dense_vegetation then
				break
			end
		end
	else
		-- If there is no biome map, we just count all jungle things we can find.
		-- Oak vines will not be generated.
		jungletree = minetest_find_nodes_in_area(minp, maxp, {"mcl_core:jungletree"})
		jungleleaves = minetest_find_nodes_in_area(minp, maxp, {"mcl_core:jungleleaves"})
	end

	local pos, treepos, dir

	if c_cocoas then
		local cocoachance = 40
		if dense_vegetation then
			cocoachance = 32
		end

		-- Pass 1: Generate cocoas at jungle trees
		for n = 1, #jungletree do

			pos = table_copy(jungletree[n])
			treepos = table_copy(pos)

			if minetest_find_node_near(pos, 1, {"mcl_core:jungleleaves"}) then

				dir = pr:next(1, cocoachance)

				if dir == 1 then
					pos.z = pos.z + 1
				elseif dir == 2 then
					pos.z = pos.z - 1
				elseif dir == 3 then
					pos.x = pos.x + 1
				elseif dir == 4 then
					pos.x = pos.x -1
				end

				local p_pos = area:index(pos.x, pos.y, pos.z)
				local l = minetest_get_node_light(pos)

				if dir < 5
				and data[p_pos] == c_air
				and l and l > 12 then
					local c = pr:next(1, 3)
					data[p_pos] = c_cocoas[c]
					vm_context.write = true
					param2_data[p_pos] = minetest_dir_to_facedir(vector_subtract(treepos, pos))
					vm_context.write_param2 = true
				end
			end
		end
	end

	-- Pass 2: Generate vines at jungle wood, jungle leaves in jungle and oak wood, oak leaves in swampland
	perlin_vines = perlin_vines or minetest.get_perlin(555, 4, 0.6, 500)
	perlin_vines_fine = perlin_vines_fine or minetest.get_perlin(43000, 3, 0.6, 1)
	perlin_vines_length = perlin_vines_length or minetest.get_perlin(435, 4, 0.6, 75)
	perlin_vines_upwards = perlin_vines_upwards or minetest.get_perlin(436, 3, 0.6, 10)
	perlin_vines_density = perlin_vines_density or minetest.get_perlin(436, 3, 0.6, 500)

	-- Extra long vines in Jungle M
	local maxvinelength = 7
	if dense_vegetation then
		maxvinelength = 14
	end
	local treething
	for i=1, 4 do
		if i==1 then
			treething = jungletree
		elseif i == 2 then
			treething = jungleleaves
		elseif i == 3 then
			treething = oaktree
		elseif i == 4 then
			treething = oakleaves
		end

		for n = 1, #treething do
			pos = treething[n]

			treepos = table_copy(pos)

			for d = 1, #dirs do
				local pos = vector_add(pos, dirs[d])
				local p_pos = area:index(pos.x, pos.y, pos.z)

				local vine_threshold = math_max(0.33333, perlin_vines_density:get_2d(pos))
				if dense_vegetation then
					vine_threshold = vine_threshold * (2/3)
				end

				if perlin_vines:get_2d(pos) > -1.0 and perlin_vines_fine:get_3d(pos) > vine_threshold and data[p_pos] == c_air then

					local rdir = {}
					rdir.x = -dirs[d].x
					rdir.y = dirs[d].y
					rdir.z = -dirs[d].z
					local param2 = minetest_dir_to_wallmounted(rdir)

					-- Determine growth direction
					local grow_upwards = false
					-- Only possible on the wood, not on the leaves
					if i == 1 then
						grow_upwards = perlin_vines_upwards:get_3d(pos) > 0.8
					end
					if grow_upwards then
						-- Grow vines up 1-4 nodes, even through jungleleaves.
						-- This may give climbing access all the way to the top of the tree :-)
						-- But this will be fairly rare.
						local length = math_ceil(math_abs(perlin_vines_length:get_3d(pos)) * 4)
						for l=0, length-1 do
							local t_pos = area:index(treepos.x, treepos.y, treepos.z)

							if (data[p_pos] == c_air or data[p_pos] == c_jungleleaves or data[p_pos] == c_leaves) and mcl_core.supports_vines(minetest.get_name_from_content_id(data[t_pos])) then
								data[p_pos] = c_vine
								param2_data[p_pos] = param2
								vm_context.write = true
							else
								break
							end
							pos.y = pos.y + 1
							p_pos = area:index(pos.x, pos.y, pos.z)
							treepos.y = treepos.y + 1
						end
					else
						-- Grow vines down, length between 1 and maxvinelength
						local length = math_ceil(math_abs(perlin_vines_length:get_3d(pos)) * maxvinelength)
						for l=0, length-1 do
							if data[p_pos] == c_air then
								data[p_pos] = c_vine
								param2_data[p_pos] = param2
								vm_context.write = true
							else
								break
							end
							pos.y = pos.y - 1
							p_pos = area:index(pos.x, pos.y, pos.z)
						end
					end
				end
			end
		end
	end
end

mcl_mapgen.register_on_generated(generate_tree_decorations, 0)
