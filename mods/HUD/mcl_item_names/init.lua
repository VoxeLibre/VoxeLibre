-- Based on 4itemnames mod by 4aiman

local wield = {}
local huds = {}
local dtimes = {}
local dlimit = 3  -- HUD element will be hidden after this many seconds
local air_hud_mod = minetest.get_modpath("4air")
local hud_mod = minetest.get_modpath("hud")
local hudbars_mod = minetest.get_modpath("hudbars")

local function set_hud(player)
	local player_name = player:get_player_name() 
	local off = {x=0, y=-70}
	if air_hud_mod or hud_mod then
		off.y = off.y - 20
	elseif hudbars_mod then
		off.y = off.y + 13
	end
	huds[player_name] = player:hud_add({
		hud_elem_type = "text",
		position = {x=0.5, y=1},
		offset = off,
		alignment = {x=0, y=0},
		number = 0xFFFFFF ,
		text = "",
	})
end

minetest.register_on_joinplayer(function(player)
	minetest.after(0, set_hud, player)
end)

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		local wstack = player:get_wielded_item():get_name()

		if dtimes[player_name] and dtimes[player_name] < dlimit then
			dtimes[player_name] = dtimes[player_name] + dtime
			if dtimes[player_name] > dlimit and huds[player_name] then
				player:hud_change(huds[player_name], 'text', "")
			end
		end

		if wstack ~= wield[player_name] then
			wield[player_name] = wstack
			dtimes[player_name] = 0
			if huds[player_name] then 
				local def = minetest.registered_items[wstack]
				local desc = def and def.description or ""
				player:hud_change(huds[player_name], 'text', desc)
			end
		end
	end
end)

