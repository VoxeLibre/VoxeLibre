
local pending_block_updates = {}
local block_update_pattern = {
	-- Distance 1 (6 positions)
	vector.new( 1, 0, 0),
	vector.new(-1, 0, 0),
	vector.new( 0, 1, 0),
	vector.new( 0,-1, 0),
	vector.new( 0, 0, 1),
	vector.new( 0, 0,-1),

	-- Distance 2 (18 positions)
	vector.new( 2, 0, 0),
	vector.new(-2, 0, 0),
	vector.new( 0, 2, 0),
	vector.new( 0,-2, 0),
	vector.new( 0, 0, 2),
	vector.new( 0, 0,-2),

	vector.new( 1, 1, 0),
	vector.new( 1,-1, 0),
	vector.new(-1, 1, 0),
	vector.new(-1,-1, 0),

	vector.new( 1, 0, 1),
	vector.new(-1, 0, 1),
	vector.new( 1, 0,-1),
	vector.new(-1, 0,-1),

	vector.new( 0, 1, 1),
	vector.new( 0,-1, 1),
	vector.new( 0, 1,-1),
	vector.new( 0,-1,-1),
}

-- Block updates are processed on the next timestep
-- This is written to consolidate multiple updates to the same position
local function queue_block_updates(pos)
	for i = 1,#block_update_pattern do
		local offset = block_update_pattern[i]
		pending_block_updates[core.hash_node_position(pos + offset)] = true
	end
end

local old_add_node = core.add_node
function core.add_node(pos, node)
	old_add_node(pos, node)
	queue_block_updates(pos)
end

local old_set_node = core.set_node
function core.set_node(pos, node)
	old_set_node(pos, node)
	queue_block_updates(pos)
end

local old_remove_node = core.remove_node
function core.remove_node(pos)
	old_remove_node(pos)
	queue_block_updates(pos)
end

local old_bulk_set_node = core.bulk_set_node
function core.bulk_set_node(lst, node)
	old_bulk_set_node(lst, node)
	for i=1,#lst do
		queue_block_updates(lst[i])
	end
end

core.register_globalstep(function(dtime)
	for hash,_ in pairs(pending_block_updates) do
		local pos = core.get_position_from_hash(hash)
		local node = core.get_node(pos)
		local def = core.registered_nodes[node.name]
		if def and def.vl_block_update then
			def.vl_block_update(pos, node, def)
		end
	end

	pending_block_updates = {}
end)
