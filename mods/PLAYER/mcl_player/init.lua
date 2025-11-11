local string = string
local sf = string.format

-- Luanti 0.4 mod: player
-- See README.txt for licensing and other information.
mcl_player = {}

-- Player animation blending
-- Note: This is currently broken due to a bug in Irrlicht, leave at 0
local animation_blend = 0

local function get_mouse_button(player)
	local controls = player:get_player_control()
	local get_wielded_item_name = player:get_wielded_item():get_name()
	if controls.RMB and not string.find(get_wielded_item_name, "mcl_bows:bow") and
		not string.find(get_wielded_item_name, "mcl_bows:crossbow") and
		core.get_item_group(get_wielded_item_name, "spear") == 0 and
		not mcl_shields.wielding_shield(player, 1) and not mcl_shields.wielding_shield(player, 2) or controls.LMB then
		return true
	else
		return false
	end
end

mcl_player.registered_player_models = {}

-- Local for speed.
local models = mcl_player.registered_player_models

function mcl_player.player_register_model(name, def)
	models[name] = def
end

-- Player stats and animations
local player_model = {}
local player_textures = {}
local player_anim = {}
local player_sneak = {}
local player_visible = {}
mcl_player.player_attached = {}

local function get_player_textures(name)
	local textures = player_textures[name]
	if textures then return textures end

	local textures = { "character.png", "blank.png", "blank.png" }
	player_textures[name] = textures
	return textures

end

function mcl_player.player_get_animation(player)
	local name = player:get_player_name()
	local textures = get_player_textures(name)

	if not player_visible[name] then
		textures = table.copy(textures)
		textures[1] = "blank.png"
	end

	return {
		model = player_model[name],
		textures = textures,
		animation = player_anim[name],
		visibility = player_visible[name]
	}
end

local registered_on_visual_change = {}

function mcl_player.register_on_visual_change(func)
	table.insert(registered_on_visual_change, func)
end

local function update_player_textures(player)
	local name = player:get_player_name()
	local textures = get_player_textures(name)

	if not player_visible[name] then
		textures = table.copy(textures)
		textures[1] = "blank.png"
	end

	player:set_properties({ textures = textures })

	-- Delay calling the callbacks because mods (including mcl_player)
	-- need to fully initialize player data from minetest.register_on_joinplayer
	-- before callbacks run
	minetest.after(0.1, function()
		if player:is_player() then
			for i, func in ipairs(registered_on_visual_change) do
				func(player)
			end
		end
	end)
end

-- Called when a player's appearance needs to be updated
function mcl_player.player_set_model(player, model_name)
	local name = player:get_player_name()
	local model = models[model_name]
	if model then
		if player_model[name] == model_name then
			return
		end
		player_model[name] = model_name
		player:set_properties({
			mesh = model_name,
			visual = "mesh",
			visual_size = model.visual_size or { x = 1, y = 1 },
			damage_texture_modifier = "^[colorize:red:130",
		})
		update_player_textures(player)

		local new_anim = "stand"
		local model_animations = models[model_name].animations
		local old_anim = player_anim[name]
		if model_animations and old_anim and model_animations[old_anim] then
			new_anim = old_anim
		end
		mcl_player.player_set_animation(player, new_anim)
	else
		player:set_properties({
			textures = { "player.png", "player_back.png", },
			visual = "upright_sprite",
		})
	end
end

function mcl_player.player_set_visibility(player, visible)
	local name = player:get_player_name()
	if player_visible[name] == visible then return end
	player_visible[name] = visible
	update_player_textures(player)
end

function mcl_player.player_set_skin(player, texture)
	local name = player:get_player_name()
	local textures = get_player_textures(name)
	textures[1] = texture
	update_player_textures(player)
end

function mcl_player.player_get_skin(player)
	local name = player:get_player_name()
	local textures = get_player_textures(name)
	return textures[1]
end

function mcl_player.player_set_armor(player, texture)
	local name = player:get_player_name()
	local textures = get_player_textures(name)
	textures[2] = texture
	update_player_textures(player)
end

---@param player mt.PlayerObjectRef
---@param x number
---@param y number
---@param w number
---@param h number
---@param fsname string
---@return string
function mcl_player.get_player_formspec_model(player, x, y, w, h, fsname)
	local name = player:get_player_name()
	local model = player_model[name]
	local anim = models[model].animations["stand"]
	local textures = get_player_textures(name)
	if not player_visible[name] then
		textures = table.copy(textures)
		textures[1] = "blank.png"
	end
	return sf("model[%s,%s;%s,%s;%s;%s;%s;0,180;false;false;%s,%s]", x, y, w, h, fsname, model,
		table.concat(textures, ","), anim.x, anim.y)
end

function mcl_player.player_set_animation(player, anim_name, speed)
	local name = player:get_player_name()
	if player_anim[name] == anim_name then
		return
	end
	local model = player_model[name] and models[player_model[name]]
	if not (model and model.animations[anim_name]) then
		return
	end
	local anim = model.animations[anim_name]
	player_anim[name] = anim_name
	player:set_animation(anim, speed or anim.speed or model.animation_speed, animation_blend)
end

