mcl_mapgen_core = {}
local registered_generators = {}

local lvm, nodes, param2 = 0, 0, 0
local lvm_buffer = {}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

--
-- Aliases for map generator outputs
--

minetest.register_alias("mapgen_air", "air")
minetest.register_alias("mapgen_stone", "mcl_core:stone")
minetest.register_alias("mapgen_tree", "mcl_core:tree")
minetest.register_alias("mapgen_leaves", "mcl_core:leaves")
minetest.register_alias("mapgen_jungletree", "mcl_core:jungletree")
minetest.register_alias("mapgen_jungleleaves", "mcl_core:jungleleaves")
minetest.register_alias("mapgen_pine_tree", "mcl_core:sprucetree")
minetest.register_alias("mapgen_pine_needles", "mcl_core:spruceleaves")

minetest.register_alias("mapgen_apple", "mcl_core:leaves")
minetest.register_alias("mapgen_water_source", "mcl_core:water_source")
minetest.register_alias("mapgen_dirt", "mcl_core:dirt")
minetest.register_alias("mapgen_dirt_with_grass", "mcl_core:dirt_with_grass")
minetest.register_alias("mapgen_dirt_with_snow", "mcl_core:dirt_with_grass_snow")
minetest.register_alias("mapgen_sand", "mcl_core:sand")
minetest.register_alias("mapgen_gravel", "mcl_core:gravel")
minetest.register_alias("mapgen_clay", "mcl_core:clay")
minetest.register_alias("mapgen_lava_source", "air") -- Built-in lava generator is too unpredictable, we generate lava on our own
minetest.register_alias("mapgen_cobble", "mcl_core:cobble")
minetest.register_alias("mapgen_mossycobble", "mcl_core:mossycobble")
minetest.register_alias("mapgen_junglegrass", "mcl_flowers:fern")
minetest.register_alias("mapgen_stone_with_coal", "mcl_core:stone_with_coal")
minetest.register_alias("mapgen_stone_with_iron", "mcl_core:stone_with_iron")
minetest.register_alias("mapgen_desert_sand", "mcl_core:sand")
minetest.register_alias("mapgen_desert_stone", "mcl_core:sandstone")
minetest.register_alias("mapgen_sandstone", "mcl_core:sandstone")
if minetest.get_modpath("mclx_core") then
	minetest.register_alias("mapgen_river_water_source", "mclx_core:river_water_source")
else
	minetest.register_alias("mapgen_river_water_source", "mcl_core:water_source")
end
minetest.register_alias("mapgen_snow", "mcl_core:snow")
minetest.register_alias("mapgen_snowblock", "mcl_core:snowblock")
minetest.register_alias("mapgen_ice", "mcl_core:ice")

minetest.register_alias("mapgen_stair_cobble", "mcl_stairs:stair_cobble")
minetest.register_alias("mapgen_sandstonebrick", "mcl_core:sandstonesmooth")
minetest.register_alias("mapgen_stair_sandstonebrick", "mcl_stairs:stair_sandstone")
minetest.register_alias("mapgen_stair_sandstone_block", "mcl_stairs:stair_sandstone")
minetest.register_alias("mapgen_stair_desert_stone", "mcl_stairs:stair_sandstone")

local mg_name = minetest.get_mapgen_setting("mg_name")
local superflat = mg_name == "flat" and minetest.get_mapgen_setting("mcl_superflat_classic") == "true"

-- End exit portal position
local END_EXIT_PORTAL_POS = vector.new(-3, -27003, -3)

