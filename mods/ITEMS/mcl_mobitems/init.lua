local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_craftitem("mcl_mobitems:rotten_flesh", {
	description = S("Rotten Flesh"),
	_tt_help = minetest.colorize(mcl_colors.YELLOW, S("80% chance of food poisoning")),
	_doc_items_longdesc = S("Yuck! This piece of flesh clearly has seen better days. If you're really desperate, you can eat it to restore a few hunger points, but there's a 80% chance it causes food poisoning, which increases your hunger for a while."),
	inventory_image = "mcl_mobitems_rotten_flesh.png",
	wield_image = "mcl_mobitems_rotten_flesh.png",
	on_place = minetest.item_eat(4),
	on_secondary_use = minetest.item_eat(4),
	groups = { food = 2, eatable = 4 },
	_mcl_saturation = 0.8,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:mutton", {
	description = S("Raw Mutton"),
	_doc_items_longdesc = S("Raw mutton is the flesh from a sheep and can be eaten safely. Cooking it will greatly increase its nutritional value."),
	inventory_image = "mcl_mobitems_mutton_raw.png",
	wield_image = "mcl_mobitems_mutton_raw.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = { food = 2, eatable = 2, smoker_cookable = 1, campfire_cookable = 1 },
	_mcl_saturation = 1.2,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:cooked_mutton", {
	description = S("Cooked Mutton"),
	_doc_items_longdesc = S("Cooked mutton is the cooked flesh from a sheep and is used as food."),
	inventory_image = "mcl_mobitems_mutton_cooked.png",
	wield_image = "mcl_mobitems_mutton_cooked.png",
	on_place = minetest.item_eat(6),
	on_secondary_use = minetest.item_eat(6),
	groups = { food = 2, eatable = 6 },
	_mcl_saturation = 9.6,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:beef", {
	description = S("Raw Beef"),
	_doc_items_longdesc = S("Raw beef is the flesh from cows and can be eaten safely. Cooking it will greatly increase its nutritional value."),
	inventory_image = "mcl_mobitems_beef_raw.png",
	wield_image = "mcl_mobitems_beef_raw.png",
	on_place = minetest.item_eat(3),
	on_secondary_use = minetest.item_eat(3),
	groups = { food = 2, eatable = 3, smoker_cookable = 1, campfire_cookable = 1 },
	_mcl_saturation = 1.8,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:cooked_beef", {
	description = S("Steak"),
	_doc_items_longdesc = S("Steak is cooked beef from cows and can be eaten."),
	inventory_image = "mcl_mobitems_beef_cooked.png",
	wield_image = "mcl_mobitems_beef_cooked.png",
	on_place = minetest.item_eat(8),
	on_secondary_use = minetest.item_eat(8),
	groups = { food = 2, eatable = 8 },
	_mcl_saturation = 12.8,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:chicken", {
	description = S("Raw Chicken"),
	_tt_help = minetest.colorize(mcl_colors.YELLOW, S("30% chance of food poisoning")),
	_doc_items_longdesc = S("Raw chicken is a food item which is not safe to consume. You can eat it to restore a few hunger points, but there's a 30% chance to suffer from food poisoning, which increases your hunger rate for a while. Cooking raw chicken will make it safe to eat and increases its nutritional value."),
	inventory_image = "mcl_mobitems_chicken_raw.png",
	wield_image = "mcl_mobitems_chicken_raw.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = { food = 2, eatable = 2, smoker_cookable = 1, campfire_cookable = 1 },
	_mcl_saturation = 1.2,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:cooked_chicken", {
	description = S("Cooked Chicken"),
	_doc_items_longdesc = S("A cooked chicken is a healthy food item which can be eaten."),
	inventory_image = "mcl_mobitems_chicken_cooked.png",
	wield_image = "mcl_mobitems_chicken_cooked.png",
	on_place = minetest.item_eat(6),
	on_secondary_use = minetest.item_eat(6),
	groups = { food = 2, eatable = 6 },
	_mcl_saturation = 7.2,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:porkchop", {
	description = S("Raw Porkchop"),
	_doc_items_longdesc = S("A raw porkchop is the flesh from a pig and can be eaten safely. Cooking it will greatly increase its nutritional value."),
	inventory_image = "mcl_mobitems_porkchop_raw.png",
	wield_image = "mcl_mobitems_porkchop_raw.png",
	on_place = minetest.item_eat(3),
	on_secondary_use = minetest.item_eat(3),
	groups = { food = 2, eatable = 3, smoker_cookable = 1, campfire_cookable = 1 },
	_mcl_saturation = 1.8,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:cooked_porkchop", {
	description = S("Cooked Porkchop"),
	_doc_items_longdesc = S("Cooked porkchop is the cooked flesh of a pig and is used as food."),
	inventory_image = "mcl_mobitems_porkchop_cooked.png",
	wield_image = "mcl_mobitems_porkchop_cooked.png",
	on_place = minetest.item_eat(8),
	on_secondary_use = minetest.item_eat(8),
	groups = { food = 2, eatable = 8 },
	_mcl_saturation = 12.8,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:rabbit", {
	description = S("Raw Rabbit"),
	_doc_items_longdesc = S("Raw rabbit is a food item from a dead rabbit. It can be eaten safely. Cooking it will increase its nutritional value."),
	inventory_image = "mcl_mobitems_rabbit_raw.png",
	wield_image = "mcl_mobitems_rabbit_raw.png",
	on_place = minetest.item_eat(3),
	on_secondary_use = minetest.item_eat(3),
	groups = { food = 2, eatable = 3, smoker_cookable = 1, campfire_cookable = 1 },
	_mcl_saturation = 1.8,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:cooked_rabbit", {
	description = S("Cooked Rabbit"),
	_doc_items_longdesc = S("This is a food item which can be eaten."),
	inventory_image = "mcl_mobitems_rabbit_cooked.png",
	wield_image = "mcl_mobitems_rabbit_cooked.png",
	on_place = minetest.item_eat(5),
	on_secondary_use = minetest.item_eat(5),
	groups = { food = 2, eatable = 5 },
	_mcl_saturation = 6.0,
	stack_max = 64,
})

