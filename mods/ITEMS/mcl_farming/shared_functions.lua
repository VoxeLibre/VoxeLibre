local plant_lists = {}

function mcl_farming:add_plant(identifier, full_grown, names, interval, chance)
	plant_lists[identifier] = {}
	plant_lists[identifier].full_grown = full_grown
	plant_lists[identifier].names = names
	minetest.register_abm({
		label = string.format("Farming plant growth (%s)", identifier),
		nodenames = names,
		interval = interval,
		chance = chance,
		action = function(pos, node)
			if minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name ~= "mcl_farming:soil_wet" and math.random(0, 9) > 0 then
				return
			else
				mcl_farming:grow_plant(identifier, pos, node)
			end
		end,
	})
end

-- Attempts to advance a plant at pos by one or more growth stages (if possible)
-- identifier: Identifier of plant as defined by mcl_farming:add_plant
-- pos: Position
-- node: Node table
-- stages: Number of stages to advance (optional, defaults to 1)
-- ignore_light: if true, ignore light requirements for growing

-- Returns true if plant has been grown by 1 or more stages.
-- Returns false if nothing changed.
function mcl_farming:grow_plant(identifier, pos, node, stages, ignore_light)
	if not minetest.get_node_light(pos) and not ignore_light then
		return false
	end
	if minetest.get_node_light(pos) < 10 and not ignore_light then
		return false
	end

	local plant_info = plant_lists[identifier]
	local step = nil

	for i, name in ipairs(plant_info.names) do
		if name == node.name then
			step = i
			break
		end
	end
	if step == nil then
		return false
	end
	if not stages then
		stages = 1
	end
	local new_node = {name = plant_info.names[step+stages]}
	if new_node.name == nil then
		new_node.name = plant_info.full_grown
	end
	new_node.param = node.param
	new_node.param2 = node.param2
	minetest.set_node(pos, new_node)
	return true
end

function mcl_farming:place_seed(itemstack, placer, pointed_thing, plantname)
	local pt = pointed_thing
	if not pt then
		return
	end
	if pt.type ~= "node" then
		return
	end

	-- Use pointed node's on_rightclick function first, if present
	local node = minetest.get_node(pt.under)
	if placer and not placer:get_player_control().sneak then
		if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
			return minetest.registered_nodes[node.name].on_rightclick(pt.under, node, placer, itemstack) or itemstack
		end
	end

	local pos = {x=pt.above.x, y=pt.above.y-1, z=pt.above.z}
	local farmland = minetest.get_node(pos)
	pos= {x=pt.above.x, y=pt.above.y, z=pt.above.z}
	local place_s = minetest.get_node(pos)

	if string.find(farmland.name, "mcl_farming:soil") and string.find(place_s.name, "air")  then
		minetest.sound_play(minetest.registered_nodes[plantname].sounds.place, {pos = pos}, true)
		minetest.add_node(pos, {name=plantname, param2 = minetest.registered_nodes[plantname].place_param2})
	else
		return
	end

	if not minetest.is_creative_enabled(placer:get_player_name()) then
		itemstack:take_item()
	end
	return itemstack
end


--[[ Helper function to create a gourd (e.g. melon, pumpkin), the connected stem nodes as

- full_unconnected_stem: itemstring of the full-grown but unconnceted stem node. This node must already be done
- connected_stem_basename: prefix of the itemstrings used for the 4 connected stem nodes to create
- stem_itemstring: Desired itemstring of the fully-grown unconnected stem node
- stem_def: Partial node definition of the fully-grown unconnected stem node. Many fields are already defined. You need to add `tiles` and `description` at minimum. Don't define on_construct without good reason
- stem_drop: Drop probability table for all stem
- gourd_itemstring: Desired itemstring of the full gourd node
- gourd_def: (almost) full definition of the gourd node. This function will add on_construct and after_dig_node to the definition for unconnecting any connected stems
- grow_interval: Will attempt to grow a gourd periodically at this interval in seconds
- grow_chance: Chance of 1/grow_chance to grow a gourd next to the full unconnected stem after grow_interval has passed. Must be a natural number
- connected_stem_texture: Texture of the connected stem
- gourd_on_construct_extra: Custom on_construct extra function for the gourd. Will be called after the stem check code
]]

