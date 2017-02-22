local anvildef = {
	groups = {cracky=1, falling_node=1, deco_block=1},
	tiles = {"mcl_anvils_anvil_top_damaged_0.png^[transformR90", "mcl_anvils_anvil_base.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-6/16, -8/16, -5/16, 6/16, -6/16, 5/16},
			{-5/16, -6/16, -3/16, 5/16, 0, 3/16},
			{-7/16, -2/16, -4/16, 7/16, 4/16, 4/16}
		}
	},
	sounds = mcl_sounds.node_sound_metal_defaults(),
}

local anvildef0 = table.copy(anvildef)
anvildef0.description = "Anvil"

local anvildef1 = table.copy(anvildef)
anvildef1.description = "Slightly Damaged Anvil"
anvildef1.groups.not_in_creative_inventory = 1
anvildef1.tiles = {"mcl_anvils_anvil_top_damaged_1.png^[transformR90", "mcl_anvils_anvil_base.png"}

local anvildef2 = table.copy(anvildef)
anvildef2.description = "Very Damaged Anvil"
anvildef2.groups.not_in_creative_inventory = 1
anvildef2.tiles = {"mcl_anvils_anvil_top_damaged_2.png^[transformR90", "mcl_anvils_anvil_base.png"}

minetest.register_node("mcl_anvils:anvil", anvildef0)
minetest.register_node("mcl_anvils:anvil_damage_1", anvildef1)
minetest.register_node("mcl_anvils:anvil_damage_2", anvildef2)

minetest.register_craft({
	output = "mcl_anvils:anvil",
	recipe = {
		{ "mcl_core:ironblock", "mcl_core:ironblock", "mcl_core:ironblock" },
		{ "", "mcl_core:iron_ingot", "" },
		{ "mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot" },
	}
})
