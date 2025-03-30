-- Adjust water palette, grass palette, foliage palette, etc.
local mg_name = core.get_mapgen_setting("mg_name")

local mg_4dir = {} -- paramtype2="4dir" randomization
local mg_color4dir = {} -- paramtype2="color4dir" randomization
local mg_water_palette = {} -- set param2 to biome water palette

-- C.f., luanti builtin/game/voxelarea.lua VoxelArea:postion, but with less overhead
local math_floor = math.floor
local function position(area, i)
	local MinEdge = area.MinEdge
	i = i - 1
	local z = math_floor(i / area.zstride)
	i = i - z * area.zstride
	local y = math_floor(i / area.ystride)
	i = i - y * area.ystride
	local x = i
	return x + MinEdge.x, y + MinEdge.y, z + MinEdge.z
end

local function adjust_param2(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	local lvm_used = false
	-- We don't use a deterministic random, because this is just cosmetic.
	-- You could seed a PcgRandom with the blockseed, though, or use coordinate-based pseudorandom.
	local biomemap = core.get_mapgen_object("biomemap")
	local barea = VoxelArea(vector.new(minp.x, 0, minp.z), vector.new(maxp.x, 0, maxp.z))
	for i in area:iter(minp.x, minp.y, minp.z, maxp.x, maxp.y, maxp.z) do
		if mg_4dir[data[i]] then
			data2[i] = math.random(0, 3)
			lvm_used = true
		elseif mg_color4dir[data[i]] then
			local bid
			if biomemap then
				local x, _, z = position(area, i)
				bid = biomemap[barea:index(x, 0, z)]
			end
			bid = bid or core.get_biome_data(area:position(i)).biome
			local biome = core.registered_biomes[core.get_biome_name(bid)]
			local pal = biome and biome._mcl_grass_palette_index
			if pal then
				data2[i] = pal * 4 + math.random(0, 3)
			else
				data2[i] = bit.band(data2[i], 0xFC) + math.random(0, 3)
			end
			lvm_used = true
		elseif mg_water_palette[data[i]] then
			local bid
			if biomemap then
				local x, _, z = position(area, i)
				bid = biomemap[barea:index(x, 0, z)]
			end
			bid = bid or core.get_biome_data(area:position(i)).biome
			local biome = core.registered_biomes[core.get_biome_name(bid)]
			local pal = biome and biome._mcl_water_palette_index
			if pal then
				data2[i] = pal
				lvm_used = true
			end
		end
	end
	return lvm_used
end
vl_mapgen.register_generator("adjust_param", adjust_param2, nil, 9999, true)

-- Identify nodes that are affected
if mg_name ~= "v6" and mg_name ~= "singlenode" then
core.register_on_mods_loaded(function()
	for n, def in pairs(core.registered_nodes) do
		local groups = def.groups or {}
		if (groups.random4dir or 0) ~= 0 then
			if def.paramtype2 ~= "4dir" then
				core.log("warning", "Node "..n.." has group random4dir but paramtype2=\""..(def.paramtype2 or "").."\"")
			end
			mg_4dir[core.get_content_id(n)] = true
		elseif (groups.randomcolor4dir or 0) ~= 0 then
			if def.paramtype2 ~= "color4dir" or not def.palette then
				core.log("warning", "Node "..n.." has group randomcolor4dir but paramtype2=\""..(def.paramtype2 or "").."\" palette \""..(palette or "").."\"")
			end
			mg_color4dir[core.get_content_id(n)] = true
		elseif (groups.water_palette or 0) ~= 0 then
			if def.paramtype2 ~= "color" or not def.palette then
				core.log("warning", "Node "..n.." has group water_palette but paramtype2=\""..(def.paramtype2 or "").."\" palette \""..(palette or "").."\"")
			end
			mg_water_palette[core.get_content_id(n)] = true
		end
	end
end)
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
