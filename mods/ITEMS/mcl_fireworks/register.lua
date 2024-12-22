local S = minetest.get_translator(minetest.get_current_modname())

local tt_help = S("Flight Duration:")
local description = S("Firework Rocket")

local function explode(self, pos)
	-- temp code
	mcl_mobs.mob_class.boom(self, pos, 1)
end

local firework_entity = {
	physical = true,
	pointable = false,
	visual = "mesh",
	visual_size = {x=3, y=3},
	mesh = "mcl_fireworks_rocket.obj",
	textures = {"mcl_fireworks_entity.png"},
	backface_culling = false,
	collisionbox = {-0.1, 0, -0.1, 0.1, 0.5, 0.1},
	collide_with_objects = false,
	liquid_drag = true,
	_fire_damage_resistant = true,

	_save_fields = {
		"last_pos", "startpos", "damage", "time_in_air", "vl_projectile", "arrow_item"--[[???]], "itemstring"
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
				self.object:add_velocity(vector.new(0, 2*dtime, 0)) -- TODO var. accel. TODO max speed?
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

local function register_rocket(n, duration, force)
	def = table.copy(firework_entity)
	vl_projectile.register("mcl_fireworks:rocket_" .. n, def) -- TODO one entity
	minetest.register_craftitem("mcl_fireworks:rocket_" .. n, { -- TODO one item, use metadata
		description = description,
		_tt_help = tt_help .. " " .. duration,
		inventory_image = "mcl_fireworks_rocket.png",
		stack_max = 64,
		on_use = function(itemstack, user, pointed_thing)
			local elytra = mcl_playerplus.elytra[user]
			if elytra.active and elytra.rocketing <= 0 then
				elytra.rocketing = duration
				if not minetest.is_creative_enabled(user:get_player_name()) then
					itemstack:take_item()
				end
				minetest.sound_play("mcl_fireworks_rocket", {pos = user:get_pos()})
			end
			return itemstack
		end,
		on_place = function(itemstack, user, pointed_thing)
			local pos = pointed_thing.above
-- 			pos.y = pos.y + 1
			vl_projectile.create("mcl_fireworks:rocket_" .. n, {
				pos=pos,
				velocity=vector.new(0,1,0)
			})
		end,
	})
end

register_rocket(1, 2.2, 10)
register_rocket(2, 4.5, 20)
register_rocket(3, 6, 30)
