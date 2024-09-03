local min_jobs = tonumber(minetest.settings:get("mcl_villages_min_jobs")) or 1
local max_jobs = tonumber(minetest.settings:get("mcl_villages_max_jobs")) or 12
local placement_priority = minetest.settings:get("mcl_villages_placement_priority") or "random"

local S = minetest.get_translator(minetest.get_current_modname())

local function add_building(settlement, building, count_buildings)
	table.insert(settlement, building)
	count_buildings[building.name] = (count_buildings[building.name] or 0) + 1
	count_buildings.num_jobs = count_buildings.num_jobs + (building.num_jobs or 0)
	count_buildings.num_beds = count_buildings.num_beds + (building.num_beds or 0)
	if building.group then
		count_buildings[building.group] = (count_buildings[building.group] or 0) + 1
	end
end

local function layout_town(vm, minp, maxp, pr, input_settlement)
	local center = vector.new(pr:next(minp.x + 24, maxp.x - 24), maxp.y, pr:next(minp.z + 24, maxp.z - 24))
	minetest.log("action", "[mcl_villages] sudo make me a village at: " .. minetest.pos_to_string(minp).." - "..minetest.pos_to_string(maxp))
	local possible_rotations = {"0", "90", "180", "270"}
	local center_surface

	local settlement = {}
	-- now some buildings around in a circle, radius = size of town center
	local x, y, z, r, lastr = center.x, center.y, center.z, 0, 99
	local mindist = 3
	if #input_settlement >= 12 then mindist = 2 end
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
			local rotation = math.floor(math.atan2(center.z-cpos.z, center.x-cpos.x) / math.pi * 2+6.5)%4
			rotation = possible_rotations[1+rotation]
			if rotation == "90" or rotation == "270" then size.x, size.z = size.z, size.x end
			local tlpos = vector.offset(cpos, -math.floor((size.x-1)/2), 0, -math.floor((size.z-1)/2))

			-- ensure we have 3 space for terraforming, and avoid problems with VoxelManip
			if  tlpos.x - 3 >= minp.x and tlpos.x + size.x + 3 <= maxp.x
			and tlpos.z + 3 >= minp.z and tlpos.z + size.y + 3 <= maxp.z then
				local pos, surface_material = vl_terraforming.find_level_vm(vm, cpos, size)
				-- check distance to other buildings. Note that we still want to add baseplates etc.
				if pos and mcl_villages.surface_mat[surface_material.name] and mcl_villages.check_distance(settlement, cpos, size.x, size.z, mindist) then
					-- use town bell as new reference point for placement height
					if #settlement == 0 then
						center_surface, y = cpos, math.min(maxp.y, pos.y + mcl_villages.max_height_difference * 0.5 + 1)
					end
					-- limit height differences to town center, but gradually allow more
					if math.abs(pos.y - center_surface.y) <= mcl_villages.max_height_difference * (0.25 + math.min(r/40,0.5)) then
						local minp = vector.offset(pos, -math.floor((size.x-1)/2), building.yadjust, -math.floor((size.z-1)/2))
						building.minp = minp
						building.maxp = vector.offset(minp, size.x, size.y, size.z)
						building.pos = pos
						building.size = size
						building.rotation = rotation
						building.surface_mat = surface_material
						table.insert(settlement, building)
						-- minetest.log("verbose", "[mcl_villages] Planning "..schema["name"].." at "..minetest.pos_to_string(pos))
						lastr = r
					else
						minetest.log("verbose", "Too large height difference "..math.abs(pos.y - center_surface.y).." at distance "..r)
					end
				end
			end
		end
		r = r + pr:next(2,4)
		if r > lastr + 20 then -- too disconnected
			minetest.log("verbose", "Disconnected village "..r.." > "..lastr)
			break
		end
	end
	-- minetest.log("verbose", "Planned "..#input_settlement.." buildings, placed "..#settlement)
	if #settlement < #input_settlement and #settlement < 6 then
		minetest.log("action", "[mcl_villages] Bad village location, could only place "..#settlement.." buildings at "..minetest.pos_to_string(center))
		return
	end
	minetest.log("action", "[mcl_villages] village plan completed at " .. minetest.pos_to_string(center))
	return settlement
end

function mcl_villages.create_site_plan(vm, minp, maxp, pr)
	local settlement = {}

	-- initialize all settlement_info table
	local count_buildings = { num_jobs = 0, num_beds = 0, target_jobs = pr:next(min_jobs, max_jobs) }

	-- first building is townhall in the center
	local bindex = pr:next(1, #mcl_villages.schematic_bells)
	local bell_info = table.copy(mcl_villages.schematic_bells[bindex])

	if mcl_villages.mandatory_buildings['jobs'] then
		for _, bld_name in pairs(mcl_villages.mandatory_buildings['jobs']) do
			local building_info = info_for_building(bld_name, mcl_villages.schematic_jobs)
			add_building(settlement, building_info, count_buildings)
		end
	end

	while count_buildings.num_jobs < count_buildings.target_jobs do
		local rindex = pr:next(1, #mcl_villages.schematic_jobs)
		local building_info = mcl_villages.schematic_jobs[rindex]

		if
			(building_info.min_jobs == nil or count_buildings.target_jobs >= building_info.min_jobs)
			and (building_info.max_jobs == nil or count_buildings.target_jobs <= building_info.max_jobs)
			and (
				building_info.num_others == nil
				or (count_buildings[building_info.group or building_info.name] or 0) == 0
				or building_info.num_others * (count_buildings[building_info.group or building_info.name] or 0) < count_buildings.num_jobs
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
			(building_info.min_jobs == nil or count_buildings.target_jobs >= building_info.min_jobs)
			and (building_info.max_jobs == nil or count_buildings.target_jobs <= building_info.max_jobs)
			and (
				building_info.num_others == nil
				or (count_buildings[building_info.group or building_info.name] or 0) == 0
				or building_info.num_others * (count_buildings[building_info.group or building_info.name] or 0) < count_buildings.num_jobs
			)
		then
			add_building(settlement, building_info, count_buildings)
		end
	end

	-- Based on number of villagers
	local num_wells = pr:next(1, math.ceil(count_buildings.num_beds / 10))
	for _ = 1, num_wells do
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
	return layout_town(vm, minp, maxp, pr, settlement)
end

local function init_nodes(p1, p2, pr)
	vl_structures.construct_nodes(p1, p2, {
		"mcl_itemframes:item_frame",
		"mcl_itemframes:glow_item_frame",
		"mcl_furnaces:furnace",
		"mcl_anvils:anvil",
		"mcl_books:bookshelf",
		"mcl_armor_stand:armor_stand",
		-- jobsite: "mcl_smoker:smoker",
		-- jobsite: "mcl_barrels:barrel_closed",
		-- jobsite: "mcl_blast_furnace:blast_furnace",
		-- jobsite: "mcl_brewing:stand_000",
	})

	-- Support mods with custom job sites
	local job_sites = minetest.find_nodes_in_area(p1, p2, mobs_mc.jobsites)
	for _, v in pairs(job_sites) do vl_structures.init_node_construct(v) end

	local nodes = vl_structures.construct_nodes(p1, p2, {"mcl_chests:chest_small", "mcl_chests:chest" })
	for _, n in pairs(nodes) do mcl_villages.fill_chest(n, pr) end
end

-- important: the vm will be written and then is outdated!
function mcl_villages.place_schematics(vm, settlement, blockseed, pr)
	-- first building is always the bell
	local bell_pos = vector.offset(settlement[1].minp, math.floor(settlement[1].size.x/2), 0, math.floor(settlement[1].size.z/2))

	for i, building in ipairs(settlement) do
		local minp, cpos, maxp, size, rotation = building.minp, building.pos, building.maxp, building.size, building.rotation

		-- adjust the schema to match location and biome
		local surface_material = building.surface_mat or {name = "mcl_core:dirt" }
		local platform_material = building.platform_mat or building.surface_mat or {name = "mcl_core:stone" }
		local schem_lua = building.schem_lua
		schem_lua = schem_lua:gsub('"mcl_core:dirt"', '"'..platform_material.name..'"')
		schem_lua = schem_lua:gsub('"mcl_core:dirt_with_grass"', '"'..surface_material.name..'"') -- also keeping param2 would be nicer, grass color
		schem_lua = mcl_villages.substitute_materials(cpos, schem_lua, pr)
		local schematic = loadstring(schem_lua)()

		-- the foundation and air space for the building was already built before
		-- minetest.log("debug", "placing schematics for "..building.name.." at "..minetest.pos_to_string(minp).." on "..surface_material)
		minetest.place_schematic_on_vmanip(vm, minp, schematic, rotation, nil, true, { place_center_x = false, place_center_y = false, place_center_z = false })
		mcl_villages.store_path_ends(vm, minp, maxp, cpos, blockseed, bell_pos)
		mcl_villages.increase_no_paths(vm, minp, maxp) -- help the path finder
	end

	vm:write_to_map(true) -- for path finder and light

	-- Path planning and placement
	mcl_villages.paths(blockseed, minetest.get_biome_name(minetest.get_biome_data(bell_pos).biome))
	-- Clean up paths and initialize nodes
	for i, building in ipairs(settlement) do
		mcl_villages.clean_no_paths(building.minp, building.maxp)
		init_nodes(building.minp, building.maxp, pr)
	end

	-- Replace center block with a temporary block, which will be used run delayed actions
	local block_name = minetest.get_node(bell_pos).name -- to restore the node afterwards
	minetest.swap_node(bell_pos, { name = "mcl_villages:village_block" })
	local meta = minetest.get_meta(bell_pos)
	meta:set_string("node_type", block_name)
	meta:set_string("blockseed", blockseed)
	meta:set_string("infotext", S("The timer for this village has not run yet!"))
	minetest.get_node_timer(bell_pos):start(1.0)
end

minetest.register_node("mcl_villages:village_block", {
	drawtype = "glasslike",
	groups = { not_in_creative_inventory = 1 },
	light_source = 14, -- This is a light source so that lamps don't get placed near it
	-- Somethings don't work reliably when done in the map building
	-- so we use a timer to run them later when they work more reliably
	-- e.g. spawning mobs, running minetest.find_path
	on_timer = function(pos, _)
		local meta = minetest.get_meta(pos)
		minetest.swap_node(pos, { name = meta:get_string("node_type") })
		mcl_villages.post_process_village(meta:get_string("blockseed"))
		return false
	end,
})

function mcl_villages.post_process_village(blockseed)
	local village_info = mcl_villages.get_village(blockseed)
	if not village_info then return end
	-- minetest.log("Postprocessing village")

	local settlement_info = village_info.data
	local jobs, beds = {}, {}

	local bell_pos = vector.copy(settlement_info[1].pos)
	local bell = vector.offset(bell_pos, 0, 1, 0)
	local biome_name = minetest.get_biome_name(minetest.get_biome_data(bell_pos).biome)

	-- Spawn Golem
	local l = minetest.add_entity(bell, "mobs_mc:iron_golem"):get_luaentity()
	if l then
		l._home = bell
	else
		minetest.log("info", "Could not create a golem!")
	end

	-- Spawn cats
	local sp = minetest.find_nodes_in_area_under_air(vector.offset(bell, -20, -10, -20),vector.offset(bell, 20, 10, 20), { "group:opaque" })
	for _ = 1, math.random(3) do
		local v = minetest.add_entity(vector.offset(sp[math.random(#sp)], 0, 1, 0), "mobs_mc:cat")
		if v and v:get_luaentity() then
			v:get_luaentity()._home = bell_pos -- help them stay local
		else
			minetest.log("info", "Could not spawn a cat")
			break
		end
	end

	-- collect beds and job sites
	for _, building in pairs(settlement_info) do
		local minp, maxp = building.minp, building.maxp
		if building.num_jobs then
			local jobsites = minetest.find_nodes_in_area(minp, maxp, mobs_mc.jobsites)
			for _, job_pos in pairs(jobsites) do table.insert(jobs, job_pos) end
		end

		if building.num_beds then
			local bld_beds = minetest.find_nodes_in_area(minp, maxp, { "group:bed" })
			for _, bed_pos in pairs(bld_beds) do
				local bed_group = minetest.get_item_group(minetest.get_node(bed_pos).name, "bed")
				-- We only spawn at bed bottoms, 1 is bottom, 2 is top
				if bed_group == 1 then table.insert(beds, bed_pos) end
			end
		end
	end
	-- TODO: shuffle jobs?

	-- minetest.log("beds: "..#beds.." jobsites: "..#jobs)
	if beds then
		for _, bed_pos in pairs(beds) do
			minetest.forceload_block(bed_pos, true)
			local m = minetest.get_meta(bed_pos)
			m:set_string("bell_pos", minetest.pos_to_string(bell_pos))
			if m:get_string("villager") == "" then
				local v = minetest.add_entity(vector.offset(bed_pos, 0, 0.06, 0), "mobs_mc:villager")
				if v then
					local l = v:get_luaentity()
					l._bed = bed_pos
					l._bell = bell_pos
					m:set_string("villager", l._id)
					m:set_string("infotext", S("A villager sleeps here"))

					local job_pos = table.remove(jobs, 1)
					if job_pos then villager_employ(l, job_pos) end -- HACK: merge more MCLA villager job code?
					for _, callback in pairs(mcl_villages.on_villager_placed) do callback(v, blockseed) end
				else
					minetest.log("info", "Could not create a villager!")
				end
			else
				minetest.log("info", "bed already owned by " .. m:get_string("villager")) -- should not happen unless villages overlap
			end
		end
	end
end

-- Terraform for an entire village
function mcl_villages.terraform(vm, settlement, pr)
	-- TODO: sort top-down, then bottom-up, or opposite?
	-- we make the foundations 2 node wider than necessary, to have one node for path laying
	for i, building in ipairs(settlement) do
		if not building.no_clearance then
			local pos, size = building.pos, building.size
			pos = vector.offset(pos, -math.floor((size.x-1)/2), 0, -math.floor((size.z-1)/2))
			-- TODO: allow different clearance for different buildings?
			vl_terraforming.clearance_vm(vm, pos.x-1, pos.y, pos.z-1, size.x+2, size.y, size.z+2, 2, building.surface_mat, building.dust_mat, pr)
		end
	end
	for i, building in ipairs(settlement) do
		if not building.no_ground_turnip then
			local pos, size = building.pos, building.size
			local surface_mat = building.surface_mat
			local platform_mat = building.platform_mat or { name = mcl_villages.foundation_materials[surface_mat.name] or "mcl_core:dirt" }
			local stone_mat = building.stone_mat or { name = mcl_villages.stone_materials[surface_mat.name] or "mcl_core:stone" }
			local dust_mat = building.dust_mat
			building.platform_mat = platform_mat -- remember for use in schematic placement
			building.stone_mat = stone_mat
			pos = vector.offset(pos, -math.floor((size.x-1)/2), 0, -math.floor((size.z-1)/2))
			vl_terraforming.foundation_vm(vm, pos.x-2, pos.y, pos.z-2, size.x+4, -5, size.z+4, 2, surface_mat, platform_mat, stone_mat, dust_mat, pr)
		end
	end
end
