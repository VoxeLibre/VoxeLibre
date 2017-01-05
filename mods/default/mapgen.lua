-- mods/default/mapgen.lua

--
-- Aliases for map generator outputs
--

minetest.register_alias("mapgen_air", "air")
minetest.register_alias("mapgen_stone", "default:stone")
minetest.register_alias("mapgen_tree", "default:tree")
minetest.register_alias("mapgen_leaves", "default:leaves")
minetest.register_alias("mapgen_jungletree", "default:jungletree")
minetest.register_alias("mapgen_jungleleaves", "default:jungleleaves")
minetest.register_alias("mapgen_apple", "default:leaves")
minetest.register_alias("mapgen_water_source", "default:water_source")
minetest.register_alias("mapgen_dirt", "default:dirt")
minetest.register_alias("mapgen_sand", "default:sand")
minetest.register_alias("mapgen_gravel", "default:gravel")
minetest.register_alias("mapgen_clay", "default:clay")
minetest.register_alias("mapgen_lava_source", "default:lava_source")
minetest.register_alias("mapgen_cobble", "default:cobble")
minetest.register_alias("mapgen_mossycobble", "default:mossycobble")
minetest.register_alias("mapgen_dirt_with_grass", "default:dirt_with_grass")
minetest.register_alias("mapgen_junglegrass", "default:junglegrass")
minetest.register_alias("mapgen_stone_with_coal", "default:stone_with_coal")
minetest.register_alias("mapgen_stone_with_iron", "default:stone_with_iron")
minetest.register_alias("mapgen_desert_sand", "default:sand")
minetest.register_alias("mapgen_desert_stone", "default:sandstone")
minetest.register_alias("mapgen_river_water_source", "default:water_source")
--
-- Ore generation
--

-- Gravel
minetest.register_ore({
	ore_type       = "blob",
	ore            = "default:gravel",
	wherein        = {"default:stone"},
	clust_scarcity = 14*14*14,
	clust_num_ores = 33,
	clust_size     = 5,
	height_min     = -90,
	height_max     = 90,
})

--
-- Coal
--
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:stone_with_coal",
	wherein        = "default:stone",
	clust_scarcity = 500,
	clust_num_ores = 5,
	clust_size     = 3,
	height_min     = 13,
	height_max     = 31000,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:stone_with_coal",
	wherein        = "default:stone",
	clust_scarcity = 500,
	clust_num_ores = 8,
	clust_size     = 3,
	height_min     = 12,
	height_max     = -12,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:stone_with_coal",
	wherein        = "default:stone",
	clust_scarcity = 1000,
	clust_num_ores = 6,
	clust_size     = 3,
	height_min     = -11,
	height_max     = 64,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:stone_with_coal",
	wherein        = "default:stone",
	clust_scarcity = 5000,
	clust_num_ores = 4,
	clust_size     = 2,
	height_min     = 65,
	height_max     = 67,
})

--
-- Iron
--
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:stone_with_iron",
	wherein        = "default:stone",
	clust_scarcity = 830,
	clust_num_ores = 5,
	clust_size     = 3,
	height_min     = -127,
	height_max     = -10,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:stone_with_iron",
	wherein        = "default:stone",
	clust_scarcity = 1660,
	clust_num_ores = 3,
	clust_size     = 2,
	height_min     = -9,
	height_max     = 1,
})

--
-- Gold
--
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:stone_with_gold",
	wherein        = "default:stone",
	clust_scarcity = 5000,
	clust_num_ores = 5,
	clust_size     = 3,
	height_min     = -59,
	height_max     = -35,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:stone_with_gold",
	wherein        = "default:stone",
	clust_scarcity = 10000,
	clust_num_ores = 3,
	clust_size     = 2,
	height_min     = -35,
	height_max     = -33,
})

--
-- Diamond
--
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:stone_with_diamond",
	wherein        = "default:stone",
	clust_scarcity = 10000,
	clust_num_ores = 4,
	clust_size     = 3,
	height_min     = -59,
	height_max     = -48,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:stone_with_diamond",
	wherein        = "default:stone",
	clust_scarcity = 5000,
	clust_num_ores = 2,
	clust_size     = 2,
	height_min     = -59,
	height_max     = -48,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:stone_with_diamond",
	wherein        = "default:stone",
	clust_scarcity = 10000,
	clust_num_ores = 8,
	clust_size     = 3,
	height_min     = -55,
	height_max     = -52,
})

