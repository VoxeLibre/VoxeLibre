local S
if (minetest.get_modpath("intllib")) then
	S = intllib.Getter()
else
	S = function ( s ) return s end
end

if minetest.setting_getbool("enable_damage") then

mcl_hunger = {}
mcl_hunger.food = {}

-- Debug Mode. If enabled, saturation and exhaustion are shown as well
local debug = minetest.setting_getbool("mcl_hunger_debug")
if debug == nil then
	debug = false
end

--[[ Data value format notes:
	Hunger values is identical to Minecraft's and ranges from 0 to 20.
	Exhaustion and saturation values are stored as integers, unlike in Minecraft.
	Exhaustion is Minecraft exhaustion times 1000 and ranges from 0 to 4000.
	Saturation is Minecraft exhaustion times 10 and ranges from 0 to 200.

	Food saturation is stored in the custom item definition field _mcl_saturation.
	This field uses the original Minecraft value.
]]

-- Count number of poisonings a player has at once
mcl_hunger.poisonings = {}

-- HUD item ids
local hunger_hud = {}

mcl_hunger.HUD_TICK = 0.1

-- Exhaustion increase
mcl_hunger.EXHAUST_DIG = 5  -- exhaustion increased this value after digged node
mcl_hunger.EXHAUST_JUMP = 50 -- jump
mcl_hunger.EXHAUST_SPRINT_JUMP = 200 -- jump while sprinting
mcl_hunger.EXHAUST_ATTACK = 100 -- attack
mcl_hunger.EXHAUST_SWIM = 10 -- player movement in water
mcl_hunger.EXHAUST_SPRINT = 100 -- sprint (per node)
mcl_hunger.EXHAUST_DAMAGE = 100 -- taking damage (protected by armor)
mcl_hunger.EXHAUST_REGEN = 6000 -- Regenerate 1 HP
mcl_hunger.EXHAUST_LVL = 4000 -- at what exhaustion player saturation gets lowered

mcl_hunger.SATURATION_INIT = 50 -- Initial saturation for new/respawning players


--load custom settings
local set = io.open(minetest.get_modpath("mcl_hunger").."/mcl_hunger.conf", "r")
if set then
	dofile(minetest.get_modpath("mcl_hunger").."/mcl_hunger.conf")
	set:close()
end

local function init_hud(player)
	hb.init_hudbar(player, "food", mcl_hunger.get_hunger(player))
	if debug then
		hb.init_hudbar(player, "saturation", mcl_hunger.get_saturation(player), mcl_hunger.get_hunger(player)*10)
		hb.init_hudbar(player, "exhaustion", mcl_hunger.get_exhaustion(player))
	end
end

-- HUD updating functions for Debug Mode. No-op if not in Debug Mode
function mcl_hunger.update_saturation_hud(player, saturation, hunger)
	if debug then
		local satulimit
		if hunger then
			satulimit = hunger * 10
		end
		hb.change_hudbar(player, "saturation", saturation, satulimit)
	end
end
function mcl_hunger.update_exhaustion_hud(player, exhaustion)
	if debug then
		hb.change_hudbar(player, "exhaustion", exhaustion)
	end
end

dofile(minetest.get_modpath("mcl_hunger").."/hunger.lua")

-- register saturation hudbar
hb.register_hudbar("food", 0xFFFFFF, S("Food"), { icon = "hbhunger_icon.png", bgicon = "hbhunger_bgicon.png",  bar = "hbhunger_bar.png" }, 20, 20, false)
if debug then
	hb.register_hudbar("saturation", 0xFFFFFF, S("Saturation"), { icon = "mcl_hunger_icon_saturation.png", bgicon = "mcl_hunger_bgicon_saturation.png", bar = "mcl_hunger_bar_saturation.png" }, mcl_hunger.SATURATION_INIT, 200, false, S("%s: %d/%d"))
	hb.register_hudbar("exhaustion", 0xFFFFFF, S("Exhaust."), { icon = "mcl_hunger_icon_exhaustion.png", bgicon = "mcl_hunger_bgicon_exhaustion.png", bar = "mcl_hunger_bar_exhaustion.png" }, 0, mcl_hunger.EXHAUST_LVL, false, S("%s: %d/%d"))
end

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
	return get_player_value_raw(player, RAW_VALUE_SATURATION, 50)
end

mcl_hunger.get_exhaustion = function(player)
	return get_player_value_raw(player, RAW_VALUE_EXHAUSTION, 0)
end

mcl_hunger.set_hunger = function(player, hunger, update_hudbars)
	hunger = math.min(20, math.max(0, hunger))

	local ok = set_player_value_raw(player, RAW_VALUE_FOOD, hunger)
	if not ok then return false end

	if update_hudbars ~= false then
		hb.change_hudbar(player, "food", hunger)
		mcl_hunger.update_saturation_hud(player, nil, hunger)
	end
	return true
end

mcl_hunger.set_saturation = function(player, saturation, update_hudbar)
	saturation = math.min(mcl_hunger.get_hunger(player)*10, math.max(0, saturation))

	local ok = set_player_value_raw(player, RAW_VALUE_SATURATION, saturation)
	if not ok then return false end

	if update_hudbar ~= false then
		mcl_hunger.update_saturation_hud(player, saturation)
	end
	return true
end

mcl_hunger.set_exhaustion = function(player, exhaustion, update_hudbar)
	exhaustion = math.min(mcl_hunger.EXHAUST_LVL, math.max(0.0, exhaustion))

	local ok = set_player_value_raw(player, RAW_VALUE_EXHAUSTION, exhaustion)
	if not ok then return false end

	if update_hudbar ~= false then
		mcl_hunger.update_exhaustion_hud(player, exhaustion)
	end
	return true
end



-- END OF API --

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local inv = player:get_inventory()
	inv:set_size("hunger", 3)
	mcl_hunger.poisonings[name] = 0
	init_hud(player)
end)

minetest.register_on_respawnplayer(function(player)
	-- reset hunger (and save)
	local name = player:get_player_name()
	local h, s, e = 20, mcl_hunger.SATURATION_INIT, 0
	mcl_hunger.set_hunger(player, h, false)
	mcl_hunger.set_saturation(player, s, false)
	mcl_hunger.set_exhaustion(player, e, false)
	hb.change_hudbar(player, "food", h)
	mcl_hunger.update_saturation_hud(player, s, h)
	mcl_hunger.update_exhaustion_hud(player, e)
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
			mcl_hunger.set_saturation(player, math.max(s - 10, 0))
			satuchanged = true
		elseif s <= 0.0001 then
			h = mcl_hunger.get_hunger(player)
			h = math.max(h-1, 0)
			mcl_hunger.set_hunger(player, h)
			satuchanged = true
		end
		if satuchanged then
			if h ~= nil then h = h*10 end
			mcl_hunger.update_saturation_hud(player, mcl_hunger.get_saturation(player), h)
		end
	end
	mcl_hunger.update_exhaustion_hud(player, mcl_hunger.get_exhaustion(player))
	return true
end

function mcl_hunger.saturate(playername, increase, update_hudbar)
	local player = minetest.get_player_by_name(playername)
	mcl_hunger.set_saturation(player, math.min(mcl_hunger.get_saturation(player) + increase, mcl_hunger.get_hunger(player)*10))
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
			-- Quick heal (every 0.5s)
			if h >= 20 and hp > 0 and hp < 20 then
				-- +1 HP, +exhaustion
				player:set_hp(hp+1)
				mcl_hunger.exhaust(name, mcl_hunger.EXHAUST_REGEN)
			-- Slow heal, and hunger damage (every 4s)
			elseif timerMult == 0 then
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
