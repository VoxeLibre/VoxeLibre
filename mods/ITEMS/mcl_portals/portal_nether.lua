local S = minetest.get_translator("mcl_portals")

-- Parameters

local OVERWORLD_TO_NETHER_SCALE = 8
local LIMIT = math.min(math.abs(mcl_vars.mapgen_edge_min), math.abs(mcl_vars.mapgen_edge_max))

-- Portal frame sizes
local FRAME_SIZE_X_MIN = 4
local FRAME_SIZE_Y_MIN = 5
local FRAME_SIZE_X_MAX = 23
local FRAME_SIZE_Y_MAX = 23

local PORTAL_NODES_MIN = 5
local PORTAL_NODES_MAX = (FRAME_SIZE_X_MAX - 2) * (FRAME_SIZE_Y_MAX - 2)

local TELEPORT_COOLOFF = 3 -- after player was teleported, for this many seconds they won't teleported again
local MOB_TELEPORT_COOLOFF = 14 -- after mob was teleported, for this many seconds they won't teleported again
local TOUCH_CHATTER_TIME = 1 -- prevent multiple teleportation attempts caused by multiple portal touches, for this number of seconds
local TOUCH_CHATTER_TIME_US = TOUCH_CHATTER_TIME * 1000000
local TELEPORT_DELAY = 3 -- seconds before teleporting in Nether portal (4 minus ABM interval time)
local DESTINATION_EXPIRES = 60 * 1000000 -- cached destination expires after this number of microseconds have passed without using the same origin portal

local PORTAL_SEARCH_HALF_CHUNK = 40 -- greater values may slow down the teleportation
local PORTAL_SEARCH_ALTITUDE = 128

local PORTAL_ALPHA = 192
if minetest.features.use_texture_alpha_string_modes then
	PORTAL_ALPHA = nil
end

-- Table of objects (including players) which recently teleported by a
-- Nether portal. Those objects have a brief cooloff period before they
-- can teleport again. This prevents annoying back-and-forth teleportation.
mcl_portals.nether_portal_cooloff = {}
local touch_chatter_prevention = {}

local overworld_ymin = math.max(mcl_vars.mg_overworld_min, -31)
local overworld_ymax = math.min(mcl_vars.mg_overworld_max_official, 63)
local nether_ymin = mcl_vars.mg_bedrock_nether_bottom_min
local nether_ymax = mcl_vars.mg_bedrock_nether_top_max
local overworld_dy = overworld_ymax - overworld_ymin + 1
local nether_dy = nether_ymax - nether_ymin + 1

local node_particles_allowed = minetest.settings:get("mcl_node_particles") or "none"
local node_particles_levels = {
	high = 3,
	medium = 2,
	low = 1,
	none = 0,
}
local node_particles_allowed_level = node_particles_levels[node_particles_allowed]


-- Functions

-- Ping-Pong fast travel, https://git.minetest.land/Wuzzy/MineClone2/issues/795#issuecomment-11058
local function nether_to_overworld(x)
	return LIMIT - math.abs(((x * OVERWORLD_TO_NETHER_SCALE + LIMIT) % (LIMIT*4)) - (LIMIT*2))
end

-- Destroy portal if pos (portal frame or portal node) got destroyed
local function destroy_nether_portal(pos)
	local meta = minetest.get_meta(pos)
	local node = minetest.get_node(pos)
	local nn, orientation = node.name, node.param2
	local obsidian = nn == "mcl_core:obsidian" 

	local has_meta = minetest.string_to_pos(meta:get_string("portal_frame1"))
	if has_meta then
		meta:set_string("portal_frame1", "")
		meta:set_string("portal_frame2", "")
		meta:set_string("portal_target", "")
		meta:set_string("portal_time", "")
	end
	local check_remove = function(pos, orientation)
		local node = minetest.get_node(pos)
		if node and (node.name == "mcl_portals:portal" and (orientation == nil or (node.param2 == orientation))) then
			minetest.log("action", "[mcl_portal] Destroying Nether portal at " .. minetest.pos_to_string(pos))
			return minetest.remove_node(pos)
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
	if not has_meta then -- no meta means repeated call: function calls on every node destruction
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

