-- mods/default/mapgen.lua

--
-- Aliases for map generator outputs
--

minetest.register_alias("mapgen_air", "air")
minetest.register_alias("mapgen_stone", "mcl_core:stone")
minetest.register_alias("mapgen_tree", "mcl_core:tree")
minetest.register_alias("mapgen_leaves", "mcl_core:leaves")
minetest.register_alias("mapgen_jungletree", "mcl_core:jungletree")
minetest.register_alias("mapgen_jungleleaves", "mcl_core:jungleleaves")
minetest.register_alias("mapgen_pine_tree", "mcl_core:darktree")
minetest.register_alias("mapgen_pine_needles", "mcl_core:darkleaves")

minetest.register_alias("mapgen_apple", "mcl_core:leaves")
minetest.register_alias("mapgen_water_source", "mcl_core:water_source")
minetest.register_alias("mapgen_dirt", "mcl_core:dirt")
minetest.register_alias("mapgen_dirt_with_grass", "mcl_core:dirt_with_grass")
minetest.register_alias("mapgen_dirt_with_snow", "mcl_core:dirt_with_snow")
minetest.register_alias("mapgen_sand", "mcl_core:sand")
minetest.register_alias("mapgen_gravel", "mcl_core:gravel")
minetest.register_alias("mapgen_clay", "mcl_core:clay")
minetest.register_alias("mapgen_lava_source", "mcl_core:lava_source")
minetest.register_alias("mapgen_cobble", "mcl_core:cobble")
minetest.register_alias("mapgen_mossycobble", "mcl_core:mossycobble")
minetest.register_alias("mapgen_junglegrass", "mcl_core:junglegrass")
minetest.register_alias("mapgen_stone_with_coal", "mcl_core:stone_with_coal")
minetest.register_alias("mapgen_stone_with_iron", "mcl_core:stone_with_iron")
minetest.register_alias("mapgen_desert_sand", "mcl_core:sand")
minetest.register_alias("mapgen_desert_stone", "mcl_core:sandstone")
minetest.register_alias("mapgen_sandstone", "mcl_core:sandstone")
minetest.register_alias("mapgen_river_water_source", "mcl_core:water_source")
minetest.register_alias("mapgen_snow", "mcl_core:snow")
minetest.register_alias("mapgen_snowblock", "mcl_core:snowblock")
minetest.register_alias("mapgen_ice", "mcl_core:ice")

minetest.register_alias("mapgen_stair_cobble", "stairs:stair_cobble")
minetest.register_alias("mapgen_sandstonebrick", "mcl_core:sandstonesmooth")
minetest.register_alias("mapgen_stair_sandstonebrick", "stairs:stair_sandstone")

--
-- Ore generation
--

-- Gravel
minetest.register_ore({
	ore_type       = "blob",
	ore            = "mcl_core:gravel",
	wherein        = {"mcl_core:stone"},
	clust_scarcity = 14*14*14,
	clust_num_ores = 33,
	clust_size     = 5,
	y_min          = -90,
	y_max          = 90,
})

--
-- Coal
--
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:stone_with_coal",
	wherein        = "mcl_core:stone",
	clust_scarcity = 500,
	clust_num_ores = 5,
	clust_size     = 3,
	y_min          = 13,
	y_max          = 31000,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:stone_with_coal",
	wherein        = "mcl_core:stone",
	clust_scarcity = 500,
	clust_num_ores = 8,
	clust_size     = 3,
	y_min          = 12,
	y_max          = -12,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:stone_with_coal",
	wherein        = "mcl_core:stone",
	clust_scarcity = 1000,
	clust_num_ores = 6,
	clust_size     = 3,
	y_min          = -11,
	y_max          = 64,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:stone_with_coal",
	wherein        = "mcl_core:stone",
	clust_scarcity = 5000,
	clust_num_ores = 4,
	clust_size     = 2,
	y_min          = 65,
	y_max          = 67,
})

--
-- Iron
--
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:stone_with_iron",
	wherein        = "mcl_core:stone",
	clust_scarcity = 830,
	clust_num_ores = 5,
	clust_size     = 3,
	y_min          = -127,
	y_max          = -10,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:stone_with_iron",
	wherein        = "mcl_core:stone",
	clust_scarcity = 1660,
	clust_num_ores = 3,
	clust_size     = 2,
	y_min          = -9,
	y_max          = 1,
})

--
-- Gold
--
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:stone_with_gold",
	wherein        = "mcl_core:stone",
	clust_scarcity = 5000,
	clust_num_ores = 5,
	clust_size     = 3,
	y_min          = -59,
	y_max          = -35,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:stone_with_gold",
	wherein        = "mcl_core:stone",
	clust_scarcity = 10000,
	clust_num_ores = 3,
	clust_size     = 2,
	y_min          = -35,
	y_max          = -33,
})

