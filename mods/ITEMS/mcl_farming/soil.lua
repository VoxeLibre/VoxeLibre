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
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("wet", 0)
	end,
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
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("wet", 7)
	end,
	groups = {handy=1,shovely=1, not_in_creative_inventory=1, soil=3, soil_sapling=1 },
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 3,
	_mcl_hardness = 0.6,
})

minetest.register_abm({
	label = "Farmland hydration",
	nodenames = {"mcl_farming:soil", "mcl_farming:soil_wet"},
	interval = 15,
	chance = 4,
	action = function(pos, node)
		-- Get wetness value
		local meta = minetest.get_meta(pos)
		local wet = meta:get_int("wet")
		if not wet then
			if node.name == "mcl_farming:soil" then
				wet = 0
			else
				wet = 7
			end
		end

		-- Turn back into dirt when covered by solid node
		local above_node = minetest.get_node_or_nil({x=pos.x,y=pos.y+1,z=pos.z})
		if above_node then
			if minetest.get_item_group(above_node.name, "solid") ~= 0 then
				node.name = "mcl_core:dirt"
				minetest.set_node(pos, node)
				return
			end
		end

		-- Check an area of 9×2×9 around the node for nodename
		local check_surroundings = function(pos, nodename)
			local nodes = minetest.find_nodes_in_area({x=pos.x-4,y=pos.y-1,z=pos.z-4}, {x=pos.x+4,y=pos.y,z=pos.z+4}, {nodename})
			return #nodes > 0
		end

		if check_surroundings(pos, "group:water") then
			if node.name ~= "mcl_farming:soil_wet" then
				-- Make it wet
				node.name = "mcl_farming:soil_wet"
				minetest.set_node(pos, node)
			end
		else
			-- Decay if no water is nearby.
			-- But not near unloaded areas since thse might include water.
			if not check_surroundings(pos, "ignore") then
				if wet <= 0 then
					local n_def = minetest.registered_nodes[node.name] or nil
					local nn = minetest.get_node_or_nil({x=pos.x,y=pos.y+1,z=pos.z})
					if not nn or not nn.name then
						return
					end
					local nn_def = minetest.registered_nodes[nn.name] or nil

					if nn_def and minetest.get_item_group(nn.name, "plant") == 0 then
						node.name = "mcl_core:dirt"
						minetest.set_node(pos, node)
						return
					end
				else
					if wet == 7 then
						node.name = "mcl_farming:soil"
						minetest.swap_node(pos, node)
					end
					-- Slowly count down wetness
					meta:set_int("wet", wet-1)
				end
			end
		end
	end,
})
