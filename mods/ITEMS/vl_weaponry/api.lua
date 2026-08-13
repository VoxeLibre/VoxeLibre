local registered_pairs = {}
local registered_upgrade_targets = {}
local registered_smelting_recipes = {}

local function assert_identifier(value, label)
	assert(type(value) == "string" and value:match("^[%a_][%w_]*$"),
		label .. " must be a valid identifier")
end

local function split_prefix(prefix, label)
	assert(type(prefix) == "string", (label or "Item name") .. " must be a string")
	local namespace, basename = prefix:match("^([%a_][%w_]*):([%a_][%w_]*)$")
	assert(namespace, (label or "Item name") .. " must be namespaced")
	return namespace, basename
end

local function validate_pair_definition(pair, label)
	assert(type(pair) == "table", label .. " must be a table")
	split_prefix(pair.item_name, label .. ".item_name")
	assert(type(pair.description) == "string" and pair.description ~= "",
		label .. ".description must be a non-empty translated string")
	assert(type(pair.inventory_image) == "string" and pair.inventory_image ~= "",
		label .. ".inventory_image must be a non-empty full texture name")
	if pair.upgrade_item then
		split_prefix(pair.upgrade_item, label .. ".upgrade_item")
	end
end

local function combine_stats(base_stats, modifiers)
	local result = {}
	for stat, base in pairs(base_stats or {}) do
		assert(type(base) == "number", "Base stat " .. stat .. " must be numeric")
		local modifier = modifiers and modifiers[stat]
		if modifier then
			assert(type(modifier) == "table", "Modifier for " .. stat .. " must be a table")
			local multiply = modifier.multiply or 1
			local add = modifier.add or 0
			assert(type(multiply) == "number", "multiply for " .. stat .. " must be numeric")
			assert(type(add) == "number", "add for " .. stat .. " must be numeric")
			result[stat] = base * multiply + add
		else
			result[stat] = base
		end
	end
	return result
end

local function excludes_pair(tool_type, material_name, material)
	return not (tool_type.materials and tool_type.materials[material_name])
		and not (material.tool_types and material.tool_types[tool_type.name])
end

local function pair_definition_for(tool_type, material_name, material)
	local from_type = tool_type.materials and tool_type.materials[material_name]
	local from_material = material.tool_types and material.tool_types[tool_type.name]
	assert(not (from_type and from_material),
		"Tool/material pair defined by both sides: " .. tool_type.name .. " + " .. material_name)
	return from_type or from_material
end

local function register_pair(tool_type, material_name, material)
	if excludes_pair(tool_type, material_name, material) then return end

	local pair_key = tool_type.name .. "\0" .. material_name
	local pair = pair_definition_for(tool_type, material_name, material)
	if registered_pairs[pair_key] then return end

	local item_name = pair.item_name
	assert(not core.registered_items[item_name], "Item already registered: " .. item_name)

	local stats = combine_stats(tool_type.base_stats, material.stat_modifiers)
	local definition = tool_type.build_definition(material_name, material, stats)
	assert(type(definition) == "table", "Tool definition builder must return a table")

	definition.description = pair.description
	definition.inventory_image = pair.inventory_image
	definition.groups = definition.groups or {}
	if stats.enchantability then
		definition.groups.enchantability = stats.enchantability
	end
	if material.fire_immune then
		definition.groups.fire_immune = 1
	end
	definition._repair_material = material.repair_material
	definition.vl_max_ench_lvl = material.max_enchant_level

	if pair.upgrade_item then
		definition._mcl_upgradable = true
		definition._mcl_upgrade_item = pair.upgrade_item
		registered_upgrade_targets[pair.upgrade_item] = true
	end

	core.register_tool(item_name, definition)
	registered_pairs[pair_key] = item_name

	if material.burn_time then
		core.register_craft({
			type = "fuel",
			recipe = item_name,
			burntime = material.burn_time,
		})
	end

	if tool_type.smelting_yield and material.smelting_output then
		core.register_craft({
			type = "cooking",
			output = material.smelting_output .. " " .. tool_type.smelting_yield,
			recipe = item_name,
			cooktime = 10,
		})
		registered_smelting_recipes[item_name] = {
			output = material.smelting_output,
			yield = tool_type.smelting_yield,
		}
	end

	if material.craftable ~= false and tool_type.register_crafts then
		assert(material.craft_material,
			"Craftable material " .. material_name .. " requires craft_material")
		tool_type.register_crafts(item_name, material.craft_material, material)
	end
end

