local is_invisible = {}
local is_poisoned = {}
local is_regenerating = {}
local is_strong = {}
local is_weak = {}
local is_water_breathing = {}
local is_leaping = {}
local is_swift = {}
local is_cat = {}


minetest.register_globalstep(function(dtime)

	-- Check for invisible players
	for player, vals in pairs(is_invisible) do

		if is_invisible[player] and player:get_properties() then

			player = player or player:get_luaentity()

			is_invisible[player].timer = is_invisible[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#B0B0B0") end

			if is_invisible[player].timer >= is_invisible[player].dur then
				mcl_potions.make_invisible(player, false)
				is_invisible[player] = nil
			end

		elseif not player:get_properties() then
			is_invisible[player] = nil
		end

	end

	-- Check for poisoned players
	for player, vals in pairs(is_poisoned) do

		if is_poisoned[player] and player:get_properties() then

			player = player or player:get_luaentity()

			is_poisoned[player].timer = is_poisoned[player].timer + dtime
			is_poisoned[player].hit_timer = (is_poisoned[player].hit_timer or 0) + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#225533") end

			if is_poisoned[player].hit_timer >= is_poisoned[player].step then
				player:set_hp( math.max(player:get_hp() - 1, 1) )
				is_poisoned[player].hit_timer = 0
			end

			if is_poisoned[player].timer >= is_poisoned[player].dur then
				is_poisoned[player] = nil
			end

		elseif not player:get_properties() then
			is_poisoned[player] = nil
		end

	end

	-- Check for regnerating players
	for player, vals in pairs(is_regenerating) do

		if is_regenerating[player] and player:get_properties() then

			player = player or player:get_luaentity()

			is_regenerating[player].timer = is_regenerating[player].timer + dtime
			is_regenerating[player].heal_timer = (is_regenerating[player].heal_timer or 0) + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#A52BB2") end

			if is_regenerating[player].heal_timer >= is_regenerating[player].step then
				player:set_hp(math.min(player:get_properties().hp_max or 20, player:get_hp() + 1))
				is_regenerating[player].heal_timer = 0
			end

			if is_regenerating[player].timer >= is_regenerating[player].dur then
				is_regenerating[player] = nil
			end

		elseif not player:get_properties() then
			is_regenerating[player] = nil
		end

	end

	-- Check for water breathing players
	for player, vals in pairs(is_water_breathing) do

		if is_water_breathing[player] and player:get_properties() then

			player = player or player:get_luaentity()

			is_water_breathing[player].timer = is_water_breathing[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#0000AA") end

			if player:get_breath() then
				if player:get_breath() < 10 then player:set_breath(10) end
			end

			if is_water_breathing[player].timer >= is_water_breathing[player].dur then
				is_water_breathing[player] = nil
			end

		elseif not player:get_properties() then
			is_water_breathing[player] = nil
		end

	end

	-- Check for leaping players
	for player, vals in pairs(is_leaping) do

		if is_leaping[player] and player:get_properties() then

			player = player or player:get_luaentity()

			is_leaping[player].timer = is_leaping[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#00CC33") end

			if is_leaping[player].timer >= is_leaping[player].dur then
				playerphysics.remove_physics_factor(player, "jump", "leaping")
				is_leaping[player] = nil
			end

		elseif not player:get_properties() then
			is_leaping[player] = nil
		end

	end

	-- Check for swift players
	for player, vals in pairs(is_swift) do

		if is_swift[player] and player:get_properties() then

			player = player or player:get_luaentity()

			is_swift[player].timer = is_swift[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#009999") end

			if is_swift[player].timer >= is_swift[player].dur then
				playerphysics.remove_physics_factor(player, "speed", "swiftness")
				is_swift[player] = nil
			end

		elseif not player:get_properties() then
			is_swift[player] = nil
		end

	end

	-- Check for Night Vision equipped players
	for player, vals in pairs(is_cat) do

		if is_cat[player] and player:get_properties() then

			player = player or player:get_luaentity()

			is_cat[player].timer = is_cat[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#1010AA") end
			player:override_day_night_ratio(0.45)

			if is_cat[player].timer >= is_cat[player].dur then
				is_cat[player] = nil
			end

		elseif not player:get_properties() then
			is_cat[player] = nil
		end

	end

end )

-- reset player is_invisible/poison if they go offline
minetest.register_on_leaveplayer(function(player)

	player = player or player:get_luaentity()

	if is_invisible[player] then
		is_invisible[player] = nil
	end

	if is_poisoned[player] then
		is_poisoned[player] = nil
	end

	if is_regenerating[player] then
		is_regenerating[player] = nil
	end

	if is_strong[player] then
		is_strong[player] = nil
	end

	if is_weak[player] then
		is_weak[player] = nil
	end

	if is_water_breathing[player] then
		is_water_breathing[player] = nil
	end

	if is_leaping[player] then
		is_leaping[player] = nil
	end

	if is_swift[player] then
		is_swift[player] = nil
	end

	if is_cat[player] then
		is_cat[player] = nil
	end

end)

function mcl_potions.make_invisible(player, toggle)

	if not player then return false end

	if toggle then -- hide player
		is_invisible[player].old_size = player:get_properties().visual_size
		player:set_properties({visual_size = {x = 0, y = 0}})
		player:set_nametag_attributes({color = {a = 0}})
	else -- show player
		player:set_properties({visual_size = is_invisible[player].old_size})
		player:set_nametag_attributes({color = {a = 255}})
	end

end

function mcl_potions.poison(player, toggle)

	if not player then return false end
	is_poisoned[player:get_player_name()] = toggle

end

function mcl_potions.regenerate(player, toggle)

	if not player then return false end
	is_regenerating[player:get_player_name()] = toggle

end

function mcl_potions._use_potion(item, obj, color)
	local d = 0.1
	local pos = obj:get_pos()
	item:replace("mcl_potions:glass_bottle")
	minetest.sound_play("mcl_potions_drinking", {pos = pos, max_hear_distance = 6, gain = 1})
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
									maxsize = 1,
									collisiondetection = true,
									vertical = false,
									texture = "mcl_potions_sprite.png^[colorize:"..color..":127",
								})
end


function mcl_potions._add_spawner(obj, color)
	local d = 0.2
	local pos = obj:get_pos()
	minetest.add_particlespawner({
									amount = 2,
									time = 1,
									minpos = {x=pos.x-d, y=pos.y+1, z=pos.z-d},
									maxpos = {x=pos.x+d, y=pos.y+2, z=pos.z+d},
									minvel = {x=-0.1, y=0, z=-0.1},
									maxvel = {x=0.1, y=0.1, z=0.1},
									minacc = {x=-0.1, y=0, z=-0.1},
									maxacc = {x=0.1, y=.1, z=0.1},
									minexptime = 0.5,
									maxexptime = 1,
									minsize = 0.5,
									maxsize = 1,
									collisiondetection = false,
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

	if not is_swift[player] then

		is_swift[player] = {dur = duration, timer = 0}
		playerphysics.add_physics_factor(player, "speed", "swiftness", factor)

	else

		local victim = is_swift[player]

		playerphysics.add_physics_factor(player, "speed", "swiftness", factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

end

function mcl_potions.leaping_func(player, factor, duration)

	if not player:get_meta() then return false end

	if not is_leaping[player] then

		is_leaping[player] = {dur = duration, timer = 0}
		playerphysics.add_physics_factor(player, "jump", "leaping", factor)

	else

		local victim = is_leaping[player]

		playerphysics.add_physics_factor(player, "jump", "leaping", factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

end


function mcl_potions.weakness_func(player, factor, duration)
	player:set_attribute("weakness", tostring(factor))
	-- print(player:get_player_name().." ".."weakness = "..player:get_attribute("weakness"))
	minetest.after(duration, function() player:set_attribute("weakness", tostring(0)) end )
	for i=1,math.floor(duration) do
		minetest.after(i, function() mcl_potions._add_spawner(player, "#6600AA") end)
	end
end


function mcl_potions.poison_func(player, factor, duration)

	if not is_poisoned[player] then

		is_poisoned[player] = {step = factor, dur = duration, timer = 0}

	else

		local victim = is_poisoned[player]

		victim.step = math.min(victim.step, factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end
end


function mcl_potions.regeneration_func(player, factor, duration)

	if not is_regenerating[player] then

		is_regenerating[player] = {step = factor, dur = duration, timer = 0}

	else

		local victim = is_regenerating[player]

		victim.step = math.min(victim.step, factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end
end


function mcl_potions.invisiblility_func(player, duration)

	if not is_invisible[player] then

		is_invisible[player] = {dur = duration, timer = 0}
		mcl_potions.make_invisible(player, true)

	else

		local victim = is_invisible[player]

		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

end

function mcl_potions.water_breathing_func(player, duration)

	if not is_water_breathing[player] then

		is_water_breathing[player] = {dur = duration, timer = 0}

	else

		local victim = is_water_breathing[player]

		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

end


function mcl_potions.fire_resistance_func(player, duration)



end


function mcl_potions.night_vision_func(player, duration)

	if not is_cat[player] then

		is_cat[player] = {dur = duration, timer = 0}

	else

		local victim = is_cat[player]

		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

end
