local S = minetest.get_translator(minetest.get_current_modname())

mcl_observers = {}

local string   = string
local get_node = minetest.get_node

-- Warning! TODO: Remove this message.
-- 'realtime' is experimental feature! It can slow down everything!
-- Please set it to false and restart the game if something's wrong:
local realtime = true
--local realtime = false

-- Horizontal output rules
local rules_flat = {
	{ x = 0, y = 0, z = -1, spread = true },
}
local function get_rules_flat(node)
	local rules = rules_flat
	for i = 1, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules
end

-- Vertical output rules
local rules_down = {{ x = 0, y = 1,  z = 0, spread = true }}
local rules_up   = {{ x = 0, y = -1, z = 0, spread = true }}

-- Fire the redstone pulse, then rely on the node-timer in each 'on' state to turn it off
function mcl_observers.observer_activate(pos)
	minetest.after(mcl_vars.redstone_tick, function(p)
		local node = get_node(p)
		if not node then return end
		local nn = node.name
		if     nn == "mcl_observers:observer_off"      then
			minetest.set_node(p, { name="mcl_observers:observer_on",     param2=node.param2 })
			mesecon.receptor_on(p, get_rules_flat(node))
		elseif nn == "mcl_observers:observer_down_off" then
			minetest.set_node(p, { name="mcl_observers:observer_down_on" })
			mesecon.receptor_on(p, rules_down)
		elseif nn == "mcl_observers:observer_up_off"   then
			minetest.set_node(p, { name="mcl_observers:observer_up_on" })
			mesecon.receptor_on(p, rules_up)
		end
	end, pos)
end

-- Scan front block and pulse if it truly changed
local function observer_scan(pos, initialize)
	local node = get_node(pos)
	local front
	if     node.name:find("observer_up")   then front = vector.add(pos, {x=0, y=1,  z=0})
	elseif node.name:find("observer_down") then front = vector.add(pos, {x=0, y=-1, z=0})
	else                                     front = vector.add(pos, minetest.facedir_to_dir(node.param2))
	end

	local frontnode = get_node(front)
	local meta      = minetest.get_meta(pos)
	local oldnode   = meta:get_string("node_name")
	local oldp2     = meta:get_string("node_param2")
	local changed   = (oldnode == "" or initialize)
	              or not (frontnode.name == oldnode and tostring(frontnode.param2) == oldp2)

	if changed and node.name:find("_off$") then
		-- Only fire if we're currently in an _off variant
		if     node.name == "mcl_observers:observer_off"      then
			minetest.set_node(pos, { name="mcl_observers:observer_on",     param2=node.param2 })
			mesecon.receptor_on(pos, get_rules_flat(node))
		elseif node.name == "mcl_observers:observer_down_off" then
			minetest.set_node(pos, { name="mcl_observers:observer_down_on" })
			mesecon.receptor_on(pos, rules_down)
		elseif node.name == "mcl_observers:observer_up_off"   then
			minetest.set_node(pos, { name="mcl_observers:observer_up_on" })
			mesecon.receptor_on(pos, rules_up)
		end
	end

	if changed then
		meta:set_string("node_name",   frontnode.name)
		meta:set_string("node_param2", tostring(frontnode.param2))
	end

	return frontnode
end

-- Vertical placement helper
local function observer_orientate(pos, placer)
	if not placer then return end
	local pitch = placer:get_look_vertical() * (180 / math.pi)
	if pitch > 55  then
		minetest.set_node(pos, { name="mcl_observers:observer_down_off" })
	elseif pitch < -55 then
		minetest.set_node(pos, { name="mcl_observers:observer_up_off" })
	end
end

--------------------------------------------------------------------------------
-- NODE DEFINITIONS
--------------------------------------------------------------------------------

