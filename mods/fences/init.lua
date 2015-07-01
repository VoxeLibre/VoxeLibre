local override_original = true  --change to "true" if you want original and placed fences replaced

local function dockable(nodename)
    if nodename == "default:wood" or string.find(nodename, "wallet:wall") or nodename == "default:brick" or nodename == "default:cobble" or nodename == "default:dirt" or nodename == "default:sandstone" or nodename == "default:stone" or string.find(nodename, "fences:fence_wood") or string.find(nodename, "fences:fencegate") then
        return true
    end
end


local function find_dock(pos, second)
	if pos == nil then
		return false
	end

	local h1 = minetest.env:get_node({x=pos.x+1, y=pos.y, z=pos.z})
	local v1 = minetest.env:get_node({x=pos.x-1, y=pos.y, z=pos.z})
	local r1 = minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z+1})
	local l1 = minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z-1})
	local code = 0
	if dockable(l1.name) then
		code = code+1
		if second < 2 then
			minetest.env:punch_node({x=pos.x, y=pos.y, z=pos.z-1})
		end
	end
	if dockable(r1.name) then
		code = code+2
		if second < 2 then
			minetest.env:punch_node({x=pos.x, y=pos.y, z=pos.z+1})
		end
	end
	if dockable(v1.name) then
		code = code+11
		if second < 2 then
			minetest.env:punch_node({x=pos.x-1, y=pos.y, z=pos.z})
		end
	end
	if dockable(h1.name) then
		code = code+21
		if second < 2 then
			minetest.env:punch_node({x=pos.x+1, y=pos.y, z=pos.z})
		end
	end
		local me = minetest.env:get_node(pos)
		if code > 0 then
			local tmp_name = "fences:fence_wood_"..code
			local tmp_node = {name=tmp_name, param1=me.param1, param2=me.param2}
			if second > 0 then
				local tmp_node = {name=tmp_name, param1=me.param1, param2=me.param2}
				minetest.env:set_node(pos, tmp_node)			
			end
		elseif code == 0 then
			if second == 2 then
				local tmp_node = {name="fences:fence_wood", param1=me.param1, param2=me.param2}
				minetest.env:set_node(pos, tmp_node)			
			end
		end
	
end

local function punch(pos, puncher)
	if not puncher ~= '' then
		find_dock(pos, 2)
	elseif not puncher:is_player() then
		find_dock(pos, 2)
	end
end


local p0 = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16}
local p1 = {-2/16, 1/2, -2/16, -2/16, 1/2+8/16, -2/16}
local p2 = {-2/16, 1/2, 2/16, -2/16, 1/2+8/16, 2/16}
local p3 = {-2/16, 1/2, 2/16, -2/16, 1/2+8/16, 2/16}
local p4 = {2/16, 1/2, -2/16, 2/16, 1/2+8/16, -2/16}
local p5 = {2/16, 1/2, 2/16, 2/16, 1/2+8/16, 2/16}

local x1 = {-2/16, 1/2-4/16, 1/16, -1/2, 1/2-1/16, -1/16}   --oben(quer) -x
local x12 = {-2/16, -1/2+6/16, 1/16, -1/2, -1/2+9/16, -1/16} --unten(quer) -x
local x2 = {2/16, 1/2-4/16, -1/16, 1/2, 1/2-1/16, 1/16}   --oben(quer) x
local x22 = {2/16, -1/2+6/16, -1/16, 1/2, -1/2+9/16, 1/16} --unten(quer) x
local z1 = {1/16, 1/2-4/16, -2/16, -1/16, 1/2-1/16, -1/2}   --oben(quer) -z
local z12 = {1/16, -1/2+6/16, -2/16, -1/16, -1/2+9/16, -1/2} --unten(quer) -z
local z2 = {-1/16, 1/2-4/16, 2/16, 1/16, 1/2-1/16, 1/2}   --oben(quer) z
local z22 = {-1/16, -1/2+6/16, 2/16, 1/16, -1/2+9/16, 1/2} --unten(quer) z

local bz1 = {1/16, 1/2-1/16, -6/16, 1/16, 1/2+8/16, -6/16}   --oben_block(quer) -z 1seite
local bz11 = {-1/16, 1/2-1/16, -6/16, -1/16, 1/2+8/16, -6/16}   --oben_block(quer) -z 2seite
local bz2 = {1/16, 1/2-1/16, 5/16, 1/16, 1/2+8/16, 5/16}   --oben_block(quer) z 1seite
local bz21 = {-1/16, 1/2-1/16, 5/16, -1/16, 1/2+8/16, 5/16}   --oben_block(quer) z 2seite

