minetest.register_alias("mapgen_dandelion", "mcl_flowers:dandelion")
minetest.register_alias("mapgen_rose", "mcl_flowers:rose")

minetest.register_alias("mapgen_oxeye_daisy", "mcl_flowers:oxeye_daisy")

minetest.register_alias("mapgen_tulip_orange", "mcl_flowers:tulip_orange")
minetest.register_alias("mapgen_tulip_pink", "mcl_flowers:tulip_pink")
minetest.register_alias("mapgen_tulip_red", "mcl_flowers:tulip_red")
minetest.register_alias("mapgen_tulip_white", "mcl_flowers:tulip_white")

minetest.register_alias("mapgen_allium", "mcl_flowers:allium")

minetest.register_alias("mapgen_poppy", "mcl_flowers:poppy")

minetest.register_alias("mapgen_azure_bluet", "mcl_flowers:azure_bluet")

minetest.register_alias("mapgen_blue_orchid", "mcl_flowers:blue_orchid")

minetest.register_on_generated(function(minp, maxp, seed)
	if maxp.y >= 3 and minp.y <= 0 then
		-- Generate flowers
		local perlin1 = minetest.get_perlin(436, 3, 0.6, 100)
		-- Assume X and Z lengths are equal
		local divlen = 16
		local divs = (maxp.x-minp.x)/divlen+1;
		for divx=0,divs-1 do
		for divz=0,divs-1 do
			local x0 = minp.x + math.floor((divx+0)*divlen)
			local z0 = minp.z + math.floor((divz+0)*divlen)
			local x1 = minp.x + math.floor((divx+1)*divlen)
			local z1 = minp.z + math.floor((divz+1)*divlen)
			-- Determine flowers amount from perlin noise
			local grass_amount = math.floor(perlin1:get2d({x=x0, y=z0}) * 9)
			-- Find random positions for flowers based on this random
			local pr = PseudoRandom(seed+456)
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
						if nn == "mcl_core:dirt_with_grass" then
							--local flower_choice = pr:next(1, 11)
							local flower_choice = math.random(0, 10)
							local flower = "mcl_core:grass"
							if flower_choice == 1 then
								flower = "mcl_flowers:dandelion"
								minetest.set_node(p, {name=flower})
							elseif flower_choice == 2 then
								flower = "mcl_flowers:fern"
								minetest.set_node(p, {name=flower})
							elseif flower_choice == 3 then
								flower = "mcl_flowers:oxeye_daisy"
								minetest.set_node(p, {name=flower})
							elseif flower_choice == 4 then
								flower = "mcl_flowers:tulip_orange"
								minetest.set_node(p, {name=flower})
							elseif flower_choice == 5 then
								flower = "mcl_flowers:tulip_pink"
								minetest.set_node(p, {name=flower})
							elseif flower_choice == 6 then
								flower = "mcl_flowers:tulip_red"
								minetest.set_node(p, {name=flower})
							elseif flower_choice == 7 then
								flower = "mcl_flowers:tulip_white"
								minetest.set_node(p, {name=flower})
							elseif flower_choice == 8 then
								flower = "mcl_flowers:allium"
								minetest.set_node(p, {name=flower})
							elseif flower_choice == 9 then
								flower = "mcl_flowers:azure_bluet"
								minetest.set_node(p, {name=flower})
							elseif flower_choice == 10 then
								flower = "mcl_flowers:poppy"
								minetest.set_node(p, {name=flower})
							elseif flower_choice == 11 then
								flower = "mcl_flowers:blue_orchid"
								minetest.set_node(p, {name=flower})
							else
								flower = "mcl_core:grass"
								minetest.set_node(p, {name=flower})
							end
							
						end
					end
				end
				
			end
		end
		end
	end
end)
