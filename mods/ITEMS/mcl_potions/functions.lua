local EF = {}
EF.invisible = {}
EF.poisoned = {}
EF.regenerating = {}
EF.strong = {}
EF.weak = {}
EF.water_breathing = {}
EF.leaping = {}
EF.swift = {} -- for swiftness AND slowness
EF.night_vision = {}
EF.fire_proof = {}

local EFFECT_TYPES = 0
for _,_ in pairs(EF) do
	EFFECT_TYPES = EFFECT_TYPES + 1
end

local icon_ids = {}

local function potions_set_hudbar(player)

	if EF.poisoned[player] and EF.regenerating[player] then
		hb.change_hudbar(player, "health", nil, nil, "hbhunger_icon_regen_poison.png", nil, "hudbars_bar_health.png")
	elseif EF.poisoned[player] then
		hb.change_hudbar(player, "health", nil, nil, "hbhunger_icon_health_poison.png", nil, "hudbars_bar_health.png")
	elseif EF.regenerating[player] then
		hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_regenerate.png", nil, "hudbars_bar_health.png")
	else
		hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_health.png", nil, "hudbars_bar_health.png")
	end

end

local function potions_init_icons(player)
	local name = player:get_player_name()
	icon_ids[name] = {}
	for e=1, EFFECT_TYPES do
		local x = -7 + -38 * e
		local id = player:hud_add({
			hud_elem_type = "image",
			text = "blank.png",
			position = { x = 1, y = 0 },
			offset = { x = x, y = 272 },
			scale = { x = 2, y = 2 },
			alignment = { x = 1, y = 1 },
			z_index = 100,
		})
		table.insert(icon_ids[name], id)
	end
end

local function potions_set_icons(player)
	local name = player:get_player_name()
	if not icon_ids[name] then
		return
	end
	local active_effects = {}
	for effect_name, effect in pairs(EF) do
		if effect[player] then
			table.insert(active_effects, effect_name)
		end
	end

	for i=1, EFFECT_TYPES do
		local icon = icon_ids[name][i]
		local effect_name = active_effects[i]
		if effect_name == "swift" and EF.swift[player].is_slow then
			effect_name = "slow"
		end
		if effect_name == nil then
			player:hud_change(icon, "text", "blank.png")
		else
			player:hud_change(icon, "text", "mcl_potions_effect_"..effect_name..".png")
		end
	end

end

