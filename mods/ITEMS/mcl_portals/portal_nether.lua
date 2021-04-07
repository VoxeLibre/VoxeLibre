local S = minetest.get_translator("mcl_portals")

local SCAN_2_MAP_CHUNKS = true -- slower but helps to find more suitable places

-- Localize functions for better performance
local abs = math.abs
local ceil = math.ceil
local floor = math.floor
local max = math.max
local min = math.min
local random = math.random
local dist = vector.distance
local add = vector.add
local mul = vector.multiply
local sub = vector.subtract

-- Setup
local W_MIN, W_MAX			= 4, 23
local H_MIN, H_MAX			= 5, 23
local N_MIN, N_MAX			= 6, (W_MAX-2) * (H_MAX-2)
local TRAVEL_X, TRAVEL_Y, TRAVEL_Z	= 8, 1, 8
local LIM_MIN, LIM_MAX			= mcl_vars.mapgen_edge_min, mcl_vars.mapgen_edge_max
local PLAYER_COOLOFF, MOB_COOLOFF	= 3, 14 -- for this many seconds they won't teleported again
local TOUCH_CHATTER_TIME		= 1 -- prevent multiple teleportation attempts caused by multiple portal touches, for this number of seconds
local CHATTER_US			= TOUCH_CHATTER_TIME * 1000000
local DELAY				= 3 -- seconds before teleporting in Nether portal in Survival mode (4 minus ABM interval time)
local DISTANCE_MAX			= 128
local PORTAL				= "mcl_portals:portal"
local OBSIDIAN				= "mcl_core:obsidian"
local O_Y_MIN, O_Y_MAX			= max(mcl_vars.mg_overworld_min, -31), min(mcl_vars.mg_overworld_max_official, 2048)
local N_Y_MIN, N_Y_MAX			= mcl_vars.mg_bedrock_nether_bottom_min, mcl_vars.mg_bedrock_nether_top_max - H_MIN
local O_DY, N_DY			= O_Y_MAX - O_Y_MIN + 1, N_Y_MAX - N_Y_MIN + 1

-- Alpha and particles
local node_particles_allowed = minetest.settings:get("mcl_node_particles") or "none"
local node_particles_levels = { none=0, low=1, medium=2, high=3 }
local PARTICLES = node_particles_levels[node_particles_allowed]

-- Table of objects (including players) which recently teleported by a
-- Nether portal. Those objects have a brief cooloff period before they
-- can teleport again. This prevents annoying back-and-forth teleportation.
local cooloff = {}
function mcl_portals.nether_portal_cooloff(object)
	return cooloff[object]
end

local chatter = {}

local queue = {}
local chunks = {}

local storage = mcl_portals.storage
local exits = {}
local keys = minetest.deserialize(storage:get_string("nether_exits_keys") or "return {}") or {}
for _, key in pairs(keys) do
	local n = tonumber(key)
	if n then
		exits[key] = minetest.deserialize(storage:get_string("nether_exits_"..key) or "return {}") or {}
	end
