-- TODO: Add special status effects for raw flesh

minetest.register_craftitem("mcl_mobitems:rotten_flesh", {
	description = "Rotten Flesh",
	_doc_items_longdesc = "Yuck! This piece of flesh clearly has seen better days. If you're really desperate, you can eat it to restore a few hunger points, but there's a 80% chance it causes food poisoning, which increases your hunger for a while.",
	inventory_image = "mcl_mobitems_rotten_flesh.png",
	wield_image = "mcl_mobitems_rotten_flesh.png",
	on_place = minetest.item_eat(4),
	on_secondary_use = minetest.item_eat(4),
	groups = { food = 2, eatable = 4 },
	_mcl_saturation = 0.8,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:mutton", {
	description = "Raw Mutton",
	_doc_items_longdesc = "Raw mutton is the flesh from a sheep and can be eaten safely. Cooking it will greatly increase its nutritional value.",
	inventory_image = "mcl_mobitems_mutton_raw.png",
	wield_image = "mcl_mobitems_mutton_raw.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = { food = 2, eatable = 2 },
	_mcl_saturation = 1.2,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:cooked_mutton", {
	description = "Cooked Mutton",
	_doc_items_longdesc = "Cooked mutton is the cooked flesh from a sheep and is used as food.",
	inventory_image = "mcl_mobitems_mutton_cooked.png",
	wield_image = "mcl_mobitems_mutton_cooked.png",
	on_place = minetest.item_eat(6),
	on_secondary_use = minetest.item_eat(6),
	groups = { food = 2, eatable = 6 },
	_mcl_saturation = 9.6,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:beef", {
	description = "Raw Beef",
	_doc_items_longdesc = "Raw beef is the flesh from cows and can be eaten safely. Cooking it will greatly increase its nutritional value.",
	inventory_image = "mcl_mobitems_beef_raw.png",
	wield_image = "mcl_mobitems_beef_raw.png",
	on_place = minetest.item_eat(3),
	on_secondary_use = minetest.item_eat(3),
	groups = { food = 2, eatable = 3 },
	_mcl_saturation = 1.8,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:cooked_beef", {
	description = "Steak",
	_doc_items_longdesc = "Steak is cooked beef from cows and can be eaten.",
	inventory_image = "mcl_mobitems_beef_cooked.png",
	wield_image = "mcl_mobitems_beef_cooked.png",
	on_place = minetest.item_eat(8),
	on_secondary_use = minetest.item_eat(8),
	groups = { food = 2, eatable = 8 },
	_mcl_saturation = 12.8,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:chicken", {
	description = "Raw Chicken",
	_doc_items_longdesc = "Raw chicken is a food item which is not safe to consume. You can eat it to restore a few hunger points, but there's a 30% chance to suffer from food poisoning, which increases your hunger rate for a while. Cooking raw chicken will make it safe to eat and increases its nutritional value.",
	inventory_image = "mcl_mobitems_chicken_raw.png",
	wield_image = "mcl_mobitems_chicken_raw.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = { food = 2, eatable = 2 },
	_mcl_saturation = 1.2,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:cooked_chicken", {
	description = "Cooked Chicken",
	_doc_items_longdesc = "A cooked chicken is a healthy food item which can be eaten.",
	inventory_image = "mcl_mobitems_chicken_cooked.png",
	wield_image = "mcl_mobitems_chicken_cooked.png",
	on_place = minetest.item_eat(6),
	on_secondary_use = minetest.item_eat(6),
	groups = { food = 2, eatable = 6 },
	_mcl_saturation = 7.2,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:porkchop", {
	description = "Raw Porkchop",
	_doc_items_longdesc = "A raw porkchop is the flesh from a pig and can be eaten safely. Cooking it will greatly increase its nutritional value.",
	inventory_image = "mcl_mobitems_porkchop_raw.png",
	wield_image = "mcl_mobitems_porkchop_raw.png",
	on_place = minetest.item_eat(3),
	on_secondary_use = minetest.item_eat(3),
	groups = { food = 2, eatable = 3 },
	_mcl_saturation = 1.8,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:cooked_porkchop", {
	description = "Cooked Porkchop",
	_doc_items_longdesc = "Cooked porkchop is the cooked flesh of a pig and is used as food.",
	inventory_image = "mcl_mobitems_porkchop_cooked.png",
	wield_image = "mcl_mobitems_porkchop_cooked.png",
	on_place = minetest.item_eat(8),
	on_secondary_use = minetest.item_eat(8),
	groups = { food = 2, eatable = 8 },
	_mcl_saturation = 12.8,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:rabbit", {
	description = "Raw Rabbit",
	_doc_items_longdesc = "Raw rabbit is a food item from a dead rabbit. It can be eaten safely. Cooking it will increase its nutritional value.",
	inventory_image = "mcl_mobitems_rabbit_raw.png",
	wield_image = "mcl_mobitems_rabbit_raw.png",
	on_place = minetest.item_eat(3),
	on_secondary_use = minetest.item_eat(3),
	groups = { food = 2, eatable = 3 },
	_mcl_saturation = 1.8,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:cooked_rabbit", {
	description = "Cooked Rabbit",
	_doc_items_longdesc = "This is a food item which can be eaten.",
	inventory_image = "mcl_mobitems_rabbit_cooked.png",
	wield_image = "mcl_mobitems_rabbit_cooked.png",
	on_place = minetest.item_eat(5),
	on_secondary_use = minetest.item_eat(5),
	groups = { food = 2, eatable = 5 },
	_mcl_saturation = 6.0,
	stack_max = 64,
})

