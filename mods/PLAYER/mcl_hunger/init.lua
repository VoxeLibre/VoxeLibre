local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)

local max_tick_timer
vl_tuning.setting("health_regen_delay", "number", {
	default = tonumber(minetest.settings:get("mcl_health_regen_delay")) or 0.5,
	set = function(val) max_tick_timer = val end,
	get = function() return max_tick_timer end,
})
local natural_regeneration = true
vl_tuning.setting("gamerule:naturalRegeneration", "bool", {
	default = true,
	set = function(val) natural_regeneration = val end,
	get = function() return natural_regeneration end,
})

mcl_hunger = {}

--- If hunger is active.
--- This value shall be true if damage is enabled
--- AND the setting "mcl_enable_hunger" is enabled.
local active = false

--- If debug is active.
--- This value shall be true if the setting "mcl_hunger_debug" is enabled.
local debug = false

---Returns true if the hunger mod is enabled.
---@return boolean
function mcl_hunger.get_active()
	return active
end

---Returns true if the hunger mod debug information is shown.
---@return boolean
function mcl_hunger.get_debug()
	return debug
end

---
---@param state boolean
function mcl_hunger.set_active(state, skip_player_refresh)
	local old = active
	active = state
	if state == old then
		return
	end
	---
	-- Apply side effects of state change
	core.settings:set_bool("mcl_enable_hunger", state)

	if skip_player_refresh then return end

	for _, player in pairs(core.get_connected_players()) do
		mcl_hunger.refresh_player_bars(player)
	end
end

---
---@param state boolean
function mcl_hunger.set_debug(state)
	local old = debug
	debug = state
	if state == old then
		return
	end
	---
	--- Apply side effects of state change
	core.settings:set_bool("mcl_hunger_debug", state)

	for _, player in pairs(core.get_connected_players()) do
		mcl_hunger.refresh_player_bars(player)
	end
end

-- First time state update
---
mcl_hunger.set_active(core.settings:get_bool("mcl_enable_hunger", true), true)
mcl_hunger.set_debug(core.settings:get_bool("mcl_hunger_debug", false))

mcl_hunger.HUD_TICK            = 0.1
mcl_hunger.EXHAUST_DIG         = 5    -- after digging node
mcl_hunger.EXHAUST_JUMP        = 50   -- jump
mcl_hunger.EXHAUST_SPRINT_JUMP = 200  -- jump while sprinting
mcl_hunger.EXHAUST_ATTACK      = 100  -- hit an enemy
mcl_hunger.EXHAUST_SWIM        = 10   -- player movement in water
mcl_hunger.EXHAUST_SPRINT      = 100  -- sprint (per node)
mcl_hunger.EXHAUST_DAMAGE      = 100  -- taking damage (protected by armor)
mcl_hunger.EXHAUST_REGEN       = 6000 -- Regenerate 1 HP
mcl_hunger.EXHAUST_HUNGER      = 5    -- Hunger status effect at base level.
mcl_hunger.EXHAUST_LVL         = 4000 -- at what exhaustion player saturation gets lowered
mcl_hunger.EATING_DELAY        = tonumber(core.settings:get("mcl_eating_delay")) or 1.61
mcl_hunger.EATING_WALK_SPEED   = tonumber(core.settings:get("movement_speed_crouch")) / tonumber(core.settings:get("movement_speed_walk"))
mcl_hunger.EATING_TOUCHSCREEN_DELAY_PADDING = 0.75
mcl_hunger.SATURATION_INIT     = 5 -- Initial saturation for new/respawning players

-- Cooldown timers for each player, to force a short delay between consuming 2 food items
mcl_hunger.last_eat = {}

--- Is player eating API
--- @param player string|core.Player
function mcl_hunger.is_eating(player)
	local name
	local t = type(player)
	if t == "table" then
		name = player:get_player_name()
	elseif t == "string" then
		name = player
	else
		error("unsupported parameter type " .. tostring(t))
	end
	return mcl_hunger.eat_internal[name].is_eating_no_padding
