mcl_mapgen_core = {}
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

dofile(modpath.."/api.lua")
core.register_on_mods_loaded(function()
	dofile(modpath.."/ores.lua")
end)

local mg_name = minetest.get_mapgen_setting("mg_name")
local sea_level = tonumber(minetest.get_mapgen_setting("water_level"))
local superflat = mg_name == "flat" and minetest.get_mapgen_setting("mcl_superflat_classic") == "true"

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

if mg_name == "v7" then
	minetest.set_mapgen_setting("mgv7_cavern_threshold", "0.20", true)
	mg_flags.caverns = true
elseif mg_name == "valleys" then
	minetest.set_mapgen_setting("mgvalleys_cavern_threshold", "0.20", true)
	mg_flags.caverns = true
elseif mg_name == "carpathian" then
	minetest.set_mapgen_setting("mgcarpathian_cavern_threshold", "0.20", true)
	mg_flags.caverns = true
elseif mg_name == "v5" then
	minetest.set_mapgen_setting("mgv5_cavern_threshold", "0.20", true)
	mg_flags.caverns = true
elseif mg_name == "fractal" then
	minetest.set_mapgen_setting("mgfractal_cavern_threshold", "0.20", true)
	mg_flags.caverns = true
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
--
-- returns true if any node was set
local function set_layers(data, area, content_id, check, min, max, minp, maxp, pr)
	if maxp.y < min or minp.y > max then return false end
	local lvm_used = false
	if not check then
		for p_pos in area:iter(minp.x, math.max(min, minp.y), minp.z, maxp.x, math.min(max, maxp.y), maxp.z) do
			data[p_pos] = content_id
			lvm_used = true
		end
	elseif type(check) == "function" then
		-- slow path, needs vector coordinates (bedrock uses y only)
		for p_pos in area:iter(minp.x, math.max(min, minp.y), minp.z, maxp.x, math.min(max, maxp.y), maxp.z) do
			if check(area:position(p_pos), data[p_pos], pr) then
				data[p_pos] = content_id
				lvm_used = true
			end
		end
	else
		for p_pos in area:iter(minp.x, math.max(min, minp.y), minp.z, maxp.x, math.min(max, maxp.y), maxp.z) do
			if check == data[p_pos] then
				data[p_pos] = content_id
				lvm_used = true
			end
		end
	end
	return lvm_used
end

local function set_grass_palette(minp,maxp,data2,area,nodes)
	-- Flat area at y=0 to read biome 3 times faster than 5.3.0.get_biome_data(pos).biome: 43us vs 125us per iteration:
	local biomemap = minetest.get_mapgen_object("biomemap")
	if not biomemap then return end
	local aream = VoxelArea(vector.new(minp.x, 0, minp.z), vector.new(maxp.x, 0, maxp.z))
	local nodes = minetest.find_nodes_in_area(minp, maxp, nodes)
	local lvm_used = false
	for n=1, #nodes do
		local n = nodes[n]
		local p_pos = area:index(n.x, n.y, n.z)
		local b_pos = aream:index(n.x, 0, n.z)
		local bn = minetest.get_biome_name(biomemap[b_pos])
		if bn then
			local biome = minetest.registered_biomes[bn]
			if biome and biome._mcl_biome_type and biome._mcl_grass_palette_index then
				data2[p_pos] = biome._mcl_grass_palette_index
				lvm_used = true
			end
		end
	end
	return lvm_used
end

local function set_foliage_palette(minp,maxp,data2,area,nodes)
	-- Flat area at y=0 to read biome 3 times faster than 5.3.0.get_biome_data(pos).biome: 43us vs 125us per iteration:
	local biomemap = minetest.get_mapgen_object("biomemap")
	if not biomemap then return end
	local aream = VoxelArea(vector.new(minp.x, 0, minp.z), vector.new(maxp.x, 0, maxp.z))
	local nodes = minetest.find_nodes_in_area(minp, maxp, nodes)
	local lvm_used = false
	for n=1, #nodes do
		local n = nodes[n]
		local p_pos = area:index(n.x, n.y, n.z)
		local b_pos = aream:index(n.x, 0, n.z)
		local bn = minetest.get_biome_name(biomemap[b_pos])
		if bn then
			local biome = minetest.registered_biomes[bn]
			if biome and biome._mcl_biome_type and biome._mcl_foliage_palette_index and data2[p_pos] <= 1 then
				data2[p_pos] = biome._mcl_foliage_palette_index
				lvm_used = true
			elseif biome and biome._mcl_biome_type and biome._mcl_foliage_palette_index and data2[p_pos] > 1 then
				data2[p_pos] = (biome._mcl_foliage_palette_index * 8) + data2[p_pos]
				lvm_used = true
			end
		end
	end
	return lvm_used
