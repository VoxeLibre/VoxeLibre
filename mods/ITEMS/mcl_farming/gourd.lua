--[[ Helper function to create a gourd (e.g. melon, pumpkin), the connected stem nodes as

- full_unconnected_stem: itemstring of the full-grown but unconnceted stem node. This node must already be done
- connected_stem_basename: prefix of the itemstrings used for the 4 connected stem nodes to create
- stemdrop: Drop probability table for all stem
- gourd_itemstring: Desired itemstring of the full gourd node
- gourd_def: (almost) full definition of the gourd node, except for
]]

function mcl_farming.register_gourd(full_unconnected_stem, connected_stem_basename, stemdrop, gourd_itemstring, gourd_def)

	local connected_stem_names = { 
		connected_stem_basename .. "_r",
		connected_stem_basename .. "_l",
		connected_stem_basename .. "_t",
		connected_stem_basename .. "_b",
	}

	-- Register gourd
	if not gourd_def.after_dig_node then
		gourd_def.after_dig_node = function(blockpos, oldnode, oldmetadata, user)
			-- Disconnect any connected stems, turning them back to normal stems
			local neighbors = {
				{ x=-1, y=0, z=0 },
				{ x=1, y=0, z=0 },
				{ x=0, y=0, z=-1 },
				{ x=0, y=0, z=1 },
			}
			for n=1, #neighbors do
				local offset = neighbors[n]
				local expected_stem = connected_stem_names[n]
				local stempos = vector.add(blockpos, offset)
				local stem = minetest.get_node(stempos)
				if stem.name == expected_stem then
					minetest.add_node(stempos, {name=full_unconnected_stem})
				end
			end
		end
	end
	minetest.register_node(gourd_itemstring, gourd_def)

	-- Register connected stems

	local connected_stem_tiles = {
		{ "blank.png", --top
		"blank.png", -- bottom
		"blank.png", -- right
		"blank.png", -- left
		"farming_tige_connect.png", -- back
		"farming_tige_connect.png^[transformFX90" --front
		},
		{ "blank.png", --top
		"blank.png", -- bottom
		"blank.png", -- right
		"blank.png", -- left
		"farming_tige_connect.png^[transformFX90", --back
		"farming_tige_connect.png", -- front
		},
		{ "blank.png", --top
		"blank.png", -- bottom
		"farming_tige_connect.png^[transformFX90", -- right
		"farming_tige_connect.png", -- left
		"blank.png", --back
		"blank.png", -- front
		},
		{ "blank.png", --top
		"blank.png", -- bottom
		"farming_tige_connect.png", -- right
		"farming_tige_connect.png^[transformFX90", -- left
		"blank.png", --back
		"blank.png", -- front
		}
	}
	local connected_stem_nodebox = {
		{-0.5, -0.5, 0, 0.5, 0.5, 0},
		{-0.5, -0.5, 0, 0.5, 0.5, 0},
		{0, -0.5, -0.5, 0, 0.5, 0.5},
		{0, -0.5, -0.5, 0, 0.5, 0.5},
	}

	for i=1, 4 do
		minetest.register_node(connected_stem_names[i], {
			_doc_items_create_entry = false,
			paramtype = "light",
			sunlight_propagates = true,
			walkable = false,
			drop = stemdrop,
			drawtype = "nodebox",
			paramtype = "light",
			node_box = {
				type = "fixed",
				fixed = connected_stem_nodebox[i]
			},
			selection_box = {
				type = "fixed",
				fixed = {-0.2, -0.5, -0.2, 0.2, 0.2, 0.2}
			},
			tiles = connected_stem_tiles[i],
			groups = {dig_immediate=3, not_in_creative_inventory=1 ,dig_by_water=1},
			sounds = mcl_sounds.node_sound_leaves_defaults(),
			_mcl_blast_resistance = 0,
		})
	end

	minetest.register_abm({
		label = "Grow gourd stem to gourd ("..full_unconnected_stem.." → "..gourd_itemstring..")",
		nodenames = {full_unconnected_stem},
		neighbors = {"air"},
		-- FIXME: Times
		interval = 1,
		chance = 1,
		action = function(stempos)
			local light = minetest.get_node_light(stempos)
			if light and light > 10 then
				-- Check the four neighbors and filter out neighbors where gourds can't grow
				local neighbors = {
					{ x=-1, y=0, z=0 },
					{ x=1, y=0, z=0 },
					{ x=0, y=0, z=-1 },
					{ x=0, y=0, z=1 },
				}
				for n=#neighbors, 1, -1 do
					local offset = neighbors[n]
					local blockpos = vector.add(stempos, offset)
					local floorpos = { x=blockpos.x, y=blockpos.y-1, z=blockpos.z }
					local floor = minetest.get_node(floorpos)
					local block = minetest.get_node(blockpos)
					local soilgroup = minetest.get_item_group(floor.name, "soil")
					if not ((floor.name=="mcl_core:dirt_with_grass" or floor.name=="mcl_core:dirt" or soilgroup == 2 or soilgroup == 3) and block.name == "air") then
						table.remove(neighbors, n)
					end
				end

				-- Pumpkins need at least 1 free neighbor to grow
				if #neighbors > 0 then
					-- From the remaining neighbors, grow randomly
					local r = math.random(1, #neighbors)
					local offset = neighbors[r]
					local blockpos = vector.add(stempos, offset)
					local p2
					if offset.x == 1 then
						minetest.set_node(stempos, {name=connected_stem_names[1]})
						p2 = 3
					elseif offset.x == -1 then
						minetest.set_node(stempos, {name=connected_stem_names[2]})
						p2 = 1
					elseif offset.z == 1 then
						minetest.set_node(stempos, {name=connected_stem_names[3]})
						p2 = 2
					elseif offset.z == -1 then
						minetest.set_node(stempos, {name=connected_stem_names[4]})
						p2 = 0
					end
					minetest.add_node(blockpos, {name=gourd_itemstring, param2=p2})
				end
			end
		end,
	})
end

