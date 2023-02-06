local get_node = mcl_vars.get_node

-------------------------------------------------------------------------------
-- function to copy tables
-------------------------------------------------------------------------------
function settlements.shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end
--
--
--
function settlements.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

-------------------------------------------------------------------------------
-- function to find surface block y coordinate
-- returns surface postion
-------------------------------------------------------------------------------
function settlements.find_surface(pos, wait)
	local p6 = vector.new(pos)
	local cnt = 0
	local itter = 1 -- count up or down
	local cnt_max = 200
	-- check, in which direction to look for surface
	local surface_node
	if wait then
		surface_node = get_node(p6, true, 10000000)
	else
		surface_node = get_node(p6)
	end
	if surface_node.name=="air" or surface_node.name=="ignore" then
		itter = -1
	end
	-- go through nodes an find surface
	while cnt < cnt_max do
		-- Check Surface_node and Node above
		if surface_node and settlements.surface_mat[surface_node.name] then
			local surface_node_plus_1 = get_node({ x=p6.x, y=p6.y+1, z=p6.z})

			if surface_node_plus_1 then

				local surface_node_minus_1 = get_node({ x=p6.x, y=p6.y-1, z=p6.z})
				local is_leaf_below  = minetest.get_item_group(surface_node_minus_1, "leaves") ~= 0 or
						string.find(surface_node_minus_1.name,"leaves")

				if not is_leaf_below and ((string.find(surface_node_plus_1.name,"air") or
					string.find(surface_node_plus_1.name,"fern") or
					string.find(surface_node_plus_1.name,"flower") or
					string.find(surface_node_plus_1.name,"bush") or
					string.find(surface_node_plus_1.name,"tree") or
					string.find(surface_node_plus_1.name,"grass")) or
					string.find(surface_node_plus_1.name,"snow"))
				then
					settlements.debug("find_surface success: " ..surface_node.name.. " " .. surface_node_plus_1.name)
					settlements.debug("node below: " .. tostring(surface_node_minus_1.name))
					settlements.debug("node below leaves group: " .. tostring(minetest.get_item_group(surface_node_minus_1, "leaves")))
					return p6, surface_node.name
				else
					settlements.debug("find_surface2: wrong surface+1")
				end
			else
				settlements.debug("find_surface8: missing node or plus_1")
			end
		else
			settlements.debug("find_surface3: wrong surface "..surface_node.name.." at pos "..minetest.pos_to_string(p6))
		end

		p6.y = p6.y + itter
		if p6.y < 0 then
			settlements.debug("find_surface4: y<0")
			return nil
		end
		cnt = cnt+1
		surface_node = get_node(p6)
	end
	settlements.debug("find_surface5: cnt_max overflow")
	return nil
end
-------------------------------------------------------------------------------
-- check distance for new building
-------------------------------------------------------------------------------
function settlements.check_distance(settlement_info, building_pos, building_size)
	local distance
	for i, built_house in ipairs(settlement_info) do
		distance = math.sqrt(
			((building_pos.x - built_house["pos"].x)*(building_pos.x - built_house["pos"].x))+
			((building_pos.z - built_house["pos"].z)*(building_pos.z - built_house["pos"].z)))
		if distance < building_size or distance < built_house["hsize"] then
			return false
		end
	end
	return true
