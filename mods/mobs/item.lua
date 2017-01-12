----------------
-- Spawn eggs --
----------------
minetest.register_craftitem("mobs:sheep", {
	description = "Spawn Sheep",
	inventory_image = "spawn_sheep.png",
	wield_scale = {x = 1.25, y = 1.25, z = 2.5},
	groups = {},
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.above then
			minetest.add_entity(pointed_thing.above, "mobs:sheep")
			if not minetest.setting_getbool("creative_mode") then itemstack:take_item() end
			minetest.log("action", placer:get_player_name() .. " placed a sheep at " .. minetest.pos_to_string(pointed_thing.above) .. ".")
		end
		return itemstack
	end,
})

minetest.register_craftitem("mobs:slime", {
	description = "Spawn Slime",
	inventory_image = "spawn_slime.png",
	wield_scale = {x = 1.25, y = 1.25, z = 2.5},
	groups = {},
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.above then
			minetest.add_entity(pointed_thing.above, "mobs:slime")
			if not minetest.setting_getbool("creative_mode") then itemstack:take_item() end
			minetest.log("action", placer:get_player_name() .. " placed a slime at " .. minetest.pos_to_string(pointed_thing.above) .. ".")
		end
		return itemstack
	end,
})

minetest.register_craftitem("mobs:zombie", {
	description = "Spawn Zombie",
	inventory_image = "spawn_zombie.png",
	wield_scale = {x = 1.25, y = 1.25, z = 2.5},
	groups = {},
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.above then
			minetest.add_entity(pointed_thing.above, "mobs:zombie")
			if not minetest.setting_getbool("creative_mode") then itemstack:take_item() end
			minetest.log("action", placer:get_player_name() .. " placed a zombie at " .. minetest.pos_to_string(pointed_thing.above) .. ".")
		end
		return itemstack
	end,
})

minetest.register_craftitem("mobs:spider", {
	description = "Spawn Spider",
	inventory_image = "spawn_spider.png",
	wield_scale = {x = 1.25, y = 1.25, z = 2.5},
	groups = {},
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.above then
			minetest.add_entity(pointed_thing.above, "mobs:spider")
			if not minetest.setting_getbool("creative_mode") then itemstack:take_item() end
			minetest.log("action", placer:get_player_name() .. " placed a spider at " .. minetest.pos_to_string(pointed_thing.above) .. ".")
		end
		return itemstack
	end,
})


minetest.register_craftitem("mobs:creeper", {
	description = "Spawn Creeper",
	inventory_image = "spawn_creeper.png",
	wield_scale = {x = 1.25, y = 1.25, z = 2.5},
	groups = {},
	
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.above then
			minetest.add_entity(pointed_thing.above, "mobs:creeper")
			if not minetest.setting_getbool("creative_mode") then itemstack:take_item() end
			minetest.log("action", placer:get_player_name() .. " placed a creeper at " .. minetest.pos_to_string(pointed_thing.above) .. ".")
		end
		return itemstack
	end,
})

---------------------
-- Drop de monstre --
---------------------

minetest.register_craftitem("mobs:rotten_flesh", {
	description = "Rotten Flesh",
	inventory_image = "rotten_flesh.png",
	wield_image = "rotten_flesh.png",
	-- TODO: Raise to 4
	on_use = minetest.item_eat(1),
	stack_max = 64,
})

minetest.register_craftitem("mobs:mutton", {
	description = "Raw Mutton",
	inventory_image = "mutton_raw.png",
	wield_image = "mutton_raw.png",
	on_use = minetest.item_eat(2),
	stack_max = 64,
})

minetest.register_craftitem("mobs:cooked_mutton", {
	description = "Cooked Mutton",
	inventory_image = "mutton_cooked.png",
	wield_image = "mutton_cooked.png",
	on_use = minetest.item_eat(6),
	stack_max = 64,
})

minetest.register_craftitem("mobs:beef", {
	description = "Raw Beef",
	inventory_image = "mobs_beef_raw.png",
	wield_image = "mobs_beef_raw.png",
	on_use = minetest.item_eat(3),
	stack_max = 64,
})

minetest.register_craftitem("mobs:cooked_beef", {
	description = "Steak",
	inventory_image = "mobs_beef_cooked.png",
	wield_image = "mobs_beef_cooked.png",
	on_use = minetest.item_eat(8),
	stack_max = 64,
})

minetest.register_craftitem("mobs:chicken", {
	description = "Raw Chicken",
	inventory_image = "mobs_chicken_raw.png",
	wield_image = "mobs_chicken_raw.png",
	on_use = minetest.item_eat(2),
	stack_max = 64,
})

minetest.register_craftitem("mobs:cooked_chicken", {
	description = "Cooked Chicken",
	inventory_image = "mobs_chicken_cooked.png",
	wield_image = "mobs_chicken_cooked.png",
	on_use = minetest.item_eat(6),
	stack_max = 64,
})