end
minetest.register_on_shutdown(function()
	local keys={}
	for key, data in pairs(exits) do
		storage:set_string("nether_exits_"..tostring(key), minetest.serialize(data))
		keys[#keys+1] = key
	end
	storage:set_string("nether_exits_keys", minetest.serialize(keys))
end)

local get_node = mcl_vars.get_node
local set_node = minetest.set_node
local registered_nodes = minetest.registered_nodes
local is_protected = minetest.is_protected
local find_nodes_in_area = minetest.find_nodes_in_area
local find_nodes_in_area_under_air = minetest.find_nodes_in_area_under_air
local log = minetest.log
local pos_to_string = minetest.pos_to_string
local is_area_protected = minetest.is_area_protected
local get_us_time = minetest.get_us_time

local limits = {
	nether = {
		pmin = {x=LIM_MIN, y = N_Y_MIN, z = LIM_MIN},
		pmax = {x=LIM_MAX, y = N_Y_MAX, z = LIM_MAX},
	},
	overworld = {
		pmin = {x=LIM_MIN, y = O_Y_MIN, z = LIM_MIN},
		pmax = {x=LIM_MAX, y = O_Y_MAX, z = LIM_MAX},
	},
}

-- This function registers exits from Nether portals.
-- Incoming verification performed: two nodes must be portal nodes, and an obsidian below them.
-- If the verification passes - position adds to the table and saves to mod storage on exit.
local function add_exit(p)
	if not p or not p.y or not p.z or not p.x then return end
	local x, y, z = floor(p.x), floor(p.y), floor(p.z)
	local p = {x = x, y = y, z = z}
	if get_node({x=x,y=y-1,z=z}).name ~= OBSIDIAN or get_node(p).name ~= PORTAL or get_node({x=x,y=y+1,z=z}).name ~= PORTAL then return end
	local k = floor(z/256) * 256 + floor(x/256)
	if not exits[k] then
		exits[k]={}
	end
	local e = exits[k]
	for i = 1, #e do
		local t = e[i]
		if t and t.x == p.x and t.y == p.y and t.z == p.z then
			return
		end
	end
	e[#e+1] = p
	log("action", "[mcl_portals] Exit added at " .. pos_to_string(p))
end

-- This function removes Nether portals exits.
local function remove_exit(p)
	if not p or not p.y or not p.z or not p.x then return end
	local x, y, z = floor(p.x), floor(p.y), floor(p.z)
	local k = floor(z/256) * 256 + floor(x/256)
	if not exits[k] then return end
	local p = {x = x, y = y, z = z}
	local e = exits[k]
	if e then
		for i, t in pairs(e) do
			if t and t.x == x and t.y == y and t.z == z then
				e[i] = nil
				log("action", "[mcl_portals] Nether portal removed from " .. pos_to_string(p))
				return
			end
		end
	end
end

-- This functon searches Nether portal nodes whitin distance specified
local function find_exit(p, dx, dy, dz)
	if not p or not p.y or not p.z or not p.x then return end
	local dx, dy, dz = dx or DISTANCE_MAX, dy or DISTANCE_MAX, dz or DISTANCE_MAX
	if dx < 1 or dy < 1 or dz < 1 then return false end
	local x, y, z = floor(p.x), floor(p.y), floor(p.z)
	local x1, y1, z1, x2, y2, z2 = x-dx+1, y-dy+1, z-dz+1, x+dx-1, y+dy-1, z+dz-1
	local k1x, k2x = floor(x1/256), floor(x2/256)
	local k1z, k2z = floor(z1/256), floor(z2/256)

	local t, d
	for kx = k1x, k2x do for kz = k1z, k2z do
		local k = kz*256 + kx
		local e = exits[k]
		if e then
			for _, t0 in pairs(e) do
				local d0 = dist(p, t0)
				if not d or d>d0 then
					d = d0
					t = t0
					if d==0 then return t end
				end
			end
		end
	end end

	if t and abs(t.x-p.x) <= dx and abs(t.y-p.y) <= dy and abs(t.z-p.z) <= dz then
		return t
	end
end


-- Ping-Pong the coordinate for Fast Travelling, https://git.minetest.land/Wuzzy/MineClone2/issues/795#issuecomment-11058
local function ping_pong(x, m, l1, l2)
	if x < 0 then
		return	 l1 + abs(((x*m+l1) % (l1*4)) - (l1*2)), 	floor(x*m/l1/2)  + ((ceil(x*m/l1)+1)%2) * ((x*m)%l1)/l1
	end
	return		 l2 - abs(((x*m+l2) % (l2*4)) - (l2*2)), 	floor(x*m/l2/2) + (floor(x*m/l2)%2) * ((x*m)%l2)/l2
end

local function get_target(p)
	if p and p.y and p.x and p.z then
		local x, z = p.x, p.z
		local y, d = mcl_worlds.y_to_layer(p.y)
		local o1, o2 -- y offset
		if y then
			if d=="nether" then
				x, o1 = ping_pong(x, TRAVEL_X, LIM_MIN, LIM_MAX)
				z, o2 = ping_pong(z, TRAVEL_Z, LIM_MIN, LIM_MAX)
				y = floor(y * TRAVEL_Y + (o1+o2) / 16 * LIM_MAX)
				y = min(max(y + mcl_vars.mg_overworld_min, mcl_vars.mg_overworld_min), mcl_vars.mg_overworld_max)
			elseif d=="overworld" then
				x, y, z = floor(x / TRAVEL_X + 0.5), floor(y / TRAVEL_Y + 0.5), floor(z / TRAVEL_Z + 0.5)
				y = min(max(y + mcl_vars.mg_nether_min, mcl_vars.mg_nether_min), mcl_vars.mg_nether_max)
			end
			return {x=x, y=y, z=z}, d
		end
	end
end

-- Destroy portal if pos (portal frame or portal node) got destroyed
local function destroy_nether_portal(pos, node)
	if not node then return end
	local nn, orientation = node.name, node.param2
	local obsidian = nn == OBSIDIAN

	local check_remove = function(pos, orientation)
		local node = get_node(pos)
		if node and (node.name == PORTAL and (orientation == nil or (node.param2 == orientation))) then
			minetest.remove_node(pos)
			remove_exit(pos)
		end
	end
	if obsidian then -- check each of 6 sides of it and destroy every portal:
		check_remove({x = pos.x - 1, y = pos.y, z = pos.z}, 0)
		check_remove({x = pos.x + 1, y = pos.y, z = pos.z}, 0)
		check_remove({x = pos.x, y = pos.y, z = pos.z - 1}, 1)
		check_remove({x = pos.x, y = pos.y, z = pos.z + 1}, 1)
		check_remove({x = pos.x, y = pos.y - 1, z = pos.z})
		check_remove({x = pos.x, y = pos.y + 1, z = pos.z})
		return
	end
	if orientation == 0 then
		check_remove({x = pos.x - 1, y = pos.y, z = pos.z}, 0)
		check_remove({x = pos.x + 1, y = pos.y, z = pos.z}, 0)
	else
		check_remove({x = pos.x, y = pos.y, z = pos.z - 1}, 1)
		check_remove({x = pos.x, y = pos.y, z = pos.z + 1}, 1)
	end
	check_remove({x = pos.x, y = pos.y - 1, z = pos.z})
	check_remove({x = pos.x, y = pos.y + 1, z = pos.z})
end

minetest.register_node(PORTAL, {
	description = S("Nether Portal"),
	_doc_items_longdesc = S("A Nether portal teleports creatures and objects to the hot and dangerous Nether dimension (and back!). Enter at your own risk!"),
	_doc_items_usagehelp = S("Stand in the portal for a moment to activate the teleportation. Entering a Nether portal for the first time will also create a new portal in the other dimension. If a Nether portal has been built in the Nether, it will lead to the Overworld. A Nether portal is destroyed if the any of the obsidian which surrounds it is destroyed, or if it was caught in an explosion."),

	tiles = {
		"blank.png",
		"blank.png",
		"blank.png",
		"blank.png",
		{
			name = "mcl_portals_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.25,
			},
		},
		{
			name = "mcl_portals_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.25,
			},
		},
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "blend" or true,
	walkable = false,
	buildable_to = false,
	is_ground_content = false,
	drop = "",
	light_source = 11,
	post_effect_color = {a = 180, r = 51, g = 7, b = 89},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1,  0.5, 0.5, 0.1},
		},
	},
	groups = { creative_breakable = 1, portal = 1, not_in_creative_inventory = 1 },
	sounds = mcl_sounds.node_sound_glass_defaults(),
	after_destruct = destroy_nether_portal,

	_mcl_hardness = -1,
	_mcl_blast_resistance = 0,
})

