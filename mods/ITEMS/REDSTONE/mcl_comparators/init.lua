local S = core.get_translator(core.get_current_modname())

-- Functions that get the input/output rules of the comparator
local output_rules = {
	[0] = {vector.new(-1, 0, 0)},
}
for i = 1,4 do
	output_rules[i] = mesecon.rotate_rules_left(output_rules[i-1])
end
local function comparator_get_output_rules(node)
	return output_rules[node.param2]
end

local input_rules = {
	[0] = {
		-- we rely on this order in update_self below, do not change
		{x = 1, y = 0, z =  0},  -- back
		{x = 0, y = 0, z = -1},  -- side
		{x = 0, y = 0, z =  1},  -- side
	},
}
for i = 1,4 do
	input_rules[i] = mesecon.rotate_rules_left(input_rules[i-1])
end

local function comparator_get_input_rules(node)
	return input_rules[node.param2]
end


-- Functions that are called after the delay time

local function comparator_turnon(params)
	local rules = comparator_get_output_rules(params.node)
	mesecon.receptor_on(params.pos, rules)
end


local function comparator_turnoff(params)
	local rules = comparator_get_output_rules(params.node)
	mesecon.receptor_off(params.pos, rules)
end


-- Functions that set the correct node type an schedule a turnon/off

local function comparator_activate(pos, node)
	local def = core.registered_nodes[node.name]
	local onstate = def.comparator_onstate
	if onstate then
		core.swap_node(pos, { name = onstate, param2 = node.param2 })
	end
	core.after(0.1, comparator_turnon , {pos = pos, node = node})
end


local function comparator_deactivate(pos, node)
	local def = core.registered_nodes[node.name]
	local offstate = def.comparator_offstate
	if offstate then
		core.swap_node(pos, { name = offstate, param2 = node.param2 })
	end
	core.after(0.1, comparator_turnoff, {pos = pos, node = node})
end

-- update comparator state, if needed
local function update_self(pos, node)
	node = node or core.get_node(pos)
	local node_def = core.registered_nodes[node.name]
	local old_power = vl_redstone.get_power_level(pos)

	-- Find the node we are pointing at
	local input_rules = comparator_get_input_rules(node);
	local back_rule = input_rules[1]
	local back_pos = vector.add(pos, back_rule)
	local back_node = core.get_node(back_pos)
	local back_nodedef = core.registered_nodes[back_node.name]

	-- Get the comparator mode
	local mode = node_def.comparator_mode

	local back_power_level = 0
	if back_nodedef and back_nodedef._mcl_comparators_get_reading then
		back_power_level = back_nodedef._mcl_comparators_get_reading(back_pos)
	else
		back_power_level = vl_redstone.get_power_level(back_pos)
	end

	-- Get the maximum side power level
	local side_power_level = 0
	for i=2,3 do
		local pl = vl_redstone.get_power_level(vector.add(pos,input_rules[i]))
		if pl > side_power_level then
			side_power_level = pl
		end
	end

	-- Apply subtraction or comparison
	local power_level
	if mode == "sub" then
		power_level = back_power_level - side_power_level
	elseif mode == "comp" then
		if side_power_level > back_power_level then
			power_level = 0
		else
			power_level = back_power_level
		end
	end
	if power_level < 0 then power_level = 0 end
	if power_level > 16 then power_level = 16 end

	core.log(dump{
		old_power = old_power,
		power_level = power_level
	})

	-- Update output power level
	vl_redstone.set_power_level(pos, output_rules[node.param2], power_level)

	-- Update node
	if power_level ~= 0 then
		node.name = node_def.comparator_onstate
		core.swap_node(pos, node)
	else
		node.name = node_def.comparator_offstate
		core.swap_node(pos, node)
	end
end


