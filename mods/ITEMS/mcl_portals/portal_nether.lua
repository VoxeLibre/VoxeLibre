local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

-- Localize functions for better performance
local abs = math.abs
local ceil = math.ceil
local floor = math.floor
local max = math.max
local min = math.min
local random = math.random
local vector_new = vector.new
local vector_copy = vector.copy
local vector_offset = vector.offset
local vector_subtract = vector.subtract
local vector_distance = vector.distance

local log = function(level, message)
	minetest.log(level, string.format("[mcl_portals] %s", message))
end

-- Resources

-- Issue that has a lot of context: https://git.minetest.land/VoxeLibre/VoxeLibre/issues/4120
-- Minecraft portal mechanics: https://minecraft.fandom.com/wiki/Tutorials/Nether_portals
-- Flow diagram: https://docs.google.com/drawings/d/1WIl4pVuxgOxI3Ncxk4g6D1pL4Fyll3bQ-fX6L9yyiLw/edit
-- Useful boundaries: https://git.minetest.land/VoxeLibre/VoxeLibre/wiki/World-structure%3A-positions%2C-boundaries%2C-blocks%2C-chunks%2C-dimensions%2C-barriers-and-the-void

-- Setup

-- === CAUTION ===
-- the following values: SEARCH_DISTANCE_OVERWORLD, SEARCH_DISTANCE_NETHER,
-- BUILD_DISTANCE_XY, W_MAX, and NETHER_COMPRESSION have been set to together
-- guarantee that standard 2-wide portals will never split into two exits.
-- Splitting will still occur rarely for portals in the overworld wider than 2,
-- will still be likely for portals in the nether wider than 16, and guaranteed
-- for portals in the nether wider than 18.
-- Changing one value without changing the others might have uninteded
-- consequences. You have been warned :-)

-- Distance compression factor for the nether. If you change this, you might
-- want to recalculate SEARCH_DISTANCE_* and W_MAX too.
local NETHER_COMPRESSION		= 8
-- Maximum distance from the ideal build spot where active parts of portals are
-- allowed to be placed.
-- There is a tradeoff here between the "walking" distance (distance to walk in
-- the overworld to get a new nether portal exit, which we want to be as similar
-- to Minecraft as possible, which is 136 [16*8+8]), and the area available for
-- exit search (which we want to maximise).
-- For our mapgen performance reasons, our search area is clipped by chunk, so
-- in the unlucky corner case the worst-case build area could be a quarter of
-- the expected size.
-- For MC build distance of 16, which gives a build area of 1,089 X-Z blocks
-- [(16+16+1)*(16+16+1)]. To guarantee this area here, we'd need to pick a build
-- distance of 32 [(32+32+1)*(32+32+1)/4]. But build distance of 32 implies
-- walking distance of 264 [32*8+8], which is already quite far, so need to pick
-- the right tradeoff:
--
-- Build dist   Minimum build area      Minimum walk distance
-- 48            2,401                  392
-- 32            1,089                  264
-- 24            625                    200
-- 16            289                    136
local BUILD_DISTANCE_XZ			= 24
-- The following two values define distance to search existing portal exits for.
-- For context, Minecraft search is "8 chunks away" for the overworld (17
-- chunks centered on the ideal position), and "1 chunk away" for the nether (3
-- chunks centered on the ideal position).
-- To prevent portal splitting on spawned portals, we add one to the build
-- distance: spawned portals are 2-wide, so we need to make sure that we can
-- reach the second exit block (which can spawn in the direction away from the
-- player).
-- The search is boundary-inclusive, meaning for position 0 in the overworld,
-- search will be from -N to N.
-- If you change this, keep in mind our exits table keying divisor is 256, so
-- small changes might have outsize performance impact. At <=128, max 4 buckets
-- are searched, at 200 max 9 buckets are searched.
local SEARCH_DISTANCE_NETHER		= BUILD_DISTANCE_XZ + 1 -- 25
local SEARCH_DISTANCE_OVERWORLD		= SEARCH_DISTANCE_NETHER * NETHER_COMPRESSION -- 200
-- Limits of portal sizes (includes the frame)
local W_MIN, W_MAX			= 4, 23
local H_MIN, H_MAX			= 5, 23
-- Limits to active nodes (mcl_portals:portal)
local N_MIN, N_MAX			= 6, (W_MAX-2) * (H_MAX-2)
local LIM_MIN, LIM_MAX			= vl_worlds.mapgen_edge_min, vl_worlds.mapgen_edge_max
local PLAYER_COOLOFF, MOB_COOLOFF	= 3, 14 -- for this many seconds they won't teleported again
local TOUCH_CHATTER_TIME		= 1 -- prevent multiple teleportation attempts caused by multiple portal touches, for this number of seconds
local CHATTER_US			= TOUCH_CHATTER_TIME * 1000000

local nether_portal_creative_delay = 0
vl_tuning.setting("gamerule:playersNetherPortalCreativeDelay", "number", {
	default = 0,
	set = function(val) nether_portal_creative_delay = val end,
	get = function() return nether_portal_creative_delay end,
})
local nether_portal_survival_delay = 4
vl_tuning.setting("gamerule:playersNetherPortalDefaultDelay", "number", {
	default = 4,
	set = function(val) nether_portal_survival_delay = val end,
	get = function() return nether_portal_survival_delay end,
})

-- Speeds up the search by allowing some non-air nodes to be replaced when
-- looking for acceptable portal locations. Setting this lower means the
-- algorithm will do more searching. Even at 0, there is no risk of finding
-- nothing - the most airy location will be used as fallback anyway.
local ACCEPTABLE_PORTAL_REPLACES	= 2


local PORTAL				= "mcl_portals:portal"
local OBSIDIAN				= "mcl_core:obsidian"