local function light_frame(x1, y1, z1, x2, y2, z2, name, node, node_frame)
	local orientation = 0
	if x1 == x2 then
		orientation = 1
	end
	local pos = {}
	local node = node or {name = PORTAL, param2 = orientation}
	local node_frame = node_frame or {name = OBSIDIAN}
	for x = x1 - 1 + orientation, x2 + 1 - orientation do
		pos.x = x
		for z = z1 - orientation, z2 + orientation do
			pos.z = z
			for y = y1 - 1, y2 + 1 do
				pos.y = y
				local frame = (x < x1) or (x > x2) or (y < y1) or (y > y2) or (z < z1) or (z > z2)
				if frame then
					set_node(pos, node_frame)
				else
					set_node(pos, node)
					add_exit({x=pos.x, y=pos.y-1, z=pos.z})
				end
			end
		end
	end
end

--Build arrival portal
function build_nether_portal(pos, width, height, orientation, name, clear_before_build)
	local width, height, orientation = width or W_MIN - 2, height or H_MIN - 2, orientation or random(0, 1)

	if clear_before_build then
		light_frame(pos.x, pos.y, pos.z, pos.x + (1 - orientation) * (width - 1), pos.y + height - 1, pos.z + orientation * (width - 1), name, {name="air"}, {name="air"})
	end
	light_frame(pos.x, pos.y, pos.z, pos.x + (1 - orientation) * (width - 1), pos.y + height - 1, pos.z + orientation * (width - 1), name)

	-- Build obsidian platform:
	for x = pos.x - orientation, pos.x + orientation + (width - 1) * (1 - orientation), 1 + orientation do
		for z = pos.z - 1 + orientation, pos.z + 1 - orientation + (width - 1) * orientation, 2 - orientation do
			local pp = {x = x, y = pos.y - 1, z = z}
			local pp_1 = {x = x, y = pos.y - 2, z = z}
			local nn = get_node(pp).name
			local nn_1 = get_node(pp_1).name
			if ((nn=="air" and nn_1 == "air") or not registered_nodes[nn].is_ground_content) and not is_protected(pp, name) then
				set_node(pp, {name = OBSIDIAN})
			end
		end
	end

	log("action", "[mcl_portals] Destination Nether portal generated at "..pos_to_string(pos).."!")

	return pos
