local boxes = { -8/16, -8/16, -8/16,  8/16, -2/16, 8/16 }

-- Daylight Sensor
minetest.register_node("mesecons_solarpanel:solar_panel_on", {
	drawtype = "nodebox",
	tiles = { "jeija_solar_panel.png","jeija_solar_panel.png","jeija_solar_panel_side.png",
	"jeija_solar_panel_side.png","jeija_solar_panel_side.png","jeija_solar_panel_side.png", },
	wield_image = "jeija_solar_panel.png",
	wield_scale = { x=1, y=1, z=3 },
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = boxes
	},
	node_box = {
		type = "fixed",
		fixed = boxes
	},
	drop = "mesecons_solarpanel:solar_panel_off",
	description="Daylight Sensor",
	_doc_items_create_entry = false,
	groups = {handy=1,axey=1, not_in_creative_inventory = 1, material_wood=1},
	sounds = mcl_sounds.node_sound_glass_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = mesecon.rules.pplate,
	}},
	on_rightclick = function(pos, node, clicker, pointed_thing)
		minetest.swap_node(pos, {name = "mesecons_solarpanel:solar_panel_inverted_off"})
		mesecon.receptor_off(pos, mesecon.rules.pplate)
	end,
	_mcl_blast_resistance = 1,
	_mcl_hardness = 0.2,
})

minetest.register_node("mesecons_solarpanel:solar_panel_off", {
	drawtype = "nodebox",
	tiles = { "jeija_solar_panel.png","jeija_solar_panel.png","jeija_solar_panel_side.png",
	"jeija_solar_panel_side.png","jeija_solar_panel_side.png","jeija_solar_panel_side.png", },
	wield_image = "jeija_solar_panel.png",
	wield_scale = { x=1, y=1, z=3 },
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = boxes
	},
	node_box = {
		type = "fixed",
		fixed = boxes
	},
	groups = {handy=1,axey=1, material_wood=1},
	description="Daylight Sensor",
	_doc_items_longdesc = "Daylight sensors are redstone components which provide redstone power when they are in sunlight and no power otherwise. They can also be inverted.",
	_doc_items_usagehelp = "Rightclick the daylight sensor to turn it into an inverted daylight sensor, which supplies redstone energy when it is in moonlight.",
	sounds = mcl_sounds.node_sound_glass_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.off,
		rules = mesecon.rules.pplate,
	}},
	on_rightclick = function(pos, node, clicker, pointed_thing)
		minetest.swap_node(pos, {name = "mesecons_solarpanel:solar_panel_inverted_on"})
		mesecon.receptor_on(pos, mesecon.rules.pplate)
	end,
	_mcl_blast_resistance = 1,
	_mcl_hardness = 0.2,
})

minetest.register_craft({
	output = 'mesecons_solarpanel:solar_panel_off',
	recipe = {
		{'mcl_core:glass', 'mcl_core:glass', 'mcl_core:glass'},
		{'mcl_nether:quartz', 'mcl_nether:quartz', 'mcl_nether:quartz'},
		{'group:wood_slab', 'group:wood_slab', 'group:wood_slab'},
	}
})

