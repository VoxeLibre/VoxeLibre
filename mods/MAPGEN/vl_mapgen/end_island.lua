-- TODO: this could/should be moved into async mapgen
local width = 200
local ybase = 18 -- with 25, the island is almost completely flat on top
local end_island_np = {
	-- note: offset ~ (ybase/25-1)^2 guarantees the end portal is on solid ground
	-- but offset + scale * 0.5 is usually enough, too.
	offset = 0.1,
	scale = 0.25,
	spread = {x = 120, y = 200, z = 120},
	seed = core.get_mapgen_setting("seed") + 99999,
	octaves = 4,
	persist = 0.66, -- makes the island more regular
	flags = "absvalue"
}

local c_end_stone = core.get_content_id("mcl_end:end_stone")
local y_offset = -2

-- Keep old maps consistent for <0.90
if not mcl_util.minimum_version(mcl_vars.map_version, {0, 90}) then
	end_island_np = {
		offset = 0.5,
		scale = 0.5,
		spread = {x = width + 10, y = width + 10, z = width + 10},
		seed = core.get_mapgen_setting("seed") + 99999,
		octaves = 4,
		persist = 0.85
	}
	ybase = 25
end

-- Generator for the main end island, originally by Fleckenstein
-- but then completely rewritten by kno10
vl_mapgen.register_generator("end_island", function(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	if maxp.y < (-27025 + y_offset) or minp.y > (-27000 + y_offset + 4) or maxp.x < -width or minp.x > width  or maxp.z < -width or minp.z > width then
		return
	end
	-- area of interest
	local minx = math.max(minp.x, -width)
	local maxx = math.min(maxp.x, width)
	local miny = math.max(minp.y, -27025 + y_offset + 4)
	local maxy = math.min(maxp.y, -27000 + y_offset)
	local minz = math.max(minp.z, -width)
	local maxz = math.min(maxp.z, width)
	local sizex, sizey, sizez = maxx - minx + 1, maxy - miny + 1, maxz - minz + 1

	-- Offsets into noise to keep the end island exactly as in earlier versions
	local offx = minx + width 
	local offy = miny + 27025 - y_offset
	local offz = minz + width
	local noisemap = PerlinNoiseMap(end_island_np, {x = sizex, y = sizey, z = sizez }):get_3d_map_flat({x = offx, y = offy, z = offz})

	-- note: x,y,z are used relative to our area of interest
	local noiseidx = 1
	for z = 1, sizez do for y = 1, sizey do
		local absx, absy, absz = minx, miny + y - 1, minz + z - 1
		local zweight = math.abs(absz / width)^2
		local rely = absy + 27025 - y_offset -- relative to center of mass
		local yweight = math.abs(1 - rely / ybase)^2
		local lvmidx = area:index(absx, absy, absz)
		for x = 1, sizex do
			local thresh = yweight + zweight + math.abs(absx / width)^2
			if noisemap[noiseidx] > thresh then
				data[lvmidx] = c_end_stone
			end
			-- increment array index and x
			lvmidx = lvmidx + 1
			noiseidx = noiseidx + 1
			absx = absx + 1
		end
	end end -- y and z
	return true,false,false
end, nil, 15, false)

