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
					local tex, opts = nil, ""
					for i = 1, #tiles do
						local tile = tiles[i]
						tex = type(tile) == 'table' and (tile.name or tile.image) or tile
						if tex ~= "blank.png" then break end
					end
					if tex then
						if nd.paramtype2 and nd.paramtype2:sub(1,5) == "color" and nd.palette ~= "" then
							opts = " " .. nd.paramtype2 .. " " .. nd.palette
						elseif nd.color and nd.color ~= "" then
							opts = " " .. nd.color
						end
						out:write(nn .. ' ' .. tex .. opts .. '\n')
					end
					n = n + 1
				end
			end
			out:write('\n')
		end
		out:close()
		return true, n .. " nodes dumped."
	end,
})
