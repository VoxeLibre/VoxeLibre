local default_seethru = {air = true}

---@param origin vector.Vector
---@param target vector.Vector
---@param seethru? {[string]: boolean} Set (look-up table) of nodes to treat as seethrough. Defaults to {air: true}
---@return boolean True if line-of-sight is blocked, false otherwise
function mcl_mobs.check_line_of_sight(origin, target, seethru)
	seethru = seethru or default_seethru
	local raycast = core.raycast(origin, target, false, true)

	local los_blocked = false
	for hitpoint in raycast do
		if hitpoint.type == "node" then
			--TODO: type object could block vision, for example minecarts
			local node = core.get_node(core.get_pointed_thing_position(hitpoint))

			if not seethru[node.name] then
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
