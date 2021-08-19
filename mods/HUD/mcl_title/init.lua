--Based on:
--https://www.digminecraft.com/game_commands/title_command.php
--https://youtu.be/oVrtQRO2hpY

--TODO: use SSCSM to reduce lag and network trafic (just send modchannel messages)
--TODO: fadeIn and fadeOut animation (needs engine change: SSCSM or native support)
--TODO: allow obfuscating text (needs engine change: SSCSM or native support)
--TODO: allow colorizing and styling of part of the text (NEEDS ENGINE CHANGE!!!)
--TODO: exactly mc like layout

--Note that the table storing timeouts use playername as index insteed of player objects (faster)
--This is intended in order to speedup the process of removing HUD elements the the timeout is up

local huds_idx = {}

local hud_hide_timeouts = {}

hud_hide_timeouts.title = {}
hud_hide_timeouts.subtitle = {}
hud_hide_timeouts.actionbar = {}

huds_idx.title = {}
huds_idx.subtitle = {}
huds_idx.actionbar = {}

mcl_title = {}
mcl_title.defaults = {fadein = 10, stay = 70, fadeout = 20}
mcl_title.layout = {}
mcl_title.layout.title = {position = {x = 0.5, y = 0.5}, alignment = {x = 0, y = -1.3}, size = 7}
mcl_title.layout.subtitle = {position = {x = 0.5, y = 0.5}, alignment = {x = 0, y = 1.7}, size = 4}
mcl_title.layout.actionbar = {position = {x = 0.5, y = 1}, alignment = {x = 0, y = 0}, size = 1}

local get_color = mcl_util.get_color

--local string = string
local pairs = pairs

local function gametick_to_secondes(gametick)
	if gametick then
		return gametick / 20
	else
		return nil
	end
end

--https://github.com/minetest/minetest/blob/b3b075ea02034306256b486dd45410aa765f035a/doc/lua_api.txt#L8477
--[[
local function style_to_bits(bold, italic)
	if bold then
		if italic then
			return 3
		else
			return 1
		end
	else
		if italic then
			return 2
		else
			return 0
		end
	end
end
]]

--PARAMS SYSTEM
local player_params = {}

minetest.register_on_joinplayer(function(player)
	--local playername = player:get_player_name()
	player_params[player] = {
		stay = mcl_title.defaults.stay,
		--fadeIn = mcl_title.defaults.fadein,
		--fadeOut = mcl_title.defaults.fadeout,
	}
	local _, hex_color = get_color("white")
	huds_idx.title[player] = player:hud_add({
		hud_elem_type = "text",
		position  = mcl_title.layout.title.position,
		alignment = mcl_title.layout.title.alignment,
		text      = "",
		--style = 0,
		size      = {x = mcl_title.layout.title.size},
		number    = hex_color,
		z_index   = 100,
	})
	huds_idx.subtitle[player] = player:hud_add({
		hud_elem_type = "text",
		position  = mcl_title.layout.subtitle.position,
		alignment = mcl_title.layout.subtitle.alignment,
		text      = "",
		--style = 0,
		size      = {x = mcl_title.layout.subtitle.size},
		number    = hex_color,
		z_index   = 100,
	})
	huds_idx.actionbar[player] = player:hud_add({
		hud_elem_type = "text",
		position  = mcl_title.layout.actionbar.position,
		offset    = {x = 0, y = -210},
		alignment = mcl_title.layout.actionbar.alignment,
		--style = 0,
		text      = "",
		size      = {x = mcl_title.layout.actionbar.size},
		number    = hex_color,
		z_index   = 100,
	})
end)

minetest.register_on_leaveplayer(function(player)
	local playername = player:get_player_name()

	--remove player params from the list
	player_params[player] = nil

	--remove HUD idx from the list (HUD elements are removed by the engine)
	huds_idx.title[player] = nil
	huds_idx.subtitle[player] = nil
	huds_idx.actionbar[player] = nil

	--remove timers from list
	hud_hide_timeouts.title[playername] = nil
	hud_hide_timeouts.subtitle[playername] = nil
	hud_hide_timeouts.actionbar[playername] = nil
end)

function mcl_title.params_set(player, data)
	player_params[player] = {
		stay = data.stay or mcl_title.defaults.stay,
		--fadeIn = data.fadeIn or mcl_title.defaults.fadein,
		--fadeOut = data.fadeOut or mcl_title.defaults.fadeout,
	}
end

function mcl_title.params_get(player)
	return player_params[player]
end

--API FUNCTIONS

function mcl_title.set(player, type, data)
	if not data.color then
		data.color = "white"
	end
	local _, hex_color = get_color(data.color)
	if not hex_color then
		return false
	end

	player:hud_change(huds_idx[type][player], "text", data.text)
	player:hud_change(huds_idx[type][player], "number", hex_color)

	--apply bold and italic
	--player:hud_change(huds_idx[type][player], "style", style_to_bits(data.bold, data.italic))

	hud_hide_timeouts[type][player:get_player_name()] = gametick_to_secondes(data.stay) or gametick_to_secondes(mcl_title.params_get(player).stay)
	return true
end

function mcl_title.remove(player, type)
	if player then
		player:hud_change(huds_idx[type][player], "text", "")
		--player:hud_change(huds_idx[type][player], "style", 0) --no styling
	end
end

function mcl_title.clear(player)
	mcl_title.remove(player, "title")
	mcl_title.remove(player, "subtitle")
	mcl_title.remove(player, "actionbar")
end

minetest.register_on_dieplayer(function(player)
	mcl_title.clear(player)
end)

minetest.register_globalstep(function(dtime)
	local new_timeouts = {
		title = {},
		subtitle = {},
		actionbar = {},
	}
	for element, content in pairs(hud_hide_timeouts) do
		for name, timeout in pairs(content) do
			timeout = timeout - dtime
			if timeout <= 0 then
				local player = minetest.get_player_by_name(name)
				mcl_title.remove(player, element)
			else
				new_timeouts[element][name] = timeout
			end
		end
	end
	hud_hide_timeouts = new_timeouts
end)


--DEBUG STUFF!!
--[[
minetest.register_chatcommand("title", {
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		mcl_title.set(player, "title", {text=param, color="gold", bold=true, italic=true})
	end,
})

minetest.register_chatcommand("subtitle", {
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		mcl_title.set(player, "subtitle", {text=param, color="gold"})
	end,
})

minetest.register_chatcommand("actionbar", {
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		mcl_title.set(player, "actionbar", {text=param, color="gold"})
	end,
})

minetest.register_chatcommand("timeout", {
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		mcl_title.params_set(player, {stay = 600})
	end,
})

minetest.register_chatcommand("all", {
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		mcl_title.params_set(player, {stay = 600})
		mcl_title.set(player, "title", {text=param, color="gold"})
		mcl_title.set(player, "subtitle", {text=param, color="gold"})
		mcl_title.set(player, "actionbar", {text=param, color="gold"})
	end,
})
]]