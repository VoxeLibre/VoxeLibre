mcl_villages.schematic_houses = {}
mcl_villages.schematic_jobs = {}
mcl_villages.schematic_lamps = {}
mcl_villages.schematic_bells = {}
mcl_villages.schematic_wells = {}
mcl_villages.on_village_placed = {}
mcl_villages.on_villager_placed = {}
mcl_villages.mandatory_buildings = {}

local S = minetest.get_translator(minetest.get_current_modname())

local function job_count(schem_lua)
	local count = 0
	for _, n in pairs(mobs_mc.jobsites) do
		if string.find(n, "^group:") then
			if n == "group:cauldron" then
				count = count + select(2, string.gsub(schem_lua, '"mcl_cauldrons:cauldron', ""))
			else
				local name = string.sub(n, 6, -1)
				local num = select(2, string.gsub(schem_lua, name, ""))
				if num then
					minetest.log("info", string.format("[mcl_villages] Guessing how to handle %s counting it as %d job sites", name, num))
					count = count + num
				else
					minetest.log("warning", string.format("[mcl_villages] Don't know how to handle group %s counting it as 1 job site", n))
					count = count + 1
				end
			end
		else
			count = count + select(2, string.gsub(schem_lua, '{name="' .. n .. '"', ""))
		end
	end

	return count
end

local function load_schema(name, mts)
	local schem_lua = minetest.serialize_schematic(mts, "lua", { lua_use_comments = false, lua_num_indent_spaces = 0 }) .. " return schematic"
	-- MCLA node names to VL for import
	if string.find(mts, "new_villages/") then
		for _, sub in pairs(mcl_villages.mcla_to_vl) do
			schem_lua = schem_lua:gsub(sub[1], sub[2])
		end
	end

	local schematic = loadstring(schem_lua)()
	return { name = name, size = schematic.size, schem_lua = schem_lua }
end

local all_optional = { "yadjust", "no_ground_turnip", "no_clearance" }

local function set_all_optional(record, data)
	for _, field in ipairs(all_optional) do
		if record[field] then data[field] = record[field] end
	end
end

local function set_mandatory(record, type)
	if record['is_mandatory'] then
		if not mcl_villages.mandatory_buildings[type] then mcl_villages.mandatory_buildings[type] = {} end
		table.insert(mcl_villages.mandatory_buildings[type], record["name"])
	end
end

function mcl_villages.register_lamp(record)
	local data = load_schema(record["name"], record["mts"])
	set_all_optional(record, data)
	table.insert(mcl_villages.schematic_lamps, data)
	set_mandatory(record, 'lamps')
end

function mcl_villages.register_bell(record)
	local data = load_schema(record["name"], record["mts"])
	set_all_optional(record, data)
	table.insert(mcl_villages.schematic_bells, data)
	set_mandatory(record, 'bells')
end

function mcl_villages.register_well(record)
	local data = load_schema(record["name"], record["mts"])
	set_all_optional(record, data)
	table.insert(mcl_villages.schematic_wells, data)
	set_mandatory(record, 'wells')
end

local optional_fields = { "min_jobs", "max_jobs", "num_others", "is_mandatory" }

function mcl_villages.register_building(record)
	local data = load_schema(record["name"], record["mts"])

	set_all_optional(record, data)
	for _, field in ipairs(optional_fields) do
		if record[field] then data[field] = record[field] end
	end

	local str = data["schem_lua"]
	local num_beds = select(2, string.gsub(str, '"mcl_beds:bed_[^"]+_bottom"', ""))
	if num_beds > 0 then data["num_beds"] = num_beds end

	local job_count = job_count(data["schem_lua"])
	if job_count > 0 then
		data["num_jobs"] = job_count
		table.insert(mcl_villages.schematic_jobs, data)
		set_mandatory(record, 'jobs')
	else
		table.insert(mcl_villages.schematic_houses, data)
		set_mandatory(record, 'houses')
	end
end

local crop_list = {}
function mcl_villages.register_crop(crop_def)
	local crops = crop_list[crop_def.type] or {}
	for biome, weight in pairs(crop_def.biomes) do
		if crops[biome] == nil then crops[biome] = {} end
		crops[biome][crop_def.node] = weight
	end
	crop_list[crop_def.type] = crops
end

function mcl_villages.get_crop_types()
	local ret = {}
	for k, _ in pairs(crop_list) do
		table.insert(ret, k)
	end
	return ret
end

function mcl_villages.get_weighted_crop(biome, crop_type, pr)
	local crops = crop_list[crop_type]
	if not crops then return end -- unknown crop
	local crops = crops[biome] or crops["plains"]

	local total = 0
	for _, weight in pairs(crops) do total = total + weight end

	local rand = pr:next(0, 1e7) * 1e-7 * total
	for node, weight in pairs(crops) do
		if rand <= weight then
			return node
		end
		rand = rand - weight
	end
	return
end

function mcl_villages.register_on_village_placed(func)
	table.insert(mcl_villages.on_village_placed, func)
end

function mcl_villages.register_on_villager_spawned(func)
	table.insert(mcl_villages.on_villager_placed, func)
end

