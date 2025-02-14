local registered_generators = {}

local lvm, nodes, param2 = 0, 0, 0
local lvm_buffer, lvm_buffer2 = {}, {}

local logging = minetest.settings:get_bool("mcl_logging_mapgen", false)
local log_timing = minetest.settings:get_bool("mcl_logging_mapgen_timing", false) -- detailed, for performance debugging
local seed = minetest.get_mapgen_setting("seed")

minetest.register_on_generated(function(minp, maxp, blockseed)
	local t1 = os.clock()
	if lvm > 0 then
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local area = VoxelArea(emin, emax)
		local data = vm:get_data(lvm_buffer)
		local data2 = param2 > 0 and vm:get_param2_data(lvm_buffer2)
		if log_timing then
			minetest.log("action", string.format("[mcl_mapgen_core] %-20s %s ... %s %8.2fms", "get_data", minetest.pos_to_string(minp), minetest.pos_to_string(maxp), (os.clock() - t1)*1000))
		end

		local lvm_used, shadow, deco_used, deco_table, ore_used, ore_table = false, false, false, false, false, false
		for _, gen in ipairs(registered_generators) do
			if gen.vf then
				local gt1 = os.clock()
				local p1, p2 = vector.copy(minp), vector.copy(maxp) -- defensive copies against some generator changing the vectors
				local e1, e2 = vector.copy(emin), vector.copy(emax) -- defensive copies against some generator changing the vectors
				local lvm_used0, shadow0, deco, ore = gen.vf(vm, data, data2, e1, e2, area, p1, p2, blockseed)
				lvm_used = lvm_used or lvm_used0
				shadow = shadow or shadow0
				if deco and type(deco) == "table" then
					assert(not deco_table, "Only one generator may currently set a decoration table")
					deco_table = deco
				elseif deco then
					deco_used = true
				end
				if ore and type(ore) == "table" then
					assert(not ore_table, "Only one generator may currently set an ore table")
					ore_table = ore
				elseif deco then
					ore_used = true
				end
				if log_timing then
					minetest.log("action", string.format("[mcl_mapgen_core] %-20s %s ... %s %8.2fms", gen.id, minetest.pos_to_string(minp), minetest.pos_to_string(maxp), (os.clock() - gt1)*1000))
				end
			end
		end

		if lvm_used then
			local gt1 = os.clock()
			vm:set_data(data)
			if param2 > 0 then vm:set_param2_data(data2) end
			if log_timing then
				minetest.log("action", string.format("[mcl_mapgen_core] %-20s %s ... %s %8.2fms", "set_data", minetest.pos_to_string(minp), minetest.pos_to_string(maxp), (os.clock() - gt1)*1000))
			end
			local gt2 = os.clock()
			if deco_used then
				minetest.generate_decorations(vm)
			elseif deco_table then
				minetest.generate_decorations(vm,vector.new(minp.x,deco_table.min,minp.z),vector.new(maxp.x,deco_table.max,maxp.z))
			end
			if log_timing and (deco_table or deco_used) then
				minetest.log("action", string.format("[mcl_mapgen_core] %-20s %s ... %s %8.2fms", "decorations", minetest.pos_to_string(minp), minetest.pos_to_string(maxp), (os.clock() - gt2)*1000))
			end
			local gt3 = os.clock()
			if ore_used then
				minetest.generate_ores(vm)
			elseif ore_table then
				minetest.generate_ores(vm,vector.new(minp.x,ore_table.min,minp.z),vector.new(maxp.x,ore_table.max,maxp.z))
			end
			if log_timing and (ore_table or ore_used) then
				minetest.log("action", string.format("[mcl_mapgen_core] %-20s %s ... %s %8.2fms", "ores", minetest.pos_to_string(minp), minetest.pos_to_string(maxp), (os.clock() - gt3)*1000))
			end
			local gt4 = os.clock()
			vm:calc_lighting(minp, maxp, shadow)
			vm:update_liquids()
			vm:write_to_map(false)
			if log_timing then
				minetest.log("action", string.format("[mcl_mapgen_core] %-20s %s ... %s %8.2fms", "light/write/liquids", minetest.pos_to_string(minp), minetest.pos_to_string(maxp), (os.clock() - gt4)*1000))
			end
		end
	end

	if nodes > 0 then
		for _, gen in ipairs(registered_generators) do
			if gen.nf then
				local gt1 = os.clock()
				gen.nf(vector.copy(minp), vector.copy(maxp), blockseed) -- defensive copies against some generator changing the vectors
				if log_timing then
					minetest.log("action", string.format("[mcl_mapgen_core] %-20s %s ... %s %8.2fms", gen.id, minetest.pos_to_string(minp), minetest.pos_to_string(maxp), (os.clock() - gt1)*1000))
				end
			end
		end
	end

	if logging then
		minetest.log("action", string.format("[mcl_mapgen_core] %-20s %s ... %s %8.2fms", "Generating chunk", minetest.pos_to_string(minp), minetest.pos_to_string(maxp), (os.clock() - t1)*1000))
	end
end)