-- Dimension-specific Y boundaries for portal exit search.  Portal search
-- algorithm will only ever look at two vertically offset chunks.  It will
-- select whether the second chunk is up or down based on which side has more
-- "valid" Y-space (where valid is defined as space between *_Y_MIN and
-- *_Y_MAX).
-- For nether, selection of the boundaries doesn't matter, because it fits
-- entirely within two chunks.
local N_Y_MIN				= mcl_vars.mg_lava_nether_max + 1
local N_Y_MAX				= mcl_vars.mg_bedrock_nether_top_min
local N_Y_SPAN				= N_Y_MAX - N_Y_MIN
-- Overworld however is much taller. Let's select the boundaries so that we
-- maximise the Y-space (so align with chunk boundary), and also pick an area
-- that has a good chance of having "find_nodes_in_area_under_air" return
-- something (so ideally caves, or surface, not just sky).
-- For the bottom bound, we try for the first chunk boundary in the negative Ys (-32).
local O_Y_MIN				= max(mcl_vars.mg_lava_overworld_max + 1, vl_worlds.central_chunk_offset_in_nodes)
-- Since O_Y_MIN is also used as a base for converting coordinates, we need to
-- make sure the top bound is high enough to encompass entire nether height. In
-- v7 mapgen nether is flatter than overworld, so this results in a span of
-- exactly two chunks.
-- Due to the O_Y_MIN being used as a base, the preferred build locations will
-- be in the bottom part of the overworld range (in v7 around -32 to 61), and
-- the high locations will be used as a fallback.  If we see too many
-- underground portals, we may need to shift just this base upwards (new setting).
local O_Y_SPAN				= max(N_Y_SPAN, 2 * vl_worlds.chunk_size_in_nodes - 1)
local O_Y_MAX				= min(mcl_vars.mg_overworld_max_official, O_Y_MIN + O_Y_SPAN)

log("verbose", string.format("N_Y_MIN=%.1f, N_Y_MAX=%.1f, O_Y_MIN=%.1f, O_Y_MAX=%.1f", N_Y_MIN, N_Y_MAX, O_Y_MIN, O_Y_MAX))
log("verbose", string.format("Nether span is %.1f, overworld span is %.1f", N_Y_MAX-N_Y_MIN+1, O_Y_MAX-O_Y_MIN+1))

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

-- Searching for portal exits, finding locations and building portals can be time consuming.
-- We can queue origins together, on the assumption they will all go to the same place in the end.
local origin_queue = {}
-- At the same time, we never want to build two portals in the same area at the
-- same time, because they will interfere and we can end up with broken portals,
-- possibly stranding the player. We won't use queue here - double queueing can
-- lead to deadlocks.  We will instead interrupt the portal building, and rely
-- on the ABM to try again later.
local chunk_building = {}

local storage = mcl_portals.storage

-- `exits` is a table storing portal exits (both nether or overworld) bucketed
-- by 256x256 areas (with each bucket containing many exits, and covering entire range of Y).
-- An exit is a location of ignited PORTAL block, with another PORTAL block above
-- and obsidian below. Thus each portal will register at minimum two exits, but more
-- for bigger portals up to the maximum of W_MAX-2.
-- This table should be maintained using `add_exits`, `remove_exits` and `find_exit`.
local exits = {}

local keys = minetest.deserialize(storage:get_string("nether_exits_keys") or "return {}") or {}
for _, key in pairs(keys) do
	local n = tonumber(key)
	if n then
		exits[key] = minetest.deserialize(storage:get_string("nether_exits_"..key) or "return {}") or {}
	end
end

local get_node = mcl_vars.get_node
local set_node = minetest.set_node
local registered_nodes = minetest.registered_nodes
local is_protected = minetest.is_protected
local find_nodes_in_area = minetest.find_nodes_in_area
local find_nodes_in_area_under_air = minetest.find_nodes_in_area_under_air
local pos_to_string = minetest.pos_to_string
local is_area_protected = minetest.is_area_protected
local get_us_time = minetest.get_us_time

local dimension_to_teleport = { nether = "overworld", overworld = "nether" }

local limits = {
	nether = {
		pmin = vector_new(LIM_MIN, N_Y_MIN, LIM_MIN),
		pmax = vector_new(LIM_MAX, N_Y_MAX, LIM_MAX),
	},
	overworld = {
		pmin = vector_new(LIM_MIN, O_Y_MIN, LIM_MIN),
		pmax = vector_new(LIM_MAX, O_Y_MAX, LIM_MAX),
	},
}

-- Deletes exit from this portal's node storage.
local function delete_portal_pos(pos)
	local p1 = vector_offset(pos,-5,-1,-5)
	local p2 = vector_offset(pos,5,5,5)
	local nn = find_nodes_in_area(p1,p2,{"mcl_portals:portal"})
	for _,p in pairs(nn) do
		minetest.get_meta(p):set_string("target_portal","")
	end
end

-- Gets exit for this portal from node storage. After Jan 2024 this is only used
-- for old portals, so that players don't get surprises. New portals, or portals that lost
-- node storage due to destruction should use the lookup table.
local function get_portal_pos(pos)
	local nn = find_nodes_in_area(vector_offset(pos,-5,-1,-5), vector_offset(pos,5,5,5), {"mcl_portals:portal"})
	for _,p in pairs(nn) do
		local m = minetest.get_meta(p):get_string("target_portal")
		if m and m ~= "" and minetest.get_node(p).name == "mcl_portals:portal" then
			return minetest.get_position_from_hash(m)
		end
	end
end

-- `exits` is a lookup table bucketing exits by 256x256 areas. This function
-- returns a key for provided position p.
local function get_exit_key(p)
	local x, z = floor(p.x), floor(p.z)
	return floor(z/256) * 256 + floor(x/256)
end

