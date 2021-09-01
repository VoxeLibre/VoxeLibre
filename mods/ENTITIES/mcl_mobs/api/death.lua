function mcl_mobs.mob:die(reason)
	self.dead = true
	self.death_timer = mcl_mobs.const.death_timer

	for _, obj in pairs(self.object:get_children()) do
		mcl_mount.throw_off(obj)
	end

	if minetest.settings:get_bool("doMobDrops", true) then
		self:drop_loot(reason)
	end

	self:play_sound("death")
	self:set_animation("death")
	self:set_properties({pointable = false})
	self:update_acceleration()

	if self.def.on_death then
		self.def.on_death(self, reason)
	end
end

function mcl_mobs.mob:death_step()
	if self:do_timer("death") then
		self:update_roll()
	else
		local pos = self.object:get_pos()

		minetest.add_particlespawner({
			amount = 50,
			time = 0.0001,
			minpos = vector.add(pos, self.collisionbox.min),
			maxpos = vector.add(pos, self.collisionbox.max),
			minvel = vector.new(-0.5, 0.5, -0.5),
			maxvel = vector.new(0.5, 1.0, 0.5),
			minexptime = 1.1,
			maxexptime = 1.5,
			minsize = 1,
			maxsize = 2,
			collisiondetection = false,
			vertical = false,
			texture = "mcl_particles_mob_death.png",
		})

		self:play_sound_specific("mcl_sounds_poof")

		self.object:remove() -- RIP
	end
end
