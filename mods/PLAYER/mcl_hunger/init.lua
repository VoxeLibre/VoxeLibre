local S = minetest.get_translator("mcl_hunger")
local mod_death_messages = minetest.get_modpath("mcl_death_messages")

mcl_hunger = {}

--[[ This variable tells you if the hunger gameplay mechanic is active.
The state of the hunger mechanic will be determined at game start.
Hunger is enabled when damage is enabled.
If the damage setting is changed within the game, this does NOT
update the hunger mechanic, so the game must be restarted for this
to take effect. ]]
if minetest.settings:get_bool("enable_damage") == true then
	mcl_hunger.active = true
else
	mcl_hunger.active = false
end

mcl_hunger.HUD_TICK = 0.1

-- Exhaustion increase
mcl_hunger.EXHAUST_DIG = 5  -- after digging node
mcl_hunger.EXHAUST_JUMP = 50 -- jump
mcl_hunger.EXHAUST_SPRINT_JUMP = 200 -- jump while sprinting
mcl_hunger.EXHAUST_ATTACK = 100 -- hit an enemy
mcl_hunger.EXHAUST_SWIM = 10 -- player movement in water
mcl_hunger.EXHAUST_SPRINT = 100 -- sprint (per node)
mcl_hunger.EXHAUST_DAMAGE = 100 -- taking damage (protected by armor)
mcl_hunger.EXHAUST_REGEN = 6000 -- Regenerate 1 HP
mcl_hunger.EXHAUST_LVL = 4000 -- at what exhaustion player saturation gets lowered

mcl_hunger.SATURATION_INIT = 5 -- Initial saturation for new/respawning players

-- Debug Mode. If enabled, saturation and exhaustion are shown as well.
-- NOTE: Only updated when settings are loaded.
mcl_hunger.debug = false

-- Cooldown timers for each player, to force a short delay between consuming 2 food items
mcl_hunger.last_eat = {}

dofile(minetest.get_modpath("mcl_hunger").."/api.lua")
dofile(minetest.get_modpath("mcl_hunger").."/hunger.lua")
dofile(minetest.get_modpath("mcl_hunger").."/register_foods.lua")

--[[ IF HUNGER IS ENABLED ]]
if mcl_hunger.active == true then

-- Read debug mode setting
-- The setting should only be read at the beginning, this mod is not
-- prepared to change this setting later.
mcl_hunger.debug = minetest.settings:get_bool("mcl_hunger_debug")
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
mcl_hunger.poison_hunger = {} -- food poisoning, increasing hunger

-- HUD
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

-- register saturation hudbar
hb.register_hudbar("hunger", 0xFFFFFF, S("Food"), { icon = "hbhunger_icon.png", bgicon = "hbhunger_bgicon.png",  bar = "hbhunger_bar.png" }, 1, 20, 20, false)
if mcl_hunger.debug then
	hb.register_hudbar("saturation", 0xFFFFFF, S("Saturation"), { icon = "mcl_hunger_icon_saturation.png", bgicon = "mcl_hunger_bgicon_saturation.png", bar = "mcl_hunger_bar_saturation.png" }, 1, mcl_hunger.SATURATION_INIT, 200, false, S("%s: %.1f/%d"))
	hb.register_hudbar("exhaustion", 0xFFFFFF, S("Exhaust."), { icon = "mcl_hunger_icon_exhaustion.png", bgicon = "mcl_hunger_bgicon_exhaustion.png", bar = "mcl_hunger_bar_exhaustion.png" }, 1, 0, mcl_hunger.EXHAUST_LVL, false, S("%s: %d/%d"))
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	mcl_hunger.init_player(player)
	init_hud(player)
	mcl_hunger.poison_hunger[name] = 0
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
	if puncher:is_player() then
		mcl_hunger.exhaust(puncher:get_player_name(), mcl_hunger.EXHAUST_ATTACK)
	end
end)

-- Exhaust on taking damage
minetest.register_on_player_hpchange(function(player, hp_change)
	if hp_change < 0 then
		local name = player:get_player_name()
		mcl_hunger.exhaust(name, mcl_hunger.EXHAUST_DAMAGE)
	end
end)

local main_timer = 0
local timer = 0		-- Half second timer
local timerMult = 1	-- Cycles from 0 to 7, each time when timer hits half a second
minetest.register_globalstep(function(dtime)
	main_timer = main_timer + dtime
	timer = timer + dtime
	if main_timer > mcl_hunger.HUD_TICK or timer > 0.5 then
		if main_timer > mcl_hunger.HUD_TICK then main_timer = 0 end
		for _,player in pairs(minetest.get_connected_players()) do
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
				-- TODO: Allow starvation at higher difficulty levels
					if hp-1 > 0 then
						if mod_death_messages then
							mcl_death_messages.player_damage(player, S("@1 starved to death.", name))
						end
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

--[[ IF HUNGER IS NOT ENABLED ]]
else

minetest.register_on_joinplayer(function(player)
	mcl_hunger.init_player(player)
	mcl_hunger.last_eat[player:get_player_name()] = -1
end)

end
