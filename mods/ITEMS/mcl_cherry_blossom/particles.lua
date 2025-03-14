-- Tree Growth
-- TODO: Use better spawning behavior and wood api when wood api is finished.

local cherry_particle = {
	velocity = vector.zero(),
	acceleration = vector.new(0, -1, 0),
	size = 1.3 + math.random() * 1.2,
	animation = {
		type = "vertical_frames",
		aspect_w = 3,
		aspect_h = 3,
		length = 0.8,
	},
	collision_removal = false,
	collisiondetection = false,
}

local wind_direction -- vector
local time_changed -- 0 - afternoon; 1 - evening; 2 - morning
local function change_wind_direction()
	local east_west = math.random() - 0.5
	local north_south = math.random() - 0.5
	wind_direction = vector.new(east_west, 0, north_south)
end
change_wind_direction()

core.register_abm({
	label = "Cherry Blossom Particles",
	nodenames = {"mcl_cherry_blossom:cherryleaves"},
	interval = 5,
	chance = 10,
	action = function(pos, node) core.after(0.1 + math.random() * 1.4, function()
		local pt = table.copy(cherry_particle)
		pt.pos = vector.offset(pos, math.random() - 0.5, -0.51, math.random() - 0.5)
		pt.expirationtime = 1.2 + math.random() * 3.3
		pt.texture = "mcl_cherry_blossom_particle_"..math.random(1, 12)..".png"

		local time = core.get_timeofday()
		if time_changed ~= 0 and time > 0.6 and time < 0.605 then
			time_changed = 0
			change_wind_direction()
		elseif (time_changed ~= 1 and time > 0.8 and time < 0.805) then
			time_changed = 1
			change_wind_direction()
		elseif (time_changed ~= 2 and time > 0.3 and time < 0.305) then
			time_changed = 2
			change_wind_direction()
		end

		pt.acceleration = pt.acceleration + wind_direction

		core.add_particle(pt)
	end) end
})