end

function mcl_portals.spawn_nether_portal(pos, rot, pr, name)
	if not pos then return end
	local o = 0
	if rot then
		if rot == "270" or rot=="90" then
			o = 1
		elseif rot == "random" then
			o = random(0,1)
		end
	end
	build_nether_portal(pos, nil, nil, o, name, true)
end

-- Teleportation cooloff for some seconds, to prevent back-and-forth teleportation
local function stop_teleport_cooloff(o)
	cooloff[o] = nil
	chatter[o] = nil
end

local function teleport_cooloff(obj)
	cooloff[obj] = true
	if obj:is_player() then
		minetest.after(PLAYER_COOLOFF, stop_teleport_cooloff, obj)
	else
		minetest.after(MOB_COOLOFF, stop_teleport_cooloff, obj)
	end
end

local function finalize_teleport(obj, exit)
	if not obj or not exit or not exit.x or not exit.y or not exit.z then return end

	local objpos = obj:get_pos()
	if not objpos then return end

	local is_player = obj:is_player()
	local name
	if is_player then
		name = obj:get_player_name()
	end
	local y, dim = mcl_worlds.y_to_layer(exit.y)


	-- If player stands, player is at ca. something+0.5 which might cause precision problems, so we used ceil for objpos.y
	objpos = {x = floor(objpos.x+0.5), y = ceil(objpos.y), z = floor(objpos.z+0.5)}
	if get_node(objpos).name ~= PORTAL then return end

	-- THIS IS A TEMPORATY CODE SECTION FOR COMPATIBILITY REASONS -- 1 of 2 -- TODO: Remove --
	-- Old worlds have no exits indexed - adding the exit to return here:
	add_exit(objpos)
	-- TEMPORATY CODE SECTION ENDS HERE --


	-- Enable teleportation cooloff for some seconds, to prevent back-and-forth teleportation
	teleport_cooloff(obj)

	-- Teleport
	obj:set_pos(exit)

	if is_player then
		mcl_worlds.dimension_change(obj, dim)
		minetest.sound_play("mcl_portals_teleport", {pos=exit, gain=0.5, max_hear_distance = 16}, true)
		log("action", "[mcl_portals] player "..name.." teleported to Nether portal at "..pos_to_string(exit)..".")
	else
		log("action", "[mcl_portals] entity teleported to Nether portal at "..pos_to_string(exit)..".")
	end
end

local function create_portal_2(pos1, name, obj)
	local orientation = 0
	local pos2 = {x = pos1.x + 3, y = pos1.y + 3, z = pos1.z + 3}
	local nodes = find_nodes_in_area(pos1, pos2, {"air"})
	if #nodes == 64 then
		orientation = random(0,1)
	else
		pos2.x = pos2.x - 1
		nodes = find_nodes_in_area(pos1, pos2, {"air"})
		if #nodes == 48 then
			orientation = 1
		end
	end
	local exit = build_nether_portal(pos1, W_MIN-2, H_MIN-2, orientation, name)
	finalize_teleport(obj, exit)
	local cn = mcl_vars.get_chunk_number(pos1)
	chunks[cn] = nil
	if queue[cn] then
		for next_obj, _ in pairs(queue[cn]) do
			if next_obj ~= obj then
				finalize_teleport(next_obj, exit)
			end
		end
		queue[cn] = nil
	end
