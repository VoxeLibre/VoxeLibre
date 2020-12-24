mcl_burning = {}

local S = minetest.get_translator("mcl_burning")

function mcl_burning.play_sound(obj, soundname)
	minetest.sound_play(soundname, {
		object = obj,
		gain = 0.18,
		max_hear_distance = 32,
	})
end

function mcl_burning.get_collisionbox(obj)
	local box = obj:get_properties().collisionbox
	return vector.new(box[1], box[2], box[3]), vector.new(box[4], box[5], box[6])
end

function mcl_burning.is_touching_nodes(obj, nodes)
	local pos = obj:get_pos()
	local box = obj:get_properties().collisionbox
	local minp, maxp = mcl_burning.get_collisionbox(obj)
	local nodes = minetest.find_nodes_in_area(vector.add(pos, minp), vector.add(pos, maxp), nodes)
	return #nodes > 0
end

function mcl_burning.create_particlespawner(obj, burn_time, old_burn_time, old_spawner)
	local new_spawner
	if old_spawner == 0 then
		old_spawner = nil
	end
	local delete_old_spawner = false
	if burn_time and (not old_spawner or burn_time >= old_burn_time) then
		delete_old_spawner = true
		local minp, maxp = mcl_burning.get_collisionbox(obj)
		new_spawner =  minetest.add_particlespawner({
			amount = 1000 * burn_time,
			time = burn_time,
			minpos = minp,
			maxpos = maxp,
			minvel = {x = -0.5, y = 1, z = -0.5},
			maxvel = {x =  0.5, y = 2, z = -0.5},
			minacc = {x = -0.1, y = 8, z = -0.1},
			maxacc = {x =  0.1, y = 10, z =  0.1},
			minexptime = 0.2,
			maxexptime = 0.3,
			minsize = 1,
			maxsize = 2,
			collisiondetection = true,
			texture = "fire_basic_flame.png",
			attached = obj,
		})
    elseif not burn_time and old_spawner then
		delete_old_spawner = true
	end
	if delete_old_spawner and old_spawner then
		minetest.delete_particlespawner(old_spawner)
		old_spawner = nil
	end
	return new_spawner or old_spawner
end

function mcl_burning.analyse(obj, meta, is_player)
	if meta then
		return meta, is_player
	end
	is_player = obj:is_player()
	if is_player then
		meta = obj:get_meta()
	else
		meta = obj:get_luaentity()
	end
	return meta, is_player
end

function mcl_burning.set_burning(obj, burn_time, old_burn_time, meta, is_player)
	meta, is_player = mcl_burning.analyse(obj, meta, is_player)
	old_burn_time = old_burn_time or mcl_burning.get_burning(obj, meta, is_player)
	if burn_time <= 0 then
		burn_time = nil
	end
	if is_player then
		if burn_time then
			meta:set_float("mcl_burning:burn_time", burn_time)
		elseif old_burn_time > 0 then
			meta:set_string("mcl_burning:burn_time", "")
			mcl_burning.play_sound(obj, "fire_extinguish_flame")
		end
		local fire_spawner = mcl_burning.create_particlespawner(obj, burn_time, old_burn_time, meta:get_int("mcl_burning:fire_spawner"))
		if fire_spawner then
			meta:set_int("mcl_burning:fire_spawner", fire_spawner)
		else
			meta:set_string("mcl_burning:fire_spawner", "")
		end
	elseif not meta._fire_resistant then
		meta._burn_time = burn_time
		meta._fire_spawner = mcl_burning.create_particlespawner(obj, burn_time, old_burn_time, meta._fire_spawner)
		if not burn_time and old_burn_time > 0 then
			mcl_burning.play_sound(obj, "fire_extinguish_flame")
		end
	end
end

function mcl_burning.get_burning(obj, meta, is_player)
	meta, is_player = mcl_burning.analyse(obj, meta, is_player)
	if is_player then
		return meta:get_float("mcl_burning:burn_time")
	else
		return meta._burn_time or 0
	end
end

function mcl_burning.damage(obj, meta, is_player)
	local hp
	if is_player then
		hp = obj:get_hp()
	else
		hp = meta.health or 0
	end
	if hp <= 0 then
		return
	end
	meta, is_player = mcl_burning.analyse(obj, meta, is_player)
	local do_damage = true
	if is_player then
		if mcl_potions.player_has_effect(obj, "fire_resistance") then
			do_damage = false
		else
			local name = obj:get_player_name()
			armor.last_damage_types[name] = "fire"
			mcl_death_messages.player_damage(obj, S("@1 burned to a crisp.", name))
		end
	end
	if do_damage then
		if is_player then
			obj:set_hp(hp - 1)
		else
			meta.health = hp - 1
		end
	end
end

local etime = 0

function mcl_burning.step(obj, dtime)
	local burn_time, old_burn_time, meta, is_player
	meta, is_player = mcl_burning.analyse(obj)
	old_burn_time = mcl_burning.get_burning(obj, meta, is_player)
	burn_time = old_burn_time - dtime
	if burn_time < 5 and mcl_burning.is_touching_nodes(obj, {"mcl_fire:fire", "mcl_fire:eternal_fire", "mcl_core:lava_source", "mcl_core:lava_flowing"}) then
		burn_time = 5
	end
	if burn_time > 0 or old_burn_time > 0 then
		if mcl_weather.get_weather() == "rain" and mcl_weather.is_outdoor(obj:get_pos()) or mcl_burning.is_touching_nodes(obj, {"mcl_core:water_source", "mcl_core:water_flowing"}) then
			burn_time = math.min(burn_time, 0.25)
		end
		mcl_burning.set_burning(obj, burn_time, old_burn_time, meta, is_player)
	end
	if burn_time > 0 then
		if math.random() < dtime then
			mcl_burning.play_sound(obj, "fire_fire")
		end
		if etime > 1 then
			mcl_burning.damage(obj, meta, is_player)
		end
	end
end

minetest.register_globalstep(function(dtime)
	if etime > 1 then
		etime = 0
	end
	etime = etime + dtime
	for _, player in ipairs(minetest.get_connected_players()) do
		mcl_burning.step(player, dtime)
	end
end)

minetest.register_on_respawnplayer(function(player)
	mcl_burning.set_burning(player, 0)
end)

minetest.register_chatcommand("burn", {
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local burn_time = tonumber(param) or 5
		if player then
			mcl_burning.set_burning(player, burn_time)
		end
	end
})
