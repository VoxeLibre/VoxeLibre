minetest.register_node("mesecons_lightstone:lightstone_off", {
	tiles = {"jeija_lightstone_gray_off.png"},
	inventory_image = minetest.inventorycube("jeija_lightstone_gray_off.png"),
	groups = {handy=1, mesecon_effector_off = 1, mesecon = 2},
	is_ground_content = false,
	description= "Redstone Lamp",
	_doc_items_longdesc = "Redstone lamps are simple redstone components which glow brightly (light level 14) when they receive redstone power.",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {effector = {
		action_on = function (pos, node)
			mesecon:swap_node(pos, "mesecons_lightstone:lightstone_on")
		end
	}},
	_mcl_blast_resistance = 1.5,
	_mcl_hardness = 0.3,
})

minetest.register_node("mesecons_lightstone:lightstone_on", {
	tiles = {"jeija_lightstone_gray_on.png"},
	inventory_image = minetest.inventorycube("jeija_lightstone_gray_off.png"),
	groups = {handy=1, not_in_creative_inventory=1, mesecon = 2},
	drop = "node mesecons_lightstone:lightstone_off",
	is_ground_content = false,
	-- Real light level: 15 (Minetest caps at 14)
	light_source = 14,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {effector = {
		action_off = function (pos, node)
			mesecon:swap_node(pos, "mesecons_lightstone:lightstone_off")
		end
	}},
	_mcl_blast_resistance = 1.5,
	_mcl_hardness = 0.3,
})

minetest.register_craft({
    output = "mesecons_lightstone:lightstone_off",
    recipe = {
	    {'',"mesecons:redstone",''},
	    {"mesecons:redstone",'mcl_nether:glowstone',"mesecons:redstone"},
	    {'','mesecons:redstone',''},
    }
})

-- Add entry alias for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mesecons_lightstone:lightstone_off", "nodes", "mesecons_lightstone:lightstone_on")
end

