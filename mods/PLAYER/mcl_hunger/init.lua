local S
if (minetest.get_modpath("intllib")) then
	S = intllib.Getter()
else
	S = function ( s ) return s end
end

if minetest.setting_getbool("enable_damage") then

mcl_hunger = {}
mcl_hunger.food = {}

-- HUD statbar values
mcl_hunger.hunger = {}
mcl_hunger.hunger_out = {}

-- Count number of poisonings a player has at once
mcl_hunger.poisonings = {}

-- HUD item ids
local hunger_hud = {}

mcl_hunger.HUD_TICK = 0.1

--Some hunger settings
mcl_hunger.exhaustion = {}
mcl_hunger.saturation = {}

-- Exhaustion increase
mcl_hunger.EXHAUST_DIG = 0.005  -- exhaustion increased this value after digged node
mcl_hunger.EXHAUST_JUMP = 0.05 -- jump
mcl_hunger.EXHAUST_SPRINT_JUMP = 0.2 -- jump while sprinting
mcl_hunger.EXHAUST_ATTACK = 0.1 -- attack
mcl_hunger.EXHAUST_SWIM = 0.01 -- player movement in water
mcl_hunger.EXHAUST_SPRINT = 0.1 -- sprint (per node)
mcl_hunger.EXHAUST_DAMAGE = 0.1 -- taking damage (protected by armor)
mcl_hunger.EXHAUST_REGEN = 6.0 -- Regenerate 1 HP
mcl_hunger.EXHAUST_LVL = 4.0 -- at what exhaustion player saturation gets lowerd


--load custom settings
local set = io.open(minetest.get_modpath("mcl_hunger").."/mcl_hunger.conf", "r")
if set then
	dofile(minetest.get_modpath("mcl_hunger").."/mcl_hunger.conf")
	set:close()
end

local function custom_hud(player)
	hb.init_hudbar(player, "food", mcl_hunger.get_hunger_raw(player))
	hb.init_hudbar(player, "saturation", mcl_hunger.saturation[player:get_player_name()], mcl_hunger.get_hunger_raw(player))
	hb.init_hudbar(player, "exhaustion", mcl_hunger.exhaustion[player:get_player_name()])
end

dofile(minetest.get_modpath("mcl_hunger").."/hunger.lua")

-- register saturation hudbar
hb.register_hudbar("food", 0xFFFFFF, S("Food"), { icon = "hbhunger_icon.png", bgicon = "hbhunger_bgicon.png",  bar = "hbhunger_bar.png" }, 20, 20, false)
hb.register_hudbar("saturation", 0xFFFFFF, S("Saturation"), { icon = "hbhunger_icon.png", bgicon = "hbhunger_bgicon.png",  bar = "hbhunger_bar.png" }, 5, 20, false, S("%s: %.1f/%d"))
hb.register_hudbar("exhaustion", 0xFFFFFF, S("Exhaustion"), { icon = "hbhunger_icon.png", bgicon = "hbhunger_bgicon.png",  bar = "hbhunger_bar.png" }, 0, 4, false, S("%s: %.3f/%d"))

-- update hud elemtens if value has changed
local function update_hud(player)
	local name = player:get_player_name()
 --hunger
	local h_out = tonumber(mcl_hunger.hunger_out[name])
	local h = tonumber(mcl_hunger.hunger[name])
	if h_out ~= h then
		mcl_hunger.hunger_out[name] = h
		hb.change_hudbar(player, "food", h)
		hb.change_hudbar(player, "saturation", nil, h)
	end
end

-- API START --
mcl_hunger.get_hunger = function(player)
	local name = player:get_player_name()
	return mcl_hunger.hunger[name]
end

mcl_hunger.set_hunger = function(player, hunger)
	local name = player:get_player_name()
	mcl_hunger.hunger[name] = hunger
	mcl_hunger.set_hunger_raw(player)
	update_hud(player)
end

-- END OF API --

-- For internal use only. Don't use the “raw” functions outside of mcl_hunger!

mcl_hunger.get_hunger_raw = function(player)
	local inv = player:get_inventory()
	if not inv then return nil end
	local hgp = inv:get_stack("hunger", 1):get_count()
	if hgp == 0 then
		hgp = 21
		inv:set_stack("hunger", 1, ItemStack({name=":", count=hgp}))
	else
		hgp = hgp
	end
	return hgp-1
end

