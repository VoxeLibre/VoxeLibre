vl_mapgen = {}
mcl_mapgen_core = vl_mapgen -- export for mod compatibility
local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

--
-- Aliases for map generator outputs
--

core.register_alias("mapgen_air", "air")
core.register_alias("mapgen_stone", "mcl_core:stone")
core.register_alias("mapgen_tree", "mcl_core:tree")
core.register_alias("mapgen_leaves", "mcl_core:leaves")
core.register_alias("mapgen_jungletree", "mcl_core:jungletree")
core.register_alias("mapgen_jungleleaves", "mcl_core:jungleleaves")
core.register_alias("mapgen_pine_tree", "mcl_core:sprucetree")
core.register_alias("mapgen_pine_needles", "mcl_core:spruceleaves")

core.register_alias("mapgen_apple", "mcl_core:leaves")
core.register_alias("mapgen_water_source", "mcl_core:water_source")
core.register_alias("mapgen_dirt", "mcl_core:dirt")
core.register_alias("mapgen_dirt_with_grass", "mcl_core:dirt_with_grass")
core.register_alias("mapgen_dirt_with_snow", "mcl_core:dirt_with_grass_snow")
core.register_alias("mapgen_sand", "mcl_core:sand")
core.register_alias("mapgen_gravel", "mcl_core:gravel")
core.register_alias("mapgen_clay", "mcl_core:clay")
core.register_alias("mapgen_lava_source", "air") -- Built-in lava generator is too unpredictable, we generate lava on our own
core.register_alias("mapgen_cobble", "mcl_core:cobble")
core.register_alias("mapgen_mossycobble", "mcl_core:mossycobble")
core.register_alias("mapgen_junglegrass", "mcl_flowers:fern")
core.register_alias("mapgen_stone_with_coal", "mcl_core:stone_with_coal")
core.register_alias("mapgen_stone_with_iron", "mcl_core:stone_with_iron")
core.register_alias("mapgen_desert_sand", "mcl_core:sand")
core.register_alias("mapgen_desert_stone", "mcl_core:sandstone")
core.register_alias("mapgen_sandstone", "mcl_core:sandstone")
core.register_alias("mapgen_river_water_source", "mclx_core:river_water_source")
core.register_alias("mapgen_snow", "mcl_core:snow")
core.register_alias("mapgen_snowblock", "mcl_core:snowblock")
core.register_alias("mapgen_ice", "mcl_core:ice")

core.register_alias("mapgen_stair_cobble", "mcl_stairs:stair_cobble")
core.register_alias("mapgen_sandstonebrick", "mcl_core:sandstonesmooth")
core.register_alias("mapgen_stair_sandstonebrick", "mcl_stairs:stair_sandstone")
core.register_alias("mapgen_stair_sandstone_block", "mcl_stairs:stair_sandstone")
core.register_alias("mapgen_stair_desert_stone", "mcl_stairs:stair_sandstone")

dofile(modpath.."/api.lua")
dofile(modpath.."/ores.lua")

local mg_name = core.get_mapgen_setting("mg_name")
local sea_level = tonumber(core.get_mapgen_setting("water_level"))
local superflat = mg_name == "flat" and core.get_mapgen_setting("mcl_superflat_classic") == "true"

-- Content IDs
local c_bedrock = core.get_content_id("mcl_core:bedrock")
local c_obsidian = core.get_content_id("mcl_core:obsidian")
local c_stone = core.get_content_id("mcl_core:stone")
local c_dirt = core.get_content_id("mcl_core:dirt")
local c_dirt_with_grass = core.get_content_id("mcl_core:dirt_with_grass")
local c_dirt_with_grass_snow = core.get_content_id("mcl_core:dirt_with_grass_snow")
local c_reeds = core.get_content_id("mcl_core:reeds")
local c_sand = core.get_content_id("mcl_core:sand")
--local c_sandstone = core.get_content_id("mcl_core:sandstone")
local c_void = core.get_content_id("mcl_core:void")
local c_lava = core.get_content_id("mcl_core:lava_source")
local c_water = core.get_content_id("mcl_core:water_source")
local c_soul_sand = core.get_content_id("mcl_nether:soul_sand")
local c_netherrack = core.get_content_id("mcl_nether:netherrack")
local c_nether_lava = core.get_content_id("mcl_nether:nether_lava_source")
--local c_end_stone = core.get_content_id("mcl_end:end_stone")
local c_realm_barrier = core.get_content_id("mcl_core:realm_barrier")
local c_top_snow = core.get_content_id("mcl_core:snow")
local c_snow_block = core.get_content_id("mcl_core:snowblock")
local c_clay = core.get_content_id("mcl_core:clay")
local c_leaves = core.get_content_id("mcl_core:leaves")
local c_jungleleaves = core.get_content_id("mcl_core:jungleleaves")
--local c_jungletree = core.get_content_id("mcl_core:jungletree")
local c_cocoa_1 = core.get_content_id("mcl_cocoas:cocoa_1")
local c_cocoa_2 = core.get_content_id("mcl_cocoas:cocoa_2")
local c_cocoa_3 = core.get_content_id("mcl_cocoas:cocoa_3")
local c_vine = core.get_content_id("mcl_core:vine")
local c_air = core.CONTENT_AIR

