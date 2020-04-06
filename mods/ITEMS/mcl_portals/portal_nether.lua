local S = minetest.get_translator("mcl_portals")

-- Parameters

local TCAVE = 0.6
local nobj_cave = nil

-- Portal frame sizes
local FRAME_SIZE_X_MIN = 4
local FRAME_SIZE_Y_MIN = 5
local FRAME_SIZE_X_MAX = 4 -- TODO: 23
local FRAME_SIZE_Y_MAX = 5 -- TODO: 23

local TELEPORT_DELAY = 3 -- seconds before teleporting in Nether portal
local TELEPORT_COOLOFF = 4 -- after object was teleported, for this many seconds it won't teleported again

local mg_name = minetest.get_mapgen_setting("mg_name")
local superflat = mg_name == "flat" and minetest.get_mapgen_setting("mcl_superflat_classic") == "true"

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
	groups = {portal=1, not_in_creative_inventory = 1},
	on_destruct = destroy_portal,

	_mcl_hardness = -1,
	_mcl_blast_resistance = 0,
})

-- Functions
--Build arrival portal
local function build_portal(pos, target)
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

		if y ~= p1.y then
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
	minetest.log("action", "[mcl_portal] Destination Nether portal generated at "..minetest.pos_to_string(p2).."!")
end

local function find_nether_target_y(target_x, target_z)
	if mg_name == "flat" then
		return mcl_vars.mg_flat_nether_floor + 1
	end
	local start_y = math.random(mcl_vars.mg_lava_nether_max + 1, mcl_vars.mg_bedrock_nether_top_min - 5) -- Search start
	if not nobj_cave then
		nobj_cave = minetest.get_perlin(np_cave)
	end
	local air = 4

	for y = start_y, math.max(mcl_vars.mg_lava_nether_max + 1), -1 do
		local nval_cave = nobj_cave:get_3d({x = target_x, y = y, z = target_z})

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
	for sx = FRAME_SIZE_X_MIN, FRAME_SIZE_X_MAX do
		local xsize = sx - 1
		for sy = FRAME_SIZE_Y_MIN, FRAME_SIZE_Y_MAX do
			local ysize = sy - 1
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
	end
end

