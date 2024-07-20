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
local function try_place_building(minp, maxp, pos_surface, building_all_info, rotation, settlement_info, pr)
	local fwidth, fdepth = building_all_info["hwidth"] or 5, building_all_info["hdepth"] or 5
	if rotation == "90" or rotation == "270" then fwidth, fdepth = fdepth, fwidth end
	local fheight = building_all_info["hheight"] or 5
	-- use building centers for better placement
	pos_surface.x = pos_surface.x - math.ceil(fwidth / 2)
	pos_surface.z = pos_surface.z - math.ceil(fdepth / 2)
	-- ensure we have 3 space for terraforming
	if pos_surface.x - 3 < minp.x or pos_surface.z + 3 < minp.z or pos_surface.x + fwidth + 3 > maxp.x or pos_surface.z + fheight + 3 > maxp.z then return nil end
	-- to find the y position, also check the corners
	local ys = {pos_surface.y}
	local pos_c
	pos_c = mcl_villages.find_surface_down(vector.new(pos_surface.x, pos_surface.y+fheight, pos_surface.z))
	if pos_c then table.insert(ys, pos_c.y) end
	pos_c = mcl_villages.find_surface_down(vector.new(pos_surface.x+fwidth-1, pos_surface.y+fheight, pos_surface.z))
	if pos_c then table.insert(ys, pos_c.y) end
	pos_c = mcl_villages.find_surface_down(vector.new(pos_surface.x, pos_surface.y+fheight, pos_surface.z+fdepth-1))
	if pos_c then table.insert(ys, pos_c.y) end
	pos_c = mcl_villages.find_surface_down(vector.new(pos_surface.x+fwidth-1, pos_surface.y+fheight, pos_surface.z+fdepth-1))
	if pos_c then table.insert(ys, pos_c.y) end
	table.sort(ys)
	-- well supported base, not too uneven?
	if #ys < 5 or ys[#ys]-ys[1] > fheight + 3 then return nil end
	pos_surface.y = 0.5 * (ys[math.floor(#ys/2)] + ys[math.ceil(#ys/2)]) -- median
	-- check distance to other buildings
	if not mcl_villages.check_distance(settlement_info, pos_surface, math.max(fheight, fdepth)) then return nil end
	return pos_surface
end
-------------------------------------------------------------------------------
-- fill settlement_info
--------------------------------------------------------------------------------
function mcl_villages.create_site_plan(minp, maxp, pr)
	local center = vector.new(math.floor((minp.x+maxp.x)/2),maxp.y,math.floor((minp.z+maxp.z)/2))
	minetest.log("action", "[mcl_villages] sudo make me a village at: " .. minetest.pos_to_string(center))
	local possible_rotations = {"0", "90", "180", "270"}
	local center_surface

	local count_buildings, number_of_buildings, number_built = mcl_villages.initialize_settlement_info(pr)
	local settlement_info = {}
	-- now some buildings around in a circle, radius = size of town center
	local x, y, z, r = center.x, maxp.y, center.z, 0
	-- draw j circles around center and increase radius by math.random(2,5)
	for j = 1,15 do
		for a = 0, 23, 1 do
			local angle = a * 71 / 24 * math.pi * 2 -- prime to increase randomness
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
					if count_buildings[building_all_info["name"]] < building_all_info["max_num"]*number_of_buildings
						and (r >= 25 or not string.find(building_all_info["name"], "lamp")) then -- no lamps in the center
						local rotation = possible_rotations[pr:next(1, #possible_rotations)]
						local pos = try_place_building(minp, maxp, pos_surface, building_all_info, rotation, settlement_info, pr)
						if pos then
							if #settlement_info == 0 then -- town bell
								center_surface, y = pos, pos.y + max_height_difference * 0.5 + 1
							end
							-- limit height differences to town center
							if math.abs(pos.y - center_surface.y) > max_height_difference * 0.5 then
								break -- other buildings likely will not fit either
							end
							count_buildings[building_all_info["name"]] = (count_buildings[building_all_info["name"]] or 0) + 1
							number_built = number_built + 1

							pos.y = pos.y + (building_all_info["yadjust"] or 0)
							table.insert(settlement_info, {
								pos = pos,
								name = building_all_info["name"],
								hsize = math.max(building_all_info["hwidth"], building_all_info["hdepth"]), -- ,building_all_info["hsize"],
								rotat = rotation,
								surface_mat = surface_material
							})
							-- minetest.log("action", "[mcl_villages] Placing "..building_all_info["name"].." at "..minetest.pos_to_string(pos))
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
	end
	mcl_villages.debug("really ".. number_built)
	if number_built < 7 then
		minetest.log("action", "[mcl_villages] Bad village location, could only place "..number_built.." buildings.")
		return
	end
	minetest.log("action", "[mcl_villages] village plan completed at " .. minetest.pos_to_string(center))
	--minetest.log("[mcl_villages] village plan completed at " .. minetest.pos_to_string(center)) -- for debugging only
	return settlement_info
end
-------------------------------------------------------------------------------
-- evaluate settlement_info and place schematics
-------------------------------------------------------------------------------
-- Initialize node
local function construct_node(p1, p2, name)
	local r = minetest.registered_nodes[name]
	if not r or not r.on_construct then
		minetest.log("warning", "[mcl_villages] No on_construct defined for node name " .. name)
	end
	local nodes = minetest.find_nodes_in_area(p1, p2, name)
	for p=1, #nodes do
		r.on_construct(nodes[p])
	end
	return nodes
end

local function spawn_iron_golem(pos)
	--minetest.log("action", "[mcl_villages] Attempt to spawn iron golem.")
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
	--minetest.log("action", "[mcl_villages] Attempt to spawn villagers.")
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
	local nodes = construct_node(p1, p2, "mcl_chests:chest_small")
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
			-- MCLA node names to VL for import
			for _, sub in pairs(mcl_villages.mcla_to_vl) do
				schem_lua = schem_lua:gsub(sub[1], sub[2])
			end
			if not schem_lua then error("schema failed to load "..building_all_info["name"]) end
			local schematic = loadstring(schem_lua)
			if not schematic then error("schema failed to load "..building_all_info["name"].." "..schem_lua) end
			schematic = schematic() -- evaluate
			if schematic.size["x"] ~= building_all_info["hwidth"] or schematic.size["y"] ~= building_all_info["hheight"] or schematic.size["z"] ~= building_all_info["hdepth"] then
				minetest.log("warning", "[mcl_villages] schematic size differs: "..building_all_info["name"].." width "..schematic.size["x"].." height "..schematic.size["y"].." depth "..schematic.size["z"])
			end
			building_all_info["schem_lua"] = schem_lua
		end
		schem_lua = schem_lua:gsub('"mcl_core:dirt"', '"'..platform_material..'"')
		schem_lua = schem_lua:gsub('"mcl_core:dirt_with_grass"', '"'..surface_material..'"')
		local schematic = loadstring(mcl_villages.substitute_materials(pos, schem_lua, pr))()

		-- already built the foundation for the building and made room above
		local sx, sy, sz = schematic.size.x, schematic.size.y, schematic.size.z
		if rotation == "90" or rotation == "270" then sx, sz = sz, sx end
		local p2 = vector.new(pos.x+sx-1,pos.y+sy-1,pos.z+sz-1)
		lvm:read_from_map(vector.new(pos.x-3, pos.y-40, pos.z-3), vector.new(pos.x+sx+3, pos.y+sy+40, pos.z+sz+3)) -- safety margins for foundation
		lvm:get_data()
		-- TODO: make configurable as in MCLA
		mcl_villages.foundation(lvm, pos, sx, sy, sz, surface_material, pr)
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
		init_nodes(pos, p2, schematic.size, rotation, pr)

		if building_all_info["name"] == "belltower" then
			spawn_iron_golem(pos)
		end
		spawn_villagers(pos,p2)
		fix_village_water(pos,p2)
	end
end