minetest.register_node("mcl_portals:portal", {
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
	diggable = false,
	pointable = false,
	buildable_to = false,
	is_ground_content = false,
	drop = "",
	light_source = 11,
	post_effect_color = {a = 180, r = 51, g = 7, b = 89},
	alpha = PORTAL_ALPHA,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1,  0.5, 0.5, 0.1},
		},
	},
	groups = {portal=1, not_in_creative_inventory = 1},
	on_destruct = destroy_nether_portal,

	_mcl_hardness = -1,
	_mcl_blast_resistance = 0,
})

local function find_target_y(x, y, z, y_min, y_max)
	local y_org = math.max(math.min(y, y_max), y_min)
	local node = minetest.get_node_or_nil({x = x, y = y, z = z})
	if node == nil then
		return y_org
	end
	while node.name ~= "air" and y < y_max do
		y = y + 1
		node = minetest.get_node_or_nil({x = x, y = y, z = z})
		if node == nil then
			break
		end
	end
	if node then
		if node.name ~= "air" then
			y = y_org
		end
	end
	while node == nil and y > y_min do
		y = y - 1
		node = minetest.get_node_or_nil({x = x, y = y, z = z})
	end
	if y == y_max and node ~= nil then -- try reverse direction who knows what they built there...
		while node.name ~= "air" and y > y_min do
			y = y - 1
			node = minetest.get_node_or_nil({x = x, y = y, z = z})
			if node == nil then
				break
			end
		end
	end
	if node == nil then
		return y_org
	end
	while node.name == "air" and y > y_min do
		y = y - 1
		node = minetest.get_node_or_nil({x = x, y = y, z = z})
		while node == nil and y > y_min do
			y = y - 1
			node = minetest.get_node_or_nil({x = x, y = y, z = z})
		end
		if node == nil then
			return y_org
		end
	end
	if y == y_min then
		return y_org
	end
	return math.max(math.min(y, y_max), y_min)
end

local function find_nether_target_y(x, y, z)
	local target_y = find_target_y(x, y, z, nether_ymin + 4, nether_ymax - 25) + 1
	minetest.log("verbose", "[mcl_portal] Found Nether target altitude: " .. tostring(target_y) .. " for pos. " .. minetest.pos_to_string({x = x, y = y, z = z}))
	return target_y
end

local function find_overworld_target_y(x, y, z)
	local target_y = find_target_y(x, y, z, overworld_ymin + 4, overworld_ymax - 25) + 1
	local node = minetest.get_node({x = x, y = target_y - 1, z = z})
	if not node then
		return target_y
	end
	local nn = node.name
	if nn ~= "air" and minetest.get_item_group(nn, "water") == 0 then
		target_y = target_y + 1
	end
	minetest.log("verbose", "[mcl_portal] Found Overworld target altitude: " .. tostring(target_y) .. " for pos. " .. minetest.pos_to_string({x = x, y = y, z = z}))
	return target_y
end


local function update_target(pos, target, time_str)
	local stack = {{x = pos.x, y = pos.y, z = pos.z}}
	while #stack > 0 do
		local i = #stack
		local meta = minetest.get_meta(stack[i])
		if meta:get_string("portal_time") == time_str then
			stack[i] = nil -- Already updated, skip it
		else
			local node = minetest.get_node(stack[i])
			local portal = node.name == "mcl_portals:portal"
			if not portal then
				stack[i] = nil
			else
				local x, y, z = stack[i].x, stack[i].y, stack[i].z
				meta:set_string("portal_time", time_str)
				meta:set_string("portal_target", target)
				stack[i].y  = y - 1
				stack[i + 1] = {x = x, y = y + 1, z = z}
				if node.param2 == 0 then
					stack[i + 2] = {x = x - 1, y = y, z = z}
					stack[i + 3] = {x = x + 1, y = y, z = z}
				else
					stack[i + 2] = {x = x, y = y, z = z - 1}
					stack[i + 3] = {x = x, y = y, z = z + 1}
				end
			end
		end
	end
end

