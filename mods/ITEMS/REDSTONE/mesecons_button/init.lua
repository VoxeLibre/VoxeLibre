-- WALL BUTTON
-- A button that when pressed emits power for 1 second
-- and then turns off again

-- FIXME: Power lower/upper nodes as well
local button_get_output_rules = function(node)
	local rules = {
		{x = -1, y = 0, z = 0},
		{x = 1, y = 0, z = 0},
		{x = 0, y = 0, z = -1},
		{x = 0, y = 0, z = 1},
		{x = 0, y = -1, z = 0},
	}
	if minetest.wallmounted_to_dir(node.param2).y == 1 then
		table.insert(rules, {x=0, y=1, z=1})
	end
	return rules
end

mesecon.button_turnoff = function (pos)
	local node = minetest.get_node(pos)
	if node.name=="mesecons_button:button_stone_on" then --has not been dug
		mesecon:swap_node(pos, "mesecons_button:button_stone_off")
		minetest.sound_play("mesecons_button_pop", {pos=pos})
		mesecon:receptor_off(pos, button_get_output_rules(node))
	elseif node.name=="mesecons_button:button_wood_on" then --has not been dug
		mesecon:swap_node(pos, "mesecons_button:button_wood_off")
		minetest.sound_play("mesecons_button_pop", {pos=pos})
		mesecon:receptor_off(pos, button_get_output_rules(node))
	end
end

local boxes_off = {
	type = "wallmounted",
	wall_side = { -8/16, -2/16, -4/16, -6/16, 2/16, 4/16 },
	wall_bottom = { -4/16, -8/16, -2/16, 4/16, -6/16, 2/16 },
	wall_top = { -4/16, 6/16, -2/16, 4/16, 8/16, 2/16 },
}
local boxes_on = {
	type = "wallmounted",
	wall_side = { -8/16, -2/16, -4/16, -7/16, 2/16, 4/16 },
	wall_bottom = { -4/16, -8/16, -2/16, 4/16, -7/16, 2/16 },
	wall_top = { -4/16, 7/16, -2/16, 4/16, 8/16, 2/16 },
}

local buttonuse = "Rightclick the button to push it."
minetest.register_node("mesecons_button:button_stone_off", {
	drawtype = "nodebox",
	tiles = {"default_stone.png"},
	wield_image = "default_stone.png^[mask:mesecons_button_wield_mask.png",
	-- FIXME: Use proper 3D inventory image
	inventory_image = "default_stone.png^[mask:mesecons_button_wield_mask.png",
	wield_scale = { x=1, y=1, z=1},
	paramtype = "light",
	paramtype2 = "wallmounted",
	is_ground_content = false,
	walkable = false,
	sunlight_propagates = true,
	node_box = boxes_off,
	groups = {handy=1,pickaxey=1, attached_node=1, dig_by_water=1, dig_by_piston=1},
	description = "Stone Button",
	_doc_items_longdesc = "A stone button is a redstone component made out of stone which can be pushed to provide redstone power. When pushed, it powers adjacent redstone components for 1 second.",
	_doc_items_usagehelp = buttonuse,
	on_rightclick = function (pos, node)
		mesecon:swap_node(pos, "mesecons_button:button_stone_on")
		mesecon:receptor_on(pos, button_get_output_rules(node))
		minetest.sound_play("mesecons_button_push", {pos=pos})
		minetest.after(1, mesecon.button_turnoff, pos)
	end,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.off,
		rules = button_get_output_rules,
	}},
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 0.5,
})

minetest.register_node("mesecons_button:button_stone_on", {
	drawtype = "nodebox",
	tiles = {"default_stone.png"},
	wield_image = "default_stone.png^[mask:mesecons_button_wield_mask.png",
	inventory_image = "default_stone.png^[mask:mesecons_button_wield_mask.png",
	wield_scale = { x=1, y=1, z=0.5},
	paramtype = "light",
	paramtype2 = "wallmounted",
	is_ground_content = false,
	walkable = false,
	sunlight_propagates = true,
	node_box = boxes_on,
	groups = {handy=1,pickaxey=1, not_in_creative_inventory=1, attached_node=1, dig_by_water=1, dig_by_piston=1},
	drop = 'mesecons_button:button_stone_off',
	description = "Stone Button",
	_doc_items_create_entry = false,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = button_get_output_rules
	}},
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 0.5,
})

minetest.register_node("mesecons_button:button_wood_off", {
	drawtype = "nodebox",
	tiles = {"default_wood.png"},
	wield_image = "default_wood.png^[mask:mesecons_button_wield_mask.png",
	inventory_image = "default_wood.png^[mask:mesecons_button_wield_mask.png",
	wield_scale = { x=1, y=1, z=1},
	paramtype = "light",
	paramtype2 = "wallmounted",
	is_ground_content = false,
	walkable = false,
	sunlight_propagates = true,
	node_box = boxes_off,
	groups = {handy=1,axey=1, attached_node=1, dig_by_water=1, dig_by_piston=1},
	description = "Wooden Button",
	_doc_items_longdesc = "A wooden button is a redstone component made out of wood which can be pushed to provide redstone power. When pushed, it powers adjacent redstone components for 1.5 seconds.",
	_doc_items_usagehelp = buttonuse,
	on_rightclick = function (pos, node)
		mesecon:swap_node(pos, "mesecons_button:button_wood_on")
		mesecon:receptor_on(pos, button_get_output_rules(node))
		minetest.sound_play("mesecons_button_push", {pos=pos})
		minetest.after(1.5, mesecon.button_turnoff, pos)
	end,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.off,
		rules = button_get_output_rules,
	}},
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 0.5,
})

minetest.register_node("mesecons_button:button_wood_on", {
	drawtype = "nodebox",
	tiles = {"default_wood.png"},
	wield_image = "default_wood.png^[mask:mesecons_button_wield_mask.png",
	inventory_image = "default_wood.png^[mask:mesecons_button_wield_mask.png",
	wield_scale = { x=1, y=1, z=0.5},
	paramtype = "light",
	paramtype2 = "wallmounted",
	is_ground_content = false,
	walkable = false,
	sunlight_propagates = true,
	node_box = boxes_on,
	groups = {handy=1,axey=1, not_in_creative_inventory=1, attached_node=1, dig_by_water=1, dig_by_piston=1},
	drop = 'mesecons_button:button_wood_off',
	description = "Wooden Button",
	_doc_items_create_entry = false,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = button_get_output_rules,
	}},
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 0.5,
})

minetest.register_craft({
	output = 'mesecons_button:button_stone_off',
	recipe = {
		{'mcl_core:stone'},
	}
})

minetest.register_craft({
	output = 'mesecons_button:button_wood_off',
	recipe = {
		{'group:wood'},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = 'mesecons_button:button_wood_off',
	burntime = 5,
})

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mesecons_button:button_wood_off", "nodes", "mesecons_button:button_wood_on")
	doc.add_entry_alias("nodes", "mesecons_button:button_stone_off", "nodes", "mesecons_button:button_stone_on")
end
