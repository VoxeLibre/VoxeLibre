minetest.register_node("mcl_farming:soil", {
	tiles = {"farming_soil.png", "default_dirt.png", "default_dirt.png", "default_dirt.png", "default_dirt.png", "default_dirt.png"},
	description = "Farmland",
	_doc_items_longdesc = "Farmland is used for farming, a necessary surface to plant crops. It is created when a hoe is used on dirt or a similar block. Plants are able to grow on farmland, but slowly. Farmland will become hydrated farmland (on which plants grow faster) when it rains or a water source is nearby.",
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
	groups = {handy=1,shovely=1, not_in_creative_inventory=1, soil=2, soil_sapling=1 },
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 0.6,
})

minetest.register_node("mcl_farming:soil_wet", {
	tiles = {"farming_soil_wet.png", "default_dirt.png", "default_dirt.png", "default_dirt.png", "default_dirt.png", "default_dirt.png"},
	description = "Hydrated Farmland",
	_doc_items_longdesc = "Hydrated farmland is used in farming, this is where you can plant and grow some plants. It is created when farmlands is under rain or near water.",
	drop = "mcl_core:dirt",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.4375, 0.5},
		}
	},
	groups = {handy=1,shovely=1, not_in_creative_inventory=1, soil=3, soil_sapling=1 },
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 0.6,
})

minetest.register_abm({
	nodenames = {"mcl_farming:soil"},
	interval = 15,
	chance = 3,
	action = function(pos, node)
		if minetest.find_node_near(pos, 4, {"mcl_core:water_source", "mcl_core:water_flowing"}) then
			node.name = "mcl_farming:soil_wet"
			minetest.set_node(pos, node)
		end
	end,
})