local drink_milk = function(itemstack, player, pointed_thing)
	local bucket = minetest.do_item_eat(0, "bucket:bucket_empty", itemstack, player, pointed_thing)
	-- Check if we were allowed to drink this (eat delay check)
	if bucket:get_name() ~= "mcl_mobitems:milk_bucket" then
		mcl_hunger.stop_poison(player)
	end
	return bucket
end

-- TODO: Clear *all* status effects
minetest.register_craftitem("mcl_mobitems:milk_bucket", {
	description = "Milk",
	_doc_items_longdesc = "Milk is very refreshing and can be obtained by using a bucket on a cow. Drinking it will cure all forms of poisoning (in later versions: all status effects), but restores no hunger points.",
	_doc_items_usagehelp = "Rightclick to drink the milk.",
	inventory_image = "mcl_mobitems_bucket_milk.png",
	wield_image = "mcl_mobitems_bucket_milk.png",
	-- Clear poisoning when used
	on_place = drink_milk,
	on_secondary_use = drink_milk,
	stack_max = 1,
	groups = { food = 3, can_eat_when_full = 1 },
})

minetest.register_craftitem("mcl_mobitems:spider_eye", {
	description = "Spider Eye",
	_doc_items_longdesc = "Spider eyes are used mainly in crafting and brewing. If you're really desperate, you can eat a spider eye, but it will poison you briefly.",
	inventory_image = "mcl_mobitems_spider_eye.png",
	wield_image = "mcl_mobitems_spider_eye.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = { food = 2, eatable = 2 },
	_mcl_saturation = 3.2,
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:bone", {
	description = "Bone",
	_doc_items_longdesc = "Bones can be used to tame wolves so they will protect you. They are also useful as a crafting ingredient.",
	_doc_items_usagehelp = "Hold the bone in your hand near wolves to attract them. Rightclick the wolf to give it a bone and tame it. You can then give commands to the tamed wolf by rightclicking it.",
	inventory_image = "mcl_mobitems_bone.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_craftitem("mcl_mobitems:string",{
	description = "String",
	_doc_items_longdesc = "Strings are used in crafting.",
	inventory_image = "mcl_mobitems_string.png",
	stack_max = 64,
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_mobitems:blaze_rod", {
	description = "Blaze Rod",
	_doc_items_longdesc = "This is a crafting component dropped from dead blazes.",
	wield_image = "mcl_mobitems_blaze_rod.png",
	inventory_image = "mcl_mobitems_blaze_rod.png",
	groups = { craftitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:blaze_powder", {
	description = "Blaze Powder",
	_doc_items_longdesc = "This item is mainly used for brewing potions and crafting.",
	wield_image = "mcl_mobitems_blaze_powder.png",
	inventory_image = "mcl_mobitems_blaze_powder.png",
	groups = { brewitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:magma_cream", {
	description = "Magma Cream",
	_doc_items_longdesc = "Magma cream is a crafting component.",
	wield_image = "mcl_mobitems_magma_cream.png",
	inventory_image = "mcl_mobitems_magma_cream.png",
	groups = { brewitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:ghast_tear", {
	description = "Ghast Tear",
	_doc_items_longdesc = "A ghast tear is an item used in potion brewing. It is dropped from dead ghasts.",
	wield_image = "mcl_mobitems_ghast_tear.png",
	inventory_image = "mcl_mobitems_ghast_tear.png",
	groups = { brewitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:nether_star", {
	description = "Nether Star",
	_doc_items_longdesc = "A nether star is a crafting component. It is dropped from the Wither.",
	wield_image = "mcl_mobitems_nether_star.png",
	inventory_image = "mcl_mobitems_nether_star.png",
	groups = { craftitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:leather", {
	description = "Leather",
	_doc_items_longdesc = "Leather is a versatile crafting component.",
	wield_image = "mcl_mobitems_leather.png",
	inventory_image = "mcl_mobitems_leather.png",
	groups = { craftitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:feather", {
	description = "Feather",
	_doc_items_longdesc = "Feathers are used in crafting and are dropped from chickens.",
	wield_image = "mcl_mobitems_feather.png",
	inventory_image = "mcl_mobitems_feather.png",
	groups = { craftitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:rabbit_hide", {
	description = "Rabbit Hide",
	_doc_items_longdesc = "Rabbit hide is used to create leather.",
	wield_image = "mcl_mobitems_rabbit_hide.png",
	inventory_image = "mcl_mobitems_rabbit_hide.png",
	groups = { craftitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:rabbit_foot", {
	description = "Rabbit's Foot",
	_doc_items_longdesc = "This item is used in brewing.",
	wield_image = "mcl_mobitems_rabbit_foot.png",
	inventory_image = "mcl_mobitems_rabbit_foot.png",
	groups = { brewitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_mobitems:saddle", {
	description = "Saddle",
	_doc_items_longdesc = "Saddles can be put on horses and pigs in order to mount them.",
	_doc_items_usagehelp = "Rightclick a horse or pig with a saddle to put on the saddle. You can now mount the animal by rightclicking it again.",
	wield_image = "mcl_mobitems_saddle.png",
	inventory_image = "mcl_mobitems_saddle.png",
	stack_max = 1,
})

minetest.register_craftitem("mcl_mobitems:rabbit_stew", {
	description = "Rabbit Stew",
	_doc_items_longdesc = "Rabbit stew is a very nutricious food item.",
	wield_image = "mcl_mobitems_rabbit_stew.png",
	inventory_image = "mcl_mobitems_rabbit_stew.png",
	stack_max = 1,
	on_place = minetest.item_eat(10, "mcl_core:bowl"),
	on_secondary_use = minetest.item_eat(10, "mcl_core:bowl"),
	groups = { food = 3, eatable = 10 },
	_mcl_saturation = 12.0,
})

minetest.register_craftitem("mcl_mobitems:shulker_shell", {
	description = "Shulker Shell",
	_doc_items_longdesc = "Shulker shells are used in crafting. They are dropped from dead shulkers.",
	inventory_image = "mcl_mobitems_shulker_shell.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_mobitems:slimeball", {
	description = "Slimeball",
	_doc_items_longdesc = "Slimeballs are used in crafting. They are dropped from slimes.",
	inventory_image = "mcl_mobitems_slimeball.png",
	groups = { craftitem = 1 },
})

minetest.register_craftitem("mcl_mobitems:gunpowder", {
	description = "Gunpowder",
	_doc_items_longdesc = doc.sub.items.temp.craftitem,
	inventory_image = "default_gunpowder.png",
	stack_max = 64,
	groups = { craftitem=1 },
})

minetest.register_tool("mcl_mobitems:carrot_on_a_stick", {
	description = "Carrot on a Stick",
	_doc_items_longdesc = "A carrot on a stick can be used on saddled pigs to ride them.",
	_doc_items_usagehelp = "Rightclick a saddled pig with the carrot on a stick to mount it. You can now ride it like a horse (TODO). Pigs will also walk towards you when you just wield the carrot on a stick.",
	wield_image = "mcl_mobitems_carrot_on_a_stick.png",
	inventory_image = "mcl_mobitems_carrot_on_a_stick.png",
	groups = { transport = 1 },
})


-----------
-- Crafting
-----------

minetest.register_craft({
	output = "mcl_mobitems:leather",
	recipe = {
		{ "mcl_mobitems:rabbit_hide", "mcl_mobitems:rabbit_hide" },
		{ "mcl_mobitems:rabbit_hide", "mcl_mobitems:rabbit_hide" },
	}
})

minetest.register_craft({
	output = "mcl_mobitems:blaze_powder 2",
	recipe = {{"mcl_mobitems:blaze_rod"}},
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
	type = "shapeless",
	output = "mcl_mobitems:magma_cream",
	recipe = {"mcl_mobitems:blaze_powder", "mcl_mobitems:slimeball"},
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
	recipe = "mcl_mobitems:blaze_rod",
	burntime = 120,
})

minetest.register_craft({
	output = 'mcl_mobitems:slimeball 9',
	recipe = {{"mcl_core:slimeblock"}},
})

minetest.register_craft({
	output = "mcl_core:slimeblock",
	recipe = {{"mcl_mobitems:slimeball","mcl_mobitems:slimeball","mcl_mobitems:slimeball",},
		{"mcl_mobitems:slimeball","mcl_mobitems:slimeball","mcl_mobitems:slimeball",},
		{"mcl_mobitems:slimeball","mcl_mobitems:slimeball","mcl_mobitems:slimeball",}},
})