local function ecb_setup_target_portal(blockpos, action, calls_remaining, param)
	-- param.: srcx, srcy, srcz, dstx, dsty, dstz, srcdim, ax1, ay1, az1, ax2, ay2, az2

	local portal_search = function(target, p1, p2)
		local portal_nodes = minetest.find_nodes_in_area(p1, p2, "mcl_portals:portal")
		local portal_pos = false
		if portal_nodes and #portal_nodes > 0 then
			-- Found some portal(s), use nearest:
			portal_pos = {x = portal_nodes[1].x, y = portal_nodes[1].y, z = portal_nodes[1].z}
			local nearest_distance = vector.distance(target, portal_pos)
			for n = 2, #portal_nodes do
				local distance = vector.distance(target, portal_nodes[n])
				if distance < nearest_distance then
					portal_pos = {x = portal_nodes[n].x, y = portal_nodes[n].y, z = portal_nodes[n].z}
					nearest_distance = distance
				end
			end
		end -- here we have the best portal_pos
		return portal_pos
	end

	if calls_remaining <= 0 then
		minetest.log("action", "[mcl_portal] Area for destination Nether portal emerged!")
		local src_pos = {x = param.srcx, y = param.srcy, z = param.srcz}
		local dst_pos = {x = param.dstx, y = param.dsty, z = param.dstz}
		local meta = minetest.get_meta(src_pos)
		local portal_pos = portal_search(dst_pos, {x = param.ax1, y = param.ay1, z = param.az1}, {x = param.ax2, y = param.ay2, z = param.az2})

		if portal_pos == false then
			minetest.log("verbose", "[mcl_portal] No portal in area " .. minetest.pos_to_string({x = param.ax1, y = param.ay1, z = param.az1}) .. "-" .. minetest.pos_to_string({x = param.ax2, y = param.ay2, z = param.az2}))
			-- Need to build arrival portal:
			local org_dst_y = dst_pos.y
			if param.srcdim == "overworld" then
				dst_pos.y = find_nether_target_y(dst_pos.x, dst_pos.y, dst_pos.z)
			else
				dst_pos.y = find_overworld_target_y(dst_pos.x, dst_pos.y, dst_pos.z)
			end
			if math.abs(org_dst_y - dst_pos.y) >= PORTAL_SEARCH_ALTITUDE / 2 then
				portal_pos = portal_search(dst_pos,
					{x = dst_pos.x - PORTAL_SEARCH_HALF_CHUNK, y = math.floor(dst_pos.y - PORTAL_SEARCH_ALTITUDE / 2), z = dst_pos.z - PORTAL_SEARCH_HALF_CHUNK},
					{x = dst_pos.x + PORTAL_SEARCH_HALF_CHUNK, y = math.ceil(dst_pos.y + PORTAL_SEARCH_ALTITUDE / 2), z = dst_pos.z + PORTAL_SEARCH_HALF_CHUNK}
				)
			end
			if portal_pos == false then
				minetest.log("verbose", "[mcl_portal] 2nd attempt: No portal in area " .. minetest.pos_to_string({x = dst_pos.x - PORTAL_SEARCH_HALF_CHUNK, y = math.floor(dst_pos.y - PORTAL_SEARCH_ALTITUDE / 2), z = dst_pos.z - PORTAL_SEARCH_HALF_CHUNK}) .. "-" .. minetest.pos_to_string({x = dst_pos.x + PORTAL_SEARCH_HALF_CHUNK, y = math.ceil(dst_pos.y + PORTAL_SEARCH_ALTITUDE / 2), z = dst_pos.z + PORTAL_SEARCH_HALF_CHUNK}))
				local width, height = 2, 3
				portal_pos = mcl_portals.build_nether_portal(dst_pos, width, height)
			end
		end

		local target_meta = minetest.get_meta(portal_pos)
		local p3 = minetest.string_to_pos(target_meta:get_string("portal_frame1"))
		local p4 = minetest.string_to_pos(target_meta:get_string("portal_frame2"))
		if p3 and p4 then
			portal_pos = vector.divide(vector.add(p3, p4), 2.0)
			portal_pos.y = math.min(p3.y, p4.y)
			portal_pos = vector.round(portal_pos)
			local node = minetest.get_node(portal_pos)
			if node and node.name ~= "mcl_portals:portal" then
				portal_pos = {x = p3.x, y = p3.y, z = p3.z}
				if minetest.get_node(portal_pos).name == "mcl_core:obsidian" then
					-- Old-version portal:
					if p4.z == p3.z then
						portal_pos = {x = p3.x + 1, y = p3.y + 1, z = p3.z}
					else
						portal_pos = {x = p3.x, y = p3.y + 1, z = p3.z + 1}
					end
				end
			end
		end
		local time_str = tostring(minetest.get_us_time())
		local target = minetest.pos_to_string(portal_pos)

		update_target(src_pos, target, time_str)
	end
