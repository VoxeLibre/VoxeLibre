local minetest_add_item = minetest.add_item
--local minetest_sound_play = minetest.sound_play

local math_pi     = math.pi
local math_random = math.random
local math_floor  = math.floor
local HALF_PI     = math_pi / 2

local vector_new = vector.new


-- drop items
local item_drop = function(self, cooked, looting_level)

	looting_level = looting_level or 0

	-- no drops for child mobs (except monster)
	if (self.child and self.type ~= "monster") then
		return
	end

	local obj, item
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

				local output = minetest.get_craft_result({
					method = "cooking",
                    width = 1,
                    items = {item},
                })

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

	--stop crashing game when object is nil
	if not self or not self.object or not self.object:get_luaentity() then
		return
	end

    self.death_animation_timer = self.death_animation_timer + dtime

	--get all attached entities and sort through them
	local attached_entities = self.object:get_children()
	if #attached_entities > 0 then
		for _,entity in pairs(attached_entities) do
			--kick the player off
			if entity:is_player() then
				mobs.detach(entity)
			--kick mobs off
			--if there is scaling issues, this needs an additional check
			else
				entity:set_detach()
			end
		end
	end

	--stop mob from getting in the way of other mobs you're fighting
	if self.object:get_properties().pointable then
		self.object:set_properties({pointable = false})
	end

    --the final POOF of a mob despawning
    if self.death_animation_timer >= 1.25 then
        item_drop(self,false,1)
        mobs.death_effect(self)
        mcl_experience.throw_experience(self.object:get_pos(), math_random(self.xp_min, self.xp_max))
        if self.on_die then
          self.on_die(self, self.object:get_pos())
        end
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
