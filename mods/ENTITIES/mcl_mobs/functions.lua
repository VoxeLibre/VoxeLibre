function mcl_mobs.check_line_of_sight(origin, target)
	local raycast = core.raycast(origin, target, false, true)

	local los_blocked = false
	for hitpoint in raycast do
		if hitpoint.type == "node" then
			--TODO: type object could block vision, for example minecarts
			local node = core.get_node(core.get_pointed_thing_position(hitpoint))

			if node.name ~= "air" then
				local nodef = core.registered_nodes[node.name]
				if nodef and nodef.walkable then
					los_blocked = true
					break
				end
			end
		end
	end
	return not los_blocked
end

