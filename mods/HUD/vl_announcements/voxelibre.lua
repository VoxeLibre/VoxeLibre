local S = core.get_translator("vl_announcements")

vl_announcements.register_provider({
	id = "voxelibre",
	name = "VoxeLibre",
	icon = "voxelibre_icon.png",
	order = 0,
})

vl_announcements.register_announcement("voxelibre", {
	id = "0.92",
	version = "0.92",
	title = S("The Undaunted Release"),
	poster = "0_92-the-undaunted-screenshot.jpg",
	intro = S("Witches, scythes, offhand features, the long awaited wielded lights and other aids for undaunted adventurers."),
	features = {
		{title = S("Witch"), icon = "default_stick.png",
			description = S("Witch re-made... new dangerous enemy awaits you!")},
		{title = S("Scythes"), icon = "vl_tool_diamondscythe.png",
			description = S("Scythes speed up crop harvesting and offer new combat options, even more so with upcoming enchantments.")},
		{title = S("Wielded lights"), icon = "soul_torch_on_floor.png",
			description = S("Any light you wield can now light your way! If you experience performance issues, make sure to check out settings in the main menu and tune them (you can also disable them there).")},
		{title = S("Rod of Iron"), icon = mcl_vars.iron_rod_tex,
			description = S("The Shepherd's Rod of Iron is now available, allowing granular control of animal leading.")},
	},
	details = {
		{title = S("Changes"), entries = {
			S("Everything can now be placed in offhand, and some items (like maps or lights) have full functionality in offhand."),
			S("Per-player settings to tune music volume, inventory interaction and more to come."),
			S("Lots of new in-game music added!"),
			S("Decorative golden scarabs can be found in the desert pyramids."),
			S("Touchscreen food controls and many other mobile interactions were improved."),
		}},
		{title = S("Fixes"), entries = {
			S("Fixed numerous issues with mobs, player mechanics, boats and other things."),
			S("Fixed crashes involving bone meal and other rare crashes."),
		}},
	},
})

vl_announcements.register_announcement("voxelibre", {
	id = "0.91",
	version = "0.91",
	title = S("The Sneaky Release"),
	poster = "0_91-the-sneaky-screenshot.jpg",
	intro = S("Tridents have finally arrived, together with new enchantments, richer ambient audio, and many improvements throughout the game."),
	features = {
		{title = S("Tridents"), icon = "vl_tridents_inv.png",
			description = S("Find this powerful spear as rare structure loot and use it underwater or in the air.")},
		{title = S("New enchantments"), icon = "mcl_enchanting_book_enchanted.png",
			description = S("Swift Sneak and Impaling open up new movement and combat options.")},
		{title = S("Ambient audio"), icon = "mcl_jukebox_top.png",
			description = S("Water, lava, caves, fire, and sculk received new or improved sounds.")},
		{title = S("More equipment"), icon = "mcl_mobitems_leather_horse_armor.png",
			description = S("Leather horse armor and the decorative star are now available.")},
	},
	details = {
		{title = S("Changes"), entries = {
			S("Mob behavior, spawning, vision, activation, and drops received numerous improvements."),
			S("The HUD bars and farming systems were reworked."),
			S("Touchscreen shield controls and many other mobile interactions were improved."),
		}},
		{title = S("Fixes"), entries = {
			S("Fixed issues with crafting results, buckets, item frames, portals, and water bottles."),
			S("Fixed crashes involving combat, campfires, mobs, and projectiles."),
		}},
	},
})

vl_announcements.register_announcement("voxelibre", {
	id = "0.90",
	version = "0.90",
	title = S("The Dynamic Release"),
	poster = "0_90-the-dynamic-screenshot.jpg",
	intro = S("This release introduced live game-rule tuning, new equipment and decorations, and broad combat and gameplay rebalancing."),
	features = {
		{title = S("Dynamic settings"), icon = "screwdriver.png",
			description = S("Administrators can tune supported settings and game rules while playing.")},
		{title = S("New equipment"), icon = "vl_deepslate_tools_deepslatepick.png",
			description = S("Discover deepslate tools, craftable chainmail armor, and golden decorations.")},
		{title = S("Combat balancing"), icon = "mcl_potions_potion_bottle.png",
			description = S("Potions, stews, enchantments, mobs, and combat received extensive balancing.")},
	},
	details = {{title = S("Changes and fixes"), entries = {
		S("The creative inventory was reorganized and fire spreading became more predictable."),
		S("Fire Elementals replaced Blazes as the first member of a broader elemental mob family."),
		S("Some gameplay bugs and compatibility issues were fixed."),
	}}},
})

vl_announcements.register_announcement("voxelibre", {
	id = "0.89",
	version = "0.89",
	title = S("The On Display Release"),
	poster = "0_89-the-on-display-screenshot.jpg",
	intro = S("Maps, signs, item frames, world generation, and mob spawning all received major upgrades."),
	features = {
		{title = S("Better maps"), icon = "mcl_maps_map_filled.png",
			description = S("Maps can be zoomed out with the cartography table and look better while held.")},
		{title = S("Display improvements"), icon = "mcl_itemframes_item_frame.png",
			description = S("Signs and item frames gained new placement and display capabilities.")},
		{title = S("Sit and relax"), icon = "mcl_core_planks_big_oak.png",
			description = S("Players can sit on supported blocks, or sit and lie down using commands.")},
	},
	details = {{title = S("Changes and fixes"), entries = {
		S("Structure generation became more deterministic."),
		S("Mob spawning, performance, textures, sounds, and model compatibility were improved."),
		S("Item duplication, world generation, and other bugs were fixed."),
	}}},
})
