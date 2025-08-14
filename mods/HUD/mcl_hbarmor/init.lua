local S = minetest.get_translator(minetest.get_current_modname())

local math = math
local tonumber = tonumber

local get_connected_players = minetest.get_connected_players

local mcl_hbarmor = {
    -- HUD statbar values
    armor = {},
    -- Stores if player's HUD bar has been initialized so far.
    player_active = {},
    -- Time difference in seconds between updates to the HUD armor bar.
    -- Increase this number for slow servers.
    tick = 0.1,
    -- If true, the armor bar is hidden when the player does not wear any armor
    autohide = true,
}

local tick_config = minetest.settings:get("mcl_hbarmor_tick")

if tonumber(tick_config) then
	mcl_hbarmor.tick = tonumber(tick_config)
end


local function must_hide(playername, arm)
	return arm == 0
end

local function arm_printable(arm)
	return math.ceil(math.floor(arm+0.5))
end

local function custom_hud(player)
	local name = player:get_player_name()
	local ret = mcl_hbarmor.get_armor(player)
	if ret == false then
		minetest.log("error", "[mcl_hbarmor] Call to mcl_hbarmor.get_armor in custom_hud returned with false!")
		return
	end
	local arm = tonumber(mcl_hbarmor.armor[name])
	if not arm then
		arm = 0
	end
	local hide
	if mcl_hbarmor.autohide then
		hide = must_hide(name, arm)
	else
		hide = false
	end
	vl_hudbars.init_hudbar(player, "armor")
	if hide then
		vl_hudbars.hide(player, "armor")
	else
		vl_hudbars.change_value(player, "armor", arm_printable(arm))
		vl_hudbars.show(player, "armor")
	end
end

--register and define armor HUD bar
vl_hudbars.register_hudbar({
	identifier = "armor",
	sort_index = 4,
	on_right = false,
	direction = 0,
	layer_gap = 4,
	scale_y = 1,
	value_type = "proportional",
	is_compound = false,
	take_up_space = true,
	value_scale = 1,
	round_to_full_texture = false,
	z_index = 99,
	default_max_val = 20,
	default_value = 0,
	default_hidden = mcl_hbarmor.autohide,
	icon = "hbarmor_icon.png",
	bgicon = "hbarmor_bgicon.png",
	layers = 1,
	z_index_step = -1
})

function mcl_hbarmor.get_armor(player)
	local name = player:get_player_name()
	local pts = player:get_meta():get_int("mcl_armor:armor_points")
	if not pts then
		return false
	else
		mcl_hbarmor.set_armor(name, pts)
	end
	return true
end

function mcl_hbarmor.set_armor(player_name, pts)
	mcl_hbarmor.armor[player_name] = math.max(0, math.min(20, pts))
end

-- update hud elemtens if value has changed
local function update_hud(player)
	local name = player:get_player_name()
	--armor
	local arm = tonumber(mcl_hbarmor.armor[name])
	if not arm then
		arm = 0
		mcl_hbarmor.armor[name] = 0
	end
	if mcl_hbarmor.autohide then
		-- hide armor bar completely when there is none
		if must_hide(name, arm) then
			vl_hudbars.hide(player, "armor")
		else
			vl_hudbars.change_value(player, "armor", arm_printable(arm))
			vl_hudbars.show(player, "armor")
		end
	else
		vl_hudbars.change_value(player, "armor", arm_printable(arm))
	end
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	custom_hud(player)
	mcl_hbarmor.player_active[name] = true
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	mcl_hbarmor.player_active[name] = false
end)

local main_timer = 0
local timer = 0
minetest.register_globalstep(function(dtime)
    --TODO: replace this by playerglobalstep API then implemented
	main_timer = main_timer + dtime
	timer = timer + dtime
	if main_timer > mcl_hbarmor.tick or timer > 4 then
		if minetest.settings:get_bool("enable_damage") then
			if main_timer > mcl_hbarmor.tick then main_timer = 0 end
			for _,player in pairs(get_connected_players()) do
				local name = player:get_player_name()
				if mcl_hbarmor.player_active[name] == true then
					local ret = mcl_hbarmor.get_armor(player)
					if ret == false then
						minetest.log("error", "[mcl_hbarmor] Call to mcl_hbarmor.get_armor in globalstep returned with false!")
					end
					-- update all hud elements
					update_hud(player)
				end
			end
		end
	end
	if timer > 4 then timer = 0 end
end)
