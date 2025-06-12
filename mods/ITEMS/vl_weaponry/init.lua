local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)

local hammer_tt = S("Can crush blocks") .. "\n" .. S("Increased knockback")
local hammer_longdesc = S("Hammers are great in melee combat, as they deal high damage with increased knockback and can endure countless battles. Hammers can also be used to crush things.")
local hammer_use = S("To crush a block, dig the block with the hammer. This only works with some blocks.")

local spear_tt = S("Reaches farther") .. "\n" .. S("Can be thrown")
local spear_longdesc = S("Spears are great in melee combat, as they have an increased reach. They can also be thrown.")
local spear_use = S("To throw a spear, hold it in your hand, then hold use (rightclick) in the air.")

local wield_scale = mcl_vars.tool_wield_scale



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
	local obj_properties = table.copy(spear_entity)
	table.update(obj_properties, {
		textures = {itemstack:get_name()}
	})
	obj:set_properties(obj_properties)
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



local uses = {
	wood = 60,
	stone = 132,
	iron = 251,
	gold = 33,
	diamond = 1562,
	netherite = 2031,
}
local materials = {
	wood = "group:wood",
	stone = "group:cobble",
	iron = "mcl_core:iron_ingot",
	gold = "mcl_core:gold_ingot",
	diamond = "mcl_core:diamond",
}

local SPEAR_RANGE = 4.5

--Hammers
core.register_tool("vl_weaponry:hammer_wood", {
	description = S("Wooden Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	_doc_items_hidden = false,
	inventory_image = "vl_tool_woodhammer.png",
	wield_scale = wield_scale,
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=15 },
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=1,
		damage_groups = {fleshy=4},
		punch_attack_uses = uses.wood,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:wood",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 1, level = 1, uses = uses.wood },
		shovely = { speed = 1, level = 2, uses = uses.wood }
	},
})
core.register_tool("vl_weaponry:hammer_stone", {
	description = S("Stone Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	inventory_image = "vl_tool_stonehammer.png",
	wield_scale = wield_scale,
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=5 },
	tool_capabilities = {
		full_punch_interval = 1.3,
		max_drop_level=3,
		damage_groups = {fleshy=5},
		punch_attack_uses = uses.stone,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:cobble",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 2, level = 3, uses = uses.stone },
		shovely = { speed = 2, level = 3, uses = uses.stone }
	},
})
core.register_tool("vl_weaponry:hammer_iron", {
	description = S("Iron Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	inventory_image = "vl_tool_steelhammer.png",
	wield_scale = wield_scale,
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=14 },
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=4,
		damage_groups = {fleshy=6},
		punch_attack_uses = uses.iron,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:iron_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 3, level = 4, uses = uses.iron },
		shovely = { speed = 3, level = 4, uses = uses.iron }
	},
})
core.register_tool("vl_weaponry:hammer_gold", {
	description = S("Golden Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	inventory_image = "vl_tool_goldhammer.png",
	wield_scale = wield_scale,
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=22 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=2,
		damage_groups = {fleshy=5},
		punch_attack_uses = uses.gold,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:gold_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 8, level = 4, uses = uses.gold },
		shovely = { speed = 8, level = 4, uses = uses.gold }
	},
})
core.register_tool("vl_weaponry:hammer_diamond", {
	description = S("Diamond Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	inventory_image = "vl_tool_diamondhammer.png",
	wield_scale = wield_scale,
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=10 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=5,
		damage_groups = {fleshy=7},
		punch_attack_uses = uses.diamond,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:diamond",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 4, level = 5, uses = uses.diamond },
		pickaxey = { speed = 4, level = 5, uses = uses.diamond }
	},
	_mcl_upgradable = true,
	_mcl_upgrade_item = "vl_weaponry:hammer_netherite"
})
core.register_tool("vl_weaponry:hammer_netherite", {
	description = S("Netherite Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	inventory_image = "vl_tool_netheritehammer.png",
	wield_scale = wield_scale,
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=10, fire_immune=1 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=5,
		damage_groups = {fleshy=9},
		punch_attack_uses = uses.netherite,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_nether:netherite_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 6, level = 6, uses = uses.netherite },
		shovely = { speed = 6, level = 6, uses = uses.netherite }
	},
})

