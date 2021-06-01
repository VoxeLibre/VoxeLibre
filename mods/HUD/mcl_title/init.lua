--TODO: use SSCSM to reduce lag and network trafic (just send modchannel messages)
--TODO: fadeIn and fadeOut animation (needs engine change: SSCSM or native support)
--TODO: exactly mc like layout

local huds_idx = {}

huds_idx.title = {}
huds_idx.subtitle = {}
huds_idx.actionbar = {}

mcl_title = {}
mcl_title.defaults = {fadein = 10, stay = 70, fadeout = 20}
mcl_title.layout = {}
mcl_title.layout.title = {position = {x = 0.5, y = 0.5}, alignment = {x = 0, y = -1.3}, size = 5}
mcl_title.layout.subtitle = {position = {x = 0.5, y = 0.5}, alignment = {x = 0, y = 1.9}, size = 2}
mcl_title.layout.actionbar = {position = {x = 0.5, y = 1}, alignment = {x = 0, y = -15}, size = 1}

local get_color = mcl_util.get_color

local function gametick_to_secondes(gametick)
	return gametick / 20
end


--PARAMS SYSTEM
local player_params = {}

minetest.register_on_joinplayer(function(player)
	player_params[player] = {
		stay = gametick_to_secondes(mcl_title.defaults.stay),
		--fadeIn = gametick_to_secondes(mcl_title.defaults.fadein),
		--fadeOut = gametick_to_secondes(mcl_title.defaults.fadeout),
	}	
end)

minetest.register_on_leaveplayer(function(player)
	player_params = nil
end)

function mcl_title.params_set(player, data)
	player_params[player] = {
		stay = gametick_to_secondes(data.stay) or gametick_to_secondes(mcl_title.defaults.stay),
		--fadeIn = gametick_to_secondes(data.fadeIn) or gametick_to_secondes(mcl_title.defaults.fadein),
		--fadeOut = gametick_to_secondes(data.fadeOut) or gametick_to_secondes(mcl_title.defaults.fadeout),
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

	if huds_idx[type][player] then
		player:hud_remove(huds_idx[type][player])
	end

	--TODO: enable this code then Fleckenstein's pr get merged
	--TODO: be sure API is correctly used
	--[[
	local bold
	if data.bold == "true" then
		bold = true
	else
		bold = false
	end

	local italic
	if data.italic == "true" then
		italic = true
	else
		italic = false
	end]]

	local stay = mcl_title.params_get(player).stay

	huds_idx[type][player] = player:hud_add({
		hud_elem_type = "text",
		position  = mcl_title.layout[type].position,
		alignment = mcl_title.layout[type].alignment,
		text      = data.text,
		--bold = bold,
		--italic = italic,
		size      = {x = mcl_title.layout[type].size},
		number    = hex_color,
		z_index   = 1100,
	})

	minetest.after(stay, function()
		if huds_idx[type][player] then
			player:hud_remove(huds_idx[type][player])
		end
		huds_idx[type][player] = nil
	end)
	return true
end

function mcl_title.remove(player, type)
	if huds_idx[type][player] then
		player:hud_remove(huds_idx[type][player])
	end
	huds_idx[type][player] = nil
end

function mcl_title.clear(player)
	mcl_title.remove(player, "title")
	mcl_title.remove(player, "subtitle")
	mcl_title.remove(player, "actionbar")
end

minetest.register_on_dieplayer(function(player)
	mcl_title.clear(player)
end)


--TEMP STUFF!!
--TODO: remove then testing/tweaking done
minetest.register_chatcommand("title", {
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		mcl_title.set(player, "title", {text=param, color="gold"})
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