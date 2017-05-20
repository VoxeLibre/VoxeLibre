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
mcl_hunger.exhaustion = {} -- Exhaustion is experimental!

mcl_hunger.HUNGER_TICK = 800 -- time in seconds after that 1 hunger point is taken
mcl_hunger.EXHAUST_DIG = 3  -- exhaustion increased this value after digged node
mcl_hunger.EXHAUST_PLACE = 1 -- exhaustion increased this value after placed
mcl_hunger.EXHAUST_MOVE = 0.3 -- exhaustion increased this value if player movement detected
mcl_hunger.EXHAUST_LVL = 160 -- at what exhaustion player satiation gets lowerd


--load custom settings
local set = io.open(minetest.get_modpath("mcl_hunger").."/mcl_hunger.conf", "r")
if set then 
	dofile(minetest.get_modpath("mcl_hunger").."/mcl_hunger.conf")
	set:close()
end

local function custom_hud(player)
	hb.init_hudbar(player, "satiation", mcl_hunger.get_hunger_raw(player))
end

dofile(minetest.get_modpath("mcl_hunger").."/hunger.lua")

-- register satiation hudbar
hb.register_hudbar("satiation", 0xFFFFFF, S("Satiation"), { icon = "hbhunger_icon.png", bgicon = "hbhunger_bgicon.png",  bar = "hbhunger_bar.png" }, 20, 20, false)

-- update hud elemtens if value has changed
local function update_hud(player)
	local name = player:get_player_name()
 --hunger
	local h_out = tonumber(mcl_hunger.hunger_out[name])
	local h = tonumber(mcl_hunger.hunger[name])
	if h_out ~= h then
		mcl_hunger.hunger_out[name] = h
		hb.change_hudbar(player, "satiation", h)
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
	mcl_hunger.exhaustion[name] = 0
	mcl_hunger.poisonings[name] = 0
	custom_hud(player)
	mcl_hunger.set_hunger_raw(player)
end)

minetest.register_on_respawnplayer(function(player)
	-- reset hunger (and save)
	local name = player:get_player_name()
	mcl_hunger.hunger[name] = 20
	mcl_hunger.set_hunger_raw(player)
	mcl_hunger.exhaustion[name] = 0
end)

local main_timer = 0
local timer = 0		-- Half second timer
local timer2 = 0
local timerMult = 1	-- Cycles from 0 to 7, each time when timer hits half a second
minetest.register_globalstep(function(dtime)
	main_timer = main_timer + dtime
	timer = timer + dtime
	timer2 = timer2 + dtime
	if main_timer > mcl_hunger.HUD_TICK or timer > 0.5 or timer2 > mcl_hunger.HUNGER_TICK then
		if main_timer > mcl_hunger.HUD_TICK then main_timer = 0 end
		for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()

		local h = tonumber(mcl_hunger.hunger[name])
		local hp = player:get_hp()
		if timer > 0.5 then
			-- Quick heal (every 0.5s)
			if h >= 20 and hp > 0 and hp < 20 then
				-- +1 HP, -3 food points
				player:set_hp(hp+1)
				h = h-3
				mcl_hunger.hunger[name] = h
				mcl_hunger.set_hunger_raw(player)
			-- Slow heal, and hunger damage (every 4s)
			elseif timerMult == 0 then
				if h >= 18 and hp > 0 and hp < 20 then
					-- +1 HP, -3 food points
					player:set_hp(hp+1)
					h = h-3
					mcl_hunger.hunger[name] = h
					mcl_hunger.set_hunger_raw(player)
				elseif h == 0 then
				-- Damage hungry player down to 1 HP
					if hp-1 >= 0 then
						player:set_hp(hp-1)
					end
				end
			end
			-- lower satiation by 1 point after xx seconds
			if timer2 > mcl_hunger.HUNGER_TICK then
				if h > 0 then
					h = h-1
					mcl_hunger.hunger[name] = h
					mcl_hunger.set_hunger_raw(player)
				end
			end

			-- update all hud elements
			update_hud(player)
			
			local controls = player:get_player_control()
			-- Determine if the player is walking
			if controls.up or controls.down or controls.left or controls.right then
				mcl_hunger.handle_node_actions(nil, nil, player)
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
	if timer2 > mcl_hunger.HUNGER_TICK then timer2 = 0 end
end)

end
