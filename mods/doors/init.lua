local init = os.clock()
doors = {}

-- Registers a door
--  name: The name of the door
--  def: a table with the folowing fields:
--    description
--    inventory_image
--    groups
--    tiles_bottom: the tiles of the bottom part of the door {front, side}
--    tiles_top: the tiles of the bottom part of the door {front, side}
--    If the following fields are not defined the default values are used
--    node_box_bottom
--    node_box_top
--    selection_box_bottom
--    selection_box_top
--    only_placer_can_open: if true only the player who placed the door can
--                          open it

local function is_right(pos, clicker) 
	local r1 = minetest.get_node({x=pos.x+1, y=pos.y, z=pos.z})
	local r2 = minetest.get_node({x=pos.x, y=pos.y, z=pos.z+1})
	if string.find(r1.name, "door_") or string.find(r2.name, "door_") then
		return true
	else
		return false
	end
end

function doors:register_door(name, def)
	def.groups.not_in_creative_inventory = 1
	
	local box = {{-8/16, -8/16, -8/16, 8/16, 8/16, -6.5/16}}
	
	if not def.node_box_bottom then
		def.node_box_bottom = box
	end
	if not def.node_box_top then
		def.node_box_top = box
	end
	if not def.selection_box_bottom then
		def.selection_box_bottom= box
	end
	if not def.selection_box_top then
		def.selection_box_top = box
	end
	
	minetest.register_craftitem(name, {
		description = def.description,
		inventory_image = def.inventory_image,
		stack_max = 64,
		on_place = function(itemstack, placer, pointed_thing)
			if not pointed_thing.type == "node" then
				return itemstack
			end
			local pn = placer:get_player_name()
				if minetest.is_protected(pointed_thing.above, pn) and minetest.is_protected(pointed_thing.under, pn) then
					return itemstack
				end
					local ptu = pointed_thing.under
					local nu = minetest.get_node(ptu)
					if minetest.registered_nodes[nu.name].on_rightclick then
						return minetest.registered_nodes[nu.name].on_rightclick(ptu, nu, placer, itemstack)
					end
					
					local pt = pointed_thing.above
					local pt2 = {x=pt.x, y=pt.y, z=pt.z}
					pt2.y = pt2.y+1
					if
						not minetest.registered_nodes[minetest.get_node(pt).name].buildable_to or
						not minetest.registered_nodes[minetest.get_node(pt2).name].buildable_to or
						not placer or
						not placer:is_player()
					then
						return itemstack
					end
					
					local p2 = minetest.dir_to_facedir(placer:get_look_dir())
					local pt3 = {x=pt.x, y=pt.y, z=pt.z}
					if p2 == 0 then
						pt3.x = pt3.x-1
					elseif p2 == 1 then
						pt3.z = pt3.z+1
					elseif p2 == 2 then
						pt3.x = pt3.x+1
					elseif p2 == 3 then
						pt3.z = pt3.z-1
					end
					if not string.find(minetest.get_node(pt3).name, name.."_b_") then
						minetest.set_node(pt, {name=name.."_b_1", param2=p2})
						minetest.set_node(pt2, {name=name.."_t_1", param2=p2})
					else
						minetest.set_node(pt, {name=name.."_b_2", param2=p2})
						minetest.set_node(pt2, {name=name.."_t_2", param2=p2})
					end
					
					if def.only_placer_can_open then
						local pn = placer:get_player_name()
						local meta = minetest.get_meta(pt)
						meta:set_string("doors_owner", "")
						--meta:set_string("infotext", "Owned by "..pn)
						meta = minetest.get_meta(pt2)
						meta:set_string("doors_owner", "")
						--meta:set_string("infotext", "Owned by "..pn)
					end
					
					if not minetest.setting_getbool("creative_mode") then
						itemstack:take_item()
					end
				return itemstack
		end,
	})
	
	local tt = def.tiles_top
	local tb = def.tiles_bottom
	
	local function after_dig_node(pos, name, digger)
		local node = minetest.get_node(pos)
		if node.name == name then
			minetest.node_dig(pos, node, digger)
		end
	end
	
	local function on_rightclick(pos, dir, check_name, replace, replace_dir, params)
		pos.y = pos.y+dir
		if not minetest.get_node(pos).name == check_name then
			return
		end
		local p2 = minetest.get_node(pos).param2
		p2 = params[p2+1]
		
		local meta = minetest.get_meta(pos):to_table()
		minetest.set_node(pos, {name=replace_dir, param2=p2})
		minetest.get_meta(pos):from_table(meta)
		
		pos.y = pos.y-dir
		meta = minetest.get_meta(pos):to_table()
		minetest.set_node(pos, {name=replace, param2=p2})
		minetest.get_meta(pos):from_table(meta)
	end
	
	local function check_player_priv(pos, player)
		if not def.only_placer_can_open then
			return true
		end
		local meta = minetest.get_meta(pos)
		local pn = player:get_player_name()
		return meta:get_string("doors_owner") == pn
	end
	
	minetest.register_node(name.."_b_1", {
		tiles = {tb[2], tb[2], tb[2], tb[2], tb[1], tb[1].."^[transformfx"},
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		drop = name,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_bottom
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_bottom
		},
		groups = def.groups,
		
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y+1
			after_dig_node(pos, name.."_t_1", digger)
		end,
		
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
			on_rightclick(pos, 1, name.."_t_1", name.."_b_2", name.."_t_2", {1,2,3,0})
				if is_right(pos, clicker) then
					minetest.sound_play("door_close", {pos = pos, gain = 0.3, max_hear_distance = 10})					
				else
					minetest.sound_play("door_open", {pos = pos, gain = 0.3, max_hear_distance = 10})
				end
			end
		end,
		
		can_dig = check_player_priv,
	})
	
	minetest.register_node(name.."_t_1", {
		tiles = {tt[2], tt[2], tt[2], tt[2], tt[1], tt[1].."^[transformfx"},
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		drop = "",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_top
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_top
		},
		groups = def.groups,
		
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y-1
			after_dig_node(pos, name.."_b_1", digger)
		end,
		
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_rightclick(pos, -1, name.."_b_1", name.."_t_2", name.."_b_2", {1,2,3,0})
				if is_right(pos, clicker) then
					minetest.sound_play("door_close", {pos = pos, gain = 0.3, max_hear_distance = 10})					
				else
					minetest.sound_play("door_open", {pos = pos, gain = 0.3, max_hear_distance = 10})
				end
			end
		end,
		
		can_dig = check_player_priv,
	})
	
	minetest.register_node(name.."_b_2", {
		tiles = {tb[2], tb[2], tb[2], tb[2], tb[1].."^[transformfx", tb[1]},
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		drop = name,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_bottom
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_bottom
		},
		groups = def.groups,
		
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y+1
			after_dig_node(pos, name.."_t_2", digger)
		end,
		
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_rightclick(pos, 1, name.."_t_2", name.."_b_1", name.."_t_1", {3,0,1,2})
				if is_right(pos, clicker) then
					minetest.sound_play("door_open", {gain = 0.3, max_hear_distance = 10})					
				else
					minetest.sound_play("door_close", {gain = 0.3, max_hear_distance = 10})
				end
			end
		end,
		
		can_dig = check_player_priv,
	})
	
	minetest.register_node(name.."_t_2", {
		tiles = {tt[2], tt[2], tt[2], tt[2], tt[1].."^[transformfx", tt[1]},
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		drop = "",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = def.node_box_top
		},
		selection_box = {
			type = "fixed",
			fixed = def.selection_box_top
		},
		groups = def.groups,
		
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			pos.y = pos.y-1
			after_dig_node(pos, name.."_b_2", digger)
		end,
		
		on_rightclick = function(pos, node, clicker)
			if check_player_priv(pos, clicker) then
				on_rightclick(pos, -1, name.."_b_2", name.."_t_1", name.."_b_1", {3,0,1,2})
				if is_right(pos, clicker) then
					minetest.sound_play("door_open", {pos=pos, gain = 0.3, max_hear_distance = 10})					
				else
					minetest.sound_play("door_close", {gain = 0.3, max_hear_distance = 10})
				end
			end
		end,
		
		can_dig = check_player_priv,
	})
	
