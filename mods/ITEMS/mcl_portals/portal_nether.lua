-- Parameters

local TCAVE = 0.6
local nobj_cave = nil

-- Portal frame sizes
local FRAME_SIZE_X_MIN = 4
local FRAME_SIZE_Y_MIN = 5
local FRAME_SIZE_X_MAX = 23
local FRAME_SIZE_Y_MAX = 23

local mg_name = minetest.get_mapgen_setting("mg_name")

-- 3D noise
local np_cave = {
	offset = 0,
	scale = 1,
	spread = {x = 384, y = 128, z = 384},
	seed = 59033,
	octaves = 5,
	persist = 0.7
}

-- Table of objects (including players) which recently teleported by a
-- Nether portal. Those objects have a brief cooloff period before they
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

	local counter = 1

	local mp1
	for x = p1.x, p2.x do
	for y = p1.y, p2.y do
	for z = p1.z, p2.z do
		local p = vector.new(x, y, z)
		local m = minetest.get_meta(p)
		if counter == 2 then
			--[[ Only proceed if the second node still has metadata.
			(first node is a corner and not needed for the portal)
			If it doesn't have metadata, another node propably triggred the delection
			routine earlier, so we bail out earlier to avoid an infinite cascade
			of on_destroy events. ]]
			mp1 = minetest.string_to_pos(m:get_string("portal_frame1"))
			if not mp1 then
				return
			end
		end
		local nn = minetest.get_node(p).name
		if nn == "mcl_core:obsidian" or nn == "mcl_portals:portal" then
			-- Remove portal nodes, but not myself
			if nn == "mcl_portals:portal" and not vector.equals(p, pos) then
				minetest.remove_node(p)
			end
			-- Clear metadata of portal nodes and the frame
			m:set_string("portal_frame1", "")
			m:set_string("portal_frame2", "")
			m:set_string("portal_target", "")
		end
		counter = counter + 1
	end
	end
	end
end

minetest.register_node("mcl_portals:portal", {
	description = "Nether Portal",
	_doc_items_longdesc = "A Nether portal teleports creatures and objects to the hot and dangerous Nether dimension (and back!). Enter at your own risk!",
	_doc_items_usagehelp = "Stand in the portal for a moment to activate the teleportation. Entering a Nether portal for the first time will also create a new portal in the other dimension. If a Nether portal has been built in the Nether, it will lead to the Overworld. A Nether portal is destroyed if the any of the obsidian which surrounds it is destroyed, or if it was caught in an explosion.",

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
				length = 0.5,
			},
		},
		{
			name = "mcl_portals_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
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
	light_source = 11,
	post_effect_color = {a = 180, r = 51, g = 7, b = 89},
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
	_mcl_blast_resistance = 0,
})

-- Functions
--Build arrival portal
local function build_portal(pos, target, is_rebuilding)
	local p = {x = pos.x - 1, y = pos.y - 1, z = pos.z}
	local p1 = {x = pos.x - 1, y = pos.y - 1, z = pos.z}
	local p2 = {x = p1.x + 3, y = p1.y + 4, z = p1.z}

	for i = 1, FRAME_SIZE_Y_MIN - 1 do
		minetest.set_node(p, {name = "mcl_core:obsidian"})
		p.y = p.y + 1
	end
	for i = 1, FRAME_SIZE_X_MIN - 1 do
		minetest.set_node(p, {name = "mcl_core:obsidian"})
		p.x = p.x + 1
	end
	for i = 1, FRAME_SIZE_Y_MIN - 1 do
		minetest.set_node(p, {name = "mcl_core:obsidian"})
		p.y = p.y - 1
	end
	for i = 1, FRAME_SIZE_X_MIN - 1 do
		minetest.set_node(p, {name = "mcl_core:obsidian"})
		p.x = p.x - 1
	end

	for x = p1.x, p2.x do
	for y = p1.y, p2.y do
		p = {x = x, y = y, z = p1.z}
		if not ((x == p1.x or x == p2.x) and (y == p1.y or y == p2.y)) then
			if not (x == p1.x or x == p2.x or y == p1.y or y == p2.y) then
				minetest.set_node(p, {name = "mcl_portals:portal", param2 = 0})
			end
			local meta = minetest.get_meta(p)
			meta:set_string("portal_frame1", minetest.pos_to_string(p1))
			meta:set_string("portal_frame2", minetest.pos_to_string(p2))
			meta:set_string("portal_target", minetest.pos_to_string(target))
		end

		if y ~= p1.y and not is_rebuilding then
			for z = -2, 2 do
				if z ~= 0 then
					p.z = p.z + z
					if minetest.registered_nodes[
							minetest.get_node(p).name].is_ground_content then
						minetest.remove_node(p)
					end
					p.z = p.z - z
				end
			end
		end
	end
	end
