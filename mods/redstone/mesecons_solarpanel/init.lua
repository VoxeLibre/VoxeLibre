local boxes = { -8/16, -8/16, -8/16,  8/16, -2/16, 8/16 } -- Solar Pannel

-- Solar Panel
minetest.register_node("mesecons_solarpanel:solar_panel_on", {
	drawtype = "nodebox",
	tiles = { "jeija_solar_panel.png","jeija_solar_panel.png","jeija_solar_panel_side.png",
	"jeija_solar_panel_side.png","jeija_solar_panel_side.png","jeija_solar_panel_side.png", },
	wield_image = "jeija_solar_panel.png",
	paramtype = "light",
	walkable = false,
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
	groups = {dig_immediate=3, not_in_creative_inventory = 1},
	sounds = mcl_core.node_sound_glass_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.on
	}},
	on_rightclick = function(pos, node, clicker, pointed_thing)
		minetest.swap_node(pos, {name = "mesecons_solarpanel:solar_panel_inverted_off"})
		mesecon:receptor_off(pos)
	end,
})

-- Solar Panel
minetest.register_node("mesecons_solarpanel:solar_panel_off", {
	drawtype = "nodebox",
	tiles = { "jeija_solar_panel.png","jeija_solar_panel.png","jeija_solar_panel_side.png",
	"jeija_solar_panel_side.png","jeija_solar_panel_side.png","jeija_solar_panel_side.png", },
	wield_image = "jeija_solar_panel.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = boxes
	},
	node_box = {
		type = "fixed",
		fixed = boxes
	},
	groups = {dig_immediate=3},
	description="Daylight Sensor",
	sounds = mcl_core.node_sound_glass_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.off
	}},
	on_rightclick = function(pos, node, clicker, pointed_thing)
		minetest.swap_node(pos, {name = "mesecons_solarpanel:solar_panel_inverted_on"})
		mesecon:receptor_on(pos)
	end,
})

minetest.register_craft({
	output = 'mesecons_solarpanel:solar_panel_off',
	recipe = {
		{'mcl_core:glass', 'mcl_core:glass', 'mcl_core:glass'},
		{'mcl_core:quartz_crystal', 'mcl_core:quartz_crystal', 'mcl_core:quartz_crystal'},
		{'group:wood_slab', 'group:wood_slab', 'group:wood_slab'},
	}
})

minetest.register_abm(
	{nodenames = {"mesecons_solarpanel:solar_panel_off"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local light = minetest.get_node_light(pos, nil)

		if light >= 12 and minetest.get_timeofday() > 0.2 and minetest.get_timeofday() < 0.8 then
			minetest.set_node(pos, {name="mesecons_solarpanel:solar_panel_on", param2=node.param2})
			mesecon:receptor_on(pos)
		end
	end,
})

minetest.register_abm(
	{nodenames = {"mesecons_solarpanel:solar_panel_on"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local light = minetest.get_node_light(pos, nil)

		if light < 12 then
			minetest.set_node(pos, {name="mesecons_solarpanel:solar_panel_off", param2=node.param2})
			mesecon:receptor_off(pos)
		end
	end,
})

--- Solar panel inversed

-- Solar Panel
minetest.register_node("mesecons_solarpanel:solar_panel_inverted_on", {
	drawtype = "nodebox",
	tiles = { "jeija_solar_panel_inverted.png","jeija_solar_panel_inverted.png","jeija_solar_panel_side.png",
	"jeija_solar_panel_side.png","jeija_solar_panel_side.png","jeija_solar_panel_side.png", },
	wield_image = "jeija_solar_panel_inverted.png",
	paramtype = "light",
	walkable = false,
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
	groups = {dig_immediate=3, not_in_creative_inventory = 1},
    	description="Inverted Daylight Sensor",
	sounds = mcl_core.node_sound_glass_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.on
	}},
	on_rightclick = function(pos, node, clicker, pointed_thing)
		minetest.swap_node(pos, {name = "mesecons_solarpanel:solar_panel_off"})
		mesecon:receptor_off(pos)
	end,
})

-- Solar Panel
minetest.register_node("mesecons_solarpanel:solar_panel_inverted_off", {
	drawtype = "nodebox",
	tiles = { "jeija_solar_panel_inverted.png","jeija_solar_panel_inverted.png","jeija_solar_panel_side.png",
	"jeija_solar_panel_side.png","jeija_solar_panel_side.png","jeija_solar_panel_side.png", },
	wield_image = "jeija_solar_panel_inverted.png",
	paramtype = "light",
	walkable = false,
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
	groups = {dig_immediate=3, not_in_creative_inventory=1},
    	description="Inverted Daylight Sensor",
	sounds = mcl_core.node_sound_glass_defaults(),
	mesecons = {receptor = {
		state = mesecon.state.off
	}},
	on_rightclick = function(pos, node, clicker, pointed_thing)
		minetest.swap_node(pos, {name = "mesecons_solarpanel:solar_panel_on"})
		mesecon:receptor_on(pos)
	end,
})

minetest.register_abm(
	{nodenames = {"mesecons_solarpanel:solar_panel_inverted_off"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local light = minetest.get_node_light(pos, nil)

		if light < 12 then
			minetest.set_node(pos, {name="mesecons_solarpanel:solar_panel_inverted_on", param2=node.param2})
			mesecon:receptor_on(pos)
		end
	end,
})

minetest.register_abm(
	{nodenames = {"mesecons_solarpanel:solar_panel_inverted_on"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local light = minetest.get_node_light(pos, nil)

		if light >= 12 and minetest.get_timeofday() > 0.8 and minetest.get_timeofday() < 0.2 then
			minetest.set_node(pos, {name="mesecons_solarpanel:solar_panel_inverted_off", param2=node.param2})
			mesecon:receptor_off(pos)
		end
	end,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mesecons_solarpanel:solar_panel_off",
	burntime = 15
})

