local S = minetest.get_translator("mcl_burning")

mcl_burning = {}

function mcl_burning.get_default(datatype)
	local default_table = {string = "", float = 0.0, int = 0, bool = false}
	return default_table[datatype]
end

function mcl_burning.get(obj, datatype, name)
	local key
	if obj:is_player() then
		local meta = obj:get_meta()
		return meta["get_" .. datatype](meta, "mcl_burning:" .. name)
	else
		local luaentity = obj:get_luaentity()
		return luaentity["mcl_burning_" .. name] or mcl_burning.get_default(datatype)
	end
end

function mcl_burning.set(obj, datatype, name, value)
	if obj:is_player() then
		local meta = obj:get_meta()
		meta["set_" .. datatype](meta, "mcl_burning:" .. name, value or mcl_burning.get_default(datatype))
	else
		local luaentity = obj:get_luaentity()
		if mcl_burning.get_default(datatype) == value then
			value = nil
		end
		luaentity["mcl_burning_" .. name] = value
	end
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

function mcl_burning.damage(obj)
	local luaentity = obj:get_luaentity()
	local health

	if luaentity then
		health = luaentity.health
	end
	
	local hp = health or obj:get_hp()
	
	if hp <= 0 then
		return
	end

	local do_damage = true
	
	if obj:is_player() then
		if mcl_potions.player_has_effect(obj, "fire_proof") then
			do_damage = false
		else
			local name = obj:get_player_name()
			armor.last_damage_types[name] = "fire"
			local deathmsg = S("@1 burned to death.", name)
			local reason = mcl_burning.get(obj, "string", "reason")
			if reason ~= "" then
				deathmsg = S("@1 was burned by @2.", name, reason)
			end
			mcl_death_messages.player_damage(obj, deathmsg)
		end
	else
		if luaentity.fire_damage_resistant then
			do_damage = false
		end
	end

	if do_damage then
		local damage = mcl_burning.get(obj, "float", "damage")
		if damage == 0 then
			damage = 1
		end
		local new_hp = hp - damage
		obj:set_hp(new_hp)
		if health then
			luaentity.health = new_hp
		end
	end
end

function mcl_burning.set_on_fire(obj, burn_time, damage, reason)
	local luaentity = obj:get_luaentity()
	if luaentity and luaentity.fire_resistant then
		return
	end

	local old_burn_time = mcl_burning.get(obj, "float", "burn_time")
	local max_fire_prot_lvl = 0
	
	if obj:is_player() then
		local inv = obj:get_inventory()
		
		for i = 2, 5 do
			local stack = inv:get_stack("armor", i)
			
			local fire_prot_lvl = mcl_enchanting.get_enchantment(stack, "fire_protection")
			max_fire_prot_lvl = math.max(max_fire_prot_lvl, fire_prot_lvl)
		end
	end
	
	if max_fire_prot_lvl > 0 then
		burn_time = burn_time - math.floor(burn_time * max_fire_prot_lvl * 0.15)
	end
	
	if old_burn_time <= burn_time then		
		mcl_burning.set(obj, "float", "burn_time", burn_time)
		mcl_burning.set(obj, "float", "damage", damage or 0)
		mcl_burning.set(obj, "string", "reason", reason or "")
		
	end
end

function mcl_burning.extinguish(obj)
	local old_burn_time = mcl_burning.get(obj, "float", "burn_time")
	
	if old_burn_time > 0 then
		minetest.sound_play("fire_extinguish_flame", {
			object = obj,
			gain = 0.18,
			max_hear_distance = 32,
		})

		mcl_burning.delete_particlespawner(obj)

		mcl_burning.set(obj, "float", "damage")
		mcl_burning.set(obj, "string", "reason")
		mcl_burning.set(obj, "float", "burn_time")
		mcl_burning.set(obj, "float", "damage_timer")
	end
end

function mcl_burning.catch_fire_tick(obj, dtime)
	local lava_nodes = {"mcl_core:lava_source", "mcl_core:lava_flowing"}
	local fire_nodes = {"mcl_fire:fire", "mcl_fire:eternal_fire"}
	local water_nodes = {"mcl_core:water_source", "mcl_core:water_flowing"}

	if mcl_weather.get_weather() == "rain" and mcl_weather.is_outdoor(obj:get_pos()) or mcl_burning.is_touching_nodes(obj, water_nodes) then
		mcl_burning.extinguish(obj)
	elseif mcl_burning.is_touching_nodes(obj, lava_nodes) then
		mcl_burning.set_on_fire(obj, 15)
	elseif mcl_burning.is_touching_nodes(obj, fire_nodes) then
		mcl_burning.set_on_fire(obj, 8)
	end
end

function mcl_burning.tick(obj, dtime)
	local burn_time = mcl_burning.get(obj, "float", "burn_time") - dtime
	
	if burn_time <= 0 then
		mcl_burning.extinguish(obj)
	else
		mcl_burning.set(obj, "float", "burn_time", burn_time)
	
		if math.random() < dtime then
			minetest.sound_play("fire_fire", {
				object = obj,
				gain = 0.18,
				max_hear_distance = 32,
			})
		end
		
		local damage_timer = mcl_burning.get(obj, "float", "damage_timer") + dtime
		
		if damage_timer >= 1 then
			damage_timer = 0
			mcl_burning.damage(obj)
		end
		
		mcl_burning.set(obj, "float", "damage_timer", damage_timer)
	end

	mcl_burning.catch_fire_tick(obj, dtime)
end

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		mcl_burning.tick(player, dtime)
	end
end)

minetest.register_on_respawnplayer(function(player)
	mcl_burning.extinguish(player)
end)

minetest.register_chatcommand("burn", {
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local sparam = param:split(" ")
		local burn_time = tonumber(sparam[1]) or 5
		local damage = tonumber(sparam[2]) or 5
		if player then
			mcl_burning.set_on_fire(player, burn_time, damage)
		end
	end
})
