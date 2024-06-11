--register built-in HUD bars
if minetest.settings:get_bool("enable_damage") or vl_hudbars.settings.forceload_default_hudbars then
	vl_hudbars.register_hudbar({
		identifier = "health",
		sort_index = 5,
		on_right = false,
		direction = 0,
		layer_gap = 4,
		scale_y = 1,
		value_type = "absolute",
		is_compound = true,
		value_scale = 1,
		round_to_full_texture = true,
		default_hidden = false,
		parts = {health_main = {
			default_max_val = 20,
			default_value = 20,
			icon = "hudbars_icon_health.png",
			bgicon = "hudbars_bgicon_health.png",
			part_sort_index = 10,
			take_up_space = true,
			z_index_offset = 0,
			},
			absorption = {
			default_max_val = 0,
			default_value = 0,
			icon = "mcl_potions_icon_absorb.png",
			bgicon = "hudbars_bgicon_health.png",
			z_index_step = -1,
			part_sort_index = 8,
			take_up_space = true,
			z_index_offset = -1,
			}
		}
	})
	vl_hudbars.register_hudbar({
		identifier = "breath",
		sort_index = 5,
		on_right = true,
		direction = 1,
		layer_gap = 4,
		scale_y = 1,
		value_type = "absolute",
		is_compound = false,
		take_up_space = true,
		value_scale = 0.5,
		round_to_full_texture = true,
		default_max_val = 10,
		default_value = 10,
		icon = "hudbars_icon_breath.png",
		bgicon = "hudbars_bgicon_breath.png",
	})
end


local function hide_builtin(player)
	local flags = player:hud_get_flags()
	flags.healthbar = false
	flags.breathbar = false
	player:hud_set_flags(flags)
end


local function custom_hud(player)
	if minetest.settings:get_bool("enable_damage") or vl_hudbars.settings.forceload_default_hudbars then
		local hide
		if minetest.settings:get_bool("enable_damage") then
			hide = false
		else
			hide = true
		end
		local hp = player:get_hp()
		local hp_max = player:get_properties().hp_max
		vl_hudbars.init_hudbar(player, "health")
		vl_hudbars.change_value(player, "health", math.min(hp, hp_max), hp_max, "health_main")
		if hide then
			vl_hudbars.hide(player, "health", "health_main")
		else
			vl_hudbars.show(player, "health", "health_main")
		end
		local breath = player:get_breath()
		local breath_max = player:get_properties().breath_max
		local hide_breath
		if breath >= breath_max and vl_hudbars.settings.autohide_breath == true then
			hide_breath = true
		else
			hide_breath = false
		end
		vl_hudbars.init_hudbar(player, "breath")
		vl_hudbars.change_value(player, "breath", math.min(breath, breath_max), breath_max)
		if hide_breath or hide then
			vl_hudbars.hide(player, "breath")
		else
			vl_hudbars.show(player, "breath")
		end
	end
end

function vl_hudbars.update_health(player, hp_change)
	hp_change = hp_change or 0
	local hp_max = player:get_properties().hp_max
	local hp = player:get_hp() + hp_change
	if hp > hp_max then hp = hp_max end
	vl_hudbars.change_value(player, "health", hp, hp_max, "health_main")
end

-- update built-in HUD bars
local function update_hud(player, has_damage)
	if not player or not player.get_player_name then return end
	if has_damage then
		if vl_hudbars.settings.forceload_default_hudbars then
			vl_hudbars.show(player, "health")
		end
		--air
		local breath_max = player:get_properties().breath_max
		local breath = player:get_breath()

		if breath >= breath_max and vl_hudbars.settings.autohide_breath == true then
			vl_hudbars.hide(player, "breath")
		else
			vl_hudbars.show(player, "breath")
			vl_hudbars.change_value(player, "breath", math.min(breath, breath_max), breath_max)
		end
		-- health handled in on_hpchange callback
	elseif vl_hudbars.settings.forceload_default_hudbars then
		vl_hudbars.hide(player, "health")
		vl_hudbars.hide(player, "breath")
	end
end

minetest.register_on_player_hpchange(function(player, hp_change)
	if vl_hudbars.has_hudbar(player, "health") then
		vl_hudbars.update_health(player, hp_change)
	end
end)

minetest.register_on_respawnplayer(function(player)
	vl_hudbars.update_health(player)
	vl_hudbars.hide(player, "breath")
end)

minetest.register_on_joinplayer(function(player)
	hide_builtin(player)
	custom_hud(player)
end)



local main_timer = 0
local timer = 0
minetest.register_globalstep(function(dtime)
	main_timer = main_timer + dtime
	timer = timer + dtime
	if main_timer > vl_hudbars.settings.tick or timer > 4 then
		if main_timer > vl_hudbars.settings.tick then main_timer = 0 end
		-- only proceed if damage is enabled
		local has_dmg = minetest.settings:get_bool("enable_damage")
		if has_dmg or vl_hudbars.settings.forceload_default_hudbars then
			for name, _ in pairs(vl_hudbars.players) do
				-- update all hud elements
				local player = minetest.get_player_by_name(name)
				update_hud(player, has_dmg)
			end
		end
	end
	if timer > 4 then timer = 0 end
end)
