local S = minetest.get_translator(minetest.get_current_modname())

local WATER_VISC = 1
local USE_TEXTURE_ALPHA = true
if minetest.features.use_texture_alpha_string_modes then
	USE_TEXTURE_ALPHA = "blend"
end

local positions = {}
local function check_bubble_column(pos, node)
	local below_pos = vector.offset(pos,0,-1,0)
	local below = minetest.get_node(below_pos)
	if below.name == "mcl_nether:soul_sand" or below.name == "mcl_nether:magma" then
		return true
	end

	if below.name == "mcl_core:water_source" and positions[minetest.hash_node_position(below_pos)] then
		return true
	end

	print("Tearing down bubble column at "..vector.to_string(pos))

	local pos_hash = minetest.hash_node_position(pos)

	-- Don't continue upwards if this already wasn't a bubble column
	if not positions[pos_hash] then return end

	-- Remove this node from the columnpositions
	positions[pos_hash] = nil

	pos = vector.offset(pos,0,1,0)

	node = minetest.get_node(pos)
	return check_bubble_column(pos,node)
end

minetest.register_abm({
	label = "Create Bubble Column",
	interval = 1,
	chance = 1,
	nodenames = { "mcl_nether:soul_sand", "mcl_nether:magma" },
	neighbors = { "mcl_core:water_source" },
	action = function(pos, node)
		local above_pos = vector.offset(pos,0,1,0)
		local above = minetest.get_node(above_pos)
		if above.name ~= "mcl_core:water_source" then return end

		local direction = 1
		if node.name == "mcl_nether:magma" then
			direction = -1
		end

		-- Create the bubble column
		while above.name == "mcl_core:water_source" do
			local above_pos_hash = minetest.hash_node_position(above_pos)
			if positions[above_pos_hash] == direction then return end
			positions[above_pos_hash] = direction

			above_pos = vector.offset(above_pos,0,1,0)
			above = minetest.get_node(above_pos)
		end
	end
})
local BUBBLE_TIME = 0.5
local BUBBLE_PARTICLE = {
	texture = "mcl_particles_bubble.png",
	collision_removal = false,
	expirationtime = BUBBLE_TIME,
	collisiondetection = false,
	size = 2.5,
}
minetest.register_globalstep(function(dtime)
	for hash,dir in pairs(positions) do
		if math.random(1,17) == 1 then
			local pos = minetest.get_position_from_hash(hash)
			local node = minetest.get_node(pos)
			if check_bubble_column(pos, node) then
				local particle = table.copy(BUBBLE_PARTICLE)
				particle.pos          =  vector.offset(pos, math.random(-28,28)/64, -0.51 * dir, math.random(-28,28)/64)
				particle.velocity     = (vector.offset(pos, math.random(-28,28)/64,  0.51 * dir, math.random(-28,28)/64) - particle.pos) / BUBBLE_TIME
				particle.acceleration = vector.zero()
				minetest.add_particle(particle)
			end
		end
	end
end)
vl_physics.register_environment_effect(function(pos, vel, staticdata, entity)
	local pos_r = vector.round(pos)
	local pos_r_hash = minetest.hash_node_position(pos_r)
	local dir = positions[pos_r_hash]
	if not dir then return nil,nil end

	return vector.new(0,4*dir,0),vector.new(0,9*dir,0)
end)

