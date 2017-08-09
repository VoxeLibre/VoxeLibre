local absorb = function(pos)
	local change = false
	local p, n
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
	return change
end

minetest.register_node("mcl_sponges:sponge", {
	description = "Sponge",
	_doc_items_longdesc = "Sponges are blocks which remove water around them when they are placed or come in contact with water, turning it into a wet sponge.",
	drawtype = "normal",
	is_ground_content = false,
	tiles = {"mcl_sponges_sponge.png"},
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

		local pos = pointed_thing.above
		local on_water = false
		if minetest.get_item_group(minetest.get_node(pos).name, "water") ~= 0 then
			on_water = true
		end
		local water_found = minetest.find_node_near(pos, 1, "group:water")
		if water_found ~= nil then
			on_water = true
		end
		if on_water then
			-- Absorb water
			-- FIXME: pos is not always the right placement position because of pointed_thing
			if absorb(pos) then
				minetest.item_place_node(ItemStack("mcl_sponges:sponge_wet"), placer, pointed_thing)
				if not minetest.settings:get_bool("creative_mode") then
					itemstack:take_item()
				end
				return itemstack
			end
		end
		return minetest.item_place_node(itemstack, placer, pointed_thing)
	end,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 0.6,
})

minetest.register_node("mcl_sponges:sponge_wet", {
	description = "Wet Sponge",
	_doc_items_longdesc = "Wet sponges can be dried in the furnace to turn it into (dry) sponge. When there's an empty bucket in the fuel slot of a furnace, water will pour into the bucket.",
	drawtype = "normal",
	is_ground_content = false,
	tiles = {"mcl_sponges_sponge_wet.png"},
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

minetest.register_abm({
	label = "Sponge water absorbtion",
	nodenames = { "mcl_sponges:sponge" },
	neighbors = { "group:water" },
	interval = 1,
	chance = 1,
	action = function(pos)
		if absorb(pos) then
			minetest.add_node(pos, {name = "mcl_sponges:sponge_wet"})
		end
	end,
})
