
--
-- 3d torch part
--

mcl_torches = {}

mcl_torches.register_torch = function(substring, description, icon, mesh_floor, mesh_wall, tiles, light, groups, sounds, moredef)
	local itemstring = minetest.get_current_modname()..":"..substring
	local itemstring_wall = minetest.get_current_modname()..":"..substring.."_wall"

	if light == nil then light = 14 end
	if mesh_floor == nil then mesh_floor = "mcl_torches_torch_floor.obj" end
	if mesh_wall == nil then mesh_wall = "mcl_torches_torch_wall.obj" end
	if groups == nil then groups = {} end

	groups.attached_node = 1
	groups.torch = 1
	groups.dig_by_water = 1

	local floordef = {
		description = description,
		drawtype = "mesh",
		mesh = mesh_floor,
		inventory_image = icon,
		wield_image = icon,
		tiles = tiles,
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		walkable = false,
		liquids_pointable = false,
		light_source = light,
		groups = groups,
		drop = itemstring,
		selection_box = {
			type = "wallmounted",
			wall_top = {-1/16, -2/16, -1/16, 1/16, 0.5, 1/16},
			wall_bottom = {-1/16, -0.5, -1/16, 1/16, 2/16, 1/16},
		},
		sounds = sounds,
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
				retval = fakestack:set_name(itemstring)
			else
				retval = fakestack:set_name(itemstring_wall)
			end
			if not retval then
				return itemstack
			end

			itemstack, success = minetest.item_place(fakestack, placer, pointed_thing, wdir)
			itemstack:set_name(itemstring)

			local idef = itemstack:get_definition()
			if success and idef.sounds and idef.sounds.place then
				minetest.sound_play(idef.sounds.place, {pos=under, gain=1})
			end
			return itemstack
		end
	}
	if moredef ~= nil then
		for k,v in pairs(moredef) do
			floordef[k] = v
		end
	end
	minetest.register_node(itemstring, floordef)

	local groups_wall = table.copy(groups)
	groups_wall.torch = 2

	local walldef = {
		drawtype = "mesh",
		mesh = mesh_wall,
		tiles = tiles,
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		walkable = false,
		light_source = light,
		groups = groups_wall,
		drop = itemstring,
		selection_box = {
			type = "wallmounted",
			wall_top = {-0.1, -0.1, -0.1, 0.1, 0.5, 0.1},
			wall_bottom = {-0.1, -0.5, -0.1, 0.1, 0.1, 0.1},
			wall_side = {-0.5, -0.5, -0.1, -0.2, 0.1, 0.1},
		},
		sounds = sounds,
	}
	if moredef ~= nil then
		for k,v in pairs(moredef) do
			walldef[k] = v
		end
	end
	minetest.register_node(itemstring_wall, walldef)
end

mcl_torches.register_torch("torch", "Torch", "default_torch_on_floor.png",
	"mcl_torches_torch_floor.obj", "mcl_torches_torch_wall.obj",
	{{
		name = "default_torch_on_floor_animated.png",
		animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
	}},
	14,
	{dig_immediate=3, torch=1, dig_by_water=1, deco_block=1},
	mcl_sounds.node_sound_wood_defaults())
	

minetest.register_craft({
	output = "mcl_torches:torch 4",
	recipe = {
		{ "group:coal" },
		{ "mcl_core:stick" },
	}
})