local mg_flags = core.settings:get_flags("mg_flags")

-- Inform other mods of dungeon setting for MCL2-style dungeons
mcl_vars.mg_dungeons = mg_flags.dungeons and not superflat

-- Disable builtin dungeons, we provide our own dungeons
mg_flags.dungeons = false

if superflat then
	-- Enforce superflat-like mapgen: no caves, decor, lakes and hills
	mg_flags.caves = false
	mg_flags.decorations = false
	core.set_mapgen_setting("mgflat_spflags", "nolakes,nohills", true)
end

if mg_name == "v7" then
	core.set_mapgen_setting("mgv7_cavern_threshold", "0.20", true)
	mg_flags.caverns = true
elseif mg_name == "valleys" then
	core.set_mapgen_setting("mgvalleys_cavern_threshold", "0.20", true)
	mg_flags.caverns = true
elseif mg_name == "carpathian" then
	core.set_mapgen_setting("mgcarpathian_cavern_threshold", "0.20", true)
	mg_flags.caverns = true
elseif mg_name == "v5" then
	core.set_mapgen_setting("mgv5_cavern_threshold", "0.20", true)
	mg_flags.caverns = true
elseif mg_name == "fractal" then
	core.set_mapgen_setting("mgfractal_cavern_threshold", "0.20", true)
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
core.set_mapgen_setting("mg_flags", mg_flags_str, true)

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
	local biomemap = core.get_mapgen_object("biomemap")
	if not biomemap then return end
	local aream = VoxelArea(vector.new(minp.x, 0, minp.z), vector.new(maxp.x, 0, maxp.z))
	local nodes = core.find_nodes_in_area(minp, maxp, nodes)
	local lvm_used = false
	for n=1, #nodes do
		local n = nodes[n]
		local p_pos = area:index(n.x, n.y, n.z)
		local b_pos = aream:index(n.x, 0, n.z)
		local bn = core.get_biome_name(biomemap[b_pos])
		if bn then
			local biome = core.registered_biomes[bn]
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
	local biomemap = core.get_mapgen_object("biomemap")
	if not biomemap then return end
	local aream = VoxelArea(vector.new(minp.x, 0, minp.z), vector.new(maxp.x, 0, maxp.z))
	local nodes = core.find_nodes_in_area(minp, maxp, nodes)
	local lvm_used = false
	for n=1, #nodes do
		local n = nodes[n]
		local p_pos = area:index(n.x, n.y, n.z)
		local b_pos = aream:index(n.x, 0, n.z)
		local bn = core.get_biome_name(biomemap[b_pos])
		if bn then
			local biome = core.registered_biomes[bn]
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
	local biomemap = core.get_mapgen_object("biomemap")
	if not biomemap then return end
	local aream = VoxelArea(vector.new(minp.x, 0, minp.z), vector.new(maxp.x, 0, maxp.z))
	-- FIXME: this relies on the voxelmanip already being written.
	local nodes = core.find_nodes_in_area(minp, maxp, nodes)
	local lvm_used = false
	for n=1, #nodes do
		local n = nodes[n]
		local p_pos = area:index(n.x, n.y, n.z)
		local b_pos = aream:index(n.x, 0, n.z)
		local bn = core.get_biome_name(biomemap[b_pos])
		if bn then
			local biome = core.registered_biomes[bn]
			if biome and biome._mcl_biome_type and biome._mcl_water_palette_index then
				data2[p_pos] = biome._mcl_water_palette_index
				lvm_used = true
			end
		end
	end
	return lvm_used
end

