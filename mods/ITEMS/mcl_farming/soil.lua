local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_node("mcl_farming:soil", {
	tiles = {"mcl_farming_farmland_dry.png", "default_dirt.png"},
	description = S("Farmland"),
	_tt_help = S("Surface for crops").."\n"..S("Can become wet"),
	_doc_items_longdesc = S("Farmland is used for farming, a necessary surface to plant crops. It is created when a hoe is used on dirt or a similar block. Plants are able to grow on farmland, but slowly. Farmland will become hydrated farmland (on which plants grow faster) when it rains or a water source is nearby. This block will turn back to dirt when a solid block appears above it or a piston arm extends above it."),
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
	groups = {handy=1,shovely=1, dirtifies_below_solid=1, dirtifier=1, soil=2, soil_sapling=1, deco_block=1, cultivatable=1 },
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0.6,
	_mcl_hardness = 0.6,
})

minetest.register_node("mcl_farming:soil_wet", {
	tiles = {"mcl_farming_farmland_wet.png", "default_dirt.png"},
	description = S("Hydrated Farmland"),
	_doc_items_longdesc = S("Hydrated farmland is used in farming, this is where you can plant and grow some plants. It is created when farmland is under rain or near water. Without water, this block will dry out eventually. This block will turn back to dirt when a solid block appears above it or a piston arm extends above it."),
	drop = "mcl_core:dirt",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.4375, 0.5},
		}
	},
	groups = {handy=1,shovely=1, not_in_creative_inventory=1, dirtifies_below_solid=1, dirtifier=1, soil=3, soil_sapling=1 },
	sounds = mcl_sounds.node_sound_dirt_defaults(),
	_mcl_blast_resistance = 0.6,
	_mcl_hardness = 0.6,
})

minetest.register_abm({
	label = "Farmland hydration",
	nodenames = {"mcl_farming:soil", "mcl_farming:soil_wet"},
	interval = 2.73,
	chance = 25,
	action = function(pos, node)
		-- Turn back into dirt when covered by solid node
		local above_node = minetest.get_node_or_nil(vector.offset(pos, 0, 1, 0))
		if above_node and minetest.get_item_group(above_node.name, "solid") ~= 0 then
			node.name = "mcl_core:dirt"
			minetest.set_node(pos, node)
			return
		end

		-- in rain, become wet, do not decay
		if mcl_weather and mcl_weather.rain.raining and mcl_weather.is_outdoor(pos) then
			if node.name == "mcl_farming:soil" then
				node.name = "mcl_farming:soil_wet"
				minetest.set_node(pos, node)
			end
			return
		end

		-- Check an area of 9x2x9 around the node for nodename (9x9 on same level and 9x9 above)
		-- include "ignore" to detect unloaded blocks
		local nodes, counts = minetest.find_nodes_in_area(vector.offset(pos, -4, 0, -4), vector.offset(pos, 4, 1, 4), {"group:water", "ignore"})
		local ignore = counts.ignore or 0
		local has_water, fully_loaded = #nodes > ignore, ignore == 0

		-- Hydrate by rain or water, do not decay
		if has_water then
			if node.name == "mcl_farming:soil" then
				node.name = "mcl_farming:soil_wet"
				minetest.set_node(pos, node)
			end
			return
		end
		-- No decay near unloaded areas (ignore) since these might include water.
		if not fully_loaded then return end

		-- Decay: make wet farmland dry up
		if node.name == "mcl_farming:soil_wet" then
			node.name = "mcl_farming:soil"
			minetest.set_node(pos, node)
			return
		end
		-- Revert to dirt if wetness is 0, and no plant above
		local above = minetest.get_node_or_nil(vector.offset(pos, 0, 1, 0))
		if minetest.get_item_group(above.name, "plant") == 0 then
			node.name = "mcl_core:dirt"
			minetest.set_node(pos, node)
		end
	end,
})

