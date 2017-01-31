minetest.register_node("mcl_farming:soil", {
	tiles = {"farming_soil.png", "default_dirt.png", "default_dirt.png", "default_dirt.png", "default_dirt.png", "default_dirt.png"},
	description = "Farmland",
	drop = "mcl_core:dirt",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			-- 15/16 of the normal height
			{-0.5, -0.5, -0.5, 0.5, 0.4375, 0.5},
		}
	},
	groups = { crumbly=3, not_in_creative_inventory=1, soil=2, soil_sapling=1 },
	sounds = mcl_core.node_sound_dirt_defaults(),
})

minetest.register_node("mcl_farming:soil_wet", {
	tiles = {"farming_soil_wet.png", "default_dirt.png", "default_dirt.png", "default_dirt.png", "default_dirt.png", "default_dirt.png"},
	description = "Hydrated Farmland",
	drop = "mcl_core:dirt",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.4375, 0.5},
		}
	},
	groups = { crumbly=3, not_in_creative_inventory=1, soil=3, soil_sapling=1 },
	sounds = mcl_core.node_sound_dirt_defaults(),
})

minetest.register_abm({
	nodenames = {"mcl_farming:soil"},
	interval = 15,
	chance = 3,
	action = function(pos, node)
		if minetest.find_node_near(pos, 3, {"mcl_core:water_source", "mcl_core:water_flowing"}) then
			node.name = "mcl_farming:soil_wet"
			minetest.set_node(pos, node)
		end
	end,
})

