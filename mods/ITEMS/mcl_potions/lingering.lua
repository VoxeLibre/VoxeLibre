local lingering_image = function(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return "mcl_potions_splash_overlay.png^[colorize:"..colorstring..":"..tostring(opacity).."^mcl_potions_lingering_bottle.png"
end


local lingering_effect_at = {}

local function add_lingering_effect(pos, color, def)

	lingering_effect_at[pos] = {color = color, timer = 30, def = def}

end


local lingering_timer = 0
minetest.register_globalstep(function(dtime)

	lingering_timer = lingering_timer + dtime
	if lingering_timer >= 1 then

		for pos, vals in pairs(lingering_effect_at) do

			vals.timer = vals.timer - lingering_timer
			local d = 4 * (vals.timer / 30.0)

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
											texture = "mcl_potions_sprite.png^[colorize:"..vals.color..":127",
										})

			for _, obj in pairs(minetest.get_objects_inside_radius(pos, d)) do

				local entity = obj:get_luaentity()
				if obj:is_player() or entity._cmi_is_mob then

					vals.def.potion_fun(obj)
					vals.timer = vals.timer / 2

				end
			end

			if vals.timer <= 0 then lingering_effect_at[pos] = nil end

		end
		lingering_timer = 0
	end
end)



local function register_lingering(name, descr, color, def)

    local id = "mcl_potions:"..name.."_lingering"
    minetest.register_craftitem(id, {
        description = descr,
		_tt_help = def.tt,
        inventory_image = lingering_image(color),
		groups = {brewitem=1, not_in_creative_inventory=0},
        on_use = function(item, placer, pointed_thing)
            local velocity = 10
            local dir = placer:get_look_dir();
            local pos = placer:getpos();
            local obj = minetest.add_entity({x=pos.x+dir.x,y=pos.y+2+dir.y,z=pos.z+dir.z}, id.."_flying")
            obj:setvelocity({x=dir.x*velocity,y=dir.y*velocity,z=dir.z*velocity})
            obj:setacceleration({x=0, y=-9.8, z=0})
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
			end
            return item
        end,
		stack_max = 1,
    })

    local w = 0.7

    minetest.register_entity(id.."_flying",{
        textures = {lingering_image(color)},
		hp_max = 1,
		visual_size = {x=w/2,y=w/2},
		collisionbox = {0,0,0,0,0,0},
        on_step = function(self, dtime)
          local pos = self.object:getpos()
          local node = minetest.get_node(pos)
          local n = node.name
					local d = 4
          			if n ~= "air" and n ~= "mcl_portals:portal" and n ~= "mcl_portals:portal_end" or mcl_potions.is_obj_hit(self, pos) then
						minetest.sound_play("mcl_potions_breaking_glass", {pos = pos, max_hear_distance = 16, gain = 1})
						add_lingering_effect(pos, color, def)
						minetest.add_particlespawner({
														amount = 40,
														time = 1,
														minpos = {x=pos.x-d, y=pos.y+0.5, z=pos.z-d},
														maxpos = {x=pos.x+d, y=pos.y+1, z=pos.z+d},
														minvel = {x=-0.5, y=0, z=-0.5},
														maxvel = {x=0.5, y=0.5, z=0.5},
														minacc = {x=-0.2, y=0, z=-0.2},
														maxacc = {x=0.2, y=.05, z=0.2},
														minexptime = 1,
														maxexptime = 2,
														minsize = 1,
														maxsize = 2,
														collisiondetection = true,
														vertical = false,
														texture = "mcl_potions_sprite.png^[colorize:"..color..":127",
													})
            		 	self.object:remove()
					end
        end,
    })
end

local function time_string(dur)
	return math.floor(dur/60)..string.format(":%02d",math.floor(dur % 60))
end

register_lingering("water", "Lingering Potion", "#0000FF", {
    potion_fun = function(player)  end,
	tt = "No effect"
})

register_lingering("river_water", "Lingering Potion", "#0000FF", {
    potion_fun = function(player)  end,
	tt = "No effect"
})

register_lingering("awkward", "Lingering Awkward Potion", "#0000FF", {
    potion_fun = function(player)  end,
	tt = "No effect"
})

