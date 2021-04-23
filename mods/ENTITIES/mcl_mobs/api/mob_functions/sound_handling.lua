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

    minetest.sound_play(sound, {
        object = self.object,
        gain = 1.0,
        max_hear_distance = self.sounds.distance,
        pitch = pitch,
    }, true)
end