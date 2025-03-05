local S = core.get_translator(core.get_current_modname())
local mcl_cozy_sit_on_stairs = core.settings:get_bool("mcl_cozy_sit_on_stairs", true)
local mcl_cozy_print_actions = core.settings:get_bool("mcl_cozy_print_actions", false)

local SIT_EYE_OFFSET = vector.new(0, -7, 2)
local LAY_EYE_OFFSET = vector.new(0, -13, -5)

local DISTANCE_THRESHOLD = 3
local VELOCITY_THRESHOLD = 0.125
local PLAYERSP_THRESHOLD = 0.1

-- used to partially avoid a race condition(?) causing the player animation to not be set properly when mounting onto
-- a block (e.g. stair)
local ACTION_APPLY_DELAY = 0.05

mcl_cozy = {}
mcl_cozy.pos = {}

-- TODO: when the API is more polished and there is demand, un-internalize this
local actions = {
	["sit"] = {
		description = S("Sit down"),
		message = {
			chat = "@1 sits",
			actionbar = {
				distance_fail = S("You can't sit, the block's too far away!"),
				movement_fail = S("You have to stop moving before sitting down!"),
			},
		},
		eye_offset = {SIT_EYE_OFFSET, SIT_EYE_OFFSET},
		on_apply = function(player)
			mcl_player.player_set_animation(player, "sit", 30)
		end,
	},
	["lay"] = {
		description = S("Lie down"),
		message = {
			chat = "@1 lies",
			actionbar = {
				distance_fail = S("You can't lay, the block's too far away!"),
				movement_fail = S("You have to stop moving before lying down!"),
			},
		},
		eye_offset = {LAY_EYE_OFFSET, LAY_EYE_OFFSET},
		on_apply = function(player)
			mcl_player.player_set_animation(player, "lay", 30)
		end,
	},
}

local function is_attached(player)
	return mcl_player.player_attached[player:get_player_name()]
end
local function set_attach(player, bool)
	mcl_player.player_attached[player:get_player_name()] = bool
end
local function is_air_below(player)
	return mcl_playerinfo[player:get_player_name()].node_stand == "air"
end
--[[if mcl_player.players then
	is_attached = function(player)
		return mcl_player.players[player].attached
	end
	set_attach = function(player, bool)
		mcl_player.players[player].attached = bool
	end
	is_air_below = function(player)
		return mcl_player.players[player].nodes.stand == "air"
	end
end]]

function mcl_cozy.print_action(name, action)
	if not mcl_cozy_print_actions then return end

	local msg = "@1 stands up"
	if actions[action] then
		msg = actions[action].message.chat
	end
	core.chat_send_all("* "..S(msg, name))
end

function mcl_cozy.actionbar_show_status(player, message)
	if not message then message = S("Move to stand up") end

	mcl_title.set(player, "actionbar", {text=message, color="white", stay=60})
end

function mcl_cozy.stand_up(player)
	local name = player:get_player_name()

	player:set_eye_offset(vector.zero(), vector.zero())
	playerphysics.remove_physics_factor(player, "speed", "mcl_cozy:attached")
	playerphysics.remove_physics_factor(player, "jump", "mcl_cozy:attached")
	set_attach(player, false)
	mcl_player.player_set_animation(player, "stand", 30)
	mcl_cozy.pos[name] = nil
	mcl_cozy.print_action(name, "stand")
end

-- register actions
for action, def in pairs(actions) do
	if not def or type(def) ~= "table" then return end

	mcl_cozy[action] = function(pos, _, player)
		if not player or not player:is_player() then return end

		local name = player:get_player_name()
		local ppos = player:get_pos()

		-- check attachment
		if is_attached(player) then
			mcl_cozy.pos[name] = nil
			mcl_cozy.stand_up(player)
			return
		end

		local delay = 0
		if pos then
			-- check distance
			if vector.distance(pos, ppos) > DISTANCE_THRESHOLD then
				mcl_cozy.actionbar_show_status(player, def.message.actionbar.distance_fail)
				return
			end
			-- check movement
			if vector.length(player:get_velocity()) > VELOCITY_THRESHOLD then
				mcl_cozy.actionbar_show_status(player, def.message.actionbar.movement_fail)
				return
			end
			-- check if occupied
			for _, other_pos in pairs(mcl_cozy.pos) do
				if vector.distance(pos, other_pos) < PLAYERSP_THRESHOLD then
					mcl_cozy.actionbar_show_status(player,
						def.message.actionbar.occupancy_fail or S("This block is already occupied!"))
					return
				end
			end

			-- all checks pass
			local node = core.get_node(pos)
			local param2 = node.param2
			local ndef = core.registered_nodes[node.name]

			local rot
			if ndef.paramtype2:find("dir") then
				local dir = core.facedir_to_dir(param2)
				rot = vector.dir_to_rotation(dir)

				-- set player's yaw to match the direction of the block they mount onto
				local yaw = rot.y
				if param2 % 2 == 0 then
					yaw = -yaw
				end
				if yaw == 0 then
					yaw = -math.pi
				elseif yaw == math.pi then
					yaw = 0
				end
				player:set_look_horizontal(-yaw)
			else
				rot = vector.zero()
			end

			if ndef._mcl_cozy_offset then -- account for the body point offset
				local off = ndef._mcl_cozy_offset
				pos = pos + vector.rotate(off, rot)
			end

			delay = ACTION_APPLY_DELAY

			player:move_to(pos)
		else
			pos = ppos
		end

		player:set_eye_offset(unpack(def.eye_offset))
		playerphysics.add_physics_factor(player, "speed", "mcl_cozy:attached", 0)
		playerphysics.add_physics_factor(player, "jump", "mcl_cozy:attached", 0)

		set_attach(player, true)
		mcl_cozy.pos[name] = pos

		core.after(delay, function()
			if player then
				def.on_apply(player)
			end
		end)

		mcl_cozy.print_action(name, action)
		mcl_cozy.actionbar_show_status(player)
	end

	core.register_chatcommand(action, {
		description = def.description,
		func = function(name)
			local player = core.get_player_by_name(name)
			-- check the node below player (and if it's air, just don't sit)
			if is_air_below(player) then return end

			mcl_cozy[action](nil, nil, player)
		end
	})
end

core.register_globalstep(function(dtime)
	for _, player in ipairs(core.get_connected_players()) do
		local name = player:get_player_name()
		local ctrl = player:get_player_control()

		if mcl_cozy.pos[name] then
			-- unmount when player tries to move
			if (ctrl.up == true or ctrl.down == true or
					ctrl.left == true or ctrl.right == true or
					ctrl.jump == true or ctrl.sneak == true) then
				mcl_cozy.stand_up(player)
			-- check the node below player (and if it's air, just unmount)
			elseif is_air_below(player) then
				mcl_cozy.stand_up(player)
			end
		end
	end
end)

-- fix players getting stuck after they leave while still sitting
core.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	playerphysics.remove_physics_factor(player, "speed", "mcl_cozy:attached")
	playerphysics.remove_physics_factor(player, "jump", "mcl_cozy:attached")
	mcl_cozy.pos[name] = nil
end)

if core.get_modpath("mcl_stairs") and mcl_cozy_sit_on_stairs then
	dofile(core.get_modpath("mcl_cozy") .. "/stairs_slabs.lua")
end