-- Update appearance when the player joins
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	mcl_player.player_attached[name] = false
	player_visible[name] = true
	get_player_textures(name)

	--player:set_local_animation({x=0, y=79}, {x=168, y=187}, {x=189, y=198}, {x=200, y=219}, 30)
-- 	player:set_fov(86.1) -- see <https://minecraft.gamepedia.com/Options#Video_settings>>>>
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_model[name] = nil
	player_anim[name] = nil
	player_textures[name] = nil
	player_sneak[name] = nil
	player_visible[name] = nil
end)

-- Localize for better performance.
local player_set_animation = mcl_player.player_set_animation
local player_attached = mcl_player.player_attached

-- Check each player and apply animations
minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local model_name = player_model[name]
		local model = model_name and models[model_name]
		if model and not player_attached[name] then
			local controls = player:get_player_control()
			local walking = false
			local animation_speed_mod = model.animation_speed or 30

			-- Determine if the player is walking
			if controls.up or controls.down or controls.left or controls.right then
				walking = true
			end

			-- Determine if the player is sneaking, and reduce animation speed if so
			if controls.sneak then
				animation_speed_mod = animation_speed_mod / 2
			end

			if mcl_shields.is_blocking(player) then
				animation_speed_mod = animation_speed_mod / 2
			end

			-- ask if player is swiming
			local head_in_water = minetest.get_item_group(mcl_playerinfo[name].node_head, "water") ~= 0
			-- ask if player is sprinting
			local is_sprinting = mcl_sprint.is_sprinting(name)

			local velocity = player:get_velocity() or player:get_player_velocity()

			-- Apply animations based on what the player is doing
			if player:get_hp() == 0 then
				player_set_animation(player, "die")
			elseif player:get_meta():get_int("mcl_damage:damage_animation") > 0 then
				player_set_animation(player, "walk", animation_speed_mod)
				local name = player:get_player_name()
				minetest.after(0.5, function()
					local player = minetest.get_player_by_name(name)
					if not player then return end
					player:get_meta():set_int("mcl_damage:damage_animation", 0)
				end)
			elseif mcl_playerplus.elytra[player] and mcl_playerplus.elytra[player].active then

			elseif walking and velocity.x > 0.35
				or walking and velocity.x < -0.35
				or walking and velocity.z > 0.35
				or walking and velocity.z < -0.35 then
				local wielded_itemname = player:get_wielded_item():get_name()
				local no_arm_moving = string.find(wielded_itemname, "mcl_bows:bow") or
					mcl_shields.wielding_shield(player, 1) or
					mcl_shields.wielding_shield(player, 2) or
					core.get_item_group(wielded_itemname, "spear") > 0
				if player_sneak[name] ~= controls.sneak then
					player_anim[name] = nil
					player_sneak[name] = controls.sneak
				end
				if get_mouse_button(player) == true and not controls.sneak and head_in_water and is_sprinting == true then
					player_set_animation(player, "swim_walk_mine", animation_speed_mod)
				elseif not controls.sneak and head_in_water and is_sprinting == true then
					player_set_animation(player, "swim_walk", animation_speed_mod)
				elseif no_arm_moving and controls.RMB and controls.sneak or
					string.find(wielded_itemname, "mcl_bows:crossbow_") and controls.sneak then
					player_set_animation(player, "bow_sneak", animation_speed_mod)
				elseif no_arm_moving and controls.RMB or string.find(wielded_itemname, "mcl_bows:crossbow_") then
					player_set_animation(player, "bow_walk", animation_speed_mod)
				elseif is_sprinting == true and get_mouse_button(player) == true and not controls.sneak and not head_in_water then
					player_set_animation(player, "run_walk_mine", animation_speed_mod)
				elseif get_mouse_button(player) == true and not controls.sneak then
					player_set_animation(player, "walk_mine", animation_speed_mod)
				elseif get_mouse_button(player) == true and controls.sneak and is_sprinting ~= true then
					player_set_animation(player, "sneak_walk_mine", animation_speed_mod)
				elseif is_sprinting == true and not controls.sneak and not head_in_water then
					player_set_animation(player, "run_walk", animation_speed_mod)
				elseif controls.sneak and not get_mouse_button(player) == true then
					player_set_animation(player, "sneak_walk", animation_speed_mod)
				else
					player_set_animation(player, "walk", animation_speed_mod)
				end
			elseif get_mouse_button(player) == true and not controls.sneak and head_in_water and is_sprinting == true then
				player_set_animation(player, "swim_mine")
			elseif not get_mouse_button(player) == true and not controls.sneak and head_in_water and is_sprinting == true then
				player_set_animation(player, "swim_stand")
			elseif get_mouse_button(player) == true and not controls.sneak then
				player_set_animation(player, "mine")
			elseif get_mouse_button(player) == true and controls.sneak then
				player_set_animation(player, "sneak_mine")
			elseif not controls.sneak and head_in_water and is_sprinting == true then
				player_set_animation(player, "swim_stand", animation_speed_mod)
			elseif not controls.sneak then
				player_set_animation(player, "stand", animation_speed_mod)
			else
				player_set_animation(player, "sneak_stand", animation_speed_mod)
			end
		end
	end
end)