--
-- Diamond
--
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:stone_with_diamond",
	wherein        = "mcl_core:stone",
	clust_scarcity = 10000,
	clust_num_ores = 4,
	clust_size     = 3,
	y_min          = -59,
	y_max          = -48,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:stone_with_diamond",
	wherein        = "mcl_core:stone",
	clust_scarcity = 5000,
	clust_num_ores = 2,
	clust_size     = 2,
	y_min          = -59,
	y_max          = -48,
})
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:stone_with_diamond",
	wherein        = "mcl_core:stone",
	clust_scarcity = 10000,
	clust_num_ores = 8,
	clust_size     = 3,
	y_min          = -55,
	y_max          = -52,
})

--
-- Redstone
--

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:stone_with_redstone",
	wherein        = "mcl_core:stone",
	clust_scarcity = 10000,
	clust_num_ores = 5,
	clust_size     = 3,
	y_min          = -59,
	y_max          = -48,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:stone_with_redstone",
	wherein        = "mcl_core:stone",
	clust_scarcity = 10000,
	clust_num_ores = 10,
	clust_size     = 4,
	y_min          = -59,
	y_max          = -48,
})

--
-- Emerald
--

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:stone_with_emerald",
	wherein        = "mcl_core:stone",
	clust_scarcity = 10000,
	clust_num_ores = 1,
	clust_size     = 2,
	y_min          = -59,
	y_max          = -35,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:stone_with_emerald",
	wherein        = "mcl_core:stone",
	clust_scarcity = 50000,
	clust_num_ores = 3,
	clust_size     = 2,
	y_min          = -59,
	y_max          = -35,
})

--
-- Lapis Lazuli
--

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:stone_with_lapis",
	wherein        = "mcl_core:stone",
	clust_scarcity = 10000,
	clust_num_ores = 7,
	clust_size     = 4,
	y_min          = -50,
	y_max          = -46,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:stone_with_lapis",
	wherein        = "mcl_core:stone",
	clust_scarcity = 10000,
	clust_num_ores = 5,
	clust_size     = 4,
	y_min          = -59,
	y_max          = -50,
})



--
-- Glowstone
--
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:glowstone",
	wherein        = "mcl_core:stone",
	clust_scarcity = 50000,
	clust_num_ores = 10,
	clust_size     = 5,
	y_min          = -59,
	y_max          = -0,
})

function mcl_core.generate_ore(name, wherein, minp, maxp, seed, chunks_per_volume, chunk_size, ore_per_chunk, y_min, y_max)
	minetest.log('action', "WARNING: mcl_core.generate_ore is deprecated")

	if maxp.y < y_min or minp.y > y_max then
		return
	end
	y_min = math.max(minp.y, y_min)
	y_max = math.min(maxp.y, y_max)
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
		if y0 >= y_min and y0 <= y_max then
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
					if minetest.get_node(p2).name == wherein then
						minetest.set_node(p2, {name=name})
					end
				end
			end
			end
			end
		end
	end
	--print("generate_ore done")
end

function mcl_core.make_reeds(pos, size)
	for y=0,size-1 do
		local p = {x=pos.x, y=pos.y+y, z=pos.z}
		local nn = minetest.get_node(p).name
		if minetest.registered_nodes[nn] and
			minetest.registered_nodes[nn].buildable_to then
			minetest.set_node(p, {name="mcl_core:reeds"})
		else
			return
		end
	end
end