end

--- Normal Door ---
doors:register_door("doors:door_wood", {
	description = "Oak Door",
	inventory_image = "door_wood.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,door=1},
	tiles_bottom = {"door_wood_b.png", "door_brown.png"},
	tiles_top = {"door_wood_a.png", "door_brown.png"},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "doors:door_wood 3",
	recipe = {
		{"mcl_core:wood", "mcl_core:wood"},
		{"mcl_core:wood", "mcl_core:wood"},
		{"mcl_core:wood", "mcl_core:wood"}
	}
})

--- Accacia Door --
doors:register_door("doors:door_acacia", {
	description = "Acacia Door",
	inventory_image = "door_acacia.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,door=1},
	tiles_bottom = {"door_acacia_b.png", "door_brown.png"},
	tiles_top = {"door_acacia_a.png", "door_brown.png"},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "doors:door_acacia 3",
	recipe = {
		{"mcl_core:acaciawood", "mcl_core:acaciawood"},
		{"mcl_core:acaciawood", "mcl_core:acaciawood"},
		{"mcl_core:acaciawood", "mcl_core:acaciawood"}
	}
})

--- birch Door --
doors:register_door("doors:door_birch", {
	description = "Birch Door",
	inventory_image = "door_birch.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,door=1},
	tiles_bottom = {"door_birch_b.png", "door_brown.png"},
	tiles_top = {"door_birch_a.png", "door_brown.png"},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "doors:door_birch 3",
	recipe = {
		{"mcl_core:birchwood", "mcl_core:birchwood"},
		{"mcl_core:birchwood", "mcl_core:birchwood"},
		{"mcl_core:birchwood", "mcl_core:birchwood"},
	}
})

