local S = core.get_translator(core.get_current_modname())

local wield_scale = mcl_vars.tool_wield_scale

local TRIDENT_THROW_POWER = 30
local TRIDENT_FULL_CHARGE_TIME = 1000000 -- time until full charge in microseconds
local TRIDENT_RANGE = 4.5

local trident_entity = table.copy(vl_weaponry.spear_entity)
table.update(trident_entity.initial_properties, {
	visual = "mesh",
	mesh = "vl_tridents.obj",
	textures = {"vl_tridents.png"},
	_damage=9,
})
table.update(trident_entity._vl_projectile, {
	pitch_offset = 0,
})

vl_projectile.register("vl_tridents:trident_entity", trident_entity)

local function trident_on_place(itemstack, user, pointed_thing)
	if pointed_thing.type == "node" then
		-- Call on_rightclick if the pointed node defines it
		local node = core.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if core.registered_nodes[node.name] and core.registered_nodes[node.name].on_rightclick then
				return core.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end
	end

	itemstack:get_meta():set_int("active", 1)
	return itemstack
end

local function throw_trident(itemstack, user, power_factor)
	if not core.is_creative_enabled(user:get_player_name()) then
		mcl_util.use_item_durability(itemstack, 1)
	end
	local meta = itemstack:get_meta()
	meta:set_string("inventory_image", "")
	meta:set_int("active", 0)

	local pos = user:get_pos()
	pos.y = pos.y + 1.5
	local dir = user:get_look_dir()
	local yaw = user:get_look_horizontal()
	local obj = vl_projectile.create("vl_tridents:trident_entity",{
		pos = pos,
		dir = dir,
		owner = user,
		velocity = TRIDENT_THROW_POWER * power_factor,
	})
	local le = obj:get_luaentity()
	le._shooter = user
	le._source_object = user
	le._damage = itemstack:get_definition()._vl_tridents_thrown_damage * power_factor
	le._is_critical = false -- TODO get from luck?
	le._startpos = pos
	le._collectable = true
	le._arrow_item = itemstack:to_string()
	core.sound_play("mcl_bows_bow_shoot", {pos=pos, max_hear_distance=16}, true)
	if user and user:is_player() then
		if obj:get_luaentity().player == "" then
			obj:get_luaentity().player = user
		end
	end

	user:set_wielded_item(ItemStack())
end

-- Factor to multiply with player speed while player uses bow
-- This emulates the sneak speed.
local AIMING_MOVEMENT_SPEED =
	tonumber(core.settings:get("movement_speed_crouch"))
	/ tonumber(core.settings:get("movement_speed_walk"))


local trident_raise_time = {}
local trident_index = {}

local function reset_trident_state(player, skip_inv_cleanup)
	-- clear the FOV change from the player.
	mcl_fovapi.remove_modifier(player, "bowcomplete")

	trident_raise_time[player:get_player_name()] = nil
	trident_index[player:get_player_name()] = nil
	if core.get_modpath("playerphysics") then
		playerphysics.remove_physics_factor(player, "speed", "mcl_bows:use_bow")
	end
	if skip_inv_cleanup then return end
	local inv = player:get_inventory()
	local list = inv:get_list("main")
	for place, stack in pairs(list) do
		if core.get_item_group(stack:get_name(), "trident") > 0 then
			local meta = stack:get_meta()
			meta:set_int("active", 0)
			meta:set_string("inventory_image", "")
		end
	end
	inv:set_list("main", list)
end

controls.register_on_release(function(player, key, time)
	if key~="RMB" and key~="zoom" then return end
	local wielditem = player:get_wielded_item()
	if core.get_item_group(wielditem:get_name(), "trident") < 1 then return end
	local meta = wielditem:get_meta()
	if not core.is_yes(meta:get("active")) then
		reset_trident_state(player)
		return
	end
	local pname = player:get_player_name()
	local raise_moment = trident_raise_time[pname] or 0
	local power = math.max(math.min((core.get_us_time() - raise_moment)
							/ TRIDENT_FULL_CHARGE_TIME, 1), 0)
	throw_trident(wielditem, player, power)
	reset_trident_state(player, true)
end)

controls.register_on_hold(function(player, key, time)
	local name = player:get_player_name()
	local creative = core.is_creative_enabled(name)
	local wielditem = player:get_wielded_item()
	if (key ~= "RMB" and key ~= "zoom")
		or core.get_item_group(wielditem:get_name(), "trident") < 1 then
		return
	end
	local meta = wielditem:get_meta()
	if trident_raise_time[name] == nil and (core.is_yes(meta:get("active")) or key == "zoom") then
		meta:set_string("inventory_image", wielditem:get_definition().inventory_image .. "^[transformR90")
		player:set_wielded_item(wielditem)
		if core.get_modpath("playerphysics") then
			-- Slow player down when using bow
			playerphysics.add_physics_factor(player, "speed", "mcl_bows:use_bow", AIMING_MOVEMENT_SPEED)
		end
		trident_raise_time[name] = core.get_us_time()
		trident_index[name] = player:get_wield_index()

		-- begin aiming Zoom.
		mcl_fovapi.apply_modifier(player, "bowcomplete")
	else
		if player:get_wield_index() ~= trident_index[name] then
			reset_trident_state(player)
		end
	end
end)

core.register_globalstep(function(dtime)
	for _, player in pairs(core.get_connected_players()) do
		local name = player:get_player_name()
		local wielditem = player:get_wielded_item()
		local wieldindex = player:get_wield_index()
		if type(trident_raise_time[name]) == "number"
			and (core.get_item_group(wielditem:get_name(), "trident") < 1
			or wieldindex ~= trident_index[name]) then
			reset_trident_state(player)
		end
	end
end)


core.register_tool("vl_tridents:trident", {
	description = S("Trident"),
	_tt_help = S("Throwable").."\n"..S("Damage from trident: 1-9"),
	_doc_items_longdesc = S(""),
	_doc_items_usagehelp = S("Use the punch key to throw."),
	inventory_image = "vl_tridents_inv.png",
	stack_max = 1,
	wield_scale = wield_scale,
	on_place = trident_on_place,
	on_secondary_use = trident_on_place,
	groups = { weapon=1, weapon_ranged=1, dig_speed_class=2, trident=1, enchantability=15 },
	range = TRIDENT_RANGE,
	tool_capabilities = {
		full_punch_interval = 0.75,
		max_drop_level=1,
		damage_groups = {fleshy=9},
		punch_attack_uses = 251, -- like iron, TODO: should be like iron sword
	},
	sound = { breaks = "default_tool_breaks" },
	--_repair_material = "group:wood", -- TODO
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 2, level = 1, uses = 251 },
		swordy_cobweb = { speed = 2, level = 1, uses = 251 }
	},
	touch_interaction = "short_dig_long_place",
	_vl_tridents_thrown_damage = 5,
})