--Spears
core.register_tool("vl_weaponry:spear_wood", {
	description = S("Wooden Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	_doc_items_hidden = false,
	inventory_image = "vl_tool_woodspear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place,
	on_secondary_use = spear_on_place,
	groups = { weapon=1, weapon_ranged=1, spear=1, dig_speed_class=2, enchantability=15 },
	range = SPEAR_RANGE,
	tool_capabilities = {
		full_punch_interval = 0.75,
		max_drop_level=1,
		damage_groups = {fleshy=3},
		punch_attack_uses = uses.wood,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:wood",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 2, level = 1, uses = uses.wood },
		swordy_cobweb = { speed = 2, level = 1, uses = uses.wood }
	},
	touch_interaction = "short_dig_long_place",
	_mcl_spear_thrown_damage = 5,
})
core.register_tool("vl_weaponry:spear_stone", {
	description = S("Stone Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	inventory_image = "vl_tool_stonespear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place,
	on_secondary_use = spear_on_place,
	groups = { weapon=1, weapon_ranged=1, spear=1, dig_speed_class=2, enchantability=5 },
	range = SPEAR_RANGE,
	tool_capabilities = {
		full_punch_interval = 0.75,
		max_drop_level=3,
		damage_groups = {fleshy=4},
		punch_attack_uses = uses.stone,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:cobble",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 2, level = 1, uses = uses.stone },
		swordy_cobweb = { speed = 2, level = 1, uses = uses.stone }
	},
	touch_interaction = "short_dig_long_place",
	_mcl_spear_thrown_damage = 6,
})
core.register_tool("vl_weaponry:spear_iron", {
	description = S("Iron Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	inventory_image = "vl_tool_steelspear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place,
	on_secondary_use = spear_on_place,
	groups = { weapon=1, weapon_ranged=1, spear=1, dig_speed_class=2, enchantability=14 },
	range = SPEAR_RANGE,
	tool_capabilities = {
		full_punch_interval = 0.75,
		max_drop_level=4,
		damage_groups = {fleshy=5},
		punch_attack_uses = uses.iron,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:iron_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 2, level = 1, uses = uses.iron },
		swordy_cobweb = { speed = 2, level = 1, uses = uses.iron }
	},
	touch_interaction = "short_dig_long_place",
	_mcl_spear_thrown_damage = 7,
})
core.register_tool("vl_weaponry:spear_gold", {
	description = S("Golden Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	inventory_image = "vl_tool_goldspear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place,
	on_secondary_use = spear_on_place,
	groups = { weapon=1, weapon_ranged=1, spear=1, dig_speed_class=2, enchantability=22 },
	range = SPEAR_RANGE,
	tool_capabilities = {
		full_punch_interval = 0.75,
		max_drop_level=2,
		damage_groups = {fleshy=3},
		punch_attack_uses = uses.gold,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:gold_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 2, level = 1, uses = uses.gold },
		swordy_cobweb = { speed = 2, level = 1, uses = uses.gold }
	},
	touch_interaction = "short_dig_long_place",
	_mcl_spear_thrown_damage = 5,
})
core.register_tool("vl_weaponry:spear_diamond", {
	description = S("Diamond Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	inventory_image = "vl_tool_diamondspear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place,
	on_secondary_use = spear_on_place,
	groups = { weapon=1, weapon_ranged=1, spear=1, dig_speed_class=2, enchantability=10 },
	range = SPEAR_RANGE,
	tool_capabilities = {
		full_punch_interval = 0.75,
		max_drop_level=5,
		damage_groups = {fleshy=6},
		punch_attack_uses = uses.diamond,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:diamond",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 2, level = 1, uses = uses.diamond },
		swordy_cobweb = { speed = 2, level = 1, uses = uses.diamond }
	},
	touch_interaction = "short_dig_long_place",
	_mcl_spear_thrown_damage = 8,
	_mcl_upgradable = true,
	_mcl_upgrade_item = "vl_weaponry:spear_netherite"
})
core.register_tool("vl_weaponry:spear_netherite", {
	description = S("Netherite Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	inventory_image = "vl_tool_netheritespear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place,
	on_secondary_use = spear_on_place,
	groups = { weapon=1, weapon_ranged=1, spear=1, dig_speed_class=2, enchantability=10, fire_immune=1 },
	range = SPEAR_RANGE,
	tool_capabilities = {
		full_punch_interval = 0.75,
		max_drop_level=5,
		damage_groups = {fleshy=8},
		punch_attack_uses = uses.netherite,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_nether:netherite_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		swordy = { speed = 2, level = 1, uses = uses.netherite },
		swordy_cobweb = { speed = 2, level = 1, uses = uses.netherite }
	},
	touch_interaction = "short_dig_long_place",
	_mcl_spear_thrown_damage = 12,
})

-- Crafting recipes
local s = "mcl_core:stick"
local b = ""
for t,m in pairs(materials) do
	core.register_craft({
		output = "vl_weaponry:hammer_"..t,
		recipe = {
			{ m, b, m },
			{ m, s, m },
			{ b, s, b },
		}
	})
	core.register_craft({
		output = "vl_weaponry:spear_"..t,
		recipe = {
			{ m, b, b },
			{ b, s, b },
			{ b, b, s },
		}
	})
	core.register_craft({
		output = "vl_weaponry:spear_"..t,
		recipe = {
			{ b, b, m },
			{ b, s, b },
			{ s, b, b },
		}
	})
end