local function drink_milk_delayed(itemstack, player, pointed_thing)
	if pointed_thing.type == "node" then
		local node = minetest.get_node(pointed_thing.under)
		if player and not player:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, player, itemstack) or itemstack
			end
		end
	elseif pointed_thing.type == "object" then
		return itemstack
	end

	local function drink_milk(itemstack, player, pointed_thing)
		-- Check if we were allowed to drink this (eat delay check)
		if mcl_hunger.get_active() and (
			player:get_inventory():get_stack("main", player:get_wield_index(), itemstack) == "mcl_mobitems:milk_bucket" or
			minetest.is_creative_enabled(player:get_player_name())
		) then
			mcl_hunger.stop_poison(player)
		end
		mcl_potions._reset_effects(player)
		mcl_weather.skycolor.update_player_sky_color(player)
	end

	-- Wrapper for handling mcl_hunger delayed eating
	local name = player:get_player_name()
	local hunger_internal = mcl_hunger.eat_internal[name]
	hunger_internal._custom_itemstack = itemstack -- Used as comparison to make sure the custom wrapper executes only when the same item is eaten
	hunger_internal._custom_var = {
		itemstack = itemstack,
		player = player,
		pointed_thing = pointed_thing,
	}
	hunger_internal._custom_func = drink_milk
	hunger_internal._custom_wrapper = function(name)
		local hunger_internal2 = mcl_hunger.eat_internal[name]
		hunger_internal2._custom_func(
			hunger_internal2._custom_var.itemstack,
			hunger_internal2._custom_var.player,
			hunger_internal2._custom_var.pointed_thing
		)
	end

	minetest.do_item_eat(0, "mcl_buckets:bucket_empty", itemstack, player, pointed_thing)
end

minetest.register_craftitem("mcl_mobitems:milk_bucket", {
	description = S("Milk"),
	_tt_help = minetest.colorize(mcl_colors.GREEN, S("Removes all status effects")),
	_doc_items_longdesc = S("Milk is very refreshing and can be obtained by using a bucket on a cow. Drinking it will remove all status effects, but restores no hunger points."),
	_doc_items_usagehelp = S("Use the placement key to drink the milk."),
	inventory_image = "mcl_mobitems_bucket_milk.png",
	wield_image = "mcl_mobitems_bucket_milk.png",
	on_place = drink_milk_delayed,
	on_secondary_use = drink_milk_delayed,
	stack_max = 1,
	groups = { food = 3, can_eat_when_full = 1 },
})