---Register a tool type and create it for every compatible registered material.
---@param name string Namespaced item prefix, such as "vl_weaponry:hammer".
---@param definition table
function vl_weaponry.register_tool_type(name, definition)
	split_prefix(name, "Tool type name")
	assert(type(definition) == "table", "Tool type definition must be a table")
	assert(type(definition.build_definition) == "function",
		"Tool type definition requires build_definition")
	assert(not vl_weaponry.registered_tool_types[name], "Tool type already registered: " .. name)
	assert(definition.materials == nil or type(definition.materials) == "table",
		"Tool type materials must be a table")
	assert(definition.smelting_yield == nil
		or type(definition.smelting_yield) == "number"
			and definition.smelting_yield > 0
			and definition.smelting_yield % 1 == 0,
		"Tool type smelting_yield must be a positive integer")
	for material_name, pair in pairs(definition.materials or {}) do
		assert_identifier(material_name, "Material name")
		validate_pair_definition(pair, name .. ".materials." .. material_name)
	end

	local tool_type = table.copy(definition)
	tool_type.name = name
	vl_weaponry.registered_tool_types[name] = tool_type

	for material_name, material in pairs(vl_weaponry.registered_tool_materials) do
		register_pair(tool_type, material_name, material)
	end
end

---Register a material and create it for every compatible registered tool type.
---@param name string Material suffix, such as "wood".
---@param definition table
function vl_weaponry.register_tool_material(name, definition)
	assert_identifier(name, "Material name")
	assert(type(definition) == "table", "Tool material definition must be a table")
	assert(definition.repair_material, "Tool material requires repair_material")
	assert(not vl_weaponry.registered_tool_materials[name],
		"Tool material already registered: " .. name)
	assert(definition.tool_types == nil or type(definition.tool_types) == "table",
		"Tool material tool_types must be a table")
	if definition.smelting_output then
		split_prefix(definition.smelting_output, "Tool material smelting_output")
	end
	assert(definition.burn_time == nil
		or type(definition.burn_time) == "number" and definition.burn_time > 0,
		"Tool material burn_time must be a positive number")
	for tool_type_name, pair in pairs(definition.tool_types or {}) do
		split_prefix(tool_type_name, "Tool type name")
		validate_pair_definition(pair, name .. ".tool_types." .. tool_type_name)
	end

	for stat, modifier in pairs(definition.stat_modifiers or {}) do
		assert_identifier(stat, "Stat name")
		assert(type(modifier) == "table", "Modifier for " .. stat .. " must be a table")
		assert(modifier.add == nil or type(modifier.add) == "number",
			"add for " .. stat .. " must be numeric")
		assert(modifier.multiply == nil or type(modifier.multiply) == "number",
			"multiply for " .. stat .. " must be numeric")
	end

	local material = table.copy(definition)
	vl_weaponry.registered_tool_materials[name] = material

	for _, tool_type in pairs(vl_weaponry.registered_tool_types) do
		register_pair(tool_type, name, material)
	end
end

core.register_on_mods_loaded(function()
	for tool_type_name, tool_type in pairs(vl_weaponry.registered_tool_types) do
		for material_name in pairs(tool_type.materials or {}) do
			assert(vl_weaponry.registered_tool_materials[material_name],
				"Concrete tool references unregistered material: "
					.. tool_type_name .. " + " .. material_name)
		end
	end
	for material_name, material in pairs(vl_weaponry.registered_tool_materials) do
		if material.smelting_output then
			assert(core.registered_items[material.smelting_output],
				"Tool material references unregistered smelting output: "
					.. material_name .. " + " .. material.smelting_output)
		end
		for tool_type_name in pairs(material.tool_types or {}) do
			assert(vl_weaponry.registered_tool_types[tool_type_name],
				"Concrete tool references unregistered tool type: "
					.. tool_type_name .. " + " .. material_name)
		end
	end
	for item_name in pairs(registered_upgrade_targets) do
		assert(core.registered_items[item_name],
			"Concrete tool references unregistered upgrade item: " .. item_name)
	end
end)

local old_get_craft_result = core.get_craft_result
function core.get_craft_result(input)
	local output, decremented_input = old_get_craft_result(input)
	if input.method ~= "cooking" or input.width ~= 1 or output.item:is_empty() then
		return output, decremented_input
	end

	local input_stack = ItemStack(input.items[1])
	local recipe = registered_smelting_recipes[input_stack:get_name()]
	if recipe and output.item:get_name() == recipe.output then
		local remaining = (65536 - input_stack:get_wear()) / 65536
		output.item:set_count(math.max(1, math.ceil(recipe.yield * remaining)))
	end
	return output, decremented_input
end
