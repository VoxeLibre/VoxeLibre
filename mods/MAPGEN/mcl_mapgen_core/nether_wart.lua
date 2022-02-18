local nether_wart_chance
if mcl_mapgen.v6 then
	nether_wart_chance = 85
else
	nether_wart_chance = 170
end

local y_min = mcl_mapgen.nether.min
local y_max = mcl_mapgen.nether.max
local place_on = {"group:soil_nether_wart"}

local block_size = mcl_mapgen.BS
local decrease_search_area = math.min(2, math.floor(block_size/2))
local search_area_size = math.max(block_size - 2 * decrease_search_area, math.max(1, math.ceil(nether_wart_chance^(1/3))))
nether_wart_chance = math.floor(nether_wart_chance * (search_area_size^3) / (block_size^3))
local nether_wart_chance_threshold = nether_wart_chance
local minetest_swap_node = minetest.swap_node

local wart_perlin
local noise_params = {
	offset = 0.4,
	scale = 0.4,
	spread = {x = block_size, y = block_size, z = block_size},
	seed = 238742,
	octaves = 1,
	persist = 0.5,
}

minetest.log("action", "Nether Wart block_size=" .. block_size .. ", search_area_size=" .. search_area_size .. ", per-area nether_wart_chance=" .. nether_wart_chance)

local minetest_find_nodes_in_area_under_air = minetest.find_nodes_in_area_under_air
local minetest_get_perlin = minetest.get_perlin

mcl_mapgen.register_mapgen_block(function(minp, maxp, seed)
	local minp = minp
	local y1 = minp.y
	if y1 > y_max then return end

	local maxp = maxp
	local y2 = maxp.y
	if y2 < y_min then return end

	local p1 = {x = minp.x + decrease_search_area, y = y1 + decrease_search_area, z = minp.z + decrease_search_area}
	local p2 = {x = maxp.x - decrease_search_area, y = y2 - decrease_search_area, z = maxp.z - decrease_search_area}

	local pos_list = minetest_find_nodes_in_area_under_air(p1, p2, place_on)
	local pr = PseudoRandom(seed)
	wart_perlin = wart_perlin or minetest_get_perlin(noise_params)

	for i = 1, #pos_list do
		local pos = pos_list[i]
		if pr:next(1, nether_wart_chance) + wart_perlin:get_3d(pos) >= nether_wart_chance_threshold then
			pos.y = pos.y + 1
			minetest.swap_node(pos, {name = "mcl_nether:nether_wart"})
		end
	end
end, 999999999)