--- dark oak Door --
doors:register_door("doors:door_dark_oak", {
	description = "Dark Oak Door",
	inventory_image = "door_dark_oak.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,door=1},
	tiles_bottom = {"door_dark_oak_b.png", "door_brown.png"},
	tiles_top = {"door_dark_oak_a.png", "door_brown.png"},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "doors:door_dark_oak 3",
	recipe = {
		{"mcl_core:darkwood", "mcl_core:darkwood"},
		{"mcl_core:darkwood", "mcl_core:darkwood"},
		{"mcl_core:darkwood", "mcl_core:darkwood"},
	}
})

--- jungle Door --
doors:register_door("doors:door_jungle", {
	description = "Jungle Door",
	inventory_image = "door_jungle.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,door=1},
	tiles_bottom = {"door_jungle_b.png", "door_brown.png"},
	tiles_top = {"door_jungle_a.png", "door_brown.png"},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "doors:door_jungle 3",
	recipe = {
		{"mcl_core:junglewood", "mcl_core:junglewood"},
		{"mcl_core:junglewood", "mcl_core:junglewood"},
		{"mcl_core:junglewood", "mcl_core:junglewood"}
	}
})

--- spruce Door --
doors:register_door("doors:door_spruce", {
	description = "Spruce Door",
	inventory_image = "door_spruce.png",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,door=1},
	tiles_bottom = {"door_spruce_b.png", "door_brown.png"},
	tiles_top = {"door_spruce_a.png", "door_brown.png"},
	sounds = mcl_core.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "doors:door_spruce 3",
	recipe = {
		{"mcl_core:sprucewood", "mcl_core:sprucewood"},
		{"mcl_core:sprucewood", "mcl_core:sprucewood"},
		{"mcl_core:sprucewood", "mcl_core:sprucewood"}
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "doors:door_wood",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "doors:door_jungle",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "doors:door_dark_oak",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "doors:door_birch",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "doors:door_acacia",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "doors:door_spruce",
	burntime = 10,
})

--- Door in Iron ---
doors:register_door("doors:door_steel", {
	description = "Iron Door",
	inventory_image = "door_steel.png",
	groups = {snappy=1,cracky=1,level=2,door=1,mesecon_effector_on=1},
	tiles_bottom = {"door_steel_b.png", "door_grey.png"},
	tiles_top = {"door_steel_a.png", "door_grey.png"},
	sounds = mcl_core.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "doors:door_steel 3",
	recipe = {
		{"mcl_core:steel_ingot", "mcl_core:steel_ingot"},
		{"mcl_core:steel_ingot", "mcl_core:steel_ingot"},
		{"mcl_core:steel_ingot", "mcl_core:steel_ingot"}
	}
})

