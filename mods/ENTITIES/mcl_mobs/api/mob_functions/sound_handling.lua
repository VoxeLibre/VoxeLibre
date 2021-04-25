local math_random = math.random


--generic call for sound handler for mobs (data access)
mobs.play_sound = function(self,sound)
    local soundinfo = self.sounds

    if not soundinfo then
        return
    end

    local play_sound = soundinfo[sound]

    if not play_sound then
        return
    end

    mobs.play_sound_handler(self, play_sound)
end


--generic sound handler for mobs
mobs.play_sound_handler = function(self, sound)
    local pitch = (100 + math_random(-15,15) + math_random()) / 100
    local distance = self.sounds.distance or 16

    minetest.sound_play(sound, {
        object = self.object,
        gain = 1.0,
        max_hear_distance = distance,
        pitch = pitch,
    }, true)
end


--random sound timing handler
mobs.random_sound_handling = function(self,dtime)

    self.random_sound_timer = self.random_sound_timer - dtime

    --play sound and reset timer
    if self.random_sound_timer <= 0 then
        mobs.play_sound(self,"random")
        self.random_sound_timer = math_random(self.random_sound_timer_min,self.random_sound_timer_max)
    end
end

--used for playing a non-mob internal sound at random pitches
mobs.play_sound_specific = function(self,soundname)
    local pitch = (100 + math_random(-15,15) + math_random()) / 100
    local distance = self.sounds.distance or 16

    minetest.sound_play(soundname, {
        object = self.object,
        gain = 1.0,
        max_hear_distance = distance,
        pitch = pitch,
    }, true)
end