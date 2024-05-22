-- Tree Growth
-- TODO: Use better spawning behavior and wood api when wood api is finished.
function mcl_cherry_blossom.generate_cherry_tree(pos)
	local pr = PseudoRandom(pos.x+pos.y+pos.z)
	local r = pr:next(1,3)
	local modpath = minetest.get_modpath("mcl_cherry_blossom")
	local path = modpath.."/schematics/mcl_cherry_blossom_tree_"..tostring(r)..".mts"
	if mcl_core.check_growth_width(pos,7,8) then
		minetest.set_node(pos, {name = "air"})
		if r == 1 then
			minetest.place_schematic(vector.offset(pos, -2, 0, -2), path, "random", nil, false)
		elseif r == 2 then
			minetest.place_schematic(vector.offset(pos, -2, 0, -2), path, nil, nil, false)
		elseif r == 3 then
			minetest.place_schematic(vector.offset(pos, -3, 0, -3), path, nil, nil, false)
		end
	end
end

minetest.register_abm({
	label = "Cherry Tree Growth",
	nodenames = "mcl_cherry_blossom:cherrysapling",
	interval = 30,
	chance = 5,
	action = function(pos,node)
		mcl_cherry_blossom.generate_cherry_tree(pos)
	end,
})

local cherry_particle = {
	velocity = vector.zero(),
	acceleration = vector.new(0,-1,0),
	size = math.random(1.3,2.5),
	texture = "mcl_cherry_blossom_particle_" .. math.random(1, 12) .. ".png",
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
	local east_west = math.random(-0.5,0.5)
	local north_south = math.random(-0.5,0.5)
	wind_direction = vector.new(east_west, 0, north_south)
end
change_wind_direction()

minetest.register_abm({
	label = "Cherry Blossom Particles",
	nodenames = {"mcl_cherry_blossom:cherryleaves"},
	interval = 5,
	chance = 10,
	action = function(pos, node)
		minetest.after(math.random(0.1,1.5),function()
			local pt = table.copy(cherry_particle)
			pt.pos = vector.offset(pos,math.random(-0.5,0.5),-0.51,math.random(-0.5,0.5))
			pt.expirationtime = math.random(1.2,4.5)
			pt.texture = "mcl_cherry_blossom_particle_" .. math.random(1, 12) .. ".png"
			local time = minetest.get_timeofday()
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

			minetest.add_particle(pt)
		end)
	end
})
