vl_attach = {}

---@type {[string]: boolean|fun(node : core.Node, def : core.NodeDef, wdir : number, attach_type : string): boolean?}
local defaults = {}

---@class core.NodeDef
---@field _vl_allow_attach? {[string]: boolean|fun(def : core.Node, wdir : number, attach_type : string)}?

---@param attach_type string
---@param allow_attach boolean|fun(node : core.Node, def : core.NodeDef, wdir : number, attach_type : string): boolean?
function vl_attach.set_default(attach_type, allow_attach)
	defaults[attach_type] = allow_attach
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
		for i = 1,#autogroupers do
			local autogrouper = autogroupers[i]
			local run = true
			for j = 1,#autogrouper.skip_existing do
				if allow_attach[autogrouper.skip_existing[j]] ~= nil then
					run = false
					break
				end
			end

			if run then
				autogrouper.callback[i](allow_attach, name, def)
			end
		end

		-- Update node definition of changes to allow_attach were made
		if table_modified(original_allow_attach, allow_attach) then
			core.override_item(name, {_vl_allow_attach = allow_attach})
		end
	end
end)

