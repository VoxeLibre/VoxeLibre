local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)

local pickaxe_longdesc = S("Pickaxes are mining tools to mine hard blocks, such as stone. A pickaxe can also be used as weapon, but it is rather inefficient.")
local axe_longdesc = S("An axe is your tool of choice to cut down trees, wood-based blocks and other blocks. Axes deal a lot of damage as well, but they are rather slow.")
local sword_longdesc = S("Swords are great in melee combat, as they are fast, deal high damage and can endure countless battles. Swords can also be used to cut down a few particular blocks, such as cobwebs.")
local shovel_longdesc = S("Shovels are tools for digging coarse blocks, such as dirt, sand and gravel. They can also be used to turn grass blocks to grass paths. Shovels can be used as weapons, but they are very weak.")
local shovel_use = S("To turn a grass block into a grass path, hold the shovel in your hand, then use (rightclick) the top or side of a grass block. This only works when there's air above the grass block.")
local shears_longdesc = S("Shears are tools to shear sheep and to mine a few block types. Shears are a special mining tool and can be used to obtain the original item from grass, leaves and similar blocks that require cutting.")
local shears_use = S("To shear sheep or carve faceless pumpkins, use the “place” key on them. Faces can only be carved at the side of faceless pumpkins. Mining works as usual, but the drops are different for a few blocks.")

local wield_scale = mcl_vars.tool_wield_scale

local function common_definition(material_name, material, group, longdesc)
	local definition = {
		_doc_items_longdesc = longdesc,
		wield_scale = wield_scale,
		groups = { tool = 1, [group] = 1, dig_speed_class = material.dig_speed_class },
		sound = { breaks = "default_tool_breaks" },
		_mcl_toollike_wield = true,
	}
	if material_name == "wood" then
		definition._doc_items_hidden = false
	end
	return definition
end

local function register_pickaxe_craft(item_name, craft_material)
	core.register_craft({
		output = item_name,
		recipe = {
			{ craft_material, craft_material, craft_material },
			{ "", "mcl_core:stick", "" },
			{ "", "mcl_core:stick", "" },
		},
	})
end

local function register_shovel_craft(item_name, craft_material)
	core.register_craft({
		output = item_name,
		recipe = {
			{ craft_material },
			{ "mcl_core:stick" },
			{ "mcl_core:stick" },
		},
	})
end

local function register_axe_crafts(item_name, craft_material)
	for _, recipe in ipairs({
		{
			{ craft_material, craft_material },
			{ craft_material, "mcl_core:stick" },
			{ "", "mcl_core:stick" },
		},
		{
			{ craft_material, craft_material },
			{ "mcl_core:stick", craft_material },
			{ "mcl_core:stick", "" },
		},
	}) do
		core.register_craft({ output = item_name, recipe = recipe })
	end
end

local function register_sword_craft(item_name, craft_material)
	core.register_craft({
		output = item_name,
		recipe = {
			{ craft_material },
			{ craft_material },
			{ "mcl_core:stick" },
		},
	})
end

local materials = {
	wood = { "mcl_tools:pick_wood", S("Wooden Pickaxe"), "default_tool_woodpick.png",
		"mcl_tools:shovel_wood", S("Wooden Shovel"), "default_tool_woodshovel.png",
		"mcl_tools:axe_wood", S("Wooden Axe"), "default_tool_woodaxe.png",
		"mcl_tools:sword_wood", S("Wooden Sword"), "default_tool_woodsword.png" },
	stone = { "mcl_tools:pick_stone", S("Stone Pickaxe"), "default_tool_stonepick.png",
		"mcl_tools:shovel_stone", S("Stone Shovel"), "default_tool_stoneshovel.png",
		"mcl_tools:axe_stone", S("Stone Axe"), "default_tool_stoneaxe.png",
		"mcl_tools:sword_stone", S("Stone Sword"), "default_tool_stonesword.png" },
	iron = { "mcl_tools:pick_iron", S("Iron Pickaxe"), "default_tool_steelpick.png",
		"mcl_tools:shovel_iron", S("Iron Shovel"), "default_tool_steelshovel.png",
		"mcl_tools:axe_iron", S("Iron Axe"), "default_tool_steelaxe.png",
		"mcl_tools:sword_iron", S("Iron Sword"), "default_tool_steelsword.png" },
	gold = { "mcl_tools:pick_gold", S("Golden Pickaxe"), "default_tool_goldpick.png",
		"mcl_tools:shovel_gold", S("Golden Shovel"), "default_tool_goldshovel.png",
		"mcl_tools:axe_gold", S("Golden Axe"), "default_tool_goldaxe.png",
		"mcl_tools:sword_gold", S("Golden Sword"), "default_tool_goldsword.png" },
	diamond = { "mcl_tools:pick_diamond", S("Diamond Pickaxe"), "default_tool_diamondpick.png",
		"mcl_tools:shovel_diamond", S("Diamond Shovel"), "default_tool_diamondshovel.png",
		"mcl_tools:axe_diamond", S("Diamond Axe"), "default_tool_diamondaxe.png",
		"mcl_tools:sword_diamond", S("Diamond Sword"), "default_tool_diamondsword.png" },
	netherite = { "mcl_tools:pick_netherite", S("Netherite Pickaxe"), "default_tool_netheritepick.png",
		"mcl_tools:shovel_netherite", S("Netherite Shovel"), "default_tool_netheriteshovel.png",
		"mcl_tools:axe_netherite", S("Netherite Axe"), "default_tool_netheriteaxe.png",
		"mcl_tools:sword_netherite", S("Netherite Sword"), "default_tool_netheritesword.png" },
}

