-- WALL BUTTON
-- A button that when pressed emits power for 1 second
-- and then turns off again

mesecon.button_turnoff = function (pos)
	local node = minetest.env:get_node(pos)
	if node.name=="mesecons_button:button_stone_on" then --has not been dug
		mesecon:swap_node(pos, "mesecons_button:button_stone_off")
		minetest.sound_play("mesecons_button_pop", {pos=pos})
		local rules = mesecon.rules.buttonlike_get(node)
		mesecon:receptor_off(pos, rules)
	elseif node.name=="mesecons_button:button_wood_on" then --has not been dug
		mesecon:swap_node(pos, "mesecons_button:button_wood_off")
		minetest.sound_play("mesecons_button_pop", {pos=pos})
		local rules = mesecon.rules.buttonlike_get(node)
		mesecon:receptor_off(pos, rules)
	end
end

local boxes_off = { -4/16, -2/16, 8/16, 4/16, 2/16, 6/16 } -- The button
local  boxes_on = { -4/16, -2/16, 8/16, 4/16, 2/16, 7/16 }  -- The button

minetest.register_node("mesecons_button:button_stone_off", {
	drawtype = "nodebox",
	tiles = {"default_stone.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_wallmounted = true,
	walkable = false,
	sunlight_propagates = true,
	selection_box = {
	type = "fixed",
		fixed = boxes_off
	},
	node_box = {
		type = "fixed",	
		fixed = boxes_off	-- the button itself
	},
	groups = {dig_immediate=2, attached_node=1},
	description = "Stone Button",
	on_punch = function (pos, node)
		mesecon:swap_node(pos, "mesecons_button:button_stone_on")
		mesecon:receptor_on(pos, mesecon.rules.buttonlike_get(node))
		minetest.sound_play("mesecons_button_push", {pos=pos})
		minetest.after(1, mesecon.button_turnoff, pos)
	end,
	sounds = default.node_sound_stone_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.off,
		rules = mesecon.rules.buttonlike_get
	}}
})

minetest.register_node("mesecons_button:button_stone_on", {
	drawtype = "nodebox",
	tiles = {"default_stone.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_wallmounted = true,
	walkable = false,
	sunlight_propagates = true,
	selection_box = {
	type = "fixed",
		fixed = boxes_on
	},
	node_box = {
		type = "fixed",	
		fixed = boxes_on	-- the button itself
	},
	groups = {dig_immediate=2, not_in_creative_inventory=1, attached_node=1},
	drop = 'mesecons_button:button_stone_off',
	description = "Stone Button",
	sounds = default.node_sound_stone_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = mesecon.rules.buttonlike_get
	}}
})

minetest.register_node("mesecons_button:button_wood_off", {
	drawtype = "nodebox",
	tiles = {"default_wood.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_wallmounted = true,
	walkable = false,
	sunlight_propagates = true,
	selection_box = {
	type = "fixed",
		fixed = boxes_off
	},
	node_box = {
		type = "fixed",	
		fixed = boxes_off	-- the button itself
	},
	groups = {dig_immediate=2, attached_node=1},
	description = "Wood Button",
	on_punch = function (pos, node)
		mesecon:swap_node(pos, "mesecons_button:button_wood_on")
		mesecon:receptor_on(pos, mesecon.rules.buttonlike_get(node))
		minetest.sound_play("mesecons_button_push", {pos=pos})
		minetest.after(1, mesecon.button_turnoff, pos)
	end,
	sounds = default.node_sound_stone_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.off,
		rules = mesecon.rules.buttonlike_get
	}}
})

minetest.register_node("mesecons_button:button_wood_on", {
	drawtype = "nodebox",
	tiles = {"default_wood.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_wallmounted = true,
	walkable = false,
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = boxes_on
	},
	node_box = {
		type = "fixed",	
		fixed = boxes_on	-- the button itself
	},
	groups = {dig_immediate=2, not_in_creative_inventory=1, attached_node=1},
	drop = 'mesecons_button:button_wood_off',
	description = "Wood Button",
	sounds = default.node_sound_stone_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = mesecon.rules.buttonlike_get
	}}
})

minetest.register_craft({
	output = 'mesecons_button:button_stone_off',
	recipe = {
		{'default:stone'},
	}
})

minetest.register_craft({
	output = 'mesecons_button:button_wood_off',
	recipe = {
		{'group:wood'},
	}
})
