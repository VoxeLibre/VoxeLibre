local S = minetest.get_translator("mcl_burning")

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
		return luaentity and luaentity["mcl_burning_" .. name] or mcl_burning.get_default(datatype)
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

function mcl_burning.is_burning(obj)
	return mcl_burning.get(obj, "float", "burn_time") > 0
end

function mcl_burning.is_affected_by_rain(obj)
	return mcl_weather and mcl_weather.get_weather() == "rain" and mcl_weather.is_outdoor(obj:get_pos())
end

function mcl_burning.get_collisionbox(obj, smaller)
	local box = obj:get_properties().collisionbox
	local minp, maxp = vector.new(box[1], box[2], box[3]), vector.new(box[4], box[5], box[6])
	if smaller then
		local s_vec = vector.new(0.1, 0.1, 0.1)
		minp = vector.add(minp, s_vec)
		maxp = vector.subtract(maxp, s_vec)
	end
	return minp, maxp
end

function mcl_burning.get_touching_nodes(obj, nodenames)
	local pos = obj:get_pos()
	local box = obj:get_properties().collisionbox
	local minp, maxp = mcl_burning.get_collisionbox(obj, true)
	local nodes = minetest.find_nodes_in_area(vector.add(pos, minp), vector.add(pos, maxp), nodenames)
	return nodes
end

function mcl_burning.get_highest_group_value(obj, groupname)
	local nodes = mcl_burning.get_touching_nodes(obj, "group:" .. groupname, true)
	local highest_group_value = 0

	for _, pos in pairs(nodes) do
		local node = minetest.get_node(pos)
		local group_value = minetest.get_item_group(node.name, groupname)
		if group_value > highest_group_value then
			highest_group_value = group_value
		end
	end

	return highest_group_value
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
		local new_hp = hp - 1
		if health then
			luaentity.health = new_hp
		else
			obj:set_hp(new_hp)
		end
	end
end

function mcl_burning.set_on_fire(obj, burn_time, reason)
	local luaentity = obj:get_luaentity()
	if luaentity and luaentity.fire_resistant then
		return
	end

	local old_burn_time = mcl_burning.get(obj, "float", "burn_time")
	local max_fire_prot_lvl = 0

	if obj:is_player() then
		if minetest.is_creative_enabled(obj:get_player_name()) then
			burn_time = burn_time / 100
		end

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
		local sound_id = mcl_burning.get(obj, "int", "sound_id")
		if sound_id == 0 then
			sound_id = minetest.sound_play("fire_fire", {
				object = obj,
				gain = 0.18,
				max_hear_distance = 16,
				loop = true,
			}) + 1
		end

		local hud_id
		if obj:is_player() then
			hud_id = mcl_burning.get(obj, "int", "hud_id")
			if hud_id == 0 then
				hud_id = obj:hud_add({
					hud_elem_type = "image",
					position = {x = 0.5, y = 0.5},
					scale = {x = -100, y = -100},
					text = "fire_basic_flame.png",
					z_index = 1000,
				}) + 1
			end
		end
		mcl_burning.set(obj, "float", "burn_time", burn_time)
		mcl_burning.set(obj, "string", "reason", reason)
		mcl_burning.set(obj, "int", "hud_id", hud_id)
		mcl_burning.set(obj, "int", "sound_id", sound_id)

		local fire_entity = minetest.add_entity(obj:get_pos(), "mcl_burning:fire")
		local minp, maxp = mcl_burning.get_collisionbox(obj)
		local obj_size = obj:get_properties().visual_size

		local vertical_grow_factor = 1.2
		local horizontal_grow_factor = 1.1
		local grow_vector = vector.new(horizontal_grow_factor, vertical_grow_factor, horizontal_grow_factor)

		local size = vector.subtract(maxp, minp)
		size = vector.multiply(size, grow_vector)
		size = vector.divide(size, obj_size)
		local offset = vector.new(0, size.y * 10 / 2, 0)

		fire_entity:set_properties({visual_size = size})
		fire_entity:set_attach(obj, "", offset, {x = 0, y = 0, z = 0})
		mcl_burning.update_animation_frame(obj, fire_entity, 0)
	end