minetest.register_alias("doors:door_wood_a_c", "doors:door_wood_t_1")
minetest.register_alias("doors:door_wood_a_o", "doors:door_wood_t_1")
minetest.register_alias("doors:door_wood_b_c", "doors:door_wood_b_1")
minetest.register_alias("doors:door_wood_b_o", "doors:door_wood_b_1")


----trapdoor Wood----

local me
local meta
local state = 0

local function update_door(pos, node) 
	minetest.set_node(pos, node)
end

local function punch(pos)
	meta = minetest.get_meta(pos)
	state = meta:get_int("state")
	me = minetest.get_node(pos)
	local tmp_node
	local tmp_node2
	local oben = {x=pos.x, y=pos.y+1, z=pos.z}
		if state == 1 then
			state = 0
			minetest.sound_play("door_close", {pos = pos, gain = 0.3, max_hear_distance = 10})
			tmp_node = {name="doors:trapdoor", param1=me.param1, param2=me.param2}
		else
			state = 1
			minetest.sound_play("door_open", {pos = pos, gain = 0.3, max_hear_distance = 10})
			tmp_node = {name="doors:trapdoor_open", param1=me.param1, param2=me.param2}
		end
		update_door(pos, tmp_node)
		meta:set_int("state", state)
end


minetest.register_node("doors:trapdoor", {
	description = "Wooden Trapdoor",
	drawtype = "nodebox",
	tiles = {"door_trapdoor.png", "door_trapdoor.png",  "default_wood.png",  "default_wood.png", "default_wood.png", "default_wood.png"},
	is_ground_content = false,
	paramtype = "light",
	stack_max = 64,
	paramtype2 = "facedir",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,mesecon_effector_on=1,door=2},
	sounds = mcl_core.node_sound_wood_defaults(),
	drop = "doors:trapdoor",
	node_box = {
		type = "fixed",
		fixed = {
		{-8/16, -8/16, -8/16, -5/16, -6/16, 8/16},--left
		{5/16, -8/16, -8/16, 8/16, -6/16, 8/16},  --right
		{-8/16, -8/16, -8/16, 8/16, -6/16, -5/16},--down
		{-8/16, -8/16, 5/16, 8/16, -6/16, 8/16},  --up
		{-2/16, -8/16, -5/16, 2/16, -6/16, 5/16}, --vert mid
		{-5/16, -8/16, -2/16, 5/16, -6/16, 2/16}, --hori mid
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
		{-8/16, -8/16, -8/16, -5/16, -6/16, 8/16},--left
		{5/16, -8/16, -8/16, 8/16, -6/16, 8/16},  --right
		{-8/16, -8/16, -8/16, 8/16, -6/16, -5/16},--down
		{-8/16, -8/16, 5/16, 8/16, -6/16, 8/16},  --up
		{-2/16, -8/16, -5/16, 2/16, -6/16, 5/16}, --vert mid
		{-5/16, -8/16, -2/16, 5/16, -6/16, 2/16}, --hori mid
		},
	},
	on_creation = function(pos)
		state = 0
	end,
	mesecons = {effector = {
		action_on = (function(pos, node)
			punch(pos)
		end),
	}},
	on_rightclick = function(pos, node, clicker)
		punch(pos)
	end,
})


minetest.register_node("doors:trapdoor_open", {
	drawtype = "nodebox",
	tiles = {"default_wood.png", "default_wood.png",  "default_wood.png",  "default_wood.png", "door_trapdoor.png", "door_trapdoor.png"},
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "facedir",
	pointable = true,
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,mesecon_effector_on=1,door=2},
	sounds = mcl_core.node_sound_wood_defaults(),
	drop = "doors:trapdoor",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 0.4, 0.5, 0.5, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 0.4, 0.5, 0.5, 0.5}
	},
	on_rightclick = function(pos, node, clicker)
		punch(pos)
	end,
	mesecons = {effector = {
	action_on = (function(pos, node)
		punch(pos)
	end),
	}},

})




