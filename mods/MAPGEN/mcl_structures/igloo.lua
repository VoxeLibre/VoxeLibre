local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)

local function spawn_mobs(p1,p2,vi,zv)
	local mc = core.find_nodes_in_area_under_air(p1,p2,{"mcl_core:stonebrickmossy"})
	if #mc == 2 then
		local vp, zp = mc[1], mc[2]
		if not vi and zv and zv:get_pos() and vector.distance(mc[1],zv:get_pos()) < 2 then
			vp = mc[2]
		elseif not zv and vi and vi:get_pos() and vector.distance(mc[2],vi:get_pos()) < 2 then
			zp = mc[1]
		elseif zv and vi then
			return
		end
		vi = core.add_entity(vector.offset(vp,0,1,0),"mobs_mc:villager")
		zv = core.add_entity(vector.offset(zp,0,1,0),"mobs_mc:villager_zombie")
		if vi and vi:get_pos() and zv and zv:get_pos() then
			core.after(1,spawn_mobs,p1,p2,vi,zv)
		end
	end
end

local function igloo_callback(cpos,def,pr,p1,p2,size,rotation)
	vl_structures.construct_nodes(p1, p2, {"mcl_furnaces:furnace","mcl_books:bookshelf"})
	-- Place igloo basement with 50% chance
	if pr:next(1,2) == 1 then return end
	local pos = p1 -- we use top left as reference
	-- Select basement depth
	local maxdepth = pos.y - (mcl_vars.mg_lava_overworld_max + 10)
	if maxdepth <= 9 then return true end
	local depth = pr:next(9, maxdepth)
	-- trapdoor position and orientation
	local tpos, dir, tdir
	if rotation == "0" then
		dir = vector.new(-1, 0, 0)
		tdir = vector.new(1, 0, 0)
		tpos = vector.new(pos.x+7, pos.y, pos.z+3)
	elseif rotation == "90" then
		dir = vector.new(0, 0, -1)
		tdir = vector.new(0, 0, -1)
		tpos = vector.new(pos.x+3, pos.y, pos.z+1)
	elseif rotation == "180" then
		dir = vector.new(1, 0, 0)
		tdir = vector.new(-1, 0, 0)
		tpos = vector.new(pos.x+1, pos.y, pos.z+3)
	elseif rotation == "270" then
		dir = vector.new(0, 0, 1)
		tdir = vector.new(0, 0, 1)
		tpos = vector.new(pos.x+3, pos.y, pos.z+7)
	else
		core.log("bad rotation: "..tostring(rotation))
		return false
	end
	local function set_brick(pos)
		local c = pr:next(1, 3) -- cracked chance
		local m = pr:next(1, 10) -- chance for monster egg
		local brick
		if m == 1 then
			brick = (c == 1 and "mcl_monster_eggs:monster_egg_stonebrickcracked") or "mcl_monster_eggs:monster_egg_stonebrick"
		else
			brick = (c == 1 and "mcl_core:stonebrickcracked") or "mcl_core:stonebrick"
		end
		core.swap_node(pos, {name=brick})
	end
	local real_depth = 2
	-- Check how deep we can actually dig
	for y=pos.y-real_depth, pos.y-depth, -1 do
		real_depth = real_depth + 1
		local node = core.get_node(vector.new(tpos.x, y, tpos.z))
		local def = node and core.registered_nodes[node.name]
		if not (def and def.walkable and def.liquidtype == "none" and def.is_ground_content) then break end
	end
	local bpos = vector.new(cpos.x, pos.y-real_depth+1, cpos.z)
	if real_depth <= 6 then
		core.log("action", "Ground not deep enough for igloo basement: "..real_depth)
		return false
	end
	local path = modpath.."/schematics/mcl_structures_igloo_basement.mts"
	vl_structures.place_schematic(bpos, -1, path, rotation, {
		name = "igloo_basement",
		force_placement = true,
		prepare = { tolerance = "off", foundation = false, clear = false },
		after_place = function(_, _, pr, p1, p2)
			-- Generate ladder to basement
			local ladder = {name="mcl_core:ladder", param2=core.dir_to_wallmounted(tdir)}
			core.swap_node(tpos, {name="mcl_doors:trapdoor", param2=20+core.dir_to_facedir(dir)}) -- TODO: more reliable param2
			-- TODO: use bulk swap? but igloos are rare anyway.
			for y = tpos.y-1, bpos.y+4, -1 do
				set_brick(vector.new(tpos.x-1, y, tpos.z  ))
				set_brick(vector.new(tpos.x+1, y, tpos.z  ))
				set_brick(vector.new(tpos.x  , y, tpos.z-1))
				set_brick(vector.new(tpos.x  , y, tpos.z+1))
				core.swap_node(vector.new(tpos.x, y, tpos.z), ladder)
			end
			vl_structures.fill_chests(p1,p2,def.loot,pr)
			-- TODO: add something into brewing stand?
			vl_structures.construct_nodes(p1,p2,{"mcl_brewing:stand_000","mcl_books:bookshelf"})
			spawn_mobs(p1,p2)
		end
	}, pr)
end

vl_structures.register_structure("igloo",{
	chunk_probability = 0.5,
	hash_mindist_2d = 80,
	filenames = { modpath.."/schematics/mcl_structures_igloo_top.mts" },
	place_on = {"mcl_core:snowblock","mcl_core:snow","group:grass_block_snow"},
	prepare = { tolerance = 3, padding = 1, corners = 1, foundation = -6, clear_top = -1 },
	y_max = mcl_vars.mg_overworld_max,
	y_min = 0,
	y_offset = -1,
	biomes = { "ColdTaiga", "IcePlainsSpikes", "IcePlains" },
	after_place = igloo_callback,
	loot = {
		["mcl_chests:chest_small"] = {{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "mcl_core:apple_gold", weight = 1 },
			}
		},
		{
			stacks_min = 2,
			stacks_max = 8,
			items = {
				{ itemstring = "mcl_core:coal_lump", weight = 15, amount_min = 1, amount_max = 4 },
				{ itemstring = "mcl_core:apple", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_farming:wheat_item", weight = 10, amount_min = 2, amount_max = 3 },
				{ itemstring = "mcl_core:gold_nugget", weight = 10, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 10 },
				{ itemstring = "mcl_tools:axe_stone", weight = 2 },
				{ itemstring = "mcl_core:emerald", weight = 1 },
				{ itemstring = "mcl_core:apple_gold", weight = 1 },
			}
		}},
	}
})