-- compute tile depending on state and mode
local function get_tiles(state, mode)
	local top = "mcl_comparators_"..state..".png^"..
		"mcl_comparators_"..mode..".png"
	local sides = "mcl_comparators_sides_"..state..".png^"..
		"mcl_comparators_sides_"..mode..".png"
	local ends = "mcl_comparators_ends_"..state..".png^"..
		"mcl_comparators_ends_"..mode..".png"
	return {
		top, "mcl_stairs_stone_slab_top.png",
		sides, sides.."^[transformFX",
		ends, ends,
	}
end

-- Given one mode, get the other mode
local function flipmode(mode)
	if mode == "comp" then    return "sub"
	elseif mode == "sub" then return "comp"
	end
end

local function make_rightclick_handler(state, mode)
	local newnodename =
		"mcl_comparators:comparator_"..state.."_"..flipmode(mode)
	return function (pos, node, clicker)
		local protname = clicker:get_player_name()
		if core.is_protected(pos, protname) then
			core.record_protection_violation(pos, protname)
			return
		end
		core.swap_node(pos, {name = newnodename, param2 = node.param2 })
	end
end


-- Register the 2 (states) x 2 (modes) comparators

local icon = "mcl_comparators_item.png"

local node_boxes = {
	comp = {
		{ -8/16, -8/16, -8/16,
		   8/16, -6/16,  8/16 },	-- the main slab
		{ -1/16, -6/16,  6/16,
		   1/16, -4/16,  4/16 },	-- front torch
		{ -4/16, -6/16, -5/16,
		  -2/16, -1/16, -3/16 },	-- left back torch
		{  2/16, -6/16, -5/16,
		   4/16, -1/16, -3/16 },	-- right back torch
	},
	sub = {
		{ -8/16, -8/16, -8/16,
		   8/16, -6/16,  8/16 },	-- the main slab
		{ -1/16, -6/16,  6/16,
		   1/16, -3/16,  4/16 },	-- front torch (active)
		{ -4/16, -6/16, -5/16,
		  -2/16, -1/16, -3/16 },	-- left back torch
		{  2/16, -6/16, -5/16,
		   4/16, -1/16, -3/16 },	-- right back torch
	},
}

local collision_box = {
	type = "fixed",
	fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
}

local state_strs = {
	[ mesecon.state.on  ] = "on",
	[ mesecon.state.off ] = "off",
}

local groups = {
	dig_immediate = 3,
	dig_by_water  = 1,
	destroy_by_lava_flow = 1,
	dig_by_piston = 1,
	attached_node = 1,
}

local on_rotate
if core.get_modpath("screwdriver") then
	on_rotate = screwdriver.disallow
end

