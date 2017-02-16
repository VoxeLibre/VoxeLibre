-- Temporarily disable this mod because of HORRIBLE bugs
-- TODO: Re-enable this mod
--[===[

local init = os.clock()
random_struct ={}

random_struct.get_struct = function(file)
	local localfile = minetest.get_modpath("random_struct").."/build/"..file
	local file, errorload = io.open(localfile, "rb")
	if errorload ~= nil then
	    minetest.log("action", '[Random_Struct] error: could not open this struct "' .. localfile .. '"')
	    return nil
	end

   local allnode = file:read("*a")
   file:close()

    return allnode
end


-- World edit function

random_struct.valueversion_WE = function(value)
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
random_struct.allocate_WE  = function(originpos, value)
	local huge = math.huge
	local pos1x, pos1y, pos1z = huge, huge, huge
	local pos2x, pos2y, pos2z = -huge, -huge, -huge
	local originx, originy, originz = originpos.x, originpos.y, originpos.z
	local count = 0
	local version = random_struct.valueversion_WE (value)
	if version == 1 or version == 2 then --flat table format
		--obtain the node table
		local get_tables = loadstring(value)
		if get_tables then --error loading value
			return originpos, originpos, count
		end
		local tables = get_tables()

		--transform the node table into an array of nodes
		for i = 1, #tables do
			for j, v in pairs(tables[i]) do
				if type(v) == "table" then
					tables[i][j] = tables[v[1]]
				end
			end
		end
		local nodes = tables[1]

		--check the node array
		count = #nodes
		if version == 1 then --original flat table format
			for index = 1, count do
				local entry = nodes[index]
				local pos = entry[1]
				local x, y, z = originx - pos.x, originy - pos.y, originz - pos.z
				if x < pos1x then pos1x = x end
				if y < pos1y then pos1y = y end
				if z < pos1z then pos1z = z end
				if x > pos2x then pos2x = x end
				if y > pos2y then pos2y = y end
				if z > pos2z then pos2z = z end
			end
		else --previous meta flat table format
			for index = 1, count do
				local entry = nodes[index]
				local x, y, z = originx - entry.x, originy - entry.y, originz - entry.z
				if x < pos1x then pos1x = x end
				if y < pos1y then pos1y = y end
				if z < pos1z then pos1z = z end
				if x > pos2x then pos2x = x end
				if y > pos2y then pos2y = y end
				if z > pos2z then pos2z = z end
			end
		end
	elseif version == 3 then --previous list format
		for x, y, z, name, param1, param2 in value:gmatch("([+-]?%d+)%s+([+-]?%d+)%s+([+-]?%d+)%s+([^%s]+)%s+(%d+)%s+(%d+)[^\r\n]*[\r\n]*") do --match node entries
			local x, y, z = originx + tonumber(x), originy + tonumber(y), originz + tonumber(z)
			if x < pos1x then pos1x = x end
			if y < pos1y then pos1y = y end
			if z < pos1z then pos1z = z end
			if x > pos2x then pos2x = x end
			if y > pos2y then pos2y = y end
			if z > pos2z then pos2z = z end
			count = count + 1
		end
	elseif version == 4 then --current nested table format
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
	end
	local pos1 = {x=pos1x, y=pos1y, z=pos1z}
	local pos2 = {x=pos2x, y=pos2y, z=pos2z}
	return pos1, pos2, count
end
random_struct.deserialise_WE = function(originpos, value)
	--make area stay loaded
	local pos1, pos2 = random_struct.allocate_WE(originpos, value)
	local manip = minetest.get_voxel_manip()
	manip:read_from_map(pos1, pos2)

	local originx, originy, originz = originpos.x, originpos.y, originpos.z
	local count = 0
	local add_node, get_meta = minetest.add_node, minetest.get_meta
	local version = random_struct.valueversion_WE(value)
	if version == 1 or version == 2 then --original flat table format
		--obtain the node table
		local get_tables = loadstring(value)
		if not get_tables then --error loading value
			return count
		end
		local tables = get_tables()

		--transform the node table into an array of nodes
		for i = 1, #tables do
			for j, v in pairs(tables[i]) do
				if type(v) == "table" then
					tables[i][j] = tables[v[1]]
				end
			end
		end
		local nodes = tables[1]

		--load the node array
		count = #nodes
		if version == 1 then --original flat table format
			for index = 1, count do
				local entry = nodes[index]
				local pos = entry[1]
				pos.x, pos.y, pos.z = originx - pos.x, originy - pos.y, originz - pos.z
				add_node(pos, entry[2])
			end
		else --previous meta flat table format
			for index = 1, #nodes do
				local entry = nodes[index]
				entry.x, entry.y, entry.z = originx + entry.x, originy + entry.y, originz + entry.z
				add_node(entry, entry) --entry acts both as position and as node
				get_meta(entry):from_table(entry.meta)
			end
		end
	elseif version == 3 then --previous list format
		local pos = {x=0, y=0, z=0}
		local node = {name="", param1=0, param2=0}
		for x, y, z, name, param1, param2 in value:gmatch("([+-]?%d+)%s+([+-]?%d+)%s+([+-]?%d+)%s+([^%s]+)%s+(%d+)%s+(%d+)[^\r\n]*[\r\n]*") do --match node entries
			pos.x, pos.y, pos.z = originx + tonumber(x), originy + tonumber(y), originz + tonumber(z)
			node.name, node.param1, node.param2 = name, param1, param2
			add_node(pos, node)
			count = count + 1
		end
	elseif version == 4 then --current nested table format
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

		--load the nodes
		count = #nodes
		for index = 1, count do
			local entry = nodes[index]
			entry.x, entry.y, entry.z = originx + entry.x, originy + entry.y, originz + entry.z
			add_node(entry, entry) --entry acts both as position and as node
		end

		--load the metadata
		for index = 1, count do
			local entry = nodes[index]
			get_meta(entry):from_table(entry.meta)
		end
	end
	return count
end

-- End of world edit deserialise part


-- The call of Struct
random_struct.call_struct= function(pos, struct_style)	
			-- 1 : City , 2 : Temple Sand
			if struct_style == 1 then
			  random_struct.generatecity(pos)
			elseif struct_style == 2 then
			  random_struct.generate_temple_sand(pos)
			end
end

random_struct.generatecity = function(pos)
	-- No Generating for the moment only place it :D
	local city = random_struct.get_struct("pnj_town_1.we")
	local newpos = {x=pos.x,y=pos.y,z=pos.z}
	if newpos == nil then
		return
	end
	random_struct.deserialise_WE(newpos, city )
end

random_struct.generate_temple_sand = function(pos)
	-- No Generating for the temple ... Why using it ? No Change
	local temple = random_struct.get_struct("desert_temple.we")
	local newpos = {x=pos.x,y=pos.y-12,z=pos.z}
	if newpos == nil then
		return
	end
	random_struct.deserialise_WE(newpos, temple)
end


-- Debug command
minetest.register_chatcommand("spawnstruct", {
	params = "",
	description = "Spawn a Struct.",
	func = function(name, param)
		local pos= minetest.get_player_by_name(name):getpos()
		if not pos then
			return
		end
		if param == "" or param == "help" then
			minetest.chat_send_player(name, "Please use instruction /spawnstruct TYPE")
			minetest.chat_send_player(name, "TYPE avaiable : town, temple_sand")
		end
		if param == "town" then
			random_struct.generatecity(pos)
			minetest.chat_send_player(name, "Town Created")
		end
		if param == "temple_sand" then
			random_struct.generate_temple_sand(pos)
			minetest.chat_send_player(name, "Temple Sand Created")
		end
	end
})

local time_to_load= os.clock() - init
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))

-- TODO: Remove after re-enabling this mod
]===]
