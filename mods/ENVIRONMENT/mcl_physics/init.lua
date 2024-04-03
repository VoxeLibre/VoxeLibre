local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local mod = {}
mcl_physics = mod

dofile(modpath.."/api.lua")

-- Flowing water
-- TODO: move to Flowlib
local FLOW_SPEED = 1.39
local BOUANCY = 3
mod.register_environment_effect(function(pos, vel, staticdata)
	-- Get the node and node definition
	local node = minetest.get_node_or_nil(pos); if not node then return end
	local nodedef = minetest.registered_nodes[node.name]; if not nodedef then return end

	-- Make sure we are in a liquid before continuing
	local is_flowing = (nodedef.liquidtype == "flowing")
	staticdata.flowing = is_flowing
	if not is_flowing then return end

	-- Get liquid flow direction
	local vec = vector.multiply(flowlib.quick_flow(pos, node), FLOW_SPEED)
	return vector.new(vec.x, -0.22, vec.z),nil
end)

-- Simple gravity and bouency
mod.register_environment_effect(function(pos, vel, staticdata)
	-- Get the node and node definition
	local node = minetest.get_node_or_nil(pos);
	local nodedef = nil
	if node then nodedef = minetest.registered_nodes[node.name] end

	if nodedef and nodedef.liquidtype == "source" then
		-- Apply decceleration and bouancy if the entity moved from flowing water to
		-- stationary water
		return nil,vector.new(
			0 - vel.x * 0.9,
			BOUANCY - vel.y * 0.9,
			0 - vel.z * 0.9
		)
	else
		local gravity = tonumber(minetest.settings:get("movement_gravity")) or 9.81
		return nil,vector.new(0,-gravity,0)
	end
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

