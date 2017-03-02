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

		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end

		if minetest.is_protected(pointed_thing.above, pn) then
			return itemstack
		end
		local change = false
		local on_water = false
		local pos = pointed_thing.above
		local nn = minetest.get_node(pointed_thing.above).name
		if minetest.get_item_group(nn, "water") ~= 0 then
			on_water = true
		end
		for i=-1,1 do
			local p = {x=pos.x+i, y=pos.y, z=pos.z}
			local n = minetest.get_node(p)
			if minetest.get_item_group(n.name, "water") ~= 0 then
				on_water = true
			end
		end
		for i=-1,1 do
			local p = {x=pos.x, y=pos.y+i, z=pos.z}
			local n = minetest.get_node(p)
			if minetest.get_item_group(n.name, "water") ~= 0 then
				on_water = true
			end
		end
		for i=-1,1 do
			local p = {x=pos.x, y=pos.y, z=pos.z+i}
			local n = minetest.get_node(p)
			if minetest.get_item_group(n.name, "water") ~= 0 then
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
						if minetest.get_item_group(n.name, "water") ~= 0 then
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

