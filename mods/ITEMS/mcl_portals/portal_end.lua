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
		if nn == "mcl_portals:portal_end" then
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

-- End portal
-- TODO: Create real end portal
minetest.register_node("mcl_portals:portal_end", {
	description = "End Portal",
	_doc_items_longdesc = "An End portal teleports creatures and objects to the mysterious End dimension (and back!).",
	_doc_items_usagehelp = "Stand in the portal for a moment to activate the teleportation. Entering such a portal for the first time will create a new portal in your destination. End portal which were built in the End will lead back to the Overworld. An End portal is destroyed if any of its surrounding frame blocks is destroyed.",
	tiles = {
		{
			name = "mcl_portals_end_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0,
			},
		},
		"blank.png",
		"blank.png",
		"blank.png",
		"blank.png",
		"blank.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
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
			{-0.5, -0.5, -0.5, 0.5, 4/16, 0.5},
		},
	},
	groups = {not_in_creative_inventory = 1},
	on_destruct = destroy_portal,

	_mcl_hardness = -1,
	_mcl_blast_resistance = 18000000,
})

local function build_end_portal_destination(pos)
	local p1 = {x = pos.x - 2, y = pos.y, z = pos.z-2}
	local p2 = {x = pos.x + 2, y = pos.y+2, z = pos.z+2}

	for x = p1.x, p2.x do
	for y = p1.y, p2.y do
	for z = p1.z, p2.z do
		local newp = {x=x,y=y,z=z}
		-- Build obsidian platform
		if minetest.registered_nodes[minetest.get_node(newp).name].is_ground_content then
			if y == p1.y then
				minetest.set_node(newp, {name="mcl_core:obsidian"})
			else
				minetest.remove_node(newp)
			end
		end
	end
	end
	end
end

local function move_check2(p1, max, dir)
	local p = {x = p1.x, y = p1.y, z = p1.z}
	local d = math.abs(max - p1[dir]) / (max - p1[dir])

	while p[dir] ~= max do
		p[dir] = p[dir] + d
		if minetest.get_node(p).name ~= fake_portal_frame then
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
	chance = 1,
	action = function(pos, node)
		-- Destroy legacy end portals created with quartz block frame
		-- by turning them into cobwebs.
		-- We can tell if a end portal is legacy if it has portal_target as metadata.
		-- FIXME: Remove this after some time.
		local meta = minetest.get_meta(pos)
		local legacy_portal_target = minetest.string_to_pos(meta:get_string("portal_target"))
		if legacy_portal_target and legacy_portal_target ~= "" then
			minetest.set_node(pos, {name="mcl_core:cobweb"})
			return
		end

		for _,obj in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
			local lua_entity = obj:get_luaentity() --maikerumine added for objects to travel
			if obj:is_player() or lua_entity then
				local _, dim = mcl_util.y_to_layer(pos.y)

				local target
				if dim == "end" then
					-- End portal in the End:
					-- Teleport back to the player's spawn in the Overworld.
					-- TODO: Implement better spawn point detection

					target = minetest.string_to_pos(obj:get_attribute("mcl_beds:spawn"))
					if not target then
						target = minetest.setting_get_pos("static_spawnpoint")
					end
					if not target then
						target = { x=0, y=0, z=0 }
						if mg_name == "flat" then
							target.y = mcl_vars.mg_bedrock_overworld_max + 5
						end
					end
				else
					-- End portal in any other dimension:
					-- Teleport to the End at a fixed position and generate a
					-- 5×5 obsidian platform below.

					local platform_pos = mcl_vars.mg_end_platform_pos

					-- force emerge of target1 area
					minetest.get_voxel_manip():read_from_map(platform_pos, platform_pos)
					if not minetest.get_node_or_nil(platform_pos) then
						minetest.emerge_area(vector.subtract(platform_pos, 3), vector.add(platform_pos, 3))
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
					local function check_and_build_end_portal_destination(pos)
						local n = minetest.get_node_or_nil(pos)
						if n and n.name ~= "mcl_core:obsidian" then
							build_end_portal_destination(pos)
							minetest.after(2, check_and_build_end_portal_destination, pos)
						elseif not n then
						minetest.after(1, check_and_build_end_portal_destination, pos)
					end
					end

					local platform
					check_and_build_end_portal_destination(platform_pos)

					target = table.copy(platform_pos)
					target.y = target.y + 1
				end

				-- Teleport
				obj:set_pos(target)
				-- Look towards the End island
				if obj:is_player() and dim ~= "end" then
					obj:set_look_horizontal(math.pi/2)
				end
				minetest.sound_play("mcl_portals_teleport", {pos=target, gain=0.5, max_hear_distance = 16})
			end
		end
	end,
})


--[[ ITEM OVERRIDES ]]

-- End Portal Frame (TODO)
minetest.register_node("mcl_portals:end_portal_frame", {
	description = "End Portal Frame",
	groups = { creative_breakable = 1, deco_block = 1 },
	tiles = { "mcl_portals_endframe_top.png", "mcl_portals_endframe_bottom.png", "mcl_portals_endframe_side.png" },
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, 5/16, 0.5 },
	},
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	sunlight_propagates = false,
	light_source = 1,
	_mcl_blast_resistance = 18000000,
	_mcl_hardness = -1,
})

minetest.register_node("mcl_portals:end_portal_frame_eye", {
	description = "End Portal Frame with Eye of Ender",
	_doc_items_create_entry = false,
	groups = { creative_breakable = 1, not_in_creative_inventory = 1 },
	tiles = { "mcl_portals_endframe_top.png^[lowpart:75:mcl_portals_endframe_eye.png", "mcl_portals_endframe_bottom.png", "mcl_portals_endframe_eye.png^mcl_portals_endframe_side.png" },
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, 5/16, 0.5 }, -- Frame
			{ -4/16, 5/16, -4/16, 4/16, 0.5, 4/16 }, -- Eye
		},
	},
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	paramtype = "light",
	sunlight_propagates = false,
	light_source = 1,
	_mcl_blast_resistance = 18000000,
	_mcl_hardness = -1,
	-- TODO: Destroy end portal if this block got destroyed
})

if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_portals:end_portal_frame", "nodes", "mcl_portals:end_portal_frame_eye")
end


-- Portal opener
minetest.override_item("mcl_end:ender_eye", {
	_doc_items_longdesc = "An eye of ender can be used to open End portals.",
	-- TODO: _doc_items_usagehelp = ,
	on_place = function(itemstack, user, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		-- If used on portal frame, open a portal
		-- FIXME: This is the fake portal. Remove when the real end portal frame works
		if pointed_thing.under and node.name == fake_portal_frame then
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

		-- Place eye of ender into end portal frame
		elseif pointed_thing.under and node.name == "mcl_portals:end_portal_frame" then
			-- TODO: Open real end portal
			minetest.swap_node(pointed_thing.under, { name = "mcl_portals:end_portal_frame_eye", param2 = node.param2 })
			if minetest.get_modpath("doc") then
				doc.mark_entry_as_revealed(user:get_player_name(), "nodes", "mcl_portals:end_portal_frame")
			end
			minetest.sound_play(
				"default_place_node_hard",
				{pos = pointed_thing.under, gain = 0.5, max_hear_distance = 16})
			if not minetest.settings:get_bool("creative_mode") then
				itemstack:take_item() -- 1 use
			end
		end
		return itemstack
	end,
})

