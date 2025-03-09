vl_attach = {}

-- Localized values
local get_item_group = core.get_item_group
local facedir_to_dir = core.facedir_to_dir
local wallmounted_to_dir = core.wallmounted_to_dir
local get_node = core.get_node
local registered_nodes = minetest.registered_nodes
local PI_OVER_4 = math.pi / 4

---@type {[string]: boolean|fun(node : core.Node, def : core.NodeDef, wdir : number, attach_type : string): boolean?}
local defaults = {}

---@class core.NodeDef
---@field _vl_allow_attach? {[string]: boolean|fun(def : core.Node, wdir : number, attach_type : string)}?
---@field _vl_attach_type? string

---@param attach_type string
---@param allow_attach boolean|fun(node : core.Node, def : core.NodeDef, wdir : number, attach_type : string): boolean?
function vl_attach.set_default(attach_type, allow_attach)
	defaults[attach_type] = allow_attach
end

-- Check if the node would
---@param pos vector.Vector
---@param node core.Node
---@return boolean
function vl_attach.should_drop(pos, node)
	local groups = registered_nodes[node.name].groups or {}

	if (groups.attached_node_facedir or 0) ~= 0 then
		local dir = facedir_to_dir(node.param2)
		if dir and get_item_group(get_node(vector.add(pos, dir)).name, "solid") == 0 then
			return true
		end
	end

	if (groups.attached_node_wallmounted or 0) ~= 0 then
		local dir = wallmounted_to_dir(node.param2)
		if dir and get_item_group(get_node(vector.add(pos, dir)).name, "solid") == 0 then
			return true
		end
	end

	if (groups.supported_node or 0) ~= 0 then
		local def = registered_nodes[get_node(vector.offset(pos, 0, -1, 0)).name]
		if def and def.drawtype == "airlike" then
			return true
		end
	end

	if (groups.supported_node_facedir or 0) ~= 0 then
		local dir = facedir_to_dir(node.param2)
		local def = dir and registered_nodes[get_node(vector.add(pos, dir)).name]
		if def and def.drawtype == "airlike" then
			return true
		end
	end

	if (groups.supported_node_wallmounted or 0) ~= 0 then
		local dir = wallmounted_to_dir(node.param2)
		local def = dir and registered_nodes[get_node(vector.add(pos, dir)).name]
		if def and def.drawtype == "airlike" then
			return true
		end
	end

	return false
end

-- Check if placement at given node is allowed
local empty_table = {}
---@param node core.Node
---@param wdir number
---@param attach_type string
---@return boolean
function vl_attach.check_allowed(node, wdir, attach_type)
	local def = minetest.registered_nodes[node.name]
	if not def then return false end

	-- Handle type-specific checks that apply to all node types
	---@type boolean|fun(node : core.Node, def : core.NodeDef, wdir : number, attach_type : string)
	local allow_attach = defaults[attach_type]
	if type(allow_attach) == "function" then
		allow_attach = allow_attach(node, def, wdir, attach_type)
	end
	if allow_attach ~= nil then return allow_attach end

	-- Allow nodes to define attachable device type handling
	local vl_allow_attach = def._vl_allow_attach or empty_table

	-- Find allow/deny/callback for specified attach_type, and use "all" as a fallback
	if vl_allow_attach.all ~= nil then allow_attach = vl_allow_attach.all end
	if vl_allow_attach[attach_type] ~= nil then allow_attach = vl_allow_attach[attach_type] end

	-- Dispatch callbacks
	if type(allow_attach) == "function" then
		allow_attach = allow_attach(node, wdir, attach_type)
	end

	return allow_attach or false
end

local function handle_buildable_to(pointed_thing)
	local under = pointed_thing.under
	local under_node = minetest.get_node(under)
	local def = minetest.registered_nodes[under_node.name]

	local dir = under - pointed_thing.above
	if def.buildable_to then
		pointed_thing.above = under
		under = under + dir
		under_node = core.get_node(under)
		def = registered_nodes[under_node.name]
		if not def then return nil, dir, under_node end

		pointed_thing.under = under
	end

	return def, dir, under_node
end

