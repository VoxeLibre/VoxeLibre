vl_structures.registered_structures = {}

local mob_cap_player = tonumber(minetest.settings:get("mcl_mob_cap_player")) or 75
local mob_cap_animal = tonumber(minetest.settings:get("mcl_mob_cap_animal")) or 10
local structure_boost = tonumber(minetest.settings:get("vl_structures_boost")) or 1
local worldseed = minetest.get_mapgen_setting("seed")
local RANDOM_SEED_OFFSET = 959 -- random constant that should be unique across each library
local floor = math.floor
local vector_offset = vector.offset

-- FIXME: switch to vl_structures_logging?
local logging = true or minetest.settings:get_bool("mcl_logging_structures", true)

-- FIXME: switch to vl_structures_disabled?
local disabled_structures = minetest.settings:get("mcl_disabled_structures")
disabled_structures = disabled_structures and disabled_structures:split(",") or {}
function mcl_structures.is_disabled(structname)
	return table.indexof(disabled_structures,structname) ~= -1
end

local mg_name = minetest.get_mapgen_setting("mg_name")

-- see vl_terraforming for documentation
local DEFAULT_PREPARE = { tolerance = 10, foundation = -3, clear = false, clear_bottom = 0, clear_top = 4, padding = 1, corners = 1 }
local DEFAULT_FLAGS = "place_center_x,place_center_z"

local function parse_prepare(prepare)
	if prepare == nil or prepare == true then return DEFAULT_PREPARE end
	if prepare == false then return {} end
	if prepare.foundation == true then
		prepare = table.copy(prepare)
		prepare.foundation = DEFAULT_PREPARE.foundation
	end
	return prepare
end

-- check "enabled" tolerances
local function tolerance_enabled(tolerance, mode)
	return mode ~= "off" and tolerance and (tolerance == "max" or tolerance == "min" or tolerance >= 0) and true
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

