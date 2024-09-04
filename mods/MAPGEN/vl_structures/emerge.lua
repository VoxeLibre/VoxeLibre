local vector_offset = vector.offset
local floor = math.floor

local logging = minetest.settings:get_bool("vl_structures_logging", false)
local mg_name = minetest.get_mapgen_setting("mg_name")

-- parse the prepare parameter
local function parse_prepare(prepare)
	if prepare == nil or prepare == true then return vl_structures.DEFAULT_PREPARE end
	if prepare == false then return {} end
	if prepare.foundation == true then prepare.foundation = vl_structures.DEFAULT_PREPARE.foundation end
	return prepare
end

-- check "enabled" tolerances
local function tolerance_enabled(tolerance, mode)
	return mode ~= "off" and tolerance and (tolerance == "max" or tolerance == "min" or tolerance >= 0) and true
end

--- Main palcement step, when the area has been emerged
local function emerge_schematics(blockpos, action, calls_remaining, param)
	if calls_remaining >= 1 then return end
	local start = os.clock()
	local vm = VoxelManip()
	vm:read_from_map(param.emin, param.emax)
	local startmain = os.clock()
	local pos, size, yoffset, def, pr = param.pos, param.size, param.yoffset or 0, param.def, param.pr
	local prepare, surface_mat = parse_prepare(param.prepare or def.prepare), param.surface_mat

	-- Step 0: pick random daughter schematics + rotations
	local daughters = {}
	for i,d in pairs(def.daughters or {}) do
		if not d.schematics or #d.schematics == 0 then
			error("Daughter schematics not loaded for structure "..def.name)
		end
		local ds = d.schematics[#d.schematics > 1 and pr:next(1,#d.schematics) or 1]
		local rotation = vl_structures.parse_rotation(d.rotation, pr)
		table.insert(daughters, {d, ds, rotation})
	end

	-- Step 1: adjust ground to a more level position
	-- todo: also support checking ground of daughter schematics, but not used by current schematics
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
	-- Placement area from center position:
	local pmin = vector_offset(pos, -floor((size.x-1)*0.5), yoffset, -floor((size.z-1)*0.5))
	local pmax = vector_offset(pmin, size.x-1, size.y-1, size.z-1)

	-- Step 2: prepare ground foundations and clear
	-- todo: allow daugthers to use prepare when parent does not, currently not used
	if prepare and (prepare.clear or prepare.foundation) then
		local prepare_start = os.clock()
		-- Get materials from biome (TODO: make this a function + table?):
		local b = mg_name ~= "v6" and minetest.registered_biomes[minetest.get_biome_name(minetest.get_biome_data(pos).biome)]
		local node_top    = b and b.node_top    and { name = b.node_top    } or surface_mat or vl_structures.DEFAULT_SURFACE
		local node_filler = b and b.node_filler and { name = b.node_filler } or vl_structures.DEFAULT_FILLER
		local node_stone  = b and b.node_stone  and { name = b.node_stone  } or vl_structures.DEFAULT_STONE
		local node_dust   = b and b.node_dust   and { name = b.node_dust   } or vl_structures.DEFAULT_DUST
		if node_top.name == "mcl_core:dirt_with_grass" and b then node_top.param2 = b._mcl_grass_palette_index end

		-- Step 2a: clear overhead area
		local corners, padding = prepare.corners or 1, prepare.padding or 1
		local gp = vector_offset(pmin, -padding, -yoffset, -padding) -- base level
		if prepare.clear then
			local yoff, ymax = prepare.clear_bottom or 0, size.y + yoffset + (prepare.clear_top or vl_structures.DEFAULT_PREPARE.clear_top)
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
					local yoff, ymax = ddp.clear_bottom or 0, dsize.y + yoffset + (ddp.clear_top or vl_structures.DEFAULT_PREPARE.clear_top)
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

		-- Step 2b: baseplate underneath
		if prepare.foundation then
			-- minetest.log("action", "[vl_structures] fill foundation "..minetest.pos_to_string(gp).." with "..tostring(node_top.name).." "..tostring(node_filler.name))
			local depth = (type(prepare.foundation) == "number" and prepare.foundation) or vl_structures.DEFAULT_PREPARE.foundation
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
					local depth = (type(ddp.foundation) == "number" and ddp.foundation) or vl_structures.DEFAULT_PREPARE.foundation
					local gp = vector_offset(pos, dd.pos.x - floor((dsize.x-1)*0.5) - padding,
					                              dd.pos.y + (yoffset or 0),
					                              dd.pos.z - floor((dsize.z-1)*0.5) - padding)
					vl_terraforming.foundation_vm(vm, gp.x, gp.y - 1, gp.z,
						dsize.x + padding * 2, depth, dsize.z + padding * 2,
						corners, node_top, node_filler, node_stone, node_dust, pr)
				end
			end
		end
	end

	-- Step 3: place schematic on center position
	minetest.place_schematic_on_vmanip(vm, pmin, param.schematic, param.rotation, param.replacements, param.force_placement, "")
	-- Step 3: place daughter schematics
	for _,tmp in ipairs(daughters) do
		local d, ds, rot = tmp[1], tmp[2], tmp[3]
		local p = vector_offset(pos, d.pos.x, d.pos.y + (yoffset or 0), d.pos.z)
		minetest.place_schematic_on_vmanip(vm, p, ds, rot, d.replacements, d.force_placement, "place_center_x,place_center_z")
		-- todo: allow after_place callbacks for daughter schematics?
	end
	local endmain = os.clock()
	vm:write_to_map(true)
	-- Note: deliberately pos, p1 and p2 from the parent, as these are calls to the parent script
	if def.loot then vl_structures.fill_chests(pmin,pmax,def.loot,pr) end
	if def.construct_nodes then vl_structures.construct_nodes(pmin,pmax,def.construct_nodes) end
	if def.after_place then def.after_place(pos,def,pr,pmin,pmax,size,param.rotation) end
	if logging and not def.terrain_feature then
		minetest.log("action", "[vl_structures] "..(def.name or "unnamed").." spawned at "..minetest.pos_to_string(pos).." in "..string.format("%.2fms (main: %.2fms)", (os.clock()-start)*1000, (endmain-startmain)*1000))
	end
end

--- Wrapper to emerge an appropriate area for a schematic (with daughters, such as nether bulwark, nether outpost with bridges)
vl_structures.place_schematic = function(pos, yoffset, schematic, rotation, def, pr)
	if schematic and not schematic.size then schematic = vl_structures.load_schematic(schematic) end -- legacy
	local rotation = vl_structures.parse_rotation(rotation, pr)
	local prepare = parse_prepare(def.prepare)
	local ppos, pmin, pmax, size = vl_structures.get_extends(pos, schematic.size, yoffset, rotation, def.flags or vl_structures.DEFAULT_FLAGS)
	-- area to emerge. Add some margin to allow for finding better suitable ground etc.
	local tolerance = prepare.tolerance or vl_structures.DEFAULT_PREPARE.tolerance -- may be negative to disable foundations
	if type(tolerance) ~= "number" then tolerance = 10 end -- extra height for emerge only, min/max/liquid_surface
	local emin, emax = vector_offset(pmin, 0, -math.max(tolerance, 0), 0), vector.offset(pmax, 0, math.max(tolerance, 0), 0)
	-- if we need to generate a foundation, we need to emerge a larger area:
	if prepare.foundation or prepare.clear then -- these functions need some extra margins. Must match vl_terraforming!
		local padding = (prepare.padding or 0) + 3
		local depth = prepare.foundation and ((type(prepare.foundation) == "number" and prepare.foundation or vl_structures.DEFAULT_PREPARE.foundation) - 3) or 0 -- minimum depth
		local height = prepare.clear and ((prepare.clear_top or vl_structures.DEFAULT_PREPARE.clear_top)*1.5+0.5*(size.y+yoffset)+2) or 0 -- headroom
		emin = vector_offset(emin, -padding, depth, -padding)
		emax = vector_offset(emax,  padding, height, padding)
	end
	-- finally, add the configured emerge margin for daugther schematics
	-- TODO: compute this instead? But we do not know rotations and sizes of daughters yet
	if def.emerge_padding then
		if #def.emerge_padding ~= 2 then error("Schematic "..def.name.." has an incorrect 'emerge_padding'. Must be two vectors.") end
		emin, emax = emin + def.emerge_padding[1], emax + def.emerge_padding[2]
	end
	-- if logging and not def.terrain_feature then minetest.log("action", "[vl_structures] "..def.name.." needs emerge "..minetest.pos_to_string(emin).."-"..minetest.pos_to_string(emax)) end
	minetest.emerge_area(emin, emax, emerge_schematics, { name = def.name,
		emin=emin, emax=emax, def=def, schematic=schematic,
		pos=ppos, yoffset=yoffset, size=size, rotation=rotation,
		pr=pr
	})
end

