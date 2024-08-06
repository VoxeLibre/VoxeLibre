mcl_structures.registered_structures = {}

local peaceful = minetest.settings:get_bool("only_peaceful_mobs", false)
local mob_cap_player = tonumber(minetest.settings:get("mcl_mob_cap_player")) or 75
local mob_cap_animal = tonumber(minetest.settings:get("mcl_mob_cap_animal")) or 10
local structure_boost = tonumber(minetest.settings:get("mcl_structures_boost")) or 1
local worldseed = minetest.get_mapgen_setting("seed")
local RANDOM_SEED_OFFSET = 959 -- random constant that should be unique across each library

local logging = minetest.settings:get_bool("mcl_logging_structures", true)

local mg_name = minetest.get_mapgen_setting("mg_name")

local disabled_structures = minetest.settings:get("mcl_disabled_structures")
if disabled_structures then disabled_structures = disabled_structures:split(",")
else disabled_structures = {} end
function mcl_structures.is_disabled(structname)
	return table.indexof(disabled_structures,structname) ~= -1
end

local ROTATIONS = { "0", "90", "180", "270" }
function mcl_structures.parse_rotation(rotation, pr)
	if rotation == "random" and pr then return ROTATIONS[pr:next(1,#ROTATIONS)] end
	return rotation
end

--- Get the size after rotation.
-- @param size vector: Size information
-- @param rotation string or number: only 0, 90, 180, 270 are allowed
-- @return vector: new vector, for safety
function mcl_structures.size_rotated(size, rotation)
	if rotation == "90" or rotation == "270" or rotation == 90 or rotation == 270 then
		return vector.new(size.z, size.y, size.x)
	end
	return vector.copy(size)
end

--- Get top left position after apply centering flags and padding.
-- @param pos vector: Placement position
-- @param[opt] size vector: Size information
-- @param[opt] flags string or table: as in minetest.place_schematic, place_center_x, place_center_y
-- @param[opt] padding number: optional margin (integer)
-- @return vector: new vector, for safety
function mcl_structures.top_left_from_flags(pos, size, flags, padding)
	local dx, dy, dz = 0, 0, 0
	-- must match src/mapgen/mg_schematic.cpp to be consistent
	if type(flags) == "table" then
		if flags["place_center_x"] ~= nil then dx = -math.floor((size.x-1)*0.5) end
		if flags["place_center_y"] ~= nil then dy = -math.floor((size.y-1)*0.5) end
		if flags["place_center_z"] ~= nil then dz = -math.floor((size.z-1)*0.5) end
	elseif type(flags) == "string" then
		if string.find(flags, "place_center_x") then dx = -math.floor((size.x-1)*0.5) end
		if string.find(flags, "place_center_y") then dy = -math.floor((size.y-1)*0.5) end
		if string.find(flags, "place_center_z") then dz = -math.floor((size.z-1)*0.5) end
	end
	if padding then
		dx = dx - padding
		dz = dz - padding
	end
	return vector.offset(pos, dx, dy, dz)
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
--   clearance boolean or string or number: clear overhead area (offset, or "top" to begin over the structure only)
--   padding number: additional padding to increase the area, default 1
--   corners number: corner smoothing of foundation and clearance, default 1
-- pr PcgRandom: random generator
-- name string: for logging
local function emerge_schematic_vm(vm, param)
	local pos, size, prepare, surface_mat = param.pos, param.size, param.prepare, nil
	-- adjust ground to a move level position
	if pos and size and prepare and (prepare.tolerance or 10) >= 0 then
		pos, surface_mat = mcl_structures.find_level(vm, pos, size, prepare.tolerance)
		if not pos then
			minetest.log("warning", "[mcl_structures] Not spawning "..tostring(param.name or param.schematic.name).." at "..minetest.pos_to_string(param.pos).." because ground is too uneven.")
			return nil
		end
		if param.y_max and pos.y > param.y_max then pos.y = param.y_max end
		if param.y_min and pos.y < param.y_min then pos.y = param.y_min end
	end
	-- Prepare the environment
	if prepare and (prepare.clearance or prepare.foundation) then
		-- Get materials from biome:
		local b = mg_name ~= "v6" and minetest.registered_biomes[minetest.get_biome_name(minetest.get_biome_data(pos).biome)]
		local node_top    = b and b.node_top    or (surface_mat and surface_mat.name) or "mcl_core:dirt_with_grass"
		local node_filler = b and b.node_filler or "mcl_core:dirt"
		local node_stone  = b and b.node_stone  or "mcl_core:stone"
		-- FIXME: not yet used: local node_dust   = b and b.node_dust
		local node_top_param2 = node_top == "mcl_core:dirt_with_grass" and b._mcl_grass_palette_index or 0 -- grass color, also other materials?

		local corners, padding, depth = prepare.corners or 1, prepare.padding or 1, (type(prepare.foundation) == "number" and prepare.foundation) or -4
		local gp = vector.offset(pos, -math.floor((size.x-1)*0.5) - padding, 0, -math.floor((size.z-1)*0.5)-padding)
		local gs = vector.offset(size, padding*2, depth, padding*2)
		if prepare.clearance then
			-- minetest.log("action", "[mcl_structures] clearing air "..minetest.pos_to_string(gp).." +"..minetest.pos_to_string(gs).." corners "..corners)
			-- TODO: add more parameters?
			local yoff, height = 0, size.y + (param.yoffset or 0)
			if prepare.clearance == "top" or prepare.clearance == "above" then
				yoff, height = height, 0
			elseif type(prepare.clearance) == "number" then
				yoff, height = prepare.clearance, height - prepare.clearance
			end
			mcl_structures.clearance(vm, gp.x, gp.y + yoff, gp.z, gs.x, height, gs.z, corners, {name=node_top, param2=node_top_param2}, param.pr)
		end
		if prepare.foundation then
			-- minetest.log("action", "[mcl_structures] fill foundation "..minetest.pos_to_string(gp).." +"..minetest.pos_to_string(gs).." corners "..corners)
			local depth = (type(prepare.foundation) == "number" and prepare.foundation) or -3
			mcl_structures.foundation(vm, gp.x, gp.y - 1, gp.z, gs.x, depth, gs.z, corners,
						{name=node_top, param2=node_top_param2}, {name=node_filler}, {name=node_stone}, param.pr)
		end
	end
	-- place the actual schematic
	pos.y = pos.y + (param.yoffset or 0)
	minetest.place_schematic_on_vmanip(vm, pos, param.schematic, param.rotation, param.replacements, param.force_placement, "place_center_x,place_center_z")
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
	vm:write_to_map(true)
	if not pos then return end
	-- repair walls (TODO: port to vmanip? but no "vm.find_nodes_in_area" yet)
	local pmin = vector.offset(pos, -math.floor((param.size.x-1)*0.5), 0, -math.floor((param.size.z-1)*0.5))
	local pmax = vector.offset(pmin, param.size.x-1, param.size.y-1, param.size.z-1)
	if pmin and pmax and mcl_walls then
		for _, n in pairs(minetest.find_nodes_in_area(pmin, pmax, { "group:wall" })) do
			mcl_walls.update_wall(n)
		end
	end
	if pmin and pmax and param.after_placement_callback then
		param.after_placement_callback(pmin, pmax, param.size, param.rotation, param.pr, param.callback_param)
	end
end

local DEFAULT_PREPARE = { tolerance = 8, foundation = -3, clearance = false, padding = 1, corners = 1 }
local DEFAULT_FLAGS = "place_center_x,place_center_z"
function mcl_structures.place_schematic(pos, yoffset, y_min, y_max, schematic, rotation, replacements, force_placement, flags, prepare, pr, after_placement_callback, callback_param)
	if schematic and not schematic.size then -- e.g., igloo still passes filenames
		schematic = loadstring(minetest.serialize_schematic(schematic, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic")()
	end
	rotation = mcl_structures.parse_rotation(rotation, pr)
	local size = mcl_structures.size_rotated(schematic.size, rotation)
	-- area to emerge; note that alignment flags could be non-center, although we almost always use place_center_x,place_center_z
	local pmin = mcl_structures.top_left_from_flags(pos, flags or DEFAULT_FLAGS)
	local ppos = vector.offset(pmin, math.floor((size.x-1)*0.5), 0, math.floor((size.z-1)*0.5)) -- center
	local pmax = vector.offset(pmin, size.x - 1, size.y - 1, size.z - 1)
	if prepare == nil or prepare == true then prepare = DEFAULT_PREPARE end
	if prepare == false then prepare = {} end
	-- area to emerge. Add some margin to allow for finding better suitable ground etc.
	local emin, emax = vector.offset(pmin, -1, -5, -1), vector.offset(pmax, 1, 5, 1)
	if prepare then emin.y = emin.y - (prepare.tolerance or 10) end
	-- if we need to generate a foundation, we need to emerge a larger area:
	if prepare.foundation or prepare.clearance then
		-- these functions need some extra margins
		local padding, depth, height = (prepare.padding or 0) + 3, (prepare.depth or -4) - 15, size.y * 2 + 6
		emin = vector.offset(pmin, -padding, depth + math.min(yoffset or 0, 0), -padding)
		emax = vector.offset(pmax, padding, height + math.max(yoffset or 0, 0), padding)
	end
	minetest.emerge_area(emin, emax, emerge_schematic, {
		emin=emin, emax=emax, name=schematic.name or (type(schematic)=="string" and schematic),
		pos=ppos, size=size, yoffset=yoffset, y_min=y_min, y_max=y_max,
		schematic=schematic, rotation=rotation, replacements=replacements, force_placement=force_placement,
		prepare=prepare, pr=pr,
		after_placement_callback=after_placement_callback, callback_param=callback_param
	})
end

-- Call all on_construct handlers
-- also called from mcl_villages for job sites
function mcl_structures.init_node_construct(pos)
	local node = minetest.get_node(pos)
	local def = node and minetest.registered_nodes[node.name]
	if def and def.on_construct then def.on_construct(pos) end
end

-- Find nodes to call on_construct handlers for
function mcl_structures.construct_nodes(p1,p2,nodes)
	local nn = minetest.find_nodes_in_area(p1,p2,nodes)
	for _,p in pairs(nn) do mcl_structures.init_node_construct(p) end
end

function mcl_structures.fill_chests(p1,p2,loot,pr)
	for it,lt in pairs(loot) do
		local nodes = minetest.find_nodes_in_area(p1, p2, it)
		for _,p in pairs(nodes) do
			local lootitems = mcl_loot.get_multi_loot(lt, pr)
			mcl_structures.init_node_construct(p)
			local meta = minetest.get_meta(p)
			local inv = meta:get_inventory()
			mcl_loot.fill_inventory(inv, "main", lootitems, pr)
		end
	end
end

function mcl_structures.spawn_mobs(mob,spawnon,p1,p2,pr,n,water)
	n = n or 1
	local sp = {}
	if water then
		local nn = minetest.find_nodes_in_area(p1,p2,spawnon)
		for k,v in pairs(nn) do
			if minetest.get_item_group(minetest.get_node(vector.offset(v,0,1,0)).name,"water") > 0 then
				table.insert(sp,v)
			end
		end
	else
		sp = minetest.find_nodes_in_area_under_air(p1,p2,spawnon)
	end
	table.shuffle(sp)
	local count = 0
	local mob_def = minetest.registered_entities[mob]
	local enabled = (not peaceful) or (mob_def and mob_def.spawn_class ~= "hostile")
	for _,node in pairs(sp) do
		if enabled and count < n and minetest.add_entity(vector.offset(node, 0, 1, 0), mob) then
			count = count + 1
		end
		minetest.get_meta(node):set_string("spawnblock", "yes") -- note: also in peaceful mode!
	end
end

function mcl_structures.place_structure(pos, def, pr, blockseed, rot)
	if not def then return end
	local log_enabled = logging and not def.terrain_feature
	-- currently only used by fallen_tree, to check for sufficient empty space to fall
	if def.on_place and not def.on_place(pos,def,pr,blockseed) then
		if log_enabled then
			minetest.log("warning","[mcl_structures] "..def.name.." at "..minetest.pos_to_string(pos).." not placed. on_place conditions not satisfied.")
		end
		return false
	end
	-- Apply vertical offset for schematic
	local yoffset = (type(def.y_offset) == "function" and def.y_offset(pr)) or def.y_offset or 0
	if def.schematics and #def.schematics > 0 then
		local schematic = def.schematics[pr:next(1,#def.schematics)]
		rot = mcl_structures.parse_rotation(rot or "random", pr)
		if not def.daughters then
			mcl_structures.place_schematic(pos, yoffset, def.y_min, def.y_max, schematic, rot, def.replacements, def.force_placement, "place_center_x,place_center_z", def.prepare, pr,
				function(p1, p2, size, rotation)
					if def.loot then mcl_structures.fill_chests(p1,p2,def.loot,pr) end
					if def.construct_nodes then mcl_structures.construct_nodes(p1,p2,def.construct_nodes) end
					if def.after_place then def.after_place(pos,def,pr,p1,p2,size,rotation) end
					if log_enabled then
						minetest.log("action", "[mcl_structures] "..def.name.." spawned at "..minetest.pos_to_string(pos))
					end
				end)
		else -- currently only nether bulwarks + nether outpost with bridges?
			-- FIXME: this really needs to be run in a single emerge!
			mcl_structures.place_schematic(pos, yoffset, def.y_min, def.y_max, schematic, rot, def.replacements, def.force_placement, "place_center_x,place_center_z", def.prepare, pr,
				function(p1, p2, size, rotation)
					for i,d in pairs(def.daughters) do
						local ds = d.files[pr:next(1,#d.files)]
						-- Daughter schematics are not loaded yet.
						if ds and not ds.size then
							ds = loadstring(minetest.serialize_schematic(ds, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic")()
						end
						-- FIXME: apply centering, apply parent rotation.
						local rot = d.rot or 0
						local dsize = mcl_structures.size_rotated(ds.size, rot)
						local p = vector.new(math.floor((p1.x+p2.x)*0.5) + d.pos.x - math.floor((dsize.x-1)*0.5), p1.y + (yoffset or 0) + d.pos.y, math.floor((p1.z+p2.z)*0.5) + d.pos.z - math.floor((dsize.z-1)*0.5))
						local callback = nil
						if i == #def.daughters then
							callback = function()
								-- Note: deliberately pos, p1 and p2 from the parent, as these are calls to the parent.
								if def.loot then mcl_structures.fill_chests(p1,p2,def.loot,pr) end
								if def.construct_nodes then mcl_structures.construct_nodes(p1,p2,def.construct_nodes) end
								if def.after_place then def.after_place(pos,def,pr,p1,p2,size,rotation) end
								if log_enabled then
									minetest.log("action", "[mcl_structures] "..def.name.." spawned at "..minetest.pos_to_string(pos))
								end
							end
						end
						mcl_structures.place_schematic(p, yoffset, d.y_min or def.y_min, d.y_max or def.y_max, ds, rot, nil, true, "place_center_x,place_center_y", d.prepare, pr, callback)
					end
				end)
		end
		if log_enabled then
			minetest.log("verbose", "[mcl_structures] "..def.name.." to be placed at "..minetest.pos_to_string(pos))
		end
		return true
	end
	if not def.place_func then
		minetest.log("warning","[mcl_structures] no schematics and no place_func for schematic "..def.name)
		return false
	end
	if def.solid_ground and def.sidelen and not def.prepare then
		-- TODO: this assumes place_center, make padding configurable, use actual size?
		local ground_p1 = vector.offset(pos,-math.floor(def.sidelen/2),-1,-math.floor(def.sidelen/2))
		local ground_p2 = vector.offset(ground_p1,def.sidelen-1,0,def.sidelen-1)
		local solid = minetest.find_nodes_in_area(ground_p1,ground_p2,{"group:solid"})
		if #solid < def.sidelen * def.sidelen then
			if log_enabled then
				minetest.log("warning", "[mcl_structures] "..def.name.." at "..minetest.pos_to_string(pos).." not placed. No solid ground.")
			end
			return false
		end
	end
	local pp = yoffset ~= 0 and vector.offset(pos, 0, yoffset, 0) or pos
	if def.place_func and def.place_func(pp,def,pr,blockseed) then
		if not def.after_place or (def.after_place and def.after_place(pp,def,pr,blockseed)) then
			if def.prepare then
				minetest.log("warning", "[mcl_structures] needed prepare for "..def.name.." placed at "..minetest.pos_to_string(pp).." but did not have size information")
			end
			if def.sidelen then
				local p1, p2 = vector.offset(pos,-def.sidelen,-def.sidelen,-def.sidelen), vector.offset(pos,def.sidelen,def.sidelen,def.sidelen)
				if def.loot then mcl_structures.fill_chests(p1,p2,def.loot,pr) end
				if def.construct_nodes then mcl_structures.construct_nodes(p1,p2,def.construct_nodes) end
			end
			if log_enabled then
				minetest.log("action","[mcl_structures] "..def.name.." placed at "..minetest.pos_to_string(pp))
			end
			return true
		else
			minetest.log("warning","[mcl_structures] after_place failed for schematic "..def.name)
			return false
		end
	elseif log_enabled then
		minetest.log("warning","[mcl_structures] place_func failed for schematic "..def.name)
	end
end

local EMPTY_SCHEMATIC = { size = {x = 0, y = 0, z = 0}, data = { } }
function mcl_structures.register_structure(name,def,nospawn) --nospawn means it will not be placed by mapgen decoration mechanism
	if mcl_structures.is_disabled(name) then return end
	def.name = name
	def.prepare = def.prepare or (type(def.make_foundation) == table and def.make_foundation)
	def.flags = def.flags or "place_center_x, place_center_z, force_placement"
	if def.filenames then
		if #def.filenames == 0 then
			minetest.log("warning","[mcl_structures] schematic "..name.." has an empty list of filenames.")
		end
		def.schematics = def.schematics or {}
		for _, filename in ipairs(def.filenames) do
			if not mcl_util.file_exists(filename) then
				minetest.log("warning","[mcl_structures] schematic "..name.." is missing file "..tostring(filename))
			else

				-- load, and ensure we have size information
				local s = nil --minetest.read_schematic(filename)
				if not s or not s.size then
					s = loadstring(minetest.serialize_schematic(filename, "lua", {lua_use_comments = false, lua_num_indent_spaces = 0}) .. " return schematic")()
				end
				if not s then
					minetest.log("warning", "[mcl_structures] failed to load schematic "..tostring(filename))
				elseif not s.size then
					minetest.log("warning", "[mcl_structures] no size information for schematic "..tostring(filename))
				else
					if logging then
						minetest.log("verbose", "[mcl_structures] loaded schematic "..tostring(filename).." size "..minetest.pos_to_string(s.size))
					end
					if not s.name then s.name = name or filename end
					table.insert(def.schematics, s)
				end
			end
		end
	end
	if not def.noise_params and def.chunk_probability and not def.fill_ratio then
		def.fill_ratio = 1.1/80/80 -- 1 per chunk, controlled by chunk probability only
	end
	mcl_structures.registered_structures[name] = def
	if nospawn then return end -- ice column, boulder
	if def.place_on then
		minetest.register_on_mods_loaded(function() --make sure all previous decorations and biomes have been registered
			mcl_mapgen_core.register_decoration({
				name = "mcl_structures:"..name,
				rank = def.rank or (def.terrain_feature and 900) or 100, -- run before regular decorations
				deco_type = "schematic",
				schematic = EMPTY_SCHEMATIC,
				place_on = def.place_on,
				spawn_by = def.spawn_by,
				num_spawn_by = def.num_spawn_by,
				sidelen = 80, -- no def.sidelen subdivisions for now
				fill_ratio = def.fill_ratio,
				noise_params = def.noise_params,
				flags = def.flags,
				biomes = def.biomes,
				y_max = def.y_max,
				y_min = def.y_min,
				gen_callback = function(t,minp,maxp,blockseed)
					for _, pos in ipairs(t) do
						local pr = PcgRandom(minetest.hash_node_position(pos) + worldseed + RANDOM_SEED_OFFSET)
						if def.chunk_probability == nil or pr:next(0, 1e9) * 1e-9 * def.chunk_probability <= 1 then
							mcl_structures.place_structure(pos, def, pr, blockseed)
							if def.chunk_probability ~= nil then break end -- allow only one per gennotify, e.g., on multiple surfaces
						end
					end
				end
			})
		end)
	end
end

local structure_spawns = {}
function mcl_structures.register_structure_spawn(def)
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
			local p = vector.offset(pos,0,1,0)
			local pname = minetest.get_node(p).name
			if def.type_of_spawning == "water" then
				if pname ~= "mcl_core:water_source" and pname ~= "mclx_core:river_water_source" then return end
			else
				if pname ~= "air" then return end
			end
			if minetest.get_meta(pos):get_string("spawnblock") == "" then return end
			if mg_name ~= "v6" and mg_name ~= "singlenode" and def.biomes then
				if table.indexof(def.biomes,minetest.get_biome_name(minetest.get_biome_data(p).biome)) == -1 then
					return
				end
			end
			local mobdef = minetest.registered_entities[def.name]
			if mobdef.can_spawn and not mobdef.can_spawn(p) then return end
			minetest.add_entity(p,def.name)
		end,
	})
end

-- To avoid a cyclic dependency, run this when modules have finished loading
minetest.register_on_mods_loaded(function()
mcl_mapgen_core.register_generator("static structures", nil, function(minp, maxp, blockseed)
	for _,struct in pairs(mcl_structures.registered_structures) do
		if struct.static_pos then
			local pr = PcgRandom(blockseed + RANDOM_SEED_OFFSET)
			for _, pos in pairs(struct.static_pos) do
				if vector.in_area(pos, minp, maxp) then
					mcl_structures.place_structure(pos, struct, pr, blockseed)
				end
			end
		end
	end
	return false, false, false
end, 100, true)
end)

