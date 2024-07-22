local min_jobs = tonumber(minetest.settings:get("mcl_villages_min_jobs")) or 1
local max_jobs = tonumber(minetest.settings:get("mcl_villages_max_jobs")) or 12
local placement_priority = minetest.settings:get("mcl_villages_placement_priority") or "random"

local S = minetest.get_translator(minetest.get_current_modname())

-------------------------------------------------------------------------------
-- initialize settlement_info
-------------------------------------------------------------------------------
function mcl_villages.initialize_settlement_info(pr)
	local count_buildings = {
		number_of_jobs = pr:next(min_jobs, max_jobs),
		num_jobs = 0,
		num_beds = 0,
	}

	for k, v in pairs(mcl_villages.schematic_houses) do
		count_buildings[v["name"]] = 0
	end
	for k, v in pairs(mcl_villages.schematic_jobs) do
		count_buildings[v["name"]] = 0
	end

	return count_buildings
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

local function spawn_cats(pos)
	local sp=minetest.find_nodes_in_area_under_air(vector.offset(pos,-20,-20,-20),vector.offset(pos,20,20,20),{"group:opaque"})
	for i=1,math.random(3) do
		local v = minetest.add_entity(vector.offset(sp[math.random(#sp)],0,1,0),"mobs_mc:cat"):get_luaentity()
		if v then
			v._home = pos
		end
	end
end

local function init_nodes(p1, p2, pr)
	--[[for _, n in pairs(minetest.find_nodes_in_area(p1, p2, { "group:wall" })) do
		mcl_walls.update_wall(n)
	end]]--

	construct_node(p1, p2, "mcl_itemframes:item_frame")
	construct_node(p1, p2, "mcl_itemframes:glow_item_frame")
	construct_node(p1, p2, "mcl_furnaces:furnace")
	construct_node(p1, p2, "mcl_anvils:anvil")

	construct_node(p1, p2, "mcl_books:bookshelf")
	construct_node(p1, p2, "mcl_armor_stand:armor_stand")
	--construct_node(p1, p2, "mcl_smoker:smoker")
	--construct_node(p1, p2, "mcl_barrels:barrel_closed")
	--construct_node(p1, p2, "mcl_blast_furnace:blast_furnace")
	--construct_node(p1, p2, "mcl_brewing:stand_000")

	-- Support mods with custom job sites
	local job_sites = minetest.find_nodes_in_area(p1, p2, mobs_mc.jobsites)
	for _, v in pairs(job_sites) do
		mcl_structures.init_node_construct(v)
	end

	-- Do new chest nodes first
	local nodes = construct_node(p1, p2, "mcl_chests:chest_small")
	if nodes and #nodes > 0 then
		for p=1, #nodes do
			mcl_villages.fill_chest(nodes[p], pr)
		end
	end

	-- Do old chest nodes after
	local nodes = construct_node(p1, p2, "mcl_chests:chest")
	if nodes and #nodes > 0 then
		for p=1, #nodes do
			mcl_villages.fill_chest(nodes[p], pr)
		end
	end
end

-- check ground for a single building, adjust position
local function check_ground(lvm, cpos, size)
	local cpos, surface_material = mcl_villages.find_surface(lvm, cpos)
	if not cpos then return nil, nil end
	local pos = vector.offset(cpos, -math.floor(size.x/2), 0, -math.floor(size.z/2))
	local ys = {pos.y}
	local pos_c = mcl_villages.find_surface_down(lvm, vector.offset(pos, 0,        size.y, 0))
	if pos_c then table.insert(ys, pos_c.y) end
	local pos_c = mcl_villages.find_surface_down(lvm, vector.offset(pos, size.x-1, size.y, 0))
	if pos_c then table.insert(ys, pos_c.y) end
	local pos_c = mcl_villages.find_surface_down(lvm, vector.offset(pos, 0,        size.y, size.z-1))
	if pos_c then table.insert(ys, pos_c.y) end
	local pos_c = mcl_villages.find_surface_down(lvm, vector.offset(pos, size.x-1, size.y, size.z-1))
	if pos_c then table.insert(ys, pos_c.y) end
	table.sort(ys)
	-- well supported base, not too uneven?
	if #ys < 5 or ys[#ys]-ys[1] > 6 then return nil, nil end
	cpos.y = math.floor(0.5 * (ys[math.floor(#ys/2)] + ys[math.ceil(#ys/2)]) + 0.5) -- median, rounded
	return cpos, surface_material
end

local function add_building(settlement, building, count_buildings)
	table.insert(settlement, building)
	count_buildings[building["name"]] = count_buildings[building["name"]] + 1
	count_buildings.num_jobs = count_buildings.num_jobs + (building["num_jobs"] or 0)
	count_buildings.num_beds = count_buildings.num_beds + (building["num_beds"] or 0)
end

local function layout_town(lvm, minp, maxp, pr, input_settlement)
	local center = vector.new(pr:next(minp.x + 24, maxp.x - 24), maxp.y, pr:next(minp.z + 24, maxp.z - 24))
	minetest.log("action", "[mcl_villages] sudo make me a village at: " .. minetest.pos_to_string(center))
	local possible_rotations = {"0", "90", "180", "270"}
	local center_surface

	local settlement = {}
	-- now some buildings around in a circle, radius = size of town center
	local x, y, z, r, lastr = center.x, maxp.y, center.z, 0, 99
	local mindist = 4
	if #input_settlement >= 12 then mindist = 3 end
	-- draw j circles around center and increase radius by math.random(2,4)
	for j = 1,20 do
		local steps = math.min(math.floor(math.pi * 2 * r / 2), 30) -- try up to 30 angles
		for a = 0, steps - 1 do
			if #settlement == #input_settlement then break end -- everything placed
			local angle = a * 71 / steps * math.pi * 2 -- prime to increase randomness
			local cpos = vector.new(math.floor(x + r * math.cos(angle) + 0.5), y, math.floor(z - r * math.sin(angle) + 0.5))
			local building = table.copy(input_settlement[#settlement + 1])
			local size = vector.copy(building.size)
			--local rotation = possible_rotations[pr:next(1, #possible_rotations)]
			local rotation = math.floor(math.atan2(center.x-cpos.x, center.z-cpos.z) / math.pi * 2+4.5)%4
			local rotation = possible_rotations[1+rotation]
			if rotation == "90" or rotation == "270" then size.x, size.z = size.z, size.x end
			local tlpos = vector.offset(cpos, -math.floor(size.x / 2), 0, -math.floor(size.z / 2))

			-- ensure we have 3 space for terraforming, and avoid problems with VoxelManip
			if  tlpos.x - 3 >= minp.x and tlpos.x + size.x + 3 <= maxp.x
			and tlpos.z + 3 >= minp.z and tlpos.z + size.y + 3 <= maxp.z then
				local pos, surface_material = check_ground(lvm, cpos, size)
				-- check distance to other buildings. Note that we still want to add baseplates etc.
				if pos and mcl_villages.check_distance(settlement, cpos, size.x, size.z, mindist) then
					-- use town bell as new reference point for placement height
					if #settlement == 0 then
						center_surface, y = cpos, pos.y + mcl_villages.max_height_difference * 0.5 + 1
					end
					-- limit height differences to town center, but gradually
					if math.abs(pos.y - center_surface.y) <= mcl_villages.max_height_difference * (0.3 + math.min(r/30,0.5)) then
						local minp = vector.offset(pos, -math.floor(size.x/2), building.yadjust, -math.floor(size.z/2))
						building.minp = minp
						building.maxp = vector.offset(minp, size.x, size.y, size.z)
						building.pos = pos
						building.size = size
						building.rotation = rotation
						building.surface_mat = surface_material
						table.insert(settlement, building)
						-- minetest.log("verbose", "[mcl_villages] Placing "..schema["name"].." at "..minetest.pos_to_string(pos))
						lastr = r
					--else
					--	minetest.log("Height difference "..math.abs(pos.y - center_surface.y))
					end
				end
			end
		end
		r = r + pr:next(2,4)
		if r > lastr + 25 then -- too disconnected
			break
		end
	end
	-- minetest.log("verbose", "Planned "..#input_settlement.." buildings, placed "..#settlement)
	if #settlement < #input_settlement and #settlement < 6 then
		minetest.log("action", "[mcl_villages] Bad village location, could only place "..#settlement.." buildings.")
		return
	end
	minetest.log("action", "[mcl_villages] village plan completed at " .. minetest.pos_to_string(center))
	return settlement
end

function mcl_villages.create_site_plan(lvm, minp, maxp, pr)
	local settlement = {}

	-- initialize all settlement_info table
	local count_buildings = mcl_villages.initialize_settlement_info(pr)

	-- first building is townhall in the center
	local bindex = pr:next(1, #mcl_villages.schematic_bells)
	local bell_info = table.copy(mcl_villages.schematic_bells[bindex])

	if mcl_villages.mandatory_buildings['jobs'] then
		for _, bld_name in pairs(mcl_villages.mandatory_buildings['jobs']) do
			local building_info = info_for_building(bld_name, mcl_villages.schematic_jobs)
			add_building(settlement, building_info, count_buildings)
		end
	end

	while count_buildings.num_jobs < count_buildings.number_of_jobs do
		local rindex = pr:next(1, #mcl_villages.schematic_jobs)
		local building_info = mcl_villages.schematic_jobs[rindex]

		if
			(building_info["min_jobs"] == nil or count_buildings.number_of_jobs >= building_info["min_jobs"])
			and (building_info["max_jobs"] == nil or count_buildings.number_of_jobs <= building_info["max_jobs"])
			and (
				building_info["num_others"] == nil
				or count_buildings[building_info["name"]] == 0
				or building_info["num_others"] * count_buildings[building_info["name"]] < count_buildings.num_jobs
			)
		then
			add_building(settlement, building_info, count_buildings)
		end
	end

	if mcl_villages.mandatory_buildings['houses'] then
		for _, bld_name in pairs(mcl_villages.mandatory_buildings['houses']) do
			local building_info = info_for_building(bld_name, mcl_villages.schematic_houses)
			add_building(settlement, building_info, count_buildings)
		end
	end

	while count_buildings.num_beds <= count_buildings.num_jobs do
		local rindex = pr:next(1, #mcl_villages.schematic_houses)
		local building_info = mcl_villages.schematic_houses[rindex]

		if
			(building_info["min_jobs"] == nil or count_buildings.number_of_jobs >= building_info["min_jobs"])
			and (building_info["max_jobs"] == nil or count_buildings.number_of_jobs <= building_info["max_jobs"])
			and (
				building_info["num_others"] == nil
				or count_buildings[building_info["name"]] == 0
				or building_info["num_others"] * count_buildings[building_info["name"]] < count_buildings.num_jobs
			)
		then
			add_building(settlement, building_info, count_buildings)
		end
	end

	-- Based on number of villagers
	local num_wells = pr:next(1, math.ceil(count_buildings.num_beds / 10))
	for i = 1, num_wells do
		local windex = pr:next(1, #mcl_villages.schematic_wells)
		local cur_schem = table.copy(mcl_villages.schematic_wells[windex])
		table.insert(settlement, pr:next(1, #settlement), cur_schem)
	end

	if placement_priority == "jobs" then
		-- keep ordered as is
	elseif placement_priority == "houses" then
		table.reverse(settlement)
	else
		settlement = mcl_villages.shuffle(settlement, pr)
	end

	table.insert(settlement, 1, bell_info)
	return layout_town(lvm, minp, maxp, pr, settlement)
end


function mcl_villages.place_schematics(lvm, settlement, blockseed, pr)
	-- local lvm = VoxelManip()
	local bell_pos = vector.offset(settlement[1].minp, math.floor(settlement[1].size.x/2), 0, math.floor(settlement[1].size.z/2))
	local bell_center_pos
	local bell_center_node_type

	for i, building in ipairs(settlement) do
		local minp, cpos, maxp, size, rotation = building.minp, building.pos, building.maxp, building.size, building.rotation

		-- adjust the schema to match location and biome
		local surface_material = building.surface_mat or {name = "mcl_core:dirt" }
		local platform_material = building.platform_mat or building.surface_mat or {name = "mcl_core:stone" }
		local schem_lua = building.schem_lua
		schem_lua = schem_lua:gsub('"mcl_core:dirt"', '"'..platform_material.name..'"') -- also keeping param2 would be nicer, grass color
		schem_lua = schem_lua:gsub('"mcl_core:dirt_with_grass"', '"'..surface_material.name..'"')
		schem_lua = mcl_villages.substitute_materials(cpos, schem_lua, pr)
		local schematic = loadstring(schem_lua)()

		-- the foundation and air space for the building was already built before
		-- lvm:read_from_map(vector.new(minp.x, minp.y, minp.z), vector.new(maxp.x, maxp.y, maxp.z))
		-- lvm:get_data()
		-- now added in placement code already, pos has the primary height if (building.yadjust or 0) ~= 0 then minp = vector.offset(minp, 0, building.yadjust, 0) end
		-- minetest.log("debug", "placing schematics for "..building.name.." at "..minetest.pos_to_string(minp).." on "..surface_material)
		minetest.place_schematic_on_vmanip(
			lvm,
			minp,
			schematic,
			rotation,
			nil,
			true,
			{ place_center_x = false, place_center_y = false, place_center_z = false }
		)
		-- to help pathing, increase the height of no_path areas
		local p = vector.zero()
		for z = minp.z,maxp.z do
			p.z = z
			for x = minp.x,maxp.x do
				p.x = x
				for y = minp.y,maxp.y-1 do
					p.y = y
					local n = lvm:get_node_at(p)
					if n and n.name == "mcl_villages:no_paths" then
						p.y = y+1
						n = lvm:get_node_at(p)
						if n and n.name == "air" then
							lvm:set_node_at(p, {name="mcl_villages:no_paths"})
						end
					end
				end
			end
		end
		mcl_villages.store_path_ends(lvm, minp, maxp, cpos, blockseed, bell_pos)

		if building.name == "belltower" then -- TODO: allow multiple types?
			bell_center_pos = cpos
			local center_node = lvm:get_node_at(cpos)
			bell_center_node_type = center_node.name
		end
	end

	lvm:write_to_map(true) -- for path finder and light

	local biome_data = minetest.get_biome_data(bell_pos)
	local biome_name = minetest.get_biome_name(biome_data.biome)
	mcl_villages.paths(blockseed, biome_name)

	-- this will run delayed actions, such as spawning mobs
	minetest.set_node(bell_center_pos, { name = "mcl_villages:village_block" })
	local meta = minetest.get_meta(bell_center_pos)
	meta:set_string("blockseed", blockseed)
	meta:set_string("node_type", bell_center_node_type)
	meta:set_string("infotext", S("The timer for this @1 has not run yet!", bell_center_node_type))
	minetest.get_node_timer(bell_center_pos):start(1.0)

	for i, building in ipairs(settlement) do
		init_nodes(vector.offset(building.minp,-2,-2,-2), vector.offset(building.maxp,2,2,2), pr)
	end

	-- read back any changes
	local emin, emax = lvm:get_emerged_area()
	lvm:read_from_map(emin, emax)
end

function mcl_villages.post_process_village(blockseed)
	local village_info = mcl_villages.get_village(blockseed)
	if not village_info then
		return
	end
	-- minetest.log("Postprocessing village")

	local settlement_info = village_info.data
	local jobs = {}
	local beds = {}

	local bell_pos = vector.copy(settlement_info[1]["pos"])
	local bell = vector.offset(bell_pos, 0, 2, 0)
	local biome_data = minetest.get_biome_data(bell_pos)
	local biome_name = minetest.get_biome_name(biome_data.biome)
	--mcl_villages.paths(blockseed, biome_name)

	local l = minetest.add_entity(bell, "mobs_mc:iron_golem"):get_luaentity()
	if l then
		l._home = bell
	else
		minetest.log("info", "Could not create a golem!")
	end
	spawn_cats(bell)

	for _, building in pairs(settlement_info) do
		local has_beds = building["num_beds"] and building["num_beds"] ~= nil
		local has_jobs = building["num_jobs"] and building["num_jobs"] ~= nil

		local minp, maxp = building["minp"], building["maxp"]

		if has_jobs then
			local jobsites = minetest.find_nodes_in_area(minp, maxp, mobs_mc.jobsites)

			for _, job_pos in pairs(jobsites) do
				table.insert(jobs, job_pos)
			end
		end

		if has_beds then
			local bld_beds = minetest.find_nodes_in_area(minp, maxp, { "group:bed" })

			for _, bed_pos in pairs(bld_beds) do
				local bed_node = minetest.get_node(bed_pos)
				local bed_group = core.get_item_group(bed_node.name, "bed")

				-- We only spawn at bed bottoms
				-- 1 is bottom, 2 is top
				if bed_group == 1 then
					table.insert(beds, bed_pos)
				end
			end
		end
	end

	-- minetest.log("beds: "..#beds.." jobsites: "..#jobs)
	if beds then
		for _, bed_pos in pairs(beds) do
			local res = minetest.forceload_block(bed_pos, true)
			if res then
				mcl_villages.forced_blocks[minetest.pos_to_string(bed_pos)] = minetest.get_us_time()
			end
			local m = minetest.get_meta(bed_pos)
			m:set_string("bell_pos", minetest.pos_to_string(bell_pos))
			if m:get_string("villager") == "" then
				local v = minetest.add_entity(bed_pos, "mobs_mc:villager")
				if v then
					local l = v:get_luaentity()
					l._bed = bed_pos
					l._bell = bell_pos
					m:set_string("villager", l._id)
					m:set_string("infotext", S("A villager sleeps here"))

					local job_pos = table.remove(jobs, 1)
					if job_pos then
						villager_employ(l, job_pos) -- HACK: merge more MCLA villager code
					end

					for _, callback in pairs(mcl_villages.on_villager_placed) do
						callback(v, blockseed)
					end
				else
					minetest.log("info", "Could not create a villager!")
				end
			else
				minetest.log("info", "bed already owned by " .. m:get_string("villager"))
			end
		end
	end
end
