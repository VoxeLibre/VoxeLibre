-- Adjust water palette, grass palette, foliage palette, etc.

local mg_name = core.get_mapgen_setting("mg_name")

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

if mg_name ~= "v6" and mg_name ~= "singlenode" then
	vl_mapgen.register_generator("block_fixes_grass", block_fixes_grass, nil, 9999, true)
	vl_mapgen.register_generator("block_fixes_water", block_fixes_water, nil, 9999, true)
end

-- LBMs to run on OLD mapblocks
if not mcl_util.minimum_version(mcl_vars.map_version, {0, 88}) then
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
end