end

local function find_nether_target_y(target_x, target_z)
	if mg_name == "flat" then
		return mcl_vars.mg_bedrock_nether_bottom_max + 5
	end
	local start_y = math.random(mcl_vars.mg_lava_nether_max + 1, mcl_vars.mg_bedrock_nether_top_min - 5) -- Search start
	if not nobj_cave then
		nobj_cave = minetest.get_perlin(np_cave)
	end
	local air = 4

	for y = start_y, math.max(mcl_vars.mg_lava_nether_max + 1), -1 do
		local nval_cave = nobj_cave:get3d({x = target_x, y = y, z = target_z})

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

local function move_check(p1, max, dir)
	local p = {x = p1.x, y = p1.y, z = p1.z}
	local d = math.sign(max - p1[dir])
	local min = p[dir]

	for k = min, max, d do
		p[dir] = k
		local node = minetest.get_node(p)
		-- Check for obsidian (except at corners)
		if k ~= min and k ~= max and node.name ~= "mcl_core:obsidian" then
			return false
		end
		-- Abort if any of the portal frame blocks already has metadata.
		-- This mod does not yet portals which neighbor each other directly.
		-- TODO: Reorganize the way how portal frame coordinates are stored.
		if node.name == "mcl_core:obsidian" then
			local meta = minetest.get_meta(p)
			local pframe1 = meta:get_string("portal_frame1")
			if minetest.string_to_pos(pframe1) ~= nil then
				return false
			end
		end
	end

	return true
end

local function check_portal(p1, p2)
	if p1.x ~= p2.x then
		if not move_check(p1, p2.x, "x") then
			return false
		end
		if not move_check(p2, p1.x, "x") then
			return false
		end
	elseif p1.z ~= p2.z then
		if not move_check(p1, p2.z, "z") then
			return false
		end
		if not move_check(p2, p1.z, "z") then
			return false
		end
	else
		return false
	end

	if not move_check(p1, p2.y, "y") then
		return false
	end
	if not move_check(p2, p1.y, "y") then
		return false
	end

	return true
end

local function is_portal(pos)
	local xsize, ysize = FRAME_SIZE_X_MIN-1, FRAME_SIZE_Y_MIN-1
	for d = -xsize, xsize do
		for y = -ysize, ysize do
			local px = {x = pos.x + d, y = pos.y + y, z = pos.z}
			local pz = {x = pos.x, y = pos.y + y, z = pos.z + d}

			if check_portal(px, {x = px.x + xsize, y = px.y + ysize, z = px.z}) then
				return px, {x = px.x + xsize, y = px.y + ysize, z = px.z}
			end
			if check_portal(pz, {x = pz.x, y = pz.y + ysize, z = pz.z + xsize}) then
				return pz, {x = pz.x, y = pz.y + ysize, z = pz.z + xsize}
			end
		end
	end
end

local function make_portal(pos)
	local p1, p2 = is_portal(pos)
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

	local target = {x = p1.x, y = p1.y, z = p1.z}
	target.x = target.x + 1
	if target.y < mcl_vars.mg_nether_max and target.y > mcl_vars.mg_nether_min then
		if mg_name == "flat" then
			target.y = mcl_vars.mg_bedrock_overworld_max + 5
		else
			target.y = math.random(mcl_vars.mg_overworld_min + 40, mcl_vars.mg_overworld_min + 96)
		end
	else
		target.y = find_nether_target_y(target.x, target.z)
	end

	local dmin, dmax, ymin, ymax = 0, FRAME_SIZE_X_MIN - 1, p1.y, p2.y
	for d = dmin, dmax do
	for y = ymin, ymax do
	if not ((d == dmin or d == dmax) and (y == ymin or y == ymax)) then
		local p
		if param2 == 0 then
			p = {x = p1.x + d, y = y, z = p1.z}
		else
			p = {x = p1.x, y = y, z = p1.z + d}
		end
		minetest.set_node(p, {name = "mcl_portals:portal", param2 = param2})
		local meta = minetest.get_meta(p)

		-- Portal frame corners
		meta:set_string("portal_frame1", minetest.pos_to_string(p1))
		meta:set_string("portal_frame2", minetest.pos_to_string(p2))

		-- Portal target coordinates
		meta:set_string("portal_target", minetest.pos_to_string(target))
	end
	end
	end

	return true
