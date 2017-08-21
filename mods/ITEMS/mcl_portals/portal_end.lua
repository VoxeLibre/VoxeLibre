-- Parameters

local TCAVE = 0.6
local nobj_cave = nil

local SPAWN_MIN = mcl_vars.mg_end_min+70
local SPAWN_MAX = mcl_vars.mg_end_min+98

local mg_name = minetest.get_mapgen_setting("mg_name")

-- 3D noise

local np_cave = {
	offset = 0,
	scale = 1,
	spread = {x = 384, y = 128, z = 384}, -- squashed 3:1
	seed = 59033,
	octaves = 5,
	persist = 0.7
}
-- Portal frame material
local portal_frame = "mcl_nether:quartz_block"

-- Table of objects (including players) which recently teleported by a
-- End portal. Those objects have a brief cooloff period before they
-- can teleport again. This prevents annoying back-and-forth teleportation.
local portal_cooloff = {}

-- Destroy portal if pos (portal frame or portal node) got destroyed
local destroy_portal = function(pos)
	-- Deactivate Nether portal
	local meta = minetest.get_meta(pos)
	local p1 = minetest.string_to_pos(meta:get_string("portal_frame1"))
	local p2 = minetest.string_to_pos(meta:get_string("portal_frame2"))
	if not p1 or not p2 then
		return
	end

	local first = true

	-- p1 metadata of first node
	local mp1
	for x = p1.x, p2.x do
	for y = p1.y, p2.y do
	for z = p1.z, p2.z do
		local p = vector.new(x, y, z)
		local m = minetest.get_meta(p)
		if first then
			--[[ Only proceed if the first node still has metadata.
			If it doesn't have metadata, another node propably triggred the delection
			routine earlier, so we bail out earlier to avoid an infinite cascade
			of on_destroy events. ]]
			mp1 = minetest.string_to_pos(m:get_string("portal_frame1"))
			if not mp1 then
				return
			end
		end
		local nn = minetest.get_node(p).name
		if nn == portal_frame or nn == "mcl_portals:portal_end" then
			-- Remove portal nodes, but not myself
			if nn == "mcl_portals:portal_end" and not vector.equals(p, pos) then
				minetest.remove_node(p)
			end
			-- Clear metadata of portal nodes and the frame
			m:set_string("portal_frame1", "")
			m:set_string("portal_frame2", "")
			m:set_string("portal_target", "")
		end
		first = false
	end
	end
	end
end

-- Nodes
minetest.register_node("mcl_portals:portal_end", {
	description = "End Portal",
	_doc_items_longdesc = "An End portal teleports creatures and objects to the mysterious End dimension (and back!).",
	_doc_items_usagehelp = "Stand in the portal for a moment to activate the teleportation. Entering such a portal for the first time will create a new portal in your destination. End portal which were built in the End will lead back to the Overworld. An End portal is destroyed if any of its surrounding frame blocks is destroyed.",
	tiles = {
		"blank.png",
		"blank.png",
		"blank.png",
		"blank.png",
		{
			name = "mcl_portals_end_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
		{
			name = "mcl_portals_end_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	use_texture_alpha = true,
	walkable = false,
	diggable = false,
	pointable = false,
	buildable_to = false,
	is_ground_content = false,
	drop = "",
	-- This is 15 in MC.
	light_source = 14,
	post_effect_color = {a = 192, r = 0, g = 0, b = 0},
	alpha = 192,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1,  0.5, 0.5, 0.1},
		},
	},
	groups = {not_in_creative_inventory = 1},
	on_destruct = destroy_portal,

	_mcl_hardness = -1,
	_mcl_blast_resistance = 18000000,
})