end

local function get_lava_level(pos, pos1, pos2)
	if pos.y > -1000 then
		return max(min(mcl_vars.mg_lava_overworld_max, pos2.y-1), pos1.y+1)
	end
	return max(min(mcl_vars.mg_lava_nether_max, pos2.y-1), pos1.y+1)
end

local function ecb_scan_area_2(blockpos, action, calls_remaining, param)
	if calls_remaining and calls_remaining > 0 then return end
	local pos, pos1, pos2, name, obj = param.pos, param.pos1, param.pos2, param.name or "", param.obj
	local pos0, distance
	local lava = get_lava_level(pos, pos1, pos2)

	-- THIS IS A TEMPORATY CODE SECTION FOR COMPATIBILITY REASONS -- 2 of 2 -- TODO: Remove --
	-- Find portals for old worlds (new worlds keep them all in the table):
	local portals = find_nodes_in_area(pos1, pos2, {PORTAL})
	if portals and #portals>0 then
		for _, p in pairs(portals) do
			add_exit(p)
		end
		local exit = find_exit(pos)
		if exit then
			finalize_teleport(obj, exit)
		end
		return
	end
	-- TEMPORATY CODE SECTION ENDS HERE --


	local nodes = find_nodes_in_area_under_air(pos1, pos2, {"group:building_block"})
	if nodes then
		local nc = #nodes
		if nc > 0 then
			log("action", "[mcl_portals] Area for destination Nether portal emerged! Found " .. tostring(nc) .. " nodes under the air around "..pos_to_string(pos))
			for i=1,nc do
				local node = nodes[i]
				local node1 = {x=node.x,   y=node.y+1, z=node.z  }
				local node2 = {x=node.x+2, y=node.y+3, z=node.z+2}
				local nodes2 = find_nodes_in_area(node1, node2, {"air"})
				if nodes2 then
					local nc2 = #nodes2
					if nc2 == 27 and not is_area_protected(node, node2, name) then
						local distance0 = dist(pos, node)
						if distance0 < 2 then
							log("action", "[mcl_portals] found space at pos "..pos_to_string(node).." - creating a portal")
							create_portal_2(node1, name, obj)
							return
						end
						if not distance or (distance0 < distance) or (distance0 < distance-1 and node.y > lava and pos0.y < lava) then
							log("action", "[mcl_portals] found distance "..tostring(distance0).." at pos "..pos_to_string(node))
							distance = distance0
							pos0 = {x=node1.x, y=node1.y, z=node1.z}
						end
					end
				end
			end
		end
	end
	if distance then -- several nodes of air might be better than lava lake, right?
		log("action", "[mcl_portals] using backup pos "..pos_to_string(pos0).." to create a portal")
		create_portal_2(pos0, name, obj)
		return
	end

	if param.next_chunk_1 and param.next_chunk_2 and param.next_pos then
		local pos1, pos2, pos = param.next_chunk_1, param.next_chunk_2, param.next_pos
		log("action", "[mcl_portals] Making additional search in chunk below, because current one doesn't contain any air space for portal, target pos "..pos_to_string(pos))
		minetest.emerge_area(pos1, pos2, ecb_scan_area_2, {pos = pos, pos1 = pos1, pos2 = pos2, name=name, obj=obj})
		return
	end

	log("action", "[mcl_portals] found no space, reverting to target pos "..pos_to_string(pos).." - creating a portal")
	if pos.y < lava then
		pos.y = lava + 1
	else
		pos.y = pos.y + 1
	end
	create_portal_2(pos, name, obj)
end

