minetest.register_node("mesecons_lightstone:lightstone_off", {
	tiles = {"jeija_lightstone_gray_off.png"},
	inventory_image = minetest.inventorycube("jeija_lightstone_gray_off.png"),
	groups = {cracky=2, mesecon_effector_off = 1, mesecon = 2},
	description= "Redstone Lamp",
	sounds = default.node_sound_stone_defaults(),
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
	light_source = LIGHT_MAX,
	sounds = default.node_sound_stone_defaults(),
	mesecons = {effector = {
		action_off = function (pos, node)
			mesecon:swap_node(pos, "mesecons_lightstone:lightstone_off")
		end
	}}
})

minetest.register_craft({
    output = "node mesecons_lightstone:lightstone_off",
    recipe = {
	    {'',"default:redstone_dust",''},
	    {"default:redstone_dust",'default:glowstone',"default:redstone_dust"},
	    {'','default:redstone_dust',''},
    }
})