function mcl_core.make_cactus(pos, size)
	for y=0,size-1 do
		local p = {x=pos.x, y=pos.y+y, z=pos.z}
		local nn = minetest.get_node(p).name
		if minetest.registered_nodes[nn] and
			minetest.registered_nodes[nn].buildable_to then
			minetest.set_node(p, {name="mcl_core:cactus"})
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
			if minetest.get_node({x=cx,y=1,z=cz}).name == "mcl_core:water_source" and
					minetest.get_node({x=cx,y=0,z=cz}).name == "mcl_core:sand" then
				local is_shallow = true
				local num_water_around = 0
				if minetest.get_node({x=cx-divlen*2,y=1,z=cz+0}).name == "mcl_core:water_source" then
					num_water_around = num_water_around + 1 end
				if minetest.get_node({x=cx+divlen*2,y=1,z=cz+0}).name == "mcl_core:water_source" then
					num_water_around = num_water_around + 1 end
				if minetest.get_node({x=cx+0,y=1,z=cz-divlen*2}).name == "mcl_core:water_source" then
					num_water_around = num_water_around + 1 end
				if minetest.get_node({x=cx+0,y=1,z=cz+divlen*2}).name == "mcl_core:water_source" then
					num_water_around = num_water_around + 1 end
				if num_water_around >= 2 then
					is_shallow = false
				end	
				if is_shallow then
					for x1=-divlen,divlen do
					for z1=-divlen,divlen do
						if minetest.get_node({x=cx+x1,y=0,z=cz+z1}).name == "mcl_core:sand" or minetest.get_node({x=cx+x1,y=0,z=cz+z1}).name == "mcl_core:sandstone" then
							minetest.set_node({x=cx+x1,y=0,z=cz+z1}, {name="mcl_core:clay"})
						end
					end
					end
				end
			end
		end
		end
		-- Generate reeds
		local perlin1 = minetest.get_perlin(354, 3, 0.7, 100)
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
				if minetest.get_node({x=x,y=1,z=z}).name == "mcl_core:dirt_with_grass" and
						minetest.find_node_near({x=x,y=1,z=z}, 1, "mcl_core:water_source") then
					mcl_core.make_reeds({x=x,y=2,z=z}, pr:next(2, 4))
				end
				local p = {x=x,y=1,z=z}
				if minetest.get_node(p).name == "mcl_core:sand" then
					if math.random(0,1000) == 1 then -- 0,12000
						-- TODO: Re-enable random_struct
						--random_struct.call_struct(p,2)
					end
				end

			end
		end
		end
		-- Generate cactuses
		local perlin1 = minetest.get_perlin(230, 3, 0.6, 100)
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
					if minetest.get_node({x=x,y=y,z=z}).name ~= "air" then
						ground_y = y
						break
					end
				end
				-- If sand, make cactus
				if ground_y and minetest.get_node({x=x,y=ground_y,z=z}).name == "mcl_core:sand" then
					mcl_core.make_cactus({x=x,y=ground_y+1,z=z}, pr:next(3, 4))
				end
			end
		end
		end
		-- Generate grass
		local perlin1 = minetest.get_perlin(329, 3, 0.6, 100)
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
					if minetest.get_node({x=x,y=y,z=z}).name ~= "air" then
						ground_y = y
						break
					end
				end
				
				if ground_y then
					local p = {x=x,y=ground_y+1,z=z}
					local nn = minetest.get_node(p).name
					-- Check if the node can be replaced
					if minetest.registered_nodes[nn] and
						minetest.registered_nodes[nn].buildable_to then
						nn = minetest.get_node({x=x,y=ground_y,z=z}).name
						-- If sand, add dry shrub
						if nn == "mcl_core:sand" then
							minetest.set_node(p,{name="mcl_core:dry_shrub"})
							
						-- If dirt with grass, add grass
						elseif nn == "mcl_core:dirt_with_grass" then
							minetest.set_node(p,{name="mcl_core:grass"})
							if math.random(0,12000) == 1 then 
								-- TODO: Re-enable random_struct
								--random_struct.call_struct(p,1)
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
		y_min          = min,
		y_max          = max,
	})
end
replace("air", "mcl_core:bedrock", -90, -80)
replace("air", "mcl_core:lava_source", -80, -70)
replace("mcl_core:stone", "mcl_core:bedrock", -90, -80)
replace("mcl_core:gravel", "mcl_core:bedrock", -90, -80)
replace("mcl_core:dirt", "mcl_core:bedrock", -90, -80)
replace("mcl_core:sand", "mcl_core:bedrock", -90, -80)
replace("mcl_core:cobble", "mcl_core:bedrock", -90, -80)
replace("mcl_core:mossycobble", "mcl_core:bedrock", -90, -80)
replace("stairs:stair_cobble", "mcl_core:bedrock", -90, -80)
replace("mcl_core:lava_source", "mcl_core:bedrock", -90, -80)
replace("mcl_core:lava_flowing", "mcl_core:bedrock", -90, -80)
replace("mcl_core:water_source", "mcl_core:bedrock", -90, -80)
replace("mcl_core:water_flowing", "mcl_core:bedrock", -90, -80)

local function bedrock(old)
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:bedrock",
		wherein        = old,
		clust_scarcity = 5,
		clust_num_ores = 3,
		clust_size     = 2,
		y_min          = -64,
		y_max          = -60,
	})
end
bedrock("air")
bedrock("mcl_core:stone")
bedrock("mcl_core:gravel")
bedrock("mcl_core:dirt")
bedrock("mcl_core:sand")
bedrock("mcl_core:cobble")
bedrock("mcl_core:mossycobble")
bedrock("stairs:stair_cobble")
bedrock("mcl_core:lava_source")
bedrock("mcl_core:lava_flowing")
bedrock("mcl_core:water_source")
bedrock("mcl_core:water_flowing")