end

function mcl_burning.extinguish(obj)
	if mcl_burning.is_burning(obj) then
		local sound_id = mcl_burning.get(obj, "int", "sound_id") - 1
		minetest.sound_stop(sound_id)

		if obj:is_player() then
			local hud_id = mcl_burning.get(obj, "int", "hud_id") - 1
			obj:hud_remove(hud_id)
		end

		mcl_burning.set(obj, "string", "reason")
		mcl_burning.set(obj, "float", "burn_time")
		mcl_burning.set(obj, "float", "damage_timer")
		mcl_burning.set(obj, "int", "hud_id")
		mcl_burning.set(obj, "int", "sound_id")
	end
end

function mcl_burning.catch_fire_tick(obj, dtime)
	if mcl_burning.is_affected_by_rain(obj) or #mcl_burning.get_touching_nodes(obj, "group:puts_out_fire") > 0 then
		mcl_burning.extinguish(obj)
	else
		local set_on_fire_value = mcl_burning.get_highest_group_value(obj, "set_on_fire")

		if set_on_fire_value > 0 then
			mcl_burning.set_on_fire(obj, set_on_fire_value)
		end
	end
end

function mcl_burning.tick(obj, dtime)
	local burn_time = mcl_burning.get(obj, "float", "burn_time") - dtime

	if burn_time <= 0 then
		mcl_burning.extinguish(obj)
	else
		mcl_burning.set(obj, "float", "burn_time", burn_time)

		local damage_timer = mcl_burning.get(obj, "float", "damage_timer") + dtime

		if damage_timer >= 1 then
			damage_timer = 0
			mcl_burning.damage(obj)
		end

		mcl_burning.set(obj, "float", "damage_timer", damage_timer)
	end

	mcl_burning.catch_fire_tick(obj, dtime)
end

function mcl_burning.update_animation_frame(obj, fire_entity, animation_frame)
	local fire_texture = "mcl_burning_entity_flame_animated.png^[opacity:180^[verticalframe:" .. mcl_burning.animation_frames .. ":" .. animation_frame
	local fire_HUD_texture = "mcl_burning_hud_flame_animated.png^[opacity:180^[verticalframe:" .. mcl_burning.animation_frames .. ":" .. animation_frame
	fire_entity:set_properties({textures = {"blank.png", "blank.png", fire_texture, fire_texture, fire_texture, fire_texture}})
	if obj:is_player() then
		local hud_id = mcl_burning.get(obj, "int", "hud_id") - 1
		obj:hud_change(hud_id, "text", fire_HUD_texture)
	end
end

function mcl_burning.fire_entity_step(self, dtime)
	if self.removed then
		return
	end

	local obj = self.object
	local parent = obj:get_attach()
	local do_remove

	self.doing_step = true

	if not parent or not mcl_burning.is_burning(parent) then
		do_remove = true
	else
		for _, other in pairs(minetest.get_objects_inside_radius(obj:get_pos(), 0)) do
			local luaentity = obj:get_luaentity()
			if luaentity and luaentity.name == "mcl_burning:fire" and not luaentity.doing_step and not luaentity.removed then
				do_remove = true
				break
			end
		end
	end

	self.doing_step = false

	if do_remove then
		self.removed = true
		obj:remove()
		return
	end

	local animation_timer = self.animation_timer + dtime
	if animation_timer >= 0.015 then
		animation_timer = 0
		local animation_frame = self.animation_frame + 1
		if animation_frame > mcl_burning.animation_frames - 1 then
			animation_frame = 0
		end
		mcl_burning.update_animation_frame(parent, obj, animation_frame)
		self.animation_frame = animation_frame
	end
	self.animation_timer = animation_timer
end
