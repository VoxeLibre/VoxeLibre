local flame_texture = {"mcl_particles_flame.png", "mcl_particles_soul_fire_flame.png"}

local smoke_pdef = {
	amount = 0.5,
	maxexptime = 2.0,
	minvel = { x = 0.0, y = 0.5, z = 0.0 },
	maxvel = { x = 0.0, y = 0.6, z = 0.0 },
	minsize = 1.5,
	maxsize = 1.5,
	minrelpos = { x = -1/16, y = 0.04, z = -1/16 },
	maxrelpos = { x =  1/16, y = 0.06, z =  1/16 },
}

local function spawn_flames_floor(pos, flame_type)

	-- Flames
	mcl_particles.add_node_particlespawner(pos, {
		amount = 8,
		time = 0,
		minpos = vector.add(pos, { x = -0.1, y = 0.05, z = -0.1 }),
		maxpos = vector.add(pos, { x = 0.1, y = 0.15, z = 0.1 }),
		minvel = { x = -0.01, y = 0, z = -0.01 },
		maxvel = { x = 0.01, y = 0.1, z = 0.01 },
		minexptime = 0.3,
		maxexptime = 0.6,
		minsize = 0.7,
		maxsize = 2,
		texture = flame_texture[flame_type],
		glow = minetest.registered_nodes[minetest.get_node(pos).name].light_source,
	}, "low")
	-- Smoke
	mcl_particles.spawn_smoke(pos, "torch", smoke_pdef)
end

local function spawn_flames_wall(pos, flame_type)
	--local minrelpos, maxrelpos
	local node = minetest.get_node(pos)
	local dir = minetest.wallmounted_to_dir(node.param2)

	local smoke_pdef = table.copy(smoke_pdef)

	if dir.x < 0 then
		smoke_pdef.minrelpos = { x = -0.38, y = 0.24, z = -0.1 }
		smoke_pdef.maxrelpos = { x = -0.2, y = 0.34, z = 0.1 }
	elseif dir.x > 0 then
		smoke_pdef.minrelpos = { x = 0.2, y = 0.24, z = -0.1 }
		smoke_pdef.maxrelpos = { x = 0.38, y = 0.34, z = 0.1 }
	elseif dir.z < 0 then
		smoke_pdef.minrelpos = { x = -0.1, y = 0.24, z = -0.38 }
		smoke_pdef.maxrelpos = { x = 0.1, y = 0.34, z = -0.2 }
	elseif dir.z > 0 then
		smoke_pdef.minrelpos = { x = -0.1, y = 0.24, z = 0.2 }
		smoke_pdef.maxrelpos = { x = 0.1, y = 0.34, z = 0.38 }
	else
		return
	end


	-- Flames
	mcl_particles.add_node_particlespawner(pos, {
		amount = 8,
		time = 0,
		minpos = vector.add(pos, smoke_pdef.minrelpos),
		maxpos = vector.add(pos, smoke_pdef.maxrelpos),
		minvel = { x = -0.01, y = 0, z = -0.01 },
		maxvel = { x = 0.01, y = 0.1, z = 0.01 },
		minexptime = 0.3,
		maxexptime = 0.6,
		minsize = 0.7,
		maxsize = 2,
		texture = flame_texture[flame_type],
		glow = minetest.registered_nodes[node.name].light_source,
	}, "low")
	-- Smoke
	mcl_particles.spawn_smoke(pos, "torch", smoke_pdef)
end

local function set_flames(pos, flame_type, attached_to)
	if attached_to == "wall" then
		return function(pos)
			spawn_flames_wall(pos, flame_type)
		end
	end

	return function(pos)
		spawn_flames_floor(pos, flame_type)
	end
end

local function remove_flames(pos)
	mcl_particles.delete_node_particlespawners(pos)
end

--
-- 3d torch part
--

-- Check if placement at given node is allowed
local function check_placement_allowed(node, wdir)
	-- Torch placement rules: Disallow placement on some nodes. General rule: Solid, opaque, full cube collision box nodes are allowed.
	-- Special allowed nodes:
	-- * soul sand
	-- * mob spawner
	-- * chorus flower
	-- * glass, barrier, ice
	-- * Fence, wall, end portal frame with ender eye: Only on top
	-- * Slab, stairs: Only on top if upside down

	-- Special forbidden nodes:
	-- * Piston, sticky piston
	local def = minetest.registered_nodes[node.name]
	if not def then
		return false
	-- No ceiling torches
	elseif wdir == 0 then
		return false
	elseif not def.buildable_to then
		if node.name ~= "mcl_core:ice" and node.name ~= "mcl_nether:soul_sand" and node.name ~= "mcl_mobspawners:spawner" and node.name ~= "mcl_core:barrier" and node.name ~= "mcl_end:chorus_flower" and node.name ~= "mcl_end:chorus_flower_dead" and (not def.groups.glass) and
				((not def.groups.solid) or (not def.groups.opaque)) then
			-- Only allow top placement on these nodes
			if node.name == "mcl_end:dragon_egg" or node.name == "mcl_portals:end_portal_frame_eye" or def.groups.fence == 1 or def.groups.wall or def.groups.slab_top == 1 or def.groups.anvil or def.groups.pane or (def.groups.stair == 1 and minetest.facedir_to_dir(node.param2).y ~= 0) then
				if wdir ~= 1 then
					return false
				end
			else
				return false
			end
		elseif minetest.get_item_group(node.name, "piston") >= 1 then
			return false
		end
	end
	return true