local function create_portal(pos, limit1, limit2, name, obj)
	local cn = mcl_vars.get_chunk_number(pos)
	if chunks[cn] then
		local q = queue[cn] or {}
		q[obj] = true
		queue[cn] = q
		return
	end
	chunks[cn] = true

	-- we need to emerge the area here, but currently (mt5.4/mcl20.71) map generation is slow
	-- so we'll emerge single chunk only: 5x5x5 blocks, 80x80x80 nodes maximum
	-- and maybe one more chunk from below if (SCAN_2_MAP_CHUNKS = true)

	local pos1 = add(mul(mcl_vars.pos_to_chunk(pos), mcl_vars.chunk_size_in_nodes), mcl_vars.central_chunk_offset_in_nodes)
	local pos2 = add(pos1, mcl_vars.chunk_size_in_nodes - 1)

	if not SCAN_2_MAP_CHUNKS then
		if limit1 and limit1.x and limit1.y and limit1.z then
			pos1 = {x = max(min(limit1.x, pos.x), pos1.x), y = max(min(limit1.y, pos.y), pos1.y), z = max(min(limit1.z, pos.z), pos1.z)}
		end
		if limit2 and limit2.x and limit2.y and limit2.z  then
			pos2 = {x = min(max(limit2.x, pos.x), pos2.x), y = min(max(limit2.y, pos.y), pos2.y), z = min(max(limit2.z, pos.z), pos2.z)}
		end
		minetest.emerge_area(pos1, pos2, ecb_scan_area_2, {pos = vector.new(pos), pos1 = pos1, pos2 = pos2, name=name, obj=obj})
		return
	end

	-- Basically the copy of code above, with minor additions to continue the search in single additional chunk below:
	local next_chunk_1 = {x = pos1.x, y = pos1.y - mcl_vars.chunk_size_in_nodes, z = pos1.z}
	local next_chunk_2 = add(next_chunk_1, mcl_vars.chunk_size_in_nodes - 1)
	local next_pos = {x = pos.x, y=next_chunk_2.y, z = pos.z}
	if limit1 and limit1.x and limit1.y and limit1.z then
		pos1 = {x = max(min(limit1.x, pos.x), pos1.x), y = max(min(limit1.y, pos.y), pos1.y), z = max(min(limit1.z, pos.z), pos1.z)}
		next_chunk_1 = {x = max(min(limit1.x, next_pos.x), next_chunk_1.x), y = max(min(limit1.y, next_pos.y), next_chunk_1.y), z = max(min(limit1.z, next_pos.z), next_chunk_1.z)}
	end
	if limit2 and limit2.x and limit2.y and limit2.z  then
		pos2 = {x = min(max(limit2.x, pos.x), pos2.x), y = min(max(limit2.y, pos.y), pos2.y), z = min(max(limit2.z, pos.z), pos2.z)}
		next_chunk_2 = {x = min(max(limit2.x, next_pos.x), next_chunk_2.x), y = min(max(limit2.y, next_pos.y), next_chunk_2.y), z = min(max(limit2.z, next_pos.z), next_chunk_2.z)}
	end
	minetest.emerge_area(pos1, pos2, ecb_scan_area_2, {pos = vector.new(pos), pos1 = pos1, pos2 = pos2, name=name, obj=obj, next_chunk_1 = next_chunk_1, next_chunk_2 = next_chunk_2, next_pos = next_pos})
end

local function available_for_nether_portal(p)
	local nn = get_node(p).name
	local obsidian = nn == OBSIDIAN
	if nn ~= "air" and minetest.get_item_group(nn, "fire") ~= 1 then
		return false, obsidian
	end
	return true, obsidian
end

local function check_and_light_shape(pos, orientation)
	local stack = {{x = pos.x, y = pos.y, z = pos.z}}
	local node_list = {}
	local index_list = {}
	local node_counter = 0
	-- Search most low node from the left (pos1) and most right node from the top (pos2)
	local pos1 = {x = pos.x, y = pos.y, z = pos.z}
	local pos2 = {x = pos.x, y = pos.y, z = pos.z}

	local kx, ky, kz = pos.x - 1999, pos.y - 1999, pos.z - 1999
	while #stack > 0 do
		local i = #stack
		local x, y, z = stack[i].x, stack[i].y, stack[i].z
		local k = (x-kx)*16000000 + (y-ky)*4000 + z-kz
		if index_list[k] then
			stack[i] = nil -- Already checked, skip it
		else
			local good, obsidian = available_for_nether_portal(stack[i])
			if obsidian then
				stack[i] = nil
			else
				if (not good) or (node_counter >= N_MAX) then
					return false
				end
				node_counter = node_counter + 1
				node_list[node_counter] = {x = x, y = y, z = z}
				index_list[k] = true
				stack[i].y = y - 1
				stack[i + 1] = {x = x, y = y + 1, z = z}
				if orientation == 0 then
					stack[i + 2] = {x = x - 1, y = y, z = z}
					stack[i + 3] = {x = x + 1, y = y, z = z}
				else
					stack[i + 2] = {x = x, y = y, z = z - 1}
					stack[i + 3] = {x = x, y = y, z = z + 1}
				end
				if (y < pos1.y) or (y == pos1.y and (x < pos1.x or z < pos1.z)) then
					pos1 = {x = x, y = y, z = z}
				end
				if (x > pos2.x or z > pos2.z) or (x == pos2.x and z == pos2.z and y > pos2.y) then
					pos2 = {x = x, y = y, z = z}
				end
			end
		end
	end

	if node_counter < N_MIN then
		return false
	end

	-- Limit rectangles width and height
	if abs(pos2.x - pos1.x + pos2.z - pos1.z) + 3 > W_MAX or abs(pos2.y - pos1.y) + 3 > H_MAX then
		return false
	end

	for i = 1, node_counter do
		local node_pos = node_list[i]
		minetest.set_node(node_pos, {name = PORTAL, param2 = orientation})
		add_exit(node_pos)
	end
	return true