local function potions_set_hud(player)

	potions_set_hudbar(player)
	potions_set_icons(player)

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
	for player, vals in pairs(EF.invisible) do

		EF.invisible[player].timer = EF.invisible[player].timer + dtime

		if player:get_pos() then mcl_potions._add_spawner(player, "#B0B0B0") end

		if EF.invisible[player].timer >= EF.invisible[player].dur then
			mcl_potions.make_invisible(player, false)
			EF.invisible[player] = nil
			if player:is_player() then
				meta = player:get_meta()
				meta:set_string("_is_invisible", minetest.serialize(EF.invisible[player]))
			end
		end

	end

	-- Check for poisoned players
	for player, vals in pairs(EF.poisoned) do

		is_player = player:is_player()
		entity = player:get_luaentity()

		EF.poisoned[player].timer = EF.poisoned[player].timer + dtime
		EF.poisoned[player].hit_timer = (EF.poisoned[player].hit_timer or 0) + dtime

		if player:get_pos() then mcl_potions._add_spawner(player, "#225533") end

		if EF.poisoned[player].hit_timer >= EF.poisoned[player].step then
			if mcl_util.get_hp(player) - 1 > 0 then
				mcl_util.deal_damage(player, 1, {type = "magic"})
			end
			EF.poisoned[player].hit_timer = 0
		end

		if EF.poisoned[player] and EF.poisoned[player].timer >= EF.poisoned[player].dur then
			EF.poisoned[player] = nil
			if is_player then
				meta = player:get_meta()
				meta:set_string("_is_poisoned", minetest.serialize(EF.poisoned[player]))
				potions_set_hud(player)
			end
		end

	end

	-- Check for regnerating players
	for player, vals in pairs(EF.regenerating) do

		is_player = player:is_player()
		entity = player:get_luaentity()

		EF.regenerating[player].timer = EF.regenerating[player].timer + dtime
		EF.regenerating[player].heal_timer = (EF.regenerating[player].heal_timer or 0) + dtime

		if player:get_pos() then mcl_potions._add_spawner(player, "#A52BB2") end

		if EF.regenerating[player].heal_timer >= EF.regenerating[player].step then

			if is_player then
				player:set_hp(math.min(player:get_properties().hp_max or 20, player:get_hp() + 1), { type = "set_hp", other = "regeneration" })
				EF.regenerating[player].heal_timer = 0
			elseif entity and entity._cmi_is_mob then
				entity.health = math.min(entity.hp_max, entity.health + 1)
				EF.regenerating[player].heal_timer = 0
			else -- stop regenerating if not a player or mob
				EF.regenerating[player] = nil
			end

		end

		if EF.regenerating[player] and EF.regenerating[player].timer >= EF.regenerating[player].dur then
			EF.regenerating[player] = nil
			if is_player then
				meta = player:get_meta()
				meta:set_string("_is_regenerating", minetest.serialize(EF.regenerating[player]))
				potions_set_hud(player)
			end
		end

	end

	-- Check for water breathing players
	for player, vals in pairs(EF.water_breathing) do

		if player:is_player() then

			EF.water_breathing[player].timer = EF.water_breathing[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#0000AA") end

			if player:get_breath() then
				if player:get_breath() < 10 then player:set_breath(10) end
			end

			if EF.water_breathing[player].timer >= EF.water_breathing[player].dur then
				meta = player:get_meta()
				meta:set_string("_is_water_breathing", minetest.serialize(EF.water_breathing[player]))
				EF.water_breathing[player] = nil
			end

		else
			EF.water_breathing[player] = nil
		end

	end

	-- Check for leaping players
	for player, vals in pairs(EF.leaping) do

		if player:is_player() then

			EF.leaping[player].timer = EF.leaping[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#00CC33") end

			if EF.leaping[player].timer >= EF.leaping[player].dur then
				playerphysics.remove_physics_factor(player, "jump", "mcl_potions:leaping")
				EF.leaping[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_leaping", minetest.serialize(EF.leaping[player]))
			end

		else
			EF.leaping[player] = nil
		end

	end

	-- Check for swift players
	for player, vals in pairs(EF.swift) do

		if player:is_player() then

			EF.swift[player].timer = EF.swift[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#009999") end

			if EF.swift[player].timer >= EF.swift[player].dur then
				playerphysics.remove_physics_factor(player, "speed", "mcl_potions:swiftness")
				EF.swift[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_swift", minetest.serialize(EF.swift[player]))
			end

		else
			EF.swift[player] = nil
		end

	end

	-- Check for Night Vision equipped players
	for player, vals in pairs(EF.night_vision) do

		if player:is_player() then

			EF.night_vision[player].timer = EF.night_vision[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#1010AA") end

			if EF.night_vision[player].timer >= EF.night_vision[player].dur then
				EF.night_vision[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_cat", minetest.serialize(EF.night_vision[player]))
				meta:set_int("night_vision", 0)
			end
			mcl_weather.skycolor.update_sky_color({player})

		else
			EF.night_vision[player] = nil
		end

	end

	-- Check for Fire Proof players
	for player, vals in pairs(EF.fire_proof) do

		if player:is_player() then

			player = player or player:get_luaentity()

			EF.fire_proof[player].timer = EF.fire_proof[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#E0B050") end

			if EF.fire_proof[player].timer >= EF.fire_proof[player].dur then
				EF.fire_proof[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_fire_proof", minetest.serialize(EF.fire_proof[player]))
			end

		else
			EF.fire_proof[player] = nil
		end

	end

	-- Check for Weak players
	for player, vals in pairs(EF.weak) do

		if player:is_player() then

			EF.weak[player].timer = EF.weak[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#7700BB") end

			if EF.weak[player].timer >= EF.weak[player].dur then
				EF.weak[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_weak", minetest.serialize(EF.weak[player]))
			end

		else
			EF.weak[player] = nil
		end

	end

	-- Check for Strong players
	for player, vals in pairs(EF.strong) do

		if player:is_player() then

			EF.strong[player].timer = EF.strong[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#7700BB") end

			if EF.strong[player].timer >= EF.strong[player].dur then
				EF.strong[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_strong", minetest.serialize(EF.strong[player]))
			end

		else
			EF.strong[player] = nil
		end

	end

end)

-- Prevent damage to player with Fire Resistance enabled
mcl_damage.register_modifier(function(obj, damage, reason)
	if EF.fire_proof[obj] and not reason.flags.bypasses_magic and reason.flags.is_fire then
		return 0
	end
end, -50)



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


function mcl_potions._reset_player_effects(player, set_hud)

	if not player:is_player() then
		return
	end
	meta = player:get_meta()

	mcl_potions.make_invisible(player, false)
	EF.invisible[player] = nil
	EF.poisoned[player] = nil
	EF.regenerating[player] = nil
	EF.strong[player] = nil
	EF.weak[player] = nil
	EF.water_breathing[player] = nil

	EF.leaping[player] = nil
	playerphysics.remove_physics_factor(player, "jump", "mcl_potions:leaping")

	EF.swift[player] = nil
	playerphysics.remove_physics_factor(player, "speed", "mcl_potions:swiftness")

	EF.night_vision[player] = nil
	meta:set_int("night_vision", 0)
	mcl_weather.skycolor.update_sky_color({player})

	EF.fire_proof[player] = nil

	if set_hud ~= false then
		potions_set_hud(player)
	end

end

function mcl_potions._save_player_effects(player)

	if not player:is_player() then
		return
	end
	meta = player:get_meta()

	meta:set_string("_is_invisible", minetest.serialize(EF.invisible[player]))
	meta:set_string("_is_poisoned", minetest.serialize(EF.poisoned[player]))
	meta:set_string("_is_regenerating", minetest.serialize(EF.regenerating[player]))
	meta:set_string("_is_strong", minetest.serialize(EF.strong[player]))
	meta:set_string("_is_weak", minetest.serialize(EF.weak[player]))
	meta:set_string("_is_water_breathing", minetest.serialize(EF.water_breathing[player]))
	meta:set_string("_is_leaping", minetest.serialize(EF.leaping[player]))
	meta:set_string("_is_swift", minetest.serialize(EF.swift[player]))
	meta:set_string("_is_cat", minetest.serialize(EF.night_vision[player]))
	meta:set_string("_is_fire_proof", minetest.serialize(EF.fire_proof[player]))

end

function mcl_potions._load_player_effects(player)

	if not player:is_player() then
		return
	end
	meta = player:get_meta()

	if minetest.deserialize(meta:get_string("_is_invisible")) then
		EF.invisible[player] = minetest.deserialize(meta:get_string("_is_invisible"))
		mcl_potions.make_invisible(player, true)
	end

	if minetest.deserialize(meta:get_string("_is_poisoned")) then
		EF.poisoned[player] = minetest.deserialize(meta:get_string("_is_poisoned"))
	end

	if minetest.deserialize(meta:get_string("_is_regenerating")) then
		EF.regenerating[player] = minetest.deserialize(meta:get_string("_is_regenerating"))
	end

	if minetest.deserialize(meta:get_string("_is_strong")) then
		EF.strong[player] = minetest.deserialize(meta:get_string("_is_strong"))
	end

	if minetest.deserialize(meta:get_string("_is_weak")) then
		EF.weak[player] = minetest.deserialize(meta:get_string("_is_weak"))
	end

	if minetest.deserialize(meta:get_string("_is_water_breathing")) then
		EF.water_breathing[player] = minetest.deserialize(meta:get_string("_is_water_breathing"))
	end

	if minetest.deserialize(meta:get_string("_is_leaping")) then
		EF.leaping[player] = minetest.deserialize(meta:get_string("_is_leaping"))
	end

	if minetest.deserialize(meta:get_string("_is_swift")) then
		EF.swift[player] = minetest.deserialize(meta:get_string("_is_swift"))
	end

	if minetest.deserialize(meta:get_string("_is_cat")) then
		EF.night_vision[player] = minetest.deserialize(meta:get_string("_is_cat"))
	end

	if minetest.deserialize(meta:get_string("_is_fire_proof")) then
		EF.fire_proof[player] = minetest.deserialize(meta:get_string("_is_fire_proof"))
	end

end

-- Returns true if player has given effect
function mcl_potions.player_has_effect(player, effect_name)
	if not EF[effect_name] then
		return false
	end
	return EF[effect_name][player] ~= nil
end

minetest.register_on_leaveplayer( function(player)
	mcl_potions._save_player_effects(player)
	mcl_potions._reset_player_effects(player) -- clearout the buffer to prevent looking for a player not there
	icon_ids[player:get_player_name()] = nil
end)

minetest.register_on_dieplayer( function(player)
	mcl_potions._reset_player_effects(player)
	potions_set_hud(player)
end)

minetest.register_on_joinplayer( function(player)
	mcl_potions._reset_player_effects(player, false) -- make sure there are no wierd holdover effects
	mcl_potions._load_player_effects(player)
	potions_init_icons(player)
	-- .after required because player:hud_change doesn't work when called
	-- in same tick as player:hud_add
	-- (see <https://github.com/minetest/minetest/pull/9611>)
	-- FIXME: Remove minetest.after
	minetest.after(3, function(player)
		if player and player:is_player() then
			potions_set_hud(player)
		end
	end, player)
end)

minetest.register_on_shutdown(function()
	-- save player effects on server shutdown
	for _,player in pairs(minetest.get_connected_players()) do
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
	local playername = player:get_player_name()
	local skin_file = ""

	if toggle then -- hide player

		skin_file = "mobs_mc_empty.png"

		if entity then
			EF.invisible[player].old_size = entity.visual_size
		elseif not player:is_player() then -- if not a player or entity, do nothing
			return
		end

		if player:is_player() then
			mcl_player.player_set_skin(player, "mobs_mc_empty.png")
		elseif not player:is_player() then
			player:set_properties({visual_size = {x = 0, y = 0}})
		end
		player:set_nametag_attributes({color = {a = 0}})

	elseif EF.invisible[player] then -- show player

		if player:is_player() then
			mcl_skins.update_player_skin(player)
		elseif not player:is_player() then
			player:set_properties({visual_size = EF.invisible[player].old_size})
		end
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
		texture = "mcl_particles_effect.png^[colorize:"..color..":127",
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
		texture = "mcl_particles_effect.png^[colorize:"..color..":127",
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

	if player:get_hp() == 0 then
		return
	end

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

		mcl_util.deal_damage(player, -hp, {type = "magic"})
	end

end

function mcl_potions.swiftness_func(player, factor, duration)

	if not player:get_meta() then
		return false
	end

	if not EF.swift[player] then

		EF.swift[player] = {dur = duration, timer = 0, is_slow = factor < 1}
		playerphysics.add_physics_factor(player, "speed", "mcl_potions:swiftness", factor)

	else

		local victim = EF.swift[player]

		playerphysics.add_physics_factor(player, "speed", "mcl_potions:swiftness", factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0
		victim.is_slow = factor < 1

	end

	if player:is_player() then
		potions_set_icons(player)
	end

end

function mcl_potions.leaping_func(player, factor, duration)

	if not player:get_meta() then
		return false
	end

	if not EF.leaping[player] then

		EF.leaping[player] = {dur = duration, timer = 0}
		playerphysics.add_physics_factor(player, "jump", "mcl_potions:leaping", factor)

	else

		local victim = EF.leaping[player]

		playerphysics.add_physics_factor(player, "jump", "mcl_potions:leaping", factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_icons(player)
	end

end


function mcl_potions.weakness_func(player, factor, duration)

	if not EF.weak[player] then

		EF.weak[player] = {dur = duration, timer = 0, factor = factor}

	else

		local victim = EF.weak[player]

		victim.factor = factor
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_icons(player)
	end

end


function mcl_potions.strength_func(player, factor, duration)

	if not EF.strong[player] then

		EF.strong[player] = {dur = duration, timer = 0, factor = factor}

	else

		local victim = EF.strong[player]

		victim.factor = factor
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_icons(player)
	end

end


function mcl_potions.poison_func(player, factor, duration)

	if not EF.poisoned[player] then

		EF.poisoned[player] = {step = factor, dur = duration, timer = 0}

	else

		local victim = EF.poisoned[player]

		victim.step = math.min(victim.step, factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_hud(player)
	end

end


function mcl_potions.regeneration_func(player, factor, duration)

	if not EF.regenerating[player] then

		EF.regenerating[player] = {step = factor, dur = duration, timer = 0}

	else

		local victim = EF.regenerating[player]

		victim.step = math.min(victim.step, factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_hud(player)
	end

end


function mcl_potions.invisiblility_func(player, null, duration)

	if not EF.invisible[player] then

		EF.invisible[player] = {dur = duration, timer = 0}
		mcl_potions.make_invisible(player, true)

	else

		local victim = EF.invisible[player]

		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_icons(player)
	end

end

function mcl_potions.water_breathing_func(player, null, duration)

	if not EF.water_breathing[player] then

		EF.water_breathing[player] = {dur = duration, timer = 0}

	else

		local victim = EF.water_breathing[player]

		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_icons(player)
	end

end


function mcl_potions.fire_resistance_func(player, null, duration)

	if not EF.fire_proof[player] then

		EF.fire_proof[player] = {dur = duration, timer = 0}

	else

		local victim = EF.fire_proof[player]
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_icons(player)
	end

end


function mcl_potions.night_vision_func(player, null, duration)

	meta = player:get_meta()
	if not EF.night_vision[player] then

		EF.night_vision[player] = {dur = duration, timer = 0}

	else

		local victim = EF.night_vision[player]

		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	is_player = player:is_player()
	if is_player then
		meta:set_int("night_vision", 1)
	else
		return -- Do not attempt to set night_vision on mobs
	end
	mcl_weather.skycolor.update_sky_color({player})

	if player:is_player() then
		potions_set_icons(player)
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
