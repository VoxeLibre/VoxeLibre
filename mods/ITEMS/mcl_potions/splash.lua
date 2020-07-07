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
            obj:set_acceleration({x=0, y=-9.8, z=0})
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
			end
            return item
        end,
				stack_max = 1,
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

register_splash("water", "Splash Water", "#0000FF", {
    potion_fun = function(player, redx)  end,
	tt = "No effect"
})

register_splash("river_water", "Splash River Water", "#0000FF", {
    potion_fun = function(player, redx)  end,
	tt = "No effect"
})

register_splash("awkward", "Splash Awkward Potion", "#0000FF", {
    potion_fun = function(player, redx)  end,
	tt = "No effect"
})

register_splash("mundane", "Splash Mundane Potion", "#0000FF", {
    potion_fun = function(player, redx)  end,
	tt = "No effect"
})

register_splash("thick", "Splash Thick Potion", "#0000FF", {
    potion_fun = function(player, redx)  end,
	tt = "No effect"
})

register_splash("healing", "Splash Healing", "#AA0000", {
    potion_fun = function(player, redx) mcl_potions.healing_func(player, 3*redx) end,
	tt = "1.5 hearts"
})

register_splash("healing_2", "Splash Healing II", "#DD0000", {
    potion_fun = function(player, redx) mcl_potions.healing_func(player, 6*redx) end,
	tt = "3 hearts"
})

register_splash("harming", "Splash Harming", "#660099", {
    potion_fun = function(player, redx) mcl_potions.healing_func(player, -6*redx) end,
	tt = "-2 hearts"
})

register_splash("harming_2", "Splash Harming II", "#330066", {
    potion_fun = function(player, redx) mcl_potions.healing_func(player, -12*redx) end,
	tt = "-3 hearts"
})

register_splash("leaping", "Splash Leaping", "#00CC33", {
		potion_fun = function(player, redx) mcl_potions.leaping_func(player, 1.2, splash_DUR*redx) end,
		tt = "120% | "..time_string(splash_DUR)

})

register_splash("leaping_2", "Splash Leaping II", "#00EE33", {
		potion_fun = function(player, redx) mcl_potions.leaping_func(player, 1.4, splash_DUR_2*redx) end,
		tt = "140% | "..time_string(splash_DUR_2)
})

register_splash("leaping_plus", "Splash Leaping +", "#00DD33", {
		potion_fun = function(player, redx) mcl_potions.leaping_func(player, 1.2, splash_DUR_pl*redx) end,
		tt = "120% | "..time_string(splash_DUR_pl)
})

register_splash("swiftness", "Splash Swiftness", "#009999", {
		potion_fun = function(player, redx) mcl_potions.swiftness_func(player, 1.2, splash_DUR*redx) end,
		tt = "120% | "..time_string(splash_DUR)
})

register_splash("swiftness_2", "Splash Swiftness II", "#00BBBB", {
		potion_fun = function(player, redx) mcl_potions.swiftness_func(player, 1.4, splash_DUR_2*redx) end,
		tt = "140% | "..time_string(splash_DUR_2)
})

register_splash("swiftness_plus", "Splash Swiftness +", "#00BBBB", {
		potion_fun = function(player, redx) mcl_potions.swiftness_func(player, 1.2, splash_DUR_pl*redx) end,
		tt = "120% | "..time_string(splash_DUR_2)
})

register_splash("slowness", "Splash Slowness", "#000080", {
		potion_fun = function(player, redx) mcl_potions.swiftness_func(player, 0.85, splash_DUR*mcl_potions.INV_FACTOR*redx) end,
		tt = "85% | "..time_string(splash_DUR*mcl_potions.INV_FACTOR)
})

register_splash("slowness_2", "Splash Slowness IV", "#000080", {
		potion_fun = function(player, redx) mcl_potions.swiftness_func(player, 0.4, 20*mcl_potions.INV_FACTOR*redx) end,
		tt = "40% | "..time_string(20*mcl_potions.INV_FACTOR)
})

register_splash("slowness_plus", "Splash Slowness +", "#000066", {
		potion_fun = function(player, redx) mcl_potions.swiftness_func(player, 0.85, splash_DUR_pl*mcl_potions.INV_FACTOR*redx) end,
		tt = "85% | "..time_string(splash_DUR_pl*mcl_potions.INV_FACTOR)
})

register_splash("poison", "Splash Poison", "#335544", {
		potion_fun = function(player, redx) mcl_potions.poison_func(player, 2.5, splash_DUR*mcl_potions.INV_FACTOR^2*redx) end,
		tt = "-1/2 heart / 2.5sec | "..time_string(splash_DUR*mcl_potions.INV_FACTOR^2)
})

