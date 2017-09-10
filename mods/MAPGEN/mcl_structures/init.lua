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


-- World edit function

mcl_structures.valueversion_WE = function(value)
	if value:find("([+-]?%d+)%s+([+-]?%d+)%s+([+-]?%d+)") and not value:find("%{") then --previous list format
		return 3
	elseif value:find("^[^\"']+%{%d+%}") then
		if value:find("%[\"meta\"%]") then --previous meta flat table format
			return 2
		end
		return 1 --original flat table format
	elseif value:find("%{") then --current nested table format
		return 4
	end
	return 0 --unknown format
end
mcl_structures.allocate_WE  = function(originpos, value)
	local huge = math.huge
	local pos1x, pos1y, pos1z = huge, huge, huge
	local pos2x, pos2y, pos2z = -huge, -huge, -huge
	local originx, originy, originz = originpos.x, originpos.y, originpos.z
	local count = 0
	local version = mcl_structures.valueversion_WE (value)
	if version == 4 then --current nested table format
		--wip: this is a filthy hack that works surprisingly well
		value = value:gsub("return%s*{", "", 1):gsub("}%s*$", "", 1)
		local escaped = value:gsub("\\\\", "@@"):gsub("\\\"", "@@"):gsub("(\"[^\"]*\")", function(s) return string.rep("@", #s) end)
		local startpos, startpos1, endpos = 1, 1
		local nodes = {}
		while true do
			startpos, endpos = escaped:find("},%s*{", startpos)
			if not startpos then
				break
			end
			local current = value:sub(startpos1, startpos)
			table.insert(nodes, minetest.deserialize("return " .. current))
			startpos, startpos1 = endpos, endpos
		end
		table.insert(nodes, minetest.deserialize("return " .. value:sub(startpos1)))

		--local nodes = minetest.deserialize(value) --wip: this is broken for larger tables in the current version of LuaJIT

		count = #nodes
		for index = 1, count do
			local entry = nodes[index]
			local x, y, z = originx + entry.x, originy + entry.y, originz + entry.z
			if x < pos1x then pos1x = x end
			if y < pos1y then pos1y = y end
			if z < pos1z then pos1z = z end
			if x > pos2x then pos2x = x end
			if y > pos2y then pos2y = y end
			if z > pos2z then pos2z = z end
		end
	else
		minetest.log("error", "[mcl_structures] Unsupported WorldEdit file format ("..version..")")
		return
	end
	local pos1 = {x=pos1x, y=pos1y, z=pos1z}
	local pos2 = {x=pos2x, y=pos2y, z=pos2z}
	return pos1, pos2, count
end

--[[
Deserialize WorldEdit string and set the nodes in the world.
Returns: count, chests
* count: Number of nodes set
* chests: Table of chest positions (use these to spawn treasures
]]
mcl_structures.deserialise_WE = function(originpos, value)
	--make area stay loaded
	local pos1, pos2 = mcl_structures.allocate_WE(originpos, value)
	local count = 0
	local chests = {} -- Remember positions of all chests
	if not pos1 then
		return count, chests
	end
	local manip = minetest.get_voxel_manip()
	manip:read_from_map(pos1, pos2)

	local originx, originy, originz = originpos.x, originpos.y, originpos.z
	local add_node, get_meta = minetest.add_node, minetest.get_meta
	local version = mcl_structures.valueversion_WE(value)
	if version == 4 then --current nested table format
		--wip: this is a filthy hack that works surprisingly well
		value = value:gsub("return%s*{", "", 1):gsub("}%s*$", "", 1)
		local escaped = value:gsub("\\\\", "@@"):gsub("\\\"", "@@"):gsub("(\"[^\"]*\")", function(s) return string.rep("@", #s) end)
		local startpos, startpos1, endpos = 1, 1
		local nodes = {}
		while true do
			startpos, endpos = escaped:find("},%s*{", startpos)
			if not startpos then
				break
			end
			local current = value:sub(startpos1, startpos)
			table.insert(nodes, minetest.deserialize("return " .. current))
			startpos, startpos1 = endpos, endpos
		end
		table.insert(nodes, minetest.deserialize("return " .. value:sub(startpos1)))

		--local nodes = minetest.deserialize(value) --wip: this is broken for larger tables in the current version of LuaJIT

		--load the nodes and remember chests
		count = #nodes
		for index = 1, count do
			local entry = nodes[index]
			entry.x, entry.y, entry.z = originx + entry.x, originy + entry.y, originz + entry.z
			add_node(entry, entry) --entry acts both as position and as node
			if entry.name == "mcl_chests:chest" then
				table.insert(chests, {x=entry.x, y=entry.y, z=entry.z})
			end
		end

		--load the metadata
		for index = 1, count do
			local entry = nodes[index]
			get_meta(entry):from_table(entry.meta)
		end
	end
	return count, chests
end

-- End of world edit deserialise part


-- The call of Struct
mcl_structures.call_struct= function(pos, struct_style)
	if struct_style == "village" then
		mcl_structures.generate_village(pos)
	elseif struct_style == "desert_temple" then
		mcl_structures.generate_desert_temple(pos)
	elseif struct_style == "desert_well" then
		mcl_structures.generate_desert_well(pos)
	elseif struct_style == "igloo" then
		mcl_structures.generate_igloo_top(pos)
	elseif struct_style == "witch_hut" then
		mcl_structures.generate_witch_hut(pos)
	elseif struct_style == "ice_spike_small" then
		mcl_structures.generate_ice_spike_small(pos)
	elseif struct_style == "ice_spike_large" then
		mcl_structures.generate_ice_spike_large(pos)
	elseif struct_style == "boulder" then
		mcl_structures.generate_boulder(pos)
	elseif struct_style == "fossil" then
		mcl_structures.generate_fossil(pos)
	end
end

mcl_structures.generate_village = function(pos)
	-- No generating for the moment, only place it :D
	-- TODO: Do complete overhaul of the algorithm
	local newpos = {x=pos.x,y=pos.y-1,z=pos.z}
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_village.mts"
	minetest.place_schematic(newpos, path, "random", nil, true)
end

mcl_structures.generate_desert_well = function(pos)
	local newpos = {x=pos.x,y=pos.y-2,z=pos.z}
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_desert_well.mts"
	minetest.place_schematic(newpos, path, "0", nil, true)
end

mcl_structures.generate_igloo_top = function(pos)
	-- FIXME: This spawns bookshelf instead of furnace. Fix this!
	-- Furnace does ot work atm because apparently meta is not set. :-(
	local newpos = {x=pos.x,y=pos.y-1,z=pos.z}
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_igloo_top.mts"
	minetest.place_schematic(newpos, path, "random", nil, true)
end

mcl_structures.generate_igloo_basement = function(pos, orientation)
	-- TODO: Add brewing stand
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_igloo_basement.mts"
	minetest.place_schematic(pos, path, orientation, nil, true)
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
	minetest.place_schematic(newpos, path)
end

mcl_structures.generate_witch_hut = function(pos)
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_witch_hut.mts"
	minetest.place_schematic(pos, path, "random", nil, true)
end

mcl_structures.generate_ice_spike_small = function(pos)
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_ice_spike_small.mts"
	minetest.place_schematic(pos, path, "random", nil, false)
end

mcl_structures.generate_ice_spike_large = function(pos)
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_ice_spike_large.mts"
	minetest.place_schematic(pos, path, "random", nil, false)
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
	minetest.place_schematic(newpos, path, "random", nil, true)
end

mcl_structures.generate_desert_temple = function(pos)
	-- No Generating for the temple ... Why using it ? No Change
	local path = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_desert_temple.mts"
	local newpos = {x=pos.x,y=pos.y-12,z=pos.z}
	local size = {x=22, y=24, z=22}
	if newpos == nil then
		return
	end
	minetest.place_schematic(newpos, path, "random", nil, true)

	-- Find chests.
	-- FIXME: Searching this large area just for the chets is not efficient. Need a better way to find the chests;
	-- probably let's just infer it from newpos because the schematic always the same.
	local chests = minetest.find_nodes_in_area({x=newpos.x-size.x, y=newpos.y, z=newpos.z-size.z}, vector.add(newpos, size), "mcl_chests:chest")

	-- Add desert temple loot into chests
	for c=1, #chests do
		-- FIXME: Use better seeding
		local pr = PseudoRandom(math.random(0, 4294967295))
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
end


-- Debug command
minetest.register_chatcommand("spawnstruct", {
	params = "desert_temple | desert_well | igloo | village | witch_hut | boulder | ice_spike_small | ice_spike_large | fossil",
	description = "Generate a pre-defined structure near your position.",
	privs = {debug = true},
	func = function(name, param)
		local pos= minetest.get_player_by_name(name):getpos()
		if not pos then
			return
		end
		local errord = false
		if param == "village" then
			mcl_structures.generate_village(pos)
			minetest.chat_send_player(name, "Village built.")
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
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))
