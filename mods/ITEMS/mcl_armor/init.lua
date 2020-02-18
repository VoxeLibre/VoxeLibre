local S = minetest.get_translator("mcl_armor")

dofile(minetest.get_modpath(minetest.get_current_modname()).."/armor.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/alias.lua")

-- Regisiter Head Armor

local longdesc = S("This is a piece of equippable armor which reduces the amount of damage you receive.")
local usage = S("To equip it, put it on the corresponding armor slot in your inventory menu.")

local function on_armor_use(itemstack, user, pointed_thing)
	if not user or user:is_player() == false then
		return itemstack
	end

	-- Call on_rightclick if the pointed node defines it
	if pointed_thing.type == "node" then
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end
	end

	local name, player_inv, armor_inv = armor:get_valid_player(user, "[on_armor_use]")
	if not name then
		return itemstack
	end

	local def = itemstack:get_definition()
	local slot
	if def.groups and def.groups.armor_head then
		slot = 2
	elseif def.groups and def.groups.armor_torso then
		slot = 3
	elseif def.groups and def.groups.armor_legs then
		slot = 4
	elseif def.groups and def.groups.armor_feet then
		slot = 5
	end

	if slot then
		local itemstack_single = ItemStack(itemstack)
		itemstack_single:set_count(1)
		local itemstack_slot = armor_inv:get_stack("armor", slot)
		if itemstack_slot:is_empty() then
			armor_inv:set_stack("armor", slot, itemstack_single)
			player_inv:set_stack("armor", slot, itemstack_single)
			armor:set_player_armor(user)
			armor:update_inventory(user)
			armor:play_equip_sound(user, itemstack_single)
			itemstack:take_item()
		elseif itemstack:get_count() <= 1 then
			armor_inv:set_stack("armor", slot, itemstack_single)
			player_inv:set_stack("armor", slot, itemstack_single)
			armor:set_player_armor(user)
			armor:update_inventory(user)
			armor:play_equip_sound(user, itemstack_single)
			itemstack = ItemStack(itemstack_slot)
		end
	end

	return itemstack
end

