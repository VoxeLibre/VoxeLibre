-------------------------------------------------------------------------------
-- function to fill empty space below baseplate when building on a hill
-------------------------------------------------------------------------------
function settlements.ground(pos, pr) -- role model: Wendelsteinkircherl, Brannenburg
	local p2 = vector.new(pos)
	local cnt = 0
	local mat = "mcl_core:dirt"
	p2.y = p2.y-1
	while true do
		cnt = cnt+1
		if cnt > 20 then break end
		if cnt>pr:next(2,4) then 
			mat = "mcl_core:stone" 
		end
		minetest.swap_node(p2, {name=mat})
		p2.y = p2.y-1
	end
end
-------------------------------------------------------------------------------
-- function clear space above baseplate 
-------------------------------------------------------------------------------
function settlements.terraform(settlement_info, pr)
	local fheight, fwidth, fdepth, schematic_data

	for i, built_house in ipairs(settlement_info) do
		-- pick right schematic_info to current built_house
		for j, schem in ipairs(settlements.schematic_table) do
			if settlement_info[i]["name"] == schem["name"] then
				schematic_data = schem
			        break
			end
		end
		local pos = settlement_info[i]["pos"] 
		if settlement_info[i]["rotat"] == "0" or settlement_info[i]["rotat"] == "180" then
			fwidth = schematic_data["hwidth"]
			fdepth = schematic_data["hdepth"]
		else
			fwidth = schematic_data["hdepth"]
			fdepth = schematic_data["hwidth"]
		end
		--fheight = schematic_data["hheight"] * 3  -- remove trees and leaves above
		fheight = schematic_data["hheight"]  -- remove trees and leaves above
		--
		-- now that every info is available -> create platform and clear space above
		--
		for xi = 0,fwidth-1 do
			for zi = 0,fdepth-1 do
				for yi = 0,fheight *3 do
					if yi == 0 then
						local p = {x=pos.x+xi, y=pos.y, z=pos.z+zi}
						settlements.ground(p, pr)
					else
						-- write ground
--						local p = {x=pos.x+xi, y=pos.y+yi, z=pos.z+zi}
--						local node = mcl_vars.get_node(p)
--						if node and node.name ~= "air" then
--							minetest.swap_node(p,{name="air"}) 
--						end
						minetest.swap_node({x=pos.x+xi, y=pos.y+yi, z=pos.z+zi},{name="air"}) 
					end
				end
			end
		end
	end
end
