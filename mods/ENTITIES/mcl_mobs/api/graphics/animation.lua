-- set defined animation
function mcl_mobs.mob:set_animation(anim, fixed_frame)

	if not self.animation or not anim then
		return
	end

	if self.state == "die" and anim ~= "die" and anim ~= "stand" then
		return
	end


	if (not self.animation[anim .. "_start"] or not self.animation[anim .. "_end"]) then
		return
	end

	--animations break if they are constantly set
	--so we put this return gate to check if it is
	--already at the animation we are trying to implement
	if self.current_animation == anim then
		return
	end

	local a_start = self.animation[anim .. "_start"]
	local a_end

	if fixed_frame then
		a_end = a_start
	else
		a_end = self.animation[anim .. "_end"]
	end

	self.object:set_animation({
		x = a_start,
		y = a_end},
		self.animation[anim .. "_speed"] or self.animation.speed_normal or 15,
		0, self.animation[anim .. "_loop"] ~= false)


	self.current_animation = anim
end

--this is a helper function for mobs explosion animation
function mcl_mobs.mob:handle_explosion_animation()

	--secondary catch-all
	if not self.explosion_animation then
		self.explosion_animation = 0
	end

	--the timer works from 0 for sense of a 0 based counting
	--but this just bumps it up so it's usable in here
	local explosion_timer_adjust = self.explosion_animation + 1


	local visual_size_modified = table.copy(self.visual_size_origin)

	visual_size_modified.x = visual_size_modified.x * (explosion_timer_adjust ^ 3)
	visual_size_modified.y = visual_size_modified.y * explosion_timer_adjust

	self.object:set_properties({visual_size = visual_size_modified})
end