end

local function nether_portal_get_target_position(src_pos)
	local _, current_dimension = mcl_worlds.y_to_layer(src_pos.y)
	local x, y, z, y_min, y_max = 0, 0, 0, 0, 0
	if current_dimension == "nether" then
		x = math.floor(nether_to_overworld(src_pos.x) + 0.5)
		z = math.floor(nether_to_overworld(src_pos.z) + 0.5)
		y = math.floor((math.min(math.max(src_pos.y, nether_ymin), nether_ymax) - nether_ymin) / nether_dy * overworld_dy + overworld_ymin + 0.5)
		y_min = overworld_ymin
		y_max = overworld_ymax
	else -- overworld:
		x = math.floor(src_pos.x / OVERWORLD_TO_NETHER_SCALE + 0.5)
		z = math.floor(src_pos.z / OVERWORLD_TO_NETHER_SCALE + 0.5)
		y = math.floor((math.min(math.max(src_pos.y, overworld_ymin), overworld_ymax) - overworld_ymin) / overworld_dy * nether_dy + nether_ymin + 0.5)
		y_min = nether_ymin
		y_max = nether_ymax
	end
	return x, y, z, current_dimension, y_min, y_max
end

local function find_or_create_portal(src_pos)
	local x, y, z, cdim, y_min, y_max = nether_portal_get_target_position(src_pos)
	local pos1 = {x = x - PORTAL_SEARCH_HALF_CHUNK, y = math.max(y_min, math.floor(y - PORTAL_SEARCH_ALTITUDE / 2)), z = z - PORTAL_SEARCH_HALF_CHUNK}
	local pos2 = {x = x + PORTAL_SEARCH_HALF_CHUNK, y = math.min(y_max, math.ceil(y + PORTAL_SEARCH_ALTITUDE / 2)), z = z + PORTAL_SEARCH_HALF_CHUNK}
	if pos1.y == y_min then
		pos2.y = math.min(y_max, pos1.y + PORTAL_SEARCH_ALTITUDE)
	else
		if pos2.y == y_max then
			pos1.y = math.max(y_min, pos2.y - PORTAL_SEARCH_ALTITUDE)
		end
	end
	minetest.emerge_area(pos1, pos2, ecb_setup_target_portal, {srcx=src_pos.x, srcy=src_pos.y, srcz=src_pos.z, dstx=x, dsty=y, dstz=z, srcdim=cdim, ax1=pos1.x, ay1=pos1.y, az1=pos1.z, ax2=pos2.x, ay2=pos2.y, az2=pos2.z})
end

local function emerge_target_area(src_pos)
	local x, y, z, cdim, y_min, y_max = nether_portal_get_target_position(src_pos)
	local pos1 = {x = x - PORTAL_SEARCH_HALF_CHUNK, y = math.max(y_min + 2, math.floor(y - PORTAL_SEARCH_ALTITUDE / 2)), z = z - PORTAL_SEARCH_HALF_CHUNK}
	local pos2 = {x = x + PORTAL_SEARCH_HALF_CHUNK, y = math.min(y_max - 2, math.ceil(y + PORTAL_SEARCH_ALTITUDE / 2)), z = z + PORTAL_SEARCH_HALF_CHUNK}
	minetest.emerge_area(pos1, pos2)
	pos1 = {x = x - 1, y = y_min, z = z - 1}
	pos2 = {x = x + 1, y = y_max, z = z + 1}
	minetest.emerge_area(pos1, pos2)
