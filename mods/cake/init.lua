--[[
#!#!#!#Cake mod created by Jordan4ibanez#!#!#
#!#!#!#Released under CC Attribution-ShareAlike 3.0 Unported #!#!#
]]--

cake_texture = {"cake_top.png","cake_bottom.png","cake_inner.png","cake_side.png","cake_side.png","cake_side.png"}
slice_1 = { -7/16, -8/16, -7/16, -5/16, 0/16, 7/16}
slice_2 = { -7/16, -8/16, -7/16, -2/16, 0/16, 7/16}
slice_3 = { -7/16, -8/16, -7/16, 1/16, 0/16, 7/16}
slice_4 = { -7/16, -8/16, -7/16, 3/16, 0/16, 7/16}
slice_5 = { -7/16, -8/16, -7/16, 5/16, 0/16, 7/16}
slice_6 = { -7/16, -8/16, -7/16, 7/16, 0/16, 7/16}

minetest.register_craft({
	output = "cake:cake",
	recipe = {
		{'bucket:bucket_water', 'bucket:bucket_water', 'bucket:bucket_water'},
		{'default:sugar', 'default:leaves', 'default:sugar'},
		{'farming:wheat_harvested', 'farming:wheat_harvested', 'farming:wheat_harvested'},
	},
	replacements = {{"bucket:bucket_water", "bucket:bucket_empty"}},
})

minetest.register_node("cake:cake", {
	description = "Cake",
	tiles = {"cake_top.png","cake_bottom.png","cake_side.png","cake_side.png","cake_side.png","cake_side.png"},
	paramtype = "light",
	drawtype = "nodebox",
	selection_box = {
		type = "fixed",
		fixed = slice_6
	},
	node_box = {
		type = "fixed",
			fixed = slice_6
		},
	is_ground_content = true,
	stack_max = 1,
	groups = {crumbly=3,falling_node=1},
	drop = '',
	--legacy_mineral = true,
	on_rightclick = function(pos, node, clicker, itemstack)
		if clicker:get_hp() < 20 then
			clicker:set_hp(clicker:get_hp()+2)
			minetest.env:add_node(pos,{type="node",name="cake:cake_5",param2=param2})
		end
	end,
})
minetest.register_node("cake:cake_5", {
	description = "Cake [5 Slices Left]",
	tiles = cake_texture,
	paramtype = "light",
	drawtype = "nodebox",
	selection_box = {
		type = "fixed",
		fixed = slice_5
	},
	node_box = {
		type = "fixed",
			fixed = slice_5
		},
	is_ground_content = true,
	groups = {crumbly=3,falling_node=1,not_in_creative_inventory=1},
	drop = '',
	--legacy_mineral = true,
	on_rightclick = function(pos, node, clicker, itemstack)
		if clicker:get_hp() < 20 then
			clicker:set_hp(clicker:get_hp()+2)
			minetest.env:add_node(pos,{type="node",name="cake:cake_4",param2=param2})
		end
	end,
})
minetest.register_node("cake:cake_4", {
	description = "Cake [4 Slices Left]",
	tiles = cake_texture,
	paramtype = "light",
	drawtype = "nodebox",
	selection_box = {
		type = "fixed",
		fixed = slice_4
	},
	node_box = {
		type = "fixed",
			fixed = slice_4
		},
	is_ground_content = true,
	groups = {crumbly=3,falling_node=1,not_in_creative_inventory=1},
	drop = '',
	--legacy_mineral = true,
	on_rightclick = function(pos, node, clicker, itemstack)
		if clicker:get_hp() < 20 then
			clicker:set_hp(clicker:get_hp()+2)
			minetest.env:add_node(pos,{type="node",name="cake:cake_3",param2=param2})
		end
	end,
})
minetest.register_node("cake:cake_3", {
	description = "Cake [3 Slices Left]",
	tiles = cake_texture,
	paramtype = "light",
	drawtype = "nodebox",
	selection_box = {
		type = "fixed",
		fixed = slice_3
	},
	node_box = {
		type = "fixed",
			fixed = slice_3
		},
	is_ground_content = true,
	groups = {crumbly=3,falling_node=1,not_in_creative_inventory=1},
	drop = '',
	--legacy_mineral = true,
	on_rightclick = function(pos, node, clicker, itemstack)
		if clicker:get_hp() < 20 then
			clicker:set_hp(clicker:get_hp()+2)
			minetest.env:add_node(pos,{type="node",name="cake:cake_2",param2=param2})
		end
	end,
})
minetest.register_node("cake:cake_2", {
	description = "Cake [2 Slices Left]",
	tiles = cake_texture,
	paramtype = "light",
	drawtype = "nodebox",
	selection_box = {
		type = "fixed",
		fixed = slice_2
	},
	node_box = {
		type = "fixed",
			fixed = slice_2
		},
	is_ground_content = true,
	groups = {crumbly=3,falling_node=1,not_in_creative_inventory=1},
	drop = '',
	--legacy_mineral = true,
	on_rightclick = function(pos, node, clicker, itemstack)
		if clicker:get_hp() < 20 then
			clicker:set_hp(clicker:get_hp()+2)
			minetest.env:add_node(pos,{type="node",name="cake:cake_1",param2=param2})
		end
	end,
})
minetest.register_node("cake:cake_1", {
	description = "Cake [1 Slice Left]",
	tiles = cake_texture,
	paramtype = "light",
	drawtype = "nodebox",
	selection_box = {
		type = "fixed",
		fixed = slice_1
	},
	node_box = {
		type = "fixed",
			fixed = slice_1
		},
	is_ground_content = true,
	groups = {crumbly=3,falling_node=1,not_in_creative_inventory=1},
	drop = '',
	--legacy_mineral = true,
	on_rightclick = function(pos, node, clicker, itemstack)
		if clicker:get_hp() < 20 then
			clicker:set_hp(clicker:get_hp()+2)
			minetest.env:remove_node(pos)
		end
	end,
})