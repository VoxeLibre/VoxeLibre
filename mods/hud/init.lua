hud = {}

local health_hud = {}
hud.hunger = {}
local hunger_hud = {}
local air_hud = {}
hud.armor = {}
local armor_hud = {}

local SAVE_INTERVAL = 0.5*60--currently useless

--default settings
HUD_ENABLE_HUNGER = minetest.setting_getbool("hud_hunger_enable")
HUD_SHOW_ARMOR = false
if minetest.get_modpath("3d_armor") ~= nil then HUD_SHOW_ARMOR = true end
if HUD_ENABLE_HUNGER == nil then HUD_ENABLE_HUNGER = minetest.setting_getbool("enable_damage") end
HUD_HUNGER_TICK = 300
HUD_HEALTH_POS = {x=0.5,y=0.89}
HUD_HEALTH_OFFSET = {x=-175, y=2}
HUD_HUNGER_POS = {x=0.5,y=0.89}
HUD_HUNGER_OFFSET = {x=15, y=2}
HUD_AIR_POS = {x=0.5,y=0.88}
HUD_AIR_OFFSET = {x=15,y=-15}
HUD_ARMOR_POS = {x=0.5,y=.88}
HUD_ARMOR_OFFSET = {x=-175, y=-15}

--load costum settings
local set = io.open(minetest.get_modpath("hud").."/hud.conf", "r")
if set then 
	dofile(minetest.get_modpath("hud").."/hud.conf")
	set:close()
else
	if not HUD_ENABLE_HUNGER then
		HUD_AIR_OFFSET = {x=15,y=0}
	end
end

--minetest.after(SAVE_INTERVAL, timer, SAVE_INTERVAL)

local function hide_builtin(player)
	 player:hud_set_flags({crosshair = true, hotbar = true, healthbar = false, wielditem = true, breathbar = false})
end


local function costum_hud(player)

 --fancy hotbar
 --player:hud_set_hotbar_image("hud_hotbar.png")
 --player:hud_set_hotbar_selected_image("hud_hotbar_selected.png")

 if minetest.setting_getbool("enable_damage") then
 --hunger
	if HUD_ENABLE_HUNGER then
       	 player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_HUNGER_POS,
		scale = {x=1, y=1},
		text = "hud_hunger_bg.png",
		number = 20,
		alignment = {x=-1,y=-1},
		offset = HUD_HUNGER_OFFSET,
	 })

	 hunger_hud[player:get_player_name()] = player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_HUNGER_POS,
		scale = {x=1, y=1},
		text = "hud_hunger_fg.png",
		number = 20,
		alignment = {x=-1,y=-1},
		offset = HUD_HUNGER_OFFSET,
	 })
	end
 --health
        player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_HEALTH_POS,
		scale = {x=1, y=1},
		text = "hud_heart_bg.png",
		number = 20,
		alignment = {x=-1,y=-1},
		offset = HUD_HEALTH_OFFSET,
	})

	health_hud[player:get_player_name()] = player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_HEALTH_POS,
		scale = {x=1, y=1},
		text = "hud_heart_fg.png",
		number = player:get_hp(),
		alignment = {x=-1,y=-1},
		offset = HUD_HEALTH_OFFSET,
	})

 --air
	air_hud[player:get_player_name()] = player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_AIR_POS,
		scale = {x=1, y=1},
		text = "hud_air_fg.png",
		number = 0,
		alignment = {x=-1,y=-1},
		offset = HUD_AIR_OFFSET,
	})

 --armor
 if HUD_SHOW_ARMOR then
       player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_ARMOR_POS,
		scale = {x=1, y=1},
		text = "hud_armor_bg.png",
		number = 20,
		alignment = {x=-1,y=-1},
		offset = HUD_ARMOR_OFFSET,
	})

	armor_hud[player:get_player_name()] = player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_ARMOR_POS,
		scale = {x=1, y=1},
		text = "hud_armor_fg.png",
		number = 0,
		alignment = {x=-1,y=-1},
		offset = HUD_ARMOR_OFFSET,
	})
  end
 end

end

--needs to be set always(for 3darmor)
function hud.set_armor()
end


if HUD_ENABLE_HUNGER then dofile(minetest.get_modpath("hud").."/hunger.lua") end
if HUD_SHOW_ARMOR then dofile(minetest.get_modpath("hud").."/armor.lua") end


local function update_hud(player)
 --air
	local air = player:get_breath()*2
	if player:get_breath() > 10 then air = 0 end
	player:hud_change(air_hud[player:get_player_name()], "number", air)
 --health
	player:hud_change(health_hud[player:get_player_name()], "number", player:get_hp())
 --armor
	local arm = tonumber(hud.armor[player:get_player_name()])
	if not arm then arm = 0 end
	player:hud_change(armor_hud[player:get_player_name()], "number", arm)
 --hunger
	local h = tonumber(hud.hunger[player:get_player_name()])
	if h>20 then h=20 end
	player:hud_change(hunger_hud[player:get_player_name()], "number", h)
end

local function timer(interval, player)
	if interval > 0 then
		hud.save_hunger(player)
		minetest.after(interval, timer, interval, player)
	end
end

minetest.register_on_joinplayer(function(player)
	hud.armor[player:get_player_name()] = 0
	if HUD_ENABLE_HUNGER then hud.hunger[player:get_player_name()] = hud.load_hunger(player) end
	if not hud.hunger[player:get_player_name()] then
		hud.hunger[player:get_player_name()] = 20
	end
	minetest.after(0.5, function()
		hide_builtin(player)
		costum_hud(player)
		if HUD_ENABLE_HUNGER then hud.save_hunger(player) end
	end)
end)

minetest.register_on_respawnplayer(function(player)
	hud.hunger[player:get_player_name()] = 20
	minetest.after(0.5, function()
		if HUD_ENABLE_HUNGER then hud.save_hunger(player) end
	end)
end)

local timer = 0
local timer2 = 0
minetest.after(2.5, function()
	minetest.register_globalstep(function(dtime)
	 timer = timer + dtime
	 timer2 = timer2 + dtime
		for _,player in ipairs(minetest.get_connected_players()) do
			if minetest.setting_getbool("enable_damage") then
			 local h = tonumber(hud.hunger[player:get_player_name()])
			 if HUD_ENABLE_HUNGER and timer > 4 then
				if h>=16 and player:get_hp() > 0 then
					player:set_hp(player:get_hp()+1)
				elseif h<=1 and minetest.setting_getbool("enable_damage") then
					if player:get_hp()-1 >= 1 then player:set_hp(player:get_hp()-1) end
				end
			 end
			 if HUD_ENABLE_HUNGER and timer2>HUD_HUNGER_TICK then
				if h>0 then
					h=h-1
					hud.hunger[player:get_player_name()]=h
					hud.save_hunger(player)
				end
			 end
			 if HUD_SHOW_ARMOR then hud.get_armor(player) end
			 update_hud(player)
			end
		end
		if timer>4 then timer=0 end
		if timer2>HUD_HUNGER_TICK then timer2=0 end
	end)
end)
