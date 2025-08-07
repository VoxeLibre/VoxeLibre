local S = core.get_translator(core.get_current_modname())

local function create_soil(pos, inv)
	if pos == nil then
		return false
	end
	local node = core.get_node(pos)
	local name = node.name
	local above = core.get_node({ x = pos.x, y = pos.y + 1, z = pos.z })
	if core.get_item_group(name, "cultivatable") == 2 then
		if above.name == "air" then
			node.name = "mcl_farming:soil"
			core.set_node(pos, node)
			core.sound_play("default_dig_crumbly", { pos = pos, gain = 0.5 }, true)
			return true
		end
	elseif core.get_item_group(name, "cultivatable") == 1 then
		if above.name == "air" then
			node.name = "mcl_core:dirt"
			core.set_node(pos, node)
			core.sound_play("default_dig_crumbly", { pos = pos, gain = 0.6 }, true)
			return true
		end
	end
	return false
end

local hoe_on_place_function = function(wear_divisor)
	return function(itemstack, user, pointed_thing)
		-- Call on_rightclick if the pointed node defines it
		local node = core.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if core.registered_nodes[node.name] and core.registered_nodes[node.name].on_rightclick then
				return core.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or
					itemstack
			end
		end

		if core.is_protected(pointed_thing.under, user:get_player_name()) then
			core.record_protection_violation(pointed_thing.under, user:get_player_name())
			return itemstack
		end

		if create_soil(pointed_thing.under, user:get_inventory()) then
			if not core.is_creative_enabled(user:get_player_name()) then
				itemstack:add_wear(65535 / wear_divisor)
				tt.reload_itemstack_description(itemstack) -- update tooltip
			end
			return itemstack
		end
	end
end

---@class mcl_farming.HoeDef
---@field description string
---@field help_text string?
---@field long_description string?
---@field usage_help string?
---@field image string?
---@field place_uses integer
---@field punch_uses integer
---@field enchantability integer
---@field crafting_material string?
---@field repair_material string
---@field upgradeable boolean?
---@field upgrade_item string?
---@field craftable boolean?
---@field dig_group {speed:integer, level: integer, uses: integer}

local hoe_tt = S("Turns block into farmland")
local hoe_longdesc = S(
	"Hoes are essential tools for growing crops. They are used to create farmland in order to plant seeds on it. Hoes can also be used as very weak weapons in a pinch.")
local hoe_usagehelp = S(
	"Use the hoe on a cultivatable block (by rightclicking it) to turn it into farmland. Dirt, grass blocks and grass paths are cultivatable blocks. Using a hoe on coarse dirt turns it into dirt.")
local s = "mcl_core:stick"
local b = ""

---Registers a hoe for the given material
---@param material string
---@param def mcl_farming.HoeDef
function mcl_farming:register_hoe(material, def)
	local description = def.description
	local help_text = def.help_text or hoe_tt
	local long_description = def.long_description or hoe_longdesc
	local usage_help = def.usage_help or hoe_usagehelp
	local image = def.image or ("farming_tool_" .. material .. "hoe.png")
	local m = def.crafting_material or def.repair_material
	local tool_name = "mcl_farming:hoe_" .. material
	local upgrade = def.upgradeable or false
	local craftable = (def.craftable ~= nil and def.craftable) or true
	assert(def.place_uses, "Hoe definition requires place_uses to be set")
	assert(def.punch_uses, "Hoe definition requires punch_uses to be set")
	assert(def.enchantability, "Hoe definition requires enchantability to be set")
	assert(def.repair_material, "Hoe definition requires repair_material to be set")
	assert(def.dig_group, "Hoe definition requires dig_group to be set")
	core.register_tool(tool_name, {
		description = description,
		_tt_help = help_text,
		_doc_items_longdesc = long_description,
		_doc_items_usagehelp = usage_help,
		_doc_items_hidden = false,
		inventory_image = image,
		wield_scale = mcl_vars.tool_wield_scale,
		on_place = hoe_on_place_function(def.place_uses),
		groups = { tool = 1, hoe = 1, enchantability = def.enchantability },
		tool_capabilities = {
			full_punch_interval = 1,
			damage_groups = { fleshy = 1, },
			punch_attack_uses = def.punch_uses,
		},
		_repair_material = def.repair_material,
		_mcl_toollike_wield = true,
		_mcl_diggroups = {
			hoey = def.dig_group
		},
		_mcl_upgradable = upgrade,
		_mcl_upgrade_item = def.upgrade_item
	})

	core.register_craft({
		type = "fuel",
		recipe = tool_name,
		burntime = 10,
	})

	if craftable then
		core.register_craft({
			output = tool_name,
			recipe = {
				{ m, m },
				{ b, s },
				{ b, s }
			}
		})
		core.register_craft({
			output = tool_name,
			recipe = {
				{ m, m },
				{ s, b },
				{ s, b }
			}
		})
	end
end

local crafts = {
	wood = {
		description = S("Wood Hoe"),
		place_uses = 60,
		punch_uses = 60,
		enchantability = 15,
		crafting_material = "group:wood",
		repair_material = "group:wood",
		dig_group = { speed = 2, level = 1, uses = 60 }
	},
	stone = {
		description = S("Stone Hoe"),
		place_uses = 132,
		punch_uses = 132,
		enchantability = 5,
		crafting_material = "group:cobble",
		repair_material = "group:cobble",
		dig_group = { speed = 4, level = 3, uses = 132 }
	},
	iron = {
		description = S("Iron Hoe"),
		place_uses = 251,
		punch_uses = 251,
		enchantability = 14,
		crafting_material = "mcl_core:iron_ingot",
		repair_material = "mcl_core:iron_ingot",
		dig_group = { speed = 6, level = 4, uses = 251 }
	},
	gold = {
		description = S("Gold Hoe"),
		place_uses = 33,
		punch_uses = 33,
		enchantability = 22,
		crafting_material = "mcl_core:gold_ingot",
		repair_material = "mcl_core:gold_ingot",
		dig_group = { speed = 12, level = 2, uses = 33 }
	},
	diamond = {
		description = S("Diamond Hoe"),
		place_uses = 1562,
		punch_uses = 1562,
		enchantability = 15,
		crafting_material = "mcl_core:diamond",
		repair_material = "mcl_core:diamond",
		dig_group = { speed = 8, level = 5, uses = 1562 },
		upgradable = true,
		upgrade_item = "mcl_farming:hoe_netherite"
	},
	netherite = {
		description = S("Netherite Hoe"),
		place_uses = 2031,
		punch_uses = 2031,
		enchantability = 15,
		crafting_material = "mcl_nether:netherite_ingot",
		repair_material = "mcl_nether:netherite_ingot",
		craftable = false,
		dig_group = { speed = 8, level = 5, uses = 2031 }
	},
}

mcl_farming:register_hoe("wood", crafts.wood)
mcl_farming:register_hoe("stone", crafts.stone)
mcl_farming:register_hoe("iron", crafts.iron)
mcl_farming:register_hoe("gold", crafts.gold)
mcl_farming:register_hoe("diamond", crafts.diamond)
mcl_farming:register_hoe("netherite", crafts.netherite)
