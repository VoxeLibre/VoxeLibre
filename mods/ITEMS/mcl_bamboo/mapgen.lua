local item_water, item_dirt, item_grass

item_water = "mcl_core:water_source"
item_dirt = "mcl_core:dirt"
item_grass = "mcl_core:dirt_with_grass"
local function make_bamboo(pos, size)
	for y = 0, size - 1 do
		local p = {x = pos.x, y = pos.y + y, z = pos.z}
		if minetest.get_node(p).name ~= "air" then
			return
		end
		minetest.set_node(p, {name = "mcl_bamboo:bamboo"})
	end
end

minetest.register_on_generated(function(minp, maxp, seed)
	if maxp.y < 2 and minp.y > 0 then
		return
	end

	local c_grass = minetest.get_content_id(item_grass)
	local n_bamboo = minetest.get_perlin(8234, 3, 0.6, 100)

	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map(minp, maxp)
	local area = VoxelArea:new {MinEdge = emin, MaxEdge = emax}
	local data = vm:get_data()

	local rand = PseudoRandom(seed % 8000)
	for z = minp.z + 2, maxp.z - 2, 4 do
		for x = minp.x + 2, maxp.x - 2, 4 do
			local bamboo_amount = math.floor(n_bamboo:get_2d({x = x, y = z}) * 7 - 3)
			for i = 1, bamboo_amount do
				local p_pos = {
					x = rand:next(x - 2, x + 2),
					y = 0,
					z = rand:next(z - 2, z + 2)
				}

				local found = false
				local node = -1
				for y = 4, 0, -1 do
					p_pos.y = y
					node = data[area:index(p_pos.x, p_pos.y, p_pos.z)]
					if node == c_grass then
						found = true
						break
					end
				end

				if found and
						minetest.find_node_near(p_pos, 5, {"group:water", item_water}) then
					p_pos.y = p_pos.y + 1
					make_bamboo(p_pos, rand:next(4, 12))
				end
			end
		end
	end
end
)