end

-- Attempts to light a Nether portal at pos
-- Pos can be any of the inner part.
-- The frame MUST be filled only with air or any fire, which will be replaced with Nether portal blocks.
-- If no Nether portal can be lit, nothing happens.
-- Returns number of portals created (0, 1 or 2)
function mcl_portals.light_nether_portal(pos)
	-- Only allow to make portals in Overworld and Nether
	local dim = mcl_worlds.pos_to_dimension(pos)
	if dim ~= "overworld" and dim ~= "nether" then
		return false
	end
	local orientation = random(0, 1)
	for orientation_iteration = 1, 2 do
		if check_and_light_shape(pos, orientation) then
			minetest.after(0.2, function(pos) -- generate target map chunk
				local pos1 = add(mul(mcl_vars.pos_to_chunk(pos), mcl_vars.chunk_size_in_nodes), mcl_vars.central_chunk_offset_in_nodes)
				local pos2 = add(pos1, mcl_vars.chunk_size_in_nodes - 1)
				minetest.emerge_area(pos1, pos2)
			end, vector.new(pos))
			return true
		end
		orientation = 1 - orientation
	end
	return false
end

-- Teleport function
local function teleport_no_delay(obj, pos)
	local is_player = obj:is_player()
	if (not is_player and not obj:get_luaentity()) or cooloff[obj] then return end

	local objpos = obj:get_pos()
	if not objpos then return end

	-- If player stands, player is at ca. something+0.5 which might cause precision problems, so we used ceil for objpos.y
	objpos = {x = floor(objpos.x+0.5), y = ceil(objpos.y), z = floor(objpos.z+0.5)}
	if get_node(objpos).name ~= PORTAL then return end

	local target, dim = get_target(objpos)
	if not target then return end

	local name
	if is_player then
		name = obj:get_player_name()
	end

	local exit = find_exit(target)
	if exit then
		finalize_teleport(obj, exit)
	else
		-- need to create arrival portal
		create_portal(target, limits[dim].pmin, limits[dim].pmax, name, obj)
	end
end

local function prevent_portal_chatter(obj)
	local time_us = get_us_time()
	local ch = chatter[obj] or 0
	chatter[obj] = time_us
	minetest.after(TOUCH_CHATTER_TIME, function(o)
		if o and chatter[o] and get_us_time() - chatter[o] >= CHATTER_US then
			chatter[o] = nil
		end
	end, obj)
	return time_us - ch > CHATTER_US
end

local function animation(player, playername)
	local ch = chatter[player] or 0
	if cooloff[player] or get_us_time() - ch < CHATTER_US then
		local pos = player:get_pos()
		if not pos then
			return
		end
		minetest.add_particlespawner({
			amount = 1,
			minpos = {x = pos.x - 0.1, y = pos.y + 1.4, z = pos.z - 0.1},
			maxpos = {x = pos.x + 0.1, y = pos.y + 1.6, z = pos.z + 0.1},
			minvel = 0,
			maxvel = 0,
			minacc = 0,
			maxacc = 0,
			minexptime = 0.1,
			maxexptime = 0.2,
			minsize = 5,
			maxsize = 15,
			collisiondetection = false,
			texture = "mcl_particles_nether_portal_t.png",
			playername = playername,
		})
		minetest.after(0.3, animation, player, playername)
	end
end