local function build_end_portal(pos, target3)
	local p = {x = pos.x - 1, y = pos.y - 1, z = pos.z}
	local p1 = {x = pos.x - 1, y = pos.y - 1, z = pos.z}
	local p2 = {x = p1.x + 3, y = p1.y + 4, z = p1.z}

	for i = 1, 4 do
		minetest.set_node(p, {name = portal_frame})
		p.y = p.y + 1
	end
	for i = 1, 3 do
		minetest.set_node(p, {name = portal_frame})
		p.x = p.x + 1
	end
	for i = 1, 4 do
		minetest.set_node(p, {name = portal_frame})
		p.y = p.y - 1
	end
	for i = 1, 3 do
		minetest.set_node(p, {name = portal_frame})
		p.x = p.x - 1
	end

	for x = p1.x, p2.x do
	for y = p1.y, p2.y do
		p = {x = x, y = y, z = p1.z}
		if not (x == p1.x or x == p2.x or y == p1.y or y == p2.y) then
			minetest.set_node(p, {name = "mcl_portals:portal_end", param2 = 0})
		end
		local meta = minetest.get_meta(p)
		meta:set_string("portal_frame1", minetest.pos_to_string(p1))
		meta:set_string("portal_frame2", minetest.pos_to_string(p2))
		meta:set_string("portal_target", minetest.pos_to_string(target3))

		for z = -2, 2 do
			if z ~= 0 then
				local newp = {x=p.x, y=p.y, z=p.z+z}
				if y ~= p1.y then
					if minetest.registered_nodes[
							minetest.get_node(newp).name].is_ground_content then
						minetest.remove_node(newp)
					end
				else
					-- Build obsidian platform if floating
					local newp_below = table.copy(newp)
					newp_below.y = newp.y - 1
					if minetest.get_node(newp).name == "air" and minetest.get_node(newp_below).name == "air" then
						minetest.set_node(newp, {name="mcl_core:obsidian"})
					end

				end
			end
		end
	end
	end
end

local function find_end_target3_y2(target3_x, target3_z)
	local start_y = math.random(SPAWN_MIN, SPAWN_MAX) -- Search start
	if not nobj_cave then
		nobj_cave = minetest.get_perlin(np_cave)
	end
	local air = 0 -- Consecutive air nodes found

	for y = start_y, SPAWN_MIN, -1 do
		local nval_cave = nobj_cave:get3d({x = target3_x, y = y, z = target3_z})

		if nval_cave > TCAVE then -- Cavern
			air = air + 1
		else -- Not cavern, check if 4 nodes of space above
			if air >= 4 then
				return y + 2
			else -- Not enough space, reset air to zero
				air = 0
			end
		end
	end

	return start_y -- Fallback
end

local function move_check2(p1, max, dir)
	local p = {x = p1.x, y = p1.y, z = p1.z}
	local d = math.abs(max - p1[dir]) / (max - p1[dir])

	while p[dir] ~= max do
		p[dir] = p[dir] + d
		if minetest.get_node(p).name ~= portal_frame then
			return false
		end
		-- Abort if any of the portal frame blocks already has metadata.
		-- This mod does not yet portals which neighbor each other directly.
		-- TODO: Reorganize the way how portal frame coordinates are stored.
		local meta = minetest.get_meta(p)
		local p1 = meta:get_string("portal_frame1")
		if minetest.string_to_pos(p1) ~= nil then
			return false
		end
	end

	return true
end

local function check_end_portal(p1, p2)
	if p1.x ~= p2.x then
		if not move_check2(p1, p2.x, "x") then
			return false
		end
		if not move_check2(p2, p1.x, "x") then
			return false
		end
	elseif p1.z ~= p2.z then
		if not move_check2(p1, p2.z, "z") then
			return false
		end
		if not move_check2(p2, p1.z, "z") then
			return false
		end
	else
		return false
	end

	if not move_check2(p1, p2.y, "y") then
		return false
	end
	if not move_check2(p2, p1.y, "y") then
		return false
	end

	return true
end

local function is_end_portal(pos)
	for d = -3, 3 do
		for y = -4, 4 do
			local px = {x = pos.x + d, y = pos.y + y, z = pos.z}
			local pz = {x = pos.x, y = pos.y + y, z = pos.z + d}

			if check_end_portal(px, {x = px.x + 3, y = px.y + 4, z = px.z}) then
				return px, {x = px.x + 3, y = px.y + 4, z = px.z}
			end
			if check_end_portal(pz, {x = pz.x, y = pz.y + 4, z = pz.z + 3}) then
				return pz, {x = pz.x, y = pz.y + 4, z = pz.z + 3}
			end
		end
	end
end

local function make_end_portal(pos)
	local p1, p2 = is_end_portal(pos)
	if not p1 or not p2 then
		return false
	end

	for d = 1, 2 do
	for y = p1.y + 1, p2.y - 1 do
		local p
		if p1.z == p2.z then
			p = {x = p1.x + d, y = y, z = p1.z}
		else
			p = {x = p1.x, y = y, z = p1.z + d}
		end
		if minetest.get_node(p).name ~= "air" then
			return false
		end
	end
	end

	local param2
	if p1.z == p2.z then
		param2 = 0
	else
		param2 = 1
	end

	local target3 = {x = p1.x, y = p1.y, z = p1.z}
	target3.x = target3.x + 1
	if target3.y < mcl_vars.mg_end_max and target3.y > mcl_vars.mg_end_min then
		if mg_name == "flat" then
			target3.y = mcl_vars.mg_bedrock_overworld_max + 5
		else
			target3.y = math.random(mcl_vars.mg_overworld_min + 40, mcl_vars.mg_overworld_min + 96)
		end
	else
		target3.y = find_end_target3_y2(target3.x, target3.z)
	end

	for d = 0, 3 do
	for y = p1.y, p2.y do
		local p = {}
		if param2 == 0 then
			p = {x = p1.x + d, y = y, z = p1.z}
		else
			p = {x = p1.x, y = y, z = p1.z + d}
		end
		if minetest.get_node(p).name == "air" then
			minetest.set_node(p, {name = "mcl_portals:portal_end", param2 = param2})
		end
		local meta = minetest.get_meta(p)

		-- Portal frame corners
		meta:set_string("portal_frame1", minetest.pos_to_string(p1))
		meta:set_string("portal_frame2", minetest.pos_to_string(p2))

		-- Portal target coordinates
		meta:set_string("portal_target", minetest.pos_to_string(target3))
	end
	end

	return true
