function mcl_mobs.mob:get_staticdata()
	if self.dead then
		self.object:remove()
		return
	end

	self:anger_on_staticdata()

	if self.def.on_staticdata then
		if self.def.on_staticdata(self) == false then
			self.object:remove()
			return
		end
	end

	return minetest.serialize(self.data)
end

function mcl_mobs.mob:on_activate(staticdata, def, dtime)
	self.is_mob = true
	self.def = mcl_mobs.registered_mobs[self.name] -- just access the mob def instead of spamming the luaentity itself with a copy of every single definition field that is never mutated
	self.description = def.description -- external mods might want to access this

	self.data = minetest.deserialize(staticdata) or {}

	self.data.health = self.data.health or math.random(self.def.health_min, self.def.health_max)
	self.data.breath = self.data.breath or self.def.breath_max
	self.data.yaw = self.data.yaw or 0

	self:reload_properties()
	self:backup_movement()

	self:anger_on_activate()
	self:despawn_on_activate()
	self:breeding_on_activate()

	self:set_animation("stand")
	self:update_collisionbox()
	self:update_eye_height()
	self:update_mesh()
	self:update_nametag()
	self:update_roll()
	self:update_textures()
	self:update_visual_size()

	if self.def.on_spawn and not self.data.on_spawn_run then
		self.def.on_spawn(self)
		self.data.on_spawn_run = true
	end

	if self.def.on_activate then
		if self.def.on_activate(self, staticdata, def, dtime) == false then
			self.object:remove()
			return
		end
	end
end
