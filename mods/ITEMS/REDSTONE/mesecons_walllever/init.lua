-- WALL LEVER
-- Basically a switch that can be attached to a wall
-- Powers the block 2 nodes behind (using a receiver)
minetest.register_node("mesecons_walllever:wall_lever_off", {
	drawtype = "nodebox",
	tiles = {
		"jeija_wall_lever_tb.png",
		"jeija_wall_lever_bottom.png",
		"jeija_wall_lever_sides.png",
		"jeija_wall_lever_sides.png",
		"jeija_wall_lever_back.png",
		"jeija_wall_lever_off.png",
	},
	inventory_image = "jeija_wall_lever.png",
	wield_image = "jeija_wall_lever.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {{ -2/16, -3/16,  8/16, 2/16, 3/16,  4/16 },
			 { -1/16, -8/16, 7/16, 1/16, 0/16,  5/16 }},
	},
	node_box = {
		type = "fixed",
		fixed = {{ -2/16, -3/16,  8/16, 2/16, 3/16,  4/16 },	-- the base
			 { -1/16, -8/16, 7/16, 1/16, 0/16,  5/16 }}	-- the lever itself.
	},
	groups = {handy=1, dig_by_water=1},
	is_ground_content = false,
	description="Lever",
	_doc_items_longdesc = "A lever is a redstone component which can be flipped on and off. It supplies redstone power to the blocks behind while it is in the “on” state.",
	_doc_items_usagehelp = "Right-click the lever to flip it on or off.",
	on_rightclick = function (pos, node)
		mesecon:swap_node(pos, "mesecons_walllever:wall_lever_on")
		mesecon:receptor_on(pos, mesecon.rules.buttonlike_get(node))
		minetest.sound_play("mesecons_lever", {pos=pos})
	end,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	mesecons = {receptor = {
		rules = mesecon.rules.buttonlike_get,
		state = mesecon.state.off
	}},
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 0.5,
})
minetest.register_node("mesecons_walllever:wall_lever_on", {
	drawtype = "nodebox",
	tiles = {
		"jeija_wall_lever_top.png",
		"jeija_wall_lever_tb.png",
		"jeija_wall_lever_sides.png",
		"jeija_wall_lever_sides.png",
		"jeija_wall_lever_back.png",
		"jeija_wall_lever_on.png",
	},
	inventory_image = "jeija_wall_lever.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {{ -2/16, -3/16,  8/16, 2/16, 3/16,  4/16 },
			 { -1/16, 0, 7/16, 1/16, 8/16,  5/16 }},
	},
	node_box = {
		type = "fixed",
		fixed = {{ -2/16, -3/16,  8/16, 2/16, 3/16,  4/16 },	-- the base
			 { -1/16, 0/16, 7/16, 1/16, 8/16,  5/16 }}	-- the lever itself.
	},
	groups = {handy=1, not_in_creative_inventory = 1, dig_by_water=1},
	is_ground_content = false,
	drop = '"mesecons_walllever:wall_lever_off" 1',
	description="Lever",
	_doc_items_create_entry = false,
	on_rightclick = function (pos, node)
		mesecon:swap_node(pos, "mesecons_walllever:wall_lever_off")
		mesecon:receptor_off(pos, mesecon.rules.buttonlike_get(node))
		minetest.sound_play("mesecons_lever", {pos=pos})
	end,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	mesecons = {receptor = {
		rules = mesecon.rules.buttonlike_get,
		state = mesecon.state.on
	}},
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 0.5,
})

minetest.register_craft({
	output = 'mesecons_walllever:wall_lever_off',
	recipe = {
		{'mcl_core:stick'},
		{'mcl_core:cobble'},
	}
})

if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mesecons_walllever:wall_lever_off", "nodes", "mesecons_walllever:wall_lever_on")
end
