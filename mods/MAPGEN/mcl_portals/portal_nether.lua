-- Parameters

local TCAVE = 0.6
local nobj_cave = nil

-- 3D noise
local np_cave = {
	offset = 0,
	scale = 1,
	spread = {x = 384, y = 128, z = 384},
	seed = 59033,
	octaves = 5,
	persist = 0.7
}

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
		first = false
	end
	end
	end
end

minetest.register_node("mcl_portals:portal", {
	description = "Nether Portal",
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
	post_effect_color = {a = 180, r = 128, g = 23, b = 23},
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
local function build_portal(pos, target)
	local p = {x = pos.x - 1, y = pos.y - 1, z = pos.z}
	local p1 = {x = pos.x - 1, y = pos.y - 1, z = pos.z}
	local p2 = {x = p1.x + 3, y = p1.y + 4, z = p1.z}

	for i = 1, 4 do
		minetest.set_node(p, {name = "mcl_core:obsidian"})
		p.y = p.y + 1
	end
	for i = 1, 3 do
		minetest.set_node(p, {name = "mcl_core:obsidian"})
		p.x = p.x + 1
	end
	for i = 1, 4 do
		minetest.set_node(p, {name = "mcl_core:obsidian"})
		p.y = p.y - 1
	end
	for i = 1, 3 do
		minetest.set_node(p, {name = "mcl_core:obsidian"})
		p.x = p.x - 1
	end

	for x = p1.x, p2.x do
	for y = p1.y, p2.y do
		p = {x = x, y = y, z = p1.z}
		if not (x == p1.x or x == p2.x or y == p1.y or y == p2.y) then
			minetest.set_node(p, {name = "mcl_portals:portal", param2 = 0})
		end
		local meta = minetest.get_meta(p)
		meta:set_string("portal_frame1", minetest.pos_to_string(p1))
		meta:set_string("portal_frame2", minetest.pos_to_string(p2))
		meta:set_string("portal_target", minetest.pos_to_string(target))

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
end

local function find_nether_target_y(target_x, target_z)
	local start_y = mcl_vars.mg_nether_min + math.random(38, 117) -- Search start
	if not nobj_cave then
		nobj_cave = minetest.get_perlin(np_cave)
	end
	local air = 4

	for y = start_y, start_y -117, -1 do
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
	local d = math.abs(max - p1[dir]) / (max - p1[dir])

	while p[dir] ~= max do
		p[dir] = p[dir] + d
		if minetest.get_node(p).name ~= "mcl_core:obsidian" then
			return false
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
	for d = -3, 3 do
		for y = -4, 4 do
			local px = {x = pos.x + d, y = pos.y + y, z = pos.z}
			local pz = {x = pos.x, y = pos.y + y, z = pos.z + d}

			if check_portal(px, {x = px.x + 3, y = px.y + 4, z = px.z}) then
				return px, {x = px.x + 3, y = px.y + 4, z = px.z}
			end
			if check_portal(pz, {x = pz.x, y = pz.y + 4, z = pz.z + 3}) then
				return pz, {x = pz.x, y = pz.y + 4, z = pz.z + 3}
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
		target.y = math.random(mcl_vars.mg_overworld_min + 40, mcl_vars.mg_overworld_min + 96)
	else
		target.y = find_nether_target_y(target.x, target.z)
	end

	for d = 0, 3 do
	for y = p1.y, p2.y do
		local p = {}
		if param2 == 0 then
			p = {x = p1.x + d, y = y, z = p1.z}
		else
			p = {x = p1.x, y = y, z = p1.z + d}
		end
		if minetest.get_node(p).name == "air"
		then
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
			"mcl_portals_particle.png" --texture
		)
		for _,obj in ipairs(minetest.get_objects_inside_radius(pos,1)) do		--maikerumine added for objects to travel
			local lua_entity = obj:get_luaentity() --maikerumine added for objects to travel
			if obj:is_player() or lua_entity then
				local meta = minetest.get_meta(pos)
				local target = minetest.string_to_pos(meta:get_string("portal_target"))
				if target then
					-- force emerge of target area
					minetest.get_voxel_manip():read_from_map(target, target)
					if not minetest.get_node_or_nil(target) then
						minetest.emerge_area(
							vector.subtract(target, 4), vector.add(target, 4))
					end
					-- teleport the player
					minetest.after(3, function(obj, pos, target)
						local objpos = obj:getpos()   if objpos == nil then return end	--maikerumine added for objects to travel
						if minetest.get_node(objpos).name ~= "mcl_portals:portal" then
							return
						end

						-- Build target portal
						local function check_and_build_portal(pos, target)
							local n = minetest.get_node_or_nil(target)
							if n and n.name ~= "mcl_portals:portal" then
								build_portal(target, pos)
								minetest.after(2, check_and_build_portal, pos, target)
							elseif not n then
								minetest.after(1, check_and_build_portal, pos, target)
							end
						end

						check_and_build_portal(pos, target)

						-- Teleport
						obj:setpos(target)
						minetest.sound_play("mcl_portals_teleport", {pos=target, gain=0.5, max_hear_distance = 16})


					end, obj, pos, target)
				end
			end
		end
	end,
})


--[[ ITEM OVERRIDES ]]

-- Frame material
minetest.override_item("mcl_core:obsidian", {
	on_destruct = destroy_portal,
	_on_ignite = function(user, pointed_thing)
		local pos = pointed_thing.under
		local portal_placed = make_portal(pos)
		if portal_placed and minetest.get_modpath("doc") then
			doc.mark_entry_as_revealed(user:get_player_name(), "nodes", "mcl_portals:portal")
		else
			local node = minetest.get_node(pointed_thing.above)
			if node.name ~= "mcl_portals:portal" then
				mcl_fire.set_fire(pointed_thing)
			end
		end
	end,
})

