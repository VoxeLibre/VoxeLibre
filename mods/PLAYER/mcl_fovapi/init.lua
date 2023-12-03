---
--- Copyright 2023, Michieal.
--- License: GPL3. (Default Mineclone2 License)
--- Created by michieal.
--- DateTime: 12/2/23 5:47 AM
---

-- Locals (and cached)
local DEBUG = false -- debug constant for troubleshooting.
local pairs = pairs

-- Globals
mcl_fovapi = {}

mcl_fovapi.default_fov = {} -- Handles default fov for players
mcl_fovapi.registered_modifiers = {}
mcl_fovapi.applied_modifiers = {}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	-- Assign default FOV
	mcl_fovapi.default_fov[name] = player:get_fov()

	if DEBUG then
		minetest.log("FOV::Player: " .. name .. "\nFOV: " .. player:get_fov())
	end

end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()

	-- handle clean up
	mcl_fovapi.default_fov[name] = nil
	mcl_fovapi.applied_modifiers[name] = nil
end)

function mcl_fovapi.register_modifier(name, fov_factor, time, is_multiplier, exclusive, on_start, on_end)
	if is_multiplier ~= true and is_multiplier ~= false then
		is_multiplier = true
	end
	if exclusive ~= true and exclusive ~= false then
		exclusive = false
	end
	local def = {
		modifer_name = name,
		fov_factor = fov_factor,
		time = time,
		is_multiplier = is_multiplier,
		exclusive = exclusive,
		on_start = on_start,
		on_end = on_end,
	}

	if DEBUG then
		minetest.log("FOV::Modifier Definition Registered:\n" .. dump(def))
	end

	mcl_fovapi.registered_modifiers[name] = def

end

function mcl_fovapi.apply_modifier(player, modifier_name)
	if player == nil then
		return
	end
	if modifier_name == nil then
		return
	end
	if mcl_fovapi.registered_modifiers[modifier_name] == nil then
		return
	end

	local modifier = mcl_fovapi.registered_modifiers[modifier_name]
	if modifier.on_start ~= nil then
		modifier.on_start(player)
	end

	mcl_fovapi.applied_modifiers[player][modifier_name] = true -- set the applied to be true.
	if DEBUG then
		minetest.log("FOV::Player Applied Modifiers :" .. dump(mcl_fovapi.applied_modifiers[player]))
	end
	local pname = player:get_player_name()

	if DEBUG then
		minetest.log("FOV::Modifier applied to player:" .. pname .. " modifier: " .. modifier_name)
	end

	-- modifier apply code.
	if modifier.exclusive == true then
		-- if exclusive, reset the player's fov, and apply the new fov.
		if modifier.is_multiplier then
			player:set_fov(0, false, 0)
		end
		player:set_fov(modifier.fov_factor, modifier.is_multiplier, modifier.time)
	else
		-- not exclusive? let's apply it in the mix.
		-- assume is_multiplier is true.
		player:set_fov(modifier.fov_factor, true, modifier.time)
	end

end

function mcl_fovapi.remove_modifier(player, modifier_name)
	if player == nil then
		return
	end

	if DEBUG then
		local name = player:get_player_name()
		minetest.log("FOV::Player: " .. name .. " modifier: " .. modifier_name .. "removed.")
	end

	mcl_fovapi.applied_modifiers[player][modifier_name] = nil

	-- check for other fov modifiers, and set them up, or reset to default.

	local applied = {}
	for k, _ in pairs(mcl_fovapi.applied_modifiers[player]) do
		applied[k] = mcl_fovapi.registered_modifiers[k]
	end

	if #applied == 0 then
		return
	end
	local exc = false
	for k in applied do
		if applied[k].exclusive == true then
			exc = applied[k]
			break
		end
	end

	-- handle exclusives.
	if exc ~= false then
		player:set_fov(exc.fov_factor, exc.is_multiplier, 0) -- we want this to be immediate.
	else
		-- handle normal fov modifiers.
		player:set_fov(0, false, 0) -- we want this to be immediate.
		for x in applied do
			player:set_fov(x.fov_factor, true, 0)
		end
	end

	if mcl_fovapi.registered_modifiers[modifier_name].on_end ~= nil then
		mcl_fovapi.registered_modifiers[modifier_name].on_end(player)
	end
end

function mcl_fovapi.remove_all_modifiers(player)
	if player == nil then
		return
	end

	if DEBUG then
		local name = player:get_player_name()
		minetest.log("FOV::Player: " .. name .. " modifiers have been reset.")
	end

	for x in mcl_fovapi.applied_modifiers[player] do
		x = nil
	end

	player:set_fov(0, false, 0)

end

--[[
Notes:
set_fov(fov, is_multiplier, transition_time): Sets player's FOV

    fov: FOV value.
    is_multiplier: Set to true if the FOV value is a multiplier. Defaults to false.
    transition_time: If defined, enables smooth FOV transition. Interpreted as the time (in seconds) to reach target FOV.
    	If set to 0, FOV change is instantaneous. Defaults to 0.
    Set fov to 0 to clear FOV override.

--]]
