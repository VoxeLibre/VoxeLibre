local S = minetest.get_translator("mcl_armor")

mcl_armor = {
	elements = {
		{
			name = "helmet",
			description = S("Helmet"),
			durability = 0.6875,
			recipe = function(m)
				return {
					{ m,  m,  m},
					{ m, "",  m},
					{"", "", ""},
				}
			end,
		},
		{
			name = "chestplate",
			description = S("Chestplate"),
			durability = 1.0,
			recipe = function(m)
				return {
					{ m, "",  m},
					{ m,  m,  m},
					{ m,  m,  m},
				}
			end,
		},
		{
			name = "leggings",
			description = S("Leggings"),
			durability = 0.9375,
			recipe = function(m)
				return {
					{ m,  m,  m},
					{ m, "",  m},
					{ m, "",  m},
				}
			end,
		},
		{
			name = "boots",
			description = S("Boots"),
			durability = 0.8125,
			recipe = function(m)
				return {
					{ m, "",  m},
					{ m, "",  m},
				}
			end,
		},
	},
	longdesc = S("This is a piece of equippable armor which reduces the amount of damage you receive."),
	usagehelp = S("To equip it, put it on the corresponding armor slot in your inventory menu."),
}

local modpath = minetest.get_modpath("mcl_armor")

dofile(modpath .. "/damage.lua")
dofile(modpath .. "/alias.lua")
dofile(modpath .. "/items.lua")
dofile(modpath .. "/enchantments.lua")

-- Regisiter Head Armor