-- Attempts to light a Nether portal at pos and
-- select target position.
-- Pos can be any of the obsidian frame blocks or the inner part.
-- The frame MUST be filled only with air or any fire, which will be replaced with Nether portal blocks.
-- If no Nether portal can be lit, nothing happens.
-- Returns true on success and false on failure.
function mcl_portals.light_nether_portal(pos)
	-- Only allow to make portals in Overworld and Nether
	local dim = mcl_worlds.pos_to_dimension(pos)
	if dim ~= "overworld" and dim ~= "nether" then
		return false
	end
	-- Create Nether portal nodes
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
		local nn = minetest.get_node(p).name
		if nn ~= "air" and minetest.get_item_group(nn, "fire") ~= 1 then
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

	-- Find target

	local target = {x = p1.x, y = p1.y, z = p1.z}
	target.x = target.x + 1
	if target.y < mcl_vars.mg_nether_max and target.y > mcl_vars.mg_nether_min then
		if superflat then
			target.y = mcl_vars.mg_bedrock_overworld_max + 5
		elseif mg_name == "flat" then
			local ground = minetest.get_mapgen_setting("mgflat_ground_level")
			ground = tonumber(ground)
			if not ground then
				ground = 8
			end
			target.y = ground + 2
		else
			target.y = math.random(mcl_vars.mg_overworld_min + 40, mcl_vars.mg_overworld_min + 96)
		end
	else
		target.y = find_nether_target_y(target.x, target.z)
	end

	local dmin, ymin, ymax = 0, p1.y, p2.y
	local dmax = math.max(math.abs(p1.x - p2.x), math.abs(p1.z - p2.z))
	for d = dmin, dmax do
	for y = ymin, ymax do
	if not ((d == dmin or d == dmax) and (y == ymin or y == ymax)) then
		local p
		if param2 == 0 then
			p = {x = p1.x + d, y = y, z = p1.z}
		else
			p = {x = p1.x, y = y, z = p1.z + d}
		end
		if d ~= dmin and d ~= dmax and y ~= ymin and y ~= ymax then
			minetest.set_node(p, {name = "mcl_portals:portal", param2 = param2})
		end
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
		minetest.add_particlespawner({
			amount = 32,
			time = 4,
			minpos = {x = pos.x - 0.25, y = pos.y - 0.25, z = pos.z - 0.25},
			maxpos = {x = pos.x + 0.25, y = pos.y + 0.25, z = pos.z + 0.25},
			minvel = {x = -0.8, y = -0.8, z = -0.8},
			maxvel = {x = 0.8, y = 0.8, z = 0.8},
			minacc = {x = 0, y = 0, z = 0},
			maxacc = {x = 0, y = 0, z = 0},
			minexptime = 0.5,
			maxexptime = 1,
			minsize = 1,
			maxsize = 2,
			collisiondetection = false,
			texture = "mcl_particles_teleport.png",
		})
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
						minetest.emerge_area(vector.subtract(target, 4), vector.add(target, 4))
					end

					-- teleport function
					local teleport = function(obj, pos, target)
						if (not obj:get_luaentity()) and  (not obj:is_player()) then
							return
						end
						-- Prevent quick back-and-forth teleportation
						if portal_cooloff[obj] then
							return
						end
						local objpos = obj:get_pos()
						if objpos == nil then
							return
						end
						-- If player stands, player is at ca. something+0.5
						-- which might cause precision problems, so we used ceil.
						objpos.y = math.ceil(objpos.y)

						if minetest.get_node(objpos).name ~= "mcl_portals:portal" then
							return
						end

						-- Teleport
						obj:set_pos(target)
						if obj:is_player() then
							mcl_worlds.dimension_change(obj, mcl_worlds.pos_to_dimension(target))
							minetest.sound_play("mcl_portals_teleport", {pos=target, gain=0.5, max_hear_distance = 16}, true)
						end

						-- Enable teleportation cooloff for some seconds, to prevent back-and-forth teleportation
						portal_cooloff[obj] = true
						minetest.after(TELEPORT_COOLOFF, function(o)
							portal_cooloff[o] = false
						end, obj)
						if obj:is_player() then
							local name = obj:get_player_name()
							minetest.log("action", "[mcl_portal] "..name.." teleported to Nether portal at "..minetest.pos_to_string(target)..".")
						end
					end

					local n = minetest.get_node_or_nil(target)
					if n and n.name ~= "mcl_portals:portal" then
						-- Emerge target area, wait for emerging to be finished, build destination portal
						-- (if there isn't already one, teleport object after a short delay.
						local emerge_callback = function(blockpos, action, calls_remaining, param)
							minetest.log("verbose", "[mcl_portal] emerge_callack called! action="..action)
							if calls_remaining <= 0 and action ~= minetest.EMERGE_CANCELLED and action ~= minetest.EMERGE_ERRORED then
								minetest.log("verbose", "[mcl_portal] Area for destination Nether portal emerged!")
								build_portal(param.target, param.pos, false)
								minetest.after(TELEPORT_DELAY, teleport, obj, pos, target)
							end
						end
						minetest.log("verbose", "[mcl_portal] Emerging area for destination Nether portal ...")
						minetest.emerge_area(vector.subtract(target, 7), vector.add(target, 7), emerge_callback, { pos = pos, target = target })
					else
						minetest.after(TELEPORT_DELAY, teleport, obj, pos, target)
					end

				end
			end
		end
	end,
})


--[[ ITEM OVERRIDES ]]

local longdesc = minetest.registered_nodes["mcl_core:obsidian"]._doc_items_longdesc
longdesc = longdesc .. "\n" .. S("Obsidian is also used as the frame of Nether portals.")
local usagehelp = S("To open a Nether portal, place an upright frame of obsidian with a width of 4 blocks and a height of 5 blocks, leaving only air in the center. After placing this frame, light a fire in the obsidian frame. Nether portals only work in the Overworld and the Nether.")

minetest.override_item("mcl_core:obsidian", {
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usagehelp,
	on_destruct = destroy_portal,
	_on_ignite = function(user, pointed_thing)
		local pos = pointed_thing.under
		local portal_placed = mcl_portals.light_nether_portal(pos)
		if portal_placed then
			minetest.log("action", "[mcl_portal] Nether portal activated at "..minetest.pos_to_string(pos)..".")
		end
		if portal_placed and minetest.get_modpath("doc") then
			doc.mark_entry_as_revealed(user:get_player_name(), "nodes", "mcl_portals:portal")

			-- Achievement for finishing a Nether portal TO the Nether
			local dim = mcl_worlds.pos_to_dimension(pos)
			if minetest.get_modpath("awards") and dim ~= "nether" and user:is_player() then
				awards.unlock(user:get_player_name(), "mcl:buildNetherPortal")
			end
			return true
		else
			return false
		end
	end,
})

