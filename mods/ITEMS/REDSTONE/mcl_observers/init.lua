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

mesecon.register_node("mcl_observers:observer",
{
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	paramtype2 = "facedir",
	-- TODO: Add to craft guide and creative inventory when it's useful
	groups = {pickaxey=1, not_in_craft_guide=1, not_in_creative_inventory=1 },
	on_rotate = false,
	_mcl_blast_resistance = 17.5,
	_mcl_hardness = 3.5,
},
{
	description = "Observer",
	tiles = {
		"mcl_observers_observer_top.png", "default_furnace_bottom.png",
		"mcl_observers_observer_side.png", "mcl_observers_observer_side.png",
		"mcl_observers_observer_front.png", "mcl_observers_observer_back.png",
	},
	-- TODO: Mesecons handling
	mesecons = { receptor = {
		state = mesecon.state.off,
		rules = get_rules_flat,
	}},
},
{
	_doc_items_create_entry = false,
	tiles = {
		"mcl_observers_observer_top.png", "default_furnace_bottom.png",
		"mcl_observers_observer_side.png", "mcl_observers_observer_side.png",
		"mcl_observers_observer_front.png", "mcl_observers_observer_back_lit.png",
	},
	-- TODO: Mesecons handling
	mesecons = { receptor = {
		state = mesecon.state.on,
		rules = get_rules_flat,
	}},
}
)


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

