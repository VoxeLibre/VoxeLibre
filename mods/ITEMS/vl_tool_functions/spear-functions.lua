local spear_entity = table.copy(mcl_bows.arrow_entity)
table.update(spear_entity,{
	visual = "item",
	visual_size = {x=-0.5, y=-0.5},
	textures = {"vl_weaponry:spear_wood"},
	_on_remove = function(self)
		vl_projectile.replace_with_item_drop(self, self.object:get_pos())
	end,
})
table.update(spear_entity._vl_projectile,{
	creative_collectable = true,
	behaviors = {
		vl_projectile.sticks,
		vl_projectile.burns,
		vl_projectile.has_tracer,
		vl_projectile.has_owner_grace_distance,
		vl_projectile.collides_with_solids,
		vl_projectile.raycast_collides_with_entities,

		-- Drop spears that are sliding
		function(self, dtime)
			if not self._last_pos then return end

			local pos = self.object:get_pos()
			local y_diff = math.abs(self._last_pos.y - pos.y)
			if y_diff > 0.0001 then
				self._flat_time = 0
				return
			end

			local flat_time = (self._flat_time or 0) + dtime
			self._flat_time = flat_time

			if flat_time < 0.25 then return end

			mcl_util.remove_entity(self)
			return true
		end,
	},
	pitch_offset = math.pi / 4,
})

vl_projectile.register("vl_weaponry:spear_entity", spear_entity)

local SPEAR_THROW_POWER = 30
-- spear_on_place gets called by spears on right click
local function spear_on_place(itemstack, user, pointed_thing)
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

local function throw_spear(itemstack, user, power_factor)
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
	local obj = vl_projectile.create("vl_weaponry:spear_entity",{
		pos = pos,
		dir = dir,
		owner = user,
		velocity = SPEAR_THROW_POWER * power_factor,
	})
	obj:set_properties({textures = {itemstack:get_name()}})
	local le = obj:get_luaentity()
	le._shooter = user
	le._source_object = user
	le._damage = itemstack:get_definition()._mcl_spear_thrown_damage * power_factor
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

local SPEAR_FULL_CHARGE_TIME = 1000000 -- time until full charge in microseconds

local spear_raise_time = {}
local spear_index = {}

local function reset_spear_state(player, skip_inv_cleanup)
	-- clear the FOV change from the player.
	mcl_fovapi.remove_modifier(player, "bowcomplete")

	spear_raise_time[player:get_player_name()] = nil
	spear_index[player:get_player_name()] = nil
	if core.get_modpath("playerphysics") then
		playerphysics.remove_physics_factor(player, "speed", "mcl_bows:use_bow")
	end
	if skip_inv_cleanup then return end
	local inv = player:get_inventory()
	local list = inv:get_list("main")
	for place, stack in pairs(list) do
		if core.get_item_group(stack:get_name(), "spear") > 0 then
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
	if core.get_item_group(wielditem:get_name(), "spear") < 1 then return end
	local meta = wielditem:get_meta()
	if not core.is_yes(meta:get("active")) then
		reset_spear_state(player)
		return
	end
	local pname = player:get_player_name()
	local raise_moment = spear_raise_time[pname] or 0
	local power = math.max(math.min((core.get_us_time() - raise_moment)
							/ SPEAR_FULL_CHARGE_TIME, 1), 0)
	throw_spear(wielditem, player, power)
	reset_spear_state(player, true)
end)

controls.register_on_hold(function(player, key, time)
	local name = player:get_player_name()
	local creative = core.is_creative_enabled(name)
	local wielditem = player:get_wielded_item()
	if (key ~= "RMB" and key ~= "zoom")
			or core.get_item_group(wielditem:get_name(), "spear") < 1 then
		return
	end
	local meta = wielditem:get_meta()
	if spear_raise_time[name] == nil and (core.is_yes(meta:get("active")) or key == "zoom") then
		meta:set_string("inventory_image", wielditem:get_definition().inventory_image .. "^[transformR90")
		player:set_wielded_item(wielditem)
		if core.get_modpath("playerphysics") then
			-- Slow player down when using bow
			playerphysics.add_physics_factor(player, "speed", "mcl_bows:use_bow", AIMING_MOVEMENT_SPEED)
		end
		spear_raise_time[name] = core.get_us_time()
		spear_index[name] = player:get_wield_index()

		-- begin aiming Zoom.
		mcl_fovapi.apply_modifier(player, "bowcomplete")
	else
		if player:get_wield_index() ~= spear_index[name] then
			reset_spear_state(player)
		end
	end
end)

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local wielditem = player:get_wielded_item()
		local wieldindex = player:get_wield_index()
		if type(spear_raise_time[name]) == "number"
				and (core.get_item_group(wielditem:get_name(), "spear") < 1
				or wieldindex ~= spear_index[name]) then
			reset_spear_state(player)
		end
	end
end)


