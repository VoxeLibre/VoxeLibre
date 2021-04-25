local S = minetest.get_translator("mcl_burning")

function mcl_burning.get_storage(obj)
	return obj:is_player() and mcl_burning.storage[obj] or obj:get_luaentity()
end

function mcl_burning.is_burning(obj)
	return mcl_burning.get_storage(obj).burn_time
end

function mcl_burning.is_affected_by_rain(obj)
	return mcl_weather.get_weather() == "rain" and mcl_weather.is_outdoor(obj:get_pos())
end

function mcl_burning.get_collisionbox(obj, smaller, storage)
	local cache = storage.collisionbox_cache
	if cache then
		local box = cache[smaller and 2 or 1]
		return box[1], box[2]
	else
		local box = obj:get_properties().collisionbox
		local minp, maxp = vector.new(box[1], box[2], box[3]), vector.new(box[4], box[5], box[6])
		local s_vec = vector.new(0.1, 0.1, 0.1)
		local s_minp = vector.add(minp, s_vec)
		local s_maxp = vector.subtract(maxp, s_vec)
		storage.collisionbox_cache = {{minp, maxp}, {s_minp, s_maxp}}
		return minp, maxp
	end
end

function mcl_burning.get_touching_nodes(obj, nodenames, storage)
	local pos = obj:get_pos()
	local minp, maxp = mcl_burning.get_collisionbox(obj, true, storage)
	local nodes = minetest.find_nodes_in_area(vector.add(pos, minp), vector.add(pos, maxp), nodenames)
	return nodes
end

function mcl_burning.set_on_fire(obj, burn_time, reason)
	if obj:get_hp() < 0 then
		return
	end

	local storage = mcl_burning.get_storage(obj)

	local luaentity = obj:get_luaentity()
	if luaentity and luaentity.fire_resistant then
		return
	end

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

	if not storage.burn_time or burn_time >= storage.burn_time then
		if obj:is_player() and not storage.fire_hud_id then
			storage.fire_hud_id = obj:hud_add({
				hud_elem_type = "image",
				position = {x = 0.5, y = 0.5},
				scale = {x = -100, y = -100},
				text = "mcl_burning_entity_flame_animated.png^[opacity:180^[verticalframe:" .. mcl_burning.animation_frames .. ":" .. 1,
				z_index = 1000,
			})
		end
		storage.burn_time = burn_time
		storage.burn_reason = reason
		storage.fire_damage_timer = 0

		local fire_entity = minetest.add_entity(obj:get_pos(), "mcl_burning:fire")
		local minp, maxp = mcl_burning.get_collisionbox(obj, false, storage)
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
		local fire_luaentity = fire_entity:get_luaentity()
		fire_luaentity:update_frame(obj, storage)

		for _, other in pairs(minetest.get_objects_inside_radius(fire_entity:get_pos(), 0)) do
			local other_luaentity = other:get_luaentity()
			if other_luaentity and other_luaentity.name == "mcl_burning:fire" and other_luaentity ~= fire_luaentity then
				other:remove()
				break
			end
		end
	end
end

function mcl_burning.extinguish(obj)
	if mcl_burning.is_burning(obj) then
		local storage = mcl_burning.get_storage(obj)
		if obj:is_player() then
			if storage.fire_hud_id then
				obj:hud_remove(storage.fire_hud_id)
			end
			mcl_burning.storage[obj] = {}
		else
			storage.burn_time = nil
			storage.burn_reason = nil
			storage.fire_damage_timer = nil
		end
	end
end

function mcl_burning.tick(obj, dtime, storage)
	if storage.burn_time then
		storage.burn_time = storage.burn_time - dtime

		if storage.burn_time <= 0 or mcl_burning.is_affected_by_rain(obj) or #mcl_burning.get_touching_nodes(obj, "group:puts_out_fire", storage) > 0 then
			mcl_burning.extinguish(obj)
			return true
		else
			storage.fire_damage_timer = storage.fire_damage_timer + dtime

			if storage.fire_damage_timer >= 1 then
				storage.fire_damage_timer = 0

				local luaentity = obj:get_luaentity()
				local is_mob = luaentity and luaentity._cmi_is_mob
				local hp = is_mob and luaentity.health or obj:get_hp()

				if hp > 0 then
					local do_damage = true

					if obj:is_player() then
						if mcl_potions.player_has_effect(obj, "fire_proof") then
							do_damage = false
						else
							local name = obj:get_player_name()
							armor.last_damage_types[name] = "fire"
							local deathmsg = S("@1 burned to death.", name)
							if storage.reason then
								deathmsg = S("@1 was burned by @2.", name, storage.reason)
							end
							mcl_death_messages.player_damage(obj, deathmsg)
						end
					elseif luaentity.fire_damage_resistant then
						do_damage = false
					end

					if do_damage then
						local new_hp = hp - 1
						if is_mob then
							luaentity.health = new_hp
						else
							obj:set_hp(new_hp)
						end
					end
				end
			end
		end
	end
end
