local c_water = minetest.get_content_id("mcl_core:water_source")
local c_dirt = minetest.get_content_id("mcl_core:dirt")
local c_clay = minetest.get_content_id("mcl_core:clay")

local perlin_clay

local math_max = math.max
local math_min = math.min
local math_floor = math.floor
local math_abs = math.abs
local offset = math_floor(mcl_mapgen.BS / 2)
local minetest_get_item_group = minetest.get_item_group
local minetest_get_name_from_content_id = minetest.get_name_from_content_id

mcl_mapgen.register_mapgen_block_lvm(function(c)
	local minp, maxp, blockseed, voxelmanip_data, voxelmanip_area = c.minp, c.maxp, c.blockseed, c.data, c.area
	local max_y = maxp.y
	if max_y < -7 then return end
	local min_y = minp.y
	if min_y > 0 then return end

	c.vm = c.vm or mcl_mapgen.get_voxel_manip(c)

	local pr = PseudoRandom(blockseed)

	perlin_clay = perlin_clay or minetest.get_perlin({
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = -316,
		octaves = 1,
		persist = 0.0
	})

	for y = math_max(min_y, -8), math_min(max_y, 0) do
		-- Assume X and Z lengths are equal
		local x = minp.x + offset + pr:next(-2, 2)
		local z = minp.z + offset + pr:next(-2, 2)
		if perlin_clay:get_3d({x = x, y = y, z = z}) + pr:next(1, 20) > 19 then
			-- Get position and shift it a bit randomly so the clay do not obviously appear in a grid
			local water_pos = voxelmanip_area:index(x, y + 1, z)
			local water_node = voxelmanip_data[water_pos]
			if water_node == c_water or water_node == c_clay then
				local surface_pos = voxelmanip_area:index(x, y, z)
				local surface_node = voxelmanip_data[surface_pos]
				if (surface_node == c_dirt or surface_node == c_clay or minetest_get_item_group(minetest_get_name_from_content_id(surface_node), "sand") == 1) then
					local diamondsize = pr:next(1, 3)
					for x1 = -diamondsize, diamondsize do
						local abs_x1 = math_abs(x1)
						for z1 = -(diamondsize - abs_x1), diamondsize - abs_x1 do
							local ccpos = voxelmanip_area:index(x + x1, y, z + z1)
							local claycandidate = voxelmanip_data[ccpos]
							if voxelmanip_data[ccpos] == c_dirt or minetest_get_item_group(minetest_get_name_from_content_id(claycandidate), "sand") == 1 then
								voxelmanip_data[ccpos] = c_clay
								c.write = true
							end
						end
					end
				end
			end
		end
	end
end)
