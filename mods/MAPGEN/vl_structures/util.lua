local peaceful = minetest.settings:get_bool("only_peaceful_mobs", false)

local floor = math.floor
local vector_offset = vector.offset

local ROTATIONS = { "0", "90", "180", "270" }
--- Parse a rotation value
-- @param rotation string: when "random", a rotation is chosen at random
-- @param[opt] pr PseudoRandom: random generator
-- @return Rotation
function vl_structures.parse_rotation(rotation, pr)
	if rotation == "random" and pr then return ROTATIONS[pr:next(1,#ROTATIONS)] end
	return rotation
end

--- Get the size after rotation.
-- @param size vector: Size information
-- @param rotation string or number: only 0, 90, 180, 270 are allowed
-- @return vector: new vector, for safety
function vl_structures.size_rotated(size, rotation)
	if rotation == "90" or rotation == "270" or rotation == 90 or rotation == 270 then return vector.new(size.z, size.y, size.x) end
	return vector.copy(size)
end

--- Get top left position after apply centering flags and padding.
-- @param pos vector: Placement position
-- @param[opt] size vector: Size information
-- @param[opt] flags string or table: as in minetest.place_schematic, place_center_x, place_center_y; default none
-- @return vector: new vector, for safety
function vl_structures.top_left_from_flags(pos, size, flags)
	local dx, dy, dz = 0, 0, 0
	-- must match src/mapgen/mg_schematic.cpp to be consistent
	if type(flags) == "table" then
		if flags["place_center_x"] ~= nil then dx = -floor((size.x-1)*0.5) end
		if flags["place_center_y"] ~= nil then dy = -floor((size.y-1)*0.5) end
		if flags["place_center_z"] ~= nil then dz = -floor((size.z-1)*0.5) end
		return vector_offset(pos, dx, dy, dz)
	elseif type(flags) == "string" then
		if string.find(flags, "place_center_x") then dx = -floor((size.x-1)*0.5) end
		if string.find(flags, "place_center_y") then dy = -floor((size.y-1)*0.5) end
		if string.find(flags, "place_center_z") then dz = -floor((size.z-1)*0.5) end
		return vector_offset(pos, dx, dy, dz)
	end
	return pos
end

--- Get the extends of a schematic after rotation and flags
-- @param pos vector: position of base
-- @param size vector: size of structure
-- @param[opt] yoffset number: vertical offset
-- @param[opt] rotation string: rotation value
-- @param[opt] flags string or table: as in minetest.place_schematic, place_center_x, place_center_y; default none
-- @return center on base level, area minimum, area maximum, rotated size (=pmax-pmin+1)
function vl_structures.get_extends(pos, size, yoffset, rotation, flags)
	local size = vl_structures.size_rotated(size, rotation)
	local pmin = vl_structures.top_left_from_flags(pos, size, flags or vl_structures.DEFAULT_FLAGS)
	local cent = vector_offset(pmin, floor((size.x-1)*0.5), 0, floor((size.z-1)*0.5)) -- center
	pmin.y = pmin.y + (yoffset or 0) -- to pmin and pmax only
	local pmax = vector_offset(pmin, size.x - 1, size.y - 1, size.z - 1)
	return cent, pmin, pmax, size
end

--- Call all on_construct handlers. Also called from mcl_villages for job sites
-- @param pos Node position
function vl_structures.init_node_construct(pos)
	local node = minetest.get_node(pos)
	local def = node and minetest.registered_nodes[node.name]
	if def and def.on_construct then return def.on_construct(pos) end
end

--- Call on_construct handlers for all nodes of given types
-- @param p1 vector: Lowest coordinates of range
-- @param p2 vector: Highest coordinates of range
-- @param nodes string or table: node name or list of node names
-- @return nodes found
function vl_structures.construct_nodes(p1,p2,nodes)
	local nn = minetest.find_nodes_in_area(p1,p2,nodes)
	for _,p in pairs(nn) do vl_structures.init_node_construct(p) end
	return nn or {}
end

--- Fill loot chests
-- @param p1 vector: Lowest coordinates of range
-- @param p2 vector: Highest coordinates of range
-- @param loot table: Loot table
-- @param pr PseudoRandom: random generator
function vl_structures.fill_chests(p1,p2,loot,pr)
	for it,lt in pairs(loot) do
		local nodes = minetest.find_nodes_in_area(p1, p2, it)
		for _,p in pairs(nodes) do
			local lootitems = mcl_loot.get_multi_loot(lt, pr)
			vl_structures.init_node_construct(p)
			local meta = minetest.get_meta(p)
			local inv = meta:get_inventory()
			mcl_loot.fill_inventory(inv, "main", lootitems, pr)
		end
	end
end

--- Spawn mobs for a structure
-- @param mob string: mob to spawn
-- @param spawnon string or table: nodes to spawn on
-- @param p1 vector: Lowest coordinates of range
-- @param p2 vector: Highest coordinates of range
-- @param pr PseudoRandom: random generator
-- @param n number: Number of mobs to spawn
-- @param water boolean: Spawn water mobs
function vl_structures.spawn_mobs(mob,spawnon,p1,p2,pr,n,water)
	n = n or 1
	local sp = {}
	if water then
		local nn = minetest.find_nodes_in_area(p1,p2,spawnon)
		for k,v in pairs(nn) do
			if minetest.get_item_group(minetest.get_node(vector_offset(v,0,1,0)).name,"water") > 0 then
				table.insert(sp,v)
			end
		end
	else
		sp = minetest.find_nodes_in_area_under_air(p1,p2,spawnon)
	end
	table.shuffle(sp)
	local count = 0
	local mob_def = minetest.registered_entities[mob]
	local enabled = (not peaceful) or (mob_def and mob_spawn_class ~= "hostile")
	for _, node in pairs(sp) do
		if enabled and count < n and minetest.add_entity(vector_offset(node, 0, 1, 0), mob) then
			count = count + 1
		end
		minetest.get_meta(node):set_string("spawnblock", "yes") -- note: also in peaceful mode!
	end
end

