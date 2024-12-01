vl_attach = {}

-- Check if placement at given node is allowed
function vl_attach.check_allowed(node, wdir, attach_type)
	local def = minetest.registered_nodes[node.name]
	if not def then return false end

	-- No ceiling torches
	if wdir == 0 then return false end

	-- Allow solid, opaque, full cube collision box nodes are allowed.
	if def.groups.solid and def.groups.opaque then return true end

	-- Allow nodes to define attachable device type handling
	if not def._vl_allow_attach then return false end
	local vl_allow_attach = def._vl_allow_attach

	-- find allow/deny/callback for specified attach_type, and use "all" as a fallback
	local allow_attach
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
		local allow_attach = def._vl_allow_attach and table.copy(def._vl_allow_attach) or {}

		-- Allow placing attachables over top buildable_to nodes
		if def.buildable_to then
			allow_attach.all = true
		end

		-- Run all autogroup callbacks to build allow_attach
		for i = 1,#autogroup_callbacks do
			autogroup_callbacks[i](allow_attach, name, def)
		end

		core.override_item(name, {_vl_allow_attach = allow_attach})
	end
end)