-- Expected contents of param:
-- pos vector: position (center.x, base.y, center.z) -- flags NOT supported
-- size vector: structure size after rotation (!)
-- yoffset number: relative to base.y, typically <= 0
-- y_min number: minimum y range permitted
-- y_max number: maximum y range permitted
-- schematic string or schematic: as in minetest.place_schematic
-- rotation string: as in minetest.place_schematic
-- replacement table: as in minetest.place_schematic
-- force_placement boolean: as in minetest.place_schematic
-- prepare table: instructions for preparation (usually from definition)
--   tolerance number: tolerable ground unevenness, -1 to disable, default 10
--   foundation boolean or number: level ground underneath structure (true is a minimum depth of -3)
--   clear boolean: clear overhead area
--   clear_min number or string: height from base to start clearing, "top" to start at top
--   clear_max number: height from top to stop primary clearing
--   padding number: additional padding to increase the area, default 1
--   corners number: corner smoothing of foundation and clear, default 1
-- pr PcgRandom: random generator
-- name string: for logging
local function emerge_schematic_vm(vm, param)
	local pos, size, yoffset, pr = param.pos, param.size, param.yoffset or 0, param.pr
	local prepare, surface_mat = parse_prepare(param.prepare), param.surface_mat
	-- Step 1: adjust ground to a more level position
	if pos and size and prepare and tolerance_enabled(prepare.tolerance, prepare.mode) then
		pos, surface_mat = vl_terraforming.find_level_vm(vm, pos, size, prepare.tolerance, prepare.mode)
		if not pos then
			minetest.log("warning", "[vl_structures] Not spawning "..tostring(param.schematic.name).." at "..minetest.pos_to_string(param.pos).." because ground is too uneven.")
			return
		end
	end
	local pmin = vector_offset(pos, -floor((size.x-1)*0.5), yoffset, -floor((size.z-1)*0.5))
	local pmax = vector_offset(pmin, size.x-1, size.y-1, size.z-1)
	-- Step 2: prepare ground foundations and clear
	if prepare and (prepare.clear or prepare.foundation) then
		local prepare_start = os.clock()
		-- Get materials from biome:
		local b = mg_name ~= "v6" and minetest.registered_biomes[minetest.get_biome_name(minetest.get_biome_data(pos).biome)]
		local node_top    = b and b.node_top and { name = b.node_top } or surface_mat or { name = "mcl_core:dirt_with_grass" }
		local node_filler = { name = b and b.node_filler or "mcl_core:dirt" }
		local node_stone  = { name = b and b.node_stone  or "mcl_core:stone" }
		local node_dust   = b and b.node_dust and { name = b.node_dust } or nil
		if node_top.name == "mcl_core:dirt_with_grass" and b then node_top.param2 = b._mcl_grass_palette_index end

		local corners, padding, depth = prepare.corners or 1, prepare.padding or 1, (type(prepare.foundation) == "number" and prepare.foundation) or -4
		local gp = vector_offset(pmin, -padding, -yoffset, -padding) -- base level
		if prepare.clear then
			local yoff, ymax = prepare.clear_bottom or 0, size.y + yoffset + (prepare.clear_top or DEFAULT_PREPARE.clear_top)
			if prepare.clear_bottom == "top" or prepare.clear_bottom == "above" then yoff = size.y + yoffset end
			--minetest.log("action", "[vl_structures] clearing air "..minetest.pos_to_string(gp)..": ".. (size.x + padding * 2)..","..ymax..","..(size.z + padding * 2))
			vl_terraforming.clearance_vm(vm, gp.x, gp.y + yoff, gp.z,
				size.x + padding * 2, ymax - yoff, size.z + padding * 2,
				corners, node_top, node_dust, pr)
		end
		if prepare.foundation then
			minetest.log("action", "[vl_structures] fill foundation "..minetest.pos_to_string(gp).." with "..tostring(node_top.name).." "..tostring(node_filler.name))
			local depth = (type(prepare.foundation) == "number" and prepare.foundation) or DEFAULT_PREPARE.foundation
			vl_terraforming.foundation_vm(vm, gp.x, gp.y - 1, gp.z,
				size.x + padding * 2, depth, size.z + padding * 2,
				corners, node_top, node_filler, node_stone, node_dust, pr)
		end
	end
	-- note: pos is always the center position
	minetest.place_schematic_on_vmanip(vm, vector_offset(pos, 0, (param.yoffset or 0), 0), param.schematic, param.rotation, param.replacements, param.force_placement, "place_center_x,place_center_z")
	return pos
end

-- Additional parameters:
-- emin vector: emerge area minimum
-- emax vector: emerge area maximum
-- after_placement_callback function: callback after placement, (pmin, pmax, size, rotation, pr, param)
-- callback_param table: additional parameters to callback function
local function emerge_schematic(blockpos, action, calls_remaining, param)
	if calls_remaining >= 1 then return end
	local vm = VoxelManip()
	vm:read_from_map(param.emin, param.emax)
	local pos = emerge_schematic_vm(vm, param)
	if not pos then return end
	vm:write_to_map(true)
	-- repair walls (TODO: port to vmanip? but no "vm.find_nodes_in_area" yet)
	local pmin = vector_offset(pos, -floor((param.size.x-1)*0.5), 0, -floor((param.size.z-1)*0.5))
	local pmax = vector_offset(pmin, param.size.x-1, param.size.y-1, param.size.z-1)
	if pmin and pmax and mcl_walls then
		for _, n in pairs(minetest.find_nodes_in_area(pmin, pmax, { "group:wall" })) do
			mcl_walls.update_wall(n)
		end
	end
	if pmin and pmax and param.after_placement_callback then
		param.after_placement_callback(pmin, pmax, param.size, param.rotation, param.pr, param.callback_param)
	end
end

