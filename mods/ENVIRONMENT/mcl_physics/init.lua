local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local mod = {}
mcl_physics = mod

dofile(modpath.."/api.lua")

-- Flowing water
-- TODO: move to Flowlib
local FLOW_SPEED = 1.39
local BOUANCY = 3
mod.register_environment_effect(function(pos, vel, staticdata, entity)
	-- Get the node and node definition
	local node = minetest.get_node_or_nil(pos); if not node then return end
	local nodedef = minetest.registered_nodes[node.name]; if not nodedef then return end

	-- Make sure we are in a liquid before continuing
	local is_flowing = (nodedef.liquidtype == "flowing")
	staticdata.flowing = is_flowing
	if not is_flowing then return end

	-- Get liquid flow direction
	local vec = vector.multiply(flowlib.quick_flow(pos, node), FLOW_SPEED)
	return vector.new(vec.x, -0.22, vec.z),nil -- TODO: move bouancy velocity out of here
end)

-- Simple gravity and bouancy
mod.register_environment_effect(function(pos, vel, staticdata, entity)
	-- Get the node and node definition
	local node = minetest.get_node_or_nil(pos);
	local nodedef = nil
	if node then nodedef = minetest.registered_nodes[node.name] end

	if nodedef and nodedef.liquidtype == "source" then -- TODO: make this apply to flowing liquids as well
		-- TODO: make this not apply to fish
		--print("entity="..dump(entity))

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
local DEFAULT_NODE_PHYSICS = {
	friction = 0.9
}
local function apply_node_physics(node, vel, staticdata, entity)
	local node_def = minetest.registered_nodes[node.name] or {}
	local node_physics = node_def._mcl_physics or DEFAULT_NODE_PHYSICS

	local node_physics_effect = node_physics.effect
	if node_physics_effect then
		return node_physics_effect(pos, vel, staticdata)
	end

	-- Default behavior
	local accel = vector.zero()

	-- Friction
	local friction_scale = node_physics.friction
	accel = accel + vel * -friction_scale

	return vector.zero(), accel
end
mod.register_environment_effect(function(pos, vel, staticdata, entity)
	local pos1_r = vector.round(pos)
	local v1,a1 = apply_node_physics(minetest.get_node(pos1_r), vel, staticdata, entity)

	-- TODO: only apply when touching under_node
	local pos2_r = vector.offset(pos1_r,0,-1,0)
	local v2,a2 = apply_node_physics(minetest.get_node(pos2_r), vel, staticdata, entity)

	return (v1 + v2), (a1 + a2)
end)

