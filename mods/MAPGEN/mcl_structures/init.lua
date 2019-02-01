local init = os.clock()
mcl_structures ={}

mcl_structures.get_struct = function(file)
	local localfile = minetest.get_modpath("mcl_structures").."/schematics/"..file
	local file, errorload = io.open(localfile, "rb")
	if errorload ~= nil then
	    minetest.log("error", '[mcl_structures] Could not open this struct: ' .. localfile)
	    return nil
	end

   local allnode = file:read("*a")
   file:close()

    return allnode
end

-- The call of Struct
mcl_structures.call_struct = function(pos, struct_style, rotation)
	if not rotation then
		rotation = "random"
	end
	if struct_style == "village" then
		return mcl_structures.generate_village(pos, rotation)
	elseif struct_style == "desert_temple" then
		return mcl_structures.generate_desert_temple(pos, rotation)
	elseif struct_style == "desert_well" then
		return mcl_structures.generate_desert_well(pos, rotation)
	elseif struct_style == "igloo" then
		return mcl_structures.generate_igloo_top(pos, rotation)
	elseif struct_style == "witch_hut" then
		return mcl_structures.generate_witch_hut(pos, rotation)
	elseif struct_style == "ice_spike_small" then
		return mcl_structures.generate_ice_spike_small(pos, rotation)
	elseif struct_style == "ice_spike_large" then
		return mcl_structures.generate_ice_spike_large(pos, rotation)
	elseif struct_style == "boulder" then
		return mcl_structures.generate_boulder(pos, rotation)
	elseif struct_style == "fossil" then
		return mcl_structures.generate_fossil(pos, rotation)
	elseif struct_style == "end_exit_portal" then
		return mcl_structures.generate_end_exit_portal(pos, rotation)
	elseif struct_style == "end_portal_shrine" then
		return mcl_structures.generate_end_portal_shrine(pos, rotation)
	end
end

mcl_structures.generate_village = function(pos)
	-- No generating for the moment, only place it :D
	-- TODO: Do complete overhaul of the algorithm
	local newpos = {x=pos.x,y=pos.y-1,z=pos.z}
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_village.mts"
	return minetest.place_schematic(newpos, path, "random", nil, true)
end

mcl_structures.generate_desert_well = function(pos)
	local newpos = {x=pos.x,y=pos.y-2,z=pos.z}
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_desert_well.mts"
	return minetest.place_schematic(newpos, path, "0", nil, true)
end

