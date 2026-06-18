vl_attach = {}

---@class core.NodeDef
---@field _vl_allow_attach? boolean|fun(node : core.Node, def : core.NodeDef, wdir : number, attached_node : core.Node?, attached_def : core.NodeDef?):boolean?
---@field _vl_attach_allow? boolean|fun(node : core.Node, def : core.NodeDef, wdir : number, attached_node : core.Node?, attached_def : core.NodeDef?):boolean?
---@field _vl_attach_surfaces? false|table|fun(node : core.Node, def : core.NodeDef, wdir : number):table?
---@field _vl_attach_contract? false|table|fun(node : core.Node, def : core.NodeDef, wdir : number):table?
---@field _vl_attach_fixed_wdir? number
---@field _vl_attach_make_placed_node? fun(placed_node : core.Node, placer : core.Player, dir : vector.Vector, itemstack : core.ItemStack, pointed_thing : core.PointedThing, under_node : core.Node) : core.Node?
---@field _vl_attach_get_supports? fun(pos : vector.Vector, node : core.Node, def : core.NodeDef, wdir : number, dir : vector.Vector):table?

-- Localized values
local get_item_group = core.get_item_group
local facedir_to_dir = core.facedir_to_dir
local wallmounted_to_dir = core.wallmounted_to_dir
local get_node = core.get_node
local registered_nodes = core.registered_nodes

-- Constants
local PI_OVER_4 = math.pi / 4
local DOWN = vector.new(0,-1,0)
local EPSILON = 0.0001
local REGULAR_BOX = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}}

local function rect_contains(container, u, v)
	return container[1] <= u + EPSILON
		and container[2] <= v + EPSILON
		and container[3] >= u - EPSILON
		and container[4] >= v - EPSILON
end

