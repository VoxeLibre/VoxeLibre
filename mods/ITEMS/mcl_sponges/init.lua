minetest.register_node("mcl_sponges:sponge", {
	description = "Sponge",
	drawtype = "normal",
	is_ground_content = false,
	tiles = {"mcl_sponges_sponge.png"},
	paramtype = 'light',
	walkable = true,
	pointable = true,
	diggable = true,
	buildable_to = false,
	stack_max = 64,
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	groups = {handy=1, building_block=1},
	   	on_place = function(itemstack, placer, pointed_thing)
		local pn = placer:get_player_name()
		if pointed_thing.type ~= "node" then
			return itemstack
		end
		if minetest.is_protected(pointed_thing.above, pn) then
			return itemstack
		end
			local change = false
			local on_water = false
			local pos = pointed_thing.above
		-- verifier si il est dans l'eau ou a cotée
		if string.find(minetest.get_node(pointed_thing.above).name, "water_source") 
		or  string.find(minetest.get_node(pointed_thing.above).name, "water_flowing") then
			on_water = true
		end
		for i=-1,1 do
			local p = {x=pos.x+i, y=pos.y, z=pos.z}
			local n = minetest.get_node(p)
			-- On verifie si il y a de l'eau
			if (n.name=="mcl_core:water_flowing") or (n.name == "mcl_core:water_source") then
				on_water = true
			end
		end
		for i=-1,1 do
			local p = {x=pos.x, y=pos.y+i, z=pos.z}
			local n = minetest.get_node(p)
			-- On verifie si il y a de l'eau
			if (n.name=="mcl_core:water_flowing") or (n.name == "mcl_core:water_source") then
				on_water = true
			end
		end
		for i=-1,1 do
			local p = {x=pos.x, y=pos.y, z=pos.z+i}
			local n = minetest.get_node(p)
			-- On verifie si il y a de l'eau
			if (n.name=="mcl_core:water_flowing") or (n.name == "mcl_core:water_source") then
				on_water = true
			end
		end
			local p, n
			if on_water == true then
				for i=-3,3 do
					for j=-3,3 do
						for k=-3,3 do
							p = {x=pos.x+i, y=pos.y+j, z=pos.z+k}
							n = minetest.get_node(p)
							-- On Supprime l'eau
							if (n.name=="mcl_core:water_flowing") or (n.name == "mcl_core:water_source")then
								minetest.add_node(p, {name="air"})
								change = true
							end
						end
					end
				end
			end
			p = {x=pos.x, y=pos.y, z=pos.z}
			n = minetest.get_node(p)
			if change == true then
				minetest.add_node(pointed_thing.above, {name = "mcl_sponges:sponge_wet"})	
			else
				minetest.add_node(pointed_thing.above, {name = "mcl_sponges:sponge"})	
			end
		return itemstack
		
	end,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 0.6,
})

minetest.register_node("mcl_sponges:sponge_wet", {
	description = "Wet Sponge",
	drawtype = "normal",
	is_ground_content = false,
	tiles = {"mcl_sponges_sponge_wet.png"},
	paramtype = 'light',
	walkable = true,
	pointable = true,
	diggable = true,
	buildable_to = false,
	stack_max = 64,
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	groups = {handy=1, building_block=1},
	_mcl_blast_resistance = 3,
	_mcl_hardness = 0.6,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_sponges:sponge",
	recipe = "mcl_sponges:sponge_wet",
	cooktime = 10,
})

