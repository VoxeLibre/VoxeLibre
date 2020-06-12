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

function mcl_potions._use_potion()
	minetest.item_eat(0, "mcl_potions:glass_bottle")
	minetest.sound_play("mcl_potions_drinking")
end

function mcl_potions.healing_func(player, hp) player:set_hp(player:get_hp() + hp) end

function mcl_potions.swiftness_func(player, factor, duration)
	playerphysics.add_physics_factor(player, "speed", "swiftness", factor)
	minetest.after(duration, function() playerphysics.remove_physics_factor(player, "speed", "swiftness") end )
end

function mcl_potions.leaping_func(player, factor, duration)
	playerphysics.add_physics_factor(player, "jump", "leaping", factor)
	minetest.after(duration, function() playerphysics.remove_physics_factor(player, "jump", "leaping") end )
end

function mcl_potions.weakness_func(player, factor, duration)
	player:set_attribute("weakness", tostring(factor))
	print(player:get_player_name().." ".."weakness = "..player:get_attribute("weakness"))
	minetest.after(duration, function() player:set_attribute("weakness", tostring(0)) end )
end

function mcl_potions.poison_func(player, factor, duration)
	player:set_attribute("poison", tostring(factor))
	print(player:get_player_name().." ".."poison = "..player:get_attribute("poison"))
	minetest.after(duration, function() player:set_attribute("poison", tostring(0)) end )
end

function mcl_potions.regeneration_func(player, factor, duration)
	player:set_attribute("regeneration", tostring(factor))
	print(player:get_player_name().." ".."regeneration = "..player:get_attribute("regeneration"))
	minetest.after(duration, function() player:set_attribute("regeneration", tostring(0)) end )
end

function mcl_potions.invisiblility_func(player, duration)
	invisible(player, true)
	minetest.after(duration, function() invisible(player, false) end )
end
