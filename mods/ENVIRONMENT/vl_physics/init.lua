local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local mod = {}
vl_physics = mod

dofile(modpath.."/api.lua")

-- Locallized functions
local math_round = math.round

-- Flowing water
-- TODO: move to Flowlib
local FLOW_SPEED = 1.39
local BOUANCY = 3
mod.register_environment_effect(function(pos, collisionbox, vel, staticdata, entity)
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
mod.register_environment_effect(function(pos, collisionbox, vel, staticdata, entity)
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
local function apply_node_physics(pos, v, a, vel, staticdata, entity)
	local node = core.get_node(pos)
	local node_def = minetest.registered_nodes[node.name] or {}
	local node_physics = node_def._vl_physics or DEFAULT_NODE_PHYSICS

	-- Custom node physics
	local node_physics_effect = node_physics.effect
	if node_physics_effect then
		return node_physics_effect(pos, vel, staticdata)
	end

	-- Default node physics

	-- Friction
	if node.name ~= "air" and vector.length(vel) > 0.01 then
		local friction_scale = node_physics.friction
		a.x = a.x + vel.x * -friction_scale
		a.y = a.y + vel.y * -friction_scale
		a.z = a.z + vel.z * -friction_scale
	end
end

local DEFAULT_COLLISION_BOX = { -0.312, -0.55, -0.312, 0.312, 1.25, 0.312 }
local npos = vector.zero()
local a = vector.zero()
local v = vector.zero()
mod.register_environment_effect(function(pos, collisionbox, vel, staticdata, entity)
	-- Reset acceleration and velocity
	a.x,a.y,a.z = 0,0,0
	v.x,v.y,v.z = 0,0,0

	npos.x = math_round(pos.x)
	npos.z = math_round(pos.z)
	for y = math_round(pos.y)-1,math_round(pos.y) do
		npos.y = y

		-- Apply node physics for the node we are inside of
		apply_node_physics(npos, v, a, vel, staticdata, entity)
	end

	-- Make speeds of less than 1/100 block/second count as zero
	local len = v.x*v.x + v.y+v.y + v.z+v.z
	if len < 0.0001 then
		return nil, a
	else
		return v,a
	end
end)

