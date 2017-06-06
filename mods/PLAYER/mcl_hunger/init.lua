local S
if (minetest.get_modpath("intllib")) then
	S = intllib.Getter()
else
	S = function ( s ) return s end
end


mcl_hunger = {}
mcl_hunger.exhaust = function() end

mcl_hunger.HUD_TICK = 0.1

-- Exhaustion increase
mcl_hunger.EXHAUST_DIG = 5  -- after digging node
mcl_hunger.EXHAUST_JUMP = 50 -- jump
mcl_hunger.EXHAUST_SPRINT_JUMP = 200 -- TODO: jump while sprinting
mcl_hunger.EXHAUST_ATTACK = 100 -- hit an enemy
mcl_hunger.EXHAUST_SWIM = 10 -- player movement in water
mcl_hunger.EXHAUST_SPRINT = 100 -- sprint (per node)
mcl_hunger.EXHAUST_DAMAGE = 100 -- TODO (mostly done): taking damage (protected by armor)
mcl_hunger.EXHAUST_REGEN = 6000 -- Regenerate 1 HP
mcl_hunger.EXHAUST_LVL = 4000 -- at what exhaustion player saturation gets lowered

mcl_hunger.SATURATION_INIT = 5 -- Initial saturation for new/respawning players

mcl_hunger.active = false

if minetest.setting_getbool("enable_damage") then
mcl_hunger.active = true

-- Debug Mode. If enabled, saturation and exhaustion are shown as well.
-- NOTE: Read-only. The setting should only be read at the beginning, this mod is not
-- prepared to change this setting later.
mcl_hunger.debug = minetest.setting_getbool("mcl_hunger_debug")
if mcl_hunger.debug == nil then
	mcl_hunger.debug = false
end

--[[ Data value format notes:
	Hunger values is identical to Minecraft's and ranges from 0 to 20.
	Exhaustion and saturation values are stored as integers, unlike in Minecraft.
	Exhaustion is Minecraft exhaustion times 1000 and ranges from 0 to 4000.
	Saturation is Minecraft saturation and ranges from 0 to 20.

	Food saturation is stored in the custom item definition field _mcl_saturation.
	This field uses the original Minecraft value.
]]

-- Count number of poisonings a player has at once
mcl_hunger.poisonings = {}

-- Cooldown timers for each player, to force a short delay between consuming 2 food items
mcl_hunger.last_eat = {}

-- HUD item ids
local hunger_hud = {}

local function init_hud(player)
	hb.init_hudbar(player, "hunger", mcl_hunger.get_hunger(player))
	if mcl_hunger.debug then
		hb.init_hudbar(player, "saturation", mcl_hunger.get_saturation(player), mcl_hunger.get_hunger(player))
		hb.init_hudbar(player, "exhaustion", mcl_hunger.get_exhaustion(player))
	end
end

-- HUD updating functions for Debug Mode. No-op if not in Debug Mode
function mcl_hunger.update_saturation_hud(player, saturation, hunger)
	if mcl_hunger.debug then
		hb.change_hudbar(player, "saturation", saturation, hunger)
	end
end
function mcl_hunger.update_exhaustion_hud(player, exhaustion)
	if mcl_hunger.debug then
		hb.change_hudbar(player, "exhaustion", exhaustion)
	end
end

dofile(minetest.get_modpath("mcl_hunger").."/hunger.lua")

-- register saturation hudbar
hb.register_hudbar("hunger", 0xFFFFFF, S("Food"), { icon = "hbhunger_icon.png", bgicon = "hbhunger_bgicon.png",  bar = "hbhunger_bar.png" }, 20, 20, false)
if mcl_hunger.debug then
	hb.register_hudbar("saturation", 0xFFFFFF, S("Saturation"), { icon = "mcl_hunger_icon_saturation.png", bgicon = "mcl_hunger_bgicon_saturation.png", bar = "mcl_hunger_bar_saturation.png" }, mcl_hunger.SATURATION_INIT, 200, false, S("%s: %.1f/%d"))
	hb.register_hudbar("exhaustion", 0xFFFFFF, S("Exhaust."), { icon = "mcl_hunger_icon_exhaustion.png", bgicon = "mcl_hunger_bgicon_exhaustion.png", bar = "mcl_hunger_bar_exhaustion.png" }, 0, mcl_hunger.EXHAUST_LVL, false, S("%s: %d/%d"))
end

-- API START --
mcl_hunger.get_hunger = function(player)
	return tonumber(player:get_attribute("mcl_hunger:hunger")) or 20
end

mcl_hunger.get_saturation = function(player)
	return tonumber(player:get_attribute("mcl_hunger:saturation")) or mcl_hunger.SATURATION_INIT
end

mcl_hunger.get_exhaustion = function(player)
	return tonumber(player:get_attribute("mcl_hunger:exhaustion")) or 0
end