mcl_structures.generate_igloo_top = function(pos)
	-- FIXME: This spawns bookshelf instead of furnace. Fix this!
	-- Furnace does ot work atm because apparently meta is not set. :-(
	local newpos = {x=pos.x,y=pos.y-1,z=pos.z}
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_igloo_top.mts"
	return minetest.place_schematic(newpos, path, "random", nil, true)
end

mcl_structures.generate_igloo_basement = function(pos, orientation)
	-- TODO: Add brewing stand
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_igloo_basement.mts"
	return minetest.place_schematic(pos, path, orientation, nil, true)
end

mcl_structures.generate_boulder = function(pos)
	-- Choose between 2 boulder sizes (2×2×2 or 3×3×3)
	local r = math.random(1, 10)
	local path
	if r <= 3 then
		path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_boulder_small.mts"
	else
		path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_boulder.mts"
	end

	local newpos = {x=pos.x,y=pos.y-1,z=pos.z}
	return minetest.place_schematic(newpos, path)
end

mcl_structures.generate_witch_hut = function(pos, rotation)
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_witch_hut.mts"
	return minetest.place_schematic(pos, path, rotation, nil, true)
end

mcl_structures.generate_ice_spike_small = function(pos)
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_ice_spike_small.mts"
	return minetest.place_schematic(pos, path, "random", nil, false)
end

mcl_structures.generate_ice_spike_large = function(pos)
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_ice_spike_large.mts"
	return minetest.place_schematic(pos, path, "random", nil, false)
end

mcl_structures.generate_fossil = function(pos)
	-- Generates one out of 8 possible fossil pieces
	local newpos = {x=pos.x,y=pos.y-1,z=pos.z}
	local fossils = {
		"mcl_structures_fossil_skull_1.mts", -- 4×5×5
		"mcl_structures_fossil_skull_2.mts", -- 5×5×5
		"mcl_structures_fossil_skull_3.mts", -- 5×5×7
		"mcl_structures_fossil_skull_4.mts", -- 7×5×5
		"mcl_structures_fossil_spine_1.mts", -- 3×3×13
		"mcl_structures_fossil_spine_2.mts", -- 5×4×13
		"mcl_structures_fossil_spine_3.mts", -- 7×4×13
		"mcl_structures_fossil_spine_4.mts", -- 8×5×13
	}
	local r = math.random(1, #fossils)
	local path = minetest.get_modpath("mcl_structures").."/schematics/"..fossils[r]
	return minetest.place_schematic(newpos, path, "random", nil, true)
end

mcl_structures.generate_end_exit_portal = function(pos)
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_end_exit_portal.mts"
	return minetest.place_schematic(pos, path, "0", nil, true)
end

mcl_structures.generate_end_portal_shrine = function(pos)
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_end_portal_room_simple.mts"
	local offset = {x=6, y=8, z=6}
	local size = {x=13, y=8, z=13}
	local newpos = { x = pos.x - offset.x, y = pos.y, z = pos.z - offset.z }
	local ret = minetest.place_schematic(newpos, path, "0", nil, true)
	if ret == nil then
		return ret
	end

	local area_start, area_end = newpos, vector.add(newpos, size)
	-- Find and setup spawner with silverfish
	local spawners = minetest.find_nodes_in_area(area_start, area_end, "mcl_mobspawners:spawner")
	for s=1, #spawners do
		local meta = minetest.get_meta(spawners[s])
		mcl_mobspawners.setup_spawner(spawners[s], "mobs_mc:silverfish")
	end

	-- Shuffle stone brick types
	local bricks = minetest.find_nodes_in_area(area_start, area_end, "mcl_core:stonebrick")
	-- FIXME: Use better seeding
	local pr = PseudoRandom(math.random(0, 4294967295))
	for b=1, #bricks do
		local r_bricktype = pr:next(1, 100)
		local r_infested = pr:next(1, 100)
		local bricktype
		if r_infested <= 5 then
			if r_bricktype <= 30 then -- 30%
				bricktype = "mcl_monster_eggs:monster_egg_stonebrickmossy"
			elseif r_bricktype <= 50 then -- 20%
				bricktype = "mcl_monster_eggs:monster_egg_stonebrickcracked"
			else -- 50%
				bricktype = "mcl_monster_eggs:monster_egg_stonebrick"
			end
		else
			if r_bricktype <= 30 then -- 30%
				bricktype = "mcl_core:stonebrickmossy"
			elseif r_bricktype <= 50 then -- 20%
				bricktype = "mcl_core:stonebrickcracked"
			end
			-- 50% stonebrick (no change necessary)
		end
		if bricktype ~= nil then
			minetest.set_node(bricks[b], { name = bricktype })
		end
	end

	-- Also replace stairs
	local stairs = minetest.find_nodes_in_area(area_start, area_end, {"mcl_stairs:stair_stonebrick", "mcl_stairs:stair_stonebrick_outer", "mcl_stairs:stair_stonebrick_inner"})
	for s=1, #stairs do
		local stair = minetest.get_node(stairs[s])
		local r_type = pr:next(1, 100)
		if r_type <= 30 then -- 30% mossy
			if stair.name == "mcl_stairs:stair_stonebrick" then
				stair.name = "mcl_stairs:stair_stonebrickmossy"
			elseif stair.name == "mcl_stairs:stair_stonebrick_outer" then
				stair.name = "mcl_stairs:stair_stonebrickmossy_outer"
			elseif stair.name == "mcl_stairs:stair_stonebrick_inner" then
				stair.name = "mcl_stairs:stair_stonebrickmossy_inner"
			end
			minetest.set_node(stairs[s], stair)
		elseif r_type <= 50 then -- 20% cracky
			if stair.name == "mcl_stairs:stair_stonebrick" then
				stair.name = "mcl_stairs:stair_stonebrickcracked"
			elseif stair.name == "mcl_stairs:stair_stonebrick_outer" then
				stair.name = "mcl_stairs:stair_stonebrickcracked_outer"
			elseif stair.name == "mcl_stairs:stair_stonebrick_inner" then
				stair.name = "mcl_stairs:stair_stonebrickcracked_inner"
			end
			minetest.set_node(stairs[s], stair)
		end
		-- 50% no change
	end

	-- Randomly add ender eyes into end portal frames, but never fill the entire frame
	local frames = minetest.find_nodes_in_area(area_start, area_end, "mcl_portals:end_portal_frame")
	local eyes = 0
	for f=1, #frames do
		local r_eye = pr:next(1, 10)
		if r_eye == 1 then
			eyes = eyes + 1
			if eyes < #frames then
				local frame_node = minetest.get_node(frames[f])
				frame_node.name = "mcl_portals:end_portal_frame_eye"
				minetest.set_node(frames[f], frame_node)
			end
		end
	end

	return ret
end

mcl_structures.generate_desert_temple = function(pos)
	-- No Generating for the temple ... Why using it ? No Change
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_desert_temple.mts"
	local newpos = {x=pos.x,y=pos.y-12,z=pos.z}
	local size = {x=22, y=24, z=22}
	if newpos == nil then
		return
	end
	local ret = minetest.place_schematic(newpos, path, "random", nil, true)
	if ret == nil then
		return ret
	end

	-- Find chests.
	-- FIXME: Searching this large area just for the chets is not efficient. Need a better way to find the chests;
	-- probably let's just infer it from newpos because the schematic always the same.
	local chests = minetest.find_nodes_in_area({x=newpos.x-size.x, y=newpos.y, z=newpos.z-size.z}, vector.add(newpos, size), "mcl_chests:chest")

	-- Add desert temple loot into chests
	-- FIXME: Use better seeding
	local pr = PseudoRandom(math.random(0, 4294967295))
	for c=1, #chests do
		-- FIXME: Use better seeding
		local lootitems = mcl_loot.get_multi_loot({
		{
			stacks_min = 2,
			stacks_max = 4,
			items = {
				{ itemstring = "mcl_mobitems:bone", weight = 25, amount_min = 4, amount_max=6 },
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 25, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_mobitems:spider_eye", weight = 25, amount_min = 1, amount_max=3 },
				-- TODO: Enchanted Book
				{ itemstring = "mcl_books:book", weight = 20, },
				{ itemstring = "mcl_mobitems:saddle", weight = 20, },
				{ itemstring = "mcl_core:apple_gold", weight = 20, },
				{ itemstring = "mcl_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_core:iron_ingot", weight = 15, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:emerald", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "", weight = 15, },
				{ itemstring = "mobs_mc:iron_horse_armor", weight = 15, },
				{ itemstring = "mobs_mc:gold_horse_armor", weight = 10, },
				{ itemstring = "mobs_mc:diamond_horse_armor", weight = 5, },
				{ itemstring = "mcl_core:diamond", weight = 5, amount_min = 1, amount_max = 3 },
				-- TODO: Enchanted Golden Apple
				{ itemstring = "mcl_core:apple_gold", weight = 2, },
			}
		},
		{
			stacks_min = 4,
			stacks_max = 4,
			items = {
				{ itemstring = "mcl_mobitems:bone", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_mobitems:gunpowder", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_core:sand", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_mobitems:string", weight = 10, amount_min = 1, amount_max = 8 },
			}
		}}, pr)

		local meta = minetest.get_meta(chests[c])
		local inv = meta:get_inventory()
		inv:set_size("main", 9*3)
		for i=1, #lootitems do
			inv:add_item("main", lootitems[i])
		end
	end

	-- Initialize pressure plates and randomly remove up to 5 plates
	local pplates = minetest.find_nodes_in_area({x=newpos.x-size.x, y=newpos.y, z=newpos.z-size.z}, vector.add(newpos, size), "mesecons_pressureplates:pressure_plate_stone_off")
	local pplates_remove = 5
	for p=1, #pplates do
		if pplates_remove > 0 and pr:next(1, 100) >= 50 then
			-- Remove plate
			minetest.remove_node(pplates[p])
			pplates_remove = pplates_remove - 1
		else
			-- Initialize plate
			minetest.registered_nodes["mesecons_pressureplates:pressure_plate_stone_off"].on_construct(pplates[p])
		end
	end

	return ret
end

local registered_structures = {}

--[[ Returns a table of structure of the specified type.
Currently the only valid parameter is "stronghold".
Format of return value:
{
	{ pos = <position>, generated=<true/false> }, -- first structure
	{ pos = <position>, generated=<true/false> }, -- second structure
	-- and so on
}

TODO: Implement this function for all other structure types as well.
]]
mcl_structures.get_registered_structures = function(structure_type)
	if registered_structures[structure_type] then
		return table.copy(registered_structures[structure_type])
	else
		return {}
	end
end

-- Register a structures table for the given type. The table format is the same as for
-- mcl_structures.get_registered_structures.
mcl_structures.register_structures = function(structure_type, structures)
	registered_structures[structure_type] = structures
end

-- Debug command
minetest.register_chatcommand("spawnstruct", {
	params = "desert_temple | desert_well | igloo | village | witch_hut | boulder | ice_spike_small | ice_spike_large | fossil | end_exit_portal | end_portal_shrine",
	description = "Generate a pre-defined structure near your position.",
	privs = {debug = true},
	func = function(name, param)
		local pos= minetest.get_player_by_name(name):get_pos()
		if not pos then
			return
		end
		local errord = false
		if param == "village" then
			mcl_structures.generate_village(pos)
			minetest.chat_send_player(name, "Village built. WARNING: Villages are experimental and might have bugs.")
		elseif param == "desert_temple" then
			mcl_structures.generate_desert_temple(pos)
			minetest.chat_send_player(name, "Desert temple built.")
		elseif param == "desert_well" then
			mcl_structures.generate_desert_well(pos)
			minetest.chat_send_player(name, "Desert well built.")
		elseif param == "igloo" then
			mcl_structures.generate_igloo_top(pos)
			minetest.chat_send_player(name, "Igloo built.")
		elseif param == "witch_hut" then
			mcl_structures.generate_witch_hut(pos)
			minetest.chat_send_player(name, "Witch hut built.")
		elseif param == "boulder" then
			mcl_structures.generate_boulder(pos)
			minetest.chat_send_player(name, "Moss stone boulder placed.")
		elseif param == "fossil" then
			mcl_structures.generate_fossil(pos)
			minetest.chat_send_player(name, "Fossil placed.")
		elseif param == "ice_spike_small" then
			mcl_structures.generate_ice_spike_small(pos)
			minetest.chat_send_player(name, "Small ice spike placed.")
		elseif param == "ice_spike_large" then
			mcl_structures.generate_ice_spike_large(pos)
			minetest.chat_send_player(name, "Large ice spike placed.")
		elseif param == "end_exit_portal" then
			mcl_structures.generate_end_exit_portal(pos)
			minetest.chat_send_player(name, "End exit portal placed.")
		elseif param == "end_portal_shrine" then
			mcl_structures.generate_end_portal_shrine(pos)
			minetest.chat_send_player(name, "End portal shrine placed.")
		elseif param == "" then
			minetest.chat_send_player(name, "Error: No structure type given. Please use “/spawnstruct <type>”.")
			errord = true
		else
			minetest.chat_send_player(name, "Error: Unknown structure type. Please use “/spawnstruct <type>”.")
			errord = true
		end
		if errord then
			minetest.chat_send_player(name, "Use /help spawnstruct to see a list of avaiable types.")
		end
	end
})

local time_to_load= os.clock() - init
minetest.log("action", (string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load)))
