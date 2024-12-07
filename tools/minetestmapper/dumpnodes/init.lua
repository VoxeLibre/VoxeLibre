minetest.register_chatcommand("dumpnodes", {
	description = "Dump node and texture list for use with minetestmapper",
	func = function()
		local out, err = io.open(minetest.get_worldpath() .. "/nodes.txt", 'wb')
		if not out then return true, err end
		for name, def in pairs(minetest.registered_nodes) do
			local tiles = def.tiles or def.tile_images
			if tiles and def.drawtype ~= 'airlike' then
				local tex = nil
				for _, tile in pairs(tiles) do
					tex = type(tile) == 'table' and (tile.name or tile.image) or tile
					if tex ~= "blank.png" then break end
				end
				if tex then
					out:write(name .. " " .. tex)
					if def.paramtype2 and def.paramtype2:sub(1,5) == "color" and def.palette ~= "" then
						out:write(" " .. def.paramtype2 .. " " .. def.palette)
					elseif def.color and def.color ~= "" then
						out:write(" " .. def.color)
					end
					out:write('\n')
				end
			end
		end
		out:close()
		return true, "Finished node dump for minetestmapper."
	end,
})
