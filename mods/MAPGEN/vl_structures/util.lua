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
-- @param[opt] flags string or table: as in core.place_schematic, place_center_x, place_center_y; default none
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
-- @param[opt] flags string or table: as in core.place_schematic, place_center_x, place_center_y; default none
-- @return center on base level, area minimum, area maximum, rotated size (=pmax-pmin+1)
function vl_structures.get_extends(pos, size, yoffset, rotation, flags)
	local size = vl_structures.size_rotated(size, rotation)
	local pmin = vl_structures.top_left_from_flags(pos, size, flags or vl_structures.DEFAULT_FLAGS)
	local cent = vector_offset(pmin, floor((size.x-1)*0.5), 0, floor((size.z-1)*0.5)) -- center
	pmin.y = pmin.y + (yoffset or 0) -- to pmin and pmax only
	local pmax = vector_offset(pmin, size.x - 1, size.y - 1, size.z - 1)
	return cent, pmin, pmax, size
end

--- Call all on_construct handlers. Also called from vl_villages for job sites
-- @param pos Node position
function vl_structures.construct_node(pos)
	local node = mcl_vars.get_node_name(pos)
	local def = node and core.registered_nodes[node]
	if def and def.on_construct then return def.on_construct(pos) end
end

--- Call on_construct handlers for all nodes of given types
-- @param p1 vector: Lowest coordinates of range
-- @param p2 vector: Highest coordinates of range
-- @param nodes string or table: node name or list of node names
-- @return nodes found
function vl_structures.construct_nodes(p1,p2,nodes)
	local nn = core.find_nodes_in_area(p1,p2,nodes) or {}
	for _,p in pairs(nn) do vl_structures.construct_node(p) end
	return nn
end

--- Fill loot chests, requires mcl_loot
-- @param p1 vector: Lowest coordinates of range
-- @param p2 vector: Highest coordinates of range
-- @param loot table: Loot table
-- @param pr PseudoRandom: random generator
function vl_structures.fill_chests(p1,p2,loot,pr)
	if not mcl_loot then return end -- optional dependency
	for it,lt in pairs(loot) do
		local nodes = core.find_nodes_in_area(p1, p2, it)
		for _,p in pairs(nodes) do
			vl_structures.construct_node(p)
			local meta = core.get_meta(p)
			local inv = meta:get_inventory()
			mcl_loot.fill_inventory(inv, "main", mcl_loot.get_multi_loot(lt, pr), pr)
		end
	end
end

--- Mapgen generation chunk from position
-- @param p vector: position
-- @param sidelen number: subdivision sidelen, default 80
-- @param ysidelen number: subdivision sidelen on y, default is sidelen
-- @return x number, y number, z number
function vl_structures.pos_to_chunk(p, sidelen, ysidelen)
	sidelen = sidelen or 80
	ysidelen = ysidelen or sidelen
	return math.floor((p.x + 32) / sidelen), math.floor((p.y + 32) / ysidelen), math.floor((p.z + 32) / sidelen)
end