--
-- Redstone
--

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:stone_with_redstone",
	wherein        = "default:stone",
	clust_scarcity = 10000,
	clust_num_ores = 5,
	clust_size     = 3,
	height_min     = -59,
	height_max     = -48,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:stone_with_redstone",
	wherein        = "default:stone",
	clust_scarcity = 10000,
	clust_num_ores = 10,
	clust_size     = 4,
	height_min     = -59,
	height_max     = -48,
})

--
-- Emerald
--

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:stone_with_emerald",
	wherein        = "default:stone",
	clust_scarcity = 10000,
	clust_num_ores = 1,
	clust_size     = 2,
	height_min     = -59,
	height_max     = -35,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:stone_with_emerald",
	wherein        = "default:stone",
	clust_scarcity = 50000,
	clust_num_ores = 3,
	clust_size     = 2,
	height_min     = -59,
	height_max     = -35,
})

--
-- Lapis Lazuli
--

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:stone_with_lapis",
	wherein        = "default:stone",
	clust_scarcity = 10000,
	clust_num_ores = 7,
	clust_size     = 4,
	height_min     = -50,
	height_max     = -46,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:stone_with_lapis",
	wherein        = "default:stone",
	clust_scarcity = 10000,
	clust_num_ores = 5,
	clust_size     = 4,
	height_min     = -59,
	height_max     = -50,
})



--
-- Glowstone
--
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "default:glowstone",
	wherein        = "default:stone",
	clust_scarcity = 50000,
	clust_num_ores = 10,
	clust_size     = 5,
	height_min     = -59,
	height_max     = -0,
})

function default.generate_ore(name, wherein, minp, maxp, seed, chunks_per_volume, chunk_size, ore_per_chunk, height_min, height_max)
	minetest.log('action', "WARNING: default.generate_ore is deprecated")

	if maxp.y < height_min or minp.y > height_max then
		return
	end
	local y_min = math.max(minp.y, height_min)
	local y_max = math.min(maxp.y, height_max)
	if chunk_size >= y_max - y_min + 1 then
		return
	end
	local volume = (maxp.x-minp.x+1)*(y_max-y_min+1)*(maxp.z-minp.z+1)
	local pr = PseudoRandom(seed)
	local num_chunks = math.floor(chunks_per_volume * volume)
	local inverse_chance = math.floor(chunk_size*chunk_size*chunk_size / ore_per_chunk)
	--print("generate_ore num_chunks: "..dump(num_chunks))
	for i=1,num_chunks do
		local y0 = pr:next(y_min, y_max-chunk_size+1)
		if y0 >= height_min and y0 <= height_max then
			local x0 = pr:next(minp.x, maxp.x-chunk_size+1)
			local z0 = pr:next(minp.z, maxp.z-chunk_size+1)
			local p0 = {x=x0, y=y0, z=z0}
			for x1=0,chunk_size-1 do
			for y1=0,chunk_size-1 do
			for z1=0,chunk_size-1 do
				if pr:next(1,inverse_chance) == 1 then
					local x2 = x0+x1
					local y2 = y0+y1
					local z2 = z0+z1
					local p2 = {x=x2, y=y2, z=z2}
					if minetest.env:get_node(p2).name == wherein then
						minetest.env:set_node(p2, {name=name})
					end
				end
			end
			end
			end
		end
	end
	--print("generate_ore done")
end

function default.make_reeds(pos, size)
	for y=0,size-1 do
		local p = {x=pos.x, y=pos.y+y, z=pos.z}
		local nn = minetest.env:get_node(p).name
		if minetest.registered_nodes[nn] and
			minetest.registered_nodes[nn].buildable_to then
			minetest.env:set_node(p, {name="default:reeds"})
		else
			return
		end
	end
end

function default.make_cactus(pos, size)
	for y=0,size-1 do
		local p = {x=pos.x, y=pos.y+y, z=pos.z}
		local nn = minetest.env:get_node(p).name
		if minetest.registered_nodes[nn] and
			minetest.registered_nodes[nn].buildable_to then
			minetest.env:set_node(p, {name="default:cactus"})
		else
			return
		end
	end
