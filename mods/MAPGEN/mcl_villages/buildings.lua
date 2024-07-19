--[[
-------------------------------------------------------------------------------
-- build schematic, replace material, rotation
-------------------------------------------------------------------------------
function mcl_villages.build_schematic(vm, data, va, pos, building, replace_wall, name)
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
  mcl_villages.foundation(
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
function mcl_villages.initialize_settlement_info(pr)
	local count_buildings = {}

	-- count_buildings table reset
	for k,v in pairs(mcl_villages.schematic_table) do
		count_buildings[v["name"]] = 0
	end

	-- randomize number of buildings
	local number_of_buildings = pr:next(10, 25)
	local number_built = 0
	mcl_villages.debug("Village ".. number_of_buildings)

	return count_buildings, number_of_buildings, number_built
end

-------------------------------------------------------------------------------
-- check ground for a single building
-------------------------------------------------------------------------------
local function try_place_building(pos_surface, building_all_info, rotation, settlement_info, pr)
	local fwidth, fdepth = building_all_info["hwidth"], building_all_info["hdepth"]
	if rotation == "90" or rotation == "270" then fwidth, fdepth = fdepth, fwidth end
	local fheight = building_all_info["hheight"]
	-- use building centers for better placement
	pos_surface.x = pos_surface.x - math.ceil(fwidth / 2)
	pos_surface.z = pos_surface.z - math.ceil(fdepth / 2)
	-- to find the y position, also check the corners
	local ys = {pos_surface.y}
	local pos_c
	pos_c = mcl_villages.find_surface_down(vector.new(pos_surface.x-1, pos_surface.y+fheight, pos_surface.z-1))
	if pos_c then table.insert(ys, pos_c.y) end
	pos_c = mcl_villages.find_surface_down(vector.new(pos_surface.x+fwidth+2, pos_surface.y+fheight, pos_surface.z-1))
	if pos_c then table.insert(ys, pos_c.y) end
	pos_c = mcl_villages.find_surface_down(vector.new(pos_surface.x-1, pos_surface.y+fheight, pos_surface.z+fdepth+2))
	if pos_c then table.insert(ys, pos_c.y) end
	pos_c = mcl_villages.find_surface_down(vector.new(pos_surface.x+fwidth+2, pos_surface.y+fheight, pos_surface.z+fdepth+2))
	if pos_c then table.insert(ys, pos_c.y) end
	table.sort(ys)
	-- well supported base, not too uneven?
	if #ys < 5 or ys[#ys]-ys[1] > fheight + 3 then return nil end
	pos_surface.y = ys[math.ceil(#ys/2)]
	-- check distance to other buildings
	if mcl_villages.check_distance(settlement_info, pos_surface, building_all_info["hsize"]) then 
		return pos_surface
	end
	return nil
end
-------------------------------------------------------------------------------
-- fill settlement_info
--------------------------------------------------------------------------------
function mcl_villages.create_site_plan(minp, maxp, pr)
	local center = vector.new(math.floor((minp.x+maxp.x)/2),maxp.y,math.floor((minp.z+maxp.z)/2))
	minetest.log("action", "sudo make me a village at: " .. minetest.pos_to_string(center))
	local possible_rotations = {"0", "90", "180", "270"}
	local center_surface

	local count_buildings, number_of_buildings, number_built = mcl_villages.initialize_settlement_info(pr)
	local settlement_info = {}
	-- now some buildings around in a circle, radius = size of town center
	local x, y, z, r = center.x, maxp.y, center.z, 0
	-- draw j circles around center and increase radius by math.random(2,5)
	for j = 1,10 do
		for angle = 0, math.pi*2, 0.262 do -- 24 attempts on a circle
			local pos1 = vector.new(math.floor(x + r * math.cos(angle) + 0.5), y, math.floor(z - r * math.sin(angle) + 0.5))
			local pos_surface, surface_material = mcl_villages.find_surface(pos1, false)
			if pos_surface then
				local randomized_schematic_table = mcl_villages.shuffle(mcl_villages.schematic_table, pr)
				if #settlement_info == 0 then randomized_schematic_table = { mcl_villages.schematic_table[1] } end -- place town bell first
				-- pick schematic
				local size = #randomized_schematic_table
				for i = 1, #randomized_schematic_table do
					local building_all_info = randomized_schematic_table[i]
					-- already enough buildings of that type?
					if count_buildings[building_all_info["name"]] < building_all_info["max_num"]*number_of_buildings then
						local rotation = possible_rotations[pr:next(1, #possible_rotations)]
						local pos = try_place_building(pos_surface, building_all_info, rotation, settlement_info, pr)
						if pos then
							if #settlement_info == 0 then -- town bell
								center_surface, y = pos, pos.y + max_height_difference
							end
							-- limit height differences to town center
							if math.abs(pos.y - center_surface.y) > max_height_difference * 0.7 then
								break -- other buildings likely will not fit either
							end
							count_buildings[building_all_info["name"]] = count_buildings[building_all_info["name"]] +1
							number_built = number_built + 1

							pos.y = pos.y + (building_all_info["yadjust"] or 0)
							table.insert(settlement_info, {
								pos = pos,
								name = building_all_info["name"],
								hsize = building_all_info["hsize"],
								rotat = rotation,
								surface_mat = surface_material
							})
							-- minetest.log("action", "Placing "..building_all_info["name"].." at "..minetest.pos_to_string(pos))
							break
						end
					end
				end
				if number_of_buildings == number_built then
					break
				end
			end
			if r == 0 then break end -- no angles in the very center
		end
		if number_built >= number_of_buildings then
			break
		end
		r = r + pr:next(2,5)
		if r > 35 then break end -- avoid touching neighboring blocks
	end
	mcl_villages.debug("really ".. number_built)
	if number_built <= 8 then
		minetest.log("action", "Bad village location, could only place "..number_built.." buildings.")
		return
	end
	minetest.log("action", "Village completed at " .. minetest.pos_to_string(center))
	minetest.log("Village completed at " .. minetest.pos_to_string(center)) -- for debugging only
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
		p.y = p.y + 1
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
	construct_node(p1, p2, "mcl_itemframes:item_frame")
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
			mcl_villages.fill_chest(pos, pr)
		end
	end
end

function mcl_villages.place_schematics(settlement_info, pr)
	local building_all_info
	local lvm = VoxelManip()

	for i, built_house in ipairs(settlement_info) do
		local is_last = i == #settlement_info

		for j, schem in ipairs(mcl_villages.schematic_table) do
			if settlement_info[i]["name"] == schem["name"] then
				building_all_info = schem
				break
			end
		end

		local pos = settlement_info[i]["pos"]
		local rotation = settlement_info[i]["rotat"]
		-- get building node material for better integration to surrounding
		local surface_material = settlement_info[i]["surface_mat"] or "mcl_core:stone"
		local platform_material = surface_material
		local schem_lua = building_all_info["schem_lua"]
		if not schem_lua then
			schem_lua = minetest.serialize_schematic(building_all_info["mts"], "lua", { lua_use_comments = false, lua_num_indent_spaces = 0 }) .. " return schematic"
			building_all_info["schem_lua"] = schem_lua
		end
		schem_lua = schem_lua:gsub('"mcl_core:dirt"', '"'..platform_material..'"')
		schem_lua = schem_lua:gsub('"mcl_core:dirt_with_grass"', '"'..surface_material..'"')
		local schematic = loadstring(mcl_villages.substitute_materials(pos, schem_lua, pr))()

		local is_belltower = building_all_info["name"] == "belltower"

		-- already built the foundation for the building and made room above
		local sx, sy, sz = schematic.size.x, schematic.size.y, schematic.size.z
		local p2 = vector.new(pos.x+sx-1,pos.y+sy-1,pos.z+sz-1)
		lvm:read_from_map(pos, p2)
		minetest.place_schematic_on_vmanip(
			lvm,
			pos,
			schematic,
			rotation,
			nil,
			true,
			{ place_center_x = false, place_center_y = false, place_center_z = false }
		)
		lvm:write_to_map(true) -- FIXME: postpone
		if rotation == "90" or rotation == "270" then sx, sz = sz, sx end
		init_nodes(pos, p2, schematic.size, rotation, pr)

		if is_belltower then
			spawn_iron_golem(pos)
		else
			spawn_villagers(pos,p2)
			fix_village_water(pos,p2)
		end
	end
end
