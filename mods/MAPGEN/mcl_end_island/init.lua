local width = 115

local noisemap = PerlinNoiseMap({
	offset = 0.5,
	scale = 0.5,
	spread = {x = width + 10, y = width + 10, z = width + 10},
	seed = minetest.get_mapgen_setting("seed") + 99999,
	octaves = 4,
	persist = 0.85,
}, {x = (width*2)+1, y = 30, z = (width * 2) + 1}):get_3d_map({x = 0, y = 0, z = 0})

local c_end_stone = minetest.get_content_id("mcl_end:end_stone")
local y_offset = -2

mcl_mapgen_core.register_generator("end_island", function(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	if maxp.y < (-27025 + y_offset) or minp.y > (-27000 + y_offset + 4) or maxp.x < -width or minp.x > width  or maxp.z < -width or minp.z > width then
		return
	end

	for idx in area:iter(math.max(minp.x, -width), math.max(minp.y, -27025 + y_offset + 4), math.max(minp.z, -width), math.min(maxp.x, width), math.min(maxp.y, -27000 + y_offset), math.min(maxp.z, width)) do
		local pos = area:position(idx)
		local y = 27025 + pos.y - y_offset
		if noisemap[pos.x + width + 1][y + 1][pos.z + width + 1] > (math.abs(1 - y / 25) ^ 2 + math.abs(pos.x / width) ^ 2 + math.abs(pos.z / width) ^ 2) then
			data[idx] = c_end_stone
		end
	end
	return true,true,true
end, function(minp,maxp,blockseed)
	local nn = minetest.find_nodes_in_area(minp,maxp,{"mcl_end:chorus_flower"})
	local pr = PseudoRandom(blockseed)
	for _,pos in pairs(nn) do
		local x, y, z = pos.x, pos.y, pos.z
		if x < -10 or x > 10 or z < -10 or z > 10 then
			mcl_end.grow_chorus_plant(pos,{name="mcl_end:chorus_flower"},pr)
		end
	end
end, 15, true)
