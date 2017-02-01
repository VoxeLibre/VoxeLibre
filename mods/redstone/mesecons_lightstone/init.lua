minetest.register_node("mesecons_lightstone:lightstone_off", {
	tiles = {"jeija_lightstone_gray_off.png"},
	inventory_image = minetest.inventorycube("jeija_lightstone_gray_off.png"),
	groups = {cracky=2, mesecon_effector_off = 1, mesecon = 2},
	is_ground_content = false,
	description= "Redstone Lamp",
	sounds = mcl_core.node_sound_stone_defaults(),
	mesecons = {effector = {
		action_on = function (pos, node)
			mesecon:swap_node(pos, "mesecons_lightstone:lightstone_on")
		end
	}}
})

minetest.register_node("mesecons_lightstone:lightstone_on", {
	tiles = {"jeija_lightstone_gray_on.png"},
	inventory_image = minetest.inventorycube("jeija_lightstone_gray_off.png"),
	groups = {cracky=2,not_in_creative_inventory=1, mesecon = 2},
	drop = "node mesecons_lightstone:lightstone_off",
	is_ground_content = false,
	-- Real light level: 15 (Minetest caps at 14)
	light_source = 14,
	sounds = mcl_core.node_sound_stone_defaults(),
	mesecons = {effector = {
		action_off = function (pos, node)
			mesecon:swap_node(pos, "mesecons_lightstone:lightstone_off")
		end
	}}
})

minetest.register_craft({
    output = "node mesecons_lightstone:lightstone_off",
    recipe = {
	    {'',"mesecons:redstone",''},
	    {"mesecons:redstone",'mcl_core:glowstone',"mesecons:redstone"},
	    {'','mesecons:redstone',''},
    }
})
