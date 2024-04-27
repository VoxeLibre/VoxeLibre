local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)


local hammer_tt = S("Can crush blocks") .. "\n" .. S("Increased knockback")
local hammer_longdesc = S("Hammers are great in melee combat, as they deal high damage with increased knockback and can endure countless battles. Hammers can also be used to crush things.")
local hammer_use = S("To crush a block, hold the hammer in your hand, then use (rightclick) the block. This only works with some blocks.")

local spear_longdesc = S("Spears are great in melee combat, as they have an increased reach. They can also be thrown.")
local spear_use = S("To throw a spear, hold it in your hand, then hold use (rightclick) in the air.")

local wield_scale = mcl_vars.tool_wield_scale

local function crush(pos)
	if pos == nil then
		return false
	end
	local node = minetest.get_node(pos)
	local name = node.name
	if minetest.get_item_group(name, "crushable") == 2 then
		node.name = minetest.registered_nodes[name]._mcl_crushed_into
		if node.name then
			minetest.set_node(pos, node)
			minetest.sound_play("default_dig_cracky", { pos = pos, gain = 0.5 }, true)
			return true
		end
	elseif minetest.get_item_group(name, "crushable") == 1 then
		minetest.set_node(pos, {name="air"})
		minetest.sound_play(mcl_sounds.node_sound_glass_defaults().dug, { pos = pos, gain = 0.5 }, true)
		return true
	end
	return false
end

local hammer_on_place = function(wear_divisor)
	return function(itemstack, user, pointed_thing)
		-- Call on_rightclick if the pointed node defines it
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		if minetest.is_protected(pointed_thing.under, user:get_player_name()) then
			minetest.record_protection_violation(pointed_thing.under, user:get_player_name())
			return itemstack
		end

		if crush(pointed_thing.under) then
			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:add_wear(65535/wear_divisor)
			end
			return itemstack
		end
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

--Hammers
minetest.register_tool("mcl_weaponry:hammer_wood", {
	description = S("Wooden Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	_doc_items_hidden = false,
	inventory_image = "vl_tool_woodhammer.png",
	wield_scale = wield_scale,
	on_place = hammer_on_place(uses.wood),
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=15 },
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=1,
		damage_groups = {fleshy=4},
		punch_attack_uses = 60,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:wood",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 2, level = 1, uses = 30 }
	},
})
minetest.register_tool("mcl_weaponry:hammer_stone", {
	description = S("Stone Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	inventory_image = "vl_tool_stonehammer.png",
	wield_scale = wield_scale,
	on_place = hammer_on_place(uses.stone),
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=5 },
	tool_capabilities = {
		full_punch_interval = 1.3,
		max_drop_level=3,
		damage_groups = {fleshy=5},
		punch_attack_uses = 132,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "group:cobble",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 2, level = 1, uses = 30 }
	},
})
minetest.register_tool("mcl_weaponry:hammer_iron", {
	description = S("Iron Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	inventory_image = "vl_tool_steelhammer.png",
	wield_scale = wield_scale,
	on_place = hammer_on_place(uses.iron),
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=14 },
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=4,
		damage_groups = {fleshy=6},
		punch_attack_uses = 251,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:iron_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 2, level = 1, uses = 30 }
	},
})
minetest.register_tool("mcl_weaponry:hammer_gold", {
	description = S("Golden Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	inventory_image = "vl_tool_goldhammer.png",
	wield_scale = wield_scale,
	on_place = hammer_on_place(uses.gold),
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=22 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=2,
		damage_groups = {fleshy=5},
		punch_attack_uses = 33,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:gold_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 2, level = 1, uses = 30 }
	},
})
minetest.register_tool("mcl_weaponry:hammer_diamond", {
	description = S("Diamond Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	inventory_image = "vl_tool_diamondhammer.png",
	wield_scale = wield_scale,
	on_place = hammer_on_place(uses.diamond),
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=10 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=5,
		damage_groups = {fleshy=7},
		punch_attack_uses = 1562,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_core:diamond",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 2, level = 1, uses = 30 }
	},
	_mcl_upgradable = true,
	_mcl_upgrade_item = "mcl_weaponry:hammer_netherite"
})
minetest.register_tool("mcl_weaponry:hammer_netherite", {
	description = S("Netherite Hammer"),
	_tt_help = hammer_tt,
	_doc_items_longdesc = hammer_longdesc,
	_doc_items_usagehelp = hammer_use,
	inventory_image = "vl_tool_netheritehammer.png",
	wield_scale = wield_scale,
	on_place = hammer_on_place(uses.netherite),
	groups = { weapon=1, hammer=1, dig_speed_class=2, enchantability=10, fire_immune=1 },
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=5,
		damage_groups = {fleshy=9},
		punch_attack_uses = 2031,
	},
	sound = { breaks = "default_tool_breaks" },
	_repair_material = "mcl_nether:netherite_ingot",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		pickaxey = { speed = 2, level = 1, uses = 30 }
	},
})
