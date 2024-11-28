local S = minetest.get_translator(minetest.get_current_modname())

local get_node = minetest.get_node

local rules_down = {{ x = 0, y = 1, z = 0, spread = true }}
local rules_up = {{ x = 0, y = -1, z = 0, spread = true }}
local function get_rules_flat(node)
	local rule = core.facedir_to_dir((node.param2+2)%4)
	rule.spread = true
	return {rule}
end

local function observer_look_position(pos, node)
	local node = node or get_node(pos)

	if node.name == "mcl_observers:observer_up_off" or node.name == "mcl_observers:observer_up_on" then
		return vector.offset(pos, 0, 1, 0)
	elseif node.name == "mcl_observers:observer_down_off" or node.name == "mcl_observers:observer_down_on" then
		return vector.offset(pos, 0, -1, 0)
	else
		return vector.add(pos, minetest.facedir_to_dir(node.param2))
	end
end

-- Vertical orientation
local function observer_orientate(pos, placer)
	-- Not placed by player
	if not placer then return end

	-- Placer pitch in degrees
	local pitch = placer:get_look_vertical() * (180 / math.pi)

	--local node = get_node(pos)
	if pitch > 55 then -- player looking upwards
		-- Observer looking downwards
		minetest.set_node(pos, {name="mcl_observers:observer_down_off"})
	elseif pitch < -55 then -- player looking downwards
		-- Observer looking upwards
		minetest.set_node(pos, {name="mcl_observers:observer_up_off"})
	end
end

local function update_observer(pos, node, def, force_activate)
	local front = observer_look_position(pos, node)
	local frontnode = get_node(front)
	local meta = minetest.get_meta(pos)

	if not force_activate then
		-- Ignore loading map blocks
		if frontnode.name == "ignore" then return end

		local oldnode = meta:get_string("node_name")
		if oldnode == "" then
			meta:set_string("node_name", frontnode.name)
			meta:set_string("node_param2", tostring(frontnode.param2))
			return
		end

		local oldparam2 = meta:get_string("node_param2")

		-- Check if the observed node has changed
		local frontnode_def = core.registered_nodes[frontnode.name]
		local ignore_param2 = frontnode_def and frontnode_def.groups.observers_ignore_param2 or 0 ~= 0
		if frontnode.name == oldnode and (ignore_param2 or tostring(frontnode.param2) == oldparam2) then
			return
		end
	end

	-- Node state changed! Activate observer
	if node.name == "mcl_observers:observer_off" then
		minetest.set_node(pos, {name = "mcl_observers:observer_on", param2 = node.param2})
		mesecon.receptor_on(pos, get_rules_flat(node))
	elseif node.name == "mcl_observers:observer_down_off" then
		minetest.set_node(pos, {name = "mcl_observers:observer_down_on"})
		mesecon.receptor_on(pos, rules_down)
	elseif node.name == "mcl_observers:observer_up_off" then
		minetest.set_node(pos, {name = "mcl_observers:observer_up_on"})
		mesecon.receptor_on(pos, rules_up)
	end

	meta:set_string("node_name", frontnode.name)
	meta:set_string("node_param2", tostring(frontnode.param2))
	return frontnode
end
local function activate_observer(pos, node, def)
	update_observer(pos, node, def, true)
end

local function decay_on_observer(pos)
	local original_name = get_node(pos).name
	core.after(mcl_vars.redstone_tick,function()
		local node = get_node(pos)
		if node.name ~= original_name then return end

		local def = core.registered_nodes[node.name]
		local old_meta = minetest.get_meta(pos):to_table()
		node.name = def._mcl_observer_off_name
		minetest.set_node(pos, node)

		mesecon.receptor_off(pos, get_rules_flat(node))
		minetest.get_meta(pos):from_table(old_meta)
	end)
end

mesecon.register_node("mcl_observers:observer", {
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_stone_defaults(),
		paramtype2 = "facedir",
		on_rotate = false,
		_mcl_blast_resistance = 3,
		_mcl_hardness = 3,
		vl_block_update = update_observer,
	}, {
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
		},
		after_place_node = observer_orientate,
		_onmove = activate_observer,
	}, {
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
	}
)

mesecon.register_node("mcl_observers:observer_down", {
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_stone_defaults(),
		groups = {pickaxey=1, material_stone=1, not_opaque=1, not_in_creative_inventory=1 },
		on_rotate = false,
		_mcl_blast_resistance = 3,
		_mcl_hardness = 3,
		drop = "mcl_observers:observer_off",
	}, {
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
		},

		_onmove = activate_observer,
	}, {
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
	}
)

mesecon.register_node("mcl_observers:observer_up", {
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_stone_defaults(),
		groups = {pickaxey=1, material_stone=1, not_opaque=1, not_in_creative_inventory=1 },
		on_rotate = false,
		_mcl_blast_resistance = 3,
		_mcl_hardness = 3,
		drop = "mcl_observers:observer_off",
		vl_block_update = update_observer,
	}, {
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
		},

		_onmove = activate_observer,
	}, {
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
	}
)

minetest.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
		{ "mcl_nether:quartz", "mesecons:redstone", "mesecons:redstone" },
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
	},
})
minetest.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
		{ "mesecons:redstone", "mesecons:redstone", "mcl_nether:quartz" },
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
	},
})

