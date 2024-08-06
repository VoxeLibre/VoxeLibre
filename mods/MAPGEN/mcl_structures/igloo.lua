local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

local function spawn_mobs(p1,p2,vi,zv)
	local mc = minetest.find_nodes_in_area_under_air(p1,p2,{"mcl_core:stonebrickmossy"})
	if #mc == 2 then
		local vp, zp = mc[1], mc[2]
		if not vi and zv and zv:get_pos() and vector.distance(mc[1],zv:get_pos()) < 2 then
			vp = mc[2]
		elseif not zv and vi and vi:get_pos() and vector.distance(mc[2],vi:get_pos()) < 2 then
			zp = mc[1]
		elseif zv and vi then
			return
		end
		vi = minetest.add_entity(vector.offset(mc[1],0,1,0),"mobs_mc:villager")
		zv = minetest.add_entity(vector.offset(mc[2],0,1,0),"mobs_mc:villager_zombie")
		minetest.after(1,spawn_mobs,p1,p2,vi,zv)
	end
end

local function generate_igloo_basement(pos, orientation, loot, pr)
end

local function generate_igloo(pos, def, pr)
	local path = modpath.."/schematics/mcl_structures_igloo_top.mts"
	local rotation = tostring(pr:next(0,3)*90)
	-- TODO: ymin, ymax
	mcl_structures.place_schematic(pos, -2, nil, nil, path, rotation, nil, true, nil, {padding=0, corners=2}, pr, function(p1, p2)
		mcl_structures.construct_nodes(p1, p2, {"mcl_furnaces:furnace","mcl_books:bookshelf"})
		-- Place igloo basement with 50% chance
		local r = 1--pr:next(1,2)
		if r == 1 then
			-- Select basement depth
			local dim = mcl_worlds.pos_to_dimension(pos)
			local buffer
			if dim == "nether" then
				buffer = pos.y - (mcl_vars.mg_lava_nether_max + 10)
			elseif dim == "end" then
				buffer = pos.y - (mcl_vars.mg_end_min + 1)
			elseif dim == "overworld" then
				buffer = pos.y - (mcl_vars.mg_lava_overworld_max + 10)
			else
				return true
			end
			if buffer <= 9 then return true end
			local depth = pr:next(9, buffer)
			local bpos = vector.new(pos.x, pos.y-depth, pos.z)
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
				minetest.log("bad rotation: "..tostring(rotation))
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
				minetest.set_node(pos, {name=brick})
			end
			local real_depth = 0
			-- Check how deep we can actually dig
			for y=1, depth-5 do
				real_depth = real_depth + 1
				local node = minetest.get_node(vector.new(tpos.x, tpos.y-y, tpos.z))
				local def = node and minetest.registered_nodes[node.name]
				if not (def and def.walkable and def.liquidtype == "none" and def.is_ground_content) then
					bpos.y = tpos.y-y+1
					break
				end
			end
			if real_depth <= 6 then
				minetest.log("not deep enough")
				return false
			end
			local path = modpath.."/schematics/mcl_structures_igloo_basement.mts"
			mcl_structures.place_schematic(bpos, 0, nil, nil, path, rotation, nil, true, nil, nil, pr, function(p1, p2)
				-- Generate ladder to basement
				local ladder = {name="mcl_core:ladder", param2=minetest.dir_to_wallmounted(tdir)}
				minetest.set_node(tpos, {name="mcl_doors:trapdoor", param2=20+minetest.dir_to_facedir(dir)}) -- TODO: more reliable param2
				for y=1, real_depth do
					set_brick(vector.new(tpos.x-1, tpos.y-y, tpos.z  ))
					set_brick(vector.new(tpos.x+1, tpos.y-y, tpos.z  ))
					set_brick(vector.new(tpos.x  , tpos.y-y, tpos.z-1))
					set_brick(vector.new(tpos.x  , tpos.y-y, tpos.z+1))
					minetest.set_node(vector.new(tpos.x, tpos.y-y, tpos.z), ladder)
				end
				mcl_structures.fill_chests(p1,p2,def.loot,pr)
				mcl_structures.construct_nodes(p1,p2,{"mcl_brewing:stand_000","mcl_books:bookshelf"})
				spawn_mobs(p1,p2)
			end)
		end
	end)
	return true
end

mcl_structures.register_structure("igloo",{
	place_on = {"mcl_core:snowblock","mcl_core:snow","group:grass_block_snow"},
	sidelen = 16,
	chunk_probability = 7,
	solid_ground = true,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 0,
	y_offset = -2,
	biomes = { "ColdTaiga", "IcePlainsSpikes", "IcePlains" },
	place_func = generate_igloo,
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
