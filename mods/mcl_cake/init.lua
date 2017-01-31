--[[
#!#!#!#Cake mod created by Jordan4ibanez#!#!#
#!#!#!#Released under CC Attribution-ShareAlike 3.0 Unported #!#!#
]]--

local cake_texture = {"cake_top.png","cake_bottom.png","cake_inner.png","cake_side.png","cake_side.png","cake_side.png"}
local slice_1 = { -7/16, -8/16, -7/16, -5/16, 0/16, 7/16}
local slice_2 = { -7/16, -8/16, -7/16, -2/16, 0/16, 7/16}
local slice_3 = { -7/16, -8/16, -7/16, 1/16, 0/16, 7/16}
local slice_4 = { -7/16, -8/16, -7/16, 3/16, 0/16, 7/16}
local slice_5 = { -7/16, -8/16, -7/16, 5/16, 0/16, 7/16}
local slice_6 = { -7/16, -8/16, -7/16, 7/16, 0/16, 7/16}

minetest.register_craft({
	output = "mcl_cake:cake",
	recipe = {
		{'mcl_mobitems:milk_bucket', 'mcl_mobitems:milk_bucket', 'mcl_mobitems:milk_bucket'},
		{'mcl_core:sugar', 'mcl_throwing:egg', 'mcl_core:sugar'},
		{'mcl_farming:wheat_harvested', 'mcl_farming:wheat_harvested', 'mcl_farming:wheat_harvested'},
	},
	replacements = {
		{"mcl_mobitems:milk_bucket", "bucket:bucket_empty"},
		{"mcl_mobitems:milk_bucket", "bucket:bucket_empty"},
		{"mcl_mobitems:milk_bucket", "bucket:bucket_empty"},
	},
})

minetest.register_node("mcl_cake:cake", {
	description = "Cake",
	tiles = {"cake_top.png","cake_bottom.png","cake_side.png","cake_side.png","cake_side.png","cake_side.png"},
	inventory_image = "cake.png",
	wield_image = "cake.png",
	paramtype = "light",
	is_ground_content = false,
	drawtype = "nodebox",
	selection_box = {
		type = "fixed",
		fixed = slice_6
	},
	node_box = {
		type = "fixed",
			fixed = slice_6
		},
	stack_max = 1,
	groups = {food=2,crumbly=3,attached_node=1},
	drop = '',
	on_rightclick = function(pos, node, clicker, itemstack)
		minetest.do_item_eat(2, ItemStack("mcl_cake:cake_5"), ItemStack("mcl_cake:cake"), clicker, {type="nothing"})
		minetest.add_node(pos,{type="node",name="mcl_cake:cake_5",param2=0})
	end,
	sounds = mcl_core.node_sound_leaves_defaults(),
})
minetest.register_node("mcl_cake:cake_5", {
	description = "Cake (5 Slices Left)",
	tiles = cake_texture,
	paramtype = "light",
	is_ground_content = false,
	drawtype = "nodebox",
	selection_box = {
		type = "fixed",
		fixed = slice_5
	},
	node_box = {
		type = "fixed",
			fixed = slice_5
		},
	groups = {food=2,crumbly=3,attached_node=1,not_in_creative_inventory=1},
	drop = '',
	on_rightclick = function(pos, node, clicker, itemstack)
		minetest.do_item_eat(2, ItemStack("mcl_cake:cake_4"), ItemStack("mcl_cake:cake_5"), clicker, {type="nothing"})
		minetest.add_node(pos,{type="node",name="mcl_cake:cake_4",param2=0})
	end,
	sounds = mcl_core.node_sound_leaves_defaults(),
})
minetest.register_node("mcl_cake:cake_4", {
	description = "Cake (4 Slices Left)",
	tiles = cake_texture,
	paramtype = "light",
	is_ground_content = false,
	drawtype = "nodebox",
	selection_box = {
		type = "fixed",
		fixed = slice_4
	},
	node_box = {
		type = "fixed",
			fixed = slice_4
		},
	groups = {food=2,crumbly=3,attached_node=1,not_in_creative_inventory=1},
	drop = '',
	on_rightclick = function(pos, node, clicker, itemstack)
		minetest.do_item_eat(2, ItemStack("mcl_cake:cake_3"), ItemStack("mcl_cake:cake_4"), clicker, {type="nothing"})
		minetest.add_node(pos,{type="node",name="mcl_cake:cake_3",param2=0})
	end,
	sounds = mcl_core.node_sound_leaves_defaults(),
})
minetest.register_node("mcl_cake:cake_3", {
	description = "Cake (3 Slices Left)",
	tiles = cake_texture,
	paramtype = "light",
	is_ground_content = false,
	drawtype = "nodebox",
	selection_box = {
		type = "fixed",
		fixed = slice_3
	},
	node_box = {
		type = "fixed",
			fixed = slice_3
		},
	groups = {food=2,crumbly=3,attached_node=1,not_in_creative_inventory=1},
	drop = '',
	on_rightclick = function(pos, node, clicker, itemstack)
		minetest.do_item_eat(2, ItemStack("mcl_cake:cake_2"), ItemStack("mcl_cake:cake_3"), clicker, {type="nothing"})
		minetest.add_node(pos,{type="node",name="mcl_cake:cake_2",param2=0})
	end,
	sounds = mcl_core.node_sound_leaves_defaults(),
})
minetest.register_node("mcl_cake:cake_2", {
	description = "Cake (2 Slices Left)",
	tiles = cake_texture,
	paramtype = "light",
	is_ground_content = false,
	drawtype = "nodebox",
	selection_box = {
		type = "fixed",
		fixed = slice_2
	},
	node_box = {
		type = "fixed",
			fixed = slice_2
		},
	groups = {food=2,crumbly=3,attached_node=1,not_in_creative_inventory=1},
	drop = '',
	on_rightclick = function(pos, node, clicker, itemstack)
		minetest.do_item_eat(2, ItemStack("mcl_cake:cake_1"), ItemStack("mcl_cake:cake_2"), clicker, {type="nothing"})
		minetest.add_node(pos,{type="node",name="mcl_cake:cake_1",param2=0})
	end,
	sounds = mcl_core.node_sound_leaves_defaults(),
})
minetest.register_node("mcl_cake:cake_1", {
	description = "Cake (1 Slice Left)",
	tiles = cake_texture,
	paramtype = "light",
	is_ground_content = false,
	drawtype = "nodebox",
	selection_box = {
		type = "fixed",
		fixed = slice_1
	},
	node_box = {
		type = "fixed",
			fixed = slice_1
		},
	groups = {food=2,crumbly=3,attached_node=1,not_in_creative_inventory=1},
	drop = '',
	on_rightclick = function(pos, node, clicker, itemstack)
		minetest.do_item_eat(2, ItemStack("mcl:cake:cake 0"), ItemStack("mcl_cake:cake_1"), clicker, {type="nothing"})
		minetest.remove_node(pos)
	end,
	sounds = mcl_core.node_sound_leaves_defaults(),
})