-- Content IDs
local c_bedrock = minetest.get_content_id("mcl_core:bedrock")
local c_obsidian = minetest.get_content_id("mcl_core:obsidian")
local c_stone = minetest.get_content_id("mcl_core:stone")
local c_dirt = minetest.get_content_id("mcl_core:dirt")
local c_dirt_with_grass = minetest.get_content_id("mcl_core:dirt_with_grass")
local c_dirt_with_grass_snow = minetest.get_content_id("mcl_core:dirt_with_grass_snow")
local c_reeds = minetest.get_content_id("mcl_core:reeds")
local c_sand = minetest.get_content_id("mcl_core:sand")
--local c_sandstone = minetest.get_content_id("mcl_core:sandstone")
local c_void = minetest.get_content_id("mcl_core:void")
local c_lava = minetest.get_content_id("mcl_core:lava_source")
local c_water = minetest.get_content_id("mcl_core:water_source")
local c_soul_sand = minetest.get_content_id("mcl_nether:soul_sand")
local c_netherrack = minetest.get_content_id("mcl_nether:netherrack")
local c_nether_lava = minetest.get_content_id("mcl_nether:nether_lava_source")
--local c_end_stone = minetest.get_content_id("mcl_end:end_stone")
local c_realm_barrier = minetest.get_content_id("mcl_core:realm_barrier")
local c_top_snow = minetest.get_content_id("mcl_core:snow")
local c_snow_block = minetest.get_content_id("mcl_core:snowblock")
local c_clay = minetest.get_content_id("mcl_core:clay")
local c_leaves = minetest.get_content_id("mcl_core:leaves")
local c_jungleleaves = minetest.get_content_id("mcl_core:jungleleaves")
--local c_jungletree = minetest.get_content_id("mcl_core:jungletree")
local c_cocoa_1 = minetest.get_content_id("mcl_cocoas:cocoa_1")
local c_cocoa_2 = minetest.get_content_id("mcl_cocoas:cocoa_2")
local c_cocoa_3 = minetest.get_content_id("mcl_cocoas:cocoa_3")
local c_vine = minetest.get_content_id("mcl_core:vine")
local c_air = minetest.CONTENT_AIR

dofile(modpath.."/ores.lua")

local mg_flags = minetest.settings:get_flags("mg_flags")

-- Inform other mods of dungeon setting for MCL2-style dungeons
mcl_vars.mg_dungeons = mg_flags.dungeons and not superflat

-- Disable builtin dungeons, we provide our own dungeons
mg_flags.dungeons = false


if superflat then
	-- Enforce superflat-like mapgen: no caves, decor, lakes and hills
	mg_flags.caves = false
	mg_flags.decorations = false
	minetest.set_mapgen_setting("mgflat_spflags", "nolakes,nohills", true)
end

local mg_flags_str = ""
for k,v in pairs(mg_flags) do
	if v == false then
		k = "no" .. k
	end
	mg_flags_str = mg_flags_str .. k .. ","
end
if string.len(mg_flags_str) > 0 then
	mg_flags_str = string.sub(mg_flags_str, 1, string.len(mg_flags_str)-1)
end
minetest.set_mapgen_setting("mg_flags", mg_flags_str, true)

local function between(x, y, z) -- x is between y and z (inclusive)
    return y <= x and x <= z
end
local function in_cube(tpos,wpos1,wpos2)
	local xmax=wpos2.x
	local xmin=wpos1.x

	local ymax=wpos2.y
	local ymin=wpos1.y

	local zmax=wpos2.z
	local zmin=wpos1.z
	if wpos1.x > wpos2.x then
		xmax=wpos1.x
		xmin=wpos2.x
	end
	if wpos1.y > wpos2.y then
		ymax=wpos1.y
		ymin=wpos2.y
	end
	if wpos1.z > wpos2.z then
		zmax=wpos1.z
		zmin=wpos2.z
	end
	if between(tpos.x,xmin,xmax) and between(tpos.y,ymin,ymax) and between(tpos.z,zmin,zmax) then
		return true
	end
	return false
end

-- Helper function for converting a MC probability to MT, with
-- regards to MapBlocks.
-- Some MC generated structures are generated on per-chunk
-- probability.
-- The MC probability is 1/x per Minecraft chunk (16×16).

-- x: The MC probability is 1/x.
-- minp, maxp: MapBlock limits
-- returns: Probability (1/return_value) for a single MT mapblock
local function minecraft_chunk_probability(x, minp, maxp)
	-- 256 is the MC chunk height
	return x * (((maxp.x-minp.x+1)*(maxp.z-minp.z+1)) / 256)
end

-- Takes an index of a biomemap table (from minetest.get_mapgen_object),
-- minp and maxp (from an on_generated callback) and returns the real world coordinates
-- as X, Z.
-- Inverse function of xz_to_biomemap
--[[local function biomemap_to_xz(index, minp, maxp)
	local xwidth = maxp.x - minp.x + 1
	local zwidth = maxp.z - minp.z + 1
	local x = ((index-1) % xwidth) + minp.x
	local z = ((index-1) / zwidth) + minp.z
	return x, z
end]]

