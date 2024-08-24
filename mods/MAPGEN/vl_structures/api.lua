vl_structures.registered_structures = {}

local structure_boost = tonumber(minetest.settings:get("vl_structures_boost")) or 1
local worldseed = minetest.get_mapgen_setting("seed")
local RANDOM_SEED_OFFSET = 959 -- random constant that should be unique across each library

local vector_offset = vector.offset

-- FIXME: switch to vl_structures_logging?
local logging = true or minetest.settings:get_bool("mcl_logging_structures", true)

-- FIXME: switch to vl_structures_disabled?
local disabled_structures = minetest.settings:get("mcl_disabled_structures")
disabled_structures = disabled_structures and disabled_structures:split(",") or {}
function mcl_structures.is_disabled(structname)
	return table.indexof(disabled_structures,structname) ~= -1
end

--- Trim a full path name to its last two parts as short name for logging
local function basename(filename)
	local fn = string.split(filename, "/")
	return #fn > 1 and (fn[#fn-1].."/"..fn[#fn]) or fn[#fn]
end

--- Load a schematic file
-- @param filename string: file name
-- @param name string: for logging, optional
-- @return loaded schematic
function vl_structures.load_schematic(filename, name)
	-- load, and ensure we have size information
	if filename == nil then error("Filename is nil for schematic "..tostring(name)) end
	if type(filename) == "string" then minetest.log("action", "Loading "..filename) end
	local s = loadstring(minetest.serialize_schematic(filename, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic")()
	if not s then
		minetest.log("warning", "[vl_structures] failed to load schematic "..basename(filename))
		return nil
	elseif not s.size then
		minetest.log("warning", "[vl_structures] no size information for schematic "..basename(filename))
		return nil
	end
	if logging then minetest.log("warning", "[vl_structures] loaded schematic "..basename(filename).." size "..minetest.pos_to_string(s.size)) end
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
--   schematic string or schematic: as in minetest.place_schematic
--   rotation string: as in minetest.place_schematic
--   replacement table: as in minetest.place_schematic
--   force_placement boolean: as in minetest.place_schematic
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
		if #def.filenames == 0 then minetest.log("warning","[vl_structures] schematic "..def.name.." has an empty list of filenames.") end
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
			minetest.log("verbose", "[vl_structures] "..def.name.." to be placed at "..minetest.pos_to_string(pos))
		end
		return true
	end
	-- structure has a custom place function
	if not def.place_func then
		minetest.log("warning","[vl_structures] no schematics and no place_func for schematic "..def.name)
		return false
	end
	local pp = yoffset ~= 0 and vector_offset(pos, 0, yoffset, 0) or pos
	if def.place_func and def.prepare then
		minetest.log("warning", "[vl_structures] needed prepare for "..def.name.." placed at "..minetest.pos_to_string(pp).." but do not have size information")
	end
	if def.place_func and def.place_func(pp,def,pr,blockseed) then
		if not def.after_place or (def.after_place and def.after_place(pos,def,pr,pmin,pmax,size,param.rotation)) then
			if def.sidelen then
				local p1, p2 = vector_offset(pos,-def.sidelen,-def.sidelen,-def.sidelen), vector.offset(pos,def.sidelen,def.sidelen,def.sidelen)
				if def.loot then vl_structures.fill_chests(p1,p2,def.loot,pr) end
				if def.construct_nodes then vl_structures.construct_nodes(p1,p2,def.construct_nodes) end
			end
			if log_enabled then
				minetest.log("action","[vl_structures] "..def.name.." placed at "..minetest.pos_to_string(pp))
			end
			return true
		else
			minetest.log("warning","[vl_structures] after_place failed for schematic "..def.name)
			return false
		end
	elseif log_enabled then
		minetest.log("warning","[vl_structures] place_func failed for schematic "..def.name)
	end
end

local EMPTY_SCHEMATIC = { size = {x = 1, y = 1, z = 1}, data = { { name = "ignore" } } }
-- local EMPTY_SCHEMATIC = { size = {x = 0, y = 0, z = 0}, data = { } }

--- Register a structure
-- @param name string: Structure name
-- @param def table: Structure definition
function vl_structures.register_structure(name,def)
	if vl_structures.is_disabled(name) then return end
	def.name = name
	vl_structures.registered_structures[name] = def
	if def.prepare and def.prepare.clear == nil and (def.prepare.clear_bottom or def.prepare.clear_top) then def.prepare.clear = true end
	if not def.noise_params and def.chunk_probability and not def.fill_ratio then
		def.fill_ratio = 1.1/80/80 -- 1 per chunk, controlled by chunk probability only
	end
	if def.filenames then
		for _, filename in ipairs(def.filenames) do
			if not mcl_util.file_exists(filename) then
				minetest.log("warning","[vl_structures] schematic "..(name or "unknown").." is missing file "..basename(filename))
				return nil
			end
		end
	end
	if def.place_on then
		minetest.register_on_mods_loaded(function()
			def.deco = mcl_mapgen_core.register_decoration({
				name = "vl_structures:deco_"..name,
				rank = def.rank or (def.terrain_feature and 900) or 100, -- run before regular decorations
				deco_type = "schematic",
				schematic = EMPTY_SCHEMATIC, -- use gennotify only
				place_on = def.place_on,
				spawn_by = def.spawn_by,
				num_spawn_by = def.num_spawn_by,
				sidelen = 80, -- no def.sidelen subdivisions for now, this field was used differently before
				fill_ratio = def.fill_ratio,
				noise_params = def.noise_params,
				flags = def.flags,
				biomes = def.biomes,
				y_max = def.y_max,
				y_min = def.y_min
			}, function() -- callback when mcl_mapgen_core has reordered the decoration calls
				def.deco_id = minetest.get_decoration_id("vl_structures:deco_"..name)
				minetest.set_gen_notify({decoration=true}, { def.deco_id })
			end)
		end)
	end
end

-- To avoid a cyclic dependency, run this when modules have finished loading
minetest.register_on_mods_loaded(function()
mcl_mapgen_core.register_generator("structures", nil, function(minp, maxp, blockseed)
	local gennotify = minetest.get_mapgen_object("gennotify")
	for _,struct in pairs(vl_structures.registered_structures) do
		if struct.deco_id then
			for _, pos in pairs(gennotify["decoration#"..struct.deco_id] or {}) do
				local pr = PcgRandom(minetest.hash_node_position(pos) + worldseed + RANDOM_SEED_OFFSET)
				if struct.chunk_probability == nil or pr:next(0, 1e9) * 1e-9 * struct.chunk_probability <= structure_boost then
					vl_structures.place_structure(vector_offset(pos, 0, 1, 0), struct, pr, blockseed)
					if struct.chunk_probability ~= nil then break end -- allow only one per gennotify, e.g., on multiple surfaces
				end
			end
		elseif struct.static_pos then
			local pr -- initialize only when needed below
			for _, pos in pairs(struct.static_pos) do
				if vector.in_area(pos, minp, maxp) then
					pr = pr or PcgRandom(worldseed + RANDOM_SEED_OFFSET)
					vl_structures.place_structure(pos, struct, pr, blockseed)
				end
			end
		end
	end
	return false, false, false
end, 100, true)
end)

local structure_spawns = {}
function vl_structures.register_structure_spawn(def)
	--name,y_min,y_max,spawnon,biomes,chance,interval,limit
	minetest.register_abm({
		label = "Spawn "..def.name,
		nodenames = def.spawnon,
		min_y = def.y_min or -31000,
		max_y = def.y_max or 31000,
		interval = def.interval or 60,
		chance = def.chance or 5,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local limit = def.limit or 7
			if active_object_count_wider > limit + mob_cap_animal then return end
			if active_object_count_wider > mob_cap_player then return end
			local p = vector_offset(pos, 0, 1, 0)
			local pname = minetest.get_node(p).name
			if def.type_of_spawning == "water" then
				if pname ~= "mcl_core:water_source" and pname ~= "mclx_core:river_water_source" then return end
			else
				if pname ~= "air" then return end
			end
			if minetest.get_meta(pos):get_string("spawnblock") == "" then return end
			if mg_name ~= "v6" and mg_name ~= "singlenode" and def.biomes then
				if table.indexof(def.biomes, minetest.get_biome_name(minetest.get_biome_data(p).biome)) == -1 then
					return
				end
			end
			local mobdef = minetest.registered_entities[def.name]
			if mobdef.can_spawn and not mobdef.can_spawn(p) then return end
			minetest.add_entity(p, def.name)
		end,
	})
end