end

local function available_for_nether_portal(p)
	local nn = minetest.get_node(p).name
	local obsidian = nn == "mcl_core:obsidian"
	if nn ~= "air" and minetest.get_item_group(nn, "fire") ~= 1 then
		return false, obsidian
	end
	return true, obsidian
end

local function light_frame(x1, y1, z1, x2, y2, z2, build_frame)
	local build_frame = build_frame or false
	local orientation = 0
	if x1 == x2 then
		orientation = 1
	end
	local disperse = 50
	local pass = 1
	while true do
		local protection = false

		for x = x1 - 1 + orientation, x2 + 1 - orientation do
			for z = z1 - orientation, z2 + orientation do
				for y = y1 - 1, y2 + 1 do
					local frame = (x < x1) or (x > x2) or (y < y1) or (y > y2) or (z < z1) or (z > z2)
					if frame then
						if build_frame then
							if pass == 1 then
								if minetest.is_protected({x = x, y = y, z = z}, "") then
									protection = true
									local offset_x = math.random(-disperse, disperse)
									local offset_z = math.random(-disperse, disperse)
									disperse = disperse + math.random(25, 177)
									if disperse > 5000 then
										return nil
									end
									x1, z1 = x1 + offset_x, z1 + offset_z
									x2, z2 = x2 + offset_x, z2 + offset_z
									local _, dimension = mcl_worlds.y_to_layer(y1)
									local height = math.abs(y2 - y1)
									y1 = (y1 + y2) / 2
									if dimension == "nether" then
										y1 = find_nether_target_y(math.min(x1, x2), y1, math.min(z1, z2))
									else
										y1 = find_overworld_target_y(math.min(x1, x2), y1, math.min(z1, z2))
									end
									y2 = y1 + height
									break
								end
							else
								minetest.set_node({x = x, y = y, z = z}, {name = "mcl_core:obsidian"})
							end
						end
					else
						if not build_frame or pass == 2 then
							local node = minetest.get_node({x = x, y = y, z = z})
							minetest.set_node({x = x, y = y, z = z}, {name = "mcl_portals:portal", param2 = orientation})
						end
					end
					if not frame and pass == 2 then
						local meta = minetest.get_meta({x = x, y = y, z = z})
						-- Portal frame corners
						meta:set_string("portal_frame1", minetest.pos_to_string({x = x1, y = y1, z = z1}))
						meta:set_string("portal_frame2", minetest.pos_to_string({x = x2, y = y2, z = z2}))
						-- Portal target coordinates
						meta:set_string("portal_target", "")
						-- Portal last teleportation time
						meta:set_string("portal_time", tostring(0))
					end
				end
				if protection then
					break
				end
			end
			if protection then
				break
			end
		end
		if build_frame == false or pass == 2 then
			break
		end
		if build_frame and not protection and pass == 1 then
			pass = 2
		end
	end
	emerge_target_area({x = x1, y = y1, z = z1})
	return {x = x1, y = y1, z = z1}
end