end

-- Variables for each player, to handle delayed eating
mcl_hunger.eat_internal = {}
mcl_hunger.eat_anim_hud = {}

-- Set per player internal variables for delayed eating
core.register_on_joinplayer(function(player)
	local name = player:get_player_name()

	mcl_hunger.eat_internal[name] = {
		is_eating            = false,
		is_eating_no_padding = false,
		itemname             = nil,
		item_definition      = nil,
		hp_change            = nil,
		replace_with_item    = nil,
		itemstack            = nil,
		user                 = nil,
		pointed_thing        = nil,
		pitch                = nil,
		do_item_eat          = false,
		_custom_itemstack    = nil, -- Used as comparison to make sure _custom_wrapper only executes when the same item is eaten
		_custom_var          = {}, -- Variables that can be used by _custom_var and _custom_wrapper
		_custom_func         = nil, -- Can be executed by _custom_wrapper
		_custom_wrapper      = nil, -- Will execute alongside core.do_item_eat if not empty and _custom_itemstack is equal to current player itemstack
		_custom_do_delayed   = false, -- If true, then will execute only _custom_wrapper after holding RMB or LMB within a delay specified by mcl_hunger.EATING_DELAY (Use to bypass core.do_item_eat entirely)
	}
	playerphysics.remove_physics_factor(player, "speed", "mcl_hunger:eating_speed")
	player:hud_set_flags({ wielditem = true })
end)

-- Clear when player leaves
core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()

	mcl_hunger.eat_internal[name] = nil
	mcl_hunger.eat_anim_hud[name] = nil
end)

dofile(modpath .. "/api.lua")
dofile(modpath .. "/hunger.lua")
dofile(modpath .. "/register_foods.lua")
dofile(modpath .. "/commands.lua")

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
-- Register built-in HUD bars
vl_hudbars.register_hudbar({
	identifier = "hunger",
	sort_index = 6,
	on_right = true,
	direction = 1,
	layer_gap = 4,
	scale_y = 1,
	value_type = "proportional",
	default_max_val = 20,
	default_value = 20,
	icon = "hbhunger_icon.png",
	bgicon = "hbhunger_bgicon.png",
	layers = 1,
})
vl_hudbars.register_hudbar({
	identifier = "saturation",
	sort_index = 2,
	on_right = true,
	direction = 0,
	layer_gap = 4,
	scale_y = 1,
	value_type = "proportional",
	default_max_val = 200,
	default_value = mcl_hunger.SATURATION_INIT,
	icon = "mcl_hunger_icon_saturation.png",
	bgicon = "mcl_hunger_bgicon_saturation.png",
	layers = 1,
})
vl_hudbars.register_hudbar({
	identifier = "exhaustion",
	sort_index = 2,
	on_right = false,
	direction = 1,
	layer_gap = 4,
	scale_y = 1,
	value_type = "proportional",
	default_max_val = mcl_hunger.EXHAUST_LVL,
	default_value = 0,
	icon = "mcl_hunger_icon_exhaustion.png",
	bgicon = "mcl_hunger_bgicon_exhaustion.png",
	layers = 1,
})

--- Hide and unhide bars depending on current mod state.
---@param player core.Player
function mcl_hunger.refresh_player_bars(player)
	if mcl_hunger.get_active() then
		vl_hudbars.show(player, "hunger")
	else
		vl_hudbars.hide(player, "hunger")
	end
	if mcl_hunger.get_active() and mcl_hunger.get_debug() then
		vl_hudbars.show(player, "saturation")
		vl_hudbars.show(player, "exhaustion")
	else
		vl_hudbars.hide(player, "saturation")
		vl_hudbars.hide(player, "exhaustion")
	end
end

