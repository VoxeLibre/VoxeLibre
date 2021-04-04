-- Minetest 0.4 mod: player
-- See README.txt for licensing and other information.
mcl_player = {}

-- Player animation blending
-- Note: This is currently broken due to a bug in Irrlicht, leave at 0
local animation_blend = 0

local function get_mouse_button(player)
	local controls = player:get_player_control()
	local get_wielded_item_name = player:get_wielded_item():get_name()
	if controls.RMB and not string.find(player:get_wielded_item():get_name(), "mcl_bows:bow") or controls.LMB then
		return true
	else
		return false
	end
end

mcl_player.registered_player_models = { }

-- Local for speed.
local models = mcl_player.registered_player_models

function mcl_player.player_register_model(name, def)
	models[name] = def
end

-- Default player appearance
mcl_player.player_register_model("character.b3d", {
	animation_speed = 30,
	textures = {"character.png", },
	animations = {
		-- Standard animations.
		stand		= {x=  0, y= 79},
		lay		= {x=162, y=166},
		walk		= {x=168, y=187},
		mine		= {x=189, y=198},
		walk_mine	= {x=200, y=219},
		sit		= {x= 81, y=160},
		sneak_stand	= {x=222, y=302},
		sneak_mine	= {x=346, y=366},
		sneak_walk	= {x=304, y=323},
		sneak_walk_mine	= {x=325, y=344},
		run_walk	= {x=440, y=460},
		run_walk_mine	= {x=461, y=481},
		sit_mount	= {x=484, y=484},
	},
})

-- Player stats and animations
local player_model = {}
local player_textures = {}
local player_anim = {}
local player_sneak = {}
mcl_player.player_attached = {}

function mcl_player.player_get_animation(player)
	local name = player:get_player_name()
	return {
		model = player_model[name],
		textures = player_textures[name],
		animation = player_anim[name],
	}
end

-- Called when a player's appearance needs to be updated
function mcl_player.player_set_model(player, model_name)
	local name = player:get_player_name()
	local model = models[model_name]
	if model then
		if player_model[name] == model_name then
			return
		end
		player:set_properties({
			mesh = model_name,
			textures = player_textures[name] or model.textures,
			visual = "mesh",
			visual_size = model.visual_size or {x=1, y=1},
			damage_texture_modifier = "^[colorize:red:130",
		})
		mcl_player.player_set_animation(player, "stand")
	else
		player:set_properties({
			textures = { "player.png", "player_back.png", },
			visual = "upright_sprite",
		})
	end
	player_model[name] = model_name
end

function mcl_player.player_set_textures(player, textures, preview)
	local name = player:get_player_name()
	player_textures[name] = textures
	player:set_properties({textures = textures,})
	if preview then
		player:get_meta():set_string("mcl_player:preview", preview)
	end
end

function mcl_player.player_get_preview(player)
	local preview = player:get_meta():get_string("mcl_player:preview")
	if preview == nil or preview == "" then
		return "player.png"
	else
		return preview
	end
end

function mcl_player.get_player_formspec_model(player, x, y, w, h, fsname)
	local name = player:get_player_name()
	local model = player_model[name]
	local anim = models[model].animations[player_anim[name]]
	return "model[" .. x .. "," .. y .. ";" .. w .. "," .. h .. ";" .. fsname .. ";" .. model .. ";" .. table.concat(player_textures[name], ",") .. ";0," .. 180 .. ";false;false;" .. anim.x .. "," .. anim.y .. "]"
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
	player:set_animation(anim, speed or model.animation_speed, animation_blend)
end

-- Update appearance when the player joins
minetest.register_on_joinplayer(function(player)
	mcl_player.player_attached[player:get_player_name()] = false
	mcl_player.player_set_model(player, "character.b3d")
	--player:set_local_animation({x=0, y=79}, {x=168, y=187}, {x=189, y=198}, {x=200, y=219}, 30)
	player:set_fov(86.1) -- see <https://minecraft.gamepedia.com/Options#Video_settings>>>>
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_model[name] = nil
	player_anim[name] = nil
	player_textures[name] = nil
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



			-- ask if player is swiming
			local head_in_water = minetest.get_item_group(mcl_playerinfo[name].node_head, "water") ~= 0
			-- ask if player is sprinting
			local is_sprinting = mcl_sprint.is_sprinting(name)

			local velocity = player:get_velocity() or player:get_player_velocity()

			-- Apply animations based on what the player is doing
			if player:get_hp() == 0 then
				player_set_animation(player, "die")
			elseif walking and velocity.x > 0.35 or walking and velocity.x < -0.35 or walking and velocity.z > 0.35 or walking and velocity.z < -0.35 then
				if player_sneak[name] ~= controls.sneak then
					player_anim[name] = nil
					player_sneak[name] = controls.sneak
				end
				if get_mouse_button(player) == true and not controls.sneak and head_in_water and is_sprinting == true then
					player_set_animation(player, "swim_walk_mine", animation_speed_mod)
				elseif not controls.sneak and head_in_water and is_sprinting == true then
					player_set_animation(player, "swim_walk", animation_speed_mod)
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

-- Don't change HP if the player falls in the water or through End Portal:
minetest.register_on_player_hpchange(function(player, hp_change, reason)
	if reason and reason.type == "fall" and player then
		local pos = player:get_pos()
		local node = minetest.get_node(pos)
		local velocity = player:get_velocity() or player:get_player_velocity() or {x=0,y=-10,z=0}
		local v_axis_max = math.max(math.abs(velocity.x), math.abs(velocity.y), math.abs(velocity.z))
		local step = {x = velocity.x / v_axis_max, y = velocity.y / v_axis_max, z = velocity.z / v_axis_max}
		for i = 1, math.ceil(v_axis_max/5)+1 do -- trace at least 1/5 of the way per second
			if not node or node.name == "ignore" then
				minetest.get_voxel_manip():read_from_map(pos, pos)
				node = minetest.get_node(pos)
			end
			if node then
				if minetest.registered_nodes[node.name].walkable then
					return hp_change
				end
				if minetest.get_item_group(node.name, "water") ~= 0 then
					return 0
				end
				if node.name == "mcl_portals:portal_end" then
					if mcl_portals and mcl_portals.end_teleport then
						mcl_portals.end_teleport(player)
					end
					return 0
				end
			end
			pos = vector.add(pos, step)
			node = minetest.get_node(pos)
		end
	end
	return hp_change
end, true)

minetest.register_on_respawnplayer(function(player)
	local pos = player:get_pos()
	minetest.add_particlespawner({
		amount = 50,
		time = 0.001,
		minpos = vector.add(pos, 0),
		maxpos = vector.add(pos, 0),
		minvel = vector.new(-5,-5,-5),
		maxvel = vector.new(5,5,5),
		minexptime = 1.1,
		maxexptime = 1.5,
		minsize = 1,
		maxsize = 2,
		collisiondetection = false,
		vertical = false,
		texture = "mcl_particles_mob_death.png^[colorize:#000000:255",
	})

	minetest.sound_play("mcl_mobs_mob_poof", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = 8,
	}, true)
end)
