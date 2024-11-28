local mod = {
	updated = {},
}
vl_block_update = mod

local block_update_pattern = {
	vector.new( 1, 0, 0), vector.new(-1, 0, 0), vector.new( 0, 1, 0),
	vector.new( 0,-1, 0), vector.new( 0, 0, 1), vector.new( 0, 0,-1),
	vector.new( 2, 0, 0), vector.new(-2, 0, 0), vector.new( 0, 2, 0),
	vector.new( 0,-2, 0), vector.new( 0, 0, 2), vector.new( 0, 0,-2),
	vector.new( 1, 1, 0), vector.new( 1,-1, 0), vector.new(-1, 1, 0),
	vector.new(-1,-1, 0), vector.new( 1, 0, 1), vector.new(-1, 0, 1),
	vector.new( 1, 0,-1), vector.new(-1, 0,-1), vector.new( 0, 1, 1),
	vector.new( 0,-1, 1), vector.new( 0, 1,-1), vector.new( 0,-1,-1),
}

-- Block updates are processed on the next timestep
-- This is written to consolidate multiple updates to the same position
local queue_block_updates
if type(core.hash_node_position(vector.zero())) == "number" then
	-- core.hash_node_position() returns a number, we can perform some optimizations based on this that will make the
	-- JIT compiler generate better code
	local function codegen_queue_block_updates()
		local code = [[
			local pending_block_updates = {}
			local function queue_block_updates(pos)
				pos = vector.round(pos)
				local pos_hash = core.hash_node_position(pos)
				vl_block_update.updated[pos_hash] = true
		]]
			for i = 1,#block_update_pattern do
				local hash_diff = core.hash_node_position(block_update_pattern[i]) - core.hash_node_position(vector.zero())
				if hash_diff < 0 then
					code = code.. "\tpending_block_updates[pos_hash-"..tostring(-hash_diff).."]=true\n"
				else
					code = code.. "\tpending_block_updates[pos_hash+"..tostring(hash_diff).."]=true\n"
				end
			end
		code = code..[[
		end
		core.register_globalstep(function(dtime)
			local start = core.get_us_time()
			local updates = pending_block_updates
			pending_block_updates = {}

			for hash,_ in pairs(updates) do
				local pos = core.get_position_from_hash(hash)
				local node = core.get_node(pos)
				local def = core.registered_nodes[node.name]
				if def and def.vl_block_update then
					def.vl_block_update(pos, node, def)
				end
			end
			vl_block_update.updated = {}
		end)
		return queue_block_updates
		]]
		return loadstring(code)()
	end
	queue_block_updates = codegen_queue_block_updates()
else
	-- Use fallback that makes no assumptions about the result from core.hash_node_position()
	local pending_block_updates = {}

	queue_block_updates = function(pos)
		pos = vector.round(pos)
		vl_block_update.updated[core.hash_node_position(pos)] = true
		for i = 1,#block_update_pattern do
			local offset = block_update_pattern[i]
			pending_block_updates[core.hash_node_position(pos + offset)] = true
		end
	end
	core.register_globalstep(function(dtime)
		local start = core.get_us_time()
		local updates = pending_block_updates
		pending_block_updates = {}

		for hash,_ in pairs(updates) do
			local pos = core.get_position_from_hash(hash)
			local node = core.get_node(pos)
			local def = core.registered_nodes[node.name]
			if def and def.vl_block_update then
				def.vl_block_update(pos, node, def)
			end
		end
		mod.updated = {}
	end)
end

local node_change_callbacks = {queue_block_updates}
function mod.register_node_change(callback)
	node_change_callbacks[#node_change_callbacks + 1] = callback
end
local function node_changed(pos)
	for i = 1,#node_change_callbacks do
		node_change_callbacks[i](pos)
	end
end

local old_add_node = core.add_node
function core.add_node(pos, node)
	old_add_node(pos, node)
	node_changed(pos)
end

local old_set_node = core.set_node
function core.set_node(pos, node)
	old_set_node(pos, node)
	node_changed(pos)
end

local old_remove_node = core.remove_node
function core.remove_node(pos)
	old_remove_node(pos)
	node_changed(pos)
end

local old_bulk_set_node = core.bulk_set_node
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