---@param itemstack core.ItemStack
---@param placer core.PlayerObjectRef
---@param idef? core.NodeDef
---@param pointed_thing core.PointedThing
---@param make_placed_node fun(placed_node : core.Node, placer : core.Player, dir : vector.Vector, itemstack : core.ItemStack) : core.Node
---@return core.ItemStack?, vector.Vector?
function vl_attach.place_attached(itemstack, placer, pointed_thing, idef, make_placed_node)
	-- Don't try to place nodes on entities
	if pointed_thing.type ~= "node" then return end

	-- Check special rightclick action of pointed node
	local handled
	itemstack, handled = mcl_util.handle_node_rightclick(itemstack, placer, pointed_thing)
	if handled then return end

	-- Handle buildable_to nodes
	local def, dir, under_node = handle_buildable_to(pointed_thing)
	if not def then return end

	idef = idef or itemstack:get_definition() --[[ @as core.NodeDef ]]

	-- Check placement allowed
	local wdir = core.dir_to_wallmounted(dir)
	local attach_type = idef._vl_attach_type or "all"
	if not vl_attach.check_allowed(under_node, wdir, attach_type) then
		core.log("not allowed "..attach_type.. " " ..dump(under_node,""))
		return
	end

	-- Make sure the node would not immediately drop
	local placed_node = {name = itemstack:get_name(), param2 = wdir}
	placed_node = make_placed_node(placed_node, placer, dir, itemstack)
	if not placed_node then
		core.log("no placed node")
		return
	end
	if vl_attach.should_drop(pointed_thing.under - dir, placed_node) then
		core.log("should drop")
		return
	end

	-- Place the node
	local itemstring = itemstack:get_name()
	local placestack = ItemStack(itemstack)
	placestack:set_name(placed_node.name)
	local pos
	itemstack, pos = core.item_place_node(placestack, placer, pointed_thing, placed_node.param2)
	if not pos then
		itemstack, pos = core.item_place(placestack, placer, pointed_thing, placed_node.param2)
	end

	core.log(dump({pos=pos},""))

	-- Restore name (core.item_place_node may change it)
	itemstack:set_name(itemstring)

	-- Play sound
	if pos and idef.sounds and idef.sounds.place then
		core.sound_play(idef.sounds.place, {pos=pointed_thing.above, gain=1}, true)
	end
	return itemstack, pos
end

local function make_placed_node_facedir(placed_node, placer, dir, _)
	-- Calculate param2 based on the player's look direction
	local param2 = minetest.dir_to_facedir(dir, true)
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

local function make_placed_node_wallmounted(placed_node, _, _, _)
	return placed_node
end

---@param itemstack core.ItemStack
---@param placer core.PlayerObjectRef
---@param idef? core.NodeDef
---@param pointed_thing core.PointedThing
---@return core.ItemStack?
function vl_attach.place_attached_wallmounted(itemstack, placer, pointed_thing, idef)
	return vl_attach.place_attached(itemstack, placer, pointed_thing, idef, make_placed_node_wallmounted)
end

---@class vl_attach.AutogrouperDef
---@field callback fun(allow_attach : {[string]: boolean|fun(node : core.Node, wdir : number, attach_type : string):boolean}, name : string, def : core.NodeDef)
---@field skip_existing? table<number, string>

---@type table<number, vl_attach.AutogrouperDef>
local autogroupers = {}

---@param def vl_attach.AutogrouperDef
function vl_attach.register_autogroup(def)
	autogroupers[#autogroupers + 1] = def
end

local function table_modified(orig, new)
	-- Check if values changed/added
	for k,v in pairs(new) do
		if orig[k] ~= v then return true end
	end

	-- Check if keys removed
	for k,v in pairs(orig) do
		if new[k] ~= v then return true end
	end

	return false
end

core.register_on_mods_loaded(function()
	for name,def in pairs(core.registered_nodes) do
		local original_allow_attach = def._vl_allow_attach or empty_table
		local allow_attach = def._vl_allow_attach and table.copy(def._vl_allow_attach) or {}

		-- Allow placing attachables over top buildable_to nodes
		if def.buildable_to then
			allow_attach.all = true
		end

		-- Run all autogroup callbacks to build allow_attach
		for _,autogrouper in ipairs(autogroupers) do
			local run = true
			for _,skip in ipairs(autogrouper.skip_existing) do
				if allow_attach[skip] ~= nil then
					run = false
					break
				end
			end

			if run then
				autogrouper.callback(allow_attach, name, def)
			end
		end

		-- Update node definition of changes to allow_attach were made
		if table_modified(original_allow_attach, allow_attach) then
			core.override_item(name, {_vl_allow_attach = allow_attach})
		end
	end
end)