--Build arrival portal
function mcl_portals.build_nether_portal(pos, width, height, orientation)
	local height = height or FRAME_SIZE_Y_MIN - 2
	local width = width or FRAME_SIZE_X_MIN - 2
	local orientation = orientation or math.random(0, 1)

	if orientation == 0 then
		minetest.load_area({x = pos.x - 3, y = pos.y - 1, z = pos.z - width * 2}, {x = pos.x + width + 2, y = pos.y + height + 2, z = pos.z + width * 2})
	else
		minetest.load_area({x = pos.x - width * 2, y = pos.y - 1, z = pos.z - 3}, {x = pos.x + width * 2, y = pos.y + height + 2, z = pos.z + width + 2})
	end

	pos = light_frame(pos.x, pos.y, pos.z, pos.x + (1 - orientation) * (width - 1), pos.y + height - 1, pos.z + orientation * (width - 1), true)

	-- Clear some space around:
	for x = pos.x - math.random(2 + (width-2)*(  orientation), 5 + (2*width-5)*(  orientation)), pos.x + width*(1-orientation) + math.random(2+(width-2)*(  orientation), 4 + (2*width-4)*(  orientation)) do
	for z = pos.z - math.random(2 + (width-2)*(1-orientation), 5 + (2*width-5)*(1-orientation)), pos.z + width*(  orientation) + math.random(2+(width-2)*(1-orientation), 4 + (2*width-4)*(1-orientation)) do
	for y = pos.y - 1, pos.y + height + math.random(1,6) do
		local nn = minetest.get_node({x = x, y = y, z = z}).name
		if nn ~= "mcl_core:obsidian" and nn ~= "mcl_portals:portal" and minetest.registered_nodes[nn].is_ground_content and not minetest.is_protected({x = x, y = y, z = z}, "") then
			minetest.remove_node({x = x, y = y, z = z})
		end
	end
	end
	end

	-- Build obsidian platform:
	for x = pos.x - orientation, pos.x + orientation + (width - 1) * (1 - orientation), 1 + orientation do
		for z = pos.z - 1 + orientation, pos.z + 1 - orientation + (width - 1) * orientation, 2 - orientation do
			local pp = {x = x, y = pos.y - 1, z = z}
			local nn = minetest.get_node(pp).name
			if not minetest.registered_nodes[nn].is_ground_content and not minetest.is_protected(pp, "") then
				minetest.set_node(pp, {name = "mcl_core:obsidian"})
			end
		end
	end

	minetest.log("action", "[mcl_portal] Destination Nether portal generated at "..minetest.pos_to_string(pos).."!")

	return pos
end

local function check_and_light_shape(pos, orientation)
	local stack = {{x = pos.x, y = pos.y, z = pos.z}}
	local node_list = {}
	local node_counter = 0
	-- Search most low node from the left (pos1) and most right node from the top (pos2)
	local pos1 = {x = pos.x, y = pos.y, z = pos.z}
	local pos2 = {x = pos.x, y = pos.y, z = pos.z}

	local wrong_portal_nodes_clean_up = function(node_list)
		for i = 1, #node_list do
			local meta = minetest.get_meta(node_list[i])
			meta:set_string("portal_time", "")
		end
		return false
	end

	while #stack > 0 do
		local i = #stack
		local meta = minetest.get_meta(stack[i])
		local target = meta:get_string("portal_time")
		if target and target == "-2" then
			stack[i] = nil -- Already checked, skip it
		else
			local good, obsidian = available_for_nether_portal(stack[i])
			if obsidian then
				stack[i] = nil
			else
				if (not good) or (node_counter >= PORTAL_NODES_MAX) then
					return wrong_portal_nodes_clean_up(node_list)
				end
				local x, y, z = stack[i].x, stack[i].y, stack[i].z
				meta:set_string("portal_time", "-2")
				node_counter = node_counter + 1
				node_list[node_counter] = {x = x, y = y, z = z}
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

	if node_counter < PORTAL_NODES_MIN then
		return wrong_portal_nodes_clean_up(node_list)
	end

	-- Limit rectangles width and height
	if math.abs(pos2.x - pos1.x + pos2.z - pos1.z) + 3 > FRAME_SIZE_X_MAX or math.abs(pos2.y - pos1.y) + 3 > FRAME_SIZE_Y_MAX then
		return wrong_portal_nodes_clean_up(node_list)
	end

	for i = 1, node_counter do
		local node_pos = node_list[i]
		local node = minetest.get_node(node_pos)
		minetest.set_node(node_pos, {name = "mcl_portals:portal", param2 = orientation})
		local meta = minetest.get_meta(node_pos)
		meta:set_string("portal_frame1", minetest.pos_to_string(pos1))
		meta:set_string("portal_frame2", minetest.pos_to_string(pos2))
		meta:set_string("portal_time", tostring(0))
		meta:set_string("portal_target", "")
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
	local orientation = math.random(0, 1)
	for orientation_iteration = 1, 2 do
		if check_and_light_shape(pos, orientation) then
			return true
		end
		orientation = 1 - orientation
	end
	return false
end

