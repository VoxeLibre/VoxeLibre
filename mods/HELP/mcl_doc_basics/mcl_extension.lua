local S = minetest.get_translator(minetest.get_current_modname())

doc.add_entry("advanced", "creative", {
	name = S("Creative Mode"),
	data = { text =
S("Enabling Creative Mode in VoxeLibre applies the following changes:").."\n\n"..

S("• You keep the things you've placed").."\n"..
S("• Creative inventory is available to obtain most items easily").."\n"..
S("• Hand breaks all default blocks instantly").."\n"..
S("• Greatly increased hand pointing range").."\n"..
S("• Mined blocks don't drop items").."\n"..
S("• Items don't get used up").."\n"..
S("• Tools don't wear off").."\n"..
S("• You can eat food whenever you want").."\n"..
S("• You can always use the minimap (including radar mode)").."\n\n"..

S("Damage is not affected by Creative Mode, it needs to be disabled separately.")
}})

doc.add_entry("basics", "mobs", {
	name = S("Mobs"),
	data = { text =
S("Mobs are the living beings in the world. This includes animals and monsters.").."\n\n"..

S("Mobs appear randomly throughout the world. This is called “spawning”. Each mob kind appears on particular block types at a given light level. The height also plays a role. Peaceful mobs tend to spawn at daylight while hostile ones prefer darkness. Most mobs can spawn on any solid block but some mobs only spawn on particular blocks (like grass blocks).").."\n\n"..

S("Like players, mobs have hit points and sometimes armor points, too (which means you need better weapons to deal any damage at all). Also like players, hostile mobs can attack directly or at a distance. Mobs may drop random items after they die.").."\n\n"..

S("Most animals roam the world aimlessly while most hostile mobs hunt players. Animals can be fed, tamed and bred.")
}})

doc.add_entry("basics", "animals", {
	name = S("Animals"),
	data = { text =
S("Animals are peaceful beings which roam the world aimlessly. You can feed, tame and breed them.").."\n\n"..

S("Feeding:").."\n"..
S("Each animal has its own taste for food and doesn't just accept any food. To feed, hold an item in your hand and right-click the animal.").."\n"..
S("Animals are attracted to the food they like and follow you as long you hold the food item in hand.").."\n"..
S("Feeding an animal has three uses: Taming, healing and breeding.").."\n"..
S("Feeding heals animals instantly, depending on the quality of the food item.").."\n\n"..

S("Taming:").."\n"..
S("A few animals can be tamed. You can generally do more things with tamed animals and use other items on them. For example, tame horses can be saddled and tame wolves fight on your side.").."\n\n"..

S("Breeding:").."\n"..
S("When you have fed an animal up to its maximum health, then feed it again, you will activate “Love Mode” and many hearts appear around the animal.").."\n"..
S("Two animals of the same species will start to breed if they are in Love Mode and close to each other. Soon a baby animal will pop up.").."\n\n"..

S("Baby animals:").."\n"..
S("Baby animals are just like their adult counterparts, but they can't be tamed or bred and don't drop anything when they die. They grow to adults after a short time. When fed, they grow to adults faster.")

}})

doc.add_entry("basics", "hunger", {
	name = S("Hunger"),
	data = { text =
S("Hunger affects your health and your ability to sprint. Hunger is not in effect when damage is disabled.").."\n\n"..

S("Core hunger rules:").."\n\n"..
S("• You start with 20/20 hunger points (more points = less hungry)").."\n"..
S("• Actions like combat, jumping, sprinting, etc. decrease hunger points").."\n"..
S("• Food restores hunger points").."\n"..
S("• If your hunger bar decreases, you're hungry").."\n"..
S("• At 18-20 hunger points, you regenerate 1 HP every 4 seconds").."\n"..
S("• At 6 hunger points or less, you can't sprint").."\n"..
S("• At 0 hunger points, you lose 1 HP every 4 seconds (down to 1 HP)").."\n"..
S("• Poisonous food decreases your health").."\n\n"..


S("Details:").."\n\n"..
S("You have 0-20 hunger points, indicated by 20 drumstick half-icons above the hotbar. You also have an invisible attribute: Saturation.").."\n"..
S("Hunger points reflect how full you are while saturation points reflect how long it takes until you're hungry again.").."\n\n"..

S("Each food item increases both your hunger level as well your saturation.").."\n"..
S("Food with a high saturation boost has the advantage that it will take longer until you get hungry again.").."\n"..
S("A few food items might induce food poisoning by chance. When you're poisoned, the health and hunger symbols turn sickly green. Food poisoning drains your health by 1 HP per second, down to 1 HP. Food poisoning also drains your saturation. Food poisoning goes away after a while or when you drink milk.").."\n\n"..

S("You start with 5 saturation points. The maximum saturation is equal to your current hunger level. So with 20 hunger points your maximum saturation is 20. What this means is that food items which restore many saturation points are more effective the more hunger points you have. This is because at low hunger levels, a lot of the saturation boost will be lost due to the low saturation cap.").."\n"..
S("If your saturation reaches 0, you're hungry and start to lose hunger points. Whenever you see the hunger bar decrease, it is a good time to eat.").."\n\n"..

S("Saturation decreases by doing things which exhaust you (highest exhaustion first):").."\n"..
S("• Regenerating 1 HP").."\n"..
S("• Suffering food poisoning").."\n"..
S("• Sprint-jumping").."\n"..
S("• Sprinting").."\n"..
S("• Attacking").."\n"..
S("• Taking damage").."\n"..
S("• Swimming").."\n"..
S("• Jumping").."\n"..
S("• Mining a block").."\n\n"..

S("Other actions, like walking, do not exhaust you.")

}})

