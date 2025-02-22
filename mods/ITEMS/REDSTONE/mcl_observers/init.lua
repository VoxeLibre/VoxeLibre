local S = core.get_translator(core.get_current_modname())

local core_get_node = core.get_node

---@class core.NodeDef
---@field _mcl_observer_on_name? string
---@field _mcl_observer_off_name? string

local rules_down = {{ x = 0, y = 1, z = 0, spread = true }}
local rules_up = {{ x = 0, y = -1, z = 0, spread = true }}
local function get_rules_flat(node)
	local rule = core.facedir_to_dir((node.param2+2)%4)
	rule.spread = true
	return {rule}
end

local function observer_look_position(pos, node)
	node = node or core_get_node(pos)

	if node.name == "mcl_observers:observer_up_off" or node.name == "mcl_observers:observer_up_on" then
		return vector.offset(pos, 0, 1, 0)
	elseif node.name == "mcl_observers:observer_down_off" or node.name == "mcl_observers:observer_down_on" then
		return vector.offset(pos, 0, -1, 0)
	else
		return vector.add(pos, core.facedir_to_dir(node.param2))
	end
end

-- Vertical orientation
local function observer_orientate(pos, placer)
	-- Not placed by player
	if not placer then return end

	-- Placer pitch in degrees
	local pitch = placer:get_look_vertical() * (180 / math.pi)

	if pitch > 55 then -- player looking upwards
		-- Observer looking downwards
		core.set_node(pos, {name="mcl_observers:observer_down_off"})
	elseif pitch < -55 then -- player looking downwards
		-- Observer looking upwards
		core.set_node(pos, {name="mcl_observers:observer_up_off"})
	end
end

local function do_observer_activation(pos, node, def)
	if def and def._mcl_observer_on_name then
		node.name = def._mcl_observer_on_name
		core.set_node(pos, node)
		mesecon.receptor_on(pos)
	end
end
vl_scheduler.register_serializable("mcl_observers:do_observer_activation", do_observer_activation)

---@param node core.Node
local function update_observer(pos, node, def, force_activate)
	local front = observer_look_position(pos, node)
	if not force_activate and not vl_block_update.updated[core.hash_node_position(front)] then
		return
	end

	def = def or core.registered_nodes[node.name]

	-- Node state changed! Activate observer
	core.after(0,do_observer_activation, pos, node, def)
end
local function on_move(pos, node)
	update_observer(pos, node, core.registered_nodes[node.name], true)
end
local function on_load(pos)
	local node = core_get_node(pos)
	update_observer(pos, node, core.registered_nodes[node.name], true)
end
local function decay_on_observer(pos)
	local original_name = core_get_node(pos).name
	core.after(mcl_vars.redstone_tick + 0.05,function()
		local node = core_get_node(pos)
		if node.name ~= original_name then return end

		local def = core.registered_nodes[node.name]
		node.name = def._mcl_observer_off_name
		core.set_node(pos, node)
		mesecon.receptor_off(pos, get_rules_flat(node))
	end)
end

