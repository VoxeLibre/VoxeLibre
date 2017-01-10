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
	on_use = minetest.item_eat(2),
})

minetest.register_craftitem("mobs:meat_raw_sheep", {
	description = "Raw Mutton",
	inventory_image = "mutton_raw.png",
	on_use = minetest.item_eat(2),
})

minetest.register_craftitem("mobs:meat_cooked_sheep", {
	description = "Cooked Mutton",
	inventory_image = "mutton_cooked.png",
	on_use = minetest.item_eat(4),
})

minetest.register_craftitem("mobs:spider_eye", {
	description = "Spider Eye",
	inventory_image = "spider_eye.png",
	on_use = minetest.item_eat(2),
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:meat_cooked_sheep",
	recipe = "mobs:meat_raw_sheep",
	cooktime = 10,
})