-- Takes x and z coordinates and minp and maxp of a generated chunk
-- (in on_generated callback) and returns a biomemap index)
-- Inverse function of biomemap_to_xz
local function xz_to_biomemap_index(x, z, minp, maxp)
	local xwidth = maxp.x - minp.x + 1
	local zwidth = maxp.z - minp.z + 1
	local minix = x % xwidth
	local miniz = z % zwidth

	return (minix + miniz * zwidth) + 1
end

-- Perlin noise objects
local perlin_structures
local perlin_vines, perlin_vines_fine, perlin_vines_upwards, perlin_vines_length, perlin_vines_density
local perlin_clay

local function generate_clay(minp, maxp, blockseed, voxelmanip_data, voxelmanip_area, lvm_used)
	-- TODO: Make clay generation reproducible for same seed.
	if maxp.y < -5 or minp.y > 0 then
		return lvm_used
	end

	local pr = PseudoRandom(blockseed)

	perlin_clay = perlin_clay or minetest.get_perlin({
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = -316,
		octaves = 1,
		persist = 0.0
	})

	for y=math.max(minp.y, 0), math.min(maxp.y, -8), -1 do
		-- Assume X and Z lengths are equal
		local divlen = 4
		local divs = (maxp.x-minp.x)/divlen+1;
		for divx=0+1,divs-2 do
		for divz=0+1,divs-2 do
			-- Get position and shift it a bit randomly so the clay do not obviously appear in a grid
			local cx = minp.x + math.floor((divx+0.5)*divlen) + pr:next(-1,1)
			local cz = minp.z + math.floor((divz+0.5)*divlen) + pr:next(-1,1)

			local water_pos = voxelmanip_area:index(cx, y+1, cz)
			local waternode = voxelmanip_data[water_pos]
			local surface_pos = voxelmanip_area:index(cx, y, cz)
			local surfacenode = voxelmanip_data[surface_pos]

			local genrnd = pr:next(1, 20)
			if genrnd == 1 and perlin_clay:get_3d({x=cx,y=y,z=cz}) > 0 and waternode == c_water and
					(surfacenode == c_dirt or minetest.get_item_group(minetest.get_name_from_content_id(surfacenode), "sand") == 1) then
				local diamondsize = pr:next(1, 3)
				for x1 = -diamondsize, diamondsize do
				for z1 = -(diamondsize - math.abs(x1)), diamondsize - math.abs(x1) do
					local ccpos = voxelmanip_area:index(cx+x1, y, cz+z1)
					local claycandidate = voxelmanip_data[ccpos]
					if voxelmanip_data[ccpos] == c_dirt or minetest.get_item_group(minetest.get_name_from_content_id(claycandidate), "sand") == 1 then
						voxelmanip_data[ccpos] = c_clay
						lvm_used = true
					end
				end
				end
			end
		end
		end
	end
	return lvm_used
end

-- Buffers for LuaVoxelManip
-- local lvm_buffer = {}
-- local lvm_buffer_param2 = {}