minetest.register_tool("mcl_armor:helmet_leather", {
	description = S("Leather Cap"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_helmet_leather.png",
	groups = {armor_head=1, mcl_armor_points=1, mcl_armor_uses=56},
	_repair_material = "mcl_mobitems:leather",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_leather",
		_mcl_armor_unequip = "mcl_armor_unequip_leather",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

minetest.register_tool("mcl_armor:helmet_iron", {
	description = S("Iron Helmet"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_helmet_iron.png",
	groups = {armor_head=1, mcl_armor_points=2, mcl_armor_uses=166},
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
		_mcl_armor_unequip = "mcl_armor_unequip_iron",
	},

	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

minetest.register_tool("mcl_armor:helmet_gold", {
	description = S("Golden Helmet"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_helmet_gold.png",
	groups = {armor_head=1, mcl_armor_points=2, mcl_armor_uses=78},
	_repair_material = "mcl_core:gold_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
		_mcl_armor_unequip = "mcl_armor_unequip_iron",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

minetest.register_tool("mcl_armor:helmet_diamond",{
	description = S("Diamond Helmet"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_helmet_diamond.png",
	groups = {armor_head=1, mcl_armor_points=3, mcl_armor_uses=364, mcl_armor_toughness=2},
	_repair_material = "mcl_core:diamond",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_diamond",
		_mcl_armor_unequip = "mcl_armor_unequip_diamond",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

minetest.register_tool("mcl_armor:helmet_chain", {
	description = S("Chain Helmet"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_helmet_chain.png",
	groups = {armor_head=1, mcl_armor_points=2, mcl_armor_uses=166},
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_chainmail",
		_mcl_armor_unequip = "mcl_armor_unequip_chainmail",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

-- Regisiter Torso Armor

minetest.register_tool("mcl_armor:chestplate_leather", {
	description = S("Leather Tunic"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_chestplate_leather.png",
	groups = {armor_torso=1, mcl_armor_points=3, mcl_armor_uses=81},
	_repair_material = "mcl_mobitems:leather",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_leather",
		_mcl_armor_unequip = "mcl_armor_unequip_leather",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

minetest.register_tool("mcl_armor:chestplate_iron", {
	description = S("Iron Chestplate"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_chestplate_iron.png",
	groups = {armor_torso=1, mcl_armor_points=6, mcl_armor_uses=241},
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
		_mcl_armor_unequip = "mcl_armor_unequip_iron",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

minetest.register_tool("mcl_armor:chestplate_gold", {
	description = S("Golden Chestplate"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_chestplate_gold.png",
	groups = {armor_torso=1, mcl_armor_points=5, mcl_armor_uses=113},
	_repair_material = "mcl_core:gold_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
		_mcl_armor_unequip = "mcl_armor_unequip_iron",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

minetest.register_tool("mcl_armor:chestplate_diamond",{
	description = S("Diamond Chestplate"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_chestplate_diamond.png",
	groups = {armor_torso=1, mcl_armor_points=8, mcl_armor_uses=529, mcl_armor_toughness=2},
	_repair_material = "mcl_core:diamond",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_diamond",
		_mcl_armor_unequip = "mcl_armor_unequip_diamond",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

minetest.register_tool("mcl_armor:chestplate_chain", {
	description = S("Chain Chestplate"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_chestplate_chain.png",
	groups = {armor_torso=1, mcl_armor_points=5, mcl_armor_uses=241},
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_chainmail",
		_mcl_armor_unequip = "mcl_armor_unequip_chainmail",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

-- Regisiter Leg Armor

minetest.register_tool("mcl_armor:leggings_leather", {
	description = S("Leather Pants"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_leggings_leather.png",
	groups = {armor_legs=1, mcl_armor_points=2, mcl_armor_uses=76},
	_repair_material = "mcl_mobitems:leather",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_leather",
		_mcl_armor_unequip = "mcl_armor_unequip_leather",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

minetest.register_tool("mcl_armor:leggings_iron", {
	description = S("Iron Leggings"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_leggings_iron.png",
	groups = {armor_legs=1, mcl_armor_points=5, mcl_armor_uses=226},
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
		_mcl_armor_unequip = "mcl_armor_unequip_iron",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

minetest.register_tool("mcl_armor:leggings_gold", {
	description = S("Golden Leggings"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_leggings_gold.png",
	groups = {armor_legs=1, mcl_armor_points=3, mcl_armor_uses=106},
	_repair_material = "mcl_core:gold_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
		_mcl_armor_unequip = "mcl_armor_unequip_iron",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

minetest.register_tool("mcl_armor:leggings_diamond",{
	description = S("Diamond Leggings"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_leggings_diamond.png",
	groups = {armor_legs=1, mcl_armor_points=6, mcl_armor_uses=496, mcl_armor_toughness=2},
	_repair_material = "mcl_core:diamond",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_diamond",
		_mcl_armor_unequip = "mcl_armor_unequip_diamond",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

minetest.register_tool("mcl_armor:leggings_chain", {
	description = S("Chain Leggings"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_leggings_chain.png",
	groups = {armor_legs=1, mcl_armor_points=4, mcl_armor_uses=226},
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_chainmail",
		_mcl_armor_unequip = "mcl_armor_unequip_chainmail",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})
-- Regisiter Boots

minetest.register_tool("mcl_armor:boots_leather", {
	description = S("Leather Boots"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_boots_leather.png",
	groups = {armor_feet=1, mcl_armor_points=1, mcl_armor_uses=66},
	_repair_material = "mcl_mobitems:leather",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_leather",
		_mcl_armor_unequip = "mcl_armor_unequip_leather",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

minetest.register_tool("mcl_armor:boots_iron", {
	description = S("Iron Boots"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_boots_iron.png",
	groups = {armor_feet=1, mcl_armor_points=2, mcl_armor_uses=196},
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
		_mcl_armor_unequip = "mcl_armor_unequip_iron",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

minetest.register_tool("mcl_armor:boots_gold", {
	description = S("Golden Boots"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_boots_gold.png",
	groups = {armor_feet=1, mcl_armor_points=1, mcl_armor_uses=92},
	_repair_material = "mcl_core:gold_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
		_mcl_armor_unequip = "mcl_armor_unequip_iron",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

minetest.register_tool("mcl_armor:boots_diamond",{
	description = S("Diamond Boots"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_boots_diamond.png",
	groups = {armor_feet=1, mcl_armor_points=3, mcl_armor_uses=430, mcl_armor_toughness=2},
	_repair_material = "mcl_core:diamond",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_diamond",
		_mcl_armor_unequip = "mcl_armor_unequip_diamond",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
})

minetest.register_tool("mcl_armor:boots_chain", {
	description = S("Chain Boots"),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usage,
	inventory_image = "mcl_armor_inv_boots_chain.png",
	groups = {armor_feet=1, mcl_armor_points=1, mcl_armor_uses=196},
	_repair_material = "mcl_core:iron_ingot",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_chainmail",
		_mcl_armor_unequip = "mcl_armor_unequip_chainmail",
	},
	on_place = on_armor_use,
	on_secondary_use = on_armor_use,
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
			output = "mcl_armor:helmet_"..k,
			recipe = {
				{m, m, m},
				{m, "", m},
				{"", "", ""},
			},
		})
		minetest.register_craft({
			output = "mcl_armor:chestplate_"..k,
			recipe = {
				{m, "", m},
				{m, m, m},
				{m, m, m},
			},
		})
		minetest.register_craft({
			output = "mcl_armor:leggings_"..k,
			recipe = {
				{m, m, m},
				{m, "", m},
				{m, "", m},
			},
		})
		minetest.register_craft({
			output = "mcl_armor:boots_"..k,
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
			recipe = "mcl_armor:helmet_"..k,
			cooktime = 10,
		})
		minetest.register_craft({
			type = "cooking",
			output = c,
			recipe = "mcl_armor:chestplate_"..k,
			cooktime = 10,
		})
		minetest.register_craft({
			type = "cooking",
			output = c,
			recipe = "mcl_armor:leggings_"..k,
			cooktime = 10,
		})
		minetest.register_craft({
			type = "cooking",
			output = c,
			recipe = "mcl_armor:boots_"..k,
			cooktime = 10,
		})
	end
end

