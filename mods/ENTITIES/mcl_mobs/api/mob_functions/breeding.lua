local minetest_get_objects_inside_radius = minetest.get_objects_inside_radius

local vector_distance = vector.distance

--check to see if someone nearby has some tasty food
mobs.check_following = function(self) -- returns true or false

    --ignore
    if not self.follow then
        self.following_person = nil
        return(false)
    end

    --hey look, this thing works for passive mobs too!
    local follower = mobs.detect_closest_player_within_radius(self,true,self.view_range,self.eye_height)

    --check if the follower is a player incase they log out
    if follower and follower:is_player() then
        local stack = follower:get_wielded_item()
        --safety check
        if not stack then
            self.following_person = nil
            return(false)
        end

        local item_name = stack:get_name()
        --all checks have passed, that guy has some good looking food
        if item_name == self.follow then
            self.following_person = follower
            return(true)
        end
    end

    --everything failed
    self.following_person = nil
    return(false)
end

--a function which attempts to make mobs enter
--the breeding state
mobs.enter_breed_state = function(self,clicker)

    --do not breed if baby
    if self.baby then
        return(false)
    end

    --do not do anything if looking for mate or
    --if cooling off from breeding
    if self.breed_lookout_timer > 0 or self.breed_timer > 0 then
        return(false)
    end

    --if this is caught, that means something has gone
    --seriously wrong
    if not clicker or not clicker:is_player() then
        return(false)
    end

    local stack = clicker:get_wielded_item()
    --safety check
    if not stack then
        return(false)
    end

    local item_name = stack:get_name()
    --all checks have passed, that guy has some good looking food
    if item_name == self.follow then        
        if not minetest.is_creative_enabled(clicker:get_player_name()) then
            stack:take_item()
            clicker:set_wielded_item(stack)
        end
        self.breed_lookout_timer = self.breed_lookout_timer_goal
        self.bred = true
        mobs.play_sound_specific(self,"mobs_mc_animal_eat_generic")
        return(true)
    end

    --everything failed
    return(false)
end


--find the closest mate in the area
mobs.look_for_mate = function(self)

	local pos1 = self.object:get_pos()
    pos1.y = pos1.y + self.eye_height

	local mates_in_area = {}
	local winner_mate = nil
	local mates_detected = 0
    local radius = self.view_range

	--get mates in radius
	for _,mate in pairs(minetest_get_objects_inside_radius(pos1, radius)) do

        --look for a breeding mate
		if mate and mate:get_luaentity() 
        and mate:get_luaentity()._cmi_is_mob 
        and mate:get_luaentity().name == self.name 
        and mate:get_luaentity().breed_lookout_timer > 0
        and mate:get_luaentity() ~= self then

			local pos2 = mate:get_pos()

			local distance = vector_distance(pos1,pos2)

			if distance <= radius then
				if line_of_sight then
					--must add eye height or stuff breaks randomly because of
					--seethrough nodes being a blocker (like grass)
					if minetest_line_of_sight(
							vector_new(pos1.x, pos1.y, pos1.z), 
							vector_new(pos2.x, pos2.y + mate:get_properties().eye_height, pos2.z)
						) then
						mates_detected = mates_detected + 1
						mates_in_area[mate] = distance
					end
				else
					mates_detected = mates_detected + 1
					mates_in_area[mate] = distance
				end
			end
		end
	end


	--return if there's no one near by
	if mates_detected <= 0 then --handle negative numbers for some crazy error that could possibly happen
		return nil
	end

	--do a default radius max
	local shortest_distance = radius + 1

	--sort through mates and find the closest mate
	for mate,distance in pairs(mates_in_area) do
		if distance < shortest_distance then
			shortest_distance = distance
			winner_mate = mate
		end
	end

	return(winner_mate)

end

--make the baby grow up
mobs.baby_grow_up = function(self)
    self.baby = nil
    self.visual_size  = self.backup_visual_size
    self.collisionbox = self.backup_collisionbox
    self.selectionbox = self.backup_selectionbox
    self.object:set_properties(self)
end

--makes the baby grow up faster with diminishing returns
mobs.make_baby_grow_faster = function(self,clicker)
    if clicker and clicker:is_player() then
        local stack = clicker:get_wielded_item()
        --safety check
        if not stack then            
            return(false)
        end

        local item_name = stack:get_name()
        --all checks have passed, that guy has some good looking food
        if item_name == self.follow then
            self.grow_up_timer = self.grow_up_timer - (self.grow_up_timer * 0.10) --take 10 percent off - diminishing returns     

            if not minetest.is_creative_enabled(clicker:get_player_name()) then
                stack:take_item()
                clicker:set_wielded_item(stack)
            end

            mobs.play_sound_specific(self,"mobs_mc_animal_eat_generic")

            return(true)
        end
    end

    return(false)
end