end

local function set_water_palette(minp,maxp,data2,area,nodes)
	-- Flat area at y=0 to read biome 3 times faster than 5.3.0.get_biome_data(pos).biome: 43us vs 125us per iteration:
	local biomemap = minetest.get_mapgen_object("biomemap")
	if not biomemap then return end
	local aream = VoxelArea(vector.new(minp.x, 0, minp.z), vector.new(maxp.x, 0, maxp.z))
	local nodes = minetest.find_nodes_in_area(minp, maxp, nodes)
	local lvm_used = false
	for n=1, #nodes do
		local n = nodes[n]
		local p_pos = area:index(n.x, n.y, n.z)
		local b_pos = aream:index(n.x, 0, n.z)
		local bn = minetest.get_biome_name(biomemap[b_pos])
		if bn then
			local biome = minetest.registered_biomes[bn]
			if biome and biome._mcl_biome_type and biome._mcl_water_palette_index then
				data2[p_pos] = biome._mcl_water_palette_index
				lvm_used = true
			end
		end
	end
	return lvm_used
end

local function set_seagrass_param2(minp,maxp,data2,area,nodes)
	local nodes = minetest.find_nodes_in_area(minp, maxp, nodes)
	local lvm_used = false
	for n=1, #nodes do
		local n = nodes[n]
		data2[area:index(n.x, n.y, n.z)] = 3
		lvm_used = true
	end
	return lvm_used
end

