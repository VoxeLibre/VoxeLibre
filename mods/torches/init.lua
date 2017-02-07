
--
-- 3d torch part
--

minetest.register_node("torches:torch", {
	description = "Torch",
	drawtype = "mesh",
	mesh = "torch_floor.obj",
	inventory_image = "default_torch_on_floor.png",
	wield_image = "default_torch_on_floor.png",
	tiles = {{
		    name = "default_torch_on_floor_animated.png",
		    animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
	}},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	liquids_pointable = false,
	light_source = 14,
	groups = {choppy=2, dig_immediate=3, attached_node=1, torch=1, dig_by_water=1, deco_block=1},
	drop = "torches:torch",
	selection_box = {
		type = "wallmounted",
		wall_top = {-1/16, -2/16, -1/16, 1/16, 0.5, 1/16},
		wall_bottom = {-1/16, -0.5, -1/16, 1/16, 2/16, 1/16},
	},
	sounds = mcl_core.node_sound_wood_defaults(),
	node_placement_prediction = "",
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			-- no interaction possible with entities, for now.
			return itemstack
		end

		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local def = minetest.registered_nodes[node.name]
		if def and def.on_rightclick then
			return def.on_rightclick(under, node, placer, itemstack,
				pointed_thing) or itemstack, false
		end

		local above = pointed_thing.above
		local wdir = minetest.dir_to_wallmounted({x = under.x - above.x, y = under.y - above.y, z = under.z - above.z})
		local fakestack = itemstack
		local retval

		if wdir == 0 then
			-- Prevent placement of ceiling torches
			return itemstack
		elseif wdir == 1 then
			retval = fakestack:set_name("torches:torch")
		else
			retval = fakestack:set_name("torches:torch_wall")
		end
		if not retval then
			return itemstack
		end

		itemstack = minetest.item_place(fakestack, placer, pointed_thing, wdir)
		itemstack:set_name("torches:torch")

		return itemstack
	end
})

minetest.register_node("torches:torch_wall", {
	drawtype = "mesh",
	mesh = "torch_wall.obj",
	tiles = {{
		    name = "default_torch_on_floor_animated.png",
		    animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
	}},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	light_source = 14,
	groups = {choppy=2, dig_immediate=3, not_in_creative_inventory=1, attached_node=1, torch=1, dig_by_water=1},
	drop = "torches:torch",
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, -0.1, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, 0.1, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.2, 0.3, 0.1},
	},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_lbm({
	name = "torches:convert_wallmounted",
	nodenames = {"torches:torch", "torches:floor", "torches:wall"},
	action = function(pos, node)
		if node.param2 >= 2 then
			minetest.set_node(pos, {name = "torches:torch_wall",
				param2 = node.param2})
		else
			minetest.set_node(pos, {name = "torches:torch",
				param2 = node.param2})
		end
	end
})

minetest.register_craft({
	output = "torches:torch 4",
	recipe = {
		{ "group:coal" },
		{ "mcl_core:stick" },
	}
})

