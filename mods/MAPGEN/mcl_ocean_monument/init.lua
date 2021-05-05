
-- Check it: `/tp 14958,8,11370` @ world seed `1`

local mcl_mapgen_get_far_node = mcl_mapgen.get_far_node
local minetest_log = minetest.log
local minetest_place_schematic = minetest.place_schematic
local minetest_pos_to_string = minetest.pos_to_string

local path = minetest.get_modpath("mcl_ocean_monument") .. "/schematics/ocean_monument.mts"
local water, air, ice = "mcl_core:water_source", "air", "mcl_core:ice"

mcl_mapgen.register_chunk_generator(function(minp, maxp, seed)
	local minp = minp
	local y = minp.y
	if y ~= -32 then return end

	local x, z = minp.x, minp.z
	local pr = PseudoRandom(seed)
	for i = 1, pr:next(10,100) do
		local pos = {x=pr:next(15,64)+x, y=pr:next(0,25)-25, z=pr:next(15,64)+z}
		local node_name = mcl_mapgen_get_far_node(pos).name
		if node_name ~= water then return end
	end
	for i = 1, pr:next(10,100) do
		local pos = {x=pr:next(0,79)+x, y=2, z=pr:next(0,79)+z}
		local node_name = mcl_mapgen_get_far_node(pos).name
		if node_name ~= air then return end
	end
	for i = 1, pr:next(10,100) do
		local pos = {x=pr:next(0,79)+x, y=1, z=pr:next(0,79)+z}
		local node_name = mcl_mapgen_get_far_node(pos).name
		if node_name ~= water and node_name ~= ice then return end
	end

	minetest_place_schematic(minp, path, tostring(pr:next(0,3)*90), nil, true)

	minetest_log("action", "[mcl_ocean_monument] Placed at " .. minetest_pos_to_string(minp))

	---- TODO: SET UP SOME NODES?

end, mcl_mapgen.priorities.OCEAN_MONUMENT)