mcl_hunger.set_hunger = function(player, hunger, update_hudbars)
	hunger = math.min(20, math.max(0, hunger))
	player:set_attribute("mcl_hunger:hunger", tostring(hunger))
	if update_hudbars ~= false then
		hb.change_hudbar(player, "hunger", hunger)
		mcl_hunger.update_saturation_hud(player, nil, hunger)
	end
	return true
end

mcl_hunger.set_saturation = function(player, saturation, update_hudbar)
	saturation = math.min(mcl_hunger.get_hunger(player), math.max(0, saturation))
	player:set_attribute("mcl_hunger:saturation", tostring(saturation))
	if update_hudbar ~= false then
		mcl_hunger.update_saturation_hud(player, saturation)
	end
	return true
end

mcl_hunger.set_exhaustion = function(player, exhaustion, update_hudbar)
	exhaustion = math.min(mcl_hunger.EXHAUST_LVL, math.max(0.0, exhaustion))
	player:set_attribute("mcl_hunger:exhaustion", tostring(exhaustion))
	if update_hudbar ~= false then
		mcl_hunger.update_exhaustion_hud(player, exhaustion)
	end
	return true
end



-- END OF API --
minetest.register_on_newplayer(function(player)
	local name = player:get_player_name()
	mcl_hunger.set_hunger(player, 20, false)
	mcl_hunger.set_saturation(player, mcl_hunger.SATURATION_INIT, false)
	mcl_hunger.set_exhaustion(player, 0, false)
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	init_hud(player)
	mcl_hunger.poisonings[name] = 0
	mcl_hunger.last_eat[name] = -1
end)

minetest.register_on_respawnplayer(function(player)
	-- reset hunger, related values and poison
	local name = player:get_player_name()

	mcl_hunger.stop_poison(player)
	mcl_hunger.last_eat[name] = -1

	local h, s, e = 20, mcl_hunger.SATURATION_INIT, 0
	mcl_hunger.set_hunger(player, h, false)
	mcl_hunger.set_saturation(player, s, false)
	mcl_hunger.set_exhaustion(player, e, false)
	hb.change_hudbar(player, "hunger", h)
	mcl_hunger.update_saturation_hud(player, s, h)
	mcl_hunger.update_exhaustion_hud(player, e)
end)

-- PvP combat exhaustion
minetest.register_on_punchplayer(function(victim, puncher, time_from_last_punch, tool_capabilities, dir, damage)
	if victim:is_player() and puncher:is_player() then
		mcl_hunger.exhaust(victim:get_player_name(), mcl_hunger.EXHAUST_DAMAGE)
		mcl_hunger.exhaust(puncher:get_player_name(), mcl_hunger.EXHAUST_ATTACK)
	end
end)

function mcl_hunger.exhaust(playername, increase)
	local player = minetest.get_player_by_name(playername)
	if not player then return false end
	mcl_hunger.set_exhaustion(player, mcl_hunger.get_exhaustion(player) + increase)
	if mcl_hunger.get_exhaustion(player) >= mcl_hunger.EXHAUST_LVL then
		mcl_hunger.set_exhaustion(player, 0.0)
		local h = nil
		local satuchanged = false
		local s = mcl_hunger.get_saturation(player)
		if s > 0 then
			mcl_hunger.set_saturation(player, math.max(s - 1.0, 0))
			satuchanged = true
		elseif s <= 0.0001 then
			h = mcl_hunger.get_hunger(player)
			h = math.max(h-1, 0)
			mcl_hunger.set_hunger(player, h)
			satuchanged = true
		end
		if satuchanged then
			if h ~= nil then h = h end
			mcl_hunger.update_saturation_hud(player, mcl_hunger.get_saturation(player), h)
		end
	end
	mcl_hunger.update_exhaustion_hud(player, mcl_hunger.get_exhaustion(player))
	return true
end

function mcl_hunger.saturate(playername, increase, update_hudbar)
	local player = minetest.get_player_by_name(playername)
	mcl_hunger.set_saturation(player, math.min(mcl_hunger.get_saturation(player) + increase, mcl_hunger.get_hunger(player)))
	if update_hudbar ~= false then
		mcl_hunger.update_saturation_hud(player, mcl_hunger.get_saturation(player), mcl_hunger.get_hunger(player))
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
			-- Slow health regeneration, and hunger damage (every 4s).
			-- Regeneration rate based on tutorial video <https://www.youtube.com/watch?v=zs2t-xCVHBo>.
			-- Minecraft Wiki seems to be wrong in claiming that full hunger gives 0.5s regen rate.
			if timerMult == 0 then
				if h >= 18 and hp > 0 and hp < 20 then
					-- +1 HP, +exhaustion
					player:set_hp(hp+1)
					mcl_hunger.exhaust(name, mcl_hunger.EXHAUST_REGEN)
					mcl_hunger.update_exhaustion_hud(player, mcl_hunger.get_exhaustion(player))
				elseif h == 0 then
				-- Damage hungry player down to 1 HP
					if hp-1 >= 0 then
						player:set_hp(hp-1)
					end
				end
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
