local minetest_add_item = minetest.add_item
local minetest_add_particlespawner = minetest.add_particlespawner
local minetest_sound_play = minetest.sound_play

local math_pi     = math.pi
local math_random = math.random
local math_floor  = math.floor
local HALF_PI     = math_pi / 2

local vector_new = vector.new


local death_effect = function(self)

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
        time = 0.001,
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


-- drop items
local item_drop = function(self, cooked, looting_level)

	looting_level = looting_level or 0

	-- no drops for child mobs (except monster)
	if (self.child and self.type ~= "monster") then
		return
	end

	local obj, item, num
	local pos = self.object:get_pos()

	self.drops = self.drops or {} -- nil check

	for n = 1, #self.drops do
		local dropdef = self.drops[n]
		local chance = 1 / dropdef.chance
		local looting_type = dropdef.looting

		if looting_level > 0 then
			local chance_function = dropdef.looting_chance_function
			if chance_function then
				chance = chance_function(looting_level)
			elseif looting_type == "rare" then
				chance = chance + (dropdef.looting_factor or 0.01) * looting_level
			end
		end

		local num = 0
		local do_common_looting = (looting_level > 0 and looting_type == "common")
		if math_random() < chance then
			num = math_random(dropdef.min or 1, dropdef.max or 1)
		elseif not dropdef.looting_ignore_chance then
			do_common_looting = false
		end

		if do_common_looting then
			num = num + math_floor(math_random(0, looting_level) + 0.5)
		end

		if num > 0 then
			item = dropdef.name

			-- cook items when true
			if cooked then

				local output = minetest_get_craft_result({
					method = "cooking", width = 1, items = {item}})

				if output and output.item and not output.item:is_empty() then
					item = output.item:get_name()
				end
			end

			-- add item if it exists
			for x = 1, num do
				obj = minetest_add_item(pos, ItemStack(item .. " " .. 1))
			end

			if obj and obj:get_luaentity() then

				obj:set_velocity({
					x = math_random(-10, 10) / 9,
					y = 6,
					z = math_random(-10, 10) / 9,
				})
			elseif obj then
				obj:remove() -- item does not exist
			end
		end
	end

	self.drops = {}
end


mobs.death_logic = function(self, dtime)
    self.death_animation_timer = self.death_animation_timer + dtime


    --the final POOF of a mob despawning
    if self.death_animation_timer >= 1.25 then

        item_drop(self,false,1)

        death_effect(self)

        self.object:remove()

        return
    end

    --I'm sure there's a more efficient way to do this
    --but this is the easiest, easier to work with 1 variable synced
    --this is also not smooth
    local death_animation_roll = self.death_animation_timer * 2 -- * 2 to make it faster
    if death_animation_roll > 1 then
        death_animation_roll = 1
    end

    local rot = self.object:get_rotation() --(no pun intended)

    rot.z = death_animation_roll * HALF_PI

    self.object:set_rotation(rot)

    mobs.set_mob_animation(self,"stand", true)


    --flying and swimming mobs just fall down
    if self.fly or self.swim then
        if self.object:get_acceleration().y ~= -self.gravity then
            self.object:set_acceleration(vector_new(0,-self.gravity,0))
        end
    end

    --when landing allow mob to slow down and just fall if in air
    if self.pause_timer <= 0 then
        mobs.set_velocity(self,0)
    end
end