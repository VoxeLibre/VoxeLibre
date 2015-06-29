dofile(minetest.get_modpath(minetest.get_current_modname()).."/armor.lua")

-- Regisiter Head Armor

minetest.register_tool("3d_armor:helmet_leather", {
	description = "Leather Helmet",
	inventory_image = "3d_armor_inv_helmet_leather.png",
	groups = {armor_head=5, armor_heal=0, armor_use=100},
	wear = 0,
})

minetest.register_tool("3d_armor:helmet_steel", {
	description = "Steel Helmet",
	inventory_image = "3d_armor_inv_helmet_steel.png",
	groups = {armor_head=10, armor_heal=5, armor_use=250},
	wear = 0,
})

minetest.register_tool("3d_armor:helmet_gold", {
	description = "Golden Helmet",
	inventory_image = "3d_armor_inv_helmet_gold.png",
	groups = {armor_head=15, armor_heal=10, armor_use=500},
	wear = 0,
})

minetest.register_tool("3d_armor:helmet_diamond",{
	description = "Diamond Helmet",
	inventory_image = "3d_armor_inv_helmet_diamond.png",
	groups = {armor_head=20, armor_heal=15, armor_use=750},
	wear = 0,
})

minetest.register_tool("3d_armor:helmet_chain", {
	description = "Chain Helmet",
	inventory_image = "3d_armor_inv_helmet_chain.png",
	groups = {armor_head=15, armor_heal=10, armor_use=500},
	wear = 0,
})

-- Regisiter Torso Armor

minetest.register_tool("3d_armor:chestplate_leather", {
	description = "Leather Chestplate",
	inventory_image = "3d_armor_inv_chestplate_leather.png",
	groups = {armor_torso=15, armor_heal=0, armor_use=100},
	wear = 0,
})

minetest.register_tool("3d_armor:chestplate_steel", {
	description = "Steel Chestplate",
	inventory_image = "3d_armor_inv_chestplate_steel.png",
	groups = {armor_torso=20, armor_heal=5, armor_use=250},
	wear = 0,
})

minetest.register_tool("3d_armor:chestplate_gold", {
	description = "Golden Chestplate",
	inventory_image = "3d_armor_inv_chestplate_gold.png",
	groups = {armor_torso=25, armor_heal=10, armor_use=500},
	wear = 0,
})

minetest.register_tool("3d_armor:chestplate_diamond",{
	description = "Diamond Helmet",
	inventory_image = "3d_armor_inv_chestplate_diamond.png",
	groups = {armor_torso=30, armor_heal=15, armor_use=750},
	wear = 0,
})

minetest.register_tool("3d_armor:chestplate_chain", {
	description = "Chain Chestplate",
	inventory_image = "3d_armor_inv_chestplate_chain.png",
	groups = {armor_torso=25, armor_heal=10, armor_use=500},
	wear = 0,
})

-- Regisiter Leg Armor

minetest.register_tool("3d_armor:leggings_leather", {
	description = "Leather Leggings",
	inventory_image = "3d_armor_inv_leggings_leather.png",
	groups = {armor_legs=10, armor_heal=0, armor_use=100},
	wear = 0,
})

minetest.register_tool("3d_armor:leggings_steel", {
	description = "Steel Leggings",
	inventory_image = "3d_armor_inv_leggings_steel.png",
	groups = {armor_legs=15, armor_heal=5, armor_use=250},
	wear = 0,
})

minetest.register_tool("3d_armor:leggings_gold", {
	description = "Golden Leggings",
	inventory_image = "3d_armor_inv_leggings_gold.png",
	groups = {armor_legs=20, armor_heal=10, armor_use=500},
	wear = 0,
})

minetest.register_tool("3d_armor:leggings_diamond",{
	description = "Diamond Helmet",
	inventory_image = "3d_armor_inv_leggings_diamond.png",
	groups = {armor_legs=25, armor_heal=15, armor_use=750},
	wear = 0,
})

minetest.register_tool("3d_armor:leggings_chain", {
	description = "Chain Leggings",
	inventory_image = "3d_armor_inv_leggings_chain.png",
	groups = {armor_legs=20, armor_heal=10, armor_use=500},
	wear = 0,
})
-- Regisiter Boots

minetest.register_tool("3d_armor:boots_leather", {
	description = "Leather Boots",
	inventory_image = "3d_armor_inv_boots_leather.png",
	groups = {armor_feet=5, armor_heal=0, armor_use=100},
	wear = 0,
})

minetest.register_tool("3d_armor:boots_steel", {
	description = "Steel Boots",
	inventory_image = "3d_armor_inv_boots_steel.png",
	groups = {armor_feet=10, armor_heal=5, armor_use=250},
	wear = 0,
})

minetest.register_tool("3d_armor:boots_gold", {
	description = "Golden Boots",
	inventory_image = "3d_armor_inv_boots_gold.png",
	groups = {armor_feet=15, armor_heal=10, armor_use=500},
	wear = 0,
})

minetest.register_tool("3d_armor:boots_diamond",{
	description = "Diamond Helmet",
	inventory_image = "3d_armor_inv_boots_diamond.png",
	groups = {armor_feet=20, armor_heal=15, armor_use=750},
	wear = 0,
})

minetest.register_tool("3d_armor:boots_chain", {
	description = "Chain Boots",
	inventory_image = "3d_armor_inv_boots_chain.png",
	groups = {armor_feet=15, armor_heal=10, armor_use=500},
	wear = 0,
})

-- Register Craft Recipies

local craft_ingreds = {
	leather = "default:wood",
	steel = "default:steel_ingot",
	gold = "default:gold_ingot",
	diamond = "default:diamond",
	chain = "fire:fire",
}		

for k, v in pairs(craft_ingreds) do
	minetest.register_craft({
		output = "3d_armor:helmet_"..k,
		recipe = {
			{v, v, v},
			{v, "", v},
			{"", "", ""},
		},
	})
	minetest.register_craft({
		output = "3d_armor:chestplate_"..k,
		recipe = {
			{v, "", v},
			{v, v, v},
			{v, v, v},
		},
	})
	minetest.register_craft({
		output = "3d_armor:leggings_"..k,
		recipe = {
			{v, v, v},
			{v, "", v},
			{v, "", v},
		},
	})
	minetest.register_craft({
		output = "3d_armor:boots_"..k,
		recipe = {
			{v, "", v},
			{v, "", v},
		},
	})
end


