local minetest_add_particlespawner = minetest.add_particlespawner

mobs.death_effect = function(self)

    local pos = self.object:get_pos()
    local yaw = self.object:get_yaw()
    local collisionbox = self.object:get_properties().collisionbox

    local min, max

    if collisionbox then
        min = {x=collisionbox[1], y=collisionbox[2], z=collisionbox[3]}
        max = {x=collisionbox[4], y=collisionbox[5], z=collisionbox[6]}
    end

    minetest_add_particlespawner({
        amount = 50,
        time = 0.0001,
        minpos = vector.add(pos, min),
        maxpos = vector.add(pos, max),
        minvel = vector.new(-0.5,0.5,-0.5),
        maxvel = vector.new(0.5,1,0.5),
        minexptime = 1.1,
        maxexptime = 1.5,
        minsize = 1,
        maxsize = 2,
        collisiondetection = false,
        vertical = false,
        texture = "mcl_particles_mob_death.png", -- this particle looks strange
    })
end

mobs.critical_effect = function(self)

    local pos = self.object:get_pos()
    local yaw = self.object:get_yaw()
    local collisionbox = self.object:get_properties().collisionbox

    local min, max

    if collisionbox then
        min = {x=collisionbox[1], y=collisionbox[2], z=collisionbox[3]}
        max = {x=collisionbox[4], y=collisionbox[5], z=collisionbox[6]}
    end

    minetest_add_particlespawner({
        amount = 10,
        time = 0.0001,
        minpos = vector.add(pos, min),
        maxpos = vector.add(pos, max),
        minvel = vector.new(-1,1,-1),
        maxvel = vector.new(1,3,1),
        minexptime = 0.7,
        maxexptime = 1,
        minsize = 1,
        maxsize = 2,
        collisiondetection = false,
        vertical = false,
        texture = "heart.png^[colorize:black:255",
    })
end

--when feeding a mob
mobs.feed_effect = function(self)

    local pos = self.object:get_pos()
    local yaw = self.object:get_yaw()
    local collisionbox = self.object:get_properties().collisionbox

    local min, max

    if collisionbox then
        min = {x=collisionbox[1], y=collisionbox[2], z=collisionbox[3]}
        max = {x=collisionbox[4], y=collisionbox[5], z=collisionbox[6]}
    end

    minetest_add_particlespawner({
        amount = 10,
        time = 0.0001,
        minpos = vector.add(pos, min),
        maxpos = vector.add(pos, max),
        minvel = vector.new(-1,1,-1),
        maxvel = vector.new(1,3,1),
        minexptime = 0.7,
        maxexptime = 1,
        minsize = 1,
        maxsize = 2,
        collisiondetection = false,
        vertical = false,
        texture = "heart.png^[colorize:gray:255",
    })
end

--hearts when tamed
mobs.tamed_effect = function(self)
    local pos = self.object:get_pos()
    local yaw = self.object:get_yaw()
    local collisionbox = self.object:get_properties().collisionbox

    local min, max

    if collisionbox then
        min = {x=collisionbox[1], y=collisionbox[2], z=collisionbox[3]}
        max = {x=collisionbox[4], y=collisionbox[5], z=collisionbox[6]}
    end

    minetest_add_particlespawner({
        amount = 30,
        time = 0.0001,
        minpos = vector.add(pos, min),
        maxpos = vector.add(pos, max),
        minvel = vector.new(-1,1,-1),
        maxvel = vector.new(1,3,1),
        minexptime = 0.7,
        maxexptime = 1,
        minsize = 1,
        maxsize = 2,
        collisiondetection = false,
        vertical = false,
        texture = "heart.png",
    })
end

--hearts when breeding
mobs.breeding_effect = function(self)
    local pos = self.object:get_pos()
    local yaw = self.object:get_yaw()
    local collisionbox = self.object:get_properties().collisionbox

    local min, max

    if collisionbox then
        min = {x=collisionbox[1], y=collisionbox[2], z=collisionbox[3]}
        max = {x=collisionbox[4], y=collisionbox[5], z=collisionbox[6]}
    end

    minetest_add_particlespawner({
        amount = 2,
        time = 0.0001,
        minpos = vector.add(pos, min),
        maxpos = vector.add(pos, max),
        minvel = vector.new(-1,1,-1),
        maxvel = vector.new(1,3,1),
        minexptime = 0.7,
        maxexptime = 1,
        minsize = 1,
        maxsize = 2,
        collisiondetection = false,
        vertical = false,
        texture = "heart.png",
    })
end