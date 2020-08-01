local S = minetest.get_translator("mcl_potions")

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



function mcl_potions.register_lingering(name, descr, color, def)

    local id = "mcl_potions:"..name.."_lingering"
    local longdesc = def.longdesc
    if not def.no_effect then
        longdesc = S("A throwable potion that will shatter on impact, where it creates a magic cloud that lingers around for a while. Any player or mob inside the cloud will receive the potion's effect, possibly repeatedly.")
        if def.longdesc then
            longdesc = longdesc .. "\n" .. def.longdesc
        end
    end
    minetest.register_craftitem(id, {
        description = descr,
		_tt_help = def.tt,
        _doc_items_longdesc = longdesc,
        _doc_items_usagehelp = S("Use the “Punch” key to throw it."),
        inventory_image = lingering_image(color),
		groups = {brewitem=1, not_in_creative_inventory=0},
        on_use = function(item, placer, pointed_thing)
            local velocity = 10
            local dir = placer:get_look_dir();
            local pos = placer:getpos();
            local obj = minetest.add_entity({x=pos.x+dir.x,y=pos.y+2+dir.y,z=pos.z+dir.z}, id.."_flying")
            obj:setvelocity({x=dir.x*velocity,y=dir.y*velocity,z=dir.z*velocity})
            obj:setacceleration({x=dir.x*-3, y=-9.8, z=dir.z*-3})
			obj:get_luaentity()._thrower = placer:get_player_name()
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

-- -- register_lingering("weakness", S("Lingering Weakness Potion"), "#6600AA", {
-- -- 	potion_fun = function(player) mcl_potions.weakness_func(player, -4, mcl_potions.DURATION*mcl_potions.INV_FACTOR*0.25) end,
-- -- 	-- TODO: Fix tooltip
-- -- 	tt = time_string(mcl_potions.DURATION*mcl_potions.INV_FACTOR*0.25)
-- -- })
-- --
-- -- register_lingering("weakness_plus", S("Lingering Weakness Potion +"), "#7700BB", {
-- -- 	potion_fun = function(player) mcl_potions.weakness_func(player, -4, mcl_potions.DURATION_PLUS*mcl_potions.INV_FACTOR*0.25) end,
-- -- 	-- TODO: Fix tooltip
-- -- 	tt = time_string(mcl_potions.DURATION*mcl_potions.INV_FACTOR*0.25)
-- -- })
-- --
-- -- register_lingering("strength", S("Lingering Strength Potion"), "#D444D4", {
-- -- 	potion_fun = function(player) mcl_potions.strength_func(player, 3, mcl_potions.DURATION*0.25) end,
-- -- 	-- TODO: Fix tooltip
-- -- 	tt = time_string(mcl_potions.DURATION*0.25)
-- -- })
-- --
-- -- register_lingering("strength_2", S("Lingering Strength Potion II"), "#D444F4", {
-- -- 	potion_fun = function(player) mcl_potions.strength_func(player, 6, smcl_potions.DURATION_2*0.25) end,
-- -- 	-- TODO: Fix tooltip
-- -- 	tt = time_string(mcl_potions.DURATION_2*0.25)
-- -- })
-- --
-- -- register_lingering("strength_plus", S("Lingering Strength Potion +"), "#D444E4", {
-- -- 	potion_fun = function(player) mcl_potions.strength_func(player, 3, mcl_potions.DURATION_PLUS*0.25) end,
-- -- 	-- TODO: Fix tooltip
-- -- 	tt = time_string(mcl_potions.DURATION_PLUS*0.25)
-- -- })