-- Below the bedrock, generate air/void
local function world_structure(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	local pr = PseudoRandom(blockseed)
	local lvm_used = false

	-- The Void below the Nether:
	lvm_used = set_layers(data, area, c_void         , nil, mcl_vars.mapgen_edge_min                     , mcl_vars.mg_nether_min                     -1, minp, maxp, pr) or lvm_used

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

-- largely replaced with decoration hack to replace grass nodes
-- BUT this still happens at the famous y=+48 level because of mapgen overgeneration
local function block_fixes_grass(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	-- Set param2 (=color) of nodes which use the grass colour palette.
	return minp.y <= mcl_vars.mg_overworld_max and maxp.y >= mcl_vars.mg_overworld_min and
		set_grass_palette(minp,maxp,data2,area,{"group:grass_palette"})
end

local function block_fixes_water(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	-- Set param2 (=color) of nodes which use the water colour palette.
	return minp.y <= mcl_vars.mg_overworld_max and maxp.y >= mcl_vars.mg_overworld_min and
		set_water_palette(minp,maxp,data2,area,{"group:water_palette"})
end

-- End block fixes:
local function end_basic(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	if maxp.y < mcl_vars.mg_end_min or minp.y > mcl_vars.mg_end_max then return end
	local lvm_used = false
	if mg_name ~= "v6" then
		local nodes = core.find_nodes_in_area(emin, emax, {"mcl_core:water_source"})
		if #nodes > 0 then
			lvm_used = true
			for _,n in pairs(nodes) do
				data[area:index(n.x, n.y, n.z)] = c_air
			end
		end
	end
	vm:set_lighting({day=15,night=0})
	lvm_used = true -- light is broken otherwise
	return lvm_used, false
end

vl_mapgen.register_generator("world_structure", world_structure, nil, 1, true)
vl_mapgen.register_generator("end_fixes", end_basic, nil, 9999, true)

if mg_name ~= "v6" and mg_name ~= "singlenode" then
	vl_mapgen.register_generator("block_fixes_grass", block_fixes_grass, nil, 9999, true)
	vl_mapgen.register_generator("block_fixes_water", block_fixes_water, nil, 9999, true)
end

if mg_name == "v6" then
	dofile(modpath.."/v6.lua")
end

core.register_lbm({
	label = "Fix grass palette indexes", -- This LBM fixes any incorrect grass palette indexes.
	name = ":mcl_mapgen_core:fix_grass_palette_indexes", -- keep old id, to not rerun
	nodenames = {"group:grass_palette"},
	run_at_every_load = false,
	action = function(pos, node)
		local grass_palette_index = mcl_util.get_palette_indexes_from_pos(pos).grass_palette_index
		if node.param2 ~= grass_palette_index then
			node.param2 = grass_palette_index
			core.swap_node(pos, node)
		end
	end
})

core.register_lbm({
	label = "Fix foliage palette indexes", -- Set correct palette indexes of foliage in old mapblocks.
	name = ":mcl_mapgen_core:fix_foliage_palette_indexes", -- keep old id, to not rerun
	nodenames = {"group:foliage_palette", "group:foliage_palette_wallmounted"},
	run_at_every_load = false,
	action = function(pos, node)
		local foliage_palette_index = mcl_util.get_palette_indexes_from_pos(pos).foliage_palette_index
		local noplconvert = {"mcl_mangrove:mangroveleaves", "mcl_core:vine"} -- These do not convert into player leaves.
		if node.param2 == 1 and node.name ~= noplconvert then -- Convert old player leaves into the new versions.
			node.param2 = foliage_palette_index
			core.remove_node(pos) -- Required, since otherwise this conversion won't work.
			core.place_node(vector.offset(pos, 0, 1, 0), node) -- Offset required, since otherwise the leaves sink one node for some reason.
		elseif node.param2 ~= foliage_palette_index and node.name ~= "mcl_core:vine" then
			node.param2 = foliage_palette_index
			core.swap_node(pos, node)
		elseif node.name == "mcl_core:vine" then
			local biome_param2 = foliage_palette_index
			local rotation_param2 = mcl_util.get_colorwallmounted_rotation(pos)
			local final_param2 = (biome_param2 * 8) + rotation_param2
			if node.param2 ~= final_param2 then
				node.param2 = final_param2
				core.swap_node(pos, node)
			end
		end
	end
})

core.register_lbm({
	label = "Fix water palette indexes",  -- Set correct palette indexes of water in old mapblocks.
	name = ":mcl_mapgen_core:fix_water_palette_indexes", -- keep old id, to not rerun
	nodenames = {"group:water_palette"},
	run_at_every_load = false,
	action = function(pos, node)
		local water_palette_index = mcl_util.get_palette_indexes_from_pos(pos).water_palette_index
		if node.param2 ~= water_palette_index then
			node.param2 = water_palette_index
			core.swap_node(pos, node)
		end
	end
})
