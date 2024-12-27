local S = minetest.get_translator(minetest.get_current_modname())

local tt_help = S("Flight Duration:")
local description = S("Firework Rocket")

local TAU = 2*math.pi

local function explode(self, pos)
	-- temp code
	vl_fireworks.generic_particle_explosion(pos)
	mcl_mobs.mob_class.safe_boom(self, pos, 1)
end

local firework_entity = {
	physical = true,
	pointable = false,
	visual = "mesh",
	visual_size = {x=3, y=3},
	mesh = "vl_fireworks_rocket.obj",
	textures = {"vl_fireworks_entity.png"},
	backface_culling = false,
	collisionbox = {-0.1, 0, -0.1, 0.1, 0.5, 0.1},
	collide_with_objects = false,
	liquid_drag = true,
	_fire_damage_resistant = true,

	_save_fields = {
		"last_pos", "startpos", "time_in_air", "vl_projectile", "arrow_item"--[[???]], "itemstring", "duration"
	},

	_damage=1,	-- Damage on impact
	_blocked = false,
	_viscosity=0,   -- Viscosity of node the arrow is currently in

	_vl_projectile = {
		ignore_gravity = true,
		survive_collision = false,
		damages_players = true,
		maximum_time = 3,
		pitch_offset = -math.pi / 2,
		damage_groups = function(self)
			return { fleshy = vector.length(self.object:get_velocity()) }
		end,
		tracer_texture = "mobs_mc_arrow_particle.png",
		behaviors = {
			vl_projectile.burns,
			vl_projectile.has_tracer,

			function(self, dtime)
				if self._vl_projectile.extra then
					local e = self._vl_projectile.extra
					self._force = e.force/10 + 5
					self._vl_projectile.maximum_time = e.dur
					self._rot_axis = e.rot_axis
					self._dir = self.object:get_velocity():normalize()
					self._vl_projectile.extra = nil
				end
				if not self._dir then return end
				if self._last_pos and (self._last_pos - self.object:get_pos()):length() < (10*dtime) then
					self._rot_axis = -self._rot_axis
				end
				self._dir = self._dir:rotate_around_axis(self._rot_axis, dtime/3)
				local obj = self.object
				obj:set_velocity((obj:get_velocity():length() + self._force*dtime) * self._dir)
			end,

			vl_projectile.collides_with_solids,
			vl_projectile.raycast_collides_with_entities,
		},
		allow_punching = function(self, entity_def, projectile_def, object)
			local lua = object:get_luaentity()
			if lua and lua.name == "mobs_mc:rover" then return false end
			--if (self.object:get_velocity() + object:get_velocity()).length() < 5 then return end

			minetest.log("allow punching")

			return true
		end,
	},

	get_staticdata = function(self)
		local out = {}
		local save_fields = self._save_fields
		for i = 1,#save_fields do
			local field = save_fields[i]
			out[field] = self["_"..field]
		end

		-- Preserve entity properties
		out.properties = self.object:get_properties()

		return minetest.serialize(out)
	end,
	on_activate = function(self, staticdata, dtime_s)
		self.object:set_armor_groups({ immortal = 1 })

		self._time_in_air = 1.0
		local data = minetest.deserialize(staticdata)
		if not data then return end

		-- Restore entity properties
		if data.properties then
			self.object:set_properties(data.properties)
			data.properties = nil
		end

		-- Restore arrow state
		local save_fields = self._save_fields
		for i = 1,#save_fields do
			local field = save_fields[i]
			self["_"..field] = data[field]
		end

		if not self._vl_projectile then
			self._vl_projetile = {}
		end
	end,

	_on_remove = function(self)
		explode(self, self.object:get_pos())
	end,
}

vl_projectile.register("vl_fireworks:rocket", firework_entity)

function vl_fireworks.shoot_firework(itemstack, pos, dir)
	local meta = itemstack:get_meta()
	local rot_axis = vector.new(1,0,0)
	rot_axis = rot_axis:rotate_around_axis(vector.new(0,1,0), math.random()*TAU)
	vl_projectile.create("vl_fireworks:rocket", {
		pos = pos,
		dir = dir or vector.new(0,1,0),
		velocity = 1 + meta:get_int("vl_fireworks:force")/10,
		extra = {
			dur = meta:get_float("vl_fireworks:duration"),
			force = meta:get_float("vl_fireworks:force"),
			rot_axis = rot_axis
		}
	})
end

local firework_def = {
	description = description,
	inventory_image = "vl_fireworks_rocket.png",
	stack_max = 64,
	on_use = function(itemstack, user, pointed_thing)
		local elytra = mcl_playerplus.elytra[user]
		if elytra.active and elytra.rocketing <= 0 then
			elytra.rocketing = meta:get_float("vl_fireworks:duration")
			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:take_item()
			end
			minetest.sound_play("vl_fireworks_rocket", {pos = user:get_pos()})
		end
		return itemstack
	end,
	on_place = function(itemstack, user, pointed_thing)
		local pos = pointed_thing.above
		vl_fireworks.shoot_firework(itemstack, pos)
	end,
	_on_dispense = function(dropitem, pos, droppos, dropnode, dropdir)
		vl_fireworks.shoot_firework(dropitem, pos, dropdir)
	end,
	_vl_fireworks_std_durs_forces = { {2.2, 10}, {4.5, 20}, {6, 30} },
	_vl_fireworks_tt = function(duration)
		return S("Duration:") .. " " .. duration
	end,
}
vl_fireworks.firework_def = table.copy(firework_def)

minetest.register_craftitem("vl_fireworks:rocket", firework_def)