minetest.register_craftitem("mcl_mobitems:spider_eye", {
	description = S("Spider Eye"),
	_tt_help = minetest.colorize(mcl_colors.YELLOW, S("Poisonous")),
	_doc_items_longdesc = S("Spider eyes are used mainly in crafting. If you're really desperate, you can eat a spider eye, but it will poison you briefly."),
	inventory_image = "mcl_mobitems_spider_eye.png",
	wield_image = "mcl_mobitems_spider_eye.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = { food = 2, eatable = 2, brewitem = 1 },
	_mcl_saturation = 3.2,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:bone", {
	description = S("Bone"),
	_doc_items_longdesc = S("Bones can be used to tame wolves so they will protect you. They are also useful as a crafting ingredient."),
	_doc_items_usagehelp = S("Wield the bone near wolves to attract them. Use the “Place” key on the wolf to give it a bone and tame it. You can then give commands to the tamed wolf by using the “Place” key on it."),
	inventory_image = "mcl_mobitems_bone.png",
	stack_max = 64,
	groups = { craftitem=1 },
	_mcl_toollike_wield = true,
})

minetest.register_craftitem("mcl_mobitems:ink_sac", {
	description = S("Squid Ink Sac"),
	_doc_items_longdesc = S("This item is dropped by dead squids. Squid ink can be used to as an ingredient to craft book and quill or black dye."),
	inventory_image = "mcl_mobitems_ink_sac.png",
	stack_max = 64,
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_mobitems:string",{
	description = S("String"),
	_doc_items_longdesc = S("Strings are used in crafting."),
	inventory_image = "mcl_mobitems_string.png",
	stack_max = 64,
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_mobitems:spectre_membrane",{
	description = S("Spectre Membrane"),
	_doc_items_longdesc = S("This is a crafting component dropped from dead spectres."),
	inventory_image = "vl_mobitems_spectre_membrane.png",
	groups = { craftitem = 1, brewitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:shiny_ice_crystal",{
	description = S("Shiny Ice Crystal"),
	_doc_items_longdesc = S("This item is mainly used for crafting."),
	inventory_image = "vl_mobitems_ice_crystal.png",
	groups = { craftitem = 1, brewitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:aery_charge",{
	description = S("Aery Charge"),
	_doc_items_longdesc = S("This item is mainly used for crafting."), -- TODO shoot?
	inventory_image = "vl_mobitems_aery_charge.png",
	groups = { craftitem = 1, brewitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:crystalline_drop",{
	description = S("Crystalline Drop"),
	_doc_items_longdesc = S("This item is mainly used for crafting."), -- TODO other uses?
	inventory_image = "vl_mobitems_crystalline_drop.png",
	groups = { craftitem = 1, brewitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:earthen_ash",{
	description = S("Earthen Ash"),
	_doc_items_longdesc = S("This item is mainly used for crafting."), -- TODO other uses?
	inventory_image = "vl_mobitems_earthen_ash.png",
	groups = { craftitem = 1, brewitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:flaming_rod", {
	description = S("Flaming Rod"),
	_doc_items_longdesc = S("This is a crafting component dropped from dead fire elementals."),
	wield_image = "vl_mobitems_flaming_rod.png",
	inventory_image = "vl_mobitems_flaming_rod.png",
	groups = { craftitem = 1 },
	stack_max = 64,
})
core.register_alias("mcl_mobitems:blaze_rod", "mcl_mobitems:flaming_rod")

minetest.register_craftitem("mcl_mobitems:flaming_powder", {
	description = S("Flaming Powder"),
	_doc_items_longdesc = S("This item is mainly used for crafting."),
	wield_image = "vl_mobitems_flaming_powder.png",
	inventory_image = "vl_mobitems_flaming_powder.png",
	groups = { craftitem = 1, brewitem = 1 },
	stack_max = 64,
})
core.register_alias("mcl_mobitems:blaze_powder", "mcl_mobitems:flaming_powder")

minetest.register_craftitem("mcl_mobitems:magma_cream", {
	description = S("Magma Cream"),
	_doc_items_longdesc = S("Magma cream is a crafting component."),
	wield_image = "mcl_mobitems_magma_cream.png",
	inventory_image = "mcl_mobitems_magma_cream.png",
	groups = { craftitem = 1, brewitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:ghast_tear", {
	description = S("Ghast Tear"),
	_doc_items_longdesc = S("Place this item in an item frame as decoration."),
	wield_image = "mcl_mobitems_ghast_tear.png",
	inventory_image = "mcl_mobitems_ghast_tear.png",
	groups = { brewitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:nether_star", {
	description = S("Nether Star"),
	_doc_items_longdesc = S("A nether star is dropped when the Wither dies. Place it in an item frame to show the world how hardcore you are! Or just as decoration."),
	wield_image = "mcl_mobitems_nether_star.png",
	inventory_image = "mcl_mobitems_nether_star.png",
	groups = { craftitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:leather", {
	description = S("Leather"),
	_doc_items_longdesc = S("Leather is a versatile crafting component."),
	wield_image = "mcl_mobitems_leather.png",
	inventory_image = "mcl_mobitems_leather.png",
	groups = { craftitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:feather", {
	description = S("Feather"),
	_doc_items_longdesc = S("Feathers are used in crafting and are dropped from chickens."),
	wield_image = "mcl_mobitems_feather.png",
	inventory_image = "mcl_mobitems_feather.png",
	groups = { craftitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:leather_piece", {
	description = S("Leather Piece"),
	_doc_items_longdesc = S("Leather piece is a smaller piece of leather."),
	wield_image = "mcl_mobitems_leather_piece.png",
	inventory_image = "mcl_mobitems_leather_piece.png",
	groups = { craftitem = 1 },
	stack_max = 64,
})
core.register_alias("mcl_mobitems:rabbit_hide", "mcl_mobitems:leather_piece")

minetest.register_craftitem("mcl_mobitems:rabbit_foot", {
	description = S("Rabbit's Foot"),
	_doc_items_longdesc = S("Must be your lucky day! Place this item in an item frame for decoration."),
	wield_image = "mcl_mobitems_rabbit_foot.png",
	inventory_image = "mcl_mobitems_rabbit_foot.png",
	groups = { brewitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:saddle", {
	description = S("Saddle"),
	_tt_help = S("Can be placed on animals to ride them"),
	_doc_items_longdesc = S("Saddles can be put on some animals in order to mount them."),
	_doc_items_usagehelp = S("Use the placement key with the saddle in your hand to try to put on the saddle. Saddles fit on horses, mules, donkeys and pigs. Horses, mules and donkeys need to be tamed first, otherwise they'll reject the saddle. Saddled animals can be mounted by using the placement key on them again."),
	wield_image = "mcl_mobitems_saddle.png",
	inventory_image = "mcl_mobitems_saddle.png",
	groups = { transport = 1 },
	stack_max = 1,
})

minetest.register_craftitem("mcl_mobitems:rabbit_stew", {
	description = S("Rabbit Stew"),
	_doc_items_longdesc = S("Rabbit stew is a very nutricious food item."),
	wield_image = "mcl_mobitems_rabbit_stew.png",
	inventory_image = "mcl_mobitems_rabbit_stew.png",
	stack_max = 1,
	on_place = minetest.item_eat(10, "mcl_core:bowl"),
	on_secondary_use = minetest.item_eat(10, "mcl_core:bowl"),
	groups = { food = 2, eatable = 10 },
	_mcl_saturation = 12.0,
})

minetest.register_craftitem("mcl_mobitems:shulker_shell", {
	description = S("Shulker Shell"),
	_doc_items_longdesc = S("Shulker shells are used in crafting. They are dropped from dead shulkers."),
	inventory_image = "mcl_mobitems_shulker_shell.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_mobitems:slimeball", {
	description = S("Slimeball"),
	_doc_items_longdesc = S("Slimeballs are used in crafting. They are dropped from slimes."),
	inventory_image = "mcl_mobitems_slimeball.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_mobitems:gunpowder", {
	description = S("Gunpowder"),
	_doc_items_longdesc = doc.sub.items.temp.craftitem,
	inventory_image = "default_gunpowder.png",
	stack_max = 64,
	groups = { craftitem=1, brewitem = 1 },
})

minetest.register_tool("mcl_mobitems:carrot_on_a_stick", {
	description = S("Carrot on a Stick"),
	_tt_help = S("Lets you ride a saddled pig"),
	_doc_items_longdesc = S("A carrot on a stick can be used on saddled pigs to ride them."),
	_doc_items_usagehelp = S("Place it on a saddled pig to mount it. You can now ride the pig like a horse. Pigs will also walk towards you when you just wield the carrot on a stick."),
	wield_image = "mcl_mobitems_carrot_on_a_stick.png^[transformFY^[transformR90",
	inventory_image = "mcl_mobitems_carrot_on_a_stick.png",
	groups = { transport = 1 },
	_mcl_toollike_wield = true,
})

minetest.register_tool("mcl_mobitems:warped_fungus_on_a_stick", {
	description = S("Warped fungus on a Stick"),
	_tt_help = S("Lets you ride a strider"),
	_doc_items_longdesc = S("A warped fungus on a stick can be used on saddled striders to ride them."),
	_doc_items_usagehelp = S("Place it on a saddled strider to mount it. You can now ride the strider like a horse. Striders will also walk towards you when you just wield the fungus on a stick."),
	wield_image = "mcl_mobitems_warped_fungus_on_a_stick.png^[transformFY^[transformR90",
	inventory_image = "mcl_mobitems_warped_fungus_on_a_stick.png",
	groups = { transport = 1 },
	_mcl_toollike_wield = true,
})

minetest.register_craftitem("mcl_mobitems:nautilus_shell", {
	description = S("Nautilus Shell"),
	_tt_help = S("Used to craft a conduit"),
	_doc_items_longdesc = S("The Nautilus Shell is used to craft a conduit. They can be obtained by fishing or killing a drowned that is wielding a shell."),
	inventory_image = "mcl_mobitems_nautilus_shell.png",
	groups = { craftitem=1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:heart_of_the_sea", {
	description = S("Heart of the Sea"),
	_tt_help = S("Used to craft a conduit"),
	_doc_items_longdesc = S("The Heart of the Sea is used to craft a conduit. They can be obtained by finding them in a buried treasure chest."),
	inventory_image = "mcl_mobitems_heart_of_the_sea.png",
	groups = { craftitem=1 },
	stack_max = 64,
})


local horse_armor_use = S("Place it on a horse to put on the horse armor. Donkeys and mules can't wear horse armor.")
minetest.register_craftitem("mcl_mobitems:leather_horse_armor", {
	description = S("Leather Horse Armor"),
	_doc_items_longdesc = S("Leather horse armor can be worn by horses to increase their protection from harm a little."),
	_doc_items_usagehelp = horse_armor_use,
	inventory_image = "mcl_mobitems_leather_horse_armor.png",
	_horse_overlay_image = "mcl_mobitems_horse_armor_leather.png",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_leather",
	},
	stack_max = 1,
	groups = { horse_armor = 88 },
})


minetest.register_craftitem("mcl_mobitems:iron_horse_armor", {
	description = S("Iron Horse Armor"),
	_doc_items_longdesc = S("Iron horse armor can be worn by horses to increase their protection from harm a bit."),
	_doc_items_usagehelp = horse_armor_use,
	inventory_image = "mcl_mobitems_iron_horse_armor.png",
	_horse_overlay_image = "mcl_mobitems_horse_armor_iron.png",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
	},
	stack_max = 1,
	groups = { horse_armor = 80 },
})


minetest.register_craftitem("mcl_mobitems:gold_horse_armor", {
	description = S("Golden Horse Armor"),
	_doc_items_longdesc = S("Golden horse armor can be worn by horses to increase their protection from harm."),
	_doc_items_usagehelp = horse_armor_use,
	inventory_image = "mcl_mobitems_gold_horse_armor.png",
	_horse_overlay_image = "mcl_mobitems_horse_armor_gold.png",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_iron",
	},
	stack_max = 1,
	groups = { horse_armor = 72 },
})

minetest.register_craftitem("mcl_mobitems:diamond_horse_armor", {
	description = S("Diamond Horse Armor"),
	_doc_items_longdesc = S("Diamond horse armor can be worn by horses to greatly increase their protection from harm."),
	_doc_items_usagehelp = horse_armor_use,
	inventory_image = "mcl_mobitems_diamond_horse_armor.png",
	_horse_overlay_image = "mcl_mobitems_horse_armor_diamond.png",
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_diamond",
	},
	stack_max = 1,
	groups = { horse_armor = 56 },
})

minetest.register_alias("mobs_mc:iron_horse_armor", "mcl_mobitems:iron_horse_armor")
minetest.register_alias("mobs_mc:gold_horse_armor", "mcl_mobitems:gold_horse_armor")
minetest.register_alias("mobs_mc:diamond_horse_armor", "mcl_mobitems:diamond_horse_armor")

minetest.register_craftitem("mcl_mobitems:glow_ink_sac", {
	description = S("Glow Ink Sac"),
	_doc_items_longdesc = S("Use it to craft the Glow Item Frame."),
	_doc_items_usagehelp = S("Use the Glow Ink Sac and the normal Item Frame to craft the Glow Item Frame."),
	inventory_image = "mcl_mobitems_glow_ink_sac.png",
	groups = { craftitem = 1 },
})


-----------
-- Crafting
-----------

minetest.register_craft({
	output = "mcl_mobitems:leather",
	recipe = {
		{ "mcl_mobitems:leather_piece", "mcl_mobitems:leather_piece" },
		{ "mcl_mobitems:leather_piece", "mcl_mobitems:leather_piece" },
	}
})

core.register_craft({
	output = "mcl_mobitems:leather_piece 4",
	recipe = {{"mcl_mobitems:leather"}},
})

minetest.register_craft({
	output = "mcl_mobitems:flaming_powder 2",
	recipe = {{"mcl_mobitems:flaming_rod"}},
})

minetest.register_craft({
	output = "mcl_mobitems:rabbit_stew",
	recipe = {
		{ "", "mcl_mobitems:cooked_rabbit", "", },
		{ "group:mushroom", "mcl_farming:potato_item_baked", "mcl_farming:carrot_item", },
		{ "", "mcl_core:bowl", "", },
	},
})

minetest.register_craft({
	output = "mcl_mobitems:rabbit_stew",
	recipe = {
		{ "", "mcl_mobitems:cooked_rabbit", "", },
		{ "mcl_farming:carrot_item", "mcl_farming:potato_item_baked", "group:mushroom", },
		{ "", "mcl_core:bowl", "", },
	},
})

minetest.register_craft({
	output = "mcl_mobitems:carrot_on_a_stick",
	recipe = {
		{ "mcl_fishing:fishing_rod", "", },
		{ "", "mcl_farming:carrot_item" },
	},
})

minetest.register_craft({
	output = "mcl_mobitems:carrot_on_a_stick",
	recipe = {
		{ "", "mcl_fishing:fishing_rod", },
		{ "mcl_farming:carrot_item", "" },
	},
})

minetest.register_craft({
	output = "mcl_mobitems:warped_fungus_on_a_stick",
	recipe = {
		{ "mcl_fishing:fishing_rod", "", },
		{ "", "mcl_crimson:warped_fungus" },
	},
})

minetest.register_craft({
	output = "mcl_mobitems:warped_fungus_on_a_stick",
	recipe = {
		{ "","mcl_fishing:fishing_rod", },
		{ "mcl_crimson:warped_fungus", "" },
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_mobitems:magma_cream",
	recipe = {"mcl_mobitems:flaming_powder", "mcl_mobitems:slimeball"},
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_mobitems:cooked_mutton",
	recipe = "mcl_mobitems:mutton",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_mobitems:cooked_rabbit",
	recipe = "mcl_mobitems:rabbit",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_mobitems:cooked_chicken",
	recipe = "mcl_mobitems:chicken",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_mobitems:cooked_beef",
	recipe = "mcl_mobitems:beef",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_mobitems:cooked_porkchop",
	recipe = "mcl_mobitems:porkchop",
	cooktime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_mobitems:flaming_rod",
	burntime = 120,
})

minetest.register_craft({
	output = "mcl_mobitems:slimeball 9",
	recipe = {{"mcl_core:slimeblock"}},
})

minetest.register_craft({
	output = "mcl_core:slimeblock",
	recipe = {{"mcl_mobitems:slimeball","mcl_mobitems:slimeball","mcl_mobitems:slimeball",},
		{"mcl_mobitems:slimeball","mcl_mobitems:slimeball","mcl_mobitems:slimeball",},
		{"mcl_mobitems:slimeball","mcl_mobitems:slimeball","mcl_mobitems:slimeball",}},
})

minetest.register_craft({
	output = "mcl_mobitems:leather_horse_armor",
	recipe = {{"mcl_mobitems:leather","","mcl_mobitems:leather",},
		{"mcl_mobitems:leather","mcl_mobitems:leather","mcl_mobitems:leather",},
		{"mcl_mobitems:leather","","mcl_mobitems:leather",}},
})

minetest.register_on_item_eat(function (hp_change, replace_with_item, itemstack, user, pointed_thing)	-- poisoning with spider eye
	if itemstack:get_name() == "mcl_mobitems:spider_eye" then
		mcl_potions.give_effect_by_level("poison", user, 1, 4)
	end
end)
