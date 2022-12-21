local function mcl_log (message)
	mcl_util.mcl_log (message, "[Village - Foundation]")
end

local foundation_materials = {}

foundation_materials["mcl_core:sand"] = "mcl_core:sandstone"
--"mcl_core:sandstonecarved"

-------------------------------------------------------------------------------
-- function to fill empty space below baseplate when building on a hill
-------------------------------------------------------------------------------
function settlements.ground(pos, pr, platform_material) -- role model: Wendelsteinkircherl, Brannenburg
	local p2 = vector.new(pos)
	local cnt = 0

	local mat = "mcl_core:dirt"
	if not platform_material then
		mat = "mcl_core:dirt"
	else
		mat = platform_material
	end

	p2.y = p2.y-1
	while true do
		cnt = cnt+1
		if cnt > 20 then break end
		if cnt>pr:next(2,4) then
			if not platform_material then
				mat = "mcl_core:stone"
			end
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

		local surface_mat = settlement_info[i]["surface_mat"]
		mcl_log("Surface material: " .. tostring(surface_mat))
		local platform_mat = foundation_materials[surface_mat]
		mcl_log("Foundation material: " .. tostring(platform_mat))

		--
		-- now that every info is available -> create platform and clear space above
		--
		for xi = 0,fwidth-1 do
			for zi = 0,fdepth-1 do
				for yi = 0,fheight *3 do
					if yi == 0 then
						local p = {x=pos.x+xi, y=pos.y, z=pos.z+zi}
						-- Pass in biome info and make foundations of same material (seed: apple for desert)
						settlements.ground(p, pr, platform_mat)
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