core.register_node("mcl_observers:observer_off",{
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	paramtype2 = "facedir",
	on_rotate = false,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	vl_block_update = update_observer,
	description = S("Observer"),
	_tt_help = S("Emits redstone pulse when block in front changes"),
	_doc_items_longdesc = S("An observer is a redstone component which observes the block in front of it and sends a very short redstone pulse whenever this block changes."),
	_doc_items_usagehelp = S("Place the observer directly in front of the block you want to observe with the “face” looking at the block. The arrow points to the side of the output, which is at the opposite side of the “face”. You can place your redstone dust or any other component here."),

	groups = {pickaxey=1, material_stone=1, not_opaque=1, },
	tiles = {
		"mcl_observers_observer_top.png^[transformR180", "default_furnace_bottom.png",
		"mcl_observers_observer_side.png", "mcl_observers_observer_side.png",
		"mcl_observers_observer_front.png", "mcl_observers_observer_back.png",
	},

	mesecons = {
		receptor = {
			state = mesecon.state.off,
			rules = get_rules_flat,
		},
		on_mvps_move = on_move,
	},

	after_place_node = observer_orientate,
	_mcl_observer_on_name = "mcl_observers:observer_on",
})
core.register_node("mcl_observers:observer_on",{
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	paramtype2 = "facedir",
	on_rotate = false,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	vl_block_update = update_observer,
	_doc_items_create_entry = false,
	groups = {pickaxey=1, material_stone=1, not_opaque=1, not_in_creative_inventory=1 },
	tiles = {
		"mcl_observers_observer_top.png^[transformR180", "default_furnace_bottom.png",
		"mcl_observers_observer_side.png", "mcl_observers_observer_side.png",
		"mcl_observers_observer_front.png", "mcl_observers_observer_back_lit.png",
	},
	mesecons = {
		receptor = {
			state = mesecon.state.on,
			rules = get_rules_flat,
		}
	},
	_mcl_observer_off_name = "mcl_observers:observer_off",
	on_construct = decay_on_observer,
	_onload = decay_on_observer,
})
core.register_node("mcl_observers:observer_down_off",{
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {pickaxey=1, material_stone=1, not_opaque=1, not_in_creative_inventory=1 },
	on_rotate = false,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	drop = "mcl_observers:observer_off",
	tiles = {
		"mcl_observers_observer_back.png", "mcl_observers_observer_front.png",
		"mcl_observers_observer_side.png^[transformR90", "mcl_observers_observer_side.png^[transformR90",
		"mcl_observers_observer_top.png", "mcl_observers_observer_top.png",
	},
	vl_block_update = update_observer,
	mesecons = {
		receptor = {
			state = mesecon.state.off,
			rules = rules_down,
		},
		on_mvps_move = on_move,
	},

	_mcl_observer_on_name = "mcl_observers:observer_down_on",
	_onload = on_load,
})
core.register_node("mcl_observers:observer_down_on",{
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {pickaxey=1, material_stone=1, not_opaque=1, not_in_creative_inventory=1 },
	on_rotate = false,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	drop = "mcl_observers:observer_off",
	_doc_items_create_entry = false,
	tiles = {
		"mcl_observers_observer_back_lit.png", "mcl_observers_observer_front.png",
		"mcl_observers_observer_side.png^[transformR90", "mcl_observers_observer_side.png^[transformR90",
		"mcl_observers_observer_top.png", "mcl_observers_observer_top.png",
	},
	mesecons = {
		receptor = {
			state = mesecon.state.on,
			rules = rules_down,
		},
	},

	_mcl_observer_off_name = "mcl_observers:observer_down_off",
	on_construct = decay_on_observer,
	_onload = decay_on_observer,
})
core.register_node("mcl_observers:observer_up_off",{
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {pickaxey=1, material_stone=1, not_opaque=1, not_in_creative_inventory=1 },
	on_rotate = false,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	drop = "mcl_observers:observer_off",
	vl_block_update = update_observer,
	tiles = {
		"mcl_observers_observer_front.png", "mcl_observers_observer_back.png",
		"mcl_observers_observer_side.png^[transformR270", "mcl_observers_observer_side.png^[transformR270",
		"mcl_observers_observer_top.png^[transformR180", "mcl_observers_observer_top.png^[transformR180",
	},
	mesecons = {
		receptor = {
			state = mesecon.state.off,
			rules = rules_up,
		},
		on_mvps_move = on_move,
	},

	_mcl_observer_on_name = "mcl_observers:observer_up_on",
	_onload = on_load,
})
core.register_node("mcl_observers:observer_up_on",{
	is_ground_content = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	groups = {pickaxey=1, material_stone=1, not_opaque=1, not_in_creative_inventory=1 },
	on_rotate = false,
	_mcl_blast_resistance = 3,
	_mcl_hardness = 3,
	drop = "mcl_observers:observer_off",
	vl_block_update = update_observer,
	_doc_items_create_entry = false,
	tiles = {
		"mcl_observers_observer_front.png", "mcl_observers_observer_back_lit.png",
		"mcl_observers_observer_side.png^[transformR270", "mcl_observers_observer_side.png^[transformR270",
		"mcl_observers_observer_top.png^[transformR180", "mcl_observers_observer_top.png^[transformR180",
	},
	mesecons = {
		receptor = {
			state = mesecon.state.on,
			rules = rules_up,
		},
	},

	_mcl_observer_off_name = "mcl_observers:observer_up_off",
	on_construct = decay_on_observer,
	_onload = decay_on_observer,
})

core.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
		{ "mcl_nether:quartz", "mesecons:redstone", "mesecons:redstone" },
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
	},
})
core.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
		{ "mesecons:redstone", "mesecons:redstone", "mcl_nether:quartz" },
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
	},
})