-- Below the bedrock, generate air/void
local function world_structure(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	local pr = PseudoRandom(blockseed)
	local lvm_used = false

	-- The Void below the Nether:
	lvm_used = set_layers(data, area, c_void         , nil, vl_worlds.mapgen_edge_min                     , mcl_vars.mg_nether_min                     -1, minp, maxp, pr) or lvm_used

	-- [[ THE NETHER:					mcl_vars.mg_nether_min			       mcl_vars.mg_nether_max							]]

	-- The Air on the Nether roof, https://git.minetest.land/VoxeLibre/VoxeLibre/issues/1186
	lvm_used = set_layers(data, area, c_air		 , nil, mcl_vars.mg_nether_max			   +1, mcl_vars.mg_nether_max + 128                 , minp, maxp, pr) or lvm_used
	-- The Void above the Nether below the End:
	lvm_used = set_layers(data, area, c_void         , nil, mcl_vars.mg_nether_max + 128               +1, mcl_vars.mg_end_min                        -1, minp, maxp, pr) or lvm_used

	-- [[ THE END:						mcl_vars.mg_end_min			       mcl_vars.mg_end_max							]]

	-- The Void above the End below the Realm barrier:
	lvm_used = set_layers(data, area, c_void         , nil, mcl_vars.mg_end_max                        +1, mcl_vars.mg_realm_barrier_overworld_end_min-1, minp, maxp, pr) or lvm_used
	-- Realm barrier between the Overworld void and the End
	lvm_used = set_layers(data, area, c_realm_barrier, nil, mcl_vars.mg_realm_barrier_overworld_end_min  , mcl_vars.mg_realm_barrier_overworld_end_max  , minp, maxp, pr) or lvm_used
	-- The Void above Realm barrier below the Overworld:
	lvm_used = set_layers(data, area, c_void         , nil, mcl_vars.mg_realm_barrier_overworld_end_max+1, mcl_vars.mg_overworld_min                  -1, minp, maxp, pr) or lvm_used


	if mg_name ~= "singlenode" then
		-- Bedrock
		lvm_used = set_layers(data, area, c_bedrock, bedrock_check, mcl_vars.mg_bedrock_overworld_min, mcl_vars.mg_bedrock_overworld_max, minp, maxp, pr) or lvm_used
		lvm_used = set_layers(data, area, c_bedrock, bedrock_check, mcl_vars.mg_bedrock_nether_bottom_min, mcl_vars.mg_bedrock_nether_bottom_max, minp, maxp, pr) or lvm_used
		lvm_used = set_layers(data, area, c_bedrock, bedrock_check, mcl_vars.mg_bedrock_nether_top_min, mcl_vars.mg_bedrock_nether_top_max, minp, maxp, pr) or lvm_used

		-- Flat Nether
		if mg_name == "flat" then
			lvm_used = set_layers(data, area, c_air, nil, mcl_vars.mg_flat_nether_floor, mcl_vars.mg_flat_nether_ceiling, minp, maxp, pr) or lvm_used
		end

		-- Big lava seas by replacing air below a certain height
		if mcl_vars.mg_lava then
			lvm_used = set_layers(data, area, c_lava, c_air, mcl_vars.mg_overworld_min, mcl_vars.mg_lava_overworld_max, minp, maxp, pr) or lvm_used
			lvm_used = set_layers(data, area, c_nether_lava, c_air, mcl_vars.mg_nether_min, mcl_vars.mg_lava_nether_max, minp, maxp, pr) or lvm_used
		end
	end
	local deco, ores = false, false
	if minp.y >  mcl_vars.mg_nether_deco_max - 64 and maxp.y <  mcl_vars.mg_nether_max + 128 then
		deco = {min=mcl_vars.mg_nether_deco_max,max=mcl_vars.mg_nether_max}
	end
	if minp.y <  mcl_vars.mg_nether_min + 10 or maxp.y <  mcl_vars.mg_nether_min + 60 then
		deco = {min=mcl_vars.mg_nether_min - 10,max=mcl_vars.mg_nether_min + 20}
		ores = {min=mcl_vars.mg_nether_min - 10,max=mcl_vars.mg_nether_min + 20}
	end
	return lvm_used, lvm_used, deco, ores
end

local function block_fixes_grass(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	-- Set param2 (=color) of nodes which use the grass colour palette.
	return minp.y <= mcl_vars.mg_overworld_max and maxp.y >= mcl_vars.mg_overworld_min and
		set_grass_palette(minp,maxp,data2,area,{"group:grass_palette"})
end

local function block_fixes_foliage(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	-- Set param2 (=color) of nodes which use the foliage colour palette.
	return minp.y <= mcl_vars.mg_overworld_max and maxp.y >= mcl_vars.mg_overworld_min and
		set_foliage_palette(minp,maxp,data2,area,{"group:foliage_palette", "group:foliage_palette_wallmounted"})
end

local function block_fixes_water(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	-- Set param2 (=color) of nodes which use the water colour palette.
	return minp.y <= mcl_vars.mg_overworld_max and maxp.y >= mcl_vars.mg_overworld_min and
		set_water_palette(minp,maxp,data2,area,{"group:water_palette"})
end

local function block_fixes_seagrass(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	-- Set param2 of seagrass to 3.
	return minp.y <= mcl_vars.mg_overworld_max and maxp.y >= mcl_vars.mg_overworld_min and
		set_seagrass_param2(minp, maxp, data2, area, {"group:seagrass"})
end

-- End block fixes:
local function end_basic(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	if maxp.y < mcl_vars.mg_end_min or minp.y > mcl_vars.mg_end_max then return end
	local lvm_used = false
	local nodes = minetest.find_nodes_in_area(emin, emax, {"mcl_core:water_source"})
	if #nodes > 0 then
		lvm_used = true
		for _,n in pairs(nodes) do
			data[area:index(n.x, n.y, n.z)] = c_air
		end
	end
	vm:set_lighting({day=15,night=0})
	lvm_used = true -- light is broken otherwise
	return lvm_used, false
end

mcl_mapgen_core.register_generator("world_structure", world_structure, nil, 1, true)
mcl_mapgen_core.register_generator("end_fixes", end_basic, nil, 9999, true)

if mg_name ~= "singlenode" then
	mcl_mapgen_core.register_generator("block_fixes_grass", block_fixes_grass, nil, 9999, true)
	mcl_mapgen_core.register_generator("block_fixes_foliage", block_fixes_foliage, nil, 9999, true)
	mcl_mapgen_core.register_generator("block_fixes_water", block_fixes_water, nil, 9999, true)
	mcl_mapgen_core.register_generator("block_fixes_seagrass", block_fixes_seagrass, nil, 9999, true)
end

minetest.register_lbm({
	label = "Fix grass palette indexes", -- This LBM fixes any incorrect grass palette indexes.
	name = "mcl_mapgen_core:fix_grass_palette_indexes",
	nodenames = {"group:grass_palette"},
	run_at_every_load = false,
	action = function(pos, node)
		local grass_palette_index = mcl_util.get_palette_indexes_from_pos(pos).grass_palette_index
		if node.param2 ~= grass_palette_index then
			node.param2 = grass_palette_index
			minetest.set_node(pos, node)
		end
	end
})

minetest.register_lbm({
	label = "Fix foliage palette indexes", -- Set correct palette indexes of foliage in old mapblocks.
	name = "mcl_mapgen_core:fix_foliage_palette_indexes",
	nodenames = {"group:foliage_palette", "group:foliage_palette_wallmounted"},
	run_at_every_load = false,
	action = function(pos, node)
		local foliage_palette_index = mcl_util.get_palette_indexes_from_pos(pos).foliage_palette_index
		local noplconvert = {"mcl_mangrove:mangroveleaves", "mcl_core:vine"} -- These do not convert into player leaves.
		if node.param2 == 1 and node.name ~= noplconvert then -- Convert old player leaves into the new versions.
			node.param2 = foliage_palette_index
			minetest.remove_node(pos) -- Required, since otherwise this conversion won't work.
			minetest.place_node(vector.offset(pos, 0, 1, 0), node) -- Offset required, since otherwise the leaves sink one node for some reason.
		elseif node.param2 ~= foliage_palette_index and node.name ~= "mcl_core:vine" then
			node.param2 = foliage_palette_index
			minetest.set_node(pos, node)
		elseif node.name == "mcl_core:vine" then
			local biome_param2 = foliage_palette_index
			local rotation_param2 = mcl_util.get_colorwallmounted_rotation(pos)
			local final_param2 = (biome_param2 * 8) + rotation_param2
			if node.param2 ~= final_param2 then
				node.param2 = final_param2
				minetest.set_node(pos, node)
			end
		end
	end
})

minetest.register_lbm({
	label = "Fix water palette indexes",  -- Set correct palette indexes of water in old mapblocks.
	name = "mcl_mapgen_core:fix_water_palette_indexes",
	nodenames = {"group:water_palette"},
	run_at_every_load = false,
	action = function(pos, node)
		local water_palette_index = mcl_util.get_palette_indexes_from_pos(pos).water_palette_index
		if node.param2 ~= water_palette_index then
			node.param2 = water_palette_index
			minetest.set_node(pos, node)
		end
	end
})

minetest.register_lbm({
	label = "Fix incorrect seagrass", -- Set correct param2 of seagrass in old mapblocks.
	name = "mcl_mapgen_core:fix_incorrect_seagrass",
	nodenames = {"group:seagrass"},
	run_at_every_load = false,
	action = function(pos, node)
		if node.param2 ~= 3 then
			node.param2 = 3
			minetest.set_node(pos, node)
		end
	end
})

-- We go outside x and y for where trees are placed next to a biome that has already been generated.
-- We go above maxp.y because trees can often get placed close to the top of a generated area and folliage may not
-- be coloured correctly.
local function fix_foliage_missed(minp, maxp)
	if maxp.y < 0 then return end
	local pos1, pos2 = vector.offset(minp, -6, 0, -6), vector.offset(maxp, 6, 14, 6)
	local foliage = minetest.find_nodes_in_area(pos1, pos2, {"group:foliage_palette", "group:foliage_palette_wallmounted"})
	for _, fpos in pairs(foliage) do
		local fnode = minetest.get_node(fpos)
		local foliage_palette_index = mcl_util.get_palette_indexes_from_pos(fpos).foliage_palette_index
		if fnode.param2 ~= foliage_palette_index and fnode.name ~= "mcl_core:vine" then
			fnode.param2 = foliage_palette_index
			minetest.set_node(fpos, fnode)
		elseif fnode.name == "mcl_core:vine" then
			local biome_param2 = foliage_palette_index
			local rotation_param2 = mcl_util.get_colorwallmounted_rotation(fpos)
			local final_param2 = (biome_param2 * 8) + rotation_param2
			if fnode.param2 ~= final_param2 then
				fnode.param2 = final_param2
				minetest.set_node(fpos, fnode)
			end
		end
	end
end
mcl_mapgen_core.register_generator("fix_foliage_missed", nil, fix_foliage_missed)