end


minetest.register_on_generated(function(minp, maxp, seed)
	if maxp.y >= 2 and minp.y <= 0 then
		-- Generate clay
		-- Assume X and Z lengths are equal
		local divlen = 4
		local divs = (maxp.x-minp.x)/divlen+1;
		for divx=0+1,divs-1-1 do
		for divz=0+1,divs-1-1 do
			local cx = minp.x + math.floor((divx+0.5)*divlen)
			local cz = minp.z + math.floor((divz+0.5)*divlen)
			if minetest.env:get_node({x=cx,y=1,z=cz}).name == "default:water_source" and
					minetest.env:get_node({x=cx,y=0,z=cz}).name == "default:sand" then
				local is_shallow = true
				local num_water_around = 0
				if minetest.env:get_node({x=cx-divlen*2,y=1,z=cz+0}).name == "default:water_source" then
					num_water_around = num_water_around + 1 end
				if minetest.env:get_node({x=cx+divlen*2,y=1,z=cz+0}).name == "default:water_source" then
					num_water_around = num_water_around + 1 end
				if minetest.env:get_node({x=cx+0,y=1,z=cz-divlen*2}).name == "default:water_source" then
					num_water_around = num_water_around + 1 end
				if minetest.env:get_node({x=cx+0,y=1,z=cz+divlen*2}).name == "default:water_source" then
					num_water_around = num_water_around + 1 end
				if num_water_around >= 2 then
					is_shallow = false
				end	
				if is_shallow then
					for x1=-divlen,divlen do
					for z1=-divlen,divlen do
						if minetest.env:get_node({x=cx+x1,y=0,z=cz+z1}).name == "default:sand" or minetest.env:get_node({x=cx+x1,y=0,z=cz+z1}).name == "default:sandstone" then
							minetest.env:set_node({x=cx+x1,y=0,z=cz+z1}, {name="default:clay"})
						end
					end
					end
				end
			end
		end
		end
		-- Generate reeds
		local perlin1 = minetest.env:get_perlin(354, 3, 0.7, 100)
		-- Assume X and Z lengths are equal
		local divlen = 8
		local divs = (maxp.x-minp.x)/divlen+1;
		for divx=0,divs-1 do
		for divz=0,divs-1 do
			local x0 = minp.x + math.floor((divx+0)*divlen)
			local z0 = minp.z + math.floor((divz+0)*divlen)
			local x1 = minp.x + math.floor((divx+1)*divlen)
			local z1 = minp.z + math.floor((divz+1)*divlen)
			-- Determine reeds amount from perlin noise
			local reeds_amount = math.floor(perlin1:get2d({x=x0, y=z0}) * 45 - 20)
			-- Find random positions for reeds based on this random
			local pr = PseudoRandom(seed+1)
			for i=0,reeds_amount do
				local x = pr:next(x0, x1)
				local z = pr:next(z0, z1)
				if minetest.env:get_node({x=x,y=1,z=z}).name == "default:dirt_with_grass" and
						minetest.env:find_node_near({x=x,y=1,z=z}, 1, "default:water_source") then
					default.make_reeds({x=x,y=2,z=z}, pr:next(2, 4))
				end
				local p = {x=x,y=1,z=z}
				if minetest.env:get_node(p).name == "default:sand" then
					if math.random(0,1000) == 1 then -- 0,12000
						random_struct.call_struct(p,2)
					end
				end

			end
		end
		end
		-- Generate cactuses
		local perlin1 = minetest.env:get_perlin(230, 3, 0.6, 100)
		-- Assume X and Z lengths are equal
		local divlen = 16
		local divs = (maxp.x-minp.x)/divlen+1;
		for divx=0,divs-1 do
		for divz=0,divs-1 do
			local x0 = minp.x + math.floor((divx+0)*divlen)
			local z0 = minp.z + math.floor((divz+0)*divlen)
			local x1 = minp.x + math.floor((divx+1)*divlen)
			local z1 = minp.z + math.floor((divz+1)*divlen)
			-- Determine cactus amount from perlin noise
			local cactus_amount = math.floor(perlin1:get2d({x=x0, y=z0}) * 6 - 3)
			-- Find random positions for cactus based on this random
			local pr = PseudoRandom(seed+1)
			for i=0,cactus_amount do
				local x = pr:next(x0, x1)
				local z = pr:next(z0, z1)
				-- Find ground level (0...15)
				local ground_y = nil
				for y=30,0,-1 do
					if minetest.env:get_node({x=x,y=y,z=z}).name ~= "air" then
						ground_y = y
						break
					end
				end
				-- If desert sand, make cactus
				if ground_y and minetest.env:get_node({x=x,y=ground_y,z=z}).name == "default:desert_sand" then
					default.make_cactus({x=x,y=ground_y+1,z=z}, pr:next(3, 4))
				end
			end
		end
		end
		-- Generate grass
		local perlin1 = minetest.env:get_perlin(329, 3, 0.6, 100)
		-- Assume X and Z lengths are equal
		local divlen = 5
		local divs = (maxp.x-minp.x)/divlen+1;
		for divx=0,divs-1 do
		for divz=0,divs-1 do
			local x0 = minp.x + math.floor((divx+0)*divlen)
			local z0 = minp.z + math.floor((divz+0)*divlen)
			local x1 = minp.x + math.floor((divx+1)*divlen)
			local z1 = minp.z + math.floor((divz+1)*divlen)
			-- Determine grass amount from perlin noise
			local grass_amount = math.floor(perlin1:get2d({x=x0, y=z0}) * 9)
			-- Find random positions for grass based on this random
			local pr = PseudoRandom(seed+1)
			for i=0,grass_amount do
				local x = pr:next(x0, x1)
				local z = pr:next(z0, z1)
				-- Find ground level (0...15)
				local ground_y = nil
				for y=30,0,-1 do
					if minetest.env:get_node({x=x,y=y,z=z}).name ~= "air" then
						ground_y = y
						break
					end
				end
				
				if ground_y then
					local p = {x=x,y=ground_y+1,z=z}
					local nn = minetest.env:get_node(p).name
					-- Check if the node can be replaced
					if minetest.registered_nodes[nn] and
						minetest.registered_nodes[nn].buildable_to then
						nn = minetest.env:get_node({x=x,y=ground_y,z=z}).name
						-- If desert sand, add dry shrub
						if nn == "default:desert_sand" then
							minetest.env:set_node(p,{name="default:dry_shrub"})
							
						-- If dirt with grass, add grass
						elseif nn == "default:dirt_with_grass" then
							minetest.env:set_node(p,{name="default:grass"})
							if math.random(0,12000) == 1 then 
								random_struct.call_struct(p,1)
							end
						end
					end
				end
				
			end
		end
		end
	end

	-- Generate nyan cats
	--generate_nyancats(seed, minp, maxp)
end)

