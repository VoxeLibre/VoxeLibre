local particle_nodes = {}

mcl_particles = {}

-- Node particles can be disabled via setting
local node_particles_allowed = minetest.settings:get_bool("mcl_node_particles", true)

-- Add a particlespawner that is assigned to a given node position.
-- * pos: Node positon. MUST use rounded values!
-- * particlespawner_definition: definition for minetest.add_particlespawner
-- NOTE: All particlespawners are automatically removed on shutdown.
-- Returns particlespawner ID on succcess and nil on failure
function mcl_particles.add_node_particlespawner(pos, particlespawner_definition)
	if not node_particles_allowed then
		return
	end
	local poshash = minetest.hash_node_position(pos)
	if not poshash then
		return
	end
	local id = minetest.add_particlespawner(particlespawner_definition)
	if id == -1 then
		return
	end
	particle_nodes[poshash] = id
	return id
end

-- Deleted a particlespawner that is assigned to a node position, if one exists.
-- Otherwise, this does nothing.
-- pos: Node positon. MUST use rounded values!
-- Returns true if particlespawner could be removed and false if none existed
function mcl_particles.delete_node_particlespawner(pos)
	if not node_particles_allowed then
		return false
	end
	local poshash = minetest.hash_node_position(pos)
	local id = particle_nodes[poshash]
	if id then
		minetest.delete_particlespawner(id)
		return true
	end
	return false
end