local bx1 = {-6/16, 1/2-1/16, 1/16, -6/16, 1/2+8/16, 1/16}   --oben_block(quer) -x 1seite
local bx11 = {-6/16, 1/2-1/16, -1/16, -6/16, 1/2+8/16, -1/16}   --oben_block(quer) -x 2seite
local bx2 = {5/16, 1/2-1/16, 1/16, 5/16, 1/2+8/16, 1/16}   --oben_block(quer) x 1seite
local bx21 = {5/16, 1/2-1/16, -1/16, 5/16, 1/2+8/16, -1/16}   --oben_block(quer) x 2seite


minetest.register_node("fences:fence_wood", {
	description = "Wooden Fence",
	tiles = {"default_wood.png"},
	inventory_image = "default_fence.png",
	wield_image = "default_fence.png",
	paramtype = "light",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fences=1},
	drop = 'fences:fence_wood',
	stack_max = 64,
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {p0,p1,p2,p3,p4,p5,}
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16},
	},
	on_construct = function(pos)
		find_dock(pos, 1)
	end,
	on_punch = function(pos, puncher)
		punch(pos, puncher)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})



--different fence types- (1=left,2=right,3=top,4=bottom)

minetest.register_node("fences:fence_wood_1", {
	tiles = {"default_wood.png"},
	paramtype = "light",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fences=1,not_in_inventory=1},
	drop = 'fences:fence_wood',
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				p0,p1,p2,p3,p4,p5,
				z1,z12,
				bz1,bz11,
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16},
	},
	on_punch = function(pos, puncher)
		punch(pos, puncher)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})

minetest.register_node("fences:fence_wood_2", {
	tiles = {"default_wood.png"},
	paramtype = "light",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fences=1,not_in_inventory=1},
	drop = 'fences:fence_wood',
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				p0,p1,p2,p3,p4,p5,
				z2,z22,
				bz2,bz21,
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16},
	},
	on_punch = function(pos, puncher)
		punch(pos, puncher)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})

minetest.register_node("fences:fence_wood_3", {  --left+right(3)
	tiles = {"default_wood.png"},
	paramtype = "light",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fences=1,not_in_inventory=1},
	drop = 'fences:fence_wood',
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				p0,p1,p2,p3,p4,p5,
				z1,z12,z2,z22,
				bz1,bz11,bz2,bz21,
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16},
	},
	on_punch = function(pos, puncher)
		punch(pos, puncher)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})

minetest.register_node("fences:fence_wood_11", {  --top
	tiles = {"default_wood.png"},
	paramtype = "light",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fences=1,not_in_inventory=1},
	drop = 'fences:fence_wood',
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				p0,p1,p2,p3,p4,p5,
				x1,x12,
				bx1,bx11,
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16},
	},
	on_punch = function(pos, puncher)
		punch(pos, puncher)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})

minetest.register_node("fences:fence_wood_21", {  --bottom
	tiles = {"default_wood.png"},
	paramtype = "light",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fences=1,not_in_inventory=1},
	drop = 'fences:fence_wood',
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				p0,p1,p2,p3,p4,p5,
				x2,x22,
				bx2,bx21,
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16},
	},
	on_punch = function(pos, puncher)
		punch(pos, puncher)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})


minetest.register_node("fences:fence_wood_32", {  --top+bottom(32)
	tiles = {"default_wood.png"},
	paramtype = "light",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fences=1,not_in_inventory=1},
	drop = 'fences:fence_wood',
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				p0,p1,p2,p3,p4,p5,
				x1,x12,x2,x22,
				bx1,bx11,bx2,bx21,
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16},
	},
	on_punch = function(pos, puncher)
		punch(pos, puncher)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})

minetest.register_node("fences:fence_wood_14", {  --left+right(3)+ top(11) =14
	tiles = {"default_wood.png"},
	paramtype = "light",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fences=1,not_in_inventory=1},
	drop = 'fences:fence_wood',
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				p0,p1,p2,p3,p4,p5,
				z1,z12,z2,z22,x1,x12,
				bz1,bz11,bz2,bz21,bx1,bx11,
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16},
	},
	on_punch = function(pos, puncher)
		punch(pos, puncher)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})

minetest.register_node("fences:fence_wood_24", {  --left+right(3)+ bottom(21) =24
	tiles = {"default_wood.png"},
	paramtype = "light",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fences=1,not_in_inventory=1},
	drop = 'fences:fence_wood',
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				p0,p1,p2,p3,p4,p5,
				z1,z12,z2,z22,x2,x22,
				bz1,bz11,bz2,bz21,bx2,bx21,
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16},
	},
	on_punch = function(pos, puncher)
		punch(pos, puncher)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})

minetest.register_node("fences:fence_wood_35", {  --left+right(3)+top+bottom(32) = 35
	tiles = {"default_wood.png"},
	paramtype = "light",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fences=1,not_in_inventory=1},
	drop = 'fences:fence_wood',
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				p0,p1,p2,p3,p4,p5,
				x1,x12,x2,x22,z1,z12,z2,z22,
				bz1,bz11,bz2,bz21,bx1,bx11,bx2,bx21,
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16},
	},
	on_punch = function(pos, puncher)
		punch(pos, puncher)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})

