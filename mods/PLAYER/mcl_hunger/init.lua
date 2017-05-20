local S
if (minetest.get_modpath("intllib")) then
	S = intllib.Getter()
else
	S = function ( s ) return s end
end

if minetest.setting_getbool("enable_damage") then

mcl_hunger = {}
mcl_hunger.food = {}

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

local function init_hud(player)
	hb.init_hudbar(player, "food", mcl_hunger.get_hunger(player))
	hb.init_hudbar(player, "saturation", mcl_hunger.get_saturation(player), mcl_hunger.get_hunger(player))
	hb.init_hudbar(player, "exhaustion", mcl_hunger.get_exhaustion(player))
end

dofile(minetest.get_modpath("mcl_hunger").."/hunger.lua")

-- register saturation hudbar
hb.register_hudbar("food", 0xFFFFFF, S("Food"), { icon = "hbhunger_icon.png", bgicon = "hbhunger_bgicon.png",  bar = "hbhunger_bar.png" }, 20, 20, false)
hb.register_hudbar("saturation", 0xFFFFFF, S("Saturation"), { icon = "hbhunger_icon.png", bgicon = "hbhunger_bgicon.png",  bar = "hbhunger_bar.png" }, 5, 20, false, S("%s: %.1f/%d"))
hb.register_hudbar("exhaustion", 0xFFFFFF, S("Exhaustion"), { icon = "hbhunger_icon.png", bgicon = "hbhunger_bgicon.png",  bar = "hbhunger_bar.png" }, 0, 4, false, S("%s: %.3f/%d"))


local RAW_VALUE_FOOD = 1
local RAW_VALUE_SATURATION = 2
local RAW_VALUE_EXHAUSTION = 3

local get_player_value_raw = function(player, id, default)
	local inv = player:get_inventory()
	if not inv then return nil end
	local value = inv:get_stack("hunger", id):get_count()
	if value == 0 then
		inv:set_stack("hunger", id, ItemStack({name=":", count=default+1}))
		return default
	else
		return value - 1
	end
end

local set_player_value_raw = function(player, id, value)
	local inv = player:get_inventory()
	inv:set_stack("hunger", id, ItemStack({name=":", count=value+1}))
	return true
end

-- API START --
mcl_hunger.get_hunger = function(player)
	return get_player_value_raw(player, RAW_VALUE_FOOD, 20)
end

mcl_hunger.get_saturation = function(player)
	return get_player_value_raw(player, RAW_VALUE_SATURATION, 50) / 10
end

mcl_hunger.get_exhaustion = function(player)
	return get_player_value_raw(player, RAW_VALUE_EXHAUSTION, 0) / 1000
end

mcl_hunger.set_hunger = function(player, hunger, update_hudbars)
	hunger = math.min(20, math.max(0, hunger))

	local ok = set_player_value_raw(player, RAW_VALUE_FOOD, hunger)
	if not ok then return false end

	if update_hudbars ~= false then
		hb.change_hudbar(player, "food", hunger)
		hb.change_hudbar(player, "saturation", nil, hunger)
	end
	return true
end

mcl_hunger.set_saturation = function(player, saturation, update_hudbar)
	saturation = math.min(mcl_hunger.get_hunger(player), math.max(0, saturation))

	local ok = set_player_value_raw(player, RAW_VALUE_SATURATION, math.floor(saturation * 10))
	if not ok then return false end

	if update_hudbar ~= false then
		hb.change_hudbar(player, "saturation", saturation)
	end
	return true
end

mcl_hunger.set_exhaustion = function(player, exhaustion, update_hudbar)
	exhaustion = math.min(4.0, math.max(0.0, exhaustion))

	local ok = set_player_value_raw(player, RAW_VALUE_EXHAUSTION, math.floor(exhaustion * 1000))
	if not ok then return false end

	if update_hudbar ~= false then
		hb.change_hudbar(player, "exhaustion", exhaustion)
	end
	return true
end



-- END OF API --

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local inv = player:get_inventory()
	inv:set_size("hunger", 3)
	mcl_hunger.poisonings[name] = 0
	local h = mcl_hunger.get_hunger(player)
	local s = mcl_hunger.get_saturation(player)
	local e = mcl_hunger.get_exhaustion(player)
	init_hud(player)
end)

minetest.register_on_respawnplayer(function(player)
	-- reset hunger (and save)
	local name = player:get_player_name()
	local h, s, e = 20, 5.0, 0.0
	mcl_hunger.set_hunger(player, h, false)
	mcl_hunger.set_saturation(player, s, false)
	mcl_hunger.set_exhaustion(player, e, false)
	hb.change_hudbar(player, "food", h)
	hb.change_hudbar(player, "saturation", s, h)
	hb.change_hudbar(player, "exhaustion", e)
end)

function mcl_hunger.exhaust(playername, increase)
	local player = minetest.get_player_by_name(playername)
	if not player then return false end
	mcl_hunger.set_exhaustion(player, mcl_hunger.get_exhaustion(player) + increase)
	if mcl_hunger.get_exhaustion(player) >= 4.0 then
		mcl_hunger.set_exhaustion(player, 0.0)
		local h = nil
		local satuchanged = false
		local s = mcl_hunger.get_saturation(player)
		if s > 0.0 then
			mcl_hunger.set_saturation(player, math.max(s - 1.0, 0.0))
			satuchanged = true
		elseif s < 0.0001 then
			h = mcl_hunger.get_hunger(player)
			h = math.max(h-1, 0)
			mcl_hunger.set_hunger(player, h)
			satuchanged = true
		end
		if satuchanged then
			hb.change_hudbar(player, "saturation", mcl_hunger.get_saturation(player), h)
		end
	end
	hb.change_hudbar(player, "exhaustion", mcl_hunger.get_exhaustion(player))
	return true
end

function mcl_hunger.saturate(playername, increase, update_hudbar)
	local player = minetest.get_player_by_name(playername)
	mcl_hunger.set_saturation(player, math.min(mcl_hunger.get_saturation(player) + increase, mcl_hunger.get_hunger(player)))
	if update_hudbar ~= false then
		hb.change_hudbar(player, "saturation", mcl_hunger.get_saturation(player), mcl_hunger.get_hunger(player))
	end
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

		local h = tonumber(mcl_hunger.get_hunger(player))
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
					hb.change_hudbar(player, "exhaustion", mcl_hunger.get_exhaustion(player))
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