-- Generate tree decorations in the bounding box. This adds:
-- * Cocoa at jungle trees
-- * Jungle tree vines
-- * Oak vines in swamplands
local function generate_tree_decorations(minp, maxp, seed, data, param2_data, area, biomemap, lvm_used, pr)
	if maxp.y < 0 then
		return lvm_used
	end

	local oaktree, oakleaves, jungletree, jungleleaves = {}, {}, {}, {}
	local swampland = minetest.get_biome_id("Swampland")
	local swampland_shore = minetest.get_biome_id("Swampland_shore")
	local jungle = minetest.get_biome_id("Jungle")
	local jungle_shore = minetest.get_biome_id("Jungle_shore")
	local jungle_m = minetest.get_biome_id("JungleM")
	local jungle_m_shore = minetest.get_biome_id("JungleM_shore")
	local jungle_edge = minetest.get_biome_id("JungleEdge")
	local jungle_edge_shore = minetest.get_biome_id("JungleEdge_shore")
	local jungle_edge_m = minetest.get_biome_id("JungleEdgeM")
	local jungle_edge_m_shore = minetest.get_biome_id("JungleEdgeM_shore")

	-- Modifier for Jungle M biome: More vines and cocoas
	local dense_vegetation = false

	if biomemap then
		-- Biome map available: Check if the required biome (jungle or swampland)
		-- is in this mapchunk. We are only interested in trees in the correct biome.
		-- The nodes are added if the correct biome is *anywhere* in the mapchunk.
		-- TODO: Strictly generate vines in the correct biomes only.
		local swamp_biome_found, jungle_biome_found = false, false
		for b=1, #biomemap do
			local id = biomemap[b]

			if not swamp_biome_found and (id == swampland or id == swampland_shore) then
				oaktree = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:tree"})
				oakleaves = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:leaves"})
				swamp_biome_found = true
			end
			if not jungle_biome_found and (id == jungle or id == jungle_shore or id == jungle_m or id == jungle_m_shore or id == jungle_edge or id == jungle_edge_shore or id == jungle_edge_m or id == jungle_edge_m_shore) then
				jungletree = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:jungletree"})
				jungleleaves = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:jungleleaves"})
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
		jungletree = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:jungletree"})
		jungleleaves = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:jungleleaves"})
	end

	local pos, treepos, dir

	local cocoachance = 40
	if dense_vegetation then
		cocoachance = 32
	end

	-- Pass 1: Generate cocoas at jungle trees
	for n = 1, #jungletree do

		pos = table.copy(jungletree[n])
		treepos = table.copy(pos)

		if minetest.find_node_near(pos, 1, {"mcl_core:jungleleaves"}) then

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
			local l = minetest.get_node_light(pos)

			if dir < 5
			and data[p_pos] == c_air
			and l and l > 12 then
				local c = pr:next(1, 3)
				if c == 1 then
					data[p_pos] = c_cocoa_1
				elseif c == 2 then
					data[p_pos] = c_cocoa_2
				else
					data[p_pos] = c_cocoa_3
				end
				param2_data[p_pos] = minetest.dir_to_facedir(vector.subtract(treepos, pos))
				lvm_used = true
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

			treepos = table.copy(pos)

			local dirs = {
				{x=1,y=0,z=0},
				{x=-1,y=0,z=0},
				{x=0,y=0,z=1},
				{x=0,y=0,z=-1},
			}

			for d = 1, #dirs do
			local pos = vector.add(pos, dirs[d])
			local p_pos = area:index(pos.x, pos.y, pos.z)

			local vine_threshold = math.max(0.33333, perlin_vines_density:get_2d(pos))
			if dense_vegetation then
				vine_threshold = vine_threshold * (2/3)
			end

			if perlin_vines:get_2d(pos) > -1.0 and perlin_vines_fine:get_3d(pos) > vine_threshold and data[p_pos] == c_air then

				local rdir = {}
				rdir.x = -dirs[d].x
				rdir.y = dirs[d].y
				rdir.z = -dirs[d].z
				local param2 = minetest.dir_to_wallmounted(rdir)

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
					local length = math.ceil(math.abs(perlin_vines_length:get_3d(pos)) * 4)
					for l=0, length-1 do
						local t_pos = area:index(treepos.x, treepos.y, treepos.z)

						if (data[p_pos] == c_air or data[p_pos] == c_jungleleaves or data[p_pos] == c_leaves) and mcl_core.supports_vines(minetest.get_name_from_content_id(data[t_pos])) then
							data[p_pos] = c_vine
							param2_data[p_pos] = param2
							lvm_used = true

						else
							break
						end
						pos.y = pos.y + 1
						p_pos = area:index(pos.x, pos.y, pos.z)
						treepos.y = treepos.y + 1
					end
				else
					-- Grow vines down, length between 1 and maxvinelength
					local length = math.ceil(math.abs(perlin_vines_length:get_3d(pos)) * maxvinelength)
					for l=0, length-1 do
						if data[p_pos] == c_air then
							data[p_pos] = c_vine
							param2_data[p_pos] = param2
							lvm_used = true

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
	return lvm_used
end