---@param player core.Player
local function init_player_hud(player)
	local name = player:get_player_name()

	-- Init hunger bars
	vl_hudbars.init_hudbar(player, "hunger")
	vl_hudbars.change_value(player, "hunger", mcl_hunger.get_hunger(player))
	vl_hudbars.init_hudbar(player, "saturation")
	vl_hudbars.change_value(player, "saturation", mcl_hunger.get_saturation(player), mcl_hunger.get_hunger(player))
	vl_hudbars.init_hudbar(player, "exhaustion")
	vl_hudbars.change_value(player, "exhaustion", mcl_hunger.get_exhaustion(player))

	-- Init eating animation
	mcl_hunger.eat_anim_hud[name] = player:hud_add({
		[mcl_vars.hud_type_field] = "image",
		text                      = "blank.png",
		position                  = { x = 0.5, y = 1 },
		scale                     = { x = -25, y = -45 },
		alignment                 = { x = 0, y = -1 },
		offset                    = { x = 0, y = -30 },
		z_index                   = -200,
	})

	mcl_hunger.refresh_player_bars(player)
end

-- HUD updating functions for Debug Mode. No-op if not in Debug Mode
---@param player     core.Player
---@param saturation number?
---@param hunger     number?
function mcl_hunger.update_saturation_hud(player, saturation, hunger)
	if mcl_hunger.get_debug() then
		vl_hudbars.change_value(player, "saturation", saturation, hunger)
	end
end

---
---@param player	 core.Player
---@param exhaustion number?
function mcl_hunger.update_exhaustion_hud(player, exhaustion)
	if mcl_hunger.get_debug() then
		if not exhaustion then
			exhaustion = mcl_hunger.get_exhaustion(player)
		end
		vl_hudbars.change_value(player, "exhaustion", exhaustion)
	end
end

core.register_on_joinplayer(function(player)
	mcl_hunger.init_player(player)
	init_player_hud(player)

	local name = player:get_player_name()

	mcl_hunger.poison_hunger[name] = 0
	mcl_hunger.last_eat[name] = -1
end)

core.register_on_respawnplayer(function(player)
	-- reset hunger, related values and poison
	local name = player:get_player_name()

	mcl_hunger.stop_poison(player)
	mcl_hunger.last_eat[name] = -1

	local h, s, e = 20, mcl_hunger.SATURATION_INIT, 0
	mcl_hunger.set_hunger(player, h, false)
	mcl_hunger.set_saturation(player, s, false)
	mcl_hunger.set_exhaustion(player, e, false)
	vl_hudbars.change_value(player, "hunger", h)
	mcl_hunger.update_saturation_hud(player, s, h)
	mcl_hunger.update_exhaustion_hud(player, e)
end)

-- PvP combat exhaustion
core.register_on_punchplayer(function(victim, puncher, time_from_last_punch, tool_capabilities, dir, damage)
	if puncher:is_player() then
		mcl_hunger.exhaust(puncher:get_player_name(), mcl_hunger.EXHAUST_ATTACK)
	end
end)

-- Exhaust on taking damage
core.register_on_player_hpchange(function(player, hp_change)
	if hp_change < 0 then
		local name = player:get_player_name()
		mcl_hunger.exhaust(name, mcl_hunger.EXHAUST_DAMAGE)
	end
end)

local food_tick_timers     = {} -- one food_tick_timer per player, keys are the player-objects
local eat_start_timers     = {}
local eat_tick_timers      = {}
local eat_effects_cooldown = {}

---
---@param player      table
---@param player_name any
local function clear_eat_internal_and_timers(player, player_name)
	playerphysics.remove_physics_factor(player, "speed", "mcl_hunger:eating_speed")
	player:hud_set_flags({ wielditem = true })
	player:hud_change(mcl_hunger.eat_anim_hud[player_name], "text", "blank.png")
	mcl_hunger.eat_internal[player_name] = {
		is_eating            = false,
		is_eating_no_padding = false,
		itemname             = nil,
		item_definition      = nil,
		hp_change            = nil,
		replace_with_item    = nil,
		itemstack            = nil,
		user                 = nil,
		pointed_thing        = nil,
		pitch                = nil,
		do_item_eat          = false,
		_custom_itemstack    = nil,
		_custom_var          = {},
		_custom_func         = nil,
		_custom_wrapper      = nil,
		_custom_do_delayed   = false,
	}
	eat_start_timers[player] = 0
	eat_tick_timers[player] = 0
	eat_effects_cooldown[player] = 0
