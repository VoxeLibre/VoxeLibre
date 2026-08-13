local S = core.get_translator(core.get_current_modname())

local spear_tt = S("Reaches farther") .. "\n" .. S("Can be thrown")
local spear_longdesc = S("Spears are great in melee combat, as they have an increased reach. They can also be thrown.")
local spear_use = S("To throw a spear, hold it in your hand, then hold use (rightclick) in the air.")

vl_weaponry.spear_tt = spear_tt

local spear_entity = table.copy(mcl_bows.arrow_entity)
table.update(spear_entity, {
	initial_properties = {
		visual = "item",
		visual_size = { x = -0.5, y = -0.5 },
		textures = { "vl_weaponry:spear_wood" },
	},
	_on_remove = function(self)
		vl_projectile.replace_with_item_drop(self, self.object:get_pos())
	end,
})
table.update(spear_entity._vl_projectile, {
	creative_collectable = true,
	behaviors = {
		vl_projectile.sticks,
		vl_projectile.burns,
		vl_projectile.has_tracer,
		vl_projectile.has_owner_grace_distance,
		vl_projectile.collides_with_solids,
		vl_projectile.raycast_collides_with_entities,

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

vl_weaponry.spear_entity = table.copy(spear_entity)
vl_projectile.register("vl_weaponry:spear_entity", spear_entity)

local SPEAR_THROW_POWER = 30
local SPEAR_RANGE = 4.5

---Begin charging a spear, while still honoring node right-click handlers.
function vl_weaponry.spear_on_place(itemstack, user, pointed_thing)
	if pointed_thing.type == "node" then
		local node = core.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			local definition = core.registered_nodes[node.name]
			if definition and definition.on_rightclick then
				return definition.on_rightclick(pointed_thing.under, node, user, itemstack)
					or itemstack
			end
		end
	end

	itemstack:get_meta():set_int("active", 1)
	return itemstack
end

---Throw a charged spear.
function vl_weaponry.throw_spear(itemstack, user, power_factor)
	local texture_name = itemstack:get_name()
	local damage = itemstack:get_definition()._mcl_spear_thrown_damage * power_factor

	if not core.is_creative_enabled(user:get_player_name()) then
		mcl_util.use_item_durability(itemstack, 1)
	end
	local meta = itemstack:get_meta()
	meta:set_string("inventory_image", "")
	meta:set_int("active", 0)

	local pos = user:get_pos()
	pos.y = pos.y + 1.5
	local dir = user:get_look_dir()
	local obj = vl_projectile.create("vl_weaponry:spear_entity", {
		pos = pos,
		dir = dir,
		owner = user,
		velocity = SPEAR_THROW_POWER * power_factor,
	})
	local obj_properties = table.copy(spear_entity)
	table.update(obj_properties, { textures = { texture_name } })
	obj:set_properties(obj_properties)

	local luaentity = obj:get_luaentity()
	luaentity._shooter = user
	luaentity._source_object = user
	luaentity._damage = damage
	luaentity._is_critical = false
	luaentity._startpos = pos
	luaentity._collectable = true
	luaentity._arrow_item = itemstack:to_string()
	core.sound_play("mcl_bows_bow_shoot", {
		pos = pos,
		max_hear_distance = 16,
	}, true)
	if user:is_player() and luaentity.player == "" then
		luaentity.player = user
	end

	user:set_wielded_item(ItemStack())
end

local AIMING_MOVEMENT_SPEED =
	tonumber(core.settings:get("movement_speed_crouch"))
	/ tonumber(core.settings:get("movement_speed_walk"))
local SPEAR_FULL_CHARGE_TIME = 1000000
local spear_raise_time = {}
local spear_index = {}

---Clear a player's spear charging state.
function vl_weaponry.reset_spear_state(player, skip_inventory_cleanup)
	mcl_fovapi.remove_modifier(player, "bowcomplete")

	local player_name = player:get_player_name()
	spear_raise_time[player_name] = nil
	spear_index[player_name] = nil
	if core.get_modpath("playerphysics") then
		playerphysics.remove_physics_factor(player, "speed", "mcl_bows:use_bow")
	end
	if skip_inventory_cleanup then return end

	local inventory = player:get_inventory()
	local list = inventory:get_list("main")
	for _, stack in pairs(list) do
		if core.get_item_group(stack:get_name(), "spear") > 0 then
			local meta = stack:get_meta()
			meta:set_int("active", 0)
			meta:set_string("inventory_image", "")
		end
	end
	inventory:set_list("main", list)
end

controls.register_on_release(function(player, key)
	if key ~= "RMB" and key ~= "zoom" then return end
	local wielditem = player:get_wielded_item()
	if core.get_item_group(wielditem:get_name(), "spear") ~= 1 then return end
	local meta = wielditem:get_meta()
	if not core.is_yes(meta:get("active")) then
		vl_weaponry.reset_spear_state(player)
		return
	end

	local player_name = player:get_player_name()
	local raise_moment = spear_raise_time[player_name] or 0
	local power = math.max(math.min(
		(core.get_us_time() - raise_moment) / SPEAR_FULL_CHARGE_TIME, 1), 0)
	vl_weaponry.throw_spear(wielditem, player, power)
	vl_weaponry.reset_spear_state(player, true)
end)

controls.register_on_hold(function(player, key)
	local player_name = player:get_player_name()
	local wielditem = player:get_wielded_item()
	if (key ~= "RMB" and key ~= "zoom")
			or core.get_item_group(wielditem:get_name(), "spear") < 1 then
		return
	end

	local meta = wielditem:get_meta()
	if spear_raise_time[player_name] == nil
			and (core.is_yes(meta:get("active")) or key == "zoom") then
		meta:set_string("inventory_image",
			wielditem:get_definition().inventory_image .. "^[transformR90")
		player:set_wielded_item(wielditem)
		if core.get_modpath("playerphysics") then
			playerphysics.add_physics_factor(
				player, "speed", "mcl_bows:use_bow", AIMING_MOVEMENT_SPEED)
		end
		spear_raise_time[player_name] = core.get_us_time()
		spear_index[player_name] = player:get_wield_index()
		mcl_fovapi.apply_modifier(player, "bowcomplete")
	elseif player:get_wield_index() ~= spear_index[player_name] then
		vl_weaponry.reset_spear_state(player)
	end
end)

core.register_globalstep(function()
	for _, player in pairs(core.get_connected_players()) do
		local player_name = player:get_player_name()
		local wielditem = player:get_wielded_item()
		if type(spear_raise_time[player_name]) == "number"
				and (core.get_item_group(wielditem:get_name(), "spear") < 1
					or player:get_wield_index() ~= spear_index[player_name]) then
			vl_weaponry.reset_spear_state(player)
		end
	end
end)

local function build_definition(_, material, stats)
	return {
		_tt_help = spear_tt,
		_doc_items_longdesc = spear_longdesc,
		_doc_items_usagehelp = spear_use,
		_doc_items_hidden = false,
		wield_scale = mcl_vars.tool_wield_scale,
		on_place = vl_weaponry.spear_on_place,
		on_secondary_use = vl_weaponry.spear_on_place,
		groups = {
			weapon = 1,
			weapon_ranged = 1,
			spear = 1,
			dig_speed_class = 2,
		},
		range = SPEAR_RANGE,
		tool_capabilities = {
			full_punch_interval = stats.fixed_attack_interval,
			max_drop_level = stats.harvest_level,
			damage_groups = { fleshy = stats.damage },
			punch_attack_uses = stats.durability,
		},
		sound = { breaks = "default_tool_breaks" },
		_mcl_toollike_wield = true,
		_mcl_diggroups = {
			swordy = { speed = 2, level = 1, uses = stats.durability },
			swordy_cobweb = { speed = 2, level = 1, uses = stats.durability },
		},
		touch_interaction = "short_dig_long_place",
		_mcl_spear_thrown_damage = stats.thrown_damage,
	}
end

local function register_crafts(item_name, craft_material)
	local stick = "mcl_core:stick"
	core.register_craft({
		output = item_name,
		recipe = {
			{ craft_material, "", "" },
			{ "", stick, "" },
			{ "", "", stick },
		},
	})
	core.register_craft({
		output = item_name,
		recipe = {
			{ "", "", craft_material },
			{ "", stick, "" },
			{ stick, "", "" },
		},
	})
end

vl_weaponry.register_tool_type("vl_weaponry:spear", {
	smelting_yield = 9,
	base_stats = {
		durability = 0,
		harvest_level = 0,
		damage = 3,
		fixed_attack_interval = 0.75,
		thrown_damage = 5,
		enchantability = 0,
	},
	build_definition = build_definition,
	register_crafts = register_crafts,
})
