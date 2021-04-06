local noisemap = PerlinNoiseMap({
	offset = 0.5,
	scale = 0.5,
	spread = {x = 84, y = 84, z = 84},
	seed = minetest.get_mapgen_setting("seed") + 99999,
	octaves = 4,
	persist = 0.85,
}, {x = 151, y = 30, z = 151}):get_3d_map({x = 0, y = 0, z = 0})

local c_end_stone = minetest.get_content_id("mcl_end:end_stone")
local y_offset = -2

minetest.register_on_generated(function(minp, maxp)
	if maxp.y < (-27025 + y_offset) or minp.y > (-27000 + y_offset + 4) or maxp.x < -75 or minp.x > 75  or maxp.z < -75 or minp.z > 75 then
		return
	end

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})

	for idx in area:iter(math.max(minp.x, -75), math.max(minp.y, -27025 + y_offset + 4), math.max(minp.z, -75), math.min(maxp.x, 75), math.min(maxp.y, -27000 + y_offset), math.min(maxp.z, 75)) do
		local pos = area:position(idx)
		local y = 27025 + pos.y - y_offset
		if noisemap[pos.x + 75 + 1][y + 1][pos.z + 75 + 1] > (math.abs(1 - y / 25) ^ 2 + math.abs(pos.x / 75) ^ 2 + math.abs(pos.z / 75) ^ 2) then
			data[idx] = c_end_stone
		end
	end

	vm:set_data(data)
	vm:calc_lighting()
	vm:update_liquids()
	vm:write_to_map()
end)