function mcl_farming:add_gourd(full_unconnected_stem, connected_stem_basename, stem_itemstring, stem_def, stem_drop, gourd_itemstring, gourd_def, grow_interval, grow_chance, connected_stem_texture, gourd_on_construct_extra)

	local connected_stem_names = { 
		connected_stem_basename .. "_r",
		connected_stem_basename .. "_l",
		connected_stem_basename .. "_t",
		connected_stem_basename .. "_b",
	}

	local neighbors = {
		{ x=-1, y=0, z=0 },
		{ x=1, y=0, z=0 },
		{ x=0, y=0, z=-1 },
		{ x=0, y=0, z=1 },
	}

	-- Connect the stem at stempos to the first neighboring gourd block.
	-- No-op if not a stem or no gourd block found
	local try_connect_stem = function(stempos)
		local stem = minetest.get_node(stempos)
		if stem.name ~= full_unconnected_stem then
			return false
		end
		for n=1, #neighbors do
			local offset = neighbors[n]
			local blockpos = vector.add(stempos, offset)
			local block = minetest.get_node(blockpos)
			if block.name == gourd_itemstring then
				if offset.x == 1 then
					minetest.set_node(stempos, {name=connected_stem_names[1]})
				elseif offset.x == -1 then
					minetest.set_node(stempos, {name=connected_stem_names[2]})
				elseif offset.z == 1 then
					minetest.set_node(stempos, {name=connected_stem_names[3]})
				elseif offset.z == -1 then
					minetest.set_node(stempos, {name=connected_stem_names[4]})
				end
				return true
			end
		end
	end

	-- Register gourd
	if not gourd_def.after_dig_node then
		gourd_def.after_dig_node = function(blockpos, oldnode, oldmetadata, user)
			-- Disconnect any connected stems, turning them back to normal stems
			for n=1, #neighbors do
				local offset = neighbors[n]
				local expected_stem = connected_stem_names[n]
				local stempos = vector.add(blockpos, offset)
				local stem = minetest.get_node(stempos)
				if stem.name == expected_stem then
					minetest.add_node(stempos, {name=full_unconnected_stem})
					try_connect_stem(stempos)
				end
			end
		end
	end
	if not gourd_def.on_construct then
		gourd_def.on_construct = function(blockpos)
			-- Connect all unconnected stems at full size
			for n=1, #neighbors do
				local stempos = vector.add(blockpos, neighbors[n])
				try_connect_stem(stempos)
			end
			-- Call custom on_construct
			if gourd_on_construct_extra then
				gourd_on_construct_extra(blockpos)
			end
		end
	end
	minetest.register_node(gourd_itemstring, gourd_def)

	-- Register unconnected stem

	-- Default values for the stem definition
	if not stem_def.selection_box then
		stem_def.selection_box = {
			type = "fixed",
			fixed = {
				{-0.15, -0.5, -0.15, 0.15, 0.5, 0.15}
			},
		}
	end
	if not stem_def.paramtype then
		stem_def.paramtype = "light"
	end
	if not stem_def.drawtype then
		stem_def.drawtype = "plantlike"
	end
	if stem_def.walkable == nil then
		stem_def.walkable = false
	end
	if stem_def.sunlight_propagates == nil then
		stem_def.sunlight_propagates = true
	end
	if stem_def.drop == nil then
		stem_def.drop = stem_drop
	end
	if stem_def.groups == nil then
		stem_def.groups = {dig_immediate=3, not_in_creative_inventory=1, plant=1,attached_node=1, dig_by_water=1,destroy_by_lava_flow=1,}
	end
	if stem_def.sounds == nil then
		stem_def.sounds = mcl_sounds.node_sound_leaves_defaults()
	end

	if not stem_def.on_construct then
		stem_def.on_construct = function(stempos)
			-- Connect stem to gourd (if possible)
			try_connect_stem(stempos)
		end
	end
	minetest.register_node(stem_itemstring, stem_def)

	-- Register connected stems

	local connected_stem_tiles = {
		{ "blank.png", --top
		"blank.png", -- bottom
		"blank.png", -- right
		"blank.png", -- left
		connected_stem_texture, -- back
		connected_stem_texture.."^[transformFX90" --front
		},
		{ "blank.png", --top
		"blank.png", -- bottom
		"blank.png", -- right
		"blank.png", -- left
		connected_stem_texture.."^[transformFX90", --back
		connected_stem_texture, -- front
		},
		{ "blank.png", --top
		"blank.png", -- bottom
		connected_stem_texture.."^[transformFX90", -- right
		connected_stem_texture, -- left
		"blank.png", --back
		"blank.png", -- front
		},
		{ "blank.png", --top
		"blank.png", -- bottom
		connected_stem_texture, -- right
		connected_stem_texture.."^[transformFX90", -- left
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
	local connected_stem_selectionbox = {
		{-0.1, -0.5, -0.1, 0.5, 0.2, 0.1},
		{-0.5, -0.5, -0.1, 0.1, 0.2, 0.1},
		{-0.1, -0.5, -0.1, 0.1, 0.2, 0.5},
		{-0.1, -0.5, -0.5, 0.1, 0.2, 0.1},
	}

	for i=1, 4 do
		minetest.register_node(connected_stem_names[i], {
			_doc_items_create_entry = false,
			paramtype = "light",
			sunlight_propagates = true,
			walkable = false,
			drop = stem_drop,
			drawtype = "nodebox",
			node_box = {
				type = "fixed",
				fixed = connected_stem_nodebox[i]
			},
			selection_box = {
				type = "fixed",
				fixed = connected_stem_selectionbox[i]
			},
			tiles = connected_stem_tiles[i],
			groups = {dig_immediate=3, not_in_creative_inventory=1, plant=1,attached_node=1, dig_by_water=1,destroy_by_lava_flow=1,},
			sounds = mcl_sounds.node_sound_leaves_defaults(),
			_mcl_blast_resistance = 0,
		})

		if minetest.get_modpath("doc") then
			doc.add_entry_alias("nodes", full_unconnected_stem, "nodes", connected_stem_names[i])
		end
	end

	minetest.register_abm({
		label = "Grow gourd stem to gourd ("..full_unconnected_stem.." → "..gourd_itemstring..")",
		nodenames = {full_unconnected_stem},
		neighbors = {"air"},
		interval = grow_interval,
		chance = grow_chance,
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
				local floorpos, floor
				for n=#neighbors, 1, -1 do
					local offset = neighbors[n]
					local blockpos = vector.add(stempos, offset)
					floorpos = { x=blockpos.x, y=blockpos.y-1, z=blockpos.z }
					floor = minetest.get_node(floorpos)
					local block = minetest.get_node(blockpos)
					local soilgroup = minetest.get_item_group(floor.name, "soil")
					if not ((minetest.get_item_group(floor.name, "grass_block") == 1 or floor.name=="mcl_core:dirt" or soilgroup == 2 or soilgroup == 3) and block.name == "air") then
						table.remove(neighbors, n)
					end
				end

				-- Gourd needs at least 1 free neighbor to grow
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
					-- Place the gourd
					if gourd_def.paramtype2 == "facedir" then
						minetest.add_node(blockpos, {name=gourd_itemstring, param2=p2})
					else
						minetest.add_node(blockpos, {name=gourd_itemstring})
					end
					-- Reset farmland, etc. to dirt when the gourd grows on top
					if minetest.get_item_group(floor.name, "dirtifies_below_solid") == 1 then
						minetest.set_node(floorpos, {name = "mcl_core:dirt"})
					end
				end
			end
		end,
	})
end

-- Used for growing gourd stems. Returns the intermediate color between startcolor and endcolor at a step
-- * startcolor: ColorSpec in table form for the stem in its lowest growing stage
-- * endcolor: ColorSpec in table form for the stem in its final growing stage
-- * step: The nth growth step. Counting starts at 1
-- * step_count: The number of total growth steps
function mcl_farming:stem_color(startcolor, endcolor, step, step_count)
	local color = {}
	local function get_component(startt, endd, step, step_count)
		return math.floor(math.max(0, math.min(255, (startt + (((step-1)/step_count) * endd)))))
	end
	color.r = get_component(startcolor.r, endcolor.r, step, step_count)
	color.g = get_component(startcolor.g, endcolor.g, step, step_count)
	color.b = get_component(startcolor.b, endcolor.b, step, step_count)
	local colorstring = string.format("#%02X%02X%02X", color.r, color.g, color.b)
	return colorstring
end