function vl_structures.place_schematic(pos, yoffset, y_min, y_max, schematic, rotation, replacements, force_placement, flags, prepare, pr, after_placement_callback, callback_param)
	if schematic and not schematic.size then -- e.g., igloo still passes filenames
		schematic = vl_structures.load_schematic(schematic)
	end
	rotation = vl_structures.parse_rotation(rotation, pr)
	prepare = parse_prepare(prepare)
	local ppos, pmin, pmax, size = vl_structures.get_extends(pos, schematic.size, yoffset, rotation, flags or DEFAULT_FLAGS)
	-- area to emerge. Add some margin to allow for finding better suitable ground etc.
	local tolerance = prepare.tolerance or DEFAULT_PREPARE.tolerance -- may be negative to disable foundations
	if not type(tolerance) == "number" then tolerance = 8 end -- for emerge only
	local emin, emax = vector_offset(pmin, 0, -math.max(tolerance, 0), 0), vector.offset(pmax, 0, math.max(tolerance, 0), 0)
	-- if we need to generate a foundation, we need to emerge a larger area:
	if prepare.foundation or prepare.clear then -- these functions need some extra margins
		local padding = (prepare.padding or 0) + 3
		local depth = prepare.foundation and ((prepare.depth or -4) - 15) or 0 -- minimum depth
		local height = prepare.clear and (size.y * 2 + 6) or 0 -- headroom
		emin = vector_offset(emin, -padding, depth, -padding)
		emax = vector_offset(emax,  padding, height, padding)
	end
	minetest.emerge_area(emin, emax, emerge_schematic, {
		emin=emin, emax=emax, name=schematic.name,
		pos=ppos, size=size, yoffset=yoffset, y_min=y_min, y_max=y_max,
		schematic=schematic, rotation=rotation, replacements=replacements, force_placement=force_placement,
		prepare=prepare, pr=pr,
		after_placement_callback=after_placement_callback, callback_param=callback_param
	})
end