minetest.register_tool("mcl_armor:helmet_leather", {
	description = S("Leather Cap"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_helmet_leather.png",
	groups = {armor_head=1, mcl_armor_points=1, mcl_armor_uses=56, enchantability=15},
	_repair_material = "mcl_mobitems:leather",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_leather",
		_mcl_armor_unequip = "mcl_armor_unequip_leather",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool("mcl_armor:helmet_iron", {
	description = S("Iron Helmet"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_helmet_iron.png",
	groups = {armor_head=1, mcl_armor_points=2, mcl_armor_uses=166, enchantability=9 },
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
		_mcl_armor_unequip = "mcl_armor_unequip_iron",
	},

	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool("mcl_armor:helmet_gold", {
	description = S("Golden Helmet"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_helmet_gold.png",
	groups = {armor_head=1, mcl_armor_points=2, mcl_armor_uses=78, enchantability=25 },
	_repair_material = "mcl_core:gold_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
		_mcl_armor_unequip = "mcl_armor_unequip_iron",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool("mcl_armor:helmet_diamond",{
	description = S("Diamond Helmet"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_helmet_diamond.png",
	groups = {armor_head=1, mcl_armor_points=3, mcl_armor_uses=364, mcl_armor_toughness=2, enchantability=10 },
	_repair_material = "mcl_core:diamond",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_diamond",
		_mcl_armor_unequip = "mcl_armor_unequip_diamond",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool("mcl_armor:helmet_chain", {
	description = S("Chain Helmet"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_helmet_chain.png",
	groups = {armor_head=1, mcl_armor_points=2, mcl_armor_uses=166, enchantability=12 },
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_chainmail",
		_mcl_armor_unequip = "mcl_armor_unequip_chainmail",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

-- Regisiter Torso Armor

minetest.register_tool("mcl_armor:chestplate_leather", {
	description = S("Leather Tunic"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_chestplate_leather.png",
	groups = {armor_torso=1, mcl_armor_points=3, mcl_armor_uses=81, enchantability=15 },
	_repair_material = "mcl_mobitems:leather",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_leather",
		_mcl_armor_unequip = "mcl_armor_unequip_leather",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool("mcl_armor:chestplate_iron", {
	description = S("Iron Chestplate"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_chestplate_iron.png",
	groups = {armor_torso=1, mcl_armor_points=6, mcl_armor_uses=241, enchantability=9 },
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
		_mcl_armor_unequip = "mcl_armor_unequip_iron",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool("mcl_armor:chestplate_gold", {
	description = S("Golden Chestplate"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_chestplate_gold.png",
	groups = {armor_torso=1, mcl_armor_points=5, mcl_armor_uses=113, enchantability=25 },
	_repair_material = "mcl_core:gold_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
		_mcl_armor_unequip = "mcl_armor_unequip_iron",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool("mcl_armor:chestplate_diamond",{
	description = S("Diamond Chestplate"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_chestplate_diamond.png",
	groups = {armor_torso=1, mcl_armor_points=8, mcl_armor_uses=529, mcl_armor_toughness=2, enchantability=10 },
	_repair_material = "mcl_core:diamond",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_diamond",
		_mcl_armor_unequip = "mcl_armor_unequip_diamond",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool("mcl_armor:chestplate_chain", {
	description = S("Chain Chestplate"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_chestplate_chain.png",
	groups = {armor_torso=1, mcl_armor_points=5, mcl_armor_uses=241, enchantability=12 },
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_chainmail",
		_mcl_armor_unequip = "mcl_armor_unequip_chainmail",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

-- Regisiter Leg Armor

minetest.register_tool("mcl_armor:leggings_leather", {
	description = S("Leather Pants"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_leggings_leather.png",
	groups = {armor_legs=1, mcl_armor_points=2, mcl_armor_uses=76, enchantability=15 },
	_repair_material = "mcl_mobitems:leather",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_leather",
		_mcl_armor_unequip = "mcl_armor_unequip_leather",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool("mcl_armor:leggings_iron", {
	description = S("Iron Leggings"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_leggings_iron.png",
	groups = {armor_legs=1, mcl_armor_points=5, mcl_armor_uses=226, enchantability=9 },
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
		_mcl_armor_unequip = "mcl_armor_unequip_iron",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool("mcl_armor:leggings_gold", {
	description = S("Golden Leggings"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_leggings_gold.png",
	groups = {armor_legs=1, mcl_armor_points=3, mcl_armor_uses=106, enchantability=25 },
	_repair_material = "mcl_core:gold_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
		_mcl_armor_unequip = "mcl_armor_unequip_iron",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool("mcl_armor:leggings_diamond",{
	description = S("Diamond Leggings"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_leggings_diamond.png",
	groups = {armor_legs=1, mcl_armor_points=6, mcl_armor_uses=496, mcl_armor_toughness=2, enchantability=10 },
	_repair_material = "mcl_core:diamond",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_diamond",
		_mcl_armor_unequip = "mcl_armor_unequip_diamond",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool("mcl_armor:leggings_chain", {
	description = S("Chain Leggings"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_leggings_chain.png",
	groups = {armor_legs=1, mcl_armor_points=4, mcl_armor_uses=226, enchantability=12 },
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_chainmail",
		_mcl_armor_unequip = "mcl_armor_unequip_chainmail",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})
-- Regisiter Boots

minetest.register_tool("mcl_armor:boots_leather", {
	description = S("Leather Boots"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_boots_leather.png",
	groups = {armor_feet=1, mcl_armor_points=1, mcl_armor_uses=66, enchantability=15 },
	_repair_material = "mcl_mobitems:leather",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_leather",
		_mcl_armor_unequip = "mcl_armor_unequip_leather",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool("mcl_armor:boots_iron", {
	description = S("Iron Boots"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_boots_iron.png",
	groups = {armor_feet=1, mcl_armor_points=2, mcl_armor_uses=196, enchantability=9 },
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
		_mcl_armor_unequip = "mcl_armor_unequip_iron",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool("mcl_armor:boots_gold", {
	description = S("Golden Boots"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_boots_gold.png",
	groups = {armor_feet=1, mcl_armor_points=1, mcl_armor_uses=92, enchantability=25 },
	_repair_material = "mcl_core:gold_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
		_mcl_armor_unequip = "mcl_armor_unequip_iron",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool("mcl_armor:boots_diamond",{
	description = S("Diamond Boots"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_boots_diamond.png",
	groups = {armor_feet=1, mcl_armor_points=3, mcl_armor_uses=430, mcl_armor_toughness=2, enchantability=10 },
	_repair_material = "mcl_core:diamond",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_diamond",
		_mcl_armor_unequip = "mcl_armor_unequip_diamond",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

minetest.register_tool("mcl_armor:boots_chain", {
	description = S("Chain Boots"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_boots_chain.png",
	groups = {armor_feet=1, mcl_armor_points=1, mcl_armor_uses=196, enchantability=12 },
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_chainmail",
		_mcl_armor_unequip = "mcl_armor_unequip_chainmail",
	},
	on_place = armor.on_armor_use,
	on_secondary_use = armor.on_armor_use,
})

-- Register Craft Recipies

local craft_ingreds = {
	leather = { "mcl_mobitems:leather" },
	iron = { "mcl_core:iron_ingot", "mcl_core:iron_nugget" },
	gold = { "mcl_core:gold_ingot", "mcl_core:gold_nugget" },
	diamond = { "mcl_core:diamond" },
	chain = { nil, "mcl_core:iron_nugget"} ,
}
