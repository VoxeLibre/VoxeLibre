local invisibility = {}

-- reset player invisibility if they go offline
minetest.register_on_leaveplayer(function(player)

	local name = player:get_player_name()
	if invisibility[name] then
		invisibility[name] = nil
	end

end)

function mcl_potions.invisible(player, toggle)

	if not player then return false end

	invisibility[player:get_player_name()] = toggle

	if toggle then -- hide player
		player:set_properties({visual_size = {x = 0, y = 0}})
		player:set_nametag_attributes({color = {a = 0}})
	else -- show player
		player:set_properties({visual_size = {x = 1, y = 1}})
		player:set_nametag_attributes({color = {a = 255}})
	end

end

function mcl_potions._use_potion(item, pos, color)
	local d = 0.1
	item:replace("mcl_potions:glass_bottle")
	minetest.sound_play("mcl_potions_drinking")
	minetest.add_particlespawner({
															amount = 25,
															time = 1,
															minpos = {x=pos.x-d, y=pos.y+1, z=pos.z-d},
															maxpos = {x=pos.x+d, y=pos.y+2, z=pos.z+d},
															minvel = {x=-0.1, y=0, z=-0.1},
															maxvel = {x=0.1, y=0.1, z=0.1},
															minacc = {x=-0.1, y=0, z=-0.1},
															maxacc = {x=0.1, y=.1, z=0.1},
															minexptime = 1,
															maxexptime = 5,
															minsize = 0.5,
															maxsize = 2,
															collisiondetection = true,
															vertical = false,
															texture = "mcl_potions_sprite.png^[colorize:"..color..":127",
														})
end

local is_zombie = {}

for i, zombie in ipairs({"husk","zombie","pigman"}) do
	is_zombie["mobs_mc:"..zombie] = true
	is_zombie["mobs_mc:baby_"..zombie] = true
end

function mcl_potions.healing_func(player, hp)

	if is_zombie[player:get_entity_name()] then hp = -hp end
	if hp > 0 then
		player:set_hp(math.min(player:get_hp() + hp, player:get_properties().hp_max))
	else
		player:set_hp(player:get_hp() + hp)
	end

end

function mcl_potions.swiftness_func(player, factor, duration)
	if not player:get_meta() then return false end
	playerphysics.add_physics_factor(player, "speed", "swiftness", factor)
	minetest.after(duration, function() playerphysics.remove_physics_factor(player, "speed", "swiftness") end )
end

function mcl_potions.leaping_func(player, factor, duration)
	if player:get_meta() then return false end
	playerphysics.add_physics_factor(player, "jump", "leaping", factor)
	minetest.after(duration, function() playerphysics.remove_physics_factor(player, "jump", "leaping") end )
end

function mcl_potions.weakness_func(player, factor, duration)
	player:set_attribute("weakness", tostring(factor))
	-- print(player:get_player_name().." ".."weakness = "..player:get_attribute("weakness"))
	minetest.after(duration, function() player:set_attribute("weakness", tostring(0)) end )
end

function mcl_potions.poison_func(player, factor, duration)
	for i=1,math.floor(duration/factor) do
		minetest.after(i*factor, function() player:set_hp(player:get_hp() - 1) end)
	end
end

function mcl_potions.regeneration_func(player, factor, duration)
	for i=1,math.floor(duration/factor) do
		minetest.after(i*factor, function()
						if player:get_hp() < 20 then
							player:set_hp(player:get_hp() + 1)
						end
					end  )
	end
end


function mcl_potions.invisiblility_func(player, duration)
	mcl_potions.invisible(player, true)
	minetest.after(duration, function() mcl_potions.invisible(player, false) end )
end

function mcl_potions.water_breathing_func(player, duration)
	if minetest.is_player(player) then

		for i=1,math.floor(duration) do
			minetest.after(i, function()
							if player:get_breath() < 10 then
								player:set_breath(10)
							end
						end  )
		end
	end

end
