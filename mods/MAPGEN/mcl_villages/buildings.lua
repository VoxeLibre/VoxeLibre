--[[
-------------------------------------------------------------------------------
-- build schematic, replace material, rotation
-------------------------------------------------------------------------------
function settlements.build_schematic(vm, data, va, pos, building, replace_wall, name)
  -- get building node material for better integration to surrounding
  local platform_material =  minetest.get_node_or_nil(pos)
  if not platform_material then
    return
  end
  platform_material = platform_material.name
  -- pick random material
  local material = wallmaterial[math.random(1,#wallmaterial)]
  -- schematic conversion to lua
  local schem_lua = minetest.serialize_schematic(building, 
    "lua", 
    {lua_use_comments = false, lua_num_indent_spaces = 0}).." return(schematic)"
  -- replace material
  if replace_wall == "y" then
    schem_lua = schem_lua:gsub("mcl_core:cobble", material)
  end
  schem_lua = schem_lua:gsub("mcl_core:dirt_with_grass", 
    platform_material)

--  Disable special junglewood for now.
 -- special material for spawning npcs
 -- schem_lua = schem_lua:gsub("mcl_core:junglewood", 
 --   "settlements:junglewood")
--

  -- format schematic string
  local schematic = loadstring(schem_lua)()
  -- build foundation for the building an make room above
  local width = schematic["size"]["x"]
  local depth = schematic["size"]["z"]
  local height = schematic["size"]["y"]
  local possible_rotations = {"0", "90", "180", "270"}
  local rotation = possible_rotations[ math.random( #possible_rotations ) ]
  settlements.foundation(
    pos, 
    width, 
    depth, 
    height, 
    rotation)
  vm:set_data(data)
  -- place schematic

  minetest.place_schematic_on_vmanip(
    vm, 
    pos, 
    schematic, 
    rotation, 
    nil, 
    true)
  vm:write_to_map(true)
end]]
-------------------------------------------------------------------------------
-- initialize settlement_info 
-------------------------------------------------------------------------------
function settlements.initialize_settlement_info(pr)
	local count_buildings = {}

	-- count_buildings table reset
	for k,v in pairs(schematic_table) do
		--    local name = schematic_table[v]["name"]
		count_buildings[v["name"]] = 0
	end

	-- randomize number of buildings
	local number_of_buildings = pr:next(10, 25)
	local number_built = 1
	settlements.debug("Village ".. number_of_buildings)

	return count_buildings, number_of_buildings, number_built
end
-------------------------------------------------------------------------------
-- fill settlement_info with LVM
--------------------------------------------------------------------------------
function settlements.create_site_plan_lvm(maxp, minp, pr)
	local settlement_info = {}
	local building_all_info
	local possible_rotations = {"0", "90", "180", "270"}
	-- find center of chunk
	local center = {
		x=maxp.x-half_map_chunk_size, 
		y=maxp.y, 
		z=maxp.z-half_map_chunk_size
	} 
	-- find center_surface of chunk
	local center_surface, surface_material = settlements.find_surface_lvm(center, minp)
	-- go build settlement around center
	if not center_surface then return false end

	-- add settlement to list
	table.insert(settlements_in_world, center_surface)
	-- save list to file
	settlements.save()
	-- initialize all settlement_info table
	local count_buildings, number_of_buildings, number_built = settlements.initialize_settlement_info(pr)
	-- first building is townhall in the center
	building_all_info = schematic_table[1]
	local rotation = possible_rotations[ pr:next(1, #possible_rotations ) ]
	-- add to settlement info table
	local index = 1
	settlement_info[index] = {
		pos = center_surface, 
		name = building_all_info["name"], 
		hsize = building_all_info["hsize"],
		rotat = rotation,
		surface_mat = surface_material
	}
	-- increase index for following buildings
	index = index + 1
	-- now some buildings around in a circle, radius = size of town center
	local x, z, r = center_surface.x, center_surface.z, building_all_info["hsize"]
	-- draw j circles around center and increase radius by math.random(2,5)
	for j = 1,20 do
		if number_built < number_of_buildings then 
			-- set position on imaginary circle
			for j = 0, 360, 15 do
				local angle = j * math.pi / 180
				local ptx, ptz = x + r * math.cos( angle ), z + r * math.sin( angle )
				ptx = settlements.round(ptx, 0)
				ptz = settlements.round(ptz, 0)
				local pos1 = { x=ptx, y=center_surface.y+50, z=ptz}
				local pos_surface, surface_material = settlements.find_surface_lvm(pos1, minp)
				if not pos_surface then break end

				local randomized_schematic_table = shuffle(schematic_table, pr)
				-- pick schematic
				local size = #randomized_schematic_table
				for i = size, 1, -1 do
					-- already enough buildings of that type?
					if count_buildings[randomized_schematic_table[i]["name"]] < randomized_schematic_table[i]["max_num"]*number_of_buildings then
						building_all_info = randomized_schematic_table[i]
						-- check distance to other buildings
						local distance_to_other_buildings_ok = settlements.check_distance(settlement_info, pos_surface, building_all_info["hsize"])
						if distance_to_other_buildings_ok then
							-- count built houses
							count_buildings[building_all_info["name"]] = count_buildings[building_all_info["name"]] +1

							rotation = possible_rotations[ pr:next(1, #possible_rotations ) ]
							number_built = number_built + 1
							settlement_info[index] = {
								pos = pos_surface, 
								name = building_all_info["name"], 
								hsize = building_all_info["hsize"],
								rotat = rotation,
								surface_mat = surface_material
							}
							index = index + 1
							break
						end
					end
				end
				if number_of_buildings == number_built then
					break
				end
			end
			r = r + pr:next(2,5)
		end
	end
	settlements.debug("really ".. number_built)
	return settlement_info
end
-------------------------------------------------------------------------------
-- fill settlement_info
--------------------------------------------------------------------------------
function settlements.create_site_plan(maxp, minp, pr)
	local settlement_info = {}
	local building_all_info
	local possible_rotations = {"0", "90", "180", "270"}
	-- find center of chunk
	local center = {
		x=maxp.x-half_map_chunk_size, 
		y=maxp.y, 
		z=maxp.z-half_map_chunk_size
	} 
	-- find center_surface of chunk
	local center_surface , surface_material = settlements.find_surface(center)
	-- go build settlement around center
	if not center_surface then return false end

	-- add settlement to list
	table.insert(settlements_in_world, center_surface)
	-- save list to file
	settlements.save()
	-- initialize all settlement_info table
	local count_buildings, number_of_buildings, number_built = settlements.initialize_settlement_info(pr)
	-- first building is townhall in the center
	building_all_info = schematic_table[1]
	local rotation = possible_rotations[ pr:next(1, #possible_rotations ) ]
	-- add to settlement info table
	local index = 1
	settlement_info[index] = {
		pos = center_surface, 
		name = building_all_info["name"], 
		hsize = building_all_info["hsize"],
		rotat = rotation,
		surface_mat = surface_material
	}
	--increase index for following buildings
	index = index + 1
	-- now some buildings around in a circle, radius = size of town center
	local x, z, r = center_surface.x, center_surface.z, building_all_info["hsize"]
	-- draw j circles around center and increase radius by math.random(2,5)
	for j = 1,20 do
		if number_built < number_of_buildings then
			-- set position on imaginary circle
			for j = 0, 360, 15 do
				local angle = j * math.pi / 180
				local ptx, ptz = x + r * math.cos( angle ), z + r * math.sin( angle )
				ptx = settlements.round(ptx, 0)
				ptz = settlements.round(ptz, 0)
				local pos1 = { x=ptx, y=center_surface.y+50, z=ptz}
				local pos_surface, surface_material = settlements.find_surface(pos1)
				if not pos_surface then break end

				local randomized_schematic_table = shuffle(schematic_table, pr)
				-- pick schematic
				local size = #randomized_schematic_table
				for i = size, 1, -1 do
					-- already enough buildings of that type?
					if count_buildings[randomized_schematic_table[i]["name"]] < randomized_schematic_table[i]["max_num"]*number_of_buildings then
						building_all_info = randomized_schematic_table[i]
						-- check distance to other buildings
						local distance_to_other_buildings_ok = settlements.check_distance(settlement_info, pos_surface, building_all_info["hsize"])
						if distance_to_other_buildings_ok then
							-- count built houses
							count_buildings[building_all_info["name"]] = count_buildings[building_all_info["name"]] +1
							rotation = possible_rotations[ pr:next(1, #possible_rotations ) ]
							number_built = number_built + 1
							settlement_info[index] = {
								pos = pos_surface, 
								name = building_all_info["name"], 
								hsize = building_all_info["hsize"],
								rotat = rotation,
								surface_mat = surface_material
							}
							index = index + 1
							break
						end
					end
				end
				if number_of_buildings == number_built then
					break
				end
			end
			r = r + pr:next(2,5)
		end
	end
	settlements.debug("really ".. number_built)
	return settlement_info
end
-------------------------------------------------------------------------------
-- evaluate settlement_info and place schematics
-------------------------------------------------------------------------------
function settlements.place_schematics_lvm(settlement_info, pr)
	for i, built_house in ipairs(settlement_info) do
		for j, schem in ipairs(schematic_table) do
			if settlement_info[i]["name"] == schem["name"] then
				building_all_info = schem
				break
			end
		end

		local pos = settlement_info[i]["pos"] 
		local rotation = settlement_info[i]["rotat"] 
		-- get building node material for better integration to surrounding
		local platform_material = settlement_info[i]["surface_mat"]
		platform_material_name = minetest.get_name_from_content_id(platform_material)
		-- pick random material
		--local material = wallmaterial[pr:next(1,#wallmaterial)]
		--
		local building = building_all_info["mts"]
		local replace_wall = building_all_info["rplc"]
		-- schematic conversion to lua
		local schem_lua = minetest.serialize_schematic(building, 
			"lua", 
			{lua_use_comments = false, lua_num_indent_spaces = 0}).." return(schematic)"
		-- replace material
		if replace_wall == "y" then
			--Note, block substitution isn't matching node names exactly; so nodes that are to be substituted that have the same prefixes cause bugs.
			-- Example: Attempting to swap out 'mcl_core:stonebrick'; which has multiple, additional sub-variants: (carved, cracked, mossy). Will currently cause issues, so leaving disabled.
			if platform_material == "mcl_core:snow" or platform_material == "mcl_core:dirt_with_grass_snow" or platform_material == "mcl_core:podzol" then
				schem_lua = schem_lua:gsub("mcl_core:tree", "mcl_core:sprucetree")
				schem_lua = schem_lua:gsub("mcl_core:wood", "mcl_core:sprucewood")
				--schem_lua = schem_lua:gsub("mcl_fences:fence", "mcl_fences:spruce_fence")
				--schem_lua = schem_lua:gsub("mcl_stairs:slab_wood_top", "mcl_stairs:slab_sprucewood_top")
				--schem_lua = schem_lua:gsub("mcl_stairs:stair_wood", "mcl_stairs:stair_sprucewood")
				--schem_lua = schem_lua:gsub("mesecons_pressureplates:pressure_plate_wood_off", "mesecons_pressureplates:pressure_plate_sprucewood_off")
			elseif platform_material == "mcl_core:sand" or platform_material == "mcl_core:redsand" then
				schem_lua = schem_lua:gsub("mcl_core:tree", "mcl_core:sandstonecarved")
				schem_lua = schem_lua:gsub("mcl_core:cobble", "mcl_core:sandstone")
				schem_lua = schem_lua:gsub("mcl_core:wood", "mcl_core:sandstonesmooth")
				--schem_lua = schem_lua:gsub("mcl_fences:fence", "mcl_fences:birch_fence")
				--schem_lua = schem_lua:gsub("mcl_stairs:slab_wood_top", "mcl_stairs:slab_birchwood_top")
				--schem_lua = schem_lua:gsub("mcl_stairs:stair_wood", "mcl_stairs:stair_birchwood")
				--schem_lua = schem_lua:gsub("mesecons_pressureplates:pressure_plate_wood_off", "mesecons_pressureplates:pressure_plate_birchwood_off")
				--schem_lua = schem_lua:gsub("mcl_stairs:stair_stonebrick", "mcl_stairs:stair_redsandstone")
				--schem_lua = schem_lua:gsub("mcl_core:stonebrick", "mcl_core:redsandstonesmooth")
				schem_lua = schem_lua:gsub("mcl_core:brick_block", "mcl_core:redsandstone")
			end
		end
		schem_lua = schem_lua:gsub("mcl_core:dirt_with_grass", platform_material_name)

		--[[ Disable special junglewood for now.
		-- special material for spawning npcs
		schem_lua = schem_lua:gsub("mcl_core:junglewood", "settlements:junglewood")
		--]]
		-- format schematic string
		local schematic = loadstring(schem_lua)()
		-- build foundation for the building an make room above
		-- place schematic

		minetest.place_schematic_on_vmanip(
			vm, 
			pos, 
			schematic, 
			rotation, 
			nil, 
			true)
	  end
end
-------------------------------------------------------------------------------
-- evaluate settlement_info and place schematics
-------------------------------------------------------------------------------
function settlements.place_schematics(settlement_info, pr)
	local building_all_info
	for i, built_house in ipairs(settlement_info) do
		for j, schem in ipairs(schematic_table) do
			if settlement_info[i]["name"] == schem["name"] then
				building_all_info = schem
				break
			end
		end

		local pos = settlement_info[i]["pos"] 
		local rotation = settlement_info[i]["rotat"] 
		-- get building node material for better integration to surrounding
		local platform_material =  settlement_info[i]["surface_mat"] 
		--platform_material_name = minetest.get_name_from_content_id(platform_material)
		-- pick random material
		--local material = wallmaterial[pr:next(1,#wallmaterial)]
		--
		local building = building_all_info["mts"]
		local replace_wall = building_all_info["rplc"]
		-- schematic conversion to lua
		local schem_lua = minetest.serialize_schematic(building, 
			"lua", 
			{lua_use_comments = false, lua_num_indent_spaces = 0}).." return(schematic)"
		-- replace material
		if replace_wall == "y" then
			--Note, block substitution isn't matching node names exactly; so nodes that are to be substituted that have the same prefixes cause bugs.
			-- Example: Attempting to swap out 'mcl_core:stonebrick'; which has multiple, additional sub-variants: (carved, cracked, mossy). Will currently cause issues, so leaving disabled.
			if platform_material == "mcl_core:snow" or platform_material == "mcl_core:dirt_with_grass_snow" or platform_material == "mcl_core:podzol" then
				schem_lua = schem_lua:gsub("mcl_core:tree", "mcl_core:sprucetree")
				schem_lua = schem_lua:gsub("mcl_core:wood", "mcl_core:sprucewood")
				--schem_lua = schem_lua:gsub("mcl_fences:fence", "mcl_fences:spruce_fence")
				--schem_lua = schem_lua:gsub("mcl_stairs:slab_wood_top", "mcl_stairs:slab_sprucewood_top")
				--schem_lua = schem_lua:gsub("mcl_stairs:stair_wood", "mcl_stairs:stair_sprucewood")
				--schem_lua = schem_lua:gsub("mesecons_pressureplates:pressure_plate_wood_off", "mesecons_pressureplates:pressure_plate_sprucewood_off")
			elseif platform_material == "mcl_core:sand" or platform_material == "mcl_core:redsand" then
				schem_lua = schem_lua:gsub("mcl_core:tree", "mcl_core:sandstonecarved")
				schem_lua = schem_lua:gsub("mcl_core:cobble", "mcl_core:sandstone")
				schem_lua = schem_lua:gsub("mcl_core:wood", "mcl_core:sandstonesmooth")
				--schem_lua = schem_lua:gsub("mcl_fences:fence", "mcl_fences:birch_fence")
				--schem_lua = schem_lua:gsub("mcl_stairs:slab_wood_top", "mcl_stairs:slab_birchwood_top")
				--schem_lua = schem_lua:gsub("mcl_stairs:stair_wood", "mcl_stairs:stair_birchwood")
				--schem_lua = schem_lua:gsub("mesecons_pressureplates:pressure_plate_wood_off", "mesecons_pressureplates:pressure_plate_birchwood_off")
				--schem_lua = schem_lua:gsub("mcl_stairs:stair_stonebrick", "mcl_stairs:stair_redsandstone")
				--schem_lua = schem_lua:gsub("mcl_core:stonebrick", "mcl_core:redsandstonesmooth")
				schem_lua = schem_lua:gsub("mcl_core:brick_block", "mcl_core:redsandstone")
			end
		end
		schem_lua = schem_lua:gsub("mcl_core:dirt_with_grass", platform_material)

		--[[ Disable special junglewood for now.
		-- special material for spawning npcs
		schem_lua = schem_lua:gsub("mcl_core:junglewood", "settlements:junglewood")
		--]]

		schem_lua = schem_lua:gsub("mcl_stairs:stair_wood_outer", "mcl_stairs:slab_wood")
		schem_lua = schem_lua:gsub("mcl_stairs:stair_stone_rough_outer", "air")

		-- format schematic string
		local schematic = loadstring(schem_lua)()
		-- build foundation for the building an make room above
		-- place schematic
		minetest.place_schematic(
			pos, 
			schematic, 
			rotation, 
			nil, 
			true)
	end
end