end

minetest.register_abm({
	label = "End portal teleportation",
	nodenames = {"mcl_portals:portal_end"},
	interval = 1,
	chance = 2,
	action = function(pos, node)
		for _,obj in ipairs(minetest.get_objects_inside_radius(pos,1)) do --maikerumine added for objects to travel
		local lua_entity = obj:get_luaentity() --maikerumine added for objects to travel
			if obj:is_player() or lua_entity then
				-- No rapid back-and-forth teleportatio
				if portal_cooloff[obj] then
					return
				end
				local meta = minetest.get_meta(pos)
				local target3 = minetest.string_to_pos(meta:get_string("portal_target"))
				if target3 then
					-- force emerge of target3 area
					minetest.get_voxel_manip():read_from_map(target3, target3)
					if not minetest.get_node_or_nil(target3) then
						minetest.emerge_area(
							vector.subtract(target3, 4), vector.add(target3, 4))
					end

					-- teleport the object
					minetest.after(3, function(obj, pos, target3)
						-- No rapid back-and-forth teleportatio
						if portal_cooloff[obj] then
							return
						end
						local objpos = obj:getpos()
						if objpos == nil then
							return
						end
						-- If player stands, player is at ca. something+0.5
						-- which might cause precision problems, so we used ceil.
						objpos.y = math.ceil(objpos.y)
						if minetest.get_node(objpos).name ~= "mcl_portals:portal_end" then
							return
						end

						-- Build destination
						local function check_and_build_end_portal(pos, target3)
							local n = minetest.get_node_or_nil(target3)
							if n and n.name ~= "mcl_portals:portal_end" then
								build_end_portal(target3, pos)
								minetest.after(2, check_and_build_end_portal, pos, target3)
							elseif not n then
								minetest.after(1, check_and_build_end_portal, pos, target3)
							end
						end

						check_and_build_end_portal(pos, target3)

						-- Teleport
						obj:setpos(target3)
						minetest.sound_play("mcl_portals_teleport", {pos=target3, gain=0.5, max_hear_distance = 16})

						-- Enable teleportation cooloff to prevent frequent back-and-forth teleportation
						portal_cooloff[obj] = true
						minetest.after(3, function(o)
							portal_cooloff[o] = false
						end, obj)

					end, obj, pos, target3)
				end
			end
		end
	end,
})


--[[ ITEM OVERRIDES ]]

local portal_open_help = "To open an End portal, place an upright frame of quartz blocks with a length of 4 blocks and a height of 5 blocks, leaving only air in the center. After placing this frame, use an eye of ender on the frame. The eye of ender is destroyed in the process."

-- Frame material
minetest.override_item(portal_frame, {
	_doc_items_longdesc = "A block of quartz can be used to create End portals.",
	_doc_items_usagehelp = portal_open_help,
	on_destruct = destroy_portal,
})

-- Portal opener
minetest.override_item("mcl_end:ender_eye", {
	_doc_items_longdesc = "An eye of ender can be used to open End portals.",
	_doc_items_usagehelp = portal_open_help,
	on_place = function(itemstack, user, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		-- If used on portal frame, open a portal
		if pointed_thing.under and node.name == portal_frame then
			local opened = make_end_portal(pointed_thing.under)
			if opened then
				if minetest.get_modpath("doc") then
					doc.mark_entry_as_revealed(user:get_player_name(), "nodes", "mcl_portals:portal_end")
				end
				minetest.sound_play(
					"fire_flint_and_steel",
					{pos = pointed_thing.above, gain = 0.5, max_hear_distance = 16})
				if not minetest.settings:get_bool("creative_mode") then
					itemstack:take_item() -- 1 use
				end
			end
		end

		return itemstack
	end,
})

