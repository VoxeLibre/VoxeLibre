local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function ( s ) return s end
end

-- Achievements from PC Edition

awards.register_achievement("mcl_buildWorkBench", {
	title = S("Benchmarking"),
	description = S("Craft a crafting table from 4 wooden planks."),
	icon = "crafting_workbench_front.png",
	trigger = {
		type = "craft",
		item = "crafting:workbench",
		target = 1
	}
})
awards.register_achievement("mcl_mineWood", {
	title = S("Getting Wood"),
	description = S("Punch a tree to get oak wood."),
	icon = "default_tree.png",
	trigger = {
		type = "dig",
		node = "mcl_core:tree",
		target = 1
	}
})
awards.register_achievement("mcl:buildPickaxe", {
	title = S("Time to Mine!"),
	description = S("Use a crafting table to craft a wooden pickaxe from wooden planks and sticks."),
	icon = "default_tool_woodpick.png",
	trigger = {
		type = "craft",
		item = "mcl_tools:pick_wood",
		target = 1
	}
})
awards.register_achievement("mcl:buildFurnace", {
	title = S("Hot Topic"),
	description = S("Use 8 cobblestones to craft a furnace."),
	icon = "default_furnace_front.png",
	trigger = {
		type = "craft",
		item = "mcl_furnaces:furnace",
		target = 1
	}
})
awards.register_achievement("mcl:buildHoe", {
	title = S("Time to Farm!"),
	description = S("Use a crafting table to craft a wooden hoe from wooden planks and sticks."),
	icon = "farming_tool_woodhoe.png",
	trigger = {
		type = "craft",
		item = "mcl_farming:hoe_wood",
		target = 1
	}
})
awards.register_achievement("mcl:makeBread", {
	title = S("Bake Bread"),
	description = S("Use wheat to craft a bread."),
	icon = "farming_bread.png",
	trigger = {
		type = "craft",
		item = "mcl_farming:bread",
		target = 1
	}
})
awards.register_achievement("mcl:cookFish", {
	title = S("Delicious Fish"),
	description = S("Catch a fish, cook it in the furnace and eat it."),
	icon = "mcl_fishing_fish_cooked.png",
	trigger = {
		type = "eat",
		item = "mcl_fishing:fish_cooked",
		target = 1
	}
})

awards.register_achievement("mcl:bakeCake", {
	title = S("The Lie"),
	description = S("Craft a cake using wheat, sugar, milk and an egg."),
	icon = "cake.png",
	trigger = {
		type = "craft",
		item = "mcl_cake:cake",
		target = 1
	}
})
awards.register_achievement("mcl:buildBetterPickaxe", {
	title = S("Getting an Upgrade"),
	icon = "default_tool_stonepick.png",
	trigger = {
		type = "craft",
		item = "mcl_tools:pick_stone",
		target = 1
	}
})
awards.register_achievement("mcl:buildSword", {
	title = S("Time to Strike!"),
	icon = "default_tool_woodsword.png",
	trigger = {
		type = "craft",
		item = "mcl_tools:sword_wood",
		target = 1
	}
})

awards.register_achievement("mcl:diamonds", {
	title = S("DIAMONDS!"),
	description = S("Pick up a diamond from the floor."),
	icon = "default_stone.png^default_mineral_diamond.png",
})

awards.register_achievement("mcl:bookcase", {
	title = S("Librarian"),
	icon = "default_bookshelf.png",
	trigger = {
		type = "craft",
		item = "mcl_books:bookshelf",
		target = 1
	}
})

awards.register_achievement("mcl:blazeRod", {
	title = S("Into Fire"),
	description = S("Pick up a blaze rod from the floor."),
	icon = "mcl_mobitems_blaze_rod.png",
})

-- NON-PC ACHIEVEMENTS (XBox, Pocket Edition, etc.)

awards.register_achievement("mcl:n_placeDispenser", {
	title = S("Dispense With This"),
	icon = "mcl_dispensers_dispenser_front_horizontal.png",
	trigger = {
		type = "place",
		node = "mcl_dispensers:dispenser",
		target = 1
	}
})

awards.register_achievement("mcl:n_eatPorkchop", {
	title = S("Pork Chop"),
	icon = "mcl_mobitems_porkchop_cooked.png",
	trigger = {
		type = "eat",
		item= "mcl_mobitems:cooked_porkchop",
		target = 1,
	}
})
awards.register_achievement("mcl:n_eatRabbit", {
	title = S("Rabbit Season"),
	icon = "mcl_mobitems_rabbit_cooked.png",
	trigger = {
		type = "eat",
		item= "mcl_mobitems:cooked_rabbit",
		target = 1,
	}
})
awards.register_achievement("mcl:n_eatRottenFlesh", {
	title = S("Iron Belly"),
	description = S("Get really desperate and eat rotten flesh."),
	icon = "mcl_mobitems_rotten_flesh.png",
	trigger = {
		type = "eat",
		item= "mcl_mobitems:rotten_flesh",
		target = 1,
	}
})
awards.register_achievement("mcl:n_placeFlowerpot", {
	title = S("Pot Planter"),
	icon = "mcl_flowerpots_flowerpot_inventory.png",
	trigger = {
		type = "place",
		node = "mcl_flowerpots:flower_pot",
		target = 1,
	}
})

awards.register_achievement("mcl:n_emeralds", {
	title = S("The Haggler"),
	icon = "default_emerald.png",
	trigger = {
		type = "dig",
		node = "mcl_core:stone_with_emerald",
		target = 30,
	}
})

-- NOT IN MINECRAFT

-- Replacement for “On a Rail”
awards.register_achievement("mcl:f_placeRails", {
	title = S("Railroad"),
	icon = "default_rail.png",
	trigger = {
		type = "place",
		node = "mcl_minecarts:rail",
		target = 1000,
	}
})


-- Show achievements formspec when the button was pressed
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.__mcl_achievements then
		local name = player:get_player_name()
		awards.show_to(name, name, nil, false)
	end
end)
