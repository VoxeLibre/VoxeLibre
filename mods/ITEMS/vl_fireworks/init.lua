local path = minetest.get_modpath("vl_fireworks")

vl_fireworks = {}

local colors = {"red", "yellow", "blue", "green", "white"}


function vl_fireworks.generic_particle_explosion(pos, size)
	if pos.object then pos = pos.object:get_pos() end
	local particle_pattern = math.random(1, 3)
	local fpitch
	local type = math.random(1, 2)
	local size = size or math.random(1, 3)
	local this_colors = {colors[math.random(#colors)], colors[math.random(#colors)], colors[math.random(#colors)]}

	if size == 1 then
		fpitch = math.random(200, 300)
	elseif size == 2 then
		fpitch = math.random(100, 130)
	else
		fpitch = math.random(60, 70)
	end

	if type == 1 then
		core.sound_play("mcl_bows_firework", {
			pos = pos,
			max_hear_distance = 100,
			gain = 3.0,
			pitch = fpitch/100
		}, true)
	else
		core.sound_play("mcl_bows_firework_soft", {
			pos = pos,
			max_hear_distance = 100,
			gain = 4.0,
			pitch = fpitch/100
		}, true)
	end

	if particle_pattern == 1 then
		core.add_particlespawner({
				amount = 400 * size,
				time = 0.0001,
				minpos = pos,
				maxpos = pos,
				minvel = vector.new(-7 * size,-7 * size,-7 * size),
				maxvel = vector.new(7 * size,7 * size,7 * size),
				minexptime = .6 * size / 2,
				maxexptime = .9 * size / 2,
				minsize = 2 * size,
				maxsize = 3 * size,
				collisiondetection = false,
				vertical = false,
				texture = "mcl_bows_firework_"..this_colors[1]..".png",
				glow = 14,
		})
		core.add_particlespawner({
				amount = 400 * size,
				time = 0.0001,
				minpos = pos,
				maxpos = pos,
				minvel = vector.new(-2 * size,-2 * size,-2 * size),
				maxvel = vector.new(2 * size,2 * size,2 * size),
				minexptime = .6 * size / 2,
				maxexptime = .9 * size / 2,
				minsize = 2 * size,
				maxsize = 3 * size,
				collisiondetection = false,
				vertical = false,
				texture = "mcl_bows_firework_"..this_colors[2]..".png",
				glow = 14,
		})
		core.add_particlespawner({
				amount = 100 * size,
				time = 0.0001,
				minpos = pos,
				maxpos = pos,
				minvel = vector.new(-14 * size,-14 * size,-14 * size),
				maxvel = vector.new(14 * size,14 * size,14 * size),
				minexptime = .6 * size / 2,
				maxexptime = .9 * size / 2,
				minsize = 2 * size,
				maxsize = 3 * size,
				collisiondetection = false,
				vertical = false,
				texture = "mcl_bows_firework_"..this_colors[3]..".png",
				glow = 14,
		})
	elseif particle_pattern == 2 then

		core.add_particlespawner({
				amount = 240 * size,
				time = 0.0001,
				minpos = pos,
				maxpos = pos,
				minvel = vector.new(-5 * size,-5 * size,-5 * size),
				maxvel = vector.new(5 * size,5 * size,5 * size),
				minexptime = .6 * size / 2,
				maxexptime = .9 * size / 2,
				minsize = 2 * size,
				maxsize = 3 * size,
				collisiondetection = false,
				vertical = false,
				texture = "mcl_bows_firework_"..this_colors[1]..".png",
				glow = 14,
		})
		core.add_particlespawner({
				amount = 500 * size,
				time = 0.0001,
				minpos = pos,
				maxpos = pos,
				minvel = vector.new(-2 * size,-2 * size,-2 * size),
				maxvel = vector.new(2 * size,2 * size,2 * size),
				minexptime = .6 * size / 2,
				maxexptime = .9 * size / 2,
				minsize = 2 * size,
				maxsize = 3 * size,
				collisiondetection = false,
				vertical = false,
				texture = "mcl_bows_firework_"..this_colors[2]..".png",
				glow = 14,
		})
		core.add_particlespawner({
				amount = 350 * size,
				time = 0.0001,
				minpos = pos,
				maxpos = pos,
				minvel = vector.new(-3 * size,-3 * size,-3 * size),
				maxvel = vector.new(3 * size,3 * size,3 * size),
				minexptime = .6 * size / 2,
				maxexptime = .9 * size / 2,
				minsize = 2 * size,
				maxsize = 3 * size,
				collisiondetection = false,
				vertical = false,
				texture = "mcl_bows_firework_"..this_colors[3]..".png",
				glow = 14,
		})
	elseif particle_pattern == 3 then

		core.add_particlespawner({
				amount = 400 * size,
				time = 0.0001,
				minpos = pos,
				maxpos = pos,
				minvel = vector.new(-6 * size,-4 * size,-6 * size),
				maxvel = vector.new(6 * size,4 * size,6 * size),
				minexptime = .6 * size,
				maxexptime = .9 * size,
				minsize = 2 * size,
				maxsize = 3 * size,
				collisiondetection = false,
				vertical = false,
				texture = "mcl_bows_firework_"..this_colors[1]..".png",
				glow = 14,
		})
		core.add_particlespawner({
				amount = 120 * size,
				time = 0.0001,
				minpos = pos,
				maxpos = pos,
				minvel = vector.new(-8 * size,6 * size,-8 * size),
				maxvel = vector.new(8 * size,6 * size,8 * size),
				minexptime = .6 * size,
				maxexptime = .9 * size,
				minsize = 2 * size,
				maxsize = 3 * size,
				collisiondetection = false,
				vertical = false,
				texture = "mcl_bows_firework_"..this_colors[2]..".png",
				glow = 14,
		})
		core.add_particlespawner({
				amount = 130 * size,
				time = 0.0001,
				minpos = pos,
				maxpos = pos,
				minvel = vector.new(-3 * size,3 * size,-3 * size),
				maxvel = vector.new(3 * size,3 * size,3 * size),
				minexptime = .6 * size,
				maxexptime = .9 * size,
				minsize = 2 * size,
				maxsize = 3 * size,
				collisiondetection = false,
				vertical = false,
				texture = "mcl_bows_firework_"..this_colors[3]..".png",
				glow = 14,
		})
	end

	return size
end

dofile(path .. "/star.lua")
dofile(path .. "/rockets.lua")
dofile(path .. "/crafting.lua")