local function update_portal_time(pos, time_str)
	local stack = {{x = pos.x, y = pos.y, z = pos.z}}
	while #stack > 0 do
		local i = #stack
		local meta = minetest.get_meta(stack[i])
		if meta:get_string("portal_time") == time_str then
			stack[i] = nil -- Already updated, skip it
		else
			local node = minetest.get_node(stack[i])
			local portal = node.name == "mcl_portals:portal"
			if not portal then
				stack[i] = nil
			else
				local x, y, z = stack[i].x, stack[i].y, stack[i].z
				meta:set_string("portal_time", time_str)
				stack[i].y  = y - 1
				stack[i + 1] = {x = x, y = y + 1, z = z}
				if node.param2 == 0 then
					stack[i + 2] = {x = x - 1, y = y, z = z}
					stack[i + 3] = {x = x + 1, y = y, z = z}
				else
					stack[i + 2] = {x = x, y = y, z = z - 1}
					stack[i + 3] = {x = x, y = y, z = z + 1}
				end
			end
		end
	end
end

local function prepare_target(pos)
	local meta, us_time = minetest.get_meta(pos), minetest.get_us_time()
	local portal_time = tonumber(meta:get_string("portal_time")) or 0
	local delta_time_us = us_time - portal_time
	local pos1, pos2 = minetest.string_to_pos(meta:get_string("portal_frame1")), minetest.string_to_pos(meta:get_string("portal_frame2"))
	if delta_time_us <= DESTINATION_EXPIRES then
		-- Destination point must be still cached according to https://minecraft.gamepedia.com/Nether_portal
		return update_portal_time(pos, tostring(us_time))
	end
	-- No cached destination point
	find_or_create_portal(pos)
end

-- Teleportation cooloff for some seconds, to prevent back-and-forth teleportation
local function stop_teleport_cooloff(o)
	mcl_portals.nether_portal_cooloff[o] = false
	touch_chatter_prevention[o] = nil
end

local function teleport_cooloff(obj)
	if obj:is_player() then
		minetest.after(TELEPORT_COOLOFF, stop_teleport_cooloff, obj)
	else
		minetest.after(MOB_TELEPORT_COOLOFF, stop_teleport_cooloff, obj)
	end
end

-- Teleport function
local function teleport_no_delay(obj, pos)
	local is_player = obj:is_player()
	if (not obj:get_luaentity()) and (not is_player) then
		return
	end

	local objpos = obj:get_pos()
	if objpos == nil then
		return
	end

	if mcl_portals.nether_portal_cooloff[obj] then
		return
	end
	-- If player stands, player is at ca. something+0.5
	-- which might cause precision problems, so we used ceil.
	objpos.y = math.ceil(objpos.y)

	if minetest.get_node(objpos).name ~= "mcl_portals:portal" then
		return
	end

	local meta = minetest.get_meta(pos)
	local delta_time = minetest.get_us_time() - (tonumber(meta:get_string("portal_time")) or 0)
	local target = minetest.string_to_pos(meta:get_string("portal_target"))
	if delta_time > DESTINATION_EXPIRES or target == nil then
		-- Area not ready yet - retry after a second
		return minetest.after(1, teleport_no_delay, obj, pos)
	end

	-- Enable teleportation cooloff for some seconds, to prevent back-and-forth teleportation
	teleport_cooloff(obj)
	mcl_portals.nether_portal_cooloff[obj] = true

	-- Teleport
	obj:set_pos(target)

	if is_player then
		mcl_worlds.dimension_change(obj, mcl_worlds.pos_to_dimension(target))
		minetest.sound_play("mcl_portals_teleport", {pos=target, gain=0.5, max_hear_distance = 16}, true)
		local name = obj:get_player_name()
		minetest.log("action", "[mcl_portal] "..name.." teleported to Nether portal at "..minetest.pos_to_string(target)..".")
	end
end