register_lingering("mundane", "Lingering Mundane Potion", "#0000FF", {
    potion_fun = function(player)  end,
	tt = "No effect"
})

register_lingering("thick", "Lingering Thick Potion", "#0000FF", {
    potion_fun = function(player)  end,
	tt = "No effect"
})

register_lingering("healing", "Lingering Healing", "#AA0000", {
    potion_fun = function(player) player:set_hp(player:get_hp() + 4*0.5) end,
	tt = "+1 heart"
})

register_lingering("healing_2", "Lingering Healing II", "#DD0000", {
    potion_fun = function(player) player:set_hp(player:get_hp() + 8*0.5) end,
	tt = "+2 hearts"
})

register_lingering("harming", "Lingering Harming", "#660099", {
    potion_fun = function(player) mcl_potions.healing_func(player, -6*0.5) end,
	tt = "-1.5 hearts"
})

register_lingering("harming_2", "Lingering Harming II", "#330066", {
    potion_fun = function(player) mcl_potions.healing_func(player, -12*0.5) end,
	tt = "-3 hearts"
})

register_lingering("leaping", "Lingering Leaping", "#00CC33", {
		potion_fun = function(player) mcl_potions.leaping_func(player, 1.2, mcl_potions.DURATION*0.25) end,
		tt = "120% | "..time_string(mcl_potions.DURATION*0.25)
})

register_lingering("leaping_2", "Lingering Leaping II", "#00EE33", {
		potion_fun = function(player) mcl_potions.leaping_func(player, 1.4, mcl_potions.DURATION_2*0.25) end,
		tt = "140% | "..time_string(mcl_potions.DURATION_2*0.25)
})

register_lingering("leaping_plus", "Lingering Leaping +", "#00DD33", {
		potion_fun = function(player) mcl_potions.leaping_func(player, 1.2, mcl_potions.DURATION_PLUS*0.25) end,
		tt = "120% | "..time_string(mcl_potions.DURATION_PLUS*0.25)
})

register_lingering("swiftness", "Lingering Swiftness", "#009999", {
		potion_fun = function(player) mcl_potions.swiftness_func(player, 1.2, mcl_potions.DURATION*0.25) end,
		tt = "120% | "..time_string(mcl_potions.DURATION*0.25)
})

register_lingering("swiftness_2", "Lingering Swiftness II", "#00BBBB", {
		potion_fun = function(player) mcl_potions.swiftness_func(player, 1.4, mcl_potions.DURATION_2*0.25) end,
		tt = "140% | "..time_string(mcl_potions.DURATION_2*0.25)
})

register_lingering("swiftness_plus", "Lingering Swiftness +", "#00BBBB", {
		potion_fun = function(player) mcl_potions.swiftness_func(player, 1.2, mcl_potions.DURATION_PLUS*0.25) end,
		tt = "120% | "..time_string(mcl_potions.DURATION_PLUS*0.25)
})

register_lingering("slowness", "Lingering Slowness", "#000080", {
		potion_fun = function(player) mcl_potions.swiftness_func(player, 0.85, mcl_potions.DURATION*mcl_potions.INV_FACTOR*0.25) end,
		tt = "85% | "..time_string(mcl_potions.DURATION*mcl_potions.INV_FACTOR*0.25)
})

register_lingering("slowness_plus", "Lingering Slowness +", "#000066", {
		potion_fun = function(player) mcl_potions.swiftness_func(player, 0.85, mcl_potions.DURATION_PLUS*mcl_potions.INV_FACTOR*0.25) end,
		tt = "85% | "..time_string(mcl_potions.DURATION_PLUS*mcl_potions.INV_FACTOR*0.25)
})

register_lingering("slowness_2", "Lingering Slowness IV", "#000066", {
		potion_fun = function(player) mcl_potions.swiftness_func(player, 0.4, 20*0.25) end,
		tt = "40% | "..time_string(20*0.25)
})

register_lingering("poison", "Lingering Poison", "#335544", {
		potion_fun = function(player) mcl_potions.poison_func(player, 2.5, 45*0.25) end,
		tt = "-1/2 heart / 2.5sec | "..time_string(45*0.25)
})

