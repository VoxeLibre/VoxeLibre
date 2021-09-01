function mcl_mobs.mob:play_sound(sound_name)
    local sound = self.def.sounds[sound_name]

    if sound then
        self:play_sound_specific(sound)
    end
end

function mcl_mobs.mob:play_sound_specific(self, sound)
	if not self.silent then
		minetest.sound_play(sound, {
			object = self.object,
			gain = 1.0,
			max_hear_distance = 16,
			pitch = (100 + math.random(-15, 15) + math.random()) / 100,
		}, true)
	end
end

function mcl_mobs.mob:start_sound_timer()
	self.random_sound_timer = math.random(self.def.random_sound_timer_min, self.def.random_sound_timer_max)
end

function mcl_mobs.mob:sound_step()
	if not self.random_sound_timer then
		self:start_sound_timer()
	end
    if self:do_timer("random_sound") then
        self:play_sound("random")
		self:start_sound_timer()
    end
end
