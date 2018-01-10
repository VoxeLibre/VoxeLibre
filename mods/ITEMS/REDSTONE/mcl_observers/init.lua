local rules_flat = {
	{ x = 0, y = 0, z = -1 },
}
local get_rules_flat = function(node)
	local rules = rules_flat
	for i=1, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules
end

-- Scan the node in front of the observer
-- and update the observer state if needed.
-- TODO: Also scan metadata changes.
-- TODO: Ignore some node changes.
local observer_scan = function(pos)
	local node = minetest.get_node(pos)
	local front = vector.add(pos, minetest.facedir_to_dir(node.param2))
	local frontnode = minetest.get_node(front)
	local meta = minetest.get_meta(pos)
	local oldnode = meta:get_string("node_name")
	local oldparam2 = meta:get_string("node_param2")
	local meta_needs_updating = false
	if oldnode ~= "" then
		if not (frontnode.name == oldnode and frontnode.param2) then
			-- Node state changed! Activate observer
			minetest.set_node(pos, {name = "mcl_observers:observer_on", param2 = node.param2})
			mesecon.receptor_on(pos)
			meta_needs_updating = true
		end
	else
		meta_needs_updating = true
	end
	if meta_needs_updating then
		meta:set_string("node_name", frontnode.name)
		meta:set_string("node_param2", frontnode.param2)
	end
	return frontnode
end

mesecon.register_node("mcl_observers:observer",
{
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	paramtype2 = "facedir",
	-- TODO: Add to craft guide and creative inventory when it's useful
	groups = {pickaxey=1, material_stone=1, not_in_craft_guide=1, not_in_creative_inventory=1 },
	on_rotate = false,
	_mcl_blast_resistance = 17.5,
	_mcl_hardness = 3.5,
},
{
	description = "Observer",
	tiles = {
		"mcl_observers_observer_top.png^[transformR180", "default_furnace_bottom.png",
		"mcl_observers_observer_side.png", "mcl_observers_observer_side.png",
		"mcl_observers_observer_front.png", "mcl_observers_observer_back.png",
	},
	mesecons = { receptor = {
		state = mesecon.state.off,
		rules = get_rules_flat,
	}},
	on_construct = function(pos)
		observer_scan(pos)
	end,

	-- DEBUG code to manually turn on an observer by rightclick.
	-- TODO: Remove this when observers are complete.
	on_rightclick = function(pos, node, clicker)
		minetest.set_node(pos, {name = "mcl_observers:observer_on", param2 = node.param2})
		mesecon.receptor_on(pos)
	end,
},
{
	_doc_items_create_entry = false,
	tiles = {
		"mcl_observers_observer_top.png^[transformR180", "default_furnace_bottom.png",
		"mcl_observers_observer_side.png", "mcl_observers_observer_side.png",
		"mcl_observers_observer_front.png", "mcl_observers_observer_back_lit.png",
	},
	mesecons = { receptor = {
		state = mesecon.state.on,
		rules = get_rules_flat,
	}},

	-- VERY quickly disable observer after construction
	on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		-- 1 redstone tick = 0.1 seconds
		timer:start(0.1)
	end,
	on_timer = function(pos, elapsed)
		local node = minetest.get_node(pos)
		minetest.set_node(pos, {name = "mcl_observers:observer_off", param2 = node.param2})
		mesecon.receptor_off(pos)
	end,
}
)

-- Regularily check the observer nodes.
-- TODO: This is rather slow and clunky. Find a more efficient way to do this.
minetest.register_abm({
	nodenames = {"mcl_observers:observer_off"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		observer_scan(pos)
	end,
})


minetest.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
		{ "mcl_nether:quartz", "mesecons:redstone", "mesecons:redstone" },
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
	}
})
minetest.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
		{ "mesecons:redstone", "mesecons:redstone", "mcl_nether:quartz" },
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
	}
})

