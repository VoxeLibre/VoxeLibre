--[[
-------------------------------------------------------------------------------
-- build schematic, replace material, rotation
-------------------------------------------------------------------------------
function settlements.build_schematic(vm, data, va, pos, building, replace_wall, name)
  -- get building node material for better integration to surrounding
  local platform_material =  mcl_vars.get_node(pos)
  if not platform_material or (platform_material.name == "air" or platform_material.name == "ignore")  then
    return
  end
  platform_material = platform_material.name
  -- pick random material
  local material = wallmaterial[math.random(1,#wallmaterial)]
  -- schematic conversion to lua
  local schem_lua = minetest.serialize_schematic(building,
    "lua",
    {lua_use_comments = false, lua_num_indent_spaces = 0}).." return schematic"
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
	for k,v in pairs(settlements.schematic_table) do
		count_buildings[v["name"]] = 0
	end

	-- randomize number of buildings
	local number_of_buildings = pr:next(10, 25)
	local number_built = 1
	settlements.debug("Village ".. number_of_buildings)

	return count_buildings, number_of_buildings, number_built
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
		x=math.floor((minp.x+maxp.x)/2),
		y=maxp.y,
		z=math.floor((minp.z+maxp.z)/2)
	}

	-- find center_surface of chunk
	local center_surface , surface_material = settlements.find_surface(center, true)
	local chunks = {}
	chunks[vl_worlds.get_chunk_number(center)] = true

	-- go build settlement around center
	if not center_surface then
		minetest.log("action", "Cannot build village at: " .. minetest.pos_to_string(center))
		return false
	else
		minetest.log("action", "Village built.")
		--minetest.log("action", "Build village at: " .. minetest.pos_to_string(center) .. " with surface material: " .. surface_material)
	end

	-- initialize all settlement_info table
	local count_buildings, number_of_buildings, number_built = settlements.initialize_settlement_info(pr)
	-- first building is townhall in the center
	building_all_info = settlements.schematic_table[1]
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
		-- set position on imaginary circle
		for j = 0, 360, 15 do
			local angle = j * math.pi / 180
			local ptx, ptz = x + r * math.cos( angle ), z + r * math.sin( angle )
			ptx = settlements.round(ptx, 0)
			ptz = settlements.round(ptz, 0)
			local pos1 = { x=ptx, y=center_surface.y+50, z=ptz}
			local chunk_number = vl_worlds.get_chunk_number(pos1)
			local pos_surface, surface_material
			if chunks[chunk_number] then
				pos_surface, surface_material = settlements.find_surface(pos1)
			else
				chunks[chunk_number] = true
				pos_surface, surface_material = settlements.find_surface(pos1, true)
			end
			if not pos_surface then break end

			local randomized_schematic_table = shuffle(settlements.schematic_table, pr)
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
		if number_built >= number_of_buildings then
			break
		end
		r = r + pr:next(2,5)
	end
	settlements.debug("really ".. number_built)
	return settlement_info
end
-------------------------------------------------------------------------------
-- evaluate settlement_info and place schematics
-------------------------------------------------------------------------------
-- Initialize node
local function construct_node(p1, p2, name)
	local r = minetest.registered_nodes[name]
	if r then
		if r.on_construct then
			local nodes = minetest.find_nodes_in_area(p1, p2, name)
			for p=1, #nodes do
				local pos = nodes[p]
				r.on_construct(pos)
			end
			return nodes
		end
		minetest.log("warning", "[mcl_villages] No on_construct defined for node name " .. name)
		return
	end
	minetest.log("warning", "[mcl_villages] Attempt to 'construct' inexistant nodes: " .. name)
end

local function spawn_iron_golem(pos)
	--minetest.log("action", "Attempt to spawn iron golem.")
	local p = minetest.find_node_near(pos,50,"mcl_core:grass_path")
	if p then
		local l=minetest.add_entity(p,"mobs_mc:iron_golem"):get_luaentity()
		if l then
			l._home = p
		end
	end
end

local function spawn_villagers(minp,maxp)
	--minetest.log("action", "Attempt to spawn villagers.")
	local beds=minetest.find_nodes_in_area(vector.offset(minp,-20,-20,-20),vector.offset(maxp,20,20,20),{"mcl_beds:bed_red_bottom"})
	for _,bed in pairs(beds) do
		local m = minetest.get_meta(bed)
		if m:get_string("villager") == "" then
			local v=minetest.add_entity(bed,"mobs_mc:villager")
			if v then
				local l=v:get_luaentity()
				l._bed = bed
				m:set_string("villager",l._id)
			end
		end
	end
end

local function fix_village_water(minp,maxp)
	local palettenodes = minetest.find_nodes_in_area(vector.offset(minp,-20,-20,-20),vector.offset(maxp,20,20,20), "group:water_palette")
	for _, palettenodepos in pairs(palettenodes) do
		local palettenode = minetest.get_node(palettenodepos)
		minetest.set_node(palettenodepos, {name = palettenode.name})
	end
end

local function init_nodes(p1, p2, size, rotation, pr)
	construct_node(p1, p2, "mcl_itemframes:frame")
	construct_node(p1, p2, "mcl_furnaces:furnace")
	construct_node(p1, p2, "mcl_anvils:anvil")

	construct_node(p1, p2, "mcl_smoker:smoker")
	construct_node(p1, p2, "mcl_barrels:barrel_closed")
	construct_node(p1, p2, "mcl_blast_furnace:blast_furnace")
	construct_node(p1, p2, "mcl_brewing:stand_000")
	local nodes = construct_node(p1, p2, "mcl_chests:chest")
	if nodes and #nodes > 0 then
		for p=1, #nodes do
			local pos = nodes[p]
			settlements.fill_chest(pos, pr)
		end
	end
end

function settlements.place_schematics(settlement_info, pr)
	local building_all_info

	for i, built_house in ipairs(settlement_info) do
		local is_last = i == #settlement_info

		for j, schem in ipairs(settlements.schematic_table) do
			if settlement_info[i]["name"] == schem["name"] then
				building_all_info = schem
				break
			end
		end




		local pos = settlement_info[i]["pos"]
		local rotation = settlement_info[i]["rotat"]
		-- get building node material for better integration to surrounding
		local platform_material = settlement_info[i]["surface_mat"]
		--platform_material_name = minetest.get_name_from_content_id(platform_material)
		-- pick random material
		--local material = wallmaterial[pr:next(1,#wallmaterial)]
		--
		local building = building_all_info["mts"]
		local replace_wall = building_all_info["rplc"]
		-- schematic conversion to lua
		local schem_lua = minetest.serialize_schematic(building,
			"lua",
			{lua_use_comments = false, lua_num_indent_spaces = 0}).." return schematic"
		schem_lua = schem_lua:gsub("mcl_core:stonebrickcarved", "mcl_villages:stonebrickcarved")
		-- replace material
		if replace_wall then
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

		local is_belltower = building_all_info["name"] == "belltower"

		-- build foundation for the building an make room above

		mcl_structures.place_schematic(
			pos,
			schematic,
			rotation,
			nil,
			true,
			nil,
			function(p1, p2, size, rotation, pr)
				if is_belltower then
					spawn_iron_golem(p1)
				else
					init_nodes(p1, p2, size, rotation, pr)
					spawn_villagers(p1,p2)
					fix_village_water(p1,p2)
				end
			end,
			pr
		)
	end
end