end
-------------------------------------------------------------------------------
-- fill chests
-------------------------------------------------------------------------------
function settlements.fill_chest(pos, pr)
	-- initialize chest (mts chests don't have meta)
	local meta = minetest.get_meta(pos)
	if meta:get_string("infotext") ~= "Chest" then
		-- For MineClone2 0.70 or before
		-- minetest.registered_nodes["mcl_chests:chest"].on_construct(pos)
		--
		-- For MineClone2 after commit 09ab1482b5 (the new entity chests)
		minetest.registered_nodes["mcl_chests:chest_small"].on_construct(pos)
	end
	-- fill chest
	local inv = minetest.get_inventory( {type="node", pos=pos} )

	local function get_treasures(prand)
		local loottable = {{
			stacks_min = 3,
			stacks_max = 8,
			items = {
				{ itemstring = "mcl_core:diamond", weight = 3, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_core:iron_ingot", weight = 10, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:gold_ingot", weight = 5, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_farming:bread", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_core:apple", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_tools:pick_iron", weight = 5 },
				{ itemstring = "mcl_tools:sword_iron", weight = 5 },
				{ itemstring = "mcl_armor:chestplate_iron", weight = 5 },
				{ itemstring = "mcl_armor:helmet_iron", weight = 5 },
				{ itemstring = "mcl_armor:leggings_iron", weight = 5 },
				{ itemstring = "mcl_armor:boots_iron", weight = 5 },
				{ itemstring = "mcl_core:obsidian", weight = 5, amount_min = 3, amount_max = 7 },
				{ itemstring = "mcl_core:sapling", weight = 5, amount_min = 3, amount_max = 7 },
				{ itemstring = "mcl_mobitems:saddle", weight = 3 },
				{ itemstring = "mcl_mobitems:iron_horse_armor", weight = 1 },
				{ itemstring = "mcl_mobitems:gold_horse_armor", weight = 1 },
				{ itemstring = "mcl_mobitems:diamond_horse_armor", weight = 1 },
			}
		}}
		local items = mcl_loot.get_multi_loot(loottable, prand)
		return items
	end

	local items = get_treasures(pr)
	mcl_loot.fill_inventory(inv, "main", items, pr)
end

-------------------------------------------------------------------------------
-- initialize furnace
-------------------------------------------------------------------------------
function settlements.initialize_furnace(pos)
  -- find chests within radius
  local furnacepos = minetest.find_node_near(pos,
    7, --radius
    {"mcl_furnaces:furnace"})
  -- initialize furnacepos (mts furnacepos don't have meta)
  if furnacepos
  then
    local meta = minetest.get_meta(furnacepos)
    if meta:get_string("infotext") ~= "furnace"
    then
      minetest.registered_nodes["mcl_furnaces:furnace"].on_construct(furnacepos)
    end
  end
end
-------------------------------------------------------------------------------
-- initialize anvil
-------------------------------------------------------------------------------
function settlements.initialize_anvil(pos)
  -- find chests within radius
  local anvilpos = minetest.find_node_near(pos,
    7, --radius
    {"mcl_anvils:anvil"})
  -- initialize anvilpos (mts anvilpos don't have meta)
  if anvilpos
  then
    local meta = minetest.get_meta(anvilpos)
    if meta:get_string("infotext") ~= "anvil"
    then
      minetest.registered_nodes["mcl_anvils:anvil"].on_construct(anvilpos)
    end
  end
end
-------------------------------------------------------------------------------
-- randomize table
-------------------------------------------------------------------------------
function shuffle(tbl, pr)
	local table = settlements.shallowCopy(tbl)
	local size = #table
	for i = size, 1, -1 do
		local rand = pr:next(1, size)
		table[i], table[rand] = table[rand], table[i]
	end
	return table
end
-------------------------------------------------------------------------------
-- evaluate heightmap
-------------------------------------------------------------------------------
function settlements.evaluate_heightmap()
	local heightmap = minetest.get_mapgen_object("heightmap")

	if not heightmap then
		minetest.log("action", "No heightmap. That should not happen")
		return max_height_difference + 1
	end

	--minetest.log("action", "heightmap size: " .. tostring(#heightmap))

	-- max height and min height, initialize with impossible values for easier first time setting
	local max_y = -50000
	local min_y = 50000
	-- only evaluate the center square of heightmap 40 x 40
	local square_start = 1621
	local square_end = 1661
	for j = 1 , 40, 1 do
		if square_start >= #heightmap then
			--minetest.log("action", "Heightmap size reached. Go no further outside")
			break
		end
		for i = square_start, square_end, 1 do
			--minetest.log("action", "current hm index: " .. tostring(i) .. "current hm entry: " .. tostring(heightmap[i]))

			if i >= #heightmap then
				--minetest.log("action", "Heightmap size reached. Go no further")
				break
			end
			local current_hm_entry = heightmap[i]
			if current_hm_entry then
				-- skip buggy heightmaps, return high value. Converted mcl5 maps can be -31007
				if current_hm_entry == -31000 or heightmap[i] == 31000 then
					--minetest.log("action", "incorrect heighmap values. abandon")
					return max_height_difference + 1
				end
				if current_hm_entry < min_y then
					min_y = current_hm_entry
				end
				if current_hm_entry > max_y then
					max_y = current_hm_entry
				end
			else
				--minetest.log("action", "Failed to get hm index: " .. tostring(i) .. "and ... " .. tostring(#heightmap))
			end
		end
		-- set next line
		square_start = square_start + 80
		square_end = square_end + 80
	end
	-- return the difference between highest and lowest pos in chunk
	local height_diff = max_y - min_y

	--minetest.log("action", "height_diff = " .. tostring(height_diff))

	-- filter buggy heightmaps
	if height_diff <= 1 then
		return max_height_difference + 1
	end
	--minetest.log("action", "return heigh diff = " .. tostring(height_diff))
	-- debug info
	settlements.debug("heightdiff ".. height_diff)
	return height_diff
end
-------------------------------------------------------------------------------
-- Set array to list
-- https://stackoverflow.com/questions/656199/search-for-an-item-in-a-lua-list
-------------------------------------------------------------------------------
function settlements.Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end