local function pairs_for(offset, upgrade_name)
	local result = {}
	for material, values in pairs(materials) do
		result[material] = {
			item_name = values[offset],
			description = values[offset + 1],
			inventory_image = values[offset + 2],
		}
	end
	if upgrade_name then
		result.diamond.upgrade_item = upgrade_name
	end
	return result
end

vl_weaponry.register_tool_type("mcl_tools:pickaxe", {
	materials = pairs_for(1, "mcl_tools:pick_netherite"),
	smelting_yield = 27,
	base_stats = { durability = 0, dig_speed = 1, harvest_level = 0, damage = 2, enchantability = 0 },
	build_definition = function(material_name, material, stats)
		local def = common_definition(material_name, material, "pickaxe", pickaxe_longdesc)
		def.tool_capabilities = {
			full_punch_interval = 0.83333333,
			max_drop_level = math.min(stats.harvest_level, 5),
			damage_groups = { fleshy = stats.damage },
			punch_attack_uses = math.ceil(stats.durability / 2),
		}
		def._mcl_diggroups = { pickaxey = {
			speed = stats.dig_speed, level = stats.harvest_level, uses = stats.durability,
		} }
		return def
	end,
	register_crafts = register_pickaxe_craft,
})

vl_weaponry.register_tool_type("mcl_tools:shovel", {
	materials = pairs_for(4, "mcl_tools:shovel_netherite"),
	smelting_yield = 9,
	base_stats = { durability = 0, dig_speed = 1, harvest_level = 0, damage = 2, enchantability = 0 },
	build_definition = function(material_name, material, stats)
		local def = common_definition(material_name, material, "shovel", shovel_longdesc)
		local dig_level = material_name == "wood" and 2 or stats.harvest_level
		def._doc_items_usagehelp = shovel_use
		def.on_place = vl_weaponry.make_grass_path
		def.tool_capabilities = {
			full_punch_interval = 1,
			max_drop_level = math.min(stats.harvest_level, 5),
			damage_groups = { fleshy = math.min(stats.damage, 5) },
			punch_attack_uses = math.ceil(stats.durability / 2),
		}
		def._mcl_diggroups = { shovely = {
			speed = stats.dig_speed, level = dig_level, uses = stats.durability,
		} }
		return def
	end,
	register_crafts = register_shovel_craft,
})

vl_weaponry.register_tool_type("mcl_tools:axe", {
	materials = pairs_for(7, "mcl_tools:axe_netherite"),
	smelting_yield = 27,
	base_stats = { durability = 0, dig_speed = 1, harvest_level = 0, damage = 7, enchantability = 0 },
	build_definition = function(material_name, material, stats)
		local def = common_definition(material_name, material, "axe", axe_longdesc)
		def.on_place = vl_weaponry.make_stripped_trunk
		def.tool_capabilities = {
			full_punch_interval = math.max(1, 1.25 - math.max(stats.dig_speed - 4, 0) / 14),
			max_drop_level = math.min(stats.harvest_level, 5),
			damage_groups = { fleshy = math.min(stats.damage, 10) },
			punch_attack_uses = math.ceil(stats.durability / 2),
		}
		def._mcl_diggroups = { axey = {
			speed = stats.dig_speed, level = stats.harvest_level, uses = stats.durability,
		} }
		return def
	end,
	register_crafts = register_axe_crafts,
})

vl_weaponry.register_tool_type("mcl_tools:sword", {
	materials = pairs_for(10, "mcl_tools:sword_netherite"),
	smelting_yield = 18,
	base_stats = { durability = 0, dig_speed = 1, harvest_level = 0, damage = 4, enchantability = 0 },
	build_definition = function(material_name, material, stats)
		local def = common_definition(material_name, material, "sword", sword_longdesc)
		def.groups.tool = nil
		def.groups.weapon = 1
		def.tool_capabilities = {
			full_punch_interval = 0.625,
			max_drop_level = math.min(stats.harvest_level, 5),
			damage_groups = { fleshy = stats.damage },
			punch_attack_uses = stats.durability,
		}
		local diggroup = { speed = stats.dig_speed, level = stats.harvest_level, uses = stats.durability }
		def._mcl_diggroups = { swordy = diggroup, swordy_cobweb = table.copy(diggroup) }
		return def
	end,
	register_crafts = register_sword_craft,
})

core.register_tool("mcl_tools:shears", {
	description = S("Shears"),
	_doc_items_longdesc = shears_longdesc,
	_doc_items_usagehelp = shears_use,
	inventory_image = "default_tool_shears.png",
	wield_image = "default_tool_shears.png",
	stack_max = 1,
	groups = { tool = 1, shears = 1, dig_speed_class = 4, enchantability = -1 },
	tool_capabilities = { full_punch_interval = 0.5, max_drop_level = 1 },
	on_place = core.get_modpath("mcl_farming") and vl_weaponry.carve_pumpkin or nil,
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		shearsy = { speed = 1.5, level = 1, uses = 238 },
		shearsy_wool = { speed = 5, level = 1, uses = 238 },
		shearsy_cobweb = { speed = 15, level = 1, uses = 238 },
	},
})

dofile(modpath .. "/crafting.lua")
dofile(modpath .. "/aliases.lua")