for _, mode in pairs{"comp", "sub"} do
	for _, state in pairs{mesecon.state.on, mesecon.state.off} do
		local state_str = state_strs[state]
		local nodename =
			"mcl_comparators:comparator_"..state_str.."_"..mode

		-- Help
		local longdesc, usagehelp, use_help
		if state_str == "off" and mode == "comp" then
			longdesc = S("Redstone comparators are multi-purpose redstone components.").."\n"..
			S("They can transmit a redstone signal, detect whether a block contains any items and compare multiple signals.")

			usagehelp = S("A redstone comparator has 1 main input, 2 side inputs and 1 output. The output is in arrow direction, the main input is in the opposite direction. The other 2 sides are the side inputs.").."\n"..
				S("The main input can powered in 2 ways: First, it can be powered directly by redstone power like any other component. Second, it is powered if, and only if a container (like a chest) is placed in front of it and the container contains at least one item.").."\n"..
				S("The side inputs are only powered by normal redstone power. The redstone comparator can operate in two modes: Transmission mode and subtraction mode. It starts in transmission mode and the mode can be changed by using the block.").."\n\n"..
				S("Transmission mode:\nThe front torch is unlit and lowered. The output is powered if, and only if the main input is powered. The two side inputs are ignored.").."\n"..
				S("Subtraction mode:\nThe front torch is lit. The output is powered if, and only if the main input is powered and none of the side inputs is powered.")
		else
			use_help = false
		end

		local nodedef = {
			description = S("Redstone Comparator"),
			inventory_image = icon,
			wield_image = icon,
			_doc_items_create_entry = use_help,
			_doc_items_longdesc = longdesc,
			_doc_items_usagehelp = usagehelp,
			drawtype = "nodebox",
			tiles = get_tiles(state_str, mode),
			use_texture_alpha = core.features.use_texture_alpha_string_modes and "opaque" or false,
			--wield_image = "mcl_comparators_off.png",
			walkable = true,
			selection_box = collision_box,
			collision_box = collision_box,
			node_box = {
				type = "fixed",
				fixed = node_boxes[mode],
			},
			groups = groups,
			paramtype = "light",
			paramtype2 = "facedir",
			sunlight_propagates = false,
			is_ground_content = false,
			drop = "mcl_comparators:comparator_off_comp",
			on_construct = update_self,
			on_rightclick =
				make_rightclick_handler(state_str, mode),
			comparator_mode = mode,
			comparator_onstate = "mcl_comparators:comparator_on_"..mode,
			comparator_offstate = "mcl_comparators:comparator_off_"..mode,
			sounds = mcl_sounds.node_sound_stone_defaults(),
			mesecons = {
				receptor = {
					state = state,
					rules = comparator_get_output_rules,
				},
				effector = {
					rules = comparator_get_input_rules,
					action_change = update_self,
				}
			},
			on_rotate = on_rotate,
		}

		if mode == "comp" and state == mesecon.state.off then
			-- This is the prototype
			nodedef._doc_items_create_entry = true
		else
			nodedef.groups = table.copy(nodedef.groups)
			nodedef.groups.not_in_creative_inventory = 1
			--local extra_desc = {}
			if mode == "sub" or state == mesecon.state.on then
				nodedef.inventory_image = nil
			end
			local desc = nodedef.description
			if mode ~= "sub" and state == mesecon.state.on then
				desc = S("Redstone Comparator (Powered)")
			elseif mode == "sub" and state ~= mesecon.state.on then
				desc = S("Redstone Comparator (Subtract)")
			elseif mode == "sub" and state == mesecon.state.on then
				desc = S("Redstone Comparator (Subtract, Powered)")
			end
			nodedef.description = desc
		end

		core.register_node(nodename, nodedef)
		mcl_wip.register_wip_item(nodename)
	end
end

-- Register recipies
local rstorch = "mesecons_torch:mesecon_torch_on"
local quartz  = "mcl_nether:quartz"
local stone   = "mcl_core:stone"

core.register_craft({
	output = "mcl_comparators:comparator_off_comp",
	recipe = {
		{ "",      rstorch, ""      },
		{ rstorch, quartz,  rstorch },
		{ stone,   stone,   stone   },
	}
})

-- Register active block handlers
core.register_abm({
	label = "Comparator signal input check (comparator is off)",
	nodenames = {
		"mcl_comparators:comparator_off_comp",
		"mcl_comparators:comparator_off_sub",
	},
	neighbors = {"group:container", "group:comparator_signal"},
	interval = 1,
	chance = 1,
	action = update_self,
})

core.register_abm({
	label = "Comparator signal input check (comparator is on)",
	nodenames = {
		"mcl_comparators:comparator_on_comp",
		"mcl_comparators:comparator_on_sub",
	},
	-- needs to run regardless of neighbors to make sure we detect when a
	-- container is dug
	interval = 1,
	chance = 1,
	action = update_self,
})


-- Add entry aliases for the Help
if core.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_comparators:comparator_off_comp",
				"nodes", "mcl_comparators:comparator_off_sub")
	doc.add_entry_alias("nodes", "mcl_comparators:comparator_off_comp",
				"nodes", "mcl_comparators:comparator_on_comp")
	doc.add_entry_alias("nodes", "mcl_comparators:comparator_off_comp",
				"nodes", "mcl_comparators:comparator_on_sub")
end
