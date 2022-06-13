mcl_structures.registered_structures = {}

function mcl_structures.place_structure(pos, def, pr)
	if not def then	return end
	local y_offset = 0
	if type(def.y_offset) == "function" then
		y_offset = def.y_offset(pr)
	elseif def.y_offset then
		y_offset = def.y_offset
	end
	if def.filenames then
		local file = def.filenames[pr:next(1,#def.filenames)]
		local pp = vector.offset(pos,0,y_offset,0)
		mcl_structures.place_schematic(pp, file, "random", nil, true, "place_center_x,place_center_z",def.after_place,pr,{pos,def})
		minetest.log("action","[mcl_structures] "..def.name.." placed at "..minetest.pos_to_string(pos))
		return true
	elseif def.place_func and def.place_func(pos,def,pr) then
		if not def.after_place or ( def.after_place  and def.after_place(pos,def,pr) ) then
			minetest.log("action","[mcl_structures] "..def.name.." placed at "..minetest.pos_to_string(pos))
			return true
		end
	end
	minetest.log("warning","[mcl_structures] placing "..def.name.." failed at "..minetest.pos_to_string(pos))
end

function mcl_structures.register_structure(name,def,nospawn) --nospawn means it will be placed by another (non-nospawn) structure that contains it's structblock i.e. it will not be placed by mapgen directly
	local structblock = "mcl_structures:structblock_"..name
	local flags = "place_center_x, place_center_z, force_placement"
	local y_offset = 0
	local sbgroups = { structblock = 1, not_in_creative_inventory=1 }
	if def.flags then flags = def.flags end
	def.name = name
	if nospawn then
		sbgroups.structblock = nil
		sbgroups.structblock_lbm = 1
	else
		def.deco = minetest.register_decoration({
			name = "mcl_structures:deco_"..name,
			decoration = structblock,
			deco_type = "simple",
			place_on = def.place_on,
			spawn_by = def.spawn_by,
			num_spawn_by = def.num_spawn_by,
			sidelen = 80,
			fill_ratio = def.fill_ratio,
			noise_params = def.noise_params,
			flags = flags,
			biomes = def.biomes,
			y_max = def.y_max,
			y_min = def.y_min
		})
		local deco_id = minetest.get_decoration_id("mcl_structures:deco_"..name)
		minetest.set_gen_notify({decoration=true}, { deco_id })
		minetest.register_on_generated(function(minp, maxp, blockseed)
			local gennotify = minetest.get_mapgen_object("gennotify")
			local pr = PseudoRandom(blockseed + 42)
			for _, pos in pairs(gennotify["decoration#"..deco_id] or {}) do
				local realpos = vector.offset(pos,0,-1,0)
				minetest.remove_node(realpos)
				mcl_structures.place_structure(realpos,def,pr)
			end
		end)
	end
	minetest.register_node(":"..structblock, {drawtype="airlike", walkable = false, pointable = false,groups = sbgroups})
	def.structblock = structblock
	mcl_structures.registered_structures[name] = def
end

--lbm for secondary structures (structblock included in base structure)
minetest.register_lbm({
	name = "mcl_structures:struct_lbm",
	run_at_every_load = true,
	nodenames = {"group:structblock_lbm"},
	action = function(pos, node)
		local name = node.name:gsub("mcl_structures:structblock_","")
		local def = mcl_structures.registered_structures[name]
		if not def then return end
		minetest.remove_node(pos)
		mcl_structures.place_structure(pos)
	end
})
