local defaults = {}
vl_attach = {
	defaults = defaults,
}

-- Check if placement at given node is allowed
local empty_table = {}
function vl_attach.check_allowed(node, wdir, attach_type)
	local def = minetest.registered_nodes[node.name]
	if not def then return false end

	-- Handle type-specific checks that apply to all node typesa
	local allow_attach = defaults[attach_type] and defaults[attach_type](node, def, wdir, attach_type)
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

	return allow_attach
end

local autogroup_callbacks = {}
function vl_attach.register_autogroup(callback)
	autogroup_callbacks[#autogroup_callbacks + 1] = callback
end

core.register_on_mods_loaded(function()
	for name,def in pairs(core.registered_nodes) do
		local groups = def.groups
		local original_allow_attach = def._vl_allow_attach or {}
		local allow_attach = def._vl_allow_attach and table.copy(def._vl_allow_attach) or {}

		-- Allow placing attachables over top buildable_to nodes
		if def.buildable_to then
			allow_attach.all = true
		end

		-- Run all autogroup callbacks to build allow_attach
		for i = 1,#autogroup_callbacks do
			autogroup_callbacks[i](allow_attach, name, def)
		end

		-- Update node definition of changes to allow_attach were made
		local has_changes = false
		for k,v in pairs(allow_attach) do
			if original_allow_attach[k] ~= v then has_changes = true end
		end
		for k,v in pairs(original_allow_attach) do
			if allow_attach[k] ~= v then has_changes = true end
		end
		if has_changes then
			core.override_item(name, {_vl_allow_attach = allow_attach})
		end
	end
end)