-- Add an exit to the exits table without writing to disk. Returns the exits
-- table key if modification was done, and specifies whether the key was new.
local function add_exit(p)
	local retval = {key=false, new=false}

	if not p or not p.y or not p.z or not p.x then return retval end
	local x, y, z = floor(p.x), floor(p.y), floor(p.z)
	local p = vector_new(x, y, z)

	if get_node(vector_new(x, y-1, z)).name ~= OBSIDIAN
		or get_node(p).name ~= PORTAL
		or get_node(vector_new(x, y+1, z)).name ~= PORTAL
	then
		return retval
	end

	local k = get_exit_key(p)
	if not exits[k] then
		exits[k]={}
		retval.new = true
	end

	local e = exits[k]
	for i = 1, #e do
		local t = e[i]
		if t and t.x == p.x and t.y == p.y and t.z == p.z then
			return retval
		end
	end

	e[#e+1] = p
	retval.key = k
	return retval
end

-- This function registers one or more exits from Nether portals and writes
-- updated table buckets to disk.
-- Exit position must be an ignited PORTAL block that sits on top of obsidian,
-- and has additional PORTAL block above it.
-- This function will silently skip exits that are invalid during the call-time.
-- If the verification passes, a new exit is added to the table of exits and
-- saved to mod storage later. Duplicate exits will be skipped and won't cause
-- writes.
local function add_exits(positions)
	local keys_to_write = {}
	local new_key_present = false

	for _, p in ipairs(positions) do
		local r = add_exit(p)
		if r.key ~= false then
			if r.new then
				new_key_present = true
				keys[#keys+1] = r.key
			end
			keys_to_write[#keys_to_write+1] = r.key
			log("verbose", "Exit added at " .. pos_to_string(p))
		end
	end

	for _, key in ipairs(keys_to_write) do
		storage:set_string("nether_exits_"..tostring(key), minetest.serialize(exits[key]))
	end
	if new_key_present then
		storage:set_string("nether_exits_keys", minetest.serialize(keys))
	end
end

-- Removes one portal exit from the exits table without writing to disk.
-- Returns the false or bucket key if change was made.
local function remove_exit(p)
	if not p or not p.y or not p.z or not p.x then
		return false
	end

	local x, y, z = floor(p.x), floor(p.y), floor(p.z)
	local p = vector_new(x, y, z)

	local k = get_exit_key(p)
	if not exits[k] then
		return false
	end

	local e = exits[k]
	if e then
		for i, t in pairs(e) do
			if t and t.x == x and t.y == y and t.z == z then
				e[i] = nil
				return k
			end
		end
	end

	return false
end

-- Removes one or more portal exits and writes updated table buckets to disk.
local function remove_exits(positions)
	local keys_to_write = {}

	for _, p in ipairs(positions) do
		r = remove_exit(p)
		if r ~= false then
			keys_to_write[#keys_to_write+1] = r
			log("verbose", "Exit removed from " .. pos_to_string(p))
		end
	end

	for _, key in ipairs(keys_to_write) do
		storage:set_string("nether_exits_"..tostring(key), minetest.serialize(exits[key]))
	end
end

-- Searches for portal exits nearby point p within the distances specified by dx
-- and dz (but only in the same dimension). Otherwise as in Minecraft, the
-- search is bounded by X and Z, but not Y.
-- If multiple exits are found, use Euclidean distance to find the nearest. This
-- uses all three coordinates.
local function find_exit(p, dx, dz)
	local dim = mcl_worlds.pos_to_dimension(p)

	if not p or not p.y or not p.z or not p.x then
		log("warning", "Corrupt position passed to find_exit: "..pos_to_string(p)..".")
		return
	end
	if dx < 1 or dz < 1 then return false end

	local x = floor(p.x)
	local z = floor(p.z)

	local x1 = x-dx
	local z1 = z-dz

	local x2 = x+dx
	local z2 = z+dz

	-- Scan the relevant hash table keys for viable exits. Dimension's entire Y is scanned.
	local k1x, k2x = floor(x1/256), floor(x2/256)
	local k1z, k2z = floor(z1/256), floor(z2/256)
	local nearest_exit, nearest_distance
	for kx = k1x, k2x do
		for kz = k1z, k2z do
			local k = kz*256 + kx
			local e = exits[k]
			if e then
				for _, t0 in pairs(e) do
					if mcl_worlds.pos_to_dimension(t0) == dim then
						-- exit is in the correct dimension
						if abs(t0.x-p.x) <= dx and abs(t0.z-p.z) <= dz then
							-- exit is within the search range
							local d0 = vector_distance(p, t0)
							if not nearest_distance or nearest_distance>d0 then
								-- it is the only exit so far, or it is the Euclidean-closest exit
								nearest_distance = d0
								nearest_exit = t0
								if nearest_distance==0 then return nearest_exit end
							end
						end
					end
				end
			end
		end
	end

	return nearest_exit
end

minetest.register_chatcommand("dumpportalkeys", {
	description = S("Dump all portal keys"),
	privs = { debug = true },
	func = function(name, param)
		keys = {}
		for k, _ in pairs(exits) do
			keys[#keys+1] = k
		end
		output = string.format("Nether portal exits keys: %s", table.concat(keys, ", "))
		return true, output
	end,
})

local function dump_key(key)
	output = string.format("[%d] => ", tonumber(key))
	for _,p in pairs(exits[tonumber(key)]) do
		output = output .. minetest.pos_to_string(p) .. " "
	end
	output = output .. "\n"
	return output
end

minetest.register_chatcommand("dumpportalexits", {
	description = S("Dump coordinates of registered nether portal exits"),
	privs = { debug = true },
	params = "[key]",
	func = function(name, param)
		local key = param

		if not key or key == "" then
			output = "Nether portal exit locations (all dimensions):\n"
		else
			output = string.format("Nether portal exit locations for key [%s] (all dimensions):\n", key)
		end

		if not key or key == "" then
			local count = 0
			for k, _ in pairs(exits) do
				count = count + 1
				if count>100 then
					output = output .. "The list exceeds 100 keys, truncated. Try /dumpportalkeys, then /dumpportalexits KEY"
					break
				end

				output = output .. dump_key(k)
			end
		else
			-- key specified, no limits
			if not exits[tonumber(key)] then
				output = output .. string.format("No exits in key [%s]\n", key)
			else
				dump_key(key)
			end
		end

		return true, output
	end,
})

-- Map coordinates between dimensions. Distances in X and Z are scaled by NETHER_COMPRESSION.
-- Distances in Y are mapped directly. Caller should check the return value, this function
-- returns nil if there is no valid mapping - for example if the target would be out of world.
local function get_target(p)
	if not p or not p.y or not p.x or not p.z then
		return
	end

	local _, dim = mcl_worlds.y_to_layer(p.y)
	local x,y,z
	if dim=="nether" then
		-- traveling to OW
		x = floor(p.x * NETHER_COMPRESSION)
		z = floor(p.z * NETHER_COMPRESSION)

		if x>=LIM_MAX or x<=LIM_MIN or z>=LIM_MAX or z<=LIM_MIN then
			-- Traveling out of bounds is forbidden.
			return
		end

		y = max(min(p.y, N_Y_MAX), N_Y_MIN)
		y = y - N_Y_MIN
		y = O_Y_MIN + y
		y = max(min(y, O_Y_MAX), O_Y_MIN)
	else
		-- traveling to the nether
		x = floor(p.x / NETHER_COMPRESSION)
		z = floor(p.z / NETHER_COMPRESSION)

		if x>=LIM_MAX or x<=LIM_MIN or z>=LIM_MAX or z<=LIM_MIN then
			-- Traveling out of bounds is forbidden.
			return
		end

		y = max(min(p.y, O_Y_MAX), O_Y_MIN)
		y = y - O_Y_MIN
		y = N_Y_MIN + y
		y = max(min(y, N_Y_MAX), N_Y_MIN)
	end

	return vector_new(x,y,z)
end

-- Destroy a nether portal.  Connected portal nodes are searched and removed
-- using 'bulk_set_node'.  This function is called from 'after_destruct' of
-- nether portal nodes.  The flag 'destroying_portal' is used to avoid this
-- function being called recursively through callbacks in 'bulk_set_node'.
-- To maintain portal integrity, it is permitted to destroy protected portal
-- blocks if the portal structure is only partly protected, and the player
-- destroys the part that is sticking out.
local destroying_portal = false
local function destroy_nether_portal(pos, node)
	if destroying_portal then
		return
	end
	destroying_portal = true

	local orientation = node.param2
	local checked_tab = { [minetest.hash_node_position(pos)] = true }
	local nodes = { pos }

	local function check_remove(pos)
		local h = minetest.hash_node_position(pos)
		if checked_tab[h] then
			return
		end

		local node = minetest.get_node(pos)
		if node and node.name == PORTAL and (orientation == nil or node.param2 == orientation) then
			table.insert(nodes, pos)
			checked_tab[h] = true
		end
	end

	local i = 1
	while i <= #nodes do
		pos = nodes[i]
		if orientation == 0 then
			check_remove(vector_offset(pos, -1, 0, 0))
			check_remove(vector_offset(pos,  1, 0, 0))
		else
			check_remove(vector_offset(pos, 0, 0, -1))
			check_remove(vector_offset(pos, 0, 0,  1))
		end
		check_remove(vector_offset(pos, 0, -1, 0))
		check_remove(vector_offset(pos, 0,  1, 0))
		remove_exits({pos})
		i = i + 1
	end

	minetest.bulk_set_node(nodes, { name = "air" })
	destroying_portal = false
end

local on_rotate
if minetest.get_modpath("screwdriver") then
	-- Presumably because it messes with the placement of exits.
	on_rotate = screwdriver.disallow
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
	use_texture_alpha = "blend",
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
	on_rotate = on_rotate,

	_mcl_hardness = -1,
	_mcl_blast_resistance = 0,
})

local function build_and_light_frame(x1, y1, z1, x2, y2, z2, name)
	local orientation = 0
	if x1 == x2 then
		orientation = 1
	end
	local pos = {}
	for x = x1 - 1 + orientation, x2 + 1 - orientation do
		pos.x = x
		for z = z1 - orientation, z2 + orientation do
			pos.z = z
			for y = y1 - 1, y2 + 1 do
				pos.y = y
				local frame = (x < x1) or (x > x2) or (y < y1) or (y > y2) or (z < z1) or (z > z2)
				if frame then
					set_node(pos, {name = OBSIDIAN})
				else
					set_node(pos, {name = PORTAL, param2 = orientation})
					add_exits({ vector_offset(pos, 0, -1, 0) })
				end
			end
		end
	end
end

-- Create a portal, where cube_pos1 is the "bottom-left" coordinate of the
-- W_MINxH_MIN cube to contain the portal - i.e. the coordinate with the
-- smallest X, Y and Z. We will be placing the portal in the middle-ish, so
-- that block +1,+1,+1 is guaranteed to be a portal block. The build area
-- includes frame.
-- Small obsidian platform will be created on either side of the exit if there
-- is no nodes there, or nodes underneath (one step down is permitted).
-- Orientation 0 is portal alongside X axis, 1 alongside Z.
function build_nether_portal(cube_pos1, width, height, orientation, name, clear_before_build)
	local width, height, orientation = width or W_MIN, height or H_MIN, orientation or random(0, 1)
	local width_inner = width-2
	local height_inner = height-2

	local cube_pos2 = vector_offset(cube_pos1, width - 1, height - 1, width - 1)
	if is_area_protected(cube_pos1, cube_pos2, name) then
		if name then
			minetest.chat_send_player(name, "Unable to build portal, area is protected.")
		end
		return
	end

	-- Calculate "bottom-left" position of the PORTAL blocks.
	-- Offset Y because we don't want it in the floor.
	-- Offset X and Z to fit the frame and place the portal in the middle-ish.
	local pos = vector_offset(cube_pos1, 1, 1, 1)

	if clear_before_build then
		local clear1, clear2
		if orientation == 0 then
			clear1 = vector_offset(cube_pos1, 0, 1, 0) -- do not delete floor
			clear2 = vector_offset(cube_pos1, width - 1, height - 2, 2) -- both sides of the entrance, so player has somewhere to step.
		else
			clear1 = vector_offset(cube_pos1, 0, 1, 0) -- do not delete floor
			clear2 = vector_offset(cube_pos1, 2, height - 2, width - 1) -- both sides of the entrance, so player has somewhere to step.
		end

		log("verbose", "Clearing between "..pos_to_string(clear1).." and "..pos_to_string(clear2))
		local airs = {}
		for x = clear1.x, clear2.x do
			for y = clear1.y, clear2.y do
				for z = clear1.z, clear2.z do
					airs[#airs+1] = vector_new(x,y,z)
				end
			end
		end
		minetest.bulk_set_node(airs, {name="air"})
	end

	build_and_light_frame(pos.x, pos.y, pos.z, pos.x + (1 - orientation) * (width_inner - 1), pos.y + height_inner - 1, pos.z + orientation * (width_inner - 1), name)

	-- Build obsidian platform:
	for x = pos.x - orientation, pos.x + orientation + (width_inner - 1) * (1 - orientation), 1 + orientation do
		for z = pos.z - 1 + orientation, pos.z + 1 - orientation + (width_inner - 1) * orientation, 2 - orientation do
			local pp = vector_new(x, pos.y - 1, z)
			local pp_1 = vector_new(x, pos.y - 2, z)
			local nn = get_node(pp).name
			local nn_1 = get_node(pp_1).name
			if ((nn=="air" and nn_1 == "air") or not registered_nodes[nn].is_ground_content) and not is_protected(pp, name) then
				set_node(pp, {name = OBSIDIAN})
			end
		end
	end

	log("verbose", "Portal generated at "..pos_to_string(pos).."!")

	return pos
end

-- Spawn portal at location - spawning is not guaranteed if target area is protected.
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
	return build_nether_portal(pos, W_MIN, H_MIN, o, name, true)
end

-- Useful for testing - it lets player point to a block and create the portal in
-- the exact spot using the block as floor, with correct orientation (facing the
-- player). Alternatively, portals can be created at exact locations and
-- orientations (which spawn structure doesn't support).
minetest.register_chatcommand("spawnportal", {
	description = S("Spawn a new nether portal at pointed thing, or at [x],[y],[z]. "
		.."The portal will either face the player, or use the passed [orientation]. "
		.."Orientation 0 means alongside X axis."),
	privs = { debug = true },
	params = "[x] [y] [z] [orientation]",
	func = function(name, param)
		local params = {}
		for p in param:gmatch("-?[0-9]+") do table.insert(params, p) end

		local exit
		if #params==0 then
			local player = minetest.get_player_by_name(name)
			if not player then return false, "Player not found" end

			local yaw = player:get_look_horizontal()
			local player_rotation = yaw / (math.pi*2)
			local orientation
			if (player_rotation<=0.875 and player_rotation>0.625)
				or (player_rotation<=0.375 and player_rotation>0.125)
			then
				orientation = "90"
			else
				orientation = "0"
			end

			local pointed_thing = mcl_util.get_pointed_thing(player, false)
			if not pointed_thing then return false, "Not pointing to anything" end
			if pointed_thing.type~="node" then return false, "Not pointing to a node" end

			local pos = pointed_thing.under
			-- Portal node will appear above the pointed node. The pointed node will turn into obsidian.
			exit = mcl_portals.spawn_nether_portal(vector_offset(pos, -1, 0, -1), orientation, nil, name)
		elseif #params==3 or #params==4 then
			local pos = vector_new(tonumber(params[1]), tonumber(params[2]), tonumber(params[3]))

			local orientation = 0
			if #params==4 then
				if tonumber(params[4])==1 then orientation = "90" else orientation = "0" end
			end

			-- Portal will be placed so that the first registered exit is at requested location.
			exit = mcl_portals.spawn_nether_portal(vector_offset(pos, -1, -1, -1), orientation, nil, name)
		else
			return false, "Invalid parameters. Pass either zero, three or four"
		end

		if exit then
			return true, "Spawned!"
		else
			return false, "Unable to spawn portal, area could be protected"
		end
	end,
})


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
	local _, dim = mcl_worlds.y_to_layer(exit.y)

	-- If player stands, player is at ca. something+0.5 which might cause precision problems, so we used ceil for objpos.y
	objpos = vector_new(floor(objpos.x+0.5), ceil(objpos.y), floor(objpos.z+0.5))
	if get_node(objpos).name ~= PORTAL then
		log("action", "Entity no longer standing in portal")
		return
	end

	-- In case something went wrong, make sure the origin portal is always added as a viable exit.
	-- In the ideal case, this is not needed, as the exits are added upon ignition. Before Jan 2024 this
	-- was broken, so there will be a lot of half-added portals out there!
	add_exits({objpos})

	-- Enable teleportation cooloff for some seconds, to prevent back-and-forth teleportation
	teleport_cooloff(obj)

	obj:set_pos(exit)

	local lua_entity = obj:get_luaentity()
	if is_player then
		mcl_worlds.dimension_change(obj, dim)
		minetest.sound_play("mcl_portals_teleport", {pos=exit, gain=0.5, max_hear_distance = 16}, true)
		log("action", "Player "..name.." teleported to portal at "..pos_to_string(exit)..".")
		if dim == "nether" then
			awards.unlock(obj:get_player_name(), "mcl:theNether")
		end
	elseif lua_entity then
		log("verbose", string.format(
			"Entity %s teleported to portal at %s",
			lua_entity.name,
			pos_to_string(exit)
		))
	end
end

local function is_origin_queued(origin)
	return not not origin_queue[pos_to_string(origin)]
end

local function is_entity_queued(obj)
	for _, q in pairs(origin_queue) do
		if q[obj] then
			return true
		end
	end
	return false
end

local function origin_enqueue(obj, origin)
	local key = pos_to_string(origin)
	log("verbose", string.format("Queueing entity for origin %s", key))
	local q = origin_queue[key] or {}
	if not q[obj] then
		q[obj] = true
		origin_queue[key] = q
	end
end

-- Flush the queue of entities waiting for specific origin.
-- Pass nil/false exit to purge the queue without teleporting.
local function origin_flush(origin, exit)
	local key = pos_to_string(origin)

	local count_teleported = 0
	local count_removed = 0
	if origin_queue[key] then
		for obj, value in pairs(origin_queue[key]) do
			if value and exit then
				finalize_teleport(obj, exit)
				count_teleported = count_teleported + 1
			else
				count_removed = count_removed + 1
			end
		end
		origin_queue[key] = nil
	end
	log("verbose", string.format(
		"Finished flushing entities waiting for origin %s: removed %d, proceeded to teleport %d",
		key,
		count_removed,
		count_teleported
	))
end

local function find_build_limits(pos, target_dim)
	-- Find node extremes of the pos's chunk.
	-- According to what people said in minetest discord and couple of docs, mapgen
	-- works on entire chunks, so we need to limit the search to chunk boundary.
	-- The goal is to emerge at most two chunks.
	local chunk_pos = vl_worlds.pos_to_chunk(pos)
	local chunk_limit1 = vector_new(chunk_pos.x * vl_worlds.chunk_size_in_nodes + vl_worlds.central_chunk_offset_in_nodes,
	                                chunk_pos.y * vl_worlds.chunk_size_in_nodes + vl_worlds.central_chunk_offset_in_nodes,
	                                chunk_pos.z * vl_worlds.chunk_size_in_nodes + vl_worlds.central_chunk_offset_in_nodes)
	local chunk_limit2 = vector_offset(chunk_limit1, vl_worlds.chunk_size_in_nodes - 1, vl_worlds.chunk_size_in_nodes - 1, vl_worlds.chunk_size_in_nodes - 1)
	-- Limit search area by using search distances. There is no Y build limit.
	local build_limit1 = vector_offset(pos,
		-- minus 1 to account for the pos block being included.
		-- plus 1 to account for the portal block offset (ignore frame)
		-BUILD_DISTANCE_XZ-1+1, 0, -BUILD_DISTANCE_XZ-1+1
	)
	local build_limit2 = vector_offset(pos,
		-- plus 1 to account for the portal block offset (ignore frame)
		-- minus potential portal width, so that the generated portal doesn't "stick out"
		BUILD_DISTANCE_XZ+1-(W_MIN-1), 0, BUILD_DISTANCE_XZ+1-(W_MIN-1)
	)

	-- Start with chunk limits
	local pos1 = vector_new(chunk_limit1.x, chunk_limit1.y, chunk_limit1.z)
	local pos2 = vector_new(chunk_limit2.x, chunk_limit2.y, chunk_limit2.z)

	-- Make sure the portal is not built beyond chunk boundary
	-- (we will be searching for the node with lowest X, Y and Z)
	pos2.x = pos2.x-(W_MIN-1)
	pos2.y = pos2.y-(H_MIN-1)
	pos2.z = pos2.z-(W_MIN-1)
	-- Avoid negative volumes
	if pos2.x < pos1.x then pos2.x = pos1.x end
	if pos2.y < pos1.y then pos2.y = pos1.y end
	if pos2.z < pos1.z then pos2.z = pos1.z end

	-- Apply build distances and dimension-specific distances, so that player does not end up in void or in lava.
	local limit1, limit2 = limits[target_dim].pmin, limits[target_dim].pmax
	pos1.x = max(pos1.x, build_limit1.x, limit1.x)
	pos1.y = max(pos1.y, limit1.y)
	pos1.z = max(pos1.z, build_limit1.z, limit1.z)
	pos2.x = min(pos2.x, build_limit2.x, limit2.x)
	pos2.y = min(pos2.y, limit2.y)
	pos2.z = min(pos2.z, build_limit2.z, limit2.z)

	local diff = vector_subtract(pos2, pos1)
	local area = (diff.x + 1) * (diff.z + 1)
	local msg = string.format(
		"Portal build area between %s-%s, a %dx%dx%d cuboid with floor area of %d nodes. "
			.."Chunk limit was at [%s,%s]. "
			.."Ideal build area was at [(%d,*,%d),(%d,*,%d)].",
		pos_to_string(pos1),
		pos_to_string(pos2),
		diff.x + 1,
		diff.y + 1,
		diff.z + 1,
		area,
		pos_to_string(chunk_limit1),
		pos_to_string(chunk_limit2),
		build_limit1.x,
		build_limit1.z,
		build_limit2.x,
		build_limit2.z
	)
	log("verbose", msg)

	return pos1, pos2
end

local function get_lava_level(pos, pos1, pos2)
	if pos.y > -1000 then
		return mcl_vars.mg_lava_overworld_max
	end
	return mcl_vars.mg_lava_nether_max
end

local function search_for_build_location(blockpos, action, calls_remaining, param)
	if calls_remaining and calls_remaining > 0 then return end

	local target, pos1, pos2, name, obj = param.target, param.pos1, param.pos2, param.name or "", param.obj
	local chunk = vl_worlds.get_chunk_number(target)

	-- Portal might still exist in the area even though nothing was found in the table.
	-- This could be due to bugs, or old worlds (portals added before the exits table).
	-- Handle gracefully by searching and adding exits as appropriate.
	local exit
	local portals = find_nodes_in_area(pos1, pos2, {PORTAL})
	if portals and #portals>0 then
		for _, p in pairs(portals) do
			-- This will only add legitimate exits that are not on the list,
			-- and will only save if there was any changes.
			add_exits({p})
		end

		if param.target_dim=="nether" then
			exit = find_exit(target, SEARCH_DISTANCE_NETHER, SEARCH_DISTANCE_NETHER)
		else
			exit = find_exit(target, SEARCH_DISTANCE_OVERWORLD, SEARCH_DISTANCE_OVERWORLD)
		end
	end

	if exit then
		log("verbose", "Using a newly found exit at "..pos_to_string(exit))
		origin_flush(param.origin, exit)
		chunk_building[chunk] = false
		return
	end

	-- No suitable portal was found, look for a suitable space and build a new one in the emerged blocks.

	local nodes = find_nodes_in_area_under_air(pos1, pos2, {"group:building_block"})
	-- Sort by distance so that we are checking the nearest nodes first.
	-- This can speed up the search considerably if there is space around the ideal X and Z.
	local center = vector_offset(param.ideal_target, -1, -1, -1)
	table.sort(nodes, function(a,b)
		return vector_distance(center, a) < vector_distance(center, b)
	end)

	local most_airy_count, most_airy_pos, most_airy_distance = param.most_airy_count, param.most_airy_pos, param.most_airy_distance
	local lava = get_lava_level(target, pos1, pos2)
	local pos0, distance
	if nodes then
		local nc = #nodes
		if nc > 0 then
			for i=1,nc do
				local node = nodes[i]
				local portal_node = vector_offset(node, 1, 1, 1) -- Skip the frame
				local node1 = vector_offset(node, 0, 1, 0) -- Floor can be solid
				local node2 = vector_offset(node, W_MIN - 1, H_MIN - 1, W_MIN - 1)

				local nodes2 = find_nodes_in_area(node1, node2, {"air"})
				if nodes2 then
					local nc2 = #nodes2

					if not is_area_protected(node, node2, name) and node.y > lava then
						local distance0 = vector_distance(param.ideal_target, portal_node)

						if nc2 >= (W_MIN*(H_MIN-1)*W_MIN) - ACCEPTABLE_PORTAL_REPLACES then
							-- We have sorted the candidates by distance, this is the best location.
							distance = distance0
							pos0 = vector_copy(node)
							log("verbose", "Found acceptable location at "..pos_to_string(pos0)..", distance "..distance0..", air nodes "..nc2)
							break
						elseif not most_airy_pos or nc2>most_airy_count then
							-- Remember the cube with the most amount of air as a fallback.
							most_airy_count = nc2
							most_airy_distance = distance0
							most_airy_pos = vector_copy(node)
							log("verbose", "Found fallback location at "..pos_to_string(most_airy_pos)..", distance "..distance0..", air nodes "..nc2)
						elseif most_airy_pos and nc2==most_airy_count and distance0<most_airy_distance then
							-- Use distance as a tiebreaker.
							most_airy_distance = distance0
							most_airy_pos = vector_copy(node)
							log("verbose", "Found fallback location at "..pos_to_string(most_airy_pos)..", distance "..distance0..", air nodes "..nc2)
						end

					end
				end
			end
		end
	end
	if pos0 then
		log("verbose", "Building portal at "..pos_to_string(pos0)..", distance "..distance)
		local exit = build_nether_portal(pos0, W_MIN, H_MIN, random(0,1), name)
		origin_flush(param.origin, exit)
		chunk_building[chunk] = false
		return
	end

	-- Look in chunks above or below, depending on which side has more
	-- space. Since our Y map distance is quite short due to the flatness of
	-- the non-lava nether, falling back like this should cover entire Y range.
	if param.chunk_counter==1 then
		local direction
		if limits[param.target_dim].pmax.y-target.y > target.y-limits[param.target_dim].pmin.y then
			-- Look up
			direction = 1
			log("verbose", "No space found, emerging one chunk above")
		else
			-- Look down
			direction = -1
			log("verbose", "No space found, emerging one chunk below")
		end

		local new_target = vector_offset(target, 0, direction * vl_worlds.chunk_size_in_nodes, 0)
		pos1, pos2 = find_build_limits(new_target, param.target_dim)
		local diff = vector_subtract(pos2, pos1)

		-- Only emerge if there is sufficient headroom to actually fit entire portal.
		if diff.y+1>=H_MIN then
			local new_chunk = vl_worlds.get_chunk_number(new_target)
			if chunk_building[new_chunk] then
				log("verbose", string.format("Secondary chunk %s is currently busy, backing off", new_chunk))
				origin_flush(param.origin, nil)
				return
			end

			chunk_building[new_chunk] = true
			minetest.emerge_area(pos1, pos2, search_for_build_location, {
				origin=param.origin,
				target = new_target,
				target_dim = param.target_dim,
				ideal_target = param.ideal_target,
				pos1 = pos1,
				pos2 = pos2,
				name=name,
				obj=obj,
				chunk_counter=param.chunk_counter+1,
				most_airy_count=most_airy_count,
				most_airy_pos=most_airy_pos,
				most_airy_distance=most_airy_distance
			})

			chunk_building[chunk] = false
			return
		end
	end

	-- Fall back to the most airy position in previous chunk, in this chunk,
	-- or if all else fails to ideal position. This could replace a lot of blocks.
	local fallback = param.ideal_target

	if most_airy_pos then
		log(
			"verbose",
			string.format(
				"Falling back to the most airy position at %s, distance %d",
				pos_to_string(most_airy_pos),
				most_airy_distance
			)
		)
		fallback = most_airy_pos
	end

	if fallback.y <= lava then
		fallback.y = lava + 1
	end

	log("verbose", "Forcing portal at "..pos_to_string(fallback)..", lava at "..lava)
	local exit = build_nether_portal(fallback, W_MIN, H_MIN, random(0,1), name, true)
	origin_flush(param.origin, exit)
	chunk_building[chunk] = false
end

local function create_portal(origin, target, target_dim, name, obj)
	local chunk = vl_worlds.get_chunk_number(target)
	if chunk_building[chunk] then
		log("verbose", string.format("Primary chunk %s is currently busy, backing off", chunk))
		origin_flush(origin, nil)
		return
	end
	chunk_building[chunk] = true

	local pos1, pos2 = find_build_limits(target, target_dim)
	minetest.emerge_area(pos1, pos2, search_for_build_location, {
		origin = origin,
		target = target,
		target_dim = target_dim,
		ideal_target = vector.copy(target),
		pos1 = pos1,
		pos2 = pos2,
		name=name,
		obj=obj,
		chunk_counter=1
	})
end

local function available_for_nether_portal(p)
	-- No need to check for protected - non-owner can't ignite blocks anyway.

	local nn = get_node(p).name
	local obsidian = nn == OBSIDIAN
	if nn ~= "air" and minetest.get_item_group(nn, "fire") ~= 1 then
		return false, obsidian
	end
	return true, obsidian
end

local function check_and_light_shape(pos, orientation)
	local stack = {vector.copy(pos)}
	local node_list = {}
	local index_list = {}
	local node_counter = 0
	-- Search most low node from the left (pos1) and most right node from the top (pos2)
	local pos1, pos2 = vector.copy(pos), vector.copy(pos)

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
				node_list[node_counter] = vector_new(x, y, z)
				index_list[k] = true
				stack[i].y = y - 1
				stack[i + 1] = vector_new(x, y + 1, z)
				if orientation == 0 then
					stack[i + 2] = vector_new(x - 1, y, z)
					stack[i + 3] = vector_new(x + 1, y, z)
				else
					stack[i + 2] = vector_new(x, y, z - 1)
					stack[i + 3] = vector_new(x, y, z + 1)
				end
				if (y < pos1.y) or (y == pos1.y and (x < pos1.x or z < pos1.z)) then
					pos1 = vector_new(x, y, z)
				end
				if (x > pos2.x or z > pos2.z) or (x == pos2.x and z == pos2.z and y > pos2.y) then
					pos2 = vector_new(x, y, z)
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

	-- Light the portal
	for i = 1, node_counter do
		minetest.set_node(node_list[i], {name = PORTAL, param2 = orientation})
	end

	-- Register valid portal exits (each portal has at least two!)
	-- Before Jan 2024, there was a bug that did not register all exits upon ignition.
	-- This means portals lit before that time will only become live as people use them
	-- (and only specific portal blocks).
	for i = 1, node_counter do
		-- Improvement possible: we are only interested in the bottom
		-- blocks as exits, but here all ignited blocks are passed in.
		-- This can cause a lot of failed validations on very large
		-- portals that we know can be skipped.
		add_exits({node_list[i]})
	end

	return true
end

-- Attempts to light a Nether portal at pos
-- Pos can be any of the inner part.
-- The frame MUST be filled only with air or any fire, which will be replaced with Nether portal blocks.
-- If no Nether portal can be lit, nothing happens.
-- Returns true if portal created
function mcl_portals.light_nether_portal(pos)

	-- Only allow to make portals in Overworld and Nether
	local dim = mcl_worlds.pos_to_dimension(pos)
	if dim ~= "overworld" and dim ~= "nether" then
		return false
	end

	if not get_target(pos) then
		-- Prevent ignition of portals that would lead to out of bounds positions.
		log("verbose", string.format(
			"No target found for position %s - portal would lead to invalid exit",
			pos_to_string(pos)
		))
		return
	end

	local orientation = random(0, 1)
	for orientation_iteration = 1, 2 do
		if check_and_light_shape(pos, orientation) then
			return true
		end
		orientation = 1 - orientation
	end
	return false
end

local function check_portal_then_teleport(obj, origin, exit)
	-- Check we are not sending the player on a one-way trip.
	minetest.emerge_area(exit, exit, function (blockpos, action, calls_remaining, param)
		if calls_remaining and calls_remaining > 0 then return end

		if get_node(exit).name ~= PORTAL then
			-- Bogus exit! Break the teleportation so we don't strand the player.
			-- The process will begin again after cooloff through the ABM, and might either
			-- find another exit, or build a new portal. This will manifest to the
			-- player as a teleportation that takes longer than usual.
			log("warning", "removing bogus portal exit encountered at "..pos_to_string(exit)..", exit no longer exists")

			remove_exits({exit})
			-- Also remove from structure storage, otherwise ABM will try the same bad exit again.
			local objpos = obj:get_pos()
			delete_portal_pos(vector_new(floor(objpos.x+0.5), ceil(objpos.y), floor(objpos.z+0.5)))

			origin_flush(origin, nil)
			return
		end

		origin_flush(origin, exit)
	end)
end


-- Teleport function
local function teleport_no_delay(obj, portal_pos)
	local is_player = obj:is_player()
	if (not is_player and not obj:get_luaentity()) or cooloff[obj] then return end

	local objpos = obj:get_pos()
	if not objpos then return end

	local _, current_dim = mcl_worlds.y_to_layer(objpos.y)
	local target_dim = dimension_to_teleport[current_dim]

	-- If player stands, player is at ca. something+0.5 which might cause precision problems, so we used ceil for objpos.y
	local origin = vector_new(floor(objpos.x+0.5), ceil(objpos.y), floor(objpos.z+0.5))
	if get_node(origin).name ~= PORTAL then return end

	local target = get_target(origin)
	if not target then
		log("verbose", string.format(
			"No target found for position %s - no valid exit found",
			pos_to_string(origin)
		))
		return
	end

	local name
	if is_player then
		name = obj:get_player_name()
	end

	if is_entity_queued(obj) then
		-- Let's not allow one entity to generate a lot of work by just moving around in a portal.
		log("verbose", "Entity already queued")
		return
	end

	log("verbose", string.format("Target calculated as %s", pos_to_string(target)))

	local already_queued = is_origin_queued(origin)
	origin_enqueue(obj, origin)

	if already_queued then
		-- Origin is already being processed, so wait in queue for the result.
		log("verbose", string.format("Origin %s already queued", pos_to_string(origin)))
		return
	end

	local exit
	local saved_portal_position = get_portal_pos(origin)
	if saved_portal_position then
		-- Before Jan 2024, portal exits were sticky - they were stored
		-- in nodes. If such a position is found, look for the exit
		-- there, so that the players don't get any surprises.
		-- Sticky exit can be removed by destroying and rebuilding the portal.
		log("verbose", "Using block-saved portal exit: "..pos_to_string(saved_portal_position)..".")
		exit = find_exit(saved_portal_position, 10, 10)
	end

	if not exit then
		-- Search for nearest suitable exit in the lookup table.
		if target_dim=="nether" then
			exit = find_exit(target, SEARCH_DISTANCE_NETHER, SEARCH_DISTANCE_NETHER)
		else
			exit = find_exit(target, SEARCH_DISTANCE_OVERWORLD, SEARCH_DISTANCE_OVERWORLD)
		end
	end

	if exit then
		log("verbose", "Exit found at "..pos_to_string(exit).." for target "..pos_to_string(target).." traveling from "..pos_to_string(origin))
		check_portal_then_teleport(obj, origin, exit)
	else
		create_portal(origin, target, target_dim, name, obj)
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
			minpos = vector_offset(pos, -0.1, 1.4, -0.1),
			maxpos = vector_offset(pos,  0.1, 1.6,  0.1),
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

	local delay = math.max(0, nether_portal_survival_delay - 1)
	if minetest.is_creative_enabled(name) then
		delay = math.max(0, nether_portal_creative_delay - 1)
	end

	if delay == 0 then
		teleport_no_delay(obj, portal_pos)
	else
		minetest.after(delay, teleport_no_delay, obj, portal_pos)
	end
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
			velocity     = vector_new(random() * 0.7 + 0.3, random() - 0.5, random() - 0.5)
			acceleration = vector_new(random() * 1.1 + 0.3, random() - 0.5, random() - 0.5)
		else
			velocity     = vector_new(random() - 0.5,       random() - 0.5, random() * 0.7 + 0.3)
			acceleration = vector_new(random() - 0.5,       random() - 0.5, random() * 1.1 + 0.3)
		end
		local distance = vector_new(velocity.x * time + acceleration.x * time * time * 0.5,
		                            velocity.y * time + acceleration.y * time * time * 0.5,
		                            velocity.z * time + acceleration.z * time * time * 0.5)
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
		for _, obj in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			-- Teleport players, mobs, boats etc.
			local lua_entity = obj:get_luaentity()
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
	on_destruct = function(pos, node)
		-- Permit extinguishing of protected portals if the frame is
		-- sticking out of the protected area to maintain integrity.
		local function check_remove(pos, orientation)
			local node = get_node(pos)
			if node and node.name == PORTAL then
				minetest.remove_node(pos)
			end
		end

		-- check each of 6 sides of it and destroy every portal
		check_remove(vector_offset(pos, -1,  0,  0))
		check_remove(vector_offset(pos,  1,  0,  0))
		check_remove(vector_offset(pos,  0,  0, -1))
		check_remove(vector_offset(pos,  0,  0,  1))
		check_remove(vector_offset(pos,  0, -1,  0))
		check_remove(vector_offset(pos,  0,  1,  0))
	end,

	_on_ignite = function(user, pointed_thing)
		local x, y, z = pointed_thing.under.x, pointed_thing.under.y, pointed_thing.under.z
		-- Check empty spaces around obsidian and light all frames found.
		-- Permit igniting of portals that are partly protected to maintain integrity.
		local portals_placed =
				mcl_portals.light_nether_portal(vector_new(x - 1, y, z)) or mcl_portals.light_nether_portal(vector_new(x + 1, y, z)) or
				mcl_portals.light_nether_portal(vector_new(x, y - 1, z)) or mcl_portals.light_nether_portal(vector_new(x, y + 1, z)) or
				mcl_portals.light_nether_portal(vector_new(x, y, z - 1)) or mcl_portals.light_nether_portal(vector_new(x, y, z + 1))
		if portals_placed then
			log("verbose", "Nether portal activated at "..pos_to_string(vector_new(x, y, z))..".")
			if minetest.get_modpath("doc") then
				doc.mark_entry_as_revealed(user:get_player_name(), "nodes", PORTAL)

				-- Achievement for finishing a Nether portal TO the Nether
				local dim = mcl_worlds.pos_to_dimension(vector_new(x, y, z))
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

mcl_structures.register_structure("nether_portal",{
	nospawn = true,
	filenames = {
		modpath.."/schematics/mcl_portals_nether_portal.mts"
	}
})
mcl_structures.register_structure("nether_portal_open",{
	nospawn = true,
	filenames = {
		modpath.."/schematics/mcl_portals_nether_portal_open.mts"
	},
	after_place = function(pos,def,pr,blockseed)
		-- The mts is the smallest portal (two wide) and places the first PORTAL block
		-- above the location of the caller (y+1). The second one is either at x+1 or z+1.
		local portals = find_nodes_in_area(vector_offset(pos, 0, 1, 0), vector_offset(pos, 1, 1, 1), {PORTAL})
		if portals and #portals>0 then
			for _, p in pairs(portals) do
				add_exits({p})
			end
		end
	end
})