mesecon.register_node("mcl_observers:observer", {
	is_ground_content     = false,
	sounds                = mcl_sounds.node_sound_stone_defaults(),
	paramtype2            = "facedir",
	on_rotate             = false,
	_mcl_blast_resistance = 3,
	_mcl_hardness         = 3,
}, {
	description          = S("Observer"),
	_tt_help             = S("Emits redstone pulse when block in front changes"),
	_doc_items_longdesc  = S("An observer is a redstone component which observes the block in front of it and sends a very short redstone pulse whenever this block changes."),
	_doc_items_usagehelp = S("Place the observer directly in front of the block you want to observe with the “face” looking at the block. The arrow points to the side of the output, which is at the opposite side of the “face”. You can place your redstone dust or any other component here."),

	groups = { pickaxey=1, material_stone=1, not_opaque=1 },
	tiles  = {
		"mcl_observers_observer_top.png^[transformR180", "default_furnace_bottom.png",
		"mcl_observers_observer_side.png",             "mcl_observers_observer_side.png",
		"mcl_observers_observer_front.png",            "mcl_observers_observer_back.png",
	},
	mesecons = {
		receptor = {
			state = mesecon.state.off,
			rules = get_rules_flat,
		},
	},

	on_construct     = function(pos)
		if not realtime then observer_scan(pos, true) end
	end,
	after_place_node = observer_orientate,
}, {
	_doc_items_create_entry = false,
	groups = { pickaxey=1, material_stone=1, not_opaque=1, not_in_creative_inventory=1 },
	tiles  = {
		"mcl_observers_observer_top.png^[transformR180", "default_furnace_bottom.png",
		"mcl_observers_observer_side.png",             "mcl_observers_observer_side.png",
		"mcl_observers_observer_front.png",            "mcl_observers_observer_back_lit.png",
	},
	mesecons = {
		receptor = {
			state = mesecon.state.on,
			rules = get_rules_flat,
		},
	},

	-- Start a node-timer to flip back off after the pulse delay.
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(mcl_vars.redstone_tick)
	end,
	on_timer = function(pos)
		local n = get_node(pos)
		if     n.name == "mcl_observers:observer_on"      then
			minetest.set_node(pos, { name="mcl_observers:observer_off",     param2=n.param2 })
			mesecon.receptor_off(pos, get_rules_flat(n))
		elseif n.name == "mcl_observers:observer_down_on" then
			minetest.set_node(pos, { name="mcl_observers:observer_down_off" })
			mesecon.receptor_off(pos, rules_down)
		elseif n.name == "mcl_observers:observer_up_on"   then
			minetest.set_node(pos, { name="mcl_observers:observer_up_off" })
			mesecon.receptor_off(pos, rules_up)
		end
	end,
})

mesecon.register_node("mcl_observers:observer_down", {
	is_ground_content     = false,
	sounds                = mcl_sounds.node_sound_stone_defaults(),
	groups                = { pickaxey=1, material_stone=1, not_opaque=1, not_in_creative_inventory=1 },
	on_rotate             = false,
	_mcl_blast_resistance = 3,
	_mcl_hardness         = 3,
	drop                  = "mcl_observers:observer_off",
}, {
	tiles = {
		"mcl_observers_observer_back.png",      "mcl_observers_observer_front.png",
		"mcl_observers_observer_side.png^[transformR90","mcl_observers_observer_side.png^[transformR90",
		"mcl_observers_observer_top.png",       "mcl_observers_observer_top.png",
	},
	mesecons = {
		receptor = {
			state = mesecon.state.off,
			rules = rules_down,
		},
	},
	on_construct = function(pos)
		if not realtime then observer_scan(pos, true) end
	end,
}, {
	_doc_items_create_entry = false,
	tiles = {
		"mcl_observers_observer_back_lit.png",  "mcl_observers_observer_front.png",
		"mcl_observers_observer_side.png^[transformR90","mcl_observers_observer_side.png^[transformR90",
		"mcl_observers_observer_top.png",       "mcl_observers_observer_top.png",
	},
	mesecons = {
		receptor = {
			state = mesecon.state.on,
			rules = rules_down,
		},
	},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(mcl_vars.redstone_tick)
	end,
	on_timer = function(pos)
		local n = get_node(pos)
		minetest.set_node(pos, { name="mcl_observers:observer_down_off", param2=n.param2 })
		mesecon.receptor_off(pos, rules_down)
	end,
})

