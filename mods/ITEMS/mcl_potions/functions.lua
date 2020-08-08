local S = minetest.get_translator("mcl_potions")

local is_invisible = {}
local is_poisoned = {}
local is_regenerating = {}
local is_strong = {}
local is_weak = {}
local is_water_breathing = {}
local is_leaping = {}
local is_swift = {}
local is_cat = {}
local is_fire_proof = {}


local function potions_set_hudbar(player)

	if is_poisoned[player] and is_regenerating[player] then
		hb.change_hudbar(player, "health", nil, nil, "hbhunger_icon_regen_poison.png", nil, "hudbars_bar_health.png")
	elseif is_poisoned[player] then
		hb.change_hudbar(player, "health", nil, nil, "hbhunger_icon_health_poison.png", nil, "hudbars_bar_health.png")
	elseif is_regenerating[player] then
		hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_regenerate.png", nil, "hudbars_bar_health.png")
	else
		hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_health.png", nil, "hudbars_bar_health.png")
	end

end



-- ███╗░░░███╗░█████╗░██╗███╗░░██╗  ███████╗███████╗███████╗███████╗░█████╗░████████╗
-- ████╗░████║██╔══██╗██║████╗░██║  ██╔════╝██╔════╝██╔════╝██╔════╝██╔══██╗╚══██╔══╝
-- ██╔████╔██║███████║██║██╔██╗██║  █████╗░░█████╗░░█████╗░░█████╗░░██║░░╚═╝░░░██║░░░
-- ██║╚██╔╝██║██╔══██║██║██║╚████║  ██╔══╝░░██╔══╝░░██╔══╝░░██╔══╝░░██║░░██╗░░░██║░░░
-- ██║░╚═╝░██║██║░░██║██║██║░╚███║  ███████╗██║░░░░░██║░░░░░███████╗╚█████╔╝░░░██║░░░
-- ╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝╚═╝░░╚══╝  ╚══════╝╚═╝░░░░░╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░
--
-- ░█████╗░██╗░░██╗███████╗░█████╗░██╗░░██╗███████╗██████╗░
-- ██╔══██╗██║░░██║██╔════╝██╔══██╗██║░██╔╝██╔════╝██╔══██╗
-- ██║░░╚═╝███████║█████╗░░██║░░╚═╝█████═╝░█████╗░░██████╔╝
-- ██║░░██╗██╔══██║██╔══╝░░██║░░██╗██╔═██╗░██╔══╝░░██╔══██╗
-- ╚█████╔╝██║░░██║███████╗╚█████╔╝██║░╚██╗███████╗██║░░██║
-- ░╚════╝░╚═╝░░╚═╝╚══════╝░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝

local is_player, entity, meta