minetest.register_on_generated(function(minp, maxp, blockseed)
	minetest.log("action", "[mcl_mapgen_core] Generating chunk " .. minetest.pos_to_string(minp) .. " ... " .. minetest.pos_to_string(maxp))
	local p1, p2 = {x=minp.x, y=minp.y, z=minp.z}, {x=maxp.x, y=maxp.y, z=maxp.z}
	if lvm > 0 then
		local lvm_used, shadow = false, false
		local lb2 = {} -- param2
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local e1, e2 = {x=emin.x, y=emin.y, z=emin.z}, {x=emax.x, y=emax.y, z=emax.z}
		local data2
		local data = vm:get_data(lvm_buffer)
		if param2 > 0 then
			data2 = vm:get_param2_data(lb2)
		end
		local area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})

		for _, rec in ipairs(registered_generators) do
			if rec.vf then
				local lvm_used0, shadow0 = rec.vf(vm, data, data2, e1, e2, area, p1, p2, blockseed)
				if lvm_used0 then
					lvm_used = true
				end
				if shadow0 then
					shadow = true
				end
			end
		end

		if lvm_used then
			-- Write stuff
			vm:set_data(data)
			if param2 > 0 then
				vm:set_param2_data(data2)
			end
			vm:calc_lighting(p1, p2, shadow)
			vm:write_to_map()
			vm:update_liquids()
		end
	end

	if nodes > 0 then
		for _, rec in ipairs(registered_generators) do
			if rec.nf then
				rec.nf(p1, p2, blockseed)
			end
		end
	end

	mcl_vars.add_chunk(minp)
end)

