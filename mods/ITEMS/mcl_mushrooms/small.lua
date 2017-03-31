local on_place = function(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then
		-- no interaction possible with entities
		return itemstack
	end

	-- Call on_rightclick if the pointed node defines it
	local node = minetest.get_node(pointed_thing.under)
	if placer and not placer:get_player_control().sneak then
		if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
			return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
		end
	end

	local a = pointed_thing.above
	local u = pointed_thing.under
	local node_above = minetest.get_node(a)
	local node_under = minetest.get_node(u)
	local def_above = minetest.registered_nodes[node_above.name]
	local def_under = minetest.registered_nodes[node_under.name]

	local place_pos, soil_node, place_node, soil_def, place_def
	if def_under.buildable_to then
		place_pos = u
		place_node = node_under
		place_def = def_under
	elseif def_above.buildable_to then
		place_pos = a
		place_node = node_above
		place_def = def_above
	else
		return itemstack
	end
	soil_node = minetest.get_node({x=place_pos.x, y=place_pos.y-1, z=place_pos.z})
	soil_def = minetest.registered_nodes[soil_node.name]

	-- Placement rules:
	-- * Always allowed on podzol or mycelimu
	-- * Otherwise, must be solid, opaque and have daylight light level <= 12
	local light = minetest.get_node_light(place_pos, 0.5)
	local light_ok = false
	if light and light <= 12 then
		light_ok = true
	end
	if (soil_node.name == "mcl_core:podzol" or soil_node.name == "mcl_core:mycelium") or
			(light_ok and (soil_def.groups and soil_def.groups.solid and soil_def.groups.opaque)) then
		local idef = itemstack:get_definition()
		local success = minetest.item_place_node(itemstack, placer, pointed_thing)

		if success then
			if idef.sounds and idef.sounds.place then
				minetest.sound_play(idef.sounds.place, {pos=above, gain=1})
			end
		end
	end

	return itemstack
end

minetest.register_node("mcl_mushrooms:mushroom_brown", {
	description = "Brown Mushroom",
	drawtype = "plantlike",
	tiles = { "farming_mushroom_brown.png" },
	inventory_image = "farming_mushroom_brown.png",
	wield_image = "farming_mushroom_brown.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3,mushroom=1,attached_node=1,dig_by_water=1,dig_by_piston=1,deco_block=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	light_source = 1,
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, -2/16, 3/16 },
	},
	node_placement_prediction = "",
	on_place = on_place,
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_mushrooms:mushroom_red", {
	description = "Red Mushroom",
	drawtype = "plantlike",
	tiles = { "farming_mushroom_red.png" },
	inventory_image = "farming_mushroom_red.png",
	wield_image = "farming_mushroom_red.png",
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	groups = {dig_immediate=3,mushroom=1,attached_node=1,dig_by_water=1,dig_by_piston=1,deco_block=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -0.5, -3/16, 3/16, -2/16, 3/16 },
	},
	node_placement_prediction = "",
	on_place = on_place,
	_mcl_blast_resistance = 0,
})

minetest.register_craftitem("mcl_mushrooms:mushroom_stew", {
	description = "Mushroom Stew",
	_doc_items_longdesc = "Mushroom stew is a healthy soup which can be consumed for 6 hunger points.",
	inventory_image = "farming_mushroom_stew.png",
	on_place = minetest.item_eat(6, "mcl_core:bowl"),
	on_secondary_use = minetest.item_eat(6, "mcl_core:bowl"),
	groups = { food = 3, eatable = 6 },
	stack_max = 1,
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_mushrooms:mushroom_stew",
	recipe = {'mcl_core:bowl', 'mcl_mushrooms:mushroom_brown', 'mcl_mushrooms:mushroom_red'}
})