end


minetest.register_abm({
	label = "Nether portal teleportation and particles",
	nodenames = {"mcl_portals:portal"},
	interval = 1,
	chance = 2,
	action = function(pos, node)
		minetest.add_particlespawner(
			32, --amount
			4, --time
			{x = pos.x - 0.25, y = pos.y - 0.25, z = pos.z - 0.25}, --minpos
			{x = pos.x + 0.25, y = pos.y + 0.25, z = pos.z + 0.25}, --maxpos
			{x = -0.8, y = -0.8, z = -0.8}, --minvel
			{x = 0.8, y = 0.8, z = 0.8}, --maxvel
			{x = 0, y = 0, z = 0}, --minacc
			{x = 0, y = 0, z = 0}, --maxacc
			0.5, --minexptime
			1, --maxexptime
			1, --minsize
			2, --maxsize
			false, --collisiondetection
			"mcl_particles_teleport.png" --texture
		)
		for _,obj in ipairs(minetest.get_objects_inside_radius(pos,1)) do		--maikerumine added for objects to travel
			local lua_entity = obj:get_luaentity() --maikerumine added for objects to travel
			if obj:is_player() or lua_entity then
				-- Prevent quick back-and-forth teleportation
				if portal_cooloff[obj] then
					return
				end
				local meta = minetest.get_meta(pos)
				local target = minetest.string_to_pos(meta:get_string("portal_target"))
				if target then
					-- force emerge of target area
					minetest.get_voxel_manip():read_from_map(target, target)
					if not minetest.get_node_or_nil(target) then
						minetest.emerge_area(
							vector.subtract(target, 4), vector.add(target, 4))
					end
					-- teleport the object
					minetest.after(3, function(obj, pos, target)
						-- Prevent quick back-and-forth teleportation
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

						if minetest.get_node(objpos).name ~= "mcl_portals:portal" then
							return
						end

						-- Build target portal
						local function check_and_build_portal(pos, target, is_rebuilding)
							-- FIXME: This is a horrible hack and a desparate attempt to make sure
							-- the portal has *really* been placed. Replace this hack!
							local n = minetest.get_node_or_nil(target)
							if n and n.name ~= "mcl_portals:portal" then
								build_portal(target, pos, is_rebuilding)
								is_rebuilding = true
								minetest.after(2, check_and_build_portal, pos, target, is_rebuilding)
							elseif not n then
								is_rebuilding = true
								minetest.after(1, check_and_build_portal, pos, target, is_rebuilding)
							end
						end

						check_and_build_portal(pos, target, false)

						-- Teleport
						obj:setpos(target)
						minetest.sound_play("mcl_portals_teleport", {pos=target, gain=0.5, max_hear_distance = 16})

						-- Enable teleportation cooloff for 4 seconds, to prevent back-and-forth teleportation
						portal_cooloff[obj] = true
						minetest.after(4, function(o)
							portal_cooloff[o] = false
						end, obj)

					end, obj, pos, target)
				end
			end
		end
	end,
})


--[[ ITEM OVERRIDES ]]

local longdesc = minetest.registered_nodes["mcl_core:obsidian"]._doc_items_longdesc
longdesc = longdesc .. "\n" .. "Obsidian is also used as the frame of Nether portals."
local usagehelp = "To open a Nether portal, place an upright frame of obsidian with a width of 4 blocks and a height of 5 blocks, leaving only air in the center. After placing this frame, ignite the obsidian with an appropriate tool, such as flint of steel."

minetest.override_item("mcl_core:obsidian", {
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usagehelp,
	on_destruct = destroy_portal,
	_on_ignite = function(user, pointed_thing)
		local pos = pointed_thing.under
		local portal_placed = make_portal(pos)
		if portal_placed and minetest.get_modpath("doc") then
			doc.mark_entry_as_revealed(user:get_player_name(), "nodes", "mcl_portals:portal")

			-- Achievement for finishing a Nether portal TO the Nether
			local _, dim = mcl_util.y_to_layer(pos.y)
			if minetest.get_modpath("awards") and dim ~= "nether" and user:is_player() then
				awards.unlock(user:get_player_name(), "mcl:buildNetherPortal")
			end
		else
			local node = minetest.get_node(pointed_thing.above)
			if node.name ~= "mcl_portals:portal" then
				mcl_fire.set_fire(pointed_thing)
			end
		end
	end,
})