local function add_sorted_edge(edges, edge)
	for _,existing in ipairs(edges) do
		if math.abs(existing - edge) <= EPSILON then return end
	end

	edges[#edges + 1] = edge
	table.sort(edges)
end

local function add_clipped_edges(edges, min_edge, max_edge, clip_min, clip_max)
	local clipped_min = math.max(min_edge, clip_min)
	local clipped_max = math.min(max_edge, clip_max)
	if clipped_min < clipped_max - EPSILON then
		add_sorted_edge(edges, clipped_min)
		add_sorted_edge(edges, clipped_max)
	end
end

local function rects_cover(rects, required)
	local u_edges = {required[1], required[3]}
	local v_edges = {required[2], required[4]}

	for _,rect in ipairs(rects) do
		add_clipped_edges(u_edges, rect[1], rect[3], required[1], required[3])
		add_clipped_edges(v_edges, rect[2], rect[4], required[2], required[4])
	end

	for u_index = 1, #u_edges - 1 do
		for v_index = 1, #v_edges - 1 do
			local u1, u2 = u_edges[u_index], u_edges[u_index + 1]
			local v1, v2 = v_edges[v_index], v_edges[v_index + 1]
			if u2 > u1 + EPSILON and v2 > v1 + EPSILON then
				local u = (u1 + u2) / 2
				local v = (v1 + v2) / 2
				local covered = false
				for _,rect in ipairs(rects) do
					if rect_contains(rect, u, v) then
						covered = true
						break
					end
				end
				if not covered then return false end
			end
		end
	end

	return true
end

local function rects_from_source(source, node, def, dir)
	local boxes
	if source == "regular" then
		boxes = REGULAR_BOX
	elseif source ~= "selection_box" and (def.drawtype == "normal" or not def[source]) then
		boxes = REGULAR_BOX
	else
		boxes = core.get_node_boxes(source, vector.zero(), node)
		if not boxes or #boxes == 0 then
			boxes = REGULAR_BOX
		end
	end

	local dir_key, coord, axis1, axis2
	if dir.x ~= 0 then
		dir_key, coord, axis1, axis2 = "x", 1, 3, 2
	elseif dir.y ~= 0 then
		dir_key, coord, axis1, axis2 = "y", 2, 1, 3
	else
		dir_key, coord, axis1, axis2 = "z", 3, 1, 2
	end
	local face_coord = dir[dir_key] > 0 and 0.5 or -0.5

	local rects = {}
	for _,box in ipairs(boxes) do
		local box_coord = dir[dir_key] > 0 and box[coord + 3] or box[coord]
		local has_area = box[axis1] < box[axis1 + 3] and box[axis2] < box[axis2 + 3]
		if has_area and math.abs(box_coord - face_coord) <= EPSILON then
			rects[#rects + 1] = {
				box[axis1],
				box[axis2],
				box[axis1 + 3],
				box[axis2 + 3],
			}
		end
	end

	return rects
end

local function get_face_class(wdir)
	if wdir == 0 then return "bottom" end
	if wdir == 1 then return "top" end
	return "side"
end

local function normalize_surface_spec(spec, node, def, wdir, dir, fallback_source)
	if spec == false then return false end
	if type(spec) == "function" then
		return spec(node, def, wdir)
	end

	if type(spec) == "table" then
		if spec.get_face then
			local rects = spec.get_face(node, def, wdir)
			if rects ~= nil then return rects end
		end

		if spec.faces then
			local rects = spec.faces[wdir]
			if rects == nil then rects = spec.faces[get_face_class(wdir)] end
			if rects ~= nil then return rects end
		end

		if spec.source then
			return rects_from_source(spec.source, node, def, dir)
		end
	end

	if fallback_source then
		return rects_from_source(fallback_source, node, def, dir)
	end
end

local function get_support_rects(node, def, wdir, dir)
	local spec = def._vl_attach_surfaces
	if spec ~= nil then
		return normalize_surface_spec(spec, node, def, wdir, dir)
	end

	local groups = def.groups or {}
	if (groups.solid or 0) ~= 0 and (groups.opaque or 0) ~= 0 then
		return rects_from_source("regular", node, def, dir)
	end
end

local function get_contract_rects(node, def, wdir, dir)
	local spec = def._vl_attach_contract
	if spec ~= nil then
		return normalize_surface_spec(spec, node, def, wdir, dir)
	end

	if def.selection_box then
		return rects_from_source("selection_box", node, def, dir)
	end
	if def.node_box then
		return rects_from_source("node_box", node, def, dir)
	end
end

-- Check whether the attached node's contact area fits the support node's face.
---@param node core.Node
---@param def core.NodeDef
---@param wdir number
---@param attached_node core.Node?
---@param attached_def core.NodeDef?
---@return boolean
function vl_attach.check_geometry(node, def, wdir, attached_node, attached_def)
	if not attached_node or not attached_def then
		core.log("warning", "vl_attach.check_geometry called without attached node definition"
			.." support="..node.name
			.." wdir="..tostring(wdir))
		return false
	end

	local attach_dir = core.wallmounted_to_dir(wdir)
	if not attach_dir then
		core.log("warning", "vl_attach.check_geometry called with invalid wallmounted direction"
			.." support="..node.name
			.." attached="..attached_node.name
			.." wdir="..tostring(wdir))
		return false
	end

	local support_rects = get_support_rects(node, def, wdir, -attach_dir)
	local attached_rects = get_contract_rects(attached_node, attached_def, wdir, attach_dir)
	if not support_rects or not attached_rects then
		return false
	end
	if #support_rects == 0 or #attached_rects == 0 then
		return false
	end

	for _,attached_rect in ipairs(attached_rects) do
		if not rects_cover(support_rects, attached_rect) then
			return false
		end
	end

	return true
end

-- Check if the node is no longer supported by a node that would allow attachment/support
---@param pos vector.Vector
---@param node core.Node
---@return boolean
function vl_attach.should_drop(pos, node)
	local def = registered_nodes[node.name]
	if not def then
		core.log("warning", "vl_attach.should_drop called for unregistered node"
			.." node="..node.name
			.." pos="..core.pos_to_string(pos))
		return false
	end
	local groups = def and def.groups

	if groups.vl_attach == 1 then
		local wdir, dir
		if def._vl_attach_fixed_wdir ~= nil then
			wdir = def._vl_attach_fixed_wdir
			local attach_dir = core.wallmounted_to_dir(wdir)
			if not attach_dir then
				core.log("warning", node.name.." has invalid _vl_attach_fixed_wdir="..tostring(wdir)
					.." at "..core.pos_to_string(pos))
				return true
			end
			dir = -attach_dir
		elseif def.paramtype2 == "facedir" then
			local attach_dir = core.facedir_to_dir(node.param2)
			if not attach_dir then
				core.log("warning", node.name.." has invalid facedir param2="..tostring(node.param2)
					.." at "..core.pos_to_string(pos))
				return true
			end
			wdir = core.dir_to_wallmounted(attach_dir)
			dir = -attach_dir
		elseif def.paramtype2 == "wallmounted" or def.paramtype2 == "colorwallmounted" then
			wdir = node.param2 % 8
			local attach_dir = core.wallmounted_to_dir(wdir)
			if not attach_dir then
				core.log("warning", node.name.." has invalid wallmounted param2="..tostring(node.param2)
					.." wdir="..tostring(wdir)
					.." at "..core.pos_to_string(pos))
				return true
			end
			dir = -attach_dir
		else
			core.log("warning", node.name.." has groups.vl_attach = 1 when paramtype2 is "..def.paramtype2)
			return false
		end

		if not wdir then
			core.log("warning", node.name.." could not resolve attachment wallmounted direction"
				.." paramtype2="..tostring(def.paramtype2)
				.." param2="..tostring(node.param2)
				.." at "..core.pos_to_string(pos))
			return true
		end

		local under_node = core.get_node(pos - dir)
		if vl_attach.check_allowed(under_node, wdir, node, def) then
			return false
		end

		if def._vl_attach_get_supports then
			for _,support in ipairs(def._vl_attach_get_supports(pos, node, def, wdir, dir) or {}) do
				local support_node = support.node or core.get_node(support.pos)
				local support_wdir = support.wdir or wdir
				local attached_node = support.attached_node or node
				local attached_def = support.attached_def or def
				if vl_attach.check_allowed(support_node, support_wdir, attached_node, attached_def) then
					return false
				end
			end
		end

		return true
	end
	local dir

	if (groups.attached_node_facedir or 0) ~= 0 then
		dir = facedir_to_dir(node.param2)
		if dir and get_item_group(get_node(vector.add(pos, dir)).name, "solid") == 0 then
			return true
		end
	end

	if (groups.attached_node_wallmounted or 0) ~= 0 then
		dir = wallmounted_to_dir(node.param2)
		if dir and get_item_group(get_node(vector.add(pos, dir)).name, "solid") == 0 then
			return true
		end
	end

	if (groups.supported_node or 0) ~= 0 then
		def = registered_nodes[get_node(vector.offset(pos, 0, -1, 0)).name]
		if def and def.drawtype == "airlike" then
			return true
		end
	end

	if (groups.supported_node_facedir or 0) ~= 0 then
		dir = facedir_to_dir(node.param2)
		def = dir and registered_nodes[get_node(vector.add(pos, dir)).name]
		if def and def.drawtype == "airlike" then
			return true
		end
	end

	if (groups.supported_node_wallmounted or 0) ~= 0 then
		dir = wallmounted_to_dir(node.param2)
		def = dir and registered_nodes[get_node(vector.add(pos, dir)).name]
		if def and def.drawtype == "airlike" then
			return true
		end
	end

	return false
end

-- Check if placement at given node is allowed
---@param node core.Node
---@param wdir number
---@param attached_node core.Node?
---@param attached_def core.NodeDef?
---@return boolean?
function vl_attach.check_allowed(node, wdir, attached_node, attached_def)
	local def = registered_nodes[node.name]
	if not def then
		core.log("warning", "vl_attach.check_allowed called for unregistered support node"
			.." support="..node.name
			.." wdir="..tostring(wdir)
			.." attached="..(attached_node and attached_node.name or "nil"))
		return false
	end

	local function refine_allowed(allow_attach, callback)
		if allow_attach == true and callback ~= vl_attach.check_geometry
		and def._vl_attach_surfaces ~= nil and attached_def and attached_def._vl_attach_contract ~= nil then
			return vl_attach.check_geometry(node, def, wdir, attached_node, attached_def)
		end
		return allow_attach
	end

	local function check_policy(policy)
		if type(policy) == "function" then
			return refine_allowed(policy(node, def, wdir, attached_node, attached_def), policy)
		end
		return refine_allowed(policy)
	end

	if def._vl_allow_attach ~= nil then
		local allowed = check_policy(def._vl_allow_attach)
		if allowed ~= nil then
			return allowed
		end
	end

	if attached_def and attached_def._vl_attach_allow ~= nil then
		local allowed = check_policy(attached_def._vl_attach_allow)
		if allowed ~= nil then
			return allowed
		end
	end

	if attached_def and attached_def._vl_attach_contract ~= nil then
		return vl_attach.check_geometry(node, def, wdir, attached_node, attached_def)
	end
	return false
end

---@return core.ItemStack?, vector.Vector?
local function handle_buildable_to(pointed_thing, body)
	local under = pointed_thing.under
	local under_node = get_node(under)
	local under_dir = under - pointed_thing.above

	local itemstack, pos = body(under_dir, pointed_thing, under_node)
	if pos then return itemstack, pos end

	-- If the clicked node cannot be used as support, try both behind and below it.
	local under_def = registered_nodes[under_node.name]
	if not under_def then
		core.log("warning", "vl_attach placement pointed at unregistered node"
			.." node="..under_node.name
			.." pos="..core.pos_to_string(under))
		return
	end
	if under_def.buildable_to then
		for _,dir in ipairs({under_dir, DOWN}) do
			local new_pointed_thing = {
				type = pointed_thing.type,
				under = under + dir,
				above = under,
				dir = dir,
			}
			local new_under_node = get_node(new_pointed_thing.under)
			itemstack, pos = body(dir, new_pointed_thing, new_under_node)
			if pos then return itemstack, pos end
		end
	end
end

local function get_placement_pointed_thing(pointed_thing, under_node)
	local under_def = registered_nodes[under_node.name]
	if not under_def or not under_def.buildable_to then
		return pointed_thing
	end

	-- The clicked node is being used as the support. Builtin placement would
	-- otherwise replace it because buildable_to nodes are placed into first.
	return {
		type = "node",
		under = pointed_thing.above,
		above = pointed_thing.above,
	}
end

---@param itemstack core.ItemStack
---@param placer core.PlayerObjectRef
---@param idef? core.NodeDef
---@param original_pointed_thing core.PointedThing
---@param make_placed_node? fun(placed_node : core.Node, placer : core.Player, dir : vector.Vector, itemstack : core.ItemStack, pointed_thing : core.PointedThing, under_node : core.Node) : core.Node?
---@return core.ItemStack?, vector.Vector?
function vl_attach.place_attached(itemstack, placer, original_pointed_thing, idef, make_placed_node)
	-- Don't try to place nodes on entities
	if original_pointed_thing.type ~= "node" then
		return itemstack
	end

	-- Check special rightclick action of pointed node
	local handled
	itemstack, handled = mcl_util.handle_node_rightclick(itemstack, placer, original_pointed_thing)
	if handled then
		return itemstack
	end

	idef = idef or itemstack:get_definition() --[[ @as core.NodeDef ]]
	local itemstring = itemstack:get_name()
	if idef.groups.vl_attach ~= 1 then
		core.log("warning", itemstring.." does not have vl_attach = 1")
		return itemstack
	end
	make_placed_node = make_placed_node or idef._vl_attach_make_placed_node

	-- Handle buildable_to nodes
	local new_itemstack, pos = handle_buildable_to(original_pointed_thing, function(dir, pointed_thing, under_node)
		local wdir = core.dir_to_wallmounted(dir)

		-- Build the concrete attached node before checking support geometry.
		local placed_node = {name = itemstack:get_name(), param2 = wdir}
		if make_placed_node then
			placed_node = make_placed_node(placed_node, placer, dir, itemstack, pointed_thing, under_node)
		end
		if not placed_node then return end
		local placed_def = registered_nodes[placed_node.name]
		if not placed_def then
			core.log("warning", placed_node.name.." is not a registered node")
			return
		end

		-- Check placement allowed
		if not vl_attach.check_allowed(under_node, wdir, placed_node, placed_def) then
			return
		end

		-- Make sure the node would not immediately drop
		local drop_pos = pointed_thing.under - dir
		if vl_attach.should_drop(drop_pos, placed_node) then
			core.log("warning", placed_node.name.." would drop immediately after vl_attach placement"
				.." at "..core.pos_to_string(drop_pos)
				.." with wdir="..wdir
				.." support="..under_node.name
				.." support_pos="..core.pos_to_string(pointed_thing.under))
			return
		end

		-- Place the node
		local placestack = ItemStack(itemstack)
		placestack:set_name(placed_node.name)
		local placement_pointed_thing = get_placement_pointed_thing(pointed_thing, under_node)
		local pos
		itemstack, pos = core.item_place_node(placestack, placer, placement_pointed_thing, placed_node.param2)
		if not pos then
			itemstack, pos = core.item_place(placestack, placer, placement_pointed_thing, placed_node.param2)
		end

		-- Restore name (core.item_place_node may change it)
		itemstack:set_name(itemstring)

		-- Play sound
		if pos and idef.sounds and idef.sounds.place then
			core.sound_play(idef.sounds.place, {pos=pointed_thing.above, gain=1}, true)
		end
		return itemstack, pos
	end)
	return new_itemstack or itemstack, pos
end

local function make_placed_node_fixed(placed_node, _, dir, _)
	local def = registered_nodes[placed_node.name]
	local wdir = core.dir_to_wallmounted(dir)
	if not def or wdir ~= def._vl_attach_fixed_wdir then
		return
	end
	placed_node.param2 = nil
	return placed_node
end

---@param itemstack core.ItemStack
---@param placer core.PlayerObjectRef
---@param pointed_thing core.PointedThing
---@param idef? core.NodeDef
---@return core.ItemStack?
function vl_attach.place_attached_fixed(itemstack, placer, pointed_thing, idef)
	return vl_attach.place_attached(itemstack, placer, pointed_thing, idef, make_placed_node_fixed)
end

local function make_placed_node_facedir(placed_node, placer, dir, _)
	-- Calculate param2 based on the player's look direction
	local param2 = core.dir_to_facedir(dir, true)
	if dir.y ~= 0 then
		local yaw = placer:get_look_horizontal()
		if (yaw > PI_OVER_4 and yaw < PI_OVER_4*3) or (yaw < PI_OVER_4*7 and yaw > PI_OVER_4*5) then
			param2 = dir.y == -1 and 13 or 15
		else
			param2 = dir.y == -1 and 10 or 8
		end
	end
	placed_node.param2 = param2
	return placed_node
end

---@param itemstack core.ItemStack
---@param placer core.PlayerObjectRef
---@param idef? core.NodeDef
---@param pointed_thing core.PointedThing
---@return core.ItemStack?
function vl_attach.place_attached_facedir(itemstack, placer, pointed_thing, idef)
	return vl_attach.place_attached(itemstack, placer, pointed_thing, idef, make_placed_node_facedir)
end
