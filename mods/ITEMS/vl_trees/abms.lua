local GROWTH_INTERVAL, GROWTH_CHANCE = 30, 3
local LEAFDECAY_INTERVAL, LEAFDECAY_CHANCE = 5, 9

local math_floor, math_random = math.floor, math.random
local vector_new, vector_offset = vector.new, vector.offset

local function leafdecay_particles(pos, node)
	core.add_particlespawner({
		amount = math_random(10, 20),
		time = 0.1,
		minpos = vector_offset(pos, -0.4, -0.4, -0.4),
		maxpos = vector_offset(pos, 0.4, 0.4, 0.4),
		minvel = vector_new(-0.2, -0.2, -0.2),
		maxvel = vector_new(0.2, 0.1, 0.2),
		minacc = vector_new(0, -9.81, 0),
		maxacc = vector_new(0, -9.81, 0),
		minexptime = 0.1,
		maxexptime = 0.5,
		minsize = 0.5,
		maxsize = 1.5,
		collisiondetection = true,
		vertical = false,
		node = node,
	})
end

-- Leaf decay ABM
--
-- Whenever a tree trunk node is removed, all `group:leaves` nodes in a radius
-- of 6 blocks are checked from the trunk node's `after_destruct` handler.
-- Any such nodes within that radius that has no trunk node present within a
-- distance of 6 blocks is replaced with a `group:orphan_leaves` node.
--
-- The `group:orphan_leaves` nodes are gradually decayed in this ABM.
core.register_abm({
	label = "Leaf decay",
	nodenames = {"group:orphan_leaves"},
	interval = LEAFDECAY_INTERVAL,
	chance = LEAFDECAY_CHANCE,
	action = function(pos, node)
		-- spawn item entities for any of the leaf's drops
		local itemstacks = core.get_node_drops(node.name)
		for _, itemname in pairs(itemstacks) do
			core.add_item(vector_offset(pos, math_random() - 0.5, math_random() - 0.5, math_random() - 0.5), itemname)
		end
		-- remove the decayed node
		core.remove_node(pos)
		leafdecay_particles(pos, node)
		core.check_for_falling(pos)
	end
})

-- Sapling growth ABM
core.register_abm({
	label = "Sapling growth",
	nodenames = {"group:sapling"},
	neighbors = {"group:soil_sapling"},
	interval = GROWTH_INTERVAL,
	chance = GROWTH_CHANCE,
	action = vl_trees.grow_sapling,
})

-- Roll-based catch-up LBM
core.register_lbm({
	name = "vl_trees:growth_on_load",
	label = "Add growth for trees in unloaded blocks",
	nodenames = {"group:sapling"},
	neighbors = {"group:soil_sapling"},
	run_at_every_load = true,
	action = function(pos, node, dtime_s)
		local rolls = math_floor(dtime_s / GROWTH_INTERVAL)
		if rolls <= 0 then return end

		-- simulate how often the block will be ticked
		local stages = 0
		for i = 1, rolls do
			if math_random(1, GROWTH_CHANCE) == 1 then stages = stages + 1 end
		end
		if stages > 0 then
			vl_trees.grow_sapling(pos, node, stages)
		end
	end,
})

core.register_lbm({
	name = "vl_trees:leaves_param2_update",
	label = "Set old leaves param2",
	nodenames = {"group:leaves,biomecolor"},
	run_at_every_load = false,
	action = function(pos, node)
		local param2 = mcl_util.get_palette_indexes_from_pos(pos).grass_palette_index
		if node.param2 ~= param2 then
			node.param2 = param2
			core.swap_node(pos, node)
		end
	end,
})