minetest.register_node("fences:fence_wood_12", {  --left(1)+top(11)=12
	tiles = {"default_wood.png"},
	paramtype = "light",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fences=1,not_in_inventory=1},
	drop = 'fences:fence_wood',
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				p0,p1,p2,p3,p4,p5,
				z1,z12,x1,x12,
				bz1,bz11,bx1,bx11,
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16},
	},
	on_punch = function(pos, puncher)
		punch(pos, puncher)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})

minetest.register_node("fences:fence_wood_22", {  --left(1)+bottom(21)=22
	tiles = {"default_wood.png"},
	paramtype = "light",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fences=1,not_in_inventory=1},
	drop = 'fences:fence_wood',
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				p0,p1,p2,p3,p4,p5,
				z1,z12,x2,x22,
				bz1,bz11,bx2,bx21,
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16},
	},
	on_punch = function(pos, puncher)
		punch(pos, puncher)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})

minetest.register_node("fences:fence_wood_33", {  --left(1)+top+bottom(32)=33
	tiles = {"default_wood.png"},
	paramtype = "light",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fences=1,not_in_inventory=1},
	drop = 'fences:fence_wood',
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				p0,p1,p2,p3,p4,p5,
				z1,z12,x1,x12,x2,x22,
				bz1,bz11,bx1,bx11,bx2,bx21,
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16},
	},
	on_punch = function(pos, puncher)
		punch(pos, puncher)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})

minetest.register_node("fences:fence_wood_34", {  --right(2)+top+bottom(32)=34
	tiles = {"default_wood.png"},
	paramtype = "light",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fences=1,not_in_inventory=1},
	drop = 'fences:fence_wood',
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				p0,p1,p2,p3,p4,p5,
				z2,z22,x1,x12,x2,x22,
				bz2,bz21,bx1,bx11,bx2,bx21,
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16},
	},
	on_punch = function(pos, puncher)
		punch(pos, puncher)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})

minetest.register_node("fences:fence_wood_23", {  --right(2)+bottom(21)=23
	tiles = {"default_wood.png"},
	paramtype = "light",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fences=1,not_in_inventory=1},
	drop = 'fences:fence_wood',
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				p0,p1,p2,p3,p4,p5,
				z2,z22,x2,x22,
				bz2,bz21,bx2,bx21,
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16},
	},
	on_punch = function(pos, puncher)
		punch(pos, puncher)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})

minetest.register_node("fences:fence_wood_13", {  --right(2)+top(11)=13
	tiles = {"default_wood.png"},
	paramtype = "light",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fences=1,not_in_inventory=1},
	drop = 'fences:fence_wood',
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				p0,p1,p2,p3,p4,p5,
				z2,z22,x1,x12,
				bz1,bz11,bx1,bx11,
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16},
	},
	on_punch = function(pos, puncher)
		punch(pos, puncher)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})

minetest.register_alias("default:fence_wood", "fences:fence")

minetest.register_craft({
	output = 'fences:fence_wood 2',
	recipe = {
		{'default:stick', 'default:stick', 'default:stick'},
		{'default:stick', 'default:stick', 'default:stick'},
	}
})

minetest.register_craft({
	output = 'fences:fencegate',
	recipe = {
		{'default:stick', 'default:wood', 'default:stick'},
		{'default:stick', 'default:wood', 'default:stick'},
	}
})




local meta2
local state2 = 0

local function update_gate(pos, node) 
	minetest.env:set_node(pos, node)
end

local function punch_gate(pos, node)
	meta2 = minetest.env:get_meta(pos)
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
	sunlight_propagates = true,
	walkable = true,
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,fences=1,not_in_inventory=1,mesecon_effector_on=1},
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
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})

minetest.register_node("fences:fencegate", {
	description = "Wooden Fancegate",
	tiles = {"default_wood.png"},
	inventory_image = "fences_fencegate.png",
	wield_image = "fences_fencegate.png",
	paramtype = "light",
	stack_max = 16,
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = true,
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=2,mesecon_effector_on=1,fences=1},
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
		me2 = minetest.env:get_node(pos)
		meta2 = minetest.env:get_meta(pos)
		meta2:set_int("state", 0)
		state2 = 0
		find_dock(pos, -1)
	end,
	mesecons = {effector = {
	action_on = (function(pos, node)
		punch_gate(pos, node)
	end),
	}},
	on_rightclick = function(pos, node, clicker)
		punch_gate(pos, node)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		find_dock(pos, -1)
	end
})


if override_original == true then
	minetest.register_abm({
		nodenames = {"default:fence_wood"},
		interval = 1.0,
		chance = 1,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local tmp_node3 = {name="fences:fence_wood"}
			minetest.env:set_node(pos, tmp_node3)
			minetest.env:punch_node(pos)
		end
	})
end
