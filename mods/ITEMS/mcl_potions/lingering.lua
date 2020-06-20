local lingering_image = function(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return "mcl_potions_splash_overlay.png^[colorize:"..colorstring..":"..tostring(opacity).."^mcl_potions_splash_bottle.png"
end

local function register_lingering(name, descr, color, def)

    local id = "mcl_potions:"..name.."_lingering"
    minetest.register_craftitem(id, {
        description = descr,
        inventory_image = lingering_image(color),
        on_use = function(item, placer, pointed_thing)
            --weapons_shot(itemstack, placer, pointed_thing, def.velocity, name)
            local velocity = 10
            local dir = placer:get_look_dir();
            local pos = placer:getpos();
            local obj = minetest.env:add_entity({x=pos.x+dir.x,y=pos.y+2+dir.y,z=pos.z+dir.z}, id.."_flying")
            obj:setvelocity({x=dir.x*velocity,y=dir.y*velocity,z=dir.z*velocity})
            obj:setacceleration({x=0, y=-9.8, z=0})
            item:take_item()
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
					local d = 2
					local redux_map = {7/8,0.5,0.25}
          if n ~= "air" then
						minetest.sound_play("mcl_potions_breaking_glass")
						minetest.add_particlespawner({
																				amount = 1000,
																				time = 30,
																				minpos = {x=pos.x-d, y=pos.y+0.5, z=pos.z-d},
																				maxpos = {x=pos.x+d, y=pos.y+d, z=pos.z+d},
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
																				texture = "mcl_potions_sprite.png^[colorize:"..color..":127",
																			})
            self.object:remove()
						for i, obj in ipairs(minetest.get_objects_inside_radius(pos, 4)) do

							if minetest.is_player(obj) or obj:get_entity_name() then

								pos2 = obj:get_pos()
								local rad = math.floor(math.sqrt((pos2.x-pos.x)^2 + (pos2.y-pos.y)^2 + (pos2.z-pos.z)^2))
								if rad > 0 then def.potion_fun(obj, redux_map[rad]) else def.potion_fun(obj, 1) end

							end
						end

					end
        end,
    })
end

register_lingering("water", "Lingering Potion", "#0000FF", {
    potion_fun = function(player, redx)  end,
})

register_lingering("river_water", "Lingering Potion", "#0000FF", {
    potion_fun = function(player, redx)  end,
})

register_lingering("awkward", "Lingering Awkward Potion", "#0000FF", {
    potion_fun = function(player, redx)  end,
})

register_lingering("mundane", "Lingering Mundane Potion", "#0000FF", {
    potion_fun = function(player, redx)  end,
})

register_lingering("thick", "Lingering Thick Potion", "#0000FF", {
    potion_fun = function(player, redx)  end,
})

register_lingering("healing", "Lingering Healing", "#AA0000", {
    potion_fun = function(player, redx) player:set_hp(player:get_hp() + 3*redx) end,
})

register_lingering("healing_2", "Lingering Healing II", "#DD0000", {
    potion_fun = function(player, redx) player:set_hp(player:get_hp() + 6*redx) end,
})

register_lingering("harming", "Lingering Harming", "#660099", {
    potion_fun = function(player, redx) mcl_potions.healing_func(player, -4*redx) end,
})

register_lingering("harming_2", "Lingering Harming II", "#330066", {
    potion_fun = function(player, redx) mcl_potions.healing_func(player, -6*redx) end,
})

register_lingering("leaping", "Lingering Leaping", "#00CC33", {
		potion_fun = function(player, redx) mcl_potions.leaping_func(player, 1.2, 135*redx) end
})

register_lingering("leaping_2", "Lingering Leaping II", "#00EE33", {
		potion_fun = function(player, redx) mcl_potions.leaping_func(player, 1.4, 135*redx) end
})

register_lingering("leaping_plus", "Lingering Leaping +", "#00DD33", {
		potion_fun = function(player, redx) mcl_potions.leaping_func(player, 1.2, 360*redx) end
})

register_lingering("swiftness", "Lingering Swiftness", "#009999", {
		potion_fun = function(player, redx) mcl_potions.swiftness_func(player, 1.2, 135*redx) end
})

register_lingering("swiftness_2", "Lingering Swiftness II", "#00BBBB", {
		potion_fun = function(player, redx) mcl_potions.swiftness_func(player, 1.4, 135*redx) end
})

register_lingering("swiftness_plus", "Lingering Swiftness +", "#00BBBB", {
		potion_fun = function(player, redx) mcl_potions.swiftness_func(player, 1.2, 360*redx) end
})

register_lingering("slowness", "Lingering Slowness ", "#000080", {
		potion_fun = function(player, redx) mcl_potions.swiftness_func(player, 0.85, 68*redx) end
})

register_lingering("slowness_plus", "Lingering Slowness +", "#000066", {
		potion_fun = function(player, redx) mcl_potions.swiftness_func(player, 0.85, 180*redx) end
})

register_lingering("poison", "Lingering Poison", "#335544", {
		potion_fun = function(player, redx) mcl_potions.poison_func(player, 2.5, 45*redx) end
})

register_lingering("poison_2", "Lingering Poison II", "#446655", {
		potion_fun = function(player, redx) mcl_potions.poison_func(player, 1.2, 21*redx) end
})

register_lingering("poison_plus", "Lingering Poison +", "#557766", {
		potion_fun = function(player, redx) mcl_potions.poison_func(player, 2.5, 90*redx) end
})

register_lingering("regeneration", "Lingering Regeneration", "#A52BB2", {
		potion_fun = function(player, redx) mcl_potions.regeneration_func(player, 2.5, 45*redx) end
})

register_lingering("regeneration_2", "Lingering Regeneration II", "#B52CC2", {
		potion_fun = function(player, redx) mcl_potions.regeneration_func(player, 1.2, 21*redx) end
})

register_lingering("regeneration_plus", "Lingering Regeneration +", "#C53DD3", {
		potion_fun = function(player, redx) mcl_potions.regeneration_func(player, 2.5, 90*redx) end
})

register_lingering("invisibility", "Lingering Invisibility", "#B0B0B0", {
	potion_fun = function(player, redx) mcl_potions.invisiblility_func(player, 135*redx) end
})

register_lingering("invisibility_plus", "Lingering Invisibility +", "#A0A0A0", {
	potion_fun = function(player, redx) mcl_potions.invisiblility_func(player, 300*redx) end
})

register_lingering("weakness", "Lingering Weakness", "#6600AA", {
	potion_fun = function(player, redx) mcl_potions.weakness_func(player, 1.2, 68*redx) end
})

register_lingering("weakness_plus", "Lingering Weakness +", "#7700BB", {
	potion_fun = function(player, redx) mcl_potions.weakness_func(player, 1.4, 180*redx) end
})
