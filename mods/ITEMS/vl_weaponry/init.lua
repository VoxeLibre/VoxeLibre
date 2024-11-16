local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

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
		-- Prevent item duplication
		if self._picked_up then return end
		self._picked_up = true

		vl_projectile.replace_with_item_drop(self, self.object:get_pos())
	end,
})
table.update(spear_entity._vl_projectile,{
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
			minetest.log(dump({
				y_diff = y_diff,
				flat_time = self._flat_time,
			}))
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

local spear_throw_power = 25

local spear_on_place = function(wear_divisor)
	return function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			-- Call on_rightclick if the pointed node defines it
			local node = minetest.get_node(pointed_thing.under)
			if user and not user:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
				end
			end
		end

		if minetest.is_protected(pointed_thing.under, user:get_player_name()) then
			minetest.record_protection_violation(pointed_thing.under, user:get_player_name())
			return itemstack
		end

		if not minetest.is_creative_enabled(user:get_player_name()) then
			mcl_util.use_item_durability(itemstack, 1)
		end

		local pos = user:get_pos()
		pos.y = pos.y + 1.5
		local dir = user:get_look_dir()
		local yaw = user:get_look_horizontal()
		local obj = vl_projectile.create("vl_weaponry:spear_entity",{
			pos = pos,
			dir = dir,
			owner = user,
			velocity = spear_throw_power,
		})
		obj:set_properties({textures = {itemstack:get_name()}})
		local le = obj:get_luaentity()
		le._shooter = user
		le._source_object = user
		le._damage = itemstack:get_definition()._mcl_spear_thrown_damage
		le._is_critical = false
		le._startpos = pos
		le._collectable = true
		le._arrow_item = itemstack:to_string()
		minetest.sound_play("mcl_bows_bow_shoot", {pos=pos, max_hear_distance=16}, true)
		if user and user:is_player() then
			if obj:get_luaentity().player == "" then
				obj:get_luaentity().player = user
			end
-- 			obj:get_luaentity().node = shooter:get_inventory():get_stack("main", 1):get_name()
		end

		return ItemStack()
	end
end

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
minetest.register_tool("vl_weaponry:hammer_wood", {
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
minetest.register_tool("vl_weaponry:hammer_stone", {
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
minetest.register_tool("vl_weaponry:hammer_iron", {
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
minetest.register_tool("vl_weaponry:hammer_gold", {
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
minetest.register_tool("vl_weaponry:hammer_diamond", {
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
minetest.register_tool("vl_weaponry:hammer_netherite", {
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
minetest.register_tool("vl_weaponry:spear_wood", {
	description = S("Wooden Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	_doc_items_hidden = false,
	inventory_image = "vl_tool_woodspear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place(uses.wood),
	on_secondary_use = spear_on_place(uses.wood),
	groups = { weapon=1, spear=1, dig_speed_class=2, enchantability=15 },
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
	_mcl_spear_thrown_damage = 5,
})
minetest.register_tool("vl_weaponry:spear_stone", {
	description = S("Stone Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	inventory_image = "vl_tool_stonespear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place(uses.stone),
	on_secondary_use = spear_on_place(uses.stone),
	groups = { weapon=1, spear=1, dig_speed_class=2, enchantability=5 },
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
	_mcl_spear_thrown_damage = 6,
})
minetest.register_tool("vl_weaponry:spear_iron", {
	description = S("Iron Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	inventory_image = "vl_tool_steelspear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place(uses.iron),
	on_secondary_use = spear_on_place(uses.iron),
	groups = { weapon=1, spear=1, dig_speed_class=2, enchantability=14 },
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
	_mcl_spear_thrown_damage = 7,
})
minetest.register_tool("vl_weaponry:spear_gold", {
	description = S("Golden Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	inventory_image = "vl_tool_goldspear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place(uses.gold),
	on_secondary_use = spear_on_place(uses.gold),
	groups = { weapon=1, spear=1, dig_speed_class=2, enchantability=22 },
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
	_mcl_spear_thrown_damage = 5,
})
minetest.register_tool("vl_weaponry:spear_diamond", {
	description = S("Diamond Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	inventory_image = "vl_tool_diamondspear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place(uses.diamond),
	on_secondary_use = spear_on_place(uses.diamond),
	groups = { weapon=1, spear=1, dig_speed_class=2, enchantability=10 },
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
	_mcl_spear_thrown_damage = 8,
	_mcl_upgradable = true,
	_mcl_upgrade_item = "vl_weaponry:spear_netherite"
})
minetest.register_tool("vl_weaponry:spear_netherite", {
	description = S("Netherite Spear"),
	_tt_help = spear_tt,
	_doc_items_longdesc = spear_longdesc,
	_doc_items_usagehelp = spear_use,
	inventory_image = "vl_tool_netheritespear.png",
	wield_scale = wield_scale,
	on_place = spear_on_place(uses.netherite),
	on_secondary_use = spear_on_place(uses.netherite),
	groups = { weapon=1, spear=1, dig_speed_class=2, enchantability=10, fire_immune=1 },
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
	_mcl_spear_thrown_damage = 12,
})

-- Crafting recipes
local s = "mcl_core:stick"
local b = ""
for t,m in pairs(materials) do
	minetest.register_craft({
		output = "vl_weaponry:hammer_"..t,
		recipe = {
			{ m, b, m },
			{ m, s, m },
			{ b, s, b },
		}
	})
	minetest.register_craft({
		output = "vl_weaponry:spear_"..t,
		recipe = {
			{ m, b, b },
			{ b, s, b },
			{ b, b, s },
		}
	})
end