mcl_hunger.set_hunger_raw = function(player)
	local inv = player:get_inventory()
	local name = player:get_player_name()
	local value = mcl_hunger.hunger[name]
	if not inv  or not value then return nil end
	if value > 20 then value = 20 end
	if value < 0 then value = 0 end

	inv:set_stack("hunger", 1, ItemStack({name=":", count=value+1}))

	return true
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local inv = player:get_inventory()
	inv:set_size("hunger",1)
	mcl_hunger.hunger[name] = mcl_hunger.get_hunger_raw(player)
	mcl_hunger.hunger_out[name] = mcl_hunger.hunger[name]
	mcl_hunger.exhaustion[name] = 0.0
	mcl_hunger.saturation[name] = 5.0
	mcl_hunger.poisonings[name] = 0
	custom_hud(player)
	mcl_hunger.set_hunger_raw(player)
end)

minetest.register_on_respawnplayer(function(player)
	-- reset hunger (and save)
	local name = player:get_player_name()
	local h = 20
	mcl_hunger.hunger[name] = h
	mcl_hunger.set_hunger_raw(player)
	mcl_hunger.exhaustion[name] = 0.0
	mcl_hunger.saturation[name] = 5.0
	hb.change_hudbar(player, "exhaustion", mcl_hunger.exhaustion[name])
	hb.change_hudbar(player, "saturation", mcl_hunger.saturation[name], h)
	hb.change_hudbar(player, "food", h)
end)

function mcl_hunger.exhaust(playername, increase)
	local player = minetest.get_player_by_name(playername)
	mcl_hunger.exhaustion[playername] = mcl_hunger.exhaustion[playername] + increase
	if mcl_hunger.exhaustion[playername] >= 4.0 then
		mcl_hunger.exhaustion[playername] = 0.0
		local h = nil
		local satuchanged = false
		if mcl_hunger.saturation[playername] > 0.0 then
			mcl_hunger.saturation[playername] = math.max(mcl_hunger.saturation[playername] - 1.0, 0.0)
			satuchanged = true
		elseif mcl_hunger.saturation[playername] < 0.0001 then
			h = mcl_hunger.get_hunger_raw(player)
			h = h-1
			mcl_hunger.hunger[playername] = h
			mcl_hunger.set_hunger_raw(player)
			satuchanged = true
		end
		if satuchanged then
			hb.change_hudbar(player, "saturation", mcl_hunger.saturation[playername], h)
		end
	end
	hb.change_hudbar(player, "exhaustion", mcl_hunger.exhaustion[playername])
end

function mcl_hunger.saturate(playername, increase)
	local player = minetest.get_player_by_name(playername)
	mcl_hunger.saturation[playername] = math.min(mcl_hunger.saturation[playername] + increase, mcl_hunger.get_hunger(player))
	hb.change_hudbar(player, "saturation", mcl_hunger.saturation[playername], mcl_hunger.get_hunger(player))
end

local main_timer = 0
local timer = 0		-- Half second timer
local timerMult = 1	-- Cycles from 0 to 7, each time when timer hits half a second
minetest.register_globalstep(function(dtime)
	main_timer = main_timer + dtime
	timer = timer + dtime
	if main_timer > mcl_hunger.HUD_TICK or timer > 0.5 then
		if main_timer > mcl_hunger.HUD_TICK then main_timer = 0 end
		for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()

		local h = tonumber(mcl_hunger.hunger[name])
		local hp = player:get_hp()
		if timer > 0.5 then
			-- Quick heal (every 0.5s)
			if h >= 20 and hp > 0 and hp < 20 then
				-- +1 HP, +6 exhaustion
				player:set_hp(hp+1)
				mcl_hunger.exhaust(name, mcl_hunger.EXHAUST_REGEN)
			-- Slow heal, and hunger damage (every 4s)
			elseif timerMult == 0 then
				if h >= 18 and hp > 0 and hp < 20 then
					-- +1 HP, +6 exhaustion
					player:set_hp(hp+1)
					mcl_hunger.exhaust(name, mcl_hunger.EXHAUST_REGEN)
					hb.change_hudbar(player, "exhaustion", mcl_hunger.exhaustion[name])
				elseif h == 0 then
				-- Damage hungry player down to 1 HP
					if hp-1 >= 0 then
						player:set_hp(hp-1)
					end
				end
			end

			local controls = player:get_player_control()
			-- Determine if the player is moving
			if controls.up or controls.down or controls.left or controls.right then
				-- TODO: Add exhaustion for moving in water
			end
			-- Jumping
			-- FIXME: This is quite hacky and doesn't check if the player is actually jumping
			if controls.jump then
				mcl_hunger.exhaust(name, mcl_hunger.EXHAUST_JUMP)
			end

			-- Reduce hunter if 0 saturation
			if timerMult == 0 and h > 0 and  mcl_hunger.saturation[name] < 0.0001 then
			end

			-- update all hud elements
			update_hud(player)

		end
		end
	end
	if timer > 0.5 then
		timer = 0
		timerMult = timerMult + 1
		if timerMult > 7 then
			timerMult = 0
		end
	end
end)

end
