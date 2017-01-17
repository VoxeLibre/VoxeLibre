local init = os.clock()

-- Node box
local p = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16}
local x1 = {-2/16, 1/2-4/16, 1/16, -1/2, 1/2-1/16, -1/16}   --oben(quer) -x
local x12 = {-2/16, -1/2+6/16, 1/16, -1/2, -1/2+9/16, -1/16} --unten(quer) -x
local x2 = {2/16, 1/2-4/16, -1/16, 1/2, 1/2-1/16, 1/16}   --oben(quer) x
local x22 = {2/16, -1/2+6/16, -1/16, 1/2, -1/2+9/16, 1/16} --unten(quer) x
local z1 = {1/16, 1/2-4/16, -2/16, -1/16, 1/2-1/16, -1/2}   --oben(quer) -z
local z12 = {1/16, -1/2+6/16, -2/16, -1/16, -1/2+9/16, -1/2} --unten(quer) -z
local z2 = {-1/16, 1/2-4/16, 2/16, 1/16, 1/2-1/16, 1/2}   --oben(quer) z
local z22 = {-1/16, -1/2+6/16, 2/16, 1/16, -1/2+9/16, 1/2} --unten(quer) z

-- Collision box
local cp = {-2/16, -1/2, -2/16, 2/16, 1, 2/16}
local cx1 = {-2/16, -1/2+6/16, 2/16, -1/2, 1, -2/16} --unten(quer) -x
local cx2 = {2/16, -1/2+6/16, -2/16, 1/2, 1, 2/16} --unten(quer) x
local cz1 = {2/16, -1/2+6/16, -2/16, -2/16, 1, -1/2} --unten(quer) -z
local cz2 = {-2/16, -1/2+6/16, 2/16, 2/16, 1, 1/2} --unten(quer) z

minetest.register_node("fences:fence_wood", {
	description = "Oak Fence",
	tiles = {"default_wood.png"},
	inventory_image = "default_fence.png",
	wield_image = "default_fence.png",
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fence=1},
	drop = 'fences:fence_wood',
	stack_max = 64,
	sunlight_propagates = true,
	drawtype = "nodebox",
	connect_sides = { "front", "back", "left", "right" },
	connects_to = { "group:solid", "group:fence" },
	node_box = {
		type = "connected",
		fixed = {p},
		connect_front = {z1,z12},
		connect_back = {z2,z22,},
		connect_left = {x1,x12},
		connect_right = {x2,x22},
	},
	collision_box = {
		type = "connected",
		fixed = {cp},
		connect_front = {cz1},
		connect_back = {cz2,},
		connect_left = {cx1},
		connect_right = {cx2},
	},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = 'fences:fence_wood 3',
	recipe = {
		{'default:wood', 'default:stick', 'default:wood'},
		{'default:wood', 'default:stick', 'default:wood'},
	}
})

