mcl_damage = {
	modifiers = {},
	types = {
		in_fire = {is_fire = true},
		lightning_bolt = {is_lightning = true},
		on_fire = {is_fire = true},
		lava = {is_fire = true},
		hot_floor = {is_fire = true},
		in_wall = {bypasses_armor = true},
		drown = {bypasses_armor = true},
		starve = {bypasses_armor = true, bypasses_magic = true},
		cactus = {},
		fall = {bypasses_armor = true},
		fly_into_wall = {bypasses_armor = true}, -- unused
		out_of_world = {bypasses_armor = true, bypasses_invulnerability = true},
		generic = {bypasses_armor = true},
		magic = {is_magic = true, bypasses_armor = true},
		wither = {bypasses_armor = true},		-- unused
		anvil = {},
		falling_node = {}, -- unused
		dragon_breath = {bypasses_armor = true}, -- unused
		mob = {},
		player = {},
		arrow = {is_projectile = true},
		fireball = {is_projectile = true, is_fire = true},
		thorns = {is_magic = true},
		explosion = {is_explosion = true},
		cramming = {bypasses_armor = true}, -- unused
		fireworks = {is_explosion = true}, -- unused
	}
}

local old_register_hpchange = minetest.register_on_player_hpchange

function minetest.register_on_player_hpchange(func, modifier)
	if modifier then
		mcl_damage.register_modifier(func, 0)
	else
		old_register_hpchange(func, modifier)
	end
end

function mcl_damage.register_modifier(func, priority)
	table.insert(mcl_damage.modifiers, {func = func, priority = priority or 0})
end

function mcl_damage.get_mcl_damage_reason(mt_reason)
	local mcl_reason = {
		type = "generic",
	}

	if mt_reason._mcl_type then
		mcl_reason.type = mt_reason._mcl_type
	elseif mt_reason.type == "fall" then
		mcl_reason.type = "fall"
	elseif mt_reason.type == "drown" then
		mcl_reason.type = "drown"
	elseif mt_reason.type == "punch" then
		mcl_reason.direct = mt_reason.object
		if mcl_reason.direct then
			local luaentity = mcl_reason.direct:get_luaentity()
			if luaentity then
				if luaentity._is_arrow then
					mcl_reason.type = "arrow"
				elseif luaentity._is_fireball then
					mcl_reason.type = "fireball"
				elseif luaentity._cmi_is_mob then
					mcl_reason.type = "mob"
				end
				mcl_reason.source = mcl_reason.source or luaentity._source_object
			else
				mcl_reason.type = "player"
			end
		end
	elseif mt_reason.type == "node_damage" and mt_reason.node then
		if minetest.get_item_group(mt_reason.node, "fire") > 0 then
			mcl_reason.type = "in_fire"
		end
		if minetest.get_item_group(mt_reason.node, "lava") > 0 then
			mcl_reason.type = "lava"
		end
	end

	for key, value in pairs(mt_reason) do
		if key:find("_mcl_") == 1 then
			mcl_reason[key:sub(6, #key)] = value
		end
	end

	mcl_reason.source = mcl_reason.source or mcl_reason.direct
	mcl_reason.flags = mcl_damage.types[mcl_reason.type]

	return mcl_reason
end

function mcl_damage.register_type(name, def)
	mcl_damage.types[name] = def
end

old_register_hpchange(function(player, hp_change, mt_reason)
	local mcl_reason = mcl_damage.get_mcl_damage_reason(mt_reason)

	for _, modf in ipairs(mcl_damage.modifiers) do
		hp_change = modf.func(player, hp_change, mt_reason, mcl_reason) or hp_change
		if hp_change == 0 then
			return 0
		end
	end

	return hp_change
end, true)

minetest.register_on_mods_loaded(function()
	table.sort(mcl_damage.modifiers, function(a, b) return a.priority < b.priority end)
end)

