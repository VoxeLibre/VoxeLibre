local S
if (minetest.get_modpath("intllib")) then
	S = intllib.Getter()
else
	S = function ( s ) return s end
end

if (not armor) or (not armor.def) then
	minetest.log("error", "[hbarmor] Outdated 3d_armor version. Please update your version of 3d_armor!")
end

local hbarmor = {}

-- HUD statbar values
hbarmor.armor = {}

-- Stores if player's HUD bar has been initialized so far.
hbarmor.player_active = {}

-- Time difference in seconds between updates to the HUD armor bar.
-- Increase this number for slow servers.
hbarmor.tick = 0.1

-- If true, the armor bar is hidden when the player does not wear any armor
hbarmor.autohide = true

--load custom settings
local set = minetest.settings:get_bool("hbarmor_autohide")
if set ~= nil then
	hbarmor.autohide = set
end

set = minetest.settings:get("hbarmor_tick")
if tonumber(set) ~= nil then
	hbarmor.tick = tonumber(set)
end


local must_hide = function(playername, arm)
	return ((not armor.def[playername].count or armor.def[playername].count == 0) and arm == 0)
end

local arm_printable = function(arm)
	return math.ceil(math.floor(arm+0.5))
end

local function custom_hud(player)
	local name = player:get_player_name()

	if minetest.settings:get_bool("enable_damage") then
		local ret = hbarmor.get_armor(player)
		if ret == false then
			minetest.log("error", "[hbarmor] Call to hbarmor.get_armor in custom_hud returned with false!")
		end
		local arm = tonumber(hbarmor.armor[name])
		if not arm then arm = 0 end
		local hide
		if hbarmor.autohide then
			hide = must_hide(name, arm)
		else
			hide = false
		end
		hb.init_hudbar(player, "armor", arm_printable(arm), nil, hide)
	end
end

--register and define armor HUD bar
hb.register_hudbar("armor", 0xFFFFFF, S("Armor"), { icon = "hbarmor_icon.png", bgicon = "hbarmor_bgicon.png", bar = "hbarmor_bar.png" }, 0, 100, hbarmor.autohide, S("%s: %d%%"))

function hbarmor.get_armor(player)
	if not player or not armor.def then
		return false
	end
	local name = player:get_player_name()
	local def = armor.def[name] or nil
	if def and def.state and def.count then
		hbarmor.set_armor(name, def.state, def.count)
	else
		return false
	end
	return true
end

function hbarmor.set_armor(player_name, ges_state, items)
	local max_items = 4
	if items == 5 then
		max_items = items
	end
	local max = max_items * 65535
	local lvl = max - ges_state
	lvl = lvl/max
	if ges_state == 0 and items == 0 then
		lvl = 0
	end

	hbarmor.armor[player_name] = math.max(0, math.min(lvl* (items * (100 / max_items)), 100))
end

-- update hud elemtens if value has changed
local function update_hud(player)
	local name = player:get_player_name()
	--armor
	local arm = tonumber(hbarmor.armor[name])
	if not arm then
		arm = 0
		hbarmor.armor[name] = 0
	end
	if hbarmor.autohide then
		-- hide armor bar completely when there is none
		if must_hide(name, arm) then
			hb.hide_hudbar(player, "armor")
		else
			hb.change_hudbar(player, "armor", arm_printable(arm))
			hb.unhide_hudbar(player, "armor")
		end
	else
		hb.change_hudbar(player, "armor", arm_printable(arm))
	end
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	custom_hud(player)
	hbarmor.player_active[name] = true
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	hbarmor.player_active[name] = false
end)

local main_timer = 0
local timer = 0
minetest.register_globalstep(function(dtime)
	main_timer = main_timer + dtime
	timer = timer + dtime
	if main_timer > hbarmor.tick or timer > 4 then
		if minetest.settings:get_bool("enable_damage") then
			if main_timer > hbarmor.tick then main_timer = 0 end
			for _,player in ipairs(minetest.get_connected_players()) do
				local name = player:get_player_name()
				if hbarmor.player_active[name] == true then
					local ret = hbarmor.get_armor(player)
					if ret == false then
						minetest.log("error", "[hbarmor] Call to hbarmor.get_armor in globalstep returned with false!")
					end
					-- update all hud elements
					update_hud(player)
				end
			end
		end
	end
	if timer > 4 then timer = 0 end
end)
