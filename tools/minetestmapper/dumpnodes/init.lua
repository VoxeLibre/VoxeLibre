local function get_tile(tiles, n)
	local tile = tiles[n]
	if type(tile) == 'table' then
		return tile.name or tile.image
	end
	return tile
end

local function pairs_s(dict)
	local keys = {}
	for k in pairs(dict) do
		keys[#keys+1] = k
	end
	table.sort(keys)
	return ipairs(keys)
end

minetest.register_chatcommand("dumpnodes", {
	description = "Dump node and texture list for use with minetestmapper",
	func = function()
		local ntbl = {}
		for _, nn in pairs_s(minetest.registered_nodes) do
			local prefix, name = nn:match('(.*):(.*)')
			if prefix == nil or name == nil then
				print("ignored(1): " .. nn)
			else
				if ntbl[prefix] == nil then
					ntbl[prefix] = {}
				end
				ntbl[prefix][name] = true
			end
		end
		local out, err = io.open(minetest.get_worldpath() .. "/nodes.txt", 'wb')
		if not out then
			return true, err
		end
		local n = 0
		for _, prefix in pairs_s(ntbl) do
			out:write('# ' .. prefix .. '\n')
			for _, name in pairs_s(ntbl[prefix]) do
				local nn = prefix .. ":" .. name
				local nd = minetest.registered_nodes[nn]
				local tiles = nd.tiles or nd.tile_images
				if tiles == nil or nd.drawtype == 'airlike' then
					print("ignored(2): " .. nn)
				else
					local tex = get_tile(tiles, 1)
					tex = (tex .. '^'):match('%(*(.-)%)*^') -- strip modifiers
					if tex:find("[combine", 1, true) then
						tex = tex:match('.-=([^:]-)') -- extract first texture
					end
					local opts = ""
					if nd.paramtype2 and nd.paramtype2:sub(1,5) == "color" and nd.palette ~= "" then
						opts = " " .. nd.paramtype2 .. " " .. nd.palette
					end
					out:write(nn .. ' ' .. tex .. opts .. '\n')
					n = n + 1
				end
			end
			out:write('\n')
		end
		out:close()
		return true, n .. " nodes dumped."
	end,
})
