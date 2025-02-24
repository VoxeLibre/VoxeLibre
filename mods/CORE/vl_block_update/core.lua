local mod = {
	updated = {},
}
vl_block_update = mod

---@class core.NodeDef
---@field vl_block_update? fun(pos : vector.Vector, node : core.Node, def : core.NodeDef)
---@field _onload? fun(pos : vector.Vector)

local PROFILE = false
local lookaside_cache = {}

local mod_internal = {
	pending_block_updates = {},
	lookaside_cache = lookaside_cache,
	vl_block_update = vl_block_update,
	has_block_updates = false,
}

local function make_pattern_setter(block_update_pattern)
	local code = [[
		local args = ...
		local mod_internal = args.mod_internal
		local lookaside_cache = mod_internal.lookaside_cache
		local vl_block_update = mod_internal.vl_block_update

		local core_hash_node_position = core.hash_node_position

		return function(pos)
			local pos_hash = core_hash_node_position(pos)
			vl_block_update.updated[pos_hash] = true
			mod_internal.has_block_updates = true
			lookaside_cache[pos_hash] = nil
	]]

	if type(core.hash_node_position(vector.zero())) == "number" then
		for i = 1,#block_update_pattern do
			local hash_diff = core.hash_node_position(block_update_pattern[i]) - core.hash_node_position(vector.zero())
			if hash_diff < 0 then
				code = code.. "mod_internal.pending_block_updates[pos_hash-"..tostring(-hash_diff).."]=true\n"
			else
				code = code.. "mod_internal.pending_block_updates[pos_hash+"..tostring(hash_diff).."]=true\n"
			end
		end
	else
		local p = block_update_pattern[1]
		code = code .. "local np = vector.offset(pos,"..p.x..","..p.y..","..p.z..")\n"
		code = code .. "mod_internal.pending_block_updates[core.hash_node_position(np)]=true\n"
		for i = 2,#block_update_pattern do
			p = block_update_pattern[i]
			code = code .. "np.x = pos.x+("..p.x..")\n"
			code = code .. "np.y = pos.y+("..p.x..")\n"
			code = code .. "np.z = pos.z+("..p.x..")\n"
			code = code .. "mod_internal.pending_block_updates[core.hash_node_position(np)]=true\n"
		end
	end

	code = code .. [[
		end
	]]

	print("code:\n"..code)
	return loadstring(code)({mod_internal = mod_internal})
end


-- Block updates are processed on the next timestep
-- This is written to consolidate multiple updates to the same position
local two_around_pattern = {
	vector.new( 1, 0, 0), vector.new(-1, 0, 0), vector.new( 0, 1, 0),
	vector.new( 0,-1, 0), vector.new( 0, 0, 1), vector.new( 0, 0,-1),
	vector.new( 2, 0, 0), vector.new(-2, 0, 0), vector.new( 0, 2, 0),
	vector.new( 0,-2, 0), vector.new( 0, 0, 2), vector.new( 0, 0,-2),
	vector.new( 1, 1, 0), vector.new( 1,-1, 0), vector.new(-1, 1, 0),
	vector.new(-1,-1, 0), vector.new( 1, 0, 1), vector.new(-1, 0, 1),
	vector.new( 1, 0,-1), vector.new(-1, 0,-1), vector.new( 0, 1, 1),
	vector.new( 0,-1, 1), vector.new( 0, 1,-1), vector.new( 0,-1,-1),
}
local queue_block_updates = make_pattern_setter(two_around_pattern)

core.register_globalstep(function()
	if not mod_internal.has_block_updates then return end

	local start = core.get_us_time()
	local updates = mod_internal.pending_block_updates
	mod_internal.pending_block_updates = {}
	mod_internal.has_block_updates = false

	for hash,_ in pairs(updates) do
		local lookaside = lookaside_cache[hash]

		if false ~= lookaside then
			local pos = lookaside and lookaside[1] or core.get_position_from_hash(hash)
			local node = lookaside and lookaside[2] or core.get_node(pos)
			local def = lookaside and lookaside[3] or core.registered_nodes[node.name]

			if def and def.vl_block_update then
				def.vl_block_update(pos, node, def)
				lookaside_cache[hash] = lookaside or {pos, node, def}
			else
				lookaside_cache[hash] = false
			end
		end
	end
	vl_block_update.updated = {}
	if PROFILE then core.log("[vl_block_update] took "..(core.get_us_time() - start).." us") end
end)

local node_change_callbacks = {queue_block_updates}
function mod.register_node_change(callback)
	node_change_callbacks[#node_change_callbacks + 1] = callback
end
local function node_changed(pos)
	for i = 1,#node_change_callbacks do
		node_change_callbacks[i](pos)
	end
end
mod.node_changed = node_changed

local old_add_node = core.add_node
---@diagnostic disable-next-line:duplicate-set-field
function core.add_node(pos, node)
	old_add_node(pos, node)
	node_changed(pos)
end

local old_set_node = core.set_node
---@diagnostic disable-next-line:duplicate-set-field
function core.set_node(pos, node)
	old_set_node(pos, node)
	node_changed(pos)
end

local old_remove_node = core.remove_node
---@diagnostic disable-next-line:duplicate-set-field
function core.remove_node(pos)
	old_remove_node(pos)
	node_changed(pos)
end

local old_bulk_set_node = core.bulk_set_node
---@diagnostic disable-next-line:duplicate-set-field
function core.bulk_set_node(lst, node)
	 old_bulk_set_node(lst, node)
	for i=1,#lst do
		node_changed(lst[i])
	end
end

core.register_lbm({
	label = "Call _onload() when blocks load",
	name = "vl_block_update:handle_onload",
	nodenames = {"group:has_onload"},
	run_at_every_load = true,
	action = function(pos, node)
		core.registered_nodes[node.name]._onload(pos)
	end
})
core.register_on_mods_loaded(function()
	for name,def in pairs(core.registered_nodes) do
		if def._onload then
			local new_groups = table.copy(def.groups)
			new_groups.has_onload = 1
			core.override_item(name, {groups = new_groups})
		end
	end
end)