function minetest.register_on_generated(node_function)
	mcl_mapgen_core.register_generator("mod_"..minetest.get_current_modname().."_"..tostring(#registered_generators+1), nil, node_function)
end

function mcl_mapgen_core.register_generator(id, lvm_function, node_function, priority, needs_param2)
	if not id then return end

	local priority = priority or 5000

	if lvm_function then lvm = lvm + 1 end
	if node_function then nodes = nodes + 1 end
	if needs_param2 then param2 = param2 + 1 end

	local new_record = {
		id = id,
		i = priority,
		vf = lvm_function,
		nf = node_function,
		needs_param2 = needs_param2,
	}

	table.insert(registered_generators, new_record)
	table.sort(registered_generators, function(a, b)
		return (a.i < b.i) or ((a.i == b.i) and a.vf and (b.vf == nil))
	end)
end

function mcl_mapgen_core.unregister_generator(id)
	local index
	for i, gen in ipairs(registered_generators) do
		if gen.id == id then
			index = i
			break
		end
	end
	if not index then return end
	local rec = registered_generators[index]
	table.remove(registered_generators, index)
	if rec.vf then lvm = lvm - 1 end
	if rec.nf then nodes = nodes - 1 end
	if rec.needs_param2 then param2 = param2 - 1 end
	--if rec.needs_level0 then level0 = level0 - 1 end
end

-- Try to make decorations more deterministic in order, by sorting by rank and name
-- At least for low-rank this should make map seeds more comparable, but
-- adding for example a new structure can still change everything that comes
-- later, because currently decoration blockseeds are incremented sequentially
-- c.f., https://github.com/minetest/minetest/issues/14919
local pending_decorations = {}
local gennotify_map = {}
function mcl_mapgen_core.register_decoration(def, callback)
	if def.sidelen and (80 % def.sidelen ~= 0) then
		-- c.f., https://api.luanti.org/definition-tables/#decoration-definition
		minetest.log("warning", "Decoration sidelen must be a divisors of the chunk size 80, check "..tostring(def.name))
	end
	if def.fill_ratio and def.noise_params then
		-- c.f., https://api.luanti.org/definition-tables/#decoration-definition
		minetest.log("warning", "Decoration fill_ratio is used only if noise_params is not specified, check "..tostring(def.name))
	end
	def = table.copy(def) -- defensive deep copy, needed for water lily
	if def.gen_callback and not def.name then error("gen_callback requires a named decoration.") end
	if callback then error("Callbacks have been redesigned.") end
	if pending_decorations == nil then
		-- Please do not register decorations in minetest.register_on_mods_loaded.
		-- This should usually not happen, but modders may misuse this.
		-- Nothing really bad should happen though, but the rank is ignored.
		minetest.log("warning", "Decoration registered after mapgen core initialization: "..tostring(def.name))
		minetest.register_decoration(def)
		if def.gen_callback then
			def.deco_id = minetest.get_decoration_id(def.name)
			if not def.deco_id then
				error("Failed to get the decoration id for "..tostring(key))
			else
				minetest.set_gen_notify({decoration = true}, {def.deco_id})
				gennotify_map["decoration#" .. def.deco_id] = def
			end
		end
		return
	end

	def = table.copy(def) -- defensive deep copy, needed for water lily
	pending_decorations[#pending_decorations+1] = def
end

local function sort_decorations()
	local keys, map = {}, {}
	for i, def in pairs(pending_decorations) do
		-- Name, or fallback names, for better ordering:
		local name = def.name or def.decoration
		if not name and type(def.schematic) == "string" then -- filename based
			local sc = string.split(def.schematic:gsub(".mts",""), "/")
			name = sc[#sc]
		end
		if not name and type(def.schematic) == "table" and def.schematic.data then
			name = "" -- "serialize" the schematic
			for _, v in ipairs(def.schematic.data) do
				if v.name then name = name .. v.name .. ":" end
			end
			if name == "" then name = nil end
		end
		-- sorting key is: rank, then insertion sequence, then name
		local key = string.format("%05d:%04d:%s", def.rank or 1000, i, name or "deco")
		keys[#keys+1] = key
		map[key] = def
	end
	table.sort(keys)
	for _, key in ipairs(keys) do
		local def = map[key]
		local deco_id = minetest.register_decoration(def)
		if not deco_id then
			error("Failed to register decoration"..tostring(key))
		end
		if def.name and def.gen_callback then
			deco_id = minetest.get_decoration_id(def.name)
			if not deco_id then
				error("Failed to get the decoration id for "..tostring(key))
			else
				minetest.set_gen_notify({decoration = true}, {deco_id})
				gennotify_map["decoration#" .. deco_id] = def
			end
		end
	end
	pending_decorations = nil -- as we will not run again
end

mcl_mapgen_core.register_generator("Gennotify callbacks", nil, function(minp, maxp, blockseed)
	local pr = PcgRandom(blockseed + seed + 48214) -- constant seed offset
	local gennotify = minetest.get_mapgen_object("gennotify")
	for key, def in pairs(gennotify_map) do
		local t = gennotify[key]
		if t and #t > 0 then
			-- Fisher-Yates shuffle, using pr
			for i = 1, #t-1 do
				local r = pr:next(i,#t)
				t[i], t[r] = t[r], t[i]
			end
			def.gen_callback(t, minp, maxp, blockseed)
		end
	end
end)

minetest.register_on_mods_loaded(sort_decorations)
