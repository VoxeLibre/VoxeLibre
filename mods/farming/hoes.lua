local function create_soil(pos, inv)
	if pos == nil then
		return false
	end
	local node = minetest.get_node(pos)
	local name = node.name
	local above = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
	if name == "default:dirt" or name == "default:dirt_with_grass" then
		if above.name == "air" then
			node.name = "farming:soil"
			minetest.set_node(pos, node)
			return true
		end
	elseif name == "default:coarse_dirt" then
		if above.name == "air" then
			node.name = "default:dirt"
			minetest.set_node(pos, node)
			return true
		end
	end
	return false
end

minetest.register_tool("farming:hoe_wood", {
	description = "Wood Hoe",
	inventory_image = "farming_tool_woodhoe.png",
	on_place = function(itemstack, user, pointed_thing)
		if create_soil(pointed_thing.under, user:get_inventory()) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/60)
			end
			return itemstack
		end
	end
})

minetest.register_craft({
	output = "farming:hoe_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"", "default:stick"},
		{"", "default:stick"}
	}
})
minetest.register_craft({
	output = "farming:hoe_wood",
	recipe = {
		{"group:wood", "group:wood"},
		{"default:stick", ""},
		{"default:stick", ""}
	}
})

minetest.register_tool("farming:hoe_stone", {
	description = "Stone Hoe",
	inventory_image = "farming_tool_stonehoe.png",
	on_place = function(itemstack, user, pointed_thing)
		if create_soil(pointed_thing.under, user:get_inventory()) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/132)
			end
			return itemstack
		end
	end
})

minetest.register_craft({
	output = "farming:hoe_stone",
	recipe = {
		{"default:cobble", "default:cobble"},
		{"", "default:stick"},
		{"", "default:stick"}
	}
})
minetest.register_craft({
	output = "farming:hoe_stone",
	recipe = {
		{"default:cobble", "default:cobble"},
		{"default:stick", ""},
		{"default:stick", ""}
	}
})

minetest.register_tool("farming:hoe_steel", {
	description = "Iron Hoe",
	inventory_image = "farming_tool_steelhoe.png",
	on_place = function(itemstack, user, pointed_thing)
		if create_soil(pointed_thing.under, user:get_inventory()) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/251)
			end
			return itemstack
		end
	end
})

minetest.register_craft({
	output = "farming:hoe_steel",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot"},
		{"", "default:stick"},
		{"", "default:stick"}
	}
})
minetest.register_craft({
	output = "farming:hoe_steel",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:stick", ""},
		{"default:stick", ""}
	}
})

minetest.register_craft({
	type = "cooking",
	output = "default:iron_nugget",
	recipe = "farming:hoe_steel",
	cooktime = 10,
})

minetest.register_tool("farming:hoe_gold", {
	description = "Golden Hoe",
	inventory_image = "farming_tool_goldhoe.png",
	on_place = function(itemstack, user, pointed_thing)
		if create_soil(pointed_thing.under, user:get_inventory()) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/33)
			end
			return itemstack
		end
	end
})

minetest.register_craft({
	output = "farming:hoe_gold",
	recipe = {
		{"default:gold_ingot", "default:gold_ingot"},
		{"", "default:stick"},
		{"", "default:stick"}
	}
})
minetest.register_craft({
	output = "farming:hoe_gold",
	recipe = {
		{"default:gold_ingot", "default:gold_ingot"},
		{"default:stick", ""},
		{"default:stick", ""}
	}
})



minetest.register_craft({
	type = "cooking",
	output = "default:gold_nugget",
	recipe = "farming:hoe_gold",
	cooktime = 10,
})

minetest.register_tool("farming:hoe_diamond", {
	description = "Diamond Hoe",
	inventory_image = "farming_tool_diamondhoe.png",
	on_place = function(itemstack, user, pointed_thing)
		if create_soil(pointed_thing.under, user:get_inventory()) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/1562)
			end
			return itemstack
		end
	end
})

minetest.register_craft({
	output = "farming:hoe_diamond",
	recipe = {
		{"default:diamond", "default:diamond"},
		{"", "default:stick"},
		{"", "default:stick"}
	}
})
minetest.register_craft({
	output = "farming:hoe_diamond",
	recipe = {
		{"default:diamond", "default:diamond"},
		{"default:stick", ""},
		{"default:stick", ""}
	}
})