local function replace(old, new, min, max)
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = new,
		wherein        = old,
		clust_scarcity = 1,
		clust_num_ores = 1,
		clust_size     = 1,
		height_min     = min,
		height_max     = max,
	})
end
replace("air", "default:bedrock", -90, -80)
replace("air", "default:lava_source", -80, -70)
replace("default:stone", "default:bedrock", -90, -80)
replace("default:gravel", "default:bedrock", -90, -80)
replace("default:dirt", "default:bedrock", -90, -80)
replace("default:sand", "default:bedrock", -90, -80)
replace("default:cobble", "default:bedrock", -90, -80)
replace("default:mossycobble", "default:bedrock", -90, -80)
replace("stairs:stair_cobble", "default:bedrock", -90, -80)
replace("default:lava_source", "default:bedrock", -90, -80)
replace("default:lava_flowing", "default:bedrock", -90, -80)
replace("default:water_source", "default:bedrock", -90, -80)
replace("default:water_flowing", "default:bedrock", -90, -80)

local function bedrock(old)
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "default:bedrock",
		wherein        = old,
		clust_scarcity = 5,
		clust_num_ores = 3,
		clust_size     = 2,
		height_min     = -64,
		height_max     = -60,
	})
end
bedrock("air")
bedrock("default:stone")
bedrock("default:gravel")
bedrock("default:dirt")
bedrock("default:sand")
bedrock("default:cobble")
bedrock("default:mossycobble")
bedrock("stairs:stair_cobble")
bedrock("default:lava_source")
bedrock("default:lava_flowing")
bedrock("default:water_source")
bedrock("default:water_flowing")

