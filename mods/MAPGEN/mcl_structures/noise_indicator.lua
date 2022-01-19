local step = 1
local chunk_borders = false

local levels = {
	[-9] = "black",
	[-8] = "brown",
	[-7] = "brown",
	[-6] = "gray",
	[-5] = "gray",
	[-4] = "red",
	[-3] = "orange",
	[-2] = "purple",
	[-1] = "magenta",
	[0] = "pink",
	[1] = "yellow",
	[2] = "green",
	[3] = "lime",
	[4] = "blue",
	[5] = "cyan",
	[6] = "light_blue",
	[7] = "silver",
	[8] = "silver",
	[9] = "white",
}

local math_min, math_max = math.min, math.max
local math_floor, math_ceil = math.floor, math.ceil

local mcl_structures_get_perlin_noise_level = mcl_structures.get_perlin_noise_level

local noise_offset_x_and_z = math_floor(mcl_mapgen.CS_NODES/2)

mcl_mapgen.register_mapgen(function(minp, maxp, seed, vm_context)
	local y0 = minp.y
	for x0 = minp.x, maxp.x, step do
		for z0 = minp.z, maxp.z, step do
			local current_noise_level = mcl_structures_get_perlin_noise_level({x = x0 - noise_offset_x_and_z, y = y0, z = z0 - noise_offset_x_and_z})
			local amount
			if current_noise_level < 0 then
				amount = math_max(math_ceil(current_noise_level * 9), -9)
			else
				amount = math_min(math_floor(current_noise_level * 9), 9)
			end
			local y0 = maxp.y - 9 + amount
			minetest.set_node({x=x0, y=y0, z=z0}, {name = "mcl_core:glass_"..levels[amount]})
		end
	end
	if chunk_borders then
		for x0 = minp.x, maxp.x, step do
			for y0 = minp.y, maxp.y, step do
				minetest.set_node({x=x0, y=y0, z=maxp.z}, {name = "mcl_core:glass"})
			end
		end
		for z0 = minp.z, maxp.z, step do
			for y0 = minp.y, maxp.y, step do
				minetest.set_node({x=maxp.x, y=y0, z=z0}, {name = "mcl_core:glass"})
			end
		end
	end
end, -1)
