local S = core.get_translator(core.get_current_modname())
local GRAVITY = tonumber(core.settings:get("movement_gravity"))
local REDUX_MAP = {7/8,0.5,0.25}
local PLAYER_HEIGHT_OFFSET = 1.64
local ACTIVE_REGION = 1.5
local PARTICLE_DIAMETER = 0.1
local PARTICLE_MIN_VELOCITY = vector.new(-2, 0, -2)
local PARTICLE_MAX_VELOCITY = vector.new( 2, 2,  2)

local mod_target = minetest.get_modpath("mcl_target")

local function splash_image(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return "mcl_potions_splash_overlay.png^[colorize:"..colorstring..":"..tostring(opacity).."^mcl_potions_splash_bottle.png"
end

local function throw_splash(item, thrower, pos, dir, velocity)
	minetest.sound_play("mcl_throwing_throw", {pos = pos, gain = 0.4, max_hear_distance = 16}, true)
	if type(item) == "string" then item = ItemStack(item) end
	local obj = vl_projectile.create(item:get_name().."_flying",{
		pos = vector.offset(pos, dir.x, dir.y, dir.z),
		owner = thrower,
		dir = dir,
		velocity = velocity,
	})
	local ent = obj:get_luaentity()
	ent._potency = item:get_meta():get_int("mcl_potions:potion_potent")
	ent._plus = item:get_meta():get_int("mcl_potions:potion_plus")
	ent._effect_list = item:get_definition()._effect_list
end
mcl_potions.throw_splash = throw_splash

function mcl_potions.register_splash(name, descr, color, def)
	local id = minetest.get_current_modname()..":"..name.."_splash"
	local longdesc = def._longdesc
	if not def.no_effect then
		longdesc = S("A throwable potion that will shatter on impact, where it gives all nearby players and mobs a status effect or a set of status effects.")
		if def._longdesc then
			longdesc = longdesc .. "\n" .. def._longdesc
		end
	end
	local groups = {brewitem=1, bottle=1, splash_potion=1, _mcl_potion=1}
	if def.nocreative then groups.not_in_creative_inventory = 1 end

	core.register_craftitem(id, {
		description = descr,
		_tt_help = def._tt,
		_dynamic_tt = def._dynamic_tt,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = S("Use the “Punch” key to throw it."),
		stack_max = def.stack_max,
		_effect_list = def._effect_list,
		uses_level = def.uses_level,
		has_potent = def.has_potent,
		has_plus = def.has_plus,
		_default_potent_level = def._default_potent_level,
		_default_extend_level = def._default_extend_level,
		inventory_image = splash_image(color),
		groups = groups,
		on_use = function(item, placer, pointed_thing)
			throw_splash(item, placer, vector.offset(placer:get_pos(), 0, PLAYER_HEIGHT_OFFSET, 0), placer:get_look_dir(), 10)
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				item:take_item()
			end
			return item
		end,
		_on_dispense = function(stack, dispenserpos, droppos, dropnode, dropdir)
			throw_splash(stack, nil, dispenserpos + dropdir*0.51, dropdir, 22)
		end
	})

	local w = 0.7

	-- Precompute particle texture and acceleration
	local particle_texture, particle_acc
	if name == "water" then
		particle_texture = "mcl_particles_droplet_bottle.png"
		particle_acc = {x=0, y=-GRAVITY, z=0}
	else
		if def.instant then
			particle_texture = "mcl_particles_instant_effect.png"
		else
			particle_texture = "mcl_particles_effect.png"
		end
		particle_acc = {x=0, y=0, z=0}
	end
	particle_texture = particle_texture.."^[colorize:"..color..":127"

	local function splash_effects(self, pos, def, range)
		core.add_particlespawner({
			amount = 50,
			time = 0.1,
			minpos = vector.offset(pos, -PARTICLE_DIAMETER, 0.5, -PARTICLE_DIAMETER),
			maxpos = vector.offset(pos,  PARTICLE_DIAMETER, 0.5,  PARTICLE_DIAMETER),
			minvel = PARTICLE_MIN_VELOCITY,
			maxvel = PARTICLE_MAX_VELOCITY,
			minacc = particle_acc,
			maxacc = particle_acc,
			minexptime = 0.5,
			maxexptime = 1.25,
			minsize = 1,
			maxsize = 2,
			collisiondetection = true,
			vertical = false,
			texture = particle_texture,
		})

		local potency = self._potency or 0
		local plus = self._plus or 0

		if def.on_splash then def.on_splash(pos, potency+1) end

		for _,obj in pairs(core.get_objects_inside_radius(pos, range)) do
			-- Make sure the potion can interact with this object
			local entity = obj:get_luaentity()
			if obj:is_player() or entity and entity.is_mob then
				local pos2 = obj:get_pos()
				local rad = math.floor(math.sqrt((pos2.x-pos.x)^2 + (pos2.y-pos.y)^2 + (pos2.z-pos.z)^2))

				-- Apply effect list
				if def._effect_list then
					for name, details in pairs(def._effect_list) do
						local ef_level
						local dur

						if details.uses_level then
							ef_level = details.level + details.level_scaling * potency
						else
							ef_level = details.level
						end

						if details.dur_variable then
							dur = details.dur * math.pow(mcl_potions.PLUS_FACTOR, plus)
							if potency>0 and details.uses_level then
								dur = dur / math.pow(mcl_potions.POTENT_FACTOR, potency)
							end
							dur = dur * mcl_potions.SPLASH_FACTOR
						else
							dur = details.dur
						end

						if details.effect_stacks then
							ef_level = ef_level + mcl_potions.get_effect_level(obj, name)
						end

						if rad > 0 then
							mcl_potions.give_effect_by_level(name, obj, ef_level, REDUX_MAP[rad]*dur)
						else
							mcl_potions.give_effect_by_level(name, obj, ef_level, dur)
						end
					end
				end

				if def.custom_effect then
					local power = (potency+1) * mcl_potions.SPLASH_FACTOR
					if rad > 0 then
						def.custom_effect(obj, REDUX_MAP[rad] * power, plus)
					else
						def.custom_effect(obj, power, plus)
					end
				end
			end
		end
	end

	vl_projectile.register(id.."_flying",{
		textures = {splash_image(color)},
		hp_max = 1,
		visual_size = {x=w/2,y=w/2},
		collisionbox = {-0.1,-0.1,-0.1,0.1,0.1,0.1},
		_vl_projectile = {
			behaviors = {
				vl_projectile.has_owner_grace_distance,
				vl_projectile.collides_with_entities,
				vl_projectile.collides_with_solids,
			},
			grace_distance = ACTIVE_REGION + PLAYER_HEIGHT_OFFSET + 0.1, -- safety margin
			on_collide_with_solid = function(self, pos, node)
				splash_effects(self, pos, def, 4)

				if mod_target and node.name == "mcl_target:target_off" then
					mcl_target.hit(pos, 0.4) -- 4 redstone ticks
				end
			end,
			on_collide_with_entity = function(self, pos, obj)
				splash_effects(self, pos, def, 4)
			end,
			sounds = {
				on_collision = {"mcl_potions_breaking_glass", {max_hear_distance = 16, gain = 1}, true},
			},
		},
		pointable = false,
	})
end

