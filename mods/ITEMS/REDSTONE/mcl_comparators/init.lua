-- Functions that get the input/output rules of the comparator

local comparator_get_output_rules = function(node)
	local rules = {{x = -1, y = 0, z = 0}}
	for i = 0, node.param2 do
		rules = mesecon:rotate_rules_left(rules)
	end
	return rules
end


local comparator_get_input_rules = function(node)
	local rules = {
		-- we rely on this order in update_self below
		{x = 1, y = 0, z =  0},  -- back
		{x = 0, y = 0, z = -1},  -- side
		{x = 0, y = 0, z =  1},  -- side
	}
	for i = 0, node.param2 do
		rules = mesecon:rotate_rules_left(rules)
	end
	return rules
end


-- Functions that are called after the delay time

local comparator_turnon = function(params)
	local rules = comparator_get_output_rules(params.node)
	mesecon:receptor_on(params.pos, rules)
end


local comparator_turnoff = function(params)
	local rules = comparator_get_output_rules(params.node)
	mesecon:receptor_off(params.pos, rules)
end


-- Functions that set the correct node type an schedule a turnon/off

local comparator_activate = function(pos, node)
	local def = minetest.registered_nodes[node.name]
	mesecon:swap_node(pos, def.comparator_onstate)
	minetest.after(0.1, comparator_turnon , {pos = pos, node = node})
end


local comparator_deactivate = function(pos, node)
	local def = minetest.registered_nodes[node.name]
	mesecon:swap_node(pos, def.comparator_offstate)
	minetest.after(0.1, comparator_turnoff, {pos = pos, node = node})
end


-- wether pos has an inventory that contains at least one item
local container_inventory_nonempty = function(pos)
	local invnode = minetest.get_node(pos)
	local invnodedef = minetest.registered_nodes[invnode.name]
	-- Ignore stale nodes
	if not invnodedef then return false end

	-- Only accept containers. When a container is dug, it's inventory
	-- seems to stay. and we don't want to accept the inventory of an air
	-- block
	if not invnodedef.groups.container then return false end

	local inv = minetest.get_inventory({type="node", pos=pos})
	if not inv then return false end

	for listname, _ in pairs(inv:get_lists()) do
		if not inv:is_empty(listname) then return true end
	end

	return false
end

-- whether the comparator should be on according to its inputs
local comparator_desired_on = function(pos, node)
	local my_input_rules = comparator_get_input_rules(node);
	local back_rule = my_input_rules[1]
	local state = mesecon:is_powered_from(pos, back_rule)
		or container_inventory_nonempty(vector.add(pos, back_rule))

	-- if back input if off, we don't need to check side inputs
	if not state then return false end

	-- without power levels, side inputs have no influence on output in compare
	-- mode
	local mode = minetest.registered_nodes[node.name].comparator_mode
	if mode == "comp" then return state end

	-- subtract mode, subtract max(side_inputs) from back input
	local side_state = false
	for ri = 2,3 do
		side_state = side_state or mesecon:is_powered_from(pos, my_input_rules[ri])
		if side_state then break end
	end
	-- state is known to be true
	return not side_state
end


-- update comparator state, if needed
local update_self = function(pos, node)
	node = node or minetest.get_node(pos)
	local old_state = mesecon:is_receptor_on(node.name)
	local new_state = comparator_desired_on(pos, node)
	if new_state ~= old_state then
		if new_state then
			comparator_activate(pos, node)
		else
			comparator_deactivate(pos, node)
		end
	end
end


-- compute tile depending on state and mode
local get_tiles = function(state, mode)
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
local flipmode = function(mode)
	if mode == "comp" then    return "sub"
	elseif mode == "sub" then return "comp"
	end
end

local make_rightclick_handler = function(state, mode)
	local newnodename =
		"mcl_comparators:comparator_"..state.."_"..flipmode(mode)
	return function (pos, node)
		mesecon:swap_node(pos,newnodename)
	end
end


-- Register the 2 (states) x 2 (modes) comparators

local longdesc = "Redstone comparators are redstone components which "..
	"compare redstone signals and measure various node states, such as "..
	"how full inventories are."
local usagehelp = "To power a redstone comparater, send a signal in “arrow” "..
	"direction, or place the block to measure there.  Send the signal "..
	"to compare with in from the side."
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

for _, mode in pairs{"comp", "sub"} do
for _, state in pairs{mesecon.state.on, mesecon.state.off} do
	local state_str = state_strs[state]
	local nodename =
		"mcl_comparators:comparator_"..state_strs[state].."_"..mode

	local nodedef = {
		description = "Redstone Comparator",
		inventory_image = icon,
		wield_image = icon,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		drawtype = "nodebox",
		tiles = get_tiles(state_strs[state], mode),
		wield_image = "mcl_comparators_off.png",
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
		drop = 'mcl_comparators:comparator_off_comp',
		on_construct = update_self,
		on_rightclick =
			make_rightclick_handler(state_strs[state], mode),
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
		}
	}

	if mode == "comp" and state == mesecon.state.off then
		-- This is the prototype
		nodedef._doc_items_create_entry = true
	else
		nodedef.groups = table.copy(nodedef.groups)
		nodedef.groups.not_in_creative_inventory = 1
		local extra_desc = {}
		if mode == "sub" then
			table.insert(extra_desc, "Subtract")
		end
		if state == mesecon.state.on then
			table.insert(extra_desc, "Powered")
		end
		nodedef.description = nodedef.description..
			" ("..table.concat(extra_desc, ", ")..")"
	end

	minetest.register_node(nodename, nodedef)
end
end

-- Register recipies
local rstorch = "mesecons_torch:mesecon_torch_on"
local quartz  = "mcl_nether:quartz"
local stone   = "mcl_core:stone"

minetest.register_craft({
	output = "mcl_comparators:comparator_off_comp",
	recipe = {
		{ "",      rstorch, ""      },
		{ rstorch, quartz,  rstorch },
		{ stone,   stone,   stone   },
	}
})

-- Register active block handlers
minetest.register_abm({
	label = "Comparator check for containers",
	nodenames = {
		"mcl_comparators:comparator_off_comp",
		"mcl_comparators:comparator_off_sub",
	},
	neighbors = {"group:container"},
	interval = 1,
	chance = 1,
	action = update_self,
})

minetest.register_abm({
	label = "Comparator check for no containers",
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
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_comparators:comparator_off_comp",
			    "nodes", "mcl_comparators:comparator_off_sub")
	doc.add_entry_alias("nodes", "mcl_comparators:comparator_off_comp",
			    "nodes", "mcl_comparators:comparator_on_comp")
	doc.add_entry_alias("nodes", "mcl_comparators:comparator_off_comp",
			    "nodes", "mcl_comparators:comparator_on_sub")
end