local function teleport(obj, portal_pos)
	local name = ""
	if obj:is_player() then
		name = obj:get_player_name()
		animation(obj, name)
	end

	if cooloff[obj] then return end

	if minetest.is_creative_enabled(name) then
		teleport_no_delay(obj, portal_pos)
		return
	end

	minetest.after(DELAY, teleport_no_delay, obj, portal_pos)
end

minetest.register_abm({
	label = "Nether portal teleportation and particles",
	nodenames = {PORTAL},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		local o = node.param2		-- orientation
		local d = random(0, 1)	-- direction
		local time = random() * 1.9 + 0.5
		local velocity, acceleration
		if o == 1 then
			velocity	= {x = random() * 0.7 + 0.3,	y = random() - 0.5,	z = random() - 0.5}
			acceleration	= {x = random() * 1.1 + 0.3,	y = random() - 0.5,	z = random() - 0.5}
		else
			velocity	= {x = random() - 0.5,		y = random() - 0.5,	z = random() * 0.7 + 0.3}
			acceleration	= {x = random() - 0.5,		y = random() - 0.5,	z = random() * 1.1 + 0.3}
		end
		local distance = add(mul(velocity, time), mul(acceleration, time * time / 2))
		if d == 1 then
			if o == 1 then
				distance.x	= -distance.x
				velocity.x	= -velocity.x
				acceleration.x	= -acceleration.x
			else
				distance.z	= -distance.z
				velocity.z	= -velocity.z
				acceleration.z	= -acceleration.z
			end
		end
		distance = sub(pos, distance)
		for _, obj in pairs(minetest.get_objects_inside_radius(pos, 15)) do
			if obj:is_player() then
				minetest.add_particlespawner({
					amount = PARTICLES + 1,
					minpos = distance,
					maxpos = distance,
					minvel = velocity,
					maxvel = velocity,
					minacc = acceleration,
					maxacc = acceleration,
					minexptime = time,
					maxexptime = time,
					minsize = 0.3,
					maxsize = 1.8,
					collisiondetection = false,
					texture = "mcl_particles_nether_portal.png",
					playername = obj:get_player_name(),
				})
			end
		end
		for _, obj in pairs(minetest.get_objects_inside_radius(pos, 1)) do	--maikerumine added for objects to travel
			local lua_entity = obj:get_luaentity()				--maikerumine added for objects to travel
			if (obj:is_player() or lua_entity) and prevent_portal_chatter(obj) then
				teleport(obj, pos)
			end
		end
	end,
})


--[[ ITEM OVERRIDES ]]

local longdesc = registered_nodes[OBSIDIAN]._doc_items_longdesc
longdesc = longdesc .. "\n" .. S("Obsidian is also used as the frame of Nether portals.")
local usagehelp = S("To open a Nether portal, place an upright frame of obsidian with a width of at least 4 blocks and a height of 5 blocks, leaving only air in the center. After placing this frame, light a fire in the obsidian frame. Nether portals only work in the Overworld and the Nether.")

minetest.override_item(OBSIDIAN, {
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usagehelp,
	after_destruct = destroy_nether_portal,
	_on_ignite = function(user, pointed_thing)
		local x, y, z = pointed_thing.under.x, pointed_thing.under.y, pointed_thing.under.z
		-- Check empty spaces around obsidian and light all frames found:
		local portals_placed =
				mcl_portals.light_nether_portal({x = x - 1, y = y, z = z}) or mcl_portals.light_nether_portal({x = x + 1, y = y, z = z}) or
				mcl_portals.light_nether_portal({x = x, y = y - 1, z = z}) or mcl_portals.light_nether_portal({x = x, y = y + 1, z = z}) or
				mcl_portals.light_nether_portal({x = x, y = y, z = z - 1}) or mcl_portals.light_nether_portal({x = x, y = y, z = z + 1})
		if portals_placed then
			log("action", "[mcl_portals] Nether portal activated at "..pos_to_string({x=x,y=y,z=z})..".")
			if minetest.get_modpath("doc") then
				doc.mark_entry_as_revealed(user:get_player_name(), "nodes", PORTAL)

				-- Achievement for finishing a Nether portal TO the Nether
				local dim = mcl_worlds.pos_to_dimension({x=x, y=y, z=z})
				if minetest.get_modpath("awards") and dim ~= "nether" and user:is_player() then
					awards.unlock(user:get_player_name(), "mcl:buildNetherPortal")
				end
			end
			return true
		else
			return false
		end
	end,
})
