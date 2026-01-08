local S = core.get_translator(core.get_current_modname())

local PARTICLE_DENSITY = 4
local PLAYER_HEIGHT_OFFSET = 1.64
local ACTIVE_REGION = 1.5
local mod_target = core.get_modpath("mcl_target")

local function lingering_image(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return "mcl_potions_splash_overlay.png^[colorize:"..colorstring..":"..tostring(opacity).."^mcl_potions_lingering_bottle.png"
end

local lingering_effect_at = {}

local function add_lingering_effect(pos, color, def, is_water, potency, plus)
	lingering_effect_at[pos] = {color = color, timer = 30, def = def, is_water = is_water, potency = potency, plus = plus}
end

local function linger_particles(pos, d, texture, color)
	minetest.add_particlespawner({
		amount = 10 * d^2,
		time = 1,
		minpos = {x=pos.x-d, y=pos.y+0.5, z=pos.z-d},
		maxpos = {x=pos.x+d, y=pos.y+1, z=pos.z+d},
		minvel = {x=-0.5, y=0, z=-0.5},
		maxvel = {x=0.5, y=0.5, z=0.5},
		minacc = {x=-0.2, y=0, z=-0.2},
		maxacc = {x=0.2, y=.05, z=0.2},
		minexptime = 1,
		maxexptime = 2,
		minsize = 2,
		maxsize = 4,
		collisiondetection = true,
		vertical = false,
		texture = texture.."^[colorize:"..color..":127",
	})
end

local lingering_timer = 0
core.register_globalstep(function(dtime)

	lingering_timer = lingering_timer + dtime
	if lingering_timer >= 1 then

		for pos, vals in pairs(lingering_effect_at) do

			vals.timer = vals.timer - lingering_timer
			local d = 4 * (vals.timer / 30.0)
			local texture
			if vals.is_water then
				texture = "mcl_particles_droplet_bottle.png"
			elseif vals.def.instant then
				texture = "mcl_particles_instant_effect.png"
			else
				texture = "mcl_particles_effect.png"
			end
			linger_particles(pos, PARTICLE_DENSITY, texture, vals.color)

-- 			-- Extinguish fire if water bottle
-- 			if vals.is_water then
-- 				if mcl_potions._extinguish_nearby_fire(pos, d) then
-- 					vals.timer = vals.timer - 3.25
-- 				end
-- 			end

			if vals.def.while_lingering and vals.def.while_lingering(pos, d, vals.potency+1) then
				vals.timer = vals.timer - 3.25
			end

			-- Affect players and mobs
			for _, obj in pairs(minetest.get_objects_inside_radius(pos, d)) do

				local entity = obj:get_luaentity()
				if obj:is_player() or entity and entity.is_mob then
					local applied = false
					if vals.def._effect_list then
						local ef_level
						local dur
						for name, details in pairs(vals.def._effect_list) do
							if details.uses_level then
								ef_level = details.level + details.level_scaling * (vals.potency)
							else
								ef_level = details.level
							end
							if details.dur_variable then
								dur = details.dur * math.pow(mcl_potions.PLUS_FACTOR, vals.plus)
								if vals.potency>0 and details.uses_level then
									dur = dur / math.pow(mcl_potions.POTENT_FACTOR, vals.potency)
								end
								dur = dur * mcl_potions.LINGERING_FACTOR
							else
								dur = details.dur
							end
							if details.effect_stacks then
								ef_level = ef_level + mcl_potions.get_effect_level(obj, name)
							end
							if mcl_potions.give_effect_by_level(name, obj, ef_level, dur) then
								applied = true
							end
						end
					end

					if vals.def.custom_effect
						and vals.def.custom_effect(obj, (vals.potency+1) * mcl_potions.LINGERING_FACTOR, vals.plus) then
							applied = true
					end

					if applied then vals.timer = vals.timer - 3.25 end
				end
			end

			if vals.timer <= 0 then
				lingering_effect_at[pos] = nil
			end

		end
		lingering_timer = 0
	end
end)



function mcl_potions.register_lingering(name, descr, color, def)
	local id = minetest.get_current_modname()..":"..name.."_lingering"
	local longdesc = def._longdesc
	if not def.no_effect then
		longdesc = S("A throwable potion that will shatter on impact, where it creates a magic cloud that lingers around for a while. Any player or mob inside the cloud will receive the potion's effect or set of effects, possibly repeatedly.")
		if def.longdesc then
			longdesc = longdesc .. "\n" .. def._longdesc
		end
	end
	local groups = {brewitem=1, bottle=1, ling_potion=1, _mcl_potion=1}
	if def.nocreative then groups.not_in_creative_inventory = 1 end
	minetest.register_craftitem(id, {
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
		inventory_image = lingering_image(color),
		groups = groups,
		on_use = function(item, placer, pointed_thing)
			mcl_potions.throw_splash(item, placer, vector.offset(placer:get_pos(), 0, PLAYER_HEIGHT_OFFSET, 0), placer:get_look_dir(), 10)
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				item:take_item()
			end
			return item
		end,
		_on_dispense = function(stack, dispenserpos, droppos, dropnode, dropdir)
			mcl_potions.throw_splash(stack, nil, dispenserpos + dropdir*0.51, dropdir, 22)
		end
	})

	local w = 0.7

	local particle_texture
	if name == "water" then
		particle_texture = "mcl_particles_droplet_bottle.png"
	else
		if def.instant then
			particle_texture = "mcl_particles_instant_effect.png"
		else
			particle_texture = "mcl_particles_effect.png"
		end
	end

	local function on_collide(self, pos)
		local potency = self._potency or 0
		local plus = self._plus or 0
		add_lingering_effect(pos, color, def, name == "water", potency, plus)
		linger_particles(pos, PARTICLE_DENSITY, particle_texture, color)
		if def.on_splash then def.on_splash(pos, potency+1) end
	end
	vl_projectile.register(id.."_flying",{
		textures = {lingering_image(color)},
		hp_max = 1,
		visual_size = {x=w/2,y=w/2},
		collisionbox = {-0.1,-0.1,-0.1,0.1,0.1,0.1},
		pointable = false,
		_vl_projectile = {
			behaviors = {
				vl_projectile.has_owner_grace_distance,
				vl_projectile.collides_with_entities,
				vl_projectile.collides_with_solids,
			},
			grace_distance = ACTIVE_REGION + PLAYER_HEIGHT_OFFSET + 0.1, -- safety margin
			on_collide_with_entity = on_collide,
			on_collide_with_solid = function(self, pos, node)
				if mod_target and node.name == "mcl_target:target_off" then
					mcl_target.hit(vector.round(pos), 0.4) --4 redstone ticks
				end

				on_collide(self, pos)
			end,
			sounds = {
				on_collision = {"mcl_potions_breaking_glass", {max_hear_distance = 16, gain = 1}},
			},
		},
	})
end
