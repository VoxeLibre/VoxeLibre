dofile(minetest.get_modpath(minetest.get_current_modname()).."/armor.lua")

-- Regisiter Head Armor

local longdesc = "This is a piece of equippable armor which reduces the amount of damage you receive."
local usage = "To equip it, put it on the corresponding armor slot in your inventory menu."

minetest.register_tool("3d_armor:helmet_leather", {
	description = "Leather Cap",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_helmet_leather.png",
	groups = {armor_head=5, armor_heal=0, armor_use=100},
	wear = 0,
	_repair_material = "mcl_mobitems:leather",
})

minetest.register_tool("3d_armor:helmet_iron", {
	description = "Iron Helmet",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_helmet_iron.png",
	groups = {armor_head=10, armor_heal=5, armor_use=250},
	wear = 0,
	_repair_material = "mcl_core:iron_ingot",
})

minetest.register_tool("3d_armor:helmet_gold", {
	description = "Golden Helmet",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_helmet_gold.png",
	groups = {armor_head=15, armor_heal=10, armor_use=500},
	wear = 0,
	_repair_material = "mcl_core:gold_ingot",
})

minetest.register_tool("3d_armor:helmet_diamond",{
	description = "Diamond Helmet",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_helmet_diamond.png",
	groups = {armor_head=20, armor_heal=15, armor_use=750},
	wear = 0,
	_repair_material = "mcl_core:diamond",
})

minetest.register_tool("3d_armor:helmet_chain", {
	description = "Chain Helmet",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_helmet_chain.png",
	groups = {armor_head=15, armor_heal=10, armor_use=500},
	wear = 0,
	_repair_material = "mcl_core:iron_ingot",
})

-- Regisiter Torso Armor

minetest.register_tool("3d_armor:chestplate_leather", {
	description = "Leather Tunic",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_chestplate_leather.png",
	groups = {armor_torso=15, armor_heal=0, armor_use=100},
	wear = 0,
	_repair_material = "mcl_mobitems:leather",
})

minetest.register_tool("3d_armor:chestplate_iron", {
	description = "Iron Chestplate",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_chestplate_iron.png",
	groups = {armor_torso=20, armor_heal=5, armor_use=250},
	wear = 0,
	_repair_material = "mcl_core:iron_ingot",
})

minetest.register_tool("3d_armor:chestplate_gold", {
	description = "Golden Chestplate",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_chestplate_gold.png",
	groups = {armor_torso=25, armor_heal=10, armor_use=500},
	wear = 0,
	_repair_material = "mcl_core:gold_ingot",
})

minetest.register_tool("3d_armor:chestplate_diamond",{
	description = "Diamond Chestplate",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_chestplate_diamond.png",
	groups = {armor_torso=30, armor_heal=15, armor_use=750},
	wear = 0,
	_repair_material = "mcl_core:diamond",
})

minetest.register_tool("3d_armor:chestplate_chain", {
	description = "Chain Chestplate",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_chestplate_chain.png",
	groups = {armor_torso=25, armor_heal=10, armor_use=500},
	wear = 0,
	_repair_material = "mcl_core:iron_ingot",
})

-- Regisiter Leg Armor

minetest.register_tool("3d_armor:leggings_leather", {
	description = "Leather Pants",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_leggings_leather.png",
	groups = {armor_legs=10, armor_heal=0, armor_use=100},
	wear = 0,
	_repair_material = "mcl_mobitems:leather",
})

minetest.register_tool("3d_armor:leggings_iron", {
	description = "Iron Leggings",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_leggings_iron.png",
	groups = {armor_legs=15, armor_heal=5, armor_use=250},
	wear = 0,
	_repair_material = "mcl_core:iron_ingot",
})

minetest.register_tool("3d_armor:leggings_gold", {
	description = "Golden Leggings",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_leggings_gold.png",
	groups = {armor_legs=20, armor_heal=10, armor_use=500},
	wear = 0,
	_repair_material = "mcl_core:gold_ingot",
})

