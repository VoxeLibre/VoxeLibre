local function create_soil(pos, inv)
	if pos == nil then
		return false
	end
	local node = minetest.get_node(pos)
	local name = node.name
	local above = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
	if minetest.get_item_group(name, "cultivatable") == 2 then
		if above.name == "air" then
			node.name = "mcl_farming:soil"
			minetest.set_node(pos, node)
			return true
		end
	elseif minetest.get_item_group(name, "cultivatable") == 1 then
		if above.name == "air" then
			node.name = "mcl_core:dirt"
			minetest.set_node(pos, node)
			return true
		end
	end
	return false
end

minetest.register_tool("mcl_farming:hoe_wood", {
	description = "Wood Hoe",
	inventory_image = "farming_tool_woodhoe.png",
	on_place = function(itemstack, user, pointed_thing)
		if create_soil(pointed_thing.under, user:get_inventory()) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/60)
			end
			return itemstack
		end
	end,
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		damage_groups = { fleshy = 1, }
	},
})

minetest.register_craft({
	output = "mcl_farming:hoe_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"", "mcl_core:stick"},
		{"", "mcl_core:stick"}
	}
})
minetest.register_craft({
	output = "mcl_farming:hoe_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"mcl_core:stick", ""},
		{"mcl_core:stick", ""}
	}
})
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_farming:hoe_wood",
	burntime = 10,
})

minetest.register_tool("mcl_farming:hoe_stone", {
	description = "Stone Hoe",
	inventory_image = "farming_tool_stonehoe.png",
	on_place = function(itemstack, user, pointed_thing)
		if create_soil(pointed_thing.under, user:get_inventory()) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/132)
			end
			return itemstack
		end
	end,
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 0.5,
		damage_groups = { fleshy = 1, }
	},
})

minetest.register_craft({
	output = "mcl_farming:hoe_stone",
	recipe = {
		{"mcl_core:cobble", "mcl_core:cobble"},
		{"", "mcl_core:stick"},
		{"", "mcl_core:stick"}
	}
})
minetest.register_craft({
	output = "mcl_farming:hoe_stone",
	recipe = {
		{"mcl_core:cobble", "mcl_core:cobble"},
		{"mcl_core:stick", ""},
		{"mcl_core:stick", ""}
	}
})

minetest.register_tool("mcl_farming:hoe_steel", {
	description = "Iron Hoe",
	inventory_image = "farming_tool_steelhoe.png",
	on_place = function(itemstack, user, pointed_thing)
		if create_soil(pointed_thing.under, user:get_inventory()) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/251)
			end
			return itemstack
		end
	end,
	groups = { tool=1 },
	tool_capabilities = {
		-- 1/3
		full_punch_interval = 0.33333333,
		damage_groups = { fleshy = 1, }
	},
})

minetest.register_craft({
	output = "mcl_farming:hoe_steel",
	recipe = {
		{"mcl_core:steel_ingot", "mcl_core:steel_ingot"},
		{"", "mcl_core:stick"},
		{"", "mcl_core:stick"}
	}
})
minetest.register_craft({
	output = "mcl_farming:hoe_steel",
	recipe = {
		{"mcl_core:steel_ingot", "mcl_core:steel_ingot"},
		{"mcl_core:stick", ""},
		{"mcl_core:stick", ""}
	}
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:iron_nugget",
	recipe = "mcl_farming:hoe_steel",
	cooktime = 10,
})

minetest.register_tool("mcl_farming:hoe_gold", {
	description = "Golden Hoe",
	inventory_image = "farming_tool_goldhoe.png",
	on_place = function(itemstack, user, pointed_thing)
		if create_soil(pointed_thing.under, user:get_inventory()) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/33)
			end
			return itemstack
		end
	end,
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 1,
		damage_groups = { fleshy = 1, }
	},
})

minetest.register_craft({
	output = "mcl_farming:hoe_gold",
	recipe = {
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot"},
		{"", "mcl_core:stick"},
		{"", "mcl_core:stick"}
	}
})
minetest.register_craft({
	output = "mcl_farming:hoe_gold",
	recipe = {
		{"mcl_core:gold_ingot", "mcl_core:gold_ingot"},
		{"mcl_core:stick", ""},
		{"mcl_core:stick", ""}
	}
})



minetest.register_craft({
	type = "cooking",
	output = "mcl_core:gold_nugget",
	recipe = "mcl_farming:hoe_gold",
	cooktime = 10,
})

minetest.register_tool("mcl_farming:hoe_diamond", {
	description = "Diamond Hoe",
	inventory_image = "farming_tool_diamondhoe.png",
	on_place = function(itemstack, user, pointed_thing)
		if create_soil(pointed_thing.under, user:get_inventory()) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/1562)
			end
			return itemstack
		end
	end,
	groups = { tool=1 },
	tool_capabilities = {
		full_punch_interval = 0.25,
		damage_groups = { fleshy = 1, }
	},
})

minetest.register_craft({
	output = "mcl_farming:hoe_diamond",
	recipe = {
		{"mcl_core:diamond", "mcl_core:diamond"},
		{"", "mcl_core:stick"},
		{"", "mcl_core:stick"}
	}
})
minetest.register_craft({
	output = "mcl_farming:hoe_diamond",
	recipe = {
		{"mcl_core:diamond", "mcl_core:diamond"},
		{"mcl_core:stick", ""},
		{"mcl_core:stick", ""}
	}
})
