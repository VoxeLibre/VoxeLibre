local S = minetest.get_translator(minetest.get_current_modname())

local lever_get_output_rules = mesecon.rules.buttonlike_get

local function on_rotate(pos, node, user, mode)
	if mode == screwdriver.ROTATE_FACE then
		if node.param2 == 10 then
			node.param2 = 13
			minetest.swap_node(pos, node)
			return true
		elseif node.param2 == 13 then
			node.param2 = 10
			minetest.swap_node(pos, node)
			return true
		elseif node.param2 == 8 then
			node.param2 = 15
			minetest.swap_node(pos, node)
			return true
		elseif node.param2 == 15 then
			node.param2 = 8
			minetest.swap_node(pos, node)
			return true
		end
	end
	-- TODO: Rotate axis
	return false
end

-- LEVER
minetest.register_node("mesecons_walllever:wall_lever_off", {
	drawtype = "mesh",
	tiles = {
		"jeija_wall_lever_lever_light_on.png",
	},
	inventory_image = "jeija_wall_lever.png",
	wield_image = "jeija_wall_lever.png",
	paramtype = "light",
	paramtype2 = "facedir",
	mesh = "jeija_wall_lever_off.obj",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -4/16, 2/16, 3/16, 4/16, 8/16 },
	},
	use_texture_alpha = "clip",
	groups = {handy=1, dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1, attached_node_facedir=1, vl_attach=1},
	is_ground_content = false,
	description=S("Lever"),
	_tt_help = S("Provides redstone power while it's turned on"),
	_doc_items_longdesc = S("A lever is a redstone component which can be flipped on and off. It supplies redstone power to adjacent blocks while it is in the “on” state."),
	_doc_items_usagehelp = S("Use the lever to flip it on or off."),
	on_rightclick = function(pos, node)
		minetest.swap_node(pos, {name="mesecons_walllever:wall_lever_on", param2=node.param2})
		mesecon.receptor_on(pos, lever_get_output_rules(node))
		minetest.sound_play("mesecons_button_push", {pos=pos, max_hear_distance=16}, true)
	end,
	node_placement_prediction = "",
	on_place = vl_attach.place_attached_facedir,
	_vl_attach_type = "lever",

	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {receptor = {
		rules = lever_get_output_rules,
		state = mesecon.state.off
	}},
	on_rotate = on_rotate,
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})
minetest.register_node("mesecons_walllever:wall_lever_on", {
	drawtype = "mesh",
	tiles = {
		"jeija_wall_lever_lever_light_on.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	mesh = "jeija_wall_lever_on.obj",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -3/16, -4/16, 2/16, 3/16, 4/16, 8/16 },
	},
<<<<<<< HEAD
	use_texture_alpha = "clip",
	groups = {handy=1, not_in_creative_inventory = 1, dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1, attached_node_facedir=1},
=======
	groups = {handy=1, not_in_creative_inventory = 1, dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1, attached_node_facedir=1, vl_attach=1},
>>>>>>> de47967ac (Make nodes with group vl_attach=1 drop if they couldn't attach to the node behind them)
	is_ground_content = false,
	drop = "mesecons_walllever:wall_lever_off",
	_doc_items_create_entry = false,
	on_rightclick = function(pos, node)
		minetest.swap_node(pos, {name="mesecons_walllever:wall_lever_off", param2=node.param2})
		mesecon.receptor_off(pos, lever_get_output_rules(node))
		minetest.sound_play("mesecons_button_push", {pos=pos, max_hear_distance=16, pitch=0.9}, true)
	end,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {receptor = {
		rules = lever_get_output_rules,
		state = mesecon.state.on
	}},
	on_rotate = on_rotate,
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

minetest.register_craft({
	output = "mesecons_walllever:wall_lever_off",
	recipe = {
		{"mcl_core:stick"},
		{"mcl_core:cobble"},
	}
})

if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mesecons_walllever:wall_lever_off", "nodes", "mesecons_walllever:wall_lever_on")
end

vl_attach.set_default("lever", function(_, _, wdir)
	-- No ceiling levers
	if wdir == 0 then return false end
end)
vl_attach.register_autogroup({
	skip_existing = {"lever"},
	callback = function(allow_attach, name, def)
		local groups = def.groups

		-- Only allow full-solid blocks to have buttons attached
		if (groups.solid or 0) ~= 0 and (groups.opaque or 0) ~= 0
		and (not def.node_box or def.node_box.type ~= "regular") then
			allow_attach.lever = true
		end

		-- Exception: allow placing on top of top-slabs
		if (groups.slab_top or 0) ~= 0 then
			allow_attach.lever = true
		end
	end
})
