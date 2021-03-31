-- Settings

-- If true, activates achievements from other Minecraft editions (XBox, PS, etc.)
local non_pc_achievements = false

local S = minetest.get_translator("mcl_achievements")

-- Achievements from PC Edition

awards.register_achievement("mcl_buildWorkBench", {
	title = S("Benchmarking"),
	description = S("Craft a crafting table from 4 wooden planks."),
	icon = "crafting_workbench_front.png",
	trigger = {
		type = "craft",
		item = "mcl_crafting_table:crafting_table",
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
	-- TODO: This achievement should support all non-wood pickaxes
	description = S("Craft a stone pickaxe using sticks and cobblestone."),
	icon = "default_tool_stonepick.png",
	trigger = {
		type = "craft",
		item = "mcl_tools:pick_stone",
		target = 1
	}
})
awards.register_achievement("mcl:buildSword", {
	title = S("Time to Strike!"),
	description = S("Craft a wooden sword using wooden planks and sticks on a crafting table."),
	icon = "default_tool_woodsword.png",
	trigger = {
		type = "craft",
		item = "mcl_tools:sword_wood",
		target = 1
	}
})

awards.register_achievement("mcl:bookcase", {
	title = S("Librarian"),
	description = S("Craft a bookshelf."),
	icon = "default_bookshelf.png",
	trigger = {
		type = "craft",
		item = "mcl_books:bookshelf",
		target = 1
	}
})

-- Item pickup achievements: These are awarded when picking up a certain item.
-- The achivements are manually given in the mod mcl_item_entity.
awards.register_achievement("mcl:diamonds", {
	title = S("DIAMONDS!"),
	description = S("Pick up a diamond from the floor."),
	icon = "mcl_core_diamond_ore.png",
})
awards.register_achievement("mcl:blazeRod", {
	title = S("Into Fire"),
	description = S("Pick up a blaze rod from the floor."),
	icon = "mcl_mobitems_blaze_rod.png",
})

awards.register_achievement("mcl:killCow", {
	title = S("Cow Tipper"),
	description = S("Pick up leather from the floor.\nHint: Cows and some other animals have a chance to drop leather, when killed."),
	icon = "mcl_mobitems_leather.png",
})
awards.register_achievement("mcl:mineWood", {
	title = S("Getting Wood"),
	description = S("Pick up a wood item from the ground.\nHint: Punch a tree trunk until it pops out as an item."),
	icon = "default_tree.png",
})

-- Smelting achivements: These are awarded when picking up an item from a furnace
-- output. They are given in mcl_furnaces.
awards.register_achievement("mcl:acquireIron", {
	title = S("Aquire Hardware"),
	description = S("Take an iron ingot from a furnace's output slot.\nHint: To smelt an iron ingot, put a fuel (like coal) and iron ore into a furnace."),
	icon = "default_steel_ingot.png",
})
awards.register_achievement("mcl:cookFish", {
	title = S("Delicious Fish"),
	description = S("Take a cooked fish from a furnace.\nHint: Use a fishing rod to catch a fish and cook it in a furnace."),
	icon = "mcl_fishing_fish_cooked.png",
})

-- Other achievements triggered outside of mcl_achievements

-- Triggered in mcl_minecarts
awards.register_achievement("mcl:onARail", {
	title = S("On A Rail"),
	description = S("Travel by minecart for at least 1000 meters from your starting point in a single ride."),
	icon = "default_rail.png",
})

-- Triggered in mcl_bows
awards.register_achievement("mcl:snipeSkeleton", {
	title = S("Sniper Duel"),
	-- TODO: This achievement should be for killing, not hitting
	-- TODO: The range should be 50, not 20. Nerfed because of reduced bow range
	description = S("Hit a skeleton, wither skeleton or stray by bow and arrow from a distance of at least 20 meters."),
	icon = "mcl_bows_bow.png",
})

-- Triggered in mcl_portals
awards.register_achievement("mcl:buildNetherPortal", {
	title = S("Into the Nether"),
	description = S("Use obsidian and a fire starter to construct a Nether portal."),
	icon = "default_obsidian.png",
})

-- NON-PC ACHIEVEMENTS (XBox, Pocket Edition, etc.)

if non_pc_achievements then
	awards.register_achievement("mcl:n_placeDispenser", {
		title = S("Dispense With This"),
		description = S("Place a dispenser."),
		icon = "mcl_dispensers_dispenser_front_horizontal.png",
		trigger = {
			type = "place",
			node = "mcl_dispensers:dispenser",
			target = 1
		}
	})

	-- FIXME: Eating achievements don't work when you have exactly one of these items on hand
	awards.register_achievement("mcl:n_eatPorkchop", {
		title = S("Pork Chop"),
		description = S("Eat a cooked porkchop."),
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
		description = S("Eat a cooked rabbit."),
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
		description = S("Place a flower pot."),
		icon = "mcl_flowerpots_flowerpot_inventory.png",
		trigger = {
			type = "place",
			node = "mcl_flowerpots:flower_pot",
			target = 1,
		}
	})

	awards.register_achievement("mcl:n_emeralds", {
		title = S("The Haggler"),
		description = S("Mine emerald ore."),
		icon = "default_emerald.png",
		trigger = {
			type = "dig",
			node = "mcl_core:stone_with_emerald",
			target = 1,
		}
	})
end

-- Show achievements formspec when the button was pressed
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.__mcl_achievements then
		local name = player:get_player_name()
		awards.show_to(name, name, nil, false)
	end
end)


awards.register_achievement("mcl:stoneAge", {
	title		= S("Stone Age"),
	description	= S("Mine a stone with new pickaxe."),
	icon		= "default_cobble.png",
})
awards.register_achievement("mcl:hotStuff", {
	title		= S("Hot Stuff"),
	description	= S("Put lava in a bucket."),
	icon		= "bucket_lava.png",
})
awards.register_achievement("mcl:obsidian", {
	title		= S("Ice Bucket Challenge"),
	description	= S("Obtain an obsidian block."),
	icon		= "default_obsidian.png",
})
