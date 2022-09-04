-- End exit portal position
local END_EXIT_PORTAL_POS = vector.new(-3, -27003, -3)

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

local function generate_end_exit_portal(pos)
	local obj = minetest.add_entity(vector.add(pos, vector.new(3, 11, 3)), "mobs_mc:enderdragon")
	if obj then
		local dragon_entity = obj:get_luaentity()
		dragon_entity._initial = true
		dragon_entity._portal_pos = pos
	else
		minetest.log("error", "[mcl_mapgen_core] ERROR! Ender dragon doesn't want to spawn")
	end
	mcl_structures.call_struct(pos, "end_exit_portal")
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

		-- Clay, vines, cocoas
		lvm_used = generate_clay(minp, maxp, blockseed, data, area, lvm_used)
		biomemap = minetest.get_mapgen_object("biomemap")


		----- Interactive block fixing section -----
		----- The section to perform basic block overrides of the core mapgen generated world. -----

		-- Snow and sand fixes. This code implements snow consistency
		-- and fixes floating sand and cut plants.
		-- A snowy grass block must be below a top snow or snow block at all times.
		if minp.y <= mcl_vars.mg_overworld_max and maxp.y >= mcl_vars.mg_overworld_min then
			-- v6 mapgen:
			if mg_name ~= "v6" then
			-- Non-v6 mapgens:
				-- Set param2 (=color) of grass blocks.
				-- Clear snowy grass blocks without snow above to ensure consistency.
				local nodes = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:dirt_with_grass", "mcl_core:dirt_with_grass_snow"})

				-- Flat area at y=0 to read biome 3 times faster than 5.3.0.get_biome_data(pos).biome: 43us vs 125us per iteration:
				local aream = VoxelArea:new({MinEdge={x=minp.x, y=0, z=minp.z}, MaxEdge={x=maxp.x, y=0, z=maxp.z}})
				for n=1, #nodes do
					local n = nodes[n]
					local p_pos = area:index(n.x, n.y, n.z)
					local p_pos_above = area:index(n.x, n.y+1, n.z)
					--local p_pos_below = area:index(n.x, n.y-1, n.z)
					local b_pos = aream:index(n.x, 0, n.z)
					local bn = minetest.get_biome_name(biomemap[b_pos])
					if bn then
						local biome = minetest.registered_biomes[bn]
						if biome and biome._mcl_biome_type then
							data2[p_pos] = biome._mcl_palette_index
							lvm_used = true
						end
					end
					if data[p_pos] == c_dirt_with_grass_snow and p_pos_above and data[p_pos_above] ~= c_top_snow and data[p_pos_above] ~= c_snow_block then
						data[p_pos] = c_dirt_with_grass
						lvm_used = true
					end
				end

				-- Set param2 (=color) of sugar cane
				nodes = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:reeds"})
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
			end

		-- Nether block fixes:
		-- * Replace water with Nether lava.
		-- * Replace stone, sand dirt in v6 so the Nether works in v6.
		elseif emin.y <= mcl_vars.mg_nether_max and emax.y >= mcl_vars.mg_nether_min then
			if mg_name ~= "v6" then
				local nodes = minetest.find_nodes_in_area(emin, emax, {"group:water"})
				for _, n in pairs(nodes) do
					data[area:index(n.x, n.y, n.z)] = c_nether_lava
				end
			end

		-- End block fixes:
		-- * Replace water with end stone or air (depending on height).
		-- * Remove stone, sand, dirt in v6 so our End map generator works in v6.
		-- * Generate spawn platform (End portal destination)
		elseif minp.y <= mcl_vars.mg_end_max and maxp.y >= mcl_vars.mg_end_min then
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
			-- Obsidian spawn platform
			if minp.y <= mcl_vars.mg_end_platform_pos.y and maxp.y >= mcl_vars.mg_end_platform_pos.y and
				minp.x <= mcl_vars.mg_end_platform_pos.x and maxp.x >= mcl_vars.mg_end_platform_pos.z and
				minp.z <= mcl_vars.mg_end_platform_pos.z and maxp.z >= mcl_vars.mg_end_platform_pos.z then

				--local pos1 = {x = math.max(minp.x, mcl_vars.mg_end_platform_pos.x-2), y = math.max(minp.y, mcl_vars.mg_end_platform_pos.y),   z = math.max(minp.z, mcl_vars.mg_end_platform_pos.z-2)}
				--local pos2 = {x = math.min(maxp.x, mcl_vars.mg_end_platform_pos.x+2), y = math.min(maxp.y, mcl_vars.mg_end_platform_pos.y+2), z = math.min(maxp.z, mcl_vars.mg_end_platform_pos.z+2)}

				for x=math.max(minp.x, mcl_vars.mg_end_platform_pos.x-2), math.min(maxp.x, mcl_vars.mg_end_platform_pos.x+2) do
				for z=math.max(minp.z, mcl_vars.mg_end_platform_pos.z-2), math.min(maxp.z, mcl_vars.mg_end_platform_pos.z+2) do
				for y=math.max(minp.y, mcl_vars.mg_end_platform_pos.y), math.min(maxp.y, mcl_vars.mg_end_platform_pos.y+2) do
					local p_pos = area:index(x, y, z)
					if y == mcl_vars.mg_end_platform_pos.y then
						data[p_pos] = c_obsidian
					else
						data[p_pos] = c_air
					end
				end
				end
				end
				lvm_used = true
			end
		end
	end
	-- Final hackery: Set sun light level in the End.
	-- -26912 is at a mapchunk border.
	local shadow = true
	if minp.y >= -26912 and maxp.y <= mcl_vars.mg_end_max then
		vm:set_lighting({day=15, night=15})
		lvm_used = true
	end
	if minp.y >= mcl_vars.mg_end_min and maxp.y <= -26911 then
		shadow = false
		lvm_used = true
	end

	return lvm_used, shadow
end

mcl_mapgen_core.register_generator("main", basic, basic_node, 1, true)

mcl_mapgen_core.register_generator("end_exit_portal",nil, function(minp, maxp, blockseed)
	if	minp.y <= END_EXIT_PORTAL_POS.y and maxp.y >= END_EXIT_PORTAL_POS.y and
		minp.x <= END_EXIT_PORTAL_POS.x and maxp.x >= END_EXIT_PORTAL_POS.x and
		minp.z <= END_EXIT_PORTAL_POS.z and maxp.z >= END_EXIT_PORTAL_POS.z then
		for y=maxp.y, minp.y, -1 do
			local p = {x=END_EXIT_PORTAL_POS.x, y=y, z=END_EXIT_PORTAL_POS.z}
			if minetest.get_node(p).name == "mcl_end:end_stone" then
				generate_end_exit_portal(p)
				return
			end
		end
		generate_end_exit_portal(END_EXIT_PORTAL_POS)
	end
end,101,true)