minetest.register_craft({
	output = 'doors:trapdoor 2',
	recipe = {
		{'group:wood', 'group:wood', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "doors:trapdoor",
	burntime = 15,
})

--- Iron Trapdoor ----
local me
local meta
local state = 0

local function update_door(pos, node) 
	minetest.set_node(pos, node)
end

local function punch(pos)
	meta = minetest.get_meta(pos)
	state = meta:get_int("state")
	me = minetest.get_node(pos)
	local tmp_node
	local tmp_node2
	local oben = {x=pos.x, y=pos.y+1, z=pos.z}
		if state == 1 then
			state = 0
			minetest.sound_play("door_close", {pos = pos, gain = 0.3, max_hear_distance = 10})
			tmp_node = {name="doors:iron_trapdoor", param1=me.param1, param2=me.param2}
		else
			state = 1
			minetest.sound_play("door_open", {pos = pos, gain = 0.3, max_hear_distance = 10})
			tmp_node = {name="doors:iron_trapdoor_open", param1=me.param1, param2=me.param2}
		end
		update_door(pos, tmp_node)
		meta:set_int("state", state)
end


minetest.register_node("doors:iron_trapdoor", {
	description = "Iron Trapdoor",
	drawtype = "nodebox",
	tiles = {"iron_trapdoor.png", "iron_trapdoor.png",  "default_steel_block.png",  "default_steel_block.png", "default_steel_block.png", "default_steel_block.png"},
	paramtype = "light",
	is_ground_content = false,
	stack_max = 64,
	paramtype2 = "facedir",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,mesecon_effector_on=1,door=2},
	sounds = mcl_core.node_sound_wood_defaults(),
	drop = "doors:iron_trapdoor",
	node_box = {
		type = "fixed",
		fixed = {
		{-8/16, -8/16, -8/16, -5/16, -6/16, 8/16},--left
		{5/16, -8/16, -8/16, 8/16, -6/16, 8/16},  --right
		{-8/16, -8/16, -8/16, 8/16, -6/16, -5/16},--down
		{-8/16, -8/16, 5/16, 8/16, -6/16, 8/16},  --up
		{-2/16, -8/16, -5/16, 2/16, -6/16, 5/16}, --vert mid
		{-5/16, -8/16, -2/16, 5/16, -6/16, 2/16}, --hori mid
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
		{-8/16, -8/16, -8/16, -5/16, -6/16, 8/16},--left
		{5/16, -8/16, -8/16, 8/16, -6/16, 8/16},  --right
		{-8/16, -8/16, -8/16, 8/16, -6/16, -5/16},--down
		{-8/16, -8/16, 5/16, 8/16, -6/16, 8/16},  --up
		{-2/16, -8/16, -5/16, 2/16, -6/16, 5/16}, --vert mid
		{-5/16, -8/16, -2/16, 5/16, -6/16, 2/16}, --hori mid
		},
	},
	mesecons = {effector = {
	action_on = (function(pos, node)
		punch(pos)
	end),
	}},
	on_creation = function(pos)
		state = 0
	end,
	on_rightclick = function(pos, node, clicker)
		punch(pos)
	end,
})


minetest.register_node("doors:iron_trapdoor_open", {
	drawtype = "nodebox",
	tiles = {"default_steel_block.png", "default_steel_block.png",  "default_steel_block.png",  "default_steel_block.png", "iron_trapdoor.png", "iron_trapdoor.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	pointable = true,
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,door=2,mesecon_effector_on=1},
	sounds = mcl_core.node_sound_wood_defaults(),
	drop = "doors:iron_trapdoor",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 0.4, 0.5, 0.5, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 0.4, 0.5, 0.5, 0.5}
	},
	mesecons = {effector = {
	action_on = (function(pos, node)
		punch(pos)
	end),
	}},
	on_rightclick = function(pos, node, clicker)
		punch(pos)
	end,
})

minetest.register_craft({
	output = 'doors:iron_trapdoor',
	recipe = {
		{'mcl_core:steel_ingot', 'mcl_core:steel_ingot'},
		{'mcl_core:steel_ingot', 'mcl_core:steel_ingot'},
	}
})

local time_to_load= os.clock() - init
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))
