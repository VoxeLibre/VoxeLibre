mcl_particles = {}

-- Table of particlespawner IDs on a per-node hash basis
-- Keys: node position hashes
-- Values: Tables of particlespawner IDs (each node pos can have an arbitrary number of particlespawners)
local particle_nodes = {}

-- Node particles can be disabled via setting
local node_particles_allowed = minetest.settings:get("mcl_node_particles") or "medium"

local levels = {
	high = 3,
	medium = 2,
	low = 1,
	none = 0,
}

allowed_level = levels[node_particles_allowed]
if not allowed_level then
	allowed_level = levels["medium"]
end


-- Add a particlespawner that is assigned to a given node position.
-- * pos: Node positon. MUST use integer values!
-- * particlespawner_definition: definition for minetest.add_particlespawner
-- * level: detail level of particles. "high", "medium" or "low". High detail levels are for
-- CPU-demanding particles, like smoke of fire (which occurs frequently)
-- NOTE: All particlespawners are automatically removed on shutdown.
-- Returns particlespawner ID on succcess and nil on failure
function mcl_particles.add_node_particlespawner(pos, particlespawner_definition, level)
	if allowed_level == 0 or levels[level] > allowed_level then
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
	if not particle_nodes[poshash] then
		particle_nodes[poshash] = {}
	end
	table.insert(particle_nodes[poshash], id)
	return id
end

-- Deletes all particlespawners that are assigned to a node position.
-- If no particlespawners exist for this position, nothing happens.
-- pos: Node positon. MUST use integer values!
-- Returns true if particlespawner could be removed and false if not
function mcl_particles.delete_node_particlespawners(pos)
	if allowed_level == 0 then
		return false
	end
	local poshash = minetest.hash_node_position(pos)
	local ids = particle_nodes[poshash]
	if ids then
		for i=1, #ids do
			minetest.delete_particlespawner(ids[i])
		end
		particle_nodes[poshash] = nil
		return true
	end
	return false
end
