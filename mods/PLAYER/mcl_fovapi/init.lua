---
--- Copyright 2023, Michieal.
--- License: GPL3. (Default Mineclone2 License)
--- Created by michieal.
--- DateTime: 12/2/23 5:47 AM
---

mcl_fovapi = {}

-- Handles default fov for players
mcl_fovapi.default_fov = {}
mcl_fovapi.registered_modifiers = {}
mcl_fovapi.applied_modifiers = {}

-- set to blank on join (for 3rd party mods)
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	-- Assign default FOV
	mcl_fovapi.default_fov[name] = player:get_fov()
end)

-- clear when player leaves
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	-- Remove default FOV
	mcl_fovapi.default_fov[name] = nil
end)

function mcl_fovapi.register_modifier(name, fov_factor, time, exclusive, on_start, on_end)
	local def = {
		modifer_name = name,
		fov = fov_factor,
		time = time,
		exclusive = exclusive,
		on_start = on_start,
		on_end = on_end,
	}

	mcl_fovapi.registered_modifiers[name] = def

end

function mcl_fovapi.apply_modifier(player, modifier_name)

	if modifier_name == nil then return end
	if mcl_fovapi.registered_modifiers[modifier_name] == nil then return end

	local modifier = mcl_fovapi.registered_modifiers[modifier_name]
	if modifier.on_start ~= nil then
		modifier.on_start(player)
	end

	mcl_fovapi.applied_modifiers[player][modifier_name] = true -- set the applied to be true.

	-- do modiifier apply code.



end