local function emerge_complex_schematics(blockpos, action, calls_remaining, param)
	if calls_remaining >= 1 then return end
	local start = os.clock()
	local vm = VoxelManip()
	vm:read_from_map(param.emin, param.emax)
	local startmain = os.clock()
	local pos, size, yoffset, def, pr = param.pos, param.size, param.yoffset or 0, param.def, param.pr
	local prepare, surface_mat = parse_prepare(param.prepare or def.prepare), param.surface_mat

	-- pick random daughter schematics + rotations
	local daughters = {}
	if def.daughters then
		for i,d in pairs(def.daughters) do
			if not d.schematics or #d.schematics == 0 then
				error("Daughter schematics not loaded for structure "..def.name)
			end
			local ds = d.schematics[#d.schematics > 1 and pr:next(1,#d.schematics) or 1]
			local rotation = vl_structures.parse_rotation(d.rotation, pr)
			table.insert(daughters, {d, ds, rotation})
		end
	end

	-- Step 1: adjust ground to a more level position
	if pos and size and prepare and tolerance_enabled(prepare.tolerance, prepare.mode) then
		pos, surface_mat = vl_terraforming.find_level_vm(vm, pos, size, prepare.tolerance, prepare.mode)
		if not pos then
			minetest.log("warning", "[vl_structures] Not spawning "..tostring(def.name or param.schematic.name).." at "..minetest.pos_to_string(param.pos).." because ground is too uneven.")
			return
		end
		-- obey height restrictions, to not violate nether roof
		if def.y_max and pos.y - yoffset > def.y_max then pos.y = def.y_max - yoffset end
		if def.y_min and pos.y - yoffset < def.y_min then pos.y = def.y_min - yoffset end
	end
	--if logging and not def.terrain_feature then minetest.log("action", "[vl_structures] "..def.name.." after find_level at "..minetest.pos_to_string(pos).." in "..string.format("%.2fms (main: %.2fms)", (os.clock()-start)*1000, (os.clock()-startmain)*1000)) end
	local pmin = vector_offset(pos, -floor((size.x-1)*0.5), yoffset, -floor((size.z-1)*0.5))
	local pmax = vector_offset(pmin, size.x-1, size.y-1, size.z-1)
	-- todo: also support checking ground of daughter schematics, but not used by current schematics
	-- Step 2: prepare ground foundations and clear
	-- todo: allow daugthers to use prepare when parent does not
	if prepare and (prepare.clear or prepare.foundation) then
		local prepare_start = os.clock()
		-- Get materials from biome:
		local b = mg_name ~= "v6" and minetest.registered_biomes[minetest.get_biome_name(minetest.get_biome_data(pos).biome)]
		local node_top    = b and b.node_top and { name = b.node_top } or surface_mat or { name = "mcl_core:dirt_with_grass" }
		local node_filler = { name = b and b.node_filler or "mcl_core:dirt" }
		local node_stone  = { name = b and b.node_stone  or "mcl_core:stone" }
		local node_dust   = b and b.node_dust and { name = b.node_dust } or nil
		if node_top.name == "mcl_core:dirt_with_grass" and b then node_top.param2 = b._mcl_grass_palette_index end

		local corners, padding, depth = prepare.corners or 1, prepare.padding or 1, (type(prepare.foundation) == "number" and prepare.foundation) or -4
		local gp = vector_offset(pmin, -padding, -yoffset, -padding) -- base level
		if prepare.clear then
			local yoff, ymax = prepare.clear_bottom or 0, size.y + yoffset + (prepare.clear_top or DEFAULT_PREPARE.clear_top)
			if prepare.clear_bottom == "top" or prepare.clear_bottom == "above" then yoff = size.y + yoffset end
			--minetest.log("action", "[vl_structures] clearing air "..minetest.pos_to_string(gp)..": ".. (size.x + padding * 2)..","..ymax..","..(size.z + padding * 2))
			vl_terraforming.clearance_vm(vm, gp.x, gp.y + yoff, gp.z,
				size.x + padding * 2, ymax - yoff, size.z + padding * 2,
				corners, node_top, node_dust, pr)
			-- clear for daughters
			for _,tmp in ipairs(daughters) do
				local dd, ds, dr = tmp[1], tmp[2], tmp[3]
				local ddp = parse_prepare(dd.prepare)
				if ddp and ddp.clear then
					local dsize = vl_structures.size_rotated(ds.size, dr) -- FIXME: rotation of parent
					local corners, padding, yoffset = ddp.corners or 1, ddp.padding or 1, ddp.yoffset or 0
					local yoff, ymax = ddp.clear_bottom or 0, dsize.y + yoffset + (ddp.clear_top or DEFAULT_PREPARE.clear_top)
					if ddp.clear_bottom == "top" or ddp.clear_bottom == "above" then yoff = dsize.y + yoffset end
					local gp = vector_offset(pos, dd.pos.x - floor((dsize.x-1)*0.5) - padding,
					                              dd.pos.y,
					                              dd.pos.z - floor((dsize.z-1)*0.5) - padding)
					local sy = ymax - yoff
					--minetest.log("action", "[vl_structures] clearing air "..minetest.pos_to_string(gp)..": ".. (dsize.x + padding * 2)..","..sy..","..(dsize.z + padding * 2))
					if sy > 0 then
						vl_terraforming.clearance_vm(vm, gp.x, gp.y + yoff, gp.z,
							dsize.x + padding * 2, ymax - yoff, dsize.z + padding * 2,
							corners, node_top, node_dust, pr)
					end
				end
			end
		end
		-- if logging and not def.terrain_feature then minetest.log("action", "[vl_structures] "..def.name.." after clear at "..minetest.pos_to_string(pos).." in "..string.format("%.2fms (main: %.2fms)", (os.clock()-start)*1000, (os.clock()-prepare_start)*1000)) end
		if prepare.foundation then
			-- minetest.log("action", "[vl_structures] fill foundation "..minetest.pos_to_string(gp).." with "..tostring(node_top.name).." "..tostring(node_filler.name))
			local depth = (type(prepare.foundation) == "number" and prepare.foundation) or DEFAULT_PREPARE.foundation
			vl_terraforming.foundation_vm(vm, gp.x, gp.y - 1, gp.z,
				size.x + padding * 2, depth, size.z + padding * 2,
				corners, node_top, node_filler, node_stone, node_dust, pr)
			-- foundation for daughters
			for _, tmp in ipairs(daughters) do
				local dd, ds, dr = tmp[1], tmp[2], tmp[3]
				local ddp = parse_prepare(dd.prepare)
				if ddp and ddp.foundation then
					local dsize = vl_structures.size_rotated(ds.size, dr) -- FIXME: rotation of parent
					local corners, padding, yoffset = ddp.corners or 1, ddp.padding or 1, ddp.yoffset or 0
					local depth = (type(ddp.foundation) == "number" and ddp.foundation) or DEFAULT_PREPARE.foundation
					local gp = vector_offset(pos, dd.pos.x - floor((dsize.x-1)*0.5) - padding,
					                              dd.pos.y + (yoffset or 0),
					                              dd.pos.z - floor((dsize.z-1)*0.5) - padding)
					vl_terraforming.foundation_vm(vm, gp.x, gp.y - 1, gp.z,
						dsize.x + padding * 2, depth, dsize.z + padding * 2,
						corners, node_top, node_filler, node_stone, node_dust, pr)
				end
			end
		end
		-- if logging and not def.terrain_feature then minetest.log("action", "[vl_structures] "..def.name.." prepared at "..minetest.pos_to_string(pos).." in "..string.format("%.2fms (main: %.2fms)", (os.clock()-start)*1000, (os.clock()-prepare_start)*1000)) end
	end

	-- note: pos is always the center position
	minetest.place_schematic_on_vmanip(vm, vector_offset(pos, 0, (param.yoffset or 0), 0), param.schematic, param.rotation, param.replacements, param.force_placement, "place_center_x,place_center_z")

	for _,tmp in ipairs(daughters) do
		local d, ds, rot = tmp[1], tmp[2], tmp[3]
		--local dsize = vl_structures.size_rotated(ds.size, rot)
		--local p = vector_offset(pos, d.pos.x - floor((ds.size.x-1)*0.5), d.pos.y + (yoffset or 0),
		--                             d.pos.z - floor((ds.size.z-1)*0.5))
		local p = vector_offset(pos, d.pos.x, d.pos.y + (yoffset or 0), d.pos.z)
		minetest.place_schematic_on_vmanip(vm, p, ds, rot, d.replacements, d.force_placement, "place_center_x,place_center_z")
	end
	local endmain = os.clock()
	vm:write_to_map(true)
	-- Note: deliberately pos, p1 and p2 from the parent, as these are calls to the parent.
	if def.loot then vl_structures.fill_chests(pmin,pmax,def.loot,pr) end
	if def.construct_nodes then vl_structures.construct_nodes(pmin,pmax,def.construct_nodes) end
	if def.after_place then def.after_place(pos,def,pr,pmin,pmax,size,param.rotation) end
	if logging and not def.terrain_feature then
		minetest.log("action", "[vl_structures] "..def.name.." spawned at "..minetest.pos_to_string(pos).." in "..string.format("%.2fms (main: %.2fms)", (os.clock()-start)*1000, (endmain-startmain)*1000))
	end
end

--- Place a schematic with daughters (nether bulwark, nether outpost with bridges)
local function place_complex_schematics(pos, yoffset, schematic, rotation, def, pr)
	if schematic and not schematic.size then -- e.g., igloo still passes filenames
		schematic = vl_structures.load_schematic(schematic)
	end
	rotation = vl_structures.parse_rotation(rotation, pr)
	local prepare = parse_prepare(def.prepare)
	local ppos, pmin, pmax, size = vl_structures.get_extends(pos, schematic.size, yoffset, rotation, def.flags or DEFAULT_FLAGS)
	-- area to emerge. Add some margin to allow for finding better suitable ground etc.
	local tolerance = prepare.tolerance or DEFAULT_PREPARE.tolerance -- may be negative to disable foundations
	if type(tolerance) ~= "number" then tolerance = 10 end -- for emerge only, min/max/liquid_surface
	local emin, emax = vector_offset(pmin, 0, -math.max(tolerance, 0), 0), vector.offset(pmax, 0, math.max(tolerance, 0), 0)
	-- if we need to generate a foundation, we need to emerge a larger area:
	if prepare.foundation or prepare.clear then -- these functions need some extra margins. Must match mcl_foundations!
		local padding = (prepare.padding or 0) + 3
		local depth = prepare.foundation and ((type(prepare.foundation) == "number" and prepare.foundation or DEFAULT_PREPARE.foundation) - 3) or 0 -- minimum depth
		local height = prepare.clear and ((prepare.clear_top or DEFAULT_PREPARE.clear_top)*1.5+0.5*(size.y+yoffset)+2) or 0 -- headroom
		emin = vector_offset(emin, -padding, depth, -padding)
		emax = vector_offset(emax,  padding, height, padding)
	end
	-- finally, add the configured emerge margin for daugther schematics
	-- TODO: compute this instead?
	if def.emerge_padding then
		if #def.emerge_padding ~= 2 then error("Schematic "..def.name.." has an incorrect 'emerge_padding'. Must be two vectors.") end
		emin, emax = emin + def.emerge_padding[1], emax + def.emerge_padding[2]
	end
	-- if logging and not def.terrain_feature then minetest.log("action", "[vl_structures] "..def.name.." needs emerge "..minetest.pos_to_string(emin).."-"..minetest.pos_to_string(emax)) end
	minetest.emerge_area(emin, emax, emerge_complex_schematics, { name = def.name,
		emin=emin, emax=emax, def=def, schematic=schematic,
		pos=ppos, yoffset=yoffset, size=size, rotation=rotation,
		pr=pr
	})
end

-- TODO: remove blockseed?
function vl_structures.place_structure(pos, def, pr, blockseed, rot)
	if not def then return end
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
		place_complex_schematics(pos, yoffset, schematic, rot, def, pr)
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

--nospawn means it will be placed by another (non-nospawn) structure that contains it's structblock i.e. it will not be placed by mapgen directly
function vl_structures.register_structure(name,def,nospawn)
	if vl_structures.is_disabled(name) then return end
	def.name = name
	vl_structures.registered_structures[name] = def
	if def.prepare and def.prepare.clear == nil and (def.prepare.clear_bottom or def.prepare.clear_top) then def.prepare.clear = true end
	if not def.noise_params and def.chunk_probability and not def.fill_ratio then
		def.fill_ratio = 1.1/80/80 -- 1 per chunk, controlled by chunk probability only
	end
	if nospawn or def.nospawn then return end -- ice column, boulder
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
				schematic = { size = {x = 1, y = 1, z = 1}, data = { { name = "ignore" } } },
				place_on = def.place_on,
				spawn_by = def.spawn_by,
				num_spawn_by = def.num_spawn_by,
				sidelen = 80, -- no def.sidelen subdivisions for now, this field was used differently before
				fill_ratio = def.fill_ratio,
				noise_params = def.noise_params,
				flags = def.flags or "place_center_x, place_center_z",
				biomes = def.biomes,
				y_max = def.y_max,
				y_min = def.y_min
			}, function()
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
				local realpos = vector_offset(pos, 0, 1, 0)
				if struct.chunk_probability == nil or pr:next(0, 1e9)/1e9 * struct.chunk_probability <= structure_boost then
					vl_structures.place_structure(realpos, struct, pr, blockseed)
					if struct.chunk_probability then break end -- one (attempt) per chunk only
				end
			end
		elseif struct.static_pos then
			local pr
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

