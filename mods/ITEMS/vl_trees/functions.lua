local core_get_node, core_get_meta = core.get_node, core.get_meta
local math_floor, math_ceil, math_max, math_random = math.floor, math.ceil, math.max, math.random
local vector_new, vector_add, vector_offset = vector.new, vector.add, vector.offset

-- Check if a node stops the tree from growing.
local function node_stops_growth(node)
	if node.name == "air" then return false end
	local def = core.registered_nodes[node.name]
	local groups = def and def.groups
	if not groups then return true end

	return not (
		def.buildable_to or
		groups.leaves or
		groups.wood or
		groups.tree or
		groups.plant or
		groups.dirt or
		groups.torch or
		groups.bark
	)
end
vl_trees.node_stops_growth = node_stops_growth

-- Check if a tree can grow at position. The width is the width to check around
-- the tree. A width of 3 and height of 5 will check a 3x3 area, 5 nodes above
-- the sapling. If any walkable node other than dirt, wood or leaves occurs in
-- those blocks, the tree cannot grow.
local function check_tree_growth(pos, width, height)
	-- huge tree (with even width to check) will check one more node in +x/y directions
	local neg_space, pos_space = math_floor((width - 1) * 0.5), math_ceil((width - 1) * 0.5)
	for x = -neg_space, pos_space do for z = -neg_space, pos_space do
		for y = 1, (height - 1) do
			local npos = vector_offset(pos, x, y, z)
			if node_stops_growth(core_get_node(npos)) then
				return false
			end
		end
	end end
	return true
end
vl_trees.check_tree_growth = check_tree_growth

-- Check if the sapling at position has 3 more neighbors, forming a square, and
-- return the positions of its neighbors and of the northeasternmost one.
--
-- orig. <https://codeberg.org/mineclonia/mineclonia/src/commit/458f950838/mods/ITEMS/mcl_trees/functions.lua#L103>
--       by cora, amino, kno10 and JoseDouglas26
local function check_2x2_saplings(pos, node)
	local sname = node.name

	do -- check if there are saplings around in the first place
		local p1, p2 = vector_offset(pos, -1, 0, -1), vector_offset(pos, 1, 0, 1)
		local saplings_nearby = #core.find_nodes_in_area_under_air(p1, p2, sname)
		if saplings_nearby < 4 then return end
	end

	-- we need to check 4 possible 2x2 squares on the x/z plane each uniquely defined by one of the
	-- diagonals of the position we're checking:
	for dx = -1, 1, 2 do for dz = -1, 1, 2 do
		local d = vector_offset(pos, dx, 0, dz) -- one of the 4 diagonal positions from this node
		local xp = vector_new(d.x, pos.y, pos.z) -- x neighbor
		local zp = vector_new(pos.x, pos.y, d.z) -- z neighbor

		if core_get_node(d).name == sname
				and core_get_node(xp).name == sname
				and core_get_node(zp).name == sname then
			return {d, xp, zp}, vector_offset(pos, math_max(dx, 0), 0, math_max(dz, 0))
		end
	end end
end
vl_trees.check_2x2_saplings = check_2x2_saplings

-- Place schematic from wood definition (def.schematic or def.schematic_2x2) at
-- specified position.
local function place_schem(pos, schematic, callback)
	do -- set pos to account for schem offset
		local offset = schematic.offset
		if offset then pos = vector_add(pos, offset) end
	end

	core.place_schematic(pos, schematic.spec, "random", callback,
		false, "place_center_x, noplace_center_y, place_center_z")
end
vl_trees.place_schem = place_schem

local function update_biomecolor_bulk(pos, width, height)
	local hw = math_ceil(width / 2)
	local foliage = core.find_nodes_in_area(
		vector_offset(pos, -hw, 0, -hw),
		vector_offset(pos, hw, height, hw),
		{"group:biomecolor"}
	)
	for _, fpos in pairs(foliage) do
		local node = core_get_node(fpos)
		local palette_index = 0
		if core.get_item_group(node.name, "biomecolor") ~= 0 then
			palette_index = mcl_util.get_palette_indexes_from_pos(fpos).grass_palette_index
		end

		node.param2 = math_floor(node.param2 / 32) * 32 + palette_index
		core.swap_node(fpos, node)
	end
end

-- Handle growing a tree at `pos`
local function grow_tree(pos, node, def)
	if not def then
		local name = core.registered_nodes[node.name] and core.registered_nodes[node.name]._vl_wood
		def = vl_trees.registered_woods[name]
	end
	if not def then return end

	local def_schematic = def.schematic
	local ppos, tbt; do -- check for 2x2 and adjust place pos and schematic if it is
		tbt, ppos = check_2x2_saplings(pos, node)
		if tbt then
			def_schematic = def.schematic_2x2
		else
			ppos = pos
		end
	end

	local schematic = type(def_schematic) == "function" and def_schematic(ppos)
		or type(def_schematic) == "table" and next(def_schematic) ~= nil and def_schematic[math_random(#def_schematic)]
		or def_schematic
	if not schematic then return end

	-- assume trunk to be in the center for 2x2s
	if tbt and not schematic.offset then
		schematic.offset = vector_new(-1, 0, -1)
	end

	local size = schematic.size
	if not size then
		local spec = schematic.spec
		if type(spec) == "string" then -- treat as a .mts path
			spec = loadstring(
				core.serialize_schematic(spec, "lua", {lua_use_comments = false, lua_num_ident_spaces = 0})
					.. " return schematic"
			)()
		end
		size = {w = math_max(spec.size.x, spec.size.z), h = spec.size.y}
	end

	do -- check for place for schematic
		local can_grow = check_tree_growth(pos, size.w, size.h)
		if not can_grow then return end
	end

	-- TADAA!! at this point everybody should clap and cheer
	if tbt then
		for _, p in pairs(tbt) do core.remove_node(p) end
	end
	core.remove_node(pos)

	place_schem(ppos, schematic)

	update_biomecolor_bulk(ppos, size.w, size.h)

	local sdef = core.registered_nodes[node.name]
	if sdef._after_grow then -- run callback if present
		local is_2x2 = not not tbt
		sdef._after_grow(ppos, schematic, is_2x2)
	end
end
vl_trees.grow_tree = grow_tree

-- Handle growing the sapling at position (with tree emerging if stage == 3),
-- with an option to progress the stage by an arbitrary integer instead of 1
-- (used by the catch-up sapling growth LBM).
function vl_trees.grow_sapling(pos, node, grow_by)
	local name = core.registered_nodes[node.name] and core.registered_nodes[node.name]._vl_wood
	local def = vl_trees.registered_woods[name]
	if not def then return end

	do -- check for light level
		local light = core.get_node_light(pos)
		if not light or light < def.params.min_light then return end
	end

	do -- check for soil below
		local below = core_get_node(vector_offset(pos, 0, -1, 0))
		local soil_type = core.get_item_group(below.name, "soil_sapling")
		if soil_type < def.params.min_soil_type then return end
	end

	do -- check and progress growth stage
		local meta = core_get_meta(pos)
		local stage = meta:get_int("stage") + (grow_by or 1)
		if stage < 3 then
			meta:set_int("stage", stage)
			return
		end
	end

	return grow_tree(pos, node, def)
end
