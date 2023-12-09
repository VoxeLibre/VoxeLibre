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

function mcl_fovapi.register_modifier(def)
	if type(def.name) ~= "string" then
		error("Modifier name must be a string")
	end
	if type(def.fov_factor) ~= "number" then
		error("FOV factor must be a number")
	end
	if type(def.time) ~= "number" then
		error("Transition time must be a number")
	end
	if def.reset_time ~= nil and type(def.reset_time) ~= "number" then
		error("Reset time, if provided, must be a number")
	end

	if def.on_start ~= nil and type(def.on_start) ~= "function" then
		error("Callback on_start must be a function")
	end
	if def.on_end ~= nil and type(def.on_end) ~= "function" then
		error("Callback on_end must be a function")
	end

	local mdef = {}

	mdef.fov_factor = def.fov_factor
	mdef.time = def.time
	mdef.reset_time = def.reset_time or def.time

	if def.is_multiplier == false then mdef.is_multiplier = false
	else mdef.is_multiplier = true end
	if def.exclusive == true then mdef.exclusive = true
	else mdef.exclusive = false end

	mdef.on_start = def.on_start
	mdef.on_end = def.on_end

	if DEBUG then
		minetest.log("FOV::Modifier Definition Registered:\n" .. dump(def))
	end

	mcl_fovapi.registered_modifiers[def.name] = mdef

end

minetest.register_on_respawnplayer(function(player)
	mcl_fovapi.remove_all_modifiers(player:get_player_name())
end)

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
	if mcl_fovapi.applied_modifiers and mcl_fovapi.applied_modifiers[player] and mcl_fovapi.applied_modifiers[player][modifier_name] then
		if mcl_fovapi.applied_modifiers[player][modifier_name] and mcl_fovapi.applied_modifiers[player][modifier_name] == true then
			return
		end
	end

	if mcl_fovapi.applied_modifiers[player] == nil then
		mcl_fovapi.applied_modifiers[player] = {}
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
		local fov_factor, is_mult = player:get_fov()
		if fov_factor == 0 then
			fov_factor = 1
			is_mult = true
		end
		if modifier.is_multiplier or is_mult then
			fov_factor = fov_factor * modifier.fov_factor
		else
			fov_factor = (fov_factor + modifier.fov_factor) / 2
		end
		if modifier.is_multiplier and is_mult then
			player:set_fov(fov_factor, true, modifier.time)
		else
			player:set_fov(fov_factor, false, modififer.time)
		end
	end

end

function mcl_fovapi.remove_modifier(player, modifier_name)
	if player == nil then
		return
	end

	if mcl_fovapi.applied_modifiers[player][modifier_name] == nil then
		return
	end

	if DEBUG then
		local name = player:get_player_name()
		minetest.log("FOV::Player: " .. name .. " modifier: " .. modifier_name .. "removed.")
	end

	mcl_fovapi.applied_modifiers[player][modifier_name] = nil
	local modifier = mcl_fovapi.registered_modifiers[modifier_name]

	-- check for other fov modifiers, and set them up, or reset to default.

	local applied = {}
	for k, _ in pairs(mcl_fovapi.applied_modifiers[player]) do
		applied[k] = mcl_fovapi.registered_modifiers[k]
	end

	local elem = next
	if elem(applied) == nil then
		player:set_fov(0, false, modifier.reset_time)
		return
	end
	local exc = false
	for k, _ in pairs(applied) do
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
		local fov_factor = 1
		local non_multiplier_added = false
		for _, x in pairs(applied) do
			if not x.is_multiplier then
				if non_multiplier_added then
					fov_factor = (fov_factor + x.fov_factor) / 2
				else
					non_multiplier_added = true
					fov_factor = fov_factor * x.fov_factor
				end
			else
				fov_factor = fov_factor * x.fov_factor
			end
		end
		player:set_fov(fov_factor, not non_multiplier_added, modifier.reset_time)
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
	if mcl_fovapi.registered_modifiers[modifier_name].on_end ~= nil then
		mcl_fovapi.registered_modifiers[modifier_name].on_end(player)
	end

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