end

---Hunger ticking code
---@param player core.Player
---@param dtime  number
local function tick_hunger(player, dtime)
	local food_tick_timer       = food_tick_timers[player] and food_tick_timers[player] + dtime or 0
	local food_saturation_level = mcl_hunger.get_saturation(player)
	local food_level            = mcl_hunger.get_hunger(player)
	local player_name           = player:get_player_name()
	local player_health         = player:get_hp()
	local max_tick_timer        = tonumber(core.settings:get("mcl_health_regen_delay")) or 0.5
	local needs_regen           = player_health > 0 and player_health < player:get_properties().hp_max

	if food_tick_timer > 4 then
		food_tick_timer = 0

		if player_health > 0 then
			-- let hunger work always
			-- mcl_hunger.exhaust(player_name, mcl_hunger.EXHAUST_HUNGER) -- later for hunger status effect
			mcl_hunger.update_exhaustion_hud(player)
		end
		if natural_regeneration and food_level >= 18 and needs_regen then
			-- health regeneration
			player:set_hp(player_health + 1)
			mcl_hunger.exhaust(player_name, mcl_hunger.EXHAUST_REGEN)
			mcl_hunger.update_exhaustion_hud(player)
		elseif food_level == 0 then
			-- the amount of health at which a player will stop to get harmed by starvation
			local maximum_starvation = 1
			-- TODO: implement Minecraft-like difficulty modes and the update maximumStarvation here
			if player_health > maximum_starvation then
				mcl_util.deal_damage(player, 1, { type = "starve" })
			end
		end
	elseif natural_regeneration and needs_regen
				and food_tick_timer > max_tick_timer and food_level == 20 and food_saturation_level > 0 then
		-- fast regeneration
		food_tick_timer = 0
		player:set_hp(player_health + 1)

		mcl_hunger.exhaust(player_name, mcl_hunger.EXHAUST_REGEN)
		mcl_hunger.update_exhaustion_hud(player)
	end

	food_tick_timers[player] = food_tick_timer
end