minetest.register_globalstep(function(dtime)

	-- Check for invisible players
	for player, vals in pairs(is_invisible) do

		is_invisible[player].timer = is_invisible[player].timer + dtime

		if player:get_pos() then mcl_potions._add_spawner(player, "#B0B0B0") end

		if is_invisible[player].timer >= is_invisible[player].dur then
			mcl_potions.make_invisible(player, false)
			is_invisible[player] = nil
			if player:is_player() then
				meta = player:get_meta()
				meta:set_string("_is_invisible", minetest.serialize(is_invisible[player]))
			end
		end

	end

	-- Check for poisoned players
	for player, vals in pairs(is_poisoned) do

		is_player = player:is_player()
		entity = player:get_luaentity()

		is_poisoned[player].timer = is_poisoned[player].timer + dtime
		is_poisoned[player].hit_timer = (is_poisoned[player].hit_timer or 0) + dtime

		if player:get_pos() then mcl_potions._add_spawner(player, "#225533") end

		if is_poisoned[player].hit_timer >= is_poisoned[player].step then

			if entity and entity._cmi_is_mob then
				entity.health = math.max(entity.health - 1, 1)
				is_poisoned[player].hit_timer = 0
			elseif is_player then
				player:set_hp( math.max(player:get_hp() - 1, 1), { type = "punch", other = "poison"})
				is_poisoned[player].hit_timer = 0
			else -- if not player or mob then remove
				is_poisoned[player] = nil
			end

		end

		if is_poisoned[player].timer >= is_poisoned[player].dur then
			is_poisoned[player] = nil
			if is_player then
				meta = player:get_meta()
				meta:set_string("_is_poisoned", minetest.serialize(is_poisoned[player]))
				potions_set_hudbar(player)
			end
		end

	end

	-- Check for regnerating players
	for player, vals in pairs(is_regenerating) do

		is_player = player:is_player()
		entity = player:get_luaentity()

		is_regenerating[player].timer = is_regenerating[player].timer + dtime
		is_regenerating[player].heal_timer = (is_regenerating[player].heal_timer or 0) + dtime

		if player:get_pos() then mcl_potions._add_spawner(player, "#A52BB2") end

		if is_regenerating[player].heal_timer >= is_regenerating[player].step then

			if is_player then
				player:set_hp(math.min(player:get_properties().hp_max or 20, player:get_hp() + 1), { type = "set_hp", other = "regeneration" })
				is_regenerating[player].heal_timer = 0
			elseif entity and entity._cmi_is_mob then
				entity.health = math.min(entity.hp_max, entity.health + 1)
				is_regenerating[player].heal_timer = 0
			else -- stop regenerating if not a player or mob
				is_regenerating[player] = nil
			end

		end

		if is_regenerating[player].timer >= is_regenerating[player].dur then
			is_regenerating[player] = nil
			if is_player then
				meta = player:get_meta()
				meta:set_string("_is_regenerating", minetest.serialize(is_regenerating[player]))
				potions_set_hudbar(player)
			end
		end

	end

	-- Check for water breathing players
	for player, vals in pairs(is_water_breathing) do

		if player:is_player() then

			is_water_breathing[player].timer = is_water_breathing[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#0000AA") end

			if player:get_breath() then
				if player:get_breath() < 10 then player:set_breath(10) end
			end

			if is_water_breathing[player].timer >= is_water_breathing[player].dur then
				meta = player:get_meta()
				meta:set_string("_is_water_breathing", minetest.serialize(is_water_breathing[player]))
				is_water_breathing[player] = nil
			end

		else
			is_water_breathing[player] = nil
		end

	end

	-- Check for leaping players
	for player, vals in pairs(is_leaping) do

		if player:is_player() then

			is_leaping[player].timer = is_leaping[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#00CC33") end

			if is_leaping[player].timer >= is_leaping[player].dur then
				playerphysics.remove_physics_factor(player, "jump", "mcl_potions:leaping")
				is_leaping[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_leaping", minetest.serialize(is_leaping[player]))
			end

		else
			is_leaping[player] = nil
		end

	end

	-- Check for swift players
	for player, vals in pairs(is_swift) do

		if player:is_player() then

			is_swift[player].timer = is_swift[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#009999") end

			if is_swift[player].timer >= is_swift[player].dur then
				playerphysics.remove_physics_factor(player, "speed", "mcl_potions:swiftness")
				is_swift[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_swift", minetest.serialize(is_swift[player]))
			end

		else
			is_swift[player] = nil
		end

	end

	-- Check for Night Vision equipped players
	for player, vals in pairs(is_cat) do

		if player:is_player() then

			is_cat[player].timer = is_cat[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#1010AA") end
			if minetest.get_timeofday() > 0.8 or minetest.get_timeofday() < 0.2 then
				player:override_day_night_ratio(0.45)
			else player:override_day_night_ratio(nil)
			end

			if is_cat[player].timer >= is_cat[player].dur then
				is_cat[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_cat", minetest.serialize(is_cat[player]))
			end

		else
			is_cat[player] = nil
		end

	end

	-- Check for Fire Proof players
	for player, vals in pairs(is_fire_proof) do

		if player:is_player() then

			player = player or player:get_luaentity()

			is_fire_proof[player].timer = is_fire_proof[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#E0B050") end

			if is_fire_proof[player].timer >= is_fire_proof[player].dur then
				is_fire_proof[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_fire_proof", minetest.serialize(is_fire_proof[player]))
			end

		else
			is_fire_proof[player] = nil
		end

	end

	-- Check for Weak players
	for player, vals in pairs(is_weak) do

		if player:is_player() then

			is_weak[player].timer = is_weak[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#7700BB") end

			if is_weak[player].timer >= is_weak[player].dur then
				is_weak[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_weak", minetest.serialize(is_weak[player]))
			end

		else
			is_weak[player] = nil
		end

	end

	-- Check for Strong players
	for player, vals in pairs(is_strong) do

		if player:is_player() then

			is_strong[player].timer = is_strong[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#7700BB") end

			if is_strong[player].timer >= is_strong[player].dur then
				is_strong[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_strong", minetest.serialize(is_strong[player]))
			end

		else
			is_strong[player] = nil
		end

	end

end)


local is_fire_node = { ["mcl_core:lava_flowing"]=true,
	["mcl_core:lava_source"]=true,
	["mcl_fire:eternal_fire"]=true,
	["mcl_fire:fire"]=true,
	["mcl_nether:magma"]=true,
	["mcl_nether:nether_lava_source"]=true,
	["mcl_nether:nether_lava_flowing"]=true,
	["mcl_nether:nether_lava_source"]=true
}

-- Prevent damage to player with Fire Resistance enabled
minetest.register_on_player_hpchange(function(player, hp_change, reason)

	if is_fire_proof[player] and hp_change < 0 then
		-- This is a bit forced, but it assumes damage is taken by fire and avoids it
		-- also assumes any change in hp happens between calls to this function
		-- it's worth noting that you don't take damage from players in this case...
		local player_info = mcl_playerinfo[player:get_player_name()]

		if is_fire_node[player_info.node_head] or is_fire_node[player_info.node_feet] or is_fire_node[player_info.node_stand] then
			return 0
		else
			return hp_change
		end

	else
		return hp_change
	end

end, true)



-- ███████╗███████╗███████╗███████╗░█████╗░████████╗
-- ██╔════╝██╔════╝██╔════╝██╔════╝██╔══██╗╚══██╔══╝
-- █████╗░░█████╗░░█████╗░░█████╗░░██║░░╚═╝░░░██║░░░
-- ██╔══╝░░██╔══╝░░██╔══╝░░██╔══╝░░██║░░██╗░░░██║░░░
-- ███████╗██║░░░░░██║░░░░░███████╗╚█████╔╝░░░██║░░░
-- ╚══════╝╚═╝░░░░░╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░
--
-- ██╗░░░░░░█████╗░░█████╗░██████╗░░░░░██╗░██████╗░█████╗░██╗░░░██╗███████╗
-- ██║░░░░░██╔══██╗██╔══██╗██╔══██╗░░░██╔╝██╔════╝██╔══██╗██║░░░██║██╔════╝
-- ██║░░░░░██║░░██║███████║██║░░██║░░██╔╝░╚█████╗░███████║╚██╗░██╔╝█████╗░░
-- ██║░░░░░██║░░██║██╔══██║██║░░██║░██╔╝░░░╚═══██╗██╔══██║░╚████╔╝░██╔══╝░░
-- ███████╗╚█████╔╝██║░░██║██████╔╝██╔╝░░░██████╔╝██║░░██║░░╚██╔╝░░███████╗
-- ╚══════╝░╚════╝░╚═╝░░╚═╝╚═════╝░╚═╝░░░░╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░╚══════╝


function mcl_potions._reset_player_effects(player)

	if not player:is_player() then
		return
	end
	meta = player:get_meta()

	mcl_potions.make_invisible(player, false)
	is_invisible[player] = nil
	is_poisoned[player] = nil
	is_regenerating[player] = nil
	is_strong[player] = nil
	is_weak[player] = nil
	is_water_breathing[player] = nil

	is_leaping[player] = nil
	playerphysics.remove_physics_factor(player, "jump", "mcl_potions:leaping")

	is_swift[player] = nil
	playerphysics.remove_physics_factor(player, "speed", "mcl_potions:swiftness")

	is_cat[player] = nil
	player:override_day_night_ratio(nil)

	is_fire_proof[player] = nil

	potions_set_hudbar(player)

end

function mcl_potions._save_player_effects(player)

	if not player:is_player() then
		return
	end
	meta = player:get_meta()

	meta:set_string("_is_invisible", minetest.serialize(is_invisible[player]))
	meta:set_string("_is_poisoned", minetest.serialize(is_poisoned[player]))
	meta:set_string("_is_regenerating", minetest.serialize(is_regenerating[player]))
	meta:set_string("_is_strong", minetest.serialize(is_strong[player]))
	meta:set_string("_is_weak", minetest.serialize(is_weak[player]))
	meta:set_string("_is_water_breathing", minetest.serialize(is_water_breathing[player]))
	meta:set_string("_is_leaping", minetest.serialize(is_leaping[player]))
	meta:set_string("_is_swift", minetest.serialize(is_swift[player]))
	meta:set_string("_is_cat", minetest.serialize(is_cat[player]))
	meta:set_string("_is_fire_proof", minetest.serialize(is_fire_proof[player]))

end

function mcl_potions._load_player_effects(player)

	if not player:is_player() then
		return
	end
	meta = player:get_meta()

	if minetest.deserialize(meta:get_string("_is_invisible")) then
		is_invisible[player] = minetest.deserialize(meta:get_string("_is_invisible"))
		mcl_potions.make_invisible(player, true)
	end

	if minetest.deserialize(meta:get_string("_is_poisoned")) then
		is_poisoned[player] = minetest.deserialize(meta:get_string("_is_poisoned"))
	end

	if minetest.deserialize(meta:get_string("_is_regenerating")) then
		is_regenerating[player] = minetest.deserialize(meta:get_string("_is_regenerating"))
	end

	if minetest.deserialize(meta:get_string("_is_strong")) then
		is_strong[player] = minetest.deserialize(meta:get_string("_is_strong"))
	end

	if minetest.deserialize(meta:get_string("_is_weak")) then
		is_weak[player] = minetest.deserialize(meta:get_string("_is_weak"))
	end

	if minetest.deserialize(meta:get_string("_is_water_breathing")) then
		is_water_breathing[player] = minetest.deserialize(meta:get_string("_is_water_breathing"))
	end

	if minetest.deserialize(meta:get_string("_is_leaping")) then
		is_leaping[player] = minetest.deserialize(meta:get_string("_is_leaping"))
	end

	if minetest.deserialize(meta:get_string("_is_swift")) then
		is_swift[player] = minetest.deserialize(meta:get_string("_is_swift"))
	end

	if minetest.deserialize(meta:get_string("_is_cat")) then
		is_cat[player] = minetest.deserialize(meta:get_string("_is_cat"))
	end

	if minetest.deserialize(meta:get_string("_is_fire_proof")) then
		is_fire_proof[player] = minetest.deserialize(meta:get_string("_is_fire_proof"))
	end

	potions_set_hudbar(player)

end

minetest.register_on_leaveplayer( function(player)
	mcl_potions._save_player_effects(player)
	mcl_potions._reset_player_effects(player) -- clearout the buffer to prevent looking for a player not there
end)

minetest.register_on_dieplayer( function(player)
	mcl_potions._reset_player_effects(player)
end)

minetest.register_on_joinplayer( function(player)
	mcl_potions._reset_player_effects(player) -- make sure there are no wierd holdover effects
	mcl_potions._load_player_effects(player)
end)

minetest.register_on_shutdown(function()
	-- save player effects on server shutdown
	for _,player in ipairs(minetest.get_connected_players()) do
		mcl_potions._save_player_effects(player)
	end

end)


-- ░██████╗██╗░░░██╗██████╗░██████╗░░█████╗░██████╗░████████╗██╗███╗░░██╗░██████╗░
-- ██╔════╝██║░░░██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██║████╗░██║██╔════╝░
-- ╚█████╗░██║░░░██║██████╔╝██████╔╝██║░░██║██████╔╝░░░██║░░░██║██╔██╗██║██║░░██╗░
-- ░╚═══██╗██║░░░██║██╔═══╝░██╔═══╝░██║░░██║██╔══██╗░░░██║░░░██║██║╚████║██║░░╚██╗
-- ██████╔╝╚██████╔╝██║░░░░░██║░░░░░╚█████╔╝██║░░██║░░░██║░░░██║██║░╚███║╚██████╔╝
-- ╚═════╝░░╚═════╝░╚═╝░░░░░╚═╝░░░░░░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝╚═╝░░╚══╝░╚═════╝░
--
-- ███████╗██╗░░░██╗███╗░░██╗░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔════╝██║░░░██║████╗░██║██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- █████╗░░██║░░░██║██╔██╗██║██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██╔══╝░░██║░░░██║██║╚████║██║░░██╗░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██║░░░░░╚██████╔╝██║░╚███║╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═╝░░░░░░╚═════╝░╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░

function mcl_potions.is_obj_hit(self, pos)

	local entity
	for _,object in pairs(minetest.get_objects_inside_radius(pos, 1.1)) do

		entity = object:get_luaentity()

		if entity and entity.name ~= self.object:get_luaentity().name then

			if entity._cmi_is_mob then
				return true
			end

		elseif object:is_player() and self._thrower ~= object:get_player_name() then
			return true
		end

	end
	return false
end


function mcl_potions.make_invisible(player, toggle)

	if not player then
		return false
	end

	local is_player = player:is_player()
	local entity = player:get_luaentity()

	if toggle then -- hide player

		if player:is_player() then
			is_invisible[player].old_size = player:get_properties().visual_size
		elseif entity then
			is_invisible[player].old_size = entity.visual_size
		else -- if not a player or entity, do nothing
			return
		end

		player:set_properties({visual_size = {x = 0, y = 0}})
		player:set_nametag_attributes({color = {a = 0}})

	elseif is_invisible[player] then -- show player

		player:set_properties({visual_size = is_invisible[player].old_size})
		player:set_nametag_attributes({color = {r = 255, g = 255, b = 255, a = 255}})

	end

end


function mcl_potions._use_potion(item, obj, color)
	local d = 0.1
	local pos = obj:get_pos()
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
		amount = 1,
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



-- ██████╗░░█████╗░░██████╗███████╗  ██████╗░░█████╗░████████╗██╗░█████╗░███╗░░██╗
-- ██╔══██╗██╔══██╗██╔════╝██╔════╝  ██╔══██╗██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║
-- ██████╦╝███████║╚█████╗░█████╗░░  ██████╔╝██║░░██║░░░██║░░░██║██║░░██║██╔██╗██║
-- ██╔══██╗██╔══██║░╚═══██╗██╔══╝░░  ██╔═══╝░██║░░██║░░░██║░░░██║██║░░██║██║╚████║
-- ██████╦╝██║░░██║██████╔╝███████╗  ██║░░░░░╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║
-- ╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝  ╚═╝░░░░░░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝
--
-- ███████╗███████╗███████╗███████╗░█████╗░████████╗
-- ██╔════╝██╔════╝██╔════╝██╔════╝██╔══██╗╚══██╔══╝
-- █████╗░░█████╗░░█████╗░░█████╗░░██║░░╚═╝░░░██║░░░
-- ██╔══╝░░██╔══╝░░██╔══╝░░██╔══╝░░██║░░██╗░░░██║░░░
-- ███████╗██║░░░░░██║░░░░░███████╗╚█████╔╝░░░██║░░░
-- ╚══════╝╚═╝░░░░░╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░
--
-- ███████╗██╗░░░██╗███╗░░██╗░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔════╝██║░░░██║████╗░██║██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- █████╗░░██║░░░██║██╔██╗██║██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██╔══╝░░██║░░░██║██║╚████║██║░░██╗░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██║░░░░░╚██████╔╝██║░╚███║╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═╝░░░░░░╚═════╝░╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░


function mcl_potions.healing_func(player, hp)

	local obj = player:get_luaentity()

	if obj and obj.harmed_by_heal then hp = -hp end

	if hp > 0 then
		-- at least 1 HP
		if hp < 1 then
			hp = 1
		end

		if obj and obj._cmi_is_mob then
			obj.health = math.max(obj.health + hp, obj.hp_max)
		elseif player:is_player() then
			player:set_hp(math.min(player:get_hp() + hp, player:get_properties().hp_max), { type = "set_hp", other = "healing" })
		end

	elseif hp < 0 then
		if hp > -1 then
			hp = -1
		end

		if obj and obj._cmi_is_mob then
			obj.health = obj.health + hp
		elseif player:is_player() then
			player:set_hp(player:get_hp() + hp, { type = "punch", other = "harming" })
		end

	end

end

function mcl_potions.swiftness_func(player, factor, duration)

	if not player:get_meta() then
		return false
	end

	if not is_swift[player] then

		is_swift[player] = {dur = duration, timer = 0}
		playerphysics.add_physics_factor(player, "speed", "mcl_potions:swiftness", factor)

	else

		local victim = is_swift[player]

		playerphysics.add_physics_factor(player, "speed", "mcl_potions:swiftness", factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

end

function mcl_potions.leaping_func(player, factor, duration)

	if not player:get_meta() then
		return false
	end

	if not is_leaping[player] then

		is_leaping[player] = {dur = duration, timer = 0}
		playerphysics.add_physics_factor(player, "jump", "mcl_potions:leaping", factor)

	else

		local victim = is_leaping[player]

		playerphysics.add_physics_factor(player, "jump", "mcl_potions:leaping", factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

end


function mcl_potions.weakness_func(player, factor, duration)

	if not is_weak[player] then

		is_weak[player] = {dur = duration, timer = 0, factor = factor}

	else

		local victim = is_weak[player]

		victim.factor = factor
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

end


function mcl_potions.strength_func(player, factor, duration)

	if not is_strong[player] then

		is_strong[player] = {dur = duration, timer = 0, factor = factor}

	else

		local victim = is_strong[player]

		victim.factor = factor
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

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

	if player:is_player() then
		potions_set_hudbar(player)
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

	if player:is_player() then
		potions_set_hudbar(player)
	end

end


function mcl_potions.invisiblility_func(player, null, duration)

	if not is_invisible[player] then

		is_invisible[player] = {dur = duration, timer = 0}
		mcl_potions.make_invisible(player, true)

	else

		local victim = is_invisible[player]

		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

end

function mcl_potions.water_breathing_func(player, null, duration)

	if not is_water_breathing[player] then

		is_water_breathing[player] = {dur = duration, timer = 0}

	else

		local victim = is_water_breathing[player]

		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

end


function mcl_potions.fire_resistance_func(player, null, duration)

	if not is_fire_proof[player] then

		is_fire_proof[player] = {dur = duration, timer = 0}

	else

		local victim = is_fire_proof[player]
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

end


function mcl_potions.night_vision_func(player, null, duration)

	if not is_cat[player] then

		is_cat[player] = {dur = duration, timer = 0}

	else

		local victim = is_cat[player]

		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

end

function mcl_potions._extinguish_nearby_fire(pos, radius)
	local epos = {x=pos.x, y=pos.y+0.5, z=pos.z}
	local dnode = minetest.get_node({x=pos.x,y=pos.y-0.5,z=pos.z})
	if minetest.get_item_group(dnode.name, "fire") ~= 0 then
		epos.y = pos.y - 0.5
	end
	local exting = false
	-- No radius: Splash, extinguish epos and 4 nodes around
	if not radius then
		local dirs = {
			{x=0,y=0,z=0},
			{x=0,y=0,z=-1},
			{x=0,y=0,z=1},
			{x=-1,y=0,z=0},
			{x=1,y=0,z=0},
		}
		for d=1, #dirs do
			local tpos = vector.add(epos, dirs[d])
			local node = minetest.get_node(tpos)
			if minetest.get_item_group(node.name, "fire") ~= 0 then
				minetest.sound_play("fire_extinguish_flame", {pos = tpos, gain = 0.25, max_hear_distance = 16}, true)
				minetest.remove_node(tpos)
				exting = true
			end
		end
	-- Has radius: lingering, extinguish all nodes in area
	else
		local nodes = minetest.find_nodes_in_area(
			{x=epos.x-radius,y=epos.y,z=epos.z-radius},
			{x=epos.x+radius,y=epos.y,z=epos.z+radius},
			{"group:fire"})
		for n=1, #nodes do
			minetest.sound_play("fire_extinguish_flame", {pos = nodes[n], gain = 0.25, max_hear_distance = 16}, true)
			minetest.remove_node(nodes[n])
			exting = true
		end
	end
	return exting
end


-- ░█████╗░██╗░░██╗░█████╗░████████╗  ░█████╗░░█████╗░███╗░░░███╗███╗░░░███╗░█████╗░███╗░░██╗██████╗░░██████╗
-- ██╔══██╗██║░░██║██╔══██╗╚══██╔══╝  ██╔══██╗██╔══██╗████╗░████║████╗░████║██╔══██╗████╗░██║██╔══██╗██╔════╝
-- ██║░░╚═╝███████║███████║░░░██║░░░  ██║░░╚═╝██║░░██║██╔████╔██║██╔████╔██║███████║██╔██╗██║██║░░██║╚█████╗░
-- ██║░░██╗██╔══██║██╔══██║░░░██║░░░  ██║░░██╗██║░░██║██║╚██╔╝██║██║╚██╔╝██║██╔══██║██║╚████║██║░░██║░╚═══██╗
-- ╚█████╔╝██║░░██║██║░░██║░░░██║░░░  ╚█████╔╝╚█████╔╝██║░╚═╝░██║██║░╚═╝░██║██║░░██║██║░╚███║██████╔╝██████╔╝
-- ░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░  ░╚════╝░░╚════╝░╚═╝░░░░░╚═╝╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░╚═════╝░


local get_chat_function = {}

get_chat_function["poison"] = mcl_potions.poison_func
get_chat_function["regeneration"] = mcl_potions.regeneration_func
get_chat_function["invisibility"] = mcl_potions.invisiblility_func
get_chat_function["fire_resistance"] = mcl_potions.fire_resistance_func
get_chat_function["night_vision"] = mcl_potions.night_vision_func
get_chat_function["water_breathing"] = mcl_potions.water_breathing_func
get_chat_function["leaping"] = mcl_potions.leaping_func
get_chat_function["swiftness"] = mcl_potions.swiftness_func
get_chat_function["heal"] = mcl_potions.healing_func

minetest.register_chatcommand("effect",{
	params = S("<effect> <duration> [<factor>]"),
	description = S("Add a status effect to yourself. Arguments: <effect>: name of potion effect, e.g. poison. <duration>: duration in seconds. <factor>: effect strength multiplier (1 = 100%)"),
	privs = {server = true},
	func = function(name, params)

		local P = {}
		local i = 0
		for str in string.gmatch(params, "([^ ]+)") do
			i = i + 1
			P[i] = str
		end

		if not P[1] then
			return false, S("Missing effect parameter!")
		elseif not tonumber(P[2]) then
			return false, S("Missing or invalid duration parameter!")
		elseif P[3] and not tonumber(P[3]) then
			return false, S("Invalid factor parameter!")
		end
		-- Default factor = 1
		if not P[3] then
			P[3] = 1.0
		end

		if get_chat_function[P[1]] then
			get_chat_function[P[1]](minetest.get_player_by_name(name), tonumber(P[3]), tonumber(P[2]))
			return true
		else
			return false, S("@1 is not an available potion effect.", P[1])
		end

	 end,
})
