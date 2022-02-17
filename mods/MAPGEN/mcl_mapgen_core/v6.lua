local c_air = minetest.CONTENT_AIR

mcl_mapgen.register_on_generated(function(vm_context)
	local minp, maxp = vm_context.minp, vm_context.maxp

	if minp.y <= mcl_mapgen.end_.max and maxp.y >= mcl_mapgen.end_.min then
		local nodes = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:water_source", "mcl_core:stone", "mcl_core:sand", "mcl_core:dirt"})
		if #nodes > 0 then
			for _, n in pairs(nodes) do
				data[area:index(n.x, n.y, n.z)] = c_air
			end
		end
		vm_context.write = true
		return
	end


	if minp.y > mcl_mapgen.overworld.max or maxp.y < mcl_mapgen.overworld.min then return end
	local vm, data, area = vm_context.vm, vm_context.data, vm_context.area

	--[[ Remove broken double plants caused by v6 weirdness.
	v6 might break the bottom part of double plants because of how it works.
	There are 3 possibilities:
	1) Jungle: Top part is placed on top of a jungle tree or fern (=v6 jungle grass).
		This is because the schematic might be placed even if some nodes of it
		could not be placed because the destination was already occupied.
		TODO: A better fix for this would be if schematics could abort placement
		altogether if ANY of their nodes could not be placed.
	2) Cavegen: Removes the bottom part, the upper part floats
	3) Mudflow: Same as 2) ]]
	local plants = minetest.find_nodes_in_area(minp, maxp, "group:double_plant")
	for n = 1, #plants do
		local node = vm:get_node_at(plants[n])
		local is_top = minetest.get_item_group(node.name, "double_plant") == 2
		if is_top then
			local p_pos = area:index(plants[n].x, plants[n].y-1, plants[n].z)
			if p_pos then
				node = vm:get_node_at({x=plants[n].x, y=plants[n].y-1, z=plants[n].z})
				local is_bottom = minetest.get_item_group(node.name, "double_plant") == 1
				if not is_bottom then
					p_pos = area:index(plants[n].x, plants[n].y, plants[n].z)
					data[p_pos] = c_air
					vm_context.write = true
				end
			end
		end
	end

end, 999999999)