end

function mcl_torches.register_torch(def)
	local itemstring = minetest.get_current_modname() .. ":" .. def.name
	local itemstring_wall = itemstring .. "_wall"

	def.light = def.light or minetest.LIGHT_MAX
	def.mesh_floor = def.mesh_floor or "mcl_torches_torch_floor.obj"
	def.mesh_wall = def.mesh_wall or "mcl_torches_torch_wall.obj"
	def.flame_type = def.flame_type or 1

	local groups = def.groups or {}

	groups.attached_node = 1
	groups.torch = 1
	groups.torch_particles = def.particles and 1
	groups.dig_by_water = 1
	groups.destroy_by_lava_flow = 1
	groups.dig_by_piston = 1
	groups.flame_type = def.flame_type or 1

	local floordef = {
		description = def.description,
		_doc_items_longdesc = def.doc_items_longdesc,
		_doc_items_usagehelp = def.doc_items_usagehelp,
		_doc_items_hidden = def.doc_items_hidden,
		_doc_items_create_entry = def._doc_items_create_entry,
		drawtype = "mesh",
		mesh = def.mesh_floor,
		inventory_image = def.icon,
		wield_image = def.icon,
		tiles = def.tiles,
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		is_ground_content = false,
		walkable = false,
		liquids_pointable = false,
		light_source = def.light,
		groups = groups,
		drop = def.drop or itemstring,
		use_texture_alpha = "clip",
		selection_box = {
			type = "wallmounted",
			wall_bottom = {-2/16, -0.5, -2/16, 2/16, 1/16, 2/16},
		},
		sounds = def.sounds,
		node_placement_prediction = "",
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				-- no interaction possible with entities, for now.
				return itemstack
			end

			local under = pointed_thing.under
			local node = minetest.get_node(under)
			local def = minetest.registered_nodes[node.name]
			if not def then return itemstack end

			-- Call on_rightclick if the pointed node defines it
			if placer and not placer:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(under, node, placer, itemstack) or itemstack
				end
			end

			local above = pointed_thing.above
			local wdir = minetest.dir_to_wallmounted({x = under.x - above.x, y = under.y - above.y, z = under.z - above.z})

			if check_placement_allowed(node, wdir) == false then
				return itemstack
			end

			local itemstring = itemstack:get_name()
			local fakestack = ItemStack(itemstack)
			local idef = fakestack:get_definition()
			local retval

			if wdir == 1 then
				retval = fakestack:set_name(itemstring)
			else
				retval = fakestack:set_name(itemstring_wall)
			end
			if not retval then
				return itemstack
			end

			local success
			itemstack, success = minetest.item_place(fakestack, placer, pointed_thing, wdir)
			itemstack:set_name(itemstring)

			if success and idef.sounds and idef.sounds.place then
				minetest.sound_play(idef.sounds.place, {pos=under, gain=1}, true)
			end
			return itemstack
		end,
		on_rotate = false,
		on_construct = function(pos)
			if def.particles then
				set_flames(pos, def.flame_type, "floor")
			end
		end,
		on_destruct = def.particles and remove_flames,
	}
	minetest.register_node(itemstring, floordef)

	local groups_wall = table.copy(groups)
	groups_wall.torch = 2

	local walldef = {
		drawtype = "mesh",
		mesh = def.mesh_wall,
		tiles = def.tiles,
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		is_ground_content = false,
		walkable = false,
		light_source = def.light,
		groups = groups_wall,
		drop = def.drop or itemstring,
		use_texture_alpha = "clip",
		selection_box = {
			type = "wallmounted",
			wall_side = {-0.5, -0.3, -0.1, -0.2, 0.325, 0.1},
		},
		sounds = def.sounds,
		on_rotate = false,
		on_construct = function(pos)
			if def.particles then
				set_flames(pos, def.flame_type, "wall")
			end
		end,
		on_destruct = def.particles and remove_flames,
	}
	minetest.register_node(itemstring_wall, walldef)

	-- Add entry alias for the Help
	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", itemstring, "nodes", itemstring_wall)
	end
end

minetest.register_lbm({
	label = "Torch flame particles",
	name = "mcl_torches:flames",
	nodenames = {"group:torch_particles"},
	run_at_every_load = true,
	action = function(pos, node)
		local torch_group = minetest.get_item_group(node.name, "torch")
		if torch_group == 1 then
			spawn_flames_floor(pos, minetest.get_item_group(node.name, "flame_type"))
		elseif torch_group == 2 then
			spawn_flames_wall(pos, minetest.get_item_group(node.name, "flame_type"))
		end
	end,
})