minetest.register_abm({
	label = "Daylight turns on solar panels",
	nodenames = {"mesecons_solarpanel:solar_panel_off"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local light = minetest.get_node_light(pos, nil)

		if light >= 12 and minetest.get_timeofday() > 0.2 and minetest.get_timeofday() < 0.8 then
			minetest.set_node(pos, {name="mesecons_solarpanel:solar_panel_on", param2=node.param2})
			mesecon.receptor_on(pos, mesecon.rules.pplate)
		end
	end,
})

minetest.register_abm({
	label = "Darkness turns off solar panels",
	nodenames = {"mesecons_solarpanel:solar_panel_on"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local light = minetest.get_node_light(pos, nil)

		if light < 12 then
			minetest.set_node(pos, {name="mesecons_solarpanel:solar_panel_off", param2=node.param2})
			mesecon.receptor_off(pos, mesecon.rules.pplate)
		end
	end,
})

--- Inverted Daylight Sensor

minetest.register_node("mesecons_solarpanel:solar_panel_inverted_on", {
	drawtype = "nodebox",
	tiles = { "jeija_solar_panel_inverted.png","jeija_solar_panel_inverted.png","jeija_solar_panel_side.png",
	"jeija_solar_panel_side.png","jeija_solar_panel_side.png","jeija_solar_panel_side.png", },
	wield_image = "jeija_solar_panel_inverted.png",
	wield_scale = { x=1, y=1, z=3 },
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = boxes
	},
	node_box = {
		type = "fixed",
		fixed = boxes
	},
	drop = "mesecons_solarpanel:solar_panel_off",
	groups = {handy=1,axey=1, not_in_creative_inventory = 1, material_wood=1},
    	description="Inverted Daylight Sensor",
	_doc_items_create_entry = false,
	sounds = mcl_sounds.node_sound_glass_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = mesecon.rules.pplate,
	}},
	on_rightclick = function(pos, node, clicker, pointed_thing)
		minetest.swap_node(pos, {name = "mesecons_solarpanel:solar_panel_off"})
		mesecon.receptor_off(pos, mesecon.rules.pplate)
	end,
	_mcl_blast_resistance = 1,
	_mcl_hardness = 0.2,
})

minetest.register_node("mesecons_solarpanel:solar_panel_inverted_off", {
	drawtype = "nodebox",
	tiles = { "jeija_solar_panel_inverted.png","jeija_solar_panel_inverted.png","jeija_solar_panel_side.png",
	"jeija_solar_panel_side.png","jeija_solar_panel_side.png","jeija_solar_panel_side.png", },
	wield_image = "jeija_solar_panel_inverted.png",
	wield_scale = { x=1, y=1, z=3 },
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = boxes
	},
	node_box = {
		type = "fixed",
		fixed = boxes
	},
	drop = "mesecons_solarpanel:solar_panel_off",
	groups = {handy=1,axey=1, not_in_creative_inventory=1, material_wood=1},
    	description="Inverted Daylight Sensor",
	_doc_items_longdesc = "An inverted daylight sensor is a variant of the daylight sensor. It is a redstone component which provides redstone power when it in moonlight and no power otherwise. It can turned back into an ordinary daylight sensor.",
	_doc_items_usagehelp = "Rightclick the daylight sensor to turn it into a daylight sensor.",
	sounds = mcl_sounds.node_sound_glass_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.off,
		rules = mesecon.rules.pplate,
	}},
	on_rightclick = function(pos, node, clicker, pointed_thing)
		minetest.swap_node(pos, {name = "mesecons_solarpanel:solar_panel_on"})
		mesecon.receptor_on(pos, mesecon.rules.pplate)
	end,
	_mcl_blast_resistance = 1,
	_mcl_hardness = 0.2,
})

minetest.register_abm({
	label = "Darkness turns on inverted solar panels",
	nodenames = {"mesecons_solarpanel:solar_panel_inverted_off"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local light = minetest.get_node_light(pos, nil)

		if light < 12 then
			minetest.set_node(pos, {name="mesecons_solarpanel:solar_panel_inverted_on", param2=node.param2})
			mesecon.receptor_on(pos, mesecon.rules.pplate)
		end
	end,
})

minetest.register_abm({
	label = "Daylight turns off inverted solar panels",
	nodenames = {"mesecons_solarpanel:solar_panel_inverted_on"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local light = minetest.get_node_light(pos, nil)

		if light >= 12 and minetest.get_timeofday() > 0.8 and minetest.get_timeofday() < 0.2 then
			minetest.set_node(pos, {name="mesecons_solarpanel:solar_panel_inverted_off", param2=node.param2})
			mesecon.receptor_off(pos, mesecon.rules.pplate)
		end
	end,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mesecons_solarpanel:solar_panel_off",
	burntime = 15
})

if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mesecons_solarpanel:solar_panel_off", "nodes", "mesecons_solarpanel:solar_panel_on")
	doc.add_entry_alias("nodes", "mesecons_solarpanel:solar_panel_inverted_off", "nodes", "mesecons_solarpanel:solar_panel_inverted_on")
end
