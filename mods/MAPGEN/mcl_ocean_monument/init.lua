
-- Check it:
--	seed 1, v7 mapgen
--	/teleport 14958,8,11370

local mcl_mapgen_get_far_node = mcl_mapgen.get_far_node
local minetest_log = minetest.log
local minetest_place_schematic = minetest.place_schematic
local minetest_pos_to_string = minetest.pos_to_string
local minetest_swap_node = minetest.swap_node

local path = minetest.get_modpath("mcl_ocean_monument") .. "/schematics/ocean_monument.mts"

local water = "mcl_core:water_source"
local air = "air"
local ice = "mcl_core:ice"

local leg_materials = {
	"mcl_ocean:prismarine_brick",
	"mcl_ocean:prismarine",
}
local what_we_can_replace_by_legs = {
	water,
	air,
	"mcl_core:water_flowing",
	"mcl_core:stone",
}

local leg_search_quick_index = {}
for _, v in pairs(leg_materials) do
	leg_search_quick_index[v] = true
end

local leg_replace_quick_index = {}
for _, v in pairs(what_we_can_replace_by_legs) do
	leg_replace_quick_index[v] = true
end

local y_wanted = mcl_mapgen.OFFSET_NODES -- supposed to be -32
local y_bottom = mcl_mapgen.overworld.min -- -62

mcl_mapgen.register_chunk_generator(function(minp, maxp, seed)
	local minp = minp
	local y = minp.y
	if y ~= y_wanted then return end

	local x, z = minp.x, minp.z
	local pr = PseudoRandom(seed)

	-- scan the ocean - it should be the ocean:
	for i = 1, pr:next(10, 100) do
		local pos = {x = pr:next(15, 64) + x, y = pr:next(0, 25) - 25, z = pr:next(15, 64) + z}
		local node_name = mcl_mapgen_get_far_node(pos).name
		if node_name ~= water then return end
	end

	-- scan nodes above water level - there should be the air:
	for i = 1, pr:next(10, 100) do
		local pos = {x = pr:next(0, 79) + x, y = 2, z = pr:next(0,79) + z}
		local node_name = mcl_mapgen_get_far_node(pos).name
		if node_name ~= air then return end
	end

	-- scan ocean surface - allow only water and ice:
	for i = 1, pr:next(10,100) do
		local pos = {x=pr:next(0, 79)+x, y=1, z=pr:next(0,79)+z}
		local node_name = mcl_mapgen_get_far_node(pos).name
		if node_name ~= water and node_name ~= ice then return end
	end

	-- random rotation:
	local rotation = pr:next(0, 3)
	local rotation_str = tostring(rotation * 90)
	minetest_place_schematic(minp, path, rotation_str, nil, true)

	-- search prismarine legs at base level and continue them up to the bottom:
	for x = x, maxp.x do
		for z = z, maxp.z do
			local pos = {x = x, y = y, z = z}
			local node_name = mcl_mapgen_get_far_node(pos).name
			if leg_search_quick_index[node_name] then
				local node_leg = {name = node_name}
				for y = y - 1, y_bottom, -1 do
					pos.y = y
					local next_name = mcl_mapgen_get_far_node(pos).name
					if not leg_replace_quick_index[next_name] then
						break
					end
					minetest_swap_node(pos, node_leg)
				end
			end
		end
	end

	minetest_log("action", "[mcl_ocean_monument] Placed at " .. minetest_pos_to_string(minp) .. ", " .. rotation_str .. " deg.")

end, mcl_mapgen.priorities.OCEAN_MONUMENT)