minetest.register_tool("3d_armor:leggings_diamond",{
	description = "Diamond Leggings",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_leggings_diamond.png",
	groups = {armor_legs=25, armor_heal=15, armor_use=750},
	wear = 0,
	_repair_material = "mcl_core:diamond",
})

minetest.register_tool("3d_armor:leggings_chain", {
	description = "Chain Leggings",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_leggings_chain.png",
	groups = {armor_legs=20, armor_heal=10, armor_use=500},
	wear = 0,
	_repair_material = "mcl_core:iron_ingot",
})
-- Regisiter Boots

minetest.register_tool("3d_armor:boots_leather", {
	description = "Leather Boots",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_boots_leather.png",
	groups = {armor_feet=5, armor_heal=0, armor_use=100},
	wear = 0,
	_repair_material = "mcl_mobitems:leather",
})

minetest.register_tool("3d_armor:boots_iron", {
	description = "Iron Boots",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_boots_iron.png",
	groups = {armor_feet=10, armor_heal=5, armor_use=250},
	wear = 0,
	_repair_material = "mcl_core:iron_ingot",
})

minetest.register_tool("3d_armor:boots_gold", {
	description = "Golden Boots",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_boots_gold.png",
	groups = {armor_feet=15, armor_heal=10, armor_use=500},
	wear = 0,
	_repair_material = "mcl_core:gold_ingot",
})

minetest.register_tool("3d_armor:boots_diamond",{
	description = "Diamond Boots",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_boots_diamond.png",
	groups = {armor_feet=20, armor_heal=15, armor_use=750},
	wear = 0,
	_repair_material = "mcl_core:diamond",
})

minetest.register_tool("3d_armor:boots_chain", {
	description = "Chain Boots",
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_boots_chain.png",
	groups = {armor_feet=15, armor_heal=10, armor_use=500},
	wear = 0,
	_repair_material = "mcl_core:iron_ingot",
})

-- Register Craft Recipies

local craft_ingreds = {
	leather = { "mcl_mobitems:leather" },
	iron = { "mcl_core:iron_ingot", "mcl_core:iron_nugget" },
	gold = { "mcl_core:gold_ingot", "mcl_core:gold_nugget" },
	diamond = { "mcl_core:diamond" },
	chain = { nil, "mcl_core:iron_nugget"} ,
}		

for k, v in pairs(craft_ingreds) do
	-- material
	local m = v[1]
	-- cooking result
	local c = v[2]
	if m ~= nil then
		minetest.register_craft({
			output = "3d_armor:helmet_"..k,
			recipe = {
				{m, m, m},
				{m, "", m},
				{"", "", ""},
			},
		})
		minetest.register_craft({
			output = "3d_armor:chestplate_"..k,
			recipe = {
				{m, "", m},
				{m, m, m},
				{m, m, m},
			},
		})
		minetest.register_craft({
			output = "3d_armor:leggings_"..k,
			recipe = {
				{m, m, m},
				{m, "", m},
				{m, "", m},
			},
		})
		minetest.register_craft({
			output = "3d_armor:boots_"..k,
			recipe = {
				{m, "", m},
				{m, "", m},
			},
		})
	end
	if c ~= nil then
		minetest.register_craft({
			type = "cooking",
			output = c,
			recipe = "3d_armor:helmet_"..k,
			cooktime = 10,
		})
		minetest.register_craft({
			type = "cooking",
			output = c,
			recipe = "3d_armor:chestplate_"..k,
			cooktime = 10,
		})
		minetest.register_craft({
			type = "cooking",
			output = c,
			recipe = "3d_armor:leggings_"..k,
			cooktime = 10,
		})
		minetest.register_craft({
			type = "cooking",
			output = c,
			recipe = "3d_armor:boots_"..k,
			cooktime = 10,
		})
	end
end
