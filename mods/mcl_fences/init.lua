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

mcl_fences = {}
mcl_fences.register_fence = function(id, fence_name, fence_gate_name, texture, fence_image, gate_image, groups, connects_to, sounds)
	if groups == nil then groups = {} end
	groups.fence = 1
	groups.deco_block = 1
	if connects_to == nil then connects_to = {} end
	table.insert(connects_to, "group:solid")
	table.insert(connects_to, "group:fence")
	local id_gate = id .. "_gate"
	minetest.register_node("mcl_fences:"..id, {
		description = fence_name,
		tiles = {texture},
		inventory_image = "mcl_fences_fence_mask.png^" .. texture .. "^mcl_fences_fence_mask.png^[makealpha:255,126,126",
		wield_image = "mcl_fences_fence_mask.png^" .. texture .. "^mcl_fences_fence_mask.png^[makealpha:255,126,126",
		paramtype = "light",
		is_ground_content = false,
		groups = groups,
		stack_max = 64,
		sunlight_propagates = true,
		drawtype = "nodebox",
		connect_sides = { "front", "back", "left", "right" },
		connects_to = connects_to,
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
		sounds = sounds,
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
			tmp_node2 = {name="mcl_fences:"..id_gate, param1=node.param1, param2=node.param2}
		else
			state2 = 1
			minetest.sound_play("door_open", {gain = 0.3, max_hear_distance = 10})
			tmp_node2 = {name="mcl_fences:"..id_gate.."_open", param1=node.param1, param2=node.param2}
		end
		update_gate(pos, tmp_node2)
		meta2:set_int("state", state2)
	end

	groups.mesecon_effector_on = 1
	minetest.register_node("mcl_fences:"..id_gate.."_open", {
		tiles = {texture},
		paramtype = "light",
		paramtype2 = "facedir",
		inventory_image = "mcl_fences_fence_gate_mask.png^" .. texture .. "^mcl_fences_fence_gate_mask.png^[makealpha:255,126,126",
		wield_image = "mcl_fences_fence_gate_mask.png^" .. texture .. "^mcl_fences_fence_gate_mask.png^[makealpha:255,126,126",
		is_ground_content = false,
		sunlight_propagates = true,
		walkable = true,
		groups = groups,
		drop = 'mcl_fences:fence_gate',
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
		on_rightclick = function(pos, node, clicker)
			punch_gate(pos, node)
		end,
		mesecons = {effector = {
			action_on = (function(pos, node)
				punch_gate(pos, node)
			end),
		}},
		sounds = sounds,
	})

	groups.mesecon_effector_on = nil
	groups.mesecon_effector_off = nil
	minetest.register_node("mcl_fences:"..id_gate, {
		description = fence_gate_name,
		tiles = {texture},
		inventory_image = "mcl_fences_fence_gate_mask.png^" .. texture .. "^mcl_fences_fence_gate_mask.png^[makealpha:255,126,126",
		wield_image = "mcl_fences_fence_gate_mask.png^" .. texture .. "^mcl_fences_fence_gate_mask.png^[makealpha:255,126,126",
		paramtype = "light",
		is_ground_content = false,
		stack_max = 64,
		paramtype2 = "facedir",
		sunlight_propagates = true,
		walkable = true,
		groups = groups,
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
			}
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-1/2, -1/2+5/16, -2/16, 1/2, 1, 2/16},   --gate
			}
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-1/2, -1/2+5/16, -1/16, 1/2, 1/2, 1/16},   --gate
			}
		},
		on_construct = function(pos)
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
		sounds = sounds,
	})

end

local wood_groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fence_wood=1}
local wood_connect = {}
local wood_sounds = mcl_core.node_sound_wood_defaults()

local woods = {
	{"", "Oak Fence", "Oak Fence Gate", "default_wood.png", "default_fence.png", "mcl_fences_fence_gate.png", "mcl_core:wood"},
	{"spruce", "Spruce Fence", "Spruce Fence Gate", "default_sprucewood.png", "default_fence.png", "mcl_fences_fence_gate.png", "mcl_core:sprucewood"},
	{"birch", "Birch Fence", "Birch Fence Gate", "default_planks_birch.png", "default_fence.png", "mcl_fences_fence_gate.png", "mcl_core:birchwood"},
	{"jungle", "Jungle Fence", "Jungle Fence Gate", "default_junglewood.png", "default_fence.png", "mcl_fences_fence_gate.png", "mcl_core:junglewood"},
	{"dark_oak", "Dark Oak Fence", "Dark Oak Fence Gate", "default_planks_big_oak.png", "default_fence.png", "mcl_fences_fence_gate.png", "mcl_core:darkwood"},
	{"acacia", "Acacia Fence", "Acacia Fence Gate", "default_acaciawood.png", "default_fence.png", "mcl_fences_fence_gate.png", "mcl_core:acaciawood"},
}

for w=1, #woods do
	local wood = woods[w]
	local id, id_gate
	if wood[1] == "" then
		id = "fence"
		id_gate = "fence_gate"
	else
		id = wood[1].."_fence"
		id_gate = wood[1].."_fence_gate"
	end
	mcl_fences.register_fence(id, wood[2], wood[3], wood[4], wood[5], wood[6], wood_groups, wood_connect, wood_sounds)

	minetest.register_craft({
		output = 'mcl_fences:'..id..' 3',
		recipe = {
			{wood[7], 'mcl_core:stick', wood[7]},
			{wood[7], 'mcl_core:stick', wood[7]},
		}
	})
	minetest.register_craft({
		output = 'mcl_fences:'..id_gate,
		recipe = {
			{'mcl_core:stick', wood[7], 'mcl_core:stick'},
			{'mcl_core:stick', wood[7], 'mcl_core:stick'},
		}
	})
end

minetest.register_craft({
	type = "fuel",
	recipe = "group:fence_wood",
	burntime = 15,
})

local time_to_load= os.clock() - init
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))


