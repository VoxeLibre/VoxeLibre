
function mcl_mobs.check_line_of_sight(origin, target)
	local raycast = minetest.raycast(origin, target, false, true)

	local los_blocked = false
	for hitpoint in raycast do
		if hitpoint.type == "node" then
			--TODO type object could block vision, for example chests
			local node = minetest.get_node(minetest.get_pointed_thing_position(hitpoint))

			if node.name ~= "air" then
				local nodef = minetest.registered_nodes[node.name]
				if nodef and nodef.walkable then
					los_blocked = true
					break
				end
			end
		end
	end
	return not los_blocked
end

