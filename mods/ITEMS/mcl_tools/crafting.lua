minetest.register_craft({
	output = "mcl_tools:pick_wood",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"", "mcl_core:stick", ""},
		{"", "mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:pick_stone",
	recipe = {
		{"group:cobble", "group:cobble", "group:cobble"},
		{"", "mcl_core:stick", ""},
		{"", "mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:pick_iron",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"", "mcl_core:stick", ""},
		{"", "mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:pick_gold",
	recipe = {
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot", "mcl_core:gold_ingot"},
		{"", "mcl_core:stick", ""},
		{"", "mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:pick_diamond",
	recipe = {
		{"mcl_core:diamond", "mcl_core:diamond", "mcl_core:diamond"},
		{"", "mcl_core:stick", ""},
		{"", "mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:shovel_wood",
	recipe = {
		{"group:wood"},
		{"mcl_core:stick"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:shovel_stone",
	recipe = {
		{"group:cobble"},
		{"mcl_core:stick"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:shovel_iron",
	recipe = {
		{"mcl_core:iron_ingot"},
		{"mcl_core:stick"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:shovel_gold",
	recipe = {
		{"mcl_core:gold_ingot"},
		{"mcl_core:stick"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:shovel_diamond",
	recipe = {
		{"mcl_core:diamond"},
		{"mcl_core:stick"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:axe_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "mcl_core:stick"},
		{"", "mcl_core:stick"},
	}
})
minetest.register_craft({
	output = "mcl_tools:axe_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"mcl_core:stick", "group:wood"},
		{"mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:axe_stone",
	recipe = {
		{"group:cobble", "group:cobble"},
		{"group:cobble", "mcl_core:stick"},
		{"", "mcl_core:stick"},
	}
})
minetest.register_craft({
	output = "mcl_tools:axe_stone",
	recipe = {
		{"group:cobble", "group:cobble"},
		{"mcl_core:stick", "group:cobble"},
		{"mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:axe_iron",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:stick"},
		{"", "mcl_core:stick"},
	}
})
minetest.register_craft({
	output = "mcl_tools:axe_iron",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:iron_ingot"},
		{"mcl_core:stick", "mcl_core:iron_ingot"},
		{"mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:axe_gold",
	recipe = {
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", "mcl_core:stick"},
		{"", "mcl_core:stick"},
	}
})
minetest.register_craft({
	output = "mcl_tools:axe_gold",
	recipe = {
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot"},
		{"mcl_core:stick", "mcl_core:gold_ingot"},
		{"mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:axe_diamond",
	recipe = {
		{"mcl_core:diamond", "mcl_core:diamond"},
		{"mcl_core:diamond", "mcl_core:stick"},
		{"", "mcl_core:stick"},
	}
})
minetest.register_craft({
	output = "mcl_tools:axe_diamond",
	recipe = {
		{"mcl_core:diamond", "mcl_core:diamond"},
		{"mcl_core:stick", "mcl_core:diamond"},
		{"mcl_core:stick", ""},
	}
})

minetest.register_craft({
	output = "mcl_tools:sword_wood",
	recipe = {
		{"group:wood"},
		{"group:wood"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:sword_stone",
	recipe = {
		{"group:cobble"},
		{"group:cobble"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:sword_iron",
	recipe = {
		{"mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:sword_gold",
	recipe = {
		{"mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:sword_diamond",
	recipe = {
		{"mcl_core:diamond"},
		{"mcl_core:diamond"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:shears",
	recipe = {
		{ "mcl_core:iron_ingot", "" },
		{ "", "mcl_core:iron_ingot", },
	}
})
minetest.register_craft({
	output = "mcl_tools:shears",
	recipe = {
		{ "", "mcl_core:iron_ingot" },
		{ "mcl_core:iron_ingot", "" },
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:pick_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:shovel_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:sword_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:axe_wood",
	burntime = 10,
})

local recyclable_tools = {
	gold = {
		output = "mcl_core:gold_nugget 9",
		durability_yield = 9,
		tools = { "sword_gold", "axe_gold", "shovel_gold", "pick_gold" },
	},
	iron = {
		output = "mcl_core:iron_nugget 9",
		durability_yield = 9,
		tools = { "sword_iron", "axe_iron", "shovel_iron", "pick_iron", "shears" },
	},
}

for _, recycling in pairs(recyclable_tools) do
	for _, tool in ipairs(recycling.tools) do
		local tool_name = "mcl_tools:" .. tool
		local groups = table.copy(core.registered_items[tool_name].groups)
		groups.blast_furnace_smeltable = 1
		groups.recycling_yield = recycling.durability_yield
		core.override_item(tool_name, { groups = groups })

		core.register_craft({
			type = "cooking",
			output = recycling.output,
			recipe = tool_name,
			cooktime = 10,
		})
	end
end

local old_get_craft_result = core.get_craft_result
function core.get_craft_result(input)
	local output, decremented_input = old_get_craft_result(input)
	if input.method ~= "cooking" or input.width ~= 1 or output.item:is_empty() then
		return output, decremented_input
	end

	local input_stack = ItemStack(input.items[1])
	local maximum_yield = core.get_item_group(input_stack:get_name(), "recycling_yield")
	if maximum_yield > 0 then
		local durability = (65536 - input_stack:get_wear()) / 65536
		output.item:set_count(math.max(1, math.ceil(maximum_yield * durability)))
	end

	return output, decremented_input
end

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:pick_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:shovel_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:sword_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:axe_wood",
	burntime = 10,
})
