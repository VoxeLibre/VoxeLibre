local S = minetest.get_translator("mcl_potions")

local splash_image = function(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return "mcl_potions_splash_overlay.png^[colorize:"..colorstring..":"..tostring(opacity).."^mcl_potions_splash_bottle.png"
end


local function register_splash(name, descr, color, def)

    local id = "mcl_potions:"..name.."_splash"
    minetest.register_craftitem(id, {
        description = descr,
		_tt_help = def.tt,
        inventory_image = splash_image(color),
		groups = {brewitem=1, not_in_creative_inventory=0},
        on_use = function(item, placer, pointed_thing)
            local velocity = 10
            local dir = placer:get_look_dir();
            local pos = placer:get_pos();
            local obj = minetest.add_entity({x=pos.x+dir.x,y=pos.y+2+dir.y,z=pos.z+dir.z}, id.."_flying")
            obj:set_velocity({x=dir.x*velocity,y=dir.y*velocity,z=dir.z*velocity})
            obj:set_acceleration({x=dir.x*-3, y=-9.8, z=dir.z*-3})
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				item:take_item()
			end
            return item
        end,
		stack_max = 1,
		_on_dispense = function(stack, dispenserpos, droppos, dropnode, dropdir)
			local s_pos = vector.add(dispenserpos, vector.multiply(dropdir, 0.51))
			local obj = minetest.add_entity({x=s_pos.x+dropdir.x,y=s_pos.y+dropdir.y,z=s_pos.z+dropdir.z}, id.."_flying")
			local velocity = 22
			obj:set_velocity({x=dropdir.x*velocity,y=dropdir.y*velocity,z=dropdir.z*velocity})
			obj:set_acceleration({x=dropdir.x*-3, y=-9.8, z=dropdir.z*-3})
		end
    })

    local w = 0.7

    minetest.register_entity(id.."_flying",{
        textures = {splash_image(color)},
		hp_max = 1,
		visual_size = {x=w/2,y=w/2},
		collisionbox = {0,0,0,0,0,0},
        on_step = function(self, dtime)
          local pos = self.object:getpos()
          local node = minetest.get_node(pos)
          local n = node.name
					local d = 2
					local redux_map = {7/8,0.5,0.25}
          			if n ~= "air" and n ~= "mcl_portals:portal" and n ~= "mcl_portals:portal_end" or mcl_potions.is_obj_hit(self, pos) then
						minetest.sound_play("mcl_potions_breaking_glass", {pos = pos, max_hear_distance = 16, gain = 1})
						minetest.add_particlespawner({
																				amount = 50,
																				time = 2,
																				minpos = {x=pos.x-d, y=pos.y+0.5, z=pos.z-d},
																				maxpos = {x=pos.x+d, y=pos.y+d, z=pos.z+d},
																				minvel = {x=-1, y=0, z=-1},
																				maxvel = {x=1, y=0.5, z=1},
																				minacc = {x=-0.5, y=0, z=-0.5},
																				maxacc = {x=0.5, y=.2, z=0.5},
																				minexptime = 1,
																				maxexptime = 3,
																				minsize = 2,
																				maxsize = 4,
																				collisiondetection = true,
																				vertical = false,
																				texture = "mcl_potions_sprite.png^[colorize:"..color..":127",
																			})
            			self.object:remove()
						for _,obj in pairs(minetest.get_objects_inside_radius(pos, 4)) do

							local entity = obj:get_luaentity()
							if obj:is_player() or entity._cmi_is_mob then

								local pos2 = obj:get_pos()
								local rad = math.floor(math.sqrt((pos2.x-pos.x)^2 + (pos2.y-pos.y)^2 + (pos2.z-pos.z)^2))
								if rad > 0 then def.potion_fun(obj, redux_map[rad]) else def.potion_fun(obj, 1) end

							end
						end

					end
        end,
    })
end

local function time_string(dur)
	return math.floor(dur/60)..string.format(":%02d",math.floor(dur % 60))
end

local splash_DUR = mcl_potions.DURATION*mcl_potions.SPLASH_FACTOR
local splash_DUR_2 = mcl_potions.DURATION_2*mcl_potions.SPLASH_FACTOR
local splash_DUR_pl = mcl_potions.DURATION_PLUS*mcl_potions.SPLASH_FACTOR

register_splash("water", S("Splash Water Bottle"), "#0000FF", {
    potion_fun = function(player, redx)  end,
	tt = S("No effect")
})

register_splash("river_water", S("Splash River Water Bottle"), "#0044FF", {
    potion_fun = function(player, redx)  end,
	tt = S("No effect")
})

register_splash("awkward", S("Awkward Splash Potion"), "#0000FF", {
    potion_fun = function(player, redx)  end,
	tt = S("No effect")
})

register_splash("mundane", S("Mundane Splash Potion"), "#0000FF", {
    potion_fun = function(player, redx)  end,
	tt = S("No effect")
})

register_splash("thick", S("Thick Splash Potion"), "#0000FF", {
    potion_fun = function(player, redx)  end,
		tt = S("No effect")
})

register_splash("healing", S("Healing Splash Potion"), "#AA0000", {
    potion_fun = function(player, redx) mcl_potions.healing_func(player, 3*redx) end,
		tt = S("+3 HP")
})

register_splash("healing_2", S("Healing Splash Potion II"), "#DD0000", {
    potion_fun = function(player, redx) mcl_potions.healing_func(player, 6*redx) end,
		tt = S("+6 HP")
})

register_splash("harming", S("Harming Splash Potion"), "#660099", {
    potion_fun = function(player, redx) mcl_potions.healing_func(player, -6*redx) end,
		tt = S("-4 HP")
})

register_splash("harming_2", S("Harming Splash Potion II"), "#330066", {
    potion_fun = function(player, redx) mcl_potions.healing_func(player, -12*redx) end,
		tt = S("-6 HP")
})

register_splash("leaping", S("Leaping Splash Potion"), "#00CC33", {
		potion_fun = function(player, redx) mcl_potions.leaping_func(player, 1.2, splash_DUR*redx) end,
		tt = S("120% | @1", time_string(splash_DUR))

})

register_splash("leaping_2", S("Leaping Splash Potion II"), "#00EE33", {
		potion_fun = function(player, redx) mcl_potions.leaping_func(player, 1.4, splash_DUR_2*redx) end,
		tt = S("140% | @1", time_string(splash_DUR_2))
})

register_splash("leaping_plus", S("Leaping Splash Potion +"), "#00DD33", {
		potion_fun = function(player, redx) mcl_potions.leaping_func(player, 1.2, splash_DUR_pl*redx) end,
		tt = S("120% | @1", time_string(splash_DUR_pl))
})

register_splash("swiftness", S("Swiftness Splash Potion"), "#009999", {
		potion_fun = function(player, redx) mcl_potions.swiftness_func(player, 1.2, splash_DUR*redx) end,
		tt = S("120% | @1", time_string(splash_DUR))
})

register_splash("swiftness_2", S("Swiftness Splash Potion II"), "#00BBBB", {
		potion_fun = function(player, redx) mcl_potions.swiftness_func(player, 1.4, splash_DUR_2*redx) end,
		tt = S("140% | @1", time_string(splash_DUR_2))
})

register_splash("swiftness_plus", S("Swiftness Splash Potion +"), "#00BBBB", {
		potion_fun = function(player, redx) mcl_potions.swiftness_func(player, 1.2, splash_DUR_pl*redx) end,
		tt = S("120% | @1", time_string(splash_DUR_2))
})

register_splash("slowness", S("Slowness Splash Potion"), "#000080", {
		potion_fun = function(player, redx) mcl_potions.swiftness_func(player, 0.85, splash_DUR*mcl_potions.INV_FACTOR*redx) end,
		tt = S("85% | @1", time_string(splash_DUR*mcl_potions.INV_FACTOR))
})

register_splash("slowness_2", S("Slowness Splash Potion IV"), "#000080", {
		potion_fun = function(player, redx) mcl_potions.swiftness_func(player, 0.4, 20*mcl_potions.INV_FACTOR*redx) end,
		tt = S("40% | @1", time_string(20*mcl_potions.INV_FACTOR))
})

register_splash("slowness_plus", S("Slowness Splash Potion +"), "#000066", {
		potion_fun = function(player, redx) mcl_potions.swiftness_func(player, 0.85, splash_DUR_pl*mcl_potions.INV_FACTOR*redx) end,
		tt = S("85% | @1", time_string(splash_DUR_pl*mcl_potions.INV_FACTOR))
})

register_splash("poison", S("Poison Splash Potion"), "#335544", {
		potion_fun = function(player, redx) mcl_potions.poison_func(player, 2.5, splash_DUR*mcl_potions.INV_FACTOR^2*redx) end,
		tt = S("-1 HP / 2.5s | @1", time_string(splash_DUR*mcl_potions.INV_FACTOR^2))
})

register_splash("poison_2", S("Poison Splash Potion II"), "#446655", {
		potion_fun = function(player, redx) mcl_potions.poison_func(player, 1.2, splash_DUR_2*mcl_potions.INV_FACTOR^2*redx) end,
		tt = S("-1 HP / 1.2s | @1", time_string(splash_DUR_2*mcl_potions.INV_FACTOR^2))
})

register_splash("poison_plus", S("Poison Splash Potion +"), "#557766", {
		potion_fun = function(player, redx) mcl_potions.poison_func(player, 2.5, splash_DUR*mcl_potions.INV_FACTOR*redx) end,
		tt = S("-1 HP / 2.5s | @1", time_string(splash_DUR_pl*mcl_potions.INV_FACTOR^2))
})

register_splash("regeneration", S("Regeneration Splash Potion"), "#A52BB2", {
		potion_fun = function(player, redx) mcl_potions.regeneration_func(player, 2.5, splash_DUR*redx) end,
		tt = S("+1 HP / 2.5s | @1", time_string(splash_DUR))
})

register_splash("regeneration_2", S("Regeneration Splash Potion II"), "#B52CC2", {
		potion_fun = function(player, redx) mcl_potions.regeneration_func(player, 1.2, (splash_DUR_2 + 1)*redx) end,
		tt = S("+1 HP / 1.2s | @1", time_string(splash_DUR_2 + 1))
})

register_splash("regeneration_plus", S("Regeneration Splash Potion +"), "#C53DD3", {
		potion_fun = function(player, redx) mcl_potions.regeneration_func(player, 2.5, splash_DUR_pl*redx) end,
		tt = S("+1 HP / 2.5s | @1", time_string(splash_DUR_pl))
})

register_splash("invisibility", S("Invisibility Splash Potion"), "#B0B0B0", {
		potion_fun = function(player, redx) mcl_potions.invisiblility_func(player, nil, splash_DUR*redx) end,
		tt = time_string(splash_DUR)
})

register_splash("invisibility_plus", S("Invisibility Splash Potion +"), "#A0A0A0", {
		potion_fun = function(player, redx) mcl_potions.invisiblility_func(player, nil, splash_DUR_pl*redx) end,
		tt = time_string(splash_DUR_pl)
})

-- register_splash("weakness", S("Weakness Splash Potion"), "#6600AA", {
-- 	potion_fun = function(player, redx) mcl_potions.weakness_func(player, -4, splash_DUR*mcl_potions.INV_FACTOR*redx) end,
-- 	-- TODO: Fix tooltip
-- 	tt = time_string(splash_DUR*mcl_potions.INV_FACTOR)
-- })
--
-- register_splash("weakness_plus", S("Weakness Splash Potion +"), "#7700BB", {
-- 	potion_fun = function(player, redx) mcl_potions.weakness_func(player, -4, splash_DUR_pl*mcl_potions.INV_FACTOR*redx) end,
-- 	-- TODO: Fix tooltip
-- 	tt = time_string(splash_DUR_pl*mcl_potions.INV_FACTOR)
-- })
--
-- register_splash("strength", S("Strength Splash Potion"), "#D444D4", {
-- 	potion_fun = function(player, redx) mcl_potions.strength_func(player, 3, splash_DUR*redx) end,
-- 	-- TODO: Fix tooltip
-- 	tt = time_string(splash_DUR)
-- })
--
-- register_splash("strength_2", S("Strength Splash Potion II"), "#D444F4", {
-- 	potion_fun = function(player, redx) mcl_potions.strength_func(player, 6, splash_DUR_2*redx) end,
-- 	-- TODO: Fix tooltip
-- 	tt = time_string(splash_DUR_2)
-- })
--
-- register_splash("strength_plus", S("Strength Splash Potion +"), "#D444E4", {
-- 	potion_fun = function(player, redx) mcl_potions.strength_func(player, 3, splash_DUR_pl*redx) end,
-- 	-- TODO: Fix tooltip
-- 	tt = time_string(splash_DUR_pl)
-- })

register_splash("water_breathing", S("Water Breathing Splash Potion"), "#0000AA", {
	potion_fun = function(player, redx) mcl_potions.water_breathing_func(player, nil, splash_DUR*redx) end,
	tt = time_string(splash_DUR)
})

register_splash("water_breathing_plus", S("Water Breathing Splash Potion +"), "#0000CC", {
	potion_fun = function(player, redx) mcl_potions.water_breathing_func(player, nil, splash_DUR_pl*redx) end,
	tt = time_string(splash_DUR_pl)
})

register_splash("fire_resistance", S("Fire Resistance Splash Potion"), "#D0A040", {
	potion_fun = function(player, redx) mcl_potions.fire_resistance_func(player, nil, splash_DUR*redx) end,
	tt = time_string(splash_DUR)
})

register_splash("fire_resistance_plus", S("Fire Resistance Splash Potion +"), "#E0B050", {
	potion_fun = function(player, redx) mcl_potions.fire_resistance_func(player, nil, splash_DUR_pl*redx) end,
	tt = time_string(splash_DUR_pl)
})

register_splash("night_vision", S("Night Vision Splash Potion"), "#1010AA", {
	potion_fun = function(player, redx) mcl_potions.night_vision_func(player, nil, splash_DUR*redx) end,
	tt = time_string(splash_DUR)
})

register_splash("night_vision_plus", S("Night Vision Splash Potion +"), "#2020BA", {
	potion_fun = function(player, redx) mcl_potions.night_vision_func(player, nil, splash_DUR_pl*redx) end,
	tt = time_string(splash_DUR_pl)
})