mesecon.register_node("mcl_observers:observer_up", {
	is_ground_content     = false,
	sounds                = mcl_sounds.node_sound_stone_defaults(),
	groups                = { pickaxey=1, material_stone=1, not_opaque=1, not_in_creative_inventory=1 },
	on_rotate             = false,
	_mcl_blast_resistance = 3,
	_mcl_hardness         = 3,
	drop                  = "mcl_observers:observer_off",
}, {
	tiles = {
		"mcl_observers_observer_front.png",            "mcl_observers_observer_back.png",
		"mcl_observers_observer_side.png^[transformR270","mcl_observers_observer_side.png^[transformR270",
		"mcl_observers_observer_top.png^[transformR180","mcl_observers_observer_top.png^[transformR180",
	},
	mesecons = {
		receptor = {
			state = mesecon.state.off,
			rules = rules_up,
		},
	},
	on_construct = function(pos)
		if not realtime then observer_scan(pos, true) end
	end,
}, {
	_doc_items_create_entry = false,
	tiles = {
		"mcl_observers_observer_front.png",            "mcl_observers_observer_back_lit.png",
		"mcl_observers_observer_side.png^[transformR270","mcl_observers_observer_side.png^[transformR270",
		"mcl_observers_observer_top.png^[transformR180","mcl_observers_observer_top.png^[transformR180",
	},
	mesecons = {
		receptor = {
			state = mesecon.state.on,
			rules = rules_up,
		},
	},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(mcl_vars.redstone_tick)
	end,
	on_timer = function(pos)
		minetest.set_node(pos, { name="mcl_observers:observer_up_off" })
		mesecon.receptor_off(pos, rules_up)
	end,
})

-- Craft recipes (unchanged)
minetest.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ "mcl_core:cobble","mcl_core:cobble","mcl_core:cobble" },
		{ "mcl_nether:quartz","mesecons:redstone","mesecons:redstone" },
		{ "mcl_core:cobble","mcl_core:cobble","mcl_core:cobble" },
	},
})
minetest.register_craft({
	output = "mcl_observers:observer_off",
	recipe = {
		{ "mcl_core:cobble","mcl_core:cobble","mcl_core:cobble" },
		{ "mesecons:redstone","mesecons:redstone","mcl_nether:quartz" },
		{ "mcl_core:cobble","mcl_core:cobble","mcl_core:cobble" },
	},
})

--------------------------------------------------------------------------------
-- REALTIME OVERRIDES (now only “notify neighbors”)
--------------------------------------------------------------------------------
if realtime then
	-- helper: test each neighbor for an observer facing this block
	local function notify_observers_of_change(pos)
		for _, o in ipairs({
			{ x= 1, y=0, z=0, axis="x", dir=-1, prefix="observer_o" },
			{ x=-1, y=0, z=0, axis="x", dir= 1, prefix="observer_o" },
			{ x=0, y=0, z= 1, axis="z", dir=-1, prefix="observer_o" },
			{ x=0, y=0, z=-1, axis="z", dir= 1, prefix="observer_o" },
			{ x=0, y= 1, z=0, prefix="observer_d" },
			{ x=0, y=-1, z=0, prefix="observer_u" },
		}) do
			local p = { x=pos.x+o.x, y=pos.y+o.y, z=pos.z+o.z }
			local n = get_node(p)
			if n and n.name:match("^mcl_observers:"..o.prefix) then
				if o.axis then
					local d = minetest.facedir_to_dir(n.param2)
					if d[o.axis] == o.dir then
						mcl_observers.observer_activate(p)
					end
				else
					mcl_observers.observer_activate(p)
				end
			end
		end
	end

	local old_add_node = minetest.add_node
	function minetest.add_node(pos, node)
		old_add_node(pos, node)
		notify_observers_of_change(pos)
	end

	local old_set_node      = minetest.set_node
	function minetest.set_node(pos, node)
		old_set_node(pos, node)
		notify_observers_of_change(pos)
	end

	local old_swap_node     = minetest.swap_node
	function minetest.swap_node(pos, node)
		old_swap_node(pos, node)
		notify_observers_of_change(pos)
	end

	local old_remove_node   = minetest.remove_node
	function minetest.remove_node(pos)
		old_remove_node(pos)
		notify_observers_of_change(pos)
	end

	local old_bulk_set_node = minetest.bulk_set_node
	function minetest.bulk_set_node(list, node)
		old_bulk_set_node(list, node)
		for _, p in ipairs(list) do notify_observers_of_change(p) end
	end
end