local function prevent_portal_chatter(obj)
	local time_us = minetest.get_us_time()
	local chatter = touch_chatter_prevention[obj] or 0
	touch_chatter_prevention[obj] = time_us
	minetest.after(TOUCH_CHATTER_TIME, function(o)
		if not o or not touch_chatter_prevention[o] then
			return
		end
		if minetest.get_us_time() - touch_chatter_prevention[o] >= TOUCH_CHATTER_TIME_US then
			touch_chatter_prevention[o] = nil
		end
	end, obj)
	return time_us - chatter > TOUCH_CHATTER_TIME_US
end

local function animation(player, playername)
	local chatter = touch_chatter_prevention[player] or 0
	if mcl_portals.nether_portal_cooloff[player] or minetest.get_us_time() - chatter < TOUCH_CHATTER_TIME_US then
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
	-- Call prepare_target() first because it might take a long
	prepare_target(portal_pos)
	-- Prevent quick back-and-forth teleportation
	if not mcl_portals.nether_portal_cooloff[obj] then
		local creative_enabled = minetest.is_creative_enabled(name)
		if creative_enabled then
			return teleport_no_delay(obj, portal_pos)
		end
		minetest.after(TELEPORT_DELAY, teleport_no_delay, obj, portal_pos)
	end
end

minetest.register_abm({
	label = "Nether portal teleportation and particles",
	nodenames = {"mcl_portals:portal"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		local o = node.param2		-- orientation
		local d = math.random(0, 1)	-- direction
		local time = math.random() * 1.9 + 0.5
		local velocity, acceleration
		if o == 1 then
			velocity	= {x = math.random() * 0.7 + 0.3,	y = math.random() - 0.5,	z = math.random() - 0.5}
			acceleration	= {x = math.random() * 1.1 + 0.3,	y = math.random() - 0.5,	z = math.random() - 0.5}
		else
			velocity	= {x = math.random() - 0.5,		y = math.random() - 0.5,	z = math.random() * 0.7 + 0.3}
			acceleration	= {x = math.random() - 0.5,		y = math.random() - 0.5,	z = math.random() * 1.1 + 0.3}
		end
		local distance = vector.add(vector.multiply(velocity, time), vector.multiply(acceleration, time * time / 2))
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
		distance = vector.subtract(pos, distance)
		for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 15)) do
			if obj:is_player() then
				minetest.add_particlespawner({
					amount = node_particles_allowed_level + 1,
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
		for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 1)) do	--maikerumine added for objects to travel
			local lua_entity = obj:get_luaentity()				--maikerumine added for objects to travel
			if (obj:is_player() or lua_entity) and prevent_portal_chatter(obj) then
				teleport(obj, pos)
			end
		end
	end,
})


--[[ ITEM OVERRIDES ]]

local longdesc = minetest.registered_nodes["mcl_core:obsidian"]._doc_items_longdesc
longdesc = longdesc .. "\n" .. S("Obsidian is also used as the frame of Nether portals.")
local usagehelp = S("To open a Nether portal, place an upright frame of obsidian with a width of at least 4 blocks and a height of 5 blocks, leaving only air in the center. After placing this frame, light a fire in the obsidian frame. Nether portals only work in the Overworld and the Nether.")

minetest.override_item("mcl_core:obsidian", {
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usagehelp,
	on_destruct = destroy_nether_portal,
	_on_ignite = function(user, pointed_thing)
		local x, y, z = pointed_thing.under.x, pointed_thing.under.y, pointed_thing.under.z
		-- Check empty spaces around obsidian and light all frames found:
		local portals_placed = 
				mcl_portals.light_nether_portal({x = x - 1, y = y, z = z}) or mcl_portals.light_nether_portal({x = x + 1, y = y, z = z}) or
				mcl_portals.light_nether_portal({x = x, y = y - 1, z = z}) or mcl_portals.light_nether_portal({x = x, y = y + 1, z = z}) or
				mcl_portals.light_nether_portal({x = x, y = y, z = z - 1}) or mcl_portals.light_nether_portal({x = x, y = y, z = z + 1})
		if portals_placed then
			minetest.log("action", "[mcl_portal] Nether portal activated at "..minetest.pos_to_string({x=x,y=y,z=z})..".")
			if minetest.get_modpath("doc") then
				doc.mark_entry_as_revealed(user:get_player_name(), "nodes", "mcl_portals:portal")

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

