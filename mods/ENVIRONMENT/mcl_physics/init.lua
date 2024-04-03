local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local mod = {}
mcl_physics = mod

dofile(modpath.."/api.lua")

-- TODO: move to Flowlib
local FLOW_SPEED = 1.39
mod.register_environment_effect(function(pos, vel, staticdata)
	-- Get the node and node definition
	local node = minetest.get_node_or_nil(pos)
	if not node then return end
	local nodedef = minetest.registered_nodes[node.name]
	if not nodedef then return end

	-- Make sure we are in a liquid before continuing
	local is_flowing = (nodedef.liquidtype == "flowing")
	staticdata.flowing = is_flowing
	if not is_flowing then
		-- Apply decelleration if the entity moved from flowing water to 
		-- stationary water
		if nodedef.liquidtype == "source" then
			return nil,vector.new(
				0 - vel.x * 0.9,
				3 - vel.y * 0.9,
				0 - vel.z * 0.9
			)
		end
		return
	end

	-- Get liquid flow direction
	local vec = vector.multiply(flowlib.quick_flow(pos, node), FLOW_SPEED)
	return vector.new(vec.x, -0.22, vec.z),nil
end)

-- Node effects
mod.register_environment_effect(function(pos, vel, staticdata)
	local pos_r = vector.round(pos)
	local node = minetest.get_node(pos_r)
	local nodedef = minetest.registered_nodes[node.name]
	if not nodedef then return end

	if nodedef._mcl_physics_effect then
		return nodedef._mcl_physics_effect(pos, vel, staticdata)
	end

	return -- nil,nil
end)