register_lingering("poison_2", "Lingering Poison II", "#446655", {
		potion_fun = function(player) mcl_potions.poison_func(player, 1.2, 21*0.25) end,
		tt = "-1/2 heart / 1.2sec | "..time_string(21*0.25)
})

register_lingering("poison_plus", "Lingering Poison +", "#557766", {
		potion_fun = function(player) mcl_potions.poison_func(player, 2.5, 90*0.25) end,
		tt = "-1/2 heart / 2.5sec | "..time_string(90*0.25)
})

register_lingering("regeneration", "Lingering Regeneration", "#A52BB2", {
		potion_fun = function(player) mcl_potions.regeneration_func(player, 2.5, 45*0.25) end,
		tt = "1/2 heart / 2.5sec | "..time_string(45*0.25)
})

register_lingering("regeneration_2", "Lingering Regeneration II", "#B52CC2", {
		potion_fun = function(player) mcl_potions.regeneration_func(player, 1.2, 22*0.25) end,
		tt = "1/2 heart / 1.2sec | "..time_string(22*0.25)
})

register_lingering("regeneration_plus", "Lingering Regeneration +", "#C53DD3", {
		potion_fun = function(player) mcl_potions.regeneration_func(player, 2.5, 90*0.25) end,
		tt = "1/2 heart / 2.5sec | "..time_string(90*0.25)
})

register_lingering("invisibility", "Lingering Invisibility", "#B0B0B0", {
	potion_fun = function(player) mcl_potions.invisiblility_func(player, mcl_potions.DURATION*0.25) end,
	tt = time_string(mcl_potions.DURATION*0.25)
})

register_lingering("invisibility_plus", "Lingering Invisibility +", "#A0A0A0", {
	potion_fun = function(player) mcl_potions.invisiblility_func(player, mcl_potions.DURATION_PLUS*0.25) end,
	tt = time_string(mcl_potions.DURATION_PLUS*0.25)
})

register_lingering("weakness", "Lingering Weakness", "#6600AA", {
	potion_fun = function(player) mcl_potions.weakness_func(player, -4, mcl_potions.DURATION*mcl_potions.INV_FACTOR*0.25) end,
	tt = "No effect | "..time_string(mcl_potions.DURATION*mcl_potions.INV_FACTOR*0.25)
})

register_lingering("weakness_plus", "Lingering Weakness +", "#7700BB", {
	potion_fun = function(player) mcl_potions.weakness_func(player, -4, mcl_potions.DURATION_PLUS*mcl_potions.INV_FACTOR*0.25) end,
	tt = "No effect | "..time_string(mcl_potions.DURATION*mcl_potions.INV_FACTOR*0.25)
})

register_lingering("fire_resistance", "Lingering Fire Resistance", "#D0A040", {
	potion_fun = function(player) mcl_potions.fire_resistance_func(player, mcl_potions.DURATION) end,
	tt = time_string(mcl_potions.DURATION)
})

register_lingering("fire_resistance_plus", "Lingering Fire Resistance +", "#E0B050", {
	potion_fun = function(player) mcl_potions.fire_resistance_func(player, mcl_potions.DURATION_PLUS) end,
	tt = time_string(mcl_potions.DURATION_PLUS)
})

register_lingering("strength", "Lingering Strength", "#D444D4", {
	potion_fun = function(player) mcl_potions.strength_func(player, 3, mcl_potions.DURATION) end,
	tt = "No effect | "..time_string(mcl_potions.DURATION)
})

register_lingering("strength_2", "Lingering Strength II", "#D444F4", {
	potion_fun = function(player) mcl_potions.strength_func(player, 6, smcl_potions.DURATION_2) end,
	tt = "No effect | "..time_string(mcl_potions.DURATION_2)
})

register_lingering("strength_plus", "Lingering Strength +", "#D444E4", {
	potion_fun = function(player) mcl_potions.strength_func(player, 3, mcl_potions.DURATION_PLUS) end,
	tt = "No effect | "..time_string(mcl_potions.DURATION_PLUS)
})
