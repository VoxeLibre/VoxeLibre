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

vl_attach.set_default("torch", function(_, def, wdir)
	-- No ceiling torches
	if wdir == 0 then return false end

	-- Allow solid, opaque, full cube collision box nodes are allowed.
	return (def.groups.solid or 0) ~= 0 and (def.groups.opaque or 0) ~= 0
end)
vl_attach.register_autogroup({
	skip_existing = {"torch"},
	callback = function(allow_attach, _, def)
		local groups = def.groups

		-- Always allow attaching torches to glass
		if (groups.glass or 0) ~= 0 then
			allow_attach.torch = true
		end

		-- Allow attaching torches to the tops of these node types
		if groups.fence == 1 or (groups.wall or 0) ~= 0 or (groups.anvil or 0) ~= 0
		or (groups.pane or 0) ~= 0 then
			allow_attach.torch = function(_, wdir) return wdir == 1 end
		end
	end
})

--
-- 3d torch part
--
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
	groups.vl_attach = 1

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
		_vl_attach_type = "torch",
		_vl_attach_make_placed_node = function(placed_node, _, dir, _)
			local wdir = core.dir_to_wallmounted(dir)
			if wdir == 1 then
				placed_node.name = itemstring
			else
				placed_node.name = itemstring.."_wall"
			end
			return placed_node
		end,
		on_place = vl_attach.place_attached,
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