register_splash("poison_2", "Splash Poison II", "#446655", {
		potion_fun = function(player, redx) mcl_potions.poison_func(player, 1.2, splash_DUR_2*mcl_potions.INV_FACTOR^2*redx) end,
		tt = "-1/2 heart / 1.2sec | "..time_string(splash_DUR_2*mcl_potions.INV_FACTOR^2)
})

register_splash("poison_plus", "Splash Poison +", "#557766", {
		potion_fun = function(player, redx) mcl_potions.poison_func(player, 2.5, splash_DUR*mcl_potions.INV_FACTOR*redx) end,
		tt = "-1/2 heart / 2.5sec | "..time_string(splash_DUR_pl*mcl_potions.INV_FACTOR^2)
})

register_splash("regeneration", "Splash Regeneration", "#A52BB2", {
		potion_fun = function(player, redx) mcl_potions.regeneration_func(player, 2.5, splash_DUR*redx) end,
		tt = "1/2 heart / 2.5sec | "..time_string(splash_DUR)
})

register_splash("regeneration_2", "Splash Regeneration II", "#B52CC2", {
		potion_fun = function(player, redx) mcl_potions.regeneration_func(player, 1.2, (splash_DUR_2 + 1)*redx) end,
		tt = "1/2 heart / 1.2sec | "..time_string(splash_DUR_2 + 1)
})

register_splash("regeneration_plus", "Splash Regeneration +", "#C53DD3", {
		potion_fun = function(player, redx) mcl_potions.regeneration_func(player, 2.5, splash_DUR_pl*redx) end,
		tt = "1/2 heart / 2.5sec | "..time_string(splash_DUR_pl)
})

register_splash("invisibility", "Splash Invisibility", "#B0B0B0", {
	potion_fun = function(player, redx) mcl_potions.invisiblility_func(player, splash_DUR*redx) end,
	tt = time_string(splash_DUR)
})

register_splash("invisibility_plus", "Splash Invisibility +", "#A0A0A0", {
	potion_fun = function(player, redx) mcl_potions.invisiblility_func(player, splash_DUR_pl*redx) end,
	tt = time_string(splash_DUR_pl)
})

register_splash("weakness", "Splash Weakness", "#6600AA", {
	potion_fun = function(player, redx) mcl_potions.weakness_func(player, -4, splash_DUR*mcl_potions.INV_FACTOR*redx) end,
	tt = "No effect | "..time_string(splash_DUR*mcl_potions.INV_FACTOR)
})

register_splash("weakness_plus", "Splash Weakness +", "#7700BB", {
	potion_fun = function(player, redx) mcl_potions.weakness_func(player, -4, splash_DUR_pl*mcl_potions.INV_FACTOR*redx) end,
	tt = "No effect | "..time_string(splash_DUR_pl*mcl_potions.INV_FACTOR)
})

register_splash("strength", "Splash Strength", "#D444D4", {
	potion_fun = function(player, redx) mcl_potions.strength_func(player, 3, splash_DUR*redx) end,
	tt = "No effect | "..time_string(splash_DUR)
})

register_splash("strength_2", "Splash Strength II", "#D444F4", {
	potion_fun = function(player, redx) mcl_potions.strength_func(player, 6, splash_DUR_2*redx) end,
	tt = "No effect | "..time_string(splash_DUR_2)
})

register_splash("strength_plus", "Splash Strength +", "#D444E4", {
	potion_fun = function(player, redx) mcl_potions.strength_func(player, 3, splash_DUR_pl*redx) end,
	tt = "No effect | "..time_string(splash_DUR_pl)
})

register_splash("water_breathing", "Splash Water Breathing", "#0000AA", {
	potion_fun = function(player, redx) mcl_potions.water_breathing_func(player, splash_DUR*redx) end,
	tt = time_string(splash_DUR)
})

register_splash("water_breathing_plus", "Splash Water Breathing +", "#0000CC", {
	potion_fun = function(player, redx) mcl_potions.water_breathing_func(player, splash_DUR_pl*redx) end,
	tt = time_string(splash_DUR_pl)
})

register_splash("fire_resistance", "Splash Fire Resistance", "#D0A040", {
	potion_fun = function(player, redx) mcl_potions.fire_resistance_func(player, splash_DUR*redx) end,
	tt = time_string(splash_DUR)
})

register_splash("fire_resistance_plus", "Splash Fire Resistance +", "#E0B050", {
	potion_fun = function(player, redx) mcl_potions.fire_resistance_func(player, splash_DUR_pl*redx) end,
	tt = time_string(splash_DUR_pl)
})

register_splash("night_vision", "Splash Night Vision", "#1010AA", {
	potion_fun = function(player, redx) mcl_potions.night_vision_func(player, splash_DUR*redx) end,
	tt = time_string(splash_DUR)
})

register_splash("night_vision_plus", "Splash Night Vision +", "#2020BA", {
	potion_fun = function(player, redx) mcl_potions.night_vision_func(player, splash_DUR_pl*redx) end,
	tt = time_string(splash_DUR_pl)
})