function minetest.register_on_generated(node_function)
	mcl_mapgen_core.register_generator("mod_"..minetest.get_current_modname().."_"..tostring(#registered_generators+1), nil, node_function)
end

function mcl_mapgen_core.register_generator(id, lvm_function, node_function, priority, needs_param2)
	if not id then return end

	local priority = priority or 5000

	if lvm_function then lvm = lvm + 1 end
	if node_function then nodes = nodes + 1 end
	if needs_param2 then param2 = param2 + 1 end

	local new_record = {
		id = id,
		i = priority,
		vf = lvm_function,
		nf = node_function,
		needs_param2 = needs_param2,
	}

	table.insert(registered_generators, new_record)
	table.sort(registered_generators, function(a, b)
		return (a.i < b.i) or ((a.i == b.i) and a.vf and (b.vf == nil))
	end)
end

function mcl_mapgen_core.unregister_generator(id)
	local index
	for i, gen in ipairs(registered_generators) do
		if gen.id == id then
			index = i
			break
		end
	end
	if not index then return end
	local rec = registered_generators[index]
	table.remove(registered_generators, index)
	if rec.vf then lvm = lvm - 1 end
	if rec.nf then nodes = nodes - 1 end
	if rec.needs_param2 then param2 = param2 - 1 end
	--if rec.needs_level0 then level0 = level0 - 1 end
end

-- Generate basic layer-based nodes: void, bedrock, realm barrier, lava seas, etc.
-- Also perform some basic node replacements.

local bedrock_check
if mcl_vars.mg_bedrock_is_rough then
	function bedrock_check(pos, _, pr)
		local y = pos.y
		-- Bedrock layers with increasing levels of roughness, until a perfecly flat bedrock later at the bottom layer
		-- This code assumes a bedrock height of 5 layers.

		local diff = mcl_vars.mg_bedrock_overworld_max - y -- Overworld bedrock
		local ndiff1 = mcl_vars.mg_bedrock_nether_bottom_max - y -- Nether bedrock, bottom
		local ndiff2 = mcl_vars.mg_bedrock_nether_top_max - y -- Nether bedrock, ceiling

		local top
		if diff == 0 or ndiff1 == 0 or ndiff2 == 4 then
			-- 50% bedrock chance
			top = 2
		elseif diff == 1 or ndiff1 == 1 or ndiff2 == 3 then
			-- 66.666...%
			top = 3
		elseif diff == 2 or ndiff1 == 2 or ndiff2 == 2 then
			-- 75%
			top = 4
		elseif diff == 3 or ndiff1 == 3 or ndiff2 == 1 then
			-- 90%
			top = 10
		elseif diff == 4 or ndiff1 == 4 or ndiff2 == 0 then
			-- 100%
			return true
		else
			-- Not in bedrock layer
			return false
		end

		return pr:next(1, top) <= top-1
	end
end


-- Helper function to set all nodes in the layers between min and max.
-- content_id: Node to set
-- check: optional.
--	If content_id, node will be set only if it is equal to check.
--	If function(pos_to_check, content_id_at_this_pos), will set node only if returns true.
-- min, max: Minimum and maximum Y levels of the layers to set
-- minp, maxp: minp, maxp of the on_generated
-- lvm_used: Set to true if any node in this on_generated has been set before.
--
-- returns true if any node was set and lvm_used otherwise
local function set_layers(data, area, content_id, check, min, max, minp, maxp, lvm_used, pr)
	if (maxp.y >= min and minp.y <= max) then
		for y = math.max(min, minp.y), math.min(max, maxp.y) do
			for x = minp.x, maxp.x do
				for z = minp.z, maxp.z do
					local p_pos = area:index(x, y, z)
					if check then
						if type(check) == "function" and check({x=x,y=y,z=z}, data[p_pos], pr) then
							data[p_pos] = content_id
							lvm_used = true
						elseif check == data[p_pos] then
							data[p_pos] = content_id
							lvm_used = true
						end
					else
						data[p_pos] = content_id
						lvm_used = true
					end
				end
			end
		end
	end
	return lvm_used
end

local function set_palette(minp,maxp,data2,area,biomemap,nodes)
	-- Flat area at y=0 to read biome 3 times faster than 5.3.0.get_biome_data(pos).biome: 43us vs 125us per iteration:
	local aream = VoxelArea:new({MinEdge={x=minp.x, y=0, z=minp.z}, MaxEdge={x=maxp.x, y=0, z=maxp.z}})
	local nodes = minetest.find_nodes_in_area(minp, maxp, nodes)
	for n=1, #nodes do
		local n = nodes[n]
		local p_pos = area:index(n.x, n.y, n.z)
		local b_pos = aream:index(n.x, 0, n.z)
		local bn = minetest.get_biome_name(biomemap[b_pos])
		if bn then
			local biome = minetest.registered_biomes[bn]
			if biome and biome._mcl_biome_type then
				data2[p_pos] = biome._mcl_palette_index
				lvm_used = true
			end
		end
	end
	return lvm_used
end

-- Below the bedrock, generate air/void
local function basic(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	local biomemap --ymin, ymax
	local lvm_used = false
	local pr = PseudoRandom(blockseed)

	-- The Void below the Nether:
	lvm_used = set_layers(data, area, c_void         , nil, mcl_vars.mapgen_edge_min                     , mcl_vars.mg_nether_min                     -1, minp, maxp, lvm_used, pr)

	-- [[ THE NETHER:					mcl_vars.mg_nether_min			       mcl_vars.mg_nether_max							]]

	-- The Air on the Nether roof, https://git.minetest.land/MineClone2/MineClone2/issues/1186
	lvm_used = set_layers(data, area, c_air		 , nil, mcl_vars.mg_nether_max			   +1, mcl_vars.mg_nether_max + 128                 , minp, maxp, lvm_used, pr)
	-- The Void above the Nether below the End:
	lvm_used = set_layers(data, area, c_void         , nil, mcl_vars.mg_nether_max + 128               +1, mcl_vars.mg_end_min                        -1, minp, maxp, lvm_used, pr)

	-- [[ THE END:						mcl_vars.mg_end_min			       mcl_vars.mg_end_max							]]

	-- The Void above the End below the Realm barrier:
	lvm_used = set_layers(data, area, c_void         , nil, mcl_vars.mg_end_max                        +1, mcl_vars.mg_realm_barrier_overworld_end_min-1, minp, maxp, lvm_used, pr)
	-- Realm barrier between the Overworld void and the End
	lvm_used = set_layers(data, area, c_realm_barrier, nil, mcl_vars.mg_realm_barrier_overworld_end_min  , mcl_vars.mg_realm_barrier_overworld_end_max  , minp, maxp, lvm_used, pr)
	-- The Void above Realm barrier below the Overworld:
	lvm_used = set_layers(data, area, c_void         , nil, mcl_vars.mg_realm_barrier_overworld_end_max+1, mcl_vars.mg_overworld_min                  -1, minp, maxp, lvm_used, pr)


	if mg_name ~= "singlenode" then
		-- Bedrock
		lvm_used = set_layers(data, area, c_bedrock, bedrock_check, mcl_vars.mg_bedrock_overworld_min, mcl_vars.mg_bedrock_overworld_max, minp, maxp, lvm_used, pr)
		lvm_used = set_layers(data, area, c_bedrock, bedrock_check, mcl_vars.mg_bedrock_nether_bottom_min, mcl_vars.mg_bedrock_nether_bottom_max, minp, maxp, lvm_used, pr)
		lvm_used = set_layers(data, area, c_bedrock, bedrock_check, mcl_vars.mg_bedrock_nether_top_min, mcl_vars.mg_bedrock_nether_top_max, minp, maxp, lvm_used, pr)

		-- Flat Nether
		if mg_name == "flat" then
			lvm_used = set_layers(data, area, c_air, nil, mcl_vars.mg_flat_nether_floor, mcl_vars.mg_flat_nether_ceiling, minp, maxp, lvm_used, pr)
		end

		-- Big lava seas by replacing air below a certain height
		if mcl_vars.mg_lava then
			lvm_used = set_layers(data, area, c_lava, c_air, mcl_vars.mg_overworld_min, mcl_vars.mg_lava_overworld_max, minp, maxp, lvm_used, pr)
			lvm_used = set_layers(data, area, c_nether_lava, c_air, mcl_vars.mg_nether_min, mcl_vars.mg_lava_nether_max, minp, maxp, lvm_used, pr)
		end
	end

	return lvm_used, false
end

local function block_fixes(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	local biomemap = minetest.get_mapgen_object("biomemap")
	local lvm_used = false
	local pr = PseudoRandom(blockseed)
	if minp.y <= mcl_vars.mg_overworld_max and maxp.y >= mcl_vars.mg_overworld_min then
		-- Set param2 (=color) of sugar cane and grass
		lvm_used = set_palette(minp,maxp,data2,area,biomemap,{"mcl_core:reeds","mcl_core:dirt_with_grass"})
	end
	return lvm_used
end


-- End block fixes:
-- * Replace water with end stone or air (depending on height).
-- * Remove stone, sand, dirt in v6 so our End map generator works in v6.
-- * Generate spawn platform (End portal destination)
local function end_basic(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	if minp.y < -26912 or maxp.y >= mcl_vars.mg_end_max then return end
	local biomemap --ymin, ymax
	local lvm_used = false
	local pr = PseudoRandom(blockseed)
	local nodes
	if mg_name ~= "v6" then
		nodes = minetest.find_nodes_in_area(emin, emax, {"mcl_core:water_source"})
		if #nodes > 0 then
			lvm_used = true
			for _,n in pairs(nodes) do
				data[area:index(n.x, n.y, n.z)] = c_air
			end
		end
	end
	-- Final hackery: Set sun light level in the End.
	-- -26912 is at a mapchunk border.
	vm:set_lighting({day=15, night=15})
	lvm_used = true

	local shadow = true
	if emin.y >= mcl_vars.mg_end_min and emax.y <= -26911 then
		shadow = false
		lvm_used = true
	end
	return lvm_used, shadow
end


mcl_mapgen_core.register_generator("main", basic, nil, 1, true)
mcl_mapgen_core.register_generator("end_fixes", end_basic, nil, 20, true)

if mg_name ~= "v6" then
	mcl_mapgen_core.register_generator("block_fixes", block_fixes, nil, 5, true)
end

mcl_mapgen_core.register_generator("structures",nil, function(minp, maxp, blockseed)
	local gennotify = minetest.get_mapgen_object("gennotify")
	local has_struct = {}
	local has = false
	local poshash = minetest.hash_node_position(minp)
	for _,struct in pairs(mcl_structures.registered_structures) do
		local pr = PseudoRandom(blockseed + 42)
		if struct.deco_id then
			for _, pos in pairs(gennotify["decoration#"..struct.deco_id] or {}) do
				local realpos = vector.offset(pos,0,1,0)
				minetest.remove_node(realpos)
				if struct.chunk_probability == nil or (not has and pr:next(1,struct.chunk_probability) == 1 ) then
					mcl_structures.place_structure(realpos,struct,pr,blockseed)
					has=true
				end
			end
		elseif struct.static_pos then
			for _,p in pairs(struct.static_pos) do
				if in_cube(p,minp,maxp) then
					mcl_structures.place_structure(p,struct,pr,blockseed)
				end
			end
		end
	end
end, 100, true)

if mg_name == "v6" then
	dofile(modpath.."/v6.lua")
end