---Eating delay code
---@param player core.Player
---@param dtime  number
local function tick_eat_delay(player, dtime)
	local player_name = player:get_player_name()

	if mcl_hunger.eat_internal[player_name] and mcl_hunger.eat_internal[player_name].is_eating or mcl_hunger.eat_internal[player_name]._custom_do_delayed then
		mcl_hunger.eat_internal[player_name].is_eating = true
		mcl_hunger.eat_internal[player_name].is_eating_no_padding = true

		local control = player:get_player_control()
		local current_itemstack = player:get_wielded_item()

		if not eat_start_timers[player] then
			eat_start_timers[player] = 0
		end

		eat_start_timers[player] = eat_start_timers[player] + dtime

		if not eat_tick_timers[player] then
			eat_tick_timers[player] = 0
		end
		if not eat_effects_cooldown[player] then
			eat_effects_cooldown[player] = 0
		end
		if not mcl_hunger.eat_internal[player_name].pitch then
			mcl_hunger.eat_internal[player_name].pitch = 1 + math.random(-10, 10) * 0.005
		end

		local item_changed = current_itemstack ~= mcl_hunger.eat_internal[player_name].itemstack and current_itemstack ~= mcl_hunger.eat_internal[player_name]._custom_itemstack
		local holding_control = control.RMB or control.LMB -- check if holding RMB (or LMB as workaround for touchscreen)

		if not item_changed and holding_control then
			eat_tick_timers[player]      = eat_tick_timers[player] + dtime
			eat_effects_cooldown[player] = eat_effects_cooldown[player] + dtime

			playerphysics.add_physics_factor(player, "speed", "mcl_hunger:eating_speed", mcl_hunger.EATING_WALK_SPEED)

			player:hud_set_flags({ wielditem = false })
			local itemstackdef = current_itemstack:get_definition()
			local wield_image  = itemstackdef.wield_image
			if not wield_image or wield_image == "" then
				wield_image = itemstackdef.inventory_image
			end
			player:hud_change(mcl_hunger.eat_anim_hud[player_name], "text", wield_image)
			player:hud_change(mcl_hunger.eat_anim_hud[player_name], "offset", { x = 0, y = 50 * math.sin(10 * eat_tick_timers[player] + math.random()) - 50 })

			if eat_effects_cooldown[player] > 0.2 then
				eat_effects_cooldown[player] = 0

				if not mcl_hunger.eat_internal[player_name].user then
					mcl_hunger.eat_internal[player_name].user = player
				end

				if not mcl_hunger.eat_internal[player_name].itemname then
					mcl_hunger.eat_internal[player_name].itemname = current_itemstack:get_name()
				end

				if not mcl_hunger.eat_internal[player_name].hp_change then
					mcl_hunger.eat_internal[player_name].hp_change = 0
				end

				local pos      = player:get_pos()
				local itemname = mcl_hunger.eat_internal[player_name].itemname
				local def      = core.registered_items[itemname]

				mcl_hunger.eat_effects(
					mcl_hunger.eat_internal[player_name].user,
					mcl_hunger.eat_internal[player_name].itemname,
					pos,
					mcl_hunger.eat_internal[player_name].hp_change,
					def,
					mcl_hunger.eat_internal[player_name].pitch
				)
			end

			-- check if eating delay is over
			if eat_tick_timers[player] >= mcl_hunger.EATING_DELAY then
				if not mcl_hunger.eat_internal[player_name]._custom_do_delayed then
					mcl_hunger.eat_internal[player_name].do_item_eat = true

					core.do_item_eat(
						mcl_hunger.eat_internal[player_name].hp_change,
						mcl_hunger.eat_internal[player_name].replace_with_item,
						mcl_hunger.eat_internal[player_name].itemstack,
						mcl_hunger.eat_internal[player_name].user,
						mcl_hunger.eat_internal[player_name].pointed_thing
					)

					-- bypass core.do_item_eat and only execute _custom_wrapper
				elseif mcl_hunger.eat_internal[player_name]._custom_itemstack and mcl_hunger.eat_internal[player_name]._custom_wrapper and mcl_hunger.eat_internal[player_name]._custom_itemstack == current_itemstack then
					mcl_hunger.eat_internal[player_name]._custom_wrapper(player_name)

					--player:get_inventory():set_stack("main", player:get_wield_index(), itemstack)
				end

				clear_eat_internal_and_timers(player, player_name)
			end
		elseif eat_start_timers[player] and eat_start_timers[player] > 0.2 then
			playerphysics.remove_physics_factor(player, "speed", "mcl_hunger:eating_speed")
			player:hud_set_flags({ wielditem = true })
			player:hud_change(mcl_hunger.eat_anim_hud[player_name], "text", "blank.png")
			mcl_hunger.eat_internal[player_name].is_eating_no_padding = false
		elseif eat_start_timers[player] and eat_start_timers[player] > mcl_hunger.EATING_TOUCHSCREEN_DELAY_PADDING then
			clear_eat_internal_and_timers(player, player_name)
		end
	end

	if eat_start_timers[player] and eat_start_timers[player] > mcl_hunger.EATING_DELAY + mcl_hunger.EATING_TOUCHSCREEN_DELAY_PADDING then
		clear_eat_internal_and_timers(player, player_name)
	end
end

core.register_globalstep(function(dtime)
	for _, player in pairs(core.get_connected_players()) do
		if mcl_hunger.get_active() then
			tick_hunger(player, dtime)
		end
		-- Players should be able to eat, regardless if hunger is enabled
		tick_eat_delay(player, dtime)
	end
end)