minetest.register_craft({
	output = 'fences:fencegate',
	recipe = {
		{'default:stick', 'default:wood', 'default:stick'},
		{'default:stick', 'default:wood', 'default:stick'},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "fences:fence_wood",
	burntime = 15,
})
minetest.register_craft({
	type = "fuel",
	recipe = "fences:fencegate",
	burntime = 15,
})

local meta2
local state2 = 0

local function update_gate(pos, node) 
	minetest.set_node(pos, node)
end

local function punch_gate(pos, node)
	meta2 = minetest.get_meta(pos)
	state2 = meta2:get_int("state")
	local tmp_node2
		if state2 == 1 then
			state2 = 0
			minetest.sound_play("door_close", {gain = 0.3, max_hear_distance = 10})
			tmp_node2 = {name="fences:fencegate", param1=node.param1, param2=node.param2}
		else
			state2 = 1
			minetest.sound_play("door_open", {gain = 0.3, max_hear_distance = 10})
			tmp_node2 = {name="fences:fencegate_open", param1=node.param1, param2=node.param2}
		end
		update_gate(pos, tmp_node2)
		meta2:set_int("state", state2)
end

minetest.register_node("fences:fencegate_open", {
	tiles = {"default_wood.png"},
	inventory_image = "default_fence.png",
	wield_image = "default_fence.png",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = true,
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fence=1,not_in_inventory=1,mesecon_effector_on=1},
	drop = 'fences:fencegate',
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				{-1/2, -1/2+5/16, -1/16, -1/2+2/16, 1/2, 1/16},   --links abschluss
				{1/2-2/16, -1/2+5/16, -1/16, 1/2, 1/2, 1/16},   --rechts abschluss
				{-1/2, 1/2-4/16, 1/16, -1/2+2/16, 1/2-1/16, 1/2-2/16},   --oben-links(quer) x
				{-1/2, -1/2+6/16, 1/16, -1/2+2/16, -1/2+9/16, 1/2-2/16}, --unten-links(quer) x
				{1/2-2/16, 1/2-4/16, 1/16, 1/2, 1/2-1/16, 1/2},   --oben-rechts(quer) x
				{1/2-2/16, -1/2+6/16, 1/16, 1/2, -1/2+9/16, 1/2}, --unten-rechts(quer) x
				{-1/2, -1/2+6/16, 6/16, -1/2+2/16, 1/2-1/16, 1/2},  --mitte links
				{1/2-2/16, 1/2-4/16, 1/2, 1/2, -1/2+9/16, 6/16},  --mitte rechts
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {
				{-1/2, -1/2+5/16, -1/16, 1/2, 1/2, 1/16},   --gate
			}
	},
	--on_punch = function(pos, node, puncher)
	on_rightclick = function(pos, node, clicker)
		punch_gate(pos, node)
	end,
	mesecons = {effector = {
	action_on = (function(pos, node)
		punch_gate(pos, node)
	end),
	}},
})

minetest.register_node("fences:fencegate", {
	description = "Oak Fence Gate",
	tiles = {"default_wood.png"},
	inventory_image = "fences_fencegate.png",
	wield_image = "fences_fencegate.png",
	paramtype = "light",
	is_ground_content = false,
	stack_max = 16,
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = true,
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,mesecon_effector_on=1,fence=1},
	drop = 'fences:fencegate',
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				{-1/2, -1/2+5/16, -1/16, -1/2+2/16, 1/2, 1/16},   --links abschluss
				{1/2-2/16, -1/2+5/16, -1/16, 1/2, 1/2, 1/16},   --rechts abschluss
				{-2/16, -1/2+6/16, -1/16, 0, 1/2-1/16, 1/16},  --mitte links
				{0, -1/2+6/16, -1/16, 2/16, 1/2-1/16, 1/16},  --mitte rechts
				{-2/16, 1/2-4/16, 1/16, -1/2, 1/2-1/16, -1/16},   --oben(quer) -z
				{-2/16, -1/2+6/16, 1/16, -1/2, -1/2+9/16, -1/16}, --unten(quer) -z
				{2/16, 1/2-4/16, -1/16, 1/2, 1/2-1/16, 1/16},   --oben(quer) z
				{2/16, -1/2+6/16, -1/16, 1/2, -1/2+9/16, 1/16}, --unten(quer) z
				p1,p2,p3,p4,p5,
				bx1,bx11,bx2,bx21,
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {
				{-1/2, -1/2+5/16, -1/16, 1/2, 1/2, 1/16},   --gate
			}
	},
	on_construct = function(pos)
		me2 = minetest.get_node(pos)
		meta2 = minetest.get_meta(pos)
		meta2:set_int("state", 0)
		state2 = 0
	end,
	mesecons = {effector = {
	action_on = (function(pos, node)
		punch_gate(pos, node)
	end),
	}},
	on_rightclick = function(pos, node, clicker)
		punch_gate(pos, node)
	end,
})

local time_to_load= os.clock() - init
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))
