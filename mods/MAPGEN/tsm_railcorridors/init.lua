local pairs = pairs
local tonumber = tonumber
local get_node_name = mcl_vars.get_node_name
local get_node_name_raw = mcl_vars.get_node_name_raw
local get_item_group = minetest.get_item_group
local swap_node = minetest.set_node

tsm_railcorridors = {
	after = {},
}

-- Load node names
dofile(minetest.get_modpath(core.get_current_modname()).."/gameconfig.lua")

local nodes = tsm_railcorridors.nodes -- shorthand
local AIR = { name = "air" } -- node

-- Minimal and maximal value of path length (forks don't look up this value)
local way_min = tonumber(minetest.settings:get("tsm_railcorridors_way_min")) or 4
local way_max = tonumber(minetest.settings:get("tsm_railcorridors_way_max")) or 7

-- Probability for every horizontal part of a corridor to be with torches
local probability_torches_in_segment = tonumber(minetest.settings:get("tsm_railcorridors_probability_torches_in_segment")) or 0.5

-- Probability for every part of a corridor to go up or down
local probability_up_or_down = tonumber(minetest.settings:get("tsm_railcorridors_probability_up_or_down")) or 0.2

-- Probability for every part of a corridor to fork – caution, too high values may cause MT to hang on.
local probability_fork = tonumber(minetest.settings:get("tsm_railcorridors_probability_fork")) or 0.04

-- Probability for every part of a corridor to contain a chest
local probability_chest = tonumber(minetest.settings:get("tsm_railcorridors_probability_chest")) or 0.05

-- Probability for every part of a corridor to contain a cart
local probability_cart = tonumber(minetest.settings:get("tsm_railcorridors_probability_cart")) or 0.05

-- Probability for a rail corridor system to be damaged
local probability_damage = tonumber(minetest.settings:get("tsm_railcorridors_probability_damage")) or 0.55

-- Enable cobwebs
local place_cobwebs = minetest.settings:get_bool("tsm_railcorridors_place_cobwebs") ~= false

-- Enable mob spawners
local place_mob_spawners = minetest.settings:get_bool("tsm_railcorridors_place_mob_spawners") ~= false

-- Max. and min. heights between rail corridors are generated
local height_min = (mcl_vars.mg_lava and mcl_vars.mg_lava_overworld_max or mcl_vars.mg_bedrock_overworld_max) + 2
local height_max = mcl_worlds.layer_to_y(60)

-- Chaos Mode: If enabled, rail corridors don't stop generating when hitting obstacles
local chaos_mode = minetest.settings:get_bool("tsm_railcorridors_chaos") or false

-- End of parameters

if not nodes.corridor_woods_function then
	local accumulated_chance = 0
	for _, woodtable in ipairs(nodes.corridor_woods) do
		accumulated_chance = accumulated_chance + woodtable.chance
	end
	nodes.corridor_woods_function = function()
		-- Select random wood type (found in gameconfig.lua)
		local rnd = pr:next(1,accumulated_chance)
		for _, woodtable in ipairs(nodes.corridor_woods) do
			rnd = rnd - woodtable.chance
			if rnd <= 0 then
				return woodtype.wood, woodtype.post
			end
		end
		return nodes.corridor_woods[1].wood, nodes.corridor_woods[1].post
	end
end

-- Random Perlin noise generators
local pr, pr_carts, pr_deco, webperlin_major, webperlin_minor
--local pr_treasures

local function InitRandomizer(seed)
	-- Mostly used for corridor gen.
	pr = PcgRandom(seed)
	-- Dirt room decorations
	pr_deco = PcgRandom(seed+25)
	-- Separate randomizer for carts because spawning carts is very timing-dependent
	pr_carts = PcgRandom(seed-654)
	-- Chest contents randomizer
	--pr_treasures = PseudoRandom(seed+777)
	-- Used for cobweb generation, both noises have to reach a high value for cobwebs to appear
	webperlin_major = PerlinNoise(934, 3, 0.6, 500)
	webperlin_minor = PerlinNoise(834, 3, 0.6, 50)
end

local carts_table = {}

local dirt_room_coords

-- Returns true if pos is inside the dirt room of the current corridor system
local function IsInDirtRoom(x,y,z)
	local min = dirt_room_coords.min
	local max = dirt_room_coords.max
	return x >= min.x and x <= max.x and z >= min.z and z <= max.z and y >= min.y and y <= max.y
end

-- Checks if the mapgen is allowed to carve through this structure and only sets
-- the node if it is allowed. Does never build in liquids.
-- If check_above is true, don't build if the node above is attached (e.g. rail)
-- or a liquid.
local function SetNodeIfCanBuild(x, y, z, node, check_above, can_replace_rail)
	if check_above then
		local abovename = get_node_name_raw(x,y+1,z)
		if abovename == "ignore" then return false end
		local abovedef = minetest.registered_nodes[abovename]
		if not abovedef or (abovedef.groups.attached_node or 0) > 0 or
				-- This is done because cobwebs are often fake liquids
				(abovedef.liquidtype ~= "none" and abovename ~= nodes.cobweb.name) then
			return false
		end
	end
	local name = get_node_name_raw(x,y,z)
	if name == "ignore" then return false end
	local def = minetest.registered_nodes[name]
	if not def then return false end
	if (def.is_ground_content and def.liquidtype == "none") or
			name == nodes.cobweb.name or
			name == nodes.torch_wall.name or
			name == nodes.torch_floor.name or
			(can_replace_rail and name == nodes.rail.name)
			then
		local pos = {x=x,y=y,z=z}
		swap_node(pos, node)
		local after = tsm_railcorridors.on_place_node[node.name]
		if after then after(pos, node) end
		return true
	end
	return false
end

-- Tries to place a rail, taking the damage chance into account
local function PlaceRail(x,y,z, damage_chance)
	if damage_chance and damage_chance > 0 and pr:next(1,1e9) * 1e-9 <= damage_chance then return false end
	return SetNodeIfCanBuild(x, y, z, nodes.rail)
end

-- Returns true if the node as point can be considered “ground”, that is, a solid material
-- in which mine shafts can be built into, e.g. stone, but not air or water
local function IsGround(x,y,z)
	local name = get_node_name_raw(x,y,z)
	if name == "ignore" then return false end
	local nodedef = minetest.registered_nodes[name]
	return nodedef and nodedef.is_ground_content and nodedef.walkable and nodedef.liquidtype == "none"
end

-- Anything walkable, used for cobweb placement
local function IsWalkable(x,y,z)
	local name = get_node_name_raw(x, y, z)
	if name == "ignore" then return false end
	local nodedef = minetest.registered_nodes[name]
	return nodedef and nodedef.walkable
end

-- Returns true if rails are allowed to be placed on top of this node
local function IsRailSurface(x,y,z)
	local name = get_node_name_raw(x,y,z)
	if name == "ignore" then return false end
	if name == nodes.rail.name then return false end
	local nodedef = minetest.registered_nodes[name]
	if not nodedef or not nodedef.walkable or (nodedef.node_box ~= nil and nodedef.node_box.type ~= "regular") then return false end
	return get_node_name_raw(x,y+2,z) ~= nodes.rail.name
end

-- Checks if the node is empty space which requires to be filled by a platform
local function NeedsPlatform(x,y,z)
	local nodename  = get_node_name_raw(x,y-1,z)
	if nodename == "ignore" then return false end
	local nodedef = minetest.registered_nodes[nodename]
	-- Node can only be replaced if ground content
	if not nodedef or not nodedef.is_ground_content then return false end
	-- Node needs platform if node below is not walkable.
	-- Unless 2 nodes below there is dirt: This is a special case for the starter cube.
	if get_node_name_raw(x,y-2,z) == nodes.dirt.name then return false end
	-- Falling nodes always need to be replaced by a platform, we want a solid and safe ground
	local falling = nodedef.groups and (nodedef.groups.falling_node or 0) > 0
	return not nodedef.walkable or falling, falling
end

-- Create a cube filled with the specified nodes
-- Specialties:
-- * Avoids floating rails
-- * May cut into wood structures of the corridors (alongside with their torches)
-- Arguments:
-- * px,py,pz: Center position
-- * radius: How many nodes from the center the cube will extend
-- * node: Node to set
-- * replace_air_only: If true, only air can be replaced
-- * wood, post: Wood and post nodes of the railway corridor to cut into (optional)

-- Returns true if all nodes could be set
-- Returns false if setting one or more nodes failed
local function Cube(px,py,pz, radius, node, replace_air_only, wood, post)
	local y_top = py+radius
	local nodedef = minetest.registered_nodes[node.name]
	local solid = nodedef and nodedef.walkable and (nodedef.node_box == nil or nodedef.node_box.type == "regular") and nodedef.liquidtype == "none"
	-- Check if all the nodes could be set
	local built_all = true

	-- If wood has been removed, remod
	local cleanup_torches = {}
	for xi = px-radius, px+radius do
		for zi = pz-radius, pz+radius do
			local column_last_attached = nil
			for yi = y_top, py-radius, -1 do
				local ok = false
				local thisname = get_node_name_raw(xi,yi,zi)
				if not solid then
					if yi == y_top then
						local topname = get_node_name_raw(xi,yi+1,zi)
						local topdef = minetest.registered_nodes[topname]
						if topdef and (topdef.groups.attached_node or 0) == 0 and topdef.liquidtype == "none" then
							ok = true
						end
					else
						ok = not column_last_attached or yi ~= column_last_attached - 1
					end
					if get_item_group(thisname, "attached_node") > 0 then
						column_last_attached = yi
					end
				else
					ok = true
				end
				local built = false
				if ok then
					if replace_air_only ~= true then
						-- Cut into wood structures (post/wood)
						if post and (xi == px or zi == pz) and thisname == post.name then
							swap_node({x=xi,y=yi,z=zi}, node)
							built = true
						elseif wood and (xi == px or zi == pz) and thisname == wood.name then
							local topname = get_node_name_raw(xi,yi+1,zi)
							local topdef = minetest.registered_nodes[topname]
							if topdef and topdef.walkable and topname ~= wood.name then
								swap_node({x=xi,y=yi,z=zi}, node)
								-- Check for torches around the wood and schedule them
								-- for removal
								if node.name == "air" then
									table.insert(cleanup_torches, {x=xi+1,y=yi,z=zi})
									table.insert(cleanup_torches, {x=xi-1,y=yi,z=zi})
									table.insert(cleanup_torches, {x=xi,y=yi,z=zi+1})
									table.insert(cleanup_torches, {x=xi,y=yi,z=zi-1})
								end
								built = true
							end
						-- Set node normally
						else
							built = SetNodeIfCanBuild(xi,yi,zi, node)
						end
					else
						if get_node_name_raw(xi,yi,zi) == "air" then
							built = SetNodeIfCanBuild(xi,yi,zi, node)
						end
					end
				end
				if not built then
					built_all = false
				end
			end
		end
	end
	-- Remove torches we have detected before
	for c=1, #cleanup_torches do
		local check = get_node_name(cleanup_torches[c])
		if check == nodes.torch_wall.name or check == nodes.torch_floor.name then
			swap_node(cleanup_torches[c], node)
		end
	end
	return built_all
end

local function DirtRoom(px, py, pz, radius, height, dirt_mode, decorations_mode)
	local y_bottom = py
	local y_top = y_bottom + height + 1
	dirt_room_coords = {
		min = { x = px-radius, y = y_bottom, z = pz-radius },
		max = { x = px+radius, y = y_top,    z = pz+radius },
	}
	local built_all = true
	for xi = px-radius, px+radius do
		for zi = pz-radius, pz+radius do
			for yi = y_top, y_bottom, -1 do
				local thisname = get_node_name_raw(xi,yi,zi)
				local built = false
				if xi == px-radius or xi == px+radius or zi == pz-radius or zi == pz+radius or yi == y_bottom or yi == y_top then
					if dirt_mode == 1 or yi == y_bottom then
						built = SetNodeIfCanBuild(xi,yi,zi, nodes.dirt)
					elseif dirt_mode == 2 and yi == y_top then
						if get_item_group(thisname, "falling_node") > 0 then
							built = SetNodeIfCanBuild(xi,yi,zi, nodes.dirt)
						end
					end
				else
					if yi == y_bottom + 1 then
						-- crazy rails
						if decorations_mode == 1 and pr_deco:next(1,3) == 1 then
							built = SetNodeIfCanBuild(xi,yi,zi, nodes.rail)
						end
					end
					if not built then
						built = SetNodeIfCanBuild(xi,yi,zi, AIR)
					end
				end
				if not built then
					built_all = false
				end
			end
		end
	end
	return built_all
end

-- node2 is secondary platform material for replacing falling nodes
local function Platform(px, py, pz, radius, node, node2)
	node2 = node2 or nodes.dirt
	local n1, n2 = {}, {}
	for zi = pz-radius, pz+radius do
		for xi = px-radius, px+radius do
			local np, np2 = NeedsPlatform(xi,py,zi)
			if np then
				table.insert(np2 and n1 or n2,{x=xi,y=py-1,z=zi})
			end
		end
	end
	minetest.bulk_swap_node(n1,node)
	minetest.bulk_swap_node(n2,node2)
end

-- Chests
local function PlaceChest(x,y,z, param2)
	if SetNodeIfCanBuild(x, y, z, {name=nodes.chest.name, param2=param2}) then
		local meta = minetest.get_meta({x=x,y=y,z=z})
		local inv = meta:get_inventory()
		local items = tsm_railcorridors.get_treasures(pr)
		mcl_loot.fill_inventory(inv, "main", items, pr)
	end
end

-- Try to place a cobweb.
-- pos: Position of cobweb
-- needs_check: If true, checks if any of the nodes above, below or to the side of the cobweb.
-- side_vector: Required if needs_check is true. Unit vector which points towards the side of the cobweb to place.
local function TryPlaceCobweb(x,y,z, needs_check, sx, sy, sz)
	if needs_check then
		-- Check for walkable nodes above, below or at the side of the cobweb.
		-- If any of those nodes is walkable, we are fine.
		if not IsWalkable(x + sx, y + sy, z + sz) and
				not IsWalkable(x, y + 1, z) and not IsWalkable(x, y - 1, z) then
			return false
		end
	end
	return SetNodeIfCanBuild(x, y, z, nodes.cobweb)
end

-- 4 wooden pillars around pos at height
local function WoodBulk(x,y,z, height, wood)
	for yi=y, y+height-1 do
		SetNodeIfCanBuild(x+1, y, z+1, wood, false, true)
		SetNodeIfCanBuild(x-1, y, z+1, wood, false, true)
		SetNodeIfCanBuild(x+1, y, z-1, wood, false, true)
		SetNodeIfCanBuild(x-1, y, z-1, wood, false, true)
	end
end

-- Build a wooden support frame
local function WoodSupport(px, py, pz, wood, fence, torches, dx, dz, t1, t2)
	local calc = {
		px+dx, pz+dz, -- X and Z, added by direction
		px-dx, pz-dz, -- subtracted
		px+dz, pz+dx, -- orthogonal
		px-dz, pz-dx, -- orthogonal, the other way
	}
	--[[ Shape:
		WWW
		P.P
		PrP
		pfp
	W = wood
	P = post (above floor level)
	p = post (in floor level, only placed if no floor)

	From previous generation (for reference):
	f = floor
	r = rail
	. = air
	]]

	-- Don't place those wood structs below open air
	if not (get_node_name_raw(calc[1], py+2, calc[2]) == "air" and
		get_node_name_raw(calc[3], py+2, calc[4]) == "air" and
		get_node_name_raw(px, py+2, pz) == "air") then

		-- Left post and planks
		local left_ok = SetNodeIfCanBuild(calc[1], py-1, calc[2], fence) and
		                SetNodeIfCanBuild(calc[1], py  , calc[2], fence) and
		                SetNodeIfCanBuild(calc[1], py+1, calc[2], wood, false, true)

		-- Right post and planks
		local right_ok = SetNodeIfCanBuild(calc[3], py-1, calc[4], fence) and
		                 SetNodeIfCanBuild(calc[3], py  , calc[4], fence) and
		                 SetNodeIfCanBuild(calc[3], py+1, calc[4], wood, false, true)

		-- Middle planks
		local top_planks_ok = left_ok and right_ok and SetNodeIfCanBuild(px, py+1, pz, wood)

		if get_node_name_raw(px,py-2,pz)=="air" then
			if left_ok then SetNodeIfCanBuild(calc[1], py-2, calc[2], fence) end
			if right_ok then SetNodeIfCanBuild(calc[3], py-2, calc[4], fence) end
		end
		-- Torches on the middle planks
		if torches and top_planks_ok then
			-- Place torches at horizontal sides
			SetNodeIfCanBuild(calc[5], py+1, calc[6], {name=nodes.torch_wall.name, param2=t1}, true)
			SetNodeIfCanBuild(calc[7], py+1, calc[8], {name=nodes.torch_wall.name, param2=t2}, true)
		end
	elseif torches then
		-- Try to build torches instead of the wood structs
		-- Try two different height levels
		local x1,y1,z1 = calc[1], py-2, calc[2]
		local nodedef1 = minetest.registered_nodes[get_node_name_raw(x1,y1,z1)]
		if nodedef1 and nodedef1.walkable then y1 = y1 + 1 end
		SetNodeIfCanBuild(x1,y1,z1, nodes.torch_floor, true)

		local x2,y2,z2 = calc[3], py-2, calc[4]
		local nodedef2 = minetest.registered_nodes[get_node_name_raw(x2,y2,z2)]
		if nodedef2 and nodedef2.walkable then y2 = y2 + 1 end
		SetNodeIfCanBuild(x2,y2,z2, nodes.torch_floor, true)
	end
end

-- Dig out a single corridor section and place wooden structures and torches

-- Returns <success>, <segments>
-- success: true if corridor could be placed entirely
-- segments: Number of segments successfully placed
local function dig_corridor_section(px, py, pz, sx, sy, sz, segment_count, wood, post, up_or_down_prev)
	local torches = pr:next(0,1e9) * 1e-9 < probability_torches_in_segment
	local d1, d2 = 0, 0
	local t1, t2 = 1, 1
	if sx == 0 and sz ~= 0 then
		d1, d2 = 1, 0
		t1, t2 = 5, 4 -- param2 for torches
	elseif sx ~= 0 and sz == 0 then
		d1, d2 = 0, 1
		t1, t2 = 3, 2 -- param2 for torches
	end
	for segmentindex = 0, segment_count-1 do
		local dug = Cube(px,py,pz, 1, AIR, false, sy == 0 and wood, sy == 0 and post)
		if not chaos_mode and segmentindex > 0 and not dug then return false, segmentindex end
		-- Add wooden platform, if neccessary. To avoid floating rails
		if sy == 0 then
			if segmentindex == 0 and up_or_down_prev then
				-- Thin 1x1 platform directly after going up or down.
				-- This is done to avoid placing too much wood at slopes
				Platform(px-d2, py-1, pz-d1, 0, wood) -- orthogonal
				Platform(px,    py-1, pz,    0, wood)
				Platform(px+d2, py-1, pz+d1, 0, wood)
			else
				-- Normal 3x3 platform
				Platform(px, py-1, pz, 1, wood)
			end
		else
			-- Sloped bridge
			Platform(px-d1, py-2, pz-d2, 0, wood)
			Platform(px,    py-2, pz,    0, wood)
			Platform(px+d1, py-2, pz+d2, 0, wood)
		end
		if segmentindex % 2 == 1 and sy == 0 then
			WoodSupport(px, py, pz, wood, post, torches, d1, d2, t1, t2)
		end

		-- Next way point
		px, py, pz = px + sx, py + sy, pz + sz
	end

	-- End of the corridor segment; create the final piece
	local dug = Cube(px,py,pz, 1, AIR, false, sy == 0 and wood, sy == 0 and post)
	if not chaos_mode and not dug then return false, segment_count end
	if sy == 0 then
		Platform(px, py-1, pz, 1, wood)
	end
	return true, segment_count
end

-- Randomly returns either the left or right side of the main rail.
-- Also returns offset
local function left_or_right(px, py, pz, vx, vy, vz)
	if pr:next(1, 2) == 1 then -- left
		return px-vz, py, pz+vx, -vz, 0,  vx
	else -- right
		return px+vz, py, pz-vx,  vz, 0, -vx
	end
end

-- Generate a corridor section. Corridor sections are part of a corridor line.
-- This is one short part of a corridor line. It can be one straight section or it goes up or down.
-- It digs out the corridor and places wood structs and torches using the helper function dig_corridor_function,
-- then it places rails, chests, and other goodies.
local function create_corridor_section(wx,wy,wz, axis, sign, up_or_down, up_or_down_next, up_or_down_prev, up, wood, post, first_or_final, damage, no_spawner)
	local segamount = up_or_down and 1 or 3
	if sign then segamount = -segamount end
	local vx, vy, vz = 0, 0, 0
	local sx, sy, sz = wx,wy,wz
	if axis == "x" then
		vx=segamount
		if up_or_down and not up then sx=sx+segamount end
	elseif axis == "z" then
		vz=segamount
		if up_or_down and not up then sz=sz+segamount end
	end
	if up_or_down then
		vy = up and 1 or -1
	end
	local segcount = pr:next(4,6)
	if up_or_down and not up then
		Cube(wx,wy,wz, 1, AIR, false)
	end
	local corridor_dug, corridor_segments_dug = dig_corridor_section(sx, sy, sz, vx, vy, vz, segcount, wood, post, up_or_down_prev)
	-- end of segment (v is reused below, we need the current values)
	local fx, fy, fz = wx + vx*segcount, wy + vy*segcount, wz + vz*segcount

	-- After this: rails
	segamount = sign and -1 or 1
	if axis == "x" then
		vx=segamount
	elseif axis == "z" then
		vz=segamount
	end
	if up_or_down then
		vy = up and 1 or -1
	end
	-- Calculate chest and cart position
	local chestplace = -1
	local cartplace = -1
	local minseg = first_or_final == "first" and 2 or 1
	if corridor_dug and not up_or_down then
		if pr:next(0,1e9) * 1e-9 < probability_chest then
			chestplace = pr:next(minseg, segcount+1)
		end
		if tsm_railcorridors.carts and #tsm_railcorridors.carts > 0 and pr:next(0,1e9) * 1e-9 < probability_cart then
			cartplace = pr:next(minseg, segcount+1)
		end
	end
	local railsegcount
	if not chaos_mode and not corridor_dug then
		railsegcount = corridor_segments_dug * 3
	elseif not up_or_down then
		railsegcount = segcount * 3
	else
		railsegcount = segcount
	end
	for i=1,railsegcount do
		local px, py, pz = wx + vx * i, wy + vy * i-1, wz + vz * i

		if get_node_name_raw(px,py-1,pz)=="air" and get_node_name_raw(px,py-3,pz)~=nodes.rail.name then
			py = py - 1
			if i == chestplace then chestplace = chestplace + 1 end
			if i == cartplace then cartplace = cartplace + 1 end
		end

		-- Chest
		if i == chestplace then
			local cx, cy, cz, ox, oy, oz = left_or_right(px, py, pz, vx, vy, vz)
			if get_node_name_raw(cx, cy, cz) == post.name or IsInDirtRoom(px,py,pz) then
				chestplace = chestplace + 1
			else
				PlaceChest(cx, cy, cz, minetest.dir_to_facedir({x=ox, y=oy, z=oz}))
			end
		end

		-- A rail at the side of the track to put a cart on
		if i == cartplace and #tsm_railcorridors.carts > 0 then
			local cx, cy, cz = left_or_right(px, py, pz, vx, vy, vz)
			if get_node_name_raw(cx, cy, cz) == post.name then
				cartplace = cartplace + 1
			else
				if IsRailSurface(cx, cy-1, cz) and PlaceRail(cx, cy, cz, damage) then
					-- We don't put on a cart yet, we put it in the carts table
					-- for later placement
					table.insert(carts_table, {pos = {x=cx, y=cy, z=cz}, cart_type = pr_carts:next(1, #tsm_railcorridors.carts) })
				end
			end
		end

		-- Mob spawner (at center)
		if place_mob_spawners and nodes.spawner and not no_spawner then
			local p = {x=px,y=py,z=pz}
			local major = webperlin_major:get_3d(p)
			local minor = major > 0.3 and webperlin_minor:get_3d(p)
			if major > 0.3 and minor > 0.5 then
				-- Place spawner (if activated in gameconfig),
				-- enclose in cobwebs and setup the spawner node.
				local spawner_placed = SetNodeIfCanBuild(px,py,pz, nodes.spawner)
				if spawner_placed then
					local size = major > 0.5 and 2 or 1
					if place_cobwebs then
						Cube(px,py,pz, size, nodes.cobweb, true)
					end
					tsm_railcorridors.on_construct_spawner(p)
					no_spawner = true
				end
			end
		end

		-- Main rail; this places almost all the rails
		if IsRailSurface(px,py-1,pz) then PlaceRail(px,py,pz, damage) end

		-- Place cobwebs left and right in the corridor
		if place_cobwebs and nodes.cobweb then
			-- Helper function to place a cobweb at the side (based on chance an Perlin noise)
			local function cobweb_at_side(x,y,z,vx,vy,vz)
				if pr:next(1,5) ~= 1 then
					local h = pr:next(0, 2) -- 3 possible cobweb heights
					local cpos = {x=x+vx, y=y+h, z=z+vz}
					if webperlin_major:get_3d(cpos) > 0.05 and webperlin_minor:get_3d(cpos) > 0.1 then
						-- No check neccessary at height offset 0 since the cobweb is on the floor
						return TryPlaceCobweb(x+vx,y+h,z+vz, h==0, vx, vy, vz)
					end
				end
			end

			-- Right cobweb
			cobweb_at_side(px,py,pz,-vz,0, vx)
			-- Left cobweb
			cobweb_at_side(px,py,pz, vz,0,-vx)

		end
	end

	if up_or_down then
		if up then
			fy = fy - 1
		elseif axis == "x" then
			fx = fx + segamount
		elseif axis == "z" then
			fz = fz + segamount
		end
		-- After going up or down, 1 missing rail piece must be added
		Platform(fx,fy-1,fz, 0, wood)
		if IsRailSurface(fx,fy-2,fz) then
			PlaceRail(fx,fy-1,fz, damage)
		end
	end
	if not corridor_dug then return end
	return fx, fy, fz, no_spawner
end

-- Generate a line of corridors.
-- The corridor can go up/down, take turns and it can branch off, creating more corridor lines.
local function create_corridor_line(wx, wy, wz, a, s, length, wood, post, damage, no_spawner)
	local ud = false -- Up or down
	local udn = false -- Up or down is next
	local udp = false -- Up or down was previous
	local up = false -- true if going up
	local upp = false -- true if was going up previously
	for i=1,length do
		-- Update previous up/down status
		udp = ud
		-- Can't go up/down if a platform is needed at waypoint
		local needs_platform = NeedsPlatform(wx,wy-2,wz)
		-- Update current up/down status
		if udn and not needs_platform then
			ud = true
			-- Force direction near the height limits
			if wy >= height_max - 12 then
				if udp then
					ud = false
				end
				up = false
			elseif wy <= height_min + 12 then
				if udp then
					ud = false
				end
				up = true
			else
				-- If previous was up/down, keep the vertical direction
				if udp and not chaos_mode then
					up = upp
				else
					-- Chose random direction
					up = pr:next(1, 2) == 1
				end
			end
			upp = up
		else
			ud = false
		end
		-- Update next up/down status
		if pr:next(0,1e9) * 1e-9 < probability_up_or_down and i~=1 and not udn and not needs_platform then
			udn = i < length
		elseif udn and not needs_platform then
			udn = false
		end
		-- Make corridor
		local first_or_final = (i == length and "final") or (i == 1 and "first")
		wx, wy, wz, no_spawner = create_corridor_section(wx,wy,wz,a,s, ud, udn, udp, up, wood, post, first_or_final, damage, no_spawner)
		if not wx then return end
		-- Fork in the road? If so, starts 2-3 new corridor lines and terminates the current one.
		if pr:next(0,1e9) * 1e-9 < probability_fork then
			-- 75% chance to fork off in 3 directions (making a crossing)
			-- 25% chance to fork off in 2 directions (making a t-junction)
			local is_crossing = pr:next(0, 3) < 3
			local forks = is_crossing and 3 or 2
			local a2 = a == "x" and "z" or "x"
			local fork_dirs = {
				{a2, s}, -- to the side
				{a2, not s}, -- to the other side
				{a, s}, -- straight ahead
			}
			for _= 1, forks do
				local r = pr:next(1, #fork_dirs)
				create_corridor_line(wx, wy, wz, fork_dirs[r][1], fork_dirs[r][2], pr:next(way_min,way_max), wood, post, damage, no_spawner)
				table.remove(fork_dirs, r)
			end
			if is_crossing and not IsInDirtRoom(wx, wy, wz) then
				-- 4 large wooden pillars around the center rail
				WoodBulk(wx, wy-1, wz, 4, wood)
			end
			return
		end
		-- Randomly change sign, toggle axis.
		-- In other words, take a turn.
		a = a == "x" and "z" or "x"
		s = pr:next(1, 2) == 1
	end
end

-- Spawns all carts in the carts table and clears the carts table afterwards
local function spawn_carts()
	for c=1, #carts_table do
		local cpos = carts_table[c].pos
		local cart_type = carts_table[c].cart_type
		local nodename = get_node_name(cpos)
		if nodename == nodes.rail.name then
			-- FIXME: The cart sometimes fails to spawn
			-- See <https://github.com/minetest/minetest/issues/4759>
			local cart_id = tsm_railcorridors.carts[cart_type]
			minetest.log("info", "[tsm_railcorridors] Cart spawn attempt: "..core.pos_to_string(cpos))
			local cart_staticdata = nil

			-- Try to create cart staticdata
			local hook = tsm_railcorridors.create_cart_staticdata
			if hook then cart_staticdata = hook(cart_id, cpos, pr, pr_carts) end

			minetest.add_entity(cpos, cart_id, cart_staticdata)
		end
	end
	carts_table = {}
end

-- Start generation of a rail corridor system
-- main_cave_coords is the center of the floor of the dirt room, from which
-- all corridors expand.
local function create_corridor_system(main_cave_coords, pr)
	-- Dirt room size
	local maxsize = chaos_mode and 9 or 6
	local size = pr:next(3, maxsize)

	--[[ Only build if starter coords are in the ground.
	Prevents corridors starting in mid-air or in liquids. ]]
	-- Center of the room, on the floor
	if not IsGround(main_cave_coords.x,        main_cave_coords.y, main_cave_coords.z       ) then return false end
	-- Also check near the 4 bottom corners of the dirt room
	if not IsGround(main_cave_coords.x+size-1, main_cave_coords.y, main_cave_coords.z+size-1) then return false end
	if not IsGround(main_cave_coords.x-size+1, main_cave_coords.y, main_cave_coords.z+size-1) then return false end
	if not IsGround(main_cave_coords.x+size-1, main_cave_coords.y, main_cave_coords.z-size+1) then return false end
	if not IsGround(main_cave_coords.x-size+1, main_cave_coords.y, main_cave_coords.z-size+1) then return false end

	local height = math.min(pr:next(4, 7), size)
	local floor_diff = pr:next(0, 100) < 50 and 0 or 1
	local dirt_mode = pr:next(1,2)
	-- Small chance to fill dirt room with random rails
	local decorations_mode = pr:next(1,1000) == 1000 and 1 or 0

	--[[ Starting point: A big hollow dirt cube from which the corridors will extend.
	Corridor generation starts here. ]]
	DirtRoom(main_cave_coords.x, main_cave_coords.y, main_cave_coords.z, size, height, dirt_mode, decorations_mode)
	main_cave_coords.y = main_cave_coords.y + 2 + floor_diff

	-- Determine if this corridor system is “damaged” (some rails removed) and to which extent
	local damage = pr:next(0,1e9)*1e-9 < probability_damage and pr:next(10, 50) * 0.01 or 0

	-- Get wood and fence post types, using gameconfig.
	local wood, post = nodes.corridor_woods_function(main_cave_coords, get_node_name(main_cave_coords))


	-- Start 2-4 corridors in each direction
	local dirs = {
		{axis="x", axis2="z", sign=false},
		{axis="x", axis2="z", sign=true},
		{axis="z", axis2="x", sign=false},
		{axis="z", axis2="x", sign=true},
	}
	local first_corridor
	local corridors = 2
	for _=1, 2 do
		if pr:next(0,100) < 70 then
			corridors = corridors + 1
		end
	end
	-- Chance for 5th corridor in Chaos Mode
	if chaos_mode and size > 4 then
		if pr:next(0,100) < 50 then
			corridors = corridors + 1
		end
	end
	local centered_crossing = corridors <= 4 and pr:next(1, 20) >= 11
	-- This moves the start of the corridors in the dirt room back and forth
	local d_max = floor_diff == 1 and height <= 4 and 4 or 3
	local from_center_base = size - pr:next(1,d_max)
	for i=1, math.min(4, corridors) do
		local d = pr:next(1, #dirs)
		local dir = dirs[d]
		local side_offset = 0
		if not centered_crossing and size > 3 then
			if i==1 and corridors == 5 then
				side_offset = pr:next(2, size-2)
				if pr:next(1,2) == 1 then
					side_offset = -side_offset
				end
			else
				side_offset = pr:next(-size+2, size-2)
			end
		end
		local from_center = from_center_base
		if dir.sign then from_center = -from_center end
		if i == 1 then
			first_corridor = {sign=dir.sign, axis=dir.axis, axis2=dir.axis2, side_offset=side_offset, from_center=from_center}
		end
		local c = vector.add(main_cave_coords, {[dir.axis] = from_center, y=0, [dir.axis2] = side_offset})
		create_corridor_line(c.x, c.y, c.z, dir.axis, dir.sign, pr:next(way_min,way_max), wood, post, damage, false)
		table.remove(dirs, d)
	end
	if corridors == 5 then
		local s = vector.add(main_cave_coords, {[first_corridor.axis2] = -first_corridor.side_offset, y=0, [first_corridor.axis] = first_corridor.from_center})
		create_corridor_line(s.x, s.y, s.z, first_corridor.axis, first_corridor.sign, pr:next(way_min,way_max), wood, post, damage, false)
	end

	-- At this point, all corridors were generated and all nodes were set.
	-- We spawn the carts now
	spawn_carts()
	return true
end

mcl_structures.register_structure("mineshaft",{
	place_on = {"group:sand","group:grass_block","mcl_core:water_source","group:dirt","mcl_core:dirt_with_grass","mcl_core:gravel","group:material_stone","mcl_core:snow"},
	fill_ratio = 0.0001, -- 64%, pretty high?
	flags = "place_center_x, place_center_z, force_placement, all_floors",
	sidelen = 80,
	y_max = 40,
	y_min = mcl_vars.mg_overworld_min,
	place_func = function(pos,_,pr,blockseed)
		local r = pr:next(-50,-10)
		local p = vector.offset(pos,0,r,0)
		if p.y < mcl_vars.mg_overworld_min + 5 then
			p.y = mcl_vars.mg_overworld_min + 5
		end
		if p.y > -10 then return true end
		InitRandomizer(blockseed)

		local hook = tsm_railcorridors.on_start
		if hook then hook() end

		create_corridor_system(p, pr)

		local hook = tsm_railcorridors.on_finish
		if hook then hook() end

		return true
	end,

})
