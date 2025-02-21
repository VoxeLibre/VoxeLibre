vl_structures.registered_structures = {}

local logging = core.settings:get_bool("vl_structures_logging", false)
local structure_boost = tonumber(core.settings:get("vl_structures_boost")) or 1
local disabled_structures = core.settings:get("vl_structures_disabled")
disabled_structures = disabled_structures and disabled_structures:split(",") or {}

local worldseed = core.get_mapgen_setting("seed")
local RANDOM_SEED_OFFSET = 959 -- random constant that should be unique across each library

--- Trim a full path name to its last two parts as short name for logging
local function basename(filename)
	local fn = string.split(filename, "/")
	return #fn > 1 and (fn[#fn-1].."/"..fn[#fn]) or fn[#fn]
end

--- Load a schematic file, ensure we have the size information
-- @param filename string: file name
-- @param name string: for logging, optional
-- @return loaded schematic
function vl_structures.load_schematic(filename, name)
	-- load, and ensure we have size information
	if filename == nil then error("Filename is nil for schematic "..tostring(name)) end
	if type(filename) == "string" then core.log("verbose", "Loading "..filename) end
	local s = loadstring(core.serialize_schematic(filename, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic")()
	if not s then
		core.log("warning", "[vl_structures] failed to load schematic "..basename(filename))
		return nil
	elseif not s.size then
		core.log("warning", "[vl_structures] no size information for schematic "..basename(filename))
		return nil
	end
	if logging then core.log("action", "[vl_structures] loaded schematic "..basename(filename).." size "..core.pos_to_string(s.size)) end
	if not s.name then s.name = name or basename(filename) end
	return s
end

-- @param pos vector: Position
-- @param def table: containing
--   pos vector: position (center.x, base.y, center.z) -- flags NOT supported, resolve before!
--   size vector: structure size after rotation (!)
--   yoffset number: relative to base.y, typically <= 0
--   y_min number: minimum y range permitted
--   y_max number: maximum y range permitted
--   schematic string or schematic: as in core.place_schematic
--   rotation string: as in core.place_schematic
--   replacement table: as in core.place_schematic
--   force_placement boolean: as in core.place_schematic
--   prepare table: instructions for preparation (usually from definition)
--     tolerance number: tolerable ground unevenness, -1 to disable, default 10
--     foundation boolean or number: level ground underneath structure (true is a minimum depth of -3)
--     clear boolean: clear overhead area
--     clear_min number or string: height from base to start clearing, "top" to start at top
--     clear_max number: height from top to stop primary clearing
--     padding number: additional padding to increase the area, default 1
--     corners number: corner smoothing of foundation and clear, default 1
--   name string: for logging
--   place_func function: to call when placing the structure
-- @param pr PcgRandom: random generator
-- @param blockseed number: passed to place_func only
-- @param rot string: rotation
function vl_structures.place_structure(pos, def, pr, blockseed, rot)
	if not pos or not def then return end
	local log_enabled = logging and not def.terrain_feature
	-- load schematics the first time
	if def.filenames and not def.schematics then
		if #def.filenames == 0 then core.log("warning","[vl_structures] schematic "..def.name.." has an empty list of filenames.") end
		def.schematics = {}
		for _, filename in ipairs(def.filenames) do
			local s = vl_structures.load_schematic(filename, def.name)
			if s then table.insert(def.schematics, s) end
		end
		if def.daughters then
			for _,d in pairs(def.daughters) do
				d.schematics = {}
				for _, filename in ipairs(d.filenames) do
					local s = vl_structures.load_schematic(filename, d.name)
					if s then table.insert(d.schematics, s) end
				end
			end
		end
	end
	-- Apply vertical offset for schematic
	local yoffset = (type(def.y_offset) == "function" and def.y_offset(pr)) or def.y_offset or 0
	if def.schematics and #def.schematics > 0 then
		local schematic = def.schematics[pr:next(1,#def.schematics)]
		rot = vl_structures.parse_rotation(rot or "random", pr)
		vl_structures.place_schematic(pos, yoffset, schematic, rot, def, pr)
		if log_enabled then
			core.log("verbose", "[vl_structures] "..def.name.." to be placed at "..core.pos_to_string(pos))
		end
		return true
	end
	-- structure has a custom place function
	if not def.place_func then
		core.log("warning", "[vl_structures] no schematics and no place_func for schematic "..def.name)
		return false
	end
	local pp = yoffset ~= 0 and vector.offset(pos, 0, yoffset, 0) or pos
	if def.place_func and def.prepare then
		core.log("warning", "[vl_structures] needed prepare for "..def.name.." placed at "..core.pos_to_string(pp).." but do not have size information.")
	end
	if def.place_func and def.place_func(pp,def,pr,blockseed) then
		if def.after_place and not def.after_place(pos,def,pr,pmin,pmax,size,param.rotation) then
			core.log("warning", "[vl_structures] after_place failed for structure "..def.name)
			return false
		end
		if def.name and not (def.terrain_feature or def.no_registry) then vl_structures.register_structures_spawn(def.name, pos) end
		if log_enabled then
			core.log("action", "[vl_structures] "..def.name.." placed at "..core.pos_to_string(pp))
		end
		return true
	elseif log_enabled then
		if def.place_func then
			core.log("warning", "[vl_structures] place_func failed for structure "..def.name)
		else
			core.log("warning", "[vl_structures] do not know how to place structure "..def.name)
		end
	end
end

-- local EMPTY_SCHEMATIC = { size = {x = 1, y = 1, z = 1}, data = { { name = "ignore" } } }
local EMPTY_SCHEMATIC = { size = {x = 0, y = 0, z = 0}, data = { } }

--- Register a structure
-- @param name string: Structure name
-- @param def table: Structure definition
function vl_structures.register_structure(name, def)
	def.name = def.name or name
	if table.indexof(disabled_structures, name) ~= -1 then return end
	if def.prepare and def.prepare.clear == nil and (def.prepare.clear_bottom or def.prepare.clear_top) then def.prepare.clear = true end
	if not def.fill_ratio and def.chunk_probability and not def.noise_params then
		def.fill_ratio = 1.1/80/80 -- 1 per chunk, controlled by chunk probability only
	end
	def.flags = def.flags or vl_structures.DEFAULT_FLAGS
	if def.filenames and mcl_util then
		for _, filename in ipairs(def.filenames) do
			if not mcl_util.file_exists(filename) then
				core.log("warning", "[vl_structures] structure "..name.." is missing file "..basename(filename))
				return nil
			end
		end
	end
	vl_structures.registered_structures[name] = def
	if not def.place_on then return end -- only for /spawnstruct, for example
	-- gennotify callback function, c.f., mcl_mapgen_core.register_decoration
	local function gen_callback(t, minp, maxp, blockseed)
		for _, pos in ipairs(t) do
			local pr = PcgRandom(mcl_util.hash_pos(pos.x, pos.y, pos.z, worldseed + RANDOM_SEED_OFFSET))
			if def.chunk_probability == nil or pr:next(0, 1e9) * 1e-9 * def.chunk_probability <= structure_boost then
				if vl_structures.place_structure(pos, def, pr, blockseed) then
					if def.chunk_probability ~= nil then break end -- allow only one per gennotify, e.g., on multiple surfaces
				end
			end
		end
	end
	mcl_mapgen_core.register_decoration({
		name = "vl_structures:"..name,
		rank = def.rank or (def.terrain_feature and 900) or 100, -- run before regular decorations
		fill_ratio = def.fill_ratio,
		noise_params = def.noise_params,
		y_max = def.y_max,
		y_min = def.y_min,
		biomes = def.biomes,
		place_on = def.place_on,
		spawn_by = def.spawn_by,
		num_spawn_by = def.num_spawn_by,
		sidelen = def.terrain_feature and (def.sidelen or 16) or 80,
		flags = def.flags,
		deco_type = "schematic",
		schematic = EMPTY_SCHEMATIC, -- use gennotify only
		gen_callback = gen_callback
	})
end

-- Persistent structure registry
local mod_storage = core.get_mod_storage()
local vl_structures_spawn_cache = {}
function vl_structures.register_structures_spawn(name, pos)
	if not name or not pos then return end
	local data = vl_structures_spawn_cache[name]
	if not data then
		data = mod_storage:get("vl_structures:spawns:"..name)
		data = data and core.deserialize(data) or {}
	end
	table.insert(data, pos)
	mod_storage:set_string("vl_structures:spawns:"..name, core.serialize(data))
	vl_structures_spawn_cache[name] = data
end
function vl_structures.get_structure_spawns(name)
	if name == nil then
		local ret = {}
		for k, _ in pairs(vl_structures_spawn_cache) do
			table.insert(ret, k)
		end
		return ret
	end
	local data = vl_structures_spawn_cache[name]
	if not data then
		data = mod_storage:get("vl_structures:spawns:"..name)
		if not data then return nil end
		data = core.deserialize(data)
		vl_structures_spawn_cache[name] = data
	end
	return table.copy(data)
end

-- To avoid a cyclic dependency, run this when modules have finished loading
-- Maybe we can eventually remove this - the end portal should likely go into the mapgen itself.
core.register_on_mods_loaded(function()
mcl_mapgen_core.register_generator("static structures", nil, function(minp, maxp, blockseed)
	for _,struct in pairs(vl_structures.registered_structures) do
		if struct.static_pos then
			local pr -- initialize only when needed below
			for _, pos in pairs(struct.static_pos) do
				if vector.in_area(pos, minp, maxp) then
					pr = pr or PcgRandom(blockseed + worldseed + RANDOM_SEED_OFFSET)
					vl_structures.place_structure(pos, struct, pr, blockseed)
				end
			end
		end
	end
	return false, false, false
end, 100, true) -- light in the end is sensitive to these options
end)

