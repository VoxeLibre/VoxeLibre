local S = minetest.get_translator("3d_armor")

dofile(minetest.get_modpath(minetest.get_current_modname()).."/armor.lua")

-- Regisiter Head Armor

local longdesc = S("This is a piece of equippable armor which reduces the amount of damage you receive.")
local usage = S("To equip it, put it on the corresponding armor slot in your inventory menu.")

minetest.register_tool("3d_armor:helmet_leather", {
	description = S("Leather Cap"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_helmet_leather.png",
	groups = {armor_head=1, mcl_armor_points=1, mcl_armor_uses=56},
	_repair_material = "mcl_mobitems:leather",
	sounds = {
		_mcl_armor_equip = "3d_armor_equip_leather",
		_mcl_armor_unequip = "3d_armor_unequip_leather",
	},
})

minetest.register_tool("3d_armor:helmet_iron", {
	description = S("Iron Helmet"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_helmet_iron.png",
	groups = {armor_head=1, mcl_armor_points=2, mcl_armor_uses=166},
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "3d_armor_equip_iron",
		_mcl_armor_unequip = "3d_armor_unequip_iron",
	},
})

minetest.register_tool("3d_armor:helmet_gold", {
	description = S("Golden Helmet"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_helmet_gold.png",
	groups = {armor_head=1, mcl_armor_points=2, mcl_armor_uses=78},
	_repair_material = "mcl_core:gold_ingot",
})

minetest.register_tool("3d_armor:helmet_diamond",{
	description = S("Diamond Helmet"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_helmet_diamond.png",
	groups = {armor_head=1, mcl_armor_points=3, mcl_armor_uses=364, mcl_armor_toughness=2},
	_repair_material = "mcl_core:diamond",
	sounds = {
		_mcl_armor_equip = "3d_armor_equip_diamond",
		_mcl_armor_unequip = "3d_armor_unequip_diamond",
	},
})

minetest.register_tool("3d_armor:helmet_chain", {
	description = S("Chain Helmet"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_helmet_chain.png",
	groups = {armor_head=1, mcl_armor_points=2, mcl_armor_uses=166},
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "3d_armor_equip_chainmail",
		_mcl_armor_unequip = "3d_armor_unequip_chainmail",
	},
})

-- Regisiter Torso Armor

minetest.register_tool("3d_armor:chestplate_leather", {
	description = S("Leather Tunic"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_chestplate_leather.png",
	groups = {armor_torso=1, mcl_armor_points=3, mcl_armor_uses=81},
	_repair_material = "mcl_mobitems:leather",
	sounds = {
		_mcl_armor_equip = "3d_armor_equip_leather",
		_mcl_armor_unequip = "3d_armor_unequip_leather",
	},
})

minetest.register_tool("3d_armor:chestplate_iron", {
	description = S("Iron Chestplate"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_chestplate_iron.png",
	groups = {armor_torso=1, mcl_armor_points=6, mcl_armor_uses=241},
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "3d_armor_equip_iron",
		_mcl_armor_unequip = "3d_armor_unequip_iron",
	},
})

minetest.register_tool("3d_armor:chestplate_gold", {
	description = S("Golden Chestplate"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_chestplate_gold.png",
	groups = {armor_torso=1, mcl_armor_points=5, mcl_armor_uses=113},
	_repair_material = "mcl_core:gold_ingot",
})

minetest.register_tool("3d_armor:chestplate_diamond",{
	description = S("Diamond Chestplate"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_chestplate_diamond.png",
	groups = {armor_torso=1, mcl_armor_points=8, mcl_armor_uses=529, mcl_armor_toughness=2},
	_repair_material = "mcl_core:diamond",
	sounds = {
		_mcl_armor_equip = "3d_armor_equip_diamond",
		_mcl_armor_unequip = "3d_armor_unequip_diamond",
	},
})

minetest.register_tool("3d_armor:chestplate_chain", {
	description = S("Chain Chestplate"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_chestplate_chain.png",
	groups = {armor_torso=1, mcl_armor_points=5, mcl_armor_uses=241},
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "3d_armor_equip_chainmail",
		_mcl_armor_unequip = "3d_armor_unequip_chainmail",
	},
})

-- Regisiter Leg Armor

minetest.register_tool("3d_armor:leggings_leather", {
	description = S("Leather Pants"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_leggings_leather.png",
	groups = {armor_legs=1, mcl_armor_points=2, mcl_armor_uses=76},
	_repair_material = "mcl_mobitems:leather",
	sounds = {
		_mcl_armor_equip = "3d_armor_equip_leather",
		_mcl_armor_unequip = "3d_armor_unequip_leather",
	},
})

minetest.register_tool("3d_armor:leggings_iron", {
	description = S("Iron Leggings"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_leggings_iron.png",
	groups = {armor_legs=1, mcl_armor_points=5, mcl_armor_uses=226},
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "3d_armor_equip_iron",
		_mcl_armor_unequip = "3d_armor_unequip_iron",
	},
})

minetest.register_tool("3d_armor:leggings_gold", {
	description = S("Golden Leggings"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_leggings_gold.png",
	groups = {armor_legs=1, mcl_armor_points=3, mcl_armor_uses=106},
	_repair_material = "mcl_core:gold_ingot",
})

minetest.register_tool("3d_armor:leggings_diamond",{
	description = S("Diamond Leggings"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_leggings_diamond.png",
	groups = {armor_legs=1, mcl_armor_points=6, mcl_armor_uses=496, mcl_armor_toughness=2},
	_repair_material = "mcl_core:diamond",
	sounds = {
		_mcl_armor_equip = "3d_armor_equip_diamond",
		_mcl_armor_unequip = "3d_armor_unequip_diamond",
	},
})

minetest.register_tool("3d_armor:leggings_chain", {
	description = S("Chain Leggings"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_leggings_chain.png",
	groups = {armor_legs=1, mcl_armor_points=4, mcl_armor_uses=226},
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "3d_armor_equip_chainmail",
		_mcl_armor_unequip = "3d_armor_unequip_chainmail",
	},
})
-- Regisiter Boots

minetest.register_tool("3d_armor:boots_leather", {
	description = S("Leather Boots"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_boots_leather.png",
	groups = {armor_feet=1, mcl_armor_points=1, mcl_armor_uses=66},
	_repair_material = "mcl_mobitems:leather",
	sounds = {
		_mcl_armor_equip = "3d_armor_equip_leather",
		_mcl_armor_unequip = "3d_armor_unequip_leather",
	},
})

minetest.register_tool("3d_armor:boots_iron", {
	description = S("Iron Boots"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_boots_iron.png",
	groups = {armor_feet=1, mcl_armor_points=2, mcl_armor_uses=196},
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "3d_armor_equip_iron",
		_mcl_armor_unequip = "3d_armor_unequip_iron",
	},
})

minetest.register_tool("3d_armor:boots_gold", {
	description = S("Golden Boots"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_boots_gold.png",
	groups = {armor_feet=1, mcl_armor_points=1, mcl_armor_uses=92},
	_repair_material = "mcl_core:gold_ingot",
})

minetest.register_tool("3d_armor:boots_diamond",{
	description = S("Diamond Boots"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_boots_diamond.png",
	groups = {armor_feet=1, mcl_armor_points=3, mcl_armor_uses=430, mcl_armor_toughness=2},
	_repair_material = "mcl_core:diamond",
	sounds = {
		_mcl_armor_equip = "3d_armor_equip_diamond",
		_mcl_armor_unequip = "3d_armor_unequip_diamond",
	},
})

minetest.register_tool("3d_armor:boots_chain", {
	description = S("Chain Boots"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "3d_armor_inv_boots_chain.png",
	groups = {armor_feet=1, mcl_armor_points=1, mcl_armor_uses=196},
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "3d_armor_equip_chainmail",
		_mcl_armor_unequip = "3d_armor_unequip_chainmail",
	},
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
