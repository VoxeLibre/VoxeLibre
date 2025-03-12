local S = core.get_translator(core.get_current_modname())
local N = function(s) return s end

local mcl_cozy_sit_on_stairs = core.settings:get_bool("mcl_cozy_sit_on_stairs", false)
local mcl_cozy_print_actions = core.settings:get_bool("mcl_cozy_print_actions", false)

local SIT_EYE_OFFSET = vector.new(0, -7, 2)
local LAY_EYE_OFFSET = vector.new(0, -13, -5)

local DISTANCE_THRESHOLD = 3
local VELOCITY_THRESHOLD = 0.125
local PLAYERSP_THRESHOLD = 0.1

-- used to partially avoid a race condition(?) causing the player animation to
-- not be set properly when mounting onto a block (e.g. stair)
local ACTION_APPLY_DELAY = 0.05

mcl_cozy = {}
mcl_cozy.players = {}

-- backwards compatibility w/ mcl_cozy 3.0.0
mcl_cozy.pos = setmetatable({}, {
	__index = function(_, name)
		return mcl_cozy.players[name] and mcl_cozy.players[name][1]
	end
})

-- TODO: when the API is more polished and there is demand, un-internalize this
local actions = {
	["sit"] = {
		description = S("Sit down"),
		message = {
			chat = N("@1 sits"),
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
			chat = N("@1 lies"),
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
local function is_unwalkable_below(player)
	return not mcl_playerinfo[player:get_player_name()].stand_on.walkable
end
--[[ for MCLA's mcl_player rewrite
local function is_attached(player)
	return mcl_player.players[player].attached
end
local function set_attach(player, bool)
	mcl_player.players[player].attached = bool
end
local function is_unwalkable_below(player)
	return not core.registered_nodes[mcl_player.players[player].nodes.stand].walkable
end]]

local function check_distance(a, b)
	return math.abs(a.x - b.x) > DISTANCE_THRESHOLD
		or math.abs(a.y - b.y) > DISTANCE_THRESHOLD / 2
		or math.abs(a.z - b.z) > DISTANCE_THRESHOLD
end

function mcl_cozy.print_action(name, action)
	if not mcl_cozy_print_actions then return end

	local msg = N("@1 stands up")
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
	mcl_cozy.players[name] = nil
	mcl_cozy.print_action(name, "stand")
end

-- register actions
for action, def in pairs(actions) do
	if not def or type(def) ~= "table" then return end

	mcl_cozy[action] = function(pos, node, player)
		if not player or not player:is_player() then return end

		local name = player:get_player_name()
		local ppos = player:get_pos()

		-- check attachment
		if is_attached(player)
				and (not mcl_cozy.players[name] or mcl_cozy.players[name][2] == action) then
			mcl_cozy.stand_up(player)
			return
		end

		local delay = 0
		if pos then
			-- check space above
			if core.registered_nodes[core.get_node(vector.offset(pos, 0, 1, 0)).name].walkable then
				return
			end
			-- check distance
			if check_distance(pos, ppos) then
				mcl_cozy.actionbar_show_status(player, def.message.actionbar.distance_fail)
				return
			end
			-- check movement
			if vector.length(player:get_velocity()) > VELOCITY_THRESHOLD then
				mcl_cozy.actionbar_show_status(player, def.message.actionbar.movement_fail)
				return
			end
			-- check if occupied
			for _, other in pairs(mcl_cozy.players) do
				if vector.distance(pos, other[1]) < PLAYERSP_THRESHOLD then
					mcl_cozy.actionbar_show_status(player,
						def.message.actionbar.occupancy_fail or S("This block is already occupied!"))
					return
				end
			end

			-- all checks pass
			node = node or core.get_node(pos)
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
		mcl_cozy.players[name] = {pos, action}

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
			if is_unwalkable_below(player) then return end

			mcl_cozy[action](nil, nil, player)
		end
	})
end

core.register_globalstep(function(dtime)
	for _, player in ipairs(core.get_connected_players()) do
		if mcl_cozy.players[player:get_player_name()] then
			local ctrl = player:get_player_control()

			-- unmount when player tries to move
			if (ctrl.up or ctrl.down or ctrl.left or ctrl.right or ctrl.jump or ctrl.sneak)
					-- unmount when there's air below
					or is_unwalkable_below(player) then
				mcl_cozy.stand_up(player)
			end
		end
	end
end)

-- fix players getting stuck after they leave while still sitting
core.register_on_joinplayer(function(player)
	playerphysics.remove_physics_factor(player, "speed", "mcl_cozy:attached")
	playerphysics.remove_physics_factor(player, "jump", "mcl_cozy:attached")
	mcl_cozy.players[player:get_player_name()] = nil
end)

if core.get_modpath("mcl_stairs") and mcl_cozy_sit_on_stairs then
	dofile(core.get_modpath("mcl_cozy") .. "/stairs_slabs.lua")
end