minetest.register_craftitem("mobs:porkchop", {
	description = "Raw Porkchop",
	inventory_image = "mobs_porkchop_raw.png",
	wield_image = "mobs_porkchop.png",
	on_use = minetest.item_eat(3),
	stack_max = 64,
})

minetest.register_craftitem("mobs:cooked_porkchop", {
	description = "Cooked Porkchop",
	inventory_image = "mobs_porkchop_cooked.png",
	wield_image = "mobs_porkchop_cooked.png",
	on_use = minetest.item_eat(8),
	stack_max = 64,
})

minetest.register_craftitem("mobs:rabbit", {
	description = "Raw Rabbit",
	inventory_image = "mobs_rabbit_raw.png",
	wield_image = "mobs_rabbit_raw.png",
	on_use = minetest.item_eat(3),
	stack_max = 64,
})

minetest.register_craftitem("mobs:cooked_rabbit", {
	description = "Cooked Rabbit",
	inventory_image = "mobs_rabbit_cooked.png",
	wield_image = "mobs_rabbit_cooked.png",
	on_use = minetest.item_eat(5),
	stack_max = 64,
})

minetest.register_craftitem("mobs:spider_eye", {
	description = "Spider Eye",
	inventory_image = "spider_eye.png",
	wield_image = "spider_eye.png",
	on_use = minetest.item_eat(2),
	stack_max = 64,
})

minetest.register_craftitem("mobs:blaze_rod", {
	description = "Blaze Rod",
	wield_image = "mobs_blaze_rod.png",
	inventory_image = "mobs_blaze_rod.png",
	stack_max = 64,
})

minetest.register_craftitem("mobs:blaze_powder", {
	description = "Blaze Powder",
	wield_image = "mobs_blaze_powder.png",
	inventory_image = "mobs_blaze_powder.png",
	stack_max = 64,
})

minetest.register_craftitem("mobs:magma_cream", {
	description = "Magma Cream",
	wield_image = "mobs_magma_cream.png",
	inventory_image = "mobs_magma_cream.png",
	stack_max = 64,
})

minetest.register_craftitem("mobs:ghast_tear", {
	description = "Ghast Tear",
	wield_image = "mobs_ghast_tear.png",
	inventory_image = "mobs_ghast_tear.png",
	stack_max = 64,
})

minetest.register_craftitem("mobs:nether_star", {
	description = "Nether Star",
	wield_image = "mobs_nether_star.png",
	inventory_image = "mobs_nether_star.png",
	stack_max = 64,
})

minetest.register_craftitem("mobs:leather", {
	description = "Leather",
	wield_image = "mobs_leather.png",
	inventory_image = "mobs_leather.png",
	stack_max = 64,
})

minetest.register_craftitem("mobs:feather", {
	description = "Feather",
	wield_image = "mobs_feather.png",
	inventory_image = "mobs_feather.png",
	stack_max = 64,
})

minetest.register_craftitem("mobs:rabbit_hide", {
	description = "Rabbit Hide",
	wield_image = "mobs_rabbit_hide.png",
	inventory_image = "mobs_rabbit_hide.png",
	stack_max = 64,
})

minetest.register_craftitem("mobs:rabbit_foot", {
	description = "Rabbit's Foot",
	wield_image = "mobs_rabbit_foot.png",
	inventory_image = "mobs_rabbit_foot.png",
	stack_max = 64,
})

-----------
-- Crafting
-----------

minetest.register_craft({
	output = "mobs:leather",
	recipe = {
		{ "mobs:rabbit_hide", "mobs:rabbit_hide" },
		{ "mobs:rabbit_hide", "mobs:rabbit_hide" },
	}
})

minetest.register_craft({
	output = "mobs:blaze_powder 2",
	recipe = {{"mobs:blaze_rod"}},
})

minetest.register_craft({
	type = "shapeless",
	output = "mobs:magma_cream",
	recipe = {"mobs:blaze_powder", "mesecons_materials:glue"},
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:cooked_mutton",
	recipe = "mobs:mutton",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:cooked_rabbit",
	recipe = "mobs:rabbit",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:cooked_chicken",
	recipe = "mobs:chicken",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:cooked_beef",
	recipe = "mobs:beef",
	cooktime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mobs:blaze_rod",
	burntime = 120,
})

-- Temporary helper recipes
-- TODO: Remove them
minetest.register_craft({
	type = "shapeless",
	output = "mobs:leather",
	recipe = { "default:paper", "default:paper" },
})
minetest.register_craft({
	output = "mobs:feather 3",
	recipe = {
		{ "flowers:oxeye_daisy" },
		{ "flowers:oxeye_daisy" },
	}
})


